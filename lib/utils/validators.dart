import '../utils/constants.dart';

class Validators {
  // Validador de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    
    if (!RegExp(Constants.emailPattern).hasMatch(value)) {
      return 'Por favor ingresa un correo electrónico válido';
    }
    
    return null;
  }

  // Validador de contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    
    if (value.length < Constants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${Constants.minPasswordLength} caracteres';
    }
    
    return null;
  }

  // Validador de confirmación de contraseña
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    
    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // Validador de nombre
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    
    if (value.length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  // Validador de peso
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu peso';
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Por favor ingresa un peso válido';
    }
    
    if (weight < 20 || weight > 300) {
      return 'El peso debe estar entre 20 y 300 kg';
    }
    
    return null;
  }

  // Validador de altura
  static String? height(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu altura';
    }
    
    final height = double.tryParse(value);
    if (height == null) {
      return 'Por favor ingresa una altura válida';
    }
    
    if (height < 100 || height > 250) {
      return 'La altura debe estar entre 100 y 250 cm';
    }
    
    return null;
  }

  // Validador de días de estrés
  static String? stressDays(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el número de días';
    }
    
    final days = int.tryParse(value);
    if (days == null) {
      return 'Por favor ingresa un número válido';
    }
    
    if (days < 0 || days > 30) {
      return 'Los días deben estar entre 0 y 30';
    }
    
    return null;
  }

  // Validador de dropdown requerido
  static String? requiredDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona $fieldName';
    }
    
    return null;
  }

  // Validador de fecha de nacimiento
  static String? birthDate(DateTime? date) {
    if (date == null) {
      return 'Por favor selecciona tu fecha de nacimiento';
    }
    
    final now = DateTime.now();
    final age = now.year - date.year;
    
    if (age < 18) {
      return 'Debes ser mayor de 18 años';
    }
    
    if (age > 120) {
      return 'Por favor ingresa una fecha válida';
    }
    
    return null;
  }

  // Validador de código de verificación
  static String? verificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el código de verificación';
    }
    
    if (value.length < 4 || value.length > 8) {
      return 'El código debe tener entre 4 y 8 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El código solo debe contener números';
    }
    
    return null;
  }
}