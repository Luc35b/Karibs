import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';

class AddQuestionScreen extends StatefulWidget {
  final int testId;
  final Function onQuestionAdded;
  final int subjectId;

  AddQuestionScreen({required this.testId, required this.onQuestionAdded, required this.subjectId});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController(); // Controller for the correct answer
  String? _selectedType;
  int? _selectedCategoryId; // New field for category
  final List<String> _questionTypes = ['Multiple Choice', 'Fill in the Blank', 'Essay'];
  List<Map<String, dynamic>> _questionCategories = []; // New list of categories
  List<TextEditingController> _choiceControllers = [];
  List<bool> _correctChoices = [];
  int? _questionOrder;

  @override
  void initState() {
    super.initState();
    _initializeQuestionOrder();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    var cats = await DatabaseHelper().getCategoriesForSubject(widget.subjectId);
    setState(() {
      _questionCategories = cats;
    });

    if (_questionCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No categories available. Please create a new category using +.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
          dismissDirection: DismissDirection.down,
        ),
      );
    }
  }

  Future<void> _initializeQuestionOrder() async {
    final questions = await DatabaseHelper().queryAllQuestions(widget.testId);
    setState(() {
      _questionOrder = questions.length + 1;
    });
  }

  void _addQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null && _selectedCategoryId != null && _questionOrder != null) { // Check for selected category
      int questionId = await DatabaseHelper().insertQuestion({
        'text': _textController.text,
        'type': _selectedType,
        'category_id': _selectedCategoryId, // Include category in insertion
        'test_id': widget.testId,
        'order': _questionOrder,
      });

      if (_selectedType == 'Multiple Choice') {
        for (int i = 0; i < _choiceControllers.length; i++) {
          await DatabaseHelper().insertQuestionChoice({
            'question_id': questionId,
            'choice_text': _choiceControllers[i].text,
            'is_correct': _correctChoices[i] ? 1 : 0,
          });
        }
      } else if (_selectedType == 'Fill in the Blank') {
        await DatabaseHelper().insertQuestionChoice({
          'question_id': questionId,
          'choice_text': _correctAnswerController.text,
          'is_correct': 1,
        });
      }

      widget.onQuestionAdded();
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  _addCategory(categoryNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
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
        backgroundColor: DeepPurple,
        foregroundColor: White,
        title: Text('Add New Question'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                if (_selectedType == 'Fill in the Blank')
                  TextField(
                    controller: _correctAnswerController,
                    decoration: InputDecoration(labelText: 'Correct Answer'),
                  ),
                SizedBox(height: 100), // Add spacing to avoid overlap with the button
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addQuestion,
                child: Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
