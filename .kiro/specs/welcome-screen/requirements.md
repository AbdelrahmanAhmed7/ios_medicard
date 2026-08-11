# Requirements Document

## Introduction

The Welcome Screen is a one-time, post-login experience presented to existing (non-new) MediCard users after the app is installed or updated. It appears once — immediately after the video splash screen completes and the home screen loads — to greet the user, highlight key app features and benefits, and then get out of the way. It must not interfere with the existing video splash or the onboarding flow for brand-new users.

## Glossary

- **Welcome_Screen**: The full-screen overlay or dedicated route that displays the welcome experience to authenticated users.
- **Welcome_Cubit**: The BLoC/Cubit responsible for determining whether the Welcome_Screen should be shown and for marking it as seen.
- **SharedPreferences**: The local key-value store used to persist the "has seen welcome" flag across app launches.
- **hasSeenWelcome flag**: A boolean value stored in SharedPreferences under the key `hasSeenWelcome` that records whether the Welcome_Screen has already been displayed.
- **Authenticated_User**: A user for whom a valid session exists in AuthSessionStorage (access token or refresh token present and not expired).
- **New_User**: A user who has never logged in and for whom the onboarding flow (`/onboarding` → `/guest-home`) applies.
- **App_Launch**: A cold start of the MediCard application — i.e., when `main()` runs and the video splash plays.
- **Feature_Highlight**: A single card or section inside the Welcome_Screen that describes one app benefit (e.g., provider network, e-card, appointments, discounts).
- **CTA_Button**: The dismissal button labelled "ابدأ" (Arabic) / "Get Started" (English) that closes the Welcome_Screen and navigates the user to the home screen.
- **GoRouter**: The routing library used by the app.
- **HomeScreen**: The main authenticated screen with the 4-tab IndexedStack (`/medicard-home`).

---

## Requirements

### Requirement 1: Display Condition

**User Story:** As an existing MediCard user, I want to see a welcome screen once after installing or updating the app, so that I am informed about key features without being interrupted on subsequent launches.

#### Acceptance Criteria

1. WHEN the app launches AND the Authenticated_User navigates to `/medicard-home` AND the `hasSeenWelcome` flag is `false` (or absent), THEN the Welcome_Screen SHALL be shown automatically.
2. WHEN the app launches AND the `hasSeenWelcome` flag is `true`, THEN the Welcome_Screen SHALL NOT be shown and the HomeScreen SHALL be displayed directly.
3. WHEN a New_User follows the onboarding flow to `/guest-home`, THEN the Welcome_Screen SHALL NOT be shown regardless of the `hasSeenWelcome` flag state.
4. WHEN the user is not authenticated and the app routes to `/medicard-login` or `/guest-home`, THEN the Welcome_Screen SHALL NOT be shown.

### Requirement 2: Display Timing

**User Story:** As a user, I want the welcome screen to appear after the app is fully loaded, so that it does not interfere with the video splash or navigation initialization.

#### Acceptance Criteria

1. WHEN the `AppVideoSplash` finishes playing AND the HomeScreen has completed its initial build, THEN the Welcome_Screen SHALL appear on the first rendered frame of the HomeScreen.
2. WHEN the Welcome_Screen is being shown, THEN the HomeScreen bottom navigation and content SHALL remain mounted and visible beneath the overlay.
3. THE Welcome_Screen SHALL animate in with a fade transition of duration 300 milliseconds or less.

### Requirement 3: One-Time Display

**User Story:** As a user, I want the welcome screen to appear exactly once, so that it does not reappear on subsequent cold starts after I have dismissed it.

#### Acceptance Criteria

1. WHEN the user dismisses the Welcome_Screen by tapping the CTA_Button, THEN the Welcome_Cubit SHALL persist the `hasSeenWelcome` flag as `true` in SharedPreferences before the screen is dismissed.
2. WHEN the app is cold-started again after the Welcome_Screen has been dismissed, THEN the Welcome_Screen SHALL NOT be shown.
3. THE Welcome_Cubit SHALL read the `hasSeenWelcome` flag from SharedPreferences during HomeScreen initialization, before the first frame is rendered.

