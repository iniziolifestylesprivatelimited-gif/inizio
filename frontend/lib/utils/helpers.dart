import 'package:frontend/utils/constants.dart';

String buildImageUrl(String raw) {
  if (raw.isEmpty) return "";
  raw = raw.replaceAll("\\", "/");

  if (raw.startsWith("http")) return raw;

  raw = raw.replaceFirst(RegExp(r"^/+"), "");
  final base = ApiConstants.imageBaseUrl.replaceFirst(RegExp(r"/+$"), "");

  return "$base/$raw";
}
