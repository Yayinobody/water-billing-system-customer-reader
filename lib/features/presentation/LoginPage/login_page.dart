import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/LoginProvider/auth_provider.dart';
import '../HomePageCustomer/customer_dashboard.dart';
import 'ForgotPassword/forgot_password.dart';
import 'ActivateAccount/activate_account.dart';
import 'ApplicationForm/application_form.dart';
import 'Landing/landing_page.dart';
import '../HomePageReader/reader_dashboard.dart';
import '../HomePageCustomer/Chatbot/chatbot_fab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String accountNumber = _accountController.text.trim();
    final String password = _passwordController.text.trim();

    if (accountNumber.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter your account number and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role = await authProvider.login(
        accountNumber: accountNumber,
        password: password,
      );
      print(role);
      if (role == 'reader') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ReaderDashboardPage()),
          );
        }
      } else if (role == 'customer') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
        _showErrorDialog('A technical error occurred. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.\nError: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true),
      // 👇 ADD THIS PART
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showChatbotSheet(context),
        icon: const Icon(Icons.chat_bubble, color: Colors.white),
        label: const Text(
          'Chat Assistant',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: colors.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WaterBillingLandingPage(), // 👈 page 1
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'gripometer',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'Log in to your account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.account_circle, color: colors.primary),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscured, // 👈 Use the variable here
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: colors.primary),
                  // 👈 Add the suffixIcon below
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: colors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary, // Button background
                  foregroundColor:
                      Colors.white, // Ensures text & icons are white
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  minimumSize: const Size.fromHeight(50), // full-width button
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Log In',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white, // override to ensure white
                        ),
                      ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(), // 👈 page 1
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.labelSmall, // ✅ Secondary
                ),
              ),
              const SizedBox(height: 10),

              const Divider(),
              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivateAccountPage(), // 👈 page 1
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colors.primary), // ✅ Primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Activate your Account',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WaterApplicationFormPage(), // 👈 page 1
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      colors.secondary, // ✅ Fill with secondary color
                  foregroundColor: Colors.white, // ✅ Text & icon color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Water Application Account',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
