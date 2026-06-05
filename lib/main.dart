// main.dart
//
// AURA — app entry + root shell. Wires Provider (DataStore, PlayerModel,
// DynamicColor), the 4 tabs, the floating fused chrome, the full-screen
// player sheet, and an in-app toast. Dark-first.
//
// NOTE: reference code, not run through the compiler. Run `flutter pub
// get`, drop real artwork in assets/artwork/, then `flutter run`. Wire
// PlayerModel to a real audio engine (just_audio / video_player).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/audio_manager.dart';
import 'core/background_audio.dart';
import 'core/dynamic_color.dart';
import 'data/models.dart';
import 'data/player_model.dart';
import 'data/store.dart';
import 'theme/tokens.dart';
import 'widgets/artwork.dart';
import 'widgets/buttons.dart';
import 'widgets/common.dart';
import 'widgets/icons.dart';
import 'screens/browser_screen.dart';
import 'screens/chrome.dart';
import 'screens/discovery_screen.dart';
import 'screens/library_screen.dart';
import 'screens/player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackgroundAudio();
  final store = DataStore();
  final audio = AudioManager();
  await audio.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<DataStore>.value(value: store),
        ChangeNotifierProvider(create: (_) => PlayerModel(queue: store.queue, audio: audio)),
        ChangeNotifierProvider(create: (_) => DynamicColor()),
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.bg,
          primary: AppColors.accent,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  String _tab = 'library';
  OverlayEntry? _toast;

  @override
  void initState() {
    super.initState();
    // Keep the dynamic colour synced to the playing track (chrome + player).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncColor());
  }

  PlayerModel get _player => context.read<PlayerModel>();
  DynamicColor get _dyn => context.read<DynamicColor>();
  String _lastArt = '';

  void _syncColor() {
    final art = _player.current.art;
    if (art != _lastArt) {
      _lastArt = art;
      _dyn.update(artProvider(art), art);
    }
  }

  void _openPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 1,
        child: PlayerScreen(onClose: () => Navigator.pop(context)),
      ),
    );
  }

  void _play(Track t) {
    _player.play(t);
    _syncColor();
    _openPlayer();
  }

  void _flash(String message, {String? icon}) {
    _toast?.remove();
    _toast = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 160,
        child: IgnorePointer(child: Center(child: Toast(message, icon: icon))),
      ),
    );
    Overlay.of(context).insert(_toast!);
    Future.delayed(const Duration(milliseconds: 2200), () {
      _toast?.remove();
      _toast = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild colour sync whenever the track changes.
    context.watch<PlayerModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncColor());
    final store = context.read<DataStore>();

    Widget body;
    switch (_tab) {
      case 'browser':
        body = BrowserScreen(onPlay: _play, onToast: (m) => _flash(m, icon: 'download'));
      case 'discovery':
        body = DiscoveryScreen(onPlay: _play, onToast: (m) => _flash(m, icon: 'download'));
      default:
        body = LibraryScreen(onPlay: _play, onMenu: _openContextMenu);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: SafeArea(bottom: false, child: body)),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom,
            child: FusedChrome(
              tab: _tab,
              onTab: (id) {
                if (id == 'player') {
                  _openPlayer();
                } else {
                  setState(() => _tab = id);
                }
              },
              onOpenPlayer: _openPlayer,
              downloadsBadge: store.downloadsBadge,
            ),
          ),
        ],
      ),
    );
  }

  void _openContextMenu(Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) {
        final rows = [
          ('queue', 'Lire ensuite'),
          ('plus', 'Ajouter à une playlist'),
          ('download', 'Télécharger'),
          ('share', 'Partager'),
        ];
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: Row(children: [
                  Artwork(track.art, size: 46, radius: 9),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(track.title, style: AppText.trackTitle.copyWith(fontSize: 16)),
                    Text(track.artist, style: AppText.subtitle.copyWith(fontSize: 13)),
                  ]),
                ]),
              ),
              for (final r in rows)
                Pressable(
                  onTap: () {
                    Navigator.pop(context);
                    _flash(r.$2 == 'Télécharger' ? 'Téléchargement lancé' : r.$2,
                        icon: r.$1 == 'download' ? 'download' : r.$1 == 'share' ? 'share' : 'check');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.separator, width: 0.5))),
                    child: Row(children: [
                      AppIcon(r.$1, size: 20, color: AppColors.accent),
                      const SizedBox(width: 14),
                      Text(r.$2, style: AppText.trackTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w400)),
                    ]),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
