class User {
  final String? id;
  final String nombre;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String sexo;
  final String email;

  User({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.sexo,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      nombre: json['first_name'] ?? json['nombre'] ?? '',        // ← Cambio aquí
      apellidos: json['last_name'] ?? json['apellidos'] ?? '',   // ← Cambio aquí  
      fechaNacimiento: DateTime.parse(json['birth_date'] ?? json['fecha_nacimiento']), // ← Cambio aquí
      sexo: json['gender'] ?? json['sexo'] ?? '',                // ← Cambio aquí
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'sexo': sexo,
      'email': email,
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
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      sexo: sexo ?? this.sexo,
      email: email ?? this.email,
    );
  }

  String get fullName => '$nombre $apellidos';
}