# Building Images with Dockerfiles

This is where Docker goes from "neat tool" to "I can't work without this." A Dockerfile lets you define exactly what your application needs, and build it into a portable image that runs anywhere.

For data engineering, this means you can package your Python ETL scripts, your dbt projects, your Spark jobs — anything — into self-contained images that your team can use without installing a single dependency.

## Your First Dockerfile

Create a file called `Dockerfile` (no extension):

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "etl.py"]
```

That's it. Seven lines. Let's build it.

First, create the supporting files:

```bash
mkdir my-etl && cd my-etl

# Create requirements.txt
echo "pandas==2.1.4
requests==2.31.0" > requirements.txt

# Create a simple ETL script
cat > etl.py << 'EOF'
import pandas as pd
print("ETL Pipeline Starting...")
df = pd.DataFrame({
    'skill': ['SQL', 'Python', 'Docker', 'Airflow'],
    'demand': [5000, 4500, 3200, 2800]
})
print(f"Loaded {len(df)} records")
print(df.to_string(index=False))
print("ETL Pipeline Complete!")
EOF

# Create the Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "etl.py"]
EOF
```

Now build and run:

```bash
# Build the image (the . means "use current directory as build context")
docker build -t my-etl:v1 .

# Run it
docker run --rm my-etl:v1
```

You should see the ETL output. Congratulations — you just containerized your first data pipeline.

## Dockerfile Instructions — The Full Toolkit

### FROM — The Starting Point

Every Dockerfile starts with `FROM`. It defines the base image.

```dockerfile
FROM python:3.11-slim          # Most common for DE
FROM ubuntu:22.04              # When you need full OS control
FROM alpine:3.19               # When size matters
FROM scratch                   # Empty — for Go binaries, etc.
```

For data engineering, `python:3.11-slim` is your go-to. It has Python + pip ready, without the bloat of the full image.

**Multi-stage builds can have multiple FROM statements** — we'll cover that later.

### WORKDIR — Set the Working Directory

```dockerfile
WORKDIR /app
```

All subsequent commands (`COPY`, `RUN`, `CMD`) execute relative to this directory. If it doesn't exist, Docker creates it.

Always set a `WORKDIR`. Don't scatter files in the root filesystem.

### COPY — Get Files Into the Image

```dockerfile
COPY requirements.txt .                # Copy one file
COPY src/ ./src/                       # Copy a directory
COPY *.py .                            # Copy matching files
COPY --chown=appuser:appuser . .       # Copy with ownership
```

The first argument is the path on your machine (relative to build context). The second is the destination inside the image.

### ADD vs COPY

`ADD` does everything `COPY` does, plus:
- Automatically extracts `.tar` archives
- Can download from URLs

But **always use COPY** unless you specifically need extraction. `COPY` is transparent — it does exactly what it says. `ADD` has magic behavior that can surprise you.

```dockerfile
# Good — explicit
COPY data.csv /app/data.csv

# Only use ADD for archives
ADD data.tar.gz /app/
```

### RUN — Execute Commands During Build

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y curl
RUN mkdir -p /app/output
```

`RUN` executes a command and **commits the result as a new layer** in the image. Each `RUN` creates a layer, so combine related commands:

```dockerfile
# Bad — 3 layers
RUN apt-get update
RUN apt-get install -y curl wget
RUN apt-get clean

# Good — 1 layer, and cleanup in the same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

Why does combining matter? Because even if you delete files in a later `RUN`, the file still exists in a previous layer. Layers are additive. Delete in the same `RUN` to actually save space.

### CMD — What Runs When the Container Starts

```dockerfile
CMD ["python", "etl.py"]
```

This is the default command when you `docker run` the image. Users can override it:

```bash
docker run my-etl:v1 python other_script.py
```

**Use the exec form** (JSON array) not the shell form:

```dockerfile
# Good — exec form (no shell wrapping, signals work properly)
CMD ["python", "etl.py"]

# Avoid — shell form (runs as /bin/sh -c "python etl.py")
CMD python etl.py
```

### ENTRYPOINT — The Fixed Command

`ENTRYPOINT` is like `CMD` but **can't be overridden** by the user (without `--entrypoint`). `CMD` becomes the default arguments.

```dockerfile
ENTRYPOINT ["python"]
CMD ["etl.py"]
```

This means:
```bash
docker run my-etl               # Runs: python etl.py
docker run my-etl transform.py  # Runs: python transform.py
```

Great pattern for data tools where the language runtime is fixed but the script varies.

### ENV — Set Environment Variables

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DATA_DIR=/app/data
```

