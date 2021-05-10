#
# Azure Functions profile.ps1
#

# Authenticate with Azure PowerShell using MSI.
if ($Env:APP_IDENTITY) {
    Connect-AzAccount -Identity -AccountId $Env:APP_IDENTITY
}

Set-AzContext -Subscription $Env:APP_SUBSCRIPTION;

class App {
    static [Microsoft.ApplicationInsights.TelemetryClient] $Telemetry
    static [Hashtable] $Globals

    static App() {
        [App]::Telemetry = [Microsoft.ApplicationInsights.TelemetryClient]::new();
        [App]::Telemetry.InstrumentationKey = $Env:APPINSIGHTS_INSTRUMENTATIONKEY;
        [App]::Globals = @{};
    }

    static [System.Collections.Generic.Dictionary[[String], [String]]] CreatePropertyBag()
    {
        return [System.Collections.Generic.Dictionary[[String], [String]]]::new();
    }

    static [void] Flush()
    {
        [App]::Telemetry.Flush();
        Start-Sleep -Seconds 5;
    }
}
