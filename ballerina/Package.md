# Ballerina HubSpot CRM Commerce Discounts connector

## Overview

[HubSpot](https://www.hubspot.com/our-story) is an AI-powered customer relationship management (CRM) platform. 

The `ballerinax/hubspot.crm.commerce.discounts` connector offers APIs to connect and interact with the [Hubspot Discounts API](https://developers.hubspot.com/docs/guides/api/crm/commerce/discounts) endpoints, specifically based on the [HubSpot REST API](https://developers.hubspot.com/docs/reference/api/overview).


## Setup guide

You need a [HubSpot developer account](https://developers.hubspot.com/get-started) with an [app](https://developers.hubspot.com/docs/guides/apps/public-apps/overview) to use HubSpot connectors.
>To create a HubSpot Developer account, [click here](https://app.hubspot.com/signup-hubspot/developers?_ga=2.207749649.2047916093.1734412948-232493525.1734412948&step=landing_page)

### Step 1: Create HubSpot Developer Project
1. [Login](https://app.hubspot.com/login) to HubSpot developer account.

2. Create a public app by clicking on "Create app".

   ![Building public image](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/build_public_app.png)

3. Click on "Create app".

   ![Creating App](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/create_app.png)

4. Under "App Info"
   - Enter Public app name.
   - Update App logo (optional).
   - Update Description (optional). 

   ![Entering App details](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/enter_app_details.png)

- Then move to "Auth" tab.

5. Setup the "Redirect URLs" with respective links.

   ![Auth Tab](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/auth_page.png)

Finally Create the app.

### Step 2: Get Client ID and Client secret.
Navigate to "Auth" tab.

![Client ID & Secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/client_id_secret.png)

### Step 3: Get access token and refresh token.

1. Set scopes under "Auth" tab for your app based on the [API requirements](https://developers.hubspot.com/docs/reference/api).

   ![API Reference page](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/exmaple_api_reference.png).
   
   Enable scopes required for HubSpot CRM Discounts API.
   - `crm.objects.line_items.read`
   - `crm.objects.line_items.write`
   - `oauth`

2. Under "Auth" tab under Sample install URL (OAuth) section copy the full URL.
   ```
   https://app.hubspot.com/oauth/authorize?client_id=<client_id>&redirect_uri=<redirect_url>&scope=<scopes>
   ```

3. Choose the preferred account.

   ![Choosing Accounts](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/docs/setup/resources/account_chose.png)

   Choose account and authorize the client.

4. Check URL tab and find the authorization code.

5. Send a http request to the HubSpot.
   * Linux/MacOS
      ```bash
      curl --request POST \ 
      --url https://api.hubapi.com/oauth/v1/token \ --header 'content-type: application/x-www-form-urlencoded' \ 
      --data 'grant_type=authorization_code&code=<code>&redirect_uri=http://localhost:9090&client_id=<client_id>&client_secret=<client_secret>'
      ```

6. Above command returns the access token and refresh token.

7. Use these tokens to authorize the client.

## Quickstart

Follow the below steps to use the `HubSpot CRM Commerce Discounts` connector in your Ballerina application.

### Step 1: Import the module

Import the `hubspot.crm.commerce.discounts` module and `oauth2` module.

```ballerina
import ballerina/oauth2;
import ballerinax/hubspot.crm.commerce.discounts;
```

### Step 2: Instantiate a new connector

1. Instantiate a `OAuth2RefreshTokenGrantConfig` with the obtained credentials and initialize the connector with it.

    ```ballerina
   configurable string clientId = ?;
   configurable string clientSecret = ?;
   configurable string refreshToken = ?;

   ConnectionConfig config = {
      auth: {
         clientId,
         clientSecret,
         refreshToken,
         credentialBearer: oauth2:POST_BODY_BEARER
      }
   };
   final Client hubSpotClient = check new (config);
   ```

2. Create a `Config.toml` file inside the Ballerina package and add the following configurations with the values retrieved in the earlier steps.
   ```toml
    clientId = <Client Id>
    clientSecret = <Client Secret>
    refreshToken = <Refresh Token>
   ```

### Step 3: Invoke the connector operation
Now, utilize the available connector operations. A sample use case is shown below.

#### Create a New Discount
```ballerina
SimplePublicObjectInputForCreate payload = {
   associations: [],
   objectWriteTraceId: "1234",
   properties: {
      "hs_label": "test_discount",
      "hs_duration": "ONCE",
      "hs_type": "PERCENT",
      "hs_value": "40",
      "hs_sort_order": "2"
   }
};

SimplePublicObject createResponse = check hubspotClient->/.post(payload, {});
```

#### List all discounts
```ballerina
GetCrmV3ObjectsDiscountsQueries params = {
   'limit: 10,
   archived: false,
   properties: ["hs_label", "hs_value", "hs_type"]
};

CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response = check hubspotClient->/.get({}, params);
```

## Examples
The HubSpot CRM Commerce Discounts connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-hubspot.crm.commerce.discounts/tree/main/examples/), covering the following use cases:

1. [Discount Manager](https://github.com/module-ballerinax-hubspot.crm.commerce.discounts/tree/main/examples/discount_manager) - see how the Hubspot API can be used to create discount and manage it through endpoints.
2. [Festival Discounts](https://github.com/module-ballerinax-hubspot.crm.commerce.discounts/tree/main/examples/festival_discounts) - see how the Hubspot API can be used to create and to manage multiple discounts at a time.
