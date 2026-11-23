# Invoz — Smart Invoicing, Quotations & Billing App

[![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4CAF50)](#)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#)

**Invoz** is a modern, cross-platform mobile and web application designed for freelancers, small business owners, and enterprises to effortlessly create, manage, and share professional invoices, quotations, proforma invoices, and receipts.

---

## 🌟 Key Features

### 📄 Document & Invoice Management
- **Multi-Document Support:** Invoices, Quotations/Estimates, Proforma Invoices, and Payment Receipts.
- **Conversion Flow:** Convert accepted quotations or proforma documents into invoices with a single tap.
- **Dynamic Calculation:** Automatically computes line-item taxes, subtotal, custom overall discounts (flat or percentage), shipping fees, and round-off adjustment.
- **Document Status Lifecycle:** Tracks statuses (`Draft`, `Sent`, `Paid`, `Partially Paid`, `Overdue`, `Cancelled`).

### 🎨 Designer PDF Templates
- Multiple customizable PDF invoice templates (Modern Blue, Minimalist Clean, Classic Professional, Compact, and Elegant).
- Real-time thumbnail preview with customizable branding colors, typography, notes, and terms.
- Built-in PDF viewer, direct system printing, and instant sharing via WhatsApp, Email, and social platforms.

### 🏢 Business Profile & Branding
- Support for multiple companies/businesses under a single account.
- Upload business **Logo**, official **Stamp**, and authorized digital **Signature**.
- Customizable bank accounts and direct **UPI QR Code** embedded directly into the invoice for instant payments.
- Configurable default payment terms and notes to customer.

### 👥 Customer & Product Directory
- **Customer Management:** Maintain client details, billing/shipping addresses, GSTIN/Tax ID, phone, and purchase history.
- **Product Catalog:** Manage items with custom units (pcs, kg, hrs, etc.), default pricing, and applicable tax rates.

### 🔐 Authentication & Security
- **Google Sign-In:** Modern Android Credential Manager integration for seamless single-tap authentication.
- **Apple Sign-In:** Secure sign-in support for Apple ecosystem users.
- **Multi-Device Session Management:** Enforce device limits based on active subscription tier with remote logout support.

### 💳 Subscriptions & Monetization
- **Tiered Plans:** Free, Pro, and Premium packages with feature and company limit gating.
- **Payment Gateway:** Secure online payment processing via **Razorpay**.
- **AdMob Integration:** Lightweight non-intrusive banner and interstitial ads for free-tier users.

### 📊 Reports & Financial Analytics
- Monthly and annual revenue summaries, total invoiced amounts, received payments, and pending dues.
- Visual charts and payment status breakdowns powered by `fl_chart`.

### 🔔 Notifications & Reminders
- Scheduled local notifications for upcoming and overdue invoice payments.
- Firebase Cloud Messaging (FCM) support for background alerts and account updates.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **State Management:** [BLoC / Cubit](https://pub.dev/packages/flutter_bloc) (`flutter_bloc ^9.1.1`)
- **Backend & Storage:**
  - [Firebase Authentication](https://firebase.google.com/products/auth) (Google & Apple Sign-In)
  - [Cloud Firestore](https://firebase.google.com/products/firestore) (Cloud syncing with offline persistence)
  - [Firebase Storage](https://firebase.google.com/products/storage) (Secure storage for company logos, stamps, and signatures)
- **PDF & Printing:** [`pdf`](https://pub.dev/packages/pdf) and [`printing`](https://pub.dev/packages/printing)
- **Payments:** [`razorpay_flutter`](https://pub.dev/packages/razorpay_flutter)
- **Ads:** [`google_mobile_ads`](https://pub.dev/packages/google_mobile_ads)
- **Local Storage & Caching:** `shared_preferences`, `flutter_cache_manager`
- **Architecture Pattern:** Feature-First Clean Architecture (Presentation, BLoC, Domain, Data/Repository).

---

## 📁 Project Structure

```
lib/
├── core/                       # Shared utilities, theme, services & widgets
│   ├── bloc/                   # App-wide BLoC observer
│   ├── constants/              # Color palette, text styles, app constants
│   ├── services/               # Analytics, notifications, device info
│   ├── theme/                  # Light and Dark theme definitions
│   └── widgets/                # Common UI widgets, buttons, responsive wrappers
├── features/
│   ├── auth/                   # Authentication (Google, Apple, BLoC, screens)
│   ├── business_profile/       # Company profile, logo, stamp, signature
│   ├── customers/              # Customer CRUD & selection
│   ├── documents/              # Invoice, quotation, receipt creation & PDF generation
│   ├── home/                   # Dashboard, quick actions, recent documents
│   ├── navigation/             # Bottom navigation scaffold
│   ├── notifications/          # Notification inbox & background listener
│   ├── onboarding/             # Welcome walkthrough
│   ├── products/               # Product catalog management
│   ├── reports/                # Analytics charts & financial reports
│   └── subscriptions/          # Plans, paywall, Razorpay checkout
├── firebase_options.dart       # FlutterFire generated platform options
└── main.dart                   # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`v3.12.2` or higher)
- [Android Studio](https://developer.android.com/studio) / VS Code with Flutter extension
- Java JDK 17
- Firebase project configured with Firestore, Auth, and Storage

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/invoz.git
   cd invoz
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` in `android/app/`.
   - Update `lib/firebase_options.dart` if using FlutterFire CLI.

4. **Run the App in Debug Mode:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Release

### Android App Bundle (Google Play Store)
To build an optimized, shrunk, and signed `.aab` for Google Play deployment:

```bash
flutter build appbundle --release
```

The resulting file will be located at:
`build/app/outputs/bundle/release/app-release.aab`

### Android APK (Direct Testing)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔑 Release Keystore & ProGuard Configuration

- **ProGuard / R8:** Code shrinking and resource shrinking are enabled with safe keep rules configured in `android/app/proguard-rules.pro` for AndroidX WorkManager, Room, Credential Manager, AdMob, and Razorpay.
- **Play App Signing:** Ensure that your Google Play App Signing SHA-1 fingerprint (from Play Console ➔ Setup ➔ App integrity) is added to your Firebase project to allow Google Sign-In on production and closed testing releases.

---

## 📄 License
Copyright © 2026 Invoz. All rights reserved.
Private and proprietary software.
