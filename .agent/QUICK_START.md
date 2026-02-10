# AzanGuru - Quick Start Guide 🚀

## What is this app?
**AzanGuru** is an Islamic learning mobile app where users can:
- 📚 Take structured Islamic courses with video lessons
- 🎧 Listen to Quran recitations
- 👨‍🏫 Join live classes with teachers
- 💬 Get support through live chat
- 📱 Available on Android & iOS

---

## Tech Stack at a Glance

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.16.4 |
| **Language** | Dart >=3.2.3 |
| **State Management** | BLoC Pattern |
| **Backend** | GraphQL API |
| **Database** | Hive (local) + SharedPreferences |
| **Authentication** | JWT + OTP |
| **Monetization** | AdMob + In-App Purchases |
| **Notifications** | Firebase Cloud Messaging |

---

## Project Setup (5 Minutes)

```bash
# 1. Clone the repo
git clone git@bitbucket.org:eia2023/azan-guru-mobile.git
cd azan-guru-mobile

# 2. Get dependencies
flutter pub get

# 3. Generate code for Hive
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

---

## Project Structure (Mental Model)

```
lib/
├── 🎯 main.dart                  → App starts here
├── 📱 ui/                        → All screens and pages
│   ├── tabbar/                  → Bottom navigation (4 tabs)
│   ├── home_module/             → Home screen + courses
│   ├── my_course/               → User's courses
│   ├── help_module/             → Support system
│   └── lrf_module/              → Login/Register/Forgot
│
├── 🧠 bloc/                      → Business logic (BLoC pattern)
│   ├── home_bloc/               → Home screen logic
│   ├── auth/                    → Authentication
│   ├── course_detail_bloc/      → Course details
│   └── [18 more BLoCs...]
│
├── 🌐 graphQL/                   → API integration
│   ├── graphql_service.dart     → API client
│   └── queries.dart             → All queries/mutations
│
├── 🎨 constant/                  → Design system
│   ├── app_colors.dart          → Color palette
│   ├── app_assets.dart          → Images/icons paths
│   └── font_style.dart          → Typography
│
├── 🛠️ service/                   → Backend services
│   ├── local_storage/           → Data persistence
│   └── localization/            → Multi-language
│
└── 🧩 common/                    → Reusable widgets
```

---

## 4 Main Tabs (User's Perspective)

### 1️⃣ **Home** 🏠
- Browse featured courses
- Get course recommendations
- Access announcements
- View resources (Quran, prayer times, etc.)

### 2️⃣ **My Courses** 📖
- View enrolled courses
- Track learning progress
- Resume lessons
- Submit homework

### 3️⃣ **Live Classes** 🎥
- See scheduled classes
- Join live sessions
- Watch replays

### 4️⃣ **Support** 💬
- Browse FAQs
- Ask questions
- Live chat with support

*(Implemented in `lib/ui/tabbar/tabbar_page.dart`)*

---

## How User Authentication Works

```
┌─────────────┐
│ Login Page  │
└──────┬──────┘
       │ Enter phone/email
       ▼
┌─────────────┐
│  Send OTP   │ ──→ Backend sends code
└──────┬──────┘
       │ User enters OTP
       ▼
┌─────────────┐
│ Verify OTP  │ ──→ Backend returns JWT token
└──────┬──────┘
       │ Token saved securely
       ▼
┌─────────────┐
│  Home Page  │ (User is logged in)
└─────────────┘
```

**Key Files:**
- `lib/ui/lrf_module/login_page.dart` - Login UI
- `lib/bloc/auth/` - Authentication logic
- `lib/service/local_storage/storage_manager.dart` - Token storage

---

## How BLoC Pattern Works (State Management)

Every feature follows this pattern:

```
User Action  →  Event  →  BLoC  →  State  →  UI Updates
```

**Example: Loading courses on Home screen**

```dart
// 1. User opens home screen → Event is dispatched
context.read<HomeBloc>().add(LoadHomeData());

// 2. BLoC processes the event
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  on<LoadHomeData>((event, emit) async {
    emit(HomeLoading());                    // Show loading
    final courses = await fetchCourses();   // Get data
    emit(HomeLoaded(courses));              // Show courses
  });
}

// 3. UI rebuilds based on state
BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) return CircularProgressIndicator();
    if (state is HomeLoaded) return CourseList(state.courses);
    if (state is HomeError) return ErrorMessage();
  }
)
```

**Key Concept:** Separation of UI and logic!

---

## GraphQL API

**Backend:** `https://azanguru.com/graphql`

### Making API Calls:

```dart
// 1. Define query in lib/graphQL/queries.dart
final String GET_COURSES = '''
  query GetCourses {
    courses {
      id
      title
      description
    }
  }
''';

// 2. Use GraphQLService
final result = await GraphQLService().performQuery(
  GET_COURSES,
  variables: {},
);

// 3. Handle response
if (result.hasException) {
  // Handle error
} else {
  final courses = result.data['courses'];
  // Use data
}
```

