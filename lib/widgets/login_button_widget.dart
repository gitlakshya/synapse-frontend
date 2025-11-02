import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginButtonWidget extends StatelessWidget {
  final bool showLabel;
  const LoginButtonWidget({super.key, this.showLabel = true});

  void _showLoginModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return PopupMenuButton<String>(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF007BFF),
              child: Text(
                authProvider.user!.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              authProvider.user!.name,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
            ),
          ],
        ),
        tooltip: authProvider.user!.name,
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            enabled: false,
            child: Text(authProvider.user!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: const Row(children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Logout')]),
          ),
        ],
        onSelected: (value) {
          if (value == 'logout') authProvider.signOut();
        },
      );
    }

    if (!showLabel) {
      return IconButton(
        icon: const Icon(Icons.account_circle),
        color: const Color(0xFF007BFF),
        tooltip: 'Login / Sign Up',
        onPressed: () => _showLoginModal(context),
      );
    }

    return InkWell(
      onTap: () => _showLoginModal(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, color: const Color(0xFF007BFF)),
            const SizedBox(width: 8),
            Text(
              'Login',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginModal extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginModal({super.key, this.onLoginSuccess});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    final authProvider = context.read<AuthProvider>();
                    authProvider.mockSignIn('Google User', 'user@gmail.com');
                    Navigator.pop(context);
                    widget.onLoginSuccess?.call();
                  }
                },
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Image.network(
                        'https://www.google.com/favicon.ico',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 20),
                      ),
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
