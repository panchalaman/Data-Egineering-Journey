# Installing Docker

Let's get Docker running on your machine. This is a one-time setup that takes about 10 minutes.

## macOS

### Option 1: Docker Desktop (Recommended for Beginners)

Docker Desktop gives you Docker Engine + a nice GUI + Docker Compose + Kubernetes, all in one package.

1. Go to [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Download the version for your chip:
   - **Apple Silicon (M1/M2/M3/M4)** — most newer Macs
   - **Intel** — older Macs
3. Open the `.dmg` file and drag Docker to Applications
4. Launch Docker from Applications
5. Wait for the whale icon 🐳 to appear in the menu bar — that means it's running

### Option 2: Colima (Lightweight Alternative)

If you don't want the heavy Docker Desktop app (it uses ~2GB of RAM), Colima is a lightweight alternative that runs Docker in a minimal Linux VM:

```bash
# Install via Homebrew
brew install colima docker docker-compose

# Start Colima (this creates a lightweight VM)
colima start

# Verify
docker --version
docker compose version
```

I personally use Colima because it's lighter and doesn't need a GUI. But Docker Desktop is totally fine for learning — pick whatever feels easier.

## Linux (Ubuntu/Debian)

```bash
# Update packages
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to the docker group (so you don't need sudo every time)
sudo usermod -aG docker $USER

# Log out and back in for the group change to take effect
# Then verify:
docker --version
```

## Windows

1. Make sure **WSL 2** is installed. Open PowerShell as admin:
   ```powershell
   wsl --install
   ```
   Restart your machine if prompted.

2. Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)

3. During installation, make sure "Use WSL 2 instead of Hyper-V" is checked

4. Open a terminal (PowerShell or WSL) and verify:
   ```bash
   docker --version
   ```

## Verify Your Installation

Run these commands to make sure everything works:

```bash
# Check Docker version
docker --version
# Should show something like: Docker version 27.x.x

# Check Docker Compose version
docker compose version
# Should show something like: Docker Compose version v2.x.x

# Run the hello-world test container
docker run hello-world
```

That last command does a LOT behind the scenes:
1. Docker looks for the `hello-world` image locally — doesn't find it
2. Pulls it from Docker Hub (the default registry)
3. Creates a container from that image
4. Runs the container, which prints a message
5. Container exits

If you see "Hello from Docker!" in the output, you're good. That's your first container! 🎉

## Docker Desktop Quick Tour (If You Installed It)

Open Docker Desktop and you'll see:

- **Containers** — Running and stopped containers
- **Images** — Downloaded images on your machine
- **Volumes** — Persistent data storage
- **Settings** — Resource limits (CPU, RAM allocated to Docker)

One important setting: go to **Settings → Resources** and make sure Docker has enough RAM. For data engineering work (running Postgres, Airflow, etc.), I'd recommend at least **4GB**, ideally **6-8GB**.

## Useful Config Tweaks

### Set Default Platform (Apple Silicon Users)

If you're on an M-series Mac, some images don't have ARM builds yet. Add this to your `~/.zshrc`:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

This tells Docker to use x86 images via emulation when ARM images aren't available. It's slower but prevents "platform mismatch" errors.

### Enable BuildKit (Faster Builds)

BuildKit is Docker's improved build engine. It's usually on by default now, but make sure:

```bash
export DOCKER_BUILDKIT=1
```

Add this to your `~/.zshrc` too.

## Troubleshooting

**"Cannot connect to the Docker daemon"**
Docker Engine isn't running. Start Docker Desktop, or if using Colima: `colima start`

**"permission denied" on Linux**
You forgot to add yourself to the docker group. Run:
```bash
sudo usermod -aG docker $USER
```
Then log out and back in.

**"no matching manifest for linux/arm64"**
You're on Apple Silicon trying to pull an x86-only image. Add `--platform linux/amd64` to your docker run/pull command, or set the `DOCKER_DEFAULT_PLATFORM` env var.

**Docker Desktop is using too much RAM**
Go to Settings → Resources and lower the memory limit. 4GB is the minimum for comfortable data engineering work.

---

You're all set. Let's actually use Docker now.

**Up next:** [Your First Container](03_Your_First_Container.md) — we'll run, stop, inspect, and manage containers.

## Resources

- [Docker Desktop Installation Guide](https://docs.docker.com/desktop/) — Official docs with platform-specific details
- [Colima GitHub](https://github.com/abiosoft/colima) — If you prefer the lightweight CLI approach
- [Post-install Steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/) — Important Linux-specific config
