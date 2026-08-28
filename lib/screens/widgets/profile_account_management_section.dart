import 'package:flutter/material.dart';

class ProfileAccountManagementSection extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onOpenAdmin;
  final VoidCallback onRequestAccountDeletion;

  const ProfileAccountManagementSection({
    super.key,
    required this.isAdmin,
    required this.onOpenAdmin,
    required this.onRequestAccountDeletion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAdmin) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Administration'),
              subtitle: const Text(
                'Gérer les armées, les appréciations et les comptes',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenAdmin,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Action définitive : compte, tournois et équipes capitaine.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onRequestAccountDeletion,
          ),
        ),
      ],
    );
  }
}
