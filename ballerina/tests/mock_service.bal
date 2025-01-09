// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

http:Service mockService = service object {

    resource isolated function get .(map<string|string[]> headers = {}) returns CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error {
        CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = {
            results: [
                {
                    id: "394348397457",
                    properties: {
                        "hs_createdate": "2025-01-02T06:06:42.695Z",
                        "hs_label": "A fixed, one-time discount",
                        "hs_lastmodifieddate": "2025-01-02T09:17:21.625Z",
                        "hs_object_id": "394348397457",
                        "hs_type": "PERCENT",
                        "hs_value": "51"
                    },
                    createdAt: "2025-01-02T06:06:42.695Z",
                    updatedAt: "2025-01-02T09:17:21.625Z",
                    archived: false
                },
                {
                    id: "394348397458",
                    properties: {
                        "hs_createdate": "2025-01-02T06:06:42.695Z",
                        "hs_label": "new year discount",
                        "hs_lastmodifieddate": "2025-01-03T04:12:31.792Z",
                        "hs_object_id": "394348397458",
                        "hs_type": "PERCENT",
                        "hs_value": "20.0000"
                    },
                    createdAt: "2025-01-02T06:06:42.695Z",
                    updatedAt: "2025-01-03T04:12:31.792Z",
                    archived: false
                },
                {
                    id: "394564000319",
                    properties: {
                        "hs_createdate": "2025-01-03T05:40:37.693Z",
                        "hs_label": "test_batch_discount_update_2",
                        "hs_lastmodifieddate": "2025-01-05T11:49:54.879Z",
                        "hs_object_id": "394564000319",
                        "hs_type": "PERCENT",
                        "hs_value": "40"
                    },
                    createdAt: "2025-01-03T05:40:37.693Z",
                    updatedAt: "2025-01-05T11:49:54.879Z",
                    archived: false
                }
            ],
            paging: {
                next: {
                    "after": "394564000320",
                    "link": "https://api.hubapi.com/crm/v3/objects/discounts?hs_static_app=developer-docs-ui&hs_static_app_version=1.11867&limit=3&properties=hs_label%2C%20hs_value%2C%20hs_type&archived=false&after=394564000320"
                }
            }
        };
        return response;

    };

    resource isolated function post batch/upsert(@http:Payload BatchInputSimplePublicObjectBatchInputUpsert payload, map<string|string[]> headers = {}) returns BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors|error {
        BatchResponseSimplePublicUpsertObject response = {
            completedAt: "2025-01-09T06:00:46.038Z",
            requestedAt: "2025-01-09T06:00:46.038Z",
            startedAt: "2025-01-09T06:00:46.038Z",
            links: {
                "additionalProp1": "string",
                "additionalProp2": "string",
                "additionalProp3": "string"
            },
            results: [
                {
                    createdAt: "2025-01-09T06:00:46.038Z",
                    archived: true,
                    archivedAt: "2025-01-09T06:00:46.038Z",
                    'new: true,
                    propertiesWithHistory: {
                        "additionalProp1": [
                            {
                                "sourceId": "string",
                                "sourceType": "string",
                                "sourceLabel": "string",
                                "updatedByUserId": 0,
                                "value": "string",
                                "timestamp": "2025-01-09T06:00:46.038Z"
                            }
                        ],
                        "additionalProp2": [
                            {
                                "sourceId": "string",
                                "sourceType": "string",
                                "sourceLabel": "string",
                                "updatedByUserId": 0,
                                "value": "string",
                                "timestamp": "2025-01-09T06:00:46.038Z"
                            }
                        ],
                        "additionalProp3": [
                            {
                                "sourceId": "string",
                                "sourceType": "string",
                                "sourceLabel": "string",
                                "updatedByUserId": 0,
                                "value": "string",
                                "timestamp": "2025-01-09T06:00:46.038Z"
                            }
                        ]
                    },
                    id: "string",
                    properties: {
                        "hs_label": "A fixed, one-time discount",
                        "hs_duration": "ONCE",
                        "hs_type": "PERCENT",
                        "hs_value": "50",
                        "hs_sort_order": "2"
                    },
                    updatedAt: "2025-01-09T06:00:46.038Z"
                }
            ],
            status: "PENDING"
        };
        return response;
    };
};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skipping mock server initialization as the tests are running on live server");
        return;
    }
    log:printInfo("Initiating mock server");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}
