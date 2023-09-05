import 'bloc_provider.dart';

abstract class FtBaseBloc extends BlocBase {
  final errorToastStreamCtrl = BlocStreamController<String>();

  @override
  void dispose() {
    errorToastStreamCtrl.close();
    onDispose();
  }

  void onDispose();
}
