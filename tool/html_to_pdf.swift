import AppKit
import Foundation

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: swift tool/html_to_pdf.swift <input.html> <output.pdf>\n", stderr)
    exit(64)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1]).standardizedFileURL
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2]).standardizedFileURL

guard FileManager.default.fileExists(atPath: inputURL.path) else {
    fputs("Input HTML does not exist: \(inputURL.path)\n", stderr)
    exit(66)
}

try? FileManager.default.removeItem(at: outputURL)
try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)

let htmlData = try Data(contentsOf: inputURL)
let importOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
    .documentType: NSAttributedString.DocumentType.html,
    .characterEncoding: String.Encoding.utf8.rawValue,
    .baseURL: inputURL.deletingLastPathComponent(),
]
let attributedDocument = try NSAttributedString(
    data: htmlData,
    options: importOptions,
    documentAttributes: nil
)

// A4 dimensions in PostScript points. The text view is laid out to the exact
// printable width, then AppKit paginates its full vector-text height.
let paperSize = NSSize(width: 595.28, height: 841.89)
let margin: CGFloat = 42
let printableWidth = paperSize.width - (margin * 2)

let textStorage = NSTextStorage(attributedString: attributedDocument)
let layoutManager = NSLayoutManager()
let textContainer = NSTextContainer(
    containerSize: NSSize(
        width: printableWidth,
        height: CGFloat.greatestFiniteMagnitude
    )
)
textContainer.widthTracksTextView = true
textContainer.heightTracksTextView = false
textContainer.lineFragmentPadding = 0
layoutManager.addTextContainer(textContainer)
textStorage.addLayoutManager(layoutManager)

let textView = NSTextView(
    frame: NSRect(x: 0, y: 0, width: printableWidth, height: paperSize.height),
    textContainer: textContainer
)
textView.isEditable = false
textView.isSelectable = true
textView.isHorizontallyResizable = false
textView.isVerticallyResizable = true
textView.textContainerInset = .zero
textView.backgroundColor = .white

layoutManager.ensureLayout(for: textContainer)
let contentRect = layoutManager.usedRect(for: textContainer)
textView.frame = NSRect(
    x: 0,
    y: 0,
    width: printableWidth,
    height: max(1, ceil(contentRect.height))
)

let printInfo = NSPrintInfo()
printInfo.paperSize = paperSize
printInfo.topMargin = margin
printInfo.bottomMargin = margin
printInfo.leftMargin = margin
printInfo.rightMargin = margin
printInfo.horizontalPagination = .fit
printInfo.verticalPagination = .automatic
printInfo.isHorizontallyCentered = true
printInfo.isVerticallyCentered = false
printInfo.jobDisposition = .save
printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = outputURL

let operation = NSPrintOperation(view: textView, printInfo: printInfo)
operation.showsPrintPanel = false
operation.showsProgressPanel = false

guard operation.run(), FileManager.default.fileExists(atPath: outputURL.path) else {
    fputs("AppKit could not create the PDF.\n", stderr)
    exit(1)
}

Swift.print("Created \(outputURL.path)")
