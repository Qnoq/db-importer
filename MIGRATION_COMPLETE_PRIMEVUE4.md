# 🎨 Migration complète vers PrimeVue 4 - DB Importer

## 📋 Contexte du problème

Le projet DB Importer mélange actuellement TailwindCSS et PrimeVue, causant :
- Dark mode cassé (mélange de couleurs light/dark)
- Classes Tailwind hardcodées qui ne respectent pas le thème
- Impossible de changer les couleurs facilement
- Incohérence visuelle sur toute l'application

**Objectif** : Migrer vers 100% PrimeVue 4 avec un thème personnalisé modifiable à un seul endroit.

## 🚀 Instructions pour la migration

### Étape 1 : Créer le thème personnalisé

**Créer le fichier `frontend/src/theme/my-preset.ts` :**

```typescript
import { definePreset } from '@primeuix/themes';
import Aura from '@primeuix/themes/aura';

export default definePreset(Aura, {
    semantic: {
        // Couleur primaire - Vert émeraude personnalisé
        primary: {
            50: '{emerald.50}',
            100: '{emerald.100}',
            200: '{emerald.200}',
            300: '{emerald.300}',
            400: '{emerald.400}',
            500: '{emerald.500}',
            600: '{emerald.600}',
            700: '{emerald.700}',
            800: '{emerald.800}',
            900: '{emerald.900}',
            950: '{emerald.950}'
        },
        
        // Configuration des couleurs pour light/dark mode
        colorScheme: {
            light: {
                primary: {
                    color: '{emerald.500}',
                    contrastColor: '#ffffff',
                    hoverColor: '{emerald.600}',
                    activeColor: '{emerald.700}'
                },
                highlight: {
                    background: '{emerald.50}',
                    focusBackground: '{emerald.100}',
                    color: '{emerald.700}',
                    focusColor: '{emerald.800}'
                },
                surface: {
                    0: '#ffffff',
                    50: '{slate.50}',
                    100: '{slate.100}',
                    200: '{slate.200}',
                    300: '{slate.300}',
                    400: '{slate.400}',
                    500: '{slate.500}',
                    600: '{slate.600}',
                    700: '{slate.700}',
                    800: '{slate.800}',
                    900: '{slate.900}',
                    950: '{slate.950}'
                }
            },
            dark: {
                primary: {
                    color: '{emerald.400}',
                    contrastColor: '{surface.900}',
                    hoverColor: '{emerald.300}',
                    activeColor: '{emerald.200}'
                },
                highlight: {
                    background: 'color-mix(in srgb, {emerald.400}, transparent 84%)',
                    focusBackground: 'color-mix(in srgb, {emerald.400}, transparent 76%)',
                    color: 'rgba(255,255,255,.87)',
                    focusColor: 'rgba(255,255,255,.87)'
                },
                surface: {
                    0: '{slate.900}',
                    50: '{slate.950}',
                    100: '{slate.800}',
                    200: '{slate.700}',
                    300: '{slate.600}',
                    400: '{slate.500}',
                    500: '{slate.400}',
                    600: '{slate.300}',
                    700: '{slate.200}',
                    800: '{slate.100}',
                    900: '{slate.50}',
                    950: '#ffffff'
                }
            }
        }
    }
});
```

### Étape 2 : Créer le composable pour gérer le thème

**Créer le fichier `frontend/src/composables/useTheme.ts` :**

