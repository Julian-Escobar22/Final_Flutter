import 'package:todo/domain/entities/stats_entity.dart';
import 'package:todo/domain/repositories/history_repository.dart';

class GetStats {
  final HistoryRepository repository;

  GetStats(this.repository);

  Future<StatsEntity> call() async {
    return await repository.getStats();
  }
}
