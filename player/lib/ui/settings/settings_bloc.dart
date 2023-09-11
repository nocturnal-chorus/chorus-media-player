import 'package:player/bloc/base_bloc.dart';
import 'package:player/utils/all_utils.dart';

import '../../bloc/bloc_provider.dart';

class FtSettingsBloc extends FtBaseBloc {
  final settingConfigStreamCtrl = BlocStreamController<SettingsConfig>();

  void initial() async {}

  @override
  void onDispose() {
    settingConfigStreamCtrl.close();
  }
}
