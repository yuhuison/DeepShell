function Invoke-FlushContent {
    param (
        [int]$start,
        [int]$end,
        [string]$content
    )
    
    $lines = $content -split "`n"

    if ($lines.Count -le ($end - $start + 1)) {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            [Console]::SetCursorPosition(0, $start + $i)
            [Console]::Write("`r" + $lines[$i])
        }

        for ($i = $lines.Count; $i -lt ($end - $start + 1); $i++) {
            [Console]::SetCursorPosition(0, $start + $i)
            [Console]::Write("`r" + " ")
        }
    }
    else {
        for ($i = 0; $i -lt ($end - $start + 1); $i++) {
            [Console]::SetCursorPosition(0, $start + $i)
            [Console]::Write("`r" + $lines[$i])
        }

        for ($i = ($end - $start + 1); $i -lt $lines.Count; $i++) {
            [Console]::WriteLine($lines[$i])
        }
    }
}