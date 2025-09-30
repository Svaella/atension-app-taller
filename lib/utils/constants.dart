class Constants {
  static const String appName = 'aTensión';
  static const String baseUrl = 'http://localhost:8000/api'; // Cambia por tu URL de FastAPI
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String evaluationEndpoint = '/evaluations';
  static const String historyEndpoint = '/evaluations/history';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Validation
  static const int minPasswordLength = 8;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Messages
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