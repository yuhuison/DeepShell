

function Invoke-RenderMessage {
    param (
        [System.Collections.ArrayList]$message,
        [int]$start,
        [int]$end,
        [string]$delta = $null
    )

    $roleColors = @{
        "system" = "DarkGray"
        "user"   = "Blue"
        "assistant" = "Cyan"
        "tool" = "DarkGray"
    }

    $roleEmojis = @{
        "user" = "$([char]0xd83d)$([char]0xde00)"
        "assistant" = "$([char]0xd83e)$([char]0xdd16)"         
        "tool" = "$([char]0xd83d)$([char]0xdcdc)"                       
    }

    if($delta){
        Write-Host $delta -NoNewline
        return
    }else{
        Clear-Host
    }


    foreach ($item in $message) {
        $role = $item.role
        $content = $item.content
        if($role -eq "system"){
            continue
        }
        if (($PSVersionTable.PSVersion.Major -ge 6) -and ($role -eq "assistant")) {
            $content = $content | ConvertFrom-Markdown -AsVT100EncodedString
            $content = $content.VT100EncodedString
        }
        $roleColor = $roleColors[$role]
        if (-not $roleColor) { $roleColor = "Gray" } 
        $roleEmoji = $roleEmojis[$role]
        if (-not $roleEmoji) { $roleEmoji = " " } 
        Write-Host "`r$roleEmoji"
        $lines = $content -split "`n"
        $ii = 0
        foreach ($line in $lines) {
            if($ii -eq 0){
                Write-Host "`r   > $line " -ForegroundColor $roleColor
            }else{
                Write-Host "`r     $line " -ForegroundColor $roleColor
            }
            $ii++;
        }
    }
}
