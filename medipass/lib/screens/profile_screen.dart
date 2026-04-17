import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer; // Pour le débogage

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  final ThemeData currentTheme;

  const ProfileScreen({
    Key? key,
    required this.userEmail,
    required this.currentTheme,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    developer.log("1. Tentative d'ouverture de la galerie...", name: "ProfileUpload");

    // Étape 1 : Choisir l'image depuis la galerie
    final XFile? image;
    try {
      image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    } catch (e) {
      developer.log("ERREUR lors de l'accès à la galerie: $e", name: "ProfileUpload", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur d'accès à la galerie: $e"), backgroundColor: Colors.red),
        );
      }
      return; // On arrête tout si la galerie ne s'ouvre pas
    }

    // Si l'utilisateur annule, on ne fait rien
    if (image == null) {
      developer.log("2. Action annulée. Aucune image sélectionnée.", name: "ProfileUpload");
      return;
    }

    developer.log("3. Image sélectionnée : ${image.path}", name: "ProfileUpload");

    // On affiche l'indicateur de chargement
    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    }

    // Étape 2 : Préparer la requête d'envoi vers le serveur
    // !!! VÉRIFIEZ BIEN CETTE ADRESSE IP !!!
    const String ipAddress = "10.0.2.2";
    var uri = Uri.parse('http://$ipAddress/medipass/api/upload_profile_picture.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = widget.userEmail;
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo', // 'photo' doit correspondre au nom du champ attendu par votre API PHP ($_FILES['photo'])
        image.path,
      ),
    );

    developer.log("4. Envoi de la requête au serveur...", name: "ProfileUpload");

    // Étape 3 : Envoyer la requête et gérer la réponse
    try {
      var response = await request.send();

      developer.log("5. Réponse du serveur reçue avec le code: ${response.statusCode}", name: "ProfileUpload");

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour !'), backgroundColor: Colors.green),
          );
          // On renvoie 'true' à la page précédente pour signaler le succès
          Navigator.pop(context, true);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        developer.log("ERREUR SERVEUR (${response.statusCode}): $responseBody", name: "ProfileUpload");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur du serveur: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      developer.log("ERREUR RÉSEAU: $e", name: "ProfileUpload", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur réseau. Impossible de contacter le serveur.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Dans tous les cas, on arrête l'indicateur de chargement
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On applique le thème reçu pour que la page respecte le mode clair/sombre
    return Theme(
      data: widget.currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Profil'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Changer ma photo de profil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Si l'envoi est en cours, on affiche un cercle de chargement
                if (_isUploading)
                  CircularProgressIndicator(color: widget.currentTheme.primaryColor)
                // Sinon, on affiche le bouton pour choisir une image
                else
                  IconButton(
                    iconSize: 60,
                    // J'ai changé l'icône pour être plus explicite (photo_library)
                    icon: Icon(Icons.photo_library, color: widget.currentTheme.primaryColor),
                    onPressed: _pickAndUploadImage,
                  ),
                const SizedBox(height: 10),
                const Text(
                  'Appuyez sur l\'icône pour choisir une image',
                ),
                const SizedBox(height: 50),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Email du compte :',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.userEmail,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
