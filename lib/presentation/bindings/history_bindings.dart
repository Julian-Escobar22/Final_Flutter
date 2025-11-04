import 'package:get/get.dart';
import 'package:todo/data/datasources/remote/history_remote_datasource.dart';
import 'package:todo/data/repositories/history_repository_impl.dart';
import 'package:todo/domain/usecases/history/get_stats.dart';
import 'package:todo/domain/usecases/history/get_recent_activity.dart';
import 'package:todo/presentation/controllers/history_controller.dart';

class HistoryBindings extends Bindings {
  @override
  void dependencies() {
    // DataSource
    Get.lazyPut<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSource(),
    );

    // Repository
    Get.lazyPut<HistoryRepositoryImpl>(
      () => HistoryRepositoryImpl(Get.find<HistoryRemoteDataSource>()),
    );

    // UseCases
    Get.lazyPut(() => GetStats(Get.find<HistoryRepositoryImpl>()));
    Get.lazyPut(() => GetRecentActivity(Get.find<HistoryRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => HistoryController(
        getStats: Get.find(),
        getRecentActivity: Get.find(),
      ),
    );
  }
}
