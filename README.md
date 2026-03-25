# feed_module

A reusable Flutter package for a social feed with Firestore integration and optimistic UI updates.

## Features
- **Firestore Integration**: Out-of-the-box support for fetching and updating posts.
- **Optimistic UI**: No-latency feedback for likes, comments, and reshares.
- **Seeding Service**: Easy dummy data generation for development.

## Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  feed_module:
    git:
      url: https://github.com/midoshawky/Flutter-Feed-App-POC.git
```

## Usage

```dart
import 'package:feed_module/feed_module.dart';

// ...
home: const FeedScreen(),
```

## Example

See the `example/` directory for a full demonstration application.
