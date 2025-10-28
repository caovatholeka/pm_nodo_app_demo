import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/on_leave_cubit.dart';
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
  sl.registerLazySingleton<OnLeaveCubit>(() => OnLeaveCubit(repository: sl()));
  sl.registerLazySingleton<CreateOnLeaveCubit>(() => CreateOnLeaveCubit(repository: sl()));

  //** Repository */
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<OnLeaveRepository>(() => OnLeaveRepositoryImpl(sl()));
}