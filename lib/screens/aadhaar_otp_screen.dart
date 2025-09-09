import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AadhaarOtpScreen extends StatefulWidget {
  const AadhaarOtpScreen({super.key});

  @override
  State<AadhaarOtpScreen> createState() => _AadhaarOtpScreenState();
}

class _AadhaarOtpScreenState extends State<AadhaarOtpScreen> {
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  void _sendOTP() {
    if (_aadhaarController.text.length == 12) {
      setState(() => _otpSent = true);
      print("OTP sent to Aadhaar: ${_aadhaarController.text}");
    }
  }

  void _verifyOTP() {
    if (_otpController.text.length == 6) {
      print("Verifying OTP: ${_otpController.text}");
      // Add OTP verification logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aadhaar Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Aadhaar Input
            TextField(
              controller: _aadhaarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Aadhaar Number',
                hintText: 'Enter 12-digit Aadhaar',
              ),
              maxLength: 12,
            ),
            
            const SizedBox(height: 20),
            
            // Send OTP Button
            ElevatedButton(
              onPressed: _sendOTP,
              child: const Text('Send OTP'),
            ),
            
            if (_otpSent) ...[
              const SizedBox(height: 30),
              const Text('Enter OTP sent to your mobile'),
              
              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) {},
                onCompleted: (value) => _verifyOTP(),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: const Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}