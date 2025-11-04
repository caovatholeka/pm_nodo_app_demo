import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import '../../data/models/entities/token_entity.dart';

class GlobalData {
  GlobalData._privateConstructor();

  static final GlobalData instance = GlobalData._privateConstructor();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  TokenEntity? token;

  String? devicesToken;

  Position? currentLocation;

  int? userId;

  ProfileEntity? userProfile;
}