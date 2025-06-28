import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // Add this import
import 'package:intl/intl.dart'; // For date formatting
import 'package:set_theory_calculator/models/operation_result.dart';

import '../utils/latex_parser.dart';

class HistoryList extends StatelessWidget {
  final List<OperationResult> history;

  const HistoryList({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text('No operations yet.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final formattedTime = DateFormat('hh:mm a - MMM d, yyyy').format(entry.timestamp); // Corrected format
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BEGIN CHANGE ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    '${entry.expression} = ${LatexParser.generateResultLatex(entry.result)}',
                    mathStyle: MathStyle.text, // Use text style for inline history
                    textStyle: const TextStyle(fontSize: 16), // Adjust font size as needed
                  ),
                ),
                // --- END CHANGE ---
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}