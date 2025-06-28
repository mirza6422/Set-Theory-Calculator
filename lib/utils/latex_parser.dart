import 'package:set_theory_calculator/models/set_model.dart';

class LatexParser {
  // Parses a string representation of a set into a SetModel
  // Expected format: {a, b, c}
  static SetModel parseSet(String input) {
    // Remove curly braces and trim whitespace
    String cleanInput = input.trim().replaceAll('{', '').replaceAll('}', '');
    if (cleanInput.isEmpty) {
      return SetModel(elements: {});
    }
    // Split by comma and trim each element
    final elements = cleanInput.split(',').map((e) => e.trim()).toSet();
    return SetModel(elements: elements);
  }

  // Generates a LaTeX string for an operation.
  // This will be more complex depending on how you want to represent operations.
  // For simplicity, let's assume direct input for now.
  static String generateOperationLatex(String operand1Latex, String operator, String operand2Latex) {
    String latexOperator = '';
    switch (operator.toLowerCase()) {
      case 'union':
      case 'u':
        latexOperator = '\\cup';
        break;
      case 'intersection':
      case 'n':
        latexOperator = '\\cap';
        break;
      case 'difference':
      case '-':
        latexOperator = '\\setminus'; // or \text{-}
        break;
      case 'symmetric difference':
      case 'delta':
        latexOperator = '\\Delta'; // or \\oplus
        break;
      case 'subset':
      case 'subseteq':
        latexOperator = '\\subseteq';
        break;
      case 'proper subset':
      case 'subset':
        latexOperator = '\\subset';
        break;
      case 'superset':
      case 'supseteq':
        latexOperator = '\\supseteq';
        break;
      case 'proper superset':
      case 'supset':
        latexOperator = '\\supset';
        break;
      case 'cartesian product':
      case 'x':
        latexOperator = '\\times';
        break;
      case 'complement':
      case 'complement of': // For complement, it's usually A^c or A'
      default:
        latexOperator = operator; // Fallback to raw operator if not mapped
        break;
    }

    // Special handling for unary operations like complement or power set
    if (operator.toLowerCase() == 'complement' || operator.toLowerCase() == 'complement of') {
      return '$operand1Latex^c'; // Assuming complement of operand1
    }
    if (operator.toLowerCase() == 'power set') {
      return 'P($operand1Latex)';
    }

    return '$operand1Latex $latexOperator $operand2Latex';
  }

  // Generates a LaTeX string for a single result (e.g., a boolean true/false)
  static String generateResultLatex(dynamic result) {
    if (result is SetModel) {
      return result.toLaTeXString();
    } else if (result is bool) {
      return result ? '\\text{True}' : '\\text{False}';
    } else if (result is Set<SetModel>) {
      // For power set, format as a set of sets
      final innerSetsLatex = result.map((s) => s.toLaTeXString()).join(', ');
      return '\\{ $innerSetsLatex \\}';
    }
    return result.toString();
  }
}