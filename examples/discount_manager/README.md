## Hubspot Discount Manager

This use case demonstrates how the `hubspot.crm.commerce.discounts` API can be used to create and manage a discount. This example involves a sequence of actions that leverage the Ballerina "Hubspot CRM Discount connector" to demonstrate the process of creating, fetching, updating and archiving discounts.

## Prerequisites

### 1. Setup the Hubspot developer account

Refer to the [Setup guide](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.commerce.discounts/main/README.md#setup-guide) to obtain necessary credentials (client Id, client secret, Refresh tokens).

### 2. Configuration

Create a `Config.toml` file in the example's root directory and, provide your Hubspot account related configurations as follows:

```toml
clientId = "<Client ID>"
clientSecret = "<Client Secret>"
refreshToken = "<Access Token>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```