import 'package:mobx/mobx.dart';
import '../models/education_model.dart';
import '../services/api_service.dart';

class AboutStore {
  final loading = Observable(true);
  final data = Observable<Map<String, dynamic>?>(null);
  final education = ObservableList<EducationModel>.of([]);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final results = await Future.wait([
        ApiService.getAbout(),
        ApiService.getEducation(),
      ]);
      runInAction(() {
        data.value = results[0] as Map<String, dynamic>;
        education
          ..clear()
          ..addAll((results[1] as List<dynamic>)
              .map((j) => EducationModel.fromJson(j as Map<String, dynamic>)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }
}
