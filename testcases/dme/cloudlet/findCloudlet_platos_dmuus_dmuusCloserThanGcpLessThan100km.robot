*** Settings ***
Documentation   FindCloudlet platos - request shall return dmuus with gcp cloudlet provisioned and dmuus closer and < 100km from request
...		dmuus tmocloud-2 cloudlet at: 35 -95
...             gcp gcpcloud-1  cloudlet at: 37 -95
...		find cloudlet closest to   : 35 -94
...                91.09km from dmuus
...                239.89km  from gcp
...             dmuus closer than and gcp but less than 100km. return dmuus cloudlet
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
...                   name: gcp
...                 name: gcpcloud-1
...               location:
...                 lat: 37
...                 long: -95
...

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${gcp_operator_name}  gcp
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95

*** Test Cases ***
FindCloudlet platos - request shall return dmuus with gcp cloudlet provisioned and dmuus closer and < 100km from request
    [Documentation]
    ...  registerClient with platos app
    ...  findCloudlet with with dmuus and gcp. dmuus closer and < 100km from request - return dmuus
    ...		dmuus tmocloud-2 cloudlet at: 35 -95
    ...         gcp gcpcloud-1  cloudlet at: 37 -95
    ...		find cloudlet closest to   : 35 -94
    ...                91.09km from dmuus
    ...                239.89km  from gcp
    ...             dmuus closer than and gcp but less than 100km. return dmuus cloudlet
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
    ...                   name: gcp
    ...                 name: gcpcloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -95

      Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

      ${fqdn}=  Get App Official FQDN  latitude=35  longitude=-94
      
      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}

      ${cloudlet}=  Platform Find Cloudlet  carrier_name=${dmuus_operator_name}  client_token=${fqdn.client_token}

      #${cloudlet}=  Find Cloudlet   carrier_name=${dmuus_operator_name}  app_name=${app_name_default}  app_version=1.0  developer_org_name=${developer_name_default}  latitude=35  longitude=-94

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${dmuus_appinst.uri}  #acmeappcosomeapplication210.tmocloud-2.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}  ${dmuus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${dmuus_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${dmuus_appinst.mapped_ports[0].proto}   #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${dmuus_appinst.mapped_ports[0].internal_port}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${dmuus_appinst.mapped_ports[0].public_port}
      Should Be Equal             ${cloudlet.ports[0].fqdn_prefix}    ${dmuus_appinst.mapped_ports[0].fqdn_prefix}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}


    #Create Operator             operator_org_name=${dmuus_operator_name} 
    #Create Operator             operator_org_name=${gcp_operator_name} 
    #Create Developer
    Create Flavor
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude}  longitude=${dmuus_cloudlet_longitude}
    #Create Cluster
    Create App                  access_ports=tcp:1  official_fqdn=${platos_uri}  #permits_platform_apps=${True}
    ${dmuus_appinst}=            Create App Instance         cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=  Get Default App Name

    #Create Developer            developer_name=${platos_developer_name}
    Create App			developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  
    #Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_org_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}

