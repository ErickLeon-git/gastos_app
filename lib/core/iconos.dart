import 'package:flutter/material.dart';

const Map<String, IconData> iconosCategoria = {
  'restaurant': Icons.restaurant,
  'directions_bus': Icons.directions_bus,
  'movie': Icons.movie,
  'favorite': Icons.favorite,
  'category': Icons.category,
};

IconData iconoDe(String nombre) => iconosCategoria[nombre] ?? Icons.category;
