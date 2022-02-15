# IEM configuration variables 
export IEM_USER="<iem-useranme>"
export IEM_PASSWORD="<iem-password>"
export IEM_URL="https://<iem-ip>:9443"

# Device Configuration variables 
export DEVICE_NAME="<ied-name>"
export DEVICE_USER="<ied-username>"
export DEVICE_PASSWORD="<ied-pasword>"
export DEVICE_MAC="<ied-mac-adress>"


# IECTL environmental variables
export IE_SKIP_CERTIFICATE=true
export EDGE_SKIP_TLS=1

cd workspace
iectl publisher workspace init

# IEM Configuration 
iectl config add iem  \
         --name "iemdev" \
         --url $IEM_URL \
         --user $IEM_USER \
         --password $IEM_PASSWORD  

rm -rfv /home/siemens/iemctl-region-call/onboarding-file/*

# Creating edge device in IEM
iectl portal devices create-device --body '{"device":{"onboarding":{"localUserName":"'$DEVICE_USER'","localPassword":"'$DEVICE_PASSWORD'","deviceName":"'$DEVICE_NAME'","deviceTypeId":"core.ieipc"},"Device":{"Network":{"Interfaces":[{"MacAddress":"'$DEVICE_MAC'","GatewayInterface":true,"DHCP":"enabled","Static":{"IPv4":"","NetMask":"","Gateway":""}}]}},"ntpServers":[{"ntpServer":"0.pool.ntp.org","preferred":true}]}}' \
        > /home/siemens/iemctl-region-call/onboarding-file/device.txt
