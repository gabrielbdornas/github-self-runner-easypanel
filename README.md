# GitHub Self-Hosted Runner for EasyPanel

A reusable GitHub Actions self-hosted runner designed to run inside an EasyPanel Process.

The project automatically:

* Installs the GitHub Actions Runner.
* Registers the runner with GitHub.
* Persists the runner installation across restarts.
* Installs additional system packages required by workflows.
* Starts the runner automatically.
* Supports repository and organization runners.
* Is fully configurable through environment variables.

## Architecture

```text
GitHub Repository
        │
        ▼
EasyPanel Process
        │
        ▼
setup.sh
  ├── Install dependencies
  ├── Create runner user
  ├── Install GitHub Runner
  └── Register runner
        │
        ▼
start.sh
  └── Start runner
        │
        ▼
GitHub Actions Jobs
```

## EasyPanel Configuration

Create an EasyPanel Box service and enable the following Modules:

- Git.
- Mounts.
- Environment.
- Processes.


## Git (Repository)

Connect the service to this repository using `https` protocol.

EasyPanel clones the repository into:

```text
/code
```

## Mounts

We need a persistent volume. Create a volume mounted at:

```text
/home/runner/actions-runner
```

This allows:

- Runner installation to persist.
- Runner registration to persist.
- Faster restarts.
- No need to download the runner over and over again.

## Environment Variables

Create environment variables as suggested in `.env.example` file.

## Process Command

Configure one EasyPanel Process command as:

- Name: start.
- Command: `chmod +x setup.sh start.sh && ./setup.sh && exec ./start.sh`.
- Directory: `/code`.

## Updating the Runner

Update:

```env
RUNNER_VERSION=2.335.0
```

Remove the existing installation:

```bash
rm -rf /home/runner/actions-runner
```

Restart the EasyPanel Process.

The new version will be installed automatically.

# License

MIT License
