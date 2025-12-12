import 'dart:async';
import 'package:dod_partner/login/bloc/login/view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocationService {
  static StreamSubscription<Position>? _locationSubscription;
  static Position? _lastPosition;

  static Future<void> startLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        debugPrint("❌ Location permission not granted.");
        return;
      }
    }

    Position firstPosition = await Geolocator.getCurrentPosition();

    await FirebaseFirestore.instance
        .collection("drivers")
        .doc(UserModel.user.firebaseId)
        .update({
      "lat": firstPosition.latitude,
      "lng": firstPosition.longitude,
      "lastUpdated": DateTime.now().toString(),
      "bearing": 0,
    });

    debugPrint("📍 FIRST update done.");

    _lastPosition = firstPosition;

    // Step 3 — Start continuous stream
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 1,
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) async {

      // Calculate movement
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < 1) {
        // Less than 1 meter → Do NOT update
        return;
      }

      // Update last position
      _lastPosition = position;

      // Update Firestore only after 1 meter
      await FirebaseFirestore.instance
          .collection("drivers")
          .doc(UserModel.user.firebaseId)
          .update({
        "lat": position.latitude,
        "lng": position.longitude,
        "lastUpdated": DateTime.now().toString(),
        "bearing": 0,
      });

      debugPrint(
          "📍 Updated Firestore (moved ${distance.toStringAsFixed(2)} m)");
    });
  }

  static void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
