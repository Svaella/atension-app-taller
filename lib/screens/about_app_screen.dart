import 'package:flutter/material.dart';
import '../utils/colors.dart';
// Eliminamos el menú superior para esta pantalla.

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // fallback por si se abrió con go() sin stack
              Navigator.of(context).pushReplacementNamed('/evaluation-form');
            }
          },
        ),
        title: const Text(
          'Acerca de aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón expandible "Ley de Protección de datos"
            Container(
              margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ExpansionTile(
                  title: const Text(
                    'Ley de Protección de datos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  backgroundColor: AppColors.primaryRed,
                  collapsedBackgroundColor: AppColors.primaryRed,
                  onExpansionChanged: (expanded) {
                    // El ExpansionTile maneja su estado interno
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Esta aplicación respeta los principios de la Ley N° 29733 y su reglamento. Los datos ingresados se utilizan únicamente con fines informativos para mostrar un resultado referencial y no se comparten con terceros.\n\nNo se realiza actualmente almacenamiento permanente de historiales clínicos completos.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón expandible "Uso de datos personales"
            Container(
              margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ExpansionTile(
                  title: const Text(
                    'Uso de datos personales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  backgroundColor: AppColors.primaryRed,
                  collapsedBackgroundColor: AppColors.primaryRed,
                  onExpansionChanged: (expanded) {
                    // El ExpansionTile maneja su estado interno
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Derechos del Usuario:\n• Acceso: Puedes solicitar conocer los datos que hayas proporcionado.\n• Rectificación y actualización: Puedes corregir datos incorrectos.\n• Cancelación/Oposición: Puedes dejar de usar la aplicación y tus datos dejarán de procesarse.\n\nBuenas Prácticas:\n• No ingreses información sensible que no sea solicitada.\n• Verifica tus datos antes de continuar.\n\nAviso Importante: El resultado mostrado no constituye diagnóstico médico. Para evaluación, tratamiento o dudas específicas debes acudir a un profesional de la salud.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Versión al final
            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
