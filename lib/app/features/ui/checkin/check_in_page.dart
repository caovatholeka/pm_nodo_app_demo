import 'dart:async';

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
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {

  final _cubit = GetIt.I.get<CheckInCubit>();
  final _appCubit = GetIt.I.get<AppCubit>();

  // google maps
  late GoogleMapController mapController;

  StreamSubscription? _locationSubscription;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void _requestLocationPermission() async {
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

      _locationSubscription = Geolocator.getPositionStream().listen((event) {
        // _cubit.onChangeAddress(event);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _requestLocationPermission();
    // _cubit.getTeachCheckInInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckInCubit,CheckInState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.getCheckInfo != cur.getCheckInfo,
        listener: (context,state) {

        },
        builder: (context,state){
          return Scaffold(
            appBar: AppBar(
              title: Text("Chấm công"),
            ),
            body: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: _bodyContent,
            )
          );
        });
  }

  get _bodyContent{
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 7,
              child: _mapWidget
          ),
          Expanded(
              flex: 3,
              child: _checkInfoWidget
          ),
        ],
      ),
    );
  }

  get _mapWidget {
    var marker = Marker(
      markerId: const MarkerId('place_name'),
      position: LatLng(21.011427,105.787951),
    );
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                21.011427,105.787951
              ),
              zoom: 16.0,
            ),
            markers: <Marker>{marker},
            myLocationButtonEnabled: false,
            buildingsEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: false
        ),
      ),
      // child: BlocBuilder<CheckInCubit,CheckInState>(
      //     bloc: _cubit,
      //     buildWhen: (prev,cur) => prev.position != cur.position,
      //     builder: (context,state){
      //       if (state.position != null) {
      //         var marker = Marker(
      //           markerId: const MarkerId('place_name'),
      //           position: LatLng(state.position!.latitude,
      //               state.position!.longitude),
      //         );
      //         return ClipRRect(
      //           borderRadius: BorderRadius.circular(12.0),
      //           child: GoogleMap(
      //               onMapCreated: _onMapCreated,
      //               initialCameraPosition: CameraPosition(
      //                 target: LatLng(
      //                   state.position!.latitude,
      //                   state.position!.longitude,
      //                 ),
      //                 zoom: 16.0,
      //               ),
      //               markers: <Marker>{marker},
      //               myLocationButtonEnabled: false,
      //               buildingsEnabled: false,
      //               zoomControlsEnabled: false,
      //               myLocationEnabled: true,
      //               mapToolbarEnabled: false,
      //               compassEnabled: false
      //           ),
      //         );
      //       }
      //       return SizedBox(child: Center(child: CircularProgressIndicator(),),);
      //     }),
    );
  }

  get _checkInfoWidget {
    return BlocBuilder<CheckInCubit,CheckInState>(
        bloc: _cubit,
        // buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
        //     prev.currentCheckInEntity != cur.currentCheckInEntity,
        builder: (context,state){
          return Container(
            color: Colors.white,
            height:double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 38,),
                _currentTimeSec,
                const SizedBox(height: 30,),
                // // (state.currentCheckInEntity?.checkinAt != null) ?
                // // _buttonCheckOut:
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
        // buildWhen: (prev,cur) => prev.listCheckInfos != cur.listCheckInfos ||
        //     prev.currentCheckInEntity != cur.currentCheckInEntity,
        builder: (context,state){
          return Padding(padding: const EdgeInsets.only(left: 38,right: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateFormat('H:mm').format(DateTime.now()),
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.themeBlackDefault
                  ),),
                const SizedBox(width: 38,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cong ty Nodo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.themeBlackDefault,
                      ),),
                    Text("So 8 Pham Hung",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.themeBlackDefault,
                      ),),
                    // Text("",
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w400,
                    //     color: AppColors.themeBlackDefault,
                    //   ),),
                  ],
                )
              ],
            ),
          );
        });
  }

  get _buttonCheckIn{
    return BlocBuilder<CheckInCubit,CheckInState>(
      bloc: _cubit,
      // buildWhen: (prev,cur) => prev.currentCheckInEntity != cur.currentCheckInEntity
      //     || prev.checkInStatus != cur.checkInStatus,
      builder: (context,state){
        final isLoading = state.checkInStatus == LoadStatus.LOADING;
        return Padding(
          padding: const EdgeInsets.only(left: 55,right: 55),
          child: PrimaryButton(
            callback: isLoading
                ? null
                : () async{
              // doCheckIn();
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

                // doCheckIn();
              }
            },
            isLoading: isLoading,
            // mainText: state.currentCheckInEntity?.checkinAt != null ?
            // context.loc.check_out : context.loc.check_in,
            mainText: "check in",
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

              // doCheckout(context);
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

                // doCheckout(context);
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
}
