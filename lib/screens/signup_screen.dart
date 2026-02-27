import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Important to keep this true so the sheet moves up with the keyboard
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Diagonal Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDED8FF), Color(0xFFFBE4EF)],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Colors.black54,
                      ),
                      label: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ),

                // This pushes the white box further down
                const Spacer(flex: 2),

                // 3. White Container (The "Sheet")
                Flexible(
                  flex: 8, // Adjust this to make the box take more/less height
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: SingleChildScrollView(
                      // Increased horizontal padding to 40
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 24, // Slightly smaller title
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Empowering you to discover hidden value and resell with ease.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Compact Input Fields ---
                          _buildCompactTextField(
                            hint: 'Full name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactTextField(
                            hint: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactTextField(
                            hint: 'Department',
                            icon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactTextField(
                            hint: 'Year of Study',
                            icon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildCompactTextField(
                            hint: 'Password',
                            isPassword: true,
                            icon: Icons.lock_outline,
                          ),

                          const SizedBox(height: 25),

                          // 4. Gradient Button
                          Container(
                            width: double.infinity,
                            height: 50, // Reduced height
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBAED3), Color(0xFFB9AAFF)],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'Sign up with',
                            style: TextStyle(
                              color: Colors.black26,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialIcon(Icons.facebook, Colors.blue),
                              const SizedBox(width: 20),
                              _socialIcon(
                                Icons.g_mobiledata,
                                Colors.red,
                                size: 35,
                              ),
                              const SizedBox(width: 20),
                              _socialIcon(Icons.apple, Colors.black),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Login Link
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Already have an account? Log In",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8E7CFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modified with smaller contentPadding
  Widget _buildCompactTextField({
    required String hint,
    bool isPassword = false,
    IconData? icon,
  }) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(fontSize: 14), // Smaller text
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.black26, size: 18)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        // Reduced vertical padding from 18 to 12
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, {double size = 25}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
