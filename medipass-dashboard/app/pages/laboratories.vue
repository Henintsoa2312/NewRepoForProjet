<template>
  <div class="dashboard-container" :class="colorMode">
    <!-- Sidebar (Identique à l'accueil) -->
    <aside class="sidebar">
      <div class="logo">MediPass</div>
      <nav>
        <ul>
          <li><NuxtLink to="/" class="nav-link">Tableau de bord</NuxtLink></li>
          <li><NuxtLink to="/doctors" class="nav-link">Docteurs</NuxtLink></li>
          <li><NuxtLink to="/patients" class="nav-link">Patients</NuxtLink></li>
          <li class="active"><NuxtLink to="/laboratories" class="nav-link">Laboratoires</NuxtLink></li>
          <li><NuxtLink to="/settings" class="nav-link">Paramètres</NuxtLink></li>
        </ul>
      </nav>
      <div class="logout">
        <button @click="logout">Déconnexion</button>
      </div>
    </aside>

    <main class="main-content">
      <header class="top-bar">
        <h2>Laboratoires Partenaires</h2>
        <div class="user-info">
          <span class="badge">{{ user?.specialty || 'Généraliste' }}</span>
        </div>
      </header>

      <div class="labs-container">
        <div v-for="(labs, city) in groupedLabs" :key="city" class="city-group">
          <h3 class="city-title">{{ city }}</h3>
          <div class="labs-grid">
            <div v-for="lab in labs" :key="lab.id" class="lab-card">
              <h4>{{ lab.name }}</h4>
              <p class="address">{{ lab.address }}</p>
              <p v-if="lab.contact" class="contact">📞 {{ lab.contact }}</p>
              <button class="btn-request">Demander analyse</button>
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
if (!user.value) navigateTo('/login')

const { data: laboratories } = await useFetch('/api/laboratories')

const groupedLabs = computed(() => {
  if (!laboratories.value) return {}
  return laboratories.value.reduce((acc, lab) => {
    const city = lab.city || 'Autres'
    if (!acc[city]) acc[city] = []
    acc[city].push(lab)
    return acc
  }, {})
})

const logout = () => {
  user.value = null
  navigateTo('/login')
}
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

/* Labs Specific Styles */
.city-group { margin-bottom: 2rem; }
.city-title { color: #3B82F6; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 0.5rem; margin-bottom: 1rem; }
.labs-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; }
.lab-card { background: rgba(255, 255, 255, 0.05); padding: 1.5rem; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); transition: transform 0.2s; }
.lab-card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.08); }
.lab-card h4 { margin: 0 0 0.5rem 0; color: white; }
.address { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.contact { color: #3B82F6; font-size: 0.9rem; margin-bottom: 1rem; }
.btn-request { width: 100%; padding: 8px; background: rgba(59, 130, 246, 0.2); color: #3B82F6; border: 1px solid #3B82F6; border-radius: 6px; cursor: pointer; transition: all 0.3s; }
.btn-request:hover { background: #3B82F6; color: #020420; }

/* Light Mode Styles */
.dashboard-container.light { background-color: #F1F5F9; color: #0F172A; }
.dashboard-container.light .sidebar { background: white; border-right-color: #E2E8F0; }
.dashboard-container.light .nav-link { color: #64748B; }
.dashboard-container.light .sidebar nav li:hover, 
.dashboard-container.light .sidebar nav li.active { background: #EFF6FF; }
.dashboard-container.light .logout button { color: #64748B; border-color: #CBD5E1; }
.dashboard-container.light .logout button:hover { border-color: #EF4444; color: #EF4444; background: #FEF2F2; }
.dashboard-container.light .main-content { color: #0F172A; }
.dashboard-container.light .lab-card { background: white; border-color: #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }
.dashboard-container.light .lab-card:hover { background: #F8FAFC; }
.dashboard-container.light .address { color: #475569; }
.dashboard-container.light .city-title { border-bottom-color: #E2E8F0; }
</style>