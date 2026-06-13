import '../models/child_profile.dart';
import '../models/family_account.dart';

class SelectedChildService {
  static ChildProfile? _current;

  static ChildProfile? get current => _current;

  static void select(ChildProfile child) => _current = child;

  // Picks the first child whose ageMode matches, falls back to children.first.
  // Returns the selected child (or null if the family has no children yet).
  static ChildProfile? selectForAgeMode(AgeMode mode) {
    final children = FamilyAccount.current?.children ?? [];
    if (children.isEmpty) return null;
    final match = children.cast<ChildProfile?>().firstWhere(
      (c) => c?.ageMode == mode,
      orElse: () => children.first,
    );
    if (match != null) _current = match;
    return match;
  }

  // Fallback: sets and returns children.first. Called when no house context exists.
  static ChildProfile? selectDefault() {
    final children = FamilyAccount.current?.children ?? [];
    if (children.isEmpty) return null;
    _current = children.first;
    return _current;
  }
}
