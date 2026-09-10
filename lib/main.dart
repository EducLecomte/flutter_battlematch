// ===========================================================================
// Point d'entrée de l'application MetaWar.
// Initialise PocketBase puis affiche soit l'écran de connexion, soit le
// shell principal selon l'état d'authentification.
// ===========================================================================

import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/refreshable_screen.dart';
import 'screens/team_management_screen.dart';
import 'screens/tournois_screen.dart';
import 'screens/widgets/tutoriel_gate.dart';
import 'services/pocketbase_data_service.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.init();
  await PocketbaseDataService.instance.ensureInitialized();
  runApp(const MetawarApp());
}

class MetawarApp extends StatelessWidget {
  const MetawarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le mode clair/sombre (MEMO 11) est un état global modifié depuis le
    // profil : on réécoute le contrôleur pour re-générer le MaterialApp avec
    // le [ThemeMode] courant.
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: applicationName,
          themeMode: ThemeController.instance.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Passe automatiquement entre l'écran de connexion et le shell principal
/// en écoutant les changements d'authentification de PocketBase.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PocketbaseDataService.instance.authStateChanges,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool estAuthentifie = snapshot.data ?? false;
        return estAuthentifie
            ? const TutorielGate(child: HomeShell())
            : const LoginScreen();
      },
    );
  }
}

/// Shell principal : barre de navigation entre Tournois, Équipes et Profil.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indexOngletActif = 0;

  // Clés d'accès aux screens : elles permettent au shell de déclencher un
  // rafraîchissement des données de l'écran qui devient actif (voir
  // RefreshableScreenState).
  final GlobalKey<RefreshableScreenState<TournoisScreen>> _keyTournois =
      GlobalKey();
  final GlobalKey<RefreshableScreenState<TeamManagementScreen>> _keyEquipes =
      GlobalKey();
  final GlobalKey<RefreshableScreenState<ProfileScreen>> _keyProfil =
      GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indexOngletActif,
        children: [
          TournoisScreen(key: _keyTournois),
          TeamManagementScreen(key: _keyEquipes),
          ProfileScreen(key: _keyProfil),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexOngletActif,
        onDestinationSelected: (int nouvelIndex) {
          setState(() {
            _indexOngletActif = nouvelIndex;
          });
          _rafraichirOngletActif(nouvelIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Tournois',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Équipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // Recharge les données de l'écran qui vient de devenir actif dans la
  // barre de navigation du bas.
  void _rafraichirOngletActif(int index) {
    switch (index) {
      case 0:
        _keyTournois.currentState?.refreshOnTabActivated();
        break;
      case 1:
        _keyEquipes.currentState?.refreshOnTabActivated();
        break;
      case 2:
        _keyProfil.currentState?.refreshOnTabActivated();
    }
  }
}
