import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
              child: Column(
                children: [
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: AppColors.successGreen,
                          title: Row(
                            children: const [
                              Icon(Icons.eco, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Software Verde', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Esta aplicación sigue buenas prácticas ambientales y utiliza infraestructura sostenible gracias a Google Cloud.\n\nMás información:',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final url = Uri.parse('https://cloud.google.com/sustainability?hl=es');
                                  try {
                                    final launched = await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!launched) {
                                      Navigator.of(dialogContext).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se pudo abrir el enlace')),
                                      );
                                    }
                                  } catch (e) {
                                    Navigator.of(dialogContext).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No se pudo abrir el enlace')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'https://cloud.google.com/sustainability?hl=es',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
                              onPressed: () => Navigator.of(dialogContext).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.eco, color: Colors.green, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Software Verde',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
