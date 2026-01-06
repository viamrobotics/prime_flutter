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

## Embedding Flutter Widgets

The documentation uses an `iframe` approach to embed live Flutter widgets.
This requires the Flutter example app to be running and accessible.

### Setup Flutter App for Embedding

1.  The Flutter app needs to be served as a web app.
2.  It works best if the Flutter app supports **hash routing** or specific routes for each widget (e.g., `/#/button`).
3.  Update `src/components/FlutterEmbed.astro` if your Flutter app URL differs from `http://localhost:8080`.

### Workflow

1.  Run Flutter app: `cd ../example && flutter run -d web-server --web-port 8080`
2.  Run Docs app: `npm run dev`
3.  Edit `.mdx` files in `src/content/docs/` to add new pages.
4.  Use `<FlutterEmbed widget="route_name" />` to embed a widget.
