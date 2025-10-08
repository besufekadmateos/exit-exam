import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question_model.dart';

class JsonService {
  Future<List<Question>> loadQuestions(String department) async {
    String fileName;

    switch (department.toLowerCase()) {
      case 'electromechanical':
        fileName = 'assets/electromechanical.json';
        break;
      case 'electrical':
        fileName = 'assets/electrical.json';
        break;
      case 'mechanical':
        fileName = 'assets/mechanical.json';
        break;
      default:
        fileName = 'assets/electromechanical.json'; // fallback
    }

    final String jsonString = await rootBundle.loadString(fileName);
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((question) => Question.fromJson(question)).toList();
  }
}
