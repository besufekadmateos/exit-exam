class Question {
  final String question;
  final List<String> answers;
  final int correctIndex;

  Question({required this.question, required this.answers, required this.correctIndex});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctIndex: json['correctIndex'],
    );
  }
}
