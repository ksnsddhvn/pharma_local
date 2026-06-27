/// Pure-Dart fuzzy search utility.
/// Uses a hybrid approach:
///   1. Prefix/substring match (fast path, O(n)).
///   2. Levenshtein distance (fallback for typo-tolerance).
class FuzzySearch {
  /// Filters and ranks [candidates] by relevance to [query].
  /// Returns a sorted list of matching strings, best match first.
  static List<T> filter<T>({
    required String query,
    required List<T> candidates,
    required String Function(T) keyOf,
    int maxResults = 50,
    int maxDistance = 2,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return candidates.take(maxResults).toList();

    final scored = <_ScoredItem<T>>[];

    for (final item in candidates) {
      final key = keyOf(item).toLowerCase();
      int score = _score(q, key, maxDistance);
      if (score >= 0) {
        scored.add(_ScoredItem(item: item, score: score));
      }
    }

    scored.sort((a, b) => a.score.compareTo(b.score));
    return scored.take(maxResults).map((s) => s.item).toList();
  }

  /// Returns a score (lower = better match), or -1 if no match.
  static int _score(String query, String key, int maxDistance) {
    // Exact match
    if (key == query) return 0;
    // Prefix match
    if (key.startsWith(query)) return 1;
    // Substring match
    if (key.contains(query)) return 2;
    // Word-boundary match (query matches start of any word)
    final words = key.split(RegExp(r'[\s\-,]+'));
    if (words.any((w) => w.startsWith(query))) return 3;
    // Levenshtein fallback for typo tolerance
    final dist = _levenshtein(query, key.substring(0, key.length.clamp(0, query.length + 3)));
    if (dist <= maxDistance) return 10 + dist;
    return -1;
  }

  /// Standard Levenshtein distance using DP.
  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (var i = 0; i <= a.length; i++) dp[i][0] = i;
    for (var j = 0; j <= b.length; j++) dp[0][j] = j;

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // deletion
          dp[i][j - 1] + 1, // insertion
          dp[i - 1][j - 1] + cost, // substitution
        ].reduce((m, v) => v < m ? v : m);
      }
    }

    return dp[a.length][b.length];
  }
}

class _ScoredItem<T> {
  final T item;
  final int score;
  _ScoredItem({required this.item, required this.score});
}
