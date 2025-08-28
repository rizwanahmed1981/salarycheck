// // lib/results_screen.dart
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ResultsScreen extends StatelessWidget {
//   final String query;
//   final List<dynamic> rawData;

//   ResultsScreen({required this.query, required this.rawData});

//   List<Map<String, dynamic>> _filterResults() {
//     final lowerQuery = query.toLowerCase();
//     final keywords = lowerQuery.split(',').map((s) => s.trim()).toList();

//     // Simple filtering: match any keyword in title/text
//     return rawData
//         .where((post) {
//           final content = '${post['title']} ${post['text'] ?? ''}'.toLowerCase();
//           return keywords.any((k) => content.contains(k));
//         })
//         .map((post) {
//           // Extract salary-like pattern (e.g., $85k, €72,000)
//           final salaryMatch = RegExp(r'(\$\d+[kM]?|\€\d+(?:,\d{3})?)').firstMatch(
//             '${post['title']} ${post['text']}',
//           );
//           final salary = salaryMatch?.group(0) ?? 'Not specified';

//           return {
//             'title': keywords.firstWhere((k) => k.contains('developer') || k.contains('engineer'), orElse: () => 'Role'),
//             'location': keywords.firstWhere((k) => k.contains('city') || k.length > 2, orElse: () => 'Unknown'),
//             'experience': keywords.firstWhere((k) => k.contains('year'), orElse: () => 'Any'),
//             'salary': salary,
//             'source': post['subreddit'] ?? 'X',
//             'snippet': post['text']?.length > 120
//                 ? '${post['text'].substring(0, 120)}...'
//                 : post['text'] ?? '',
//             'url': post['url'],
//           };
//         })
//         .take(10)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final results = _filterResults();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Results for \"$query\""),
//         leading: BackButton(),
//       ),
//       body: results.isEmpty
//           ? Center(child: Text("No salary data found for this search."))
//           : ListView.separated(
//               padding: EdgeInsets.all(12),
//               itemCount: results.length,
//               separatorBuilder: (_, __) => Divider(),
//               itemBuilder: (context, i) {
//                 final data = results[i];
//                 return ListTile(
//                   title: Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("${data['location']} • ${data['experience']}"),
//                       SizedBox(height: 4),
//                       Text("💰 ${data['salary']} • via ${data['source']}"),
//                       SizedBox(height: 6),
//                       Text(data['snippet'], maxLines: 2, overflow: TextOverflow.ellipsis),
//                     ],
//                   ),
//                   trailing: Icon(Icons.open_in_new, size: 16),
//                   onTap: () async {
//                     final uri = Uri.parse(data['url']);
//                     if (await canLaunchUrl(uri)) {
//                       await launchUrl(uri);
//                     }
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }

