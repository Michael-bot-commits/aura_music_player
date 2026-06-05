# CONTEXTE PROJET — AURA Media Player
# Fichier de passation pour Claude Code (autre instance)
# Généré le : 2026-06-04

---

## PROJET

**Nom :** AURA Media Player
**Type :** Application Flutter / Dart · iOS-first (Android en secondaire)
**Environnement :** VSCode sur Ubuntu
**Répertoire de travail :** `/home/michael/Documents/music_player/music_player`

L'application est un lecteur multimédia tout-en-un comprenant :
- Un navigateur web intégré qui détecte et capture les médias
- Une bibliothèque locale (musique + vidéo)
- Un écran Découverte (multi-sources : Deezer, SoundCloud, Jamendo)
- Un gestionnaire de téléchargements
- Un player plein écran immersif
- **Mécanique signature : couleur dynamique** — la couleur dominante de la pochette teinte toute l'interface en temps réel (crossfade 600ms)

**Design keywords :** épuré · premium · immersif · dark-first · frosted glass · couleur dynamique · minimal · coral accent (#FF6E72)

---

## RÈGLES DE COLLABORATION — OBLIGATOIRES ET PERMANENTES

Ces 4 règles ont été imposées par l'utilisateur. Elles doivent être respectées à la lettre du début à la fin du projet :

1. **Rapport détaillé avant toute avance** : Ne jamais passer à l'étape suivante sans avoir fourni un rapport/résumé DÉTAILLÉ de ce qui vient d'être réalisé, ET confirmé qu'il n'y a AUCUNE erreur de compilation (`flutter analyze → No issues found`).

2. **Autorisation explicite avant chaque nouvelle étape** : Toujours demander une confirmation/autorisation de l'utilisateur avant de commencer l'étape suivante. Ne jamais enchaîner deux étapes de sa propre initiative.

3. **Signaler les tâches [TOI] et [JAMAIS CC]** : À chaque fois qu'une tâche dans le fichier `SUIVI_INGENIEUR.md` est marquée `[TOI]` ou `[JAMAIS CC]`, la signaler clairement à l'utilisateur avec les commandes exactes à exécuter. Attendre sa confirmation avant de continuer.

4. **Respect intégral du début à la fin** : Ces règles ne souffrent d'aucune exception, d'aucun raccourci.

---

## FICHIERS SOURCE DE RÉFÉRENCE

Le design handoff complet se trouve dans :
- **ZIP extrait :** `/tmp/aura_handoff/design_handoff_aura_flutter/`
- **ZIP original :** `design_handoff_aura_flutter-20260604T193506Z-3-001.zip` (dans le répertoire de travail)

Fichiers clés du handoff :
- `README.md` — brief technique complet
- `CLAUDE_CODE_PROMPT.md` — prompt d'implémentation Flutter détaillé (14 étapes)
- `SUIVI_INGENIEUR.md` — journal de suivi avec tâches [TOI] / [CC] / [JAMAIS CC]
- `screenshots/` — 9 screenshots de référence visuelle (01 à 09)
- `prototype/` — prototype HTML/JS interactif (vérité visuelle absolue)
- `flutter/lib/` — code Dart de référence (blueprint)

---

## STRUCTURE DU PROJET (état actuel)

```
music_player/
├── pubspec.yaml              ← dépendances installées
├── lib/
│   ├── main.dart             ← entry + RootShell + AudioManager init
│   ├── core/
│   │   ├── audio_manager.dart    ← CRÉÉ à l'étape 3 (just_audio)
│   │   └── dynamic_color.dart   ← NE PAS MODIFIER
│   ├── data/
│   │   ├── models.dart      ← Track (avec streamUrl, filePath ajoutés)
│   │   ├── player_model.dart ← RÉÉCRIT étape 3 (Timer→just_audio streams)
│   │   └── store.dart       ← 12 tracks avec URLs SoundHelix de démo
│   ├── theme/
│   │   └── tokens.dart      ← NE PAS MODIFIER
│   ├── widgets/
│   │   ├── icons.dart       ← NE PAS MODIFIER (SVG paths)
│   │   ├── artwork.dart
│   │   ├── buttons.dart
│   │   ├── common.dart
│   │   ├── scrubber.dart
│   │   └── progress_ring.dart
│   └── screens/
│       ├── chrome.dart           ← FusedChrome (MiniPlayer + TabBar)
│       ├── player_screen.dart    ← Player plein écran
│       ├── player_subviews.dart  ← LyricsView + QueueView
│       ├── library_screen.dart   ← Bibliothèque
│       ├── downloads_screen.dart ← Téléchargements
│       ├── browser_screen.dart   ← Browser + InterceptSheet
│       └── discovery_screen.dart ← Découverte + ArtistPageView
├── assets/
│   └── artwork/
│       └── [12 fichiers .jpg placeholder colorés]
└── test/
    └── widget_test.dart     ← placeholder simple
```

---

## DÉPENDANCES INSTALLÉES (pubspec.yaml)

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.2           # state management
  google_fonts: ^6.2.1       # Inter (SF Pro substitute)
  palette_generator: ^0.3.3  # extraction couleur dominante
  path_drawing: ^1.0.1       # rendu SVG icons
  just_audio: ^0.9.36        # lecture audio réelle (étape 3)
  audio_session: ^0.1.18     # configuration session audio (étape 3)
```

---

## FICHIERS À NE JAMAIS MODIFIER

- `lib/theme/tokens.dart` — tokens couleurs, typo, spacing, motion
- `lib/core/dynamic_color.dart` — extraction couleur dominante
- `lib/widgets/icons.dart` — paths SVG custom (sauf imports manquants)

---

## ÉTAT DES ÉTAPES

### ✅ ÉTAPE 1 — Setup projet Flutter (TERMINÉE)
- Projet Flutter existant réutilisé (pas de `flutter create`)
- Tous les fichiers `flutter/lib/` du handoff copiés dans `lib/`
- `pubspec.yaml` mis à jour avec les 4 dépendances initiales
- `assets/artwork/` créé avec 12 images JPG placeholder (couleurs unies)
- 4 erreurs de compilation corrigées (imports manquants, test obsolète)
- 17 warnings `withOpacity` → `withValues(alpha:)` corrigés
- **Résultat :** `flutter analyze → No issues found`

### ✅ ÉTAPE 2 — Intégration fichiers design (TERMINÉE)
- Revue complète de tous les fichiers Dart vs screenshots de référence
- Tous les 9 écrans vérifiés code ↔ screenshots (01 à 09)
- **Validation utilisateur :** Tests visuels sur Chrome concluants ✅
- **Résultat :** `flutter analyze → No issues found`

### ✅ ÉTAPE 3 — Câblage just_audio (TERMINÉE — EN ATTENTE VALIDATION)
- `just_audio: ^0.9.46` + `audio_session: ^0.1.25` installés
- `Track` model : ajout `streamUrl?` et `filePath?`
- `DataStore` : 12 tracks avec URLs SoundHelix (public domain, CC0)
- `lib/core/audio_manager.dart` créé (loadTrack, play, pause, seek, volume, streams)
- `PlayerModel` réécrit : Timer supprimé, câblé sur streams just_audio
- `main.dart` : `AudioManager` initialisé async avant `runApp`
- **Résultat :** `flutter analyze → No issues found`
- **En attente :** Validation utilisateur sur Android/iOS (CORS bloque les URLs sur Chrome)

### ⏳ ÉTAPE 4 — Background audio + Control Center iOS (À FAIRE)
**[TOI] :** Ajouter `just_audio_background: ^0.0.1-beta.10` dans pubspec.yaml
**[TOI] :** Modifier `ios/Runner/Info.plist` (UIBackgroundModes: audio, fetch)
**[TOI] :** Modifier `android/app/src/main/AndroidManifest.xml` (FOREGROUND_SERVICE)
**[CC] :** Créer `lib/core/background_audio.dart`
**Validation :** Verrouiller écran → audio continue + Control Center iOS

### ⏳ ÉTAPE 5 — Player plein écran complet (À FAIRE)
**[CC] :** Vérifier tous les éléments PlayerScreen câblés avec vrai PlayerModel
**Validation :** Scrubber drag, DynamicColor, AnimatedSwitcher, Shuffle/Repeat, Heart

### ⏳ ÉTAPE 6 — Bibliothèque locale réelle (À FAIRE)
**[CC] :** Lire fichiers audio/vidéo dans app documents via path_provider
**Validation :** Bibliothèque affiche vrais fichiers, lecture au tap

### ⏳ ÉTAPE 7 — Base de données sqflite (À FAIRE)
**[TOI] :** Ajouter `sqflite: ^2.3.2`, `path: ^1.9.0`, `path_provider: ^2.1.2`
**[CC] :** Créer `lib/data/database.dart` (tables tracks, playlists, playlist_tracks)
**Validation :** Données persistent entre sessions

### ⏳ ÉTAPE 8 — Browser avec webview_flutter réel (À FAIRE)
**[TOI] :** Ajouter `webview_flutter: ^4.7.0`
**[TOI] :** Modifier `ios/Runner/Info.plist` (NSAppTransportSecurity)
**[CC] :** Remplacer simulation par WebViewController + injection JS détection médias
**Validation :** YouTube dans browser → InterceptSheet apparaît

### ⏳ ÉTAPE 9 — Backend service + Download manager (À FAIRE)
**[CC] :** Créer `lib/services/backend_service.dart` + `download_manager.dart`
**Note :** Backend Python (Partie 2 du projet) doit être lancé séparément
**Validation :** Téléchargement avec ProgressRing, badge TabBar

### ⏳ ÉTAPE 10 — Deezer API (À FAIRE)
**[TOI] :** Obtenir clé API Deezer (developers.deezer.com — gratuit)
**[CC] :** Créer `lib/services/deezer_service.dart`
**Validation :** Recherche réelle, aperçu 30s, fiche artiste

### ⏳ ÉTAPE 11 — SoundCloud + Jamendo + Last.fm (À FAIRE)
**[TOI] :** Clés API SoundCloud, Jamendo, Last.fm
**[CC] :** Créer les 3 services correspondants
**Validation :** Résultats groupés multi-sources

### ⏳ ÉTAPE 12 — Pochettes automatiques (À FAIRE)
**[TOI] :** Ajouter `cached_network_image: ^3.3.1`
**[CC] :** Créer `lib/services/musicbrainz_service.dart`
**Logique :** MusicBrainz → miniature YouTube → placeholder

### ⏳ ÉTAPE 13 — Paroles (À FAIRE)
**[CC] :** Créer `lib/services/lrclib_service.dart` + `genius_service.dart`
**[TOI] :** Clé API Genius (genius.com/api-clients — gratuit)
**Validation :** Paroles synchronisées dans LyricsView

### ⏳ ÉTAPE 14 — Polish et stabilisation (À FAIRE)
**[CC] :** Mode offline, animations finales, 0 régression
**Validation :** `flutter analyze → 0 erreur`, 60fps sur device réel

---

## CLÉS API À OBTENIR (étapes 10-13)

| Service | URL | Clé requise |
|---|---|---|
| Deezer | developers.deezer.com | ✅ Gratuit |
| Last.fm | last.fm/api | ✅ Gratuit |
| SoundCloud | developers.soundcloud.com | ✅ Gratuit |
| Jamendo | developer.jamendo.com | ✅ Gratuit |
| Genius | genius.com/api-clients | ✅ Gratuit |
| LRCLIB | lrclib.net | ❌ Pas de clé |
| MusicBrainz | musicbrainz.org | ❌ Pas de clé |

---

## TOKENS VISUELS IMPORTANTS (ne jamais modifier)

```dart
// Accent unique
AppColors.accent = Color(0xFFFF6E72)  // Coral

// Surfaces dark
AppColors.bg  = Color(0xFF000000)
AppColors.bg2 = Color(0xFF1C1C1E)
AppColors.bg3 = Color(0xFF2C2C2E)

// Motion
Motion.dynamicColor = 600ms  // crossfade couleur dynamique
Motion.base = 240ms
Motion.spring = Cubic(0.34, 1.2, 0.64, 1)  // scale artwork

// Frosted glass
BackdropFilter(ImageFilter.blur(sigmaX: 24, sigmaY: 24))
Glass.fill = Color(0x8C28282C)
```

---

## ÉTAT ACTUEL — CE QUI EST EN ATTENTE

L'utilisateur doit valider l'**Étape 3** en testant sur Android ou un appareil physique :
- Tap sur une piste → lecture audio réelle
- Barre de progression avance en temps réel
- Play/pause fonctionne
- Piste suivante au tap → démarre
- AnimatedScale artwork (1.0 ↔ 0.82)
- Timestamps corrects

Une fois l'Étape 3 validée, la prochaine étape est l'**Étape 4 (Background audio)**.

---

*Ce fichier peut être supprimé une fois que l'autre instance Claude Code a le contexte.*
