import 'package:flutter/services.dart';

/// Point d'accès unique au code natif Kotlin.
class CanauxNatifs {
  // Étape 1
  static const _infos = MethodChannel('appareil/infos'); // même nom qu'en Kotlin
  // Étape 2
  static const _vibreur = MethodChannel('appareil/vibrer');
  // Étape 3
  static const _lumiere = EventChannel('capteur/lumiere');
  // Étape 4
  static const _permission = MethodChannel('audio/permission');
  static const _audio = EventChannel('audio/niveau');
  // Exercice 1
  static const _proximite = EventChannel('capteur/proximite');
  // Exercice 2
  static const _torche = MethodChannel('appareil/torche');

  // ---------- Étape 1 : MethodChannel ----------
  static Future<Map<String, dynamic>> lireInfos() async {
    final infos = await _infos.invokeMapMethod<String, dynamic>('lire');
    return infos ?? {};
  }

  // ---------- Étape 2 : MethodChannel avec argument ----------
  static Future<void> vibrer(String motif) =>
      _vibreur.invokeMethod('vibrer', {'motif': motif}); // arguments = un Map

  // ---------- Étape 3 : EventChannel ----------
  static Stream<double> lumiere() =>
      _lumiere.receiveBroadcastStream().map((v) => (v as num).toDouble());

  // ---------- Étape 4 : permission + flux audio ----------
  static Future<bool> demanderMicro() async =>
      await _permission.invokeMethod<bool>('demander') ?? false;

  static Stream<double> niveauSonore() =>
      _audio.receiveBroadcastStream().map((v) => (v as num).toDouble());

  // ---------- Exercice 1 : proximité ----------
  /// true = un objet est proche, false = loin.
  static Stream<bool> proximite() =>
      _proximite.receiveBroadcastStream().map((v) => v as bool);

  // ---------- Exercice 2 : torche ----------
  static Future<void> allumerTorche(bool etat) =>
      _torche.invokeMethod('allumer', {'etat': etat});
}
