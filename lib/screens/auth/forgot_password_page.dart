import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/translations.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/language_selector.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _t(String key) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    return Translations.get(language, key);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement password reset logic
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // Left side - Image and Quote
          Expanded(
            child: Container(
              color: const Color(0xFF1a1a1a),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fit',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w100,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Club',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.primaryColor.withOpacity(0.7),
                            fontWeight: FontWeight.w100,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '"${_t('login_quote')}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t('quote_author'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Reset Password Form
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  // Top bar with language selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_t('back_to_login')),
                        ),
                        const SizedBox(width: 24),
                        LanguageSelector(
                          currentLanguage: languageProvider.currentLanguage,
                          onLanguageChanged: (language) {
                            languageProvider.setLanguage(language);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Form content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('forgot_password_title'),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w100,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _t('forgot_password_subtitle'),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('email'),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: _t('email_hint'),
                                      hintStyle: const TextStyle(color: Colors.white60),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white54),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white54),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      errorStyle: const TextStyle(color: Colors.white70),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return _t('email_validation');
                                      }
                                      if (!value.contains('@') || !value.contains('.')) {
                                        return _t('email_invalid');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        _t('reset_password'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w100,
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 