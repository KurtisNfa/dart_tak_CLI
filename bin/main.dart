import 'package:task_cli/exceptions.dart';
import 'package:task_cli/models.dart';
import 'package:task_cli/repository.dart';

void main(List<String> args) {
  final repo = Repository<Tache>('taches.json');
  repo.charger();

  if (args.isEmpty) {
    afficherAide();
    return;
  }

  try {
    switch (args[0]) {
      case 'add':
        ajouterTache(repo, args);
        break;
      case 'list':
        listerTaches(repo);
        break;
      case 'complete':
        terminerTache(repo, args);
        break;
      case 'delete':
        supprimerTache(repo, args);
        break;
      default:
        afficherAide();
    }
  } on DonneesInvalidesException catch (e) {
    print('Erreur: $e');
  } on TacheIntrouvableException catch (e) {
    print('Erreur: $e');
  }
}

// Exemple: dart run bin/main.dart add "Réviser le rapport" high 2026-08-01
// Exemple urgent: dart run bin/main.dart add "Corriger bug" high 2026-08-01 urgent
void ajouterTache(Repository<Tache> repo, List<String> args) {
  if (args.length < 3) {
    throw DonneesInvalidesException(
        'usage: add "<titre>" <low|medium|high> [AAAA-MM-JJ] [urgent]');
  }

  final titre = args[1];
  final priorite = priorieDepuisTexte(args[2]);

  DateTime? dateLimite;
  if (args.length > 3 && args[3] != 'urgent') {
    dateLimite = DateTime.parse(args[3]);
  }
  final estUrgente = args.contains('urgent');

  final id = DateTime.now().millisecondsSinceEpoch.toString();

  final Tache tache = estUrgente
      ? TacheUrgente(id: id, titre: titre, priorite: priorite, dateLimite: dateLimite)
      : TacheNormale(id: id, titre: titre, priorite: priorite, dateLimite: dateLimite);

  repo.ajouter(tache);
  repo.sauvegarder();
  print('Tâche ajoutée (id: $id)');
}

void listerTaches(Repository<Tache> repo) {
  final taches = repo.tous();
  if (taches.isEmpty) {
    print('Aucune tâche.');
    return;
  }

  // Tri simple par priorité : high avant medium avant low.
  taches.sort((a, b) => b.priorite.index.compareTo(a.priorite.index));

  for (var t in taches) {
    print('[${t.id}] ${t.afficher()}');
  }
}

void terminerTache(Repository<Tache> repo, List<String> args) {
  if (args.length < 2) {
    throw DonneesInvalidesException('usage: complete <id>');
  }
  final tache = repo.trouverParId(args[1]);
  if (tache == null) {
    throw TacheIntrouvableException('id "${args[1]}"');
  }
  tache.terminee = true;
  repo.sauvegarder();
  print('Tâche terminée: ${tache.afficher()}');
}

void supprimerTache(Repository<Tache> repo, List<String> args) {
  if (args.length < 2) {
    throw DonneesInvalidesException('usage: delete <id>');
  }
  repo.supprimer(args[1]);
  repo.sauvegarder();
  print('Tâche supprimée.');
}

void afficherAide() {
  print('''
Commandes disponibles:
  add "<titre>" <low|medium|high> [AAAA-MM-JJ] [urgent]
  list
  complete <id>
  delete <id>
''');
}