// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
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

import ballerina/test;

// create mock client
final Client mockClient = check new (
    {
        auth: {
            token: "test-token" // This approach eliminates the need for the client to make additional server requests for token validation, such as a refresh token request in the OAuth2 flow.
        }
    }, "http://localhost:9090"
);

// this is a mock test
@test:Config {
    groups: ["mock_service_test"]
}
function testMockBatchUpsert() returns error? {

    BatchInputSimplePublicObjectBatchInputUpsert payload = {
        "inputs": [
            {
                "idProperty": "string",
                "objectWriteTraceId": "string",
                "id": "string",
                "properties": {
                    "additionalProp1": "string",
                    "additionalProp2": "string",
                    "additionalProp3": "string"
                }
            }
        ]
    };

    BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors upsertResponse =
    check mockClient->/batch/upsert.post(payload);

    if upsertResponse is BatchResponseSimplePublicUpsertObjectWithErrors {
        test:assertFail("Batch upsert failed");
    }
    test:assertNotEquals(upsertResponse.results[0].id, ());
    test:assertEquals(upsertResponse.results[0].properties["hs_label"], "A fixed, one-time discount");
    test:assertEquals(upsertResponse.results[0].properties["hs_value"], "50");
    test:assertEquals(upsertResponse.results[0].properties["hs_type"], "PERCENT");
}

// this is a mock test
@test:Config {
    groups: ["mock_service_test"]
}
function testMockList() returns error? {

    GetCrmV3ObjectsDiscountsQueries params = {
        'limit: 10,
        archived: false,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response =
    check mockClient->/.get(queries=params);

    test:assertNotEquals(response.results, [], "No discounts found");
    test:assertTrue(response.results.length() <= 10, "Limit Exceeded");
    test:assertNotEquals(response.results[0].id, (), "Discount id is not found");
    test:assertNotEquals(response.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(response.results[0].properties["hs_type"], (), "Discount label is not found");
    test:assertNotEquals(response.results[0].properties["hs_value"], (), "Discount value is not found");
    test:assertNotEquals(response.results[0].properties["hs_label"], (), "Discount type is not found");
}
