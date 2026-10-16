FROM oven/bun:1.4.3-slim AS base
WORKDIR /usr/src/app
ENV BUN_INSTALL_CACHE_DIR=/root/.bun/install/cache

FROM base AS install

# dev
RUN mkdir -p /temp/dev
COPY package.json bun.lock /temp/dev/
RUN --mount=type=cache,target=/root/.bun/install/cache \
    cd /temp/dev && bun install --frozen-lockfile

# prod
RUN mkdir -p /temp/prod
COPY package.json bun.lock /temp/prod/
RUN --mount=type=cache,target=/root/.bun/install/cache \
    cd /temp/prod && bun install --frozen-lockfile --production

# build
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

ENV NODE_ENV=production
RUN bun run build

FROM base AS release
ENV NODE_ENV=production
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/dist dist
COPY --from=prerelease /usr/src/app/package.json .

USER bun
EXPOSE 3000

CMD ["bun", "dist/main.js"]
