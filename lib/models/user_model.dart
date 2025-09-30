class User {
  final String? id;
  final String nombre;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String sexo;
  final String correo;

  User({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.sexo,
    required this.correo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      sexo: json['sexo'] ?? '',
      correo: json['correo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'sexo': sexo,
      'correo': correo,
    };
  }

  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  User copyWith({
    String? id,
    String? nombre,
    String? apellidos,
    DateTime? fechaNacimiento,
    String? sexo,
    String? correo,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      sexo: sexo ?? this.sexo,
      correo: correo ?? this.correo,
    );
  }
}