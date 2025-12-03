# P.R.I.M.E. Flutter

**Pretty Rad Interactive Modular Elements**

Made with 💙 at Viam.

A collection of UI elements for Flutter, implementing Viam's design system.

> **Note**
> This is the Flutter implementation of Prime. For the web version, see [viamrobotics/prime](https://github.com/viamrobotics/prime).

## Features

Prime Flutter provides a set of polished, reusable widgets that adhere to a consistent design system:

-   **Avatar**: Circular avatars for user profiles or icons.
-   **Badge**: Status indicators with various semantic variants (success, danger, warning, info).
-   **Button**: Customizable buttons with multiple variants (primary, secondary, ghost, danger).
-   **Input**: Styled text fields with built-in focus states and icon support.
-   **ListItem**: Versatile list items with support for leading/trailing widgets and expansion.
-   **NavigationBar**: A custom bottom navigation bar.
-   **PrimeAppBar**: A clean, customizable app bar.
-   **PrimeSheet**: A modal bottom sheet with a modern look and feel.
-   **FilterPill**: Selectable chips for filtering content.
-   **Progress**: Circular progress indicators.
-   **PrimeScaffold**: A scaffold wrapper that integrates seamlessly with the Prime theme.

## Getting started

Add `prime_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  prime_flutter:
    path: ./path/to/prime_flutter
```

## Usage

Wrap your application in `PrimeApp` to provide the necessary theme context:

```dart
import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeApp(
      title: 'Prime Flutter Demo',
      home: const HomeScreen(),
    );
  }
}
```

### Using Widgets

```dart
import 'package:prime_flutter/prime_flutter.dart';

// ...

Button(
  label: 'Click Me',
  variant: ButtonVariant.primary,
  onPressed: () {
    print('Button pressed!');
  },
)

Input(
  placeholder: 'Enter your name',
  leading: Icon(PrimeIcons.account),
)
```

## Theming

Prime Flutter uses `PrimeTheme` to manage colors, typography, and other design tokens. You can access the current theme using `PrimeTheme.of(context)`.

```dart
final theme = PrimeTheme.of(context);
final primaryColor = theme.colorScheme.primary;
```

## License

Copyright 2025 Viam Inc.
Apache 2.0
