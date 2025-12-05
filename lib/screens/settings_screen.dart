import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/farm_management_screen.dart';
import 'package:gestantes/services/pdf_service.dart';
import 'package:gestantes/services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            _buildSectionTitle(context, 'Gestion'),
            _buildSettingCard(
              context,
              Icons.agriculture,
              'Gestionar Fincas',
              'Crear y editar fincas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FarmManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildSectionTitle(context, 'Reportes'),
            Consumer<AnimalProvider>(
              builder: (context, provider, _) => Column(
                spacing: 8,
                children: [
                  _buildSettingCard(
                    context,
                    Icons.picture_as_pdf,
                    'Exportar Reporte General',
                    'Generar PDF de todos los animales',
                    onTap: () async {
                      try {
                        await PdfService.generateGeneralReport(provider.allAnimals);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionTitle(context, 'Backup'),
            Consumer<AnimalProvider>(
              builder: (context, provider, _) => Column(
                spacing: 8,
                children: [
                  _buildSettingCard(
                    context,
                    Icons.cloud_upload,
                    'Exportar Backup',
                    'Descargar copia de seguridad',
                    onTap: () async {
                      try {
                        await BackupService.exportBackup();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                  _buildSettingCard(
                    context,
                    Icons.cloud_download,
                    'Importar Backup',
                    'Restaurar copia de seguridad',
                    onTap: () async {
                      try {
                        final success = await BackupService.importBackup();
                        if (success) {
                          await provider.loadAnimals();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Backup restaurado exitosamente')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionTitle(context, 'Informacion'),
            _buildSettingCard(
              context,
              Icons.info_outline,
              'Acerca de',
              'Ver funcionalidades',
              onTap: () => _showAboutDialog(context),
            ),
            _buildSettingCard(
              context,
              Icons.code,
              'Version',
              '1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildDeveloperCard(context),
            const SizedBox(height: 32),
            _buildFeaturesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 8,
          children: [
            Icon(
              Icons.person,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              'Desarrollado por',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              'Oscar Grau',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '© Derechos Reservados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              'Funcionalidades',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildFeatureItem(context, '📋', 'Gestion de animales', 'Registra y edita informacion de tus vacas'),
            _buildFeatureItem(context, '📊', 'Estadisticas', 'Visualiza graficas de distribucion y estado'),
            _buildFeatureItem(context, '📈', 'Dashboard', 'Alertas de parto y palpados pendientes'),
            _buildFeatureItem(context, '🔍', 'Busqueda avanzada', 'Filtra por raza, meses o ID'),
            _buildFeatureItem(context, '📝', 'Notas', 'Registra observaciones, tratamientos y sintomas'),
            _buildFeatureItem(context, '📋', 'Historial', 'Timeline completo de eventos por animal'),
            _buildFeatureItem(context, '🏷️', 'Etiquetas', 'Marca animales con etiquetas personalizadas'),
            _buildFeatureItem(context, '📄', 'PDF', 'Genera reportes en PDF con toda la informacion'),
            _buildFeatureItem(context, '💾', 'Backup', 'Exporta e importa copia de seguridad completa'),
            _buildFeatureItem(context, '🌾', 'Multiples fincas', 'Gestiona varios predios en una sola app'),
            _buildFeatureItem(context, '💾', 'Exportacion', 'Descarga datos en formato CSV'),
            _buildFeatureItem(context, '🌙', 'Tema oscuro', 'Interfaz adaptable a tu preferencia'),
            _buildFeatureItem(context, '⚡', 'Offline', 'Funciona completamente sin internet'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Acerca de Gestantes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                'App para gestion de vacas prenadas en fincas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const Divider(),
              Text(
                'Caracteristicas principales:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildBulletPoint('Registro completo de animales'),
              _buildBulletPoint('Calculo automatico de gestacion'),
              _buildBulletPoint('Alertas por parto proximo'),
              _buildBulletPoint('Historial de palpados'),
              _buildBulletPoint('Estadisticas detalladas'),
              _buildBulletPoint('Exportacion de datos'),
              _buildBulletPoint('Generacion de reportes PDF'),
              _buildBulletPoint('Backup y restauracion'),
              _buildBulletPoint('Gestion de multiples fincas'),
              _buildBulletPoint('Funciona offline'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text('•'),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
