#!/bin/bash
set -e  # Stop the script if any command fails

# ─────────────────────────────────────────────────────────────────────────────
# create-ied.sh
#
# Description: Creates a new Industrial Edge Device (IED) in the Industrial
#              Edge Manager (IEM) and generates the onboarding file (device.txt)
#              required to activate the device.
#
# Prerequisites:
#   - iectl must be installed and available in PATH
#   - Valid IEM credentials and a reachable IEM URL
#   - The onboarding directory (./onboarding-file) must be writable
#
# Output:
#   - ./onboarding-file/device.txt  → Used by activate-ied.sh to activate the device
#
# Next Step:
#   - Run activate-ied.sh to complete the device activation
#
# Usage: sh create-ied.sh
# ─────────────────────────────────────────────────────────────────────────────

# ─── IEM Configuration Variables ───────────────────────────────────────────
export IEM_USER="<iem-username>"        # Email address of the IEM user
export IEM_PASSWORD="<iem-password>"    # Password of the IEM user
export IEM_URL="<iem-url>"              # IEM URL

# ─── Device Configuration Variables ────────────────────────────────────────
export DEVICE_NAME="<ied-name>"         # Name of your Edge device
export DEVICE_USER="<ied-email>"        # Email address of the device user
export DEVICE_PASSWORD="<ied-pasword>"  # Password of the device user
export DEVICE_MAC="<ied-mac-adress>"    # Edge devie MAC address

# ─── IECTL Environment Variables ───────────────────────────────────────────
export IE_SKIP_CERTIFICATE=true
export EDGE_SKIP_TLS=1

# ─── Project Variables ──────────────────────────────────────────────────────
export ONBOARDING_DIR="./onboarding-file"
export ONBOARDING_FILE="$ONBOARDING_DIR/device.txt"

# ─── Prepare Output Directory ──────────────────────────────────────────────
mkdir -p "$ONBOARDING_DIR"
rm -f "$ONBOARDING_FILE"

# ─── Configure IEM ─────────────────────────────────────────────────────────
iectl config add iem \
    --name "iemdev" \
    --url "$IEM_URL" \
    --user "$IEM_USER" \
    --password "$IEM_PASSWORD"

# ─── Build Device JSON Body ─────────────────────────────────────────────────
DEVICE_BODY=$(cat <<EOF
{
  "device": {
    "onboarding": {
      "localUserName": "$DEVICE_USER",
      "localPassword": "$DEVICE_PASSWORD",
      "deviceName": "$DEVICE_NAME",
      "deviceTypeId": "core.ieipc"
    },
    "Device": {
      "Network": {
        "Interfaces": [
          {
            "MacAddress": "$DEVICE_MAC",
            "GatewayInterface": true,
            "DHCP": "enabled",
            "Static": {
              "IPv4": "",
              "NetMask": "",
              "Gateway": ""
            }
          }
        ]
      }
    },
    "ntpServers": [
      {
        "ntpServer": "0.pool.ntp.org",
        "preferred": true
      }
    ]
  }
}
EOF
)

# ─── Create Device in IEM ───────────────────────────────────────────────────
echo "🔄 Creating device '$DEVICE_NAME' in IEM..."
iectl iem device create --body "$DEVICE_BODY" > "$ONBOARDING_FILE"

# ─── Validate Output ────────────────────────────────────────────────────────
if [ ! -s "$ONBOARDING_FILE" ]; then
    echo "❌ Error: The onboarding file was not generated correctly."
    exit 1
fi

echo "✅ Device created successfully. Onboarding file available at: $ONBOARDING_FILE"