import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../models/marker.dart';
import '../providers/marker_provider.dart';
import '../widgets/marker_tile.dart';
import '../widgets/add_marker_dialog.dart';
import '../widgets/calendar_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAddMarkerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMarkerDialog(
        onAdd: (marker) {
          context.read<MarkerProvider>().addMarker(marker);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CalendarView(),
              );
            },
          ),
        ],
      ),
      body: Consumer<MarkerProvider>(
        builder: (context, provider, child) {
          final pendingMarkers = provider.pendingMarkers;
          final updatedMarkers = provider.updatedMarkers;
          final allMarkers = [...pendingMarkers, ...updatedMarkers];

          if (allMarkers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No markers yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddMarkerDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Marker'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: allMarkers.length,
              itemBuilder: (context, index) {
                final marker = allMarkers[index];
                return MarkerTile(
                  key: ValueKey(marker.id),
                  marker: marker,
                  onValueUpdate: (value) {
                    provider.updateMarkerValue(marker.id, value);
                  },
                  onDelete: () {
                    provider.removeMarker(marker.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMarkerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
