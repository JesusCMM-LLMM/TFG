import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  server: {
    allowedHosts: ['frontend_dev'],
    watch: {
      usePolling: true,     // Obliga a revisar los archivos periódicamente
      interval: 1000        // Revisa cada 1 segundo
    },
    hmr: {
      clientPort: 80,       // El WebSocket debe conectarse a través del puerto 80 de tu Nginx
      // host: 'localhost'  // Descomentar esto si sigues habiendo errores de conexión en la consola del navegador
    }
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
      },
    },
  })
