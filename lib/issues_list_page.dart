import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'issue_detail_page.dart';

class IssuesListPage extends StatefulWidget {
  const IssuesListPage({super.key});

  @override
  State<IssuesListPage> createState() => _IssuesListPageState();
}

class _IssuesListPageState extends State<IssuesListPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchReports();
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    final response = await _supabase
        .from('reports')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    // Supabase Flutter returns dynamic, ensure list of maps
    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Reports')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load reports: ${snapshot.error}'),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No reports yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = items[index];
              final issueType = (row['issue_type'] ?? 'Unknown').toString();
              final imageUrl = (row['image_url'] ?? '').toString();
              final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty ? const Icon(Icons.report_problem_outlined) : null,
                  ),
                  title: Text(issueType),
                  subtitle: Text(
                    createdAt != null
                        ? '${createdAt.toLocal()}'
                        : 'Unknown time',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IssueDetailPage(report: row),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _future = _fetchReports();
          });
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }
}


