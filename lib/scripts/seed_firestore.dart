import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../services/firestore_seed_service.dart';

/// Standalone script to seed Firestore.
/// Run with: flutter run -t lib/scripts/seed_firestore.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🌱 Seeding Firestore data...');
  final seeder = FirestoreSeedService();
  
  // Custom logic: always seed if running this script specifically
  await seeder.seedIfNeeded(force: true);

  print('✅ Seeding complete! Exiting in 3 seconds...');
  await Future.delayed(const Duration(seconds: 3));
}
