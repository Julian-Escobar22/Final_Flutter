import 'package:todo/domain/entities/activity_entity.dart';
import 'package:todo/domain/repositories/history_repository.dart';

class GetRecentActivity {
  final HistoryRepository repository;

  GetRecentActivity(this.repository);

  Future<List<ActivityEntity>> call({int limit = 10}) async {
    return await repository.getRecentActivity(limit: limit);
  }
}
