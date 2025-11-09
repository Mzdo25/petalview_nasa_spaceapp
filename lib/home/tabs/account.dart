import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// nigga
// --- NEW IMPORTS ---
// To get the current user and sign out
import 'package:firebase_auth/firebase_auth.dart';
// To fetch the user's data from the database
import 'package:cloud_firestore/cloud_firestore.dart';
// To navigate back to the login screen
import 'package:petalview/auth/login.dart';
// --- END NEW IMPORTS ---


// --- 1. CONVERTED TO A STATEFUL WIDGET ---
class AccountScreen extends StatefulWidget {
  // We no longer pass the name in, we fetch it.
  const AccountScreen({super.key});
  static const routeName = 'Account';

  // ثوابت ألوان
  static const mint = Color(0xFFE6F3EA);
  static const green = Color(0xFFDAEFDE);
  static const barGreen = Color(0xFF1E7E5A);
  static const pastelChip = Color(0xFFFFE0B2);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  // --- 2. ADDED STATE VARIABLES ---
  String _userName = "";  // Will hold the user's name
  bool _isLoading = true; // To show a loading indicator

  // --- 3. ADDED 'initState' AND 'fetch' METHODS ---
  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch data when the widget loads
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current user from Authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the user's document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Get the 'firstName' field from the document
          // and update our state
          setState(() {
            _userName = (userDoc.data() as Map<String, dynamic>)['firstName'] ?? 'User';
            _isLoading = false;
          });
        } else {
          // Handle case where user is authenticated but doc doesn't exist
          setState(() {
            _userName = "User";
            _isLoading = false;
          });
        }
      } else {
        // Handle case where no user is logged in
        setState(() {
          _userName = "Guest";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle any errors
      setState(() {
        _userName = "Guest";
        _isLoading = false;
      });
    }
  }

  // --- 4. ADDED REAL SIGN-OUT METHOD ---
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Go back to the login screen
        Navigator.of(context).pushReplacementNamed(Login.routeName);
      }
    } catch (e) {
      print("Error signing out: $e");
      // Show an error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --- END OF NEW METHODS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg_welcome.png', fit: BoxFit.cover),
          Container(color: AccountScreen.mint.withOpacity(0.15)),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/onboarding/logo.png',
                    height: 52,
                  ),
                ),
                const SizedBox(height: 32),

                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        // --- 5. UPDATED USER ICON ---
                        // Show a loading circle or the icon
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: AccountScreen.barGreen))
                          : const Icon(Icons.perm_identity_sharp, size: 90, color: Colors.black),
                      ),
                      const Positioned(
                        right: 30,
                        top: 50,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.favorite, size: 30, color: Color(0xffFCD9BB)),
                        ),
                      ),
                      Positioned(
                        bottom: -12,
                        right: 56,
                        child: InkWell(
                          onTap: () {
                            // TODO: Change profile picture
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, size: 18, color: AccountScreen.barGreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 6. UPDATED NAME DISPLAY ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hello, ",
                      style: GoogleFonts.merriweather(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      // Show a placeholder while loading, then the user's name
                      _isLoading ? "..." : "$_userName!",
                      style: GoogleFonts.merriweather(
                        fontSize: 30,
                        color: AccountScreen.barGreen,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                // --- END OF NAME UPDATE ---

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                  child: Column(
                    children: [
                      _AccountButton(
                        text: "SOS",
                        onPressed: () {
                          // TODO: 
                        },
                      ),
                      const SizedBox(height: 12),
                      _AccountButton(
                        text: "Settings",
                        onPressed: () {
                          // TODO:
                        },
                      ),
                      const SizedBox(height: 12),
                      _AccountButton(
                        text: "About us",
                        onPressed: () {
                          // TODO:
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // --- 7. UPDATED SIGN OUT BUTTON ---
                      _AccountButton(
                        text: "Sign out",
                        filled: true,
                        onPressed: _signOut, // Calls the real sign out method
                      ),
                      // --- END OF SIGN OUT UPDATE ---
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;

  const _AccountButton({
    required this.text,
    required this.onPressed,
    this.filled = false,
  });

  static const green = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: green, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.merriweather(
            color: green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}