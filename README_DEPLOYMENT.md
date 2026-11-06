# UniMarket — Deployment & Operations Guide

> **Campus Marketplace & Rental Platform for NSTU Students**  
> GitHub Repository: [https://github.com/AyorafHossain/UniMarket_SPL2_Project](https://github.com/AyorafHossain/UniMarket_SPL2_Project)

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Complete Repository Structure](#3-complete-repository-structure)
4. [Frontend Architecture](#4-frontend-architecture)
5. [Backend Architecture](#5-backend-architecture)
6. [Database Configuration & Schema](#6-database-configuration--schema)
7. [Environment Variables and Configuration](#7-environment-variables-and-configuration)
8. [Local Development Setup](#8-local-development-setup)
9. [Frontend Web Deployment](#9-frontend-web-deployment)
10. [Backend Deployment](#10-backend-deployment)
11. [Database Deployment and Configuration](#11-database-deployment-and-configuration)
12. [Android APK Build & Release](#12-android-apk-build--release)
13. [Production Configuration](#13-production-configuration)
14. [Common Build Errors and Troubleshooting](#14-common-build-errors-and-troubleshooting)
15. [Authentication and Login Troubleshooting](#15-authentication-and-login-troubleshooting)
16. [Security Best Practices](#16-security-best-practices)
17. [Production Release Checklist](#17-production-release-checklist)
18. [Maintainer Notes](#18-maintainer-notes)

---

## 1. Project Overview

**UniMarket** is a specialized peer-to-peer campus marketplace designed exclusively for students and faculty of **Noakhali Science and Technology University (NSTU)**. It empowers students to buy, sell, rent, and exchange academic textbooks, electronics, dorm essentials, and everyday items safely within the university community.

The platform consists of two distinct applications:
1. **`uni_market` (Client App)**: Cross-platform mobile (Android/iOS) and web application for students and sellers featuring real-time messaging, order management, rental tracking, item exchanges, support ticketing, and integrated SSLCommerz payment processing.
2. **`uni_market_admin` (Admin Console)**: Dedicated management dashboard for administrators to oversee platform analytics, manage categories, moderate listings, handle payout approvals, manage users, and resolve support tickets.

---

## 2. Technology Stack

### Core Framework & Runtimes
| Technology | Version / Specification | Usage |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.11.4` (Compatible with Flutter 3.24+ / 3.41+) | Cross-platform UI toolkit |
| **Dart SDK** | `^3.11.4` | Programming language |
| **Java JDK** | Version 17 (Required for Gradle build) | Android toolchain |
| **Gradle** | `8.14` (Wrapper: `gradle-8.14-all.zip`) | Android build automation |
| **Android SDK** | `compileSdk = 36`, `targetSdk = 34`, `minSdk = 24` | Android runtime targets |

### Backend & Cloud Services (Serverless BaaS)
| Service | Configuration | Role |
| :--- | :--- | :--- |
| **Firebase Authentication** | Email/Password & Google Sign-In | User authentication with domain gating |
| **Cloud Firestore** | Rules v2 (`firestore.rules`) | Real-time NoSQL primary database |
| **Firebase Cloud Messaging** | `firebase_messaging: ^16.2.2` | Push notifications |
| **Cloudinary** | REST API (`api.cloudinary.com/v1_1`) | Unsigned image, video, and audio uploads |
| **SSLCommerz** | V4 Payment Gateway REST API | Mobile webview checkout & payment processing |

### State Management & Key Libraries
- **State Management**: `provider` (`^6.1.1`) with `ChangeNotifier` & `ChangeNotifierProxyProvider`
- **UI & Typography**: `google_fonts: ^6.2.1` (Poppins & Inter), `fl_chart: ^1.2.0`, `cupertino_icons`
- **Device & Media**: `image_picker: ^1.2.2`, `file_picker: ^11.0.2`, `record: ^6.2.1`, `audioplayers: ^6.6.0`, `video_player: ^2.11.1`
- **Networking & Web**: `http: ^1.2.1`, `webview_flutter: ^4.13.1`, `url_launcher: ^6.3.2`
- **Local Persistence**: `shared_preferences: ^2.5.5`, `flutter_local_notifications: ^21.0.0`

---

## 3. Complete Repository Structure

```
UniMarket/
├── .git/                                 # Git version control
├── README_DEPLOYMENT.md                  # Comprehensive deployment & ops manual
├── uni_market/                           # Main student/seller application
│   ├── android/                          # Native Android host configuration
│   │   ├── app/
│   │   │   ├── build.gradle.kts          # App-level build config (compileSdk 36, Java 17)
│   │   │   ├── google-services.json      # Android Firebase configuration
│   │   │   └── src/main/AndroidManifest.xml
│   │   ├── build.gradle.kts              # Root Android build configuration
│   │   ├── gradle/wrapper/gradle-wrapper.properties  # Gradle 8.14
│   │   ├── key.properties                # Keystore signing credentials (local/secured)
│   │   └── settings.gradle.kts           # Gradle plugin management
│   ├── assets/                           # Bundled assets (icons, images, banners)
│   ├── ios/                              # Native iOS host configuration
│   ├── lib/
│   │   ├── config/
│   │   │   └── sslcommerz_config.dart    # SSLCommerz store IDs & gateway URLs
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # UI color palette
│   │   │   └── app_constants.dart        # Route names & application constants
│   │   ├── firebase_options.dart         # FlutterFire generated project options
│   │   ├── main.dart                     # App entry point, MultiProvider setup & theme
│   │   ├── models/                       # Data models (Order, Product, User, etc.)
│   │   ├── providers/                    # Business logic & state (Auth, Cart, User, Nav)
│   │   ├── screens/                      # UI Views organized by domain
│   │   │   ├── auth/                     # Login, Signup, Verification, AuthWrapper
│   │   │   ├── chat/                     # 1-to-1 chat, media playback, messaging
│   │   │   ├── checkout/                 # SSLCommerz WebView, Order Confirmation
│   │   │   ├── exchange/                 # Student exchange requests
│   │   │   ├── home/                     # Product catalog, search, banner carousels
│   │   │   ├── notifications/            # Push/Firestore notification listing
│   │   │   ├── order/                    # Buyer order history
│   │   │   ├── product_details/          # Product specs, rent/buy/exchange actions
│   │   │   ├── profile/                  # User profile, edit profile, renter view
│   │   │   ├── sell/                     # Product listing & asset upload
│   │   │   ├── seller/                   # Seller dashboard, rent/exchange management
│   │   │   ├── splash/                   # App boot and splash screen
│   │   │   ├── support/                  # Help tickets & support interaction
│   │   │   └── wishlist/                 # Saved items
│   │   ├── services/                     # Cloud & API services (Auth, Firestore, Cloudinary)
│   │   ├── utils/                        # Route mapping, currency formatting
│   │   └── widgets/                      # Reusable components (ProductCard, Shimmer, etc.)
│   ├── web/                              # Web hosting assets (index.html, manifest.json)
│   ├── firebase.json                     # Firebase CLI project binding
│   ├── firestore.rules                   # Production Firestore security rules
│   └── pubspec.yaml                      # Dependencies & asset declarations
│
└── uni_market_admin/                     # Dedicated administrator portal
    ├── android/                          # Native Android host configuration
    ├── assets/                           # Admin icons & graphics
    ├── lib/
    │   ├── firebase_options.dart         # Admin Firebase credentials binding
    │   ├── main.dart                     # Admin app entry point
    │   ├── models/                       # Admin domain models (Category, Order, User, etc.)
    │   ├── providers/                    # Admin state (Auth, Dashboard, Navigation)
    │   ├── screens/                      # Admin views (Categories, Orders, Payouts, Users)
    │   │   ├── categories_screen.dart    # Category management & icon assignment
    │   │   ├── dashboard_screen.dart     # Revenue, transaction & user analytics
    │   │   ├── orders_screen.dart        # Order status monitoring
    │   │   ├── pending_payouts_screen.dart # Seller payout disbursement
    │   │   ├── products_screen.dart      # Listing moderation
    │   │   ├── support_tickets_screen.dart # Ticket response center
    │   │   └── users_screen.dart         # Student account moderation & ban/unban
    │   └── services/                     # Admin Firestore service operations
    ├── web/                              # Web portal host files
    └── pubspec.yaml                      # Admin dependencies
```

---

## 4. Frontend Architecture

UniMarket uses a decoupled **Layered Clean Architecture** across both applications:

```
┌─────────────────────────────────────────────────────────────┐
│                 Presentation Layer (Screens & Widgets)      │
│  Home, ProductDetails, Checkout, ChatRoom, SellerDashboard  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Watches / Dispatches
┌──────────────────────────────▼──────────────────────────────┐
│             State Management (Provider Layer)               │
│      AuthProvider, CartProvider, UserProvider, NavProvider  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invokes
┌──────────────────────────────▼──────────────────────────────┐
│              Domain Services & Gateway Facades              │
│    AuthService, ProductService, OrderService, ChatService   │
│         CloudinaryService, PaymentService (SSLCommerz)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ Reads / Writes
┌──────────────────────────────▼──────────────────────────────┐
│                     External Cloud APIs                     │
│    Cloud Firestore | Firebase Auth | Cloudinary | SSLCommerz│
└─────────────────────────────────────────────────────────────┘
```

- **Routing**: Centralized static route definitions mapped in `AppRoutes.routes` (`uni_market/lib/utils/app_routes.dart`). Authentication guard handled via `AuthWrapper`.
- **State Flow**: Reactive state binding with `provider`. Cart updates automatically sync with user identity through `ChangeNotifierProxyProvider<AuthProvider, CartProvider>`.
- **Media Upload Pipeline**: Images and audio are captured on-device, converted via `CloudinaryService` using unsigned HTTP multipart requests, and the resulting secure HTTPS URLs are written to Firestore documents.

---

## 5. Backend Architecture

UniMarket utilizes a **Backend-as-a-Service (BaaS)** architecture powered directly by **Google Firebase** and specialized third-party cloud APIs:

1. **Identity & Access Management**: Managed via Firebase Authentication. Email verification and token generation are natively handled by Firebase SDKs.
2. **Primary Database**: Managed Google Cloud Firestore with real-time listeners (`Stream<T>`).
3. **Media Storage**: Cloudinary Media Management. File uploads bypass the app server, streaming directly from device to CDN endpoints.
4. **Payment Gateway**: SSLCommerz V4 Session API. The mobile client initiates a payment session via POST to `https://sandbox.sslcommerz.com/gwprocess/v4/api.php` (or production endpoint) and inspects URL redirects in a headless/visible WebView (`SSLCommerzWebViewScreen`).

> [!NOTE]
> There is **no custom Node.js, Python, or Go application server** in this repository. All business rules, transactions, and access controls are enforced at the Firestore Security Rules layer and client-side service facades.

---

## 6. Database Configuration & Schema

### Cloud Firestore Collections
The database is named `(default)` under Firebase project `unimarket-78693`.

| Collection | Document ID | Key Fields | Description |
| :--- | :--- | :--- | :--- |
| `users` | User UID | `name`, `email`, `universityEmail`, `department`, `phoneNumber`, `role`, `isEmailVerified`, `isBanned`, `isActive` | Registered user profiles |
| `products` | Product ID | `title`, `description`, `price`, `sellerId`, `category`, `condition`, `isForRent`, `isForExchange`, `images`, `stockQuantity` | Marketplace product listings |
| `products/{id}/reviews` | Review ID | `userId`, `userName`, `rating`, `comment`, `createdAt` | Subcollection for product reviews |
| `orders` | Order ID | `userId`, `sellerId`, `items`, `totalAmount`, `status`, `paymentMethod`, `buyerName`, `buyerPhone` | Purchase orders (`pending_payment`, `paid`, `cancelled`) |
| `chat_rooms` | Room ID | `participantIds`, `lastMessage`, `lastMessageTime`, `productId` | Messaging threads |
| `chat_rooms/{id}/messages`| Message ID | `senderId`, `senderName`, `text`, `mediaUrl`, `type`, `timestamp` | Subcollection for chat messages |
| `rentRequests` | Request ID | `productId`, `renterId`, `ownerId`, `rentDuration`, `status`, `totalRentPrice` | Rental transaction agreements |
| `exchangeRequests` | Request ID | `productId`, `requesterId`, `ownerId`, `offeredItemTitle`, `status` | Item swap proposals |
| `categories` | Category ID | `id`, `name`, `icon` | Marketplace product categories |
| `support_tickets` | Ticket ID | `userId`, `subject`, `description`, `status`, `createdAt` | Student customer support inquiries |
| `notifications` | Notification ID| `userId`, `title`, `body`, `type`, `isRead`, `createdAt` | User notification logs |

### Production Security Rules Summary (`firestore.rules`)
- **Domain Whitelist**: Write operations require an email matching `.*@student[.]nstu[.]edu[.]bd`.
- **Ban Restriction**: Users with `isBanned == true` in their `users/{uid}` document cannot create listings or initiate exchange/rent requests.
- **Resource Ownership**: Users can only update/delete listings where `resource.data.sellerId == request.auth.uid`.

---

## 7. Environment Variables and Configuration

UniMarket does not rely on local `.env` files; it uses standard Flutter configuration files.

### 1. Firebase Client Configuration
Client configurations are compiled into:
- `uni_market/lib/firebase_options.dart`
- `uni_market_admin/lib/firebase_options.dart`
- `uni_market/android/app/google-services.json`

To generate or refresh these credentials for a new Firebase project:
```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure uni_market
cd uni_market
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# Configure uni_market_admin
cd ../uni_market_admin
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

### 2. Cloudinary Media Configuration
Located in [`uni_market/lib/services/cloudinary_service.dart`](file:///D:/3.1/UniMarket/uni_market/lib/services/cloudinary_service.dart):
```dart
static const String cloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
static const String uploadPreset = 'YOUR_UNSIGNED_UPLOAD_PRESET';
```
> [!IMPORTANT]
> Ensure the preset in Cloudinary Settings -> Upload is set to **Unsigned** mode with asset folder mapping enabled.

### 3. SSLCommerz Payment Gateway Configuration
Located in [`uni_market/lib/config/sslcommerz_config.dart`](file:///D:/3.1/UniMarket/uni_market/lib/config/sslcommerz_config.dart):
```dart
static const String storeId = 'YOUR_STORE_ID';
static const String storePassword = 'YOUR_STORE_PASSWORD';
static const bool isSandbox = true; // Set to false for live production
static const String sandboxBaseUrl = 'https://sandbox.sslcommerz.com';
static const String liveBaseUrl = 'https://securepay.sslcommerz.com';
```

---

## 8. Local Development Setup

### Prerequisites
- **Flutter SDK**: `3.24.x` or higher (`Dart 3.5+` / `3.11+`)
- **Java Development Kit**: JDK 17
- **Android Studio** / VS Code with Flutter extension
- **Chrome Browser** (for web development)

### Step 1: Clone the Repository
```bash
git clone https://github.com/AyorafHossain/UniMarket_SPL2_Project.git
cd UniMarket_SPL2_Project
```

### Step 2: Set Up the Client App (`uni_market`)
```bash
cd uni_market

# Fetch packages
flutter pub get

# Verify local device detection
flutter devices

# Run on an Android Emulator / Physical Device
flutter run -d android

# Or run in Chrome (Web)
flutter run -d chrome
```

### Step 3: Set Up the Admin App (`uni_market_admin`)
Open a separate terminal:
```bash
cd uni_market_admin

# Fetch packages
flutter pub get

# Run on Chrome
flutter run -d chrome
```

---

## 9. Frontend Web Deployment

Both `uni_market` and `uni_market_admin` can be built and deployed as Single Page Web Applications (SPAs).

### Building Web Artifacts
```bash
# 1. Build Client Web App
cd uni_market
flutter build web --release

# 2. Build Admin Web App
cd ../uni_market_admin
flutter build web --release
```
Build outputs are located at:
- `uni_market/build/web/`
- `uni_market_admin/build/web/`

### Deployment Options

#### Option A: Firebase Hosting (Recommended)
1. Initialize Firebase Hosting in the desired app directory:
   ```bash
   cd uni_market_admin
   firebase init hosting
   ```
   - Select your Firebase Project (`unimarket-78693`).
   - Specify public directory: `build/web`
   - Configure as single-page app (rewrite all URLs to /index.html): **Yes**
   - Automatic builds and deploys with GitHub: **Optional**
2. Deploy the build:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

#### Option B: Vercel / Netlify
1. Point your deployment root to either `uni_market` or `uni_market_admin`.
2. Build Command: `flutter build web --release`
3. Output Directory: `build/web`
4. Add rewrite rule for SPA routing (`/*` -> `/index.html`).

---

## 10. Backend Deployment

Because UniMarket uses a **Serverless Firebase Architecture**, there is no standalone server binary to deploy. However, maintaining production stability requires deploying rules and index configurations:

### Deploying Firestore Rules
From `uni_market/`:
```bash
firebase deploy --only firestore:rules
```

### Future Server-Side Operations (Recommended Architecture)
For production, SSLCommerz session initialization and transaction verification (IPN - Instant Payment Notification) should ideally be executed via **Firebase Cloud Functions** rather than directly on the mobile client.
To add cloud functions later:
```bash
firebase init functions
```

---

## 11. Database Deployment and Configuration

### Deploying Firestore Security Rules
The source of truth for database security is `uni_market/firestore.rules`.
To validate and deploy:
```bash
cd uni_market
firebase deploy --only firestore:rules
```

### Creating Required Firestore Composite Indexes
When querying products with multiple filters (e.g., category + price sort + availability), Firestore will require composite indexes. If an index is missing, Flutter will throw a console error containing a direct URL to create the index in Firebase Console.

Common required indexes:
- Collection: `products` -> `category` (Ascending) + `createdAt` (Descending)
- Collection: `products` -> `isForRent` (Ascending) + `createdAt` (Descending)
- Collection: `orders` -> `sellerId` (Ascending) + `createdAt` (Descending)
- Collection: `orders` -> `userId` (Ascending) + `createdAt` (Descending)

---

## 12. Android APK Build & Release

The Android project is pre-configured for automated release signing using Kotlin DSL Gradle (`build.gradle.kts`).

### 1. Keystore Configuration
Ensure `uni_market/android/key.properties` exists with the following properties:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=upload-keystore.jks
```
Ensure the `upload-keystore.jks` file is placed at `uni_market/android/app/upload-keystore.jks`.

### 2. Generate a New Release Keystore (If Needed)
If creating a fresh keystore:
```bash
keytool -genkey -v -keystore uni_market/android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 3. Build Commands
Run the release build from inside `uni_market`:
```bash
cd uni_market

# Clean previous build artifacts
flutter clean
flutter pub get

# Build Release APK (Fat APK containing all ABIs)
flutter build apk --release

# Or build ABI-split APKs (Smaller download size per architecture)
flutter build apk --split-per-abi --release

# Build Android App Bundle (Required for Google Play Store)
flutter build appbundle --release
```

### 4. Generated Artifact Paths
- **Fat Release APK**:  
  `uni_market/build/app/outputs/flutter-apk/app-release.apk`
- **ABI Split APKs**:  
  `uni_market/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`  
  `uni_market/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`  
  `uni_market/build/app/outputs/flutter-apk/app-x86_64-release.apk`
- **Play Store App Bundle**:  
  `uni_market/build/app/outputs/bundle/release/app-release.aab`

---

## 13. Production Configuration

Before publishing UniMarket to production users:

1. **Switch SSLCommerz from Sandbox to Live**:
   - In `uni_market/lib/config/sslcommerz_config.dart`:
     - Update `storeId` and `storePassword` with production merchant credentials.
     - Set `isSandbox = false`.
     - Update `sandboxBaseUrl` to live gateway URL: `https://securepay.sslcommerz.com`.
2. **Configure Production Return URLs**:
   - Update `successUrl`, `failUrl`, and `cancelUrl` to production domain endpoints or custom deep-link URI schemes.
3. **Verify Google Cloud API Restrictions**:
   - In Google Cloud Console, restrict your Firebase Android/Web API keys to only call Firestore, Firebase Auth, and FCM.
4. **Register Android Release SHA-1**:
   - Extract the SHA-1 fingerprint from your production keystore and register it in Firebase Console -> Project Settings -> Android App.

---

## 14. Common Build Errors and Troubleshooting

### 1. Java Version Mismatch
- **Error**: `compileOptions requires JavaVersion.VERSION_17` or `Unsupported class file major version`.
- **Cause**: Gradle 8.14 and Android Gradle Plugin 8.x require Java 17.
- **Solution**: Set your `JAVA_HOME` environment variable to JDK 17:
  ```powershell
  # Windows PowerShell
  $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
  ```

### 2. Gradle Out of Memory / Daemon Crash
- **Error**: `Expiring Daemon because JVM heap space is exhausted`.
- **Solution**: Check `uni_market/android/gradle.properties` and add:
  ```properties
  org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
  ```

### 3. Core Library Desugaring Error
- **Error**: `Cannot find method isCoreLibraryDesugaringEnabled` or desugaring failure.
- **Solution**: Both `uni_market/android/app/build.gradle.kts` and `uni_market_admin` require:
  ```kotlin
  compileOptions {
      isCoreLibraryDesugaringEnabled = true
  }
  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  }
  ```

### 4. CocoaPods / iOS Build Failures
- **Error**: `Podfile out of date` or `CocoaPods could not find compatible versions`.
- **Solution**:
  ```bash
  cd uni_market/ios
  pod repo update
  pod install
  ```

---

## 15. Authentication and Login Troubleshooting

### 1. "Only NSTU student accounts are allowed"
- **Cause**: Both client registration and Google Sign-In enforce an institutional email domain policy:
  ```dart
  email.trim().toLowerCase().endsWith('@student.nstu.edu.bd')
  ```
- **Resolution**: Use an official student email address (`name@student.nstu.edu.bd`). For internal QA/testing, temporarily add test accounts in `AuthService.isNstuStudentEmail()` or disable the check in non-production environments.

### 2. Google Sign-In Error `ApiException: 10`
- **Cause**: The Android signing key SHA-1 fingerprint is not registered in Firebase Console.
- **Resolution**:
  1. Print the SHA-1 of your debug keystore:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
  2. Or print the SHA-1 of your release keystore:
     ```bash
     keytool -list -v -keystore uni_market/android/app/upload-keystore.jks -alias upload
     ```
  3. Add the resulting SHA-1 and SHA-256 fingerprints to your Firebase Android App Settings and re-download `google-services.json`.

### 3. Admin Login: "Access Denied: Only admin accounts can log in"
- **Cause**: The admin console verifies `role == 'admin'` and `isActive == true` on the `users/{uid}` document.
- **Resolution**:
  1. Open Firebase Console -> Firestore Database.
  2. Navigate to `users` -> Select your Admin User UID document.
  3. Set or update field: `role: "admin"` (String) and `isActive: true` (Boolean).

---

## 16. Security Best Practices

### Critical Discovered Secret Exposures
> [!CAUTION]
> The following files in the repository contain credentials and sensitive build material that should be secured:
> 1. `uni_market/android/key.properties`: Contains plaintext release keystore passwords.
> 2. `uni_market/android/app/upload-keystore.jks`: Android app signing private key committed directly to the repository.
> 3. `uni_market/lib/config/sslcommerz_config.dart`: Hardcoded SSLCommerz Store ID and Store Password.
> 4. `uni_market/lib/services/cloudinary_service.dart`: Cloudinary cloud name and unsigned upload preset.

### Security Hardening Instructions
1. **Keystore Protection**:
   - Add `key.properties` and `*.jks` to `.gitignore`.
   - Never commit signing keys to public GitHub repositories.
2. **Move Payment Secrets to Backend / Cloud Functions**:
   - Client applications should never store `storePassword`. The client should invoke an HTTPS Cloud Function that contacts SSLCommerz and returns only the payment URL.
3. **Audit Firestore Security Rules**:
   - Ensure `firestore.rules` enforces admin-only write permissions on the `categories` collection:
     ```javascript
     match /categories/{categoryId} {
       allow read: if request.auth != null;
       allow write: if request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
     }
     ```

---

## 17. Production Release Checklist

Before releasing a new version of UniMarket to students:

- [ ] Flutter dependencies verified with `flutter pub outdated` and updated.
- [ ] Code formatting and analysis clean (`flutter analyze`).
- [ ] NSTU domain filter active in `auth_service.dart`.
- [ ] Release Keystore SHA-1 registered in Firebase Console.
- [ ] `google-services.json` updated with latest project credentials.
- [ ] SSLCommerz switched to production credentials with secure return URLs.
- [ ] Cloudinary unsigned preset upload limits and file extensions restricted.
- [ ] Firestore production rules deployed and verified with test queries.
- [ ] Version and build numbers incremented in `pubspec.yaml` (e.g. `1.0.1+2`).
- [ ] Release APK / App Bundle tested on a clean physical Android device.

---

## 18. Maintainer Notes

- **Primary Repository**: [UniMarket_SPL2_Project](https://github.com/AyorafHossain/UniMarket_SPL2_Project)
- **Target Organization**: Noakhali Science and Technology University (NSTU)
- **Architecture Type**: Dual Flutter Client/Admin with Firebase Serverless BaaS
- **Admin Setup**: First-time administrators must have their Firestore `users/{uid}` document updated manually with `role: "admin"` via the Firebase Web Console.
- **Submodules / Multi-Project Notice**: If maintaining the admin panel as a separate repository or submodule, ensure pubspec versions are aligned.
