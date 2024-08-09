import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/overlay.dart';

class AddQuestionScreen extends StatefulWidget {
  final int testId;
  final Function(int) onQuestionAdded; // Update the type of callback to expect an int
  final int subjectId;

  const AddQuestionScreen({super.key, required this.testId, required this.onQuestionAdded, required this.subjectId});

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
  final List<TextEditingController> _choiceControllers = [];
  final List<bool> _correctChoices = [];
  int? _questionOrder;
  int _essaySpaces = 1; // Default number of spaces for essay questions

  @override
  void initState() {
    super.initState();
    _initializeQuestionOrder();
    _fetchCategories();
  }

  /// Fetches categories for the current subject from the database.
  Future<void> _fetchCategories() async {
    var cats = await DatabaseHelper().getCategoriesForSubject(widget.subjectId);
    setState(() {
      _questionCategories = cats;
    });

    // Show a snack bar if no categories are available.
    if (_questionCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No categories available. Please create a new category using +.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 60.0, left: 16.0, right: 16.0),
          dismissDirection: DismissDirection.down,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Initializes the question order based on existing questions for the current test.
  Future<void> _initializeQuestionOrder() async {
    final questions = await DatabaseHelper().queryAllQuestions(widget.testId);
    setState(() {
      _questionOrder = questions.length + 1;
    });
  }

  /// Validates input fields and adds the question to the database.
  void _addQuestion() async {
    if (_textController.text.isNotEmpty && _selectedType != null && _selectedCategoryId != null && _questionOrder != null) {
      if (_selectedType == 'Multiple Choice') {
        // Check for blank correct choice.
        bool hasBlankChoice = false;
        for (int i = 0; i < _choiceControllers.length; i++) {
          if (_choiceControllers[i].text.isEmpty && _correctChoices[i]) {
            hasBlankChoice = true;
            break;
          }
        }
        if (hasBlankChoice) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Correct choice cannot be blank.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
        // Check if at least one correct choice is selected.
        if (!_correctChoices.contains(true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one correct choice for multiple-choice questions.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
      }

      // Insert question into database based on question type.
      int questionId = await DatabaseHelper().insertQuestion({
        'text': _textController.text,
        'type': _selectedType,
        'category_id': _selectedCategoryId,
        'test_id': widget.testId,
        'order': _questionOrder,
        'essay_spaces': _selectedType == 'Essay' ? _essaySpaces : null, // Save essay spaces if type is 'Essay'
      });

      // Insert choices based on question type.
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

      // Call the callback function to notify the parent widget that a question has been added.
      widget.onQuestionAdded(questionId); // Pass the new question ID here
      Navigator.of(context).pop();
    } else {
      // Show a snack bar if not all fields are filled.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  /// Adds a new choice field for multiple-choice questions.
  void _addChoiceField() {
    setState(() {
      _choiceControllers.add(TextEditingController());
      _correctChoices.add(false);
    });
  }

  /// Removes a choice field for multiple-choice questions.
  void _removeChoiceField(int index) {
    setState(() {
      _choiceControllers.removeAt(index);
      _correctChoices.removeAt(index);
    });
  }

  /// Shows a dialog to add a new category.
  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: categoryNameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () async {
                if (categoryNameController.text.isNotEmpty) {
                  var categoryName = categoryNameController.text.trim();
                  var existingCategory = await DatabaseHelper().getCategoryByName(categoryName);

                  if (existingCategory != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category $categoryName already exists within subject "${existingCategory['subject_name']}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    _addCategory(categoryName);
                    await _fetchCategories();
                    var id = await DatabaseHelper().getCategoryId(categoryName);

                    setState(() {
                      _selectedCategoryId = id;
                    });

                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showManageCategoriesDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Categories'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _questionCategories.length,
                  itemBuilder: (context, index) {
                    bool isNoneCategory = _questionCategories[index]['name'] == 'None';
                    return ListTile(
                      title: Text(_questionCategories[index]['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: isNoneCategory ? null : () async {
                              await _showEditCategoryDialog(index, _questionCategories[index]['name']);
                              setState(() {
                                _fetchCategories();
                              });
                            },
                            color: isNoneCategory ? Colors.grey : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: isNoneCategory ? null : () async {
                              await _showConfirmDeleteCategoryDialog(index);
                              setState(() {
                                _fetchCategories();
                              });
                            },
                            color: isNoneCategory ? Colors.grey : Colors.red,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
    _fetchCategories(); // Refresh the categories after managing
  }

  Future<void> _showEditCategoryDialog(int index, String currentName) async {
    final TextEditingController categoryNameController = TextEditingController(text: currentName);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: categoryNameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (categoryNameController.text.isNotEmpty) {
                  await DatabaseHelper().updateCategory(_questionCategories[index]['id'], categoryNameController.text.trim());
                  Navigator.of(context).pop();
                  _fetchCategories(); // Refresh the categories list
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDeleteCategoryDialog(int index) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteCategory(_questionCategories[index]['id'], _questionCategories[index]['subject_id']);
                Navigator.of(context).pop();
                setState(() {
                  _fetchCategories();
                });

              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  /// Inserts a new category into the database.
  /// Inserts a new category into the database.
  void _addCategory(String categoryName) async {
    var existingCategory = await DatabaseHelper().getCategoryByNameAndSubjectId(categoryName, widget.subjectId);

    if (existingCategory != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category $categoryName already exists for this subject!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await DatabaseHelper().insertCategory({'name': categoryName, 'subject_id': widget.subjectId});
      await _fetchCategories();  // Ensure categories are refreshed immediately
    }
  }





  /// Shows a tutorial dialog for add question screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddQuestionScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: DeepPurple,
          foregroundColor: White,
          title: Row(
            children: [
              Text('Add New Question'),
              SizedBox(width: 8), // Adjust spacing between title and icon
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  // Show tutorial dialog
                  _showTutorialDialog();
                },
              ),
            ],
          ),
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
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _questionCategories.any((category) => category['id'] == _selectedCategoryId) ? _selectedCategoryId : null,
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
                decoration: const InputDecoration(labelText: 'Question Category'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCategoryDialog,
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _showManageCategoriesDialog,
            ),
          ],
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
                                  const SnackBar(
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
                          color: Colors.red[900],
                          onPressed: () => _removeChoiceField(i),
                        ),
                      ],
                    ),
                  Padding(padding: EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DeepPurple,
                        side: const BorderSide(
                            width: 2, color: DeepPurple),
                      ),
                      onPressed: _addChoiceField,
                      child: const Text('Add Choice'),
                    ),
                  ),
                ],
              ),
            if (_selectedType == 'Fill in the Blank')
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: DeepPurple,
                      side: const BorderSide(
                          width: 2, color: DeepPurple),
                    ),
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