### Requirement 4: Content and Layout

**User Story:** As a user, I want the welcome screen to greet me and show me what MediCard can do, so that I understand the app's value at a glance.

#### Acceptance Criteria

1. THE Welcome_Screen SHALL display a greeting message that includes the localised text for "Welcome to MediCard" (key: `welcome_screen.greeting_title`).
2. THE Welcome_Screen SHALL display at least three Feature_Highlight items, each containing an icon, a title, and a short description.
3. THE Welcome_Screen SHALL include the CTA_Button labelled with the localised text for "Get Started" (key: `welcome_screen.cta_button`).
4. WHERE the app locale is Arabic (`ar`), THE Welcome_Screen SHALL render all text in Arabic and use RTL layout direction.
5. WHERE the app locale is English (`en`), THE Welcome_Screen SHALL render all text in English and use LTR layout direction.
6. THE Welcome_Screen SHALL use `flutter_screenutil` sizing (`ScreenUtil`) for all dimensions to ensure correct rendering across device sizes.

### Requirement 5: Dismissal

**User Story:** As a user, I want to dismiss the welcome screen easily, so that I can start using the app without friction.

#### Acceptance Criteria

1. WHEN the user taps the CTA_Button, THEN the Welcome_Screen SHALL dismiss with a fade-out animation of duration 300 milliseconds or less.
2. WHEN the Welcome_Screen is dismissed, THEN the HomeScreen SHALL become fully interactive with no residual overlay.
3. IF the user taps outside the Welcome_Screen content area (barrier tap), THEN the Welcome_Screen SHALL NOT be dismissed; only the CTA_Button SHALL trigger dismissal.

### Requirement 6: Integration with Existing Navigation

**User Story:** As a developer, I want the welcome screen to integrate cleanly with GoRouter and the existing HomeScreen, so that no navigation state is corrupted.

#### Acceptance Criteria

1. THE Welcome_Screen SHALL be implemented as an overlay shown from within the HomeScreen's `initState` via `WidgetsBinding.instance.addPostFrameCallback`, matching the pattern used by `SummerPromoDialog`.
2. WHEN the Welcome_Screen is shown, THEN the GoRouter navigation stack SHALL contain only `/medicard-home`; no additional route SHALL be pushed.
3. WHEN the Welcome_Screen is dismissed, THEN the GoRouter navigation stack SHALL remain at `/medicard-home` without any back-navigation side effects.
4. THE Welcome_Cubit SHALL be provided via the existing `ServiceLocator` (`sl`) pattern and SHALL be registered as a `LazySingleton`.

### Requirement 7: Localization

**User Story:** As an Arabic or English-speaking user, I want all welcome screen text to appear in my chosen language, so that the experience feels native to me.

#### Acceptance Criteria

1. THE Welcome_Screen SHALL source all displayed strings exclusively from the `easy_localization` translation files (`ar.json` and `en.json`) under the `welcome_screen` namespace.
2. WHEN the app language changes via `LocalizationCubit`, THE Welcome_Screen — if visible — SHALL update its displayed text immediately without requiring a rebuild of the parent widget tree.

### Requirement 8: State Management

**User Story:** As a developer, I want a dedicated Cubit to manage the welcome screen's visibility state, so that the logic is testable and separate from UI code.

#### Acceptance Criteria

1. THE Welcome_Cubit SHALL expose a boolean state `shouldShow` that is `true` when the Welcome_Screen should be visible and `false` otherwise.
2. WHEN `Welcome_Cubit.initialize()` is called, THEN the Welcome_Cubit SHALL read the `hasSeenWelcome` flag from SharedPreferences and set `shouldShow` accordingly.
3. WHEN `Welcome_Cubit.markAsSeen()` is called, THEN the Welcome_Cubit SHALL write `hasSeenWelcome = true` to SharedPreferences and emit `shouldShow = false`.
4. IF SharedPreferences throws an exception during read or write, THEN the Welcome_Cubit SHALL default to `shouldShow = false` and log the error, ensuring the app continues to function normally.
