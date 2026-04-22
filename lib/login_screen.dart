import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'audio_handler.dart';
import 'main.dart';
import 'navidrome_api.dart';
import 'tracks_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _checkedSavedLogin = false;
  bool _rememberLogin = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_login') ?? false;
    final savedUrl = prefs.getString('server_url');
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (!mounted) return;

    setState(() {
      _rememberLogin = remember;
      if (savedUrl != null) _serverController.text = savedUrl;
      if (savedUsername != null) _usernameController.text = savedUsername;
      if (savedPassword != null) _passwordController.text = savedPassword;
    });

    if (remember &&
        savedUrl != null &&
        savedUsername != null &&
        savedPassword != null) {
      final api = NavidromeApi(
        baseUrl: savedUrl,
        username: savedUsername,
        password: savedPassword,
      );

      try {
        await api.ping();
        (audioHandler as PulseAudioHandler).updateApi(api);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TracksShell(api: api)),
        );
        return;
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _checkedSavedLogin = true;
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = NavidromeApi(
      baseUrl: _serverController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    try {
      await api.ping();
      (audioHandler as PulseAudioHandler).updateApi(api);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_login', _rememberLogin);
      if (_rememberLogin) {
        await prefs.setString('server_url', _serverController.text.trim());
        await prefs.setString('username', _usernameController.text.trim());
        await prefs.setString('password', _passwordController.text);
      } else {
        await prefs.remove('server_url');
        await prefs.remove('username');
        await prefs.remove('password');
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TracksShell(api: api)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedSavedLogin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pulse',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect to your Navidrome server',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _serverController,
                          label: 'Server URL',
                          hint: 'e.g. http://music.local:4533',
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _usernameController,
                          label: 'Username',
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          value: _rememberLogin,
                          onChanged: (value) {
                            setState(() {
                              _rememberLogin = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.accent,
                          title: const Text('Remember login info'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _loading ? null : _connect,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Connect'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}