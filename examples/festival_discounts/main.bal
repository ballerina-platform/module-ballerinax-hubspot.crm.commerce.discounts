import ballerina/http;
import ballerina/oauth2;
import ballerinax/hubspot.crm.commerce.discounts as discounts;
import ballerina/io;

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

public function main(){
    // store discount ids for batch endpoints
    string[] discountIds = [];

    // create a batch of discounts
    discounts:BatchInputSimplePublicObjectInputForCreate payload = {
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

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors|error batch_create_response = hubspotClient->/batch/create.post(payload, {});

    if (batch_create_response is discounts:BatchResponseSimplePublicObject) {
        foreach discounts:SimplePublicObject obj in batch_create_response.results {
            io:println("Discount created successfully with id: " + obj.id.toString());
            discountIds.push(obj.id.toString());
        }
    } else {
        io:println("Error occurred while creating discounts");
    }

    // batch read discounts
    discounts:BatchReadInputSimplePublicObjectId batch_read_payload = {
        propertiesWithHistory: ["hs_label", "hs_value", "hs_type"],
        inputs: [
            {id: discountIds[0]},
            {id: discountIds[1]}
        ],
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors|error batch_read_response = hubspotClient->/batch/read.post(batch_read_payload, {});

    if (batch_read_response is discounts:BatchResponseSimplePublicObject) {
        foreach discounts:SimplePublicObject obj in batch_read_response.results {
            io:println("Discount read successfully with id: " + obj.id.toString());
        }
    } else {
        io:println("Error occurred while reading discounts");
    }

    // update batch of discounts
    discounts:BatchInputSimplePublicObjectBatchInput update_payload = {
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

    discounts:BatchResponseSimplePublicObject|discounts:BatchResponseSimplePublicObjectWithErrors|error batch_update_response = hubspotClient->/batch/update.post(update_payload, {});

    if (batch_update_response is discounts:BatchResponseSimplePublicObject) {
        foreach discounts:SimplePublicObject obj in batch_update_response.results {
            io:println("Discount updated successfully with id: " + obj.id.toString());
        }
    } else {
        io:println("Error occurred while updating discounts");
    }
    
    // search for a discount
    discounts:PublicObjectSearchRequest search_payload = {
        sorts: ["hs_value"],
        query: "festival_batch_discount_update_",
        'limit: 5,
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:CollectionResponseWithTotalSimplePublicObjectForwardPaging|error search_response = hubspotClient->/search.post(search_payload, {});

    if (search_response is discounts:CollectionResponseWithTotalSimplePublicObjectForwardPaging) {
        foreach discounts:SimplePublicObject obj in search_response.results {
            io:println("Discount found from search with id: " + obj.id.toString());
        }
    } else {
        io:println("Error occurred while searching for discounts");
    }

    // archive batch of discounts
    discounts:BatchInputSimplePublicObjectId batch_archive_payload = {
        inputs: [
            {id: discountIds[0]},
            {id: discountIds[1]}
        ]
    };

    http:Response|error batch_archive_response = hubspotClient->/batch/archive.post(batch_archive_payload, {});
    if (batch_archive_response is http:Response) {
        if (batch_archive_response.statusCode == 204) {
            io:println("Discounts archived successfully");
        } else {
            io:println("Archiving failed");
        }
    } else {
        io:println("Error occurred while archiving discounts");
    }
    
}