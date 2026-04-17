<template>
  <div class="auth-container">
    <div class="background-elements">
      <div class="geo-shape shape-1"></div>
      <div class="geo-shape shape-2"></div>
      <div class="geo-shape shape-3"></div>
    </div>

    <div class="auth-card">
      <div class="header">
        <h1 class="title">MediPass <span class="highlight">Dashboard</span></h1>
        <p class="subtitle">Portail réservé aux docteurs</p>
      </div>

      <!-- Tabs -->
      <div class="tabs">
        <button :class="{ active: isLogin }" @click="isLogin = true">Connexion</button>
        <button :class="{ active: !isLogin }" @click="isLogin = false">Inscription</button>
      </div>

      <Transition name="fade" mode="out-in">
        <!-- Login Form -->
        <form v-if="isLogin" @submit.prevent="handleLogin" class="form" key="login">
          <div class="input-group">
            <label>Email</label>
            <input v-model="form.email" type="email" placeholder="docteur@medipass.com" required />
          </div>
          <div class="input-group">
            <label>Mot de passe</label>
            <input v-model="form.password" type="password" placeholder="••••••••" required />
          </div>
          <button type="submit" class="btn-submit" :disabled="loading">
            {{ loading ? 'Connexion...' : 'Se connecter' }}
          </button>
        </form>

        <!-- Register Form -->
        <form v-else @submit.prevent="handleRegister" class="form" key="register">
        <div class="input-group">
          <label>Nom complet</label>
          <input v-model="form.name" type="text" placeholder="Dr. Dupont" required />
        </div>
        <div class="input-group">
          <label>Spécialité</label>
          <input v-model="form.specialty" type="text" placeholder="Cardiologue" />
        </div>
        <div class="input-group">
          <label>Numéro Mobile</label>
          <input v-model="form.mobile" type="tel" placeholder="06 12 34 56 78" required />
        </div>
        <div class="input-group">
          <label>Email</label>
          <input v-model="form.email" type="email" placeholder="docteur@medipass.com" required />
        </div>
        <div class="input-group">
          <label>Mot de passe</label>
          <input v-model="form.password" type="password" placeholder="••••••••" required />
        </div>

        <!-- Verification Section -->
        <div class="verification-section">
          <div class="input-group">
            <label>Numéro RPPS / Diplôme</label>
            <input v-model="form.diplomaNumber" type="text" placeholder="1000xxxxxxx" required />
          </div>
          <div class="checkbox-group">
            <input v-model="form.consent" type="checkbox" id="consent" required />
            <label for="consent">J'autorise la vérification auprès du ministère.</label>
          </div>
        </div>

        <button type="submit" class="btn-submit" :disabled="loading">
          {{ loading ? 'Inscription...' : "S'inscrire" }}
        </button>
      </form>
      </Transition>

      <p v-if="message" :class="['message', messageType]">{{ message }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'

const isLogin = ref(true)
const loading = ref(false)
const message = ref('')
const messageType = ref('info')

// Utilisation d'un cookie pour stocker l'utilisateur connecté
const userCookie = useCookie('user')

const form = reactive({
  name: '',
  email: '',
  password: '',
  specialty: '',
  diplomaNumber: '',
  consent: false,
  mobile: ''
})

const validateEmail = (email) => {
  const re = /^[^\s@]+@gmail\.com$/
  return re.test(email)
}

const handleLogin = async () => {
  loading.value = true
  message.value = ''

  if (!validateEmail(form.email)) {
    messageType.value = 'error'
    message.value = 'Veuillez entrer une adresse Gmail valide.'
    loading.value = false
    return
  }

  try {
    const res = await $fetch('/api/auth/login', {
      method: 'POST',
      body: { email: form.email, password: form.password }
    })
    messageType.value = 'success'
    message.value = `Bienvenue Dr. ${res.user.name} !`
    
    // Sauvegarde de l'utilisateur et redirection
    userCookie.value = res.user
    setTimeout(() => {
      navigateTo('/')
    }, 1000)
    
  } catch (err) {
    messageType.value = 'error'
    message.value = err.data?.statusMessage || 'Erreur de connexion'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  loading.value = true
  message.value = ''

  if (!validateEmail(form.email)) {
    messageType.value = 'error'
    message.value = 'Veuillez entrer une adresse Gmail valide.'
    loading.value = false
    return
  }

  try {
    await $fetch('/api/auth/register', {
      method: 'POST',
      body: { ...form }
    })
    messageType.value = 'success'
    message.value = 'Compte créé ! Veuillez vous connecter.'
    isLogin.value = true // Switch to login
    form.password = '' // Clear password
  } catch (err) {
    messageType.value = 'error'
    message.value = err.data?.statusMessage || "Erreur lors de l'inscription"
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Theme Nuxt Colors: Dark #020420, Green #00DC82, White #fff */
.auth-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* Geometric Background Animation */
.background-elements {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
}

.geo-shape {
  position: absolute;
  opacity: 0.1;
  animation: float 10s infinite ease-in-out alternate;
}

/* Triangle */
.shape-1 {
  top: 10%;
  left: 5%;
  width: 300px;
  height: 300px;
  background: #3B82F6;
  clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
}

/* Hexagon */
.shape-2 {
  bottom: 10%;
  right: 5%;
  width: 350px;
  height: 350px;
  background: #60A5FA;
  clip-path: polygon(25% 0%, 75% 0%, 100% 50%, 75% 100%, 25% 100%, 0% 50%);
  animation-delay: -5s;
}

/* Diamond */
.shape-3 {
  top: 20%;
  right: 20%;
  width: 150px;
  height: 150px;
  background: #3B82F6;
  clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
  animation-duration: 15s;
}

@keyframes float {
  0% { transform: translate(0, 0) rotate(0deg); }
  100% { transform: translate(50px, 50px) rotate(90deg); }
}

/* Card Style */
.auth-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  padding: 2rem;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 400px;
  z-index: 1;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}

.title { font-size: 1.8rem; font-weight: bold; margin-bottom: 0.5rem; text-align: center; }
.highlight { color: #3B82F6; }
.subtitle { text-align: center; color: #888; margin-bottom: 2rem; font-size: 0.9rem; }

.tabs { display: flex; margin-bottom: 1.5rem; border-bottom: 1px solid rgba(255,255,255,0.1); }
.tabs button {
  flex: 1;
  background: none;
  border: none;
  color: #888;
  padding: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: color 0.3s;
}
.tabs button.active { color: #3B82F6; border-bottom: 2px solid #3B82F6; }

.input-group { margin-bottom: 1rem; }
.input-group label { display: block; margin-bottom: 0.5rem; font-size: 0.9rem; color: #ccc; }
.input-group input {
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,0.2);
  background: rgba(0,0,0,0.2);
  color: white;
  outline: none;
  transition: border-color 0.3s;
}
.input-group input:focus { border-color: #3B82F6; }

.btn-submit {
  width: 100%;
  padding: 12px;
  background: #3B82F6;
  color: #020420;
  border: none;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  transition: transform 0.2s, background 0.2s;
}
.btn-submit:hover { background: #2563EB; transform: translateY(-2px); }
.btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }

.message { margin-top: 1rem; text-align: center; font-size: 0.9rem; padding: 10px; border-radius: 6px; }
.message.error { background: rgba(255, 0, 0, 0.1); color: #ff6b6b; }
.message.success { background: rgba(59, 130, 246, 0.1); color: #3B82F6; }

/* Verification Section */
.verification-section {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}
.checkbox-group { display: flex; align-items: center; gap: 10px; margin-bottom: 1rem; font-size: 0.85rem; color: #ccc; }
.checkbox-group input { width: auto; accent-color: #3B82F6; }

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>