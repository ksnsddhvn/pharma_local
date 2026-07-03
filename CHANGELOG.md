# Changelog

All notable changes to this project will be documented in this file.
## [1.0.3+5] - 2026-07-03

### Added
- **Multi-Tier Pricing:** Added a dynamic multi-tier pricing system for products (Unit, Sheet/Strip, Pack/Box) in the Add/Edit Product screen, embedded via JSON without database schema changes.
- **Cart Tier Selection:** Added a dropdown in the POS cart tile to select the desired pricing tier (Unit, Sheet, Pack) at runtime, automatically scaling prices and stock deduction logic.

### Changed
- **Receipts:** WhatsApp text receipts now parse the dynamic pricing tier and output readable units (e.g., '2 Strip(s)', '1 Pack(s)') instead of raw numeric totals.
- **Theme:** Updated Dark Mode color schema to use purer whites for primary text, solving the issue where text blended with dark card backgrounds.
- **Auto-Update Permissions:** Added android.permission.INTERNET to AndroidManifest.xml to ensure in-app updater check triggers correctly.

## [1.0.3+4] - 2026-07-01

### Added
- **Backup Location:** Users can now specify a custom backup folder for Auto-Backup in the settings screen.
- **Backup Frequency:** Added the ability to choose the auto-backup frequency (On App Close, Daily, Weekly) in the settings screen.
- **UI Overflow Protection:** Added TextOverflow.ellipsis and maxLines across sales, inventory, and supplier screens to prevent rendering crashes on small screens when data values are unusually long.

### Changed
- **Toolchain Upgrade:** Upgraded Gradle wrapper to 8.14, AGP to 8.11.1, and Kotlin to 2.2.20 for improved build stability.
- **Dependencies Bump:** Upgraded `shared_preferences`, `package_info_plus`, and `share_plus` to modern versions, resolving ecosystem conflicts.
- **Dashboard Refactor:** Removed the weekly sales chart from the dashboard to save space and expanded the High Contrast Debt/Revenue Dashboard Card to full width.
- **Updater Flow:** Modified the Github Updater Service dialog to be permissive instead of forced. Users can now choose "Later" and skip updates for the current latest version.


## [1.0.2+3] - 2026-07-01

### Added
- **Supplier FAB:** Added a Floating Action Button on the Suppliers screen for quicker data entry.
- **Deployment Docs:** Added "App Workflow & Deployment Pipeline" section to `README.md` documenting the staging → production release process.
- **Changelog Rule:** Codified a permanent rule in `.agents/AGENTS.md` to always update the changelog after every set of changes.

### Changed
- **Reports Tabs:** Switched the Reports screen tab bar from a vertical icon+text layout to a horizontal scrollable layout (`isScrollable: true`) to prevent text clipping on smaller screens.
- **Sales Unit Display:** Replaced the editable unit `DropdownButton` in the POS cart with a static read-only `Text` label. Units are now locked to whatever was set during product entry, preventing accidental overrides.
- **Checkout Button:** Renamed "New Sale" to "Sale" on the checkout confirmation screen.
- **Test Cases:** Updated `test/unit_tests.dart` — the Tablet Fractional Math test group now validates the new product-type-aware strip calculation logic (Tablets/Capsules divide by perStrip; Syrups, Creams, etc. use quantity directly).

### Fixed
- **Product Detail Crash:** Fixed `StateError` when viewing products with no stock batches by changing `innerJoin` to `leftOuterJoin` on `stockBatches` in `products_dao.dart`, and using `readTableOrNull` + `whereType<StockBatch>()` to safely filter null batch rows.
- **Inventory Adjustment Buttons:** Removed the manual increment/decrement (`+`/`-`) `IconButton` widgets from the product detail screen. Stock adjustments should only go through auditable flows (Receive Stock, Expiry Processing).
- **Invoice Calculation:** Fixed `_autoCalculateInvoiceAmount` in `receive_stock_screen.dart` to only apply strip-division logic for Tablets and Capsules. Non-strip product types (Syrups, Creams, Injections, etc.) now correctly use the raw quantity × rate formula.

## [1.0.1+2] - 2026-07-01

### Fixed
- **Database Migrations:** Prevented unintended data destruction on database schema upgrades. The migration script now uses non-destructive column additions (`addColumn`) for `customerPlace` on the `salesInvoices` table, and `packagingUnit` & `productType` on the `products` table across old version schemas (v5 to v13) instead of dropping tables.
- **UI Interaction:** Removed forced text capitalization (`TextCapitalization.characters`) on text input fields in `receive_stock_screen.dart` to permit natural, standard keyboard entries. (The inputs on `checkout_screen.dart` were already set correctly).
