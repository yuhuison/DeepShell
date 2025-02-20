function do {
    param (
        [string]$action
    )

    switch ($action) {
        "chat" {
            Start-Process "https://chat.openai.com/"
            break
        }
        "python" {
            $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
            if (-not $pythonPath) {
                Write-Output "Python 未安装，请从 Microsoft Store 安装 Python。"
                Start-Process "ms-windows-store://pdp/?ProductId=9NJ46SX7X90P"
            } else {
                Write-Output "Python 已安装，路径：$pythonPath"
            }
            break
        }
        default {
            Write-Output "未知的操作：$action"
        }
    }
}
