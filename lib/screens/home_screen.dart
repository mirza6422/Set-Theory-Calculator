import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'package:set_theory_calculator/utils/app_styles.dart';

import '../provider/set_provider.dart';
import '../widgets/custom_keyboard.dart';
import '../widgets/history_list.dart';
import '../widgets/latex_input_field.dart';
import '../widgets/result_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to show the info dialog
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Use the Calculator'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  'This calculator supports standard set operations and complex expressions.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Text(
                  '1. Input Sets:',
                  style: AppStyles.labelStyle,
                ),
                const Text(
                  'Enter elements for Set A, Set B, and optionally a Universal Set (required for complement operations). Use curly braces {} and comma-separated values, e.g., {1, 2, 3}.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  '2. Individual Operations:',
                  style: AppStyles.labelStyle,
                ),
                const Text(
                  'Use the buttons for quick common operations like Union, Intersection, Difference, etc.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  '3. Complex Expressions:',
                  style: AppStyles.labelStyle,
                ),
                const Text(
                  'Type your expression using Set A, Set B, U (for Universal Set), and keywords for operations. Use parentheses for grouping.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  'Supported Keywords:',
                  style: AppStyles.labelStyle.copyWith(fontSize: 14),
                ),
                const Text(
                  '  - union (or \\cup)\n'
                      '  - intersection (or \\cap)\n'
                      '  - difference (or \\setminus)\n'
                      '  - symmetric_difference (or \\Delta)\n'
                      '  - cartesian_product (or \\times)\n'
                      '  - complement (unary, e.g., complement A)\n'
                      '  - powerseta (unary, power set of A)\n'
                      '  - powersetb (unary, power set of B)',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  'Examples:',
                  style: AppStyles.labelStyle.copyWith(fontSize: 14),
                ),
                Math.tex(
                  '(A \\cup B) \\cap C',
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const Text(
                  '  (Type: (A union B) intersection U)',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                Math.tex(
                  'A^c \\cup B^c',
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const Text(
                  '  (Type: (complement A) union (complement B))',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Results will be displayed below in mathematical notation.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got It!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatorProvider = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Theory Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context), // Call the info dialog method
            tooltip: 'How to use',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputField(
              label: 'Set A',
              hint: '{1, 2, 3}',
              onChanged: (value) => calculatorProvider.setSetA(value),
              initialValue: calculatorProvider.setA.toDisplayString(),
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Set B',
              hint: '{3, 4, 5}',
              onChanged: (value) => calculatorProvider.setSetB(value),
              initialValue: calculatorProvider.setB.toDisplayString(),
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Universal Set (for Complement)',
              hint: '{1, 2, 3, 4, 5, 6}',
              onChanged: (value) => calculatorProvider.setUniversalSet(value),
              initialValue: calculatorProvider.universalSet.toDisplayString(),
            ),
            const Divider(height: 32),
            Text(
              'Complex Expression',
              style: AppStyles.headingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Enter Expression (e.g., (A union B) intersection U)',
              hint: '(A union B) intersection U', // Updated hint for U
              onChanged: (value) => calculatorProvider.setExpressionInput(value),
              initialValue: calculatorProvider.expressionInput,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculatorProvider.evaluateExpression,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Evaluate Expression',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const Divider(height: 32),
            Text(
              'Individual Operations',
              style: AppStyles.headingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OperationButtons(
              onOperationSelected: (operation) {
                calculatorProvider.performOperation(operation);
              },
            ),
            const SizedBox(height: 24),
            ResultDisplay(
              expressionLatex: calculatorProvider.currentOperationDisplay,
              result: calculatorProvider.result,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: calculatorProvider.clearCalculator,
                icon: const Icon(Icons.clear),
                label: const Text('Clear All'),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: AppStyles.headingStyle,
                ),
                TextButton(
                  onPressed: calculatorProvider.clearHistory,
                  child: const Text('Clear History'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            HistoryList(history: calculatorProvider.history),
          ],
        ),
      ),
    );
  }
}