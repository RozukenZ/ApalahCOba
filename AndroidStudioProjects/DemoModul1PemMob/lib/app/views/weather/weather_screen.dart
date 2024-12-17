import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/weather_controller.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherController weatherController = Get.put(WeatherController());

  WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (weatherController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (weatherController.weatherData.isEmpty) {
          return const Center(child: Text('No Data Available'));
        }

        // Extracting weather data for easy use
        var weather = weatherController.weatherData;
        var cityName = weather['name'];
        var temperature = weather['main']['temp'];
        var description = weather['weather'][0]['description'];
        var wind = weather['wind']['speed'];
        var humidity = weather['main']['humidity'];
        var pressure = weather['main']['pressure'];
        var feelsLike = weather['main']['feels_like'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // City Name and Temperature
              Text(
                cityName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$temperature°C',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Divider(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // Weather Description
              Text(
                'Weather: $description',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // Additional weather information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoCard(title: 'Wind', value: '$wind m/s'),
                  InfoCard(title: 'Humidity', value: '$humidity%'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoCard(title: 'Pressure', value: '$pressure hPa'),
                  InfoCard(title: 'Feels Like', value: '$feelsLike°C'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Helper widget to display the weather information in cards
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
