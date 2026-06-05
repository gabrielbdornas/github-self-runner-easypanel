#!/bin/bash
set -eux

RUNNER_VERSION="${RUNNER_VERSION:-2.334.0}"
RUNNER_DIR="${RUNNER_DIR:-/home/runner/actions-runner}"
RUNNER_USER="${RUNNER_USER:-runner}"

REQUIRED_PACKAGES="curl tar git"
OPTIONAL_PACKAGES="${SYSTEM_PACKAGES:-make}"

PACKAGES=(
  $REQUIRED_PACKAGES
  $OPTIONAL_PACKAGES
)

echo "Checking system dependencies..."

MISSING_PACKAGES=()

for package in "${PACKAGES[@]}"; do
  if ! command -v "$package" >/dev/null 2>&1; then
    MISSING_PACKAGES+=("$package")
  fi
done

if [ "${#MISSING_PACKAGES[@]}" -gt 0 ]; then
  echo "Installing missing packages: ${MISSING_PACKAGES[*]}"
  apt-get update
  apt-get install -y "${MISSING_PACKAGES[@]}"
else
  echo "All required packages are already installed."
fi

echo "Checking runner user..."

if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  useradd -m "$RUNNER_USER"
fi

echo "Checking runner installation..."

mkdir -p "$RUNNER_DIR"

if [ ! -f "$RUNNER_DIR/config.sh" ]; then
  echo "Installing GitHub Actions Runner v${RUNNER_VERSION}..."

  curl -o /tmp/actions-runner-linux-x64.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

  tar xzf /tmp/actions-runner-linux-x64.tar.gz -C "$RUNNER_DIR"

  rm -f /tmp/actions-runner-linux-x64.tar.gz
else
  echo "GitHub Actions Runner is already installed."
fi

chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"

cd "$RUNNER_DIR"

echo "Checking GitHub runner registration..."

if [ ! -f ".runner" ]; then

  su "$RUNNER_USER" -c "
    ./config.sh \
      --url '$REPO_URL' \
      --token '$REGISTRATION_TOKEN' \
      --name '$RUNNER_NAME' \
      --labels '$RUNNER_LABELS' \
      --unattended \
      --replace \
      --disableupdate
  "

else
  echo "Runner is already registered."
fi

echo "Setup completed successfully."
