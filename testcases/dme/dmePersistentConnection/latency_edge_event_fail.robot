*** Settings ***
Documentation   DME Persistent Connection Failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

Test Timeout    60s

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3297
DMEPersistentConnection - Request App Instance Latency with bad appinst info shall fail
   [Documentation]
    ...  - make DME persistent connection 
    ...  - send Request App Instance Latency with bad appinst data
    ...  - verify error is received 

   [Tags]  DMEPersistentConnection

   Create Flavor  region=${region}
   Create App  region=${region}  access_ports=tcp:1  deployment=docker
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=docker
   ${dmuus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

   Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloudlet.edge_events_cookie}') > 100

   Create DME Persistent Connection  carrier_name=GDDT  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

   ${app_name}=  Get Default App Name
   ${developer_org_name}=  Get Default Developer Name
   ${cluster_name}=  Get Default Cluster Name

   ${error1}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=x  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error1}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"x\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error2}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=2.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error2}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"2.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error3}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=x  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error3}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error4}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=x  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error4}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error5}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=x  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error5}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"x\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error6}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=x  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error6}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"x\\\\"}} not found"}')

   ${error7}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=x  operator_org_name=${operator_name_fake}
   Should Be Equal  ${error7}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_fake}\\\\",\\\\"name\\\\":\\\\"x\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

   ${error8}=  Run Keyword and Expect Error  *  Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=x
   Should Be Equal  ${error8}  ('code=400', 'error={"message":"AppInst key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cluster_inst_key\\\\":{\\\\"cluster_key\\\\":{\\\\"name\\\\":\\\\"${cluster_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_fake}\\\\"},\\\\"organization\\\\":\\\\"${developer_org_name}\\\\"}} not found"}')

DMEPersistentConnection - Latency edge event shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples
    ...  - verify response has correct stats

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}

    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    Create DME Persistent Connection  carrier_name=${operator_name_fake}x  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${latency}=  Send Latency Edge Event  carrier_name=${operator_name_fake}x  #edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    sleep  30s
    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

*** Keywords ***
Setup
    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    ${edge_cookie}=  Set Variable  ${cloudlet.edge_events_cookie}
    @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${70.45}

    Create DME Persistent Connection  carrier_name=${operator_name_fake}  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    Set Suite Variable  ${edge_cookie}
    Set Suite Variable  @{samples}
