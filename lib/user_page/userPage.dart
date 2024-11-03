import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

//TOKEN YÜKLE
  String? _token;
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
    await _fetchUserData();
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _fetchUserData() async {
    print("fetchUserData fonksiyonu içi token $_token");
    const url = "https://btkbackend.randevuburada.com/api/v1/account/user-info";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userInfo = data["data"];
        print("İşlem başarılı");
        print(data);
        print(userInfo);
        print(userInfo["firstName"]);
        setState(() {
          nameController.text = userInfo["firstName"] ?? "";
          surnameController.text = userInfo["lastName"] ?? "";
          emailController.text = userInfo["email"] ?? "";
          phoneController.text = userInfo["phoneNumber"] ?? "";
          passwordController.text = "********";
        });
      } else {
        print("Veri çekme başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    const url =
        "https://btkbackend.randevuburada.com/api/v1/account/update/user-info";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "firstName": nameController.text,
          "lastName": surnameController.text,
          "phoneNumber": phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        print("Kullanıcı bilgileri güncellendi.");

        _fetchUserData();
      } else {
        print('Güncelleme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Güncelleme hatası: $e');
    }
  }

  Future<void> _updatePassword(
      String currentPassword, String newPassword) async {
    const url =
        "https://btkbackend.randevuburada.com/api/v1/account/update/password";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
          "confirmPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        print("Şifre başarıyla güncellendi.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifre başarıyla güncellendi")),
        );
      } else {
        print('Şifre güncelleme başarısız: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Şifre güncellenemedi, lütfen tekrar deneyin")),
        );
      }
    } catch (e) {
      print('Şifre güncelleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu")),
      );
    }
  }

  Future<void> _updateEmail(
      {required String newEmail, required String currentPassword}) async {
    const url =
        "https://btkbackend.randevuburada.com/api/v1/account/update/mail";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newEmail": newEmail,
        }),
      );

      if (response.statusCode == 200) {
        print("E-posta adresi güncellendi.");

        _fetchUserData();
      } else {
        print('E-posta güncelleme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('E-posta güncelleme hatası: $e');
    }
  }

//TEXTFİELD ALANLARI
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kullanıcı Bilgileri"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField("İsim", nameController),
              _buildEditableField("Soy İsim", surnameController),
              _buildEditableField("Email", emailController),
              _buildEditableField("Telefon", phoneController),
              _buildEditableField("Şifre", passwordController,
                  obscureText: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: "$label ",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    if (label == "Şifre") {
                      _showPasswordEditDialog();
                    } else if (label == "Email") {
                      _showEmailEditDialog(controller);
                    } else {
                      _showEditDialog(label, controller);
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }

  void _showPasswordEditDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Şifre Güncelle"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Mevcut şifre",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Mevcut şifre boş bırakılamaz.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Yeni şifre",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Yeni şifre boş bırakılamaz.";
                    }
                    if (value.length < 6) {
                      return "Yeni şifre en az 6 karakter olmalıdır.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Yeni şifreyi doğrula",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Şifreyi doğrulamak için lütfen bir değer girin.";
                    }
                    if (value != newPasswordController.text) {
                      return "Yeni şifreler eşleşmiyor.";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Kaydet"),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

// EMAİL GÜNCELLEME
  void _showEmailEditDialog(TextEditingController controller) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    emailController.text = controller.text;
    final formKey = GlobalKey<FormState>();

    String? emailValidator(String? value) {
      // E-posta formatını kontrol et
      if (value == null || value.isEmpty) {
        return "Email alanı boş bırakılamaz.";
      }
      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return "Geçerli bir email adresi girin.";
      }
      return null;
    }

    String? passwordValidator(String? value) {
      if (value == null || value.isEmpty) {
        return "Lütfen şifrenizi girin.";
      }
      return null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Email Güncelle"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Yeni email giriniz",
                  ),
                  validator: emailValidator,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: "Mevcut şifrenizi giriniz",
                  ),
                  obscureText: true,
                  validator: passwordValidator,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Kaydet"),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _updateEmail(
                    newEmail: emailController.text,
                    currentPassword: passwordController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String label, TextEditingController controller) {
    final TextEditingController dialogController = TextEditingController();
    dialogController.text = controller.text;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: AlertDialog(
            title: Text("$label Güncelle"),
            content: TextFormField(
              controller: dialogController,
              decoration: InputDecoration(hintText: "$label giriniz"),
              obscureText: label == "Şifre" ? true : false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "$label boş bırakılamaz.";
                }
                if (label == "Telefon") {
                  if (label.length != 10) {
                    return "Telefon 10 haneli olmalıdır";
                  }
                }
                return null;
              },
            ),
            actions: [
              TextButton(
                child: const Text("İptal"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Kaydet"),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      controller.text = dialogController.text;
                    });
                    _updateUserInfo();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
