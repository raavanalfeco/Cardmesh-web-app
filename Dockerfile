# syntax = docker/dockerfile:1

# ---- Build stage ----
# Pin exact Node LTS version. Bump deliberately, not automatically, and re-run
# `npm audit` after any bump.
ARG NODE_VERSION=20.19.0
FROM node:${NODE_VERSION}-slim AS build

WORKDIR /app

# Install deps first so this layer is cached unless package*.json changes.
COPY --link package.json package-lock.json ./
RUN npm install --production=false --legacy-peer-deps

# Copy source and build.
COPY --link . .
RUN npm run build

# Strip devDependencies before the final copy - final image should never
# contain build tooling, test frameworks, or linters.
RUN npm prune --production --legacy-peer-deps

# ---- Runtime stage ----
FROM node:${NODE_VERSION}-slim AS runtime

LABEL org.opencontainers.image.title="CardMesh web-app"

WORKDIR /app
ENV NODE_ENV=production

# Run as a dedicated, unprivileged, non-root user. Never run a public-facing
# Node process as root - if the process is ever compromised, root access to
# the container is a much bigger blast radius than a scoped app user.
RUN groupadd --system --gid 1001 nodeapp \
  && useradd --system --uid 1001 --gid nodeapp --home /app --shell /usr/sbin/nologin nodeapp

# Only copy the built output and pruned node_modules - nothing else from the
# build stage (no source maps of dev tooling, no test files, no .git).
COPY --from=build --chown=nodeapp:nodeapp /app/build ./build
COPY --from=build --chown=nodeapp:nodeapp /app/node_modules ./node_modules
COPY --from=build --chown=nodeapp:nodeapp /app/package.json ./package.json
COPY --from=build --chown=nodeapp:nodeapp /app/.env.production ./.env

# Drop root before the process ever starts.
USER nodeapp

EXPOSE 3000

# Let Docker/Coolify detect a hung or crashed process instead of routing
# traffic to a dead container silently.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', r => process.exit(r.statusCode < 500 ? 0 : 1)).on('error', () => process.exit(1))"

CMD [ "node", "build" ]
