class Constants {
  static const String appName = 'aTensión';
  //static const String baseUrl = 'http://localhost:8000/api'; // Cambia por tu URL de FastAPI
  // URL base del backend (SIN /api al final)
  //static const String baseUrl = 'http://127.0.0.1:8000';
  static const String baseUrl = 'http://192.168.1.38:8000';
  //static const String baseUrl = 'http://10.148.228.11:8000';
  //static const String baseUrl = 'http://10.139.134.80:8000';
  static const String apiV1 = '/api/v1';
  
  // Endpoints de autenticación
  static const String loginEndpoint = '$apiV1/auth/token';
  static const String registerEndpoint = '$apiV1/users/';
  static const String userMeEndpoint = '$apiV1/auth/me';           // ← AÑADIR
  static const String resetPasswordEndpoint = '$apiV1/auth/reset-password';
  
  // Endpoints de evaluaciones
  static const String evaluationEndpoint = '$apiV1/evaluations/';
  static const String historyEndpoint = '$apiV1/evaluations/';  // Sin /history
  
  // Health check
  static const String healthEndpoint = '/health';
  
  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';  // ← Debe existir esta línea
  static const String userKey = 'user_data';
  
  // Headers comunes
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };
  
  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Validation (mantener lo existente)
  static const int minPasswordLength = 8;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Messages (mantener lo existente)
  static const String welcomeMessage = '¡Bienvenido!';
  static const String evaluationInstructions = 
      'Esta evaluación busca realizar una valoración del riesgo de desarrollar '
      'Hipertensión Arterial. Se pide responder las preguntas con sinceridad '
      'para que el resultado sea lo más preciso posible.';
  
  static const String disclaimerText = 
      'Recuerde que este es un análisis preliminar y no sustituye la consulta '
      'con un profesional de la salud.';
      
  static const String hypertensionInfo = 
      'La Hipertensión Arterial (HTA) es una enfermedad silenciosa que ataca '
      'sigilosamente, donde se considera que alguien tiene presión alta cuando:';
}