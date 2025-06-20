import 'package:flutter/material.dart';
import 'package:frontend/models/lockout_note.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/steg_logo.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Section 1: Header Information
  final _uniteStegController = TextEditingController();
  final _posteHtController = TextEditingController();
  
  // Section 2: Equipment Details
  EquipmentType _selectedEquipmentType = EquipmentType.TRANSFORMATEUR_MD;
  final _equipmentDetailsController = TextEditingController();
  final _workNatureController = TextEditingController();
  
  // Section 3: Planning
  DateTime? _retraitDate;
  DateTime? _debutTravaux;
  DateTime? _finTravaux;
  DateTime? _retourDate;
  final _joursIndisponibiliteController = TextEditingController();
  
  // Section 4: Personnel
  final _chargeRetraitController = TextEditingController();
  final _chargeConsignationController = TextEditingController();
  final _chargeTravauxController = TextEditingController();
  final _chargeEssaisController = TextEditingController();
  
  // Section 5: Additional Information
  final _instructionsTechniquesController = TextEditingController();
  final _destinatairesController = TextEditingController();
  final _coupureDemandeParController = TextEditingController();
  final _noteTransmiseAController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _posteHtController.dispose();
    _uniteStegController.dispose();
    _equipmentDetailsController.dispose();
    _workNatureController.dispose();
    _joursIndisponibiliteController.dispose();
    _chargeRetraitController.dispose();
    _chargeConsignationController.dispose();
    _chargeTravauxController.dispose();
    _chargeEssaisController.dispose();
    _instructionsTechniquesController.dispose();
    _destinatairesController.dispose();
    _coupureDemandeParController.dispose();
    _noteTransmiseAController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse joursIndisponibilite as integer if provided
      int? joursIndisponibilite;
      if (_joursIndisponibiliteController.text.isNotEmpty) {
        joursIndisponibilite = int.tryParse(_joursIndisponibiliteController.text);
      }
      
      final apiService = ApiService();
      await apiService.createNote(
        _posteHtController.text,
        equipmentType: _selectedEquipmentType,
        equipmentDetails: _equipmentDetailsController.text,
        uniteSteg: _uniteStegController.text,
        workNature: _workNatureController.text,
        retraitDate: _retraitDate,
        debutTravaux: _debutTravaux,
        finTravaux: _finTravaux,
        retourDate: _retourDate,
        joursIndisponibilite: joursIndisponibilite,
        chargeRetrait: _chargeRetraitController.text,
        chargeConsignation: _chargeConsignationController.text,
        chargeTravaux: _chargeTravauxController.text,
        chargeEssais: _chargeEssaisController.text,
        instructionsTechniques: _instructionsTechniquesController.text,
        destinataires: _destinatairesController.text,
        coupureDemandeePar: _coupureDemandeParController.text,
        noteTransmiseA: _noteTransmiseAController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      // Extract the error message from the exception
      String errorMessage = 'Failed to create note';
      
      if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permission denied: You may not have the required role to create notes.';
      } else if (e.toString().contains('Bad request')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e.toString().contains('Not authenticated')) {
        errorMessage = 'You are not authenticated. Please log in again.';
      } else {
        errorMessage = 'Failed to create note: ${e.toString()}';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
      
      // Show a snackbar with the error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to create a date picker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
      );
      
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateSelected(combinedDateTime);
      }
    }
  }
  
  // Helper method to format date for display
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} -- ${dateTime.hour.toString().padLeft(2, '0')}h${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const StegLogo(size: 40),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Create Lockout Note',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Lockout Note',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Section 1: Header Information
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. En-tête de la note d\'arrêt',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Unité STEG
                      TextFormField(
                        controller: _uniteStegController,
                        decoration: const InputDecoration(
                          labelText: 'Unité STEG',
                          border: OutlineInputBorder(),
                          helperText: 'Unité/Division concernée par l\'arrêt',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Poste HT (required)
                      TextFormField(
                        controller: _posteHtController,
                        decoration: const InputDecoration(
                          labelText: 'Poste HT',
                          border: OutlineInputBorder(),
                          helperText: 'Enter the high-voltage post identifier',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Poste HT identifier';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Section 2: Equipment Details
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Détails de l\'arrêt',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Equipment Type
                      const Text('Type d\'équipement:'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<EquipmentType>(
                        value: _selectedEquipmentType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: EquipmentType.values.map((type) {
                          return DropdownMenuItem<EquipmentType>(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEquipmentType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Equipment Details
                      TextFormField(
                        controller: _equipmentDetailsController,
                        decoration: const InputDecoration(
                          labelText: 'Équipements/Zone concernés',
                          border: OutlineInputBorder(),
                          helperText: 'Décrire précisément les installations à arrêter',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the equipment details';
                          }
                          return null;
                        },
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Work Nature
                      TextFormField(
                        controller: _workNatureController,
                        decoration: const InputDecoration(
                          labelText: 'Nature des travaux',
                          border: OutlineInputBorder(),
                          helperText: 'Détail des opérations prévues',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Section 3: Planning
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. Planning de l\'arrêt',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Retrait Date
                      ListTile(
                        title: const Text('Retrait'),
                        subtitle: Text(_formatDateTime(_retraitDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, _retraitDate, (date) {
                          setState(() {
                            _retraitDate = date;
                          });
                        }),
                      ),
                      const Divider(),
                      
                      // Début des travaux
                      ListTile(
                        title: const Text('Début des travaux'),
                        subtitle: Text(_formatDateTime(_debutTravaux)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, _debutTravaux, (date) {
                          setState(() {
                            _debutTravaux = date;
                          });
                        }),
                      ),
                      const Divider(),
                      
                      // Fin des travaux
                      ListTile(
                        title: const Text('Fin des travaux'),
                        subtitle: Text(_formatDateTime(_finTravaux)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, _finTravaux, (date) {
                          setState(() {
                            _finTravaux = date;
                          });
                        }),
                      ),
                      const Divider(),
                      
                      // Retour
                      ListTile(
                        title: const Text('Retour'),
                        subtitle: Text(_formatDateTime(_retourDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, _retourDate, (date) {
                          setState(() {
                            _retourDate = date;
                          });
                        }),
                      ),
                      const Divider(),
                      
                      // Jours d'indisponibilité
                      TextFormField(
                        controller: _joursIndisponibiliteController,
                        decoration: const InputDecoration(
                          labelText: 'Jours d\'indisponibilité',
                          border: OutlineInputBorder(),
                          helperText: 'Nombre de jours d\'interruption prévus',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Section 4: Personnel
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '4. Personnel impliqué',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chargé du Retrait
                      TextFormField(
                        controller: _chargeRetraitController,
                        decoration: const InputDecoration(
                          labelText: 'Chargé du Retrait',
                          border: OutlineInputBorder(),
                          helperText: 'Nom, prénom, unité, téléphone',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chargé de Consignation
                      TextFormField(
                        controller: _chargeConsignationController,
                        decoration: const InputDecoration(
                          labelText: 'Chargé de Consignation',
                          border: OutlineInputBorder(),
                          helperText: 'Responsable de la sécurité électrique',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chargé de Travaux
                      TextFormField(
                        controller: _chargeTravauxController,
                        decoration: const InputDecoration(
                          labelText: 'Chargé de Travaux',
                          border: OutlineInputBorder(),
                          helperText: 'Chef d\'équipe exécutant les travaux',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chargé d'Essais
                      TextFormField(
                        controller: _chargeEssaisController,
                        decoration: const InputDecoration(
                          labelText: 'Chargé d\'Essais',
                          border: OutlineInputBorder(),
                          helperText: 'Responsable des tests post-travaux',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Section 5: Additional Information
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '5. Informations complémentaires',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Instructions techniques
                      TextFormField(
                        controller: _instructionsTechniquesController,
                        decoration: const InputDecoration(
                          labelText: 'Instructions techniques',
                          border: OutlineInputBorder(),
                          helperText: 'Indications concernant les manœuvres et condamnations',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Destinataires
                      TextFormField(
                        controller: _destinatairesController,
                        decoration: const InputDecoration(
                          labelText: 'Destinataires',
                          border: OutlineInputBorder(),
                          helperText: 'Poste concerné',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Coupure demandée par
                      TextFormField(
                        controller: _coupureDemandeParController,
                        decoration: const InputDecoration(
                          labelText: 'Coupure pour travaux demandés par',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Note transmise à
                      TextFormField(
                        controller: _noteTransmiseAController,
                        decoration: const InputDecoration(
                          labelText: 'Note transmise par message collationné à M.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null) ...[                
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _createNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Note'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