```typescript
import { ref, watch } from 'vue'

// État global partagé pour le dark mode
const isDark = ref(false)

/**
 * Composable pour gérer le thème PrimeVue 4
 * Utilise la classe 'p-dark' sur l'élément html
 */
export function useTheme() {
  
  // Initialiser le thème au chargement
  const initTheme = () => {
    // Vérifier localStorage en premier
    const savedTheme = localStorage.getItem('theme')
    
    if (savedTheme) {
      isDark.value = savedTheme === 'dark'
    } else {
      // Sinon utiliser la préférence système
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    
    updateTheme()
  }
  
  // Mettre à jour le DOM avec la classe p-dark
  const updateTheme = () => {
    if (isDark.value) {
      document.documentElement.classList.add('p-dark')
    } else {
      document.documentElement.classList.remove('p-dark')
    }
  }
  
  // Basculer entre light et dark
  const toggleTheme = () => {
    isDark.value = !isDark.value
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
    updateTheme()
  }
  
  // Définir explicitement le thème
  const setTheme = (dark: boolean) => {
    isDark.value = dark
    localStorage.setItem('theme', dark ? 'dark' : 'light')
    updateTheme()
  }
  
  // Watcher pour les changements
  watch(isDark, updateTheme)
  
  // Initialiser au premier appel
  if (typeof window !== 'undefined') {
    initTheme()
  }
  
  return {
    isDark,
    toggleTheme,
    setTheme,
    initTheme
  }
}
```

### Étape 3 : Remplacer le fichier main.ts

**Remplacer le contenu de `frontend/src/main.ts` par :**

```typescript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import MyPreset from './theme/my-preset'
import ToastService from 'primevue/toastservice'
import Tooltip from 'primevue/tooltip'
import router from './router'
import App from './App.vue'

// Import des styles PrimeVue uniquement
import 'primeicons/primeicons.css'

// Initialiser le thème AVANT le montage pour éviter le flash
const initTheme = () => {
  // Vérifier localStorage pour la préférence sauvegardée
  const savedTheme = localStorage.getItem('theme')
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  
  // Appliquer le thème sauvegardé ou la préférence système
  const isDark = savedTheme ? savedTheme === 'dark' : prefersDark
  
  if (isDark) {
    document.documentElement.classList.add('p-dark')
  } else {
    document.documentElement.classList.remove('p-dark')
  }
}

// Initialiser le thème immédiatement
initTheme()

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: MyPreset,
    options: {
      // PrimeVue 4 utilise 'p-dark' par défaut sur l'élément html
      darkModeSelector: '.p-dark',
      // Utiliser CSS layers pour mieux isoler les styles
      cssLayer: {
        name: 'primevue',
        order: 'primevue'
      }
    }
  }
})
app.use(ToastService)
app.directive('tooltip', Tooltip)

app.mount('#app')
```

### Étape 4 : Supprimer l'ancien composable useDarkMode

**Supprimer le fichier `frontend/src/composables/useDarkMode.ts`** (remplacé par useTheme.ts)

### Étape 5 : Créer un nouveau fichier de styles sans Tailwind

**Remplacer le contenu de `frontend/src/style.css` par :**

```css
/* Variables globales personnalisées */
:root {
  --app-header-height: 5rem;
  --app-max-width: 1280px;
  --app-padding: 1rem;
  --app-gap: 1rem;
}

/* Reset de base */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--p-font-family);
  background-color: var(--p-surface-ground);
  color: var(--p-text-color);
  transition: background-color 0.3s, color 0.3s;
}

/* Container principal */
.app-container {
  width: 100%;
  max-width: var(--app-max-width);
  margin: 0 auto;
  padding: 0 var(--app-padding);
}

/* Carte personnalisée utilisant les variables PrimeVue */
.app-card {
  background: var(--p-surface-0);
  border: 1px solid var(--p-surface-border);
  border-radius: var(--p-border-radius);
  padding: var(--p-card-body-padding);
  box-shadow: var(--p-shadow-2);
  transition: all 0.3s;
}

.app-card:hover {
  box-shadow: var(--p-shadow-4);
}

/* Grille responsive */
.app-grid {
  display: grid;
  gap: var(--app-gap);
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

/* Animations globales */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease;
}

.slide-enter-from {
  transform: translateX(-100%);
}

.slide-leave-to {
  transform: translateX(100%);
}
```

### Étape 6 : Supprimer TailwindCSS

**Exécuter les commandes suivantes :**

