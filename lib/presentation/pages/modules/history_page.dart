import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:todo/presentation/controllers/history_controller.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, isSmallScreen),
                  SizedBox(height: isSmallScreen ? 20 : 32),

                  // Estadísticas generales
                  Obx(() {
                    if (controller.loading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.stats.value == null) {
                      return const Center(child: Text('No hay estadísticas'));
                    }

                    return Column(
                      children: [
                        // Tarjetas de estadísticas
                        _buildStatsCards(context, controller, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 20 : 32),

                        // Gráfica de rendimiento
                        if (controller.stats.value!.quizScores.isNotEmpty)
                          _buildPerformanceChart(context, controller, isSmallScreen),

                        SizedBox(height: isSmallScreen ? 20 : 32),

                        // Actividad reciente
                        _buildRecentActivity(context, controller, isSmallScreen),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights,
              size: isSmallScreen ? 28 : 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Historial / Progreso',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 22 : 28,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Revisa tu actividad reciente y evolución',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, HistoryController controller, bool isSmallScreen) {
    final stats = controller.stats.value!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isSmallScreen ? 2 : 4;
        final childAspectRatio = isSmallScreen ? 1.3 : 1.5;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _StatCard(
              icon: Icons.note_outlined,
              title: 'Notas',
              value: '${stats.totalNotes}',
              color: Colors.blue,
            ),
            _StatCard(
              icon: Icons.quiz_outlined,
              title: 'Quizzes',
              value: '${stats.totalQuizzes}',
              color: Colors.orange,
            ),
            _StatCard(
              icon: Icons.check_circle_outline,
              title: 'Completados',
              value: '${stats.totalQuizzesCompleted}',
              color: Colors.green,
            ),
            _StatCard(
              icon: Icons.trending_up,
              title: 'Promedio',
              value: '${stats.averageQuizScore.toStringAsFixed(0)}%',
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceChart(BuildContext context, HistoryController controller, bool isSmallScreen) {
    final stats = controller.stats.value!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rendimiento en Quizzes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: isSmallScreen ? 200 : 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles:false,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.quizScores.length) {
                            final date = stats.quizScores[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(date),
                                style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.quizScores
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.score))
                          .toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, HistoryController controller, bool isSmallScreen) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Reciente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.loadingActivities.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay actividad reciente',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = controller.activities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity.type).withOpacity(0.2),
                      child: Text(
                        controller.getActivityIcon(activity.type),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      activity.description ?? activity.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTimestamp(activity.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(dynamic type) {
    final typeString = type.toString().split('.').last;
    switch (typeString) {
      case 'noteCreated':
        return Colors.green;
      case 'noteEdited':
        return Colors.blue;
      case 'quizGenerated':
        return Colors.orange;
      case 'quizCompleted':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes}m';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(timestamp);
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
