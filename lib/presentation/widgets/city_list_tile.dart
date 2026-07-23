import 'package:flutter/material.dart';

import '../../domain/entities/city.dart';

/// Réutilisé pour les résultats de recherche et la liste des favoris.
class CityListTile extends StatelessWidget {
  const CityListTile({super.key, required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (city.admin1 != null && city.admin1!.isNotEmpty) city.admin1!,
      city.country,
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.location_city),
        title: Text(city.name),
        subtitle: Text(subtitleParts.join(' · ')),
        onTap: onTap,
      ),
    );
  }
}
