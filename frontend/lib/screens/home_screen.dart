import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/lockout_note.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/steg_logo.dart';
import 'package:frontend/utils/role_based_access.dart';
import 'package:frontend/widgets/notification_badge.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/providers/refresh_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotes();
    });

    // Écouter les changements de cycle de vie
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<LockoutNote> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Method to fetch notes
  Future<void> _fetchNotes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final notes = await apiService.getAllNotes();

      if (mounted) {
        setState(() {
          _notes = notes;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh the notes list when the app is resumed
      _fetchNotes();
    }
  }

  // This method is called when the route is pushed or popped
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Écouter les événements de rafraîchissement
    final refreshProvider = Provider.of<RefreshProvider>(context);
    if (refreshProvider.shouldRefresh) {
      _fetchNotes();
      refreshProvider.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const StegLogo(size: 36),
            const SizedBox(width: 8),
            Flexible(
              child: const Text(
                'STEG LOTO - Dashboard',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          // Notification badge with counter
          Consumer<NotificationProvider>(
            builder: (ctx, notificationProvider, _) {
              return NotificationBadge(
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Notifications',
                  onPressed: null, // Handled by NotificationBadge
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                isAppBar: true, // Specify this is in the app bar
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final apiService = ApiService();
              await apiService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StegLogo(size: 60),
                  SizedBox(height: 12),
                  Text(
                    'STEG LOTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Lockout/Tagout System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            FutureBuilder<bool>(
              future: RoleBasedAccess.isAdmin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == false) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text('Admin Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin_dashboard');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('User Management'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/user_management');
                      },
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                final apiService = ApiService();
                await apiService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FutureBuilder<bool>(
        future: RoleBasedAccess.canCreateNotes(),
        builder: (context, snapshot) {
          // If still loading or user can't create notes, don't show the button
          if (!snapshot.hasData || snapshot.data == false) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () async {
              // Navigate to create note screen and refresh when returning
              await Navigator.pushNamed(context, '/create_note');
              // Refresh the notes list
              _fetchNotes();
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  // Method to build the body based on the current state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      String errorMessage = _errorMessage!;

      if (errorMessage.contains('403')) {
        errorMessage =
            'You do not have permission to access this resource. Please check your credentials.';
      } else if (errorMessage.contains('401')) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Auto-redirect to login after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNotes,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Text('No lockout notes found'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchNotes();
      },
      child: ListView.builder(
        itemCount: _notes.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/note_details',
                  arguments: note.id,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                              fontSize: 16,
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
                    const SizedBox(height: 8),
                    Text(
                      'Created by: ${note.createdBy?.matricule ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created at: ${_formatDateTime(note.createdAt)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About STEG LOTO'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'STEG LOTO is a Lockout/Tagout application for managing safety procedures for high-voltage electrical equipment.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Create and manage lockout notes'),
              Text('• Role-based access control'),
              Text('• Validation workflow'),
              Text('• Audit logging'),
              SizedBox(height: 16),
              Text('Version: 1.0.0'),
              Text('© 2025 STEG'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
