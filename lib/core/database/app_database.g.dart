// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compositionMeta = const VerificationMeta(
    'composition',
  );
  @override
  late final GeneratedColumn<String> composition = GeneratedColumn<String>(
    'composition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsnCodeMeta = const VerificationMeta(
    'hsnCode',
  );
  @override
  late final GeneratedColumn<String> hsnCode = GeneratedColumn<String>(
    'hsn_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProductCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('otc'),
  ).withConverter<ProductCategory>($ProductsTable.$convertercategory);
  static const VerificationMeta _rackLocationMeta = const VerificationMeta(
    'rackLocation',
  );
  @override
  late final GeneratedColumn<String> rackLocation = GeneratedColumn<String>(
    'rack_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minStockThresholdMeta = const VerificationMeta(
    'minStockThreshold',
  );
  @override
  late final GeneratedColumn<double> minStockThreshold =
      GeneratedColumn<double>(
        'min_stock_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(5.0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    composition,
    hsnCode,
    category,
    rackLocation,
    minStockThreshold,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('composition')) {
      context.handle(
        _compositionMeta,
        composition.isAcceptableOrUnknown(
          data['composition']!,
          _compositionMeta,
        ),
      );
    }
    if (data.containsKey('hsn_code')) {
      context.handle(
        _hsnCodeMeta,
        hsnCode.isAcceptableOrUnknown(data['hsn_code']!, _hsnCodeMeta),
      );
    }
    if (data.containsKey('rack_location')) {
      context.handle(
        _rackLocationMeta,
        rackLocation.isAcceptableOrUnknown(
          data['rack_location']!,
          _rackLocationMeta,
        ),
      );
    }
    if (data.containsKey('min_stock_threshold')) {
      context.handle(
        _minStockThresholdMeta,
        minStockThreshold.isAcceptableOrUnknown(
          data['min_stock_threshold']!,
          _minStockThresholdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      composition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}composition'],
      ),
      hsnCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_code'],
      ),
      category: $ProductsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      rackLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rack_location'],
      ),
      minStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_stock_threshold'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProductCategory, String, String>
  $convertercategory = const EnumNameConverter<ProductCategory>(
    ProductCategory.values,
  );
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final String? composition;
  final String? hsnCode;
  final ProductCategory category;
  final String? rackLocation;
  final double minStockThreshold;
  const Product({
    required this.id,
    required this.name,
    this.composition,
    this.hsnCode,
    required this.category,
    this.rackLocation,
    required this.minStockThreshold,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || composition != null) {
      map['composition'] = Variable<String>(composition);
    }
    if (!nullToAbsent || hsnCode != null) {
      map['hsn_code'] = Variable<String>(hsnCode);
    }
    {
      map['category'] = Variable<String>(
        $ProductsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || rackLocation != null) {
      map['rack_location'] = Variable<String>(rackLocation);
    }
    map['min_stock_threshold'] = Variable<double>(minStockThreshold);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      composition: composition == null && nullToAbsent
          ? const Value.absent()
          : Value(composition),
      hsnCode: hsnCode == null && nullToAbsent
          ? const Value.absent()
          : Value(hsnCode),
      category: Value(category),
      rackLocation: rackLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(rackLocation),
      minStockThreshold: Value(minStockThreshold),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      composition: serializer.fromJson<String?>(json['composition']),
      hsnCode: serializer.fromJson<String?>(json['hsnCode']),
      category: $ProductsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      rackLocation: serializer.fromJson<String?>(json['rackLocation']),
      minStockThreshold: serializer.fromJson<double>(json['minStockThreshold']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'composition': serializer.toJson<String?>(composition),
      'hsnCode': serializer.toJson<String?>(hsnCode),
      'category': serializer.toJson<String>(
        $ProductsTable.$convertercategory.toJson(category),
      ),
      'rackLocation': serializer.toJson<String?>(rackLocation),
      'minStockThreshold': serializer.toJson<double>(minStockThreshold),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    Value<String?> composition = const Value.absent(),
    Value<String?> hsnCode = const Value.absent(),
    ProductCategory? category,
    Value<String?> rackLocation = const Value.absent(),
    double? minStockThreshold,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    composition: composition.present ? composition.value : this.composition,
    hsnCode: hsnCode.present ? hsnCode.value : this.hsnCode,
    category: category ?? this.category,
    rackLocation: rackLocation.present ? rackLocation.value : this.rackLocation,
    minStockThreshold: minStockThreshold ?? this.minStockThreshold,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      composition: data.composition.present
          ? data.composition.value
          : this.composition,
      hsnCode: data.hsnCode.present ? data.hsnCode.value : this.hsnCode,
      category: data.category.present ? data.category.value : this.category,
      rackLocation: data.rackLocation.present
          ? data.rackLocation.value
          : this.rackLocation,
      minStockThreshold: data.minStockThreshold.present
          ? data.minStockThreshold.value
          : this.minStockThreshold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('composition: $composition, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('category: $category, ')
          ..write('rackLocation: $rackLocation, ')
          ..write('minStockThreshold: $minStockThreshold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    composition,
    hsnCode,
    category,
    rackLocation,
    minStockThreshold,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.composition == this.composition &&
          other.hsnCode == this.hsnCode &&
          other.category == this.category &&
          other.rackLocation == this.rackLocation &&
          other.minStockThreshold == this.minStockThreshold);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> composition;
  final Value<String?> hsnCode;
  final Value<ProductCategory> category;
  final Value<String?> rackLocation;
  final Value<double> minStockThreshold;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.composition = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.category = const Value.absent(),
    this.rackLocation = const Value.absent(),
    this.minStockThreshold = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.composition = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.category = const Value.absent(),
    this.rackLocation = const Value.absent(),
    this.minStockThreshold = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? composition,
    Expression<String>? hsnCode,
    Expression<String>? category,
    Expression<String>? rackLocation,
    Expression<double>? minStockThreshold,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (composition != null) 'composition': composition,
      if (hsnCode != null) 'hsn_code': hsnCode,
      if (category != null) 'category': category,
      if (rackLocation != null) 'rack_location': rackLocation,
      if (minStockThreshold != null) 'min_stock_threshold': minStockThreshold,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? composition,
    Value<String?>? hsnCode,
    Value<ProductCategory>? category,
    Value<String?>? rackLocation,
    Value<double>? minStockThreshold,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      composition: composition ?? this.composition,
      hsnCode: hsnCode ?? this.hsnCode,
      category: category ?? this.category,
      rackLocation: rackLocation ?? this.rackLocation,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (composition.present) {
      map['composition'] = Variable<String>(composition.value);
    }
    if (hsnCode.present) {
      map['hsn_code'] = Variable<String>(hsnCode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ProductsTable.$convertercategory.toSql(category.value),
      );
    }
    if (rackLocation.present) {
      map['rack_location'] = Variable<String>(rackLocation.value);
    }
    if (minStockThreshold.present) {
      map['min_stock_threshold'] = Variable<double>(minStockThreshold.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('composition: $composition, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('category: $category, ')
          ..write('rackLocation: $rackLocation, ')
          ..write('minStockThreshold: $minStockThreshold')
          ..write(')'))
        .toString();
  }
}

class $StockBatchesTable extends StockBatches
    with TableInfo<$StockBatchesTable, StockBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mrpMeta = const VerificationMeta('mrp');
  @override
  late final GeneratedColumn<double> mrp = GeneratedColumn<double>(
    'mrp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseRateMeta = const VerificationMeta(
    'purchaseRate',
  );
  @override
  late final GeneratedColumn<double> purchaseRate = GeneratedColumn<double>(
    'purchase_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstPercentageMeta = const VerificationMeta(
    'gstPercentage',
  );
  @override
  late final GeneratedColumn<double> gstPercentage = GeneratedColumn<double>(
    'gst_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(12.0),
  );
  static const VerificationMeta _currentStockMeta = const VerificationMeta(
    'currentStock',
  );
  @override
  late final GeneratedColumn<int> currentStock = GeneratedColumn<int>(
    'current_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOpeningStockMeta = const VerificationMeta(
    'isOpeningStock',
  );
  @override
  late final GeneratedColumn<bool> isOpeningStock = GeneratedColumn<bool>(
    'is_opening_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opening_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    batchNumber,
    expiryDate,
    mrp,
    purchaseRate,
    gstPercentage,
    currentStock,
    barcode,
    isOpeningStock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('mrp')) {
      context.handle(
        _mrpMeta,
        mrp.isAcceptableOrUnknown(data['mrp']!, _mrpMeta),
      );
    } else if (isInserting) {
      context.missing(_mrpMeta);
    }
    if (data.containsKey('purchase_rate')) {
      context.handle(
        _purchaseRateMeta,
        purchaseRate.isAcceptableOrUnknown(
          data['purchase_rate']!,
          _purchaseRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseRateMeta);
    }
    if (data.containsKey('gst_percentage')) {
      context.handle(
        _gstPercentageMeta,
        gstPercentage.isAcceptableOrUnknown(
          data['gst_percentage']!,
          _gstPercentageMeta,
        ),
      );
    }
    if (data.containsKey('current_stock')) {
      context.handle(
        _currentStockMeta,
        currentStock.isAcceptableOrUnknown(
          data['current_stock']!,
          _currentStockMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('is_opening_stock')) {
      context.handle(
        _isOpeningStockMeta,
        isOpeningStock.isAcceptableOrUnknown(
          data['is_opening_stock']!,
          _isOpeningStockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      mrp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mrp'],
      )!,
      purchaseRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_rate'],
      )!,
      gstPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_percentage'],
      )!,
      currentStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stock'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      isOpeningStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opening_stock'],
      )!,
    );
  }

  @override
  $StockBatchesTable createAlias(String alias) {
    return $StockBatchesTable(attachedDatabase, alias);
  }
}

class StockBatch extends DataClass implements Insertable<StockBatch> {
  final int id;
  final int productId;
  final String batchNumber;
  final DateTime expiryDate;
  final double mrp;
  final double purchaseRate;
  final double gstPercentage;
  final int currentStock;
  final String? barcode;
  final bool isOpeningStock;
  const StockBatch({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.expiryDate,
    required this.mrp,
    required this.purchaseRate,
    required this.gstPercentage,
    required this.currentStock,
    this.barcode,
    required this.isOpeningStock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['batch_number'] = Variable<String>(batchNumber);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['mrp'] = Variable<double>(mrp);
    map['purchase_rate'] = Variable<double>(purchaseRate);
    map['gst_percentage'] = Variable<double>(gstPercentage);
    map['current_stock'] = Variable<int>(currentStock);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['is_opening_stock'] = Variable<bool>(isOpeningStock);
    return map;
  }

  StockBatchesCompanion toCompanion(bool nullToAbsent) {
    return StockBatchesCompanion(
      id: Value(id),
      productId: Value(productId),
      batchNumber: Value(batchNumber),
      expiryDate: Value(expiryDate),
      mrp: Value(mrp),
      purchaseRate: Value(purchaseRate),
      gstPercentage: Value(gstPercentage),
      currentStock: Value(currentStock),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      isOpeningStock: Value(isOpeningStock),
    );
  }

  factory StockBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockBatch(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      mrp: serializer.fromJson<double>(json['mrp']),
      purchaseRate: serializer.fromJson<double>(json['purchaseRate']),
      gstPercentage: serializer.fromJson<double>(json['gstPercentage']),
      currentStock: serializer.fromJson<int>(json['currentStock']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      isOpeningStock: serializer.fromJson<bool>(json['isOpeningStock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'mrp': serializer.toJson<double>(mrp),
      'purchaseRate': serializer.toJson<double>(purchaseRate),
      'gstPercentage': serializer.toJson<double>(gstPercentage),
      'currentStock': serializer.toJson<int>(currentStock),
      'barcode': serializer.toJson<String?>(barcode),
      'isOpeningStock': serializer.toJson<bool>(isOpeningStock),
    };
  }

  StockBatch copyWith({
    int? id,
    int? productId,
    String? batchNumber,
    DateTime? expiryDate,
    double? mrp,
    double? purchaseRate,
    double? gstPercentage,
    int? currentStock,
    Value<String?> barcode = const Value.absent(),
    bool? isOpeningStock,
  }) => StockBatch(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    batchNumber: batchNumber ?? this.batchNumber,
    expiryDate: expiryDate ?? this.expiryDate,
    mrp: mrp ?? this.mrp,
    purchaseRate: purchaseRate ?? this.purchaseRate,
    gstPercentage: gstPercentage ?? this.gstPercentage,
    currentStock: currentStock ?? this.currentStock,
    barcode: barcode.present ? barcode.value : this.barcode,
    isOpeningStock: isOpeningStock ?? this.isOpeningStock,
  );
  StockBatch copyWithCompanion(StockBatchesCompanion data) {
    return StockBatch(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      mrp: data.mrp.present ? data.mrp.value : this.mrp,
      purchaseRate: data.purchaseRate.present
          ? data.purchaseRate.value
          : this.purchaseRate,
      gstPercentage: data.gstPercentage.present
          ? data.gstPercentage.value
          : this.gstPercentage,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      isOpeningStock: data.isOpeningStock.present
          ? data.isOpeningStock.value
          : this.isOpeningStock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockBatch(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('mrp: $mrp, ')
          ..write('purchaseRate: $purchaseRate, ')
          ..write('gstPercentage: $gstPercentage, ')
          ..write('currentStock: $currentStock, ')
          ..write('barcode: $barcode, ')
          ..write('isOpeningStock: $isOpeningStock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    batchNumber,
    expiryDate,
    mrp,
    purchaseRate,
    gstPercentage,
    currentStock,
    barcode,
    isOpeningStock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockBatch &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.batchNumber == this.batchNumber &&
          other.expiryDate == this.expiryDate &&
          other.mrp == this.mrp &&
          other.purchaseRate == this.purchaseRate &&
          other.gstPercentage == this.gstPercentage &&
          other.currentStock == this.currentStock &&
          other.barcode == this.barcode &&
          other.isOpeningStock == this.isOpeningStock);
}

class StockBatchesCompanion extends UpdateCompanion<StockBatch> {
  final Value<int> id;
  final Value<int> productId;
  final Value<String> batchNumber;
  final Value<DateTime> expiryDate;
  final Value<double> mrp;
  final Value<double> purchaseRate;
  final Value<double> gstPercentage;
  final Value<int> currentStock;
  final Value<String?> barcode;
  final Value<bool> isOpeningStock;
  const StockBatchesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.mrp = const Value.absent(),
    this.purchaseRate = const Value.absent(),
    this.gstPercentage = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isOpeningStock = const Value.absent(),
  });
  StockBatchesCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required String batchNumber,
    required DateTime expiryDate,
    required double mrp,
    required double purchaseRate,
    this.gstPercentage = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.barcode = const Value.absent(),
    this.isOpeningStock = const Value.absent(),
  }) : productId = Value(productId),
       batchNumber = Value(batchNumber),
       expiryDate = Value(expiryDate),
       mrp = Value(mrp),
       purchaseRate = Value(purchaseRate);
  static Insertable<StockBatch> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? batchNumber,
    Expression<DateTime>? expiryDate,
    Expression<double>? mrp,
    Expression<double>? purchaseRate,
    Expression<double>? gstPercentage,
    Expression<int>? currentStock,
    Expression<String>? barcode,
    Expression<bool>? isOpeningStock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (mrp != null) 'mrp': mrp,
      if (purchaseRate != null) 'purchase_rate': purchaseRate,
      if (gstPercentage != null) 'gst_percentage': gstPercentage,
      if (currentStock != null) 'current_stock': currentStock,
      if (barcode != null) 'barcode': barcode,
      if (isOpeningStock != null) 'is_opening_stock': isOpeningStock,
    });
  }

  StockBatchesCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<String>? batchNumber,
    Value<DateTime>? expiryDate,
    Value<double>? mrp,
    Value<double>? purchaseRate,
    Value<double>? gstPercentage,
    Value<int>? currentStock,
    Value<String?>? barcode,
    Value<bool>? isOpeningStock,
  }) {
    return StockBatchesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      mrp: mrp ?? this.mrp,
      purchaseRate: purchaseRate ?? this.purchaseRate,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      currentStock: currentStock ?? this.currentStock,
      barcode: barcode ?? this.barcode,
      isOpeningStock: isOpeningStock ?? this.isOpeningStock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (mrp.present) {
      map['mrp'] = Variable<double>(mrp.value);
    }
    if (purchaseRate.present) {
      map['purchase_rate'] = Variable<double>(purchaseRate.value);
    }
    if (gstPercentage.present) {
      map['gst_percentage'] = Variable<double>(gstPercentage.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<int>(currentStock.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (isOpeningStock.present) {
      map['is_opening_stock'] = Variable<bool>(isOpeningStock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockBatchesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('mrp: $mrp, ')
          ..write('purchaseRate: $purchaseRate, ')
          ..write('gstPercentage: $gstPercentage, ')
          ..write('currentStock: $currentStock, ')
          ..write('barcode: $barcode, ')
          ..write('isOpeningStock: $isOpeningStock')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinNumberMeta = const VerificationMeta(
    'gstinNumber',
  );
  @override
  late final GeneratedColumn<String> gstinNumber = GeneratedColumn<String>(
    'gstin_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactPerson,
    phone,
    gstinNumber,
    address,
    currentBalance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('gstin_number')) {
      context.handle(
        _gstinNumberMeta,
        gstinNumber.isAcceptableOrUnknown(
          data['gstin_number']!,
          _gstinNumberMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      gstinNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin_number'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? gstinNumber;
  final String? address;
  final double currentBalance;
  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.gstinNumber,
    this.address,
    required this.currentBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || gstinNumber != null) {
      map['gstin_number'] = Variable<String>(gstinNumber);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['current_balance'] = Variable<double>(currentBalance);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      gstinNumber: gstinNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(gstinNumber),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      currentBalance: Value(currentBalance),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      phone: serializer.fromJson<String?>(json['phone']),
      gstinNumber: serializer.fromJson<String?>(json['gstinNumber']),
      address: serializer.fromJson<String?>(json['address']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'phone': serializer.toJson<String?>(phone),
      'gstinNumber': serializer.toJson<String?>(gstinNumber),
      'address': serializer.toJson<String?>(address),
      'currentBalance': serializer.toJson<double>(currentBalance),
    };
  }

  Supplier copyWith({
    int? id,
    String? name,
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> gstinNumber = const Value.absent(),
    Value<String?> address = const Value.absent(),
    double? currentBalance,
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    phone: phone.present ? phone.value : this.phone,
    gstinNumber: gstinNumber.present ? gstinNumber.value : this.gstinNumber,
    address: address.present ? address.value : this.address,
    currentBalance: currentBalance ?? this.currentBalance,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      gstinNumber: data.gstinNumber.present
          ? data.gstinNumber.value
          : this.gstinNumber,
      address: data.address.present ? data.address.value : this.address,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('gstinNumber: $gstinNumber, ')
          ..write('address: $address, ')
          ..write('currentBalance: $currentBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactPerson,
    phone,
    gstinNumber,
    address,
    currentBalance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.gstinNumber == this.gstinNumber &&
          other.address == this.address &&
          other.currentBalance == this.currentBalance);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String?> phone;
  final Value<String?> gstinNumber;
  final Value<String?> address;
  final Value<double> currentBalance;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.gstinNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.currentBalance = const Value.absent(),
  });
  SuppliersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.gstinNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.currentBalance = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Supplier> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? gstinNumber,
    Expression<String>? address,
    Expression<double>? currentBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (gstinNumber != null) 'gstin_number': gstinNumber,
      if (address != null) 'address': address,
      if (currentBalance != null) 'current_balance': currentBalance,
    });
  }

  SuppliersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contactPerson,
    Value<String?>? phone,
    Value<String?>? gstinNumber,
    Value<String?>? address,
    Value<double>? currentBalance,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      gstinNumber: gstinNumber ?? this.gstinNumber,
      address: address ?? this.address,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (gstinNumber.present) {
      map['gstin_number'] = Variable<String>(gstinNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('gstinNumber: $gstinNumber, ')
          ..write('address: $address, ')
          ..write('currentBalance: $currentBalance')
          ..write(')'))
        .toString();
  }
}

class $SupplierLedgersTable extends SupplierLedgers
    with TableInfo<$SupplierLedgersTable, SupplierLedger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierLedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LedgerTxType, String>
  transactionType =
      GeneratedColumn<String>(
        'transaction_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LedgerTxType>(
        $SupplierLedgersTable.$convertertransactionType,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNoteMeta = const VerificationMeta(
    'referenceNote',
  );
  @override
  late final GeneratedColumn<String> referenceNote = GeneratedColumn<String>(
    'reference_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    transactionType,
    amount,
    balanceAfter,
    invoiceNumber,
    referenceNote,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_ledgers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierLedger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('reference_note')) {
      context.handle(
        _referenceNoteMeta,
        referenceNote.isAcceptableOrUnknown(
          data['reference_note']!,
          _referenceNoteMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierLedger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierLedger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_id'],
      )!,
      transactionType: $SupplierLedgersTable.$convertertransactionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      referenceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_note'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $SupplierLedgersTable createAlias(String alias) {
    return $SupplierLedgersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LedgerTxType, String, String>
  $convertertransactionType = const EnumNameConverter<LedgerTxType>(
    LedgerTxType.values,
  );
}

class SupplierLedger extends DataClass implements Insertable<SupplierLedger> {
  final int id;
  final int supplierId;
  final LedgerTxType transactionType;
  final double amount;
  final double balanceAfter;
  final String? invoiceNumber;
  final String? referenceNote;
  final DateTime timestamp;
  const SupplierLedger({
    required this.id,
    required this.supplierId,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    this.invoiceNumber,
    this.referenceNote,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['supplier_id'] = Variable<int>(supplierId);
    {
      map['transaction_type'] = Variable<String>(
        $SupplierLedgersTable.$convertertransactionType.toSql(transactionType),
      );
    }
    map['amount'] = Variable<double>(amount);
    map['balance_after'] = Variable<double>(balanceAfter);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    if (!nullToAbsent || referenceNote != null) {
      map['reference_note'] = Variable<String>(referenceNote);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  SupplierLedgersCompanion toCompanion(bool nullToAbsent) {
    return SupplierLedgersCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      transactionType: Value(transactionType),
      amount: Value(amount),
      balanceAfter: Value(balanceAfter),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      referenceNote: referenceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNote),
      timestamp: Value(timestamp),
    );
  }

  factory SupplierLedger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierLedger(
      id: serializer.fromJson<int>(json['id']),
      supplierId: serializer.fromJson<int>(json['supplierId']),
      transactionType: $SupplierLedgersTable.$convertertransactionType.fromJson(
        serializer.fromJson<String>(json['transactionType']),
      ),
      amount: serializer.fromJson<double>(json['amount']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      referenceNote: serializer.fromJson<String?>(json['referenceNote']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supplierId': serializer.toJson<int>(supplierId),
      'transactionType': serializer.toJson<String>(
        $SupplierLedgersTable.$convertertransactionType.toJson(transactionType),
      ),
      'amount': serializer.toJson<double>(amount),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'referenceNote': serializer.toJson<String?>(referenceNote),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  SupplierLedger copyWith({
    int? id,
    int? supplierId,
    LedgerTxType? transactionType,
    double? amount,
    double? balanceAfter,
    Value<String?> invoiceNumber = const Value.absent(),
    Value<String?> referenceNote = const Value.absent(),
    DateTime? timestamp,
  }) => SupplierLedger(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    transactionType: transactionType ?? this.transactionType,
    amount: amount ?? this.amount,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    referenceNote: referenceNote.present
        ? referenceNote.value
        : this.referenceNote,
    timestamp: timestamp ?? this.timestamp,
  );
  SupplierLedger copyWithCompanion(SupplierLedgersCompanion data) {
    return SupplierLedger(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      referenceNote: data.referenceNote.present
          ? data.referenceNote.value
          : this.referenceNote,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierLedger(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('referenceNote: $referenceNote, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    transactionType,
    amount,
    balanceAfter,
    invoiceNumber,
    referenceNote,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierLedger &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.transactionType == this.transactionType &&
          other.amount == this.amount &&
          other.balanceAfter == this.balanceAfter &&
          other.invoiceNumber == this.invoiceNumber &&
          other.referenceNote == this.referenceNote &&
          other.timestamp == this.timestamp);
}

class SupplierLedgersCompanion extends UpdateCompanion<SupplierLedger> {
  final Value<int> id;
  final Value<int> supplierId;
  final Value<LedgerTxType> transactionType;
  final Value<double> amount;
  final Value<double> balanceAfter;
  final Value<String?> invoiceNumber;
  final Value<String?> referenceNote;
  final Value<DateTime> timestamp;
  const SupplierLedgersCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.referenceNote = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SupplierLedgersCompanion.insert({
    this.id = const Value.absent(),
    required int supplierId,
    required LedgerTxType transactionType,
    required double amount,
    required double balanceAfter,
    this.invoiceNumber = const Value.absent(),
    this.referenceNote = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : supplierId = Value(supplierId),
       transactionType = Value(transactionType),
       amount = Value(amount),
       balanceAfter = Value(balanceAfter);
  static Insertable<SupplierLedger> custom({
    Expression<int>? id,
    Expression<int>? supplierId,
    Expression<String>? transactionType,
    Expression<double>? amount,
    Expression<double>? balanceAfter,
    Expression<String>? invoiceNumber,
    Expression<String>? referenceNote,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (amount != null) 'amount': amount,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (referenceNote != null) 'reference_note': referenceNote,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SupplierLedgersCompanion copyWith({
    Value<int>? id,
    Value<int>? supplierId,
    Value<LedgerTxType>? transactionType,
    Value<double>? amount,
    Value<double>? balanceAfter,
    Value<String?>? invoiceNumber,
    Value<String?>? referenceNote,
    Value<DateTime>? timestamp,
  }) {
    return SupplierLedgersCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      referenceNote: referenceNote ?? this.referenceNote,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(
        $SupplierLedgersTable.$convertertransactionType.toSql(
          transactionType.value,
        ),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (referenceNote.present) {
      map['reference_note'] = Variable<String>(referenceNote.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierLedgersCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('transactionType: $transactionType, ')
          ..write('amount: $amount, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('referenceNote: $referenceNote, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $SalesInvoicesTable extends SalesInvoices
    with TableInfo<$SalesInvoicesTable, SalesInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doctorNameMeta = const VerificationMeta(
    'doctorName',
  );
  @override
  late final GeneratedColumn<String> doctorName = GeneratedColumn<String>(
    'doctor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalGstMeta = const VerificationMeta(
    'totalGst',
  );
  @override
  late final GeneratedColumn<double> totalGst = GeneratedColumn<double>(
    'total_gst',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDiscountMeta = const VerificationMeta(
    'totalDiscount',
  );
  @override
  late final GeneratedColumn<double> totalDiscount = GeneratedColumn<double>(
    'total_discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode, String> paymentMode =
      GeneratedColumn<String>(
        'payment_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('cash'),
      ).withConverter<PaymentMode>($SalesInvoicesTable.$converterpaymentMode);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceNumber,
    customerName,
    customerPhone,
    doctorName,
    createdAt,
    subtotal,
    totalGst,
    totalDiscount,
    totalAmount,
    paymentMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesInvoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('doctor_name')) {
      context.handle(
        _doctorNameMeta,
        doctorName.isAcceptableOrUnknown(data['doctor_name']!, _doctorNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('total_gst')) {
      context.handle(
        _totalGstMeta,
        totalGst.isAcceptableOrUnknown(data['total_gst']!, _totalGstMeta),
      );
    } else if (isInserting) {
      context.missing(_totalGstMeta);
    }
    if (data.containsKey('total_discount')) {
      context.handle(
        _totalDiscountMeta,
        totalDiscount.isAcceptableOrUnknown(
          data['total_discount']!,
          _totalDiscountMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesInvoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      doctorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      totalGst: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_gst'],
      )!,
      totalDiscount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_discount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentMode: $SalesInvoicesTable.$converterpaymentMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_mode'],
        )!,
      ),
    );
  }

  @override
  $SalesInvoicesTable createAlias(String alias) {
    return $SalesInvoicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMode, String, String> $converterpaymentMode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
}

class SalesInvoice extends DataClass implements Insertable<SalesInvoice> {
  final int id;
  final String invoiceNumber;
  final String? customerName;
  final String? customerPhone;
  final String? doctorName;
  final DateTime createdAt;
  final double subtotal;
  final double totalGst;
  final double totalDiscount;
  final double totalAmount;
  final PaymentMode paymentMode;
  const SalesInvoice({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
    this.customerPhone,
    this.doctorName,
    required this.createdAt,
    required this.subtotal,
    required this.totalGst,
    required this.totalDiscount,
    required this.totalAmount,
    required this.paymentMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || doctorName != null) {
      map['doctor_name'] = Variable<String>(doctorName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['subtotal'] = Variable<double>(subtotal);
    map['total_gst'] = Variable<double>(totalGst);
    map['total_discount'] = Variable<double>(totalDiscount);
    map['total_amount'] = Variable<double>(totalAmount);
    {
      map['payment_mode'] = Variable<String>(
        $SalesInvoicesTable.$converterpaymentMode.toSql(paymentMode),
      );
    }
    return map;
  }

  SalesInvoicesCompanion toCompanion(bool nullToAbsent) {
    return SalesInvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      doctorName: doctorName == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorName),
      createdAt: Value(createdAt),
      subtotal: Value(subtotal),
      totalGst: Value(totalGst),
      totalDiscount: Value(totalDiscount),
      totalAmount: Value(totalAmount),
      paymentMode: Value(paymentMode),
    );
  }

  factory SalesInvoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesInvoice(
      id: serializer.fromJson<int>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      doctorName: serializer.fromJson<String?>(json['doctorName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      totalGst: serializer.fromJson<double>(json['totalGst']),
      totalDiscount: serializer.fromJson<double>(json['totalDiscount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentMode: $SalesInvoicesTable.$converterpaymentMode.fromJson(
        serializer.fromJson<String>(json['paymentMode']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'customerName': serializer.toJson<String?>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'doctorName': serializer.toJson<String?>(doctorName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'subtotal': serializer.toJson<double>(subtotal),
      'totalGst': serializer.toJson<double>(totalGst),
      'totalDiscount': serializer.toJson<double>(totalDiscount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentMode': serializer.toJson<String>(
        $SalesInvoicesTable.$converterpaymentMode.toJson(paymentMode),
      ),
    };
  }

  SalesInvoice copyWith({
    int? id,
    String? invoiceNumber,
    Value<String?> customerName = const Value.absent(),
    Value<String?> customerPhone = const Value.absent(),
    Value<String?> doctorName = const Value.absent(),
    DateTime? createdAt,
    double? subtotal,
    double? totalGst,
    double? totalDiscount,
    double? totalAmount,
    PaymentMode? paymentMode,
  }) => SalesInvoice(
    id: id ?? this.id,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    customerName: customerName.present ? customerName.value : this.customerName,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    doctorName: doctorName.present ? doctorName.value : this.doctorName,
    createdAt: createdAt ?? this.createdAt,
    subtotal: subtotal ?? this.subtotal,
    totalGst: totalGst ?? this.totalGst,
    totalDiscount: totalDiscount ?? this.totalDiscount,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentMode: paymentMode ?? this.paymentMode,
  );
  SalesInvoice copyWithCompanion(SalesInvoicesCompanion data) {
    return SalesInvoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      doctorName: data.doctorName.present
          ? data.doctorName.value
          : this.doctorName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      totalGst: data.totalGst.present ? data.totalGst.value : this.totalGst,
      totalDiscount: data.totalDiscount.present
          ? data.totalDiscount.value
          : this.totalDiscount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('doctorName: $doctorName, ')
          ..write('createdAt: $createdAt, ')
          ..write('subtotal: $subtotal, ')
          ..write('totalGst: $totalGst, ')
          ..write('totalDiscount: $totalDiscount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMode: $paymentMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceNumber,
    customerName,
    customerPhone,
    doctorName,
    createdAt,
    subtotal,
    totalGst,
    totalDiscount,
    totalAmount,
    paymentMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesInvoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.doctorName == this.doctorName &&
          other.createdAt == this.createdAt &&
          other.subtotal == this.subtotal &&
          other.totalGst == this.totalGst &&
          other.totalDiscount == this.totalDiscount &&
          other.totalAmount == this.totalAmount &&
          other.paymentMode == this.paymentMode);
}

class SalesInvoicesCompanion extends UpdateCompanion<SalesInvoice> {
  final Value<int> id;
  final Value<String> invoiceNumber;
  final Value<String?> customerName;
  final Value<String?> customerPhone;
  final Value<String?> doctorName;
  final Value<DateTime> createdAt;
  final Value<double> subtotal;
  final Value<double> totalGst;
  final Value<double> totalDiscount;
  final Value<double> totalAmount;
  final Value<PaymentMode> paymentMode;
  const SalesInvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.totalGst = const Value.absent(),
    this.totalDiscount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentMode = const Value.absent(),
  });
  SalesInvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceNumber,
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.createdAt = const Value.absent(),
    required double subtotal,
    required double totalGst,
    this.totalDiscount = const Value.absent(),
    required double totalAmount,
    this.paymentMode = const Value.absent(),
  }) : invoiceNumber = Value(invoiceNumber),
       subtotal = Value(subtotal),
       totalGst = Value(totalGst),
       totalAmount = Value(totalAmount);
  static Insertable<SalesInvoice> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? doctorName,
    Expression<DateTime>? createdAt,
    Expression<double>? subtotal,
    Expression<double>? totalGst,
    Expression<double>? totalDiscount,
    Expression<double>? totalAmount,
    Expression<String>? paymentMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (doctorName != null) 'doctor_name': doctorName,
      if (createdAt != null) 'created_at': createdAt,
      if (subtotal != null) 'subtotal': subtotal,
      if (totalGst != null) 'total_gst': totalGst,
      if (totalDiscount != null) 'total_discount': totalDiscount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentMode != null) 'payment_mode': paymentMode,
    });
  }

  SalesInvoicesCompanion copyWith({
    Value<int>? id,
    Value<String>? invoiceNumber,
    Value<String?>? customerName,
    Value<String?>? customerPhone,
    Value<String?>? doctorName,
    Value<DateTime>? createdAt,
    Value<double>? subtotal,
    Value<double>? totalGst,
    Value<double>? totalDiscount,
    Value<double>? totalAmount,
    Value<PaymentMode>? paymentMode,
  }) {
    return SalesInvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      doctorName: doctorName ?? this.doctorName,
      createdAt: createdAt ?? this.createdAt,
      subtotal: subtotal ?? this.subtotal,
      totalGst: totalGst ?? this.totalGst,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (doctorName.present) {
      map['doctor_name'] = Variable<String>(doctorName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (totalGst.present) {
      map['total_gst'] = Variable<double>(totalGst.value);
    }
    if (totalDiscount.present) {
      map['total_discount'] = Variable<double>(totalDiscount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(
        $SalesInvoicesTable.$converterpaymentMode.toSql(paymentMode.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('doctorName: $doctorName, ')
          ..write('createdAt: $createdAt, ')
          ..write('subtotal: $subtotal, ')
          ..write('totalGst: $totalGst, ')
          ..write('totalDiscount: $totalDiscount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMode: $paymentMode')
          ..write(')'))
        .toString();
  }
}

class $SalesInvoiceItemsTable extends SalesInvoiceItems
    with TableInfo<$SalesInvoiceItemsTable, SalesInvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesInvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_invoices (id)',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mrpMeta = const VerificationMeta('mrp');
  @override
  late final GeneratedColumn<double> mrp = GeneratedColumn<double>(
    'mrp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstPercentageMeta = const VerificationMeta(
    'gstPercentage',
  );
  @override
  late final GeneratedColumn<double> gstPercentage = GeneratedColumn<double>(
    'gst_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
    'discount_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lineTotalMeta = const VerificationMeta(
    'lineTotal',
  );
  @override
  late final GeneratedColumn<double> lineTotal = GeneratedColumn<double>(
    'line_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    batchId,
    productId,
    productName,
    batchNumber,
    quantity,
    mrp,
    gstPercentage,
    discountPercent,
    lineTotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesInvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('mrp')) {
      context.handle(
        _mrpMeta,
        mrp.isAcceptableOrUnknown(data['mrp']!, _mrpMeta),
      );
    } else if (isInserting) {
      context.missing(_mrpMeta);
    }
    if (data.containsKey('gst_percentage')) {
      context.handle(
        _gstPercentageMeta,
        gstPercentage.isAcceptableOrUnknown(
          data['gst_percentage']!,
          _gstPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gstPercentageMeta);
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    }
    if (data.containsKey('line_total')) {
      context.handle(
        _lineTotalMeta,
        lineTotal.isAcceptableOrUnknown(data['line_total']!, _lineTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesInvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesInvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      mrp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mrp'],
      )!,
      gstPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_percentage'],
      )!,
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_percent'],
      )!,
      lineTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_total'],
      )!,
    );
  }

  @override
  $SalesInvoiceItemsTable createAlias(String alias) {
    return $SalesInvoiceItemsTable(attachedDatabase, alias);
  }
}

class SalesInvoiceItem extends DataClass
    implements Insertable<SalesInvoiceItem> {
  final int id;
  final int invoiceId;
  final int batchId;
  final int productId;
  final String productName;
  final String batchNumber;
  final int quantity;
  final double mrp;
  final double gstPercentage;
  final double discountPercent;
  final double lineTotal;
  const SalesInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.batchId,
    required this.productId,
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.mrp,
    required this.gstPercentage,
    required this.discountPercent,
    required this.lineTotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    map['batch_id'] = Variable<int>(batchId);
    map['product_id'] = Variable<int>(productId);
    map['product_name'] = Variable<String>(productName);
    map['batch_number'] = Variable<String>(batchNumber);
    map['quantity'] = Variable<int>(quantity);
    map['mrp'] = Variable<double>(mrp);
    map['gst_percentage'] = Variable<double>(gstPercentage);
    map['discount_percent'] = Variable<double>(discountPercent);
    map['line_total'] = Variable<double>(lineTotal);
    return map;
  }

  SalesInvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return SalesInvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      batchId: Value(batchId),
      productId: Value(productId),
      productName: Value(productName),
      batchNumber: Value(batchNumber),
      quantity: Value(quantity),
      mrp: Value(mrp),
      gstPercentage: Value(gstPercentage),
      discountPercent: Value(discountPercent),
      lineTotal: Value(lineTotal),
    );
  }

  factory SalesInvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesInvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      batchId: serializer.fromJson<int>(json['batchId']),
      productId: serializer.fromJson<int>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      quantity: serializer.fromJson<int>(json['quantity']),
      mrp: serializer.fromJson<double>(json['mrp']),
      gstPercentage: serializer.fromJson<double>(json['gstPercentage']),
      discountPercent: serializer.fromJson<double>(json['discountPercent']),
      lineTotal: serializer.fromJson<double>(json['lineTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'batchId': serializer.toJson<int>(batchId),
      'productId': serializer.toJson<int>(productId),
      'productName': serializer.toJson<String>(productName),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'quantity': serializer.toJson<int>(quantity),
      'mrp': serializer.toJson<double>(mrp),
      'gstPercentage': serializer.toJson<double>(gstPercentage),
      'discountPercent': serializer.toJson<double>(discountPercent),
      'lineTotal': serializer.toJson<double>(lineTotal),
    };
  }

  SalesInvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? batchId,
    int? productId,
    String? productName,
    String? batchNumber,
    int? quantity,
    double? mrp,
    double? gstPercentage,
    double? discountPercent,
    double? lineTotal,
  }) => SalesInvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    batchId: batchId ?? this.batchId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    batchNumber: batchNumber ?? this.batchNumber,
    quantity: quantity ?? this.quantity,
    mrp: mrp ?? this.mrp,
    gstPercentage: gstPercentage ?? this.gstPercentage,
    discountPercent: discountPercent ?? this.discountPercent,
    lineTotal: lineTotal ?? this.lineTotal,
  );
  SalesInvoiceItem copyWithCompanion(SalesInvoiceItemsCompanion data) {
    return SalesInvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      mrp: data.mrp.present ? data.mrp.value : this.mrp,
      gstPercentage: data.gstPercentage.present
          ? data.gstPercentage.value
          : this.gstPercentage,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      lineTotal: data.lineTotal.present ? data.lineTotal.value : this.lineTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('batchId: $batchId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantity: $quantity, ')
          ..write('mrp: $mrp, ')
          ..write('gstPercentage: $gstPercentage, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('lineTotal: $lineTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    batchId,
    productId,
    productName,
    batchNumber,
    quantity,
    mrp,
    gstPercentage,
    discountPercent,
    lineTotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesInvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.batchId == this.batchId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.batchNumber == this.batchNumber &&
          other.quantity == this.quantity &&
          other.mrp == this.mrp &&
          other.gstPercentage == this.gstPercentage &&
          other.discountPercent == this.discountPercent &&
          other.lineTotal == this.lineTotal);
}

class SalesInvoiceItemsCompanion extends UpdateCompanion<SalesInvoiceItem> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<int> batchId;
  final Value<int> productId;
  final Value<String> productName;
  final Value<String> batchNumber;
  final Value<int> quantity;
  final Value<double> mrp;
  final Value<double> gstPercentage;
  final Value<double> discountPercent;
  final Value<double> lineTotal;
  const SalesInvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.mrp = const Value.absent(),
    this.gstPercentage = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.lineTotal = const Value.absent(),
  });
  SalesInvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    required int batchId,
    required int productId,
    required String productName,
    required String batchNumber,
    required int quantity,
    required double mrp,
    required double gstPercentage,
    this.discountPercent = const Value.absent(),
    required double lineTotal,
  }) : invoiceId = Value(invoiceId),
       batchId = Value(batchId),
       productId = Value(productId),
       productName = Value(productName),
       batchNumber = Value(batchNumber),
       quantity = Value(quantity),
       mrp = Value(mrp),
       gstPercentage = Value(gstPercentage),
       lineTotal = Value(lineTotal);
  static Insertable<SalesInvoiceItem> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<int>? batchId,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<String>? batchNumber,
    Expression<int>? quantity,
    Expression<double>? mrp,
    Expression<double>? gstPercentage,
    Expression<double>? discountPercent,
    Expression<double>? lineTotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (batchId != null) 'batch_id': batchId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (quantity != null) 'quantity': quantity,
      if (mrp != null) 'mrp': mrp,
      if (gstPercentage != null) 'gst_percentage': gstPercentage,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (lineTotal != null) 'line_total': lineTotal,
    });
  }

  SalesInvoiceItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? invoiceId,
    Value<int>? batchId,
    Value<int>? productId,
    Value<String>? productName,
    Value<String>? batchNumber,
    Value<int>? quantity,
    Value<double>? mrp,
    Value<double>? gstPercentage,
    Value<double>? discountPercent,
    Value<double>? lineTotal,
  }) {
    return SalesInvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      batchId: batchId ?? this.batchId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      mrp: mrp ?? this.mrp,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      discountPercent: discountPercent ?? this.discountPercent,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (mrp.present) {
      map['mrp'] = Variable<double>(mrp.value);
    }
    if (gstPercentage.present) {
      map['gst_percentage'] = Variable<double>(gstPercentage.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (lineTotal.present) {
      map['line_total'] = Variable<double>(lineTotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('batchId: $batchId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantity: $quantity, ')
          ..write('mrp: $mrp, ')
          ..write('gstPercentage: $gstPercentage, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('lineTotal: $lineTotal')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $StockBatchesTable stockBatches = $StockBatchesTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $SupplierLedgersTable supplierLedgers = $SupplierLedgersTable(
    this,
  );
  late final $SalesInvoicesTable salesInvoices = $SalesInvoicesTable(this);
  late final $SalesInvoiceItemsTable salesInvoiceItems =
      $SalesInvoiceItemsTable(this);
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final StockBatchesDao stockBatchesDao = StockBatchesDao(
    this as AppDatabase,
  );
  late final SuppliersDao suppliersDao = SuppliersDao(this as AppDatabase);
  late final SupplierLedgerDao supplierLedgerDao = SupplierLedgerDao(
    this as AppDatabase,
  );
  late final SalesDao salesDao = SalesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    stockBatches,
    suppliers,
    supplierLedgers,
    salesInvoices,
    salesInvoiceItems,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> composition,
      Value<String?> hsnCode,
      Value<ProductCategory> category,
      Value<String?> rackLocation,
      Value<double> minStockThreshold,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> composition,
      Value<String?> hsnCode,
      Value<ProductCategory> category,
      Value<String?> rackLocation,
      Value<double> minStockThreshold,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockBatchesTable, List<StockBatch>>
  _stockBatchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockBatches,
    aliasName: $_aliasNameGenerator(db.products.id, db.stockBatches.productId),
  );

  $$StockBatchesTableProcessedTableManager get stockBatchesRefs {
    final manager = $$StockBatchesTableTableManager(
      $_db,
      $_db.stockBatches,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockBatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get composition => $composableBuilder(
    column: $table.composition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnCode => $composableBuilder(
    column: $table.hsnCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProductCategory, ProductCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rackLocation => $composableBuilder(
    column: $table.rackLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minStockThreshold => $composableBuilder(
    column: $table.minStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockBatchesRefs(
    Expression<bool> Function($$StockBatchesTableFilterComposer f) f,
  ) {
    final $$StockBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableFilterComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get composition => $composableBuilder(
    column: $table.composition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnCode => $composableBuilder(
    column: $table.hsnCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rackLocation => $composableBuilder(
    column: $table.rackLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minStockThreshold => $composableBuilder(
    column: $table.minStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get composition => $composableBuilder(
    column: $table.composition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hsnCode =>
      $composableBuilder(column: $table.hsnCode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProductCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get rackLocation => $composableBuilder(
    column: $table.rackLocation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minStockThreshold => $composableBuilder(
    column: $table.minStockThreshold,
    builder: (column) => column,
  );

  Expression<T> stockBatchesRefs<T extends Object>(
    Expression<T> Function($$StockBatchesTableAnnotationComposer a) f,
  ) {
    final $$StockBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({bool stockBatchesRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> composition = const Value.absent(),
                Value<String?> hsnCode = const Value.absent(),
                Value<ProductCategory> category = const Value.absent(),
                Value<String?> rackLocation = const Value.absent(),
                Value<double> minStockThreshold = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                composition: composition,
                hsnCode: hsnCode,
                category: category,
                rackLocation: rackLocation,
                minStockThreshold: minStockThreshold,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> composition = const Value.absent(),
                Value<String?> hsnCode = const Value.absent(),
                Value<ProductCategory> category = const Value.absent(),
                Value<String?> rackLocation = const Value.absent(),
                Value<double> minStockThreshold = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                composition: composition,
                hsnCode: hsnCode,
                category: category,
                rackLocation: rackLocation,
                minStockThreshold: minStockThreshold,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockBatchesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stockBatchesRefs) db.stockBatches],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stockBatchesRefs)
                    await $_getPrefetchedData<
                      Product,
                      $ProductsTable,
                      StockBatch
                    >(
                      currentTable: table,
                      referencedTable: $$ProductsTableReferences
                          ._stockBatchesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProductsTableReferences(
                        db,
                        table,
                        p0,
                      ).stockBatchesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.productId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({bool stockBatchesRefs})
    >;
typedef $$StockBatchesTableCreateCompanionBuilder =
    StockBatchesCompanion Function({
      Value<int> id,
      required int productId,
      required String batchNumber,
      required DateTime expiryDate,
      required double mrp,
      required double purchaseRate,
      Value<double> gstPercentage,
      Value<int> currentStock,
      Value<String?> barcode,
      Value<bool> isOpeningStock,
    });
typedef $$StockBatchesTableUpdateCompanionBuilder =
    StockBatchesCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<String> batchNumber,
      Value<DateTime> expiryDate,
      Value<double> mrp,
      Value<double> purchaseRate,
      Value<double> gstPercentage,
      Value<int> currentStock,
      Value<String?> barcode,
      Value<bool> isOpeningStock,
    });

final class $$StockBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $StockBatchesTable, StockBatch> {
  $$StockBatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.stockBatches.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $StockBatchesTable> {
  $$StockBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpeningStock => $composableBuilder(
    column: $table.isOpeningStock,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockBatchesTable> {
  $$StockBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpeningStock => $composableBuilder(
    column: $table.isOpeningStock,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockBatchesTable> {
  $$StockBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mrp =>
      $composableBuilder(column: $table.mrp, builder: (column) => column);

  GeneratedColumn<double> get purchaseRate => $composableBuilder(
    column: $table.purchaseRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStock => $composableBuilder(
    column: $table.currentStock,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get isOpeningStock => $composableBuilder(
    column: $table.isOpeningStock,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockBatchesTable,
          StockBatch,
          $$StockBatchesTableFilterComposer,
          $$StockBatchesTableOrderingComposer,
          $$StockBatchesTableAnnotationComposer,
          $$StockBatchesTableCreateCompanionBuilder,
          $$StockBatchesTableUpdateCompanionBuilder,
          (StockBatch, $$StockBatchesTableReferences),
          StockBatch,
          PrefetchHooks Function({bool productId})
        > {
  $$StockBatchesTableTableManager(_$AppDatabase db, $StockBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<double> mrp = const Value.absent(),
                Value<double> purchaseRate = const Value.absent(),
                Value<double> gstPercentage = const Value.absent(),
                Value<int> currentStock = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> isOpeningStock = const Value.absent(),
              }) => StockBatchesCompanion(
                id: id,
                productId: productId,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                mrp: mrp,
                purchaseRate: purchaseRate,
                gstPercentage: gstPercentage,
                currentStock: currentStock,
                barcode: barcode,
                isOpeningStock: isOpeningStock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required String batchNumber,
                required DateTime expiryDate,
                required double mrp,
                required double purchaseRate,
                Value<double> gstPercentage = const Value.absent(),
                Value<int> currentStock = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<bool> isOpeningStock = const Value.absent(),
              }) => StockBatchesCompanion.insert(
                id: id,
                productId: productId,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                mrp: mrp,
                purchaseRate: purchaseRate,
                gstPercentage: gstPercentage,
                currentStock: currentStock,
                barcode: barcode,
                isOpeningStock: isOpeningStock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$StockBatchesTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$StockBatchesTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockBatchesTable,
      StockBatch,
      $$StockBatchesTableFilterComposer,
      $$StockBatchesTableOrderingComposer,
      $$StockBatchesTableAnnotationComposer,
      $$StockBatchesTableCreateCompanionBuilder,
      $$StockBatchesTableUpdateCompanionBuilder,
      (StockBatch, $$StockBatchesTableReferences),
      StockBatch,
      PrefetchHooks Function({bool productId})
    >;
typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> gstinNumber,
      Value<String?> address,
      Value<double> currentBalance,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contactPerson,
      Value<String?> phone,
      Value<String?> gstinNumber,
      Value<String?> address,
      Value<double> currentBalance,
    });

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SupplierLedgersTable, List<SupplierLedger>>
  _supplierLedgersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierLedgers,
    aliasName: $_aliasNameGenerator(
      db.suppliers.id,
      db.supplierLedgers.supplierId,
    ),
  );

  $$SupplierLedgersTableProcessedTableManager get supplierLedgersRefs {
    final manager = $$SupplierLedgersTableTableManager(
      $_db,
      $_db.supplierLedgers,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierLedgersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstinNumber => $composableBuilder(
    column: $table.gstinNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> supplierLedgersRefs(
    Expression<bool> Function($$SupplierLedgersTableFilterComposer f) f,
  ) {
    final $$SupplierLedgersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedgers,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgersTableFilterComposer(
            $db: $db,
            $table: $db.supplierLedgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstinNumber => $composableBuilder(
    column: $table.gstinNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get gstinNumber => $composableBuilder(
    column: $table.gstinNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  Expression<T> supplierLedgersRefs<T extends Object>(
    Expression<T> Function($$SupplierLedgersTableAnnotationComposer a) f,
  ) {
    final $$SupplierLedgersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedgers,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgersTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierLedgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, $$SuppliersTableReferences),
          Supplier,
          PrefetchHooks Function({bool supplierLedgersRefs})
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> gstinNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                gstinNumber: gstinNumber,
                address: address,
                currentBalance: currentBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> gstinNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                gstinNumber: gstinNumber,
                address: address,
                currentBalance: currentBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({supplierLedgersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (supplierLedgersRefs) db.supplierLedgers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (supplierLedgersRefs)
                    await $_getPrefetchedData<
                      Supplier,
                      $SuppliersTable,
                      SupplierLedger
                    >(
                      currentTable: table,
                      referencedTable: $$SuppliersTableReferences
                          ._supplierLedgersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SuppliersTableReferences(
                            db,
                            table,
                            p0,
                          ).supplierLedgersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.supplierId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, $$SuppliersTableReferences),
      Supplier,
      PrefetchHooks Function({bool supplierLedgersRefs})
    >;
typedef $$SupplierLedgersTableCreateCompanionBuilder =
    SupplierLedgersCompanion Function({
      Value<int> id,
      required int supplierId,
      required LedgerTxType transactionType,
      required double amount,
      required double balanceAfter,
      Value<String?> invoiceNumber,
      Value<String?> referenceNote,
      Value<DateTime> timestamp,
    });
typedef $$SupplierLedgersTableUpdateCompanionBuilder =
    SupplierLedgersCompanion Function({
      Value<int> id,
      Value<int> supplierId,
      Value<LedgerTxType> transactionType,
      Value<double> amount,
      Value<double> balanceAfter,
      Value<String?> invoiceNumber,
      Value<String?> referenceNote,
      Value<DateTime> timestamp,
    });

final class $$SupplierLedgersTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierLedgersTable, SupplierLedger> {
  $$SupplierLedgersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias(
        $_aliasNameGenerator(db.supplierLedgers.supplierId, db.suppliers.id),
      );

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<int>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierLedgersTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierLedgersTable> {
  $$SupplierLedgersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LedgerTxType, LedgerTxType, String>
  get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNote => $composableBuilder(
    column: $table.referenceNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgersTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierLedgersTable> {
  $$SupplierLedgersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNote => $composableBuilder(
    column: $table.referenceNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierLedgersTable> {
  $$SupplierLedgersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LedgerTxType, String> get transactionType =>
      $composableBuilder(
        column: $table.transactionType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNote => $composableBuilder(
    column: $table.referenceNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierLedgersTable,
          SupplierLedger,
          $$SupplierLedgersTableFilterComposer,
          $$SupplierLedgersTableOrderingComposer,
          $$SupplierLedgersTableAnnotationComposer,
          $$SupplierLedgersTableCreateCompanionBuilder,
          $$SupplierLedgersTableUpdateCompanionBuilder,
          (SupplierLedger, $$SupplierLedgersTableReferences),
          SupplierLedger,
          PrefetchHooks Function({bool supplierId})
        > {
  $$SupplierLedgersTableTableManager(
    _$AppDatabase db,
    $SupplierLedgersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierLedgersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierLedgersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierLedgersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> supplierId = const Value.absent(),
                Value<LedgerTxType> transactionType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> referenceNote = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => SupplierLedgersCompanion(
                id: id,
                supplierId: supplierId,
                transactionType: transactionType,
                amount: amount,
                balanceAfter: balanceAfter,
                invoiceNumber: invoiceNumber,
                referenceNote: referenceNote,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int supplierId,
                required LedgerTxType transactionType,
                required double amount,
                required double balanceAfter,
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> referenceNote = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => SupplierLedgersCompanion.insert(
                id: id,
                supplierId: supplierId,
                transactionType: transactionType,
                amount: amount,
                balanceAfter: balanceAfter,
                invoiceNumber: invoiceNumber,
                referenceNote: referenceNote,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierLedgersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({supplierId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (supplierId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.supplierId,
                                referencedTable:
                                    $$SupplierLedgersTableReferences
                                        ._supplierIdTable(db),
                                referencedColumn:
                                    $$SupplierLedgersTableReferences
                                        ._supplierIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SupplierLedgersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierLedgersTable,
      SupplierLedger,
      $$SupplierLedgersTableFilterComposer,
      $$SupplierLedgersTableOrderingComposer,
      $$SupplierLedgersTableAnnotationComposer,
      $$SupplierLedgersTableCreateCompanionBuilder,
      $$SupplierLedgersTableUpdateCompanionBuilder,
      (SupplierLedger, $$SupplierLedgersTableReferences),
      SupplierLedger,
      PrefetchHooks Function({bool supplierId})
    >;
typedef $$SalesInvoicesTableCreateCompanionBuilder =
    SalesInvoicesCompanion Function({
      Value<int> id,
      required String invoiceNumber,
      Value<String?> customerName,
      Value<String?> customerPhone,
      Value<String?> doctorName,
      Value<DateTime> createdAt,
      required double subtotal,
      required double totalGst,
      Value<double> totalDiscount,
      required double totalAmount,
      Value<PaymentMode> paymentMode,
    });
typedef $$SalesInvoicesTableUpdateCompanionBuilder =
    SalesInvoicesCompanion Function({
      Value<int> id,
      Value<String> invoiceNumber,
      Value<String?> customerName,
      Value<String?> customerPhone,
      Value<String?> doctorName,
      Value<DateTime> createdAt,
      Value<double> subtotal,
      Value<double> totalGst,
      Value<double> totalDiscount,
      Value<double> totalAmount,
      Value<PaymentMode> paymentMode,
    });

final class $$SalesInvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesInvoicesTable, SalesInvoice> {
  $$SalesInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SalesInvoiceItemsTable, List<SalesInvoiceItem>>
  _salesInvoiceItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.salesInvoiceItems,
        aliasName: $_aliasNameGenerator(
          db.salesInvoices.id,
          db.salesInvoiceItems.invoiceId,
        ),
      );

  $$SalesInvoiceItemsTableProcessedTableManager get salesInvoiceItemsRefs {
    final manager = $$SalesInvoiceItemsTableTableManager(
      $_db,
      $_db.salesInvoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _salesInvoiceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalGst => $composableBuilder(
    column: $table.totalGst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDiscount => $composableBuilder(
    column: $table.totalDiscount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMode, PaymentMode, String>
  get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> salesInvoiceItemsRefs(
    Expression<bool> Function($$SalesInvoiceItemsTableFilterComposer f) f,
  ) {
    final $$SalesInvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesInvoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalGst => $composableBuilder(
    column: $table.totalGst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDiscount => $composableBuilder(
    column: $table.totalDiscount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get totalGst =>
      $composableBuilder(column: $table.totalGst, builder: (column) => column);

  GeneratedColumn<double> get totalDiscount => $composableBuilder(
    column: $table.totalDiscount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMode, String> get paymentMode =>
      $composableBuilder(
        column: $table.paymentMode,
        builder: (column) => column,
      );

  Expression<T> salesInvoiceItemsRefs<T extends Object>(
    Expression<T> Function($$SalesInvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$SalesInvoiceItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.salesInvoiceItems,
          getReferencedColumn: (t) => t.invoiceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SalesInvoiceItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.salesInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SalesInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesInvoicesTable,
          SalesInvoice,
          $$SalesInvoicesTableFilterComposer,
          $$SalesInvoicesTableOrderingComposer,
          $$SalesInvoicesTableAnnotationComposer,
          $$SalesInvoicesTableCreateCompanionBuilder,
          $$SalesInvoicesTableUpdateCompanionBuilder,
          (SalesInvoice, $$SalesInvoicesTableReferences),
          SalesInvoice,
          PrefetchHooks Function({bool salesInvoiceItemsRefs})
        > {
  $$SalesInvoicesTableTableManager(_$AppDatabase db, $SalesInvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> totalGst = const Value.absent(),
                Value<double> totalDiscount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<PaymentMode> paymentMode = const Value.absent(),
              }) => SalesInvoicesCompanion(
                id: id,
                invoiceNumber: invoiceNumber,
                customerName: customerName,
                customerPhone: customerPhone,
                doctorName: doctorName,
                createdAt: createdAt,
                subtotal: subtotal,
                totalGst: totalGst,
                totalDiscount: totalDiscount,
                totalAmount: totalAmount,
                paymentMode: paymentMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String invoiceNumber,
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required double subtotal,
                required double totalGst,
                Value<double> totalDiscount = const Value.absent(),
                required double totalAmount,
                Value<PaymentMode> paymentMode = const Value.absent(),
              }) => SalesInvoicesCompanion.insert(
                id: id,
                invoiceNumber: invoiceNumber,
                customerName: customerName,
                customerPhone: customerPhone,
                doctorName: doctorName,
                createdAt: createdAt,
                subtotal: subtotal,
                totalGst: totalGst,
                totalDiscount: totalDiscount,
                totalAmount: totalAmount,
                paymentMode: paymentMode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({salesInvoiceItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesInvoiceItemsRefs) db.salesInvoiceItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesInvoiceItemsRefs)
                    await $_getPrefetchedData<
                      SalesInvoice,
                      $SalesInvoicesTable,
                      SalesInvoiceItem
                    >(
                      currentTable: table,
                      referencedTable: $$SalesInvoicesTableReferences
                          ._salesInvoiceItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesInvoicesTableReferences(
                            db,
                            table,
                            p0,
                          ).salesInvoiceItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.invoiceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesInvoicesTable,
      SalesInvoice,
      $$SalesInvoicesTableFilterComposer,
      $$SalesInvoicesTableOrderingComposer,
      $$SalesInvoicesTableAnnotationComposer,
      $$SalesInvoicesTableCreateCompanionBuilder,
      $$SalesInvoicesTableUpdateCompanionBuilder,
      (SalesInvoice, $$SalesInvoicesTableReferences),
      SalesInvoice,
      PrefetchHooks Function({bool salesInvoiceItemsRefs})
    >;
typedef $$SalesInvoiceItemsTableCreateCompanionBuilder =
    SalesInvoiceItemsCompanion Function({
      Value<int> id,
      required int invoiceId,
      required int batchId,
      required int productId,
      required String productName,
      required String batchNumber,
      required int quantity,
      required double mrp,
      required double gstPercentage,
      Value<double> discountPercent,
      required double lineTotal,
    });
typedef $$SalesInvoiceItemsTableUpdateCompanionBuilder =
    SalesInvoiceItemsCompanion Function({
      Value<int> id,
      Value<int> invoiceId,
      Value<int> batchId,
      Value<int> productId,
      Value<String> productName,
      Value<String> batchNumber,
      Value<int> quantity,
      Value<double> mrp,
      Value<double> gstPercentage,
      Value<double> discountPercent,
      Value<double> lineTotal,
    });

final class $$SalesInvoiceItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SalesInvoiceItemsTable,
          SalesInvoiceItem
        > {
  $$SalesInvoiceItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesInvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.salesInvoices.createAlias(
        $_aliasNameGenerator(
          db.salesInvoiceItems.invoiceId,
          db.salesInvoices.id,
        ),
      );

  $$SalesInvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$SalesInvoicesTableTableManager(
      $_db,
      $_db.salesInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SalesInvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SalesInvoiceItemsTable> {
  $$SalesInvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesInvoicesTableFilterComposer get invoiceId {
    final $$SalesInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesInvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesInvoiceItemsTable> {
  $$SalesInvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mrp => $composableBuilder(
    column: $table.mrp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesInvoicesTableOrderingComposer get invoiceId {
    final $$SalesInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesInvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesInvoiceItemsTable> {
  $$SalesInvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get mrp =>
      $composableBuilder(column: $table.mrp, builder: (column) => column);

  GeneratedColumn<double> get gstPercentage => $composableBuilder(
    column: $table.gstPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lineTotal =>
      $composableBuilder(column: $table.lineTotal, builder: (column) => column);

  $$SalesInvoicesTableAnnotationComposer get invoiceId {
    final $$SalesInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesInvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesInvoiceItemsTable,
          SalesInvoiceItem,
          $$SalesInvoiceItemsTableFilterComposer,
          $$SalesInvoiceItemsTableOrderingComposer,
          $$SalesInvoiceItemsTableAnnotationComposer,
          $$SalesInvoiceItemsTableCreateCompanionBuilder,
          $$SalesInvoiceItemsTableUpdateCompanionBuilder,
          (SalesInvoiceItem, $$SalesInvoiceItemsTableReferences),
          SalesInvoiceItem,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$SalesInvoiceItemsTableTableManager(
    _$AppDatabase db,
    $SalesInvoiceItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesInvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesInvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesInvoiceItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> invoiceId = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> mrp = const Value.absent(),
                Value<double> gstPercentage = const Value.absent(),
                Value<double> discountPercent = const Value.absent(),
                Value<double> lineTotal = const Value.absent(),
              }) => SalesInvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                batchId: batchId,
                productId: productId,
                productName: productName,
                batchNumber: batchNumber,
                quantity: quantity,
                mrp: mrp,
                gstPercentage: gstPercentage,
                discountPercent: discountPercent,
                lineTotal: lineTotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int invoiceId,
                required int batchId,
                required int productId,
                required String productName,
                required String batchNumber,
                required int quantity,
                required double mrp,
                required double gstPercentage,
                Value<double> discountPercent = const Value.absent(),
                required double lineTotal,
              }) => SalesInvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                batchId: batchId,
                productId: productId,
                productName: productName,
                batchNumber: batchNumber,
                quantity: quantity,
                mrp: mrp,
                gstPercentage: gstPercentage,
                discountPercent: discountPercent,
                lineTotal: lineTotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesInvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable:
                                    $$SalesInvoiceItemsTableReferences
                                        ._invoiceIdTable(db),
                                referencedColumn:
                                    $$SalesInvoiceItemsTableReferences
                                        ._invoiceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SalesInvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesInvoiceItemsTable,
      SalesInvoiceItem,
      $$SalesInvoiceItemsTableFilterComposer,
      $$SalesInvoiceItemsTableOrderingComposer,
      $$SalesInvoiceItemsTableAnnotationComposer,
      $$SalesInvoiceItemsTableCreateCompanionBuilder,
      $$SalesInvoiceItemsTableUpdateCompanionBuilder,
      (SalesInvoiceItem, $$SalesInvoiceItemsTableReferences),
      SalesInvoiceItem,
      PrefetchHooks Function({bool invoiceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$StockBatchesTableTableManager get stockBatches =>
      $$StockBatchesTableTableManager(_db, _db.stockBatches);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$SupplierLedgersTableTableManager get supplierLedgers =>
      $$SupplierLedgersTableTableManager(_db, _db.supplierLedgers);
  $$SalesInvoicesTableTableManager get salesInvoices =>
      $$SalesInvoicesTableTableManager(_db, _db.salesInvoices);
  $$SalesInvoiceItemsTableTableManager get salesInvoiceItems =>
      $$SalesInvoiceItemsTableTableManager(_db, _db.salesInvoiceItems);
}