These persist into the running container. You can also override at runtime:

```bash
docker run -e DATA_DIR=/mnt/data my-etl
```

For data engineering, common ENV vars:

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1           # Don't create .pyc files
ENV PYTHONUNBUFFERED=1                  # Print output immediately (important for logs!)
ENV PIP_NO_CACHE_DIR=1                  # Don't cache pip downloads
```

`PYTHONUNBUFFERED=1` is crucial. Without it, Python buffers stdout and your `docker logs` might show nothing until the container exits.

### ARG — Build-Time Variables

```dockerfile
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}
```

`ARG` only exists during `docker build`. Pass it with `--build-arg`:

```bash
docker build --build-arg PYTHON_VERSION=3.12 -t my-etl .
```

Use `ARG` for things that change between builds but shouldn't be in the running container. Use `ENV` for things the running application needs.

### EXPOSE — Document Ports

```dockerfile
EXPOSE 8080
```

This does NOT actually publish the port. It's documentation — it tells people (and tools) which ports the container listens on. You still need `-p` when running:

```bash
docker run -p 8080:8080 my-app
```

### LABEL — Add Metadata

```dockerfile
LABEL maintainer="aman@example.com"
LABEL version="2.1.0"
LABEL description="ETL pipeline for job postings"
```

Good for tracking who built what. Check with `docker inspect`.

### HEALTHCHECK — Check if Your App is Working

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

Docker periodically runs this command inside the container. If it fails 3 times, the container is marked "unhealthy." Orchestration tools (Kubernetes, Docker Compose) use this to restart containers.

## Layer Caching — Why Build Order Matters

This is one of the most important things to understand. Docker caches layers and reuses them if nothing changed. But if ANY layer changes, all subsequent layers are rebuilt.

```dockerfile
FROM python:3.11-slim
WORKDIR /app

# Layer 1: copy requirements (changes rarely)
COPY requirements.txt .

# Layer 2: install dependencies (expensive, changes rarely)
RUN pip install --no-cache-dir -r requirements.txt

# Layer 3: copy application code (changes frequently)
COPY . .

CMD ["python", "etl.py"]
```

**Why this order matters:**

When you change `etl.py`, Docker sees:
- Layer 1 (COPY requirements.txt): unchanged → **cached** ✓
- Layer 2 (pip install): unchanged → **cached** ✓ (this saves minutes!)
- Layer 3 (COPY .): changed → **rebuilt**

If you had `COPY . .` BEFORE `pip install`, changing ANY file would invalidate the pip install cache and rebuild all dependencies. Every. Single. Time.

**Rule: Put things that change less frequently EARLIER in the Dockerfile.**

## .dockerignore — Keep Garbage Out

Just like `.gitignore`, create a `.dockerignore` file to prevent unnecessary files from being copied:

```
# .dockerignore
.git
.gitignore
__pycache__
*.pyc
.env
.venv
venv
node_modules
*.md
.DS_Store
docker-compose*.yml
Dockerfile
.dockerignore
data/output/
*.duckdb
*.db
```

Without this, `COPY . .` sends EVERYTHING in your directory to Docker — including `.git`, `venv`, data files, etc. This makes builds slow and images huge.

**Always create a `.dockerignore`.** This is one of those things people forget and then wonder why their 50KB Python script produces a 2GB image.

## Real-World Dockerfile for Data Engineering

Here's a production-quality Dockerfile for a Python ETL pipeline:

```dockerfile
# ──────────────────────────────────────────────
# Production ETL Pipeline Image
# ──────────────────────────────────────────────
FROM python:3.11-slim AS base

# Prevent Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Create a non-root user
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid 1000 --create-home appuser

WORKDIR /app

# Install system dependencies (if needed for Python packages)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first (leverage layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser src/ ./src/
COPY --chown=appuser:appuser config/ ./config/

# Switch to non-root user
USER appuser

