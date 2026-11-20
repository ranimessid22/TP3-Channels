import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'native/canaux.dart';

void main() => runApp(const MonApp());

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorSchemeLight = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5C6BC0),
      brightness: Brightness.light,
    );
    final colorSchemeDark = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7986CB),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'TP 3 – Platform Channels',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorSchemeLight,
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorSchemeLight.primaryContainer,
          foregroundColor: colorSchemeLight.onPrimaryContainer,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorSchemeLight.onPrimaryContainer,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: colorSchemeDark,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorSchemeDark.surfaceContainerHighest,
          foregroundColor: colorSchemeDark.onSurfaceVariant,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorSchemeDark.onSurfaceVariant,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const PageCanaux(),
    );
  }
}

class PageCanaux extends StatefulWidget {
  const PageCanaux({super.key});

  @override
  State<PageCanaux> createState() => _PageCanauxState();
}

class _PageCanauxState extends State<PageCanaux> {
  // Étape 1
  Map<String, dynamic>? _infosMap;
  // Étape 3
  double? _lux;
  StreamSubscription<double>? _abonnementLumiere;
  // Étape 4
  double? _db;
  StreamSubscription<double>? _abonnementAudio;
  // Exercice 1
  bool? _proche;
  StreamSubscription<bool>? _abonnementProximite;
  // Exercice 2
  bool _torche = false;

