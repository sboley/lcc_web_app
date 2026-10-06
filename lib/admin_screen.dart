import 'package:flutter/material.dart';

import 'services/menu_api.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _flavorsController = TextEditingController();
  final _api = MenuApi();

  String? _token;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _flavorsController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _api.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      final menu = await _api.getMenu();
      if (!mounted) return;
      _flavorsController.text = menu.flavors.join('\n');
      setState(() {
        _token = token;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to sign in: $error';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final flavors = _flavorsController.text
        .split('\n')
        .map((flavor) => flavor.trim())
        .where((flavor) => flavor.isNotEmpty)
        .toList();
    if (flavors.isEmpty) {
      setState(() => _error = 'Enter at least one flavor before saving.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.updateFlavors(_token!, flavors);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Flavors saved.')));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to save flavors: $error';
        _loading = false;
      });
    }
  }

  void _logout() {
    setState(() {
      _token = null;
      _passwordController.clear();
      _flavorsController.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = _token != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.pink[100],
        actions: [
          if (isSignedIn)
            TextButton(
              onPressed: _loading ? null : _logout,
              child: const Text('Log out'),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isSignedIn ? _buildFlavorEditor() : _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Admin login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
          enabled: !_loading,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onSubmitted: (_) => _loading ? null : _login(),
          enabled: !_loading,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _loading ? null : _login,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
      ],
    );
  }

  Widget _buildFlavorEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Edit flavors',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Enter one flavor or section heading per line.'),
        const SizedBox(height: 16),
        TextField(
          controller: _flavorsController,
          minLines: 16,
          maxLines: 24,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            labelText: 'Current flavors',
          ),
          enabled: !_loading,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _save,
          icon: const Icon(Icons.save),
          label: Text(_loading ? 'Saving...' : 'Save flavors'),
        ),
      ],
    );
  }
}
