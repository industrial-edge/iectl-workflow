# Set configuration variables
export HUB_USER="<hub-email>"
export HUB_API_KEY="<hub-api-key>"
export IEM_USER="<iem-email>"
export IEM_PASSWORD="<iem-password>"
export IEM_URL="https://<iem-ip>"
export IEM_NAME="<iem-name>"
export IEM_COMMON_NAME="<iem-common-name>"

# Set environmental variables 
export EDGE_SKIP_TLS=1

# Configuration for IE HUB
iectl config add iehub \
         --name "configname" \
         --loginurl "https://siemens-00035.eu.auth0.com" \
         --audience "industrialedge" \
         --url "https://iehub.eu1.edge.siemens.cloud/" \
         --user $HUB_USER \
         --password $HUB_API_KEY \
         --clientid "sylfULpmKW4A2EfRx334HPTMl1LSsA1m"

# Activate IEM in HUB 
iectl onboard onboard-iem \
           --username $IEM_USER \
           --password $IEM_PASSWORD \
           --iem-url $IEM_URL \
           --cn $IEM_COMMON_NAME \
           --name $IEM_NAME \

