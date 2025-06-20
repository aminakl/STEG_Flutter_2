import 'package:flutter/material.dart';
import 'package:frontend/models/lockout_note.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/steg_logo.dart';
import 'package:frontend/utils/role_based_access.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/edit_note_screen.dart';
import 'package:frontend/screens/manoeuver_sheet_screen.dart';
import 'package:frontend/services/manoeuver_sheet_service.dart';
import 'package:frontend/models/manoeuver_sheet.dart';
import 'package:frontend/screens/work_attestation_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/refresh_provider.dart'; // Make sure this path is correct

class NoteDetailsScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailsScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  _NoteDetailsScreenState createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  LockoutNote? _note;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isChargeConsignation = false;
  String? _manoeuverSheetId;
  bool _manoeuverSheetExists = false;
  
  @override
  void initState() {
    super.initState();
    _fetchNoteDetails();
    _checkRoleAndManoeuverSheet();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final refreshProvider = Provider.of<RefreshProvider>(context);

    if (refreshProvider.shouldRefresh) {
      _fetchNoteDetails();
      refreshProvider.refreshCompleted();
    }
  }

  Future<void> _fetchNoteDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiService = ApiService();
      final note = await apiService.getNoteById(widget.noteId);
      
      if (mounted) {
        setState(() {
          _note = note;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _checkRoleAndManoeuverSheet() async {
    _isChargeConsignation = await RoleBasedAccess.isChargeConsignation();
    if (_note != null) {
      try {
        final service = ManoeuverSheetService();
        final sheet = await service.getManoeuverSheetByLockoutNoteId(_note!.id);
        if (sheet != null && sheet.id.isNotEmpty) {
          setState(() {
            _manoeuverSheetId = sheet.id;
            _manoeuverSheetExists = true;
          });
        } else {
          setState(() {
            _manoeuverSheetExists = false;
          });
        }
      } catch (_) {
        setState(() {
          _manoeuverSheetExists = false;
        });
      }
    }
  }

  Future<void> _openOrCreateManoeuverSheet() async {
    final noteId = _note?.id;
    if (noteId == null) return;
    final service = ManoeuverSheetService();
    try {
      ManoeuverSheet? sheet;
      if (_manoeuverSheetExists && _manoeuverSheetId != null) {
        sheet = await service.getManoeuverSheetByLockoutNoteId(noteId);
      } else {
        sheet = await service.createManoeuverSheet(noteId);
      }
      final sheetId = sheet?.id;
      if (sheetId != null && sheetId.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManoeuverSheetScreen(manoeuverSheetId: sheetId),
          ),
        );
        // Refresh the note and manoeuver sheet data after returning
        await _fetchNoteDetails();
        await _checkRoleAndManoeuverSheet();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening manoeuver sheet: ${e.toString()}')),
      );
    }
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
                'Note Details',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Edit button - only visible for Chef de Base and Chef d'Exploitation when note is in DRAFT status
          if (_note != null)
            FutureBuilder<bool>(
              future: Future.wait([
                RoleBasedAccess.isChefDeBase(),
                RoleBasedAccess.isChefExploitation(),
              ]).then((results) => results[0] || results[1]), // Either Chef de Base or Chef d'Exploitation
              builder: (context, snapshot) {
                final bool canEdit = snapshot.data == true && 
                                    _note!.status == NoteStatus.DRAFT;
                
                if (!canEdit) {
                  return const SizedBox.shrink();
                }
                
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Note',
                  onPressed: () => _navigateToEditNote(context, _note!),
                );
              },
            ),
          // Delete button
          FutureBuilder<bool>(
            future: RoleBasedAccess.canDeleteNotes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == false) {
                return const SizedBox.shrink();
              }
              
              return IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete Note',
                onPressed: () => _showDeleteConfirmation(context),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNoteDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_note == null) {
      return const Center(
        child: Text('Note not found'),
      );
    }
    
    return _buildNoteDetails(_note!);
  }
  
  Widget _buildNoteDetails(LockoutNote note) {
    bool showViewManoeuverSheet = _manoeuverSheetExists || (note.consignationCompletedAt != null);
    bool showWorkAttestation = note.deconsignationCompletedAt != null;
    bool showViewManoeuverSheetAfterConsignation =
      note.status == NoteStatus.VALIDATED &&
      note.assignedTo != null &&
      note.consignationCompletedAt != null &&
      note.deconsignationStartedAt == null &&
      _isChargeConsignation;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main information card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Poste HT: ${note.posteHt}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2, // Allow up to 2 lines for long titles
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: _buildStatusChip(note.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Created by: ${note.createdBy?.matricule ?? 'Unknown'}'),
                  Text('Created at: ${_formatDateTime(note.createdAt)}'),
                  
                  // Display validation information
                  if (note.validatedByChefBase != null) ...[  
                    const SizedBox(height: 8),
                    Text('Validated by Chef Base: ${note.validatedByChefBase?.matricule ?? 'Unknown'}'),
                    Text('Validated at: ${_formatDateTime(note.validatedAtChefBase!)}'),
                  ],
                  if (note.validatedByChargeExploitation != null) ...[  
                    const SizedBox(height: 8),
                    Text('Validated by Charge Exploitation: ${note.validatedByChargeExploitation?.matricule ?? 'Unknown'}'),
                    Text('Validated at: ${_formatDateTime(note.validatedAtChargeExploitation!)}'),
                  ],
                ],
              ),
            ),
          ),
          
          // Display rejection reason if the note is rejected
          if (note.status == NoteStatus.REJECTED && note.rejectionReason != null)
            Card(
              margin: const EdgeInsets.only(top: 16),
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Reason',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(note.rejectionReason!),
                  ],
                ),
              ),
            ),
          
          // Equipment Information
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Equipment Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text('Equipment Type: ${note.equipmentType?.displayName ?? 'Not specified'}'),
                  if (note.equipmentDetails != null && note.equipmentDetails!.isNotEmpty) ...[  
                    const SizedBox(height: 8),
                    const Text(
                      'Equipment Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(note.equipmentDetails!),
                  ],
                ],
              ),
            ),
          ),
          
          // Work Information
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Work Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (note.uniteSteg != null && note.uniteSteg!.isNotEmpty)
                    Text('Unité STEG: ${note.uniteSteg}'),
                  if (note.workNature != null && note.workNature!.isNotEmpty)
                    Text('Nature of Work: ${note.workNature}'),
                ],
              ),
            ),
          ),
          
          // Schedule Information
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (note.retraitDate != null)
                    Text('Retrait Date: ${_formatDateTime(note.retraitDate!)}'),
                  if (note.debutTravaux != null)
                    Text('Work Start: ${_formatDateTime(note.debutTravaux!)}'),
                  if (note.finTravaux != null)
                    Text('Work End: ${_formatDateTime(note.finTravaux!)}'),
                  if (note.retourDate != null)
                    Text('Return Date: ${_formatDateTime(note.retourDate!)}'),
                  if (note.joursIndisponibilite != null)
                    Text('Days Unavailable: ${note.joursIndisponibilite}'),
                ],
              ),
            ),
          ),
          
          // Personnel Information
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personnel Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (note.chargeRetrait != null && note.chargeRetrait!.isNotEmpty)
                    Text('Charge Retrait: ${note.chargeRetrait}'),
                  if (note.chargeConsignation != null && note.chargeConsignation!.isNotEmpty)
                    Text('Charge Consignation: ${note.chargeConsignation}'),
                  if (note.chargeTravaux != null && note.chargeTravaux!.isNotEmpty)
                    Text('Charge Travaux: ${note.chargeTravaux}'),
                  if (note.chargeEssais != null && note.chargeEssais!.isNotEmpty)
                    Text('Charge Essais: ${note.chargeEssais}'),
                ],
              ),
            ),
          ),
          
          // Additional Information
          if (note.instructionsTechniques != null || note.destinataires != null || 
              note.coupureDemandeePar != null || note.noteTransmiseA != null)
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    if (note.instructionsTechniques != null && note.instructionsTechniques!.isNotEmpty) ...[  
                      const Text(
                        'Technical Instructions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(note.instructionsTechniques!),
                      const SizedBox(height: 8),
                    ],
                    if (note.destinataires != null && note.destinataires!.isNotEmpty)
                      Text('Recipients: ${note.destinataires}'),
                    if (note.coupureDemandeePar != null && note.coupureDemandeePar!.isNotEmpty)
                      Text('Requested By: ${note.coupureDemandeePar}'),
                    if (note.noteTransmiseA != null && note.noteTransmiseA!.isNotEmpty)
                      Text('Transmitted To: ${note.noteTransmiseA}'),
                  ],
                ),
              ),
            ),
          
          // Action Buttons based on note status
          const SizedBox(height: 24),
          // Draft status - show Submit for Validation button
          if (note.status == NoteStatus.DRAFT) ...[
            const Text(
              'Submit Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: FutureBuilder<bool>(
                future: RoleBasedAccess.canCreateNotes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == false) {
                    return const Text('You do not have permission to submit notes');
                  }
                  
                  return ElevatedButton.icon(
                    onPressed: () => _validateNote(context, note.id, NoteStatus.PENDING_CHEF_BASE),
                    icon: const Icon(Icons.send),
                    label: const Text('Submit for Validation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Pending Chef Base status - show Approve/Reject buttons for Chef de Base
          if (note.status == NoteStatus.PENDING_CHEF_BASE) ...[
            const Text(
              'Validate Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: RoleBasedAccess.canValidateAsChefDeBase(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const Center(
                    child: Text('Only Admins and Chef de Base can validate notes at this stage'),
                  );
                }
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _validateNote(context, note.id, NoteStatus.PENDING_CHARGE_EXPLOITATION),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _validateNote(context, note.id, NoteStatus.REJECTED),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToEditScreen(context, note),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          // Rejected status - show Return to Draft option for Chef d'Exploitation
          if (note.status == NoteStatus.REJECTED) ...[  
            const Text(
              'Note Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: RoleBasedAccess.isChefExploitation(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const SizedBox.shrink();
                }
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _validateNote(context, note.id, NoteStatus.DRAFT),
                      icon: const Icon(Icons.edit),
                      label: const Text('Return to Draft'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Discard Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          
          // Pending Charge Exploitation status - show Approve/Reject buttons for Charge Exploitation
          if (note.status == NoteStatus.PENDING_CHARGE_EXPLOITATION) ...[
            const Text(
              'Validate Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: RoleBasedAccess.canValidateAsChargeExploitation(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const Center(
                    child: Text('Only Admins and Charge Exploitation can validate notes at this stage'),
                  );
                }
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAssignmentDialog(context, note),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve & Assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _validateNote(context, note.id, NoteStatus.REJECTED),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          // For validated notes assigned to Charge Consignation, show consignation/deconsignation buttons
          if (note.status == NoteStatus.VALIDATED && note.assignedTo != null) ...[  
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: RoleBasedAccess.canPerformConsignation(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const SizedBox.shrink();
                }
                
                // Show different buttons based on consignation state
                if (note.consignationStartedAt == null) {
                  // Not consigned yet
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _startConsignation(context, note.id),
                      icon: const Icon(Icons.lock),
                      label: const Text('Start Consignation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  );
                } else if (note.consignationCompletedAt == null) {
                  // Consignation started but not completed
                  return Center(
                    child: Column(
                      children: [
                        Text('Consignation started at: ${_formatDateTime(note.consignationStartedAt!)}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _completeConsignation(context, note.id),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete Consignation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (note.deconsignationStartedAt == null) {
                  // Consignation completed, deconsignation not started
                  return Center(
                    child: Column(
                      children: [
                        Text('Consignation completed at: ${_formatDateTime(note.consignationCompletedAt!)}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _startDeconsignation(context, note.id),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Start Deconsignation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (note.deconsignationCompletedAt == null) {
                  // Deconsignation started but not completed
                  return Center(
                    child: Column(
                      children: [
                        Text('Deconsignation started at: ${_formatDateTime(note.deconsignationStartedAt!)}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _completeDeconsignation(context, note.id),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete Deconsignation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Full cycle completed
                  return Center(
                    child: Column(
                      children: [
                        Text('Deconsignation completed at: ${_formatDateTime(note.deconsignationCompletedAt!)}'),
                        const SizedBox(height: 8),
                        const Text('Consignation cycle completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
          
          // For validated or rejected notes, show a button to return to draft state (if user has permission)
          if (note.status == NoteStatus.VALIDATED || note.status == NoteStatus.REJECTED) ...[
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: RoleBasedAccess.isAdmin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const SizedBox.shrink();
                }
                
                return Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _validateNote(context, note.id, NoteStatus.DRAFT),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Return to Draft'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
          // Insert after the Equipment Information card
          if (showViewManoeuverSheetAfterConsignation && _manoeuverSheetId != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text('View Manoeuver Sheet'),
                onPressed: _openOrCreateManoeuverSheet,
              ),
            ),
          ],
          if (_note != null && _isChargeConsignation && _note!.status == NoteStatus.VALIDATED) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  if (!showWorkAttestation && !showViewManoeuverSheetAfterConsignation) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.assignment),
                      label: Text(showViewManoeuverSheet ? 'View Manoeuver Sheet' : 'Create Manoeuver Sheet'),
                      onPressed: _openOrCreateManoeuverSheet,
                    ),
                  ],
                  if (showWorkAttestation && _manoeuverSheetId != null) ...[
                    FutureBuilder<ManoeuverSheet>(
                      future: ManoeuverSheetService().getManoeuverSheet(_manoeuverSheetId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        final sheet = snapshot.data!;
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.assignment),
                                label: const Text('View Manoeuver Sheet'),
                                onPressed: _openOrCreateManoeuverSheet,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (sheet.workAttestationId != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.verified),
                                  label: const Text('View Work Attestation'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkAttestationScreen(workAttestationId: sheet.workAttestationId!),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(NoteStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case NoteStatus.DRAFT:
        color = Colors.grey;
        label = 'Draft';
        break;
      case NoteStatus.PENDING_CHEF_BASE:
        color = Colors.blue;
        label = 'Pending';
        break;
      case NoteStatus.PENDING_CHARGE_EXPLOITATION:
        color = Colors.orange;
        label = 'Pending';
        break;
      case NoteStatus.VALIDATED:
        color = Colors.green;
        label = 'Validated';
        break;
      case NoteStatus.REJECTED:
        color = Colors.red;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteNote(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteNote(BuildContext context) async {
    try {
      final apiService = ApiService();
      await apiService.deleteNote(widget.noteId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully')),
        );
        
        // Navigate back to the home screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToEditScreen(BuildContext context, LockoutNote note) async {
    // Navigate to edit screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );
    
    // If the edit was successful, refresh the note details
    if (result == true) {
      _fetchNoteDetails();
    }
  }

  Future<String?> _showRejectionReasonDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rejection Reason'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejecting this note:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter rejection reason',
                ),
                maxLines: 3,
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
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a rejection reason')),
                  );
                } else {
                  Navigator.of(context).pop(reasonController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startConsignation(BuildContext context, String noteId) async {
    try {
      final apiService = ApiService();
      await apiService.startConsignation(noteId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consignation started')),
        );
        
        // Refresh the note details
        _fetchNoteDetails();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting consignation: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _completeConsignation(BuildContext context, String noteId) async {
    try {
      final apiService = ApiService();
      await apiService.completeConsignation(noteId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consignation completed')),
        );
        
        // Refresh the note details
        _fetchNoteDetails();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing consignation: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _startDeconsignation(BuildContext context, String noteId) async {
    try {
      final apiService = ApiService();
      await apiService.startDeconsignation(noteId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deconsignation started')),
        );
        
        // Refresh the note details
        _fetchNoteDetails();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting deconsignation: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _completeDeconsignation(BuildContext context, String noteId) async {
    try {
      final apiService = ApiService();
      await apiService.completeDeconsignation(noteId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deconsignation completed')),
        );
        
        // Refresh the note details
        _fetchNoteDetails();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing deconsignation: ${e.toString()}')),
        );
      }
    }
  }

  void _showAssignmentDialog(BuildContext context, LockoutNote note) async {
    // Fetch all users with CHARGE_CONSIGNATION role
    final apiService = ApiService();
    List<User> chargeConsignationUsers = [];
    
    try {
      final allUsers = await apiService.getAllUsers();
      chargeConsignationUsers = allUsers.where((user) => 
        user.role == 'CHARGE_CONSIGNATION').toList();
      
      if (chargeConsignationUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Charge Consignation users available for assignment')),
        );
        return;
      }
      
      // Show dialog to select a user
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Assign Note'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a Charge Consignation user to assign this note:'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: chargeConsignationUsers.length,
                      itemBuilder: (context, index) {
                        final user = chargeConsignationUsers[index];
                        return ListTile(
                          title: Text(user.matricule),
                          subtitle: Text(user.email ?? ''),
                          onTap: () async {
                            Navigator.of(context).pop();
                            
                            // First validate the note
                            await _validateNote(context, note.id, NoteStatus.VALIDATED);
                            
                            // Then assign it to the selected user
                            try {
                              await apiService.assignNote(note.id, int.parse(user.id));
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Note assigned to ${user.matricule}')),
                                );
                                
                                // Refresh the note details
                                _fetchNoteDetails();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error assigning note: ${e.toString()}')),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: ${e.toString()}')),
      );
    }
  }

  Future<void> _validateNote(BuildContext context, String noteId, NoteStatus status) async {
    try {
      final apiService = ApiService();
      
      print('Validating note $noteId with status: ${status.toString()}');
      
      // If rejecting, prompt for rejection reason
      if (status == NoteStatus.REJECTED) {
        final rejectionReason = await _showRejectionReasonDialog(context);
        if (rejectionReason == null) {
          // User cancelled the rejection
          print('Rejection cancelled by user');
          return;
        }
        
        print('Rejecting note with reason: $rejectionReason');
        // Call validateNote with rejection reason
        await apiService.validateNote(noteId, status, rejectionReason: rejectionReason);
      } else if (status == NoteStatus.DRAFT) {
        // Special case for returning a rejected note to draft
        print('Returning rejected note to draft status');
        await apiService.validateNote(noteId, status);
      } else {
        // Normal validation without rejection reason
        print('Normal validation to status: ${status.toString()}');
        await apiService.validateNote(noteId, status);
      }
      
      if (context.mounted) {
        String statusMessage = '';
        switch (status) {
          case NoteStatus.DRAFT:
            statusMessage = 'returned to draft';
            break;
          case NoteStatus.PENDING_CHEF_BASE:
            statusMessage = 'submitted for Chef Base validation';
            break;
          case NoteStatus.PENDING_CHARGE_EXPLOITATION:
            statusMessage = 'submitted for Charge Exploitation validation';
            break;
          case NoteStatus.VALIDATED:
            statusMessage = 'approved';
            break;
          case NoteStatus.REJECTED:
            statusMessage = 'rejected';
            break;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note $statusMessage')),
        );
        
        // Refresh the note details
        _fetchNoteDetails();
        
        // If the status change was to validate or reject, navigate back to the home screen
        if (status == NoteStatus.VALIDATED || status == NoteStatus.REJECTED) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  // Navigate to edit note screen
  Future<void> _navigateToEditNote(BuildContext context, LockoutNote note) async {
    // Navigate to edit screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );
    
    // If the edit was successful, refresh the note details
    if (result == true) {
      _fetchNoteDetails();
    }
  }
}

