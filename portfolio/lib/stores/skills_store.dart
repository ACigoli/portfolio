import 'package:mobx/mobx.dart';
import '../models/skill_model.dart';
import '../services/api_service.dart';

class SkillsStore {
  final items = ObservableList<SkillModel>.of([]);
  final loading = Observable(true);
  final selectedCategory = Observable('');
  final animated = Observable(false);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getSkills();
      runInAction(() {
        items
          ..clear()
          ..addAll(
              data.map((j) => SkillModel.fromJson(j as Map<String, dynamic>)));
        if (items.isNotEmpty && selectedCategory.value.isEmpty) {
          selectedCategory.value = items.first.category;
        }
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  void selectCategory(String cat) {
    runInAction(() {
      selectedCategory.value = cat;
      animated.value = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      runInAction(() => animated.value = true);
    });
  }

  List<String> get categories =>
      items.map((s) => s.category).toSet().toList();

  List<SkillModel> get filtered {
    if (selectedCategory.value.isEmpty) return [];
    return items.where((s) => s.category == selectedCategory.value).toList();
  }
}
