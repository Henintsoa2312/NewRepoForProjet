<template>
  <div class="dashboard-container" :class="colorMode">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="logo">MediPass</div>
      <nav>
        <ul>
          <li class="active"><NuxtLink to="/" class="nav-link">Tableau de bord</NuxtLink></li>
          <li><NuxtLink to="/doctors" class="nav-link">Docteurs</NuxtLink></li>
          <li><NuxtLink to="/patients" class="nav-link">Patients</NuxtLink></li>
          <li><NuxtLink to="/laboratories" class="nav-link">Laboratoires</NuxtLink></li>
          <li><NuxtLink to="/settings" class="nav-link">Paramètres</NuxtLink></li>
        </ul>
      </nav>
      <div class="logout">
        <button @click="logout">Déconnexion</button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <header class="top-bar">
        <h2>Bienvenue, Dr. {{ user?.name || 'Utilisateur' }}</h2>
        <div class="user-info">
          <span class="badge">{{ user?.specialty || 'Généraliste' }}</span>
        </div>
      </header>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Patients</h3>
          <p class="stat-number">{{ patients?.length || 0 }}</p>
        </div>
        <div class="stat-card">
          <h3>Rendez-vous</h3>
          <p class="stat-number">{{ appointmentsList?.length || 0 }}</p>
        </div>
        <div class="stat-card">
          <h3>Prescriptions</h3>
          <p class="stat-number">{{ prescriptions?.length || 0 }}</p>
        </div>
        <div class="stat-card">
          <h3>Analyses</h3>
          <p class="stat-number">{{ analyses?.length || 0 }}</p>
        </div>
        <div class="stat-card">
          <h3>Messages</h3>
          <p class="stat-number">{{ messages?.length || 0 }}</p>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="quick-actions">
        <button class="action-btn">
          <span class="icon">+</span> Nouveau Patient
        </button>
        <button class="action-btn">
          <span class="icon">📅</span> Planifier RDV
        </button>
        <button class="action-btn">
          <span class="icon">✉️</span> Message
        </button>
      </div>

      <div class="content-grid">
        <!-- Doctors Table -->
        <div class="recent-section">
          <h3>Liste des Docteurs Inscrits</h3>
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th>Nom</th>
                  <th>Spécialité</th>
                  <th>Email</th>
                  <th>Mobile</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="doc in doctors" :key="doc.id">
                  <td>{{ doc.name }}</td>
                  <td>{{ doc.specialty }}</td>
                  <td>{{ doc.email }}</td>
                  <td>{{ doc.phone || 'Non renseigné' }}</td>
                  <td>
                    <span :class="['status', doc.status === 'verified' ? 'verified' : 'pending']">
                      {{ doc.status === 'verified' ? 'Vérifié' : 'En attente' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Upcoming Appointments -->
        <div class="appointments-section">
          <h3>Rendez-vous à venir</h3>
          <div class="card-list">
            <div v-if="!appointments.length" class="appointment-card empty-card">
              <div class="apt-details">
                <h4>Aucun rendez-vous</h4>
                <p>Les prochains rendez-vous s'afficheront ici.</p>
              </div>
            </div>
            <div class="appointment-card" v-for="apt in appointments" :key="apt.id">
              <div class="apt-time">
                <span class="time">{{ apt.time }}</span>
                <span class="date">{{ apt.date }}</span>
              </div>
              <div class="apt-details">
                <h4>{{ apt.patient }}</h4>
                <p>{{ apt.type }}</p>
              </div>
              <div class="apt-status" :class="apt.status">
                {{ apt.statusLabel }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
const user = useCookie('user')
const colorMode = useCookie('color-mode', { default: () => 'dark' })

// Protection simple : si pas d'utilisateur, retour au login
if (!user.value) {
  navigateTo('/login')
}

// Récupération des docteurs depuis l'API
const { data: doctors } = await useFetch('/api/doctors')
const { data: patients } = await useFetch('/api/patients')
const { data: appointmentsList } = await useFetch('/api/appointments')
const { data: prescriptions } = await useFetch('/api/prescriptions')
const { data: analyses } = await useFetch('/api/analysis')
const { data: messages } = await useFetch('/api/messages')

const appointments = computed(() => {
  return (appointmentsList.value || [])
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .map(apt => ({
    id: apt.id,
    time: new Date(apt.date).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    date: new Date(apt.date).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }),
    patient: apt.patient?.name || apt.patient_name || 'Patient',
    type: apt.type || 'Consultation',
    status: apt.status || 'pending',
    statusLabel: apt.status === 'confirmed' ? 'Confirmé' : (apt.status === 'cancelled' ? 'Annulé' : 'En attente')
  }))
})

const logout = () => {
  user.value = null
  navigateTo('/login')
}
</script>

<style scoped>
.dashboard-container { 
  display: flex;
  min-height: 100vh;
  background-color: #0F172A;
  color: white;
}

/* Sidebar */
.sidebar {
  width: 250px;
  background: rgba(255, 255, 255, 0.03);
  border-right: 1px solid rgba(255, 255, 255, 0.1);
  padding: 2rem;
  display: flex;
  flex-direction: column;
}
.logo { font-size: 1.5rem; font-weight: bold; color: #3B82F6; margin-bottom: 3rem; }
.sidebar nav ul { list-style: none; padding: 0; }
.sidebar nav li { margin-bottom: 10px; border-radius: 8px; transition: background 0.3s; }
.sidebar nav li:hover, .sidebar nav li.active { background: rgba(59, 130, 246, 0.1); color: #3B82F6; }
.nav-link { text-decoration: none; color: #aaa; display: block; padding: 10px 15px; width: 100%; height: 100%; }
.sidebar nav li.active .nav-link { color: #3B82F6; }
.logout { margin-top: auto; }
.logout button { width: 100%; padding: 10px; background: none; border: 1px solid rgba(255,255,255,0.2); color: white; border-radius: 6px; cursor: pointer; }
.logout button:hover { background: rgba(255, 0, 0, 0.1); border-color: #ff6b6b; color: #ff6b6b; }

/* Main Content */
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
.badge { background: #3B82F6; color: #020420; padding: 5px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; }

/* Stats Grid */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
.stat-card { background: rgba(255, 255, 255, 0.05); padding: 1.5rem; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); }
.stat-card h3 { font-size: 0.9rem; color: #888; margin-bottom: 0.5rem; }
.stat-number { font-size: 2rem; font-weight: bold; color: white; }

/* Table */
.recent-section h3 { margin-bottom: 1rem; }
.table-container { background: rgba(255, 255, 255, 0.05); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255, 255, 255, 0.1); }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 15px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.05); }
th { background: rgba(0, 0, 0, 0.2); color: #888; font-weight: 600; font-size: 0.9rem; }
tr:hover { background: rgba(255, 255, 255, 0.02); }

.status { padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; }
.status.verified { background: rgba(59, 130, 246, 0.2); color: #3B82F6; }
.status.pending { background: rgba(255, 165, 0, 0.2); color: orange; }

/* Quick Actions */
.quick-actions { display: flex; gap: 1rem; margin-bottom: 2rem; }
.action-btn { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.1); color: white; padding: 0.8rem 1.5rem; border-radius: 8px; cursor: pointer; transition: all 0.3s; display: flex; align-items: center; gap: 0.5rem; font-weight: 500; }
.action-btn:hover { background: rgba(59, 130, 246, 0.2); border-color: #3B82F6; color: #3B82F6; transform: translateY(-2px); }

/* Content Grid */
.content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; }
@media (max-width: 1024px) { .content-grid { grid-template-columns: 1fr; } }

/* Appointments */
.appointments-section h3 { margin-bottom: 1rem; color: #ccc; font-size: 1rem; }
.card-list { display: flex; flex-direction: column; gap: 1rem; }
.appointment-card { background: rgba(255, 255, 255, 0.05); padding: 1rem; border-radius: 12px; display: flex; align-items: center; gap: 1rem; border: 1px solid rgba(255, 255, 255, 0.05); transition: background 0.3s; }
.appointment-card:hover { background: rgba(255, 255, 255, 0.08); }
.empty-card { justify-content: center; text-align: center; color: #888; border-style: dashed; }
.apt-time { display: flex; flex-direction: column; align-items: center; min-width: 60px; padding-right: 1rem; border-right: 1px solid rgba(255, 255, 255, 0.1); }
.apt-time .time { font-size: 1.2rem; font-weight: bold; color: #3B82F6; }
.apt-time .date { font-size: 0.8rem; color: #888; }
.apt-details { flex: 1; }
.apt-details h4 { margin: 0 0 0.2rem 0; font-size: 1rem; }
.apt-details p { margin: 0; font-size: 0.85rem; color: #aaa; }
.apt-status { font-size: 0.75rem; padding: 4px 8px; border-radius: 4px; }
.apt-status.confirmed { background: rgba(59, 130, 246, 0.2); color: #3B82F6; }
.apt-status.pending { background: rgba(255, 165, 0, 0.2); color: orange; }
.apt-status.cancelled { background: rgba(255, 0, 0, 0.2); color: #ff6b6b; }

/* Light Mode Styles */
.dashboard-container.light { background-color: #F1F5F9; color: #0F172A; }
.dashboard-container.light .sidebar { background: white; border-right-color: #E2E8F0; }
.dashboard-container.light .nav-link { color: #64748B; }
.dashboard-container.light .sidebar nav li:hover, 
.dashboard-container.light .sidebar nav li.active { background: #EFF6FF; }
.dashboard-container.light .logout button { color: #64748B; border-color: #CBD5E1; }
.dashboard-container.light .logout button:hover { border-color: #EF4444; color: #EF4444; background: #FEF2F2; }
.dashboard-container.light .main-content { color: #0F172A; }
.dashboard-container.light .stat-card,
.dashboard-container.light .table-container,
.dashboard-container.light .appointment-card { background: white; border-color: #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
.dashboard-container.light .stat-card h3 { color: #64748B; }
.dashboard-container.light .stat-number { color: #1E293B; }
.dashboard-container.light th { background: #F8FAFC; color: #64748B; }
.dashboard-container.light tr:hover { background: #F8FAFC; }
.dashboard-container.light td { border-bottom-color: #F1F5F9; }
.dashboard-container.light .action-btn { background: #F8FAFC; border-color: #E2E8F0; color: #334155; }
.dashboard-container.light .action-btn:hover { background: #EFF6FF; border-color: #3B82F6; color: #3B82F6; }
.dashboard-container.light .apt-details p { color: #475569; }
.dashboard-container.light .appointments-section h3 { color: #475569; }
.dashboard-container.light .empty-card { background: #F8FAFC; }
</style>