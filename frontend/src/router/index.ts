import { createRouter, createWebHistory } from 'vue-router'
import UploadSchema from '../pages/UploadSchema.vue'
import SelectTable from '../pages/SelectTable.vue'
import UploadData from '../pages/UploadData.vue'
import Mapping from '../pages/Mapping.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'UploadSchema',
      component: UploadSchema
    },
    {
      path: '/select-table',
      name: 'SelectTable',
      component: SelectTable
    },
    {
      path: '/upload-data',
      name: 'UploadData',
      component: UploadData
    },
    {
      path: '/mapping',
      name: 'Mapping',
      component: Mapping
    }
  ]
})

export default router