  void _message(String texte) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texte),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  // ---------- Étape 1 ----------
  Future<void> _lireInfos() async {
    final i = await CanauxNatifs.lireInfos();
    setState(() => _infosMap = i);
  }

  // ---------- Étape 2 ----------
  Future<void> _vibrer(String motif) async {
    try {
      await CanauxNatifs.vibrer(motif);
      _message('Vibration « $motif »');
    } on PlatformException catch (e) {
      _message('Erreur ${e.code} : ${e.message}');
    }
  }

  // ---------- Étape 3 ----------
  void _basculerLumiere() {
    if (_abonnementLumiere == null) {
      _abonnementLumiere = CanauxNatifs.lumiere().listen(
        (lux) => setState(() => _lux = lux),
        onError: (e) => _message('Capteur : ${(e as PlatformException).message}'),
      );
    } else {
      _abonnementLumiere!.cancel();
      _abonnementLumiere = null;
    }
    setState(() {});
  }

  // ---------- Étape 4 ----------
  Future<void> _basculerMicro() async {
    if (_abonnementAudio != null) {
      await _abonnementAudio!.cancel();
      setState(() => _abonnementAudio = null);
      return;
    }
    final accordee = await CanauxNatifs.demanderMicro();
    if (!accordee) {
      _message('Permission micro refusée');
      return;
    }
    setState(() {
      _abonnementAudio = CanauxNatifs.niveauSonore().listen(
        (db) => setState(() => _db = db),
        onError: (e) => _message('Micro : ${(e as PlatformException).message}'),
      );
    });
  }

  // ---------- Exercice 1 ----------
  void _basculerProximite() {
    if (_abonnementProximite == null) {
      _abonnementProximite = CanauxNatifs.proximite().listen(
        (proche) => setState(() => _proche = proche),
        onError: (e) => _message('Proximité : ${(e as PlatformException).message}'),
      );
    } else {
      _abonnementProximite!.cancel();
      _abonnementProximite = null;
    }
    setState(() {});
  }

  // ---------- Exercice 2 ----------
  Future<void> _changerTorche(bool etat) async {
    try {
      await CanauxNatifs.allumerTorche(etat);
      setState(() => _torche = etat);
    } on PlatformException catch (e) {
      _message('Erreur ${e.code} : ${e.message}');
    }
  }

  @override
  void dispose() {
    _abonnementLumiere?.cancel();
    _abonnementAudio?.cancel();
    _abonnementProximite?.cancel();
    super.dispose();
  }

  Widget _carte({
    required String titre,
    required IconData icone,
    required List<Widget> contenu,
    Color? couleurIcone,
  }) {
    final theme = Theme.of(context);
    final color = couleurIcone ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...contenu,
          ],
        ),
      ),
    );
  }

  IconData _getIconForMotif(String m) {
    switch (m) {
      case 'court':
        return Icons.bolt;
      case 'long':
        return Icons.waves;
      case 'sos':
        return Icons.warning_amber_rounded;
      case 'disco':
        return Icons.music_note;
      default:
        return Icons.vibration;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TP 3 – Platform Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'TP 3 – Platform Channels',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Application Flutter de démonstration des canaux natifs Android.'),
                ],
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Infos appareil
          _carte(
            titre: '1. Infos appareil (MethodChannel)',
            icone: Icons.phone_android,
            couleurIcone: Colors.blue.shade700,
            contenu: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _infosMap == null
                    ? Text(
                        'Appuyez sur le bouton pour lire les informations',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.smartphone,
                            'Appareil',
                            '${_infosMap!['marque'] ?? ''} ${_infosMap!['modele'] ?? ''}',
                            Colors.blue.shade700,
                          ),
                          _buildInfoRow(
                            Icons.android,
                            'Version Android',
                            'Android ${_infosMap!['version'] ?? ''}',
                            Colors.green.shade700,
                          ),
                          _buildInfoRow(
                            Icons.code,
                            'Niveau SDK (API)',
                            'API ${_infosMap!['sdk'] ?? ''}',
                            Colors.deepPurple.shade700,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _lireInfos,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Lire les infos'),
              ),
            ],
          ),

          // 2. Vibration
          _carte(
            titre: '2. Vibration (arguments + erreurs)',
            icone: Icons.vibration,
            couleurIcone: Colors.orange.shade700,
            contenu: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in ['court', 'long', 'sos', 'disco'])
                    FilledButton.tonalIcon(
                      onPressed: () => _vibrer(m),
                      icon: Icon(_getIconForMotif(m), size: 18),
                      label: Text(m),
                    ),
                ],
              ),
            ],
          ),

          // 3. Capteur de lumière
          _carte(
            titre: '3. Capteur de lumière (EventChannel)',
            icone: Icons.light_mode,
            couleurIcone: Colors.amber.shade700,
            contenu: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _lux == null ? '—' : '${_lux!.toStringAsFixed(0)} lux',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _lux != null ? Colors.amber.shade800 : null,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _basculerLumiere,
                    style: FilledButton.styleFrom(
                      backgroundColor: _abonnementLumiere == null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    icon: Icon(
                      _abonnementLumiere == null ? Icons.play_arrow : Icons.stop,
                      size: 18,
                    ),
                    label: Text(_abonnementLumiere == null ? 'Démarrer' : 'Arrêter'),
                  ),
                ],
              ),
            ],
          ),

          // 4. Niveau sonore
          _carte(
            titre: '4. Niveau sonore (permission + coroutine)',
            icone: Icons.mic,
            couleurIcone: Colors.red.shade700,
            contenu: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _db == null ? '—' : '${_db!.toStringAsFixed(1)} dBFS',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _db != null ? Colors.red.shade700 : null,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _basculerMicro,
                    style: FilledButton.styleFrom(
                      backgroundColor: _abonnementAudio == null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    icon: Icon(
                      _abonnementAudio == null ? Icons.mic : Icons.stop,
                      size: 18,
                    ),
                    label: Text(_abonnementAudio == null ? 'Écouter' : 'Arrêter'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (((_db ?? -90) + 90) / 90).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),

          // 5. Capteur de proximité
          _carte(
            titre: '5. Exercice 1 – Capteur de proximité',
            icone: Icons.sensors,
            couleurIcone: Colors.purple.shade700,
            contenu: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _proche == null
                            ? Icons.help_outline
                            : (_proche! ? Icons.near_me : Icons.explore_outlined),
                        color: _proche == null
                            ? Colors.grey
                            : (_proche! ? Colors.green : Colors.blue),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _proche == null ? '—' : (_proche! ? 'Proche' : 'Loin'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _proche == null
                              ? null
                              : (_proche! ? Colors.green.shade700 : Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: _basculerProximite,
                    style: FilledButton.styleFrom(
                      backgroundColor: _abonnementProximite == null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    icon: Icon(
                      _abonnementProximite == null ? Icons.play_arrow : Icons.stop,
                      size: 18,
                    ),
                    label: Text(_abonnementProximite == null ? 'Démarrer' : 'Arrêter'),
                  ),
                ],
              ),
            ],
          ),

          // 6. Lampe torche
          _carte(
            titre: '6. Exercice 2 – Lampe torche',
            icone: _torche ? Icons.flashlight_on : Icons.flashlight_off,
            couleurIcone: _torche ? Colors.amber.shade900 : Colors.grey.shade700,
            contenu: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  _torche ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: _torche ? Colors.amber.shade700 : Colors.grey,
                  size: 28,
                ),
                title: Text(
                  _torche ? 'Torche allumée' : 'Torche éteinte',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(_torche ? 'La LED de l’appareil est activée' : 'Appuyez pour activer la LED'),
                value: _torche,
                onChanged: _changerTorche,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
