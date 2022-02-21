# Implementation of the scripts

- [Implementation of the scripts](#implementation-of-the-scripts)
  - [Activate IEM](#activate-iem)

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

  This command adds a new IE Hub configuration. Options:

  * name: Configuration name
  * loginurl: OAuth Url for IE HUB login used by default for prod HUB
  * audience: Audience for IE HUB login used by default for prod HUB
  * url: IE HUB URL
  * user: Users email of the IE HUB which has granted API access
  * password: Users password of the IE HUB which has granted API access
  * clientid: Client id for IE HUB login used by default for prod HUB

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_config.html#iectl-config-add-iehub)

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

More information about this command can be found [here](https://industrial-edge.io/developer/platform/references/iectl/docs/iectl_onboard.html#iectl-onboard-onboard-iem)
