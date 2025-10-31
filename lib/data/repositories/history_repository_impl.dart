import 'package:todo/domain/entities/activity_entity.dart';
import 'package:todo/domain/entities/stats_entity.dart';
import 'package:todo/domain/repositories/history_repository.dart';
import 'package:todo/data/datasources/remote/history_remote_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<StatsEntity> getStats() async {
    final data = await remoteDataSource.getStats();
    return StatsEntity.fromJson(data);
  }

  @override
  Future<List<ActivityEntity>> getRecentActivity({int limit = 10}) async {
    final data = await remoteDataSource.getRecentActivity(limit: limit);
    return data.map((json) => ActivityEntity.fromJson(json)).toList();
  }
}
