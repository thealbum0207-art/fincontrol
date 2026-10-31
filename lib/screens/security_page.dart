import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const _storage = FlutterSecureStorage();

String _derivePin(Map<String, String> payload) {
  List<int> bytes = utf8.encode('${payload['salt']}:${payload['pin']}');
  // The salt + repeated derivation provides protection in addition to
  // encrypted Android Keystore-backed application storage.
  for (var i = 0; i < 25000; i++) {
    bytes = sha256.convert(bytes).bytes;
  }
  return base64UrlEncode(bytes);
}

class PinProtection {
  static Future<bool> hasPin() async =>
      (await _storage.read(key: 'fincontrol_pin_hash')) != null;

  static Future<bool> biometricsEnabled() async =>
      (await _storage.read(key: 'fincontrol_biometrics')) == 'true';

  static Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) {
      throw ArgumentError('O PIN precisa ter de 4 a 8 dígitos.');
    }
    final salt = base64UrlEncode(
      List<int>.generate(24, (_) => Random.secure().nextInt(256)));
    final hash = await compute(_derivePin, {'salt': salt, 'pin': pin});
    await _storage.write(key: 'fincontrol_pin_salt', value: salt);
    await _storage.write(key: 'fincontrol_pin_hash', value: hash);
  }

  static Future<bool> verify(String pin) async {
    final stored = await _storage.read(key: 'fincontrol_pin_hash');
    final salt = await _storage.read(key: 'fincontrol_pin_salt');
    if (stored == null || salt == null) return false;
    final hash = await compute(_derivePin, {'salt': salt, 'pin': pin});
    // Constant-time comparison avoids early mismatch timing disclosure.
    final a = utf8.encode(stored), b = utf8.encode(hash);
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) { difference |= a[i] ^ b[i]; }
    return difference == 0;
  }

  static Future<void> disable(String pin) async {
    if (!await verify(pin)) throw StateError('PIN incorreto.');
    await _storage.delete(key: 'fincontrol_biometrics');
    await _storage.delete(key: 'fincontrol_pin_hash');
    await _storage.delete(key: 'fincontrol_pin_salt');
  }

  static Future<bool> canUseBiometrics() async {
    final auth = LocalAuthentication();
    return await auth.canCheckBiometrics &&
        (await auth.getAvailableBiometrics()).isNotEmpty;
  }

  static Future<void> setBiometrics(bool enabled) async {
    if (enabled && (!await hasPin() || !await canUseBiometrics())) {
      throw StateError('Ative o PIN e cadastre uma biometria no aparelho.');
    }
    await _storage.write(key: 'fincontrol_biometrics',
        value: enabled.toString());
  }

  static Future<bool> authenticateBiometric() async {
    if (!await biometricsEnabled()) return false;
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: 'Desbloquear suas finanças no FinControl',
        options: const AuthenticationOptions(
          biometricOnly: true, stickyAuth: true),
      );
    } catch (_) { return false; }
  }
}

