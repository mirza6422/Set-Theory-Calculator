import 'package:set_theory_calculator/models/set_model.dart';

class SetOperations {
  // Union (A ∪ B)
  static SetModel union(SetModel setA, SetModel setB) {
    return SetModel(elements: setA.elements.union(setB.elements));
  }

  // Intersection (A ∩ B)
  static SetModel intersection(SetModel setA, SetModel setB) {
    return SetModel(elements: setA.elements.intersection(setB.elements));
  }

  // Difference (A \ B or A - B)
  static SetModel difference(SetModel setA, SetModel setB) {
    return SetModel(elements: setA.elements.difference(setB.elements));
  }

  // Symmetric Difference (A Δ B or A ⊖ B)
  static SetModel symmetricDifference(SetModel setA, SetModel setB) {
    final unionSet = union(setA, setB);
    final intersectionSet = intersection(setA, setB);
    return SetModel(elements: unionSet.elements.difference(intersectionSet.elements));
  }

  // Subset (A ⊆ B)
  static bool isSubset(SetModel setA, SetModel setB) {
    return setB.elements.containsAll(setA.elements);
  }

  // Proper Subset (A ⊂ B)
  static bool isProperSubset(SetModel setA, SetModel setB) {
    return isSubset(setA, setB) && setA.elements.length < setB.elements.length;
  }

  // Superset (A ⊇ B)
  static bool isSuperset(SetModel setA, SetModel setB) {
    return setA.elements.containsAll(setB.elements);
  }

  // Proper Superset (A ⊃ B)
  static bool isProperSuperset(SetModel setA, SetModel setB) {
    return isSuperset(setA, setB) && setA.elements.length > setB.elements.length;
  }

  // Disjoint Sets (A ∩ B = ∅)
  static bool areDisjoint(SetModel setA, SetModel setB) {
    return intersection(setA, setB).elements.isEmpty;
  }

  // Power Set (P(A))
  // This can get computationally expensive for large sets.
  static Set<SetModel> powerSet(SetModel setA) {
    final elements = setA.elements.toList();
    final powerSetResult = <SetModel>{};
    final n = elements.length;

    // Iterate from 0 to 2^n - 1 to generate all combinations
    for (int i = 0; i < (1 << n); i++) {
      final currentSubsetElements = <String>{};
      for (int j = 0; j < n; j++) {
        if ((i >> j) & 1 == 1) {
          currentSubsetElements.add(elements[j]);
        }
      }
      powerSetResult.add(SetModel(elements: currentSubsetElements));
    }
    return powerSetResult;
  }

  // Cartesian Product (A × B)
  static SetModel cartesianProduct(SetModel setA, SetModel setB) {
    final productElements = <String>{};
    for (String elemA in setA.elements) {
      for (String elemB in setB.elements) {
        productElements.add('($elemA, $elemB)');
      }
    }
    return SetModel(elements: productElements);
  }

  // Complement (requires a universal set)
  // For demonstration, let's assume a universal set is provided or implicitly known.
  // In a real app, you'd probably have a way to define the universal set.
  static SetModel complement(SetModel setA, SetModel universalSet) {
    return SetModel(elements: universalSet.elements.difference(setA.elements));
  }
}