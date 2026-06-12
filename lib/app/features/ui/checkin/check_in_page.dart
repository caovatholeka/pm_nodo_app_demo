import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/core/utils/widget_to_marker.dart';
import 'package:pm_app/app/data/models/entities/check_in_info_entity.dart';
import 'package:pm_app/app/data/models/entities/check_in_out_entity.dart';
import 'package:pm_app/app/features/ui/checkin/face_attendance_page.dart';
import 'package:pm_app/app/features/ui/checkin/widget/my_map_marker.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/square_avatar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/utils/utils.dart';
import '../../widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/primary_button.dart';
import 'bloc/check_in_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/commons/app_colors.dart';

class CheckInPage extends StatefulWidget {
  final bool? isFromHome;
  const CheckInPage({super.key, this.isFromHome});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _cubit = GetIt.I.get<CheckInCubit>();
  final _appCubit = GetIt.I.get<AppCubit>();
  CheckInOutEntity? _pendingAttendanceResult;

  String actionCheckIn = "";

  GoogleMapController? _mapController;
  Set<Marker> oldMarkers = {};
  final MapType _mapType = MapType.terrain;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  StreamSubscription? _locationSubscription;

  static const LatLng _defaultLng = LatLng(21.027763, 105.834160); // Hà Nội
  bool _movedToGpsOnce = false;

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    logger.d("_onMapCreated ::: load map thanh cong!!!!");
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _moveCameraToCurrentPlace();
    // });
    await _mapController!.moveCamera(
      CameraUpdate.newLatLngZoom(_defaultLng, 13),
    );

