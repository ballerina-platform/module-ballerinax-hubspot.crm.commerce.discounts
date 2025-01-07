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
// AUTO-GENERATED FILE. DO NOT MODIFY.

import ballerina/http;
import ballerina/oauth2;
import ballerina/test;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable boolean isServerLocal = false;

// test discount ids for batch and basic endpoints.
string discount_id = "";
string[] batch_discount_ids = [];

// discount properties for basic create
string hs_value = "";
string hs_label = "";
string hs_type = "";

// discount properties for update
string new_hs_value = "8";
string new_hs_label = "test_updated_label";
string new_hs_type = "PERCENT";

ConnectionConfig config = {
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        credentialBearer: oauth2:POST_BODY_BEARER
    }
};

final string serviceURL = isServerLocal ? "localhost:8080" : "https://api.hubapi.com/crm/v3/objects/discounts";
final Client hubspotClient = check new (config, serviceURL);

@test:Config {
    dependsOn: [testBatchCreate]
}
function testList() returns error? {

    GetCrmV3ObjectsDiscountsQueries params = {
        'limit: 10,
        archived: false,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error response = check hubspotClient->/.get({}, params);
    if response is CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
        test:assertNotEquals(response.results, [], "No discounts found");
        test:assertTrue(response.results.length() <= 10, "Limit Exceeded");
        test:assertNotEquals(response.results[0].id, (), "Discount id is not found");
        test:assertNotEquals(response.results[0].properties, (), "Discount properties are not found");
        test:assertNotEquals(response.results[0].properties["hs_type"], (), "Discount label is not found");
        test:assertNotEquals(response.results[0].properties["hs_value"], (), "Discount value is not found");
        test:assertNotEquals(response.results[0].properties["hs_label"], (), "Discount type is not found");
    } else {
        test:assertFail("Error occurred while fetching discounts");
    }
}

