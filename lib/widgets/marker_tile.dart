import 'package:flutter/material.dart';
import '../models/marker.dart';

class MarkerTile extends StatefulWidget {
  final Marker marker;
  final Function(String) onValueUpdate;
  final VoidCallback onDelete;

  const MarkerTile({
    super.key,
    required this.marker,
    required this.onValueUpdate,
    required this.onDelete,
  });

  @override
  State<MarkerTile> createState() => _MarkerTileState();
}

class _MarkerTileState extends State<MarkerTile> {
  bool _showDeleteButton = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showValuePicker(BuildContext context) {
    _removeOverlay();

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              color: Colors.black26,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: position.dy + button.size.height,
            left: position.dx,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: button.size.width,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.marker.type == MarkerType.choice
                    ? _buildChoiceList()
                    : _buildNumericSlider(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildChoiceList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.marker.possibleValues.map((value) {
        return InkWell(
          onTap: () {
            widget.onValueUpdate(value);
            _removeOverlay();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumericSlider() {
    final min = widget.marker.minValue ?? 0;
    final max = widget.marker.maxValue ?? 10;
    return StatefulBuilder(
      builder: (context, setState) {
        return _NumericSliderContent(
          min: min,
          max: max,
          onConfirm: (value) {
            widget.onValueUpdate(value.toStringAsFixed(0));
            _removeOverlay();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => _showDeleteButton = true);
      },
      onTap: () => _showValuePicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.marker.color.withOpacity(widget.marker.isUpdatedToday ? 0.5 : 1.0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.marker.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (_showDeleteButton)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final height = box.size.height;
                    final localPosition = details.localPosition;
                    // If tap is in the bottom 20% of the tile, cancel delete
                    if (localPosition.dy > height * 0.8) {
                      setState(() => _showDeleteButton = false);
                    } else {
                      widget.onDelete();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NumericSliderContent extends StatefulWidget {
  final double min;
  final double max;
  final Function(double) onConfirm;

  const _NumericSliderContent({
    required this.min,
    required this.max,
    required this.onConfirm,
  });

  @override
  State<_NumericSliderContent> createState() => _NumericSliderContentState();
}

class _NumericSliderContentState extends State<_NumericSliderContent> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.min;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: _value,
          min: widget.min,
          max: widget.max,
          divisions: (widget.max - widget.min).toInt(),
          label: _value.toStringAsFixed(0),
          onChanged: (newValue) {
            setState(() => _value = newValue);
          },
        ),
        TextButton(
          onPressed: () => widget.onConfirm(_value),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
