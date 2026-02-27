import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/get_started.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_page.dart';   // adjust path if folder name differs

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const FindrApp());
}

class FindrApp extends StatelessWidget {
  const FindrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color seedColor = const Color(0xFF814FEF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Findr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: Supabase.instance.client.auth.currentUser == null
    ? const GetStartedScreen()
    : const HomePageScreen(),
    );
  }
}
