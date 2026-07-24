// Exceptions personnalisées utilisées dans l'application.

class TacheIntrouvableException implements Exception {
  final String message;
  TacheIntrouvableException(this.message);

  @override
  String toString() => 'Tâche introuvable : $message';
}

class DonneesInvalidesException implements Exception {
  final String message;
  DonneesInvalidesException(this.message);

  @override
  String toString() => 'Données invalides : $message';
}