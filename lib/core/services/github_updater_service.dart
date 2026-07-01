import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class GithubUpdaterService {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/kanishk-c/pharma_local/releases/latest';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final dio = Dio();
      final response = await dio.get(_latestReleaseUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        final String tagName = data['tag_name'] ?? '';
        final List assets = data['assets'] ?? [];

        if (tagName.isNotEmpty && assets.isNotEmpty) {
          final packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = packageInfo.version;

          final cleanTag = tagName.replaceAll('v', '').trim();
          final cleanCurrent = currentVersion.replaceAll('v', '').trim();

          if (_isNewerVersion(cleanTag, cleanCurrent)) {
            final apkAsset = assets.firstWhere(
                (asset) => asset['name'].toString().endsWith('.apk'),
                orElse: () => null);

            if (apkAsset != null) {
              final downloadUrl = apkAsset['browser_download_url'];
              if (context.mounted) {
                _showUpdateDialog(context, cleanTag, downloadUrl);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewerVersion(String newVersion, String currentVersion) {
    List<int> newV = newVersion.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    List<int> curV = currentVersion.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final n = i < newV.length ? newV[i] : 0;
      final c = i < curV.length ? curV[i] : 0;
      if (n > c) return true;
      if (n < c) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context, String newVersion, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _UpdateDialogContent(
          newVersion: newVersion,
          downloadUrl: downloadUrl,
        );
      },
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final String newVersion;
  final String downloadUrl;

  const _UpdateDialogContent({
    required this.newVersion,
    required this.downloadUrl,
  });

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _status = 'Downloading...';
    });

    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/pharma_local_update.apk';

      final dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _status = 'Downloading... ${(_progress * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );

      setState(() {
        _status = 'Installing...';
      });

      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done) {
        setState(() {
          _status = 'Error: ${result.message}';
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Failed: $e';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Version ${widget.newVersion} is now available. You must update to continue.', style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          if (_isDownloading)
            Column(
              children: [
                LinearProgressIndicator(value: _progress),
                SizedBox(height: 8),
                Text(_status, style: TextStyle(fontSize: 12)),
              ],
            )
          else
            ElevatedButton(
              onPressed: _startDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 52),
              ),
              child: Text('Download & Install', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }
}
