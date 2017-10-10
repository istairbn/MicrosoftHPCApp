;/**
 * This script sends a SQL request for the current data from the HPCScheduler.Job database .
 * It counts all the Calls that are currently running and gives total stats
 * It checks to see if today's filename exists - if it does it will not overwrite the data. If it doesn't exist, it will create it!
 * Takes SQL location from SQLconfig.properties or other file specified in argument
 * User: Ben Newton
 * Date: 18/03/2015
 * Time: 09:11
 * 
 */

import java.sql.Connection
import java.sql.DriverManager
import javax.sql.DataSource
import groovy.sql.Sql
import java.lang.reflect.Field

System.setProperty("java.library.path", "./lib");
 Field fieldSysPath = ClassLoader.class.getDeclaredField( "sys_paths" );
fieldSysPath.setAccessible( true );
fieldSysPath.set( null, null );

Properties properties = new Properties()
def props = args.length > 0 ? ".\\lib\\" + args[0] : ".\\lib\\SQLconfig.properties"
def propertiesFile = new File(props)

if (propertiesFile.exists()){
    propertiesFile.withInputStream{
        properties.load(it)
        }
    }

else
    {
    println "No Properties File Present"
    println System.getProperty("user.dir")
    return 0
    }

def host = properties.dbHost
def instance = properties.dbInstance
def security = properties.security
def user = properties.user
def pwd = properties.password

pout = pout == null ? System.out : pout
perr = perr == null ? System.err : perr

dbDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"

def sqlConnect ="jdbc:sqlserver://$host;instanceName=$instance;DatabaseName=HPCScheduler;integratedSecurity=$security"

conn= sqlConnect


def propertyMissing (String name) {}

def log( line ){
    dt = new Date()
    timestamp = String.format('%1$row.te-%1$row.tb-%1$row.ty %tT',dt)
    pout <<  "" + timestamp + "\t" + line  + "\n"
}


def stdOut = pout
def stdErr = perr


def driver = Class.forName(dbDriver).newInstance();


def conn = DriverManager.getConnection(conn,user,pwd)


def getHPCLiveCallIndividuals(sql){

    query="SELECT SYSDATETIMEOFFSET() AS 'Timestamp', J.ID, ISNULL(J.NumberOfCalls,0) AS TotalCalls,ISNULL(J.NumOfOutstandCalls,0) AS QueuedCalls,ISNULL(J.NumberOfCalls - J.NumOfOutstandCalls,0) AS CompletedCalls, J.CallsPerSecond,J.CallDuration,J.Progress, ISNULL(DATEDIFF(MS,J.CreateTime,J.SubmitTime),0) AS CR_SUB_MS, ISNULL(DATEDIFF(MS,J.SubmitTime,J.StartTime),0) AS SUB_STA_MS, ISNULL(DATEDIFF(S,J.CreateTime,GETUTCDATE()),0) AS TotalElapsedSecs, ISNULL(DATEDIFF(S,J.ChangeTime,GETUTCDATE()),0) AS ChangeElapsedSecs, T.Name as JobTemplate, J.ServiceName as ServiceName, J.Name as Name, N.Name as Project, P.Name AS Pool FROM dbo.Job J INNER JOIN JobTemplate T ON J.JobTemplateId = T.Id INNER JOIN JobProjectName N ON J.ProjectId = N.ID INNER JOIN Pool P ON J.PoolId = P.ID WHERE State < 128 ORDER BY ID"

    sql.eachRow(query){   row ->

		println ("$row.Timestamp,$row.ID,$row.TotalCalls,$row.QueuedCalls,$row.CompletedCalls,$row.CallsPerSecond,$row.CallDuration,$row.Progress,$row.CR_SUB_MS,$row.SUB_STA_MS,$row.TotalElapsedSecs,$row.ChangeElapsedSecs,$row.JobTemplate,$row.ServiceName,$row.Name,$row.Project,$row.Pool")
    }
}


try{
    def sql= new Sql(conn)
    getHPCLiveCallIndividuals(sql)
}

catch(Exception e){

    perr << e

}