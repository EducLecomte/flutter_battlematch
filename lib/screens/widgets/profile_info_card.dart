import 'package:flutter/material.dart';

/// Carte d'édition des informations personnelles du profil
/// (email en lecture seule, pseudo, initiales et bouton d'enregistrement).
class ProfileInfoCard extends StatelessWidget {
  final String email;
  final TextEditingController nomController;
  final TextEditingController shortController;
  final bool isSaving;
  final VoidCallback onSave;

  const ProfileInfoCard({
    super.key,
    required this.email,
    required this.nomController,
    required this.shortController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations personnelles",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Email : $email",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Champ Pseudo
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Pseudo / Nom complet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Champ Initiales
            TextFormField(
              controller: shortController,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Initiales (Max 6 lettres)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text("Enregistrer les modifications"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
