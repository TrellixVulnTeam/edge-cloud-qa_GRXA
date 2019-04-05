import app_client_pb2
import app_client_pb2_grpc
import loc_pb2

import shared_variables

auth_token_global = None
session_cookie_global = None
token_server_uri_global = None
token_global = None

class RegisterClientObject():
    request = None
    
    def __init__(self, developer_name=None, app_name=None, app_version=None, auth_token=None, use_defaults=True):
        client_dict = {}
        self.dev_name = developer_name
        self.app_name = app_name
        self.app_vers = app_version
        self.auth_token = auth_token

        global auth_token_global
        
        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            if not app_version: self.app_vers = shared_variables.app_version_default
            if not developer_name: self.dev_name = shared_variables.developer_name_default
            if not auth_token: self.auth_token = auth_token_global
            
        #if auth_token == 'default':
        #    self.auth_token = 
        if self.dev_name is not None:
            client_dict['DevName'] = self.dev_name
        if self.app_name is not None:
            client_dict['AppName'] = self.app_name
        if self.app_vers is not None:
            client_dict['AppVers'] = self.app_vers
        if self.auth_token is not None:
            client_dict['AuthToken'] = self.auth_token

        self.request = app_client_pb2.RegisterClientRequest(**client_dict)

class FindCloudletRequestObject():
    request_dict = None
    request_dict_string = None
    request = None
    
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_name=None, timestamp_seconds=None, timestamp_nanos=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.seconds = timestamp_seconds
        self.nanos = timestamp_nanos
        
        if session_cookie == 'default':
            self.session_cookie = shared_variables.session_cookie_default
            
        if use_defaults:
            if not session_cookie: self.session_cookie = shared_variables.session_cookie_default
            if not carrier_name: self.carrier_name = shared_variables.operator_name_default

        time_dict = {}
        if self.seconds is not None:
            time_dict['seconds'] = int(self.seconds)
        if self.nanos is not None:
            time_dict['nanos'] = int(self.nanos)

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)
        if time_dict:
            loc_dict['timestamp'] = loc_pb2.Timestamp(**time_dict)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['CarrierName'] = self.carrier_name
        if self.app_name is not None:
            request_dict['AppName'] = self.app_name
        if self.app_version is not None:
            request_dict['AppVers'] = self.app_version
        if self.developer_name is not None:
            request_dict['DevName'] = self.developer_name

        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)

        #self.request_dict = request_dict
        #self.request_dict_string = str(request_dict).replace('\n', ',')
        self.request = app_client_pb2.FindCloudletRequest(**request_dict)
        #print('*WARN*', 'aa', str(self.request_dict['GpsLocation'].__dict__))

class VerifyLocationRequestObject():
    def __init__(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude
        self.carrier_name = carrier_name
        self.token = token

        if session_cookie == 'default':
            self.session_cookie = shared_variables.session_cookie_default

        if token == 'default':
            self.token = shared_variables.token_default

        if use_defaults:
            if not session_cookie: self.session_cookie = shared_variables.session_cookie_default
            if token is None: self.token = shared_variables.token_default

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['CarrierName'] = self.carrier_name    
        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)
        if self.token is not None:
            request_dict['VerifyLocToken'] = self.token

        print(request_dict)
        self.request = app_client_pb2.VerifyLocationRequest(**request_dict)
