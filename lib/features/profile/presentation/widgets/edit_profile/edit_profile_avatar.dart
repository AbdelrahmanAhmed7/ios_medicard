import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/auth_shared_widgets.dart';

/// Profile photo stack (photo + edit button). Pure given its inputs; image
/// picking/preview stay on the screen.
class EditProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final bool isPickingImage;
  final bool removeImage;
  final String? imageUrl;
  final VoidCallback onPreviewTap;
  final VoidCallback onEditTap;

  const EditProfileAvatar({
    super.key,
    required this.imageFile,
    required this.isPickingImage,
    required this.removeImage,
    required this.imageUrl,
    required this.onPreviewTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPreviewTap,
          child: Container(
            width: 110.r,
            height: 110.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: imageFile != null
                ? ClipOval(
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  )
                : isPickingImage
                ? Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: kAuthBlue,
                          ),
                        ),
                      ),
                    ),
                  )
                : removeImage
                ? const CircleAvatar(
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 55, color: Colors.white),
                  )
                : _RemoteImage(imageUrl: imageUrl),
          ),
        ),
        PositionedDirectional(
          bottom: 2.h,
          end: 2.w,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEditTap,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: kAuthBlue, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.edit_outlined, size: 18.sp, color: kAuthBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class _RemoteImage extends StatelessWidget {
  final String? imageUrl;

  const _RemoteImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (!hasValidProfileImageUrl(imageUrl)) {
      return const CircleAvatar(
        backgroundColor: Color(0xFFE0E0E0),
        child: Icon(Icons.person, size: 55, color: Colors.white),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) =>
            const Icon(Icons.person, size: 55),
      ),
    );
  }
}

/// True only when [url] points to an actual resource, not a bare domain.
bool hasValidProfileImageUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  // Reject bare-domain URLs like "https://domain.com/" (path is "/" or
  // empty, no meaningful segments)
  final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  return pathSegments.isNotEmpty;
}

/// Full-screen photo preview dialog. No-ops when there is no photo to show.
void showProfileImagePreview(
  BuildContext context, {
  required File? imageFile,
  required String? imageUrl,
  required bool removeImage,
}) {
  final hasPhoto =
      imageFile != null || (!removeImage && hasValidProfileImageUrl(imageUrl));
  if (!hasPhoto) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (dialogContext) {
      return GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        behavior: HitTestBehavior.opaque,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(16.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 280.r,
                  height: 280.r,
                  child: _PreviewPhoto(
                    imageFile: imageFile,
                    imageUrl: imageUrl,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PreviewPhoto extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;

  const _PreviewPhoto({required this.imageFile, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    }
    if (hasValidProfileImageUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) =>
            const Icon(Icons.person, size: 55),
      );
    }
    return const CircleAvatar(
      backgroundColor: Color(0xFFE0E0E0),
      child: Icon(Icons.person, size: 55, color: Colors.white),
    );
  }
}
