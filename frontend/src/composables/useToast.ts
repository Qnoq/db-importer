import { useToast as useNuxtToast } from '#imports'

interface ToastOptions {
  title: string
  description?: string
  color?: 'green' | 'red' | 'blue' | 'orange' | 'gray' | 'primary' | 'error' | 'success' | 'warning' | 'info'
  timeout?: number
  actions?: Array<{
    label: string
    click?: () => void
  }>
}

export function useToast() {
  const toast = useNuxtToast()

  return {
    show(options: ToastOptions) {
      toast.add({
        id: `toast-${Date.now()}`,
        title: options.title,
        description: options.description,
        color: options.color || 'gray',
        timeout: options.timeout || 3000,
        actions: options.actions,
        icon: getIconForColor(options.color)
      })
    },

    success(title: string, description?: string) {
      this.show({
        title,
        description,
        color: 'green'
      })
    },

    error(title: string, description?: string) {
      this.show({
        title,
        description,
        color: 'red'
      })
    },

    warning(title: string, description?: string) {
      this.show({
        title,
        description,
        color: 'orange'
      })
    },

    info(title: string, description?: string) {
      this.show({
        title,
        description,
        color: 'blue'
      })
    }
  }
}

function getIconForColor(color?: string): string {
  switch (color) {
    case 'green':
    case 'success':
      return 'i-heroicons-check-circle'
    case 'red':
    case 'error':
      return 'i-heroicons-x-circle'
    case 'orange':
    case 'warning':
      return 'i-heroicons-exclamation-triangle'
    case 'blue':
    case 'info':
      return 'i-heroicons-information-circle'
    default:
      return 'i-heroicons-bell'
  }
}
