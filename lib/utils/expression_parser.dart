import 'package:set_theory_calculator/models/set_model.dart';
import 'package:set_theory_calculator/utils/set_operations.dart';

// --- AST Node Definitions ---
abstract class AstNode {
  // A method to generate LaTeX from the AST node
  String toLatex(int parentPrecedence);
}

class SetNode implements AstNode {
  final String setName; // 'A', 'B', 'U'

  SetNode(this.setName);

  @override
  String toLatex(int parentPrecedence) {
    // Set names don't need parentheses regardless of parent precedence
    return setName;
  }
}

class UnaryOperationNode implements AstNode {
  final String operator; // 'complement', 'powerset'
  final AstNode operand;

  UnaryOperationNode(this.operator, this.operand);

  @override
  String toLatex(int parentPrecedence) {
    // Unary operators usually have very high precedence.
    // Parentheses around the operand depend on its own structure.
    switch (operator) {
      case 'complement':
      // A^c, B^c - operand is the base set
        return '${operand.toLatex(_operatorPrecedence[operator] ?? 0)}^c';
      case 'powerseta':
      // P(A)
        return 'P(${operand.toLatex(_operatorPrecedence[operator] ?? 0)})';
      case 'powersetb':
      // P(B)
        return 'P(${operand.toLatex(_operatorPrecedence[operator] ?? 0)})';
      default:
        return 'UNKNOWN_UNARY($operator, ${operand.toLatex(0)})';
    }
  }
}

class BinaryOperationNode implements AstNode {
  final String operator; // 'union', 'intersection', 'difference', etc.
  final AstNode left;
  final AstNode right;

  BinaryOperationNode(this.operator, this.left, this.right);

  @override
  String toLatex(int parentPrecedence) {
    final currentPrecedence = _operatorPrecedence[operator] ?? 0;

    // Determine if parentheses are needed for this operation relative to its parent
    bool needsParentheses = currentPrecedence < parentPrecedence;

    // Special handling for associative operations or specific rules.
    // For set operations, generally, if a lower precedence operation is inside
    // a higher precedence operation, it needs parentheses.
    // E.g., (A union B) intersection C
    // Here, "union" has lower precedence than "intersection".
    // So, "A union B" needs parentheses when it's the child of "intersection".

    // Convert operator string to LaTeX symbol
    String latexOperator = _latexOperatorMap[operator] ?? operator;

    // Recursively get LaTeX for children, passing current precedence
    String leftLatex = left.toLatex(currentPrecedence);
    String rightLatex = right.toLatex(currentPrecedence);

    // If the left child is a binary operation with lower or equal precedence than this one,
    // it likely needs parentheses. E.g., for `A union B intersection C`, `B intersection C`
    // will have higher precedence, so `intersection` will be inside `union`.
    if (left is BinaryOperationNode &&
        (_operatorPrecedence[(left as BinaryOperationNode).operator] ?? 0) < currentPrecedence) {
      leftLatex = '\\left( $leftLatex \\right)';
    }

    if (right is BinaryOperationNode &&
        (_operatorPrecedence[(right as BinaryOperationNode).operator] ?? 0) < currentPrecedence) {
      rightLatex = '\\left( $rightLatex \\right)';
    }


    String expression = '$leftLatex $latexOperator $rightLatex';

    if (needsParentheses) {
      return '\\left( $expression \\right)';
    }
    return expression;
  }
}

// --- Token Definitions (from previous version, unchanged) ---
const Map<String, int> _operatorPrecedence = {
  '(': 0,
  ')': 0,
  'complement': 4, // Unary
  'powerseta': 4, // Unary
  'powersetb': 4, // Unary
  'intersection': 3,
  'union': 2,
  'difference': 2,
  'symmetric_difference': 2,
  'cartesian_product': 1,
};

