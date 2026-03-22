import 'package:mobx/mobx.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class ServicesStore {
  final items = ObservableList<ServiceModel>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getServices();
      runInAction(() {
        items
          ..clear()
          ..addAll(data
              .map((j) => ServiceModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }
}
