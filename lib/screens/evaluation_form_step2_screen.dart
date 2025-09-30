import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/evaluation_service.dart';
import '../models/evaluation_draft.dart';
import '../widgets/top_navigation_menu.dart';
import '../widgets/user_menu_button.dart';

class EvaluationFormStep2Screen extends StatefulWidget {
  final EvaluationDraft draft;
  const EvaluationFormStep2Screen({super.key, required this.draft});

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_habitoTabaquismo.isEmpty || _actividadFisica.isEmpty || _colesterolAlto.isEmpty || _diabetes.isEmpty || _cigarrilloElectronico.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    final evaluationService = Provider.of<EvaluationService>(context, listen: false);
    final draft = widget.draft.copyWith(
      habitoTabaquismo: _habitoTabaquismo,
      diasEstres: int.tryParse(_diasEstresController.text.trim()),
      actividadFisica: _actividadFisica,
      colesterolAlto: _colesterolAlto,
      diabetes: _diabetes,
      cigarrilloElectronico: _cigarrilloElectronico,
    );

    evaluationService.setDummyResult(pesoKg: draft.peso, alturaCm: draft.altura);
    if (mounted) context.go('/evaluation-result');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('aTensión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          padding: const EdgeInsets.all(24),
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
                
                // Defina su hábito de tabaquismo
                CustomDropdown<String>(
                  labelText: 'Defina su hábito de tabaquismo',
                  value: _habitoTabaquismo.isEmpty ? null : _habitoTabaquismo,
                  items: const [
                    DropdownMenuItem(value: 'No fuma', child: Text('Nunca fumé')),
                    DropdownMenuItem(value: 'Ex fumador', child: Text('Ex fumador')),
                    DropdownMenuItem(value: 'Fuma algunos días', child: Text('Fuma algunos días')),
                    DropdownMenuItem(value: 'Fuma a diario', child: Text('Fuma a diario')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _habitoTabaquismo = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 20),
                
                CustomTextField(
                  controller: _diasEstresController,
                  labelText: 'Sufrió de estrés, ansiedad o depresión (últimos 30 días)',
                  hintText: 'Ingrese un número de días',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el número de días';
                    }
                    final v = int.tryParse(value);
                    if (v == null || v < 0 || v > 30) {
                      return 'Ingresa un número válido (0-30)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdown<String>(
                  labelText: '¿Realiza actividad física diaria >= 30 min (sin contar caminar)?',
                  value: _actividadFisica.isEmpty ? null : _actividadFisica,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                    DropdownMenuItem(value: 'A veces', child: Text('A veces')),
                  ],
                  onChanged: (val) => setState(() => _actividadFisica = val ?? ''),
                ),
                const SizedBox(height: 20),
                CustomDropdown<String>(
                  labelText: '¿Ha sido diagnosticado con colesterol alto?',
                  value: _colesterolAlto.isEmpty ? null : _colesterolAlto,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                    DropdownMenuItem(value: 'No lo sé', child: Text('No lo sé')),
                  ],
                  onChanged: (val) => setState(() => _colesterolAlto = val ?? ''),
                ),
                const SizedBox(height: 20),
                CustomDropdown<String>(
                  labelText: '¿Conoce su diagnóstico de diabetes?',
                  value: _diabetes.isEmpty ? null : _diabetes,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                    DropdownMenuItem(value: 'Prediabetes', child: Text('Prediabetes')),
                  ],
                  onChanged: (val) => setState(() => _diabetes = val ?? ''),
                ),
                const SizedBox(height: 20),
                CustomDropdown<String>(
                  labelText: '¿Usa usted algún tipo de cigarrillo electrónico?',
                  value: _cigarrilloElectronico.isEmpty ? null : _cigarrilloElectronico,
                  items: const [
                    DropdownMenuItem(value: 'Si', child: Text('Sí')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (val) => setState(() => _cigarrilloElectronico = val ?? ''),
                ),
                const SizedBox(height: 40),
                Consumer<EvaluationService>(
                  builder: (context, evaluationService, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Evaluar riesgo',
                        onPressed: _submit,
                        isLoading: evaluationService.isLoading,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
