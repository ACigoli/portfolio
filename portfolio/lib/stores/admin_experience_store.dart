import 'package:mobx/mobx.dart';
import '../services/api_service.dart';

class AdminExperienceStore {
  final items = ObservableList<Map<String, dynamic>>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getExperience();
      runInAction(() {
        items
          ..clear()
          ..addAll(data.map((j) => Map<String, dynamic>.from(j as Map)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  Future<void> delete(int id) async {
    await ApiService.deleteExperience(id);
    await load();
  }
}
