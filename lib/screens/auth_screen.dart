import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1722),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 60),
              _buildSocialLogin(),
              const SizedBox(height: 40),
              _buildDivider(),
              const SizedBox(height: 40),
              _buildEmailLogin(),
              const SizedBox(height: 30),
              _buildToggleAuth(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrangeAccent, Colors.orange.shade700],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 40),
        ).animate().scale(delay: 200.ms),
        const SizedBox(height: 24),
        Text(
          _isSignUp ? 'Create Account' : 'Welcome Back',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 8),
        Text(
          _isSignUp 
            ? 'Start planning your dream trips'
            : 'Sign in to continue your journey',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Center(
      child: SizedBox(
        width: 250,
        child: _buildSocialButton(
          'Continue with Google',
          Icons.g_mobiledata,
          Colors.white,
          Colors.black,
          () => _signInWithGoogle(),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ).animate().slideX(begin: -0.3, delay: 800.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }

  Widget _buildEmailLogin() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.deepOrangeAccent),
            filled: true,
            fillColor: const Color(0xFF1A2332),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepOrangeAccent),
            ),
          ),
        ).animate().slideX(begin: 0.3, delay: 1200.ms),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepOrangeAccent),
            filled: true,
            fillColor: const Color(0xFF1A2332),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepOrangeAccent),
            ),
          ),
        ).animate().slideX(begin: -0.3, delay: 1400.ms),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signInWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
          ),
        ).animate().scale(delay: 1600.ms),
      ],
    );
  }

  Widget _buildToggleAuth() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
          style: const TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isSignUp = !_isSignUp;
            });
          },
          child: Text(
            _isSignUp ? 'Sign In' : 'Sign Up',
            style: const TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1800.ms);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to sign in with Google');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    try {
      final user = await AuthService().signInWithApple();
      if (user != null && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to sign in with Apple');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    try {
      final user = await AuthService().signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to sign in');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}