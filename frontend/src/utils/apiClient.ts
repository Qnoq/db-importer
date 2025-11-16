/**
 * Centralized API Client
 * Provides a unified interface for all HTTP requests with consistent error handling
 */

// API Configuration
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

/**
 * Custom error class for API errors
 */
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public statusText: string,
    public data?: any
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

/**
 * API Request options
 */
export interface ApiRequestOptions {
  headers?: Record<string, string>
  credentials?: RequestCredentials
  signal?: AbortSignal
}

/**
 * API Response wrapper
 */
export interface ApiResponse<T = any> {
  data: T
  message?: string
  error?: string
}

/**
 * Default headers for all requests
 */
const getDefaultHeaders = (): Record<string, string> => ({
  'Content-Type': 'application/json',
})

/**
 * Process the response and handle errors uniformly
 */
async function processResponse<T>(response: Response): Promise<T> {
  // Try to parse JSON response
  let data: any
  try {
    data = await response.json()
  } catch {
    // If JSON parsing fails, use status text as error
    if (!response.ok) {
      throw new ApiError(
        response.statusText || 'Request failed',
        response.status,
        response.statusText
      )
    }
    return data
  }

  // Handle error responses
  if (!response.ok) {
    const errorMessage = data.error || data.message || response.statusText || 'Request failed'
    throw new ApiError(errorMessage, response.status, response.statusText, data)
  }

  return data
}

/**
 * Make a request to the API
 */
async function request<T = any>(
  endpoint: string,
  method: string,
  body?: any,
  options: ApiRequestOptions = {}
): Promise<T> {
  const url = `${API_URL}${endpoint}`

  const config: RequestInit = {
    method,
    headers: {
      ...getDefaultHeaders(),
      ...options.headers,
    },
    credentials: options.credentials || 'include', // Always include cookies by default
    signal: options.signal,
  }

  // Add body for non-GET requests
  if (body && method !== 'GET' && method !== 'HEAD') {
    config.body = JSON.stringify(body)
  }

  const response = await fetch(url, config)
  return processResponse<T>(response)
}

/**
 * API Client
 */
export const apiClient = {
  /**
   * GET request
   */
  get<T = any>(endpoint: string, options?: ApiRequestOptions): Promise<T> {
    return request<T>(endpoint, 'GET', undefined, options)
  },

  /**
   * POST request
   */
  post<T = any>(endpoint: string, body?: any, options?: ApiRequestOptions): Promise<T> {
    return request<T>(endpoint, 'POST', body, options)
  },

  /**
   * PUT request
   */
  put<T = any>(endpoint: string, body?: any, options?: ApiRequestOptions): Promise<T> {
    return request<T>(endpoint, 'PUT', body, options)
  },

  /**
   * PATCH request
   */
  patch<T = any>(endpoint: string, body?: any, options?: ApiRequestOptions): Promise<T> {
    return request<T>(endpoint, 'PATCH', body, options)
  },

  /**
   * DELETE request
   */
  delete<T = any>(endpoint: string, options?: ApiRequestOptions): Promise<T> {
    return request<T>(endpoint, 'DELETE', undefined, options)
  },

  /**
   * Upload file with multipart/form-data
   */
  upload<T = any>(endpoint: string, formData: FormData, options?: ApiRequestOptions): Promise<T> {
    const url = `${API_URL}${endpoint}`

    // Don't set Content-Type for FormData, let browser set it with boundary
    const headers = { ...options?.headers }
    delete headers['Content-Type']

    const config: RequestInit = {
      method: 'POST',
      headers,
      credentials: options?.credentials || 'include',
      signal: options?.signal,
      body: formData,
    }

    return fetch(url, config).then(processResponse<T>)
  },

  /**
   * Get the API base URL
   */
  getBaseUrl(): string {
    return API_URL
  },
}

/**
 * Helper to create async action wrapper with loading/error state
 * Usage in stores:
 *
 * const action = createAsyncAction(
 *   () => apiClient.get('/endpoint'),
 *   (data) => { this.items = data }
 * )
 * await action()
 */
export function createAsyncAction<T = any>(
  apiCall: () => Promise<T>,
  onSuccess?: (data: T) => void,
  onError?: (error: ApiError) => void
) {
  return async () => {
    try {
      const data = await apiCall()
      if (onSuccess) {
        onSuccess(data)
      }
      return data
    } catch (error) {
      const apiError = error instanceof ApiError ? error : new ApiError(
        error instanceof Error ? error.message : 'Unknown error',
        500,
        'Internal Error'
      )

      if (onError) {
        onError(apiError)
      } else {
        throw apiError
      }
    }
  }
}

export default apiClient
