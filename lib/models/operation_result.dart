import 'package:set_theory_calculator/models/set_model.dart';

class OperationResult {
  final String expression; // e.g., "A union B" or "A \cap B"
  final SetModel result;
  final DateTime timestamp;

  OperationResult({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}