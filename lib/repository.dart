import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';
import 'models.dart';

// GÉNÉRIQUE : Repository<T> peut stocker n'importe quel type T
// qui hérite de Tache. Ici on l'utilise avec T = Tache.
class Repository<T extends Tache> {
  final String cheminFichier;
  final List<T> elements = [];

  Repository(this.cheminFichier);

  List<T> tous() => elements;

  T? trouverParId(String id) {
    for (var e in elements) {
      if (e.id == id) return e;
    }
    return null;
  }

  void ajouter(T element) {
    elements.add(element);
  }

  void supprimer(String id) {
    final trouve = trouverParId(id);
    if (trouve == null) {
      throw TacheIntrouvableException('id "$id"');
    }
    elements.remove(trouve);
  }

  // Charge les tâches depuis le fichier JSON (s'il existe).
  void charger() {
    final fichier = File(cheminFichier);
    elements.clear();
    if (!fichier.existsSync()) return;

    final contenu = fichier.readAsStringSync();
    if (contenu.trim().isEmpty) return;

    final liste = jsonDecode(contenu) as List;
    for (var item in liste) {
      elements.add(Tache.fromJson(item) as T);
    }
  }

  // Écrit les tâches dans le fichier JSON.
  void sauvegarder() {
    final fichier = File(cheminFichier);
    final liste = elements.map((e) => e.toJson()).toList();
    fichier.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(liste));
  }
}