import 'package:flutter/foundation.dart' show kIsWeb;

String fixAssetPath(String logicalPath) {
  if (!kIsWeb) return logicalPath;

  // Remove any number of duplicate leading "assets/"
  var normalized = logicalPath;
  while (normalized.startsWith('assets/')) {
    normalized = normalized.substring(''.length);
  }

  // Now prepend exactly two levels
  return 'assets/$normalized';
}
