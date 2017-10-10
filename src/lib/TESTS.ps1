
<#
    .Synopsis
    This takes a list of nodes and grows them according to the scaling parameters given. Works with Azure AND ComputeNodes  
    
    .Parameter LogFilePrefix
    Determines the prefixed log name

    .Parameter Logging
    Boolean whether or not to create a log or just display host output

   .Parameter CallQueueThreshold
    The number of queued calls required to set off a growth of Nodes.Default is 2000

   .Parameter GridMinsRemainingThreshold
    The time in minutes, of remaining Grid work. If this threshold is exceeded, more Nodes will be allocated. Default is 30

    .Parameter ExcludedNodes
    Nodes you do not want touched.
     
    .Parameter $NodeGroup
    Which Nodes can be grown. Defaults to AzureNodes AND ComputeNodes. If you only want to grow one type, select this. 
    
    .Parameter NodeTemplates
    Used to specify growing only a certain type of Nodes. 
    
    .Paramaeter NodeGrowth
    How many Nodes per JobTemplate will be turned on

    .Parameter Scheduler
    Determines the scheduler used - defaults to the environment variable

    .Parameter Start-HPCClusterNodes
    Assuming more than 1 node currently exists (i.e. the Grid is currently running) how much more should be assigned.

    .Example
    To autoscale your Azure Nodes up: Start-HPCClusterNodes -NodeGroup AzureNodes
    
    .Notes
    Scales the grid up as and when required. If you have an agnostic Grid (all services can run on all nodes) this will be sufficient - if you have more complex needs you can pass the Nodes as NodesToGrow and scale up gradually.

    .Link
    www.excelian.com
#>
    Param(
        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
        [string]
        $LogFilePrefix,

        [Parameter (Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [bool] 
        $Logging=$False,

        [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
        [string]
        $Scheduler = $env:CCP_SCHEDULER,

        [Parameter (Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [String[]] 
        $NodeGroup="AzureNodes,ComputeNodes",

        [Parameter (Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [String[]] 
        $ExcludedNodes=@(),

        [Parameter (Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [String[]] 
        $NodeTemplates,
            
        [Parameter (Mandatory=$False)]
        [ValidateRange(0,100)]
        [Int] 
        $TemplateUtilisationThreshold,

        [Parameter (Mandatory=$False)]
        [ValidateRange(0,[Int]::MaxValue)]
        [Int] 
        $CallQueueThreshold=2000,

        [Parameter (Mandatory=$False)]
        [ValidateRange(0,[Int]::MaxValue)]
        [Int] 
        $JobQueueThreshold=1,

        [Parameter (Mandatory=$False)]
        [ValidateRange(0,[Int]::MaxValue)]
        [Int] 
        $GridMinsRemainingThreshold= 20,

        [Parameter (Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [String[]] 
        $ExcludedNodeTemplates = @(),

        [Parameter (Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
        [int] 
        $NodeGrowth = 5
    )

    Try{
    Import-Module -Name .\MicrosoftHPCServerTools.psm1  -Force -ErrorAction SilentlyContinue
    Import-Module -Name .\lib\MicrosoftHPCServerTools.psm1  -Force -ErrorAction SilentlyContinue
    Import-Module -Name .\deployed-bundles\HPCHybridAutoScalerApp-2.0\lib\MicrosoftHPCServerTools.psm1 -Force -ErrorAction SilentlyContinue
    Add-PSSnapin Microsoft.hpc
}Catch [System.Exception]{    Write-LogError $Error.ToString()    $Error.Clear()}
    $NodesCheck = Get-HPCClusterNodesToGrowByTemplate -Scheduler $Scheduler -jobTemplates $jobTemplates `    -InitialNodeGrowth $InitialNodeGrowth -ExcludedNodes $ExcludedNodes -NodeGroup $NodeGroup `    -NodeGrowth $NodeGrowth -CallQueueThreshold $CallQueueThreshold -NumOfQueuedJobsToGrowThreshold $JobQueueThreshold `    -GridMinsRemainingThreshold $GridMinsRemainingThreshold -NodeTemplates $NodeTemplates -ExcludedNodeTemplates $ExcludedNodeTemplates `    -ExcludedGroups $ExcludedGroups -TemplateUtilisationThreshold $TemplateUtilisationThreshold `    -Logging $Logging -LogFilePrefix $LogFilePrefix    $NodesCheck.Count    If(@($NodesCheck).Count -gt 0){        Write-Host YEAH
        #Start-HPCClusterNodes -NodesToGrow $NodesCheck -LogFilePrefix $LogFilePrefix -Logging $Logging -Scheduler $Scheduler
    }
    Else{
        Write-LogInfo -Logging $Logging -LogFilePrefix $LogFilePrefix -message "No Nodes to Grow"
    }