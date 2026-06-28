import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import 'package:drift/drift.dart' as drift;

final _archivedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.watch(databaseProvider);
  return (db.select(db.products)..where((p) => p.isDeleted.equals(true))..orderBy([(p) => drift.OrderingTerm.asc(p.name)])).get();
});

final _archivedSuppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final db = ref.watch(databaseProvider);
  return (db.select(db.suppliers)..where((s) => s.isDeleted.equals(true))..orderBy([(s) => drift.OrderingTerm.asc(s.name)])).get();
});

class ArchivedItemsScreen extends ConsumerWidget {
  const ArchivedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: Text('Archived Items'),
          bottom: TabBar(
            labelColor: context.colors.primary,
            unselectedLabelColor: context.colors.textMuted,
            indicatorColor: context.colors.primary,
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Suppliers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArchivedList<Product>(
              provider: _archivedProductsProvider,
              titleBuilder: (p) => p.name,
              subtitleBuilder: (p) => 'HSN: ${p.hsnCode} | Type: ${p.productType}',
              onRestore: (p) async {
                final db = ref.read(databaseProvider);
                await (db.update(db.products)..where((tbl) => tbl.id.equals(p.id)))
                    .write(ProductsCompanion(isDeleted: drift.Value(false)));
                ref.invalidate(_archivedProductsProvider);
                ref.invalidate(allProductsStreamProvider);
              },
            ),
            _ArchivedList<Supplier>(
              provider: _archivedSuppliersProvider,
              titleBuilder: (s) => s.name,
              subtitleBuilder: (s) => s.phone ?? 'No phone',
              onRestore: (s) async {
                final db = ref.read(databaseProvider);
                await (db.update(db.suppliers)..where((tbl) => tbl.id.equals(s.id)))
                    .write(SuppliersCompanion(isDeleted: drift.Value(false)));
                ref.invalidate(_archivedSuppliersProvider);
                ref.invalidate(allSuppliersStreamProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedList<T> extends ConsumerWidget {
  final AutoDisposeFutureProvider<List<T>>? autoDisposeProvider;
  final FutureProvider<List<T>>? provider;
  final String Function(T) titleBuilder;
  final String Function(T) subtitleBuilder;
  final Future<void> Function(T) onRestore;

  const _ArchivedList({
    this.autoDisposeProvider,
    this.provider,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = provider != null ? ref.watch(provider!) : ref.watch(autoDisposeProvider!);

    return asyncVal.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text('No archived items found.',
                style: TextStyle(color: context.colors.textMuted)),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return ListTile(
              title: Text(titleBuilder(item), style: TextStyle(color: context.colors.textPrimary)),
              subtitle: Text(subtitleBuilder(item), style: TextStyle(color: context.colors.textMuted)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.success,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, 36),
                ),
                onPressed: () async {
                  await onRestore(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item restored successfully')),
                    );
                  }
                },
                child: Text('Restore'),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
