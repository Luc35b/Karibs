import 'package:flutter/foundation.dart';
import 'package:karibs/database/database_helper.dart';

class StudentGradingProvider extends ChangeNotifier {

  int _update = 0;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];

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