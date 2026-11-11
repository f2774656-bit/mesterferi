FROM nineseconds/mtg:2.3.0 AS mtg
FROM node:22-bookworm-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build && npm prune --omit=dev
FROM node:22-bookworm-slim AS runtime
ENV NODE_ENV=production DATA_DIR=/data MTG_BIN=/usr/local/bin/mtg
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates dumb-init && rm -rf /var/lib/apt/lists/* && mkdir -p /data && chown -R node:node /data
COPY --from=mtg /mtg /usr/local/bin/mtg
COPY --from=build --chown=node:node /app/package.json ./package.json
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/server ./server
COPY --from=build --chown=node:node /app/dist ./dist
USER node
VOLUME ["/data"]
EXPOSE 3000 3128
ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["node","server/index.js"]
