#!/bin/bash
set -e  # Stop the script if any command fails

# ─────────────────────────────────────────────────────────────────────────────
# deploy-app.sh
#
# Description: installs a published application from the IEM catalog onto the
#              target Industrial Edge Device (IED) using iectl.
#
# Prerequisites:
#   - iectl must be installed and available in PATH
#   - Valid IEM credentials and a reachable IEM URL
#   - Python scripts must exist at ./script/
#   - App id must be known and set in .env file
#   - Possible prerequisites of the App must be met before running this script
#
# Usage: sh deploy-app.sh
# ─────────────────────────────────────────────────────────────────────────────

# ─── Load Configuration ──────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ ERROR: Configuration file not found: $ENV_FILE"
  echo "   Copy .env.example to .env and fill in your values."
  exit 1
fi
set -a
# shellcheck source=.env
. "$ENV_FILE"
set +a

echo "📦 Deploying application to IED..."

echo -n "  ↳ Retrieving device ID for: $DEVICE_NAME:"

deviceID=$(iectl iem device list --size 100 | \
  python3 ./script/getDeviceId.py --device_name "$DEVICE_NAME")

if [ -z "$deviceID" ]; then
  echo "❌ ERROR: Could not retrieve device ID for: $DEVICE_NAME"
  exit 1
fi
echo " $deviceID"

echo "  ↳ Submitting installation job to device: $DEVICE_NAME..."
RESULT=$(iectl iem job batch-create \
  --appid "$APP_ID" \
  --operation "installApplication" \
  --infoMap "{\"devices\":[\"$deviceID\"]}")

echo "✅ Deployment job submitted successfully!"
