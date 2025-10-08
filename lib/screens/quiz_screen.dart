import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/json_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String departmentName;

  const QuizScreen({Key? key, required this.departmentName}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questions;
  List<Question>? _questionsList;
  int _questionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  List<int?> _userAnswers = []; // Track user answers for all questions

  @override
  void initState() {
    super.initState();
    _resetQuiz();
  }

  void _resetQuiz() {
    setState(() {
      _questions = JsonService().loadQuestions(widget.departmentName);
      _questionsList = null;
      _questionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _userAnswers = [];
    });

    _questions.then((questions) {
      setState(() {
        _questionsList = questions;
        _userAnswers = List.filled(questions.length, null); // Initialize with nulls
      });
    });
  }

  void _answerQuestion(int selectedIndex) {
    if (_answered || _questionsList == null) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
      _userAnswers[_questionIndex] = selectedIndex; // Store the answer
    });

    final question = _questionsList![_questionIndex];
    if (selectedIndex == question.correctIndex) {
      setState(() {
        _score++;
      });
    }

    // Removed automatic navigation - now user controls with buttons
  }

  void _goToPreviousQuestion() {
    if (_questionIndex > 0) {
      setState(() {
        _questionIndex--;
        _answered = _userAnswers[_questionIndex] != null; // Restore answered state
        _selectedAnswer = _userAnswers[_questionIndex]; // Restore selected answer
      });
    }
  }

  void _goToNextQuestion() {
    if (_questionIndex < _questionsList!.length - 1) {
      setState(() {
        _questionIndex++;
        _answered = _userAnswers[_questionIndex] != null; // Restore answered state
        _selectedAnswer = _userAnswers[_questionIndex]; // Restore selected answer
      });
    } else {
      // If on last question, submit quiz
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(score: _score, totalQuestions: _questionsList!.length, departmentName: widget.departmentName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.departmentName} Quiz'), backgroundColor: Colors.blue),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions available for ${widget.departmentName}'));
          }

          final questions = snapshot.data!;
          final question = questions[_questionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_questionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 20),
                Text(
                  'Question ${_questionIndex + 1}/${questions.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(question.question, style: TextStyle(fontSize: 22)),
                SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.answers.length,
                    itemBuilder: (context, index) {
                      final answer = question.answers[index];
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = index == question.correctIndex;

                      Color tileColor = Colors.white;
                      if (_answered) {
                        if (isSelected) {
                          tileColor = isCorrect ? Colors.green : Colors.red;
                        } else if (isCorrect) {
                          tileColor = Colors.green;
                        }
                      }

                      return Card(
                        color: tileColor,
                        child: ListTile(
                          title: Text(
                            answer,
                            style: TextStyle(
                              fontSize: 18,
                              color: _answered && (isSelected || isCorrect) ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () => _answerQuestion(index),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    ElevatedButton(
                      onPressed: _questionIndex > 0 ? _goToPreviousQuestion : null,
                      child: Text('Back'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(100, 40)),
                    ),

                    // Next/Submit Button
                    ElevatedButton(
                      onPressed: _answered ? _goToNextQuestion : null,
                      child: Text(_questionIndex < questions.length - 1 ? 'Next' : 'Submit'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(100, 40)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
