# Implementation of the scripts

- [Implementation of the scripts](#implementation-of-the-scripts)
  - [Onboard IED to IEM](#onboard-ied-to-iem)
    - [Create IED](#create-ied)
    - [Activate IED](#activate-ied)
  - [Deploy custom application](#deploy-custom-application)

## Onboard IED to IEM

To onboard IED(s) to IEM, you have to run 2 scripts in the right order.

### Create IED

  ```bash
    iectl config add iem  \
         --name "iemdev" \
         --url "$IEM_URL" \
         --user "$IEM_USER" \
         --password "$IEM_PASSWORD"
  ```
This command adds a new IEM configuration for connection to your instance. Options: 
  * name: Configuration name
  * url: IEM URL to connect with.
  * user: IEM users email address 
  * password: IEM users password

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/config/add/iectl-config-add-iem).

  ```bash
    iectl iem device create --body "$DEVICE_BODY" > "$ONBOARDING_FILE"
  ```
This command creates an Edge Device within the IEM with the given configuration. It returns a JSON string which can be used for onboarding the Edge Device. Options: 
  * body: device configuration as JSON formatted data

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/iem/device/iectl-iem-device-create).

### Activate IED

  ```bash
    iectl config add ied \
        --name "device-config-dev" \
        --url "$DEVICE_URL" \
        --user "$DEVICE_USER" \
        --password "$DEVICE_PASSWORD"
  ```
This command adds a new Edge Device configuration. Options: 
  * name: Configuration name 
  * url: Device URL before activation 
  * user: Device users email address
  * password: Device users password 

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/config/add/iectl-config-add-ied).

  ```bash
    iectl ied system activate \
            --files "./onboarding-file/device.txt"
  ```

This command activates the Edge Device and registers it to the IEM. Activating an Edge Device requires a configuration file that contains information such as username, password and Edge Device name. You can get the configuration file from the step of [creating](#create-ied) the device instance in IEM. Options: 
  * files: Configuration file previously retrieved from IEM while creating the device instance

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/ied/system/iectl-ied-system-activate).

## Deploy custom application

  ```bash
    iectl config add publisher \
      --name "publisherdev" \
      --dockerurl "http://127.0.0.1:2375" \
      --workspace "./workspace" 
  ```
This command adds new configuration for the IE App Publisher. Options: 
  * name: Configuration name 
  * dockerurl: URL for connecting to docker engine through exposed API port 
  * workspace: Path to project workspace

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/config/add/iectl-config-add-publisher).

  ```bash
    iectl publisher workspace init
  ```
These commands navigate to workspace folder and initialize project workspace. If workspace is already initialize, you will get this information from the output. 

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/publisher/workspace/iectl-publisher-workspace-init).

  ```bash
    iectl publisher standalone-app create \
            --reponame "$APP_REPO" \
            --appdescription "application description"  \
            --iconpath "./appicon/icon.png" \
            --appname "$APP_NAME"
  ```
This command creates new standalone application with provided details. In case the application exists already, you will get this information from the output information. Options: 
  * reponame: Applications repository name 
  * appdescription: Desctription for the application to be displayed in IEM
  * iconpath: Path of the applications icon
  * appname: Applications name 

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/publisher/standalone-app/iectl-publisher-standalone-app-create).


  ```bash
    version=$(iectl publisher standalone-app version list \
        --appname "$APP_NAME" \
        -k "versionNumber" | \
        python3 ./script/getAppVersion.py)

    version_new=$(echo "$version" | awk -F. -v OFS=. \
        'NF==1{print ++$NF};
        NF>1{if(length($NF+1)>length($NF))$(NF-1)++;
        $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')

    iectl publisher standalone-app version create \
        --appname "$APP_NAME" \
        --changelogs "initial release" \
        --yamlpath "./app/docker-compose.prod.yml" \
        --versionnumber "$version_new" \
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

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/publisher/standalone-app/version/iectl-publisher-standalone-app-version-create).

  ```bash
    iectl publisher app-project upload catalog \
        --appname "$APP_NAME" \
        -v "$version_new"

  ```
This command uploads standalone application or .app file to IEM's catalog. Options: 

  * appname: Standalone application name to upload to catalog.

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/publisher/app-project/upload/iectl-publisher-app-project-upload-catalog).

  ```bash
  # Get application ID
  appID=$(iectl iem catalog list | \
        python3 ./script/getAppId.py --app_name "$APP_NAME")

  # Get edge device ID
  deviceID=$(iectl iem device list | \
        python3 ./script/getDeviceId.py --device_name "$DEVICE_NAME")

  # Submit a batch job to install app to IED
  iectl iem job batch-create \
        --appid "$appID" \
        --operation "installApplication" \
        --infoMap "{\"devices\":[\"$deviceID\"]}"
  ```

These commands first run python scripts to get uploaded application ID and ID of an Edge device to which the application should be deployed. Then a batch job is submitted to install the application on the device. Options: 

  * appid: Application ID to which the batch job is submitted 
  * operation: The operation to perform (install, uninstall, or update)
  * infoMap:  Info Map object defining the unique Edge Device ID or other info regarding config,resourses etc. More info can be found in help

More information about this command can be found [here](https://docs.industrial-operations-x.siemens.cloud/r/en-us/v26.01/industrial-edge-platform-operation-apis-references/industrial-edge-control-iectl/all-commands/iem/job/iectl-iem-job-batch-create).