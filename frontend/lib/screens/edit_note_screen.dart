import 'package:flutter/material.dart';
import 'package:frontend/models/lockout_note.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/steg_logo.dart';

class EditNoteScreen extends StatefulWidget {
  final LockoutNote note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Section 1: Header Information
  late final TextEditingController _uniteStegController;
  late final TextEditingController _posteHtController;
  
  // Section 2: Equipment Details
  late EquipmentType _selectedEquipmentType;
  late final TextEditingController _equipmentDetailsController;
  late final TextEditingController _workNatureController;
  
  // Section 3: Planning
  DateTime? _retraitDate;
  DateTime? _debutTravaux;
  DateTime? _finTravaux;
  DateTime? _retourDate;
  late final TextEditingController _joursIndisponibiliteController;
  
  // Section 4: Personnel
  late final TextEditingController _chargeRetraitController;
  late final TextEditingController _chargeConsignationController;
  late final TextEditingController _chargeTravauxController;
  late final TextEditingController _chargeEssaisController;
  
  // Section 5: Additional Information
  late final TextEditingController _instructionsTechniquesController;
  late final TextEditingController _destinatairesController;
  late final TextEditingController _coupureDemandeParController;
  late final TextEditingController _noteTransmiseAController;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing note data
    _uniteStegController = TextEditingController(text: widget.note.uniteSteg ?? '');
    _posteHtController = TextEditingController(text: widget.note.posteHt);
    
    _selectedEquipmentType = widget.note.equipmentType ?? EquipmentType.TRANSFORMATEUR_MD;
    _equipmentDetailsController = TextEditingController(text: widget.note.equipmentDetails ?? '');
    _workNatureController = TextEditingController(text: widget.note.workNature ?? '');
    
    _retraitDate = widget.note.retraitDate;
    _debutTravaux = widget.note.debutTravaux;
    _finTravaux = widget.note.finTravaux;
    _retourDate = widget.note.retourDate;
    _joursIndisponibiliteController = TextEditingController(
      text: widget.note.joursIndisponibilite?.toString() ?? ''
    );
    
    _chargeRetraitController = TextEditingController(text: widget.note.chargeRetrait ?? '');
    _chargeConsignationController = TextEditingController(text: widget.note.chargeConsignation ?? '');
    _chargeTravauxController = TextEditingController(text: widget.note.chargeTravaux ?? '');
    _chargeEssaisController = TextEditingController(text: widget.note.chargeEssais ?? '');
    
    _instructionsTechniquesController = TextEditingController(text: widget.note.instructionsTechniques ?? '');
    _destinatairesController = TextEditingController(text: widget.note.destinataires ?? '');
    _coupureDemandeParController = TextEditingController(text: widget.note.coupureDemandeePar ?? '');
    _noteTransmiseAController = TextEditingController(text: widget.note.noteTransmiseA ?? '');
  }

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

  Future<void> _updateNote() async {
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
      await apiService.updateNote(
        widget.note.id,
        posteHt: _posteHtController.text,
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
          const SnackBar(content: Text('Note updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update note: ${e.toString()}';
      });
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
                'Edit Lockout Note',
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
                'Edit Lockout Note',
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
                onPressed: _isLoading ? null : _updateNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Note'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
