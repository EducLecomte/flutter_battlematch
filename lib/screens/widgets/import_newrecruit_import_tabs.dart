import 'package:flutter/material.dart';

import 'import_newrecruit_api_tab.dart';
import 'import_newrecruit_manual_tab.dart';

class ImportNewRecruitImportTabs extends StatelessWidget {
  final TextEditingController tournamentIdController;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final TextEditingController manualTextController;
  final VoidCallback onRunApiImport;
  final VoidCallback onRunManualImport;

  const ImportNewRecruitImportTabs({
    super.key,
    required this.tournamentIdController,
    required this.loginController,
    required this.passwordController,
    required this.manualTextController,
    required this.onRunApiImport,
    required this.onRunManualImport,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.cloud_sync_outlined),
                text: "Automatique (API)",
              ),
              Tab(
                icon: Icon(Icons.paste_outlined),
                text: "Copier/Coller (Manuel)",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                ImportNewRecruitApiTab(
                  tournamentIdController: tournamentIdController,
                  loginController: loginController,
                  passwordController: passwordController,
                  onRunApiImport: onRunApiImport,
                ),
                ImportNewRecruitManualTab(
                  manualTextController: manualTextController,
                  onRunManualImport: onRunManualImport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
