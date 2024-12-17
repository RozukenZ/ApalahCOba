import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController extends GetxController {
  var isLoading = true.obs;
  var weatherData = {}.obs;

  @override
  void onInit() {
    fetchWeather();
    super.onInit();
  }

  void fetchWeather() async {
    try {
      isLoading(true);
      // Ganti URL API dengan OpenWeatherMap atau API lainnya
      var response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Jakarta&appid=41f93fb18e42aadea7928ba0a4b6588d&units=metric'));
      if (response.statusCode == 200) {
        weatherData.value = json.decode(response.body);
      } else {
        Get.snackbar('Error', 'Failed to load weather data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }
}
