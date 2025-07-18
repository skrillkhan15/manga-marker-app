import 'package:flutter/material.dart';
import 'package:manga_marker/auth_manager.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const PinLockScreen({super.key, required this.onAuthenticated});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSettingPin = false;
  String? _error;
  String? _firstPinEntry;
  final AuthManager _authManager = AuthManager();

  @override
  void initState() {
    super.initState();
    _checkIfPinSet();
  }

  Future<void> _checkIfPinSet() async {
    final pin = await _authManager.getPin();
    setState(() {
      _isSettingPin = pin == null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final pin = _pinController.text;
    if (_isSettingPin) {
      if (_firstPinEntry == null) {
        setState(() {
          _firstPinEntry = pin;
          _pinController.clear();
          _error = 'Re-enter PIN to confirm';
        });
      } else if (_firstPinEntry == pin) {
        await _authManager.setPin(pin);
        widget.onAuthenticated();
      } else {
        setState(() {
          _error = 'PINs do not match. Try again.';
          _firstPinEntry = null;
          _pinController.clear();
        });
      }
    } else {
      final valid = await _authManager.verifyPin(pin);
      if (valid) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _error = 'Incorrect PIN.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _isSettingPin ? 'Set a 4-digit PIN' : 'Enter your PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'PIN'),
                  validator: (value) {
                    if (value == null || value.length != 4)
                      return 'Enter 4 digits';
                    if (!RegExp(r'^\d{4}').hasMatch(value))
                      return 'Digits only';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    _isSettingPin
                        ? (_firstPinEntry == null ? 'Next' : 'Set PIN')
                        : 'Unlock',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
