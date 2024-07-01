import 'package:firebase_demo/NotificationHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  String code = "";

  @override
  void initState() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    super.initState();
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      // Get the user's email address (may be used as username)
      final String? username = userCredential.user?.email;
      print(
          'Signed in with username: $username'); // Or use username for other purposes

      return userCredential;
    } else {
      return null;
    }
  }

  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Sign the user in automatically if verification is instant
          await _auth.signInWithCredential(credential);
          print("Signed in automatically");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          code = verificationId;
          // Save the verification ID and resend token for later use
          print("Verification code sent: $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval failed, may need to ask user to input code manually.
          print("Auto-retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print("Error sending verification code: $e");
    }
  }

  Future<void> signInWithVerificationCode(
      String verificationId, String code) async {
    print(
        "dsddsdsdsdsdsdsdsdsdsdsd + $verificationId =============== code $code");
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      await _auth.signInWithCredential(credential);
      print("Signed in successfully!");
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the value as needed
                ),
              ),
              onPressed: () {
                signInWithGoogle();
              },
              child: const Text("Google Sign-In"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the value as needed
                ),
              ),
              onPressed: () {
                sendVerificationCode("+916264861959");
              },
              child: const Text("Need Mobile Verification"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Please enter 6 digit OTP Here...",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(width: 1, color: Colors.black)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the value as needed
                ),
              ),
              onPressed: () {
                NotificationHelper.showNotification(
                  'Hello, Notification!',
                  'This is a test notification.',
                );
                //  signInWithVerificationCode(code, controller.text);
              },
              child: const Text("Verify PLease"),
            ),
          ],
        ),
      ),
    );
  }
}
