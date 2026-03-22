import 'package:mobx/mobx.dart';
import '../services/api_service.dart';

class ContactStore {
  final sending = Observable(false);
  final submitted = Observable(false);
  final apiError = Observable<String?>(null);

  Future<bool> submit(String name, String email, String message) async {
    runInAction(() {
      sending.value = true;
      apiError.value = null;
    });
    try {
      await ApiService.sendMessage(name, email, message);
      runInAction(() {
        sending.value = false;
        submitted.value = true;
      });
      return true;
    } catch (e) {
      runInAction(() {
        sending.value = false;
        apiError.value = e.toString().replaceFirst('Exception: ', '');
      });
      return false;
    }
  }

  void reset() {
    runInAction(() {
      submitted.value = false;
      apiError.value = null;
    });
  }
}
