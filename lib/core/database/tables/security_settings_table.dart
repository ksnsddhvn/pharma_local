import 'package:drift/drift.dart';

@DataClassName('SecuritySetting')
class SecuritySettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isAppLockEnabled => boolean().withDefault(Constant(false))();
  TextColumn get securePinHash => text().nullable()(); // Encrypted/hashed 4-digit PIN string for app access locks
  BoolColumn get isBiometricEnabled => boolean().withDefault(Constant(false))();
}
