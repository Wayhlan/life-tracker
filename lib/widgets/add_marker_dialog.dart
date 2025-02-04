import 'package:flutter/material.dart';
import '../models/marker.dart';
import '../config/theme.dart';

class AddMarkerDialog extends StatefulWidget {
  final Function(Marker) onAdd;

  const AddMarkerDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<AddMarkerDialog> {
  final _nameController = TextEditingController();
  MarkerType _selectedType = MarkerType.choice;
  final List<String> _possibleValues = [];
  double _minValue = 0;
  double _maxValue = 5;
  int _currentStep = 0;
  String _newValue = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPossibleValue() {
    if (_newValue.isNotEmpty) {
      setState(() {
        _possibleValues.add(_newValue);
        _newValue = '';
      });
    }
  }

  void _removePossibleValue(int index) {
    setState(() {
      _possibleValues.removeAt(index);
    });
  }

  bool get _canProceed {
    if (_currentStep == 0) {
      return _nameController.text.isNotEmpty;
    } else {
      if (_selectedType == MarkerType.choice) {
        return _possibleValues.isNotEmpty;
      }
      return true;
    }
  }

  void _createMarker() {
    final marker = Marker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _selectedType,
      possibleValues: _possibleValues,
      minValue: _selectedType == MarkerType.numeric ? _minValue : null,
      maxValue: _selectedType == MarkerType.numeric ? _maxValue : null,
      color: AppTheme.markerColors[
        DateTime.now().millisecondsSinceEpoch % AppTheme.markerColors.length
      ],
    );
    widget.onAdd(marker);
    Navigator.of(context).pop();
  }

  Widget _buildFirstStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Marker Name',
            hintText: 'Enter marker name',
          ),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text('Marker Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        SegmentedButton<MarkerType>(
          segments: const [
            ButtonSegment(
              value: MarkerType.choice,
              label: Text('Choice'),
              icon: Icon(Icons.list),
            ),
            ButtonSegment(
              value: MarkerType.numeric,
              label: Text('Numeric'),
              icon: Icon(Icons.numbers),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<MarkerType> selected) {
            setState(() => _selectedType = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildSecondStep() {
    if (_selectedType == MarkerType.choice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Add Possible Value',
                    hintText: 'Enter a value',
                  ),
                  onChanged: (value) => setState(() => _newValue = value),
                  onSubmitted: (_) => _addPossibleValue(),
                ),
              ),
              IconButton(
                onPressed: _addPossibleValue,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_possibleValues.isNotEmpty) ...[
            const Text('Values:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...List.generate(_possibleValues.length, (index) {
              return Chip(
                label: Text(_possibleValues[index]),
                onDeleted: () => _removePossibleValue(index),
              );
            }),
          ],
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Range:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Min Value'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _minValue = double.tryParse(value) ?? 0;
                    });
                  },
                  controller: TextEditingController(text: _minValue.toString()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Max Value'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _maxValue = double.tryParse(value) ?? 5;
                    });
                  },
                  controller: TextEditingController(text: _maxValue.toString()),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _currentStep == 0 ? 'New Marker' : 'Configure Values',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 0 ? _buildFirstStep() : _buildSecondStep(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() => _currentStep--);
                    },
                    child: const Text('Back'),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _canProceed
                      ? () {
                          if (_currentStep == 0) {
                            setState(() => _currentStep++);
                          } else {
                            _createMarker();
                          }
                        }
                      : null,
                  child: Text(_currentStep == 0 ? 'Next' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
