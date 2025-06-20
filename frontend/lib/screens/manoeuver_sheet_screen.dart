import 'package:flutter/material.dart';
import 'dart:async';
import '../models/manoeuver_sheet.dart';
import '../services/manoeuver_sheet_service.dart';
import '../utils/role_based_access.dart';
import '../data/equipment_checklists.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManoeuverSheetScreen extends StatefulWidget {
  final String manoeuverSheetId;

  const ManoeuverSheetScreen({
    Key? key,
    required this.manoeuverSheetId,
  }) : super(key: key);

  @override
  State<ManoeuverSheetScreen> createState() => _ManoeuverSheetScreenState();
}

class _ManoeuverSheetScreenState extends State<ManoeuverSheetScreen> {
  final ManoeuverSheetService _service = ManoeuverSheetService();
  ManoeuverSheet? _manoeuverSheet;
  bool _isLoading = true;
  String? _error;
  Map<String, bool> _checkedItems = {};
  Map<String, Timer?> _timers = {};
  Map<String, int> _timerDurations = {};
  List<Offset> _gndPositions = [];
  bool _placingGnd = false;

  @override
  void initState() {
    super.initState();
    _loadManoeuverSheet();
  }

  @override
  void dispose() {
    _timers.values.forEach((timer) => timer?.cancel());
    super.dispose();
  }

