import 'package:flutter/material.dart';

/// Indicateur de chargement affiché pendant un flux d'import
/// (spinner centré + texte de statut).
class ImportNewRecruitLoadingIndicator extends StatelessWidget {
  final String statusText;

  const ImportNewRecruitLoadingIndicator({
    super.key,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
