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
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/entities/check_in_info_entity.dart';
import 'package:pm_app/app/features/ui/checkin/face_attendance_page.dart';
import 'package:pm_app/app/features/ui/checkin/widget/my_map_marker.dart';
import 'package:pm_app/app/features/widgets/cached_image_widget.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/utils/utils.dart';
import '../../widgets/app_snackbar.dart';
import 'face_scan_page.dart';
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
  const CheckInPage({super.key,this.isFromHome});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {

  final _cubit = GetIt.I.get<CheckInCubit>();
  final _appCubit = GetIt.I.get<AppCubit>();

  String actionCheckIn = "";

  // google maps
  late GoogleMapController mapController;
  Set<Marker> oldMarkers = {};
  MapType _mapType = MapType.terrain;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  StreamSubscription? _locationSubscription;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    // await _fitToAllCheckIn();
  }

Future<void> _requestLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Vui lòng bật dịch vụ định vị (GPS)."),
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
        const SnackBar(
          content: Text("Quyền vị trí bị từ chối. Không thể xác định vị trí."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            "Quyền vị trí bị từ chối vĩnh viễn. Vui lòng bật lại trong Cài đặt."),
        backgroundColor: Colors.redAccent,
      ),
    );
    await openAppSettings();
    return;
  }
  _locationSubscription?.cancel();

  _locationSubscription = Geolocator.getPositionStream().listen((event) {
    _cubit.onChangeAddress(event);
  });
}


  @override
  void initState() {
    _requestLocationPermission();
    _cubit.getListCheckInInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _requestLocationPermission();
    _cubit.getListCheckInInfo();
  }

  Future _initMarkers(List<CheckInInfoEntity> listCheckins) async {
    _markers.clear();
    final markerFutures = listCheckins.map((checkin) async {
      final icon = await MyMapMarker(infoEntity: checkin).toBitmapDescriptor();
      return Marker(
        markerId: MarkerId(checkin.id.toString()),
        position: LatLng(checkin.latitude ?? 0.0, checkin.longitude ?? 0.0),
        icon: icon,
        onTap: () {
          // _showBottomSheet(product, product.propertyUnit?.totalListing ?? 0);
          // show thong tin
          logger.d("dia chi check in ::: ${checkin.name}");
        },
      );
    }).toList();

    final circleFutures = listCheckins.map((checkin) async {
      return Circle(
        circleId: CircleId('c_${checkin.id}'),
        center: LatLng(checkin.latitude ?? 0.0, checkin.longitude ?? 0.0),
        radius: 300.0, //checkin.radius ?? 0.0,       // mét
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.15),
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

  // Helpers
  String todayFormatted({Locale? locale, DateTime? now}) {
    final DateTime d = now ?? DateTime.now();
    final String lang = (locale?.languageCode ?? 'en').toLowerCase();
    final String prefix = (lang == 'vi') ? 'Hôm nay' : 'Today';

    final String dateStr = DateFormat('d/M/yyyy', lang == 'vi' ? 'vi' : 'en')
        .format(d);

    return '$prefix, $dateStr';
  }

  Future<void> _fitToAllCheckIn() async {
    if ((_cubit.state.listCheckInfos ?? []).isEmpty) return;

    double minLat = (_cubit.state.listCheckInfos ?? []).first.latitude ?? 0.0;
    double maxLat = (_cubit.state.listCheckInfos ?? []).first.latitude ?? 0.0;
    double minLng = (_cubit.state.listCheckInfos ?? []).first.longitude ?? 0.0;
    double maxLng = (_cubit.state.listCheckInfos ?? []).first.longitude ?? 0.0;

    for (final s in (_cubit.state.listCheckInfos ?? [])) {
      minLat = math.min(minLat, s.latitude);
      maxLat = math.max(maxLat, s.latitude);
      minLng = math.min(minLng, s.longitude);
      maxLng = math.max(maxLng, s.longitude);
    }

    // Tạo bounds thô theo tâm
    var bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Animate camera theo bounds với padding
    final padding = 16.0;
    try {
      await mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (_) {
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng((_cubit.state.listCheckInfos ?? []).first.latitude ?? 0.0,
            (_cubit.state.listCheckInfos ?? []).first.longitude ?? 0.0),
          zoom: _zoomForRadius((_cubit.state.listCheckInfos ?? []).first.radius ?? 0.0),
        )),
      );
    }
  }

  double _zoomForRadius(double radiusMeters) {
    double km = (radiusMeters <= 0) ? 0.001 : (radiusMeters / 1000.0);
    final z = 16.5 - (math.log(km) / math.log(2));
    return z.clamp(3.0, 21.0).toDouble();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckInCubit,CheckInState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.getCheckInfo != cur.getCheckInfo ||
          prev.listCheckInfos != cur.listCheckInfos ||
        prev.currentCheckInEntity != cur.currentCheckInEntity ||
        prev.hasLateOrEarly != cur.hasLateOrEarly,
        listener: (context,state) async {
          if(state.getCheckInfo == LoadStatus.LOADING ||
              state.updateExplain == LoadStatus.LOADING){
            LoadingOverlay.show(context);
          }if(state.getCheckInfo == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            _initMarkers(state.listCheckInfos ?? []);
          }
          else if(state.checkInStatus == LoadStatus.SUCCESS){
            _cubit.onResetState();
            AppSnackBar.showInfo(title: "Chấm công thành công",message:
              "${DateFormat('dd/MM/yyyy H:mm').format(DateTime.now())}- ${state.currentCheckInEntity?.name} ");
            // check chấm công muộn sớm
            if(state.hasLateOrEarly){
              final String? reason = await showLateEarlyDialog(context);
              if (reason != null) {
                _cubit.updateExplanation(reason,
                  state.checkInOutResponse?.id ?? 0);
              }
            }
          }else if(state.checkOutStatus == LoadStatus.SUCCESS){
            _cubit.onResetState();
            AppSnackBar.showInfo(title:"Chấm công thành công",message:  "${state.checkInOutResponse?.datetime} - ${state.currentCheckInEntity?.name} ");
          }
          else if(state.updateExplain == LoadStatus.SUCCESS){
            _cubit.onResetState();
            AppSnackBar.showInfo(title:"Thành Công",message: "Giải trình công thành công");
          }
          else if(state.checkInStatus == LoadStatus.FAILURE ||
              state.checkOutStatus == LoadStatus.FAILURE){
            _cubit.onResetState();
            if((state.errStatus ?? "").contains("ERROR.")){
              AppSnackBar.showError(title: "Chấm công thất bại",message: state.errMsg);
            }else{
              AppSnackBar.showError(title: "Chấm công thất bại",message: "Máy chủ đang bận, vui lòng thử lại sau");
            }
          }
          else{
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state){
          return BlocBuilder<CheckInCubit,CheckInState>(
              bloc: _cubit,
              buildWhen: (prev,cur) => prev.isMapExpanded != cur.isMapExpanded,
              builder: (context,state){
                return state.isMapExpanded ?
                _mapZoomFullScreen :
                _mapNormalScreen;
              });

        });
  }

  get _mapNormalScreen {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chấm công"),
          flexibleSpace: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.appbarBg),
                fit: BoxFit.fill,
              ),
            ),
          ),
          leading: (widget.isFromHome ?? false)
              ? IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: Image.asset(
              AppAssets.ic_arrowB,
              width: 30,
              height: 30,
            ),
          ) : const SizedBox(),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.bodyColor,
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: _bodyContent
          ),
        )
    );
  }
  get _mapZoomFullScreen{
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
                          Text("Vị trí đã chọn",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600
                            ),).paddingOnly(bottom: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.icCheckinPlace,width: 18,height: 22,
                                color: AppColors.themePrimaryDefault,).paddingOnly(right: 8),
                              Text(_cubit.state.currentCheckInEntity?.name ?? "",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400
                                ),),
                            ],
                          )
                        ],
                      ),
                    ).paddingOnly(bottom: 16),
                    PrimaryButton(
                      callback: (){
                        _cubit.onExpandMap();
                      },
                        mainText: "Xong").paddingOnly(bottom: 20)
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  get _bodyContent{
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12,),
          Text(DateFormat('H:mm a').format(DateTime.now()),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.colorSuccess500
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: 16),
         InkWell(
           onTap: (){
             // thuc hien check in
             doCheckIn();
           },
           child: SvgPicture.asset(AppAssets.camScan,width: 80,height: 80,),
         ).paddingOnly(bottom: 16),

          Text("Nhận dạng khuôn mặt",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.themeBlackDefault
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: 12),
          Text("Đảm bảo bạn đang ở văn phòng và nơi có đủ ảnh sáng \n "
              "để nhận diện được khuôn mặt một cách tối ưu",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral400
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ).paddingOnly(bottom: 16),
          SizedBox(
            height: ScreenSize.of(context).height*0.4,
              width: double.infinity,
              child: _mapWidget
          ).paddingOnly(bottom: 16),
          BlocBuilder<CheckInCubit,CheckInState>(
              bloc: _cubit,
              buildWhen: (prev,cur) => prev.currentCheckInEntity != cur.currentCheckInEntity,
              builder: (context,state){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.icCheckinPlace,width: 18,height: 22,
                      color: AppColors.themePrimaryDefault,),
                    const SizedBox(width: 8,),
                    Text(state.currentCheckInEntity?.name ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),)
                  ],
                );
              })

        ],
      ),
    );
  }
  get _mapWidget {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: BlocBuilder<CheckInCubit,CheckInState>(
          bloc: _cubit,
          buildWhen: (prev,cur) => prev.position != cur.position ||
            prev.isMapExpanded != cur.isMapExpanded,
          builder: (context,state){
            if (state.position != null) {
              var marker = Marker(
                markerId: const MarkerId('place_name'),
                position: LatLng(state.position!.latitude,
                    state.position!.longitude),
              );
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: GoogleMap(
                        key: ValueKey(LatLng(state.position?.latitude ?? 0.0, state.position?.longitude ?? 0.0)),
                        mapType: _mapType,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            state.position!.latitude,
                            state.position!.longitude,
                          ),
                          zoom: 15.0,
                        ),
                        markers: _markers,
                        // circles: _circles,
                        myLocationButtonEnabled: false,
                        buildingsEnabled: false,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        mapToolbarEnabled: false,
                        compassEnabled: false
                    ),
                  ),
                  !(state.isMapExpanded ?? false) ?
                  Positioned(
                      top: 12,
                      right: 12,
                      child: InkWell(
                        onTap: (){
                          _cubit.onExpandMap();
                        },
                        child: SvgPicture.asset(AppAssets.icExpandOut,width: 24,),
                      )) : const SizedBox.shrink()
                ],
              );
            }
            return SizedBox(child: Center(child: CircularProgressIndicator(),),);
          }),
    );
  }

  // checkin success
  get _checkInSuccess {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12,),
              SvgPicture.asset(AppAssets.icCheckinSuccess),
              Text("Chấm công thành công",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.themeBlackDefault
                ),
              ).paddingOnly(bottom: 6),
              Text(AppDateUtils.getCurrentTimeAM(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.colorSuccess500
                ),
              ).paddingOnly(bottom: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: CachedImageWidget(urlImage: ""),
                  ).paddingOnly(right: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GlobalData.instance.userProfile?.name ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeBlackDefault
                        ),
                      ).paddingOnly(bottom: 5),
                      Text(
                        GlobalData.instance.userProfile?.jobTitle ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral500
                        ),
                      ).paddingOnly(bottom: 5),
                      Text(
                        GlobalData.instance.userProfile?.employeeCode ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral500
                        ),
                      )
                    ],
                  ),
                  
                  SvgPicture.asset(AppAssets.icSuccess)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  get _checkInfoWidget {
    return BlocBuilder<CheckInCubit,CheckInState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
            prev.currentCheckInEntity != cur.currentCheckInEntity ||
            prev.checkInStatus != cur.checkInStatus ||
            prev.checkOutStatus != cur.checkOutStatus ||
            prev.actionCheck != cur.actionCheck,
        builder: (context,state){
          return Container(
            color: Colors.white,
            height:double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30,),
                _currentTimeSec,
                const SizedBox(height: 20,),
                // ((state.actionCheck ?? "").isNotEmpty) ?
                //  _buttonCheckOut:
                _buttonCheckIn,
                const SizedBox(height: 10,),
              ],
            )
          );
        });
  }

  get _currentTimeSec{
    return BlocBuilder<CheckInCubit,CheckInState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
            prev.currentCheckInEntity != cur.currentCheckInEntity,
        builder: (context,state){
          return Padding(padding: const EdgeInsets.only(left: 16,right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Text(DateFormat('H:mm').format(DateTime.now()),
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            color: AppColors.themeBlackDefault
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(todayFormatted(locale: const Locale('vi')),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.themeBlackDefault
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // const SizedBox(width: 30,),
                Expanded(
                  flex: 5,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.currentCheckInEntity?.name ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.themeBlackDefault,
                        ),),
                      Text("",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.themeBlackDefault,
                        ),),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  get _buttonCheckIn{
    return BlocBuilder<CheckInCubit,CheckInState>(
      bloc: _cubit,
      buildWhen: (prev,cur) => prev.currentCheckInEntity != cur.currentCheckInEntity
          || prev.checkInStatus != cur.checkInStatus,
      builder: (context,state){
        final isLoading = state.checkInStatus == LoadStatus.LOADING;
        return Padding(
          padding: const EdgeInsets.only(left: 55,right: 55),
          child: PrimaryButton(
            callback: isLoading ? null
            : () async {
              bool serviceEnabled;
              LocationPermission permission;
              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                openAppSettings();
              } else {
                permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    openAppSettings();
                  }
                }
                if (permission == LocationPermission.deniedForever) {
                  openAppSettings();
                }

                doCheckIn();
              }
            },
            isLoading: isLoading,
            mainText: "Chấm công",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor
            ),
          ),
        );
      },
    );
  }

  // dialog giai trinh
  Future<String?> showLateEarlyDialog(
      BuildContext context) async {
    final reasonController = TextEditingController();
    final _reasonKey = GlobalKey<FormState>();

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Chấm công muộn/sớm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bạn đã chấm công sớm/muộn, bạn có muốn giải trình ngay không?',
                    style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.35),
                  ),

                  const SizedBox(height: 12),

                  // TextField lý do
                 Form(
                   key: _reasonKey,
                   child: InputTextField(
                       title: "",
                       disableTitle: true,
                       hintText: "Nhập lý do...",
                       isRequiredField: true,
                      enable: true,
                     maxLine: 3,
                     controller: reasonController,
                     onChange: (val){
                       _reasonKey.currentState!.validate();
                     },
                     validator: (val)
                      => Validator.validateEmpty(val, "Lý do"),
                   ),
                 ),

                  const SizedBox(height: 16),

                  FilledButton(
                    onPressed :(){
                      final reasonValid = _reasonKey.currentState?.validate() ?? false;
                      if(reasonValid){
                        String reason = reasonController.text.trim();
                        // Navigator.of(ctx).pop(reason);
                        Navigator.pop(context,reason);
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.themePrimaryDefault,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Giải trình', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),


                  OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Để sau', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }


  get _buttonCheckOut{
    return BlocBuilder<CheckInCubit,CheckInState>(
      bloc: _cubit,
      buildWhen: (prev,cur) => prev.checkOutStatus != cur.checkOutStatus,
      builder: (context,state){
        final isLoading = state.checkOutStatus == LoadStatus.LOADING;
        return Padding(
          padding: const EdgeInsets.only(left: 55,right: 55),
          child: PrimaryButton(
            callback: isLoading
                ? null
                : () async {
              bool serviceEnabled;
              LocationPermission permission;
              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                openAppSettings();
              } else {
                permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    openAppSettings();
                  }
                }
                if (permission == LocationPermission.deniedForever) {
                  openAppSettings();
                }

                doCheckOut();
              }

            },
            isLoading: isLoading,
            mainText: "Check out",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.themeBlackDefault
            ),
          ),
        );
      },
    );
  }

  // Functions
  doCheckIn() async{
    // Validate
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        openAppSettings();
      } else {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            openAppSettings();
          }
        }
        if (permission == LocationPermission.deniedForever) {
          openAppSettings();
        }

        // check vị trí
         double distance = Utils().calcDistanceMetersGeolocator(
            _cubit.state.position?.latitude ?? 0.0,
            _cubit.state.position?.longitude ?? 0.0,
           _cubit.state.currentCheckInEntity?.latitude ?? 0.0,
            _cubit.state.currentCheckInEntity?.longitude ?? 0.0);
        if(distance.round() + 5 > (_cubit.state.currentCheckInEntity?.radius ?? 100.0).round()){
          AppSnackBar.showError(title: "Cảnh báo",message: "Bạn đang không trong vị trí được phép Check-In");
        }else{
          // validate khuôn mặt
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaceAttendancePage()),
          );

          if (result != null && result.toString().isNotEmpty) {
            // call api checking
          logger.d("file Path::: ${result.toString()}" );
          _cubit.doCheckInGps(result);
          }
        }

      }
  }

  doCheckOut() async{
    // check vị trí
    double distance = Utils().calcDistanceMetersGeolocator(
        _cubit.state.position?.latitude ?? 0.0,
        _cubit.state.position?.longitude ?? 0.0,
        _cubit.state.currentCheckInEntity?.latitude ?? 0.0,
        _cubit.state.currentCheckInEntity?.longitude ?? 0.0);
    if(distance.round() + 5 > (_cubit.state.currentCheckInEntity?.radius ?? 100.0).round()){
      AppSnackBar.showError(title: "Cảnh báo",message: "Bạn đang không trong vị trí được phép Check-Out");
    }else{
      // validate khuôn mặt
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FaceAttendancePage()),
      );

      if (result != null && result.toString().isNotEmpty) {
        // call api checking
        logger.d("file Path::: ${result.toString()}" );
        _cubit.doCheckOutGps(result);
      }
    }
  }

}
