# Copyright (c) Bernie White.
# Licensed under the MIT License.

param($Timer)

Write-Host 'Running policy-history';
$tc = [App]::Telemetry;

$context = Get-AzContext;
Write-Host "Using Azure Subscription: $($context.Subscription.Name)";

$ResourceGroupName = $Env:POLICY_HISTORY_RESOURCE_GROUP;
$WorkspaceName = $Env:POLICY_HISTORY_WORKSPACE_NAME;
Write-Host "Using Azure Log Analytics workspace: $ResourceGroupName/$WorkspaceName";

function GetResourceGroupSummary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspaceId,

        [Parameter(Mandatory = $True)]
        [securestring]$WorkspaceKey
    )
    process {
        $assertParams = @{
            Module = 'Azure.PolicyInsights'
            ResultVariable = 'results'
            Convention = 'AzurePolicy_Collect'
            Option = @{
                'Binding.TargetType' = 'Type', 'ResourceType'
                'Binding.TargetName' = 'Name', 'ResourceGroupName'
                'Binding.Field'      = @{
                    resourceId       = 'resourceId', 'id'
                }
            }
        }
        $subscriptionContext = @(Get-AzContext -ListAvailable);
        foreach ($profile in $subscriptionContext) {
            $rg = @(Get-AzResourceGroup -DefaultProfile $profile | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'Microsoft.Resources/resourceGroups' -PassThru);
            $rg | Assert-PSRule @assertParams -ErrorAction SilentlyContinue;
            $results | Send-PSRuleMonitorRecord -WorkspaceId $WorkspaceId -SharedKey $WorkspaceKey;
        }
    }
}

try {
    Import-Module -Name Azure.PolicyInsights;

    if ([String]::IsNullOrEmpty($WorkspaceName)) {
        throw 'Workspace not found';
    }

    $WorkspaceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName).CustomerId;
    if ([String]::IsNullOrEmpty($WorkspaceId)) {
        throw 'Workspace not found';
    }
    $WorkspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroupName -Name $WorkspaceName).PrimarySharedKey | ConvertTo-SecureString -Force -AsPlainText;

    GetResourceGroupSummary -WorkspaceId $WorkspaceId -WorkspaceKey $WorkspaceKey -Verbose:$VerbosePreference;
}
finally {
    [App]::Flush();
}
