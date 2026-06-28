import 'dart:io';

void main() async {
  // We run flutter analyze and parse the output
  final process = await Process.run('flutter', ['analyze']);
  final lines = process.stdout.toString().split('\n');
  
  Map<String, Set<int>> filesToFix = {};
  
  for (final line in lines) {
    if (line.contains('invalid_constant') || line.contains('non_constant_default_value')) {
      final parts = line.split(' • ');
      if (parts.length >= 3) {
        final loc = parts[1].trim(); // e.g. lib/features/settings/settings_screen.dart:70:93
        final locParts = loc.split(':');
        if (locParts.length >= 2) {
          final file = locParts[0];
          final lineNum = int.tryParse(locParts[1]);
          if (file.isNotEmpty && lineNum != null) {
            filesToFix.putIfAbsent(file, () => {}).add(lineNum);
          }
        }
      }
    }
  }

  for (final file in filesToFix.keys) {
    final f = File(file);
    if (await f.exists()) {
      final fileLines = await f.readAsLines();
      final targetLines = filesToFix[file]!.toList()..sort();
      
      for (final lineNum in targetLines) {
        final idx = lineNum - 1;
        if (idx >= 0 && idx < fileLines.length) {
          // Naive replace 'const ' with ''
          // But 'const' could be on the line before
          fileLines[idx] = fileLines[idx].replaceAll('const ', '');
          
          if (idx > 0 && !fileLines[idx].contains('const ') && !fileLines[idx].trim().startsWith('const')) {
             // Check the line before as well, just in case
             if (fileLines[idx-1].trim() == 'const') {
               fileLines[idx-1] = fileLines[idx-1].replaceAll('const', '');
             } else if (fileLines[idx-1].contains('const ')) {
               // Only replace if it looks like it belongs to this widget, a bit risky but we have to.
               fileLines[idx-1] = fileLines[idx-1].replaceAll(RegExp(r'\bconst\s+'), '');
             }
          }
        }
      }
      
      await f.writeAsString(fileLines.join('\n'));
    }
  }
}
