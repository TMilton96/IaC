# This script is for an automation runbook that parses webhook data using regex to find app services in a down state and restart the specified service.
param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)

# Collect properties of WebhookData.
$WebhookName    =   $WebhookData.WebhookName
$WebhookBody    =   $WebhookData.RequestBody
$WebhookHeaders =   $WebhookData.RequestHeader

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

try
{
    # Information on the webhook name that called This
    Write-Output "This runbook was started from webhook $WebhookName."

    # Obtain the WebhookBody containing the AlertContext
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookBody)
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$target_id = $WebhookBody.data.essentials.alertTargetIDs[0]

$temp = $target_id.Substring($target_id.IndexOf("groups/") + 7)

$rg_name = $temp.Split("/")[0]
$vm_name = $target_id.Substring($target_id.IndexOf("virtualmachines/") + 16)

foreach($svc in $WebhookBody.data.alertContext.condition.allOf) {
  
    foreach($sv in $svc.dimensions) {

        Write-Output "Attempting to restart service: $($sv.value)"

        $script = @"

            Function Restart-Svc($name) {

                $status = Get-Service -Name "$name"

                if ($status) {
                    Write-Output "Service is already started, nothing to do.

                    return $true
                }else{
                    Restart-Service -Force -Name "$name"

                    if (Get-Service -Name "$name") {
                        Write-Output "Service was restarted."
                        return $true
                    }else{
                        Write-Output "Service failed to start for a second time, please review why this is failing to start."
                    }
                }

                return $false
            }

            if ("$($sv.value)" -like "<provide_prefix_identifier") {

                $services = @(
                    "Provide",
                    "List of Service Names",
                    "Here"
                )

                foreach($s in $services) {
                    Restart-Svc($s)
                }

            }

"@

Start-Sleep 120

        try
        {
            Invoke-AzVMRunCommand -ResourceGroupName $rg_name -VMName $vm_name -CommandId "RunPowerShellScript" -ScriptString $script
        }
        catch {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }

    }

}