# Default command
CMD ["python", "-m", "src.main"]
```

This follows every best practice:
1. Slim base image
2. Environment variables for Python
3. Non-root user (security)
4. System deps installed and cleaned up in one layer
5. Requirements copied and installed BEFORE application code (caching)
6. `.dockerignore` keeps the build context clean
7. Explicit CMD in exec form

## Multi-Stage Builds

This is an advanced technique that produces MUCH smaller images. The idea: use one stage to BUILD (with all the build tools), then copy only the result into a clean final image.

```dockerfile
# ── Stage 1: Build ──
FROM python:3.11 AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Production ──
FROM python:3.11-slim

# Copy only the installed packages from the builder
COPY --from=builder /install /usr/local

WORKDIR /app
COPY src/ ./src/

CMD ["python", "-m", "src.main"]
```

Why? The builder stage has gcc, build tools, header files — stuff you need to compile packages but don't need at runtime. The final image only has the compiled packages and your code. Can cut image size by 50-70%.

## Build Commands

```bash
# Basic build
docker build -t my-etl:v1 .

# Build with a specific Dockerfile
docker build -f Dockerfile.prod -t my-etl:prod .

# Build with build arguments
docker build --build-arg APP_VERSION=2.0.0 -t my-etl:v2 .

# Build without using cache (force fresh build)
docker build --no-cache -t my-etl:v1 .

# Build and see all output (useful for debugging)
docker build --progress=plain -t my-etl:v1 .

# Build for a specific platform
docker build --platform linux/amd64 -t my-etl:v1 .
```

## Tagging Strategy

Tags are how you version your images. Here's what I use:

```bash
# Version tags
docker build -t my-etl:v1.0.0 .
docker build -t my-etl:v1.0.1 .

# Git SHA tags (great for CI/CD — you know exactly which code is in the image)
docker build -t my-etl:$(git rev-parse --short HEAD) .

# Environment tags
docker build -t my-etl:staging .
docker build -t my-etl:production .

# Tag an existing image with additional tags
docker tag my-etl:v1.0.0 my-etl:latest
docker tag my-etl:v1.0.0 registry.example.com/my-etl:v1.0.0
```

---

## Practice Problems

### Beginner

1. Create a Dockerfile that runs a Python script printing "Hello from Docker!". Build and run it.

2. Modify the `my-etl` Dockerfile to use `python:3.12-slim` instead of `3.11`. Rebuild and verify it works.

3. Create a `.dockerignore` file that excludes `.git`, `__pycache__`, `.env`, and `*.md`. Build an image and exec into it to verify those files are NOT inside the container.

### Intermediate

4. Write a Dockerfile for a script that:
   - Reads a CSV from a `/data` directory inside the container
   - Uses pandas to calculate basic stats
   - Prints the results
   - Uses proper layer caching (requirements before code)

5. Build the same image twice. Change only the Python script (not requirements.txt) and rebuild. Notice how pip install is cached the second time. Now move `COPY . .` before `RUN pip install` and repeat. See the difference?

6. Use `ARG` to make the Python version configurable:
   ```dockerfile
   ARG PYTHON_VERSION=3.11
   FROM python:${PYTHON_VERSION}-slim
   ```
   Build with `--build-arg PYTHON_VERSION=3.12` and verify.

### Advanced

7. Create a multi-stage Dockerfile for a Python ETL that:
   - Stage 1 (builder): installs pandas, numpy, sqlalchemy with all build deps
   - Stage 2 (final): slim image with only runtime deps
   - Compare the size of single-stage vs multi-stage images

8. Write a production-ready Dockerfile that includes:
   - Non-root user
   - Health check
   - Labels (maintainer, version)
   - Proper layer caching
   - `.dockerignore`
   - Multi-stage build
   Build it and verify the health check with `docker inspect`.

9. Create a Dockerfile for a DuckDB-based ETL:
   ```
   pip install duckdb pandas
   ```
   Write a script that creates an in-memory database, loads some data, runs a query, and exports results. Containerize it end-to-end.

---

**Up next:** [Volumes and Storage](06_Volumes_And_Storage.md) — because containers are ephemeral, but your data shouldn't be.

## Resources

- [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/) — Complete list of all instructions
- [Build Best Practices](https://docs.docker.com/build/building/best-practices/) — Official guide to writing efficient Dockerfiles
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/) — Deep dive on multi-stage patterns
- [.dockerignore Reference](https://docs.docker.com/build/building/context/#dockerignore-files) — Syntax and patterns
