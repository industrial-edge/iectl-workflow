# Industrial Edge Control

Industrial Edge Control (IECTL) is a command line tool that enables you to interact with APIs of Industrial Edge components using just commands. This document describes how to use IECTL to automate workflow from provisioning IEM, onboarding Edge Devices to automatically deploying Edge applications. More information about the tool as well as the official documentation can be found [here](https://industrial-edge.io/developer/platform/references/iectl/index.html).

- [Industrial Edge Control](#industrial-edge-control)
  - [Description](#description)
    - [Overview](#overview)
    - [General task](#general-task)
  - [Requirements](#requirements)
    - [Prerequisites](#prerequisites)
    - [Used Components](#used-components)
  - [Installation](#installation)
  - [Implementation](#implementation)
  - [Documentation](#documentation)
  - [Contribution](#contribution)
  - [License and Legal Information](#license-and-legal-information)
  - [Disclaimer](#disclaimer)

## Description

### Overview

This application example shows how to install and use IECTL in a complete workflow to automatically setup Edge components in 3 steps:

  1. Activate IEM
  2. Onboard Edge device
  3. Deploy Edge applications

### General task
The main goal of this example is to show how to setup the Industrial Edge platform in an automated workflow using IECTL. The idea is to provide with several shell scripts which can be adjusted and executed from a development environment to provision Industrial Edge components. This application example follows the network structure displayed in the picture below. The workflow starts with activating IEM in IE HUB, continues with automatic onboarding of one Edge Device and finally custom application is uploaded and deployed to the newly onboarded device. The provided shell scripts can be used and scaled for multiple IEMs, IEDs or applications. Please note that IP based IEM is used in this example and for DNS based setup the steps may differ.

<img src="./docs/graphics/network-setup.PNG"/>

## Requirements

### Prerequisites

- All Components are connected to a network with DHCP server available
- All components have an IP address
- IEM has connection to IE HUB
- IP based IEM is used in this example
- Linux Device with Docker and docker compose installed

### Used Components

- Industrial Edge HUB
- Industrial Edge Management App v1.4.11
- Industrial Edge Management OS v1.4.0-42-amd64
- Industrial Edge Device v1.3.0-57
- Ubuntu 20.04 as development environment
- Industrial Edge Control (IECTL) for Linux v2.0.3

## Installation

The installation steps can be found [here](docs/installation.md).
The installation consist of following steps: 
* [Activating IEM](docs/installation.md#activate-iem)
* [Onboarding IED](docs/installation.md#onboard-edge-devices)
* [Deploying self developed app](docs/installation.md#deploy-custom-application)

## Implementation

The description of the implemented commands in the scripts can be found [here](./docs/Implementation.md).

## Documentation
 
- You can find further documentation and help in the following links
  - [Industrial Edge Hub](https://iehub.eu1.edge.siemens.cloud/#/documentation)
  - [Industrial Edge Forum](https://forum.mendix.com/link/space/industrial-edge)
  - [Industrial Edge landing page](https://new.siemens.com/global/en/products/automation/topic-areas/industrial-edge/simatic-edge.html)
  - [Industrial Edge GitHub page](https://github.com/industrial-edge)
  - [Industrial Edge documentation page](https://docs.eu1.edge.siemens.cloud/index.html)
  
## Contribution

Thank you for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section.
Additionally everybody is free to propose any changes to this repository using Pull Requests.

If you haven't previously signed the [Siemens Contributor License Agreement](https://cla-assistant.io/industrial-edge/) (CLA), the system will automatically prompt you to do so when you submit your Pull Request. This can be conveniently done through the CLA Assistant's online platform. Once the CLA is signed, your Pull Request will automatically be cleared and made ready for merging if all other test stages succeed.

## License and Legal Information

Please read the [Legal information](LICENSE.txt).

## Disclaimer

IMPORTANT - PLEASE READ CAREFULLY:

This documentation describes how you can download and set up containers which consist of or contain third-party software. By following this documentation you agree that using such third-party software is done at your own discretion and risk. No advice or information, whether oral or written, obtained by you from us or from this documentation shall create any warranty for the third-party software. Additionally, by following these descriptions or using the contents of this documentation, you agree that you are responsible for complying with all third party licenses applicable to such third-party software. All product names, logos, and brands are property of their respective owners. All third-party company, product and service names used in this documentation are for identification purposes only. Use of these names, logos, and brands does not imply endorsement.
