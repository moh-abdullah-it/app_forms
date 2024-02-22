import 'package:app_forms/app_forms.dart';

final Map<String, AppForm> _forms = {};

class AppForms<T extends AppForm> {
  static injectForms(List<AppForm> formsList) {
    for (var form in formsList) {
      _forms[form.runtimeType.toString()] = form;
    }
  }

  static T get<T extends AppForm>() {
    if (_forms.containsKey(T.toString())) {
      return _forms[T.toString()] as T;
    }
    throw Exception("Form ${T.toString()} Not Found");
  }
}
