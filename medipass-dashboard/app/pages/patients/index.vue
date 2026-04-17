<template>
  <div class="dashboard-container" :class="colorMode">
    <aside class="sidebar">
      <div class="logo">MediPass</div>
      <nav>
        <ul>
          <li><NuxtLink to="/" class="nav-link">Tableau de bord</NuxtLink></li>
          <li><NuxtLink to="/doctors" class="nav-link">Docteurs</NuxtLink></li>
          <li class="active"><NuxtLink to="/patients" class="nav-link">Patients</NuxtLink></li>
          <li><NuxtLink to="/laboratories" class="nav-link">Laboratoires</NuxtLink></li>
          <li><NuxtLink to="/settings" class="nav-link">Paramètres</NuxtLink></li>
        </ul>
      </nav>
      <div class="logout"><button @click="logout">Déconnexion</button></div>
    </aside>

    <main class="main-content">
      <header class="top-bar">
        <h2>Mes Patients</h2>
        <div class="user-info"><span class="badge">{{ user?.specialty || 'Généraliste' }}</span></div>
      </header>
      
      <!-- Add Patient Form -->
      <div class="add-patient-form">
        <h3>Ajouter un nouveau patient</h3>
        <form @submit.prevent="linkPatient">
          <p>Entrez le code unique à 8 caractères (ex: N3QR-XLJ3) fourni par votre patient.</p>
          <div class="input-row">
            <input v-model.trim="patientCode" type="text" placeholder="N3QR-XLJ3" required />
            <button type="submit" class="action-btn" :disabled="loading">
              {{ loading ? 'Ajout...' : 'Lier le patient' }}
            </button>
          </div>
        </form>
        <p v-if="message" :class="['message', messageType]">{{ message }}</p>
      </div>

      <!-- Patient List -->
      <div class="patient-list-section">
        <h3>Liste de vos patients</h3>
        <div v-if="pending" class="loading-state">Chargement de la liste...</div>
        <div v-else-if="error" class="error-state">Erreur de chargement des patients.</div>
        <div v-else-if="patients && patients.length > 0" class="table-container">
          <table>
            <thead>
              <tr>
                <th>Patient</th>
                <th>Email</th>
                <th>Téléphone</th>
                <th>Inscrit le</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="patient in patients" :key="patient.id" @click="navigateTo(`/patients/${patient.id}`)" class="clickable-row">
                <td class="patient-info">
                  <img 
                    :src="patient.photo_url || `https://ui-avatars.com/api/?name=${patient.name}&background=random`" 
                    @error="handleImageError($event, patient.name)"
                    :title="patient.photo_url || 'Pas de photo définie'"
                    alt="" class="avatar" 
                  />
                  <span>{{ patient.name }}</span>
                </td>
                <td>{{ patient.email }}</td>
                <td>{{ patient.phone }}</td>
                <td>{{ new Date(patient.created_at).toLocaleDateString() }}</td>
                <td>
                  <button class="btn-manage">Gérer</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
const user = useCookie('user')
const colorMode = useCookie('color-mode', { default: () => 'dark' })
if (!user.value) navigateTo('/login')

const patientCode = ref('')
const loading = ref(false)
const message = ref('')
const messageType = ref('info')

// Récupère la liste des patients liés à ce médecin
const { data: patients, pending, error, refresh } = await useFetch('/api/patients')

const linkPatient = async () => {
  loading.value = true
  message.value = ''
  
  const codeRegex = /^[A-Z0-9]{4}-[A-Z0-9]{4}$/i;
  if (!codeRegex.test(patientCode.value)) {
    messageType.value = 'error'
    message.value = 'Format du code invalide. Le format doit être XXXX-XXXX.'
    loading.value = false
    return
  }

  try {
    const res = await $fetch('/api/patients/link', {
      method: 'POST',
      body: { patientCode: patientCode.value.toUpperCase() }
    })
    messageType.value = 'success'
    message.value = `${res.message} (Patient : ${res.patient.name})`
    patientCode.value = '' // Vide le champ
    await refresh() // Rafraîchit la liste des patients
  } catch (err) {
    messageType.value = 'error'
    message.value = err.data?.statusMessage || 'Une erreur est survenue.'
  } finally {
    loading.value = false
  }
}

const handleImageError = (e, name) => {
  e.target.onerror = null
  e.target.src = `https://ui-avatars.com/api/?name=${name}&background=random`
  console.warn(`Impossible de charger l'image pour ${name}`)
}

const logout = () => { user.value = null; navigateTo('/login') }
</script>

