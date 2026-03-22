import 'package:mobx/mobx.dart';
import '../services/api_service.dart';

class AuthStore {
  final loading = Observable(false);
  final error = Observable<String?>(null);

  Future<bool> login(String email, String password) async {
    runInAction(() {
      loading.value = true;
      error.value = null;
    });
    try {
      await ApiService.login(email, password);
      runInAction(() => loading.value = false);
      return true;
    } catch (e) {
      runInAction(() {
        loading.value = false;
        error.value = e.toString().replaceFirst('Exception: ', '');
      });
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
  }
}
