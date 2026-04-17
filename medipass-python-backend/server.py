from flask import Flask, request, jsonify
import os
import re
import logging
import traceback

# Tentative d'import dynamique des backends LLM
def has_local_llm():
    try:
        import llama_cpp  # noqa: F401
        return True
    except Exception:
        return False

def generate_with_local_llm(prompt_text, max_tokens=512, temperature=0.2):
    from llama_cpp import Llama
    model_path = os.getenv('LLAMA_MODEL_PATH')
    if not model_path:
        raise RuntimeError('LLAMA_MODEL_PATH non défini')
    llm = Llama(model_path=model_path)
    resp = llm.create(prompt=prompt_text, max_tokens=max_tokens, temperature=temperature)
    # resp structure depends on llama-cpp-python version
    if isinstance(resp, dict):
        # typical shape: {'id':..., 'object':..., 'choices':[{'text': '...'}], ...}
        choices = resp.get('choices') or []
        if choices and 'text' in choices[0]:
            return choices[0]['text']
        return resp.get('text', '')
    # fallback
    return str(resp)



# Crée l'application Flask
app = Flask(__name__)
logging.basicConfig(level=logging.INFO)


def detect_emergency(text):
    # Mots-clés simples déclenchant un refus et orientation vers urgences
    emergency_patterns = [
        r"\b(saignement|perte de connaissance|inconscience|respiratoire|difficulté respiratoire|arrêt cardiaque|douleur thoracique|attaque|accident vasculaire)\b",
        r"\b(urgence|urgence vitale|appel les urgences|appel urgence)\b",
    ]
    lower = text.lower()
    for p in emergency_patterns:
        if re.search(p, lower):
            return True
    return False


# Définit la route qui sera appelée par l'application Flutter
# L'URL sera: http://<votre_ip>:5000/api/medical_chat
@app.route('/api/medical_chat', methods=['POST'])
def medical_chat():
    logging.info('Requête reçue sur /api/medical_chat')

    data = request.get_json()
    if not data or 'prompt' not in data:
        logging.warning("'prompt' manquant dans la requête")
        return jsonify({'error': 'Requête invalide, "prompt" manquant.'}), 400

    user_prompt = data['prompt']
    logging.info(f"Prompt de l'utilisateur: {user_prompt}")

    # Détection rapide d'urgences
    if detect_emergency(user_prompt):
        resp = (
            "Si vous êtes en danger immédiat ou présentez des signes vitaux altérés, appelez immédiatement les services d'urgence locaux. "
            "Je ne peux pas aider pour les urgences."
        )
        return jsonify({'response': resp, 'model': None}), 200

    # Construire un prompt système orienté sécurité et limitation médicale
    system_prefix = (
        "Vous êtes un assistant médical d'aide au tri et d'information. "
        "Fournissez des informations générales, des conseils pour décider de consulter, et des sources quand c'est possible. "
        "Ne fournissez pas de diagnostic définitif. Rappelez toujours que vous n'êtes pas un médecin et recommandez une consultation en cas de doute."
    )

    full_prompt = system_prefix + "\nPatient: " + user_prompt + "\nAssistant:"

    # Vérifier que le backend local est disponible et configuré
    if not (has_local_llm() and os.getenv('LLAMA_MODEL_PATH')):
        logging.error('Aucun backend LLM local configuré: LLAMA_MODEL_PATH requis')
        return jsonify({'error': 'Aucun backend LLM local configuré. Configurez LLAMA_MODEL_PATH vers un modèle local (ggml/gguf).'}), 503

    # Choisir backend local Llama
    model_used = 'local-llama'
    try:
        logging.info('Utilisation du modèle local (llama)')
        model_text = generate_with_local_llm(full_prompt)

        # Post-traitement: sécurité et disclaimer
        def safe_response_check(generated_text, user_text):
            """
            Vérifie le texte généré pour des instructions à risque (prescriptions, posologies, diagnostics catégoriques).
            Si on détecte du contenu à risque, retourne une réponse sûre et non-actionnable.
            """
            txt = generated_text.lower()

            # Patterns dangereux/à filtrer
            prescription_words = [r"prescr", r"ordonn", r"prendre", r"administrer", r"dose", r"posologie"]
            dosage_pattern = r"\b\d+\s?(mg|g|ml|mcg|μg)\b"
            diagnostic_patterns = [r"vous avez un", r"vous avez une", r"c'est (?:un|une)", r"diagnostic"]

            # Si on trouve un motif de dosage -> redaction
            if re.search(dosage_pattern, txt):
                return (False, (
                    "Je ne peux pas fournir de posologie ou d'ordonnance. "
                    "Consultez un professionnel de santé pour un dosage et une prescription adaptés."
                ))

            # Prescription explicite
            for p in prescription_words:
                if re.search(r"\b" + p + r"\b", txt):
                    return (False, (
                        "Je ne peux pas fournir d'ordonnance ni recommander de médicaments spécifiques. "
                        "Veuillez consulter un professionnel de santé."
                    ))

            # Diagnostic catégorique
            for p in diagnostic_patterns:
                if re.search(p, txt):
                    return (False, (
                        "Je ne peux pas établir de diagnostic définitif. "
                        "Si vous avez des inquiétudes, consultez un professionnel de santé pour un examen."
                    ))

            # Pas de contenu dangereux détecté
            return (True, generated_text)

        disclaimer = (
            "\n\nRemarque: Ceci est une information générale et ne remplace pas une consultation médicale. "
            "Consultez un professionnel de santé pour un avis médical personnalisé."
        )


        # Si la génération n'a pas produit de texte (très improbable pour un backend local),
        # on renvoie une erreur interne plutôt qu'un fallback automatique.
        if model_text is None:
            logging.error('La génération locale a renvoyé None')
            return jsonify({'error': 'Erreur interne: le modèle local a renvoyé une réponse invalide.'}), 500
        

        ok, checked = safe_response_check(model_text.strip(), user_prompt)
        if not ok:
            final_response = checked + disclaimer
        else:
            final_response = model_text.strip() + disclaimer

        logging.info('Réponse générée avec succès (sécurité appliquée: %s)', ok)
        return jsonify({'response': final_response, 'model': model_used, 'safe': ok}), 200

    except Exception:
        logging.exception('Erreur lors de la génération IA')
        return jsonify({'error': 'Erreur serveur lors de la génération de la réponse IA.'}), 500

    # (ancien fallback déplacé plus haut) -- fin de la route


# Point d'entrée pour lancer le serveur
if __name__ == '__main__':
    # host='0.0.0.0' est crucial pour que le serveur soit accessible
    # depuis votre réseau local (et donc par l'émulateur Android).
    print("Démarrage du serveur Flask pour Medipass...")
    app.run(host='0.0.0.0', port=5000)