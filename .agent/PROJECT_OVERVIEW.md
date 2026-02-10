# AzanGuru Mobile App - Project Overview for New Developers

## 📱 What is AzanGuru?

**AzanGuru** is an Islamic learning mobile application built with Flutter that helps users learn about Islam through structured courses, Quran listening, live classes, and interactive support. The app provides a comprehensive platform for Islamic education with features like video lessons, homework assignments, in-app purchases, and live teacher interactions.

---

## 🏗️ Project Information

- **App Name**: AzanGuru Mobile (`azan_guru_mobile`)
- **Current Version**: 3.8.0+371
- **Flutter Version**: 3.16.4
- **Dart Version**: >=3.2.3 <4.0.0
- **Repository**: git@bitbucket.org:eia2023/azan-guru-mobile.git
- **Backend**: GraphQL API hosted at `https://azanguru.com/graphql`

---

## 🎯 Core Features

### 1. **Authentication & User Management**
- Login/Register with OTP (One-Time Password)
- Guest login support
- Password reset functionality
- Deep linking for auto-login
- Session management with JWT tokens

### 2. **Course System**
- Browse and purchase Islamic courses via in-app purchases (IAP)
- Course recommendations based on user preferences
- Video lessons with custom video player (pod_player)
- Homework/assignments with submissions
- Progress tracking
- Course completion certificates

### 3. **Listen to Quran**
- Free Quran audio streaming
- Offline caching using Hive database
- Audio playback controls
- Chapter/verse selection

### 4. **Live Classes**
- Real-time Islamic classes
- Scheduled class notifications
- Interactive sessions with teachers

### 5. **Help & Support**
- FAQ section
- Question & Answer system
- Live chat with support team
- Message history

### 6. **User Profile**
- View and edit profile information
- Change password
- Manage subscriptions
- Language selection (multi-language support)
- Delete account functionality
- Settings management

### 7. **Monetization**
- Google AdMob integration (banner ads)
- In-app purchases for premium courses
- WooCommerce integration for payments
- Subscription management

### 8. **Notifications**
- Firebase Cloud Messaging (FCM) for push notifications
- Local notifications
- In-app notification center

---

## 🏛️ Architecture & Design Pattern

The project follows **BLoC (Business Logic Component) Pattern** for state management, which provides:
- Clear separation between UI and business logic
- Predictable state management
- Easy testing
- Better code organization