```bash
# Se positionner dans le dossier frontend
cd frontend

# Désinstaller les packages Tailwind
npm uninstall tailwindcss postcss autoprefixer

# Supprimer le fichier de configuration Tailwind
rm tailwind.config.js
rm postcss.config.js
```

### Étape 7 : Mettre à jour tous les composants Vue

**Pour chaque fichier `.vue` dans `frontend/src/`, remplacer les classes Tailwind par les équivalents PrimeVue :**

#### Mapping des classes principales

| Classe Tailwind | Remplacement PrimeVue |
|----------------|----------------------|
| `bg-white` | `style="background-color: var(--p-surface-0)"` |
| `bg-gray-50` | `style="background-color: var(--p-surface-50)"` |
| `bg-gray-900` | `style="background-color: var(--p-surface-900)"` |
| `text-gray-700` | `style="color: var(--p-text-color)"` |
| `text-gray-500` | `style="color: var(--p-text-muted-color)"` |
| `border-gray-200` | `style="border-color: var(--p-surface-border)"` |
| `bg-green-600`, `bg-neon-green-600` | `style="background-color: var(--p-primary-color)"` |
| `text-green-600`, `text-neon-green-600` | `style="color: var(--p-primary-color)"` |
| `hover:bg-green-700` | `:hover { background-color: var(--p-primary-hover-color) }` |
| `shadow-md` | `style="box-shadow: var(--p-shadow-2)"` |
| `shadow-lg` | `style="box-shadow: var(--p-shadow-4)"` |
| `rounded-lg` | `style="border-radius: var(--p-border-radius)"` |
| `dark:bg-gray-900` | Automatique avec p-dark |
| `dark:text-white` | Automatique avec p-dark |

### Étape 8 : Exemple de composant migré - App.vue

**Voici comment migrer `frontend/src/App.vue` :**

