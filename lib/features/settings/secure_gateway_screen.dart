import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_theme.dart';
import 'settings_screen.dart'; // To access securitySettingsProvider

// A simple global state provider to track if the session is unlocked
final sessionUnlockedProvider = StateProvider<bool>((ref) => false);

class SecureGatewayScreen extends ConsumerStatefulWidget {
  final String redirectPath;
  SecureGatewayScreen({super.key, required this.redirectPath});

  @override
  ConsumerState<SecureGatewayScreen> createState() => _SecureGatewayScreenState();
}

class _SecureGatewayScreenState extends ConsumerState<SecureGatewayScreen> {
  final _pinCtrl = TextEditingController();
  bool _hasError = false;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometric();
    });
  }

  Future<void> _checkBiometric() async {
    final settings = await ref.read(securitySettingsProvider.future);
    if (settings != null && settings.isBiometricEnabled) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
        if (!canCheck) return;
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to unlock Sri Ranga Medical',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
        if (authenticated) {
          ref.read(sessionUnlockedProvider.notifier).state = true;
          if (mounted) {
            context.go(widget.redirectPath.isEmpty || widget.redirectPath == '/secure-gateway' ? '/' : widget.redirectPath);
          }
        }
      } catch (e) {
        // Silently fallback to PIN
      }
    }
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final settings = await ref.read(securitySettingsProvider.future);
    if (settings != null && settings.securePinHash == _pinCtrl.text.trim()) {
      ref.read(sessionUnlockedProvider.notifier).state = true;
      if (mounted) {
        context.go(widget.redirectPath.isEmpty || widget.redirectPath == '/secure-gateway' ? '/' : widget.redirectPath);
      }
    } else {
      setState(() {
        _hasError = true;
        _pinCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: context.colors.primary),
              SizedBox(height: 24),
              Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
              SizedBox(height: 8),
              Text('Enter your 4-digit PIN to access', style: TextStyle(color: context.colors.textMuted)),
              SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pinCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: context.colors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    errorText: _hasError ? 'Incorrect PIN' : null,
                  ),
                  onChanged: (v) {
                    if (_hasError) setState(() => _hasError = false);
                    if (v.length == 4) _verifyPin();
                  },
                  onSubmitted: (_) => _verifyPin(),
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _verifyPin,
                      child: Text('Unlock', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.surfaceElevated,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(Icons.fingerprint, size: 24, color: context.colors.primary),
                    onPressed: _checkBiometric,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
