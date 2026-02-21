# Your First Container

Time to actually run things. This lesson covers the core commands you'll use every single day with Docker. By the end, managing containers will feel as natural as `cd` and `ls`.

## Running Your First Real Container

Let's run something useful — an Nginx web server:

```bash
docker run -d -p 8080:80 --name my-web nginx
```

Now open [http://localhost:8080](http://localhost:8080) in your browser. You should see the Nginx welcome page.

**Let's break down every flag:**

| Flag | What It Does |
|------|-------------|
| `docker run` | Create and start a container |
| `-d` | Run in **detached** mode (background) — gives you your terminal back |
| `-p 8080:80` | **Port mapping** — map YOUR machine's port 8080 to the container's port 80 |
| `--name my-web` | Give the container a human-readable name (otherwise Docker assigns a random one) |
| `nginx` | The image to use |

Think of `-p 8080:80` like this: traffic arrives at your laptop on port 8080, Docker forwards it to port 80 inside the container where Nginx is listening.

## Essential Container Commands

These are the commands you'll use constantly. Learn these first.

### See Running Containers

```bash
docker ps
```

Output looks like:
```
CONTAINER ID   IMAGE   COMMAND                  CREATED          STATUS          PORTS                  NAMES
a1b2c3d4e5f6   nginx   "/docker-entrypoint.…"   2 minutes ago    Up 2 minutes    0.0.0.0:8080->80/tcp   my-web
```

### See ALL Containers (Including Stopped)

```bash
docker ps -a
```

Stopped containers still exist on disk. They're just not running. This catches people off guard — you can accumulate hundreds of stopped containers without realizing it.

### Stop a Container

```bash
docker stop my-web
```

This sends a `SIGTERM` signal (graceful shutdown). The container has 10 seconds to clean up, then Docker force-kills it.

### Start a Stopped Container

```bash
docker start my-web
```

### Restart a Container

```bash
docker restart my-web
```

### Remove a Container

```bash
docker rm my-web
```

You can't remove a running container. Stop it first, or force-remove:

```bash
docker rm -f my-web
```

### Remove ALL Stopped Containers

```bash
docker container prune
```

I run this regularly to clean up. Stopped containers waste disk space.

## Interactive Containers

Not every container runs a server. Sometimes you want to jump INSIDE a container and poke around. This is incredibly useful for debugging.

### Run an Interactive Container

```bash
docker run -it ubuntu bash
```

You're now inside an Ubuntu container with a bash shell. Try:

```bash
cat /etc/os-release    # Yep, it's Ubuntu
ls /                   # Look at the filesystem
whoami                 # You're root by default
apt update             # You can install packages
exit                   # Leave the container
```

**Flags:**
- `-i` = Interactive (keep STDIN open)
- `-t` = Allocate a pseudo-TTY (gives you a proper terminal)
- `-it` = Almost always used together

When you `exit`, the container stops. Because the main process (bash) has ended.

### Exec Into a Running Container

What if a container is already running and you want to get a shell inside it?

```bash
# Start nginx again
docker run -d --name my-web nginx

# Get a shell inside the RUNNING container
docker exec -it my-web bash
```

`docker exec` runs a NEW process inside an existing container. The container keeps running even after you `exit` the exec session.

This is the #1 debugging technique: something's wrong in your container? `docker exec` in and look around.

```bash
# Inside the container:
cat /etc/nginx/nginx.conf    # Check the config
ls /usr/share/nginx/html/    # See the web files
curl localhost                # Test from inside
exit
```

### Quick One-Off Commands

You don't always need a shell. Run a single command:

```bash
docker exec my-web cat /etc/nginx/nginx.conf
```

No `-it` needed for non-interactive commands.

## Viewing Logs

Containers write their output to stdout/stderr, and Docker captures it.

```bash
# View logs
docker logs my-web

# Follow logs in real-time (like tail -f)
docker logs -f my-web

# Last 50 lines
docker logs --tail 50 my-web

# Logs with timestamps
docker logs -t my-web
```

In data engineering, logs are how you debug failed pipeline runs. Get comfortable reading them.

## Inspecting Containers

Want to know everything about a container? IP address, environment variables, volumes, config?

```bash
docker inspect my-web
```

This dumps a huge JSON blob. Filter it with `--format`:

```bash
# Get the container's IP address
docker inspect --format '{{.NetworkSettings.IPAddress}}' my-web

# Get environment variables
docker inspect --format '{{.Config.Env}}' my-web

# Get the container's status
docker inspect --format '{{.State.Status}}' my-web
```

## Resource Usage

See how much CPU, memory, and I/O your containers are using:

```bash
docker stats
```

This is a live dashboard. Press `Ctrl+C` to exit.

For a one-shot view:

```bash
docker stats --no-stream
```

## Container Lifecycle

Here's the full picture of a container's life:

```
docker create  ──>  Created
                       │
docker start   ──>  Running  ◄──  docker restart
                       │                │
docker stop    ──>  Stopped  ──────────┘
                       │
docker rm      ──>  Removed (gone forever)
```

`docker run` = `docker create` + `docker start` in one command. That's why most people just use `run`.

## Automatic Cleanup

Tired of cleaning up stopped containers? Use `--rm`:

```bash
docker run --rm -it ubuntu bash
```

When this container stops, Docker automatically removes it. I use `--rm` for all throwaway containers.

## Naming Conventions

Random names like `brave_babbage` are funny but useless. Always name your containers:

```bash
docker run -d --name postgres-dev postgres
docker run -d --name airflow-web apache/airflow
docker run -d --name etl-runner my-etl-image
```

In data engineering, I usually follow this pattern:
- `{service}-{environment}` — like `postgres-dev`, `airflow-staging`
- Or `{project}-{service}` — like `pipeline-db`, `pipeline-worker`

## Running a Python Script in a Container

This is closer to what you'll actually do in data engineering. Let's run a Python script without installing Python on your machine:

```bash
# Run Python in a container
docker run --rm -it python:3.11 python -c "print('Hello from a container!')"

# Run a Python shell
docker run --rm -it python:3.11 python

# Run a script from your machine inside the container
docker run --rm -v $(pwd):/app -w /app python:3.11 python my_script.py
```

That last one is powerful:
- `-v $(pwd):/app` mounts your current directory into the container at `/app`
- `-w /app` sets the working directory inside the container to `/app`
- Now the container can see and run your local files

Don't worry about `-v` (volumes) too much yet — we'll cover that in detail in Lesson 06.

## Clean Up

Let's clean up everything from this lesson:

```bash
# Stop and remove our nginx container
docker rm -f my-web

# Remove all stopped containers
docker container prune -f

# See what's left
docker ps -a
```

---

## Practice Problems

### Beginner

1. Run an `alpine` container interactively (`docker run --rm -it alpine sh`). Alpine is a tiny Linux distro (~5MB). Inside it:
   - Check the OS version: `cat /etc/os-release`
   - List running processes: `ps aux`
   - Create a file: `echo "hello" > /tmp/test.txt`
   - Exit and run the same container again. Is the file still there? Why or why not?

2. Run Nginx on port 3000 instead of 8080. Verify by opening `http://localhost:3000`.

3. Run three separate Nginx containers named `web-1`, `web-2`, and `web-3` on ports 8081, 8082, and 8083 respectively. List them all with `docker ps`. Stop and remove them all.

### Intermediate

4. Run a PostgreSQL container:
   ```bash
   docker run -d --name my-postgres -e POSTGRES_PASSWORD=mysecret -p 5432:5432 postgres:16
   ```
   Then exec into it and run a SQL query:
   ```bash
   docker exec -it my-postgres psql -U postgres -c "SELECT version();"
   ```

5. Run a Python 3.11 container, install pandas inside it, and run a quick script:
   ```bash
   docker run --rm -it python:3.11 bash
   # Inside: pip install pandas && python -c "import pandas; print(pandas.__version__)"
   ```
   Notice: when you exit and re-run the container, pandas is gone. Why? (Hint: container filesystem is ephemeral)

### Advanced

6. Run a container in the background, watch its logs in real-time, then stop it gracefully:
   ```bash
   docker run -d --name log-test busybox sh -c "while true; do echo 'heartbeat: '$(date); sleep 2; done"
   docker logs -f log-test
   # In another terminal: docker stop log-test
   ```
   Observe how long it takes to stop. Then try `docker rm -f` and compare.

7. Use `docker stats` to compare resource usage between running `nginx`, `postgres`, and `python:3.11 sleep infinity`. Which uses the most memory? Why?

---

**Up next:** [Docker Images](04_Docker_Images.md) — understanding layers, tags, and how images actually work.

## Resources

- [Docker Run Reference](https://docs.docker.com/reference/cli/docker/container/run/) — Every flag you can pass to `docker run`
- [Docker CLI Cheat Sheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf) — Print this and keep it nearby
- [Docker Container Lifecycle](https://docs.docker.com/get-started/docker-concepts/running-containers/) — Official guide on container states
