
function Get-LocalAccounts {
    $localAccs = Get-CimInstance -classname win32_account -computername localhost
    # needs service not running on my machine
    Write-Host $localAccs
    
}
function Get-LoggedInUser { 
    $loggedInUser = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, UserName, PrimaryOwnerName,
    Domain, totalphysicalmemory, Model, manufacturer
    Write-Host $loggedInUser | Format-Table
    
}
function Get-NetworkConnection {
    $RemoteHost = Read-Host "Do you want to specify a remote host IP (you must also have a remote port)? Enter IP or no"
    $RemotePort = Read-Host "Do you want to specify a remote port? Enter port or no"

    if (($RemoteHost -ne "no") -And ($RemotePort -ne "no")){
        $netCon = Get-NetTCPConnection -RemoteAddress $RemoteHost -RemotePort $RemotePort | Select-Object CreationTime, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, State
    } else {
        $netCon = Get-NetTCPConnection | Select-Object CreationTime, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, State
    }
    Write-Host $netCon
    
}
function Get-NetworkShares {
    $netShares = Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\" | Select-Object PSChildName
    Write-Host $netShares
}
function Get-RunningProcesses{
    $ProcessID = Read-Host "Specify a process ID? Enter ID or no"
    if ($processID -ne "no") {
        $procs = Get-Process | Select-Object StartTime, ProcessName, ID, Path | Where-Object Id -eq $ProcessID
    } else {
        $procs = Get-Process | Select-Object StartTime, ProcessName, ID, Path
    }
    Write-Host $procs
}
function Get-AutomaticServices {
    $autoServices = Get-Service | Select-Object Name, DisplayName, Status, StartType | Where-Object StartType -eq "Automatic"
    Write-Host $autoServices 
}
function Get-ParentProcessesAndCommandLines {
    $ProcessID = Read-Host "Specify a process ID? Enter ID or no"
    if ($processID -ne "no") {
        $procAndParentCMD = Get-CimInstance -ClassName Win32_Process | Select-Object CreationDate, ProcessName, ProcessID, COmmandLine, ParentProcessId | Where-Object ProcessID -eq $ProcessID
    } else {
        $procAndParentCMD = Get-CimInstance -ClassName Win32_Process | Select-Object CreationDate, ProcessName, ProcessID, COmmandLine, ParentProcessId
    }
    
    Write-Host $procAndParentCM
}
function Get-ScheduledTasks {
    $schedTasks = Get-ScheduledTask | Select-Object TaskName, TaskPath, Date, Author, Actions, Triggers, Description, State | where Author -NotLike 'Microsoft*' | where Author -ne $null | where Author -NotLike '*@%SystemRoot%\*'
    $schedTasks
}
function Get-HashOfFile {
    $pathtohash = Read-Host "Enter path to file"
    $fileHash = Get-FileHash $pathtohash -Algorithm SHA256
    Write-Host $fileHash
}
function Get-AlternativeDataStreams {
    $PathToAlternativeDataStream = Read-Host "Enter path to file"
    $ADS = Get-Item $PathToAlternativeDataStream -Stream *
    Write-Host $ADS 
    # Get-Item $PathToAlternativeDataStream * | where Stream -ne ':$DATA'
}
function Get-ADSStreamContent {
    $PathToADSStream = Read-Host "Enterpath to file"
    $StreamName = Read-Host "Enter Stream Name"
    if ($PathToADSStream -and $StreamName) {
        $streamConent = Get-Content $PathToADSStream -Stream $StreamName
        Write-host $streamConent
    } else {
        Write-Host "Error: No file/stream relationship found"
    }
}
function Get-FileAnalysis {
    $filepath = Read-Host "Enter path to file"
    $answer = Read-Host "Do you want the hex format? Enter yes or no"
    if ($answer -eq "yes"){
        $fileContent = get-content $filepath | Format-Hex
    } else {
        $fileContent = get-content $filepath
    }
    Write-Host $fileContent
}
function Get-DecodedData {
    $Base64Data = Read-Host "Enter Base64 string"
    $b64Decoded = [System.Text.Encoding]::ascii.GetString([System.Convert]::FromBase64String($Base64Data))
    $b64Decodedhex = [System.Text.Encoding]::ascii.GetString([System.Convert]::FromBase64String($Base64Data)) | Format-Hex
    
    write-host $b64Decoded
    Write-Host $b64Decodedhex

}
function Get-ParentProcessesAndCommandLines {
$RunningProcesses = Get-CimInstance -classname Win32_Process | `
Select-Object CreationDate, ProcessName, ProcessID, COmmandLine, ParentProcessId

for ($i=0;$i -le $RunningProcesses.count; $i++) {
    Write-host $RunningProcesses[$i]

    Write-Host("Parent")
    Write-Host (Get-CimInstance -ClassName Win32_Process | Where-Object ProcessID -eq $runningprocesses[$i].ParentProcessId).ProcessName
    Write-Host("Parent CmdLine:")
    Write-Host (Get-CimInstance -ClassName Win32_Process | Where-Object ProcessId -eq $runningprocesses[$i].ParentProcessId).CommandLine
    Write-Host("Parent Process Name")
    Write-Host("-----------------------------")
    }
}
function Get-TCPConnectionsAndCommandLines {
        $TCPConns = Get-NetTCPConnection | `
        Select-Object CreationTime, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, State

    for($i=0;$i -le $TCPConns.count; $i++) {
        Write-Host $TCPConns[$i]

        Write-Host("Process:")
        Write-Host (Get-CimInstance -classname Win32_Process | Where-Object ProcessId -eq $TCPConns[$i].OwningProcess).ProcessName
        Write-Host("CmdLine:")
        Write-Host (Get-CimInstance -ClassName Win32_Process | Where-Object ProcessId -eq $TCPConns[$i].OwningProcess).CommandLine
        Write-Host("-------------------------")
    }
}
function Get-UDPConnectionsAndCommandLines {
    $UDPConns = Get-NetUDPEndpoint | `
    Select-Object CreationTime, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, State

    for ($i=0;$i -le $UDPConns.count; $i++) {
        Write-host $UDPConns[$i]

        Write-Host("Process:")
        Write-Host (Get-CimInstance -ClassName Win32_Process | Where-Object ProcessId -eq $UDPConns[$i].OwningProcess).ProcessName
        Write-Host("CmdLine:")
        Write-Host (Get-CimInstance -classname Win32_Process | Where-Object ProcessId -eq $UDPConns[$i].OwningProcess).CommandLine
        Write-Host("------------------------")
    }
}
function Get-UnusualExecutables {
    $ignore_extensions = '.exe','dll'

    $DirectoryPath = Read-Host "Enter Directory path"
    $directoryFiles = Get-ChildItem $DirectoryPath
    Write-Host("Number of files/folder:")$directoryFiles.count
    $count_suspect = 0

    for ($i=0;$i -lt $directoryFiles.count; $i++) {
        if ( (Test-path $directoryFiles[$i] -PathType Leaf) -and ($directoryFiles[$i].Extension -notin $ignore_extensions)) {
            $magicBytes = '{0:X2}' -f (Get-Content $directoryFiles[$i] -AsByteStream -readcount 4)
            if ($magicBytes -eq '4D 5A 90 00') {
                write-host ("Found atypical file:")$directoryFiles[$i]
                $count_suspect++
            }
        }
    }

    Write-Host("Number of atypical executables found:")$count_suspect
}

# Wrapped the switch case in a function, moved Read-Host to Write-Host only to "read" the users input 
# i've had situations where read-host can cause odd behaviors with large text blocks like this

function Invoke-Hunt {
    Write-Host ("welcome")
    $SelectedAdventure = Write-Host "Choose your adventure:
    1: Get local account information
    2: Get Current Logged In User
    3: Get Network Activity
    4: Get Network Shares
    5: Get Running Processes
    6: Get Automatic Services
    7: Get Parent Processes and Command Lines
    8: Get Suspicious Scheduled Tasks
    9: Collect a file's hash
    10: Evaluate file's Alternative Data Stream
    12: Evaluate a file's ADS' Data
    13: Collect a file's content
    14: Decode Base64 String
    15: Get Parent/Child Process Relationships
    16: Get TCP Connections, their processes, and command lines
    17: Get UDP Connections, their processes, and command lines
    18: Get Executable with atypical extensions (anything other than .exe and .dll)
    99: Exit"

    # grab user input
    $SelectedAdventure = read-host
    Switch ($SelectedAdventure) {
        1 {Get-LocalAccounts}
        2 {Get-LoggedInUser}
        3 {Get-NetworkConnection}
        4 {Get-NetworkShares}
        5 {Get-RunningProcesses}
        6 {Get-AutomaticServices}
        7 {Get-ParentProcessesAndCommandLines}
        8 {Get-ScheduledTasks}
        9 {Get-HashOfFile}
        10 {Get-AlternativeDataStreams}
        12 {Get-ADSStreamContent}
        13 {Get-FileAnalysis}
        14 {Get-DecodedData}
        15 {Get-ParentProcessesAndCommandLines}
        16 {Get-TCPConnectionsAndCommandLines}
        17 {Get-UDPConnectionsAndCommandLines}
        18 {Get-UnusualExecutables}
        99 {Write-Host "Thank you"; Exit} #break out of while loop
    }
} 

while ($true) {
    Invoke-Hunt
}
