/// Collects leaf translation keys from nested easy_localization JSON.
/// Matches codegen naming: `general.continue` → `general_continue` in [LocaleKeys].
Set<String> collectEasyLocalizationFlatKeys(Map<String, dynamic> map) {
  final Set<String> result = <String>{};
  void walk(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> e in node.entries) {
      final String path = prefix.isEmpty ? e.key : '$prefix.${e.key}';
      final Object? v = e.value;
      if (v is Map<String, dynamic>) {
        walk(v, path);
      } else if (v is String) {
        result.add(path.replaceAll('.', '_'));
      }
    }
  }

  walk(map, '');
  return result;
}

/// Removes unused leaf keys from nested JSON; prunes empty parent maps.
bool removeUnusedLeavesFromNestedJson(
  Map<String, dynamic> data,
  String prefix,
  Set<String> unusedFlatKeys,
) {
  bool changed = false;
  final List<String> keysToRemove = <String>[];
  for (final MapEntry<String, dynamic> e in data.entries) {
    final String path = prefix.isEmpty ? e.key : '$prefix.${e.key}';
    final Object? v = e.value;
    if (v is Map<String, dynamic>) {
      if (removeUnusedLeavesFromNestedJson(v, path, unusedFlatKeys)) {
        changed = true;
      }
      if (v.isEmpty) {
        keysToRemove.add(e.key);
      }
    } else if (v is String) {
      final String flat = path.replaceAll('.', '_');
      if (unusedFlatKeys.contains(flat)) {
        keysToRemove.add(e.key);
        changed = true;
      }
    }
  }
  for (final String k in keysToRemove) {
    data.remove(k);
    changed = true;
  }
  return changed;
}
