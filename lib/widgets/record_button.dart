import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback? onTap;
  final Duration? elapsed;
  final kMax = 5;

  const RecordButton({
    super.key,
    required this.isRecording,
    this.onTap,
    this.elapsed,
  });

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isRecording ? Colors.red : Colors.green;
    final fillColor = isRecording ? Colors.red.shade50 : Colors.green[100];
    final iconColor = isRecording ? Colors.red : Colors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(250),
          onTap: onTap,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              size: 150,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isRecording ? 'Recording...' : 'Tap to record',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (elapsed != null) ...[
          const SizedBox(height: 4),
          Text(
            '${_formatDuration(elapsed!)} / 00:0$kMax',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
