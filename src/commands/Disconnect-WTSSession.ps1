#Requires -Version 5

using namespace System;
using namespace System.Collections.Generic;
using namespace System.Runtime.InteropServices;

Set-StrictMode -Version 'Latest';

function Disconnect-WTSSession {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Computer that the user is logged into to.')]
        [string] $ComputerName = [Environment]::MachineName,

        [Parameter(Mandatory = $true, HelpMessage = 'Session ID of the user to disconnect.')]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $SessionId,

        [Parameter(Mandatory = $false, HelpMessage = 'Wait for session disconnection.')]
        [switch] $Wait
    );
    begin {
        [List[PSCustomObject]] $results = @();
    } process {
        [IntPtr] $handle = [wtsapi]::WTSOpenServer($ComputerName);
        [bool] $disconnected = [wtsapi]::WTSDisconnectSession($handle, $SessionId, $WaitForResponse.ToBool());
        [PSCustomObject] $result = [PSCustomObject] @{
            SessionId    = $SessionId;
            Disconnected = $disconnected;
        };
        [void] $results.Add($result);
        [void] [wtsapi]::WTSCloseServer($handle);
        $handle = [IntPtr]::Zero;
    } end {
        return $results.ToArray();
    }
}
