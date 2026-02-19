# ── Stage 1: build ───────────────────────────────────────────────────────────
FROM dart:stable AS build

WORKDIR /app

# Fetch dependencies before copying source so Docker can cache this layer.
COPY pubspec.* ./
RUN dart pub get

COPY . .
# Re-run pub get in offline mode to verify the lockfile is up-to-date.
RUN dart pub get --offline

# Compile to a self-contained AOT native binary.
RUN dart compile exe bin/server.dart -o /app/server

# ── Stage 2: runtime ─────────────────────────────────────────────────────────
FROM debian:bookworm-slim AS runtime

# sqlite3 shared library is required at runtime by the compiled binary.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/server ./server

# Persistent volume for the SQLite database file and uploaded images.
# Mount a named volume here in production:
#   docker run -v gymtracker_data:/data ...
RUN mkdir -p /data /data/uploads
VOLUME ["/data"]

ENV PORT=8080 \
    DB_PATH=/data/gymtracker.db \
    UPLOADS_DIR=/data/uploads
# JWT_SECRET must be supplied at runtime — never bake secrets into the image.
# Example: docker run -e JWT_SECRET=$(openssl rand -hex 32) ...

EXPOSE 8080

ENTRYPOINT ["./server"]