### Architecture Layers:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│         (UI - lib/ui/)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Business Logic Layer         │
│         (BLoC - lib/bloc/)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│          Service Layer              │
│   (GraphQL, Storage, Firebase)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│           Data Layer                │
│  (Models, Repositories, Entities)   │
└─────────────────────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── bloc/                               # BLoC state management
│   ├── auth/                          # Authentication BLoCs
│   ├── home_bloc/                     # Home screen logic
│   ├── course_detail_bloc/            # Course details & lessons
│   ├── my_course_bloc/                # User's purchased courses
│   ├── player_bloc/                   # Audio/video player
│   ├── help_bloc/                     # Support & help system
│   ├── profile_module/                # Profile management
│   ├── listen_quran_bloc/             # Quran audio player
│   ├── live_class_bloc/               # Live class management
│   ├── in_app_purchase_bloc/          # IAP handling
│   ├── firebase_bloc/                 # Firebase messaging
│   └── notification_module/           # Notifications
│
├── ui/                                 # User Interface
│   ├── splash/                        # Splash screen
│   ├── auth/                          # Login/Register screens
│   ├── lrf_module/                    # Login/Register/Forgot Password
│   ├── tabbar/                        # Main bottom navigation
│   ├── home_module/                   # Home screen & course discovery
│   │   ├── home_page.dart
│   │   ├── course_detail_module/      # Course details, lessons, homework
│   │   ├── course_selection_question_module/  # Course recommendations
│   │   ├── notification_module/       # In-app notifications
│   │   └── live_class_tab.dart        # Live classes tab
│   ├── my_course/                     # User's enrolled courses
│   ├── listen_quran/                  # Quran listening feature
│   ├── help_module/                   # Support system
│   ├── profile_module/                # User profile & settings
│   ├── course_module/                 # Course browsing
│   ├── my_subscription/               # Subscription management
│   ├── model/                         # UI data models
│   └── common/                        # Reusable UI widgets
│
├── service/                            # Backend services
│   ├── local_storage/                 # SharedPreferences wrapper
│   ├── localization/                  # Multi-language support
│   └── digits_service.dart            # Phone number services
│
├── graphQL/                            # GraphQL integration
│   ├── graphql_service.dart           # GraphQL client setup
│   └── queries.dart                   # All GraphQL queries & mutations
│
├── common/                             # Common utilities & widgets
│   ├── custom_button.dart
│   ├── loader.dart
│   ├── util.dart                      # Helper functions
│   └── [other reusable widgets]
│
├── constant/                           # App constants
│   ├── app_assets.dart                # Asset paths (images, SVGs)
│   ├── app_colors.dart                # Color palette
│   ├── font_style.dart                # Typography
│   ├── enum.dart                      # Enumerations
│   ├── extensions.dart                # Dart extensions
│   └── language_key.dart              # Localization keys
│
├── entities/                           # Data entities
│   └── app_version.dart               # Version checking
│
├── route/                              # Navigation
│   └── app_routes.dart                # All app routes
│
├── mixin/                              # Reusable behaviors
│
├── main.dart                           # App entry point
├── firebase_options.dart               # Firebase configuration
├── firebase_message_service.dart       # FCM service
└── local_message_service.dart          # Local notifications
```

---

## 🔑 Key Dependencies

### UI & Design
- **flutter_screenutil** (5.6.0) - Responsive UI across different screen sizes
- **flutter_svg** (2.0.9) - SVG image support
- **cached_network_image** (3.3.1) - Image caching
- **flutter_html** (3.0.0-beta.2) - HTML rendering

### State Management
- **flutter_bloc** (9.1.1) - BLoC pattern implementation
- **get** (4.6.6) - Navigation & dependency injection

### Backend & Networking
- **graphql_flutter** (5.0.1) - GraphQL client
- **http** (1.2.0) - HTTP requests
- **dio** (5.4.0) - Advanced HTTP client

### Storage
- **shared_preferences** (2.0.12) - Simple key-value storage
- **flutter_secure_storage** (8.0.0) - Secure storage for tokens
- **hive** (2.2.3) & **hive_flutter** (1.1.0) - Local NoSQL database

### Media & Player
- **pod_player** (0.2.1) - Video player
- **chewie** (1.3.5) - Video player UI
- **video_player** (2.2.19) - Flutter video player
- **audioplayers** (6.4.0) - Audio playback
- **audio_waveforms** (1.0.4) - Audio waveform visualization

### Firebase
- **firebase_core** (3.13.0) - Firebase SDK
- **firebase_messaging** (15.2.5) - Push notifications
- **flutter_local_notifications** (19.1.0) - Local notifications

### Monetization
- **google_mobile_ads** (5.0.0) - AdMob integration
- **in_app_purchase** (3.1.0) - IAP for courses

### Utilities
- **connectivity_plus** (4.0.1) - Network connectivity
- **url_launcher** (6.3.2) - Open URLs/deep links
- **webview_flutter** (4.11.0) - In-app browser (for payments)
- **app_links** (3.1.0) - Deep linking
- **share_plus** (11.0.0) - Share functionality
- **permission_handler** (12.0.0) - Device permissions
- **package_info_plus** (8.3.0) - App version info
- **fluttertoast** (8.0.9) - Toast messages

### Fonts
- **DM Sans** (Regular, Medium, SemiBold, Bold)
- **Poppins** (Regular, Medium, SemiBold, Bold)
- **Playfair Display** (Regular, Medium, SemiBold, Bold)

---

## 🚀 App Initialization Flow

### 1. **main.dart**
```dart
main() → runZonedGuarded() → async initialization
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── SharedPreferences initialization (StorageManager)
  ├── Firebase initialization
  ├── Hive initialization (local database)
  │   ├── FreeQuranData adapters
  │   └── LiveClassesData adapters
  ├── Google AdMob initialization
  ├── System UI configuration (status bar, orientation)
  ├── Version check (isUpdateRequired)
  └── runApp(App(forceUpdate: needsUpdate))
