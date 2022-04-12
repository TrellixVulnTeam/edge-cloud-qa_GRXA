#!/usr/bin/python3
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# delete a cluster with invalid name
# verify failes with 'Invalid cluster name'
#

import unittest
import grpc
import sys
import time
import os
from delayedassert import expect, expect_equal, assert_expectations
import logging

import cluster_pb2
import cluster_pb2_grpc
import clusterflavor_pb2

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        #controller_channel = grpc.insecure_channel(controller_address)
        self.mex_root_cert = self._findFile(mex_root_cert)
        self.mex_key = self._findFile(mex_key)
        self.mex_cert = self._findFile(mex_cert)

        with open(self.mex_root_cert, 'rb') as f:
            print('using root_cert =',mex_root_cert)
            #trusted_certs = f.read().encode()
            trusted_certs = f.read()
        with open(self.mex_key,'rb') as f:
            print('using key =',mex_key)
            trusted_key = f.read()
        with open(self.mex_cert, 'rb') as f:
            print('using client cert =', mex_cert)
            cert = f.read()

        credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert)
        controller_channel = grpc.secure_channel(controller_address, credentials)


        self.cluster_stub = cluster_pb2_grpc.ClusterApiStub(controller_channel)

        show_cluster_resp = self.cluster_stub.ShowCluster(cluster_pb2.Cluster())
        self.num_clusters_before = 0
        for c in show_cluster_resp:
            print('clusterBeforeAdd=', c)
            self.num_clusters_before += 1

    def test_DeleteClusterUnderscore(self):
        # [Documentation] Cluster - User shall not be able to delete a cluster with underscore
        # ... delete a cluster with underscore
        # ... verify failes with 'Invalid cluster name'

        cluster = cluster_pb2.Cluster(key = cluster_pb2.ClusterKey(name = 'Auto_Clustername'))

        try:
            create_cluster_resp = self.cluster_stub.DeleteCluster(cluster)
        except grpc.RpcError as e:
            print('error', type(e.code()), e.details())
            expect_equal(e.code(), grpc.StatusCode.UNKNOWN, 'status code')
            expect_equal(e.details(), 'Invalid cluster name', 'error details')
        else:
            print('cluster added',create_cluster_resp)

    def test_DeleteClusterInvalidChars(self):
        # [Documentation] Cluster - User shall not be able to delete a cluster with '()'
        # ... delete a cluster with '()'
        # ... verify failes with 'Invalid cluster name'

        cluster = cluster_pb2.Cluster(key = cluster_pb2.ClusterKey(name = 'Auto(Cluste)rname'))

        try:
            create_cluster_resp = self.cluster_stub.DeleteCluster(cluster)
        except grpc.RpcError as e:
            print('error', type(e.code()), e.details())
            expect_equal(e.code(), grpc.StatusCode.UNKNOWN, 'status code')
            expect_equal(e.details(), 'Invalid cluster name', 'error details')
        else:
            print('cluster added',create_cluster_resp)

    def _findFile(path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Error('cant find file {}'.format(path))

    def tearDown(self):
        show_cluster_resp = self.cluster_stub.ShowCluster(cluster_pb2.Cluster())
        num_clusters_after = 0
        for c in show_cluster_resp:
            print('clusterAfterAdd=', c)
            num_clusters_after += 1

        #expect_equal(self.num_clusters_before, num_clusters_after, 'same number of cluster')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