/// Locks previously protected data on foreground return and cold start.
/// It NEVER removes local financial records on failed authentication.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _ready = false;
  bool _locked = false;
  bool _verifying = false;
  final _pin = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final locked = await PinProtection.hasPin();
      if (!mounted) return;
      setState(() { _ready = true; _locked = locked; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _ready = true; _locked = true;
        _error = 'Não foi possível acessar a proteção local: $e'; });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Recheck when returning so a newly configured PIN is also enforced.
      _ready = false;
      _locked = true;
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  Future<void> _unlock() async {
    if (_verifying) return;
    setState(() { _verifying = true; _error = null; });
    try {
      final good = await PinProtection.verify(_pin.text);
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _locked = !good;
        _error = good ? null : 'PIN incorreto.';
      });
      if (good) _pin.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() { _verifying = false;
        _error = 'Erro ao verificar o PIN. Seus dados continuam protegidos.'; });
    }
  }

  Future<void> _biometrics() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    final success = await PinProtection.authenticateBiometric();
    if (!mounted) return;
    setState(() {
      _verifying = false;
      if (success) { _ready = true; _locked = false; _error = null; }
      else { _error = 'Biometria não validada. Use seu PIN.'; }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(
      body: Center(child: CircularProgressIndicator()));
    if (!_locked) return widget.child;
    return Scaffold(body: SafeArea(child: Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
        child: ListView(shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.lock_outline_rounded, size: 60),
            const SizedBox(height: 14),
            const Text('FinControl protegido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Informe seu PIN para acessar suas finanças.',
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(controller: _pin, obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8, onSubmitted: (_) => _unlock(),
              decoration: const InputDecoration(labelText: 'PIN')),
            if (_error != null) Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            FilledButton(onPressed: _verifying ? null : _unlock,
              child: const Text('Desbloquear')),
            OutlinedButton.icon(onPressed: _verifying ? null : _biometrics,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Tentar biometria')),
          ],
        )),
    )));
  }
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _loading = true;
  bool _hasPin = false, _biometrics = false;
  String? _error;

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    try {
      final has = await PinProtection.hasPin();
      final bio = await PinProtection.biometricsEnabled();
      if (!mounted) return;
      setState(() { _hasPin = has; _biometrics = bio;
        _loading = false; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = '$e'; });
    }
  }

  Future<String?> _askPin(String title) async {
    final c = TextEditingController();
    final pin = await showDialog<String>(context: context, builder: (ctx) =>
      AlertDialog(title: Text(title),
        content: TextField(controller: c, obscureText: true,
          maxLength: 8, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN de 4 a 8 dígitos')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('Confirmar')),
        ]));
    c.dispose();
    return pin;
  }

  Future<void> _changePin() async {
    final oldPin = _hasPin ? await _askPin('PIN atual') : null;
    if (_hasPin && (oldPin == null || !await PinProtection.verify(oldPin))) {
      if (mounted) setState(() => _error = 'PIN atual não confirmado.');
      return;
    }
    if (!mounted) return;
    final newPin = await _askPin('Definir novo PIN');
    if (newPin == null) return;
    if (!mounted) return;
    final again = await _askPin('Repetir novo PIN');
    if (again != newPin) {
      if (mounted) setState(() => _error = 'Os PINs não coincidem.');
      return;
    }
    try { await PinProtection.setPin(newPin); await _refresh(); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
  }

  Future<void> _removePin() async {
    final pin = await _askPin('Confirmar desativação');
    if (pin == null) return;
    try { await PinProtection.disable(pin); await _refresh(); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
  }

  Future<void> _toggleBio(bool enabled) async {
    try { await PinProtection.setBiometrics(enabled); await _refresh(); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Proteção do aplicativo')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : ListView(padding: const EdgeInsets.all(18), children: [
        const ListTile(leading: Icon(Icons.shield_outlined),
          title: Text('Proteção local opcional'),
          subtitle: Text('Seu PIN é guardado como verificador protegido '
            'no aparelho. Não há recuperação remota do PIN.')),
        if (_error != null) ListTile(title: Text(_error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error))),
        Card(child: ListTile(
          title: Text(_hasPin ? 'Alterar PIN' : 'Ativar PIN'),
          subtitle: const Text('4 a 8 dígitos'),
          onTap: _changePin, trailing: const Icon(Icons.chevron_right))),
        if (_hasPin)
          Card(child: ListTile(title: const Text('Desativar PIN'),
            onTap: _removePin, trailing: const Icon(Icons.lock_open))),
        SwitchListTile(title: const Text('Desbloquear por biometria'),
          subtitle: const Text('Requer PIN e biometria cadastrada no aparelho'),
          value: _biometrics, onChanged: _hasPin ? _toggleBio : null),
        const Padding(padding: EdgeInsets.all(12),
          child: Text('Faça backup antes de ativar. A perda do PIN poderá '
            'impedir o acesso aos dados locais.')),
      ]),
  );
}