```

### 2. **app.dart - Main App Widget**
The `App` widget sets up:
- **MultiBlocProvider**: All BLoCs are provided at root level
- **ScreenUtilInit**: Responsive design setup
- **GetMaterialApp**: Navigation with GetX
- **Deep Linking**: Handles app links
- **Internet Connectivity**: Monitors connection status
- **Route Observer**: Tracks navigation changes

### 3. **Initial Route Logic** (`_initMainScreen()`)
```
Check if user is logged in (JWT token exists)
  ├── Yes → Navigate to TabBarPage (main app)
  └── No → Navigate to Login/Language Selection
```

### 4. **TabBarPage - Main Navigation**
Four main tabs:
1. **Home** - Course discovery, resources, announcements
2. **My Courses** - User's enrolled courses
3. **Live Classes** - Scheduled live sessions
4. **Support** - Help & FAQ

---

## 🔐 Authentication System

### Login Flow:
1. User enters phone/email → Click "Send OTP"
2. Backend sends OTP via SMS/Email
3. User enters OTP
4. Backend validates and returns JWT token
5. Token stored in `flutter_secure_storage`
6. GraphQL client configured with auth token
7. Navigate to TabBarPage

### Auto-Login via Deep Link:
- Format: `https://azanguru.com/?email=...&password=...`
- App automatically logs in user if valid credentials

---

## 🎨 UI/UX Highlights

