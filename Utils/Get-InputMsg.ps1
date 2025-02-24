
function Get-InputMsg {
    param (
        [string]$tip = $null
    )
    
    Write-Host "$([char]0xd83d)$([char]0xde00)"
    if($tip){
        Write-Host "   $tip" -ForegroundColor DarkGray
    }
    $ret = Read-Host  "   >"
    return $ret
}