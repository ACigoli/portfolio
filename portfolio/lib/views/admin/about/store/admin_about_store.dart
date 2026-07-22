import 'package:mobx/mobx.dart';
import '../../../../models/education_model.dart';
import '../../../../services/api_service.dart';

/// Extracted from what used to be ~9 inline `TextEditingController`s and an
/// `ObservableList<EducationModel>` living directly on the About widget's
/// state, with no real store class. Same runtime-MobX pattern as the other
/// admin stores: observables + `runInAction` + `load()`. The view still owns
/// its `TextEditingController`s (needed to bind to [TextField]s) but seeds
/// them from [aboutData] after [load] resolves, and every education CRUD
/// action goes through this store instead of calling `ApiService` inline.
class AdminAboutStore {
  final loading = Observable(true);
  final saving = Observable(false);
  final successMessage = Observable<String?>(null);
  final errorMessage = Observable<String?>(null);

  final aboutData = Observable<Map<String, dynamic>>(const {});
  final education = ObservableList<EducationModel>.of([]);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final results = await Future.wait([
        ApiService.getAbout(),
        ApiService.getEducation(),
      ]);
      runInAction(() {
        aboutData.value = results[0] as Map<String, dynamic>;
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

  Future<bool> save(Map<String, dynamic> data) async {
    runInAction(() {
      saving.value = true;
      successMessage.value = null;
      errorMessage.value = null;
    });
    try {
      await ApiService.updateAbout(data);
      runInAction(() {
        saving.value = false;
        successMessage.value = 'Salvo com sucesso!';
      });
      return true;
    } catch (e) {
      runInAction(() {
        saving.value = false;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      });
      return false;
    }
  }

  Future<void> _reloadEducation() async {
    final list = await ApiService.getEducation();
    runInAction(() {
      education
        ..clear()
        ..addAll(list.map((j) => EducationModel.fromJson(j as Map<String, dynamic>)));
    });
  }

  Future<void> createEducation(Map<String, dynamic> data) async {
    await ApiService.createEducation(data);
    await _reloadEducation();
  }

  Future<void> updateEducation(int id, Map<String, dynamic> data) async {
    await ApiService.updateEducation(id, data);
    await _reloadEducation();
  }

  Future<void> deleteEducation(int id) async {
    await ApiService.deleteEducation(id);
    await _reloadEducation();
  }
}
