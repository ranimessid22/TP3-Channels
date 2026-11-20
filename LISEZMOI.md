# TP 3 – Platform Channels (tp3_channels)

ISET Bizerte · Atelier Développement Mobile Natif · SEM3 · Mme Mounira Zouaghi

Projet Flutter + Kotlin : package Android `tn.isetbizerte.tp3_channels`.

## Ouvrir et lancer (Android Studio)

1. Dézipper `tp3_channels.zip`.
2. Dans un terminal, dans le dossier `tp3_channels` :
   ```
   flutter pub get
   ```
   (cela crée `android/local.properties` avec le chemin du SDK Flutter ; indispensable
   avant d'ouvrir le dossier `android/`).
3. Android Studio → **File > Open** → dossier `tp3_channels` (fenêtre **Flutter**, code Dart).
4. Android Studio → **File > Open** → dossier `tp3_channels/android` (fenêtre **Android**, code Kotlin,
   avec autocomplétion). Attendre la synchronisation Gradle.
5. Brancher un **vrai téléphone Android** (débogage USB activé), vérifier avec `flutter devices`.
6. Lancer : `flutter run`.

> **Règle d'or** : après chaque modification du code **Kotlin**, arrêter l'application et relancer
> `flutter run`. Le hot reload ne recharge que le code Dart.

## Si un fichier de génération manque

Le dossier contient tout le code du TP. Si Flutter se plaint d'un fichier de structure manquant
(ex. `gradlew`, `.metadata`), lancer dans le dossier du projet :

```
flutter create --org tn.isetbizerte --platforms android .
```

Cette commande complète les fichiers manquants **sans écraser** ceux qui existent.

Si la synchronisation Gradle échoue sur la dépendance coroutines `1.11.0`, la remplacer par
`1.10.2` dans `android/app/build.gradle.kts`, puis *Sync Now*.

## Contenu

| Canal | Type | Kotlin | Étape |
|---|---|---|---|
| `appareil/infos` | MethodChannel | `MainActivity.kt` | Étape 1 |
| `appareil/vibrer` | MethodChannel + argument + erreur | `Vibreur.kt` | Étape 2 |
| `capteur/lumiere` | EventChannel | `CapteurLumiere.kt` | Étape 3 |
| `audio/permission` | MethodChannel (réponse différée) | `MainActivity.kt` | Étape 4a |
| `audio/niveau` | EventChannel + coroutine | `NiveauSonore.kt` | Étape 4b + Exercice 3 |
| `capteur/proximite` | EventChannel | `CapteurProximite.kt` | Exercice 1 |
| `appareil/torche` | MethodChannel + argument | `Torche.kt` | Exercice 2 |

Côté Dart : `lib/native/canaux.dart` (tous les appels natifs) et `lib/main.dart` (interface : 6 cartes).

## Points de contrôle

1. L'app s'ouvre avec « TP 3 – Platform Channels ».
2. **Lire** affiche marque, modèle, version Android.
3. court / long / sos font vibrer ; **disco** affiche `MOTIF_INCONNU`.
4. **Démarrer** (lumière) : la valeur change quand on couvre le haut du téléphone.
5. **Écouter** : demande de permission, puis la barre réagit à la voix ; le point vert du micro disparaît à l'arrêt.
6. Proximité : « Proche » / « Loin » quand on passe la main près de l'écouteur.
7. Torche : l'interrupteur allume/éteint le flash.
