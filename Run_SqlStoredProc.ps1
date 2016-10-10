<#
.SYNOPSIS
    Runs the specified SQL Server stored proceedure.

.DESCRIPTION
    This runbook will run a stored procedure on a SQL server and return the results. 

    In order for this runbook to work, the SQL Server must be accessible from the runbook worker
    running this runbook. Make sure the SQL Server allows incoming connections from Azure services
    by selecting 'Allow Windows Azure Services' on the SQL Server configuration page in Azure.

    This runbook also requires an Automation Credential asset be created before the runbook is
    run, which stores the username and password of an account with access to the SQL Server.
    That credential should be referenced for the SqlCredential parameter of this runbook.

    More information about Powershell Workflows can be found here: 
    https://blogs.technet.microsoft.com/heyscriptingguy/2012/12/26/powershell-workflows-the-basics/ 

.PARAMETER SqlServer
    String name of the SQL Server to connect to

.PARAMETER SqlServerPort
    Integer port to connect to the SQL Server on

.PARAMETER Database
    String name of the SQL Server database to connect to

.PARAMETER Proc
    String name of the stored proceedure to run including any arguments

.PARAMETER SqlCredential
    PSCredential containing a username and password with access to the SQL Server  

.EXAMPLE
    Run_SqlStoredProc -SqlServer "somesqlserver.cloudapp.net" -SqlServerPort 1433 -Database "SomeDatabaseName" -Proc "SomeSP arg1 arg2" -SqlCredential $SomeSqlCred

.NOTES
    AUTHOR: Scott Semyan
    LASTEDIT: Sept 28, 2016 
#>

param(
    [parameter(Mandatory=$True)]
    [string] $SqlServer,
        
    [parameter(Mandatory=$False)]
    [int] $SqlServerPort = 1433,
        
    [parameter(Mandatory=$True)]
    [string] $Database,
        
    [parameter(Mandatory=$True)]
    [string] $ProcCommand,
        
    [parameter(Mandatory=$True)]
    [PSCredential] $SqlCredential
)

# Get the username and password from the SQL Credential
$SqlUsername = $SqlCredential.UserName
$SqlPass = $SqlCredential.GetNetworkCredential().Password
    
# Define the connection to the SQL Database
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")
        
# Open the SQL connection
$Conn.Open()

# Define the SQL command to run. In this case we are getting the number of rows in the table
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec dbo.$ProcCommand", $Conn)
$Cmd.CommandTimeout=120

# Execute the SQL command
$Ds=New-Object system.Data.DataSet
$Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
[void]$Da.fill($Ds)

# Output the results
$Ds.Tables[0]

# Close the SQL connection
$Conn.Close()
