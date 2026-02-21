# Docker Networking

Containers are isolated by default. A Python container can't just "see" a PostgreSQL container running next to it. They need a network to communicate. Understanding Docker networking is critical for data engineering because your pipelines almost always talk to at least one database, message queue, or API.

## The Default Bridge Network

When you install Docker, it creates three networks automatically:

```bash
docker network ls
```

```
NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local
f6e5d4c3b2a1   host      host      local
9876543210ab   none      null      local
```

| Network | What It Does |
|---------|------------|
| **bridge** | Default network. Containers can reach the internet but not each other by name. |
| **host** | Container uses the host's network directly. No isolation. |
| **none** | No networking at all. Complete isolation. |

When you `docker run` without specifying a network, containers go on the default `bridge` network. The problem? Containers on the default bridge can't reach each other by name. They can only communicate by IP address, which changes every time a container restarts.

## User-Defined Bridge Networks

This is what you actually want to use. Create your own network and containers on it can find each other by NAME, not just IP.

```bash
# Create a network
docker network create my-pipeline

# Run postgres on the network
docker run -d \
    --name pipeline-db \
    --network my-pipeline \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB=warehouse \
    postgres:16

# Run python on the SAME network
docker run --rm -it \
    --network my-pipeline \
    python:3.11-slim \
    python -c "
import socket
# This resolves! Docker provides DNS within user-defined networks
ip = socket.gethostbyname('pipeline-db')
print(f'PostgreSQL is at: {ip}')
"
```

The Python container can reach PostgreSQL using the hostname `pipeline-db` (which is the container name). Docker runs an internal DNS server that resolves container names to their IPs within user-defined networks.

### Connecting From Your Python Code

```python
import psycopg2  # or sqlalchemy, or whatever

# Inside a container on the same network, use container name as host
conn = psycopg2.connect(
    host="pipeline-db",     # <-- container name, NOT localhost
    port=5432,
    dbname="warehouse",
    user="postgres",
    password="secret"
)
```

This is one of the most important things to understand: inside Docker networks, `localhost` means "this container", not "the host machine". Use the container's NAME as the hostname.

## How Container DNS Works

```
┌─────────────────────────────────────┐
│        Network: my-pipeline         │
│                                     │
│  ┌──────────┐     ┌──────────────┐  │
│  │ python   │     │ pipeline-db  │  │
│  │ app      │────>│ (postgres)   │  │
│  │          │     │              │  │
│  └──────────┘     └──────────────┘  │
│                                     │
│  Docker DNS: pipeline-db → 172.18.0.2  │
│  Docker DNS: python-app  → 172.18.0.3  │
└─────────────────────────────────────┘
```

Docker maintains a DNS server for each user-defined network. When a container says "connect to pipeline-db", Docker resolves it to the container's IP on that network. If a container restarts and gets a new IP, Docker updates the DNS automatically. That's why you use names, not IPs.

## Network Commands

```bash
# Create a network
docker network create data-net

# List networks
docker network ls

# Inspect a network (see which containers are on it)
docker network inspect data-net

# Connect a running container to a network
docker network connect data-net my-container

# Disconnect a container from a network
docker network disconnect data-net my-container

# Remove a network (must have no containers attached)
docker network rm data-net

# Remove all unused networks
docker network prune
```

### Connecting a Container to Multiple Networks

A container can be on more than one network. This is useful for security — only expose what needs to be exposed.

```bash
docker network create frontend
docker network create backend

# API server needs to talk to both the frontend and the database
docker run -d --name api --network frontend my-api
docker network connect backend api

# Database only on backend (not exposed to frontend)
docker run -d --name db --network backend postgres:16
```

Now:
- `api` can talk to `db` (both on `backend`)
- `api` can receive requests from the frontend
- Nothing on `frontend` can reach `db` directly

## Port Mapping

Port mapping exposes a container's port to the host machine. This is how you access services running in containers from your browser or local tools.

```bash
# Map host port 5432 to container port 5432
docker run -d -p 5432:5432 postgres:16

# Map a different host port (useful when 5432 is already in use)
docker run -d -p 5433:5432 postgres:16

# Bind to localhost only (more secure — not accessible from other machines)
docker run -d -p 127.0.0.1:5432:5432 postgres:16

# Map multiple ports
docker run -d -p 8080:8080 -p 5555:5555 airflow-webserver
```

The format is `-p HOST_PORT:CONTAINER_PORT`:
- **HOST_PORT**: the port on your machine
- **CONTAINER_PORT**: the port inside the container

Important: port mapping is for host-to-container communication. Container-to-container communication on the same network doesn't need port mapping at all. Containers can reach each other on any port directly through the network.

```
  Your Machine (Host)
  ┌──────────────────────────────────────┐
  │                                      │
  │  localhost:5432  ──────────────────┐  │
  │                                   │  │
  │  ┌───────────────────────────────┐│  │
  │  │      Docker Network          ││  │
  │  │                              ││  │
  │  │  ┌────────┐   ┌──────────┐   ││  │
  │  │  │ Python │──>│ Postgres │<──┘│  │
  │  │  │ :8000  │   │ :5432    │    │  │
  │  │  └────────┘   └──────────┘    │  │
  │  │    (no port      (port        │  │
  │  │     mapping)      mapped)     │  │
  │  └──────────────────────────────┘│  │
  └──────────────────────────────────────┘
```

