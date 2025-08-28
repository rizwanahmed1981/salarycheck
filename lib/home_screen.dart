// // home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'results_screen.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _loading = false;
//   String _error = '';

//   // 🔗 Change this to your actual GitHub raw link
//   static const String DATA_URL =
//       'https://raw.githubusercontent.com/rizwanahmed1981/salarycheck/main/data/salary_data.json';

//   /// Fetch salary data from GitHub
//   Future<List<dynamic>> fetchSalaryData() async {
//     try {
//       final uri = Uri.parse(DATA_URL);
//       final response = await http.get(uri);

//       if (response.statusCode == 404) {
//         throw Exception('Data file not found. Did you upload salary_data.json to GitHub?');
//       }

//       if (response.statusCode != 200) {
//         throw Exception('Failed to load data: ${response.statusCode}');
//       }

//       final String body = response.body;
//       if (body.isEmpty) {
//         throw Exception('Empty response from server');
//       }

//       final Map<String, dynamic> data = json.decode(body);

//       // Safely extract sources
//       final reddit = data['sources']?['reddit'] ?? [];
//       final x = data['sources']?['x'] ?? [];

//       if (reddit is! List || x is! List) {
//         throw Exception('Invalid data format: expected lists under "sources"');
//       }

//       // Combine and clean data
//       final List<dynamic> combined = [
//         ...reddit.map((e) => e is Map ? e.cast<String, dynamic>() : {}),
//         ...x.map((e) => e is Map ? e.cast<String, dynamic>() : {}),
//       ];

//       // Remove any entries without essential fields
//       return combined.where((post) {
//         final title = post['title']?.toString().toLowerCase() ?? '';
//         final text = (post['text']?.toString().toLowerCase() ?? '');
//         return title.contains('salary') ||
//             title.contains('offer') ||
//             text.contains('salary') ||
//             text.contains('offer') ||
//             title.contains('pay');
//       }).toList();
//     } catch (e) {
//       // Re-throw with user-friendly message
//       if (e.toString().contains('SocketException')) {
//         throw Exception('No internet connection. Please check your network.');
//       }
//       rethrow;
//     }
//   }

// void _searchSalary() async {
//   // ✅ Declare ONCE at the top
//   final query = _searchController.text.trim();

//   if (query.isEmpty) {
//     setState(() {
//       _error = 'Please enter a search term (e.g., Frontend Developer, Berlin)';
//     });
//     return;
//   }

//   setState(() {
//     _loading = true;
//     _error = '';
//   });

//   try {
//     final rawData = await fetchSalaryData();

//     if (rawData.isEmpty) {
//       setState(() {
//         _error = 'No salary data found. The scraper might still be setting up.';
//       });
//       return;
//     }

//     // ✅ Use the same `query` — no re-declaration
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ResultsScreen(query: query, rawData: rawData),
//       ),
//     );
//   } on Exception catch (e) {
//     setState(() {
//       _error = 'Error: ${e.toString()}';
//     });
//   } catch (e) {
//     setState(() {
//       _error = 'An unexpected error occurred: $e';
//     });
//   } finally {
//     setState(() {
//       _loading = false;
//     });
//   }
// }
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SalaryCheck"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "See what people *really* earn",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 32),
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: "e.g. Frontend Developer, Berlin, 3 years",
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 12),
//               ),
//               textInputAction: TextInputAction.search,
//               onSubmitted: (value) => _searchSalary(),
//             ),
//             SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _searchSalary,
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _loading
//                     ? SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : Text(
//                         "Check Salary",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       ),
//               ),
//             ),
//             SizedBox(height: 16),
//             if (_error.isNotEmpty)
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Text(
//                   _error,
//                   style: TextStyle(color: Colors.red, height: 1.4),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             Spacer(),
//             Opacity(
//               opacity: 0.7,
//               child: Text(
//                 "Based on real public posts • Anonymous • No login",
//                 style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'results_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String _error = '';
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;

  // 🔗 Change this to your actual GitHub raw link
  static const String DATA_URL =
      'https://raw.githubusercontent.com/rizwanahmed1981/salarycheck/main/data/salary_data.json';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _logoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Fetch salary data from GitHub
  Future<List<dynamic>> fetchSalaryData() async {
    try {
      final uri = Uri.parse(DATA_URL);
      final response = await http.get(uri);

      if (response.statusCode == 404) {
        throw Exception('Data file not found. Did you upload salary_data.json to GitHub?');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load ${response.statusCode}');
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

  Widget _buildTrendingSearches() {
    final trending = [
      'Software Engineer, USA, 3 years',
      'UX Designer, Canada, 2 years',
      'Data Scientist, UK, 5 years',
      'Product Manager, Remote',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = trending[index];
                  _searchSalary();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      trending[index],
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonial() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.quoteLeft,
            size: 24,
            color: Color(0xFF4361EE),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"SalaryCheck helped me negotiate a 20% higher salary by showing me what others in my field were making!"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '- Sarah J., Senior Developer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo with subtle animation
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      FontAwesomeIcons.chartLine,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // App title with gradient
                Text(
                  "Know Your Worth",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()..shader = const LinearGradient(
                          colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "See what people *really* earn based on public salary posts",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Search field with icon
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "e.g. Frontend Developer, Berlin, 3 years",
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(FontAwesomeIcons.xmark),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _searchSalary(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Search button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _searchSalary,
                    child: _loading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text("Find My Salary"),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Trending searches
                _buildTrendingSearches(),
                
                const SizedBox(height: 24),
                
                // Testimonial
                _buildTestimonial(),
                
                const SizedBox(height: 32),
                
                // Stats section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("50K+", "Salary Posts", FontAwesomeIcons.database),
                    _buildStatCard("150+", "Cities", FontAwesomeIcons.mapLocationDot),
                    _buildStatCard("30+", "Professions", FontAwesomeIcons.briefcase),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // How it works
                _buildHowItWorks(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

Widget _buildHowItWorks() {
  final steps = [
    {
      'icon': FontAwesomeIcons.reddit as IconData,
      'title': 'Public Posts',
      'description': 'We scan Reddit, X, and LinkedIn for real salary discussions',
    },
    {
      'icon': FontAwesomeIcons.shieldHalved as IconData,
      'title': 'Anonymous Data',
      'description': 'All data is anonymized and aggregated for privacy',
    },
    {
      'icon': FontAwesomeIcons.chartSimple as IconData,
      'title': 'Clear Insights',
      'description': 'Get median salaries, ranges, and trends for your role',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      ...steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,  // Explicit cast
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description'] as String,
                      style: const TextStyle(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  );
}
}