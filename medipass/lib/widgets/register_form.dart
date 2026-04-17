// lib/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour les input formatters
import 'package:medipass/services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onLoginInstead;

  const RegisterForm({Key? key, required this.onLoginInstead}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _dateNaissance;

  // --- MODIFICATION POUR LE SEXE ---
  String? _selectedSexeValue; // Va contenir 'Masculin' ou 'Féminin'

  final List<Map<String, String>> _sexeOptions = [
    {'display': 'Homme', 'value': 'Masculin'}, // Affichage "Homme", valeur backend "Masculin"
    {'display': 'Femme', 'value': 'Féminin'},  // Affichage "Femme", valeur backend "Féminin"
    // Si vous voulez un troisième choix "Autre" et que votre DB a été adaptée:
    // {'display': 'Autre', 'value': 'Autre'}, // Assurez-vous que la contrainte DB inclut 'Autre'
  ];
  // --- FIN MODIFICATION POUR LE SEXE ---

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDatePickerDate =
        _dateNaissance ?? DateTime.now().subtract(const Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      helpText: 'SÉLECTIONNER DATE DE NAISSANCE',
      cancelText: 'ANNULER',
      confirmText: 'OK',
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateNaissance) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_dateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner votre date de naissance.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_selectedSexeValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner votre sexe.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _dateNaissance!,
        sexe: _selectedSexeValue!, // Enverra 'Masculin' ou 'Féminin'
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Inscription réussie !'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState?.reset();
        setState(() {
          _dateNaissance = null;
          _selectedSexeValue = null;
        });
        widget.onLoginInstead();
      } else {
        String errorMessage = result['message'] ?? 'Erreur lors de l\'inscription.';
        if (result.containsKey('errors') && result['errors'] is List && (result['errors'] as List).isNotEmpty) {
          final errorsList = result['errors'] as List;
          final errorsString = errorsList.map((e) => e.toString()).join('\n');
          errorMessage = errorsString;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur inattendue: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Créer un compte',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person_outline)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Le nom est requis.';
                  if (value.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Prénom
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person_outline)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Le prénom est requis.';
                  if (value.trim().length < 2) return 'Le prénom doit contenir au moins 2 caractères.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Date de Naissance
              FormField<DateTime>(
                builder: (FormFieldState<DateTime> field) {
                  return InkWell(
                    onTap: () async {
                      await _selectDate(context);
                      field.didChange(_dateNaissance);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        errorText: field.errorText,
                      ),
                      child: Text(
                        _dateNaissance == null
                            ? 'Non sélectionnée'
                            : '${_dateNaissance!.day.toString().padLeft(2, '0')}/${_dateNaissance!.month.toString().padLeft(2, '0')}/${_dateNaissance!.year}',
                      ),
                    ),
                  );
                },
                validator: (value) {
                  if (_dateNaissance == null) return 'La date de naissance est requise.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Sexe
              DropdownButtonFormField<String>(
                value: _selectedSexeValue,
                decoration: const InputDecoration(
                  labelText: 'Sexe',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                hint: const Text('Sélectionner...'),
                isExpanded: true,
                items: _sexeOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'], // Sera 'Masculin' ou 'Féminin'
                    child: Text(option['display']!), // Sera "Homme" ou "Femme"
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSexeValue = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner votre sexe.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Le téléphone est requis.';
                  if (value.trim().length < 9) return 'Numéro de téléphone invalide.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'L\'email est requis.';
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Veuillez entrer un email valide.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le mot de passe est requis.';
                  if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères.';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Confirmer le mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez confirmer le mot de passe.';
                  if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas.';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _isLoading ? null : _register(),
              ),
              const SizedBox(height: 25),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _register,
                child: const Text('S\'INSCRIRE', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ?"),
                  TextButton(
                    onPressed: widget.onLoginInstead,
                    child: const Text('Se connecter'),
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