// lib/results_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResultsScreen extends StatelessWidget {
  final String query;
  final List<dynamic> rawData;

  ResultsScreen({required this.query, required this.rawData});

  List<Map<String, dynamic>> _filterResults() {
    final lowerQuery = query.toLowerCase();
    final keywords = lowerQuery.split(',').map((s) => s.trim()).toList();

    // Simple filtering: match any keyword in title/text
    return rawData
        .where((post) {
          final content = '${post['title']} ${post['text'] ?? ''}'.toLowerCase();
          return keywords.any((k) => content.contains(k));
        })
        .map((post) {
          // Extract salary-like pattern (e.g., $85k, €72,000)
          final salaryMatch = RegExp(r'(\$\d+[kM]?|\€\d+(?:,\d{3})?)').firstMatch(
            '${post['title']} ${post['text']}',
          );
          final salary = salaryMatch?.group(0) ?? 'Not specified';

          // Extract experience from query
          String experience = 'Any';
          if (keywords.any((k) => k.contains('year'))) {
            experience = keywords.firstWhere((k) => k.contains('year'), 
                orElse: () => 'Experience').replaceAll(RegExp(r'[^0-9]'), '');
            if (experience.isNotEmpty) {
              experience = '$experience ${int.parse(experience) == 1 ? 'year' : 'years'}';
            }
          }

          return {
            'title': keywords.firstWhere((k) => 
                k.contains('developer') || 
                k.contains('engineer') || 
                k.contains('designer') ||
                k.contains('scientist') ||
                k.contains('manager'),
                orElse: () => 'Role').toUpperCase(),
            'location': keywords.firstWhere((k) => 
                !k.contains('year') && k.length > 2,
                orElse: () => 'Location').toUpperCase(),
            'experience': experience,
            'salary': salary,
            'source': (post['subreddit'] ?? post['user'] ?? 'Anonymous').toString(),
            'snippet': (post['text']?.length > 120
                ? '${post['text'].substring(0, 120)}...'
                : post['text']?.toString() ?? 'No details'),
            'url': (post['url']?.toString() ?? '').isNotEmpty ? post['url'] : null,
            'confidence': _calculateConfidence(post, keywords),
          };
        })
        .take(10)
        .toList();
  }

  int _calculateConfidence(Map<String, dynamic> post, List<String> keywords) {
    int score = 0;
    
    // Check if title contains keywords
    final title = post['title']?.toString().toLowerCase() ?? '';
    for (var keyword in keywords) {
      if (title.contains(keyword)) score += 2;
    }
    
    // Check text length (more details = more reliable)
    final text = post['text']?.toString() ?? '';
    if (text.length > 200) score += 3;
    if (text.length > 100) score += 2;
    
    // Check for specific numbers
    if (RegExp(r'\$\d+').hasMatch(text)) score += 3;
    
    return score.clamp(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterResults();
    final location = query.split(',').firstWhere((e) => e.trim().isNotEmpty, 
        orElse: () => 'Your Location').trim().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text("Salary Insights for $location"),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.share),
            onPressed: () {
              // Share functionality would go here
            },
          ),
        ],
      ),
      body: results.isEmpty
          ? _buildEmptyState(context)
          : _buildResultsList(results, context),
    );
  }

  // ALL HELPER METHODS NOW ACCEPT BuildContext context AS A PARAMETER
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.chartLine,
              size: 80,
              color: Color(0xFF4361EE),
            ),
            const SizedBox(height: 24),
            Text(
              "No salary data found",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "We couldn't find salary information for your search. Try a different role or location.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Try Another Search"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> results, BuildContext context) {
    // Calculate stats
    final salaries = results
        .where((r) => r['salary'] != 'Not specified')
        .map((r) {
          final match = RegExp(r'\d+').firstMatch(r['salary']);
          return match != null ? int.tryParse(match.group(0)!) : null;
        })
        .whereType<int>()
        .toList();
    
    final median = salaries.isNotEmpty 
        ? salaries.reduce((a, b) => a + b) ~/ salaries.length 
        : null;
    
    final min = salaries.isNotEmpty ? salaries.reduce((a, b) => a < b ? a : b) : null;
    final max = salaries.isNotEmpty ? salaries.reduce((a, b) => a > b ? a : b) : null;
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Summary card
              _buildSummaryCard(median, min, max, context),
              
              const SizedBox(height: 24),
              
              // Reliability notice
              _buildReliabilityNotice(results.length, context),
              
              const SizedBox(height: 24),
              
              // Results title
              Text(
                "Recent Salary Reports",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildResultItem(results[index], index, context),
            childCount: results.length,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildActionButtons(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int? median, int? min, int? max, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Salary Insights",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (median != null)
            Text(
              "\$$median,000",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (min != null && max != null)
            Text(
              "Range: \$$min,000 - \$$max,000",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.circleCheck,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                "${query.split(',').first.trim().toUpperCase()} professionals",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReliabilityNotice(int count, BuildContext context) {
    String message;
    Color color;
    
    if (count >= 5) {
      message = "High reliability • Based on $count recent reports";
      color = Colors.green;
    } else if (count >= 2) {
      message = "Moderate reliability • Based on $count recent reports";
      color = Colors.orange;
    } else {
      message = "Limited data • Based on $count report";
      color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.circleExclamation,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> data, int index, BuildContext context) {
    final confidence = data['confidence'] ?? 5;
    final confidenceColor = confidence >= 8 
        ? Colors.green 
        : confidence >= 5 
            ? Colors.orange 
            : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final url = data['url'];
          if (url == null || url.isEmpty) return;
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with role and confidence
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Confidence indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          confidence >= 8 
                              ? FontAwesomeIcons.star 
                              : confidence >= 5 
                                  ? FontAwesomeIcons.circleExclamation 
                                  : FontAwesomeIcons.triangleExclamation,
                          color: confidenceColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$confidence/10",
                          style: TextStyle(
                            color: confidenceColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${data['location']} • ${data['experience']}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              
              // Salary information
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.moneyBillWave,
                    size: 16,
                    color: Color(0xFF4361EE),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Reported: ${data['salary']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Source information
              Row(
                children: [
                  Icon(
                    data['source'].contains('reddit') 
                        ? FontAwesomeIcons.reddit 
                        : FontAwesomeIcons.twitter,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data['source'].contains('reddit') ? "From Reddit" : "From X (Twitter)",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Snippet
              Text(
                data['snippet'],
                style: const TextStyle(
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Learn more button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final url = data['url'];
                    if (url == null || url.isEmpty) return;
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(
                    FontAwesomeIcons.arrowRight,
                    size: 14,
                  ),
                  label: const Text("View source"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4361EE),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Would implement salary negotiation tips
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Get Negotiation Tips"),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Would implement email report
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text("Email This Report"),
        ),
      ],
    );
  }
}