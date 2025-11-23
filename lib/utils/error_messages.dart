// utils/error_messages.dart

class ErrorMessages {
  // Errores de red
  static const String noConnection = 
      'No se pudo conectar con el servidor. Por favor, verifica tu conexión a internet.';
  static const String timeout = 
      'La conexión tardó demasiado. Por favor, intenta nuevamente.';
  static const String serverError = 
      'El servidor está experimentando problemas. Por favor, intenta más tarde.';
  
  // Errores de autenticación
  static const String invalidCredentials = 
      'Correo o contraseña incorrectos. Por favor, verifica tus datos.';
  static const String sessionExpired = 
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
  static const String emailAlreadyExists = 
      'Este correo electrónico ya está registrado.';
  static const String invalidEmail = 
      'El correo electrónico no es válido.';
  static const String weakPassword = 
      'La contraseña debe tener al menos 8 caracteres.';
  
  // Errores de validación
  static const String requiredField = 
      'Este campo es obligatorio.';
  static const String invalidData = 
      'Los datos ingresados no son válidos. Por favor, verifica la información.';
  static const String notFound = 
      'No se encontró la información solicitada.';
  
  // Errores generales
  static const String unexpectedError = 
      'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
  static const String permissionDenied = 
      'No tienes permiso para realizar esta acción.';
  
  // Mensajes de éxito
  static const String loginSuccess = 
      'Inicio de sesión exitoso';
  static const String registerSuccess = 
      'Registro exitoso. ¡Bienvenido!';
  static const String dataSaved = 
      'Los datos se guardaron correctamente';
  static const String dataDeleted = 
      'Los datos se eliminaron correctamente';
  
  /// Obtiene un mensaje de error amigable basado en el código de estado HTTP
  static String fromStatusCode(int statusCode, {String? detail}) {
    switch (statusCode) {
      case 400:
        return detail ?? invalidData;
      case 401:
        return invalidCredentials;
      case 403:
        return permissionDenied;
      case 404:
        return notFound;
      case 422:
        return detail ?? invalidData;
      case 500:
      case 502:
      case 503:
        return serverError;
      default:
        return unexpectedError;
    }
  }
  
  /// Analiza el detalle del error y devuelve un mensaje más específico
  static String parseErrorDetail(dynamic detail) {
    if (detail == null) return unexpectedError;
    
    final message = detail.toString().toLowerCase();
    
    if (message.contains('email') && message.contains('already')) {
      return emailAlreadyExists;
    }
    if (message.contains('email') && message.contains('invalid')) {
      return invalidEmail;
    }
    if (message.contains('password') && (message.contains('short') || message.contains('weak'))) {
      return weakPassword;
    }
    if (message.contains('incorrect') || message.contains('wrong')) {
      return invalidCredentials;
    }
    if (message.contains('not found')) {
      return notFound;
    }
    if (message.contains('unauthorized')) {
      return sessionExpired;
    }
    
    // Si no coincide con ningún patrón conocido, devolver el mensaje original si es corto
    if (detail.toString().length < 100) {
      return detail.toString();
    }
    
    return unexpectedError;
  }
}
