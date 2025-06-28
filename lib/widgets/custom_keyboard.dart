import 'package:flutter/material.dart';

class OperationButtons extends StatelessWidget {
  final Function(String) onOperationSelected;

  const OperationButtons({
    super.key,
    required this.onOperationSelected,
  });

  final List<String> operations = const [
    'Union',
    'Intersection',
    'Difference (A-B)',
    'Difference (B-A)',
    'Symmetric Difference',
    'Is Subset (A ⊆ B)',
    'Is Proper Subset (A ⊂ B)',
    'Is Superset (A ⊇ B)',
    'Is Proper Superset (A ⊃ B)',
    'Are Disjoint',
    'Power Set (A)',
    'Power Set (B)',
    'Cartesian Product (A x B)',
    'Cartesian Product (B x A)',
    'Complement (A)',
    'Complement (B)',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2.5,
      ),
      itemCount: operations.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () => onOperationSelected(operations[index]),
          child: Text(
            operations[index],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}