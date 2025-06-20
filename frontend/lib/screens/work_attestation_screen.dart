import 'package:flutter/material.dart';
import '../services/work_attestation_service.dart';

class WorkAttestationScreen extends StatefulWidget {
  final String workAttestationId;

  const WorkAttestationScreen({
    Key? key,
    required this.workAttestationId,
  }) : super(key: key);

  @override
  State<WorkAttestationScreen> createState() => _WorkAttestationScreenState();
}

class _WorkAttestationScreenState extends State<WorkAttestationScreen> {
  final WorkAttestationService _service = WorkAttestationService();
  Map<String, dynamic>? _workAttestation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkAttestation();
  }

  Future<void> _loadWorkAttestation() async {
    try {
      final attestation = await _service.getWorkAttestation(widget.workAttestationId);
      setState(() {
        _workAttestation = attestation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

    if (_workAttestation == null) {
      return const Scaffold(
        body: Center(
          child: Text('Work attestation not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Attestation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('ID: ${_workAttestation!['work']['id']}'),
                    Text('Description: ${_workAttestation!['work']['description']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Worker Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_workAttestation!['worker']['name']}'),
                    Text('Matricule: ${_workAttestation!['worker']['matricule']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equipment Types',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...(_workAttestation!['equipmentTypes'] as List).map((type) {
                      return Text('• $type');
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timestamps',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Created: ${_workAttestation!['createdAt']}'),
                    Text('Updated: ${_workAttestation!['updatedAt']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 