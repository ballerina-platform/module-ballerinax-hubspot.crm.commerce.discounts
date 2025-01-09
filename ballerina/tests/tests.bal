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

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

configurable boolean isLiveServer = ?;
string serviceUrl = isLiveServer ? "https://api.hubapi.com/crm/v3/objects/discounts" : "http://localhost:9090";

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

ConnectionConfig config = {
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        credentialBearer: oauth2:POST_BODY_BEARER
    }
};

final Client hubspotClient = check new (config, serviceUrl);

@test:Config
function testList() returns error? {

    GetCrmV3ObjectsDiscountsQueries params = {
        'limit: 10,
        archived: false,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = check hubspotClient->/.get({}, params);

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
    enable: isLiveServer
}
function testRead() returns error? {
    GetCrmV3ObjectsDiscountsDiscountidQueries params = {
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    SimplePublicObjectWithAssociations response = check hubspotClient->/[discountId].get({}, params);

    test:assertNotEquals(response.id, (), "Discount id is not found");
    test:assertNotEquals(response.properties, (), "Discount properties are not found");
    test:assertEquals(response.properties["hs_type"], hsType, "Discount type is not correct");
    test:assertEquals(response.properties["hs_value"], hsValue, "Discount value is not correct");
    test:assertEquals(response.properties["hs_label"], hsLabel, "Discount label is not correct");
}

@test:Config {
    dependsOn: [testRead],
    enable: isLiveServer
}
function testUpdate() returns error? {
    SimplePublicObjectInput payload = {
        objectWriteTraceId: "1234",
        properties: {
            "hs_value": newHsValue,
            "hs_label": newHsLabel
        }
    };

    SimplePublicObject update_response = check hubspotClient->/[discountId].patch(payload, {});

    test:assertEquals(update_response.properties["hs_value"], newHsValue, "Discount value is not updated");
    test:assertEquals(update_response.properties["hs_label"], newHsLabel, "Discount label is not updated");
}

@test:Config {
    dependsOn: [testUpdate],
    enable: isLiveServer
}
function testArchive() returns error? {
    http:Response delete_response = check hubspotClient->/[discountId].delete({});

    test:assertEquals(delete_response.statusCode, 204, "Discount is not deleted");
}

@test:Config {
    enable: isLiveServer
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

    SimplePublicObject create_response = check hubspotClient->/.post(payload, {});

    test:assertFalse(create_response.archived ?: true, "Discount is archived");
    test:assertFalse(create_response.id == "", "Discount id is not valid");

    discountId = create_response.id;

    test:assertEquals(create_response.properties["hs_label"], "test_discount", "Discount label is not correct");
    test:assertEquals(create_response.properties["hs_value"], "40", "Discount value is not correct");
    test:assertEquals(create_response.properties["hs_type"], "PERCENT", "Discount type is not correct");
}

@test:Config {
    enable: isLiveServer,
    dependsOn: [testBatchRead]
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

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batch_update_response = check hubspotClient->/batch/update.post(payload, {});

    test:assertEquals(batch_update_response.status, "COMPLETE", "Batch update failed");
    test:assertEquals(batch_update_response.results.length(), 2, "Not all the specified discounts are updated");
    test:assertNotEquals(batch_update_response.results[0].id, (), "Update failed as id varies");
    test:assertNotEquals(batch_update_response.results[1].id, (), "Update failed as id varies");

    if (batch_update_response.results[0].id == batchDiscountIds[0]) {
        test:assertEquals(batch_update_response.results[0].properties["hs_value"], "30", "Discount value is not updated");
        test:assertEquals(batch_update_response.results[0].properties["hs_label"], "test_batch_discount_update_1", "Discount label is not updated");
        test:assertEquals(batch_update_response.results[1].properties["hs_value"], "40", "Discount value is not updated");
        test:assertEquals(batch_update_response.results[1].properties["hs_label"], "test_batch_discount_update_2", "Discount label is not updated");
    }

    if (batch_update_response.results[0].id == batchDiscountIds[1]) {
        test:assertEquals(batch_update_response.results[0].properties["hs_value"], "40", "Discount value is not updated");
        test:assertEquals(batch_update_response.results[0].properties["hs_label"], "test_batch_discount_update_2", "Discount label is not updated");
        test:assertEquals(batch_update_response.results[1].properties["hs_value"], "30", "Discount value is not updated");
        test:assertEquals(batch_update_response.results[1].properties["hs_label"], "test_batch_discount_update_1", "Discount label is not updated");

    }
}

@test:Config {
    enable: isLiveServer,
    dependsOn: [testSearch]
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

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batch_read_response = check hubspotClient->/batch/read.post(payload, {});

    test:assertEquals(batch_read_response.status, "COMPLETE", "Batch read failed");
    test:assertEquals(batch_read_response.results.length(), 2, "Not all the specified discounts are fetched");
    test:assertNotEquals(batch_read_response.results[0].id, (), "Read failed as id is null");
    test:assertNotEquals(batch_read_response.results[1].id, (), "Read failed as id is null");
    test:assertNotEquals(batch_read_response.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(batch_read_response.results[1].properties, (), "Discount properties are not found");
    test:assertNotEquals(batch_read_response.results[0].propertiesWithHistory, (), "Propertites with history are not fetched");
    test:assertNotEquals(batch_read_response.results[1].propertiesWithHistory, (), "Propertites with history are not fetched");
}

@test:Config {
    enable: isLiveServer,
    dependsOn: [testArchive]
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
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors batch_create_response = check hubspotClient->/batch/create.post(payload, {});

    test:assertEquals(batch_create_response.status, "COMPLETE", "Batch create failed");
    test:assertEquals(batch_create_response.results.length(), 3, "Not all the specified discounts are created");
    test:assertNotEquals(batch_create_response.results[0].id, (), "Create failed as id varies");
    test:assertNotEquals(batch_create_response.results[1].id, (), "Create failed as id varies");
    test:assertNotEquals(batch_create_response.results[2].id, (), "Create failed as id varies");
    test:assertNotEquals(batch_create_response.results[0].properties, (), "Discount properties are not found");
    test:assertNotEquals(batch_create_response.results[1].properties, (), "Discount properties are not found");
    test:assertNotEquals(batch_create_response.results[2].properties, (), "Discount properties are not found");

    // preparing discount ids for batch tests
    int i = 0;
    while (i < batch_create_response.results.length()) {
        batchDiscountIds.push(batch_create_response.results[i].id);
        i = i + 1;
    }
}

@test:Config {
    enable: isLiveServer,
    dependsOn: [testBatchUpdate]
}
function testBatchArchive() returns error? {
    BatchInputSimplePublicObjectId payload = {
        inputs: [
            {id: batchDiscountIds[0]},
            {id: batchDiscountIds[1]},
            {id: batchDiscountIds[2]}
        ]
    };

    http:Response batch_archive_response = check hubspotClient->/batch/archive.post(payload, {});

    test:assertEquals(batch_archive_response.statusCode, 204, "Batch archive failed");
}

@test:Config {
    enable: isLiveServer,
    dependsOn: [testBatchCreate]
}
function testSearch() returns error? {
    PublicObjectSearchRequest payload = {
        sorts: ["hs_value"],
        query: "test_",
        'limit: 10,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseWithTotalSimplePublicObjectForwardPaging search_response = check hubspotClient->/search.post(payload, {});

    test:assertNotEquals(search_response.results, [], "No search results found");
    test:assertTrue(search_response.results.length() <= 10, "Limit Exceeded");

    int i = 0;
    while (i < search_response.results.length()) {
        test:assertNotEquals(search_response.results[i].id, (), "Discount id is not found");
        test:assertNotEquals(search_response.results[i].properties, (), "Discount properties are not found");
        test:assertNotEquals(search_response.results[i].properties["hs_type"], (), "Discount type is not found");
        test:assertNotEquals(search_response.results[i].properties["hs_value"], (), "Discount value is not found");
        test:assertEquals(search_response.results[i].properties["hs_label"].toString().substring(0, 5), "test_", "Discount label is not found");

        i = i + 1;
    }
}

// this is a mock test
@test:Config {
    enable: !isLiveServer
}
function testBatchUpsert() returns error? {

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

    BatchResponseSimplePublicUpsertObject|BatchResponseSimplePublicUpsertObjectWithErrors upsert_response = check hubspotClient->/batch/upsert.post(payload, {});

    test:assertNotEquals(upsert_response.results[0].id, ());
    test:assertEquals(upsert_response.results[0].properties["hs_label"], "A fixed, one-time discount");
    test:assertEquals(upsert_response.results[0].properties["hs_value"], "50");
    test:assertEquals(upsert_response.results[0].properties["hs_type"], "PERCENT");

}
