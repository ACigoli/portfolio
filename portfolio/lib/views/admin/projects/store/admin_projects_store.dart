import 'package:mobx/mobx.dart';
import '../../../../models/project_model.dart';
import '../../../../services/api_service.dart';

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
          ..addAll(data.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  /// Create a project via the API and refresh the list. Form dialogs must
  /// call this (not `ApiService` directly) so store state stays in sync.
  Future<void> create(Map<String, dynamic> data) async {
    await ApiService.createProject(data);
    await load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await ApiService.updateProject(id, data);
    await load();
  }

  Future<void> delete(int id) async {
    await ApiService.deleteProject(id);
    await load();
  }
}
