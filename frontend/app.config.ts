// frontend/app.config.ts
export default defineAppConfig({
  ui: {
    // Couleurs principales
    primary: 'green',
    gray: 'slate',
    
    // Configuration globale des stratégies
    strategy: 'override', // ou 'merge' pour fusionner avec les défauts
    
    // Configuration des composants
    button: {
      base: 'focus:outline-none focus-visible:outline-0 disabled:cursor-not-allowed disabled:opacity-75 flex-shrink-0 font-medium',
      rounded: 'rounded-md',
      size: {
        xs: 'text-xs px-2.5 py-1.5',
        sm: 'text-sm px-3 py-1.5',
        md: 'text-sm px-4 py-2',
        lg: 'text-base px-4 py-2',
        xl: 'text-base px-6 py-3'
      },
      variant: {
        solid: 'shadow-sm text-white dark:text-gray-900 bg-{color}-500 hover:bg-{color}-600 disabled:bg-{color}-500 dark:bg-{color}-400 dark:hover:bg-{color}-500 dark:disabled:bg-{color}-400 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400',
        outline: 'ring-1 ring-inset ring-current text-{color}-500 dark:text-{color}-400 hover:bg-{color}-50 dark:hover:bg-{color}-950 focus-visible:ring-2 focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400',
        soft: 'text-{color}-500 dark:text-{color}-400 bg-{color}-50 hover:bg-{color}-100 dark:bg-{color}-950 dark:hover:bg-{color}-900 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400',
        ghost: 'text-{color}-500 dark:text-{color}-400 hover:bg-{color}-50 dark:hover:bg-{color}-950 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400',
        link: 'text-{color}-500 hover:text-{color}-600 dark:text-{color}-400 dark:hover:text-{color}-500 underline-offset-4 hover:underline focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400'
      },
      default: {
        size: 'md',
        variant: 'solid',
        color: 'primary',
        loadingIcon: 'i-heroicons-arrow-path-20-solid'
      }
    },
    
    input: {
      base: 'relative block w-full disabled:cursor-not-allowed disabled:opacity-75 focus:outline-none border-0',
      rounded: 'rounded-md',
      placeholder: 'placeholder-gray-400 dark:placeholder-gray-500',
      size: {
        xs: 'text-xs px-2.5 py-1.5',
        sm: 'text-sm px-3 py-1.5',
        md: 'text-sm px-4 py-2',
        lg: 'text-base px-4 py-2',
        xl: 'text-base px-6 py-3'
      },
      color: {
        white: {
          outline: 'shadow-sm bg-white dark:bg-gray-900 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-primary-500 dark:focus:ring-primary-400'
        },
        gray: {
          outline: 'shadow-sm bg-gray-50 dark:bg-gray-800 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-primary-500 dark:focus:ring-primary-400'
        }
      },
      variant: {
        outline: 'shadow-sm bg-transparent text-gray-900 dark:text-white ring-1 ring-inset ring-{color}-500 dark:ring-{color}-400 focus:ring-2 focus:ring-{color}-500 dark:focus:ring-{color}-400',
        none: 'bg-transparent focus:ring-0 focus:shadow-none'
      },
      icon: {
        base: 'flex-shrink-0 text-gray-400 dark:text-gray-500',
        color: 'text-{color}-500 dark:text-{color}-400',
        size: {
          xs: 'h-4 w-4',
          sm: 'h-4 w-4',
          md: 'h-5 w-5',
          lg: 'h-5 w-5',
          xl: 'h-6 w-6'
        }
      },
      default: {
        size: 'md',
        color: 'white',
        variant: 'outline',
        loadingIcon: 'i-heroicons-arrow-path-20-solid'
      }
    },
    
    select: {
      base: 'relative block w-full disabled:cursor-not-allowed disabled:opacity-75 focus:outline-none border-0',
      rounded: 'rounded-md',
      placeholder: 'text-gray-400 dark:text-gray-500',
      size: {
        xs: 'text-xs px-2.5 py-1.5',
        sm: 'text-sm px-3 py-1.5',
        md: 'text-sm px-4 py-2',
        lg: 'text-base px-4 py-2',
        xl: 'text-base px-6 py-3'
      },
      color: {
        white: {
          outline: 'shadow-sm bg-white dark:bg-gray-900 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-primary-500 dark:focus:ring-primary-400'
        },
        gray: {
          outline: 'shadow-sm bg-gray-50 dark:bg-gray-800 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-primary-500 dark:focus:ring-primary-400'
        }
      },
      icon: {
        base: 'flex-shrink-0 text-gray-400 dark:text-gray-500',
        trailing: 'ms-2',
        size: {
          xs: 'h-4 w-4',
          sm: 'h-4 w-4',
          md: 'h-5 w-5',
          lg: 'h-5 w-5',
          xl: 'h-6 w-6'
        }
      },
      default: {
        size: 'md',
        color: 'white',
        variant: 'outline',
        loadingIcon: 'i-heroicons-arrow-path-20-solid',
        trailingIcon: 'i-heroicons-chevron-down-20-solid'
      }
    },
    
    selectMenu: {
      base: 'relative focus:outline-none overflow-y-auto scroll-py-1',
      background: 'bg-white dark:bg-gray-800',
      shadow: 'shadow-lg',
      rounded: 'rounded-md',
      padding: 'p-1',
      ring: 'ring-1 ring-gray-200 dark:ring-gray-700',
      empty: 'text-sm text-gray-400 dark:text-gray-500 px-2 py-1.5',
      option: {
        base: 'cursor-pointer select-none relative flex items-center justify-between gap-2 rounded-md px-2 py-1.5 text-sm',
        active: 'bg-gray-100 dark:bg-gray-900 text-gray-900 dark:text-white',
        inactive: 'text-gray-700 dark:text-gray-200',
        selected: 'pe-7',
        disabled: 'cursor-not-allowed opacity-50',
        icon: {
          base: 'flex-shrink-0 h-4 w-4',
          active: 'text-gray-900 dark:text-white',
          inactive: 'text-gray-400 dark:text-gray-500'
        },
        selectedIcon: {
          base: 'absolute end-2 flex-shrink-0 h-4 w-4 text-gray-900 dark:text-white'
        }
      },
      transition: {
        enterActiveClass: 'transition ease-out duration-100',
        enterFromClass: 'transform opacity-0 scale-95',
        enterToClass: 'transform opacity-100 scale-100',
        leaveActiveClass: 'transition ease-in duration-75',
        leaveFromClass: 'transform opacity-100 scale-100',
        leaveToClass: 'transform opacity-0 scale-95'
      },
      popper: {
        placement: 'bottom-start',
        scroll: false
      }
    },
    
    alert: {
      base: 'relative overflow-hidden w-full',
      rounded: 'rounded-lg',
      shadow: 'shadow',
      padding: 'p-4',
      gap: 'gap-3',
      icon: {
        base: 'flex-shrink-0 w-5 h-5'
      },
      title: 'text-sm font-medium',
      description: 'mt-1 text-sm leading-5 opacity-90',
      default: {
        color: 'white',
        variant: 'solid',
        closeButton: {
          icon: 'i-heroicons-x-mark-20-solid',
          color: 'gray',
          variant: 'link'
        }
      }
    },
    
    modal: {
      base: 'relative text-left overflow-hidden w-full flex flex-col',
      overlay: {
        base: 'fixed inset-0 transition-opacity',
        background: 'bg-gray-200/75 dark:bg-gray-800/75',
        transition: {
          enter: 'ease-out duration-300',
          enterFrom: 'opacity-0',
          enterTo: 'opacity-100',
          leave: 'ease-in duration-200',
          leaveFrom: 'opacity-100',
          leaveTo: 'opacity-0'
        }
      },
      background: 'bg-white dark:bg-gray-900',
      ring: 'ring-1 ring-gray-200 dark:ring-gray-800',
      rounded: 'rounded-lg',
      shadow: 'shadow-xl',
      width: 'sm:max-w-md',
      height: '',
      padding: 'p-4',
      transition: {
        enter: 'ease-out duration-300',
        enterFrom: 'opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95',
        enterTo: 'opacity-100 translate-y-0 sm:scale-100',
        leave: 'ease-in duration-200',
        leaveFrom: 'opacity-100 translate-y-0 sm:scale-100',
        leaveTo: 'opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95'
      }
    },
    
    card: {
      base: 'overflow-hidden',
      background: 'bg-white dark:bg-gray-900',
      divide: 'divide-y divide-gray-200 dark:divide-gray-800',
      ring: 'ring-1 ring-gray-200 dark:ring-gray-800',
      rounded: 'rounded-lg',
      shadow: 'shadow',
      body: {
        base: '',
        background: '',
        padding: 'px-4 py-5 sm:p-6'
      },
      header: {
        base: '',
        background: '',
        padding: 'px-4 py-5 sm:px-6'
      },
      footer: {
        base: '',
        background: '',
        padding: 'px-4 py-4 sm:px-6'
      }
    },
    
    checkbox: {
      base: 'h-4 w-4 dark:checked:bg-current dark:checked:border-transparent dark:indeterminate:bg-current dark:indeterminate:border-transparent disabled:opacity-50 disabled:cursor-not-allowed focus:ring-0 focus:ring-transparent focus:ring-offset-transparent',
      rounded: 'rounded',
      color: 'text-{color}-500 dark:text-{color}-400',
      background: 'bg-white dark:bg-gray-900',
      border: 'border border-gray-300 dark:border-gray-700',
      ring: 'focus-visible:ring-2 focus-visible:ring-{color}-500 dark:focus-visible:ring-{color}-400 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-gray-900',
      label: 'ms-2 text-sm font-medium text-gray-700 dark:text-gray-200',
      help: 'ms-2 text-sm text-gray-500 dark:text-gray-400',
      default: {
        color: 'primary'
      }
    },
    
    table: {
      wrapper: 'relative overflow-x-auto',
      base: 'min-w-full table-fixed',
      divide: 'divide-y divide-gray-300 dark:divide-gray-700',
      thead: 'relative',
      tbody: 'divide-y divide-gray-200 dark:divide-gray-800',
      tr: {
        base: '',
        selected: 'bg-gray-50 dark:bg-gray-800/50',
        active: 'hover:bg-gray-50 dark:hover:bg-gray-800/50 cursor-pointer'
      },
      th: {
        base: 'text-left rtl:text-right',
        padding: 'px-3 py-3.5',
        color: 'text-gray-900 dark:text-white',
        font: 'font-semibold',
        size: 'text-sm'
      },
      td: {
        base: 'whitespace-nowrap',
        padding: 'px-3 py-4',
        color: 'text-gray-500 dark:text-gray-400',
        font: '',
        size: 'text-sm'
      },
      loadingState: {
        wrapper: 'flex flex-col items-center justify-center flex-1 px-6 py-14 sm:px-14',
        label: 'text-sm text-center text-gray-900 dark:text-white',
        icon: 'w-6 h-6 mx-auto text-gray-400 dark:text-gray-500 mb-4 animate-spin'
      },
      emptyState: {
        wrapper: 'flex flex-col items-center justify-center flex-1 px-6 py-14 sm:px-14',
        label: 'text-sm text-center text-gray-900 dark:text-white',
        icon: 'w-6 h-6 mx-auto text-gray-400 dark:text-gray-500 mb-4'
      },
      default: {
        sortAscIcon: 'i-heroicons-bars-arrow-up-20-solid',
        sortDescIcon: 'i-heroicons-bars-arrow-down-20-solid',
        sortButton: {
          icon: 'i-heroicons-arrows-up-down-20-solid',
          trailing: true,
          square: true,
          color: 'gray',
          variant: 'ghost',
          size: 'xs',
          class: '-m-1.5'
        },
        loadingState: {
          icon: 'i-heroicons-arrow-path-20-solid',
          label: 'Loading...'
        },
        emptyState: {
          icon: 'i-heroicons-circle-stack-20-solid',
          label: 'No items.'
        }
      }
    },
    
    badge: {
      base: 'inline-flex items-center',
      rounded: 'rounded-md',
      font: 'font-medium',
      size: {
        xs: 'text-xs px-1.5 py-0.5',
        sm: 'text-xs px-2 py-1',
        md: 'text-sm px-2 py-1',
        lg: 'text-sm px-2.5 py-1.5'
      },
      color: {
        white: {
          solid: 'ring-1 ring-inset ring-gray-300 dark:ring-gray-700 text-gray-900 dark:text-white bg-white dark:bg-gray-900'
        },
        gray: {
          solid: 'ring-1 ring-inset ring-gray-300 dark:ring-gray-700 text-gray-700 dark:text-gray-200 bg-gray-50 dark:bg-gray-800'
        },
        black: {
          solid: 'text-white dark:text-gray-900 bg-gray-900 dark:bg-white'
        }
      },
      variant: {
        solid: 'bg-{color}-50 dark:bg-{color}-400 dark:bg-opacity-10 text-{color}-500 dark:text-{color}-400',
        outline: 'text-{color}-500 dark:text-{color}-400 ring-1 ring-inset ring-{color}-500 dark:ring-{color}-400',
        soft: 'bg-{color}-50 dark:bg-{color}-400 dark:bg-opacity-10 text-{color}-500 dark:text-{color}-400',
        subtle: 'bg-{color}-50 dark:bg-{color}-400 dark:bg-opacity-10 text-{color}-500 dark:text-{color}-400 ring-1 ring-inset ring-{color}-500 dark:ring-{color}-400 ring-opacity-25 dark:ring-opacity-25'
      },
      default: {
        size: 'sm',
        variant: 'solid',
        color: 'primary'
      }
    },
    
    tooltip: {
      wrapper: 'relative inline-flex',
      container: 'z-20',
      base: '[@media(pointer:coarse)]:hidden h-auto px-2 py-1 text-xs font-normal',
      background: 'bg-white dark:bg-gray-900',
      color: 'text-gray-900 dark:text-white',
      shadow: 'shadow',
      rounded: 'rounded',
      ring: 'ring-1 ring-gray-200 dark:ring-gray-800',
      shortcuts: 'hidden md:inline-flex flex-shrink-0 gap-0.5',
      arrow: {
        base: 'invisible before:visible before:block before:rotate-45 before:z-[-1] before:w-2 before:h-2',
        ring: 'before:ring-1 before:ring-gray-200 dark:before:ring-gray-800',
        background: 'before:bg-white dark:before:bg-gray-900',
        shadow: 'before:shadow',
        placement: {
          top: 'bottom-0 mb-[6px] left-1/2 -translate-x-1/2',
          'top-start': 'bottom-0 mb-[6px] left-2',
          'top-end': 'bottom-0 mb-[6px] right-2',
          bottom: 'top-0 mt-[6px] left-1/2 -translate-x-1/2',
          'bottom-start': 'top-0 mt-[6px] left-2',
          'bottom-end': 'top-0 mt-[6px] right-2',
          left: 'right-0 mr-[6px] top-1/2 -translate-y-1/2',
          'left-start': 'right-0 mr-[6px] top-2',
          'left-end': 'right-0 mr-[6px] bottom-2',
          right: 'left-0 ml-[6px] top-1/2 -translate-y-1/2',
          'right-start': 'left-0 ml-[6px] top-2',
          'right-end': 'left-0 ml-[6px] bottom-2'
        }
      },
      transition: {
        enterActiveClass: 'transition ease-out duration-200',
        enterFromClass: 'opacity-0',
        enterToClass: 'opacity-100',
        leaveActiveClass: 'transition ease-in duration-150',
        leaveFromClass: 'opacity-100',
        leaveToClass: 'opacity-0'
      },
      popper: {
        strategy: 'fixed'
      }
    }
  }
})