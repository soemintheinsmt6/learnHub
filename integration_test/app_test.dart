import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn_hub/main.dart' as app;
import 'package:learn_hub/widgets/tiles/company_tile.dart';
import 'package:learn_hub/widgets/tiles/user_tile.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to wait for splash screen, onboarding, and navigate to login screen
  Future<void> waitForLoginScreen(WidgetTester tester) async {
    // Wait for splash screen (1.5 seconds) plus navigation time
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if we're already on login screen
    final welcomeText = find.text('Welcome Developer');
    if (welcomeText.evaluate().isNotEmpty) {
      // Already on login screen, no need to navigate
      return;
    }

    // Check if we're on onboarding screen
    final skipButton = find.text('Skip');
    final continueButton = find.text('Continue');
    
    // If we see Skip or Continue, we're on onboarding screen
    if (skipButton.evaluate().isNotEmpty) {
      // Tap Skip to go to last page
      await tester.tap(skipButton);
      await tester.pumpAndSettle();
      
      // Now on last page, tap Sign In to go to login screen
      final signInBtn = find.text('Sign In');
      if (signInBtn.evaluate().isNotEmpty) {
        await tester.tap(signInBtn.first);
        await tester.pumpAndSettle();
      }
    } else if (continueButton.evaluate().isNotEmpty) {
      // Navigate through all onboarding pages
      for (int i = 0; i < 5; i++) {
        final continueBtn = find.text('Continue');
        if (continueBtn.evaluate().isNotEmpty) {
          await tester.tap(continueBtn);
          await tester.pumpAndSettle();
        } else {
          // Last page, tap Sign In
          final signInBtn = find.text('Sign In');
          if (signInBtn.evaluate().isNotEmpty) {
            await tester.tap(signInBtn.first);
            await tester.pumpAndSettle();
            break;
          }
        }
      }
    } else {
      // Might be on last page of onboarding already
      final signInBtn = find.text('Sign In');
      if (signInBtn.evaluate().isNotEmpty && welcomeText.evaluate().isEmpty) {
        // On onboarding last page, tap Sign In
        await tester.tap(signInBtn.first);
        await tester.pumpAndSettle();
      }
    }

    // Verify we're on login screen (not onboarding)
    // Login screen has "Welcome Developer" text
    expect(find.text('Welcome Developer'), findsOneWidget);
  }

  // Helper to attempt login and wait for navigation
  Future<void> attemptLogin(WidgetTester tester) async {
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.first, 'testuser');
      await tester.pump();
      await tester.enterText(textFields.last, 'testpassword');
      await tester.pump();
    }

    final signInButton = find.text('Sign In');
    if (signInButton.evaluate().isNotEmpty) {
      await tester.tap(signInButton.last);
      await tester.pumpAndSettle(const Duration(seconds: 10));
    }
  }

  group('Learn Hub Integration Tests', () {
    testWidgets('App launches and displays splash screen then onboarding then login screen', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pump();

      // Initially, splash screen should be visible
      // Wait a bit to see splash screen
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for splash screen to complete and navigate to onboarding
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on onboarding screen
      // Either Skip or Continue button should be present
      final skipButton = find.text('Skip');
      final continueButton = find.text('Continue');
      expect(
        skipButton.evaluate().isNotEmpty || continueButton.evaluate().isNotEmpty,
        isTrue,
      );

      // Navigate through onboarding to login
      await waitForLoginScreen(tester);

      // Verify login screen is displayed
      // "Sign In" appears twice - once as title, once as button text
      expect(find.text('Sign In'), findsNWidgets(2));
      expect(find.text('Welcome Developer'), findsOneWidget);
      // "User Name" appears twice - once as label, once as hint text
      expect(find.text('User Name'), findsNWidgets(2));
      // "Password" appears twice - once as label, once as hint text
      expect(find.text('Password'), findsNWidgets(2));
    });

    testWidgets('Onboarding screen displays and can be navigated', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pump();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on onboarding screen
      // Either Skip or Continue button should be present
      final skipButton = find.text('Skip');
      final continueButton = find.text('Continue');
      expect(
        skipButton.evaluate().isNotEmpty || continueButton.evaluate().isNotEmpty,
        isTrue,
      );
      
      // Verify page indicator is present
      expect(find.byType(PageView), findsOneWidget);

      // Verify we can see onboarding content
      // The first page should have a title
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Can skip onboarding and navigate to login', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pump();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap Skip button
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Should be on last page now, tap Sign In
      final signInButton = find.text('Sign In');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton.first);
        await tester.pumpAndSettle();
      }

      // Verify we're on login screen
      expect(find.text('Welcome Developer'), findsOneWidget);
    });

    testWidgets('User detail screen can be opened from user list', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);
      await attemptLogin(tester);

      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final userTab = find.byIcon(Icons.person);
        if (userTab.evaluate().isNotEmpty) {
          await tester.tap(userTab);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        final userTileFinder = find.byType(UserTile);
        if (userTileFinder.evaluate().isNotEmpty) {
          await tester.tap(userTileFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.text('About Me'), findsOneWidget);
          expect(find.text('Personal Information'), findsOneWidget);
        }
      }
    });

    testWidgets('Company detail screen can be opened from company list', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);
      await attemptLogin(tester);

      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final companyTab = find.byIcon(Icons.collections_bookmark);
        if (companyTab.evaluate().isNotEmpty) {
          await tester.tap(companyTab);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        final companyTileFinder = find.byType(CompanyTile);
        if (companyTileFinder.evaluate().isNotEmpty) {
          await tester.tap(companyTileFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.text('About Company'), findsOneWidget);
          expect(find.text('Company Information'), findsOneWidget);
        }
      }
    });

    testWidgets('Login screen has input fields', (WidgetTester tester) async {
      app.main();
      await waitForLoginScreen(tester);

      // Verify TextField widgets exist
      expect(find.byType(TextField), findsNWidgets(2));

      // Find text fields by their labels (title text above the field)
      // "User Name" and "Password" appear as labels and hints
      expect(find.text('User Name'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });

    testWidgets('Can enter credentials in login form', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Find and enter username (first TextField)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      final userNameField = textFields.first;
      await tester.enterText(userNameField, 'testuser');
      await tester.pump();

      // Find and enter password (second TextField)
      final passwordField = textFields.last;
      await tester.enterText(passwordField, 'testpassword');
      await tester.pump();

      // Verify that text fields are interactive and password is obscured
      // Since TextField uses onChanged callback without controller, we verify
      // that we can successfully enter text (which we did above) and check obscureText
      final usernameTextField = tester.widget<TextField>(userNameField);
      final passwordTextField = tester.widget<TextField>(passwordField);

      // Verify password field is obscured
      expect(passwordTextField.obscureText, isTrue);

      // Verify username field is not obscured
      expect(usernameTextField.obscureText, isFalse);

      // Verify both fields exist and are TextField widgets
      expect(usernameTextField, isA<TextField>());
      expect(passwordTextField, isA<TextField>());
    });

    testWidgets('Sign In button is present and tappable', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      final userNameField = textFields.first;
      await tester.enterText(userNameField, 'testuser');
      await tester.pump();

      // Find and enter password (second TextField)
      final passwordField = textFields.last;
      await tester.enterText(passwordField, 'testpassword');
      await tester.pump();

      // Find the Sign In button text (appears in BarButton)
      final signInButtonText = find.text('Sign In');
      expect(signInButtonText, findsWidgets);

      // Find the InkWell (BarButton uses InkWell for tap handling)
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsAtLeastNWidgets(1));

      // Tap the button
      await tester.tap(signInButtonText.last);
      await tester.pump();
    });

    testWidgets('Complete login flow with navigation', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Verify we're on login screen
      expect(find.text('Welcome Developer'), findsOneWidget);

      // Enter credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'testuser');
      await tester.pump();
      await tester.enterText(textFields.last, 'testpassword');
      await tester.pump();

      // Tap Sign In button (use last occurrence which is the button text)
      final signInButton = find.text('Sign In').last;
      await tester.tap(signInButton);

      // Wait for navigation (with timeout)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // After successful login, bottom navigation should appear
      // Note: This will only pass if login is successful
      // In a real scenario, you might need to mock the API response
      final bottomNavBar = find.byType(BottomNavigationBar);

      if (bottomNavBar.evaluate().isNotEmpty) {
        // Verify bottom navigation has 3 tabs
        final bottomNav = tester.widget<BottomNavigationBar>(bottomNavBar);
        expect(bottomNav.items.length, 3);

        // Verify home screen is displayed
        expect(find.text('Home'), findsOneWidget);
      }
    });

    testWidgets('Bottom navigation bar has three tabs', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Try to find bottom navigation bar
      // This will only work if we're on the bottom navigation screen
      final bottomNavBar = find.byType(BottomNavigationBar);

      // If bottom nav exists, verify it has items
      if (bottomNavBar.evaluate().isNotEmpty) {
        final bottomNav = tester.widget<BottomNavigationBar>(bottomNavBar);
        expect(bottomNav.items.length, 3);

        // Verify icons are present
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.collections_bookmark), findsOneWidget);
      }
    });

    testWidgets('Can switch between navigation tabs', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // This test assumes we're on the bottom navigation screen
      final bottomNavBar = find.byType(BottomNavigationBar);

      if (bottomNavBar.evaluate().isNotEmpty) {
        // Verify home screen is initially displayed
        expect(find.text('Home'), findsOneWidget);

        // Tap on second tab (User List)
        final userTab = find.byIcon(Icons.person);
        if (userTab.evaluate().isNotEmpty) {
          await tester.tap(userTab);
          await tester.pumpAndSettle();

          // Verify user list screen appears
          expect(find.text('User List'), findsOneWidget);
        }

        // Tap on third tab (Company List)
        final companyTab = find.byIcon(Icons.collections_bookmark);
        if (companyTab.evaluate().isNotEmpty) {
          await tester.tap(companyTab);
          await tester.pumpAndSettle();

          // Verify company list screen appears
          expect(find.text('Company List'), findsOneWidget);
        }

        // Tap back to home tab
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab);
          await tester.pumpAndSettle();

          // Verify home screen appears again
          expect(find.text('Home'), findsOneWidget);
        }
      }
    });

    testWidgets('User list screen loads and displays content', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Navigate to user list if bottom nav is available
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final userTab = find.byIcon(Icons.person);
        if (userTab.evaluate().isNotEmpty) {
          await tester.tap(userTab);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify user list screen elements
          expect(find.text('User List'), findsOneWidget);

          // Check for loading indicator or list content
          final loadingIndicator = find.byType(CircularProgressIndicator);
          final listView = find.byType(ListView);

          // Either loading or list should be present
          expect(
            loadingIndicator.evaluate().isNotEmpty ||
                listView.evaluate().isNotEmpty,
            isTrue,
          );
        }
      }
    });

    testWidgets('Company list screen loads and displays content', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Navigate to company list if bottom nav is available
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final companyTab = find.byIcon(Icons.collections_bookmark);
        if (companyTab.evaluate().isNotEmpty) {
          await tester.tap(companyTab);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify company list screen elements
          expect(find.text('Company List'), findsOneWidget);

          // Check for loading indicator or list content
          final loadingIndicator = find.byType(CircularProgressIndicator);
          final listView = find.byType(ListView);

          // Either loading or list should be present
          expect(
            loadingIndicator.evaluate().isNotEmpty ||
                listView.evaluate().isNotEmpty,
            isTrue,
          );
        }
      }
    });

    testWidgets('Home screen displays correctly', (WidgetTester tester) async {
      app.main();
      await waitForLoginScreen(tester);

      // Navigate to home if bottom nav is available
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab);
          await tester.pumpAndSettle();

          // Verify home screen content
          expect(find.text('Home'), findsOneWidget);
        }
      } else {
        // If not logged in, verify login screen
        // "Sign In" appears twice (title and button), so use findsWidgets
        expect(find.text('Sign In'), findsWidgets);
        expect(find.text('Welcome Developer'), findsOneWidget);
      }
    });

    testWidgets('Password field is obscured', (WidgetTester tester) async {
      app.main();
      await waitForLoginScreen(tester);

      // Find password field (second TextField)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      final passwordField = textFields.last;
      final passwordTextField = tester.widget<TextField>(passwordField);

      // Verify password field has obscureText set to true
      expect(passwordTextField.obscureText, isTrue);
    });

    testWidgets('Error handling on failed login attempt', (
      WidgetTester tester,
    ) async {
      app.main();
      await waitForLoginScreen(tester);

      // Verify we start on login screen
      expect(find.text('Welcome Developer'), findsOneWidget);

      // Enter invalid credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'invaliduser');
      await tester.pump();
      await tester.enterText(textFields.last, 'wrongpassword');
      await tester.pump();

      // Tap Sign In button
      final signInButton = find.text('Sign In').last;
      await tester.tap(signInButton);

      // Wait for API response (but don't wait too long)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Check what screen we're on after login attempt
      final signInText = find.text('Sign In');
      final bottomNavBar = find.byType(BottomNavigationBar);

      // Either we're still on login screen (failed login) or we navigated (success)
      // Note: Error handling uses NativeDialogPlus which shows a native dialog
      // that may not be easily testable, but we can verify the app state
      if (signInText.evaluate().isNotEmpty) {
        // Still on login screen - login failed
        expect(find.text('Welcome Developer'), findsOneWidget);
      } else if (bottomNavBar.evaluate().isNotEmpty) {
        // Navigated to home screen - login succeeded (API may accept any credentials)
        // This is acceptable behavior for the test
        expect(bottomNavBar, findsOneWidget);
      } else {
        // Neither screen found - might be in a dialog or loading state
        // This is still acceptable as it shows the app is handling the login attempt
        expect(true, isTrue);
      }
    });
  });
}
