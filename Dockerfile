# استخدم صورة node alpine
FROM node:22.21.1-alpine AS base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# تثبيت المكتبات اللازمة لـ sharp + chromium
RUN apk add --no-cache \
    vips-dev \
    fftw-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    lcms2-dev \
    openexr-dev \
    tiff-dev \
    giflib-dev \
    glib-dev \
    chromium \
    bash \
    git \
    python3 \
    make \
    g++ \
    libc6-compat \
    && rm -rf /var/cache/apk/*

# نسخ package.json و package-lock.json (بدون yarn.lock)
COPY package*.json ./

# تثبيت الحزم مع تثبيت sharp optional dependency
RUN npm install --include=optional

# مرحلة build
FROM base AS build
WORKDIR /usr/src/wpp-server
COPY . .
RUN npm run build

# مرحلة الإنتاج
FROM base
WORKDIR /usr/src/wpp-server
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
