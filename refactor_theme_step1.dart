import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  
  final regexConst = RegExp(r'const\s+([A-Za-z0-9_]+\(.*AppColors\.[A-Za-z0-9_]+.*)');
  // We actually need a robust way to remove const. A simple way is to remove all `const ` before widgets that contain AppColors. 
  // It's easier to just find `const ` and if it's on a widget that uses AppColors on the same line, remove it. But it could span multiple lines.

  // Let's just do a naive replace of `AppColors.` to `context.colors.` first, then we can use `flutter analyze` to find all the invalid `const` and remove them.
  // Wait, if we use `flutter analyze`, it outputs `error • The constructor being called isn't a const constructor`. We can parse that and fix it.
  
  for (final file in libDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('app_theme.dart')) {
      String content = await file.readAsString();
      if (content.contains('AppColors.')) {
        content = content.replaceAll('AppColors.', 'context.colors.');
        
        // Also import app_theme.dart if not present (since we need the extension)
        if (!content.contains('core/theme/app_theme.dart')) {
          // Find last import
          final lastImport = content.lastIndexOf(RegExp(r'^import .*;\n', multiLine: true));
          if (lastImport != -1) {
            final insertPos = content.indexOf('\n', lastImport) + 1;
            // determine relative path to core/theme/app_theme.dart
            // Since it's complicated, we'll just use a hack: import 'package:pharma_local/core/theme/app_theme.dart';
            content = "${content.substring(0, insertPos)}import 'package:pharma_local/core/theme/app_theme.dart';\n${content.substring(insertPos)}";
          }
        } else {
            // Already imported, wait, if they import app_theme.dart using relative path it's fine.
        }
        
        await file.writeAsString(content);
      }
    }
  }
}
