import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  // Initializing main screen variables
  final TextEditingController userIdController = TextEditingController();
  StreamSubscription<Position>? positionStream;
  SharedPreferences? prefs;
  LatLng? myLocation;
  String? userId = '';

  bool isLoading = true;

  // Initializing map screen variables
  late GoogleMapController controller;
  bool isMapLoading = true;
  double distance = 0.0;
  LatLng mainLocation = const LatLng(11.3215292, 75.9967841);
  LatLng? targetLocation;
  MapType currentMapType = MapType.normal;

  // Get current location of user
  void getCurrentLocation() async {
    // ignore: unused_local_variable
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    myLocation = location;
    isLoading = false;
    notifyListeners();
  }

  // Add user Id to database and also to shared preference
  setLocation() async {
    try {
      prefs = await SharedPreferences.getInstance();
      await prefs?.setString('userId', userIdController.text);
      if (userIdController.text == '') {
        print('user id should not be empty');
      } else {
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(userIdController.text)
            .set({
          'name': userIdController.text,
          'latitude': myLocation!.latitude,
          'longitude': myLocation!.longitude,
        });
        print('added to database');
        userIdController.text = '';
        userId = prefs?.getString('userId');
        notifyListeners();
      }
    } catch (err) {
      print(err);
      notifyListeners();
    }
    notifyListeners();
  }

  // Enable live location of user
  enableLiveLocation() async {
    prefs = await SharedPreferences.getInstance();
    String? userId = prefs?.getString('userId');
    print(userId);
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) {
      FirebaseFirestore.instance.collection('locations').doc(userId).set({
        'name': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      }, SetOptions(merge: true)).catchError((err) {
        print(err);
        positionStream?.cancel();
        positionStream = null;
        notifyListeners();
      });
    });
    print('live position: $positionStream');
  }

  // disable live location of user
  disableLiveLocation() async {
    positionStream?.cancel();
    positionStream = null;
    print('disabled live location');
    notifyListeners();
  }

  // Add user id to shared preferences
  setUserId() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs?.getString('userId');
  }

  // Remove user id to shared preferences
  resetUserId() async {
    prefs = await SharedPreferences.getInstance();
    await prefs?.remove('userId');
    print('removed user id');
    notifyListeners();
  }

  // Set user location which used for map screen
  setTargetLocation(latitude, longitude) {
    targetLocation = LatLng(latitude, longitude);
  }

  /// Map Screen Methods ///

  // Assigning controller
  void onMapCreated(GoogleMapController controller) {
    controller = controller;
  }

  // Switch normal view to satellite view
  switchMapViews() {
    currentMapType =
        currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    notifyListeners();
  }

  // Get distance b/w main location and target/user location
  getDistance() async {
    // distance
    double totalDistance = 0;
    totalDistance = Geolocator.distanceBetween(
        mainLocation.latitude,
        mainLocation.longitude,
        targetLocation!.latitude,
        targetLocation!.longitude);

    distance = totalDistance / 1000;
    isMapLoading = false;
    notifyListeners();
  }
}
