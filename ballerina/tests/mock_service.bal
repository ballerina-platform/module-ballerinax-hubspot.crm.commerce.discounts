import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

http:Service mockService = service object {

    resource isolated function get .(map<string|string[]> headers = {}) returns CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error {
        CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = {
    "results": [
        {
        "id": "394348397457",
        "properties": {
            "hs_createdate": "2025-01-02T06:06:42.695Z",
            "hs_label": "A fixed, one-time discount",
            "hs_lastmodifieddate": "2025-01-02T09:17:21.625Z",
            "hs_object_id": "394348397457",
            "hs_type": "PERCENT",
            "hs_value": "51"
        },
        "createdAt": "2025-01-02T06:06:42.695Z",
        "updatedAt": "2025-01-02T09:17:21.625Z",
        "archived": false
        },
        {
        "id": "394348397458",
        "properties": {
            "hs_createdate": "2025-01-02T06:06:42.695Z",
            "hs_label": "new year discount",
            "hs_lastmodifieddate": "2025-01-03T04:12:31.792Z",
            "hs_object_id": "394348397458",
            "hs_type": "PERCENT",
            "hs_value": "20.0000"
        },
        "createdAt": "2025-01-02T06:06:42.695Z",
        "updatedAt": "2025-01-03T04:12:31.792Z",
        "archived": false
        },
        {
        "id": "394564000319",
        "properties": {
            "hs_createdate": "2025-01-03T05:40:37.693Z",
            "hs_label": "test_batch_discount_update_2",
            "hs_lastmodifieddate": "2025-01-05T11:49:54.879Z",
            "hs_object_id": "394564000319",
            "hs_type": "PERCENT",
            "hs_value": "40"
        },
        "createdAt": "2025-01-03T05:40:37.693Z",
        "updatedAt": "2025-01-05T11:49:54.879Z",
        "archived": false
        }
    ],
    "paging": {
        "next": {
        "after": "394564000320",
        "link": "https://api.hubapi.com/crm/v3/objects/discounts?hs_static_app=developer-docs-ui&hs_static_app_version=1.11867&limit=3&properties=hs_label%2C%20hs_value%2C%20hs_type&archived=false&after=394564000320"
        }
    }
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