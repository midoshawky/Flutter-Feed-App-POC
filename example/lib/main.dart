import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feed_module/feed_module.dart';

const String _authToken =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi1iYWNrZW5kLXNodXdpZXIucG9tYWMuaW5mby9hcGkvYXV0aC9sb2dpbiIsImlhdCI6MTc3NzIxNjc0MywiZXhwIjoxNzc3MjQ5MTQzLCJuYmYiOjE3NzcyMTY3NDMsImp0aSI6ImtQSUVGb1dUTHZlNGgyZkgiLCJzdWIiOiIxOTIiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.W_keFtTzO6dCnXOTHbUWLa9QoVls7jot17GU1zjkVkc';

// JWT sub claim → user 192 ("Ahmed" / new_test1258)
const String _currentUserId = '192';
const String _currentUserName = 'Ahmed';

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
        useMaterial3: false,
        fontFamily: 'Product Sans',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
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
      ),
    );
  }
}
