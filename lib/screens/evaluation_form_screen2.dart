import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/auth_service.dart';
import '../services/evaluation_service.dart';
import '../widgets/top_navigation_menu.dart';
import '../widgets/user_menu_button.dart';

class EvaluationFormScreen extends StatefulWidget {
  const EvaluationFormScreen({super.key});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _diasEstresController = TextEditingController();

  final String _controlaConsumoSal = '';
  final String _consumoAlcohol = '';
  final String _habitoTabaquismo = '';
  String _actividadFisica = '';
  String _colesterolAlto = '';
  String _diabetes = '';
  String _cigarrilloElectronico = '';

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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
    _diasEstresController.dispose();
    super.dispose();
  }

  Future<void> _submitEvaluation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_controlaConsumoSal.isEmpty ||
        _consumoAlcohol.isEmpty ||
        _habitoTabaquismo.isEmpty ||
        _actividadFisica.isEmpty ||
        _colesterolAlto.isEmpty ||
        _diabetes.isEmpty ||
        _cigarrilloElectronico.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final evaluationService = Provider.of<EvaluationService>(context, listen: false);

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // (Datos ingresados ignorados en modo demo)

  // MODO DEMO con IMC dinámico usando peso y altura ingresados
  final peso = double.tryParse(_pesoController.text.trim());
  final altura = double.tryParse(_alturaController.text.trim());
  evaluationService.setDummyResult(pesoKg: peso, alturaCm: altura);
    if (mounted) context.go('/evaluation-result');
  }

  @override
  Widget build(BuildContext context) {
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
              

                // Sufrió de estrés, ansiedad o depresión (últimos 30 días)
                CustomTextField(
                  controller: _diasEstresController,
                  labelText: 'Sufrió de estrés, ansiedad o depresión (últimos 30 días)',
                  hintText: 'Ingrese un número de días',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el número de días';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 0 || days > 30) {
                      return 'Ingresa un número válido entre 0 y 30';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ¿Realiza actividad física diaria >= 30 min (sin contar caminar)?
                CustomDropdown<String>(
                  labelText: '¿Realiza actividad física diaria >= 30 min (sin contar caminar)?',
                  value: _actividadFisica.isEmpty ? null : _actividadFisica,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _actividadFisica = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ¿Ha sido diagnosticado con colesterol alto?
                CustomDropdown<String>(
                  labelText: '¿Ha sido diagnosticado con colesterol alto?',
                  value: _colesterolAlto.isEmpty ? null : _colesterolAlto,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _colesterolAlto = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ¿Conoce su diagnóstico de diabetes?
                CustomDropdown<String>(
                  labelText: '¿Conoce su diagnóstico de diabetes?',
                  value: _diabetes.isEmpty ? null : _diabetes,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                    DropdownMenuItem(value: 'No sé', child: Text('No sé')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _diabetes = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ¿Usa usted algún tipo de cigarrillo electrónico?
                CustomDropdown<String>(
                  labelText: '¿Usa usted algún tipo de cigarrillo electrónico?',
                  value: _cigarrilloElectronico.isEmpty ? null : _cigarrilloElectronico,
                  items: const [
                    DropdownMenuItem(value: 'No fuma', child: Text('Nunca fumé')),
                    DropdownMenuItem(value: 'Ex fumador', child: Text('Ex fumador')),
                    DropdownMenuItem(value: 'Algunos días', child: Text('Algunos días')),
                    DropdownMenuItem(value: 'Todos los días', child: Text('Todos los días')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _cigarrilloElectronico = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 40),

                // Botón continuar
                Consumer<EvaluationService>(
                  builder: (context, evaluationService, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Continuar',
                        onPressed: _submitEvaluation,
                        isLoading: evaluationService.isLoading,
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