import 'package:flutter/foundation.dart';

class StudentGradingProvider extends ChangeNotifier {

  int _update = 0;
  final List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _filteredStudents = [];

  int get update => _update;

  void grade() {
    _update++;
    notifyListeners();
    print('notified listeners');
  }

  void reset() {
    _update = 0;
  }


}