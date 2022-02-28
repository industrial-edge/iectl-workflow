# Implementation of the scripts

- [Implementation of the scripts](#implementation-of-the-scripts)
  - [Activate IEM](#activate-iem)
  - [Onboard IED to IEM](#onboard-ied-to-iem)
    - [Create IED](#create-ied)
    - [Activate IED](#activate-ied)
  - [Deploy custom application](#deploy-custom-application)

## Activate IEM 

  ```bash
    iectl config add iehub \
         --name "configname" \
         --loginurl "https://siemens-00035.eu.auth0.com" \
         --audience "industrialedge" \
         --url "https://iehub.eu1.edge.siemens.cloud/" \
         --user $HUB_USER \
         --password $HUB_API_KEY \
         --clientid "sylfULpmKW4A2EfRx334HPTMl1LSsA1m"
  ```

  This command adds a new IE Hub configuration for connection and authentification . Options:

  * name: Configuration name
  * loginurl: OAuth Url for IE HUB login used by default for prod HUB
  * audience: Audience for IE HUB login used by default for prod HUB
  * url: IE HUB URL
  * user: Users email of the IE HUB which has granted API access
  * password: Users password of the IE HUB which has granted API access
  * clientid: Client id for IE HUB login used by default for prod HUB

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_config.html#iectl-config-add-iehub).

  ```bash
    iectl onboard onboard-iem \
           --username $IEM_USER \
           --password $IEM_PASSWORD \
           --iem-url $IEM_URL \
           --cn $IEM_COMMON_NAME \
           --name $IEM_NAME \
  ```
  This command connects to IE HUB. creates IEM instance and activate the IEM cluster creation. Options: 
  * username: Email address of the IEM admin 
  * password: Password of the IEM admin 
  * iem-url: URL with IP address of the IEM virtual machine to be activated
  * cn: Common Name for initial certificate/ca creation
  * name: Name of the IEM instance to be activated

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_onboard.html#iectl-onboard-onboard-iem).

## Onboard IED to IEM

To onboard IED(s) to IEM, you have to run 2 scripts in the right order.

### Create IED

  ```bash
    cd workspace
    iectl publisher workspace init
  ```
These commands navigate to workspace folder and initialize project workspace. If workspace is already initialize, you will get this information from the output. 

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_publisher.html#iectl-publisher-workspace-init).

  ```bash
    iectl config add iem  \
         --name "iemdev" \
         --url $IEM_URL \
         --user $IEM_USER \
         --password $IEM_PASSWORD  
  ```
This command adds a new IEM configuration for connection to your instance. Options: 
  * name: Configuration name
  * url: IEM URL to connect with. For IP based setup it requires port 9443
  * user: IEM users email address 
  * password: IEM users password

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_config.html#iectl-config-add-iem).

  ```bash
    iectl portal devices create-device --body '{"device":{"onboarding":{"localUserName":"'$DEVICE_USER'","localPassword":"'$DEVICE_PASSWORD'","deviceName":"'$DEVICE_NAME'","deviceTypeId":"core.ieipc"},"Device":{"Network":{"Interfaces":[{"MacAddress":"'$DEVICE_MAC'","GatewayInterface":true,"DHCP":"enabled","Static":{"IPv4":"","NetMask":"","Gateway":""}}]}},"ntpServers":[{"ntpServer":"0.pool.ntp.org","preferred":true}]}}' \
        > $PROJECT_PATH_PREFIX/onboarding-file/device.txt
  ```
This command creates an Edge Device within the IEM with the given configuration. It returns a JSON string which can be used for onboarding the Edge Device. Options: 
  * body: device configuration as JSON formatted data

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_portal.html#iectl-portal-devices-create-device).

### Activate IED

  ```bash
    iectl config add device \
        --name "device-config-dev" \
        --url $DEVICE_URL \
        --user $DEVICE_USER \
        --password $DEVICE_PASSWORD  
  ```
This command adds a new Edge Device configuration. Options: 
  * name: Configuration name 
  * url: Device URL before activation 
  * user: Device users email address
  * password: Device users password 

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_config.html#iectl-config-add-device).


  ```bash
    iectl ied device activate \
            --files "$PROJECT_PATH_PREFIX/onboarding-file/device.txt" 
  ```

This command activates the Edge Device and registers it to the IEM. Activating an Edge Device requires a configuration file that contains information such as username, password and Edge Device name. You can get the configuration file from the step of [creating](#create-ied) the device instance in IEM. Options: 
  * files: Configuration file previously retrieved from IEM while creating the device instance

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_ied.html#iectl-ied-device-activate).

## Deploy custom application

  ```bash
    iectl config add publisher \
      --name "publisherdev" \
      --dockerurl "http://127.0.0.1:2375" \
      --workspace "$PROJECT_PATH_PREFIX/workspace" 
  ```
This command adds new configuration for the IE App Publisher. Options: 
  * name: Configuration name 
  * dockerurl: URL for connecting to docker engine through exposed API port 
  * workspace: Path to project workspace

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_config.html#iectl-config-add-publisher).

  ```bash
    iectl publisher standaloneapp create \
            --reponame $APP_REPO \
            --appdescription "application description"  \
            --iconpath "$PROJECT_PATH_PREFIX/appicon/icon.png" \
            --appname $APP_NAME
  ```
This command creates new standalone application with provided details. In case the application exists already, you will get this information from the output information. Options: 
  * reponame: Applications repository name 
  * appdescription: Desctription for the application to be displayed in IEM
  * iconpath: Path of the applications icon
  * appname: Applications name 

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_publisher.html#iectl-publisher-standaloneapp-create).


  ```bash
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

  ```

These commands first evaluates whether the standalone application already has a version by executing a simple python script. If the application has a version, new version is created with incremented versioned number, otherwise very first version is created. After the version management, the standalone application version is created. Options: 

  * appname: Name of the application for which a new version should be created
  * changelogs: Applications release notes 
  * yamlpath: Path to docker-compose file 
  * versionnumber: Version number associated with the new version
  * n/nginxjson: JSON map of nginx configuration defining reverse proxy settings
  * -s/redirectsection: Redirect Section/Service on which to reverse proxy should be applied
  * -t/redirecttype:  Redirect Type ("FromBoxReverseProxy","FromBoxSpecificPort","ExternalLink")
  * -u/redirecturl: Redirect URL/Path where the webserver is reachable https://<IED-IP>/<redirect-url>/
  * -r/restredirecturl: Rest Redirect URL/Rest URL options to send to the container

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_publisher.html#iectl-publisher-standaloneapp-createversion).

  ```bash
    iectl publisher edgemanagement login -u $IEM_URL -e $IEM_USER -p $IEM_PASSWORD
  ```

This command connects to Edge Management with users credentials. Options:

  * -u/portalurl: IEM URL to connect to. For IP based IEM, port 9443 is needed. 
  * -e/email: IEM users email address 
  * -p/password: IEM users password

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_publisher.html#iectl-publisher-edgemanagement-login).

  ```bash
    iectl publisher edgemanagement application uploadtocatalog \
        --appname $APP_NAME \
        -w $version_new

  ```
This command uploads standalone application or .app file to IEM's catalog. Options: 

  * appname: Standalone application name to upload to catalog.

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_publisher.html#iectl-publisher-edgemanagement-application-uploadtocatalog).

  ```bash
  # Get application ID
  appID=$(iectl portal applications list-catalog | \
        python3 $PROJECT_PATH_PREFIX/script/getAppId.py --app_name $APP_NAME)  
  echo $appID

  # Get edge device ID
  deviceID=$(iectl portal devices list-devices | \
        python3 $PROJECT_PATH_PREFIX/script/getDeviceId.py --device_name $DEVICE_NAME)  
  echo $deviceID

  # Submit a batch job to install app to IED
  iectl portal batches submit-batch \
        --appid "$appID" \
        --operation "installApplication" \
        --infoMap  {"devices":["$deviceID"]}
  ```

These commands first run python scripts to get uploaded application ID and ID of an Edge device to which the application should be deployed. Then a batch job is submitted to install the application on the device. Options: 

  * appid: Application ID to which the batch job is submitted 
  * operation: The operation to perform (install, uninstall, or update)
  * infoMap:  Info Map object defining the unique Edge Device ID or other info regarding config,resourses etc. More info can be found in help

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_portal.html#iectl-portal-batches-submit-batch).