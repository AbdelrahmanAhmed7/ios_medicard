/// Resolves backend image URLs that may come back either as absolute
/// (`https://...`) or relative (`/uploads/...`) paths.
///
/// The API returns relative paths (e.g. `/uploads/providers/x.png`); prepend
/// the server origin so the image can actually load.
String? resolveImageUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return 'https://medicard-api-v2.medicardeg.com/$normalized';
}

bool isSvgImageUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  return path.toLowerCase().endsWith('.svg');
}
