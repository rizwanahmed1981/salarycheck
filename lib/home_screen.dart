// home_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String _error = '';

  // 🔗 Change this to your actual GitHub raw link
  static const String DATA_URL =
      'https://raw.githubusercontent.com/rizwanahmed1981/salarycheck/main/data/salary_data.json';

  /// Fetch salary data from GitHub
  Future<List<dynamic>> fetchSalaryData() async {
    try {
      final uri = Uri.parse(DATA_URL);
      final response = await http.get(uri);

      if (response.statusCode == 404) {
        throw Exception('Data file not found. Did you upload salary_data.json to GitHub?');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      final String body = response.body;
      if (body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final Map<String, dynamic> data = json.decode(body);

      // Safely extract sources
      final reddit = data['sources']?['reddit'] ?? [];
      final x = data['sources']?['x'] ?? [];

      if (reddit is! List || x is! List) {
        throw Exception('Invalid data format: expected lists under "sources"');
      }

      // Combine and clean data
      final List<dynamic> combined = [
        ...reddit.map((e) => e is Map ? e.cast<String, dynamic>() : {}),
        ...x.map((e) => e is Map ? e.cast<String, dynamic>() : {}),
      ];

      // Remove any entries without essential fields
      return combined.where((post) {
        final title = post['title']?.toString().toLowerCase() ?? '';
        final text = (post['text']?.toString().toLowerCase() ?? '');
        return title.contains('salary') ||
            title.contains('offer') ||
            text.contains('salary') ||
            text.contains('offer') ||
            title.contains('pay');
      }).toList();
    } catch (e) {
      // Re-throw with user-friendly message
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      rethrow;
    }
  }

void _searchSalary() async {
  // ✅ Declare ONCE at the top
  final query = _searchController.text.trim();

  if (query.isEmpty) {
    setState(() {
      _error = 'Please enter a search term (e.g., Frontend Developer, Berlin)';
    });
    return;
  }

  setState(() {
    _loading = true;
    _error = '';
  });

  try {
    final rawData = await fetchSalaryData();

    if (rawData.isEmpty) {
      setState(() {
        _error = 'No salary data found. The scraper might still be setting up.';
      });
      return;
    }

    // ✅ Use the same `query` — no re-declaration
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(query: query, rawData: rawData),
      ),
    );
  } on Exception catch (e) {
    setState(() {
      _error = 'Error: ${e.toString()}';
    });
  } catch (e) {
    setState(() {
      _error = 'An unexpected error occurred: $e';
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SalaryCheck"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "See what people *really* earn",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _searchSalary(),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _searchSalary,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Check Salary",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            SizedBox(height: 16),
            if (_error.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _error,
                  style: TextStyle(color: Colors.red, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            Spacer(),
            Opacity(
              opacity: 0.7,
              child: Text(
                "Based on real public posts • Anonymous • No login",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}