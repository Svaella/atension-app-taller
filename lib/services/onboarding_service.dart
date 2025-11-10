import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService extends ChangeNotifier {
  static const _kEvalDone = 'evaluation_completed';
  bool _evaluationDone = false;

  bool get evaluationDone => _evaluationDone;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _evaluationDone = sp.getBool(_kEvalDone) ?? false;
    notifyListeners();
  }

  Future<void> markEvaluationDone() async {
    final sp = await SharedPreferences.getInstance();
    _evaluationDone = true;
    await sp.setBool(_kEvalDone, true);
    notifyListeners();
  }
}