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

import ballerina/http;
import ballerina/oauth2;
import ballerina/test;

configurable string clientId = "clientId";
configurable string clientSecret = "clientSecret";
configurable string refreshToken = "refreshToken";
configurable boolean enableClientOauth2 = false;

// test discount ids for batch and basic endpoints.
string discountId = "";
string[] batchDiscountIds = [];

// discount properties for basic create
string hsValue = "";
string hsLabel = "";
string hsType = "";

// discount properties for update
string newHsValue = "8";
string newHsLabel = "test_updated_label";
string newHsType = "PERCENT";

// create connection config for live client
ConnectionConfig config = {
    auth: enableClientOauth2 ? {
            clientId,
            clientSecret,
            refreshToken,
            credentialBearer: oauth2:POST_BODY_BEARER
        } : {token: "Bearer token"}
};

// create live client
final Client hsClient = check new (config);

@test:Config {
    groups: ["live_service_test"]
}
function testList() returns error? {

    GetCrmV3ObjectsDiscountsQueries params = {
        'limit: 10,
        archived: false,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response =
    check hsClient->/.get(queries = params);

    test:assertNotEquals(response.results, [], "No discounts found");
    test:assertTrue(response.results.length() <= 10, "Limit Exceeded");
    test:assertNotEquals(response.results[0].id, (), "Discount id is not found");
    test:assertNotEquals(response.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(response.results[0].properties["hs_type"], (), "Discount label is not found");
    test:assertNotEquals(response.results[0].properties["hs_value"], (), "Discount value is not found");
    test:assertNotEquals(response.results[0].properties["hs_label"], (), "Discount type is not found");
}

@test:Config {
    dependsOn: [testCreate],
    groups: ["live_service_test"]
}
function testRead() returns error? {
    GetCrmV3ObjectsDiscountsDiscountidQueries params = {
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    SimplePublicObjectWithAssociations response = check hsClient->/[discountId].get(queries = params);

    test:assertNotEquals(response.id, (), "Discount id is not found");
    test:assertNotEquals(response.properties, (), "Discount properties are not found");
    test:assertEquals(response.properties["hs_type"], hsType, "Discount type is not correct");
    test:assertEquals(response.properties["hs_value"], hsValue, "Discount value is not correct");
    test:assertEquals(response.properties["hs_label"], hsLabel, "Discount label is not correct");
}

@test:Config {
    dependsOn: [testRead],
    groups: ["live_service_test"]
}
function testUpdate() returns error? {
    SimplePublicObjectInput payload = {
        objectWriteTraceId: "1234",
        properties: {
            "hs_value": newHsValue,
            "hs_label": newHsLabel
        }
    };

    SimplePublicObject updateResponse = check hsClient->/[discountId].patch(payload);

    test:assertEquals(updateResponse.properties["hs_value"], newHsValue, "Discount value is not updated");
    test:assertEquals(updateResponse.properties["hs_label"], newHsLabel, "Discount label is not updated");
}

@test:Config {
    dependsOn: [testUpdate],
    groups: ["live_service_test"]
}
function testArchive() returns error? {
    http:Response deleteResponse = check hsClient->/[discountId].delete();

    test:assertEquals(deleteResponse.statusCode, 204, "Discount is not deleted");
}

@test:Config {
    groups: ["live_service_test"]
}
function testCreate() returns error? {
    hsLabel = "test_discount";
    hsValue = "40";
    hsType = "PERCENT";

    SimplePublicObjectInputForCreate payload = {
        associations: [],
        objectWriteTraceId: "1234",
        properties: {
            "hs_label": hsLabel,
            "hs_duration": "ONCE",
            "hs_type": hsType,
            "hs_value": hsValue,
            "hs_sort_order": "2"
        }
    };

    SimplePublicObject createResponse = check hsClient->/.post(payload);

    test:assertFalse(createResponse.archived ?: true, "Discount is archived");
    test:assertFalse(createResponse.id == "", "Discount id is not valid");

    discountId = createResponse.id;

    test:assertEquals(createResponse.properties["hs_label"], "test_discount", "Discount label is not correct");
    test:assertEquals(createResponse.properties["hs_value"], "40", "Discount value is not correct");
    test:assertEquals(createResponse.properties["hs_type"], "PERCENT", "Discount type is not correct");
}

@test:Config {
    dependsOn: [testBatchRead],
    groups: ["live_service_test"]
}
function testBatchUpdate() returns error? {
    BatchInputSimplePublicObjectBatchInput payload = {
        inputs: [
            {
                id: batchDiscountIds[0],
                properties: {
                    "hs_value": "30",
                    "hs_label": "test_batch_discount_update_1"
                }
            },
            {
                id: batchDiscountIds[1],
                properties: {
                    "hs_value": "40",
                    "hs_label": "test_batch_discount_update_2"
                }
            }
        ]
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batchUpdateResponse =
    check hsClient->/batch/update.post(payload);

    if batchUpdateResponse is BatchResponseSimplePublicObjectWithErrors {
        test:assertFail("Batch update failed");
    }

    test:assertEquals(batchUpdateResponse.status, "COMPLETE", "Batch update failed");
    test:assertEquals(batchUpdateResponse.results.length(), 2, "Not all the specified discounts are updated");
    test:assertNotEquals(batchUpdateResponse.results[0].id, (), "Update failed as id varies");
    test:assertNotEquals(batchUpdateResponse.results[1].id, (), "Update failed as id varies");

    if batchUpdateResponse.results[0].id == batchDiscountIds[0] {
        test:assertEquals(batchUpdateResponse.results[0].properties["hs_value"],
                "30", "Discount value is not updated");
        test:assertEquals(batchUpdateResponse.results[0].properties["hs_label"],
                "test_batch_discount_update_1", "Discount label is not updated");
        test:assertEquals(batchUpdateResponse.results[1].properties["hs_value"],
                "40", "Discount value is not updated");
        test:assertEquals(batchUpdateResponse.results[1].properties["hs_label"],
                "test_batch_discount_update_2", "Discount label is not updated");
    }

    if batchUpdateResponse.results[0].id == batchDiscountIds[1] {
        test:assertEquals(batchUpdateResponse.results[0].properties["hs_value"],
                "40", "Discount value is not updated");
        test:assertEquals(batchUpdateResponse.results[0].properties["hs_label"],
                "test_batch_discount_update_2", "Discount label is not updated");
        test:assertEquals(batchUpdateResponse.results[1].properties["hs_value"],
                "30", "Discount value is not updated");
        test:assertEquals(batchUpdateResponse.results[1].properties["hs_label"],
                "test_batch_discount_update_1", "Discount label is not updated");

    }
}

@test:Config {
    dependsOn: [testSearch],
    groups: ["live_service_test"]
}
function testBatchRead() returns error? {
    BatchReadInputSimplePublicObjectId payload = {
        propertiesWithHistory: ["hs_label", "hs_value", "hs_type"],
        inputs: [
            {id: batchDiscountIds[0]},
            {id: batchDiscountIds[1]}
        ],
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batchReadResponse =
    check hsClient->/batch/read.post(payload);

    if batchReadResponse is BatchResponseSimplePublicObjectWithErrors {
        test:assertFail("Batch read failed");
    }

    test:assertEquals(batchReadResponse.status, "COMPLETE", "Batch read failed");
    test:assertEquals(batchReadResponse.results.length(), 2, "Not all the specified discounts are fetched");
    test:assertNotEquals(batchReadResponse.results[0].id, (), "Read failed as id is null");
    test:assertNotEquals(batchReadResponse.results[1].id, (), "Read failed as id is null");
    test:assertNotEquals(batchReadResponse.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(batchReadResponse.results[1].properties, (), "Discount properties are not found");
    test:assertNotEquals(batchReadResponse.results[0].propertiesWithHistory, (),
            "Propertites with history are not fetched");
    test:assertNotEquals(batchReadResponse.results[1].propertiesWithHistory, (),
            "Propertites with history are not fetched");
}

@test:Config {
    dependsOn: [testArchive],
    groups: ["live_service_test"]
}
function testBatchCreate() returns error? {

    BatchInputSimplePublicObjectInputForCreate payload = {
        inputs: [
            {
                associations: [],
                properties: {
                    "hs_label": "test_batch_create_discount_1",
                    "hs_duration": "ONCE",
                    "hs_type": "PERCENT",
                    "hs_value": "10",
                    "hs_sort_order": "2"
                }
            },
            {
                associations: [],
                properties: {
                    "hs_label": "test_batch_create_discount_2",
                    "hs_duration": "ONCE",
                    "hs_type": "PERCENT",
                    "hs_value": "10",
                    "hs_sort_order": "3"
                }
            },
            {
                associations: [],
                properties: {
                    "hs_label": "test_batch_create_discount_3",
                    "hs_duration": "ONCE",
                    "hs_type": "PERCENT",
                    "hs_value": "15",
                    "hs_sort_order": "4"
                }
            }
        ]
    };
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batchCreateResponse =
    check hsClient->/batch/create.post(payload);

    if batchCreateResponse is BatchResponseSimplePublicObjectWithErrors {
        test:assertFail("Batch create failed");
    }

    test:assertEquals(batchCreateResponse.status, "COMPLETE", "Batch create failed");
    test:assertEquals(batchCreateResponse.results.length(), 3, "Not all the specified discounts are created");
    test:assertNotEquals(batchCreateResponse.results[0].id, (), "Create failed as id varies");
    test:assertNotEquals(batchCreateResponse.results[1].id, (), "Create failed as id varies");
    test:assertNotEquals(batchCreateResponse.results[2].id, (), "Create failed as id varies");
    test:assertNotEquals(batchCreateResponse.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(batchCreateResponse.results[1].properties, (), "Discount properties are not found");
    test:assertNotEquals(batchCreateResponse.results[2].properties, (), "Discount properties are not found");

    // preparing discount ids for batch tests
    int i = 0;
    while i < batchCreateResponse.results.length() {
        batchDiscountIds.push(batchCreateResponse.results[i].id);
        i = i + 1;
    }
}

@test:Config {
    dependsOn: [testBatchUpdate],
    groups: ["live_service_test"]
}
function testBatchArchive() returns error? {
    BatchInputSimplePublicObjectId payload = {
        inputs: [
            {id: batchDiscountIds[0]},
            {id: batchDiscountIds[1]},
            {id: batchDiscountIds[2]}
        ]
    };

    http:Response batchArchiveResponse = check hsClient->/batch/archive.post(payload);

    test:assertEquals(batchArchiveResponse.statusCode, 204, "Batch archive failed");
}

@test:Config {
    dependsOn: [testBatchCreate],
    groups: ["live_service_test"]
}
function testSearch() returns error? {
    PublicObjectSearchRequest payload = {
        sorts: ["hs_value"],
        query: "test_",
        'limit: 10,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseWithTotalSimplePublicObjectForwardPaging searchResponse =
    check hsClient->/search.post(payload);

    test:assertNotEquals(searchResponse.results, [], "No search results found");
    test:assertTrue(searchResponse.results.length() <= 10, "Limit Exceeded");

    int i = 0;
    while i < searchResponse.results.length() {
        test:assertNotEquals(searchResponse.results[i].id, (), "Discount id is not found");
        test:assertNotEquals(searchResponse.results[i].properties, (), "Discount properties are not found");
        test:assertNotEquals(searchResponse.results[i].properties["hs_type"], (), "Discount type is not found");
        test:assertNotEquals(searchResponse.results[i].properties["hs_value"], (), "Discount value is not found");
        test:assertEquals(searchResponse.results[i].properties["hs_label"].toString().substring(0, 5),
                "test_", "Discount label is not found");

        i = i + 1;
    }
}
