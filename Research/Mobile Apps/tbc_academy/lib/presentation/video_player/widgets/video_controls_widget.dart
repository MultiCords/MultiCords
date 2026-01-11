import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class VideoControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;
  final double playbackSpeed;
  final Function(double) onSpeedChange;
  final String quality;
  final Function(String) onQualityChange;
  final bool captionsEnabled;
  final VoidCallback onToggleCaptions;

  const VideoControlsWidget({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipForward,
    required this.onSkipBackward,
    required this.playbackSpeed,
    required this.onSpeedChange,
    required this.quality,
    required this.onQualityChange,
    required this.captionsEnabled,
    required this.onToggleCaptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'replay_10',
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: onSkipBackward,
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName:
                      isPlaying ? 'pause_circle_filled' : 'play_circle_filled',
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'forward_10',
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: onSkipForward,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlButton(
                context,
                icon: 'speed',
                label: '${playbackSpeed}x',
                onTap: () => _showSpeedDialog(context),
              ),
              _buildControlButton(
                context,
                icon: 'hd',
                label: quality,
                onTap: () => _showQualityDialog(context),
              ),
              _buildControlButton(
                context,
                icon: captionsEnabled
                    ? 'closed_caption'
                    : 'closed_caption_disabled',
                label: 'CC',
                onTap: onToggleCaptions,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds.map((speed) {
            return RadioListTile<double>(
              title: Text('${speed}x'),
              value: speed,
              groupValue: playbackSpeed,
              onChanged: (value) {
                if (value != null) {
                  onSpeedChange(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final qualities = ['Auto', '1080p', '720p', '480p', '360p'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities.map((q) {
            return RadioListTile<String>(
              title: Text(q),
              value: q,
              groupValue: quality,
              onChanged: (value) {
                if (value != null) {
                  onQualityChange(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
