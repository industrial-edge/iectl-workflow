#!/bin/bash
set -e  # Stop the script if any command fails

# ─────────────────────────────────────────────────────────────────────────────
# standalone-app.sh
#
# Description: Creates an application in Industrial Edge Publisher, publishes
#              it to the Industrial Edge Manager (IEM) catalog, and installs
#              it on a target Industrial Edge Device (IED).
#
# Prerequisites:
#   - iectl must be installed and available in PATH
#   - Docker must be running and accessible at http://127.0.0.1:2375
#   - Valid IEM credentials and a reachable IEM URL
#   - App icon must exist at ./appicon/icon.png
#   - docker-compose.prod.yml must exist at ./app/docker-compose.prod.yml
#   - Python scripts must exist at ./script/
#
# Flow:
#   Phase 1 — Environment Setup:    Configure publisher and IEM connections
#   Phase 2 — Application Build:    Create application and version in publisher
#   Phase 3 — Publish to IEM:       Upload application to IEM catalog
#   Phase 4 — Deploy to IED:        Install application on target device
#
# Usage: sh standalone-app.sh
# ─────────────────────────────────────────────────────────────────────────────

# ─── IEM Configuration Variables ─────────────────────────────────────────────
export IEM_USER="<iem-username>"          # IEM username
export IEM_PASSWORD="<iem-password>"      # IEM password
export IEM_URL="<iem-url>"    # IEM URL

# ─── Device Configuration Variables ──────────────────────────────────────────
export DEVICE_NAME="<ied-name>"        # Target Edge device name

# ─── Application Configuration Variables ─────────────────────────────────────
export APP_NAME="<application-name>"      # Application name
export APP_REPO="<application-repo>"      # Application repository (must be unique)

# ─── IECTL Environment Variables ─────────────────────────────────────────────
export IE_SKIP_CERTIFICATE=true           # Skip certificate check (trusted environments only!)
export EDGE_SKIP_TLS=1                    # Disable TLS verification

# ═════════════════════════════════════════════════════════════════════════════
# PHASE 1 — Environment Setup
# Configure the publisher and IEM connections before any operation
# ═════════════════════════════════════════════════════════════════════════════

echo "⚙️  [Phase 1/4] Setting up environment..."

echo "  ↳ Creating publisher configuration..."

iectl config add publisher \
  --name "publisherdev" \
  --dockerurl "http://127.0.0.1:2375" \
  --workspace "./workspace"

echo "  ↳ Initializing workspace..."

iectl publisher workspace init

echo "  ↳ Creating IEM configuration..."

iectl config add iem \
  --name "iemdev" \
  --url "$IEM_URL" \
  --user "$IEM_USER" \
  --password "$IEM_PASSWORD"

echo "✅ Environment setup complete."

# ═════════════════════════════════════════════════════════════════════════════
# PHASE 2 — Application Build
# Create the application and its version in the publisher
# ═════════════════════════════════════════════════════════════════════════════

echo "🔨 [Phase 2/4] Building application..."

echo "  ↳ Creating application: $APP_NAME..."

iectl publisher standalone-app create \
  --reponame "$APP_REPO" \
  --appdescription "application description" \
  --iconpath "./appicon/icon.png" \
  --appname "$APP_NAME"

echo "  ↳ Resolving version number..."

version=$(iectl publisher standalone-app version list \
  --appname "$APP_NAME" \
  -k "versionNumber" | \
  python3 ./script/getAppVersion.py)

version_new=$(echo "$version" | awk -F. -v OFS=. \
  'NF==1{print ++$NF};
   NF>1{if(length($NF+1)>length($NF))$(NF-1)++;
   $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')

echo "  ↳ Creating application version: $version_new..."

iectl publisher standalone-app version create \
  --appname "$APP_NAME" \
  --changelogs "initial release" \
  --yamlpath "./app/docker-compose.prod.yml" \
  --versionnumber "$version_new" \
  -n '{"hello-edge":[{"name":"hello-edge","protocol":"HTTP","port":"80","headers":"","rewriteTarget":"/"}]}' \
  -s "hello-edge" \
  -t "FromBoxReverseProxy" \
  -u "hello-edge" \
  -r "/"

echo "✅ Application build complete. Version: $version_new"

# ═════════════════════════════════════════════════════════════════════════════
# PHASE 3 — Publish to IEM
# Upload the application to the IEM catalog and retrieve its assigned ID
# ═════════════════════════════════════════════════════════════════════════════

echo "🚀 [Phase 3/4] Publishing application to IEM..."

echo "  ↳ Uploading $APP_NAME v$version_new to IEM catalog..."

iectl publisher app-project upload catalog \
  --appname "$APP_NAME" \
  -v "$version_new"

echo "  ↳ Retrieving application ID from catalog..."

appID=$(iectl iem catalog list | \
  python3 ./script/getAppId.py --app_name "$APP_NAME")

if [ -z "$appID" ]; then
  echo "❌ ERROR: Could not retrieve application ID for: $APP_NAME"
  exit 1
fi

echo "✅ Application published to IEM. App ID: $appID"

# ═════════════════════════════════════════════════════════════════════════════
# PHASE 4 — Deploy to IED
# Locate the target device and install the application on it
# ═════════════════════════════════════════════════════════════════════════════

echo "📦 [Phase 4/4] Deploying application to IED..."

echo "  ↳ Retrieving device ID for: $DEVICE_NAME..."

deviceID=$(iectl iem device list | \
  python3 ./script/getDeviceId.py --device_name "$DEVICE_NAME")

if [ -z "$deviceID" ]; then
  echo "❌ ERROR: Could not retrieve device ID for: $DEVICE_NAME"
  exit 1
fi

echo "  ↳ Submitting installation job to device: $DEVICE_NAME..."

iectl iem job batch-create \
  --appid "$appID" \
  --operation "installApplication" \
  --infoMap "{\"devices\":[\"$deviceID\"]}"

echo "✅ Deployment job submitted successfully!"
echo ""
echo "════════════════════════════════════════════"
echo "  ✅ All phases completed successfully!"
echo "  📦 App:     $APP_NAME v$version_new"
echo "  🖥️  Device:  $DEVICE_NAME"
echo "════════════════════════════════════════════"