const Map<String, String> _latexOperatorMap = {
  'union': '\\cup',
  'intersection': '\\cap',
  'difference': '\\setminus',
  'symmetric_difference': '\\Delta',
  'cartesian_product': '\\times',
  // Complement and Power Set are handled specifically in UnaryOperationNode
};

enum TokenType {
  setA,
  setB,
  universalSet,
  operator,
  parenthesis,
  unknown,
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);

  @override
  String toString() => 'Token(type: $type, value: $value)';
}

// --- Refactored ExpressionParser to build and evaluate AST ---

class ExpressionParser {
  final Map<String, SetModel> definedSets;

  ExpressionParser({required this.definedSets});

  List<Token> _tokenize(String expression) {
    final tokens = <Token>[];
    String currentToken = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];

      if (char == '(' || char == ')') {
        if (currentToken.isNotEmpty) {
          tokens.add(_identifyToken(currentToken.toLowerCase()));
          currentToken = '';
        }
        tokens.add(Token(TokenType.parenthesis, char));
      } else if (char == ' ') {
        if (currentToken.isNotEmpty) {
          tokens.add(_identifyToken(currentToken.toLowerCase()));
          currentToken = '';
        }
      } else {
        currentToken += char;
      }
    }
    if (currentToken.isNotEmpty) {
      tokens.add(_identifyToken(currentToken.toLowerCase()));
    }
    return tokens;
  }

  Token _identifyToken(String rawValue) {
    switch (rawValue) {
      case 'a':
        return Token(TokenType.setA, 'A');
      case 'b':
        return Token(TokenType.setB, 'B');
      case 'u':
      case 'universal':
        return Token(TokenType.universalSet, 'U');
      case 'union':
        return Token(TokenType.operator, 'union');
      case 'intersection':
        return Token(TokenType.operator, 'intersection');
      case 'difference':
        return Token(TokenType.operator, 'difference');
      case 'symmetric_difference':
        return Token(TokenType.operator, 'symmetric_difference');
      case 'cartesian_product':
        return Token(TokenType.operator, 'cartesian_product');
      case 'complement':
        return Token(TokenType.operator, 'complement');
      case 'powerseta':
        return Token(TokenType.operator, 'powerseta');
      case 'powersetb':
        return Token(TokenType.operator, 'powersetb');
      default:
        throw Exception('Unknown token: $rawValue'); // Throw error for unrecognized tokens
    }
  }

  // Modified Shunting-yard to produce an AST
  AstNode parse(String expression) {
    final tokens = _tokenize(expression);
    final outputQueue = <Token>[]; // Still use RPN logic for ordering
    final operatorStack = <Token>[];

    for (var token in tokens) {
      if (token.type == TokenType.setA || token.type == TokenType.setB || token.type == TokenType.universalSet) {
        outputQueue.add(token);
      } else if (token.type == TokenType.operator) {
        while (operatorStack.isNotEmpty &&
            operatorStack.last.type == TokenType.operator &&
            _operatorPrecedence[token.value]! <= _operatorPrecedence[operatorStack.last.value]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      } else if (token.type == TokenType.parenthesis) {
        if (token.value == '(') {
          operatorStack.add(token);
        } else if (token.value == ')') {
          while (operatorStack.isNotEmpty && operatorStack.last.value != '(') {
            outputQueue.add(operatorStack.removeLast());
          }
          if (operatorStack.isEmpty || operatorStack.last.value != '(') {
            throw Exception('Mismatched parentheses');
          }
          operatorStack.removeLast(); // Pop '('
        }
      } else {
        throw Exception('Unknown token: ${token.value}');
      }
    }

    while (operatorStack.isNotEmpty) {
      if (operatorStack.last.type == TokenType.parenthesis) {
        throw Exception('Mismatched parentheses');
      }
      outputQueue.add(operatorStack.removeLast());
    }

    // Now, build the AST from the RPN output queue
    return _buildAstFromRpn(outputQueue);
  }

  AstNode _buildAstFromRpn(List<Token> rpnTokens) {
    final stack = <AstNode>[];

    for (var token in rpnTokens) {
      if (token.type == TokenType.setA) {
        stack.add(SetNode('A'));
      } else if (token.type == TokenType.setB) {
        stack.add(SetNode('B'));
      } else if (token.type == TokenType.universalSet) {
        stack.add(SetNode('U'));
      } else if (token.type == TokenType.operator) {
        if (token.value == 'complement' || token.value.startsWith('powerset')) {
          // Unary operator
          if (stack.isEmpty) throw Exception('Syntax Error: Missing operand for ${token.value}');
          final operand = stack.removeLast();
          stack.add(UnaryOperationNode(token.value, operand));
        } else {
          // Binary operator
          if (stack.length < 2) throw Exception('Syntax Error: Missing operands for ${token.value}');
          final right = stack.removeLast();
          final left = stack.removeLast();
          stack.add(BinaryOperationNode(token.value, left, right));
        }
      }
    }

    if (stack.length != 1) {
      throw Exception('Invalid expression syntax. Check operators and operands.');
    }
    return stack.single;
  }

  // Evaluate the AST
  dynamic evaluateAst(AstNode node) {
    if (node is SetNode) {
      final set = definedSets[node.setName];
      if (set == null) throw Exception('Set ${node.setName} not defined.');
      return set;
    } else if (node is UnaryOperationNode) {
      final operandValue = evaluateAst(node.operand);
      if (operandValue is! SetModel) throw Exception('Operand for unary operation is not a set.');

      switch (node.operator) {
        case 'complement':
          if (!definedSets.containsKey('U') || definedSets['U']!.elements.isEmpty) {
            throw Exception('Universal set (U) is required for complement operation.');
          }
          return SetOperations.complement(operandValue, definedSets['U']!);
        case 'powerseta':
        case 'powersetb':
          return SetOperations.powerSet(operandValue);
        default:
          throw Exception('Unsupported unary operator: ${node.operator}');
      }
    } else if (node is BinaryOperationNode) {
      final leftValue = evaluateAst(node.left);
      final rightValue = evaluateAst(node.right);

      if (leftValue is! SetModel || rightValue is! SetModel) {
        // Handle comparison operators if they return bool.
        // For now, only set operations are assumed.
        if (node.operator.startsWith('is_')) { // Example for comparison operators
          switch (node.operator) {
            case 'is_subset':
              return SetOperations.isSubset(leftValue, rightValue);
            case 'is_proper_subset':
              return SetOperations.isProperSubset(leftValue, rightValue);
            case 'is_superset':
              return SetOperations.isSuperset(leftValue, rightValue);
            case 'is_proper_superset':
              return SetOperations.isProperSuperset(leftValue, rightValue);
            case 'are_disjoint':
              return SetOperations.areDisjoint(leftValue, rightValue);
            default:
              throw Exception('Unsupported comparison operator: ${node.operator}');
          }
        }
        throw Exception('Operands for binary operation are not sets.');
      }

      switch (node.operator) {
        case 'union':
          return SetOperations.union(leftValue, rightValue);
        case 'intersection':
          return SetOperations.intersection(leftValue, rightValue);
        case 'difference':
          return SetOperations.difference(leftValue, rightValue);
        case 'symmetric_difference':
          return SetOperations.symmetricDifference(leftValue, rightValue);
        case 'cartesian_product':
          return SetOperations.cartesianProduct(leftValue, rightValue);
        default:
          throw Exception('Unsupported binary operator: ${node.operator}');
      }
    }
    throw Exception('Unknown AST node type.');
  }

  // Public method to parse and evaluate
  dynamic parseAndEvaluate(String expression) {
    final ast = parse(expression);
    return evaluateAst(ast);
  }

  // Public method to parse and generate LaTeX
  String parseAndGenerateLatex(String expression) {
    final ast = parse(expression);
    // Pass a very low precedence to the root to ensure no unnecessary parentheses
    // are added at the top level.
    return ast.toLatex(0);
  }
}