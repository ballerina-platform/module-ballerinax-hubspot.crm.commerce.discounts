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
    string created_discount_id = "";

    // create a discount

    discounts:SimplePublicObjectInputForCreate create_payload = {
        associations: [],
        objectWriteTraceId: "1234",
        properties: {
            "hs_label": "discount_1",
            "hs_duration": "ONCE",
            "hs_type": "PERCENT",
            "hs_value": "7",
            "hs_sort_order": "2"
        }
    };

    discounts:SimplePublicObject create_response = check hubspotClient->/.post(create_payload, {});

    io:println("Discount created successfully with id: " + create_response.id.toString());
    created_discount_id = create_response.id.toString();


    // update a discount
    discounts:SimplePublicObjectInput payload = {
        objectWriteTraceId: "1234",
        properties: {
            "hs_value": "17",
            "hs_label": "updated_discount_label"
        }
    };

    discounts:SimplePublicObject update_response = check hubspotClient->/[created_discount_id].patch(payload, {});

    io:println("Discount updated successfully with id: " + update_response.id.toString());


    // read a discount
    discounts:GetCrmV3ObjectsDiscountsDiscountidQueries params = {
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:SimplePublicObjectWithAssociations response = check hubspotClient->/[created_discount_id].get({}, params);

    io:println("Discount read successfully with id: " + response.id.toString());


    // delete a discount
    http:Response delete_response = check hubspotClient->/[created_discount_id].delete({});
    if (delete_response.statusCode == 204) {
        io:println("Discount deleted successfully with id: " + created_discount_id);
    } else {
        io:println("Archiving failed");
    }
}
