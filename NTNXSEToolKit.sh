#!/bin/bash

#Team 6 Tech Summit 2017
#Nutanix Cluster Management script
#Choose Menu options for various cluster functions
#REST API and Calm.IO REST API is used for various functions


#content-type
CT="Content-Type:application/json"

#login info
USER="admin"
PASSWD="nutanix/4u"
CALM_USER="marka"
CALM_PASS="Nutanix/4u"

#URL
SERVICE_URL="https://10.68.69.102:9440/api/nutanix/v2.0"
CALM_URL="http://10.68.69.2/public/api/1/default/blueprints/run"
RESPONSE_CODE="%{http_code}\n"

#resources
RES_VM="/vms/"
RES_SC="/storage_containers/"
RES_IM="/images/"
RES_NET="/networks/"
RES_CLU="/cluster"
RES_HC="/health_checks/"
RES_HOSTS="/hosts/"
DSIP="10.68.69.79"

#response code
STATUS=$(curl --write-out $RESPONSE_CODE --insecure -s --output /dev/null -H $CT -X GET -u $USER:$PASSWD "$SERVICE_URL$RES_VM")
echo $STATUS
echo
echo







#--------------------------
OIFS=$IFS  # Save the current IFS (Internal Field Seperator)
IFS=','
### STOP ARRAY BREAKING ON SPACES
### Start Array breaking on commas