The Python container talks to Postgres over the Docker network (no port mapping needed). Port mapping is only so YOU can reach Postgres from your host machine (like using DBeaver or psql).

## Host Networking

On Linux, you can use `--network host` to skip Docker's network isolation entirely. The container uses the host's network stack directly.

```bash
docker run --network host my-app
```

- Container's ports are directly on the host (no `-p` needed)
- Faster (no NAT overhead)
- Less secure (no isolation)
- Only works on Linux (on macOS, Docker runs in a VM so host networking behaves differently)

Rarely used in production, but useful for benchmarking or when you need maximum network performance.

## Real-World DE Network Setup

Here's a typical data engineering development setup:

```bash
# Create the network
docker network create de-pipeline

# Start PostgreSQL (data warehouse)
docker run -d \
    --name warehouse \
    --network de-pipeline \
    -e POSTGRES_PASSWORD=warehouse_pass \
    -e POSTGRES_DB=warehouse \
    -v warehouse-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:16

# Start Redis (job queue / caching)
docker run -d \
    --name redis \
    --network de-pipeline \
    redis:7-alpine

# Run your ETL script
docker run --rm \
    --network de-pipeline \
    -v $(pwd):/app \
    -w /app \
    my-etl:latest \
    python etl.py
```

Inside `etl.py`:

```python
import psycopg2
import redis

# These hostnames work because all containers are on "de-pipeline"
db = psycopg2.connect(host="warehouse", dbname="warehouse",
                       user="postgres", password="warehouse_pass")
cache = redis.Redis(host="redis", port=6379)
```

Notice:
- Postgres has `-p 5432:5432` so you can connect from DBeaver on your machine
- Redis does NOT have port mapping — only accessible from within the Docker network
- The ETL container uses `--rm` — it runs, does its job, and cleans up

## Common Networking Mistakes

### 1. Using `localhost` Inside Containers

```python
# WRONG — localhost inside a container means "this container"
conn = psycopg2.connect(host="localhost", port=5432, ...)

# RIGHT — use the container name
conn = psycopg2.connect(host="warehouse", port=5432, ...)
```

### 2. Forgetting the Network Flag

```bash
# These containers CAN'T communicate by name
docker run -d --name db postgres:16
docker run -d --name app my-app

# Fix: put them on the same user-defined network
docker run -d --name db --network my-net postgres:16
docker run -d --name app --network my-net my-app
```

### 3. Port Conflicts

```bash
# This fails if port 5432 is already in use on your machine
docker run -p 5432:5432 postgres:16

# Use a different host port
docker run -p 5433:5432 postgres:16
# Connect from host: psql -h localhost -p 5433
```

### 4. Container-to-Container with Port Mapping

```bash
# You DON'T need port mapping for container-to-container
# If both are on the same network, they can talk directly

# Don't do this:
docker run --name db -p 5432:5432 --network my-net postgres:16
# And then connect from another container using localhost:5432

# Instead, just use the container name:
# host="db", port=5432 (container's internal port)
```

---

## Practice Problems

### Beginner

1. Create a user-defined network called `test-net`. Run two Alpine containers on it. From one container, ping the other by name. (Hint: `docker exec container1 ping container2`)

2. Run a PostgreSQL container with port mapping `-p 5433:5432`. Connect to it from your host machine using `psql -h localhost -p 5433 -U postgres`. Then remove the container.

3. Run `docker network inspect bridge` and `docker network inspect` on a user-defined network. Compare the output — what's different?

### Intermediate

4. Set up this architecture:
   - A PostgreSQL container named `db` on network `backend`
   - A Python container on network `backend` that connects to `db` and creates a table
   - Verify that a container NOT on `backend` cannot reach `db`

5. Create a "multi-tier" setup:
   - Network `frontend` and network `backend`
   - Container `api` connected to BOTH networks
   - Container `db` connected to `backend` only
   - Prove that `api` can reach `db` but a container on `frontend`-only cannot

6. Run two PostgreSQL containers on the same host, both needing port 5432 internally. Map them to different host ports (5432 and 5433). Connect to each from your machine.

### Advanced

7. Build a mini data pipeline:
   - Create a network called `pipeline`
   - Run PostgreSQL (`source-db`) and another PostgreSQL (`target-db`) on it
   - Write a Python script that reads from `source-db` and writes to `target-db`
   - Run the Python script in a container on the same network
   - This simulates an EL (Extract-Load) pipeline running entirely in Docker

8. Set up a container that acts as a reverse proxy (nginx) routing to two different backend services by name. This shows how DNS-based service discovery works in Docker.

---

**Up next:** [Docker Compose](08_Docker_Compose.md) — because manually creating networks and running `docker run` with 10 flags for every container is not sustainable.

## Resources

- [Docker Networking Overview](https://docs.docker.com/engine/network/) — Official networking guide
- [Bridge Networks](https://docs.docker.com/engine/network/drivers/bridge/) — Default vs user-defined bridges
- [Container Networking Model](https://docs.docker.com/engine/network/) — Deep dive into Docker's networking architecture
