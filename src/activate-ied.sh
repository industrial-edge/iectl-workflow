# Device Configuration variables 
export DEVICE_USER="<ied-username>"
export DEVICE_PASSWORD="<ied-password>"
export DEVICE_URL="<ied-url>"


# IECTL environmental variables
export IE_SKIP_CERTIFICATE=true
export EDGE_SKIP_TLS=1

# Project envirinmental variables 
export PROJECT_PATH_PREFIX="<project-path-prefix>"

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