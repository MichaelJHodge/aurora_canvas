# Aurora Canvas

A small Flutter app that fetches and displays a random image from an API, with a background color that adapts to the image for an immersive effect.

## Features

- Single-screen UI with a centered square image
- Background color adapts to the image
- “Another” button loads a new image
- Smooth transitions (image fade-in, animated background)
- Loading and error states handled gracefully
- Image caching and placeholders for large remote images
- Light and dark mode support
- Basic accessibility via semantic labels

## API

- **Endpoint:** `GET /image`
- **Example response:**

```json
{
  "url": "https://images.unsplash.com/..."
}
```

- **Swagger documentation**:
  https://november7-730026606190.europe-west1.run.app/docs#/default/get_random_image_image__get

## Project Structure

The project is organized with clear separation of concerns:

```
lib/
├─ core/
│  ├─ theme/ # Image-based color extraction & background blending**
│  └─ ui/ # Shared UI primitives (error banner, loading overlay)
│
├─ data/
│  ├─ image_api.dart # HTTP + decoding
│  └─ random_image_repository.dart
│
├─ domain/
│  ├─ random_image.dart
│  └─ failures.dart # Typed failure models
│
├─ presentation/
│  └─ image/
│     ├─ image_screen.dart
│     ├─ random_image_controller.dart
│     ├─ random_image_state.dart
│     └─ widgets/ # Feature-specific UI widgets
│
└─ main.dart
```

## Running the App

```
flutter pub get
flutter run
```

## Demo

Demo video: 