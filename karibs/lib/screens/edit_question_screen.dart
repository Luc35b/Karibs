import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class EditQuestionScreen extends StatefulWidget {
  final int questionId;
  final Function onQuestionUpdated;
  final int subjectId;

  EditQuestionScreen({required this.questionId, required this.onQuestionUpdated, required this.subjectId});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController();
  String? _selectedType;
  int? _selectedCategoryId;
  final List<String> _questionTypes = ['Multiple Choice', 'Fill in the Blank', 'Essay'];
  List<Map<String, dynamic>> _questionCategories = [];
  List<TextEditingController> _choiceControllers = [];
  List<bool> _correctChoices = [];
  bool _isLoading = true;
  int _essaySpaces = 1; // Default number of spaces for essay questions

  @override
  void initState() {
    super.initState();
    _loadQuestion();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    var cats = await DatabaseHelper().getCategoriesForSubject(widget.subjectId);
    setState(() {
      _questionCategories = cats;
    });
  }

  void _loadQuestion() async {
    var question = await DatabaseHelper().queryQuestion(widget.questionId);
    var choices = await DatabaseHelper().queryQuestionChoices(widget.questionId);

    setState(() {
      _textController.text = question?['text'];
      _selectedType = question?['type'];
      _selectedCategoryId = question?['category_id'];
      if (_selectedType == 'Multiple Choice') {
        _choiceControllers = choices.map((choice) {
          var controller = TextEditingController(text: choice['choice_text']);
          return controller;
        }).toList();
        _correctChoices = choices.map((choice) => choice['is_correct'] == 1).toList();
      } else if (_selectedType == 'Fill in the Blank') {
        _correctAnswerController.text = choices.isNotEmpty ? choices[0]['choice_text'] : '';
      } else if (_selectedType == 'Essay') {
        _essaySpaces = question?['essay_spaces'] ?? 1;
      }
      _isLoading = false;
    });
  }

  void _updateQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null && _selectedCategoryId != null) {
      if (_selectedType == 'Multiple Choice') {
        bool hasBlankChoice = false;
        for (int i = 0; i < _choiceControllers.length; i++) {
          if (_choiceControllers[i].text.isEmpty && _correctChoices[i]) {
            hasBlankChoice = true;
            break;
          }
        }
        if (hasBlankChoice) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Correct choice cannot be blank.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
        if (!_correctChoices.contains(true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please mark at least one choice as correct'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
      }

      await DatabaseHelper().updateQuestion(widget.questionId, {
        'text': _textController.text,
        'type': _selectedType,
        'category_id': _selectedCategoryId,
        'essay_spaces': _selectedType == 'Essay' ? _essaySpaces : null, // Save essay spaces if type is 'Essay'
      });

      await DatabaseHelper().deleteQuestionChoices(widget.questionId);

      if (_selectedType == 'Multiple Choice') {
        for (int i = 0; i < _choiceControllers.length; i++) {
          await DatabaseHelper().insertQuestionChoice({
            'question_id': widget.questionId,
            'choice_text': _choiceControllers[i].text,
            'is_correct': _correctChoices[i] ? 1 : 0,
          });
        }
      } else if (_selectedType == 'Fill in the Blank') {
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

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  _addCategory(categoryNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  void _addCategory(String categoryName) async {
    await DatabaseHelper().insertCategory({'name': categoryName, 'subject_id': widget.subjectId});
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Question'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
            children: [
        SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    TextField(
    controller: _textController,
    decoration: const InputDecoration(labelText: 'Question Text', hintText: 'The sky is ____'),
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
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              items: _questionCategories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              decoration: InputDecoration(labelText: 'Question Category'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      if (_selectedType == 'Multiple Choice')
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
                        if (_choiceControllers[i].text.isNotEmpty) {
                          _correctChoices[i] = value!;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Correct choice cannot be blank.'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
                            ),
                          );
                        }
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
      if (_selectedType == 'Fill in the Blank')
        TextField(
          controller: _correctAnswerController,
          decoration: const InputDecoration(labelText: 'Correct Answer'),
        ),
      if (_selectedType == 'Essay')
        DropdownButtonFormField<int>(
          value: _essaySpaces,
          items: List.generate(10, (index) => index + 1).map((num) {
            return DropdownMenuItem<int>(
              value: num,
              child: Text('$num lines'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _essaySpaces = value!;
            });
          },
          decoration: const InputDecoration(labelText: 'Number of lines for Essay'),
        ),
      const SizedBox(height: 16),
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
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
        ),
    );
  }
}

