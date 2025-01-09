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
import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.commerce.discounts as discounts;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

discounts:ConnectionConfig config = {
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        credentialBearer: oauth2:POST_BODY_BEARER
    }
};

// create client
final discounts:Client hubspotClient = check new (config);

public function main() returns error? {
    // store discount ids for batch endpoints
    string[] discountIds = [];

    // create a batch of discounts
    discounts:BatchInputSimplePublicObjectInputForCreate batchCreatePayload = {
        inputs: [
            {
                associations: [],
                properties: {
                    "hs_label": "festival_discount_1",
                    "hs_duration": "ONCE",
                    "hs_type": "PERCENT",
                    "hs_value": "10",
                    "hs_sort_order": "2"
                }
            },
            {
                associations: [],
                properties: {
                    "hs_label": "festival_discount_2",
                    "hs_duration": "ONCE",
                    "hs_type": "PERCENT",
                    "hs_value": "6",
                    "hs_sort_order": "3"
                }
            }
        ]
    };

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors batchCreateResponse = check hubspotClient->/batch/create.post(batchCreatePayload, {});

    if (batchCreateResponse is discounts:BatchResponseSimplePublicObjectWithErrors) {
        io:println("Error occurred while creating discounts");
    } else {
        foreach discounts:SimplePublicObject obj in batchCreateResponse.results {
            io:println("Discount created successfully with id: " + obj.id.toString());
            discountIds.push(obj.id.toString());
        }
    }

    // batch read discounts
    discounts:BatchReadInputSimplePublicObjectId batchReadPayload = {
        propertiesWithHistory: ["hs_label", "hs_value", "hs_type"],
        inputs: [
            {id: discountIds[0]},
            {id: discountIds[1]}
        ],
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors batchReadResponse = check hubspotClient->/batch/read.post(batchReadPayload, {});

    if (batchReadResponse is discounts:BatchResponseSimplePublicObjectWithErrors) {
        io:println("Error occurred while reading discounts");
    } else {
        foreach discounts:SimplePublicObject obj in batchReadResponse.results {
            io:println("Discount read successfully with id: " + obj.id.toString());
        }
    }

    // update batch of discounts
    discounts:BatchInputSimplePublicObjectBatchInput batchUpdatePayload = {
        inputs: [
            {
                id: discountIds[0],
                properties: {
                    "hs_value": "30",
                    "hs_label": "festival_batch_discount_update_1"
                }
            },
            {
                id: discountIds[1],
                properties: {
                    "hs_value": "40",
                    "hs_label": "festival_batch_discount_update_2"
                }
            }
        ]
    };

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors batchUpdateResponse = check hubspotClient->/batch/update.post(batchUpdatePayload, {});

    if (batchUpdateResponse is discounts:BatchResponseSimplePublicObjectWithErrors) {
        io:println("Error occurred while updating discounts");
    } else {
        foreach discounts:SimplePublicObject obj in batchUpdateResponse.results {
            io:println("Discount updated successfully with id: " + obj.id.toString());
        }

    }

    // search for a discount
    discounts:PublicObjectSearchRequest searchPayload = {
        sorts: ["hs_value"],
        query: "festival_batch_discount_update_",
        'limit: 5,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:CollectionResponseWithTotalSimplePublicObjectForwardPaging searchResponse = check hubspotClient->/search.post(searchPayload, {});

    foreach discounts:SimplePublicObject obj in searchResponse.results {
        io:println("Discount found from search with id: " + obj.id.toString());
    }

    // archive batch of discounts
    discounts:BatchInputSimplePublicObjectId batchArchivePayload = {
        inputs: [
            {id: discountIds[0]},
            {id: discountIds[1]}
        ]
    };

    http:Response batchArchiveResponse = check hubspotClient->/batch/archive.post(batchArchivePayload, {});

    if (batchArchiveResponse.statusCode == 204) {
        io:println("Discounts archived successfully");
    } else {
        io:println("Archiving failed");
    }
}
