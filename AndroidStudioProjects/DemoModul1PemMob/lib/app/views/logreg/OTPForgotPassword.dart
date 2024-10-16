import 'package:demomodul1pemmob/app/views/logreg/NewPassword.dart';
import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2329),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verifikasi Nomor Hp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukan Kode OTP yang telah dikirimkan ke nomor anda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextField(
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('OTP Sent'),
                        content: const Text('Kode OTP berhasil dikirim.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewPassword()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kirim'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak menerima kode? ',
                      style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Resend OTP'),
                            content:
                                const Text('Kode OTP telah dikirim ulang.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Kirim ulang',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
