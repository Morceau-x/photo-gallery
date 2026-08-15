# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app (Dart) that connects to AWS S3 to browse, display, and upload images in a masonry-style gallery. Currently a proof of concept with placeholder S3 credentials.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Code generation (freezed models, riverpod providers, go_router routes)
flutter pub run build_runner build
# Watch mode for continuous code generation
flutter pub run build_runner watch

# Run the app
flutter run

# Run tests
flutter test

# Lint/analyze
flutter analyze

# Format
dart format .
```

**Important:** After modifying any file with `@freezed`, `@riverpod`, or `@TypedGoRoute` annotations, run `build_runner build` to regenerate the `.g.dart` and `.freezed.dart` files.

## Architecture

**Layered architecture** with Riverpod for state management:

```
UI (pages/atoms) → Riverpod Providers → Repository → Datasource → S3 API
```

- **Datasource layer** (`lib/io/datasource/`): `HttpService` base class with `S3Datasource` implementing AWS Signature V4 authentication manually (HMAC-SHA256). Handles both virtual-hosted and path-style S3 URLs.
- **Repository layer** (`lib/io/repository/s3_repository.dart`): Business logic wrapping `S3Datasource`. Singleton with S3 credentials (currently TODO placeholders).
- **Models** (`lib/models/`): Freezed immutable classes with DTOs for XML→JSON S3 response parsing (via xml2json).
- **State** (`lib/ui/pages/home_page.dart`): Riverpod async providers (`s3ItemsProvider`, `fileUrlProvider`) manage data fetching.
- **Routing** (`lib/routes/`): GoRouter with typed routes via go_router_builder code generation.

## Key Patterns

- All data classes use **Freezed** for immutability and code generation
- S3 XML responses are converted to JSON with `xml2json`, then deserialized via `json_serializable`
- Media files are downloaded to temp directory on-demand; FFprobeKit extracts dimensions
- Image upload uses `image_picker` → streaming PUT via `S3Datasource.sendFile()`
