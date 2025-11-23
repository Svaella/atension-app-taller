import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedSexo = '';
  DateTime? _selectedDate = DateTime(2000, 1, 1);
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final isDark = themeService.isDarkTheme;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryRed,
                    onPrimary: Colors.white,
                    surface: AppColors.darkGray,
                    onSurface: Colors.white,
                    background: AppColors.darkBackground,
                    onBackground: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryRed,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                    background: Colors.white,
                    onBackground: Colors.black87,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: isDark ? AppColors.darkBackground : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryRed,
                  width: 2,
                ),
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              bodyMedium: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            dialogBackgroundColor: isDark ? AppColors.darkGray : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text = 
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _showTermsAndConditionsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkGray,
          title: const Text(
             '📄 Términos y Condiciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                   '''
Última actualización: 20 de octubre de 2025

1. Aceptación de los términos

Al registrarse, acceder o utilizar la aplicación aTensión, el usuario acepta estos Términos y Condiciones. Si no está de acuerdo con alguna parte de los mismos, debe abstenerse de utilizar la aplicación.

2. Descripción del servicio

aTensión es una aplicación móvil diseñada para realizar una valoración preliminar del riesgo de desarrollar Hipertensión Arterial. La aplicación utiliza datos ingresados por el usuario (como peso, altura, edad, hábitos, entre otros) y un modelo de Machine Learning basado en el conjunto de datos BRFSS.

• El resultado proporcionado no constituye un diagnóstico médico y debe ser interpretado únicamente como una orientación informativa.

• Para obtener una valoración médica definitiva, se recomienda consultar con un profesional de la salud.

3. Registro y uso de la cuenta

• El usuario deberá proporcionar información veraz, completa y actualizada durante el registro.

• El acceso a la cuenta es personal e intransferible.

• El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso.

4. Uso adecuado de la aplicación

El usuario se compromete a utilizar la aplicación únicamente con fines informativos y personales, absteniéndose de:

• Ingresar información falsa o de terceros sin consentimiento.

• Utilizar la aplicación con fines comerciales, ilegales o que puedan afectar su funcionamiento.

• Modificar, copiar o distribuir el contenido o código de la aplicación sin autorización previa.

5. Protección de datos personales

aTensión cumple con la Ley de Protección de Datos Personales vigente. Los datos ingresados se utilizan exclusivamente para:

• Calcular el nivel de riesgo de hipertensión arterial.

• Generar estadísticas o métricas anónimas para la mejora del servicio.

La aplicación no comparte, vende ni divulga información personal a terceros sin el consentimiento del usuario.
Para más detalles, consulte la sección “Uso de datos personales” dentro de la aplicación.

6. Limitación de responsabilidad

El equipo desarrollador de aTensión no se hace responsable por:

• Decisiones médicas o de salud tomadas con base en los resultados de la aplicación.

• Daños directos o indirectos derivados del uso o imposibilidad de uso del sistema.

• Errores de ingreso de datos por parte del usuario o interrupciones técnicas.

7. Actualizaciones del servicio

• La aplicación puede ser actualizada periódicamente para incorporar mejoras, correcciones o nuevas funciones.

• El usuario acepta que dichas actualizaciones pueden realizarse automáticamente.

8. Derechos de propiedad intelectual

Todos los elementos de diseño, logotipos, textos, código fuente y contenidos de aTensión son propiedad de su desarrollador y están protegidos por las leyes de propiedad intelectual vigentes.

              ''',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _acceptTerms = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar tu fecha de nacimiento'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_selectedSexo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar tu sexo'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final user = User(
      nombre: _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      fechaNacimiento: _selectedDate!,
      sexo: _selectedSexo,
      email: _correoController.text.trim(),
    );

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final result = await authService.register(user, _passwordController.text);  // ← NUEVO
    
      if (mounted) {
        if (result['success']) {
          // Registro exitoso - usuario ya está autenticado, dirigir a evaluación
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido! Completa tu primera evaluación'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Dirigir a la evaluación (usuario nuevo siempre debe hacerla)
          context.go('/evaluation-form');
        } else {
          // Registro falló - mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al registrarse'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Mostrar mensaje de error amigable
        final errorMessage = e is ApiException ? e.message : 'No se pudo completar el registro. Por favor, verifica tus datos e intenta nuevamente.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  // fallback si no hay stack de navegación
                  context.go('/welcome');
                }
              },
        ),
        title: const Text(
          'Registrarse',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeService.isDarkTheme
                    ? [AppColors.darkBackground, const Color(0xFF2D3748)]
                    : [Colors.grey[50]!, Colors.grey[100]!],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryRed,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        Constants.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: themeService.isDarkTheme ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Formulario
                  CustomTextField(
                    controller: _nombreController,
                    labelText: 'Nombre',
                    hintText: 'Ingresa tu nombre',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    controller: _apellidosController,
                    labelText: 'Apellidos',
                    hintText: 'Ingresa tus apellidos',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tus apellidos';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    controller: _fechaNacimientoController,
                    labelText: 'Fecha de Nacimiento',
                    hintText: 'DD/MM/YYYY',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: AppColors.darkGray),
                      onPressed: _selectDate,
                    ),
                    onChanged: (value) {
                      // Intentar parsear la fecha cuando se ingresa manualmente
                      if (value.length == 10) {
                        try {
                          final parts = value.split('/');
                          if (parts.length == 3) {
                            final day = int.parse(parts[0]);
                            final month = int.parse(parts[1]);
                            final year = int.parse(parts[2]);
                            final date = DateTime(year, month, day);
                            
                            // Validar que la fecha sea válida
                            if (date.year == year && date.month == month && date.day == day) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          }
                        } catch (e) {
                          // Si falla el parseo, no hacer nada
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona tu fecha de nacimiento';
                      }
                      
                      // Validar formato DD/MM/YYYY
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return 'Formato inválido. Use DD/MM/YYYY';
                      }
                      
                      // Validar que la fecha sea válida
                      try {
                        final parts = value.split('/');
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        final date = DateTime(year, month, day);
                        
                        if (date.year != year || date.month != month || date.day != day) {
                          return 'Fecha inválida';
                        }
                        
                        if (date.isAfter(DateTime.now())) {
                          return 'La fecha no puede ser futura';
                        }
                        
                        if (date.isBefore(DateTime(1900))) {
                          return 'La fecha debe ser posterior a 1900';
                        }
                      } catch (e) {
                        return 'Fecha inválida';
                      }
                      
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomDropdown(
                    labelText: 'Sexo',
                    value: _selectedSexo.isEmpty ? null : _selectedSexo,
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSexo = value ?? '';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    controller: _correoController,
                    labelText: 'Correo',
                    hintText: 'example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!RegExp(Constants.emailPattern).hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    hintText: '********',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.darkGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña';
                      }
                      if (value.length < Constants.minPasswordLength) {
                        return 'La contraseña debe tener al menos ${Constants.minPasswordLength} caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Términos y condiciones
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryRed,
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Acepta ',
                                  style: TextStyle(
                                    color: themeService.isDarkTheme ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'términos y condiciones',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _showTermsAndConditionsModal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botón registrarse
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Registrarse',
                          onPressed: _handleRegister,
                          isLoading: authService.isLoading,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ¿Ya tienes cuenta?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: TextStyle(
                          color: themeService.isDarkTheme ? AppColors.textSecondary : Colors.grey[700],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}