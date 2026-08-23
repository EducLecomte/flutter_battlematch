import 'package:flutter/material.dart';

class ImportNewRecruitApiTab extends StatelessWidget {
  final TextEditingController tournamentIdController;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final VoidCallback onRunApiImport;

  const ImportNewRecruitApiTab({
    super.key,
    required this.tournamentIdController,
    required this.loginController,
    required this.passwordController,
    required this.onRunApiImport,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Configurez l'import direct de tournoi d'équipe.",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: tournamentIdController,
            decoration: const InputDecoration(
              labelText: "ID du Tournoi New Recruit",
              hintText: "Ex: 1234567890abcdef",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: loginController,
            decoration: const InputDecoration(
              labelText: "Nom d'utilisateur New Recruit",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mot de passe New Recruit",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRunApiImport,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text("Lancer l'importation API"),
          ),
        ],
      ),
    );
  }
}
