<#
    .Synopsis
    This function takes two arguments: $Node and $Scheduler. If checks if a HostName ($Node) is already registered against a HPC HeadNode ($Scheduler)
    If it is, it will remove the Node. If it is not, it will do nothing. Both arguments are mandatory but acceptable from the pipeline.
    
    .Parameter Node
    The Node you want to be removed if it already exists. A String.
    
    .Parameter Scheduler
    The HPC Server Headnode. $env:CCP_Scheduler will be your environment variable. A String

    .Example
    Confirm-HPCNodeDoesNotAlreadyExist -Node SUEUC4110154 -Scheduler EURV192501  - This will remove SUEUC4110154 from the EURV192501 cluster
    
    .Notes
    ben.newton@excelian.com
    
    .Link
    www.excelian.com
#>
Function Confirm-HPCNodeDoesNotAlreadyExist{
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
    [String]
    $Node = "SUEUC4110154",

    [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
    [String]
    $Scheduler = $env:CCP_SCHEDULER
    )
    Add-PSSnapin Microsoft.Hpc
    If(Get-HpcNode $Node -Scheduler $env:CCP_SCHEDULER -ErrorAction SilentlyContinue){
        Write-Verbose "$Node exists on $Scheduler"
        Remove-HpcNode -Name $Node -Scheduler $Scheduler -Comment "Internal Cloud Deployment Requires the SID to be removed" 
    }
    Else{
        Write-Verbose "$Node does not exist on $Scheduler"
    }
}