**Auto Features:**
- JWT token automatically added to requests
- Session expiry handled (redirects to login)
- Caching with Hive

---

## Important Patterns & Conventions

### 1. **Navigation**
Uses **GetX** for routing:

```dart
// Navigate to a page
Get.toNamed(Routes.courseDetailPage, arguments: courseId);

// Go back
Get.back();

// Replace route
Get.offNamed(Routes.login);
```

All routes defined in: `lib/route/app_routes.dart`

### 2. **Colors**
Always use predefined colors:

```dart
import 'package:azan_guru_mobile/constant/app_colors.dart';

Container(color: AppColors.primaryColor)  // ✅ Good
Container(color: Color(0xFF123456))       // ❌ Avoid
```

### 3. **Assets**
Reference images/icons via constants:

```dart
import 'package:azan_guru_mobile/constant/app_assets.dart';

Image.asset(AssetImages.logo)           // ✅ Good
Image.asset('assets/images/logo.png')   // ❌ Avoid
```

### 4. **Typography**
Use predefined text styles:

```dart
import 'package:azan_guru_mobile/constant/font_style.dart';

Text(
  'Hello',
  style: AppFontStyle.poppinsMedium.copyWith(fontSize: 16.sp)
)
```

### 5. **Responsive Design**
Use ScreenUtil for responsive sizing:

```dart
Container(
  width: 100.w,      // Responsive width
  height: 50.h,      // Responsive height
  padding: EdgeInsets.all(16.r),  // Responsive radius
)
```

---

## Common Tasks

### ✅ Add a New Screen

1. Create file: `lib/ui/your_module/your_page.dart`
2. Define route: `lib/route/app_routes.dart`
3. Add navigation: `Get.toNamed(Routes.yourPage)`

### ✅ Add a New API Call

1. Add query to: `lib/graphQL/queries.dart`
2. Call via: `GraphQLService().performQuery(YOUR_QUERY)`
3. Handle in BLoC

### ✅ Create a New BLoC

1. Create folder: `lib/bloc/your_bloc/`
2. Add 3 files:
   - `your_bloc.dart` - Logic
   - `your_event.dart` - User actions
   - `your_state.dart` - UI states
3. Provide in `lib/ui/app.dart` MultiBlocProvider

### ✅ Debug Issues

```dart
// Add logging
import 'dart:developer' show log;

log('Debug message: $variable');
```

Check Flutter DevTools for network requests, BLoC events, and UI inspector.

---

## Key Dependencies You'll Use

| Package | Purpose | Usage |
|---------|---------|-------|
| `flutter_bloc` | State management | Managing app state |
| `get` | Navigation | Routing between screens |
| `graphql_flutter` | API calls | Fetching data |
| `hive` | Local database | Offline data storage |
| `flutter_screenutil` | Responsive UI | Sizing widgets |
| `cached_network_image` | Image loading | Displaying images |
| `pod_player` | Video player | Course videos |
| `firebase_messaging` | Push notifications | User notifications |

---

## File Naming Conventions

- **Screens:** `your_screen_page.dart` (e.g., `home_page.dart`)
- **BLoCs:** `your_bloc.dart`, `your_event.dart`, `your_state.dart`
- **Models:** `mdl_your_model.dart` or `your_data.dart`
- **Widgets:** `descriptive_name.dart` (e.g., `custom_button.dart`)

---

## Testing Scenarios

### 1. **Login Flow**
- Enter phone → Receive OTP → Enter OTP → Should see Home

### 2. **Course Purchase**
- Browse courses → Select → Purchase → Should appear in "My Courses"

### 3. **Video Playback**
- Open course → Select lesson → Play video → Should play smoothly

### 4. **Offline Mode**
- Open Listen Quran → Play audio → Turn off network → Should continue playing (cached)

### 5. **Ads Display**
- Free user: Should see banner ads
- Premium user: Should NOT see ads

---

## Environment Variables

Check these files for configuration:
- `lib/firebase_options.dart` - Firebase config
- `lib/graphQL/graphql_service.dart` - API URL
- `android/app/google-services.json` - Android Firebase
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase

---

## Troubleshooting

### App won't build?
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive errors?
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Cache issues?
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

---

## Next Steps

1. ✅ Read full overview: `.agent/PROJECT_OVERVIEW.md`
2. ✅ Run the app: `flutter run`
3. ✅ Explore code: Start with `main.dart` → `app.dart` → `tabbar_page.dart`
4. ✅ Make a small change: Try changing a color or text
5. ✅ Create a feature: Follow the patterns you see

---

## Resources

- **Flutter Docs:** https://docs.flutter.dev/
- **BLoC Pattern:** https://bloclibrary.dev/
- **GetX Navigation:** https://pub.dev/packages/get
- **GraphQL Flutter:** https://pub.dev/packages/graphql_flutter

---

**Happy Coding! 🎉**

If you have questions, check the main overview doc or explore the codebase - it's well-organized!
