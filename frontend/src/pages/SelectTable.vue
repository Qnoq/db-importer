<template>
  <div class="px-4 py-6">
    <div class="bg-white shadow rounded-lg p-6">
      <h2 class="text-2xl font-semibold mb-4">Step 2: Select Target Table</h2>
      <p class="text-gray-600 mb-6">
        Choose the table where you want to import data
      </p>

      <div v-if="!store.hasSchema" class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
        <p class="text-yellow-700">No schema loaded. Please upload a SQL file first.</p>
        <button
          @click="router.push('/')"
          class="mt-3 text-blue-600 hover:text-blue-700 font-semibold"
        >
          <i class="pi pi-arrow-left mr-2"></i>
          Go back to upload schema
        </button>
      </div>

      <div v-else>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="table in store.tables"
            :key="table.name"
            @click="selectTable(table.name)"
            class="border-2 rounded-lg p-4 cursor-pointer transition hover:border-blue-500 hover:bg-blue-50"
            :class="{ 'border-blue-500 bg-blue-50': selectedTableName === table.name }"
          >
            <div class="flex items-center mb-2">
              <i class="pi pi-table text-blue-600 text-xl mr-2"></i>
              <h3 class="font-semibold text-lg">{{ table.name }}</h3>
            </div>
            <p class="text-gray-600 text-sm">{{ table.fields.length }} columns</p>
            <div class="mt-3 max-h-32 overflow-y-auto">
              <ul class="text-sm text-gray-500 space-y-1">
                <li v-for="field in table.fields.slice(0, 5)" :key="field.name">
                  <i class="pi pi-circle-fill text-xs mr-1"></i>
                  {{ field.name }}
                </li>
                <li v-if="table.fields.length > 5" class="text-xs italic">
                  ... and {{ table.fields.length - 5 }} more
                </li>
              </ul>
            </div>
          </div>
        </div>

        <button
          v-if="selectedTableName"
          @click="goToUploadData"
          class="mt-6 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-md transition"
        >
          Continue to Data Upload
          <i class="pi pi-arrow-right ml-2"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMappingStore } from '../store/mappingStore'

const router = useRouter()
const store = useMappingStore()
const selectedTableName = ref('')

function selectTable(tableName: string) {
  selectedTableName.value = tableName
  store.selectTable(tableName)
}

function goToUploadData() {
  router.push('/upload-data')
}
</script>
