// lib/results_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

          return {
            'title': keywords.firstWhere((k) => k.contains('developer') || k.contains('engineer'), orElse: () => 'Role'),
            'location': keywords.firstWhere((k) => k.contains('city') || k.length > 2, orElse: () => 'Unknown'),
            'experience': keywords.firstWhere((k) => k.contains('year'), orElse: () => 'Any'),
            'salary': salary,
            'source': post['subreddit'] ?? 'X',
            'snippet': post['text']?.length > 120
                ? '${post['text'].substring(0, 120)}...'
                : post['text'] ?? '',
            'url': post['url'],
          };
        })
        .take(10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterResults();

    return Scaffold(
      appBar: AppBar(
        title: Text("Results for \"$query\""),
        leading: BackButton(),
      ),
      body: results.isEmpty
          ? Center(child: Text("No salary data found for this search."))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: results.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, i) {
                final data = results[i];
                return ListTile(
                  title: Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data['location']} • ${data['experience']}"),
                      SizedBox(height: 4),
                      Text("💰 ${data['salary']} • via ${data['source']}"),
                      SizedBox(height: 6),
                      Text(data['snippet'], maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: Icon(Icons.open_in_new, size: 16),
                  onTap: () async {
                    final uri = Uri.parse(data['url']);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                );
              },
            ),
    );
  }
}