```vue
<template>
  <div class="app-wrapper">
    <Toast />
    
    <!-- Header -->
    <header class="app-header">
      <div class="app-container">
        <div class="app-header-content">
          <!-- Logo et Navigation -->
          <div class="app-header-left">
            <a @click="handleNewImport" class="app-logo">
              <img src="/logo.png" alt="SQL Importer" />
            </a>

            <nav v-if="authStore.isAuthenticated" class="app-nav">
              <Button
                label="New Import"
                icon="pi pi-plus-circle"
                :text="currentRoute !== '/'"
                :severity="currentRoute === '/' ? 'success' : 'secondary'"
                @click="handleNewImport"
                size="small"
              />
              <Button
                label="History"
                icon="pi pi-history"
                :text="currentRoute !== '/history'"
                :severity="currentRoute === '/history' ? 'success' : 'secondary'"
                @click="() => router.push('/history')"
                size="small"
              />
            </nav>
          </div>

          <!-- Actions à droite -->
          <div class="app-header-right">
            <!-- Toggle Thème -->
            <Button
              :icon="isDark ? 'pi pi-sun' : 'pi pi-moon'"
              text
              rounded
              severity="secondary"
              @click="toggleTheme"
              v-tooltip.bottom="isDark ? 'Light Mode' : 'Dark Mode'"
            />

            <!-- Menu utilisateur -->
            <div v-if="authStore.isAuthenticated" class="app-user">
              <Chip>
                <template #icon>
                  <Avatar
                    :label="userInitials"
                    shape="circle"
                    class="app-avatar"
                  />
                </template>
                <span>{{ authStore.userDisplayName }}</span>
              </Chip>
              
              <Button
                icon="pi pi-sign-out"
                text
                rounded
                severity="danger"
                @click="handleLogout"
                v-tooltip.bottom="'Sign Out'"
              />
            </div>

            <!-- Boutons invité -->
            <div v-else class="app-guest">
              <Button
                label="Sign In"
                icon="pi pi-sign-in"
                text
                @click="() => router.push('/login')"
              />
              <Button
                label="Sign Up"
                icon="pi pi-user-plus"
                severity="success"
                @click="() => router.push('/register')"
              />
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Contenu principal -->
    <main class="app-main">
      <div class="app-container">
        <router-view />
      </div>
    </main>

    <!-- Footer -->
    <footer class="app-footer">
      <div class="app-container">
        <div class="app-footer-content">
          <div class="app-footer-links">
            <router-link to="/privacy">Privacy Policy</router-link>
            <span class="app-footer-separator">•</span>
            <router-link to="/legal-notice">Legal Notice</router-link>
          </div>
          <div class="app-footer-version">v{{ appVersion }}</div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from './store/authStore'
import { useMappingStore } from './store/mappingStore'
import { useTheme } from './composables/useTheme'
import { APP_VERSION } from './version'

// Composants PrimeVue
import Button from 'primevue/button'
import Avatar from 'primevue/avatar'
import Chip from 'primevue/chip'
import Toast from 'primevue/toast'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const mappingStore = useMappingStore()
const { isDark, toggleTheme } = useTheme()
const appVersion = APP_VERSION

const currentRoute = computed(() => route.path)

const userInitials = computed(() => {
  if (!authStore.user) return 'G'
  const { firstName, lastName, email } = authStore.user
  if (firstName && lastName) return firstName[0] + lastName[0]
  if (firstName) return firstName[0]
  if (email) return email[0].toUpperCase()
  return 'U'
})

const handleNewImport = () => {
  mappingStore.reset()
  router.push('/')
}

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.app-wrapper {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--p-surface-ground);
}

/* Header */
.app-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--p-surface-0);
  border-bottom: 1px solid var(--p-surface-border);
  box-shadow: var(--p-shadow-2);
}

.app-header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: var(--app-header-height);
  gap: 2rem;
}

.app-header-left {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.app-logo {
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: transform 0.3s;
}

.app-logo:hover {
  transform: scale(1.05);
}

.app-logo img {
  height: 4rem;
  width: auto;
}

.app-nav {
  display: flex;
  gap: 0.5rem;
}

.app-header-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.app-user,
.app-guest {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.app-avatar {
  background-color: var(--p-primary-color);
  color: var(--p-primary-contrast-color);
}

/* Main */
.app-main {
  flex: 1;
  padding: 2rem 0;
}

/* Footer */
.app-footer {
  background: var(--p-surface-0);
  border-top: 1px solid var(--p-surface-border);
  padding: 1.5rem 0;
  margin-top: auto;
}

.app-footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.app-footer-links {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.app-footer-links a {
  color: var(--p-text-muted-color);
  text-decoration: none;
  transition: color 0.3s;
}

.app-footer-links a:hover {
  color: var(--p-primary-color);
}

.app-footer-separator {
  color: var(--p-text-muted-color);
}

.app-footer-version {
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}

/* Responsive */
@media (max-width: 768px) {
  .app-nav {
    display: none;
  }
  
  .app-header-content {
    gap: 1rem;
  }
  
  .app-footer-content {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>
```

### Étape 9 : Script pour identifier les fichiers à migrer

**Créer le fichier `frontend/scripts/find-tailwind-classes.js` :**

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Pattern pour détecter les classes Tailwind
const tailwindPattern = /\b(bg|text|border|shadow|rounded|p|m|flex|font|hover|dark|space|gap|grid|col|row|h|w|min|max|inline|block|hidden|visible|absolute|relative|fixed|sticky|z|opacity|transition|transform|scale|rotate|translate|duration|ease|cursor|select|outline|ring|divide|placeholder|resize|fill|stroke|sr-only)-[\w-]+/g;

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const matches = content.match(tailwindPattern);
  
  if (matches && matches.length > 0) {
    const uniqueClasses = [...new Set(matches)];
    return {
      file: filePath.replace(process.cwd() + '/', ''),
      count: uniqueClasses.length,
      classes: uniqueClasses.slice(0, 10) // Premiers 10 exemples
    };
  }
  return null;
}

