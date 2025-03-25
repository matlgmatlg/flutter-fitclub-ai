import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/translations.dart';
import '../../widgets/common/index.dart';
import '../../services/auth_service.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const backgroundColor = Color(0xFF1A1A1A);
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isTrainer = false;
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(_emailController.text, _passwordController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          _isTrainer ? '/trainer/client-list' : '/client/dashboard',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _t(String key) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    return Translations.get(language, key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              children: [
                // Left side - Image and Quote
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      image: DecorationImage(
                        image: AssetImage('assets/FitClub Context/nexur_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo in top-left
                        Positioned(
                          top: 32,
                          left: 32,
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              overlayColor: Colors.transparent,
                            ).copyWith(
                              splashFactory: NoSplash.splashFactory,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Fit',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w100,
                                      fontSize: 32,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Club',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.primaryColor.withOpacity(0.7),
                                      fontWeight: FontWeight.w100,
                                      fontSize: 32,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '"${_t('login_quote')}"',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _t('quote_author'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right side - Login Form
                Expanded(
                  child: Container(
                    color: backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 1),
                        // Login Form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('login'),
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 32,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('welcome_back'),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 60),
                            
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email Field
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t('email'),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _emailController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white24),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white24),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: AppTheme.primaryColor),
                                          ),
                                          contentPadding: EdgeInsets.only(bottom: 8),
                                          isDense: true,
                                          filled: false,
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return _t('email_validation');
                                          }
                                          if (!value.contains('@')) {
                                            return _t('email_invalid');
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t('password'),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _passwordController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white24),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white24),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: AppTheme.primaryColor),
                                          ),
                                          isDense: true,
                                          filled: false,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showPassword ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.white54,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: !_showPassword,
                                        textInputAction: TextInputAction.done,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return _t('password_validation');
                                          }
                                          if (value.length < 6) {
                                            return _t('password_length');
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 48),

                                  // Error Message
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                  // Login Button and Forgot Password
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  _t('login_button'),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Text(
                                              _t('forgot_password'),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),

                        // Sign Up Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _t('no_account'),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.only(left: 8),
                                ),
                                child: Text(
                                  _t('sign_up'),
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Language Selector
          Positioned(
            top: 16,
            right: 16,
            child: LanguageSelector(
              currentLanguage: Provider.of<LanguageProvider>(context).currentLanguage,
              onLanguageChanged: (language) {
                Provider.of<LanguageProvider>(context, listen: false)
                    .setLanguage(language);
              },
            ),
          ),
        ],
      ),
    );
  }
} 