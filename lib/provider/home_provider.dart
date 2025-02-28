import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../model/weather_model.dart';
import '../repo/home_repo.dart';

final homePod = ChangeNotifierProvider<HomeProvider>((ref) {
  return HomeProvider();
});

class HomeProvider extends ChangeNotifier {
//This function will get the current Latitude and Longitude for futhur API call
  String lat = "";
  String log = "";

  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

// Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.checkPermission();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    await Geolocator.getCurrentPosition().then(
      (value) {
        lat = value.latitude.toString();
        log = value.longitude.toString();
        notifyListeners();
        getWeatheData();
      },
    );
  }

//This function will fetch the current weather data as per the Latitude and Longitude
  final _homeRepository = HomeRepository();
  Weather? weatherModel;
  Future getWeatheData() async {
    final response =
        await _homeRepository.getWeatherData(latitude: lat, longitude: log);
    if (response.statusCode == 200) {
      weatherModel = weatherFromJson(response.body);
      notifyListeners();
    } else {
      debugPrint("Error in fetching Data");
    }
  }
}
