# ── STAGE 1: preparación de archivos estáticos ────────────────────────────────
# En un proyecto más complejo (React, Vue) aquí compilaríamos con npm build.
# Este frontend no tiene compilación, pero mantenemos multi-stage para
# cumplir buenas prácticas y porque la pauta lo exige.
FROM node:18-alpine AS builder

WORKDIR /app
# Si hubiera dependencias de build (webpack, vite, etc.) irían aquí.
# Por ahora solo copiamos los estáticos listos.
COPY index.html app.js ./

# ── STAGE 2: servidor Nginx ────────────────────────────────────────────────────
# nginx:alpine pesa ~23MB. Sirve archivos estáticos y actúa como
# reverse proxy hacia el backend. Es la elección estándar de producción.
FROM nginx:alpine AS runner

# Limpieza de la página por defecto de Nginx.
RUN rm -rf /usr/share/nginx/html/*

# Copiamos los estáticos desde el stage builder (no desde el host directamente).
COPY --from=builder /app/index.html /app/app.js /usr/share/nginx/html/

# Nuestra configuración custom reemplaza la de Nginx por defecto.
# Aquí se define el proxy reverso hacia el backend.
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
