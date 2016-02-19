#------------------------------------------------------------------------------
#Script: ResetToHome.ps1
#Author: Benjamin Newton - Excelian 
#Version 1.0.0
#Keywords: HPC,Hybrid Environment, Auto grow and Shrink,Reset 
#Comments:This sets the Rabo Internal Environment to a balanced one. 
#-------------------------------------------------------------------------------

<# 
   .Synopsis 
    If the Grid is quiet, this will balance the UAT Grid equally

    .Parameter $NodeGroup
    Which Nodes can be affected. Defaults to InternalCloudNodes and ComputeNodes

    .Parameter ExcludedNodes
    Determines which Nodes will be excluded from the calculation

    .Parameter ExcludedGroups
    This function excludes groups 1-9 as they are descripive (ComputeNodes,AzureNodes). If you have other descriptive groups, excluding them means that the script will not treat them as active/passive for later calculation.

   .Parameter Logging
    Whether the script creates a Log file or not - location determined by the LogFilePrefix. Default is True

   .Parameter LogFilePrefix
    Specifies the prefix name of the log file, you can include the path, by default the log will be in current working directory

   .Notes 
    The prerequisites for running this script include the Module

   .Link 
   www.excelian.com
#>


Param(
[CmdletBinding()]
[Parameter (Mandatory=$False)]
[bool]
$Logging=$False,

[Parameter (Mandatory=$False)]
[String]
$LogFilePrefix="ResetToHome",

[Parameter (Mandatory=$False)]
[string[]]
$NodeGroup = @("InternalCloudNodes","ComputeNodes"),

[Parameter (Mandatory=$False)]
[string[]]
$ExcludedGroups = @("InternalCloudNodes"),

[Parameter (Mandatory=$False)]
[string[]]
$ExcludedNodes=@("CDCS192510","CDCS192515","CDCS192516")
)

Try{
Import-Module -Name .\deployed-bundles\HPC_Hybrid_AutoscalerApp-1.0\lib\HPCServer_AutoScaleTools.psm1 -ErrorAction SilentlyContinue -Force
#Import-Module -Name .\HPCServer_AutoScaleTools.psm1 -ErrorAction SilentlyContinue -Force
Add-PSSnapIn Microsoft.HPC;
}
Catch [System.Exception]{
    LogError -message $Error -Logging $Logging -LogFilePrefix $LogFilePrefix
    $error.Clear()
}
LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Msg:`"Commencing reset check"
LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:ParamCheck ExcludedNodes:$ExcludedNodes ExcludedGroups:$ExcludedGroups NodeGroup:$NodeGroup"
$Status = ClusterStatus -ExcludedGroups $ExcludedGroups -ExcludedNodes $ExcludedNodes -Logging $Logging -LogFilePrefix $LogFilePrefix

Try{
If($Status.BusyCores -eq 0){
    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Reset:TRUE"
    $AllCompute = Get-HpcNode -GroupName $NodeGroup -Name $Status.IdleNodes.Split(",") | Sort-Object -Property NetBiosName
    #$AllCompute
    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:SETOFFLINE"
    Set-HpcNodeState -State offline -Node $AllCompute

    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:GroupStrip"
    StripGroups -LogFilePrefix $LogFilePrefix -Logging $Logging -NodesToGrow $AllCompute -ExcludedGroups $ExcludedGroups
    
    $NodeCount = [Math]::Floor($AllCompute.Count / 3)
    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "NodesPerTemplate:$NodeCount"
    $Group1 = @()
    $Group2 = @()
    $Group3 = @()

    ForEach($Node in $AllCompute[0..($NodeCount-1)]){
        
        $Group1 += $Node
        $Template1 = Get-HpcNodeTemplate -Name PPQ_SRE_PREPROD_ComputeNode
    }
    
    ForEach($Node in $AllCompute[$NodeCount..($NodeCount+($NodeCount-1))]){
        $Group2 += $Node
        $Template2 = Get-HpcNodeTemplate -Name PPQ_SRE_UAT1_ComputeNode
    }

    ForEach($Node in $AllCompute[($NodeCount+$NodeCount)..$AllCompute.Count]){
        $Group3 += $Node
        $Template3 = Get-HpcNodeTemplate -Name PPQ_SRE_UAT2_ComputeNode
    }
    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:Node-Reassignment"
    Assign-HpcNodeTemplate -Template $Template1 -Node $Group1 -Confirm:$False
    Assign-HpcNodeTemplate -Template $Template2 -Node $Group2 -Confirm:$False
    Assign-HpcNodeTemplate -Template $Template3 -Node $Group3 -Confirm:$False

    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:Group-Reassignment"

    Add-HpcGroup -Node $Group1 -Name PPQ_SRE_PREPROD,SOPHIS 
    Add-HpcGroup -Node $Group2 -Name PPQ_SRE_UAT1,SOPHIS
    Add-HpcGroup -Node $Group3 -Name PPQ_SRE_UAT2,SOPHIS

    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Action:Complete"

}
Else{
    LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "Reset:FALSE"
}
}
Catch [System.Exception]{
    LogError -message $Error -LogFilePrefix $LogFilePrefix -Logging $Logging
    $Error.Clear()
}