    final p = _cubit.state.position;
    if (p != null && !_movedToGpsOnce) {
      _movedToGpsOnce = true;
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 15),
      );
    }
  }

  void _initMapRenderer() {
    // final GoogleMapsFlutterPlatform mapsImplementation =
    //     GoogleMapsFlutterPlatform.instance;
    // if (mapsImplementation is GoogleMapsFlutterAndroid) {
    //   mapsImplementation.useAndroidViewSurface = true;
    // }
  }

  Future<void> _requestLocationPermission() async {
    final s = S.of(context);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.check_in_condition),
          backgroundColor: Colors.orange,
        ),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.check_in_permissionWarning),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //         "Quyền vị trí bị từ chối vĩnh viễn. Vui lòng bật lại trong Cài đặt."),
      //     backgroundColor: Colors.redAccent,
      //   ),
      // );
      // await openAppSettings();
      showLocationSettingPopup();
      return;
    }

    if (Platform.isIOS) {
      final accuracyStatus = await Geolocator.getLocationAccuracy();
      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: "PreciseLocation",
        );
      }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _cubit.onChangeAddress(pos);
    } catch (_) {
      // nếu timeout thì vẫn nghe stream
    }
    _listenLocation();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onInit();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onInit() async {
    await _ensureUserProfileReady(showLoading: false);
    await _requestLocationPermission();
    _initMapRenderer();
    _movedToGpsOnce = false;
    _cubit.getListCheckInInfo();
  }

  Future<void> _onRefresh() async {
    await _ensureUserProfileReady(showLoading: false);
    await _requestLocationPermission();
    _cubit.getListCheckInInfo();
  }

  Future<bool> _ensureUserProfileReady({bool showLoading = true}) async {
    if (GlobalData.instance.userProfile?.employeeId != null) {
      return true;
    }

    if (showLoading && mounted) {
      LoadingOverlay.show(context);
    }

    try {
      final profile = await _appCubit.getProfile(forceRefresh: true);
      return profile?.employeeId != null;
    } finally {
      if (showLoading && mounted) {
        LoadingOverlay.hide(context);
      }
    }
  }

  Future<bool> _guardUserProfileReady() async {
    final ready = await _ensureUserProfileReady();
    if (ready) {
      return true;
    }

    if (mounted) {
      AppSnackBar.showError(
        title: S.of(context).check_in_failed,
        message:
            "Thông tin người dùng chưa sẵn sàng. Vui lòng thử lại sau ít giây.",
      );
    }
    return false;
  }

  void _finishAttendanceFlow() {
    if (!(widget.isFromHome ?? false) || !mounted) {
      return;
    }

    Navigator.pop(context, _pendingAttendanceResult);
  }

  Future _initMarkers(List<CheckInInfoEntity> listCheckins) async {
    _markers.clear();
    final markerFutures =
        listCheckins.map((checkin) async {
          final icon =
              await MyMapMarker(infoEntity: checkin).toBitmapDescriptor();
          return Marker(
            markerId: MarkerId(checkin.id.toString()),
            position: LatLng(checkin.latitude ?? 0.0, checkin.longitude ?? 0.0),
            icon: icon,
            onTap: () {
              // show thong tin
              logger.d("dia chi check in ::: ${checkin.name}");
            },
          );
        }).toList();

    final circleFutures =
        listCheckins.map((checkin) async {
          final r = (checkin.radius ?? 0.0).toDouble();
          return Circle(
            circleId: CircleId('c_${checkin.id}'),
            center: LatLng(checkin.latitude ?? 0.0, checkin.longitude ?? 0.0),
            radius: Platform.isIOS ? r + 30 : r,
            strokeWidth: 2,
            strokeColor: Color(0xFFCE0000).withOpacity(0.2),
            fillColor: Color(0xFFCE0000).withOpacity(0.2),
          );
        }).toList();

    final newMarkers = Set<Marker>.from(await Future.wait(markerFutures));
    final newCircles = Set<Circle>.from(await Future.wait(circleFutures));

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _circles = newCircles;
      });
      // setState(() => _markers = newMarkers);
    }
  }

  void _listenLocation() {
    _locationSubscription?.cancel();
    LocationSettings locationSettings;

    if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      // Giữ nguyên cho Android như cũ
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _cubit.onChangeAddress(position);
    });
  }

  // Helpers
  String todayFormatted({Locale? locale, DateTime? now}) {
    final DateTime d = now ?? DateTime.now();
    final String lang = (locale?.languageCode ?? 'en').toLowerCase();
    final String prefix = (lang == 'vi') ? 'Hôm nay' : 'Today';

    final String dateStr = DateFormat(
      'd/M/yyyy',
      lang == 'vi' ? 'vi' : 'en',
    ).format(d);

    return '$prefix, $dateStr';
  }

  Future<void> _moveCameraToCurrentPlace() async {
    if (!mounted) return;
    if (_mapController == null) return;

    final state = _cubit.state;

    final e =
        state.currentCheckInEntity ??
        (state.listCheckInfos != null && state.listCheckInfos!.isNotEmpty
            ? state.listCheckInfos!.first
            : null);

    if (e == null) {
      if (state.position != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                state.position!.latitude,
                state.position!.longitude,
              ),
              zoom: 16,
            ),
          ),
        );
      }
      return;
    }

    final target = LatLng(e.latitude ?? 0.0, e.longitude ?? 0.0);
    final radius = (e.radius ?? 100.0);

    final zoom = _zoomForRadius(radius);

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (err, st) {
      logger.e("moveCamera error: $err\n$st");
    }
  }

  double _zoomForRadius(double radiusMeters) {
    if (radiusMeters <= 0) radiusMeters = 200;

    final scale = radiusMeters / 500;
    final zoom = 15 - (math.log(scale) / math.ln2);

    return zoom.clamp(12.0, 19.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<CheckInCubit, CheckInState>(
      bloc: _cubit,
      buildWhen:
          (prev, cur) =>
              prev.getCheckInfo != cur.getCheckInfo ||
              prev.listCheckInfos != cur.listCheckInfos ||
              prev.currentCheckInEntity != cur.currentCheckInEntity ||
              prev.hasLateOrEarly != cur.hasLateOrEarly,

      listenWhen: (prev, cur) {
        return prev.getCheckInfo != cur.getCheckInfo ||
            prev.checkInStatus != cur.checkInStatus ||
            prev.updateExplain != cur.updateExplain ||
            prev.checkOutStatus != cur.checkOutStatus;
      },

      listener: (context, state) async {
        if (state.checkInStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          _pendingAttendanceResult = state.checkInOutResponse;

          AppSnackBar.showInfo(
            title: s.check_in_success,
            message:
                "${DateFormat('dd/MM/yyyy H:mm').format(DateTime.now())} - ${state.currentCheckInEntity?.name}",
          );

          _cubit.onResetState();

          if (state.hasLateOrEarly) {
            final String? reason = await showLateEarlyDialog(context);
            if (reason != null) {
              _cubit.updateExplanation(
                reason,
                state.checkInOutResponse?.id ?? 0,
              );
            } else {
              _finishAttendanceFlow();
            }
          } else {
            _finishAttendanceFlow();
          }
        } else if (state.updateExplain == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          AppSnackBar.showInfo(
            title: s.success,
            message: s.check_in_justificationSuccess,
          );

          _cubit.onResetState();
          _finishAttendanceFlow();
        } else if (state.checkInStatus == LoadStatus.FAILURE ||
            state.checkOutStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);

          _cubit.onResetState();

          if ((state.errStatus ?? "").contains("ERROR.")) {
            AppSnackBar.showError(
              title: s.check_in_failed,
              message: state.errMsg,
            );
          } else {
            AppSnackBar.showError(
              title: s.check_in_failed,
              message: s.check_in_timeout,
            );
          }
        } else if (state.getCheckInfo == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);

          await _initMarkers(state.listCheckInfos ?? []);
          await _moveCameraToCurrentPlace();
        } else if (state.getCheckInfo == LoadStatus.LOADING ||
            state.updateExplain == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },

      builder: (context, state) {
        return BlocBuilder<CheckInCubit, CheckInState>(
          bloc: _cubit,
          buildWhen: (prev, cur) => prev.isMapExpanded != cur.isMapExpanded,
          builder: (context, state) {
            return state.isMapExpanded ? _mapZoomFullScreen : _mapNormalScreen;
          },
        );
      },
    );
  }

  get _mapNormalScreen {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: MyAppBar(
        titleAppbar: S.of(context).check_in_title,
        haveBackButton: (widget.isFromHome ?? false) ? true : false,
        haveActionButton: true,
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: _bodyContent,
      ),
    );
  }

  get _mapZoomFullScreen {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            _mapWidget,
            Positioned(
              bottom: 100,
              left: 18,
              right: 18,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: AppColors.whiteColor.withOpacity(0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).check_in_currentLocation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ).paddingOnly(bottom: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.icCheckinPlace,
                                width: 18,
                                height: 22,
                                color: AppColors.themePrimaryDefault,
                              ).paddingOnly(right: 8),
                              Text(
                                _cubit.state.currentCheckInEntity?.name ?? "",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).paddingOnly(bottom: 16),
                    PrimaryButton(
                      callback: () {
                        _cubit.onExpandMap();
                      },
                      mainText: S.of(context).day_off_donebtn,
                    ).paddingOnly(bottom: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  get _bodyContent {
    final s = S.of(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            DateFormat('H:mm a', 'en').format(DateTime.now()),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.colorSuccess500,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: 16),

          // Text("Nhận dạng khuôn mặt",
          //   style: TextStyle(
          //       fontSize: 22,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.themeBlackDefault
          //   ),
          //   textAlign: TextAlign.center,
          // ).paddingOnly(bottom: 12),
          Text(
            "${s.check_in_subtitle} \n "
            "${s.check_in_subtitle2}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ).paddingOnly(bottom: 16),
          SizedBox(
            height: ScreenSize.of(context).height * 0.4,
            width: double.infinity,
            child: _mapWidget,
          ).paddingOnly(bottom: 20),
          BlocBuilder<CheckInCubit, CheckInState>(
            bloc: _cubit,
            buildWhen:
                (prev, cur) =>
                    prev.currentCheckInEntity != cur.currentCheckInEntity,
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.icCheckinPlace,
                    width: 18,
                    height: 22,
                    color: AppColors.themePrimaryDefault,
                  ),
                  const SizedBox(width: 8),
                  (state.currentCheckInEntity?.address ?? "").isNotEmpty
                      ? Flexible(
                        child: Text(
                          "${state.currentCheckInEntity?.name ?? ""} ,${state.currentCheckInEntity?.address ?? ""}",
                          // state.currentCheckInEntity?.name ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      : Flexible(
                        child: Text(
                          s.check_in_timekeeping,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ],
              );
            },
          ),

          // button checkin
          const SizedBox(height: 20),
          BlocBuilder<CheckInCubit, CheckInState>(
            bloc: _cubit,
            buildWhen: (prev, cur) => prev.checkInStatus != cur.checkInStatus,
            builder: (context, state) {
              final isLoading = state.checkInStatus == LoadStatus.LOADING;
              return InkWell(
                onTap:
                    isLoading
                        ? () {}
                        : () {
                          if ((_cubit.state.position?.latitude ?? 0) != 0) {
                            doCheckIn();
                          } else {
                            AppSnackBar.showError(
                              title: "Cảnh báo",
                              message: "Tín hiệu GPS kém",
                            );
                          }
                        },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.themePrimaryDefault,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child:
                      isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.whiteColor,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.camScan,
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                S.of(context).check_in_button,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                ),
              ).paddingOnly(bottom: 16);
            },
          ),
        ],
      ),
    );
  }

  get _mapWidget {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: BlocBuilder<CheckInCubit, CheckInState>(
        bloc: _cubit,
        buildWhen:
            (prev, cur) =>
                prev.position != cur.position ||
                prev.isMapExpanded != cur.isMapExpanded,
        builder: (context, state) {
          final isExpanded = state.isMapExpanded ?? false;

          final LatLng center =
              state.position != null
                  ? LatLng(state.position!.latitude, state.position!.longitude)
                  : _defaultLng;

          Widget mapChild = GoogleMap(
            key: const ValueKey('checkin_map'),
            mapType: _mapType,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: state.position != null ? 16.0 : 13.0,
            ),
            markers: _markers,
            circles: _circles,
            myLocationButtonEnabled: false,
            buildingsEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: state.position != null, // optional
            mapToolbarEnabled: false,
            compassEnabled: false,
          );

          if (!isExpanded) {
            mapChild = ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: mapChild,
            );
          }

          if (state.position != null &&
              _mapController != null &&
              !_movedToGpsOnce) {
            _movedToGpsOnce = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted || _mapController == null) return;
              await _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(state.position!.latitude, state.position!.longitude),
                  16,
                ),
              );
            });
          }

          return Stack(
            children: [
              Positioned.fill(child: mapChild),
              if (!isExpanded)
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () async {
                      await _moveCameraToCurrentPlace();
                      _cubit.onExpandMap();
                    },
                    child: SvgPicture.asset(AppAssets.icExpandOut, width: 24),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /*
  get _mapWidget {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: BlocBuilder<CheckInCubit, CheckInState>(
        bloc: _cubit,
        buildWhen: (prev, cur) =>
        prev.position != cur.position ||
            prev.isMapExpanded != cur.isMapExpanded,
        builder: (context, state) {
          if (state.position == null) {
            // return const Center(child: CircularProgressIndicator());
            return GoogleMap(initialCameraPosition: CameraPosition(
              target: LatLng(
                21.027763,
                105.834160,
              ),
              zoom: 13.0,
            ));
          }

          final isExpanded = state.isMapExpanded ?? false;

          // GoogleMap
          Widget mapChild = GoogleMap(
            key: const ValueKey('checkin_map'),
            mapType: _mapType,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                state.position!.latitude,
                state.position!.longitude,
              ),
              zoom: 13.0,
            ),
            markers: _markers,
            circles: _circles,
            myLocationButtonEnabled: false,
            buildingsEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: false,
          );

          if (!isExpanded) {
            mapChild = ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: mapChild,
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: mapChild),

              if (!isExpanded)
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () async {
                      await _moveCameraToCurrentPlace();
                      _cubit.onExpandMap();
                    },
                    child: SvgPicture.asset(
                      AppAssets.icExpandOut,
                      width: 24,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
   */

  // checkin success
  get _checkInSuccess {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              SvgPicture.asset(
                AppAssets.icCheckinSuccess,
                width: 76,
                height: 76,
              ),
              Text(
                S.of(context).check_in_success,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.themeBlackDefault,
                ),
              ).paddingOnly(bottom: 6, top: 8),
              Text(
                AppDateUtils.getCurrentTimeAM(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.colorSuccess500,
                ),
              ).paddingOnly(bottom: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AvatarSquare(
                          imageUrl:
                              GlobalData.instance.userProfile?.avatarUrl ?? "",
                        ).paddingOnly(right: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GlobalData.instance.userProfile?.name ?? "",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.themeBlackDefault,
                              ),
                            ).paddingOnly(bottom: 5),
                            Text(
                              GlobalData.instance.userProfile?.jobTitle ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral500,
                              ),
                            ).paddingOnly(bottom: 5),
                            Text(
                              GlobalData.instance.userProfile?.employeeCode ??
                                  "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppAssets.icSuccess),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${S.of(context).check_in_sucesssub1} ${S.of(context).check_in_sucesssub2}!",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  get _checkInFailure {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              SvgPicture.asset(
                AppAssets.icCheckinFailed,
                width: 76,
                height: 76,
              ),
              Text(
                S.of(context).check_in_failed,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.themeBlackDefault,
                ),
              ).paddingOnly(bottom: 6, top: 8),
              Text(
                AppDateUtils.getCurrentTimeAM(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textRed,
                ),
              ).paddingOnly(bottom: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AvatarSquare(
                          imageUrl:
                              GlobalData.instance.userProfile?.avatarUrl ?? "",
                        ).paddingOnly(right: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GlobalData.instance.userProfile?.name ?? "",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.themeBlackDefault,
                              ),
                            ).paddingOnly(bottom: 5),
                            Text(
                              GlobalData.instance.userProfile?.jobTitle ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral500,
                              ),
                            ).paddingOnly(bottom: 5),
                            Text(
                              GlobalData.instance.userProfile?.employeeCode ??
                                  "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppAssets.icFailed),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).check_in_codition_failed,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // get _checkInfoWidget {
  //   return BlocBuilder<CheckInCubit,CheckInState>(
  //       bloc: _cubit,
  //       buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
  //           prev.currentCheckInEntity != cur.currentCheckInEntity ||
  //           prev.checkInStatus != cur.checkInStatus ||
  //           prev.checkOutStatus != cur.checkOutStatus ||
  //           prev.actionCheck != cur.actionCheck,
  //       builder: (context,state){
  //         return Container(
  //           color: Colors.white,
  //           height:double.infinity,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const SizedBox(height: 30,),
  //               _currentTimeSec,
  //               const SizedBox(height: 20,),
  //               // ((state.actionCheck ?? "").isNotEmpty) ?
  //               //  _buttonCheckOut:
  //               _buttonCheckIn,
  //               const SizedBox(height: 10,),
  //             ],
  //           )
  //         );
  //       });
  // }

  // get _currentTimeSec{
  //   return BlocBuilder<CheckInCubit,CheckInState>(
  //       bloc: _cubit,
  //       buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
  //           prev.currentCheckInEntity != cur.currentCheckInEntity,
  //       builder: (context,state){
  //         return Padding(padding: const EdgeInsets.only(left: 16,right: 16),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Expanded(
  //                 flex: 5,
  //                 child: Column(
  //                   children: [
  //                     Text(DateFormat('H:mm').format(DateTime.now()),
  //                       style: TextStyle(
  //                           fontSize: 35,
  //                           fontWeight: FontWeight.w600,
  //                           color: AppColors.themeBlackDefault
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                     Text(todayFormatted(locale: const Locale('vi')),
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w400,
  //                           color: AppColors.themeBlackDefault
  //                       ),
  //                       maxLines: 3,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // const SizedBox(width: 30,),
  //               Expanded(
  //                 flex: 5,
  //                 child: Column(
  //                   // crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(state.currentCheckInEntity?.name ?? "",
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w700,
  //                         color: AppColors.themeBlackDefault,
  //                       ),),
  //                     Text("",
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w400,
  //                         color: AppColors.themeBlackDefault,
  //                       ),),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  // get _buttonCheckIn{
  //   return BlocBuilder<CheckInCubit,CheckInState>(
  //     bloc: _cubit,
  //     buildWhen: (prev,cur) => prev.currentCheckInEntity != cur.currentCheckInEntity
  //         || prev.checkInStatus != cur.checkInStatus,
  //     builder: (context,state){
  //       final isLoading = state.checkInStatus == LoadStatus.LOADING;
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 55,right: 55),
  //         child: PrimaryButton(
  //           callback: isLoading ? null
  //           : () async {
  //             bool serviceEnabled;
  //             LocationPermission permission;
  //             serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //             if (!serviceEnabled) {
  //               openAppSettings();
  //             } else {
  //               permission = await Geolocator.checkPermission();
  //               if (permission == LocationPermission.denied) {
  //                 permission = await Geolocator.requestPermission();
  //                 if (permission == LocationPermission.denied) {
  //                   openAppSettings();
  //                 }
  //               }
  //               if (permission == LocationPermission.deniedForever) {
  //                 openAppSettings();
  //               }
  //
  //               doCheckIn();
  //             }
  //           },
  //           isLoading: isLoading,
  //           mainText: "Chấm công",
  //           style: TextStyle(
  //               fontSize: 15,
  //               fontWeight: FontWeight.w500,
  //               color: AppColors.whiteColor
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // dialog giai trinh

  /*
  Future<String?> showLateEarlyDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    final reasonKey = GlobalKey<FormState>();
    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) {
          final mediaQuery = MediaQuery.of(dialogContext);
          final keyboardHeight = mediaQuery.viewInsets.bottom;
          final screenHeight = mediaQuery.size.height;

          final dialogMaxHeight = keyboardHeight > 0
              ? (screenHeight - keyboardHeight - 24)
              : (screenHeight * 0.60);

          return PopScope(
            canPop: true,
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: dialogMaxHeight < 260 ? 260 : dialogMaxHeight,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    16 + (keyboardHeight > 0 ? 12 : 0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        S.of(dialogContext).check_in_late_early,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        S.of(dialogContext).check_in_lateReason,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: reasonKey,
                        child: InputTextField(
                          title: "",
                          disableTitle: true,
                          hintText: S.of(dialogContext).check_in_enterReason,
                          isRequiredField: true,
                          enable: true,
                          maxLine: 3,
                          controller: reasonController,
                          onChange: (_) {
                            reasonKey.currentState?.validate();
                          },
                          validator: (val) =>
                              Validator.validateEmpty(val, "Lý do"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          final reasonValid =
                              reasonKey.currentState?.validate() ?? false;
                          if (reasonValid) {
                            final reason = reasonController.text.trim();
                            // dùng ctx hiện tại để pop dialog
                            Navigator.of(dialogContext).pop(reason);
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.themePrimaryDefault,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          S.of(context).check_in_sendExplantation,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      return result;
    } finally {
      reasonController.dispose();
    }
  }

   */

  Future<String?> showLateEarlyDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    final reasonKey = GlobalKey<FormState>();

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);
        final keyboardHeight = mediaQuery.viewInsets.bottom;
        final screenHeight = mediaQuery.size.height;

        final dialogMaxHeight =
            keyboardHeight > 0
                ? (screenHeight - keyboardHeight - 24)
                : (screenHeight * 0.60);

        return StatefulBuilder(
          builder: (ctx, setState) {
            return PopScope(
              canPop: true,
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: dialogMaxHeight < 260 ? 260 : dialogMaxHeight,
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        16 + (keyboardHeight > 0 ? 12 : 0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            S.of(context).check_in_late_early,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            S.of(context).check_in_lateReason,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),

                          //TextFiled lý do
                          Form(
                            key: reasonKey,
                            child: InputTextField(
                              title: "",
                              disableTitle: true,
                              hintText: S.of(context).check_in_enterReason,
                              isRequiredField: true,
                              enable: true,
                              maxLine: 3,
                              controller: reasonController,
                              onChange: (val) {
                                reasonKey.currentState?.validate();
                              },
                              validator:
                                  (val) =>
                                      Validator.validateEmpty(val, "Lý do"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              final reasonValid =
                                  reasonKey.currentState?.validate() ?? false;
                              if (reasonValid) {
                                final reason = reasonController.text.trim();
                                // dùng ctx hiện tại để pop dialog
                                Navigator.of(ctx).pop(reason);
                              }
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: AppColors.themePrimaryDefault,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              S.of(context).check_in_sendExplantation,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Functions
  showLocationSettingPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   "Quyền vị trí",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.w700,
                //     fontStyle: FontStyle.normal,
                //     color: AppColors.themeBlackDefault,
                //   ),
                // ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).check_in_requirement,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: AppColors.themeBlackDefault,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          S.of(context).check_in_later, //context.loc.cancel,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            color: AppColors.themeBlackDefault,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.themePrimaryDefault,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          S
                              .of(context)
                              .check_in_goSetting, //context.loc.check_out,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  doCheckIn() async {
    if (!await _guardUserProfileReady()) {
      return;
    }

    if ((_cubit.state.position?.latitude ?? 0) == 0) {
      AppSnackBar.showError(
        title: "Cáº£nh bÃ¡o",
        message: "TÃ­n hiá»‡u GPS kÃ©m",
      );
      return;
    }

    // Validate
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // open popup
      logger.d("service not enabled");
      showLocationSettingPopup();
      // openAppSettings();
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showLocationSettingPopup();
          logger.d("service is denied");
          // openAppSettings();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        showLocationSettingPopup();
        logger.d("service is deniedForever");
        // openAppSettings();
      } else {
        // check vị trí
        double distance = Utils().calcDistanceMetersGeolocator(
          _cubit.state.position?.latitude ?? 0.0,
          _cubit.state.position?.longitude ?? 0.0,
          _cubit.state.currentCheckInEntity?.latitude ?? 0.0,
          _cubit.state.currentCheckInEntity?.longitude ?? 0.0,
        );
        if (distance.round() >
            (_cubit.state.currentCheckInEntity?.radius ?? 100.0).round() +
                100) {
          AppSnackBar.showError(
            title: "Cảnh báo",
            message: "Bạn đang không trong vị trí được phép Check-In",
          );
        } else {
          // validate khuôn mặt
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaceAttendancePage()),
          );

          if (result != null && result.toString().isNotEmpty) {
            // call api checking
            _cubit.doCheckInGps(result);
          }
        }
      }
    }
  }

  // doCheckOut() async{
  //   // check vị trí
  //   double distance = Utils().calcDistanceMetersGeolocator(
  //       _cubit.state.position?.latitude ?? 0.0,
  //       _cubit.state.position?.longitude ?? 0.0,
  //       _cubit.state.currentCheckInEntity?.latitude ?? 0.0,
  //       _cubit.state.currentCheckInEntity?.longitude ?? 0.0);
  //   if(distance.round() + 5 > (_cubit.state.currentCheckInEntity?.radius ?? 100.0).round()){
  //     AppSnackBar.showError(title: "Cảnh báo",message: "Bạn đang không trong vị trí được phép Check-Out");
  //   }else{
  //     // validate khuôn mặt
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => const FaceAttendancePage()),
  //     );
  //
  //     if (result != null && result.toString().isNotEmpty) {
  //       _cubit.doCheckOutGps(result);
  //     }
  //   }
  // }
}
