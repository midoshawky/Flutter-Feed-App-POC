import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feed_module/feed_module.dart';

const String _authToken =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi1iYWNrZW5kLXNodXdpZXIucG9tYWMuaW5mby9hcGkvYXV0aC9sb2dpbiIsImlhdCI6MTc4MjcyNTg1OCwiZXhwIjoxNzgyNzU4MjU4LCJuYmYiOjE3ODI3MjU4NTgsImp0aSI6Im5CbHJNNVNqaG4xZDFHcE8iLCJzdWIiOiIxOTIiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3IiwiaWQiOjE5MiwidXNlcm5hbWUiOiJuZXdfdGVzdDEyNTgiLCJ0b2tlbl92ZXJzaW9uIjoxLCJ0eXBlIjoiZnJlZWxhbmNlciIsIm5hbWUiOiJBaG1lZCIsImF2YXRhciI6Imh0dHBzOi8vZGV2LWJhY2tlbmQtc2h1d2llci5wb21hYy5pbmZvL3N0b3JhZ2UvcHJvZmlsZXMvNjliN2UwY2Q1ZDQ1Mi5qcGcifQ.Y4SD9G3PFtJu8E7GoCNqKwSNlLasNn-2AeUgT3TWbq8';

// JWT sub claim → user 192 ("Ahmed" / new_test1258)
const String _currentUserId = '192';
const String _currentUserName = 'Ahmed';
const String _currentUserUsername = 'new_test1258';
const String _currentUserAvatarUrl =
    'https://dev-backend-shuwier.pomac.info/storage/profiles/69b7e0cd5d452.jpg';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Feed POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Product Sans',
        brightness: Brightness.light,
        popupMenuTheme: PopupMenuThemeData(color: Colors.white),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        cardColor: Colors.white,
        cardTheme: CardThemeData(color: Colors.white),
        dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        primaryColor: const Color(0xFF4535C1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4535C1),
          surface: Colors.white,
        ),
      ),
      home: const FeedScreen(
        authToken: _authToken,
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
        currentUserUsername: _currentUserUsername,
        currentUserAvatarUrl: _currentUserAvatarUrl,
      ),
    );
  }
}
