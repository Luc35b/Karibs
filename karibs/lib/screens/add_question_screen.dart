import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
//import 'package:karibs/pdf_gen.dart';

class AddQuestionScreen extends StatefulWidget {
  final int testId;
  final Function onQuestionAdded;

  const AddQuestionScreen({super.key, required this.testId, required this.onQuestionAdded});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController(); // Controller for the correct answer
  String? _selectedType;
  String? _selectedCategory; // New field for category
  final List<String> _questionTypes = ['multiple_choice', 'fill_in_the_blank'];
  final List<String> _questionCategories = ['Vocab', 'Comprehension']; // New list of categories
  final List<TextEditingController> _choiceControllers = [];
  final List<bool> _correctChoices = [];
  int? _questionOrder;

  @override
  void initState() {
    super.initState();
    _initializeQuestionOrder();
  }

  Future<void> _initializeQuestionOrder() async {
    final questions = await DatabaseHelper().queryAllQuestions(widget.testId);
    setState(() {
      _questionOrder = questions.length + 1;
    });
  }

  void _addQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null && _selectedCategory != null && _questionOrder != null) { // Check for selected category
      BuildContext currentContext = context;

      int questionId = await DatabaseHelper().insertQuestion({
        'text': _textController.text,
        'type': _selectedType,
        'category': _selectedCategory, // Include category in insertion
        'test_id': widget.testId,
        'order': _questionOrder,
      });

      if (_selectedType == 'multiple_choice') {
        for (int i = 0; i < _choiceControllers.length; i++) {
          await DatabaseHelper().insertQuestionChoice({
            'question_id': questionId,
            'choice_text': _choiceControllers[i].text,
            'is_correct': _correctChoices[i] ? 1 : 0,
          });
        }
      } else if (_selectedType == 'fill_in_the_blank') {
        await DatabaseHelper().insertQuestionChoice({
          'question_id': questionId,
          'choice_text': _correctAnswerController.text,
          'is_correct': 1,
        });
      }

      widget.onQuestionAdded();
      if (Navigator.canPop(currentContext)) {
        Navigator.of(currentContext).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }


  void _addChoiceField() {
    setState(() {
      _choiceControllers.add(TextEditingController());
      _correctChoices.add(false);
    });
  }

  void _removeChoiceField(int index) {
    setState(() {
      _choiceControllers.removeAt(index);
      _correctChoices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DeepPurple,
        foregroundColor: White,
        title: const Text('Add New Question'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Question Text'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _questionTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Question Type'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _questionCategories.map((category) { // Add dropdown for category
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Question Category'), // Add label for category
                ),
                if (_selectedType == 'multiple_choice')
                  Column(
                    children: [
                      for (int i = 0; i < _choiceControllers.length; i++)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _choiceControllers[i],
                                decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                              ),
                            ),
                            Checkbox(
                              value: _correctChoices[i],
                              onChanged: (value) {
                                setState(() {
                                  _correctChoices[i] = value!;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeChoiceField(i),
                            ),
                          ],
                        ),
                      ElevatedButton(
                        onPressed: _addChoiceField,
                        child: const Text('Add Choice'),
                      ),
                    ],
                  ),
                if (_selectedType == 'fill_in_the_blank')
                  TextField(
                    controller: _correctAnswerController,
                    decoration: const InputDecoration(labelText: 'Correct Answer'),
                  ),
                const SizedBox(height: 100), // Add spacing to avoid overlap with the button
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
