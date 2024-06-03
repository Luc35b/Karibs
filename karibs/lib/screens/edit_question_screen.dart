import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class EditQuestionScreen extends StatefulWidget {
  final int questionId;
  final Function onQuestionUpdated;

  EditQuestionScreen({required this.questionId, required this.onQuestionUpdated});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController(); // Controller for the correct answer
  String? _selectedType;
  String? _selectedCategory;
  final List<String> _questionTypes = ['multiple_choice', 'fill_in_the_blank'];
  final List<String> _questionCategories = ['Vocab', 'Comprehension'];
  List<TextEditingController> _choiceControllers = [];
  List<bool> _correctChoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() async {
    var question = await DatabaseHelper().queryQuestion(widget.questionId);
    var choices = await DatabaseHelper().queryQuestionChoices(widget.questionId);

    setState(() {
      _textController.text = question?['text'];
      _selectedType = question?['type'];
      _selectedCategory = question?['category'];
      if (_selectedType == 'multiple_choice') {
        _choiceControllers = choices.map((choice) {
          var controller = TextEditingController(text: choice['choice_text']);
          return controller;
        }).toList();
        _correctChoices = choices.map((choice) => choice['is_correct'] == 1).toList();
      } else if (_selectedType == 'fill_in_the_blank') {
        _correctAnswerController.text = choices.isNotEmpty ? choices[0]['choice_text'] : '';
      }
      _isLoading = false;
    });
  }

  void _updateQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null && _selectedCategory != null) {
      await DatabaseHelper().updateQuestion(widget.questionId, {
        'text': _textController.text,
        'type': _selectedType,
        'category': _selectedCategory,
      });

      await DatabaseHelper().deleteQuestionChoices(widget.questionId);

      if (_selectedType == 'multiple_choice') {
        for (int i = 0; i < _choiceControllers.length; i++) {
          await DatabaseHelper().insertQuestionChoice({
            'question_id': widget.questionId,
            'choice_text': _choiceControllers[i].text,
            'is_correct': _correctChoices[i] ? 1 : 0,
          });
        }
      } else if (_selectedType == 'fill_in_the_blank') {
        await DatabaseHelper().insertQuestionChoice({
          'question_id': widget.questionId,
          'choice_text': _correctAnswerController.text,
          'is_correct': 1,
        });
      }

      widget.onQuestionUpdated();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),),
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
        title: Text('Edit Question'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80.0), // Padding to avoid overlap with buttons
            child: Padding(
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
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _questionCategories.map((category) {
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
                    decoration: InputDecoration(labelText: 'Question Category'),
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
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeChoiceField(i),
                              ),
                            ],
                          ),
                        ElevatedButton(
                          onPressed: _addChoiceField,
                          child: Text('Add Choice'),
                        ),
                      ],
                    ),
                  if (_selectedType == 'fill_in_the_blank')
                    TextField(
                      controller: _correctAnswerController,
                      decoration: InputDecoration(labelText: 'Correct Answer'),
                    ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _updateQuestion,
                child: Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
