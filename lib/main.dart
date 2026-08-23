// ===========================================================================
// Point d'entrée de l'application MetaWar.
// Initialise PocketBase puis affiche soit l'écran de connexion, soit le
// shell principal selon l'état d'authentification.
// ===========================================================================

import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/team_management_screen.dart';
import 'screens/tournois_screen.dart';
import 'services/pocketbase_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PocketbaseDataService.instance.ensureInitialized();
  runApp(const MetawarApp());
}

class MetawarApp extends StatelessWidget {
  const MetawarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaWar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
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
        return estAuthentifie ? const HomeShell() : const LoginScreen();
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

  static const List<Widget> _onglets = [
    TournoisScreen(),
    TeamManagementScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indexOngletActif, children: _onglets),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexOngletActif,
        onDestinationSelected: (int nouvelIndex) {
          setState(() {
            _indexOngletActif = nouvelIndex;
          });
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
}
