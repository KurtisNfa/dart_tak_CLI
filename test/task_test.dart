import 'dart:io';

import 'package:task_cli/exceptions.dart';
import 'package:task_cli/models.dart';
import 'package:task_cli/repository.dart';
import 'package:test/test.dart';

void main() {
  test('une tâche normale affiche son titre', () {
    final tache = TacheNormale(id: '1', titre: 'Faire les courses', priorite: Priorite.low);
    expect(tache.afficher(), contains('Faire les courses'));
  });

  test('une tâche urgente affiche le mot URGENT', () {
    final tache = TacheUrgente(id: '2', titre: 'Corriger le bug', priorite: Priorite.high);
    expect(tache.afficher(), contains('URGENT'));
  });

  test('un titre vide déclenche une DonneesInvalidesException', () {
    expect(
      () => TacheNormale(id: '3', titre: '', priorite: Priorite.medium),
      throwsA(isA<DonneesInvalidesException>()),
    );
  });

  test('priorieDepuisTexte lève une exception pour un texte inconnu', () {
    expect(() => priorieDepuisTexte('extreme'),
        throwsA(isA<DonneesInvalidesException>()));
  });

  test('le repository sauvegarde puis recharge les tâches depuis le JSON', () {
    final chemin = 'test_taches.json';
    final repo = Repository<Tache>(chemin);
    repo.ajouter(TacheNormale(id: '10', titre: 'Réviser', priorite: Priorite.medium));
    repo.sauvegarder();

    final repo2 = Repository<Tache>(chemin);
    repo2.charger();

    expect(repo2.tous().length, 1);
    expect(repo2.trouverParId('10')?.titre, 'Réviser');

    File(chemin).deleteSync(); // nettoyage
  });

  test('supprimer() lève TacheIntrouvableException si l\'id n\'existe pas', () {
    final repo = Repository<Tache>('inexistant.json');
    expect(() => repo.supprimer('999'), throwsA(isA<TacheIntrouvableException>()));
  });
}