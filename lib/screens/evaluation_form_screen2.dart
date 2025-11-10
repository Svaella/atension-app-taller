import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/auth_service.dart';
import '../services/evaluation_service.dart';
// TopNavigationMenu removed - tabs no longer needed in evaluation
import '../widgets/user_menu_button.dart';
import '../models/evaluation_draft.dart';
import '../models/evaluation_model.dart'; // ← AÑADIR

class EvaluationFormStep2Screen extends StatefulWidget {
  final EvaluationDraft draft;
  
  const EvaluationFormStep2Screen({
    super.key,
    required this.draft,
  });

  @override
  State<EvaluationFormStep2Screen> createState() => _EvaluationFormStep2ScreenState();
}

class _EvaluationFormStep2ScreenState extends State<EvaluationFormStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _diasEstresController = TextEditingController();

  String _habitoTabaquismo = '';
  String _actividadFisica = '';
  String _colesterolAlto = '';
  String _diabetes = '';
  String _cigarrilloElectronico = '';

  @override
  void dispose() {
    _diasEstresController.dispose();
    super.dispose();
  }

  Future<void> _submitEvaluation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_habitoTabaquismo.isEmpty ||
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
          content: Text('Debes iniciar sesión para realizar una evaluación'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      debugPrint('🔵 Iniciando evaluación...');
      
      // Importar modelo Evaluation
      final evaluation = Evaluation(
        userId: authService.currentUser!.id ?? '',
        peso: widget.draft.peso,
        altura: widget.draft.altura,
        controlaConsumoSal: widget.draft.controlaConsumoSal,
        consumoAlcohol: widget.draft.consumoAlcohol,
        habitoTabaquismo: (_habitoTabaquismo == 'Fumador actual' || _habitoTabaquismo == 'Fumador Ocasional') ? 'Si' : 'No',
        diasEstres: int.parse(_diasEstresController.text),
        actividadFisica: _actividadFisica == 'Si' ? 'Si' : 'No',
        colesterolAlto: _colesterolAlto == 'Si' ? 'Si' : 'No',
        diabetes: _diabetes == 'Si' ? 'Si' : 'No',
        cigarrilloElectronico: (_cigarrilloElectronico == 'Todos los días' || _cigarrilloElectronico == 'Algunos días') ? 'Si' : 'No',
        fechaEvaluacion: DateTime.now(),
      );

      debugPrint('📦 Evaluación creada: peso=${evaluation.peso}, altura=${evaluation.altura}');

      // Llamar al servicio (intenta backend, fallback a simulación)
      final result = await evaluationService.createEvaluation(evaluation);

      debugPrint('✅ Resultado recibido: ${result.nivelRiesgo}');

      if (mounted) {
        context.go('/evaluation-result');
      }
    } catch (e) {
      debugPrint('❌ Error en evaluación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar la evaluación: ${e.toString()}'),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del paso 2
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Información adicional',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Hábito de tabaquismo
                CustomDropdown<String>(
                  labelText: '¿Cuál es su hábito de tabaquismo?',
                  value: _habitoTabaquismo.isEmpty ? null : _habitoTabaquismo,
                  items: const [
                    DropdownMenuItem(value: 'No fuma', child: Text('No fuma')),
                    DropdownMenuItem(value: 'Ex fumador', child: Text('Ex fumador')),
                    DropdownMenuItem(value: 'Fumador Ocasional', child: Text('Fumador ocasional')),
                    DropdownMenuItem(value: 'Fumador actual', child: Text('Fumador actual')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _habitoTabaquismo = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),

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

                // Botones de navegación
                Row(
                  children: [
                    // Botón volver
                    Expanded(
                      flex: 1,
                      child: CustomButton(
                        text: 'Volver',
                        onPressed: () => context.pop(),
                        backgroundColor: Colors.grey[600]!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón continuar
                    Expanded(
                      flex: 2,
                      child: Consumer<EvaluationService>(
                        builder: (context, evaluationService, child) {
                          return CustomButton(
                            text: 'Finalizar',
                            onPressed: _submitEvaluation,
                            isLoading: evaluationService.isLoading,
                          );
                        },
                      ),
                    ),
                  ],
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