<style scoped>
/* Styles identiques à index.vue pour la cohérence */
.dashboard-container { display: flex; min-height: 100vh; background-color: #0F172A; color: white; }
.sidebar { width: 250px; background: rgba(255, 255, 255, 0.03); border-right: 1px solid rgba(255, 255, 255, 0.1); padding: 2rem; display: flex; flex-direction: column; }
.logo { font-size: 1.5rem; font-weight: bold; color: #3B82F6; margin-bottom: 3rem; }
.sidebar nav ul { list-style: none; padding: 0; }
.sidebar nav li { margin-bottom: 10px; border-radius: 8px; transition: background 0.3s; }
.sidebar nav li:hover, .sidebar nav li.active { background: rgba(59, 130, 246, 0.1); }
.nav-link { text-decoration: none; color: #aaa; display: block; padding: 10px 15px; width: 100%; height: 100%; }
.sidebar nav li.active .nav-link { color: #3B82F6; }
.logout { margin-top: auto; }
.logout button { width: 100%; padding: 10px; background: none; border: 1px solid rgba(255,255,255,0.2); color: white; border-radius: 6px; cursor: pointer; }
.logout button:hover { background: rgba(255, 0, 0, 0.1); border-color: #ff6b6b; color: #ff6b6b; }
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
.badge { background: #3B82F6; color: #020420; padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; }

/* Form Styles */
.add-patient-form { background: rgba(255, 255, 255, 0.05); padding: 1.5rem; border-radius: 12px; margin-bottom: 2rem; border: 1px solid rgba(255, 255, 255, 0.1); }
.add-patient-form h3 { margin-top: 0; margin-bottom: 0.5rem; }
.add-patient-form p { color: #aaa; font-size: 0.9rem; margin-bottom: 1rem; }
.input-row { display: flex; gap: 1rem; }
.input-row input { flex: 1; padding: 10px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); background: rgba(0,0,0,0.2); color: white; outline: none; font-family: 'Courier New', Courier, monospace; text-transform: uppercase; }
.input-row input:focus { border-color: #3B82F6; }
.action-btn { background: #3B82F6; color: #020420; border: none; padding: 10px 20px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: background 0.3s; }
.action-btn:disabled { opacity: 0.5; cursor: not-allowed; }

/* Patient List Styles */
.patient-list-section { margin-top: 2rem; }
.table-container { background: rgba(255, 255, 255, 0.05); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255, 255, 255, 0.1); }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 15px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
th { background: rgba(0, 0, 0, 0.2); color: #888; font-weight: 600; font-size: 0.9rem; }
tr:hover { background: rgba(255, 255, 255, 0.02); }

.empty-state, .loading-state, .error-state { text-align: center; margin-top: 4rem; color: #888; padding: 2rem; background: rgba(255,255,255,0.05); border-radius: 12px; }
.error-state { color: #ff6b6b; }

.message { margin-top: 1rem; font-size: 0.9rem; padding: 10px; border-radius: 6px; }
.message.error { background: rgba(255, 0, 0, 0.1); color: #ff6b6b; }
.message.success { background: rgba(59, 130, 246, 0.1); color: #3B82F6; }

.patient-info { display: flex; align-items: center; gap: 12px; }
.avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.1); }

.clickable-row { cursor: pointer; transition: background 0.2s; }
.clickable-row:hover { background: rgba(255, 255, 255, 0.08); }

.btn-manage { padding: 6px 12px; background: rgba(59, 130, 246, 0.1); color: #3B82F6; border: 1px solid #3B82F6; border-radius: 6px; cursor: pointer; font-size: 0.8rem; }
.btn-manage:hover { background: #3B82F6; color: #020420; }

/* Light Mode Styles */
.dashboard-container.light { background-color: #F1F5F9; color: #0F172A; }
.dashboard-container.light .sidebar { background: white; border-right-color: #E2E8F0; }
.dashboard-container.light .nav-link { color: #64748B; }
.dashboard-container.light .sidebar nav li:hover, 
.dashboard-container.light .sidebar nav li.active { background: #EFF6FF; }
.dashboard-container.light .logout button { color: #64748B; border-color: #CBD5E1; }
.dashboard-container.light .logout button:hover { border-color: #EF4444; color: #EF4444; background: #FEF2F2; }
.dashboard-container.light .main-content { color: #0F172A; }
.dashboard-container.light .add-patient-form,
.dashboard-container.light .table-container { background: white; border-color: #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
.dashboard-container.light .add-patient-form p { color: #475569; }
.dashboard-container.light .input-row input { background: #F8FAFC; border-color: #E2E8F0; color: #1E293B; }
.dashboard-container.light .input-row input:focus { border-color: #3B82F6; }
.dashboard-container.light th { background: #F8FAFC; color: #64748B; }
.dashboard-container.light tr:hover { background: #F8FAFC; }
.dashboard-container.light td { border-bottom-color: #F1F5F9; }
</style>