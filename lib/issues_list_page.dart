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
  try {
    final response = await _supabase
        .from('reports')
        .select('*')
        .order('created_at', ascending: false)
        .limit(100);

    print('✅ Supabase fetched ${response.length} rows');
    return List<Map<String, dynamic>>.from(response);
  } on PostgrestException catch (e) {
    print('❌ PostgrestException: ${e.message}');
    throw Exception('Supabase error: ${e.message}');
  } catch (e) {
    print('❌ Unexpected error: $e');
    throw Exception('Unexpected error: $e');
  }
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load reports',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _future = _fetchReports();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 48),
                  const SizedBox(height: 8),
                  const Text('No reports yet'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _future = _fetchReports();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _fetchReports();
              });
              await _future;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
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


