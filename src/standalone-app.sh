# IEM configuration variables 
export IEM_USER="<iem-username>"
export IEM_PASSWORD="<iem-password>"
export IEM_URL="https://<iem-ip>:9443"

# Device Configuration variables 
export DEVICE_NAME="<device-name>"

# Application configuration variables
export APP_NAME="<application-name>"
export APP_REPO="<application-repository>"

# IECTL environmental variables
export IE_SKIP_CERTIFICATE=true
export EDGE_SKIP_TLS=1

# Project envirinmental variables 
export PROJECT_PATH_PREFIX="<project-path-prefix>"


echo "---------------------------Creating publisher configuration---------------------------"
iectl config add publisher \
    --name "publisherdev" \
    --dockerurl "http://127.0.0.1:2375" \
    --workspace "$PROJECT_PATH_PREFIX/workspace" 

echo "---------------------------Initializing workspace---------------------------"
cd workspace
iectl publisher workspace init

echo "---------------------------Creating application---------------------------"
iectl publisher standaloneapp create \
            --reponame $APP_REPO \
            --appdescription "application description"  \
            --iconpath "$PROJECT_PATH_PREFIX/appicon/icon.png" \
            --appname $APP_NAME

echo "---------------------------Creating application version---------------------------"
# Version managment 
version=$(iectl publisher sa lv -a $APP_NAME -k "versionNumber" | \
        python3 $PROJECT_PATH_PREFIX/script/getAppVersion.py)

version_new=$(echo $version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
echo 'new Version: '$version_new

iectl publisher standaloneapp createversion \
            --appname $APP_NAME \
            --changelogs "initial release" \
            --yamlpath "$PROJECT_PATH_PREFIX/app/docker-compose.prod.yml" \
            --versionnumber $version_new \
            -n '{"hello-edge":[{"name":"hello-edge","protocol":"HTTP","port":"80","headers":"","rewriteTarget":"/"}]}' \
            -s "hello-edge" \
            -t "FromBoxReverseProxy" \
            -u "hello-edge" \
            -r "/"

echo "---------------------------Creating IEM configuration---------------------------"
iectl config add iem  \
         --name "iemdev" \
         --url $IEM_URL \
         --user $IEM_USER \
         --password $IEM_PASSWORD  

iectl publisher edgemanagement login -u $IEM_URL -e $IEM_USER -p $IEM_PASSWORD

echo "---------------------------Uploading app to IEM---------------------------"
iectl publisher edgemanagement application uploadtocatalog \
        --appname $APP_NAME \
        -w $version_new


echo "---------------------------Deploying app to IED---------------------------"
# Get application ID
appID=$(iectl portal applications list-catalog | \
        python3 $PROJECT_PATH_PREFIX/script/getAppId.py --app_name $APP_NAME)  
echo $appID

# Get edge device ID
deviceID=$(iectl portal devices list-devices | \
        python3 $PROJECT_PATH_PREFIX/script/getDeviceId.py --device_name $DEVICE_NAME)  
echo $deviceID

# SUbmit a batch job to install app to IED
iectl portal batches submit-batch \
        --appid "$appID" \
        --operation "installApplication" \
        --infoMap  {"devices":["$deviceID"]}