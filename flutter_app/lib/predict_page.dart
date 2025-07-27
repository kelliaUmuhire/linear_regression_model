// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_app/result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}


class _PredictPageState extends State<PredictPage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown options (example mappings, adjust as needed)

  final offenderStatusMap = {
    'Unknown': 0,
    'Arrested': 1,
    'Not Arrested': 2,
  };
  final raceMap = {
    'White': 0,
    'Black': 1,
    'Asian': 2,
    'Native Hawaiian or Pacific Islander': 3,
    'Unknown': 4,
    'Other': 5,
  };
  final genderMap = {
    'Male': 0,
    'Female': 1,
    'Unknown': 2,
  };
  final categoryMap = {
    'Violence': 1,
    'Theft': 2,
    'Vandalism': 3,
    'Miscellaneous': 4,
    'Other': 5,
  };

  String offenderStatus = 'Unknown';
  String offenderRace = 'White';
  String offenderGender = 'Male';
  String victimRace = 'White';
  String victimGender = 'Male';
  String category = 'Violence';

  String? prediction;
  String? explanation;
  String? error;

  // Actual mean and std values from dataset preprocessing
  final double offenderAgeMean = 32.68695744230362;
  final double offenderAgeStd = 11.635924607314797;
  final double victimAgeMean = 37.23830192674148;
  final double victimAgeStd = 15.66995683147725;

  final ageValidator = (String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final v = double.tryParse(value);
    if (v == null) return 'Must be a number';
    if (v < 0 || v > 120) return 'Must be a realistic age (0-120)';
    return null;
  };

  final offenderAgeController = TextEditingController();
  final victimAgeController = TextEditingController();

  Future<void> predict() async {
    setState(() { prediction = null; error = null; explanation = null; });
    final url = 'https://linear-regression-model-bovf.onrender.com/predict';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'OffenderStatus': offenderStatus,
          'Offender_Race': offenderRace,
          'Offender_Gender': offenderGender,
          'Offender_Age': double.tryParse(offenderAgeController.text) ?? 0.0,
          'Victim_Race': victimRace,
          'Victim_Gender': victimGender,
          'Victim_Age': double.tryParse(victimAgeController.text) ?? 0.0,
          'Category': category,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prediction = data['prediction'].toString();
          explanation = data['explanation']?.toString();
        });
      } else {
        setState(() { error = 'Error: ${response.body}'; });
      }
    } catch (e) {
      setState(() { error = 'Error: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crime Fatality Prediction')),
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: offenderStatus,
                items: offenderStatusMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, overflow: TextOverflow.ellipsis))).toList(),
                decoration: InputDecoration(
                  label: Text('Offender Status', style: TextStyle(overflow: TextOverflow.ellipsis)),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => offenderStatus = v ?? 'Unknown'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: offenderRace,
                items: raceMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: InputDecoration(labelText: 'Offender Race', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => offenderRace = v ?? 'White'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: offenderGender,
                items: genderMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: InputDecoration(labelText: 'Offender Gender', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => offenderGender = v ?? 'Male'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: offenderAgeController,
                decoration: InputDecoration(labelText: 'Offender Age', border: OutlineInputBorder(), helperText: 'Enter actual age (years)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: ageValidator,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: victimRace,
                items: raceMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: InputDecoration(labelText: 'Victim Race', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => victimRace = v ?? 'White'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: victimGender,
                items: genderMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: InputDecoration(labelText: 'Victim Gender', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => victimGender = v ?? 'Male'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: victimAgeController,
                decoration: InputDecoration(labelText: 'Victim Age', border: OutlineInputBorder(), helperText: 'Enter actual age (years)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: ageValidator,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: category,
                items: categoryMap.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                decoration: InputDecoration(labelText: 'Crime Category', border: OutlineInputBorder()),
                onChanged: (v) => setState(() => category = v ?? 'Violence'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await predictMapped();
                      if (prediction != null && explanation != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(prediction: prediction!, explanation: explanation),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Predict', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              if (error != null)
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.red[100],
                  child: Text(error!, style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> predictMapped() async {
    setState(() { prediction = null; error = null; explanation = null; });
    final url = 'https://linear-regression-model-bovf.onrender.com/predict';
    try {
      // Validate age fields before sending
      final offenderAgeRaw = double.tryParse(offenderAgeController.text);
      final victimAgeRaw = double.tryParse(victimAgeController.text);
      if (offenderAgeRaw == null || offenderAgeRaw < 0 || offenderAgeRaw > 120) {
        setState(() { error = 'Offender Age must be a realistic number (0-120)'; });
        return;
      }
      if (victimAgeRaw == null || victimAgeRaw < 0 || victimAgeRaw > 120) {
        setState(() { error = 'Victim Age must be a realistic number (0-120)'; });
        return;
      }
      // Standardize ages
      final offenderAgeStdzd = (offenderAgeRaw - offenderAgeMean) / offenderAgeStd;
      final victimAgeStdzd = (victimAgeRaw - victimAgeMean) / victimAgeStd;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'OffenderStatus': offenderStatusMap[offenderStatus],
          'Offender_Race': raceMap[offenderRace],
          'Offender_Gender': genderMap[offenderGender],
          'Offender_Age': offenderAgeStdzd,
          'Victim_Race': raceMap[victimRace],
          'Victim_Gender': genderMap[victimGender],
          'Victim_Age': victimAgeStdzd,
          'Category': categoryMap[category],
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prediction = data['prediction'].toString();
          explanation = data['explanation']?.toString();
        });
      } else {
        setState(() { error = 'Error: ${response.body}'; });
      }
    } catch (e) {
      setState(() { error = 'Error: $e'; });
    }
  }
}
