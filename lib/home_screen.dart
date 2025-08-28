// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'results_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<List<dynamic>> fetchSalaryData() async {
    const url = 'https://raw.githubusercontent.com/yourusername/salarycheck/main/data/salary_data.json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sources']['reddit'] + data['sources']['x'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _searchSalary() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final rawData = await fetchSalaryData();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(query: query, rawData: rawData),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Could not load salary data. Check your connection.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SalaryCheck"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "See what people *really* earn",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "e.g. Frontend Developer, Berlin, 3 years",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) => _searchSalary(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchSalary,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Check Salary", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 16),
            if (_loading) CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  _error,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Spacer(),
            Opacity(
              opacity: 0.7,
              child: Text(
                "Based on real public posts • Anonymous • No login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }
}