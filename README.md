# Pharma Local

Pharma Local is a 100% offline, privacy-first, zero-cloud pharmacy management and point-of-sale (POS) system built entirely on Flutter and Drift. It is designed specifically to run seamlessly on Android tablets and devices at busy pharmacy counters, ensuring speed, ergonomics, and reliability without requiring an internet connection.

## Key Features

- **Offline-First & Zero-Cloud:** All data is securely stored locally using SQLite and Drift. No cloud subscriptions, no syncing delays, and complete data privacy.
- **High-Speed Point of Sale (POS):** 
  - Ergonomically designed for tablets, with right-thumb accessible critical actions.
  - Intelligent inventory search grouped by suppliers and categories.
  - Quick addition of items with stock validation, MRP, and discount tracking.
- **Inventory & Batch Management:** Track products, HSN codes, multi-batch expiry dates, dynamic stock adjustments, and re-order levels effortlessly.
- **Sales & Accounts Dashboard:** 
  - Beautiful metrics to track daily cash flow, UPI collections, and outstanding pending debt.
  - Settle accounts with a single tap.
- **Automated WhatsApp Invoicing:** Send digital receipts directly to customers via WhatsApp or share them instantly as cleanly formatted PDFs.
- **Secure Encrypted Backups:** Keep your data safe with AES-encrypted `.pharmabak` archive files. Export your full database and settings securely, and restore them at will.
- **Modern & Premium UI:** Designed using custom dark/light glassmorphic UI tokens (avoiding generic Material templates) to provide a premium, modern user experience.

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version recommended)
- Android Studio / Android SDK for tablet deployment.

### Running the App Locally

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd pharma_local
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Database Generation (if modifying Drift schemas):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## Creating a Production Build (APK)

To build a standalone APK for deployment on Android tablets:

```bash
flutter build apk --release
```
You can find the generated APK at: `build/app/outputs/flutter-apk/app-release.apk`

## Design & Architecture

- **State Management:** Riverpod `2.6.x`
- **Routing:** GoRouter `17.x`
- **Database:** Drift `2.26.x` (SQLite)
- **Theming:** Custom `AppThemeExtension` for tailored colors, semantic tokens, and typography (Inter font).
- **UI Components:** Glassmorphism dialogs, intuitive bottom sheets, and safety barriers for destructive actions.

## License

Copyright © 2026 Pharma Local. All rights reserved.
