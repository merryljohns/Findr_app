import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/get_started.dart';

void main() {
  runApp(const FindrApp());
=======
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(const MyApp());
>>>>>>> d4c15df (backend)
}

class FindrApp extends StatelessWidget {
  const FindrApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary purple/blue from the image as the seed color for Material 3.
    // The specific hex from the buttons is roughly #814FEF or similar.
    final Color seedColor = const Color(0xFF814FEF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Findr',
<<<<<<< HEAD
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        // Optional: Custom text theme to match the clean font style in the image.
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
          ), // Gray body text
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      home: const GetStartedScreen(),
    );
  }
}
=======
      home: const LoginScreen(),
    );
  }
}
>>>>>>> d4c15df (backend)
