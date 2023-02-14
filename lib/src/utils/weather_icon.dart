String weatherIcon(String condition) {
  switch (condition) {
    case 'Thunderstorm':
      return 'assets/icons/weather_rain.png';
    case 'Drizzle':
      return 'assets/icons/weather_rain.png.png';
    case 'Rain':
      return 'assets/icons/weather_rain.png';
    case 'Snow':
      return 'assets/icons/weather_snow.png';
    case 'Atmosphere':
      return 'assets/icons/weather_cloud.png';
    case 'Clouds':
      return 'assets/icons/weather_cloud.png';
    case 'Clear':
      return 'assets/icons/weather_sun.png';
    default:
      return 'assets/icons/weather_cloud.png';
  }
}
