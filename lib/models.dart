import 'exceptions.dart';

// Enum simple pour la priorité d'une tâche.
enum Priorite { low, medium, high }

// Convertit un texte ("low", "medium", "high") en Priorite.
Priorite priorieDepuisTexte(String texte) {
  switch (texte.toLowerCase()) {
    case 'low':
      return Priorite.low;
    case 'medium':
      return Priorite.medium;
    case 'high':
      return Priorite.high;
    default:
      throw DonneesInvalidesException('priorité inconnue "$texte"');
  }
}

// INTERFACE : toute classe "Affichable" doit savoir se décrire en texte.
abstract class Affichable {
  String afficher();
}

// CLASSE ABSTRAITE : base commune à toutes les tâches.
// Une classe abstraite ne peut pas être instanciée directement,
// elle sert de modèle pour ses sous-classes.
abstract class Tache implements Affichable {
  String id;
  String titre;
  Priorite priorite;
  DateTime? dateLimite;
  bool terminee;

  Tache({
    required this.id,
    required this.titre,
    required this.priorite,
    this.dateLimite,
    this.terminee = false,
  }) {
    if (titre.trim().isEmpty) {
      throw DonneesInvalidesException('le titre ne peut pas être vide');
    }
  }

  // Chaque sous-classe doit indiquer son "type", utile pour le JSON.
  String get type;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'titre': titre,
      'priorite': priorite.name,
      'dateLimite': dateLimite?.toIso8601String(),
      'terminee': terminee,
    };
  }

  // Reconstruit une Tache (ou une de ses sous-classes) depuis du JSON.
  static Tache fromJson(Map<String, dynamic> json) {
    final priorite = priorieDepuisTexte(json['priorite']);
    final dateLimite =
        json['dateLimite'] != null ? DateTime.parse(json['dateLimite']) : null;

    if (json['type'] == 'urgent') {
      return TacheUrgente(
        id: json['id'],
        titre: json['titre'],
        priorite: priorite,
        dateLimite: dateLimite,
        terminee: json['terminee'] ?? false,
      );
    }
    return TacheNormale(
      id: json['id'],
      titre: json['titre'],
      priorite: priorite,
      dateLimite: dateLimite,
      terminee: json['terminee'] ?? false,
    );
  }
}

// HÉRITAGE : TacheNormale hérite de Tache (extends).
class TacheNormale extends Tache {
  TacheNormale({
    required super.id,
    required super.titre,
    required super.priorite,
    super.dateLimite,
    super.terminee,
  });

  @override
  String get type => 'normal';

  @override
  String afficher() {
    final statut = terminee ? '[x]' : '[ ]';
    return '$statut $titre (priorité: ${priorite.name})';
  }
}

// HÉRITAGE : TacheUrgente hérite aussi de Tache, avec un affichage différent.
class TacheUrgente extends Tache {
  TacheUrgente({
    required super.id,
    required super.titre,
    required super.priorite,
    super.dateLimite,
    super.terminee,
  });

  @override
  String get type => 'urgent';

  @override
  String afficher() {
    final statut = terminee ? '[x]' : '[ ]';
    return '$statut URGENT - $titre (priorité: ${priorite.name})';
  }
}