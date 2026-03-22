import 'package:mobx/mobx.dart';
import '../models/experience_model.dart';
import '../services/api_service.dart';

class ExperienceStore {
  final items = ObservableList<ExperienceModel>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getExperience();
      runInAction(() {
        items
          ..clear()
          ..addAll(data
              .map((j) => ExperienceModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }
}
