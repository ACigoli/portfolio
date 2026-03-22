import 'package:mobx/mobx.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';

class AdminProjectsStore {
  final projects = ObservableList<ProjectModel>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getProjects();
      runInAction(() {
        projects
          ..clear()
          ..addAll(data
              .map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  Future<void> delete(int id) async {
    await ApiService.deleteProject(id);
    await load();
  }
}
