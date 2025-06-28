import 'package:flutter/material.dart';
import 'package:set_theory_calculator/models/set_model.dart';
import 'package:set_theory_calculator/models/operation_result.dart';

import '../utils/latex_parser.dart';
import '../utils/set_operations.dart';

class CalculatorProvider extends ChangeNotifier {
  SetModel _setA = SetModel(elements: {});
  SetModel _setB = SetModel(elements: {});
  SetModel _universalSet = SetModel(elements: {}); // For complement operations
  dynamic _result; // Can be SetModel, bool, or Set<SetModel>
  String _currentExpression = '';
  String _currentOperationDisplay = ''; // For LaTeX display of the operation
  final List<OperationResult> _history = [];

  SetModel get setA => _setA;
  SetModel get setB => _setB;
  SetModel get universalSet => _universalSet;
  dynamic get result => _result;
  String get currentExpression => _currentExpression;
  String get currentOperationDisplay => _currentOperationDisplay;
  List<OperationResult> get history => _history;

  void setSetA(String input) {
    try {
      _setA = LatexParser.parseSet(input);
      _currentExpression = ''; // Clear expression when sets are updated
      _result = null;
      _currentOperationDisplay = '';
      notifyListeners();
    } catch (e) {
      // Handle parsing error (e.g., show a snackbar)
      _setA = SetModel(elements: {}); // Reset on error
      _result = null;
      _currentOperationDisplay = 'Error parsing Set A: ${e.toString()}';
      notifyListeners();
    }
  }

  void setSetB(String input) {
    try {
      _setB = LatexParser.parseSet(input);
      _currentExpression = '';
      _result = null;
      _currentOperationDisplay = '';
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
      _currentExpression = '';
      _result = null;
      _currentOperationDisplay = '';
      notifyListeners();
    } catch (e) {
      _universalSet = SetModel(elements: {});
      _result = null;
      _currentOperationDisplay = 'Error parsing Universal Set: ${e.toString()}';
      notifyListeners();
    }
  }

  void performOperation(String operation) {
    String expression = '';
    dynamic calculatedResult;
    String operatorSymbol = operation; // Default to operation name

    try {
      switch (operation.toLowerCase()) {
        case 'union':
          calculatedResult = SetOperations.union(_setA, _setB);
          expression = 'A \\cup B';
          operatorSymbol = 'Union';
          break;
        case 'intersection':
          calculatedResult = SetOperations.intersection(_setA, _setB);
          expression = 'A \\cap B';
          operatorSymbol = 'Intersection';
          break;
        case 'difference (a-b)':
          calculatedResult = SetOperations.difference(_setA, _setB);
          expression = 'A \\setminus B';
          operatorSymbol = 'Difference (A-B)';
          break;
        case 'difference (b-a)':
          calculatedResult = SetOperations.difference(_setB, _setA);
          expression = 'B \\setminus A';
          operatorSymbol = 'Difference (B-A)';
          break;
        case 'symmetric difference':
          calculatedResult = SetOperations.symmetricDifference(_setA, _setB);
          expression = 'A \\Delta B';
          operatorSymbol = 'Symmetric Difference';
          break;
        case 'is subset (a ⊆ b)':
          calculatedResult = SetOperations.isSubset(_setA, _setB);
          expression = 'A \\subseteq B';
          operatorSymbol = 'Is Subset (A ⊆ B)';
          break;
        case 'is proper subset (a ⊂ b)':
          calculatedResult = SetOperations.isProperSubset(_setA, _setB);
          expression = 'A \\subset B';
          operatorSymbol = 'Is Proper Subset (A ⊂ B)';
          break;
        case 'is superset (a ⊇ b)':
          calculatedResult = SetOperations.isSuperset(_setA, _setB);
          expression = 'A \\supseteq B';
          operatorSymbol = 'Is Superset (A ⊇ B)';
          break;
        case 'is proper superset (a ⊃ b)':
          calculatedResult = SetOperations.isProperSuperset(_setA, _setB);
          expression = 'A \\supset B';
          operatorSymbol = 'Is Proper Superset (A ⊃ B)';
          break;
        case 'are disjoint':
          calculatedResult = SetOperations.areDisjoint(_setA, _setB);
          expression = 'A \\cap B = \\emptyset'; // Simplified LaTeX for disjoint check
          operatorSymbol = 'Are Disjoint';
          break;
        case 'power set (a)':
          calculatedResult = SetOperations.powerSet(_setA);
          expression = 'P(A)';
          operatorSymbol = 'Power Set (A)';
          break;
        case 'power set (b)':
          calculatedResult = SetOperations.powerSet(_setB);
          expression = 'P(B)';
          operatorSymbol = 'Power Set (B)';
          break;
        case 'cartesian product (a x b)':
          calculatedResult = SetOperations.cartesianProduct(_setA, _setB);
          expression = 'A \\times B';
          operatorSymbol = 'Cartesian Product (A x B)';
          break;
        case 'cartesian product (b x a)':
          calculatedResult = SetOperations.cartesianProduct(_setB, _setA);
          expression = 'B \\times A';
          operatorSymbol = 'Cartesian Product (B x A)';
          break;
        case 'complement (a)':
          if (_universalSet.elements.isEmpty) {
            throw Exception('Universal Set is required for Complement operation.');
          }
          calculatedResult = SetOperations.complement(_setA, _universalSet);
          expression = 'A^c';
          operatorSymbol = 'Complement (A)';
          break;
        case 'complement (b)':
          if (_universalSet.elements.isEmpty) {
            throw Exception('Universal Set is required for Complement operation.');
          }
          calculatedResult = SetOperations.complement(_setB, _universalSet);
          expression = 'B^c';
          operatorSymbol = 'Complement (B)';
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      _result = calculatedResult;

      // Construct the full LaTeX expression including set inputs
      String setALatex = _setA.toLaTeXString();
      String setBLatex = _setB.toLaTeXString();
      String universalSetLatex = _universalSet.toLaTeXString();

      if (operation.toLowerCase().contains('complement')) {
        _currentOperationDisplay = LatexParser.generateOperationLatex(
          operation.toLowerCase().contains('(a)') ? setALatex : setBLatex,
          operation,
          universalSetLatex, // Universal set for complement
        );
      } else if (operation.toLowerCase().contains('power set')) {
        _currentOperationDisplay = LatexParser.generateOperationLatex(
          operation.toLowerCase().contains('(a)') ? setALatex : setBLatex,
          operation,
          '', // No second operand for power set
        );
      } else if (operation.toLowerCase().contains('is ')) {
        _currentOperationDisplay = LatexParser.generateOperationLatex(
          setALatex,
          operation,
          setBLatex,
        );
      }
      else {
        _currentOperationDisplay = LatexParser.generateOperationLatex(
          setALatex,
          operation,
          setBLatex,
        );
      }


      // Add to history
      _history.insert(0, OperationResult(
        expression: _currentOperationDisplay,
        result: calculatedResult is SetModel ? calculatedResult : SetModel(elements: {calculatedResult.toString()}), // Store as a simple set if not SetModel
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
    _currentExpression = '';
    _currentOperationDisplay = '';
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}