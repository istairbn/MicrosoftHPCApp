Try{
    Add-PSSnapin Microsoft.Hpc
}
Catch{
    Write-Error "Not an HPC Node"
    Exit 1
}
Function Repair-PerfCounters{
    [CmdletBinding()]
    Param()
    $HPCServices = Get-Service -Name *HPC*
    Write-Verbose "Rebuilding Counters"
    $Expression = 'lodctr /R'
    Invoke-Expression $Expression -ErrorAction SilentlyContinue
    Invoke-Expression $Expression
    $HPCServices = Get-Service -Name *HPC*
    Write-Verbose "Restarting Services"
    restart-service $HPCServices
}

$Test = Get-HpcMetricValue -NodeName $Env:COMPUTERNAME -Name HPCCoresInUse -ErrorAction SilentlyContinue
If($Test.Value -eq $Null){
    $Work = Get-Process -Name HpcServiceHost*

    If(@($Work).count -eq 0){
        Write-Verbose "PerfCounters being Repaired"
        Repair-PerfCounters -verbose
    }
    Else{
        Write-Verbose "PerfCounters need repair, work in progress"
    }
}
Else{
    Write-Verbose "PerfCounters Working"
}