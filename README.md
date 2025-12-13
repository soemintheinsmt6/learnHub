# learn_hub

learn_hub is a Flutter application that demonstrates a small but complete stack:

- Authentication (login screen)
- Bottom navigation with nested tabs
- User list and company list screens backed by a REST API
- BLoC for state management
- Repository and service layers for separation of concerns

The project is structured to be a good starting point for medium-sized apps that
need clean separation between UI, business logic, and data access.

## Features

- Login with username and password (`lib/features/login_screen.dart`)
- Home tab placeholder (`lib/features/navigation_tab/home_screen.dart`)
- User list tab with avatars and basic info (`lib/features/navigation_tab/user_list.dart`)
- Company list tab with card-style tiles and progress indicator (`lib/features/navigation_tab/company_list.dart`)
- Bottom navigation to switch between Home, Users, and Companies (`lib/features/bottom_navigation_screen.dart`)
- API integration via a configurable `ApiService` (`lib/services/api_service.dart`)
- Error handling using a custom `ApiException` and alert/snackbar widgets

## Architecture

The app uses a layered architecture with clear responsibilities:

- **Presentation layer (UI + BLoC)**
  - Widgets in `lib/features` compose screens.
  - Reusable UI components live in `lib/widgets`.
  - BLoC classes in `lib/bloc` hold the presentation logic and expose states to the UI.

- **Domain / data-access layer**
  - Repositories in `lib/repositories` abstract the data source and expose high-level methods such as `fetchUsers`, `fetchCompanies`, and `login`.
  - Models in `lib/models` (`User`, `Company`) define the app’s core entities and serialization logic.

- **Infrastructure layer**
  - `ApiService` in `lib/services/api_service.dart` wraps HTTP calls, shared headers, token handling, and response/error handling.
  - `AppConfig` in `lib/core/app_config.dart` holds configuration like `baseUrl`.

### Flow example: User list

1. `UserList` screen (`lib/features/navigation_tab/user_list.dart`) creates a `UserBloc` and injects a `UserRepository`.
2. On initialization, `UserBloc` receives a `LoadUser` event (`lib/bloc/user/user_event.dart`).
3. `UserBloc` (`lib/bloc/user/user_bloc.dart`) calls `UserRepository.fetchUsers()`.
4. `UserRepository` (`lib/repositories/user_repository.dart`) calls `ApiService.get('users')`.
5. The JSON response is mapped to `User` models (`lib/models/user.dart`) and returned.
6. `UserBloc` emits loading, success, or error states (`lib/bloc/user/user_state.dart`), and the UI rebuilds with a loading spinner, error message, or `ListView` of `UserTile` widgets (`lib/widgets/user_tile.dart`).

The company list follows the same pattern using `CompanyBloc`, `CompanyRepository`, and `Company` models.

## Design patterns

- **BLoC (Business Logic Component)**
  - Implemented with `flutter_bloc`.
  - Each feature has its own BLoC:
    - `LoginBloc` (`lib/bloc/login/login_bloc.dart`)
    - `UserBloc` (`lib/bloc/user/user_bloc.dart`)
    - `CompanyBloc` (`lib/bloc/company/company_bloc.dart`)
  - Events represent user actions or lifecycle events (`*_event.dart`).
  - States capture UI-relevant data (`*_state.dart`), commonly including `isLoading`, data collections, and `error`.

- **Repository pattern**
  - `LoginRepository`, `UserRepository`, and `CompanyRepository` encapsulate access to the REST API.
  - This keeps HTTP details out of BLoCs and widgets and makes the code easier to test.

- **Service layer**
  - `ApiService` centralizes HTTP logic (headers, base URL, token, error handling).
  - Other parts of the app depend on the service via repositories, not on the raw `http` client.

- **Value equality with `Equatable`**
  - BLoC states and some data classes extend `Equatable` to support value-based equality, which reduces unnecessary rebuilds and simplifies testing.

- **Manual dependency injection**
  - Dependencies (repositories and services) are manually constructed and passed into widgets/BLoCs.
  - Example: `UserList` creates an `ApiService`, wraps it in a `UserRepository`, and injects it into `UserBloc`.

## Folder structure

High-level structure:

```text
lib/
  bloc/
    company/
      company_bloc.dart
      company_event.dart
      company_state.dart
    login/
      login_bloc.dart
      login_event.dart
      login_state.dart
    user/
      user_bloc.dart
      user_event.dart
      user_state.dart
  core/
    app_config.dart
  features/
    navigation_tab/
      company_list.dart
      home_screen.dart
      user_list.dart
    bottom_navigation_screen.dart
    login_screen.dart
  models/
    company.dart
    user.dart
  repositories/
    company_repository.dart
    login_repository.dart
    user_repository.dart
  services/
    api_service.dart
  utils/
    api_exception.dart
    app_color.dart
    text_field_decoration.dart
  widgets/
    alert/
      alert.dart
      snack_bar.dart
    buttons/
      bar_button.dart
    text_fields/
      custom_text_field.dart
    company_tile.dart
    user_tile.dart
  main.dart

test/
  bloc/
    company_bloc_test.dart
    login_bloc_test.dart
    user_bloc_test.dart
  repositories/
    company_repository_test.dart
    login_repository_test.dart
    user_repository_test.dart
  mock_api.dart

integration_test/
  app_test.dart
```

## Testing

The project includes both unit tests and an integration test:

- **Unit tests**
  - Repository tests (`test/repositories/*_repository_test.dart`) verify API calls and JSON mapping.
  - BLoC tests (`test/bloc/*_bloc_test.dart`) verify state transitions for success and error flows.

- **Integration test**
  - `integration_test/app_test.dart` boots the full app and verifies the main shell renders correctly.

Run all tests:

```bash
flutter test
```

Run only the integration tests:

```bash
flutter test integration_test
```

## Running the app

1. Ensure Flutter SDK is installed and on your `PATH`.
2. Configure the API base URL in `.env` referenced by `AppConfig`.
3. Fetch dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```
