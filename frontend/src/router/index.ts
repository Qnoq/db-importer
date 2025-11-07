import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../store/authStore'
import UploadSchema from '../pages/UploadSchema.vue'
import SelectTable from '../pages/SelectTable.vue'
import UploadData from '../pages/UploadData.vue'
import Mapping from '../pages/Mapping.vue'
import Login from '../pages/Login.vue'
import Register from '../pages/Register.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'UploadSchema',
      component: UploadSchema,
      meta: { requiresAuth: false }
    },
    {
      path: '/select-table',
      name: 'SelectTable',
      component: SelectTable,
      meta: { requiresAuth: false }
    },
    {
      path: '/upload-data',
      name: 'UploadData',
      component: UploadData,
      meta: { requiresAuth: false }
    },
    {
      path: '/mapping',
      name: 'Mapping',
      component: Mapping,
      meta: { requiresAuth: false }
    },
    {
      path: '/login',
      name: 'Login',
      component: Login,
      meta: { requiresAuth: false, guestOnly: true }
    },
    {
      path: '/register',
      name: 'Register',
      component: Register,
      meta: { requiresAuth: false, guestOnly: true }
    }
  ]
})

// Navigation guard for protected routes
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // Check if token needs refresh
  if (authStore.isAuthenticated && authStore.shouldRefreshToken() && !authStore.isTokenExpired) {
    try {
      await authStore.refreshAccessToken()
    } catch (error) {
      console.error('Token refresh failed:', error)
    }
  }

  // If route requires authentication
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // Redirect to login with return URL
    next({
      name: 'Login',
      query: { redirect: to.fullPath }
    })
    return
  }

  // If route is for guests only (login/register) and user is authenticated
  if (to.meta.guestOnly && authStore.isAuthenticated) {
    next({ name: 'UploadSchema' })
    return
  }

  next()
})

export default router
