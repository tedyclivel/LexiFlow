# Contribuer à LexiFlow

Merci de votre intérêt pour LexiFlow. Ce document décrit le processus attendu pour proposer une amélioration de qualité, reproductible et facile à examiner.

## Avant de commencer

Avant d’ouvrir une issue ou une pull request :

- recherchez les discussions et tickets existants afin d’éviter les doublons ;
- vérifiez que votre proposition correspond au périmètre du projet ;
- pour une évolution importante, ouvrez d’abord une discussion afin de valider l’approche ;
- ne publiez jamais de secret, de donnée personnelle ou de fichier Firebase confidentiel.

## Préparer son environnement

Installez une version de Flutter compatible avec le SDK déclaré dans [`pubspec.yaml`](pubspec.yaml), puis exécutez :

```bash
flutter doctor
flutter pub get
```

Pour les fonctionnalités connectées, utilisez un projet Firebase de développement et des règles adaptées à cet environnement. Ne testez pas une modification destructive directement sur des données de production.

## Créer une branche

Partez de la branche principale à jour et utilisez une branche courte et explicite :

```bash
git switch main
git pull --rebase
git switch -c feat/daily-challenge-streak
```

Préfixes recommandés :

- `feat/` pour une fonctionnalité ;
- `fix/` pour une correction ;
- `refactor/` pour une restructuration sans changement fonctionnel ;
- `test/` pour les tests ;
- `docs/` pour la documentation ;
- `chore/` pour la maintenance technique.

## Développer avec cohérence

- Respectez les conventions Dart et les règles activées dans `analysis_options.yaml`.
- Préférez les widgets et services réutilisables aux duplications.
- Gardez la logique métier dans les providers, modèles ou services appropriés plutôt que dans les widgets d’interface.
- Utilisez Riverpod conformément aux patterns déjà présents dans `lib/providers/`.
- Préservez les comportements hors ligne lorsque la fonctionnalité ne dépend pas strictement de Firebase.
- Traitez explicitement les erreurs réseau, les états de chargement et les données absentes.
- Tenez compte des plateformes Flutter supportées avant d’utiliser une API native.
- N’ajoutez pas de dépendance sans justification claire et vérification de sa maintenance et de sa licence.

## Tests et vérifications

Toute modification devrait être accompagnée des tests pertinents. Avant de soumettre votre travail, exécutez :

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Si votre changement concerne une plateforme spécifique, testez également sur l’émulateur ou l’appareil concerné. Pour l’interface, vérifiez les états normal, vide, chargement, erreur et hors ligne lorsque cela s’applique.

Une pull request qui ne peut pas exécuter Firebase localement doit tout de même pouvoir valider les parcours non connectés, ou expliquer précisément la limitation.

## Commits

Rédigez des commits atomiques, faciles à relire, avec un message à l’impératif et un périmètre clair :

```text
feat(blitz): add session summary
fix(auth): handle expired session
docs: clarify Firebase setup
```

Évitez de mélanger une refactorisation générale avec une correction fonctionnelle sans nécessité. Les messages de commit peuvent être en anglais ou en français, mais restent cohérents et explicites.

## Ouvrir une pull request

Une pull request de qualité contient :

- un titre concis décrivant le résultat attendu ;
- le contexte et le problème traité ;
- une description de l’approche retenue ;
- les plateformes concernées ;
- les captures ou enregistrements utiles pour un changement d’interface ;
- la liste des commandes de vérification exécutées ;
- les limites connues, migrations ou étapes de configuration nécessaires.

Avant de demander une revue, vérifiez que la branche est à jour, que les changements sont ciblés et qu’aucun secret ou fichier généré inutile n’est inclus.

## Signaler un bug

Un signalement utile contient au minimum :

1. la version de l’application, de Flutter et de l’appareil ;
2. les étapes exactes pour reproduire le problème ;
3. le résultat attendu et le résultat observé ;
4. les journaux pertinents, après suppression des données sensibles ;
5. une capture d’écran ou une vidéo lorsque le problème est visuel.

Pour un problème de sécurité, ne publiez pas de détails exploitables dans une issue publique. Contactez directement les mainteneurs via le canal privé officiellement indiqué par le projet.

## Revue et intégration

Les mainteneurs évaluent notamment la justesse fonctionnelle, la lisibilité, la couverture de tests, l’impact multiplateforme, l’accessibilité, la performance et la compatibilité avec les fonctionnalités existantes.

Une demande de modification est une étape normale du processus. Les échanges doivent rester factuels, respectueux et orientés vers l’amélioration du projet. Une pull request peut être refusée si elle augmente sensiblement la complexité, introduit un risque de sécurité ou ne correspond pas à la direction du produit.

## Licence et propriété intellectuelle

La licence du dépôt n’étant pas encore indiquée, vérifiez avec les mainteneurs les conditions applicables avant de proposer du contenu tiers, des sons, des images, des polices, des textes ou du code provenant d’un autre projet.

En contribuant, vous confirmez disposer des droits nécessaires sur votre contribution et acceptez qu’elle puisse être examinée, modifiée et intégrée au projet selon les conditions qui seront définies par les mainteneurs.
