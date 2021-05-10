# Azure Function samples using PSRule

This repository contains sample code for using PSRule with Azure Functions.

## Disclaimer

This project is **not a supported product**.

However if you have a specific issue you can log an [issue] on GitHub.
If you do not see your problem captured, please file a new issue.

If you have any problems with the [PSRule][engine] engine, please check the project GitHub [issues](https://github.com/Microsoft/PSRule/issues) page instead.

## Getting started

This function code included in this repository runs on an Azure Function running PowerShell 7.
This repository includes the following functions:

- `policy-history` - Captures Azure Policy compliance state by Resource Group.
  - Collected compliance state is stored within a Log Analytics workspace.
  - This function is scheduled to trigger once a day.

### Function Configuration

The following application configuration settings need to be set.

Setting                          | Description
-------                          | -----------
`APP_IDENTITY`                   | The client Id of a Managed Identity resource, configured as a User Assign Managed Identity for the Function App. This Managed Identity requires permission assigned to view policy compliance and list workspace keys for the Log Analytics workspace where compliance data will be logged.
`APP_SUBSCRIPTION`               | The subscription Id of the default Azure subscription where the policy history Log Analytics workspace resides.
`APPINSIGHTS_INSTRUMENTATIONKEY` | An Application Insights instrumentation key for monitoring.
`POLICY_HISTORY_RESOURCE_GROUP`  | The name of the Resource Group where the Log Analytics workspace resides.
`POLICY_HISTORY_WORKSPACE_NAME`  | The name of the Log Analytics workspace that will store compliance data.

## Maintainers

- [Bernie White](https://github.com/BernieWhite)

## License

This project is [licensed under the MIT License](LICENSE).

[engine]: https://github.com/Microsoft/PSRule
[issue]: https://github.com/BernieWhite/PSRule-function-samples/issues
