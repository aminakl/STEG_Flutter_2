import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../utils/auth_utils.dart';
import '../widgets/notification_badge.dart';
import '../utils/role_based_access.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: AuthUtils.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          final userInfo = snapshot.data ?? {};
          final String role = userInfo['role'] ?? '';
          final String matricule = userInfo['matricule'] ?? '';
          final String email = userInfo['email'] ?? '';
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(matricule),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    matricule.isNotEmpty ? matricule[0].toUpperCase() : 'U',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
              if (role == 'CHEF_EXPLOITATION')
                ListTile(
                  leading: Icon(Icons.note_add),
                  title: Text('Create Note'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_note');
                  },
                ),
              ListTile(
                leading: NotificationBadge(
                  child: Icon(Icons.notifications),
                  onTap: () {},
                ),
                title: Text('Notifications'),
                onTap: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
              ),
              FutureBuilder<bool>(
                future: RoleBasedAccess.canAccessDashboard(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text('Admin Dashboard'),
                    onTap: () {
                      Navigator.of(context).pushNamed('/admin_dashboard');
                    },
                  );
                },
              ),
              FutureBuilder<bool>(
                future: RoleBasedAccess.isAdmin(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: Icon(Icons.people),
                    title: Text('User Management'),
                    onTap: () {
                      Navigator.of(context).pushNamed('/user_management');
                    },
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () async {
                  await AuthUtils.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
