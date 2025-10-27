import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../app/core/network/api_client.dart';
import '../app/core/network/api_util.dart';
import '../app/data/repositories/auth_repository.dart';
import '../app/features/bloc/app_cubit.dart';
import '../app/features/ui/splash/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ** network */
  sl.registerLazySingleton<ApiUtil>(() => ApiUtil.instance);
  sl.registerLazySingleton<Dio>(() => sl<ApiUtil>().dio);
  sl.registerLazySingleton<ApiClient>(() => sl<ApiUtil>().apiClient);

  //*** BLOC */
  sl.registerLazySingleton<AppCubit>(
          () => AppCubit(authRepository: sl())
  );
  sl.registerLazySingleton<SplashCubit>(() => SplashCubit(authRepository: sl()));

  //** Repository */
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
}