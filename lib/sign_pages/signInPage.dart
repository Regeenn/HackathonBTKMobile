import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarisma/bottom_navbar/bottom_menu.dart';
import 'package:yarisma/sign_pages/signUpPage.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
          ),
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  String? validateEmail(String? value) {
    const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(emailPattern);
    if (value == null || value.isEmpty) {
      return 'Email boş bırakılamaz';
    } else if (!regex.hasMatch(value)) {
      return 'Geçersiz email';
    }
    return null;
  }

  Future<void> _signInUser() async {
    setState(() {
      _isLoading = true;
    });
    const String apiUrl =
        "https://btkbackend.randevuburada.com/api/v1/account/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "identifier": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 1) {
          String token = responseData['token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          print("Kullanıcı giriş yaptı");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomMenu()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Giriş işlemi başarısız: Geçersiz yanıt")),
          );
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? "Bilinmeyen bir hata oluştu";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş Hatası: $errorMessage")),
        );
        print("Giriş Hatası: $errorMessage");
      }
    } catch (e) {
      print("Giriş işlemi sırasında bir hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bir hata oluştu, lütfen tekrar deneyin.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ));
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.1),
                      child: Text(
                        "GİRİŞ YAP!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.13,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      label: "Şifre",
                      controller: _passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "şifre boş bırakılamaz";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signInUser();
                        } else {
                          print("form hata");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenWidth * 0.5, 50)),
                      child: const Text(
                        "Giriş yap",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Signuppage()),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Zaten hesabın var mı?",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Kayıt ol!",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    )
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
