# Device Configuration variables 
export DEVICE_USER="<ied-username>" # User name of the Edge device
export DEVICE_PASSWORD="<ied-password>" # Password for the Edge device
export DEVICE_URL="<ied-url>" # Edge device URL before onboarding


# IECTL environmental variables
export IE_SKIP_CERTIFICATE=true # Skips certificate check - do this in trusted environment only!
export EDGE_SKIP_TLS=1 # Disable TLS verification

# Project environmental variables 
export PROJECT_PATH_PREFIX="<project-path-prefix>" # Prefix of the absolute path where the project is inside of your development environment

cd workspace
iectl publisher workspace init

# Creating Edge Device configuration 
iectl config add device \
        --name "device-config-dev" \
        --url $DEVICE_URL \
        --user $DEVICE_USER \
        --password $DEVICE_PASSWORD  

# Activating device in IEM
iectl ied device activate \
            --files "$PROJECT_PATH_PREFIX/onboarding-file/device.txt" 