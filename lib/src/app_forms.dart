import 'package:app_forms/app_forms.dart';

final Map<String, AppForm> _forms = {};
final Map<String, bool> _initForms = {};

class AppForms<T extends AppForm> {
  static injectForms(List<AppForm> formsList) {
    for (var form in formsList) {
      _forms[form.runtimeType.toString()] = form;
    }
  }

  static T get<T extends AppForm>() {
    if (_forms.containsKey(T.toString())) {
      T form = _forms[T.toString()] as T;
      if (!_initForms.containsKey(T.toString())) {
        form.onInit();
        _initForms[T.toString()] = true;
      }
      return form;
    }
    throw Exception("Form ${T.toString()} Not Found");
  }

  static void dispose<T extends AppForm>() {
    _initForms.remove(T.toString());
  }
}