### Custom Tab Bar
- Custom-designed bottom navigation (not using Flutter's default)
- Smooth page transitions using `PageController`
- Active/inactive state with color changes
- Custom SVG icons

### Color Scheme
- Primary colors defined in `app_colors.dart`
- Dark theme with vibrant accent colors
- Consistent color palette across app

### Typography
- Three font families with multiple weights
- Responsive font sizes using ScreenUtil
- Consistent text styles in `font_style.dart`

### Advertising Strategy
- Banner ads shown to non-premium users
- Ads hidden for users who purchased courses
- Strategic placement (home, course pages)

---

## 📊 State Management with BLoC

### BLoC Structure Example:
```
home_bloc/
├── home_bloc.dart      # Business logic
├── home_event.dart     # User actions (events)
└── home_state.dart     # UI states
```

### Common Event-State Flow:
```
User Action → Event dispatched → BLoC processes → New State emitted → UI rebuilds
```

Example:
```dart
// Event
context.read<HomeBloc>().add(LoadHomeData());

// BLoC processes
// State emitted: HomeLoading, HomeLoaded, or HomeError

// UI reacts
BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) return Loader();
    if (state is HomeLoaded) return CourseList(state.courses);
    if (state is HomeError) return ErrorWidget(state.message);
  }
)
```

---

## 🗄️ Data Persistence

### 1. **SharedPreferences** (via StorageManager)
- User preferences
- Auth token
- Guest login status
- Selected language

### 2. **Hive Database**
- Offline Quran audio data
- Live class information
- Cached course content

### 3. **Secure Storage**
- JWT authentication tokens
- Sensitive user data

---

## 🌐 GraphQL Integration

### GraphQLService (`graphql_service.dart`)
- Singleton service for API calls
- Automatic JWT token injection in headers
- Error handling for expired sessions
- Cache management with Hive

### API URL: 
`https://azanguru.com/graphql`

### Common Operations:
- **performQuery**: Fetch data (with cache-and-network policy)
- **performMutation**: Create/update data

### Authentication Error Handling:
- If "unauthenticated" error → Clear storage → Redirect to login
- Show toast: "Session expired. Please login again."

---

## 🔔 Notification System

### Push Notifications (Firebase)
- Course updates
- New lesson availability
- Live class reminders
- Promotional messages

### Local Notifications
- Scheduled reminders
- Offline event triggers

---

## 💰 Monetization

### 1. **In-App Purchases**
- Premium course purchases
- Subscription plans
- Handled by `in_app_purchase_bloc`

### 2. **Google AdMob**
- Banner ads throughout the app
- Ads hidden for premium users
- Custom widget: `AGBannerAd`

### 3. **WooCommerce Integration**
- Payment gateway through WebView
- Checkout process in `ag_webview_page.dart`

---

## 🧪 Testing & Quality

### Development Tools:
- **build_runner** - Code generation for Hive adapters
- **hive_generator** - Generate Hive type adapters
- **flutter_lints** (5.0.0) - Code quality enforcement

### Code Analysis:
- Configured in `analysis_options.yaml`
- Enforces Flutter best practices

---

## 🌍 Localization

- Multi-language support via `flutter_localizations`
- Language selection screen on first launch
- Translation keys in `language_key.dart`
- Localization service in `service/localization/`

---

## 🔧 Key Utilities

### `common/util.dart`
- Helper functions used throughout the app
- Version checking (`isUpdateRequired`)
- Common UI utilities

### `common/loader.dart` (AGLoader)
- Global loading indicator
- Can be shown/hidden from anywhere

### Deep Linking
- Handles `azanguru.com` links
- Auto-login functionality
- Course deep links

### Internet Connectivity Monitor
- Shows dialog when offline
- Dismisses when connection restored
- Uses `connectivity_plus` package

---

## 🎓 Course System Deep Dive

### Course Flow:
1. **Discovery** → Home page shows available courses
2. **Recommendation** → Answer questions → Get personalized suggestions
3. **Purchase** → In-app purchase or subscription
4. **Learning** → Access lessons (videos, PDFs, audio)
5. **Homework** → Submit assignments
6. **Completion** → Get certificate

### Course Components:
- **Lessons**: Video/audio content with pod_player
- **Resources**: Downloadable materials
- **Homework**: Assignment submission with image upload
- **Progress Tracking**: Percentage completion
- **Certificates**: On course completion

---

## 🎯 Important Files to Know

### Entry Points:
- **`main.dart`** - App initialization
- **`lib/ui/app.dart`** - Main app widget setup

### Navigation:
- **`route/app_routes.dart`** - All route definitions

### Constants:
- **`constant/app_colors.dart`** - Color palette
- **`constant/app_assets.dart`** - Asset paths
- **`constant/font_style.dart`** - Typography

### Services:
- **`graphQL/graphql_service.dart`** - API client
- **`service/local_storage/storage_manager.dart`** - Data persistence

### Main Screens:
- **`ui/tabbar/tabbar_page.dart`** - Bottom navigation
- **`ui/home_module/home_page.dart`** - Home screen
- **`ui/my_course/my_course_page.dart`** - User courses
- **`ui/lrf_module/login_page.dart`** - Authentication

---

## 🚨 Common Issues & Solutions

### 1. **Loader Not Showing**
- Check if `AGLoader.isShown` before showing again
- Ensure loading state is properly emitted from BLoC

### 2. **Navigation Bar Overlap**
- Use `SafeArea` widget with `bottom: true`
- Check `extendBody` property in Scaffold

### 3. **Ads Showing for Premium Users**
- Verify purchase status check in `AGBannerAd`
- Ensure `hasPurchasedCourses` flag is properly set

### 4. **WebView Checkout Spinner Stuck**
- Clear WebView cache on navigation back
- Reset loading state in BLoC

---

## 📱 Platform-Specific Info

### Android (`android/`)
- Minimum SDK: Configured in `build.gradle`
- Firebase configuration: `google-services.json`
- Signing: `azanguru.jks` keystore

### iOS (`ios/`)
- Firebase configuration: `GoogleService-Info.plist`
- Capabilities: Push notifications, in-app purchase

### Cross-platform (`web/`, `windows/`, `linux/`, `macos/`)
- Basic support configured
- Primary focus is mobile (Android/iOS)

---

## 🛠️ Development Workflow

### Getting Started:
```bash
# Clone repository
git clone git@bitbucket.org:eia2023/azan-guru-mobile.git
cd azan-guru-mobile

# Install dependencies
flutter pub get

# Generate Hive adapters (if models changed)
flutter pub run build_runner build

# Run on device/emulator
flutter run
```

### Code Organization Tips:
1. **New Feature** → Create BLoC in `lib/bloc/`
2. **New Screen** → Add to appropriate module in `lib/ui/`
3. **New Route** → Define in `route/app_routes.dart`
4. **New Model** → Add to `lib/ui/model/`
5. **New API Call** → Add query/mutation to `graphQL/queries.dart`

---

## 👥 Key Responsibilities by Module

### Home Module
- Course discovery and featured content
- User guidance and course recommendations
- Announcements and news

### My Courses Module
- Display enrolled courses
- Progress tracking
- Resume learning functionality

### Live Classes Module
- Schedule display
- Join live sessions
- Class notifications

### Help Module
- FAQ browsing
- Submit support tickets
- Live chat with support team

### Profile Module
- User information management
- Settings and preferences
- Account deletion

---

## 🎨 Design System

### Spacing
- Uses ScreenUtil for responsive spacing (`.w`, `.h`, `.r`)
- Consistent padding/margin throughout

### Components
- Custom buttons in `common/custom_button.dart`
- Reusable tiles and cards
- Loading indicators

### Animations
- Page transitions with GetX
- Smooth navigation
- Loading states

---

## 🔒 Security Considerations

1. **JWT Storage**: Tokens stored in secure storage
2. **API Authentication**: Auto-attached to GraphQL requests
3. **Session Expiry**: Handled gracefully with redirect to login
4. **Deep Link Validation**: URLs validated before processing
5. **Sensitive Data**: Never logged or exposed

---

## 📚 Further Reading

- **Flutter BLoC**: https://bloclibrary.dev/
- **GraphQL**: https://graphql.org/
- **GetX Navigation**: https://pub.dev/packages/get
- **Hive Database**: https://docs.hivedb.dev/
- **Firebase**: https://firebase.google.com/docs/flutter

---

## 🤝 Getting Help

When you encounter issues:
1. Check the conversation history for similar problems
2. Review the BLoC state/event flow
3. Add debug logs in critical sections
4. Use Flutter DevTools for debugging
5. Check GraphQL responses in network logs

---

## 📌 Quick Reference

### Important User Flows:

**New User Journey:**
```
Launch App → Splash → Language Selection → Login → Send OTP → 
Verify OTP → Home → Choose Course → Purchase → Learn
```

**Returning User:**
```
Launch App → Splash → (Auto Login) → TabBar (Home)
```

**Learning Flow:**
```
My Courses → Select Course → View Lessons → 
Play Video → Complete Homework → Next Lesson → Complete Course → Certificate
```

---

## 🎯 Summary

AzanGuru is a comprehensive Islamic learning platform with:
- **BLoC architecture** for clean state management
- **GraphQL API** for backend communication
- **Multi-feature app** including courses, Quran, live classes, and support
- **Monetization** through IAP and ads
- **Modern UI** with custom components and responsive design
- **Robust handling** of auth, storage, and notifications

The codebase is well-organized with clear separation of concerns, making it maintainable and scalable for future enhancements.

---

**Welcome to the team! 🎉**
