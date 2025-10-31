import 'package:get/get.dart';
import 'package:todo/domain/entities/activity_entity.dart';
import 'package:todo/domain/entities/stats_entity.dart';
import 'package:todo/domain/usecases/history/get_stats.dart';
import 'package:todo/domain/usecases/history/get_recent_activity.dart';

class HistoryController extends GetxController {
  final GetStats getStats;
  final GetRecentActivity getRecentActivity;

  HistoryController({
    required this.getStats,
    required this.getRecentActivity,
  });

  // Estado
  final Rx<StatsEntity?> stats = Rx<StatsEntity?>(null);
  final RxList<ActivityEntity> activities = <ActivityEntity>[].obs;
  final loading = false.obs;
  final loadingActivities = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // 👇 Escucha cambios de ruta para recargar cuando vuelvas
    ever(Get.currentRoute.obs, (route) {
      if (route.toString().contains('home')) {
        loadData();
      }
    });
  }

  /// Carga todos los datos
  Future<void> loadData() async {
    await Future.wait([
      loadStats(),
      loadActivities(),
    ]);
  }

  /// Carga estadísticas
  Future<void> loadStats() async {
    try {
      loading.value = true;
      final result = await getStats();
      stats.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las estadísticas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  /// Carga actividades recientes
  Future<void> loadActivities() async {
    try {
      loadingActivities.value = true;
      final result = await getRecentActivity(limit: 10);
      activities.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las actividades: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loadingActivities.value = false;
    }
  }

  /// Obtiene color para tipo de actividad
  String getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.noteCreated:
        return '#4CAF50';
      case ActivityType.noteEdited:
        return '#2196F3';
      case ActivityType.quizGenerated:
        return '#FF9800';
      case ActivityType.quizCompleted:
        return '#9C27B0';
    }
  }

  /// Obtiene ícono para tipo de actividad
  String getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.noteCreated:
        return '📝';
      case ActivityType.noteEdited:
        return '✏️';
      case ActivityType.quizGenerated:
        return '📋';
      case ActivityType.quizCompleted:
        return '✅';
    }
  }
}
