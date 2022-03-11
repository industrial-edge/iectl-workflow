# Set configuration variables
export HUB_USER="<hub-email>" # Email of the user with API access granted
export HUB_API_KEY="<hub-api-key>" # HUB API key
export IEM_USER="<iem-email>" # Email adress of the IEM user
export IEM_PASSWORD="<iem-password>" # Password of the IEM user
export IEM_URL="https://<iem-ip>" # IP adress of the IEM before activating (Use without port 9443)
export IEM_NAME="<iem-name>" # Name of your IEM instance
export IEM_COMMON_NAME="<iem-common-name>" # IEM common name

# Set environmental variables 
export EDGE_SKIP_TLS=1

# Configuration for IE HUB
iectl config add iehub \
         --name "configname" \
         --url "https://iehub.eu1.edge.siemens.cloud/" \
         --user $HUB_USER \
         --password $HUB_API_KEY

# Activate IEM in HUB 
iectl onboard onboard-iem \
           --username $IEM_USER \
           --password $IEM_PASSWORD \
           --iem-url $IEM_URL \
           --cn $IEM_COMMON_NAME \
           --name $IEM_NAME \

