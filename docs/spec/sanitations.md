_Author_:  @Pranavan-S \
_Created_: 2024/12/17 \
_Updated_: 2025/01/09 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from HubSpot CRM Commerce Discounts. 
The OpenAPI specification is obtained from [Hubspot Public API Spec Collection](https://github.com/HubSpot/HubSpot-public-api-spec-collection/blob/main/PublicApiSpecs/CRM/Discounts/Rollouts/424/v3/discounts.json).
These changes are implemented to enhance the overall usability and readability of the generated client.

1. `date-time` type mentioned in `discounts.json` was changed to `datetime`.
2. **Change the `url` property of the `servers` object**:
    - **Original**: `https://api.hubapi.com`
    - **Updated**: `https://api.hubapi.com/crm/v3/objects/discounts`
    - **Reason**: This change is made to ensure that all API paths are relative to the versioned base URL (crm/v3/objects/discounts), which improves the consistency and usability of the APIs.

3. **Update API Paths**:
    - **Original**: Paths included the version prefix in each endpoint (e.g., `/crm/v3/objects/discounts`)
    - **Updated**: Paths are modified to remove the version prefix from the endpoints, as it is now included in the base URL. For example:
        - **Original**: `/crm/v3/objects/discounts/[discountId]`
        - **Updated**: `/[discountId]`
    - **Reason**: This modification simplifies the API paths, making them shorter and more readable. It also centralizes the versioning to the base URL, which is a common best practice.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/discounts.json --mode client --license docs/license.txt -o ballerina 
```
