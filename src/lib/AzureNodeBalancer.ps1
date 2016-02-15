<#
        .Synopsis
        This script automatically scales Azure Nodes

        .Parameter Scheduler
        Determines the scheduler used - defaults to the environment variable
        
        .Example
        Azure Node Balancer.ps1

        .Notes
         

        .Link
        www.excelian.com
#>    
[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
[String]
$Scheduler = $env:CCP_SCHEDULER
)

Try{
    Import-Module -Name .\MicrosoftHPCServerTools.psm1  -Force -ErrorAction SilentlyContinue
    Import-Module -Name .\lib\MicrosoftHPCServerTools.psm1  -Force -ErrorAction SilentlyContinue
    Import-Module -Name .\deployed-bundles\MicrosoftHPCApp-2.0\lib\MicrosoftHPCServerTools.psm1 -Force -ErrorAction SilentlyContinue
    Add-PSSnapin Microsoft.hpc
}

Catch [System.Exception]{
    Write-LogError $Error.ToString()
    $Error.Clear()
}

$elapsed = [System.Diagnostics.Stopwatch]::StartNew()
Write-LogInfo "Starting Autoscaling"

While($elapsed.Elapsed.Hours -lt 1){

    Invoke-HPCClusterHybridAutoScaler -Scheduler $Scheduler -InitialNodeGrowth 10 -NodeGrowth 5 -UndeployAzure $True -Logging $False -SwitchInternalNodeTemplates $False 

    sleep 60

}
Write-LogInfo "Hour has elapsed. Restarting"
