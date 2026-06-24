import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressChartStub extends StatelessWidget {
  final int streakDays;
  final double averageScore;
  final List<int> recentScores;
  final String label;

  const ProgressChartStub({
    super.key,
    required this.streakDays,
    required this.averageScore,
    required this.recentScores,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // We'll fake a bar chart by normalizing scores (0-100) to a max height.
    // This is STATIC VISUAL ONLY for Milestone 0.
    const double maxBarHeight = 60;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: streak + avg
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Streak
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '$streakDays day streak',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Average score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Text(
                    'Avg ${averageScore.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mini chart label
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // Fake bar chart row
            SizedBox(
              height: maxBarHeight + 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(recentScores.length, (index) {
                  final score = recentScores[index];
                  final barHeight =
                      (score.clamp(0, 100) / 100.0) * maxBarHeight;

                  // Just making sure there's at least a little bar if score > 0
                  final safeHeight = score == 0
                      ? 2.0
                      : math.max(barHeight, 6.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // bar
                      Container(
                        width: 14,
                        height: safeHeight,
                        decoration: BoxDecoration(
                          color: Colors.blue, // we can style later w/ theme
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        score.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Tiny caption
            Text(
              'Higher bar = better pronunciation score',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
