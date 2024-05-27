import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class AddQuestionScreen extends StatefulWidget {
  final int testId;
  final Function onQuestionAdded;

  AddQuestionScreen({required this.testId, required this.onQuestionAdded});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedType;
  final List<String> _questionTypes = ['multiple_choice', 'fill_in_the_blank'];
  List<TextEditingController> _choiceControllers = [];
  List<bool> _correctChoices = [];

  void _addQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null) {
      int questionId = await DatabaseHelper().insertQuestion({
        'text': _textController.text,
        'type': _selectedType,
        'test_id': widget.testId,
      });

      if (_selectedType == 'multiple_choice') {
        for (int i = 0; i < _choiceControllers.length; i++) {
          await DatabaseHelper().insertQuestionChoice({
            'question_id': questionId,
            'choice_text': _choiceControllers[i].text,
            'is_correct': _correctChoices[i] ? 1 : 0,
          });
        }
      }

      widget.onQuestionAdded();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  void _addChoiceField() {
    setState(() {
      _choiceControllers.add(TextEditingController());
      _correctChoices.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Question Text'),
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
              decoration: InputDecoration(labelText: 'Question Type'),
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
                      ],
                    ),
                  ElevatedButton(
                    onPressed: _addChoiceField,
                    child: Text('Add Choice'),
                  ),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addQuestion,
              child: Text('Add Question'),
            ),
          ],
        ),
      ),
    );
  }
}
