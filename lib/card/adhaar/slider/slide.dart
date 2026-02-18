import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoSliderPage extends StatefulWidget {
  const TwoSliderPage({super.key});

  @override
  State<TwoSliderPage> createState() => _TwoSliderPageState();
}

class _TwoSliderPageState extends State<TwoSliderPage> {
  double hindiFirst = 15;
  double hindiSecond = 32;
  double englishFirst = 15;
  double englishSecond = 32;

  static const String keyHindiFirst = 'hindifirst';
  static const String keyHindiSecond = 'hindisecond';
  static const String keyEnglishFirst = 'englishfirst';
  static const String keyEnglishSecond = 'englishsecond';

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hindiFirst = prefs.getDouble(keyHindiFirst) ?? 15;
      hindiSecond = prefs.getDouble(keyHindiSecond) ?? 32;
      englishFirst = prefs.getDouble(keyEnglishFirst) ?? 15;
      englishSecond = prefs.getDouble(keyEnglishSecond) ?? 32;
    });
  }

  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyHindiFirst, hindiFirst);
    await prefs.setDouble(keyHindiSecond, hindiSecond);
    await prefs.setDouble(keyEnglishFirst, englishFirst);
    await prefs.setDouble(keyEnglishSecond, englishSecond);
  }

  Widget buildSlider({
    required String title,
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.toInt()}'),
        Slider(
          min: 5,
          max: 100,
          divisions: 95,
          value: value,
          label: value.toInt().toString(),
          onChanged: (val) {
            setState(() {
              onChanged(val);
            });
            _saveValues();
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Limits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Default English Address",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 19),),
            ),
            buildSlider(
              title: 'English First Line',
              value: englishFirst,
              onChanged: (v) => englishFirst = v,
            ),
            buildSlider(
              title: 'English Second Line Onwards',
              value: englishSecond,
              onChanged: (v) => englishSecond = v,
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Default Hindi Address",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 19),),
            ),
            buildSlider(
              title: 'Hindi First Line',
              value: hindiFirst,
              onChanged: (v) => hindiFirst = v,
            ),
            buildSlider(
              title: 'Hindi Second Line Onwards',
              value: hindiSecond,
              onChanged: (v) => hindiSecond = v,
            ),
          ],
        ),
      ),
    );
  }
}
