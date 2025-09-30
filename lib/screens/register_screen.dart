import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController(text: 'Prueba');
  final _apellidosController = TextEditingController(text: 'Test Usuario');
  final _fechaNacimientoController = TextEditingController(text: '01/01/2000');
  final _correoController = TextEditingController(text: 'prueba@email.com');
  final _passwordController = TextEditingController(text: 'test1234');

  String _selectedSexo = 'Masculino';
  DateTime? _selectedDate = DateTime(2000, 1, 1);
  bool _acceptTerms = true;
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
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
      correo: _correoController.text.trim(),
    );

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      await authService.register(user, _passwordController.text);
      
      if (mounted) {
  context.go('/evaluation-form');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrarse: ${e.toString()}'),
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
              context.go('/');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkBackground, Color(0xFF2D3748)],
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
                          color: Colors.white,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona tu fecha de nacimiento';
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
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text(
                              'Acepto términos y condiciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
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
                      const Text(
                        '¿Ya tienes una cuenta? ',
                        style: TextStyle(color: AppColors.textSecondary),
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
      ),
    );
  }
}