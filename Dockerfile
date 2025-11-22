FROM node:22-bullseye AS base

WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# تثبيت المكتبات اللازمة لـ sharp + chromium
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvips-dev \
    libfftw3-dev \
    libpng-dev \
    libjpeg-dev \
    liblcms2-dev \
    libtiff-dev \
    libgif-dev \
    libglib2.0-dev \
    chromium \
    git \
    python3 \
    make \
    g++ \
    bash \
    && rm -rf /var/lib/apt/lists/*

# نسخ package.json و lockfile
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
