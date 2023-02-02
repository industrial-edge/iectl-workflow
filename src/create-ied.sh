# IEM configuration variables 
export IEM_USER="<iem-username>" # Email address of the IEM user
export IEM_PASSWORD="<iem-password>" # Password of the IEM user
export IEM_URL="https://<iem-ip>:9443" # IEM URL with port 9443

# Device Configuration variables 
export DEVICE_NAME="<ied-name>" # Name of your Edge device
export DEVICE_USER="<ied-email>" # Email address of the device user
export DEVICE_PASSWORD="<ied-pasword>" # Password of the device user
export DEVICE_MAC="<ied-mac-adress>" # Edge devie MAC address


# IECTL environmental variables
export IE_SKIP_CERTIFICATE=true
export EDGE_SKIP_TLS=1

# Project environmental variables 
export PROJECT_PATH_PREFIX="<project-path-prefix>" # Prefix of the absolute path where the project is inside of your development environment


cd workspace
iectl publisher workspace init

# IEM Configuration 
iectl config add iem  \
         --name "iemdev" \
         --url $IEM_URL \
         --user $IEM_USER \
         --password $IEM_PASSWORD  

rm -rfv $PROJECT_PATH_PREFIX/onboarding-file/*

# Creating edge device in IEM
iectl iem device create --body '{"device":{"onboarding":{"localUserName":"'$DEVICE_USER'","localPassword":"'$DEVICE_PASSWORD'","deviceName":"'$DEVICE_NAME'","deviceTypeId":"core.ieipc"},"Device":{"Network":{"Interfaces":[{"MacAddress":"'$DEVICE_MAC'","GatewayInterface":true,"DHCP":"enabled","Static":{"IPv4":"","NetMask":"","Gateway":""}}]}},"ntpServers":[{"ntpServer":"0.pool.ntp.org","preferred":true}]}}' \
        > $PROJECT_PATH_PREFIX/onboarding-file/device.txt
