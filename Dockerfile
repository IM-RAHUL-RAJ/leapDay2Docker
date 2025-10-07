# ---------- Build stage ----------
FROM node:20-bookworm-slim AS build
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=development
ENV NPM_CONFIG_PRODUCTION=false

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .

# ✅ Build with SSR disabled to avoid document errors
RUN npx ng build --configuration=production --ssr=false --prerender=false

# ---------- Runtime stage ----------
FROM nginx:1.27-alpine

RUN printf 'server {\n\
  listen 80;\n\
  server_name _;\n\
  root /usr/share/nginx/html;\n\
  index index.html;\n\
  location / { try_files $uri $uri/ /index.html; }\n\
}\n' > /etc/nginx/conf.d/default.conf

# Remove default Nginx welcome assets
RUN rm -rf /usr/share/nginx/html/*

# ✅ Copy only the browser build output (Angular 18 creates dist/<app>/browser)
COPY --from=build /app/dist/trade-x/browser /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
