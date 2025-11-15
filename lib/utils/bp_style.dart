import 'package:flutter/material.dart';

class BpVisual {
  final String label;
  final Color color;
  const BpVisual(this.label, this.color);
}

BpVisual bpVisualFromCategory(String? category) {
  final key = (category ?? '').toUpperCase();
  switch (key) {
    case 'NORMAL':
      return const BpVisual('NORMAL', Color(0xFF22C55E)); // verde
    case 'ELEVADO': // ← coincide con backend
      return const BpVisual('ELEVADA', Color.fromARGB(255, 227, 204, 0)); // etiqueta mostrada
    case 'PREHIPERTENSION':
      return const BpVisual('PREHIPERTENSIÓN', Color(0xFFFB923C)); // naranja
    case 'HIPERTENSION':
      return const BpVisual('HIPERTENSIÓN', Color(0xFFEF4444)); // rojo
    default:
      return const BpVisual('—', Colors.grey);
  }
}