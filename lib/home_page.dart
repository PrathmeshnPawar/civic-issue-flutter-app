import 'package:flutter/material.dart';
import 'report_page.dart'; // We'll create this next
import 'issues_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Civic Issue Reporter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.map_rounded,
                        size: 180,
                        color: color.onPrimaryContainer.withOpacity(0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Make your city better',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: color.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Report potholes, broken streetlights, waste and more. Your report helps authorities act faster.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: color.onPrimaryContainer.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.report_gmailerrorred_rounded),
                                label: const Text('Report an Issue'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ReportPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('View Reports'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IssuesListPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
                              TextButton.icon(
                                icon: const Icon(Icons.info_outline_rounded),
                                label: const Text('How it works'),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    showDragHandle: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text('How reporting works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 8),
                                            Text('1) Choose an issue type\n2) Add a photo\n3) Auto-capture location\n4) Submit to our system'),
                                            SizedBox(height: 8),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  title: 'Issues fixed',
                  value: '1.2k+',
                  icon: Icons.check_circle_outline,
                ),
                _StatCard(
                  title: 'Active users',
                  value: '8.5k',
                  icon: Icons.people_alt_outlined,
                ),
                _StatCard(
                  title: 'Avg. response',
                  value: '48h',
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        height: 96,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: color.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
