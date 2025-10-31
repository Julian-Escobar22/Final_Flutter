import 'package:todo/domain/entities/activity_entity.dart';
import 'package:todo/domain/entities/stats_entity.dart';

abstract class HistoryRepository {
  Future<StatsEntity> getStats();
  Future<List<ActivityEntity>> getRecentActivity({int limit = 10});
}
