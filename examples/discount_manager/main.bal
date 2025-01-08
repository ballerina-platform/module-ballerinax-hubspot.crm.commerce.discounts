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

public function main() {
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

    discounts:SimplePublicObject|error create_response = hubspotClient->/.post(create_payload, {});

    if (create_response is discounts:SimplePublicObject) {
        io:println("Discount created successfully with id: " + create_response.id.toString());
        created_discount_id = create_response.id.toString();
    } else {
        io:println("Error occurred while creating discount");
    }


    // update a discount
    discounts:SimplePublicObjectInput payload = {
        objectWriteTraceId: "1234",
        properties: {
            "hs_value": "17",
            "hs_label": "updated_discount_label"
        }
    };

    discounts:SimplePublicObject|error update_response = hubspotClient->/[created_discount_id].patch(payload, {});

    if (update_response is discounts:SimplePublicObject) {
        io:println("Discount updated successfully with id: " + update_response.id.toString());
    } else {
        io:println("Error occurred while updating discount");
    }


    // read a discount
    discounts:GetCrmV3ObjectsDiscountsDiscountidQueries params = {
        properties: ["hs_label", "hs_value", "hs_type"]
    };

    discounts:SimplePublicObjectWithAssociations|error response = hubspotClient->/[created_discount_id].get({}, params);

    if (response is discounts:SimplePublicObjectWithAssociations) {
        io:println("Discount read successfully with id: " + response.id.toString());
    } else {
        io:println("Error occurred while reading discount");
    }


    // delete a discount
    http:Response|error delete_response = hubspotClient->/[created_discount_id].delete({});
    if (delete_response is http:Response) {
        if (delete_response.statusCode == 204) {
            io:println("Discount deleted successfully with id: " + created_discount_id);
        } else {
            io:println("Archiving failed");
        }
    } else {
        io:println("Error occurred while deleting discount");
    }

}
