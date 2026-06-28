import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'package:drift/drift.dart' hide Column;
import '../../core/theme/app_theme.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';

final securitySettingsProvider = FutureProvider<SecuritySetting?>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.select(db.securitySettings).getSingleOrNull();
});

class SettingsScreen extends ConsumerStatefulWidget {
  SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleAppLock(bool enable, SecuritySetting? current) async {
    final db = ref.read(databaseProvider);
    if (current == null) {
      await db.into(db.securitySettings).insert(
            SecuritySettingsCompanion.insert(isAppLockEnabled: Value(enable)),
          );
    } else {
      await db.update(db.securitySettings).replace(
            current.copyWith(isAppLockEnabled: enable),
          );
    }
    ref.invalidate(securitySettingsProvider);
  }

  Future<void> _setPin(SecuritySetting? current) async {
    final pin = _pinCtrl.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must be exactly 4 digits'), backgroundColor: context.colors.error),
      );
      return;
    }
    final db = ref.read(databaseProvider);
    if (current == null) {
      await db.into(db.securitySettings).insert(
            SecuritySettingsCompanion.insert(securePinHash: Value(pin)),
          );
    } else {
      await db.update(db.securitySettings).replace(
            current.copyWith(securePinHash: Value(pin)),
          );
    }
    _pinCtrl.clear();
    ref.invalidate(securitySettingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Security PIN updated successfully'), backgroundColor: context.colors.success),
      );
    }
  }

  Future<void> _backupDB() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'pharma_local.sqlite'));

      if (!await dbFile.exists()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database file not found.')));
        return;
      }

      final result = await FilePicker.getDirectoryPath(dialogTitle: 'Select Backup Folder');
      if (result != null) {
        final backupFile = File(p.join(result, 'pharma_local_backup_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
        await dbFile.copy(backupFile.path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved to ${backupFile.path}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e'), backgroundColor: context.colors.error));
    }
  }

  Future<void> _restoreDB() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Database Backup',
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dbFolder.path, 'pharma_local.sqlite'));

        await sourceFile.copy(dbFile.path);
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text('Restore Successful'),
              content: Text('Database has been restored. Please restart the app for changes to take effect.'),
              actions: [
                TextButton(
                  onPressed: () => exit(0),
                  child: Text('Restart App'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e'), backgroundColor: context.colors.error));
    }
  }

  Future<void> _generateMockData() async {
    try {
      final db = ref.read(databaseProvider);
      
      final existingCat = await (db.select(db.productCategories)..where((c) => c.name.equals('General Medicine'))).getSingleOrNull();
      final catId = existingCat?.id ?? await db.into(db.productCategories).insert(
        ProductCategoriesCompanion.insert(name: 'General Medicine'),
      );
      
      final existingSup = await (db.select(db.suppliers)..where((s) => s.name.equals('Pharma Distributors Inc.'))).getSingleOrNull();
      final supId = existingSup?.id ?? await db.into(db.suppliers).insert(
        SuppliersCompanion.insert(
          name: 'Pharma Distributors Inc.', 
          contactPerson: Value('John Doe'),
          phone: Value('9876543210'),
        ),
      );

      final p1 = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'Paracetamol 500mg Tablet',
          hsnCode: '3004',
          packagingUnit: Value("10's"),
          categoryId: Value(catId),
        ),
      );

      final p2 = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'Cough Syrup 100ml',
          hsnCode: '300490',
          packagingUnit: Value("100ml"),
          categoryId: Value(catId),
        ),
      );

      await db.into(db.stockBatches).insert(
        StockBatchesCompanion.insert(
          productId: p1,
          batchNumber: 'B1001',
          expiryDate: DateTime.now().add(Duration(days: 365)),
          mrp: 50.0,
          purchaseRate: 35.0,
          currentStock: Value(100),
        ),
      );

      await db.into(db.stockBatches).insert(
        StockBatchesCompanion.insert(
          productId: p2,
          batchNumber: 'C2002',
          expiryDate: DateTime.now().add(Duration(days: 180)),
          mrp: 120.0,
          purchaseRate: 90.0,
          currentStock: Value(50),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mock Data Generated Successfully!'), backgroundColor: context.colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate mock data: $e'), backgroundColor: context.colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(securitySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: context.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: settingsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading settings: $e')),
        data: (settings) {
          final isLocked = settings?.isAppLockEnabled ?? false;
          final hasPin = settings?.securePinHash != null && settings!.securePinHash!.isNotEmpty;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Display Section
              Text('Display', style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Theme Mode', style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                    Consumer(
                      builder: (context, ref, child) {
                        final currentTheme = ref.watch(themeModeProvider);
                        return SegmentedButton<ThemeMode>(
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: context.colors.primary.withValues(alpha: 0.2),
                            selectedForegroundColor: context.colors.primary,
                            backgroundColor: context.colors.background,
                            foregroundColor: context.colors.textSecondary,
                            side: BorderSide(color: context.colors.surfaceBorder),
                          ),
                          segments: [
                            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18), label: Text('Light')),
                            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18), label: Text('Dark')),
                            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 18), label: Text('Auto')),
                          ],
                          selected: {currentTheme},
                          onSelectionChanged: (set) {
                            if (set.isNotEmpty) {
                              ref.read(themeModeProvider.notifier).setThemeMode(set.first);
                            }
                          },
                        );
                      }
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Security Section
              Text('Security', style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Enable App Lock', style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                      subtitle: Text('Require PIN to open the app', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      value: isLocked,
                      activeColor: context.colors.primary,
                      onChanged: (v) => _toggleAppLock(v, settings),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: context.colors.surfaceBorder),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pinCtrl,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: true,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: hasPin ? 'Enter new 4-digit PIN' : 'Create 4-digit PIN',
                                filled: true,
                                fillColor: context.colors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () => _setPin(settings),
                            child: Text('Save PIN', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Data Management Section
              Text('Data Management', style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.download, color: context.colors.textPrimary),
                      title: Text('Backup Database', style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                      subtitle: Text('Export data to your local storage', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      onTap: _backupDB,
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: context.colors.surfaceBorder),
                    ListTile(
                      leading: Icon(Icons.upload, color: context.colors.textPrimary),
                      title: Text('Restore Database', style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                      subtitle: Text('Import data from a backup file', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      onTap: _restoreDB,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Developer Section
              Text('Developer Tools', style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.bug_report, color: context.colors.textPrimary),
                      title: Text('Generate Mock Data', style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                      subtitle: Text('Seed database with sample products and inventory', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      onTap: _generateMockData,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
