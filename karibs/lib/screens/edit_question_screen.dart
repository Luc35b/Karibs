import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/overlay.dart';
import 'package:karibs/main.dart';

class EditQuestionScreen extends StatefulWidget {
  final int questionId;
  final Function onQuestionUpdated;
  final int subjectId;

  const EditQuestionScreen({super.key, required this.questionId, required this.onQuestionUpdated, required this.subjectId});

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

  /// Fetches question categories for the subject from the database.
  Future<void> _fetchCategories() async {
    var cats = await DatabaseHelper().getCategoriesForSubject(widget.subjectId);
    setState(() {
      _questionCategories = cats;
    });
  }

  /// Loads the question details from the database based on [widget.questionId].
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
    _fetchCategories();
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
          content: const Text('Are you sure you want to delete this category? Items with this category will be reassigned to "None".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteCategory(_questionCategories[index]['id'], widget.subjectId);
                Navigator.of(context).pop();
                _fetchCategories(); // Refresh the categories list
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _checkAndSetDefaultCategory() {
    bool categoryExists = _questionCategories.any((category) => category['id'] == _selectedCategoryId);

    if (!categoryExists) {
      // Find the ID of the "None" category
      int noneCategoryId = _questionCategories.firstWhere(
            (category) => category['name'] == 'None',
        orElse: () => {'id': null},
      )['id'];

      // Set the selectedCategoryId to the "None" category ID
      _selectedCategoryId = noneCategoryId;
    }
  }






  /// Updates the question in the database based on user input.
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
            const SnackBar(
              content: Text('Correct choice cannot be blank.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
        if (!_correctChoices.contains(true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please mark at least one choice as correct'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            ),
          );
          return;
        }
      }

      //print("getting here");

      _checkAndSetDefaultCategory();


      /// Update question details in the database
      await DatabaseHelper().updateQuestion(widget.questionId, {
        'text': _textController.text,
        'type': _selectedType,
        'category_id': _selectedCategoryId,
        'essay_spaces': _selectedType == 'Essay' ? _essaySpaces : null, // Save essay spaces if type is 'Essay'
      });

      // Delete existing question choices and insert new ones based on question type
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

      // Notify parent widget that question has been updated and close the screen
      widget.onQuestionUpdated();
      Navigator.of(context).pop();
    } else {
      // Show error message if any required field is empty
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

  /// Removes a choice field for multiple-choice questions at the given [index].
  void _removeChoiceField(int index) {
    setState(() {
      _choiceControllers.removeAt(index);
      _correctChoices.removeAt(index);
    });
  }

  /// Displays a dialog to add a new category for the question.
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
                  var categoryName = categoryNameController.text;
                  _addCategory(categoryNameController.text);
                  var id = await DatabaseHelper().getCategoryId(categoryName);

                  setState(() {
                    _selectedCategoryId = id;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  /// Adds a new category with the provided [categoryName] to the database.
  void _addCategory(String categoryName) async {
    await DatabaseHelper().insertCategory({'name': categoryName, 'subject_id': widget.subjectId});
    _fetchCategories();
  }

  /// Displays a tutorial dialog to guide users on editing questions.
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditQuestionScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back), // Use the back arrow icon
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Text('Edit Question'),
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
          backgroundColor: DeepPurple, // Set app bar background color
          foregroundColor: White, // Set app bar foreground color
          automaticallyImplyLeading: false, // Disable automatic back button
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
            : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 16.0),
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
                  if (_selectedType == 'Multiple Choice') {
                    _choiceControllers = [_choiceControllers.isNotEmpty ? _choiceControllers[0] : TextEditingController()];
                    _correctChoices = [_correctChoices.isNotEmpty ? _correctChoices[0] : false];
                  }
                });
              },
              decoration: const InputDecoration(labelText: 'Question Type'),
            ),
            const SizedBox(height: 16.0),
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
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateQuestion,
                  child: const Text('Save'),
                ),
              ],
            ),
        ),
    );
  }
}
