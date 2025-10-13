import 'package:flutter/material.dart';

class IssueDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;
  const IssueDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final issueType = (report['issue_type'] ?? 'Unknown').toString();
    final imageUrl = (report['image_url'] ?? '').toString();
    final createdAt = DateTime.tryParse(report['created_at']?.toString() ?? '');
    final latitude = report['latitude'];
    final longitude = report['longitude'];

    return Scaffold(
      appBar: AppBar(title: Text(issueType)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.outlineVariant),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 48),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Issue', value: issueType),
                  _DetailRow(
                    label: 'Created',
                    value: createdAt != null ? createdAt.toLocal().toString() : 'Unknown',
                  ),
                  if (latitude != null && longitude != null)
                    _DetailRow(label: 'Location', value: 'Lat: ${latitude.toStringAsFixed(5)}, Lng: ${longitude.toStringAsFixed(5)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}


