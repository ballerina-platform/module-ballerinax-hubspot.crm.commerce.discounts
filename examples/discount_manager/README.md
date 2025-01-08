## Hubspot Discount Manager

This use case demonstrates how the `hubspot.crm.commerce.discounts` API can be used to create and manage a discount. This example involves a sequence of actions that leverage the Hubspot CRM API v3 to demonstrate the process of creating, fetching, updating and archiving discounts.

## Prerequisites

### 1. Setup the Hubspot developer account

Refer to the [Setup guide](./../../README.md) to obtain necessary credentials (client Id, client secret, Refresh tokens).

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