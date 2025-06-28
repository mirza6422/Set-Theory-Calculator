class SetModel {
  final Set<String> elements; // Using String for elements for simplicity. Can be dynamic.
  final String name; // Optional: for naming sets if needed (e.g., Set A, Set B)

  SetModel({required this.elements, this.name = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SetModel &&
              runtimeType == other.runtimeType &&
              setEquals(elements, other.elements); // Custom set comparison

  @override
  int get hashCode => elements.hashCode;

  // Helper to compare two sets for equality (order-independent)
  static bool setEquals(Set<String>? set1, Set<String>? set2) {
    if (set1 == null || set2 == null) {
      return set1 == set2;
    }
    if (set1.length != set2.length) {
      return false;
    }
    return set1.containsAll(set2);
  }

  // Method to convert set to a string representation for display
  String toDisplayString() {
    return '{${elements.join(', ')}}';
  }

  // Method to convert set to LaTeX representation
  String toLaTeXString() {
    return '\\{${elements.join(', ')}\\}';
  }
}