<template>
  <div class="dashboard-container" :class="colorMode">
    <aside class="sidebar">
      <div class="logo">MediPass</div>
      <nav>
        <ul>
          <li><NuxtLink to="/" class="nav-link">Tableau de bord</NuxtLink></li>
          <li class="active"><NuxtLink to="/doctors" class="nav-link">Docteurs</NuxtLink></li>
          <li><NuxtLink to="/patients" class="nav-link">Patients</NuxtLink></li>
          <li><NuxtLink to="/laboratories" class="nav-link">Laboratoires</NuxtLink></li>
          <li><NuxtLink to="/settings" class="nav-link">Paramètres</NuxtLink></li>
        </ul>
      </nav>
      <div class="logout"><button @click="logout">Déconnexion</button></div>
    </aside>

    <main class="main-content">
      <header class="top-bar">
        <h2>Annuaire Docteurs</h2>
        <div class="user-info"><span class="badge">{{ user?.specialty || 'Généraliste' }}</span></div>
      </header>

      <!-- Formulaire d'inscription docteur -->
      <div class="add-doctor-section">
        <h3>Inscrire un nouveau docteur</h3>
        <form @submit.prevent="addDoctor" class="add-form">
          <input v-model="newDoctor.name" type="text" placeholder="Nom complet" required />
          <input v-model="newDoctor.specialty" type="text" placeholder="Spécialité" required />
          <input v-model="newDoctor.email" type="email" placeholder="Email" required />
          <input v-model="newDoctor.phone" type="tel" placeholder="Téléphone Fixe" />
          <input v-model="newDoctor.mobile" type="tel" placeholder="Numéro Mobile" required />
          <button type="submit" class="btn-add">Ajouter</button>
        </form>
      </div>

      <div class="search-bar">
        <input v-model="searchQuery" type="text" placeholder="Rechercher un docteur par nom ou spécialité..." />
      </div>

      <div class="doctors-list-section">
        <div v-if="pending" class="loading-state">Chargement de l'annuaire...</div>
        <div v-else-if="error" class="error-state">Erreur de chargement des docteurs.</div>
        <div v-else-if="filteredDoctors && filteredDoctors.length > 0" class="table-container">
          <table>
            <thead>
              <tr>
                <th>Docteur</th>
                <th>Spécialité</th>
                <th>Email</th>
                <th>Mobile</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="doc in filteredDoctors" :key="doc.id">
                <td class="doctor-info">
                  <img :src="doc.photo_url || `https://ui-avatars.com/api/?name=${doc.name}&background=random`" class="avatar" alt="" />
                  <span>Dr. {{ doc.name }}</span>
                </td>
                <td>{{ doc.specialty }}</td>
                <td>{{ doc.email }}</td>
                <td>{{ doc.mobile || doc.phone || 'Non renseigné' }}</td>
                <td>
                  <button class="btn-contact" @click="contactDoctor(doc)" v-if="doc.mobile || doc.phone">
                    {{ doc.mobile || doc.phone }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="empty-state">Aucun docteur trouvé.</div>
      </div>
    </main>
  </div>
</template>

<script setup>
const user = useCookie('user')
if (!user.value) navigateTo('/login')
const colorMode = useCookie('color-mode', { default: () => 'dark' })
const { data: doctors, pending, error } = await useFetch('/api/doctors')

const searchQuery = ref('')

const newDoctor = ref({ name: '', specialty: '', email: '', phone: '', mobile: '' })

const addDoctor = () => {
  // Logique d'ajout (simulée pour l'instant)
  alert(`Docteur ${newDoctor.value.name} ajouté avec succès. Mobile: ${newDoctor.value.mobile}`)
  newDoctor.value = { name: '', specialty: '', email: '', phone: '', mobile: '' }
}

const filteredDoctors = computed(() => {
  if (!doctors.value) return []
  const q = searchQuery.value.toLowerCase()
  return doctors.value.filter(d => 
    d.name.toLowerCase().includes(q) || 
    d.specialty.toLowerCase().includes(q)
  )
})

const contactDoctor = (doc) => {
  alert(`Contact avec Dr. ${doc.name} bientôt disponible.`)
}

const logout = () => { user.value = null; navigateTo('/login') }
</script>

<style scoped>
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
.table-container { background: rgba(255, 255, 255, 0.05); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255, 255, 255, 0.1); }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 15px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
th { background: rgba(0, 0, 0, 0.2); color: #888; font-weight: 600; font-size: 0.9rem; }
tr:hover { background: rgba(255, 255, 255, 0.02); }
.doctor-info { display: flex; align-items: center; gap: 12px; }
.avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.1); }
.empty-state, .loading-state, .error-state { text-align: center; margin-top: 4rem; color: #888; padding: 2rem; background: rgba(255,255,255,0.05); border-radius: 12px; }
.error-state { color: #ff6b6b; }
.search-bar { margin-bottom: 1.5rem; }
.search-bar input { width: 100%; padding: 12px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; outline: none; font-size: 1rem; }
.search-bar input:focus { border-color: #3B82F6; }
.btn-contact { padding: 6px 12px; background: rgba(59, 130, 246, 0.1); color: #3B82F6; border: 1px solid #3B82F6; border-radius: 6px; cursor: pointer; font-size: 0.8rem; transition: background 0.3s; }
.btn-contact:hover { background: #3B82F6; color: #020420; }
.add-doctor-section { background: rgba(255,255,255,0.05); padding: 1.5rem; border-radius: 12px; margin-bottom: 2rem; border: 1px solid rgba(255,255,255,0.1); }
.add-doctor-section h3 { margin-top: 0; margin-bottom: 1rem; color: #3B82F6; font-size: 1.1rem; }
.add-form { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
.add-form input { padding: 10px; background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.1); border-radius: 6px; color: white; outline: none; }
.add-form input:focus { border-color: #3B82F6; }
.btn-add { background: #3B82F6; color: #020420; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; transition: opacity 0.3s; }
.btn-add:hover { opacity: 0.9; }

/* Light Mode Styles */
.dashboard-container.light { background-color: #F1F5F9; color: #0F172A; }
.dashboard-container.light .sidebar { background: white; border-right-color: #E2E8F0; }
.dashboard-container.light .nav-link { color: #64748B; }
.dashboard-container.light .sidebar nav li:hover, 
.dashboard-container.light .sidebar nav li.active { background: #EFF6FF; }
.dashboard-container.light .logout button { color: #64748B; border-color: #CBD5E1; }
.dashboard-container.light .logout button:hover { border-color: #EF4444; color: #EF4444; background: #FEF2F2; }
.dashboard-container.light .main-content { color: #0F172A; }
.dashboard-container.light .add-doctor-section,
.dashboard-container.light .table-container { background: white; border-color: #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
.dashboard-container.light .search-bar input { background: white; border-color: #E2E8F0; color: #1E293B; }
.dashboard-container.light .search-bar input:focus { border-color: #3B82F6; }
.dashboard-container.light .add-form input { background: #F8FAFC; border-color: #E2E8F0; color: #1E293B; }
.dashboard-container.light th { background: #F8FAFC; color: #64748B; }
.dashboard-container.light tr:hover { background: #F8FAFC; }
.dashboard-container.light td { border-bottom-color: #F1F5F9; }
</style>