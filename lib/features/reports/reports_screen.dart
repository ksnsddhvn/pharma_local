import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/database/tables/inventory_adjustments_table.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/csv_export_service.dart';
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          labelPadding: EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.analytics_outlined, size: 16), SizedBox(width: 6), Text('P&L')])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.warning_amber_rounded, size: 16), SizedBox(width: 6), Text('Shortbook')])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.hourglass_bottom, size: 16), SizedBox(width: 6), Text('Expiry')])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.backup_outlined, size: 16), SizedBox(width: 6), Text('Backup')])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _PnLTab(),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${bwp.batch.currentStock} qty',
                          style: TextStyle(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showAdjustmentDialog(context, ref, bwp),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size(0, 0),
                          backgroundColor: color.withValues(alpha: 0.1),
                          foregroundColor: color,
                        ),
                        child: Text('Take Action', style: TextStyle(fontSize: 12)),
                      ),
                    ],
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

  Future<void> _showAdjustmentDialog(BuildContext context, WidgetRef ref, dynamic bwp) async {
    final qtyCtrl = TextEditingController(text: bwp.batch.currentStock.toString());
    final notesCtrl = TextEditingController();
    AdjustmentType selectedType = AdjustmentType.expiredReturned;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.colors.surfaceElevated,
              title: Text('Process Expired Stock', style: TextStyle(fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product: ${bwp.product.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Batch: ${bwp.batch.batchNumber}', style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
                    SizedBox(height: 16),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity to Remove',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<AdjustmentType>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Action Taken',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: AdjustmentType.expiredReturned, child: Text('Returned to Supplier')),
                        DropdownMenuItem(value: AdjustmentType.expiredDisposed, child: Text('Disposed / Thrown Away')),
                        DropdownMenuItem(value: AdjustmentType.other, child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final qty = int.tryParse(qtyCtrl.text) ?? 0;
                    if (qty <= 0 || qty > bwp.batch.currentStock) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid quantity')));
                      return;
                    }
                    try {
                      await ref.read(inventoryAdjustmentDaoProvider).processAdjustment(
                        batchId: bwp.batch.id,
                        quantity: qty,
                        type: selectedType,
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock adjusted successfully')));
                      }
                    } catch (e) {
                      if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
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
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Pharma Local Encrypted Backup',
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup ready'),
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

  Future<void> _exportCsv() async {
    setState(() => _loading = true);
    try {
      final path = await ref.read(csvExportServiceProvider).exportToCsvZip();
      if (mounted) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Pharma Local CSV Export',
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('CSV Export ready'),
            backgroundColor: context.colors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('CSV Export failed: $e'),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _export,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(Icons.lock_outline, size: 18),
                      label: _loading
                          ? Text('Exporting...')
                          : Text('Encrypted Backup'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _exportCsv,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(Icons.table_chart_outlined, size: 18, color: context.colors.primary),
                      label: Text('Export to CSV', style: TextStyle(color: context.colors.primary)),
                    ),
                  ),
                ],
              ),
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

class _PnLTab extends ConsumerWidget {
  const _PnLTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We are defaulting to "Last 30 Days" as per plan
    final pnlAsync = ref.watch(profitLossStatsProvider(30));

    return pnlAsync.when(
      data: (stats) {
        final hasLosses = stats.lossMakers.isNotEmpty;
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Last 30 Days Summary', style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Revenue', amount: stats.revenue, color: context.colors.primary)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'COGS', amount: stats.cogs, color: context.colors.warning)),
              ],
            ),
            SizedBox(height: 12),
            _StatCard(title: 'Gross Profit', amount: stats.grossProfit, color: stats.grossProfit >= 0 ? context.colors.success : context.colors.error),
            SizedBox(height: 24),
            
            Text('Loss Makers & Low Margins (< 5%)', style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            if (!hasLosses)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, color: context.colors.success),
                    SizedBox(width: 12),
                    Expanded(child: Text('All products sold with good margins!', style: TextStyle(color: context.colors.success))),
                  ],
                ),
              )
            else
              ...stats.lossMakers.map((lm) {
                final margin = lm.soldPrice > 0 ? (lm.profit / lm.soldPrice * 100).toStringAsFixed(1) : 'N/A';
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lm.profit < 0 ? context.colors.error.withValues(alpha: 0.5) : context.colors.warning.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(lm.profit < 0 ? Icons.trending_down : Icons.warning_amber_rounded, color: lm.profit < 0 ? context.colors.error : context.colors.warning),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lm.productName, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                            Text('Revenue: ₹${lm.soldPrice.toStringAsFixed(2)} | Cost: ₹${lm.costPrice.toStringAsFixed(2)}', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${lm.profit.toStringAsFixed(2)}', style: TextStyle(color: lm.profit < 0 ? context.colors.error : context.colors.warning, fontWeight: FontWeight.bold)),
                          Text('$margin%', style: TextStyle(color: context.colors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: context.colors.error))),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  const _StatCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
          SizedBox(height: 8),
          Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
