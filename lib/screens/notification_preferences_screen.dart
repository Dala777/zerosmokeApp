import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../models/notification_preference.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  _NotificationPreferencesScreenState createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late NotificationPreference _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = NotificationPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    if (!_saving && provider.preferences.enableDailyReminder != _draft.enableDailyReminder) {
      _draft = provider.preferences;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("Preferencias generales"),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: "Recordatorio diario",
                  subtitle: "Recibe un recordatorio para hacer tu check-in diario",
                  value: _draft.enableDailyReminder,
                  onChanged: (v) => _update(provider, enableDailyReminder: v),
                ),
                _buildSwitchTile(
                  title: "Alertas de riesgo",
                  subtitle: "Notificaciones cuando tu riesgo de recaída es alto",
                  value: _draft.enableRiskAlerts,
                  onChanged: (v) => _update(provider, enableRiskAlerts: v),
                ),
                _buildSwitchTile(
                  title: "Mensajes motivacionales",
                  subtitle: "Recibe mensajes de ánimo basados en tu progreso",
                  value: _draft.enableMotivation,
                  onChanged: (v) => _update(provider, enableMotivation: v),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Horario preferido"),
                const SizedBox(height: 8),
                _buildHourSelector(
                  label: "Hora preferida",
                  value: _draft.preferredHour,
                  onChanged: (v) => _update(provider, preferredHour: v),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Horas de silencio"),
                const SizedBox(height: 8),
                _buildHourSelector(
                  label: "Inicio",
                  value: _draft.quietHoursStart,
                  onChanged: (v) => _update(provider, quietHoursStart: v),
                ),
                _buildHourSelector(
                  label: "Fin",
                  value: _draft.quietHoursEnd,
                  onChanged: (v) => _update(provider, quietHoursEnd: v),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHourSelector({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          DropdownButton<int>(
            value: value,
            underline: const SizedBox(),
            items: List.generate(24, (i) {
              final hour = i.toString().padLeft(2, '0');
              return DropdownMenuItem(value: i, child: Text("$hour:00"));
            }),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  void _update(NotificationProvider provider, {
    bool? enableDailyReminder,
    bool? enableRiskAlerts,
    bool? enableMotivation,
    int? preferredHour,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    setState(() => _saving = true);
    final updated = _draft.copyWith(
      enableDailyReminder: enableDailyReminder,
      enableRiskAlerts: enableRiskAlerts,
      enableMotivation: enableMotivation,
      preferredHour: preferredHour,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );
    _draft = updated;
    provider.updatePreferences(updated).then((_) {
      if (mounted) setState(() => _saving = false);
    });
  }
}
