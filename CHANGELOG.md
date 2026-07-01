# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1+2] - 2026-07-01

### Fixed
- **Database Migrations:** Prevented unintended data destruction on database schema upgrades. The migration script now uses non-destructive column additions (`addColumn`) for `customerPlace` on the `salesInvoices` table, and `packagingUnit` & `productType` on the `products` table across old version schemas (v5 to v13) instead of dropping tables.
- **UI Interaction:** Removed forced text capitalization (`TextCapitalization.characters`) on text input fields in `receive_stock_screen.dart` to permit natural, standard keyboard entries. (The inputs on `checkout_screen.dart` were already set correctly).
