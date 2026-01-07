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
│  ├─ theme/ # Image-based color extraction & background blending
│  └─ ui/ # Shared UI primitives (error banner, loading overlay)
│
├─ data/
│  ├─ image_api.dart # HTTP + decoding
│  └─ random_image_repository.dart
│
├─ domain/
│  ├─ random_image.dart # Domain model
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

## Testing
- Basic unit tests for data and domain logic
- Widget tests covering key UI states (loading, error, interactions)
- Tests focus on behavior rather than implementation details.

## Running the App

```
flutter pub get
flutter run
```

## Demo

Demo video: 

iOS: https://github.com/user-attachments/assets/bc4d2090-8a8c-40ee-8b69-0baade20c984

Android: https://github.com/user-attachments/assets/59e674aa-9e39-4682-b918-a85bd12e4660





