import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import '../homescreen/home_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:async';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginMode { password, otp }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Timer? otpTimer; // <--- ADD THIS LINE

  String otpValue = "";
  bool _obscurePassword = true;
  LoginMode loginMode = LoginMode.password;
  bool otpSent = false;
  bool isSendingOtp = false;
  int timerSeconds = 30;
  bool isPhone(String input) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(input);
  }

  void showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.black : Colors.redAccent,
      ),
    );
  }

  

void startOtpTimer() {
  timerSeconds = 30;

  otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) return; // Prevents setState after dispose

    if (timerSeconds == 0) {
      timer.cancel();
      setState(() {});
    } else {
      setState(() => timerSeconds--);
    }
  });
}


Future<void> sendOtp() async {
  final input = emailController.text.trim();

  if (input.isEmpty) {
    showSnack("Please enter email or phone");
    return;
  }

  setState(() => isSendingOtp = true);

  final auth = Provider.of<AuthProvider>(context, listen: false);
  Map<String, dynamic> res = {};

  try {
    if (isPhone(input)) {
      // 10-digit mobile → SMS OTP
      res = await auth.sendSmsOtp(input);
    } else {
      // Otherwise treat as email
      res = await auth.sendOtp(input);
    }
  } catch (e) {
    showSnack("Something went wrong, try again.");
  } finally {
    setState(() => isSendingOtp = false);
  }

  final msg = (res["message"] ?? "Unable to send OTP").toString();
  showSnack(msg, success: true);

  // ✅ Generic success check for both:
  // "OTP sent successfully via SMS"
  // "OTP sent to your email"
  final lowerMsg = msg.toLowerCase();
  if (lowerMsg.contains("otp sent")) {
    setState(() {
      otpSent = true;
      timerSeconds = 30;
    });
    startOtpTimer();
  }
}



  Future<void> verifyOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    Map<String, dynamic> res;

    if (isPhone(emailController.text.trim())) {
      res = await auth.verifySmsOtp(emailController.text.trim(), otpValue);
    } else {
      res = await auth.verifyOtp(emailController.text.trim(), otpValue);
    }

    if (res.containsKey("token")) {
      showSnack("Login Successful 🎉", success: true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      showSnack(res["message"] ?? "Invalid OTP");
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.login(emailController.text.trim(), passwordController.text.trim());

    if (res.containsKey('token')) {
      showSnack("Login Successful 🎉", success: true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      showSnack(res["message"] ?? "Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                 constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height - 80,
    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 28),
                
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(12),
                      fillColor: Colors.black,
                      selectedColor: Colors.white,
                      color: Colors.black,
                      isSelected: [
                        loginMode == LoginMode.password,
                        loginMode == LoginMode.otp,
                      ],
                      onPressed: (i) {
                        setState(() {
                          loginMode = i == 0 ? LoginMode.password : LoginMode.otp;
                          otpSent = false;
                        });
                      },
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text("Password Login")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text("OTP Login")),
                      ],
                    ),
                
                    const SizedBox(height: 25),
                
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email or Phone Number",
                        border: UnderlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Enter email or phone" : null,
                    ),
                
                    if (loginMode == LoginMode.password) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                
                   if (loginMode == LoginMode.otp && otpSent) ...[
                  const SizedBox(height: 20),
                  const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                
                  Center(
                    child: Pinput(
                      length: 6,
                      onCompleted: (v) => otpValue = v,
                    ),
                  ),
                
                  const SizedBox(height: 18),
                
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: otpValue.length == 6 ? verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
                
                
                    const SizedBox(height: 28),
                
                    isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.black))
                        : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginMode == LoginMode.password
                    ? login
                    : !otpSent
                        ? sendOtp
                        : null,
                
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerSeconds > 0 && otpSent ? Colors.grey : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                   child: isSendingOtp
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        loginMode == LoginMode.password
                ? "Sign In"
                : !otpSent
                    ? "Send OTP"
                    : "Resend OTP in $timerSeconds s",
                        style: const TextStyle(color: Colors.white),
                      ),
                
                  ),
                ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text("Create an account", style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
