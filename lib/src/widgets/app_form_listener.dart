import 'package:app_forms/app_forms.dart';
import 'package:flutter/material.dart';

typedef StateWidgetBuilder<T extends AppForm> = Widget Function(T form);

class AppFormListener<T extends AppForm> extends StatelessWidget {
  final StateWidgetBuilder<T> builder;
  AppFormListener({super.key, required this.builder}) {
    AppForms.get<T>().listener = this;
  }
  late void Function(void Function()) setState;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, void Function(void Function()) setState) {
        this.setState = setState;
        return builder(AppForms.get<T>());
      },
    );
  }

  void update() {
    setState(() => {});
  }
}