  void _startTimer(String itemId) {
    if (_timers[itemId] != null) return;

    _timerDurations[itemId] = 0;
    _timers[itemId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerDurations[itemId] = (_timerDurations[itemId] ?? 0) + 1;
      });
    });
  }

  void _stopTimer(String itemId) {
    _timers[itemId]?.cancel();
    _timers[itemId] = null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadManoeuverSheet() async {
    try {
      final sheet = await _service.getManoeuverSheet(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyEPI() async {
    try {
      final sheet = await _service.verifyEPI(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _startConsignation() async {
    try {
      final sheet = await _service.startConsignation(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _completeConsignation() async {
    try {
      final sheet = await _service.completeConsignation(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _startDeconsignation() async {
    try {
      final sheet = await _service.startDeconsignation(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _completeDeconsignation() async {
    try {
      final sheet = await _service.completeDeconsignation(widget.manoeuverSheetId);
      setState(() {
        _manoeuverSheet = sheet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _reportIncident() async {
    final TextEditingController descriptionController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Incident'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please describe the incident that occurred during the manoeuver:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter incident description...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(descriptionController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Report Incident'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await _service.reportIncident(widget.manoeuverSheetId, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incident reported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reporting incident: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _handleGndPlacement(TapDownDetails details) {
    if (!_placingGnd) return;
    
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    setState(() {
      _gndPositions.add(localPosition);
      _placingGnd = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    if (_manoeuverSheet == null) {
      return const Scaffold(
        body: Center(
          child: Text('Manoeuver sheet not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Manoeuver Sheet - ${_manoeuverSheet!.equipmentType}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment Schema Card with GND canvas
            Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Equipment Schema',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GestureDetector(
                    onTapDown: _handleGndPlacement,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          child: Image.asset(
                            _manoeuverSheet!.getEquipmentSchemaPath(),
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[300],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Schema not found',
                                      style: TextStyle(
                                        color: Colors.red[300],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        ..._gndPositions.map((pos) => Positioned(
                          left: pos.dx - 16,
                          top: pos.dy - 16,
                          child: SvgPicture.asset(
                            'assets/schemas/gnd.svg',
                            width: 32,
                            height: 32,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // EPI Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ÉQUIPEMENTS DE PROTECTION INDIVIDUELLE (EPI)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildEPIChecklist(),
                    if (!_manoeuverSheet!.epiVerified)
                      ElevatedButton(
                        onPressed: _verifyEPI,
                        child: const Text('Verify EPI'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Consignation Section
            if (_manoeuverSheet!.epiVerified && !_manoeuverSheet!.consignationStarted)
              ElevatedButton(
                onPressed: _startConsignation,
                child: const Text('Start Consignation'),
              ),

            if (_manoeuverSheet!.consignationStarted && !_manoeuverSheet!.consignationCompleted)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÉTAPE DE CONSIGNATION',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildConsignationChecklist(),
                      ElevatedButton(
                        onPressed: _completeConsignation,
                        child: const Text('Complete Consignation'),
                      ),
                    ],
                  ),
                ),
              ),

            // Deconsignation Section
            if (_manoeuverSheet!.consignationCompleted && !_manoeuverSheet!.deconsignationStarted)
              ElevatedButton(
                onPressed: _startDeconsignation,
                child: const Text('Start Deconsignation'),
              ),

            if (_manoeuverSheet!.deconsignationStarted && !_manoeuverSheet!.deconsignationCompleted)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÉTAPE DE DECONSIGNATION',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildDeconsignationChecklist(),
                      ElevatedButton(
                        onPressed: _completeDeconsignation,
                        child: const Text('Complete Deconsignation'),
                      ),
                    ],
                  ),
                ),
              ),

            // Work Attestation
            if (_manoeuverSheet!.workAttestationId != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Work Attestation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_manoeuverSheet!.workAttestation != null) ...[
                        Text('Work Attestation ID: ${_manoeuverSheet!.workAttestation!.id}'),
                        const SizedBox(height: 8),
                        Text('Work Description: ${_manoeuverSheet!.workAttestation!.work.description}'),
                        const SizedBox(height: 8),
                        Text('Worker: ${_manoeuverSheet!.workAttestation!.worker.name}'),
                        const SizedBox(height: 8),
                        const Text('Equipment Types:'),
                        ..._manoeuverSheet!.workAttestation!.equipmentTypes.map((type) => Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('• ${type.displayName}'),
                        )),
                        const SizedBox(height: 8),
                        Text('Created: ${_manoeuverSheet!.workAttestation!.createdAt}'),
                        Text('Updated: ${_manoeuverSheet!.workAttestation!.updatedAt}'),
                      ] else ...[
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Incident Report Button
            if (_manoeuverSheet!.consignationStarted && !_manoeuverSheet!.deconsignationCompleted) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _reportIncident,
                icon: const Icon(Icons.warning),
                label: const Text('Report Incident'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _placingGnd = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap on the schema to place GND symbol'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add GND Symbol'),
      ),
    );
  }

  Widget _buildEPIChecklist() {
    final items = [
      'Casque isolant',
      'Gants isolants (Classe 4 pour HT)',
      'Écran facial anti-arc',
      'Vêtements ignifugés',
      'Chaussures diélectriques',
    ];

    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: _manoeuverSheet!.epiVerified,
          onChanged: null,
        );
      }).toList(),
    );
  }

  Widget _buildChecklist(List<ChecklistItem> items) {
    return Column(
      children: items.map((item) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (item.designation != null)
                            Text(
                              'Designation: ${item.designation}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (item.requiresTimer)
                      Text(
                        _formatDuration(_timerDurations[item.description] ?? 0),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item.requiresTimer)
                      TextButton(
                        onPressed: () {
                          if (_timers[item.description] == null) {
                            _startTimer(item.description);
                          } else {
                            _stopTimer(item.description);
                          }
                        },
                        child: Text(_timers[item.description] == null ? 'Start Timer' : 'Stop Timer'),
                      ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: _checkedItems[item.description] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _checkedItems[item.description] = value ?? false;
                          if (value == true && item.requiresTimer) {
                            _stopTimer(item.description);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsignationChecklist() {
    if (_manoeuverSheet == null) return const SizedBox.shrink();
    return _buildChecklist(
      EquipmentChecklists.consignationChecklists[_manoeuverSheet!.equipmentType] ?? [],
    );
  }

  Widget _buildDeconsignationChecklist() {
    if (_manoeuverSheet == null) return const SizedBox.shrink();
    return _buildChecklist(
      EquipmentChecklists.deconsignationChecklists[_manoeuverSheet!.equipmentType] ?? [],
    );
  }
} 