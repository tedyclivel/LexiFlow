import 'package:search_word/models/level_model.dart';
import 'package:flutter/material.dart';

class World {
  final int id;
  final String name;
  final String description;
  final Color color;
  final List<Level> levels;
  bool isLocked;

  World({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.levels,
    this.isLocked = true,
  });
}

class LevelData {
  static List<World> worlds = [
    // ────────────── MONDE 1 : NATURE (15 mots, grilles 10x10) ──────────────
    World(
      id: 1,
      name: "Nature",
      description: "Explorez la faune et la flore sauvage.",
      color: Colors.teal.shade700,
      isLocked: false,
      levels: [
        Level(
          id: 1, worldId: 1, worldName: "Nature", name: "Animaux",
          rows: 10, cols: 10, timeLimit: 0, mode: GameMode.classic,
          words: [
            "LION", "TIGRE", "CHAT", "CHIEN", "OURS",
            "AIGLE", "LOUP", "CERF", "LAPIN", "RENARD",
            "BISON", "PHOQUE", "COBRA", "LYNX", "PANDA",
          ],
        ),
        Level(
          id: 2, worldId: 1, worldName: "Nature", name: "Forêt",
          rows: 10, cols: 10, timeLimit: 0, mode: GameMode.classic,
          words: [
            "ARBRE", "FEUILLE", "BOIS", "PIN", "CHENE",
            "MOUSSE", "LIERRE", "CEDRE", "SAULE", "ERABLE",
            "HERBE", "FLEUR", "RACINE", "TRONC", "BRANCHE",
          ],
        ),
        Level(
          id: 3, worldId: 1, worldName: "Nature", name: "Oiseaux",
          rows: 10, cols: 10, timeLimit: 0, mode: GameMode.timed,
          words: [
            "AIGLE", "PIE", "HIBOU", "CORBEAU", "MERLE",
            "CYGNE", "HERON", "CANARD", "GRUE", "FAUCON",
            "PERCHE", "GEAI", "ROUGE", "COLOMBE", "MARTIN",
          ],
        ),
      ],
    ),

    // ────────────── MONDE 2 : ESPACE (20 mots, grilles 12x12) ──────────────
    World(
      id: 2,
      name: "Espace",
      description: "Un voyage aux confins de l'univers.",
      color: Colors.indigo.shade900,
      isLocked: true,
      levels: [
        Level(
          id: 4, worldId: 2, worldName: "Espace", name: "Planètes",
          rows: 12, cols: 12, timeLimit: 0, mode: GameMode.classic,
          words: [
            "MARS", "JUPITER", "SATURNE", "VENUS", "TERRE",
            "MERCURE", "NEPTUNE", "URANUS", "PLUTON", "CERES",
            "SOLEIL", "LUNE", "COMETE", "METEOR", "ASTREE",
            "PHOEBE", "TITAN", "EUROPE", "CALLISTO", "GANYMEDE",
          ],
        ),
        Level(
          id: 5, worldId: 2, worldName: "Espace", name: "Astrologie",
          rows: 12, cols: 12, timeLimit: 0, mode: GameMode.hard,
          words: [
            "ZODIAQUE", "BELIER", "TAUREAU", "GEMEAUX", "CANCER",
            "LION", "VIERGE", "BALANCE", "SCORPION", "SAGITTAIRE",
            "CAPRICORNE", "VERSEAU", "POISSONS", "ASCENDANT", "MAISON",
            "PLANETE", "SIGNE", "CUSP", "NOEUD", "CARRE",
          ],
        ),
        Level(
          id: 6, worldId: 2, worldName: "Espace", name: "Galaxies",
          rows: 12, cols: 12, timeLimit: 0, mode: GameMode.zen,
          words: [
            "ANDROMEDE", "SPIRALE", "NEBULEUSE", "COMETE", "QUASAR",
            "PULSAR", "TROU", "SUPERNOVA", "VOIELACTEE", "AMAS",
            "MAGELLANIC", "SEYFERT", "LENTICULAIRE", "ELLIPTIQUE", "IRREGULIER",
            "NUAGE", "RADIANT", "PHOTON", "PROTON", "PLASMA",
          ],
        ),
      ],
    ),

    // ────────────── MONDE 3 : HISTOIRE (25 mots, grilles 14x14) ─────────────
    World(
      id: 3,
      name: "Histoire",
      description: "Redécouvrez les grandes civilisations.",
      color: Colors.orange.shade800,
      isLocked: true,
      levels: [
        Level(
          id: 7, worldId: 3, worldName: "Histoire", name: "Egypte",
          rows: 14, cols: 14, timeLimit: 0, mode: GameMode.hard,
          words: [
            "PHARAON", "PYRAMIDE", "SPHINX", "NIL", "ANUBIS",
            "HORUS", "ISIS", "OSIRIS", "CLEOPATRE", "RAMSES",
            "MOMIE", "PAPYRUS", "HIEROGLYPHE", "TIARE", "AMULETTE",
            "SARCOPHAGE", "CANOPE", "BAST", "THOT", "SEKHMET",
            "APIS", "ATON", "AMON", "NUBIE", "KARNAK",
          ],
        ),
        Level(
          id: 8, worldId: 3, worldName: "Histoire", name: "Rome",
          rows: 14, cols: 14, timeLimit: 0, mode: GameMode.hard,
          words: [
            "CESAR", "SENAT", "FORUM", "GLADIATEUR", "EMPIRE",
            "LEGION", "CONSUL", "TRIBUN", "MARCUS", "AURELIUS",
            "COLISEE", "BASILIQUE", "AQUEDUCT", "CICERON", "BRUTUS",
            "HANNIBAL", "VIRGILE", "OVIDE", "PLINE", "TACITE",
            "POMPEE", "TIBERIUS", "HADRIEN", "TRAJAN", "CALIGULA",
          ],
        ),
      ],
    ),
  ];

  static List<Level> get allLevels => worlds.expand((w) => w.levels).toList();

  static Level? getLevelById(int id) {
    for (var world in worlds) {
      for (var level in world.levels) {
        if (level.id == id) return level;
      }
    }
    return null;
  }

  static Level? getNextLevel(Level current) {
    final world = worlds.firstWhere((w) => w.id == current.worldId);
    final currentIndex = world.levels.indexWhere((l) => l.id == current.id);

    if (currentIndex != -1 && currentIndex < world.levels.length - 1) {
      return world.levels[currentIndex + 1];
    }

    final worldIndex = worlds.indexOf(world);
    if (worldIndex != -1 && worldIndex < worlds.length - 1) {
      return worlds[worldIndex + 1].levels.first;
    }

    return null;
  }
}
