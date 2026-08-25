import 'package:flutter/material.dart';

import '../../config/app_config.dart';

class ConfidenceStarIcon extends StatelessWidget {
  static const double defaultIconSize = 12;

  final String confidenceLevel;
  final double iconSize;

  const ConfidenceStarIcon({
    super.key,
    required this.confidenceLevel,
    this.iconSize = defaultIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final IconData starIcon;
    final Color starColor;

    switch (confidenceLevel) {
      case estimConfianceFaible:
        starIcon = Icons.star_border;
        starColor = Colors.red;
      case estimConfianceEleve:
        starIcon = Icons.star;
        starColor = Colors.green;
      default:
        starIcon = Icons.star_half;
        starColor = Colors.amber;
    }

    return Icon(starIcon, size: iconSize, color: starColor);
  }
}
