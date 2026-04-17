<template>
  <div class="dashboard-container" :class="colorMode">
    <aside class="sidebar">
      <div class="logo">MediPass</div>
      <nav>
        <ul>
          <li><NuxtLink to="/" class="nav-link">Tableau de bord</NuxtLink></li>
          <li><NuxtLink to="/doctors" class="nav-link">Docteurs</NuxtLink></li>
          <li><NuxtLink to="/patients" class="nav-link">Patients</NuxtLink></li>
          <li><NuxtLink to="/laboratories" class="nav-link">Laboratoires</NuxtLink></li>
          <li class="active"><NuxtLink to="/settings" class="nav-link">Paramètres</NuxtLink></li>
        </ul>
      </nav>
      <div class="logout"><button @click="logout">Déconnexion</button></div>
    </aside>

    <main class="main-content">
      <header class="top-bar">
        <h2>Paramètres</h2>
        <div class="user-info"><span class="badge">{{ user?.specialty || 'Généraliste' }}</span></div>
      </header>
      
      <div class="settings-content">
        <div class="card">
          <h3>Mon Profil</h3>
          <p>Nom: {{ user?.name }}</p>
          <p>Email: {{ user?.email }}</p>
          <p>Spécialité: {{ user?.specialty }}</p>
        </div>

        <div class="card">
          <h3>Apparence</h3>
          <div class="theme-toggle">
            <p>Thème actuel : <strong>{{ colorMode === 'dark' ? 'Sombre' : 'Clair' }}</strong></p>
            <button @click="toggleTheme" class="btn-toggle">
              {{ colorMode === 'dark' ? '☀️ Passer en mode Clair' : '🌙 Passer en mode Sombre' }}
            </button>
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
const logout = () => { user.value = null; navigateTo('/login') }

const toggleTheme = () => {
  colorMode.value = colorMode.value === 'dark' ? 'light' : 'dark'
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
.card { background: rgba(255, 255, 255, 0.05); padding: 1.5rem; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); }
.card h3 { margin-top: 0; color: #3B82F6; }
.card p { color: #ccc; }

.settings-content { display: flex; flex-direction: column; gap: 1.5rem; }
.btn-toggle { padding: 10px 20px; background: rgba(59, 130, 246, 0.1); color: #3B82F6; border: 1px solid #3B82F6; border-radius: 8px; cursor: pointer; font-weight: bold; transition: all 0.3s; margin-top: 0.5rem; }
.btn-toggle:hover { background: #3B82F6; color: white; }

/* Light Mode Styles */
.dashboard-container.light { background-color: #F1F5F9; color: #0F172A; }
.dashboard-container.light .sidebar { background: white; border-right-color: #E2E8F0; }
.dashboard-container.light .card { background: white; border-color: #E2E8F0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.dashboard-container.light .card p { color: #475569; }
.dashboard-container.light .nav-link { color: #64748B; }
.dashboard-container.light .sidebar nav li:hover, 
.dashboard-container.light .sidebar nav li.active { background: #EFF6FF; }
.dashboard-container.light .logout button { color: #64748B; border-color: #CBD5E1; }
.dashboard-container.light .logout button:hover { border-color: #EF4444; color: #EF4444; background: #FEF2F2; }
</style>