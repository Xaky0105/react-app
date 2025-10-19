# --- 1. Сборка фронтенда ---
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .
RUN yarn build

# --- 2. Nginx для раздачи сборки ---
FROM nginx:stable-alpine

# Копируем сборку в Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем конфиг
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]