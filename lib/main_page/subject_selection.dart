import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarisma/main_page/camera_page.dart';
import 'package:http/http.dart' as http;
import 'package:yarisma/question_page/question_page.dart';

class SubjectSelection {
  static String? selectedClass; // seçilen sınıfı gösterir
  static String? lessonSubject; // seçilen konu
  static String? selectedLesson; // seçilen ders
  static String? _token;
  static File? lastCroppedImage;
  static bool isLoading = false;
  static int? selectedIndex;
  static Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> selectClass(BuildContext context) async {
    _token = await _loadToken();
    bool isLoading = false;

    // SINIFI KAYDEDER
    Future<void> saveClass() async {
      const String apiUrl =
          "https://btkbackend.randevuburada.com/api/v1/questions/category/add";

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
          body: jsonEncode({
            "categoryName": selectedClass,
            "parentId": 0,
          }),
        );

        if (response.statusCode == 200) {
          print("Başarıyla kaydedildi: $selectedClass");
        } else {
          print("Hata: ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("Hata oluştu: $e");
      }
    }

    // SINIFIN DAHA ÖNCE SEÇİLİP SEÇİLMEDİĞİNİ KONTROL EDER
    Future<void> controlClassIsAwaible(
        StateSetter setModalState, BuildContext context) async {
      final String url =
          "https://btkbackend.randevuburada.com/api/v1/questions/category/list?categoryName=${Uri.encodeComponent(selectedClass ?? '')}&onlyRoot=false";

      setModalState(() {
        isLoading = true;
      });

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $_token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          if (data['data'] != null && data['data'].isEmpty) {
            await saveClass();
          } else {
            print("Data dolu, veri kaydedilmeden devam ediyor.");
          }
        } else {
          print("Veri çekme başarısız: ${response.statusCode}");
        }
      } catch (e) {
        print('Veri çekme hatası: $e');
      } finally {
        setModalState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        _selectLessons(context);
      }
    }

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int? selectedC = null;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bir sınıf seçin',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (selectedIndex != null) {
                            controlClassIsAwaible(setModalState, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen bir sınıf seçin.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            itemCount: 12,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text('${index + 1}.Sınıf'),
                                trailing: selectedIndex == index
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : null,
                                onTap: () {
                                  setModalState(() {
                                    if (selectedIndex == index) {
                                      selectedIndex = null;
                                      selectedClass = null;
                                    } else {
                                      selectedClass = '${index + 1}.Sınıf';
                                      selectedIndex = index;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _selectLessons(BuildContext context) async {
    _token = await _loadToken();

    Future<int?> getId(BuildContext context) async {
      final String url =
          "https://btkbackend.randevuburada.com/api/v1/questions/category/list?categoryName=${Uri.encodeComponent(selectedClass ?? '')}&onlyRoot=false";

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $_token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          if (data['data'] != null && data['data'].isNotEmpty) {
            int idValue = data['data'][0]['id'];
            print("ID Değeri: $idValue ");
            return idValue;
          } else {
            print("Data dizisi boş veya null.");
            return null;
          }
        } else {
          print("Veri çekme başarısız: ${response.statusCode}");
          return null;
        }
      } catch (e) {
        print('Veri çekme hatası: $e');
        return null;
      }
    }

//DERSLERİ KAYDET
    Future<void> saveLessons(String selectedLesson) async {
      final int? parentId = await getId(context);
      const String apiUrl =
          "https://btkbackend.randevuburada.com/api/v1/questions/category/add";

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
          body: jsonEncode({
            "categoryName": selectedLesson,
            "parentId": parentId,
          }),
        );

        if (response.statusCode == 200) {
          print("Başarıyla kaydedildi: $selectedLesson");
        } else {
          print("Hata: ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("Hata oluştu: $e");
      }
    }

    Future<void> controLessonsIsAwaible(
        BuildContext context, String selectedLesson) async {
      final int? parentId = await getId(context);

      if (parentId != null) {
        final String url =
            "https://btkbackend.randevuburada.com/api/v1/questions/category/list?categoryName=${Uri.encodeComponent(selectedLesson)}&parentId=$parentId&onlyRoot=false";

        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $_token",
              "Content-Type": "application/json",
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data != null &&
                data['data'] != null &&
                data['data'].isNotEmpty) {
              String name = data['data'][0]['name'];

              if (name == selectedLesson) {
                print(
                    "Ders zaten mevcut: $name, kayıt yapılmadan devam ediliyor.");
              } else {
                print("Ders mevcut değil, kaydediliyor.");
                await saveLessons(selectedLesson);
              }
            } else {
              saveLessons(selectedLesson);
            }
          } else {
            print("Veri çekme başarısız: ${response.statusCode}");
          }
        } catch (e) {
          print('Veri çekme hatası: $e');
        }
      } else {
        print("Geçerli bir parentId değeri bulunamadı.");
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        selectedLesson = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "Ders Seçin (Seçili: ${selectedLesson ?? ''})",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_sharp),
                            iconSize: 35,
                            onPressed: () async {
                              if (selectedLesson != null) {
                                controLessonsIsAwaible(
                                    context, selectedLesson!);
                                Navigator.pop(context);
                                _showSubjectInputDialog(context);
                                print("Seçilen Ders: $selectedLesson");
                              } else {
                                print("Ders seçilmedi.");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  _buildSubjectTile(
                      context, "Türkçe", Icons.book, setModalState),
                  _buildSubjectTile(
                      context, "Matematik", Icons.calculate, setModalState),
                  _buildSubjectTile(
                      context, "Tarih", Icons.public, setModalState),
                  _buildSubjectTile(
                      context, "Coğrafya", Icons.terrain, setModalState),
                  _buildSubjectTile(
                      context, "Felsefe", Icons.question_answer, setModalState),
                  _buildSubjectTile(
                      context, "Fizik", Icons.bolt, setModalState),
                  _buildSubjectTile(
                      context, "Kimya", Icons.science, setModalState),
                  _buildSubjectTile(
                      context, "Biyoloji", Icons.eco, setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Ders listesi oluşturan fonksiyon
  static Widget _buildSubjectTile(BuildContext context, String lesson,
      IconData icon, StateSetter setModalState) {
    return ListTile(
      leading: Icon(icon),
      title: Text(lesson),
      trailing: selectedLesson == lesson
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setModalState(() {
          if (selectedLesson == lesson) {
            selectedLesson = null;
          } else {
            selectedLesson = lesson;
          }
        });
      },
    );
  }

  static Future<void> _showSubjectInputDialog(BuildContext context) async {
    _token = await _loadToken();
//İD AL
    Future<int?> getId(BuildContext context) async {
      final String url =
          "https://btkbackend.randevuburada.com/api/v1/questions/category/list?categoryName=${Uri.encodeComponent(selectedLesson ?? '')}&onlyRoot=false"; //ders id dönüyor

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $_token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          if (data['data'] != null && data['data'].isNotEmpty) {
            int idValue = data['data'][0]['id'];
            print("ID Değeri: $idValue ");
            return idValue;
          } else {
            print("Data dizisi boş veya null.");
            return null;
          }
        } else {
          print("Veri çekme başarısız: ${response.statusCode}");
          return null;
        }
      } catch (e) {
        print('Veri çekme hatası: $e');
        return null;
      }
    }

    Future<void> saveSubject(int id) async {
      final int? lessonId = await getId(context);
      const String apiUrl =
          "https://btkbackend.randevuburada.com/api/v1/questions/sub-category/add";

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
          body: jsonEncode({
            "subCategoryName": lessonSubject,
            "parentId": 0,
            "categoryId": lessonId // ders id si
          }),
        );

        if (response.statusCode == 200) {
          print("Başarıyla kaydedildi: $selectedLesson");
        } else {
          print("Hata: ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("Hata oluştu: $e");
      }
    }

    Future<int?> controlSubjectIsAwaible(
        BuildContext parentContext, String selectedLesson) async {
      final int? id = await getId(parentContext);
      print(id);

      if (id != null) {
        final String url =
            "https://btkbackend.randevuburada.com/api/v1/questions/sub-category/list/tree?categoryId=$id";

        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $_token",
              "Content-Type": "application/json",
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            print(data);

            if (data != null && data['data'] != null) {
              for (var item in data['data']) {
                String name = item['name'];
                print(name);

                await saveSubject(id);
              }
            }

            print(" kaydediliyor.");
          } else {
            print("Veri çekme başarısız: ${response.statusCode}");
          }
        } catch (e) {
          print('Veri çekme hatası: $e');
          throw "Bir hata oluştu: $e";
        }

        return id;
      } else {
        throw "Geçerli bir parentId değeri bulunamadı.";
      }
    }

    Future<Map<String, dynamic>?> uploadImage() async {
      final int? lessonId = await getId(context);
      final int? subjectId =
          await controlSubjectIsAwaible(context, selectedLesson!);
      const String apiUrl =
          "https://btkbackend.randevuburada.com/api/v1/questions/add";
      var token = await _loadToken();

      File? croppedImage = CameraPage.lastCroppedImage;

      if (croppedImage != null) {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'multipart/form-data';

        request.fields['CategoryId'] = lessonId.toString();
        request.fields['SubCategoryId'] = subjectId.toString();

        request.files.add(
          await http.MultipartFile.fromPath(
            "QuestionImage",
            croppedImage.path,
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          print("Resim başarıyla yüklendi!");
          var responseData = await http.Response.fromStream(response);
          print(jsonDecode(responseData.body));
          return jsonDecode(responseData.body);
        } else {
          print("Yükleme hatası: ${response.statusCode}");
          var errorData = await http.Response.fromStream(response);
          print("Hata Detayı: ${jsonDecode(errorData.body)}");
        }
      } else {
        print("Kırpılan bir resim yok.");
      }
      return null;
    }

    TextEditingController subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konu Bilgisi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Lütfen dersin konusunu giriniz:",
                  textAlign: TextAlign.left,
                ),
              ),
              TextField(
                controller: subjectController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "(Kümeler, dil bilgisi gibi)",
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Devam Et"),
              onPressed: () async {
                lessonSubject = subjectController.text;
                if (lessonSubject!.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Hata"),
                        content: const Text("Konu boş bırakılamaz."),
                        actions: [
                          TextButton(
                            child: const Text("Tamam"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  try {
                    await controlSubjectIsAwaible(context, lessonSubject!);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 15),
                              Text("Cevap hazırlanıyor..."),
                            ],
                          ),
                        );
                      },
                    );

                    Map<String, dynamic>? response = await uploadImage();
                    Navigator.of(context).pop();

                    if (response != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const QuestionsPage(),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Hata"),
                            content:
                                const Text("Resim yüklemesi başarısız oldu."),
                            actions: [
                              TextButton(
                                child: const Text("Tamam"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (error) {
                    // Hata mesajı
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Hata"),
                          content: Text(error.toString()),
                          actions: [
                            TextButton(
                              child: const Text("Tamam"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
