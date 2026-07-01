import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feed_module/feed_module.dart';

const String _authToken =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi1iYWNrZW5kLXNodXdpZXIucG9tYWMuaW5mby9hcGkvYXV0aC9yZWZyZXNoIiwiaWF0IjoxNzgyMjk1NjUzLCJleHAiOjE3ODM5NDM2NjEsIm5iZiI6MTc4MjczNDA2MSwianRpIjoidWNvMmNBZEFSbEZUS2xZeSIsInN1YiI6IjE5MiIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjciLCJpZCI6MTkyLCJ1c2VybmFtZSI6Im5ld190ZXN0MTI1OCIsInRva2VuX3ZlcnNpb24iOjEsInR5cGUiOiJmcmVlbGFuY2VyIiwibmFtZSI6IkFobWVkIiwiYXZhdGFyIjoiaHR0cHM6Ly9kZXYtYmFja2VuZC1zaHV3aWVyLnBvbWFjLmluZm8vc3RvcmFnZS9wcm9maWxlcy82OWI3ZTBjZDVkNDUyLmpwZyJ9.MPZoLfQM6vcq55gZ-S-3clM2im0LaUVR9OOy_vU6gi4';

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
