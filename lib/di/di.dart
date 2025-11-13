import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/repositories/attendance_repository.dart';
import 'package:pm_app/app/data/repositories/check_in_repository.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/check_in_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/staff/bottom_sheet/employee_filter_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_cubit.dart';
import '../app/core/network/api_client.dart';
import '../app/core/network/api_util.dart';
import '../app/data/repositories/auth_repository.dart';
import '../app/features/bloc/app_cubit.dart';
import '../app/features/ui/splash/splash_cubit.dart';
import '../app/features/ui/account/account_cubit.dart';
import '../app/features/ui/account/changepassword/change_password_cubit.dart';
import 'package:pm_app/app/config/app_env.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ** NETWORK **
  sl.registerLazySingleton<ApiUtil>(() => ApiUtil.instance);
  sl.registerLazySingleton<Dio>(() {
    final dio = sl<ApiUtil>().dio;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final tokenEntity = await SharedPrefsHelper.getToken();
            final token = tokenEntity?.accessToken;

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            options.headers['Content-Type'] = 'application/json';
          } catch (e) {
            print('⚠️ Không thể lấy token: $e');
          }

          return handler.next(options);
        },
      ),
    );
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🔹 $obj'),
    ));

    return dio;
  });
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<Dio>(),
      baseUrl: Environment.prod.baseUrl,
    ),
  );

  // *** BLOC ***
  sl.registerLazySingleton<AppCubit>(
    () => AppCubit(authRepository: sl(), userRepository: sl()),
  );
  sl.registerLazySingleton<SplashCubit>(
    () => SplashCubit(authRepository: sl()),
  );
  sl.registerLazySingleton<LogInCubit>(
    () => LogInCubit(authRepository: sl()),
  );
  sl.registerLazySingleton<OnLeaveCubit>(
    () => OnLeaveCubit(repository: sl()),
  );
  sl.registerLazySingleton<DetailOnLeaveCubit>(
    () => DetailOnLeaveCubit(repository: sl()),
  );
  sl.registerLazySingleton<CreateOnLeaveCubit>(
    () => CreateOnLeaveCubit(repository: sl()),
  );
  sl.registerLazySingleton<CheckInCubit>(
    () => CheckInCubit(checkInRepository: sl()),
  );
  sl.registerLazySingleton<StaffCubit>(
    () => StaffCubit(repository: sl()),
  );
  sl.registerLazySingleton<EmployeeFilterCubit>(
    () => EmployeeFilterCubit(),
  );

  sl.registerLazySingleton<AttendanceDataCubit>(
        () => AttendanceDataCubit(repository: sl()),
  );

  // ** Repository **
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<OnLeaveRepository>(
    () => OnLeaveRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CheckInRepository>(
    () => CheckInRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(sl()));

  // ** Account **
  sl.registerLazySingleton<AccountCubit>(
    () => AccountCubit(sl()),
  );
  sl.registerLazySingleton<ChangePasswordCubit>(
    () => ChangePasswordCubit(userRepository: sl()),
  );
  sl.registerFactory<PersonalCubit>(
    () => PersonalCubit(userRepository: sl()),
  );
}
