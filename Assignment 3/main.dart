// lib/main.dart
// Single-file lively Weather UI inspired by your image.
// Requires: http, intl in pubspec.yaml

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const BeautifulLiveWeatherApp());
}

class BeautifulLiveWeatherApp extends StatelessWidget {
  const BeautifulLiveWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const WeatherHomeSingleFile(),
    );
  }
}

class WeatherHomeSingleFile extends StatefulWidget {
  const WeatherHomeSingleFile({super.key});

  @override
  State<WeatherHomeSingleFile> createState() => _WeatherHomeSingleFileState();
}

class _WeatherHomeSingleFileState extends State<WeatherHomeSingleFile>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController(text: 'Karachi');
  static const String _apiKey = '2681230852c2f95398b2a92baeaef9e1'; // from you
  WeatherData? _weather;
  bool _loading = false;
  String? _error;

  // Animation controllers
  late final AnimationController _cloudFloatController;
  late final AnimationController _raindropController;
  late final AnimationController _sunRotationController;

  // UI gradient
  List<Color> _bgGradient = [const Color(0xFF512DA8), const Color(0xFF8E24AA)];

  // cached forecast (simple)
  List<ForecastDay> _forecast = [];

  @override
  void initState() {
    super.initState();
    _cloudFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _raindropController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _sunRotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    // initial fetch:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather(_cityController.text);
    });
  }

  @override
  void dispose() {
    _cloudFloatController.dispose();
    _raindropController.dispose();
    _sunRotationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // map simple main -> gradient
  List<Color> _gradientFor(String main, double temp) {
    final m = main.toLowerCase();
    if (m.contains('clear')) {
      if (temp > 24) return [const Color(0xFFFFB347), const Color(0xFFFF5E62)]; // warm orange
      return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]; // cool blue
    } else if (m.contains('cloud')) {
      return [const Color(0xFF2b5876), const Color(0xFF4e4376)]; // purple-blue
    } else if (m.contains('rain') || m.contains('drizzle')) {
      return [const Color(0xFF0f2027), const Color(0xFF2c5364)]; // stormy
    } else if (m.contains('snow')) {
      return [const Color(0xFF83a4d4), const Color(0xFFb6fbff)]; // icy
    } else if (m.contains('mist') || m.contains('haze') || m.contains('fog')) {
      return [const Color(0xFF616161), const Color(0xFF9bc5c3)];
    } else {
      return [const Color(0xFF3a6073), const Color(0xFF16222A)];
    }
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Current weather
      final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': city,
        'appid': _apiKey,
        'units': 'metric',
      });

      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        final map = jsonDecode(resp.body);
        throw Exception(map['message'] ?? 'Failed to fetch weather');
      }
      final current = jsonDecode(resp.body) as Map<String, dynamic>;
      final wd = WeatherData.fromJson(current);

      // 7-day forecast using One Call (requires lat/lon and maybe different endpoint)
      // We will call the "forecast/daily" alternative: use "onecall" via lat/lon if permitted.
      final lat = wd.lat.toString();
      final lon = wd.lon.toString();
      final fUri = Uri.https('api.openweathermap.org', '/data/2.5/onecall', {
        'lat': lat,
        'lon': lon,
        'exclude': 'minutely,hourly,alerts',
        'appid': _apiKey,
        'units': 'metric',
      });

      final fResp = await http.get(fUri).timeout(const Duration(seconds: 12));
      List<ForecastDay> forecast = [];
      if (fResp.statusCode == 200) {
        final fmap = jsonDecode(fResp.body) as Map<String, dynamic>;
        final List<dynamic> daily = fmap['daily'] ?? [];
        forecast = daily.take(7).map((d) => ForecastDay.fromJson(d as Map<String, dynamic>)).toList();
      } else {
        // fallback: empty forecast
        forecast = [];
      }

      final grad = _gradientFor(wd.main, wd.temp);

      setState(() {
        _weather = wd;
        _forecast = forecast;
        _bgGradient = grad;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // small helper for formatted date
  String _formatTime() => DateFormat('EEE, d MMM • hh:mm a').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // top bar
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Weather Forecasts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [const Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 3))],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _cityController.text = 'Islamabad';
                        _fetchWeather('Islamabad');
                      },
                      icon: const Icon(Icons.location_city, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // search and input
                Row(
                  children: [
                    Expanded(
                      child: _buildSearchBox(),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      ),
                      onPressed: _loading ? null : () => _fetchWeather(_cityController.text.trim()),
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                          : const Text('Get', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // large weather card area with animated decorations
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Big lively card with 3D-ish icon + house image + stats
                        SizedBox(
                          height: media.height * 0.48,
                          child: Stack(
                            children: [
                              // frosted card
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                      child: Column(
                                        children: [
                                          // city + time + temp row
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _weather?.cityName ?? 'Search a city',
                                                      style: const TextStyle(
                                                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      _formatTime(),
                                                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // temperature large
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _weather != null ? '${_weather!.temp.toStringAsFixed(1)}°C' : '--°C',
                                                    style: const TextStyle(
                                                        fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    _weather?.description ?? '—',
                                                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // lively icon + house / illustration area
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                // subtle glowing circle behind icon
                                                Positioned(
                                                  left: 20,
                                                  top: 6,
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 900),
                                                    width: 160,
                                                    height: 160,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: RadialGradient(
                                                        colors: [
                                                          Colors.white.withOpacity(0.12),
                                                          Colors.white.withOpacity(0.02)
                                                        ],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white.withOpacity(0.06),
                                                          blurRadius: 40,
                                                          spreadRadius: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // cloud floating (animated)
                                                Positioned(
                                                  left: 20 + (_cloudFloatController.value * 8),
                                                  top: 10 + (sin(_cloudFloatController.value * pi * 2) * 6),
                                                  child: Opacity(
                                                    opacity: 0.98,
                                                    child: SizedBox(
                                                      width: 140,
                                                      height: 120,
                                                      child: _LivelyCloud(
                                                        main: _weather?.main ?? 'Clear',
                                                        iconCode: _weather?.icon ?? '01d',
                                                        sunRotAnim: _sunRotationController,
                                                        rainAnim: _raindropController,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // little house illustration (using simple container)
                                                Positioned(
                                                  right: 18,
                                                  bottom: 12,
                                                  child: Transform.rotate(
                                                    angle: -0.04,
                                                    child: Container(
                                                      width: 140,
                                                      height: 110,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.house, size: 36, color: Colors.white.withOpacity(0.95)),
                                                            const SizedBox(height: 8),
                                                            Text('Today', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                                            const SizedBox(height: 6),
                                                            Text(
                                                              _weather != null ? '${_weather!.temp.toStringAsFixed(0)}°C' : '--°C',
                                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          // mini stats row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _miniStat('Humidity', _weather != null ? '${_weather!.humidity}%' : '--'),
                                              _miniStat('Wind', _weather != null ? '${_weather!.windSpeed} m/s' : '--'),
                                              _miniStat('Feels', _weather != null ? '${_weather!.feelsLike.toStringAsFixed(1)}°C' : '--'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // small top-left decorative bubble
                              Positioned(
                                left: 6,
                                top: 6,
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.06),
                                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  child: const Icon(Icons.wb_sunny_outlined, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 7-day forecast picker style
                        SizedBox(
                          height: 130,
                          child: _forecast.isEmpty ? _emptyForecastRow() : _buildForecastRow(),
                        ),

                        const SizedBox(height: 18),

                        // extra info cards (air quality, sunrise/uv)
                        Row(
                          children: [
                            Expanded(child: _infoCard('Air Quality', '3 - Low Health Risk')),
                            const SizedBox(width: 10),
                            Expanded(child: _infoCard('UV Index', '4 Moderate')),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // footer small note
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            _weather != null ? 'Last updated ${DateFormat('hh:mm a').format(DateTime.now())}' : 'No data',
                            style: TextStyle(color: Colors.white.withOpacity(0.85)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // small widgets
  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _cityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter city (e.g., Lahore)',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onSubmitted: (s) {
                if (s.trim().isNotEmpty) _fetchWeather(s.trim());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75))),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _infoCard(String title, String content) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(content, style: TextStyle(color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _emptyForecastRow() {
    return Center(
      child: Text(
        _loading ? 'Loading forecast...' : (_error ?? 'No forecast data'),
        style: TextStyle(color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  Widget _buildForecastRow() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _forecast.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final f = _forecast[i];
        final day = DateFormat('E').format(DateTime.fromMillisecondsSinceEpoch(f.dt * 1000));
        return Container(
          width: 92,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.02)]),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 6))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
              // small icon using network icon
              Image.network(
                'https://openweathermap.org/img/wn/${f.icon}@2x.png',
                width: 46,
                height: 46,
                errorBuilder: (_, __, ___) => const Icon(Icons.cloud, color: Colors.white70),
              ),
              Text('${f.max.toStringAsFixed(0)}°', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${f.min.toStringAsFixed(0)}°', style: TextStyle(color: Colors.white.withOpacity(0.75))),
            ],
          ),
        );
      },
    );
  }
}

// -------------------- small localized models --------------------

class WeatherData {
  final String cityName;
  final String main;
  final String description;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String icon;
  final int pressure;
  final double lat;
  final double lon;

  WeatherData({
    required this.cityName,
    required this.main,
    required this.description,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.pressure,
    required this.lat,
    required this.lon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List<dynamic>?)?.first as Map<String, dynamic>? ?? {};
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final coord = json['coord'] as Map<String, dynamic>? ?? {};
    return WeatherData(
      cityName: json['name'] ?? 'Unknown',
      main: (weather['main'] ?? 'Clear').toString(),
      description: (weather['description'] ?? '').toString(),
      temp: (main['temp'] ?? 0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: (main['humidity'] ?? 0).toInt(),
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      icon: (weather['icon'] ?? '01d').toString(),
      pressure: (main['pressure'] ?? 0).toInt(),
      lat: (coord['lat'] ?? 0).toDouble(),
      lon: (coord['lon'] ?? 0).toDouble(),
    );
  }
}

class ForecastDay {
  final int dt;
  final double min;
  final double max;
  final String icon;

  ForecastDay({required this.dt, required this.min, required this.max, required this.icon});

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List<dynamic>?)?.first as Map<String, dynamic>? ?? {};
    final temp = json['temp'] as Map<String, dynamic>? ?? {};
    return ForecastDay(
      dt: (json['dt'] ?? 0).toInt(),
      min: (temp['min'] ?? 0).toDouble(),
      max: (temp['max'] ?? 0).toDouble(),
      icon: (weather['icon'] ?? '01d').toString(),
    );
  }
}

// -------------------- animated cloud + rain widget --------------------

class _LivelyCloud extends StatelessWidget {
  final String main;
  final String iconCode;
  final AnimationController sunRotAnim;
  final AnimationController rainAnim;

  const _LivelyCloud({
    required this.main,
    required this.iconCode,
    required this.sunRotAnim,
    required this.rainAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isRain = main.toLowerCase().contains('rain') || main.toLowerCase().contains('drizzle') || main.toLowerCase().contains('thunder');
    final isClear = main.toLowerCase().contains('clear');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // sun behind if clear
        if (isClear)
          Positioned(
            left: -28,
            top: -18,
            child: RotationTransition(
              turns: sunRotAnim,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.yellow.withOpacity(0.95), Colors.orange.withOpacity(0.4)]),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.18), blurRadius: 22, spreadRadius: 6)],
                ),
              ),
            ),
          ),

        // main cloud shape
        Positioned(
          left: 20,
          top: 18,
          child: CustomPaint(
            size: const Size(120, 80),
            painter: _CloudPainter(),
          ),
        ),

        // weather icon from openweathermap (fallback)
        Positioned(
          left: 36,
          top: 4,
          child: Image.network(
            'https://openweathermap.org/img/wn/$iconCode@2x.png',
            width: 62,
            height: 62,
            errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 62, color: Colors.white70),
          ),
        ),

        // raindrops animation if raining
        if (isRain)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RainPainter(anim: rainAnim, dropColor: Colors.lightBlueAccent.withOpacity(0.9)),
              ),
            ),
          ),
      ],
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.95);
    final p2 = Paint()..color = Colors.white.withOpacity(0.08);

    // main cloud blobs
    final r1 = RRect.fromRectAndRadius(Rect.fromLTWH(8, 26, 80, 36), const Radius.circular(30));
    canvas.drawRRect(r1, paint);

    canvas.drawCircle(Offset(42, 20), 22, paint);
    canvas.drawCircle(Offset(72, 26), 18, paint);

    // subtle shadow under cloud
    canvas.drawOval(Rect.fromLTWH(18, 52, 92, 10), p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RainPainter extends CustomPainter {
  final AnimationController anim;
  final Color dropColor;
  _RainPainter({required this.anim, required this.dropColor}) : super(repaint: anim);

  final Random _rnd = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dropColor;
    final t = anim.value;

    // draw several animated drops under cloud region
    final startX = 32.0;
    final endX = 140.0;
    final dropCount = 6;
    for (int i = 0; i < dropCount; i++) {
      final phase = ((i / dropCount) + t) % 1.0;
      final x = startX + (endX - startX) * (i / (dropCount - 1));
      final y = 40 + (phase * 36);
      final len = 8 + (phase * 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, y, 6, len), const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}
