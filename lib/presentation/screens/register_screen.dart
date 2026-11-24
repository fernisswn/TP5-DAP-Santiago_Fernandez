// Valida el perfil y crea una cuenta con email y contraseña en Firebase.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error is String ? error : 'No se pudo crear la cuenta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tu perfil',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('Completá tus datos para guardar tu inventario.'),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? 'Ingresá tu nombre.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: _validateRegisterEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: 'Mostrar u ocultar contraseña',
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Usá al menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Las contraseñas no coinciden.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear cuenta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateRegisterEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Ingresá tu correo electrónico.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Ingresá un correo electrónico válido.';
  }
  return null;
}
