import 'projects_store.dart';
import 'skills_store.dart';
import 'experience_store.dart';
import 'services_store.dart';
import 'contact_store.dart';
import 'auth_store.dart';

class AppStores {
  static final AppStores _instance = AppStores._();
  factory AppStores() => _instance;
  AppStores._();

  final projects = ProjectsStore();
  final skills = SkillsStore();
  final experience = ExperienceStore();
  final services = ServicesStore();
  final contact = ContactStore();
  final auth = AuthStore();
}
