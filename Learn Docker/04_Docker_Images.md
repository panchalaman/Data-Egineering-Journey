# Docker Images — How They Actually Work

Images are the foundation of everything in Docker. You've already used a few (`nginx`, `ubuntu`, `python`), but now let's understand what they actually are, how they're built, and why they're so efficient.

## What Is an Image, Really?

An image is a **stack of read-only layers**. Each layer represents a change — a file added, a package installed, a config modified. Docker stacks these layers on top of each other to create the final filesystem.

```
Image: python:3.11

┌─────────────────────────────┐
│  Layer 4: Set CMD python3   │  ← What runs when container starts
├─────────────────────────────┤
│  Layer 3: Install Python    │  ← Python binaries + pip
├─────────────────────────────┤
│  Layer 2: Install OS deps   │  ← Build tools, SSL, etc.
├─────────────────────────────┤
│  Layer 1: Debian base       │  ← Minimal Debian filesystem
└─────────────────────────────┘
```

Why layers? Because they're **shared and cached**. If you have 10 containers all using `python:3.11`, the base layers are stored once on disk and shared across all of them. Docker only stores what's different.

This is why pulling an image the second time is instant — you already have most of the layers from other images.

## Finding Images

### Docker Hub

[Docker Hub](https://hub.docker.com/) is the default registry — like GitHub for container images. Some images you'll use constantly in data engineering:

| Image | What It Is | Pull Command |
|-------|-----------|-------------|
| `python` | Python runtime | `docker pull python:3.11` |
| `postgres` | PostgreSQL database | `docker pull postgres:16` |
| `apache/airflow` | Apache Airflow | `docker pull apache/airflow:2.9.0` |
| `apache/spark` | Apache Spark | `docker pull apache/spark:3.5.0` |
| `dbt-labs/dbt-core` | dbt | `docker pull ghcr.io/dbt-labs/dbt-core:latest` |
| `redis` | Redis cache | `docker pull redis:7` |
| `ubuntu` | Ubuntu base | `docker pull ubuntu:22.04` |
| `alpine` | Tiny Linux (~5MB) | `docker pull alpine:3.19` |

### Official vs Community Images

On Docker Hub, you'll see two types:

- **Official images** — Maintained by Docker and the upstream project. They have no username prefix: `python`, `postgres`, `nginx`. Always prefer these.
- **Community images** — Created by users or organizations. They have a prefix: `bitnami/postgresql`, `apache/airflow`. Check the download count and when it was last updated before trusting one.

### Searching from CLI

```bash
docker search postgres
```

This lists images matching "postgres" from Docker Hub. I usually just browse Docker Hub in a browser though — the CLI search is basic.

## Image Tags

Tags are versions. They tell you exactly which variant of an image you're getting.

```bash
docker pull python:3.11        # Python 3.11.x
docker pull python:3.11.8      # Python 3.11.8 specifically
docker pull python:3.11-slim   # Smaller version, fewer OS packages
docker pull python:3.11-alpine # Even smaller, uses Alpine Linux
docker pull python:latest      # Whatever the latest version is
```

### The `latest` Trap

**Never use `latest` in production.** Here's why:

`latest` isn't a fixed version — it's just the default tag that points to whatever's newest. If you deploy with `python:latest` today and your colleague deploys next month, you might get different Python versions. Your pipeline breaks and nobody knows why.

Always pin specific versions:

```bash
# Bad — could change at any time
docker pull python:latest

# Good — this will always be the same
docker pull python:3.11.8

# Also good — minor version pinning (gets patch updates)
docker pull python:3.11

# Good for slim images
docker pull python:3.11-slim
```

### Understanding Tag Variants

Most images offer multiple variants:

| Tag Pattern | What It Means | Size | Use When |
|-------------|--------------|------|----------|
| `3.11` | Full Debian-based | ~900MB | You need OS-level packages (most common) |
| `3.11-slim` | Minimal Debian | ~120MB | You want smaller images without sacrificing compatibility |
| `3.11-alpine` | Alpine Linux based | ~50MB | You want the smallest possible image |
| `3.11-bookworm` | Specific Debian release | ~900MB | You need a specific Debian version |

For data engineering, I usually go with `-slim`. Alpine can cause issues with Python packages that need compiled C extensions (like pandas, numpy) because Alpine uses `musl` instead of `glibc`.

## Managing Local Images

### List Downloaded Images

```bash
docker images
# or
docker image ls
```

Output:
```
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
python       3.11      a1b2c3d4e5f6   2 weeks ago    914MB
nginx        latest    b2c3d4e5f6a7   3 weeks ago    187MB
postgres     16        c3d4e5f6a7b8   1 week ago     432MB
```

### Remove an Image

```bash
docker rmi python:3.11
# or
docker image rm python:3.11
```

You can't remove an image if a container (even a stopped one) is using it. Remove the container first.

### Remove All Unused Images

```bash
docker image prune
```

This removes "dangling" images (layers that aren't tagged and aren't used by any container).

Nuclear option — remove ALL unused images:

```bash
docker image prune -a
```

Be careful with this. It removes everything not currently used by a running container. You'll have to re-pull images next time.

### Check Disk Usage

```bash
docker system df
```

This shows how much space images, containers, and volumes are using. Docker can eat up disk space fast. I check this weekly.

## Image Layers in Detail

Let's look at the layers of an image:

```bash
docker history python:3.11
```

Output shows each layer, its size, and the command that created it. This is useful for understanding why an image is so big.

### Pulling and Layer Caching

Watch what happens when you pull related images:

```bash
# Pull Python 3.11
docker pull python:3.11
# ...downloads several layers...

# Now pull Python 3.11-slim
docker pull python:3.11-slim
# Some layers say "Already exists" — they share base layers!
```

Docker deduplicates at the layer level. If two images share a Debian base, that base is stored once.

## Inspecting Images

```bash
docker inspect python:3.11
```

Useful fields:
```bash
# See the default command
docker inspect --format '{{.Config.Cmd}}' python:3.11

# See exposed ports
docker inspect --format '{{.Config.ExposedPorts}}' nginx

# See environment variables baked into the image
docker inspect --format '{{.Config.Env}}' postgres:16

# See the image's total size
docker inspect --format '{{.Size}}' python:3.11
```

## Saving and Loading Images

Need to move an image to a machine without internet? (This happens in air-gapped environments.)

```bash
# Save to a tar file
docker save -o python-3.11.tar python:3.11

# Load on another machine
docker load -i python-3.11.tar
```

## How Images Relate to Containers

This is important to internalize:

```
Image (read-only layers)         Container (image + writable layer)

┌─────────────────────┐         ┌─────────────────────┐
│                     │         │  Writable layer     │ ← Your changes go here
│  Layer 3 (python)   │         ├─────────────────────┤
│  Layer 2 (deps)     │    ──>  │  Layer 3 (python)   │   (read-only, shared)
│  Layer 1 (debian)   │         │  Layer 2 (deps)     │
│                     │         │  Layer 1 (debian)   │
└─────────────────────┘         └─────────────────────┘
```

When a container writes a file, it goes to the **writable layer** on top. The image layers below are never modified. This is called **Copy-on-Write (CoW)**.

That's why:
- Creating containers is instant (no copying)
- Changes inside containers don't affect the image
- When you remove a container, only the writable layer is deleted

## Image Naming Convention

Full image name format:

```
registry/namespace/repository:tag

Examples:
docker.io/library/python:3.11          # Full form of "python:3.11"
docker.io/apache/airflow:2.9.0         # Apache Airflow
ghcr.io/dbt-labs/dbt-core:1.7          # dbt on GitHub Container Registry
123456789.dkr.ecr.us-east-1.amazonaws.com/my-etl:v2.1  # Private AWS ECR
```

When you just write `python:3.11`, Docker expands it to `docker.io/library/python:3.11`.

---

## Practice Problems

### Beginner

1. Pull `postgres:16`, `postgres:16-alpine`, and `python:3.11-slim`. Compare their sizes with `docker images`. Which is smallest? Why?

2. Run `docker history nginx` and identify which layer is the largest. What does that layer do?

3. Pull `python:3.11` and `python:3.12`. How many layers do they share? (Hint: watch the "Already exists" messages during pull)

### Intermediate

4. Find the official Apache Airflow image on Docker Hub. What tags are available? Which one would you use for a production pipeline and why?

5. Run `docker system df` and note the total space used. Pull 5 different images, then check again. Now run `docker image prune -a` and check once more to see the cleanup.

6. Use `docker inspect` to find the default command, exposed ports, and environment variables of the `postgres:16` image. What does the `POSTGRES_USER` default to?

### Advanced

7. Pull `python:3.11`, `python:3.11-slim`, and `python:3.11-alpine`. For each, run a container and try: `pip install pandas numpy`. Which one succeeds? Which one fails? Why? What does this tell you about choosing base images for data engineering?

8. Save the `python:3.11-slim` image to a tar file. Check its size. What are scenarios in data engineering where you'd need to use `docker save/load`?

---

**Up next:** [Building Images with Dockerfiles](05_Building_Images.md) — this is where Docker gets really powerful for data engineering.

## Resources

- [Docker Hub](https://hub.docker.com/) — Browse and search for images
- [Docker Image Best Practices](https://docs.docker.com/build/building/best-practices/) — Official guide on choosing and using images
- [Understanding Image Layers](https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/) — Deep dive from Docker docs
