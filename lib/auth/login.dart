import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petalview/auth/signup.dart';

// --- NEW IMPORT ---
import 'package:firebase_auth/firebase_auth.dart';
// --- END NEW IMPORT ---

class Login extends StatefulWidget {
  static const routeName = 'login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  bool _isLoading = false;

  static const mint  = Color(0xFFE6F3EA);
  static const green = Color(0xFF23C16B);
  static const borderLight = Color(0xFFDAEFDE);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: green, width: 1.6),
      ),
      suffixIcon: suffix,
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[A-Za-z]{2,}$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  void _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      print("Log-in successful: ${userCredential.user?.uid}");

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('home');
      }

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'invalid-credential') {
        message = 'Invalid email or password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'The email format is not valid.';
      } else {
        print(e.message);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 1. HERE IS THE NEW FORGOT PASSWORD METHOD ---
  Future<void> _forgotPassword() async {
    // 1. Get the email from the text controller
    final email = _email.text.trim();

    // 2. Validate the email (using your existing validator)
    final emailError = _emailValidator(email);
    
    if (emailError != null) {
      // If the email is empty or invalid, show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              emailError == 'Email is required'
                  ? 'Please enter your email in the field first.'
                  : emailError, // Shows "Enter a valid email"
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return; // Stop if email is not valid
    }

    // 3. If email is valid, send the reset link
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 4. Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email. Check your inbox.'),
            backgroundColor: Colors.green, // Green for success
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Print the error for debugging.
      // We'll show a generic success message anyway to prevent
      // attackers from "guessing" which emails are registered.
      print("Forgot Password Error: ${e.code}");

      // Show a generic message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent. If $email is registered, you will receive it.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle other errors
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --- END OF NEW METHOD ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg_welcome.png', fit: BoxFit.cover),
          Container(color: mint.withOpacity(0.15)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset('assets/onboarding/logo.png', height: 56),
                  const SizedBox(height: 16),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Log in',
                            style: GoogleFonts.merriweather(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: green,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _dec('Email address'),
                            validator: _emailValidator,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: _dec(
                              'Password',
                              suffix: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  const TextSpan(text: 'Forgot your Password? '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      // --- 2. THIS IS THE ONLY CHANGE IN THE BUILD METHOD ---
                                      onTap: _forgotPassword, // <-- UPDATED
                                      // --- END OF CHANGE ---
                                      child: Text(
                                        'Click here',
                                        style: GoogleFonts.merriweather(
                                          color: green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Log in button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      'Log in',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // divider "Continue with"
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Continue with',
                                  style: GoogleFonts.merriweather(fontSize: 12),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // social buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              _SocialButton(asset: 'assets/icons/google.png'),
                              _SocialButton(asset: 'assets/icons/apple.png'),
                              _SocialButton(asset: 'assets/icons/facbook.png'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // OR
                          Center(
                            child: Text(
                              'OR',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Continue as a guest
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: green, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed('home');
                              },
                              child: Text(
                                'Continue as a guest',
                                style: GoogleFonts.poppins(
                                  color: green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Don't have an account? Sign up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, Signup.routeName);
                                },
                                child: Text(
                                  "Sign up",
                                  style: GoogleFonts.poppins(
                                    color: green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  const _SocialButton({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Image.asset(asset, height: 32),
    );
  }
}