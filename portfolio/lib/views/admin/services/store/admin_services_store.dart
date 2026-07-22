import 'package:mobx/mobx.dart';
import '../../../../models/service_model.dart';
import '../../../../services/api_service.dart';

class AdminServicesStore {
  final services = ObservableList<ServiceModel>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getServices();
      runInAction(() {
        services
          ..clear()
          ..addAll(data.map((j) => ServiceModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await ApiService.createService(data);
    await load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await ApiService.updateService(id, data);
    await load();
  }

  Future<void> delete(int id) async {
    await ApiService.deleteService(id);
    await load();
  }
}
