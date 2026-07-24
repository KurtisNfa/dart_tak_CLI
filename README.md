# Task CLI — Gestionnaire de tâches en ligne de commande (Dart)

Application en ligne de commande écrite en **Dart pur** (sans Flutter) qui
permet d'ajouter, lister, terminer et supprimer des tâches. Les tâches sont
sauvegardées automatiquement dans un fichier JSON local (`taches.json`).

---

## 1. Structure du projet

```
dart_projet/
├── .dart_tool/
├── bin/
│   └── main.dart          → point d'entrée : lit les commandes tapées dans le terminal
├── lib/
│   ├── exceptions.dart    → exceptions personnalisées
│   ├── models.dart        → Priorite, interface Affichable, classe Tache et ses sous-classes
│   └── repository.dart    → Repository<T> : gère la liste des tâches + le fichier JSON
├── test/
│   └── task_test.dart     → tests unitaires (package `test`)
├── pubspec.yaml           → dépendances du projet
└── README.md              → ce fichier
```

---

## 2. Installation

Il faut avoir le [SDK Dart](https://dart.dev/get-dart) installé sur ta machine.

```bash
cd task_cli
dart pub get
```

`dart pub get` télécharge le package `test`, nécessaire uniquement pour lancer
les tests (l'application elle-même n'a aucune dépendance externe).

---

## 3. Lancer les tests

```bash
dart test
```

Tu dois voir 6 tests passer (`All tests passed!`). Ils vérifient entre autres
que les exceptions sont bien levées en cas de données invalides, et que la
sauvegarde/relecture du fichier JSON fonctionne.

---

## 4. Utilisation de la CLI

Toutes les commandes se lancent avec :

```bash
dart run bin/main.dart <commande> [arguments]
```

Si tu ne tapes aucune commande, l'aide s'affiche automatiquement :

```bash
dart run bin/main.dart
```

```
Commandes disponibles:
  add "<titre>" <low|medium|high> [AAAA-MM-JJ] [urgent]
  list
  complete <id>
  delete <id>
```

Un fichier `taches.json` est créé automatiquement dans le dossier courant dès
le premier ajout de tâche.

---

### 4.1 Ajouter une tâche — `add`

**Syntaxe générale :**

```bash
dart run bin/main.dart add "<titre>" <priorité> [date limite] [urgent]
```

| Paramètre | Obligatoire | Valeurs possibles |
|---|---|---|
| `<titre>` | oui | texte entre guillemets, non vide |
| `<priorité>` | oui | `low`, `medium` ou `high` |
| `[date limite]` | non | format `AAAA-MM-JJ`, ex. `2026-08-01` |
| `[urgent]` | non | le mot exact `urgent`, toujours en dernier |

**⚠️ Important : `urgent` doit toujours être le dernier argument.** S'il est
placé avant la date, il sera interprété comme une date invalide et le
programme plantera.

#### Cas 1 — Tâche normale, sans date limite

```bash
dart run bin/main.dart add "Faire les courses" low
```
```
Tâche ajoutée (id: 1721839201234)
```

#### Cas 2 — Tâche normale, avec date limite

```bash
dart run bin/main.dart add "Réviser le rapport" medium 2026-08-01
```
```
Tâche ajoutée (id: 1721839205678)
```

#### Cas 3 — Tâche urgente, sans date limite

```bash
dart run bin/main.dart add "Répondre au client" high urgent
```
```
Tâche ajoutée (id: 1721839209012)
```

#### Cas 4 — Tâche urgente, avec date limite

```bash
dart run bin/main.dart add "Corriger le bug production" high 2026-08-01 urgent
```
```
Tâche ajoutée (id: 1721839212345)
```

#### Cas 5 — Erreur : titre ou priorité manquants

```bash
dart run bin/main.dart add "Titre seul"
```
```
Erreur: Données invalides : usage: add "<titre>" <low|medium|high> [AAAA-MM-JJ] [urgent]
```

#### Cas 6 — Erreur : priorité inconnue

```bash
dart run bin/main.dart add "Tâche test" extreme
```
```
Erreur: Données invalides : priorité inconnue "extreme"
```

#### Cas 7 — Erreur : titre vide

```bash
dart run bin/main.dart add "" high
```
```
Erreur: Données invalides : le titre ne peut pas être vide
```

---

### 4.2 Lister les tâches — `list`

```bash
dart run bin/main.dart list
```

Les tâches sont automatiquement triées par priorité décroissante
(`high` → `medium` → `low`).

#### Cas 1 — Il y a des tâches

```
[1721839212345] [ ] URGENT - Corriger le bug production (priorité: high)
[1721839205678] [ ] Réviser le rapport (priorité: medium)
[1721839201234] [ ] Faire les courses (priorité: low)
```

Chaque ligne commence par l'identifiant entre crochets (`[id]`), utile pour
les commandes `complete` et `delete`. Le `[ ]` ou `[x]` indique si la tâche
est terminée.

#### Cas 2 — Aucune tâche enregistrée

```bash
dart run bin/main.dart list
```
```
Aucune tâche.
```

---

### 4.3 Marquer une tâche comme terminée — `complete`

```bash
dart run bin/main.dart complete <id>
```

L'`<id>` s'obtient avec la commande `list` (nombre affiché entre crochets).

#### Cas 1 — L'id existe

```bash
dart run bin/main.dart complete 1721839201234
```
```
Tâche terminée: [x] Faire les courses (priorité: low)
```

#### Cas 2 — L'id n'existe pas

```bash
dart run bin/main.dart complete 999999
```
```
Erreur: Tâche introuvable : id "999999"
```

#### Cas 3 — Aucun id fourni

```bash
dart run bin/main.dart complete
```
```
Erreur: Données invalides : usage: complete <id>
```

---

### 4.4 Supprimer une tâche — `delete`

```bash
dart run bin/main.dart delete <id>
```

#### Cas 1 — L'id existe

```bash
dart run bin/main.dart delete 1721839201234
```
```
Tâche supprimée.
```

#### Cas 2 — L'id n'existe pas

```bash
dart run bin/main.dart delete 999999
```
```
Erreur: Tâche introuvable : id "999999"
```

#### Cas 3 — Aucun id fourni

```bash
dart run bin/main.dart delete
```
```
Erreur: Données invalides : usage: delete <id>
```

---

## 5. Le fichier de persistance `taches.json`

Après quelques ajouts, `taches.json` ressemble à ceci :

```json
[
  {
    "id": "1721839212345",
    "type": "urgent",
    "titre": "Corriger le bug production",
    "priorite": "high",
    "dateLimite": "2026-08-01T00:00:00.000",
    "terminee": false
  },
  {
    "id": "1721839201234",
    "type": "normal",
    "titre": "Faire les courses",
    "priorite": "low",
    "dateLimite": null,
    "terminee": true
  }
]
```

Le champ `"type"` (`"normal"` ou `"urgent"`) permet à l'application de
recréer la bonne classe Dart (`TacheNormale` ou `TacheUrgente`) au moment du
chargement — c'est ce qu'on appelle la désérialisation polymorphe.

Tu peux supprimer ce fichier à tout moment pour repartir de zéro : il sera
recréé automatiquement au prochain `add`.

---

## 6. Correspondance avec les exigences techniques du projet

| Exigence | Où c'est implémenté |
|---|---|
| Classe abstraite + héritage | `Tache` (abstraite, `lib/models.dart`) → `TacheNormale`, `TacheUrgente` |
| Interface implémentée | `Affichable` (méthode `afficher()`), implémentée par `Tache` |
| Générique | `Repository<T extends Tache>` (`lib/repository.dart`) |
| Exceptions personnalisées | `TacheIntrouvableException`, `DonneesInvalidesException` (`lib/exceptions.dart`) |
| Persistance JSON | `Repository.charger()` / `Repository.sauvegarder()` avec `dart:convert` |
| Tests unitaires (≥5) | `test/task_test.dart` — 6 tests |

---

## 7. Limitations connues (pistes d'amélioration)

- Une date mal formée (ex. `01/08/2026` au lieu de `2026-08-01`) fait
  planter le programme avec une erreur Dart brute, car `DateTime.parse()`
  n'est pas protégé par un `try/catch`. Une amélioration possible serait de
  capturer cette erreur et de la relancer sous forme de
  `DonneesInvalidesException`.
- Le mot `urgent` doit obligatoirement être le **dernier** argument de la
  commande `add`. L'ordre n'est pas flexible dans cette version simple.
- Il n'y a pas de commande pour modifier le titre ou la priorité d'une tâche
  existante (seulement `complete` et `delete`).