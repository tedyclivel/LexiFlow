enum GameMode {
  classic,
  timed,
  zen,
  hard,
  blitz, // Fast-paced mode with successive grids
  chaos, // Letters drift and shuffle
  multiplayer, // Competitive duel
}

class Word {
  final String text; // The word itself (e.g. "FLUTTER")
  final String hint; // Optional hint
  bool found; // Is it found?
  List<int> foundIndices; // Indices in the grid (e.g. [0, 1, 2...])

  Word({
    required this.text,
    this.hint = '',
    this.found = false,
    this.foundIndices = const [],
  });
}

class Level {
  final int id;
  final String name; // e.g. "Animals"
  final int rows;
  final int cols;
  final List<String> words;
  final int timeLimit; // in seconds
  final GameMode mode;
  final int worldId;
  final String worldName;

  Level({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.words,
    required this.timeLimit,
    this.mode = GameMode.classic,
    required this.worldId,
    required this.worldName,
  });
}