function scanDirectory(dir) {
  const results = [];
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory() && !file.includes('node_modules')) {
      results.push(...scanDirectory(fullPath));
    } else if (file.endsWith('.vue') || file.endsWith('.ts') || file.endsWith('.js')) {
      const result = scanFile(fullPath);
      if (result) results.push(result);
    }
  });
  
  return results;
}

// Scanner le projet
console.log('🔍 Recherche des classes Tailwind...\n');
const results = scanDirectory('./src');

if (results.length === 0) {
  console.log('✅ Aucune classe Tailwind trouvée !');
} else {
  console.log(`📊 ${results.length} fichiers contiennent des classes Tailwind:\n`);
  
  results.sort((a, b) => b.count - a.count).forEach(r => {
    console.log(`📄 ${r.file}`);
    console.log(`   ${r.count} classes détectées`);
    console.log(`   Exemples: ${r.classes.slice(0, 5).join(', ')}`);
    console.log('');
  });
  
  console.log('\n💡 Utilisez les mappings dans ce guide pour remplacer ces classes.');
}
```

**Exécuter le script :**

```bash
cd frontend
node scripts/find-tailwind-classes.js
```

### Étape 10 : Tester le dark mode

**Après la migration, tester :**

1. Ouvrir l'application dans le navigateur
2. Cliquer sur le bouton soleil/lune pour basculer le thème
3. Vérifier que TOUTES les couleurs changent correctement
4. Rafraîchir la page pour vérifier la persistance

### Étape 11 : Personnaliser les couleurs (optionnel)

**Pour changer les couleurs de toute l'application, modifier uniquement `frontend/src/theme/my-preset.ts` :**

```typescript
// Exemple : Passer du vert au bleu
primary: {
    50: '{blue.50}',
    100: '{blue.100}',
    // ... etc
    500: '{blue.500}',  // Couleur principale
    600: '{blue.600}',  // Hover
}

// Ou utiliser des couleurs hexadécimales custom
primary: {
    50: '#eff6ff',
    100: '#dbeafe',
    500: '#3b82f6',  // Votre couleur principale
    600: '#2563eb',  // Hover
    // ... etc
}
```

## 📋 Checklist finale

- [ ] Thème personnalisé créé (`src/theme/my-preset.ts`)
- [ ] Composable useTheme créé (`src/composables/useTheme.ts`)
- [ ] main.ts mis à jour avec la nouvelle configuration
- [ ] useDarkMode.ts supprimé
- [ ] style.css nettoyé (sans Tailwind)
- [ ] Packages Tailwind désinstallés
- [ ] tailwind.config.js supprimé
- [ ] Tous les composants .vue migrés
- [ ] Dark mode testé et fonctionnel
- [ ] Persistance du thème vérifiée

## 🎯 Résultat attendu

Après cette migration :
- ✅ Un seul fichier (`my-preset.ts`) pour gérer toutes les couleurs
- ✅ Dark mode 100% fonctionnel avec la classe `p-dark`
- ✅ Cohérence visuelle sur toute l'application
- ✅ Performance améliorée (moins de CSS)
- ✅ Maintenance simplifiée
- ✅ Respect total du design system PrimeVue 4

## 💡 Tips supplémentaires

1. **Utilise les composants PrimeVue natifs** quand possible (Card, Button, DataTable, etc.)
2. **Variables CSS PrimeVue** pour les styles custom : `var(--p-primary-color)`, `var(--p-surface-0)`, etc.
3. **Évite les styles inline** - crée plutôt des classes CSS dans `<style scoped>`
4. **Documentation PrimeVue 4** : https://primevue.org/theming/styled/

## 🆘 En cas de problème

Si certains éléments ne s'affichent pas correctement après la migration :

1. Vérifier que la classe `p-dark` est bien ajoutée/retirée sur `<html>`
2. Vérifier les variables CSS utilisées dans les DevTools
3. S'assurer qu'aucune classe Tailwind ne reste
4. Vérifier que le preset est bien importé dans main.ts

---

**Migration réalisée pour le projet DB Importer - Novembre 2025**
