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

# ─── Load Configuration ─────────────────────────────────────────────────────
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

# ─── Project Variables ──────────────────────────────────────────────────────
ONBOARDING_DIR="./onboarding-file"
ONBOARDING_FILE="$ONBOARDING_DIR/device.txt"

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

# ─── Build Optional DNS JSON Block ──────────────────────────────────────────
DNS_CONFIG_JSON=""
if [ -n "$DEVICE_DNS_PRIMARY" ] || [ -n "$DEVICE_DNS_SECONDARY" ]; then
  DNS_CONFIG_JSON=', "DNSConfig": {'
  first_dns_field=true

  if [ -n "$DEVICE_DNS_PRIMARY" ]; then
    DNS_CONFIG_JSON="$DNS_CONFIG_JSON\"PrimaryDNS\": \"$DEVICE_DNS_PRIMARY\""
    first_dns_field=false
  fi

  if [ -n "$DEVICE_DNS_SECONDARY" ]; then
    if [ "$first_dns_field" = false ]; then
      DNS_CONFIG_JSON="$DNS_CONFIG_JSON, "
    fi
    DNS_CONFIG_JSON="$DNS_CONFIG_JSON\"SecondaryDNS\": \"$DEVICE_DNS_SECONDARY\""
  fi

  DNS_CONFIG_JSON="$DNS_CONFIG_JSON}"
fi

DEVICE_BODY=$(cat <<EOF
{
  "device": {
    "onboarding": {
      "localUserName": "$DEVICE_USER",
      "localPassword": "$DEVICE_PASSWORD",
      "deviceName": "$DEVICE_NAME",
      "deviceTypeId": "$DEVICE_TYPE"
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
            $DNS_CONFIG_JSON
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

# ─── Assign label to device ─────────────────────────────────────────────────
if [ -n "$DEVICE_LABEL" ]; then
    echo "🔄 Assigning label '$DEVICE_LABEL' to device '$DEVICE_NAME'"
    sleep 2s
    echo "  ↳ Retrieving device ID for: $DEVICE_NAME..."

    deviceID=$(iectl iem device list | \
      python3 ./script/getDeviceId.py --device_name "$DEVICE_NAME")
    
    if [ -z "$deviceID" ]; then
      echo "❌ ERROR: Could not retrieve device ID for: $DEVICE_NAME"
      exit 1
    fi

    iectl iem device label allocate \
      --device-id "$deviceID" \
      --label "$DEVICE_LABEL"

    # ─── Validate Output ────────────────────────────────────────────────────────
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to assign label to the device."
        exit 1
    fi
fi

echo "✅ Device created successfully. Onboarding file available at: $ONBOARDING_FILE"
