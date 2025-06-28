import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // Add this import

import 'package:set_theory_calculator/utils/app_styles.dart';

import '../utils/latex_parser.dart';

class ResultDisplay extends StatelessWidget {
  final String expressionLatex;
  final dynamic result;

  const ResultDisplay({
    super.key,
    required this.expressionLatex,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    String resultLatex = '';
    if (result != null) {
      resultLatex = LatexParser.generateResultLatex(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expression:',
          style: AppStyles.labelStyle,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          // --- BEGIN CHANGE ---
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              expressionLatex.isEmpty ? '' : '$expressionLatex',
              mathStyle: MathStyle.display, // Or .text for inline
              textStyle: AppStyles.resultTextStyle.copyWith(color: Colors.black), // Adjust font size/color if needed
              // textAlign: TextAlign.center, // Math.tex doesn't directly have textAlign
              // You might need to wrap in Center or Align if you want to center it visually
            ),
          ),
          // --- END CHANGE ---
        ),
        const SizedBox(height: 16),
        Text(
          'Result:',
          style: AppStyles.labelStyle,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          // --- BEGIN CHANGE ---
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              resultLatex.isEmpty ? '' : resultLatex,
              mathStyle: MathStyle.display, // Or .text for inline
              textStyle: AppStyles.resultTextStyle, // Use your defined style
            ),
          ),
          // --- END CHANGE ---
        ),
      ],
    );
  }
}