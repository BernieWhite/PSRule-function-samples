# Copyright (c) Bernie White.
# Licensed under the MIT License.

Export-PSRuleConvention 'AzurePolicy_Collect' -Begin {
    $name = $TargetObject.name;
    if ([String]::IsNullOrEmpty($name)) {
        $name = $TargetObject.ResourceGroupName;
    }

    if ($name) {
        $summary = Get-AzPolicyStateSummary -ResourceGroupName $name;

        $policy_compliant_count = 0;
        $policy_noncompliant_count = 0;
        $policy_exempt_count = 0;

        $summary.Results.ResourceDetails | ForEach-Object {
            if ($_.ComplianceState -eq 'compliant') {
                $policy_compliant_count += $_.Count;
            }
            elseif ($_.ComplianceState -eq 'noncompliant') {
                $policy_noncompliant_count += $_.Count;
            }
            elseif ($_.ComplianceState -eq 'exempt') {
                $policy_exempt_count += $_.Count;
            }
        }

        $PSRule.Data['policy_state'] = $True;
        $PSRule.Data['policy_compliant_count'] = $policy_compliant_count;
        $PSRule.Data['policy_noncompliant_count'] = $policy_noncompliant_count;
        $PSRule.Data['policy_exempt_count'] = $policy_exempt_count;
        $PSRule.Data['resourceId'] = $TargetObject.resourceId;
    }
}

# Synopsis: Resource groups should have no non-compliant policies.
Rule 'RG.Compliance' -If { $PSRule.Data.ContainsKey('policy_state') } {
    $Assert.LessOrEqual($PSRule, 'Data.policy_noncompliant_count', 0);
}
