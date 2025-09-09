import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'aadhaar_otp_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showAnimatedText = true;

  void _navigateToAadhaarLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AadhaarOtpScreen()));
  }

  void _navigateToRegistration() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
  }

  void _loginWithEmail() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    print("Email login: ${_emailController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Animated Logo
              Hero(
                tag: 'app-logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Name - Will stay after animation
              AnimatedTextKit(
                animatedTexts: [
                  ScaleAnimatedText(
                    'CivicLink',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    duration: const Duration(milliseconds: 1000),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                onFinished: () {
                  setState(() {
                    _showAnimatedText = false;
                  });
                },
              ),
              
              // Persistent text after animation completes
              if (!_showAnimatedText)
                Text(
                  'CivicLink',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              
              const SizedBox(height: 10),

              // Tagline - Will stay after animation
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'BE THE CHANGE IN YOUR COMMUNITY',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),
              
              // Persistent tagline after animation completes
              if (!_showAnimatedText)
                Text(
                  'BE THE CHANGE IN YOUR COMMUNITY',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              
              const SizedBox(height: 50),

              // Login Form Card
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(color: Colors.blue.shade800),
                        prefixIcon: Icon(Feather.mail, color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(color: Colors.blue.shade800),
                        prefixIcon: Icon(Feather.lock, color: Colors.blue.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Feather.eye_off : Feather.eye,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    _isLoading
                        ? Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.blue.shade700,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _loginWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.blue.shade300,
                            ),
                            child: Text(
                              'LOGIN WITH EMAIL',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Aadhaar Login Button
                    OutlinedButton(
                      onPressed: _navigateToAadhaarLogin,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        side: BorderSide(color: Colors.blue.shade700, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Feather.smartphone, color: Colors.blue.shade700),
                          const SizedBox(width: 10),
                          Text(
                            'LOGIN WITH AADHAAR OTP',
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Registration Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                        GestureDetector(
                          onTap: _navigateToRegistration,
                          child: Text(
                            'SIGN UP',
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}