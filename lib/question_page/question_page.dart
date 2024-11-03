import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lessonmodel {
  final String questions;
  final String answer;
  final String imageUrl;

  Lessonmodel({
    required this.questions,
    required this.answer,
    required this.imageUrl,
  });
}

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({
    super.key,
  });

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  String? selectedSubject;
  bool newOld = false;
  String? _token;
  bool _isLoading = false;
  late int questionIds;
  late String createdDates;
  late String lessonsFromData;
  late String subCategoryNames;

  String? searchText = "";

  @override
  void initState() {
    super.initState();
    _getQuestionList();
  }

  static Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _getQuestionList() async {
    setState(() {
      _isLoading = true;
    });
    _token = await _loadToken();

    const String url =
        "https://btkbackend.randevuburada.com/api/v1/questions/list";
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
        print("soru listesi çekme cevabı: $data");

        _addDataToCourseContents(data);

        setState(() {});
      } else {
        print("Veri çekme başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print('Veri çekme hatası: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addDataToCourseContents(Map<String, dynamic> data) {
    print("Veri ekleniyor: $data");

    final List<dynamic> questionsList = data['data'];

    for (var questionData in questionsList) {
      questionIds = (questionData['id'] ?? 0);
      createdDates = (questionData['createdAt'] ?? "Varsayılan Tarih");
      lessonsFromData =
          (questionData['category']['name'] ?? "Varsayılan Kategori");
      subCategoryNames =
          (questionData['subCategory']['name'] ?? "Varsayılan Alt Kategori");

      final String questions = questionData['question'] ?? "Varsayılan soru";
      final String answer =
          questionData['answers'] != null && questionData['answers'].isNotEmpty
              ? questionData['answers'][0]['answer'] ?? "Varsayılan cevap"
              : "Varsayılan cevap";
      final String imageUrl = questionData['questionImage'] ??
          "https://www.boslukkopyala.com/wp-content/uploads/2023/04/Carpi-Isareti-Kopyala.jpg";

      final newLesson = Lessonmodel(
        questions: questions,
        answer: answer,
        imageUrl: imageUrl,
      );

      // courseContents ekleme
      if (courseContents.containsKey(lessonsFromData)) {
        courseContents[lessonsFromData]!.add(newLesson);
      } else {
        courseContents[lessonsFromData] = [newLesson];
      }
    }

    setState(() {});
  }

  void _selectLessons() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 16),
                    child: Center(
                      child: Text(
                        "Ders Seçin",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  buildSelectLesson("Türkçe", Icons.book),
                  buildSelectLesson("Matematik", Icons.calculate),
                  buildSelectLesson("Tarih", Icons.public),
                  buildSelectLesson("Coğrafya", Icons.terrain),
                  buildSelectLesson("Felsefe", Icons.question_answer),
                  buildSelectLesson("Fizik", Icons.bolt),
                  buildSelectLesson("Kimya", Icons.science),
                  buildSelectLesson("Biyoloji", Icons.eco),
                  buildSelectLesson("Diğer", Icons.more_horiz),
                  buildSelectLesson("Hepsi", Icons.category),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSelectLesson(String lessonFromData, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(lessonFromData),
      onTap: () {
        setState(() {
          selectedSubject = lessonFromData == "Hepsi" ? null : lessonFromData;
        });
        Navigator.pop(context);
      },
    );
  }

  final Map<String, List<Lessonmodel>> courseContents = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sorular"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Ara...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        newOld = !newOld;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sırala'),
                        const SizedBox(width: 8),
                        Icon(
                          newOld ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectLessons();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Ders'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Konu'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLessonsDisplay(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLessonsDisplay() {
    List<Widget> filteredLessons = [];
    if (selectedSubject != null &&
        courseContents.containsKey(selectedSubject)) {
      filteredLessons = _buildFilteredContent(selectedSubject!);
    } else if (selectedSubject == null) {
      filteredLessons = _buildFilteredAllLessons();
    }
    return filteredLessons.isNotEmpty
        ? filteredLessons
        : [const Text("Sonuç bulunamadı")];
  }

  List<Widget> _buildFilteredContent(String lessonFromData) {
    List<Widget> lessonWidgets = [];
    if (courseContents.containsKey(lessonFromData)) {
      for (var lesson in courseContents[lessonFromData]!) {
        if (lesson.questions.contains(searchText!)) {
          lessonWidgets.add(_lessonWidget(lesson));
          lessonWidgets.add(const SizedBox(height: 16));
        }
      }
    }
    return lessonWidgets;
  }

  List<Widget> _buildFilteredAllLessons() {
    List<Widget> allLessons = [];
    courseContents.forEach((lessonFromData, lessons) {
      for (var lesson in lessons) {
        if (lesson.questions.contains(searchText!)) {
          allLessons.add(_lessonWidget(lesson));
          allLessons.add(const SizedBox(height: 16));
        }
      }
    });
    return allLessons;
  }

  Widget _lessonWidget(
    Lessonmodel lesson,
  ) {
    const int maxLength = 100;

    String truncateText(String text) {
      return text.length > maxLength
          ? '${text.substring(0, maxLength)}...'
          : text;
    }

    void showImagePopUpDialog(BuildContext context, String imageUrl) {
      // popup resim gösterme fonksiyon
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return Center(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: screenWidth - 32,
                      height: screenHeight * 0.8,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: AlertDialog(
                            backgroundColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showImagePopUpDialog(
                                            context, lesson.imageUrl);
                                      },
                                      child: Image.network(
                                        lesson.imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Soru: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  lesson.questions.isNotEmpty
                                      ? lesson.questions
                                      : "Gösterilecek soru yok",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Divider(),
                                const Text(
                                  "Cevap: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  lesson.answer.isNotEmpty
                                      ? lesson.answer
                                      : "Gösterilecek cevap yok",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    truncateText(lesson.questions.isNotEmpty
                        ? lesson.questions
                        : "Gösterilecek soru yok"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(truncateText(lesson.answer)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              showImagePopUpDialog(context, lesson.imageUrl);
            },
            child: Image.network(
              lesson.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
