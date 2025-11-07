<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 flex flex-col">
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center shadow-md">
              <i class="pi pi-database text-white text-xl"></i>
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">
                SQL Data Importer
              </h1>
              <p class="text-xs text-gray-500">Import data safely & efficiently</p>
            </div>
          </div>

          <!-- Future: Add quick action buttons here if needed -->
          <div class="flex items-center space-x-4">
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto py-8 sm:px-6 lg:px-8 flex-1">
      <router-view />
    </main>

    <footer class="py-6 border-t border-gray-200 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-center text-sm text-gray-500">
          <span>v{{ appVersion }}</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { APP_VERSION } from './version'

const appVersion = APP_VERSION
</script>
