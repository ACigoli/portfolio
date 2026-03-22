import 'package:mobx/mobx.dart';
import '../services/api_service.dart';

class DashboardStore {
  final projectsCount = Observable(0);
  final skillsCount = Observable(0);
  final experienceCount = Observable(0);
  final newMessagesCount = Observable(0);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final results = await Future.wait([
        ApiService.getProjects(),
        ApiService.getSkills(),
        ApiService.getExperience(),
        ApiService.getMessages(),
      ]);
      runInAction(() {
        projectsCount.value = results[0].length;
        skillsCount.value = results[1].length;
        experienceCount.value = results[2].length;
        newMessagesCount.value = results[3]
            .where((m) => m['read'] == 0 || m['read'] == false)
            .length;
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }
}
