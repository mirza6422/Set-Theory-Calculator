import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tex/flutter_tex.dart';

import 'package:set_theory_calculator/utils/app_styles.dart';

import '../provider/set_provider.dart';
import '../widgets/custom_keyboard.dart';
import '../widgets/history_list.dart';
import '../widgets/latex_input_field.dart';
import '../widgets/result_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculatorProvider = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Theory Calculator'),
        centerTitle: true,
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
            const SizedBox(height: 24),
            Text(
              'Operations',
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
                label: const Text('Clear'),
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