@test:Config {
    dependsOn: [testCreate]
}
function testRead() returns error? {
    GetCrmV3ObjectsDiscountsDiscountidQueries params = {
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    SimplePublicObjectWithAssociations|error response = check hubspotClient->/[discount_id].get({}, params);

    if response is SimplePublicObjectWithAssociations {
        test:assertNotEquals(response.id, (), "Discount id is not found");
        test:assertNotEquals(response.properties, (), "Discount properties are not found");
        test:assertEquals(response.properties["hs_type"], hs_type, "Discount type is not correct");
        test:assertEquals(response.properties["hs_value"], hs_value, "Discount value is not correct");
        test:assertEquals(response.properties["hs_label"], hs_label, "Discount label is not correct");

    } else {
        test:assertFail("Error occurred while fetching this discount");
    }
}

@test:Config {
    dependsOn: [testRead]
}
function testUpdate() returns error? {
    SimplePublicObjectInput payload = {
        objectWriteTraceId: "1234",
        properties: {
            "hs_value": new_hs_value,
            "hs_label": new_hs_label
        }
    };

    SimplePublicObject|error update_response = check hubspotClient->/[discount_id].patch(payload, {});

    if update_response is SimplePublicObject {
        test:assertEquals(update_response.properties["hs_value"], new_hs_value, "Discount value is not updated");
        test:assertEquals(update_response.properties["hs_label"], new_hs_label, "Discount label is not updated");
    } else {
        test:assertFail("Error occurred while updating this discount");
    }
}

@test:Config {
    dependsOn: [testUpdate]
}
function testArchive() returns error? {
    http:Response|error delete_response = check hubspotClient->/[discount_id].delete({});

    if delete_response is http:Response {
        test:assertEquals(delete_response.statusCode, 204, "Discount is not deleted");
    } else {
        test:assertFail("Error occurred while deleting this discount");
    }
}

@test:Config
function testCreate() returns error? {
    hs_label = "test_discount";
    hs_value = "40";
    hs_type = "PERCENT";

    SimplePublicObjectInputForCreate payload = {
        associations: [],
        objectWriteTraceId: "1234",
        properties: {
            "hs_label": hs_label,
            "hs_duration": "ONCE",
            "hs_type": hs_type,
            "hs_value": hs_value,
            "hs_sort_order": "2"
        }
    };

    SimplePublicObject|error create_response = check hubspotClient->/.post(payload, {});

    if create_response is SimplePublicObject {
        test:assertFalse(create_response.archived ?: true, "Discount is archived");
        test:assertFalse(create_response.id == "", "Discount id is not valid");

        discount_id = create_response.id;

        test:assertEquals(create_response.properties["hs_label"], "test_discount", "Discount label is not correct");
        test:assertEquals(create_response.properties["hs_value"], "40", "Discount value is not correct");
        test:assertEquals(create_response.properties["hs_type"], "PERCENT", "Discount type is not correct");
    } else {
        test:assertFail("Error occurred while creating this discount");
    }
}

@test:Config {
    dependsOn: [testBatchRead]
}
function testBatchUpdate() returns error? {
    BatchInputSimplePublicObjectBatchInput payload = {
        inputs: [
            {
                id: batch_discount_ids[0],
                properties: {
                    "hs_value": "30",
                    "hs_label": "test_batch_discount_update_1"
                }
            },
            {
                id: batch_discount_ids[1],
                properties: {
                    "hs_value": "40",
                    "hs_label": "test_batch_discount_update_2"
                }
            }
        ]
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors|error batch_update_response = check hubspotClient->/batch/update.post(payload, {});

    if batch_update_response is BatchResponseSimplePublicObject {
        test:assertEquals(batch_update_response.status, "COMPLETE", "Batch update failed");
        test:assertEquals(batch_update_response.results.length(), 2, "Not all the specified discounts are updated");
        test:assertNotEquals(batch_update_response.results[0].id, (), "Update failed as id varies");
        test:assertNotEquals(batch_update_response.results[1].id, (), "Update failed as id varies");
        if (batch_update_response.results[0].id == batch_discount_ids[0]) {
            test:assertEquals(batch_update_response.results[0].properties["hs_value"], "30", "Discount value is not updated");
            test:assertEquals(batch_update_response.results[0].properties["hs_label"], "test_batch_discount_update_1", "Discount label is not updated");
            test:assertEquals(batch_update_response.results[1].properties["hs_value"], "40", "Discount value is not updated");
            test:assertEquals(batch_update_response.results[1].properties["hs_label"], "test_batch_discount_update_2", "Discount label is not updated");
        }
        if (batch_update_response.results[0].id == batch_discount_ids[1]) {
            test:assertEquals(batch_update_response.results[0].properties["hs_value"], "40", "Discount value is not updated");
            test:assertEquals(batch_update_response.results[0].properties["hs_label"], "test_batch_discount_update_2", "Discount label is not updated");
            test:assertEquals(batch_update_response.results[1].properties["hs_value"], "30", "Discount value is not updated");
            test:assertEquals(batch_update_response.results[1].properties["hs_label"], "test_batch_discount_update_1", "Discount label is not updated");

        }
    }
    else {
        test:assertFail("Error occurred while batch updating discounts");
    }
}

@test:Config {
    dependsOn: [testSearch]
}
function testBatchRead() returns error? {
    BatchReadInputSimplePublicObjectId payload = {
        propertiesWithHistory: ["hs_label", "hs_value", "hs_type"],
        inputs: [
            {id: batch_discount_ids[0]},
            {id: batch_discount_ids[1]}
        ],
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors|error batch_read_response = check hubspotClient->/batch/read.post(payload, {});

    if (batch_read_response is BatchResponseSimplePublicObject) {
        test:assertEquals(batch_read_response.status, "COMPLETE", "Batch read failed");
        test:assertEquals(batch_read_response.results.length(), 2, "Not all the specified discounts are fetched");
        test:assertNotEquals(batch_read_response.results[0].id, (), "Read failed as id is null");
        test:assertNotEquals(batch_read_response.results[1].id, (), "Read failed as id is null");
        test:assertNotEquals(batch_read_response.results[0].properties, (), "Discount properties are not found");
        test:assertNotEquals(batch_read_response.results[1].properties, (), "Discount properties are not found");
        test:assertNotEquals(batch_read_response.results[0].propertiesWithHistory, (), "Propertites with history are not fetched");
        test:assertNotEquals(batch_read_response.results[1].propertiesWithHistory, (), "Propertites with history are not fetched");
    } else {
        test:assertFail("Error occurred while batch reading discounts");
    }
}

@test:Config {
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
    BatchResponseSimplePublicObject|BatchResponseSimplePublicObjectWithErrors|error batch_create_response = check hubspotClient->/batch/create.post(payload, {});

    if (batch_create_response is BatchResponseSimplePublicObject) {
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
            batch_discount_ids.push(batch_create_response.results[i].id);
            i = i + 1;
        }

    } else {
        test:assertFail("Error occurred while batch creating discounts");
    }
}

@test:Config {
    dependsOn: [testBatchUpdate]
}
function testBatchArchive() returns error? {
    BatchInputSimplePublicObjectId payload = {
        inputs: [
            {id: batch_discount_ids[0]},
            {id: batch_discount_ids[1]},
            {id: batch_discount_ids[2]}
        ]
    };

    http:Response|error batch_archive_response = check hubspotClient->/batch/archive.post(payload, {});

    if batch_archive_response is http:Response {
        test:assertEquals(batch_archive_response.statusCode, 204, "Batch archive failed");
    } else {
        test:assertFail("Error occurred while batch archiving discounts");
    }
}

@test:Config {
    dependsOn: [testList]
}
function testSearch() returns error? {
    PublicObjectSearchRequest payload = {
        sorts: ["hs_value"],
        query: "test_",
        'limit: 10,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    CollectionResponseWithTotalSimplePublicObjectForwardPaging|error search_response = check hubspotClient->/search.post(payload, {});

    if search_response is CollectionResponseWithTotalSimplePublicObjectForwardPaging {
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

    } else {
        test:assertFail("Error occurred while searching discounts");
    }
}
