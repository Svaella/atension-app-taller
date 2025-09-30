import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/evaluation_service.dart'; // aún usado para isLoading pero no se crea resultado aquí
import '../services/auth_service.dart';
import '../models/evaluation_draft.dart';
import '../widgets/top_navigation_menu.dart';
import '../widgets/user_menu_button.dart';
import '../utils/constants.dart';

class EvaluationFormScreen extends StatefulWidget {
  const EvaluationFormScreen({super.key});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  // Campo de estrés pasa al paso 2, se remueve aquí
  // final _diasEstresController = TextEditingController();

  String _controlaConsumoSal = '';
  String _consumoAlcohol = '';
  // String _habitoTabaquismo = ''; // Movido a la pantalla 2
  // Campos del paso 2 se eliminan aquí

  bool _dialogShown = false; // Evitar que se abra más de una vez si rebuild ocurre

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowInstructions());
  }

  Future<void> _maybeShowInstructions() async {
    if (_dialogShown) return; // seguridad
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_evaluation_instructions') ?? false;
    if (hasSeen) return; // No mostrar nuevamente
    _dialogShown = true;
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false, // Obligamos a pulsar el botón
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Instrucciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  Constants.evaluationInstructions,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_seen_evaluation_instructions', true);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
  // _diasEstresController.dispose(); // ya no se usa en paso 1
    super.dispose();
  }

  Future<void> _goToStep2() async {
    if (!_formKey.currentState!.validate()) return;

    if (_controlaConsumoSal.isEmpty ||
        _consumoAlcohol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final peso = double.tryParse(_pesoController.text.trim()) ?? 0;
    final altura = double.tryParse(_alturaController.text.trim()) ?? 0;
    final draft = EvaluationDraft(
      peso: peso,
      altura: altura,
      controlaConsumoSal: _controlaConsumoSal,
      consumoAlcohol: _consumoAlcohol,
      // habitoTabaquismo se agregará en la pantalla 2
    );
    if (mounted) context.push('/evaluation-form-step2', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.push('/about'),
          ),
          const UserMenuButton(),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: TopNavigationMenu(activeTab: 'evaluacion'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtítulo "Ingrese sus datos"
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Ingrese sus datos',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Información del usuario (no editable)
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    final user = authService.currentUser;
                    if (user == null) return const SizedBox.shrink();
                    
                    return Column(
                      children: [
                        // Edad (no editable con estilo especial)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edad',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color.fromARGB(255, 160, 160, 160),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardBackground : const Color.fromARGB(255, 230, 230, 230),
                                borderRadius: BorderRadius.circular(8),
                                border: isDark 
                                  ? Border.all(color: Colors.grey[600]!, width: 1)
                                  : null,
                              ),
                              child: Text(
                                '${user.edad} años',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[300] : const Color.fromARGB(255, 100, 100, 100),
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Sexo (no editable con estilo especial)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sexo',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color.fromARGB(255, 160, 160, 160),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardBackground : const Color.fromARGB(255, 230, 230, 230),
                                borderRadius: BorderRadius.circular(8),
                                border: isDark 
                                  ? Border.all(color: Colors.grey[600]!, width: 1)
                                  : null,
                              ),
                              child: Text(
                                user.sexo,
                                style: TextStyle(
                                  color: isDark ? Colors.grey[300] : const Color.fromARGB(255, 100, 100, 100),
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                
                // Peso
                CustomTextField(
                  controller: _pesoController,
                  labelText: 'Peso',
                  hintText: 'Ingrese su peso en kg',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu peso';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa un peso válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Altura
                CustomTextField(
                  controller: _alturaController,
                  labelText: 'Altura',
                  hintText: 'Ingrese su altura en cm',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu altura';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa una altura válida';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ¿Controla o reduce su consumo de sal?
                CustomDropdown<String>(
                  labelText: '¿Controla o reduce su consumo de sal?',
                  value: _controlaConsumoSal.isEmpty ? null : _controlaConsumoSal,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _controlaConsumoSal = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ¿Consumió al menos una bebida alcohólica en los últimos 30 días?
                CustomDropdown<String>(
                  labelText: '¿Consumió al menos una bebida alcohólica en los últimos 30 días?',
                  value: _consumoAlcohol.isEmpty ? null : _consumoAlcohol,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _consumoAlcohol = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),
                // Botón continuar
                Consumer<EvaluationService>(
                  builder: (context, evaluationService, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Siguiente',
                        onPressed: _goToStep2,
                        isLoading: false,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}