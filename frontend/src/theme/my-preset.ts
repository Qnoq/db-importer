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
