import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/check_in_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/my_app_bar.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {

  final _cubit = GetIt.I.get<CheckInCubit>();

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
            appBar: MyAppBar(titleAppbar: "Chấm công",
              haveBackButton: true,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.appBg),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 120,),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _bodyContent,
                          const SizedBox(height: 32,)
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  get _bodyContent{
    return RefreshIndicator(
      onRefresh: _onRefresh,
    );
  }
}
