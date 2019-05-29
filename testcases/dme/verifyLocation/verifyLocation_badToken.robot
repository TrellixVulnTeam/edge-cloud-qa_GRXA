*** Settings ***
Documentation   VerifyLocation - request with bad token shall return LOC_ERROR_UNAUTHORIZED

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
		
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   dmuus
${cloudlet_name1}  tmocloud-1

${beacon_lat}      52.5200
${beacon_long}     13.4050

*** Test Cases ***
VerifyLocation - request with bad token shall return LOC_ERROR_UNAUTHORIZED
#EDGECLOUD-369 - VerifyToken with token=xx does not return LOC_ERROR_UNAUTHORIZED
    [Documentation]
    ...  send VerifyLocatoin with token=xx
    ...  verify return LOC_ERROR_UNAUTHORIZED
	
      Register Client
      ${verify_reply}=  Verify Location  token=xx  carrier_name=GDDT  latitude=${beacon_lat}  longitude=${beacon_long}
      log to console  ${verify_reply}
      Should Be Equal As Numbers  ${verify_reply.gps_location_status}  6  #LOC_ERROR_UNAUTHORIZED
      Should Be Equal As Numbers  ${verify_reply.gps_location_accuracy_km}  -1

VerifyLocation - request with empty token shall return 'verifyloc token required'
    [Documentation]
    ...  send VerifyLocatoin with empty token
    ...  verify return 'verifyloc token required'
	
      Register Client
      ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  token=  carrier_name=GDDT  latitude=${beacon_lat}  longitude=${beacon_long}

      Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
      Should Contain  ${error_msg}   details = "verifyloc token required"

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
    Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}  cluster_instance_name=autocluster



