#########################################################################
# Microsoft HPC App for Logscape
# info@logscape.com in conjunction with ben.newton@excelian.com
# This software is provided as written under the GNU license, without any warranty (express or implied) as to it's functionality.
#########################################################################

The Microsoft HPC App 2.0 is designed to provide monitoring of an HPC Server 2012 SP1 (or greater) environment. 
Note: The workspaces in this version supercede the 1.0 App. The older data types are included (marked deprecated) but they will not be used for display purposes.   

The two main sources of information: 
	-Powershell: running the cmndlet to pull data from the HeadNode. 
	-Logs: Uncompressing the HPC Server log files. 
	Deprecated
	-The old SQL scripts. These have been replaced by Powershell scripts relying on the Schedulers access

This app runs scripts and SQL queries at various times, creating output files and then allowing Logscape to ingest them directly.

The HPC LogParser is documented separately, please read the LogParserReadme.txt for details on how to configure and use it. There is also an Azure Automation script for automating your Azure deployment according to workload. Please check seperate documentation

-----------------------------------------------------------------------
MicrosoftHPCApp-2.0.bundle = A bundle file which does NOT include the HPC Log Parser or the Azure deployment automation
EXAMPLE_bundle_with_Log_Parser = A bundle file WITH an HPCParser service and Azure Automation.

If you wish to use the LogParser in batch mode, follow the separate instructions and edit the bundle file accordingly.
However, ensure that there is only one .bundle file in the app when deployed! 
-----------------------------------------------------------------------

CONFIGURATION

1. EITHER
  Edit the Bundle file to ensure you are running the scripts on the Headnode and on the preferred timeframe. If you have already configured your Headnode with headnode in the role (for example: dev.hpcheadnode.Forwarder) then it will work without configuration.  
OR
Deploy an override.properties file (sample provided) and redeploy the App
	For more on Bundle files, check the Logscape documentation.
2. If you are using the LogParser, follow the configuration in the separate documentation.

	For each script, you pick the run time and which script to run.


------------------------------------------------------------------------

OUTPUT

This app extracts a lot of data from the HPC environment. Here is a description of the types provided:

--Constant Metrics
hpc_Overview = Outputs the number of jobs in any particular state (running,submitting etc) as well as Core and Node states.
hpc_CallTotals = Summary amount of total calls and pending calls. Outputs 0 if no calls are running.
hpc_Node = For each Node, performance metrics such as cores in use and disk queue.

--Event Driven Metrics
hpc_JobHistory = For each completed Job, it's type, terminating event, run time and tasks
hpc_SchedEvents = From the Scheduler, event viewer events relating to HPC
hpc_CallIndividuals = For each running job, the progress, amount of calls completed and run time. Data only outputted when calls are running.

-- Daily Metrics
hpc_Usage = For each Day, a summary of Cluster Utilisation and Availability

hpc_Metrics = For each day, an aggregate count of jobs, calls and grid run-time in seconds and minutes for each service type.
#DEPRECATED - These stats have been moved to hpc_JobHistory


Note that this version 2 - whilst version 1 data will still be typed and ingested, the Workspaces will all use the version 2 data.
The main improvements are:
- Use of the HPCServerTools module - this abstracts the underlying logic from the Logscape scripts and centralizes it - making maintenance easier. Check out istairbn/MicrosoftHPCServerTools for the latest commits to that project. 
- Removal of SQL config dependency - the new App assumes deployment to the headnode and uses the database connection permissions that the Scheduler uses. 
