# --- 1. Сборка фронтенда ---
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .
RUN yarn build

# Устанавливаем утилиты для сжатия
RUN apk add --no-cache gzip brotli

# Сжимаем файлы в dist/
# - gzip: максимальное сжатие (-9), создаёт .gz рядом с файлами
# - brotli: максимальное сжатие (-Z), создаёт .br рядом с файлами
RUN find dist -type f -regex ".*\.\(js\|css\|html\|svg\|json\)" -exec gzip -9 -k {} \;
RUN find dist -type f -regex ".*\.\(js\|css\|html\|svg\|json\)" -exec brotli -Z {} \;


# --- 2. Nginx для раздачи сборки ---
FROM nginx:stable-alpine

# Копируем сборку в Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем конфиг
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]