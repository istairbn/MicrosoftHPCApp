<#
    .Synopsis
    This gets the current Windows Event View events. 
    
    .Parameter Wait
    Length of the Loop

#>
[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)]
[int]
$Wait = 60
)

while(1) {
    
    $SINCE = (get-date).addseconds(-1 * $wait)
    
    Write-Verbose ">>> getting:"

    Try{
	    If($OUT = Get-Winevent -logname  "Microsoft-HPC-Scheduler/Operational" | where {$_.timecreated -ge $SINCE}){
    
            foreach ($RECORD in $OUT){
                if (!$RECORD.Message.Contains("was modified by")) { 
                    $timestamp = $RECORD.TimeCreated.ToString("yyyy/MM/dd HH:mm:ss zzz")
                    $LOG = $timestamp  + "," + $RECORD.Id  + "," + $RECORD.LevelDisplayName  + "," + $RECORD.Message 
                    Write-Output $LOG
                }
             }
         }
         Else{
            Write-Verbose "None found"
         }
         Write-Verbose ">>> sleep:"
	}

    Catch [System.Exception]{
        Write-Error $Error.ToString() 
        $Error.Clear()
    }

	Sleep $wait
}
