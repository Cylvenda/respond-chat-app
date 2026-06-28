import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_theme.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  final bool _isCreatingUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUsers();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _showCreateUserDialog() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isAdmin = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return SwitchListTile(
                      title: const Text('Administrator account'),
                      value: isAdmin,
                      onChanged: (value) {
                        setDialogState(() {
                          isAdmin = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.createUser(
                  email: emailController.text.trim(),
                  fullName: nameController.text.trim(),
                  password: passwordController.text.trim(),
                  isAdmin: isAdmin,
                );

                if (success) {
                  await authProvider.loadUsers();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                } else {
                  final error = authProvider.error ?? 'Failed to create user.';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final users = authProvider.allUsers;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome, ${currentUser?.fullName ?? 'Admin'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCreatingUser ? null : _showCreateUserDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('New User'),
            ),
            const SizedBox(height: 12),
            if (authProvider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.errorColor.withOpacity(0.1),
                ),
                child: Text(
                  authProvider.error!,
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            const SizedBox(height: 12),
            if (authProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (users.isEmpty)
              const Expanded(
                child: Center(child: Text('No users available yet.')),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.fullName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                if (user.isAdmin)
                                  Chip(
                                    label: const Text('Admin'),
                                    backgroundColor: AppTheme.primaryColor
                                        .withOpacity(0.12),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(user.email),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  selected: user.isVerified,
                                  label: const Text('Verified'),
                                  onSelected: (_) async {
                                    final updatedUser = user.copyWith(
                                      isVerified: !user.isVerified,
                                    );
                                    await authProvider.updateUser(updatedUser);
                                  },
                                ),
                                ChoiceChip(
                                  selected: user.isAdmin,
                                  label: const Text('Admin Role'),
                                  onSelected: (_) async {
                                    final updatedUser = user.copyWith(
                                      isAdmin: !user.isAdmin,
                                    );
                                    await authProvider.updateUser(updatedUser);
                                  },
                                ),
                                ChoiceChip(
                                  selected: user.isDisabled,
                                  label: Text(
                                    user.isDisabled ? 'Disabled' : 'Active',
                                  ),
                                  selectedColor: user.isDisabled
                                      ? Colors.red.withOpacity(0.12)
                                      : Colors.green.withOpacity(0.12),
                                  onSelected: (_) async {
                                    final updatedUser = user.copyWith(
                                      isDisabled: !user.isDisabled,
                                    );
                                    await authProvider.updateUser(updatedUser);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (user.id != currentUser?.id)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final shouldDisable = !user.isDisabled;
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              shouldDisable
                                                  ? 'Disable User'
                                                  : 'Enable User',
                                            ),
                                            content: Text(
                                              '${shouldDisable ? 'Disable' : 'Enable'} ${user.fullName}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: Navigator.of(
                                                  context,
                                                ).pop,
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(true);
                                                },
                                                child: Text(
                                                  shouldDisable
                                                      ? 'Disable'
                                                      : 'Enable',
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirm == true) {
                                        final updatedUser = user.copyWith(
                                          isDisabled: shouldDisable,
                                        );
                                        await authProvider.updateUser(
                                          updatedUser,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      user.isDisabled
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                    ),
                                    label: Text(
                                      user.isDisabled ? 'Enable' : 'Disable',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
