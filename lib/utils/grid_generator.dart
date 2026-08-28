import 'dart:math';
import 'package:search_word/models/level_model.dart';

class GridData {
  final List<List<String>> grid;
  final List<String> placedWords;

  GridData({required this.grid, required this.placedWords});
}

class GridGenerator {
  static GridData generate(int rows, int cols, List<String> words, GameMode mode) {
    if (words.isEmpty) {
      return GridData(
        grid: List.generate(rows, (_) => List.filled(cols, '')),
        placedWords: [],
      );
    }

    // Try multiple times to get a perfect grid where all words are placed
    for (int retry = 0; retry < 10; retry++) {
      List<List<String>> grid = List.generate(rows, (_) => List.filled(cols, ''));
      List<String> sortedWords = List.from(words)..sort((a, b) => b.length.compareTo(a.length));
      List<String> successfullyPlaced = [];
      final random = Random();

      for (String word in sortedWords) {
        bool placed = false;
        int attempts = 0;
        
        while (!placed && attempts < 200) {
          attempts++;
          int directionCount = (mode == GameMode.hard) ? 8 : 4;
          int direction = random.nextInt(directionCount); 
          int r = random.nextInt(rows);
          int c = random.nextInt(cols);
          int dr = 0, dc = 0;
          String wordToPlace = word;

          switch (direction) {
            case 0: dr = 0; dc = 1; break; // Right
            case 1: dr = 1; dc = 0; break; // Down
            case 2: dr = 1; dc = 1; break; // Down-Right
            case 3: dr = -1; dc = 1; break; // Up-Right
            case 4: dr = 0; dc = -1; break; // Left
            case 5: dr = -1; dc = 0; break; // Up
            case 6: dr = -1; dc = -1; break; // Up-Left
            case 7: dr = 1; dc = -1; break; // Down-Left
          }
          
          if (mode == GameMode.hard && random.nextBool()) {
            wordToPlace = word.split('').reversed.join();
          }
          
          int endRow = r + dr * (wordToPlace.length - 1);
          int endCol = c + dc * (wordToPlace.length - 1);
          
          if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= cols) continue;
          
          bool fits = true;
          for (int i = 0; i < wordToPlace.length; i++) {
            String cell = grid[r + dr * i][c + dc * i];
            if (cell.isNotEmpty && cell != wordToPlace[i]) {
              fits = false;
              break;
            }
          }
          
          if (fits) {
            for (int i = 0; i < wordToPlace.length; i++) {
              grid[r + dr * i][c + dc * i] = wordToPlace[i];
            }
            successfullyPlaced.add(word);
            placed = true;
          }
        }
      }

      // If everything is placed, we are good!
      if (successfullyPlaced.length == words.length) {
        _fillEmptyCells(grid, random);
        return GridData(grid: grid, placedWords: successfullyPlaced);
      }
    }

    // Fallback: If we couldn't place all words after retries, 
    // try one last time and return whatever we managed to place
    List<List<String>> finalGrid = List.generate(rows, (_) => List.filled(cols, ''));
    List<String> sortedWords = List.from(words)..sort((a, b) => b.length.compareTo(a.length));
    List<String> successfullyPlaced = [];
    final random = Random();

    for (String word in sortedWords) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        attempts++;
        int directionCount = (mode == GameMode.hard) ? 8 : 4;
        int direction = random.nextInt(directionCount);
        int r = random.nextInt(rows);
        int c = random.nextInt(cols);
        int dr = 0, dc = 0;
        switch (direction) {
          case 0: dr = 0; dc = 1; break;
          case 1: dr = 1; dc = 0; break;
          case 2: dr = 1; dc = 1; break;
          case 3: dr = -1; dc = 1; break;
          case 4: dr = 0; dc = -1; break;
          case 5: dr = -1; dc = 0; break;
          case 6: dr = -1; dc = -1; break;
          case 7: dr = 1; dc = -1; break;
        }
        int endRow = r + dr * (word.length - 1);
        int endCol = c + dc * (word.length - 1);
        if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= cols) continue;
        bool fits = true;
        for (int i = 0; i < word.length; i++) {
          String cell = finalGrid[r + dr * i][c + dc * i];
          if (cell.isNotEmpty && cell != word[i]) { fits = false; break; }
        }
        if (fits) {
          for (int i = 0; i < word.length; i++) finalGrid[r + dr * i][c + dc * i] = word[i];
          successfullyPlaced.add(word);
          placed = true;
        }
      }
    }
    _fillEmptyCells(finalGrid, random);
    return GridData(grid: finalGrid, placedWords: successfullyPlaced);
  }

  static void _fillEmptyCells(List<List<String>> grid, Random random) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = chars[random.nextInt(chars.length)];
        }
      }
    }
  }
}
