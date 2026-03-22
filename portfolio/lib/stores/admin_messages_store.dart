import 'package:mobx/mobx.dart';
import '../services/api_service.dart';

class AdminMessagesStore {
  final messages = ObservableList<Map<String, dynamic>>.of([]);
  final loading = Observable(true);

  Future<void> load() async {
    runInAction(() => loading.value = true);
    try {
      final data = await ApiService.getMessages();
      runInAction(() {
        messages
          ..clear()
          ..addAll(data.map((j) => Map<String, dynamic>.from(j as Map)));
        loading.value = false;
      });
    } catch (_) {
      runInAction(() => loading.value = false);
    }
  }

  Future<void> markRead(int id) async {
    await ApiService.markMessageRead(id);
    await load();
  }

  Future<void> delete(int id) async {
    await ApiService.deleteMessage(id);
    await load();
  }
}
