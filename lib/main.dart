import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'seed/mock_data.dart';
import 'core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for mobile; allow landscape on tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ProviderScope(
      child: _SeedWrapper(),
    ),
  );
}

/// Seeds mock data on first launch, then shows the app.
class _SeedWrapper extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SeedWrapper> createState() => _SeedWrapperState();
}

class _SeedWrapperState extends ConsumerState<_SeedWrapper> {
  bool _seeded = false;
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  Future<void> _seed() async {
    if (_seeding) return;
    _seeding = true;
    try {
      final db = ref.read(databaseProvider);
      await MockDataSeeder(db).seedIfEmpty();
    } catch (e) {
      debugPrint('Seeding error: $e');
    } finally {
      if (mounted) setState(() => _seeded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const Scaffold(
          backgroundColor: Color(0xFF0D1117),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF00BFA5)),
                SizedBox(height: 16),
                Text('Initializing PharmaLocal...',
                    style: TextStyle(color: Color(0xFF8B949E))),
              ],
            ),
          ),
        ),
      );
    }
    return const PharmaLocalApp();
  }
}
