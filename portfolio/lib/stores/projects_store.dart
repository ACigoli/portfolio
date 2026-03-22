import 'package:mobx/mobx.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';

class ProjectsStore {
  final items = ObservableList<ProjectModel>.of([]);
  final loading = Observable(true);
  final filter = Observable('Todos');

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getProjects();
      runInAction(() {
        items
          ..clear()
          ..addAll(
              data.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  void setFilter(String f) => runInAction(() => filter.value = f);

  List<ProjectModel> get filtered {
    if (filter.value == 'Todos') return List.unmodifiable(items);
    return items.where((p) => p.category == filter.value).toList();
  }
}
