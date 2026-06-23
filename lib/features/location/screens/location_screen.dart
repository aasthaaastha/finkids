import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _sharing = false;

  void _toggleShare() {
    // TODO: Call geolocator to request permission, then start streaming
    // location to parent's device (via Firestore or a custom backend).
    setState(() => _sharing = !_sharing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map placeholder
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.locationLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded,
                      size: 60, color: AppColors.location.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'Map goes here',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const Text(
                    'Add your Google Maps API key to enable',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Share with parents',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _sharing
                  ? '✅ Your location is being shared in real time.'
                  : 'Start sharing so your parents can always see where you are.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _toggleShare,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _sharing ? Colors.red.shade600 : AppColors.location,
                ),
                icon: Icon(_sharing ? Icons.stop_rounded : Icons.share_location_rounded),
                label: Text(_sharing ? 'Stop sharing' : 'Start sharing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