function show_hosts {
  echo
  echo "Showing Hosts"
  echo
  #Get a list of Hosts
  HOSTList=$(curl --insecure -s -H $CT -X GET -u $USER:$PASSWD "$SERVICE_URL$RES_HOSTS" -H 'cache-control: no-cache' | jq -r .entities[].name)
  echo "-------------- Host List --------------"
  echo $HOSTList
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function show_containers {
  echo
  echo "Showing Containers"
  echo
  #Get a list of Storage Containers
  SCList=$(curl --insecure -s -H $CT -X GET -u $USER:$PASSWD "$SERVICE_URL$RES_SC" -H 'cache-control: no-cache' | jq -r .entities[].name)
  echo "-------------- Storage Container List --------------"
  echo $SCList
  echo
  echo
	read -p "Press any key to continue..." -n1 -s
	clear
}

function show_vms {
  echo
  echo "Showing VMs"
  echo
  #Get a list of VMs
  VMlist=$(curl --insecure -s -H $CT -X GET -u $USER:$PASSWD "$SERVICE_URL$RES_VM" | jq -r .entities[].name)
  echo "-------------- VM List --------------"
  echo $VMlist
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

#function show_ip_addresses {
#	echo "No IPs BOOoooo"
#  echo
#  echo
#  read -p "Press any key to continue..." -n1 -s
#	clear
#}

function gather_task_and_health {
  echo
  echo "Displaying Cluster Health Check."
  echo
  #cluster health check
  GET_HealthCheck=$(curl --insecure -s -H $CT -X GET -u $USER:$PASSWD "$SERVICE_URL$RES_HC" -H 'cache-control: no-cache' | jq '.entities[] .name')
  echo "-------------- Healthcheck List --------------"
  echo $GET_HealthCheck
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function change_container_variables {
    echo
    echo "Enable Inline Compression on Container"
    echo
    #Change options on a storage container
    CHG_SC=$(curl --insecure -s -H $CT -X PUT -u $USER:$PASSWD "$SERVICE_URL$RES_SC" -d '{"id": "00054e93-16d8-0e87-7a49-001fc69be34b::2299","storage_container_uuid": "e785953e-bdaa-423e-9a44-85afbe4febaa","name": "ISOs","cluster_uuid": "00054e93-16d8-0e87-7a49-001fc69be34b","on_disk_dedup": "NONE","compression_enabled": true,"compression_delay_in_secs": 0}')
    echo "------------- Enabling Inline Compression --------------"
    echo $CHG_SC
    echo
    echo "Success"
    echo
    echo
    read -p "Press any key to continue..." -n1 -s
  	clear
}

function create_new_network {
  echo
  echo "Creating a New AHV Network"
  echo
  #add a network in AHV
  ADD_NETWORK=$(curl --insecure -s -H $CT -X POST -u $USER:$PASSWD "$SERVICE_URL$RES_NET" -H "cache-control: no-cache" -d '{"name": "DMZ2","vlan_id": "47"}')
  echo "-------------- Adding Network to AHV --------------"
  echo $ADD_NETWORK
  echo
  echo "Network added successfully!"
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function add_data_services_ip {
  echo
  echo "Adding External Data Services IP"
  echo
  #add data services IP to cluster
  ADD_DSIP=$(curl --insecure -s -H $CT -X PUT -u $USER:$PASSWD "$SERVICE_URL$RES_CLU" -H 'cache-control: no-cache'  -d '{"name": "MUHA","cluster_external_data_services_ipaddress": "10.68.69.79"}')
  echo "-------------- Updating Data Services IP for Cluster --------------"
  echo $ADD_DSIP
  echo
  echo "IP updated successfully to " $DSIP
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function create_one_centos_rest {
  echo
  echo "Creating One CentOS VM using REST APIs"
  echo
  #deploy a CentOS VM using the REST api
  ADD_VM=$(curl --insecure -s -H $CT -X POST -u $USER:$PASSWD "$SERVICE_URL$RES_VM" -H 'cache-control: no-cache' -d '{ "name": "team6-1", "memory_mb": 1024, "num_vcpus": 1, "description": "", "num_cores_per_vcpu": 1, "vm_disks": [ { "is_cdrom": true, "is_empty": true, "disk_address": { "device_bus": "ide" } }, { "is_cdrom": false, "disk_address": { "device_bus": "scsi" }, "vm_disk_clone": { "disk_address": { "vmdisk_uuid": "04d98a9b-e635-4b21-aa21-04da8ac0d1a3" }, "minimum_size": 21474836480 } } ], "vm_nics": [ { "network_uuid": "694baac4-8462-45f0-9ef4-cbeba2dc56b2" } ], "hypervisor_type": "ACROPOLIS", "affinity": null, "vm_customization_config": { "userdata": "#cloud-config\nhostname: team6-1\nfqdn: team6-1.example.com\nbootcmd:\n - yum update -y", "files_to_inject_list": [] }}')
  echo "-------------- Creating new VM with Guest Customization --------------"
  echo $ADD_VM
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function create_two_centos_rest {
  echo
  echo "Creating 2 CentOS VMs using REST APIs"
  echo
  #deploy a CentOS VM using the REST api
  ADD_VM=$(curl --insecure -s -H $CT -X POST -u $USER:$PASSWD "$SERVICE_URL$RES_VM" -H 'cache-control: no-cache' -d '{ "name": "team6-2", "memory_mb": 1024, "num_vcpus": 1, "description": "", "num_cores_per_vcpu": 1, "vm_disks": [ { "is_cdrom": true, "is_empty": true, "disk_address": { "device_bus": "ide" } }, { "is_cdrom": false, "disk_address": { "device_bus": "scsi" }, "vm_disk_clone": { "disk_address": { "vmdisk_uuid": "04d98a9b-e635-4b21-aa21-04da8ac0d1a3" }, "minimum_size": 21474836480 } } ], "vm_nics": [ { "network_uuid": "694baac4-8462-45f0-9ef4-cbeba2dc56b2" } ], "hypervisor_type": "ACROPOLIS", "affinity": null, "vm_customization_config": { "userdata": "#cloud-config\nhostname: team6-1\nfqdn: team6-1.example.com\nbootcmd:\n - yum update -y", "files_to_inject_list": [] }}')
  echo "-------------- Creating First VM with Guest Customization --------------"
  echo
  echo $ADD_VM
  echo
  ADD_VM=$(curl --insecure -s -H $CT -X POST -u $USER:$PASSWD "$SERVICE_URL$RES_VM" -H 'cache-control: no-cache' -d '{ "name": "team6-3", "memory_mb": 1024, "num_vcpus": 1, "description": "", "num_cores_per_vcpu": 1, "vm_disks": [ { "is_cdrom": true, "is_empty": true, "disk_address": { "device_bus": "ide" } }, { "is_cdrom": false, "disk_address": { "device_bus": "scsi" }, "vm_disk_clone": { "disk_address": { "vmdisk_uuid": "04d98a9b-e635-4b21-aa21-04da8ac0d1a3" }, "minimum_size": 21474836480 } } ], "vm_nics": [ { "network_uuid": "694baac4-8462-45f0-9ef4-cbeba2dc56b2" } ], "hypervisor_type": "ACROPOLIS", "affinity": null, "vm_customization_config": { "userdata": "#cloud-config\nhostname: team6-1\nfqdn: team6-1.example.com\nbootcmd:\n - yum update -y", "files_to_inject_list": [] }}')
  echo "-------------- Creating Second VM with Guest Customization --------------"
  echo
  echo $ADD_VM
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function deploy_multi_tier_calm_bitches {
  echo
  echo "Deploying a Three-Tier Application from Calm. Bitches."
  echo
  #Launch a Calm Deployment from a Blueprint
  CALM_DEPLOY=$(curl --insecure -X POST $CALM_URL -u $CALM_USER:$CALM_PASS -H 'cache-control: no-cache' -H $CT -d '{"blueprint_name": "Multiple App Servers","team_name": "Administrator Team","application_name": "Test-App5"}')
  echo $CALM_DEPLOY
  echo
  echo
  read -p "Press any key to continue..." -n1 -s
	clear
}

function quit_code {
  echo
  echo "Quitting"
  echo
  COUNTER=1
	IFS=$OIFS
}

MENUITEMS=("List Hosts","Show Containers","Show VMs","Gather Task and Health Data","Enable Inline Compression","Create New Network","Change External Data Services IP","Create One CentOS VM via REST","Create Two CentOS VMs via REST","Deploy Three-Tier Application via Calm Bitches","Quit")
COUNTER=0

clear

while [ $COUNTER -lt 1 ]; do
  echo '$$\   $$\$$\   $$\$$$$$$$$\ $$$$$$\ $$\   $$\$$$$$$\$$\   $$\'
  echo '$$$\  $$ $$ |  $$ \__$$  __$$  __$$\$$$\  $$ \_$$  _$$ |  $$ |'
  echo '$$$$\ $$ $$ |  $$ |  $$ |  $$ /  $$ $$$$\ $$ | $$ | \$$\ $$  |'
  echo '$$ $$\$$ $$ |  $$ |  $$ |  $$$$$$$$ $$ $$\$$ | $$ |  \$$$$  /'
  echo '$$ \$$$$ $$ |  $$ |  $$ |  $$  __$$ $$ \$$$$ | $$ |  $$  $$<'
  echo '$$ |\$$$ $$ |  $$ |  $$ |  $$ |  $$ $$ |\$$$ | $$ | $$  /\$$\'
  echo '$$ | \$$ \$$$$$$  |  $$ |  $$ |  $$ $$ | \$$ $$$$$$\$$ /  $$ |'
  echo '\__|  \__|\______/   \__|  \__|  \__\__|  \__\______\__|  \__|'
  echo

  echo "Please select from the following choices: "
  echo
  select item in $MENUITEMS; do
		case $REPLY in
			1) show_hosts; break ;;
      2) show_containers; break ;;
			3) show_vms; break ;;
			4) gather_task_and_health; break ;;
			5) change_container_variables; break ;;
			6) create_new_network; break ;;
			7) add_data_services_ip; break ;;
      8) create_one_centos_rest; break ;;
      9) create_two_centos_rest; break ;;
      10) deploy_multi_tier_calm_bitches; break;;
			11) quit_code; break ;;
		esac
	done
done
