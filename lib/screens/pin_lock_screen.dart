import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback? onUnlock;

  const PinLockScreen({super.key, this.isSetup = false, this.onUnlock});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final List<int> _pin = [];
  final int _pinLength = 4;
  bool _isConfirming = false;
  List<int> _confirmPin = [];
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isSetup) {
      _checkExistingPin();
    }
  }

  Future<void> _checkExistingPin() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPin = prefs.getString('app_pin');
    if (existingPin != null) {
      // PIN already exists, this should be unlock mode
      setState(() {
        _isConfirming = false;
      });
    }
  }

  void _addDigit(int digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(digit);
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _handlePinComplete() async {
    if (widget.isSetup) {
      if (!_isConfirming) {
        // First time entering PIN
        setState(() {
          _confirmPin = List.from(_pin);
          _pin.clear();
          _isConfirming = true;
        });
      } else {
        // Confirming PIN
        if (_pin.length == _confirmPin.length &&
            _pin.every((digit) => _confirmPin.contains(digit))) {
          // PINs match, save it
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_pin', _pin.join());

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN set successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onUnlock?.call();
          }
        } else {
          // PINs don't match
          setState(() {
            _isError = true;
            _pin.clear();
            _confirmPin.clear();
            _isConfirming = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PINs do not match. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Unlock mode
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('app_pin');

      if (savedPin == _pin.join()) {
        // Correct PIN
        if (mounted) {
          widget.onUnlock?.call();
        }
      } else {
        // Wrong PIN
        setState(() {
          _isError = true;
          _pin.clear();
        });
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect PIN. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lgSpacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.book, size: 40, color: Colors.white),
                ),

                const SizedBox(height: AppConstants.xlSpacing),

                // Title
                Text(
                  widget.isSetup ? 'Set Up PIN' : 'Enter PIN',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 24),
                ),

                const SizedBox(height: AppConstants.smSpacing),

                // Subtitle
                Text(
                  widget.isSetup
                      ? _isConfirming
                            ? 'Confirm your PIN'
                            : 'Create a 4-digit PIN to secure your app'
                      : 'Enter your PIN to unlock the app',
                  style: AppTheme.getBodyStyle(context).copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.xlSpacing),

                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final isFilled = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isError
                            ? Colors.red
                            : isFilled
                            ? AppConstants.primaryColor
                            : Colors.grey[400],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppConstants.xlSpacing),

                // Number pad
                Column(
                  children: List.generate(3, (row) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (col) {
                        final number = row * 3 + col + 1;
                        return _buildNumberButton(number);
                      }),
                    );
                  }),
                ),

                // Bottom row (0, backspace)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 60), // Spacer
                    _buildNumberButton(0),
                    _buildBackspaceButton(),
                  ],
                ),

                const SizedBox(height: AppConstants.lgSpacing),

                // Forgot PIN option (only in unlock mode)
                if (!widget.isSetup)
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot PIN functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact support to reset your PIN'),
                        ),
                      );
                    },
                    child: const Text('Forgot PIN?'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _addDigit(number),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: _removeDigit,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: const Icon(Icons.backspace, size: 24),
        ),
      ),
    );
  }
}
