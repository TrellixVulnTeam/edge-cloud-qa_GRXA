*** Settings ***
Documentation   FindCloudlet - request shall return dmuus with azure cloudlet provisioned and dmuus and azure same coord
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             azure azurecloud-1  cloudlet at: 35 -95
...		find cloudlet closest to   : 36 -95
...                111.19km from dmuus
...                111.19km  from azure
...             dmuus and azure are same coord/distance. return dmuus cloudlet
...
...             ShowCloudlet
...             - key:
...                 operatorkey:
...                   name: dmuus
...                 name: tmocloud-2
...               location:
...                 lat: 35
...                 long: -95
...             - key:
...                 operatorkey:
...                   name: azure
...                 name: azurecloud-1
...               location:
...                 lat: 35
...                 long: -95
...

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${azure_cloudlet_latitude}	  35
${azure_cloudlet longitude}	  -95
${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet - request shall return dmuus with azure cloudlet provisioned and dmuus and azure same coord
    [Documentation]
    ...  findCloudlet with dmuus and azure provisioned. dmuus and azure same coord. return dmuus
    ...             dmuus tmocloud-2 cloudlet at: 35 -95
    ...             azure azurecloud-1  cloudlet at: 35 -95
    ...             find cloudlet closest to   : 36 -95
    ...                111.19km from dmuus
    ...                111.19km  from azure
    ...             dmuus and azure are same coord/distance. return dmuus cloudlet
    ...
    ...             ShowCloudlet
    ...             - key:
    ...                 operatorkey:
    ...                   name: dmuus
    ...                 name: tmocloud-2
    ...               location:
    ...                 lat: 35
    ...                 long: -95
    ...             - key:
    ...                 operatorkey:
    ...                   name: azure
    ...                 name: azurecloud-1
    ...               location:
    ...                 lat: 35
    ...                 long: -95

      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${dmuus_operator_name}  latitude=36  longitude=-95

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.FQDN}                         ${dmuus_appinst.uri}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${dmuus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${dmuus_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${dmuus_appinst.mapped_ports[0].proto}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${dmuus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${dmuus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].FQDN_prefix}    ${dmuus_appinst.mapped_ports[0].FQDN_prefix}

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    Create Cluster Flavor	
    Create Cluster		
    Create App			access_ports=tcp:1  
    ${dmuus_appinst}=            Create App Instance		cloudlet_name=${dmuus_cloudlet_name}  operator_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 
