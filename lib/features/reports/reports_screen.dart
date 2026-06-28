import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/stock_batches_dao.dart';
import '../../core/providers.dart';
import '../../core/services/shortbook_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Reports'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.warning_amber_rounded, size: 18), text: 'Shortbook'),
            Tab(icon: Icon(Icons.hourglass_bottom, size: 18), text: 'Expiry'),
            Tab(icon: Icon(Icons.backup_outlined, size: 18), text: 'Backup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _ShortbookTab(),
          _ExpiryTab(),
          _BackupTab(),
        ],
      ),
    );
  }
}

class _ShortbookTab extends ConsumerWidget {
  const _ShortbookTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortbookAsync = ref.watch(shortbookItemsProvider);

    return shortbookAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: context.colors.success),
                SizedBox(height: 12),
                Text('All products are well-stocked!',
                    style: TextStyle(color: context.colors.textSecondary)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final ratio = item.threshold > 0
                ? item.currentStock / item.threshold
                : 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: ratio == 0
                        ? context.colors.expiryCritical.withValues(alpha: 0.4)
                        : context.colors.warning.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.product.name,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ratio == 0
                              ? context.colors.expiryCritical.withValues(alpha: 0.15)
                              : context.colors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ratio == 0 ? 'OUT OF STOCK' : 'LOW STOCK',
                          style: TextStyle(
                            color: ratio == 0
                                ? context.colors.expiryCritical
                                : context.colors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Current: ${item.currentStock}',
                        style: TextStyle(
                            color: context.colors.textSecondary, fontSize: 12),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Min: ${item.threshold.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: context.colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      backgroundColor: context.colors.surfaceBorder,
                      color: ratio == 0
                          ? context.colors.expiryCritical
                          : context.colors.warning,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: context.colors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ExpiryTab extends ConsumerWidget {
  const _ExpiryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiryAsync = ref.watch(expiringBatchesProvider(90));

    return expiryAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: context.colors.success),
                SizedBox(height: 12),
                Text('No batches expiring in 90 days',
                    style: TextStyle(color: context.colors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final bwp = items[i];
            final days =
                bwp.batch.expiryDate.difference(DateTime.now()).inDays;
            final color = days < 0
                ? context.colors.expiryCritical
                : days <= 30
                    ? context.colors.expiryCritical
                    : context.colors.expiryWarning;

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bwp.product.name,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('Batch: ${bwp.batch.batchNumber}',
                            style: TextStyle(
                                color: context.colors.textMuted, fontSize: 11)),
                        Text(
                          AppFormatters.expiryLabel(bwp.batch.expiryDate),
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text('${bwp.batch.currentStock} qty',
                      style: TextStyle(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: context.colors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _BackupTab extends ConsumerStatefulWidget {
  const _BackupTab();

  @override
  ConsumerState<_BackupTab> createState() => _BackupTabState();
}

class _BackupTabState extends ConsumerState<_BackupTab> {
  final _passphraseCtrl = TextEditingController();
  bool _loading = false;
  String? _lastBackupPath;
  bool _obscure = true;

  @override
  void dispose() {
    _passphraseCtrl.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_passphraseCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Passphrase must be at least 6 characters'),
          backgroundColor: context.colors.warning));
      return;
    }
    setState(() => _loading = true);
    try {
      final path = await ref.read(backupServiceProvider).exportBackup(
            passphrase: _passphraseCtrl.text,
          );
      setState(() => _lastBackupPath = path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup saved: $path'),
            backgroundColor: context.colors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: context.colors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: context.colors.primary, size: 20),
                  SizedBox(width: 10),
                  Text('AES-256 Encrypted Backup',
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Your database will be encrypted with AES-256 and saved '
                'to your documents folder. Use the same passphrase to restore.',
                style: TextStyle(
                    color: context.colors.textSecondary, fontSize: 12, height: 1.5),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passphraseCtrl,
                obscureText: _obscure,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Backup Passphrase',
                  hintText: 'Min 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: context.colors.textMuted, size: 18),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _export,
                icon: Icon(Icons.download_outlined, size: 18),
                label: _loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Text('Export Backup'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(48)),
              ),
              if (_lastBackupPath != null) ...[
                SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(backupServiceProvider)
                      .shareBackup(_lastBackupPath!),
                  icon: Icon(Icons.share_outlined, size: 18),
                  label: Text('Share Backup File'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(48)),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.info.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: context.colors.info, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Transfer the .pharmaenc file to any device and use the same passphrase to restore. '
                  'Keep your passphrase safe — it cannot be recovered.',
                  style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
