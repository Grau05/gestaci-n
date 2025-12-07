import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';
import 'package:gestantes/screens/farm_management_screen.dart';
import 'package:gestantes/services/pdf_service.dart';
import 'package:gestantes/services/backup_service.dart';
import 'package:gestantes/services/backup_file_service.dart';
import 'dart:convert';

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
                final animalProvider = context.read<AnimalProvider>();
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const FarmManagementScreen(),
                      ),
                    )
                    .then((_) {
                  animalProvider.loadFarmsAndAnimals();
                });
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
                    'Guardar y compartir copia de seguridad JSON',
                    onTap: () async {
                      try {
                        final backupJson = await BackupService.exportBackupAsJson();
                        final file = await BackupFileService.saveBackupToFile(backupJson);

                        final Map<String, dynamic> data =
                            jsonDecode(backupJson) as Map<String, dynamic>;
                        final farmsCount = (data['farms'] as List).length;
                        final animalsCount = (data['animals'] as List).length;
                        final notesCount = (data['notes'] as List).length;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Backup guardado'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 12,
                              children: [
                                Text(
                                  'Archivo: ${file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : file.path}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Ubicación: ${file.parent.path}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  'Puedes buscar este archivo con un gestor de archivos o usar el botón "Compartir" para enviarlo (por ejemplo a WhatsApp o guardarlo en Descargas/Drive).',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Resumen del contenido:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Fincas: $farmsCount\nAnimales: $animalsCount\nNotas: $notesCount',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await BackupFileService.shareBackupFile(file);
                                },
                                child: const Text('Compartir'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  _buildSettingCard(
                    context,
                    Icons.cloud_download,
                    'Restaurar Backup',
                    'Seleccionar archivo de copia de seguridad',
                    onTap: () async {
                      _showRestoreDialog(context, provider);
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
              'Oscar Joaquin Grau Carranza',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              ' Derechos Reservados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              'ojgrau',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
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

  void _showRestoreDialog(BuildContext context, AnimalProvider provider) async {
    try {
      final json = await BackupFileService.pickBackupFileAndRead();

      if (json == null) {
        return;
      }

      if (!BackupService.validateBackupJson(json)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON inválido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final backup = jsonDecode(json) as Map<String, dynamic>;
      final farmsCount = (backup['farms'] as List).length;
      final animalsCount = (backup['animals'] as List).length;
      final notesCount = (backup['notes'] as List).length;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmar restauración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const Text(
                'Se borrarán todos los datos actuales de fincas, animales y notas y se reemplazarán por los del backup.',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Resumen del backup:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fincas: $farmsCount\nAnimales: $animalsCount\nNotas: $notesCount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return;
      }

      await BackupService.restoreFromJson(json);
      await provider.loadFarmsAndAnimals();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restaurado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
