<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
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

          <div class="flex items-center space-x-4">
            <a
              href="https://github.com/yourusername/db-importer"
              target="_blank"
              class="text-gray-500 hover:text-gray-700 transition"
              title="View on GitHub"
            >
              <i class="pi pi-github text-xl"></i>
            </a>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto py-8 sm:px-6 lg:px-8">
      <router-view />
    </main>

    <footer class="mt-auto py-6 border-t border-gray-200 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between text-sm text-gray-500">
          <p>
            Made with <span class="text-red-500">♥</span> for developers who need to import data safely
          </p>
          <div class="flex items-center space-x-4">
            <span>v1.0.0</span>
            <span>•</span>
            <a href="#" class="hover:text-gray-700 transition">Documentation</a>
            <span>•</span>
            <a href="#" class="hover:text-gray-700 transition">Support</a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
</script>
