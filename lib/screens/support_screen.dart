import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte y Ayuda'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFAQSection(context),
            const SizedBox(height: 24),
            _buildResourcesSection(),
            const SizedBox(height: 24),
            _buildContactInfo(),
            const SizedBox(height: 24),
            _buildEmergencySupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.support_agent,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo podemos ayudarte?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos aquí para apoyarte en tu camino para dejar de fumar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': '¿Cómo funciona el contador de días sin fumar?',
        'answer':
            'El contador comienza desde el día que estableces como tu fecha para dejar de fumar. Se actualiza automáticamente cada día y te muestra estadísticas sobre tu progreso.'
      },
      {
        'question': '¿Puedo modificar mi plan diario?',
        'answer':
            'Sí, puedes personalizar tu plan diario en la sección de configuración. Puedes ajustar tus objetivos, actividades recomendadas y recordatorios.'
      },
      {
        'question': '¿Qué hago si tengo una recaída?',
        'answer':
            'Las recaídas son parte del proceso. Si tienes una recaída, utiliza el botón de emergencia en la pantalla principal para acceder a técnicas que te ayudarán a superar el momento. Recuerda que cada intento te acerca más a tu meta.'
      },
      {
        'question': '¿Cómo se calculan los ahorros?',
        'answer':
            'Los ahorros se calculan multiplicando el número de cigarrillos que no has fumado por el precio promedio de un cigarrillo que configuraste en tu perfil.'
      },
      {
        'question': '¿Puedo exportar mis datos de progreso?',
        'answer':
            'Sí, puedes exportar tus datos de progreso en formato PDF o CSV desde la sección de estadísticas en tu perfil.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preguntas frecuentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  faqs[index]['question']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faqs[index]['answer']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    final resources = [
      {
        'title': 'Guía para dejar de fumar',
        'description': 'Una guía completa con consejos y estrategias',
        'icon': Icons.book,
        'color': Colors.green,
        'url': 'https://www.example.com/guia-dejar-fumar',
      },
      {
        'title': 'Beneficios de dejar de fumar',
        'description': 'Infografía sobre los beneficios para la salud',
        'icon': Icons.health_and_safety,
        'color': Colors.blue,
        'url': 'https://www.example.com/beneficios-dejar-fumar',
      },
      {
        'title': 'Técnicas de relajación',
        'description': 'Videos con ejercicios de respiración y meditación',
        'icon': Icons.spa,
        'color': Colors.purple,
        'url': 'https://www.example.com/tecnicas-relajacion',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recursos útiles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (resource['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    resource['icon'] as IconData,
                    color: resource['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(
                  resource['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  resource['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () async {
                  final url = Uri.parse(resource['url'] as String);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contáctanos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              'Correo electrónico',
              'soporte@zerosmoke.com',
              'mailto:soporte@zerosmoke.com',
            ),
            const Divider(height: 24),
            _buildContactItem(
              Icons.phone,
              'Teléfono',
              '+1 (555) 123-4567',
              'tel:+15551234567',
            ),
            const Divider(height: 24),
            _buildContactItem(
              Icons.chat,
              'Chat en vivo',
              'Disponible de 9:00 AM a 6:00 PM',
              'https://www.zerosmoke.com/chat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    String url,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySupport() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '¿Necesitas ayuda urgente?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Si sientes una necesidad urgente de fumar, estas opciones pueden ayudarte:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para ejercicio de respiración
                  },
                  icon: const Icon(Icons.air),
                  label: const Text('Respiración'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para distracción rápida
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Distracción'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}