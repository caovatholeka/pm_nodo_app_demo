import 'package:flutter_bloc/flutter_bloc.dart';
import 'fire_base_analystic.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    FirebaseAnalysticService.recordError(error, stackTrace, fatal: false);
  
  FirebaseAnalysticService.log(
    bloc.runtimeType.toString(),
  );

  super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    FirebaseAnalysticService.log(
      '${bloc.runtimeType}- ${transition.event.runtimeType}'
    );

    super.onTransition(bloc, transition);
  }
}
