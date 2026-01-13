# Prime Flutter Documentation

This directory contains the documentation site for Prime Flutter, built with [Astro](https://astro.build) and [Starlight](https://starlight.astro.build).

## Getting Started

1.  **Install Dependencies**:
    ```bash
    npm install
    ```

2.  **Run Development Server**:
    ```bash
    npm run dev
    ```
    The site will be available at http://localhost:4321.

## Adding a New Component

To add documentation for a new component with interactive playgrounds, follow these steps:

### 1. Create Playground Page (`website/playground/lib/screens/`)
Create a new file (e.g., `my_component_page.dart`) in the playground app. This page should accept customizable parameters (via query params) to showcase different states of your widget.

```dart
class MyComponentPage extends StatelessWidget {
  final String? variant;
  const MyComponentPage({super.key, this.variant});

  @override
  Widget build(BuildContext context) {
    // Render widget based on variant
  }
}
```

### 2. Register Route (`website/playground/lib/main.dart`)
Add a new route check in `onGenerateRoute` to handle your component's path.

```dart
if (uri.path == '/my-component') {
  final variant = uri.queryParameters['variant'];
  return PrimePageRoute(builder: (_) => MyComponentPage(variant: variant));
}
```

### 3. Add Documentation Page (`website/src/content/docs/components/`)
Create an `.mdx` file (e.g., `my-component.mdx`). Use the `<Preview>` component to embed the playground.

```mdx
import Preview from '../../../components/Preview.astro';

<Preview src="my-component?variant=default" height="200px">

```dart
// Code snippet showing how to use the widget
```

</Preview>
```

### 4. Verify
Run `npm run dev` to see your changes locally. The preview iframe points to the `website/playground` app build.
