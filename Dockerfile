# Zoo Foundation — Next.js static export, served via hanzoai/spa.
#
# next.config.js sets output:'export' -> static site in out/. Runtime
# serves it on :3000 via ghcr.io/hanzoai/spa (canonical Zoo static server).

# ─── Build stage ─────────────────────────────────────────────────────
FROM node:22-alpine AS build
RUN apk add --no-cache git
WORKDIR /app

# Manifest first for layer caching. The repo's pnpm-workspace.yaml only
# carries `onlyBuiltDependencies` (no `packages:` field), which pnpm v9
# rejects as an empty workspace root — and this is a single-package app,
# so it is intentionally NOT copied here.
COPY package.json pnpm-lock.yaml* ./
RUN corepack enable && corepack prepare pnpm@9 --activate
RUN pnpm install --no-frozen-lockfile

# Source + static export build (next build -> out/, then next-sitemap).
# Drop the workspace marker brought in by `COPY . .` for the same reason;
# next.config.js sets images.unoptimized, so the sharp build it gated is
# not needed for the export.
COPY . .
RUN rm -f pnpm-workspace.yaml
RUN pnpm build

# ─── Runtime: static via hanzoai/spa (serves /public on :3000) ───────
# The exported site carries ~485MB of static media (3D models, videos,
# images). Copying it as ONE layer makes a single ~485MB GHCR blob that
# evo's connection cannot upload in one shot (the PUT drops mid-stream).
# Splitting the heavy directories into separate COPY layers keeps each
# blob small enough to push (and resume) reliably. Order: biggest first
# so each is its own layer; the final COPY picks up everything else.
FROM ghcr.io/hanzoai/spa:1.2.0
COPY --from=build /app/out/models  /public/models
COPY --from=build /app/out/videos  /public/videos
COPY --from=build /app/out/images  /public/images
COPY --from=build /app/out/document /public/document
COPY --from=build /app/out         /public
