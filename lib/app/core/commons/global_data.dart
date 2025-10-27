import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/entities/token_entity.dart';

class GlobalData {
  GlobalData._privateConstructor() {}

  static final GlobalData instance = GlobalData._privateConstructor();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  TokenEntity? token;

  String? devicesToken;

  Position? currentLocation;


}