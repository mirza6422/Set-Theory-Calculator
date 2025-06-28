import 'package:flutter/material.dart';
import 'package:set_theory_calculator/models/set_model.dart';
import 'package:set_theory_calculator/models/operation_result.dart';


import '../utils/expression_parser.dart';
import '../utils/latex_parser.dart';
import '../utils/set_operations.dart'; // Ensure this is imported

class CalculatorProvider extends ChangeNotifier {
  SetModel _setA = SetModel(elements: {});
  SetModel _setB = SetModel(elements: {});
  SetModel _universalSet = SetModel(elements: {});
  dynamic _result;
  String _currentOperationDisplay = '';
  String _expressionInput = '';
  final List<OperationResult> _history = [];

  SetModel get setA => _setA;
  SetModel get setB => _setB;
  SetModel get universalSet => _universalSet;
  dynamic get result => _result;
  String get currentOperationDisplay => _currentOperationDisplay;
  String get expressionInput => _expressionInput;
  List<OperationResult> get history => _history;

  void setExpressionInput(String input) {
    _expressionInput = input;
    _currentOperationDisplay = '';
    _result = null;
    notifyListeners();
  }

  void setSetA(String input) {
    try {
      _setA = LatexParser.parseSet(input);
      _currentOperationDisplay = '';
      _result = null;
      notifyListeners();
    } catch (e) {
      _setA = SetModel(elements: {});
      _result = null;
      _currentOperationDisplay = 'Error parsing Set A: ${e.toString()}';
      notifyListeners();
    }
  }

  void setSetB(String input) {
    try {
      _setB = LatexParser.parseSet(input);
      _currentOperationDisplay = '';
      _result = null;
      notifyListeners();
    } catch (e) {
      _setB = SetModel(elements: {});
      _result = null;
      _currentOperationDisplay = 'Error parsing Set B: ${e.toString()}';
      notifyListeners();
    }
  }

  void setUniversalSet(String input) {
    try {
      _universalSet = LatexParser.parseSet(input);
      _currentOperationDisplay = '';
      _result = null;
      notifyListeners();
    } catch (e) {
      _universalSet = SetModel(elements: {});
      _result = null;
      _currentOperationDisplay = 'Error parsing Universal Set: ${e.toString()}';
      notifyListeners();
    }
  }

  // --- MODIFIED evaluateExpression to use AST ---
  void evaluateExpression() {
    if (_expressionInput.isEmpty) {
      _result = null;
      _currentOperationDisplay = 'Please enter an expression.';
      notifyListeners();
      return;
    }

    try {
      final parser = ExpressionParser(definedSets: {
        'A': _setA,
        'B': _setB,
        'U': _universalSet,
      });

      final evaluatedResult = parser.parseAndEvaluate(_expressionInput);
      _result = evaluatedResult;

      // Generate LaTeX from the AST for precise rendering
      _currentOperationDisplay = parser.parseAndGenerateLatex(_expressionInput);

      // Add to history
      _history.insert(0, OperationResult(
        expression: _currentOperationDisplay,
        result: _result is SetModel ? _result : SetModel(elements: {_result.toString()}),
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      _result = null;
      _currentOperationDisplay = 'Error evaluating expression: ${e.toString()}';
      notifyListeners();
    }
  }

  // Existing performOperation (no change needed here as it handles simple ops)
  void performOperation(String operation) {
    _expressionInput = ''; // Clear expression input when a single operation is performed

    String expression = '';
    dynamic calculatedResult;

    try {
      switch (operation.toLowerCase()) {
        case 'union':
          calculatedResult = SetOperations.union(_setA, _setB);
          expression = 'A \\cup B';
          break;
        case 'intersection':
          calculatedResult = SetOperations.intersection(_setA, _setB);
          expression = 'A \\cap B';
          break;
        case 'difference (a-b)':
          calculatedResult = SetOperations.difference(_setA, _setB);
          expression = 'A \\setminus B';
          break;
        case 'difference (b-a)':
          calculatedResult = SetOperations.difference(_setB, _setA);
          expression = 'B \\setminus A';
          break;
        case 'symmetric difference':
          calculatedResult = SetOperations.symmetricDifference(_setA, _setB);
          expression = 'A \\Delta B';
          break;
        case 'is subset (a ⊆ b)':
          calculatedResult = SetOperations.isSubset(_setA, _setB);
          expression = 'A \\subseteq B';
          break;
        case 'is proper subset (a ⊂ b)':
          calculatedResult = SetOperations.isProperSubset(_setA, _setB);
          expression = 'A \\subset B';
          break;
        case 'is superset (a ⊇ b)':
          calculatedResult = SetOperations.isSuperset(_setA, _setB);
          expression = 'A \\supseteq B';
          break;
        case 'is proper superset (a ⊃ b)':
          calculatedResult = SetOperations.isProperSuperset(_setA, _setB);
          expression = 'A \\supset B';
          break;
        case 'are disjoint':
          calculatedResult = SetOperations.areDisjoint(_setA, _setB);
          expression = 'A \\cap B = \\emptyset';
          break;
        case 'power set (a)':
          calculatedResult = SetOperations.powerSet(_setA);
          expression = 'P(A)';
          break;
        case 'power set (b)':
          calculatedResult = SetOperations.powerSet(_setB);
          expression = 'P(B)';
          break;
        case 'cartesian product (a x b)':
          calculatedResult = SetOperations.cartesianProduct(_setA, _setB);
          expression = 'A \\times B';
          break;
        case 'cartesian product (b x a)':
          calculatedResult = SetOperations.cartesianProduct(_setB, _setA);
          expression = 'B \\times A';
          break;
        case 'complement (a)':
          if (_universalSet.elements.isEmpty) {
            throw Exception('Universal Set is required for Complement operation.');
          }
          calculatedResult = SetOperations.complement(_setA, _universalSet);
          expression = 'A^c';
          break;
        case 'complement (b)':
          if (_universalSet.elements.isEmpty) {
            throw Exception('Universal Set is required for Complement operation.');
          }
          calculatedResult = SetOperations.complement(_setB, _universalSet);
          expression = 'B^c';
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      _result = calculatedResult;
      _currentOperationDisplay = expression;

      _history.insert(0, OperationResult(
        expression: _currentOperationDisplay,
        result: calculatedResult is SetModel ? calculatedResult : SetModel(elements: {calculatedResult.toString()}),
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    } catch (e) {
      _result = null;
      _currentOperationDisplay = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearCalculator() {
    _setA = SetModel(elements: {});
    _setB = SetModel(elements: {});
    _universalSet = SetModel(elements: {});
    _result = null;
    _expressionInput = '';
    _currentOperationDisplay = '';
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}