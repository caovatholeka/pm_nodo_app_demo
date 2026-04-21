import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/repositories/attendance_repository.dart';
import 'package:pm_app/app/data/repositories/check_in_repository.dart';
import 'package:pm_app/app/data/repositories/dashboard_repository.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/data/repositories/upload_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';
import 'package:pm_app/app/data/repositories/work_trip_repository.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/apprasial_form_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_cubit.dart';
import 'package:pm_app/app/features/ui/auth/login/login_cubit.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_cubit.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/check_in_cubit.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui/justification/bloc/justification_cubit.dart';
import 'package:pm_app/app/features/ui/justification/bloc/justification_detail_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/detail_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_detail_cubit.dart';
import 'package:pm_app/app/features/ui/staff/bottom_sheet/employee_filter_cubit.dart';
import 'package:pm_app/app/features/ui/staff/employee_detail_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_cubit.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';

import '../app/core/network/api_util.dart';
import '../app/data/repositories/auth_repository.dart';
import '../app/data/repositories/face_id_repository.dart';
import '../app/features/bloc/app_cubit.dart';
import '../app/features/ui/checkin/bloc/face_scan_cubit.dart';
import '../app/features/ui/splash/splash_cubit.dart';
import '../app/features/ui/account/account_cubit.dart';

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

            if (options.data is FormData) {
              options.headers.remove(Headers.contentTypeHeader);
            } else {
              options.headers.putIfAbsent(
                Headers.contentTypeHeader,
                () => Headers.jsonContentType,
              );
            }
          } catch (e) {
            print('⚠️ Không thể lấy token: $e');
          }

          return handler.next(options);
        },
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🔹 $obj'),
      ),
    );

    return dio;
  });
  // sl.registerLazySingleton<ApiClient>(
  //       () => ApiClient(sl<Dio>(), baseUrl: AppConfig.baseUrl),
  // );

  // sl.registerLazySingleton<ApiClientFaceId>(
  //   () => ApiClientFaceId(sl<Dio>(), baseUrl: AppConfig.baseFaceIdUrl),
  // );

  // *** BLOC ***
  sl.registerLazySingleton<AppCubit>(
    () => AppCubit(authRepository: sl(), userRepository: sl()),
  );
  sl.registerLazySingleton<SplashCubit>(
    () => SplashCubit(authRepository: sl(), appCubit: sl()),
  );
  sl.registerLazySingleton<LogInCubit>(() => LogInCubit(authRepository: sl()));
  sl.registerLazySingleton<OnLeaveCubit>(() => OnLeaveCubit(repository: sl()));
  sl.registerLazySingleton<DetailOnLeaveCubit>(
    () => DetailOnLeaveCubit(repository: sl()),
  );
  sl.registerLazySingleton<CreateOnLeaveCubit>(
    () => CreateOnLeaveCubit(repository: sl()),
  );
  sl.registerLazySingleton<CheckInCubit>(
    () => CheckInCubit(checkInRepository: sl()),
  );
  sl.registerLazySingleton<StaffCubit>(() => StaffCubit(repository: sl()));
  sl.registerLazySingleton<EmployeeFilterCubit>(() => EmployeeFilterCubit());

  sl.registerLazySingleton<WorkTripCubit>(
    () => WorkTripCubit(uploadRepo: sl(), tripRepository: sl()),
  );

  sl.registerLazySingleton<AttendanceDataCubit>(
    () => AttendanceDataCubit(repository: sl()),
  );

  // ** Repository **
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<OnLeaveRepository>(() => OnLeaveRepositoryImpl());
  sl.registerLazySingleton<CheckInRepository>(() => CheckInRepositoryImpl());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  sl.registerLazySingleton<EmployeeRepository>(() => EmployeeRepositoryImpl());
  sl.registerLazySingleton<UploadRepository>(() => UploadRepositoryImpl());
  sl.registerLazySingleton<WorkTripRepository>(() => WorkTripRepositoryImpl());

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(),
  );

  // ** Account **
  sl.registerLazySingleton<AccountCubit>(() => AccountCubit(sl()));

  // sl.registerFactory<ChangePasswordCubit>(
  //   () => ChangePasswordCubit(userRepository: sl()),
  // );

  sl.registerFactory<PersonalCubit>(() => PersonalCubit(userRepository: sl()));

  sl.registerLazySingleton<FaceScanCubit>(
    () => FaceScanCubit(faceIdRepository: sl()),
  );

  sl.registerLazySingleton<HomeCubit>(
    () => HomeCubit(userRepository: sl(), taskRepository: sl()),
  );

  sl.registerLazySingleton<ExplanationCubit>(
    () => ExplanationCubit(repository: sl()),
  );

  sl.registerLazySingleton<TaskCubit>(() => TaskCubit(repository: sl()));

  sl.registerLazySingleton<WorkEntryRepository>(
    () => WorkEntryRepositoryImpl(),
  );

  sl.registerLazySingleton<ForgotCubit>(() => ForgotCubit(sl()));

  sl.registerLazySingleton<FaceIdRepository>(() => FaceIdRepositoryImpl());

  sl.registerFactory<OtpVerifyCubit>(() => OtpVerifyCubit(sl()));

  sl.registerFactory<NotiCubit>(() => NotiCubit(userRepository: sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl());

  sl.registerFactory<EmployeeDetailCubit>(
    () => EmployeeDetailCubit(repository: sl<EmployeeRepository>()),
  );

  sl.registerLazySingleton<JustificationCubit>(() => JustificationCubit());

  sl.registerLazySingleton<JustificationDetailCubit>(
    () => JustificationDetailCubit(),
  );
  sl.registerLazySingleton<JutificationRepository>(
    () => JutificationRepositoryImpl(),
  );

  //OT
  sl.registerLazySingleton<OvertimeCubit>(() => OvertimeCubit());
  sl.registerLazySingleton<OvertimeDetailCubit>(() => OvertimeDetailCubit());
  sl.registerLazySingleton<OvertimeRepository>(() => OvertimeRepositoryImpl());
  sl.registerLazySingleton<ApprasialFormCubit>(
    () => ApprasialFormCubit(repository: sl()),
  );
  sl.registerLazySingleton<EvaluationRepository>(
    () => EvaluationRepositoryImpl(),
  );

  sl.registerLazySingleton<CreateAppraisalCubit>(
    () => CreateAppraisalCubit(repository: sl()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(repository: sl()));
}
