import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/role_based_access.dart';
import 'package:frontend/widgets/steg_logo.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }
  
  Future<void> _fetchUsers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final apiService = ApiService();
      final users = await apiService.getAllUsers();
      
      if (mounted) {
        setState(() {
          _users = users;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const StegLogo(size: 40),
            const SizedBox(width: 12),
            const Text('User Management'),
          ],
        ),
      ),
      body: FutureBuilder<bool>(
        future: RoleBasedAccess.isAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.data == false) {
            return const Center(
              child: Text(
                'You do not have permission to access this page.\nOnly administrators can manage users.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and registration form in a scrollable container
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Register New User',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _RegisterUserForm(onUserAdded: _fetchUsers),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Existing Users',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Users list in an expanded container
                  Expanded(
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                        ? Center(child: Text('Error: $_errorMessage'))
                        : _UsersList(users: _users, onRefresh: _fetchUsers),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegisterUserForm extends StatefulWidget {
  final Function onUserAdded;

  const _RegisterUserForm({Key? key, required this.onUserAdded}) : super(key: key);

  @override
  _RegisterUserFormState createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<_RegisterUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'CHARGE_CONSIGNATION';
  bool _isLoading = false;

  @override
  void dispose() {
    _matriculeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TextFormField(
            controller: _matriculeController,
            decoration: const InputDecoration(
              labelText: 'Matricule',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a matricule';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            value: _selectedRole,
            items: const [
              DropdownMenuItem(
                value: 'ADMIN',
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: 'CHEF_EXPLOITATION',
                child: Text('Chef d\'exploitation'),
              ),
              DropdownMenuItem(
                value: 'CHEF_DE_BASE',
                child: Text('Chef de base'),
              ),
              DropdownMenuItem(
                value: 'CHARGE_EXPLOITATION',
                child: Text('Chargé d\'exploitation'),
              ),
              DropdownMenuItem(
                value: 'CHARGE_CONSIGNATION',
                child: Text('Chargé de consignation'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register User'),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        await apiService.register(
          _matriculeController.text,
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully')),
          );
          
          // Clear the form
          _matriculeController.clear();
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            _selectedRole = 'CHARGE_CONSIGNATION';
          });
          
          // Refresh the users list
          widget.onUserAdded();
          
          // Wait a moment and then refresh the UI
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onUserAdded();
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
  }
}

class _UsersList extends StatelessWidget {
  final List<User> users;
  final Function onRefresh;

  const _UsersList({Key? key, required this.users, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found or user listing not implemented yet.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.matricule),
            subtitle: Text(user.email ?? 'No email provided'),
            trailing: Chip(
              label: Text(user.role),
              backgroundColor: _getRoleColor(user.role),
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'CHEF_EXPLOITATION':
        return Colors.orange;
      case 'CHARGE_CONSIGNATION':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
