$srciptFiles = @( Get-ChildItem -Path $PSScriptRoot\Utils\*.ps1 -ErrorAction SilentlyContinue -Recurse )

$FoundErrors = @(
    Foreach ($Import in $srciptFiles) {
        Try {
            . $Import.Fullname
        }
        Catch {
            Write-Error -Message "Failed to import functions from $($import.Fullname): $_"
            $true
        }
    }
)

if ($FoundErrors.Count -gt 0) {
    $ModuleElementName = (Get-ChildItem $PSScriptRoot\*.psd1).BaseName
    Write-Warning "Importing module $ModuleElementName failed. Fix errors before continuing."
    break
}

function Ds {
    param (
        [string]$action
    )

    switch ($action) {
        "ui" {
            $global:messageStore = New-Object System.Collections.ArrayList;
            $null = $global:messageStore.Add(@{ role = "system";content = "$systemPrompt"});
            $null = $global:messageStore.Add(@{ role = "user"; content = "Test MSG" });
            $null = $global:messageStore.Add(@{ role = "user"; content = "Test Reply......................." });
            $count = $global:messageStore.Count
            $ret = Invoke-RenderMessage -message $global:messageStore
            Write-Host $ret
        }
        "test" {

            $messages = @(
                @{ role = "system"; content = "You are a helpful assistant." }
                @{ role = "user"; content = "HI? Can u help me to send email to a@live.com and b@live.com and say happy birthday" }
            )

            $APIKey = "sk-39add90575334b72baa13ad0ae397da4"
            $APIUri = "https://api.deepseek.com/chat/completions"
            $ModelName = "deepseek-chat"

            $callback = {
                param ($delta)
                Write-Host "New message: $delta"
            }

            $functionCalls = {
                param ($calls)
                Invoke-Tools -invokes $calls
            }

            Invoke-OpenAIChatStream -messages $messages -APIKey $APIKey -uri $APIUri -model $ModelName -msgCallBack $callback -toolsCallBack $functionCalls
            break;
        }
        default {
            Write-Host " "

            $originY = $Host.UI.RawUI.CursorPosition.Y
            $systemPrompt = Get-SystemPrompt
            $tools = Get-Tools

            $global:messageStore = New-Object System.Collections.ArrayList;
            $null = $global:messageStore.Add(@{ role = "system";content = "$systemPrompt"});
            $null = $global:messageStore.Add(@{ role = "user"; content = "$action" });
            Invoke-RenderMessage -messages $global:messageStore;

            $APIKey = "sk-991HER5q9SGxagrZE783E76647C84b6dAbDe3e89A3BcB8Df";
            $APIUri = "https://api.guidaodeng.com/v1/chat/completions";
            $ModelName = "gpt-4o";

            $streamCallback = {
                param (
                    [string]$delta,
                    [string]$complete
                )
                switch ($delta) {
                    "<DS_START>" {
                        $global:messageStore.Add(@{
                            role = "assistant"
                            content = ""
                        })
                        Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY;
                    }
                    "<DS_END>"{
                        Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY;
                    }
                    "<TOOL_CALL>"{
                        
                    }
                    Default {
                        $last = $global:messageStore | Where-Object { $_.role -eq "assistant" } | Select-Object -Last 1;
                        if($last){
                            $last.content = $complete;
                        }
                        $currentY = $Host.UI.RawUI.CursorPosition.Y;
                        Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY -delta $delta;
                    }
                }
            };

            $runtoolCallback = {
                param (
                    [string]$delta
                )
                $last = $global:messageStore | Where-Object { $_.role -eq "tool" } | Select-Object -Last 1;
                if($last){
                    Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY -delta "$delta";
                }
            }

            while($true){
                $result = Invoke-OpenAIChatStream -message $global:messageStore -APIKey $APIKey -uri $APIUri -model $ModelName -functions $tools -msgCallBack $streamCallback;
                $result = $result | ConvertFrom-Json;
                $calls = @($result.tools);
                if($result.tools -and $calls.Length -gt 0){
                    $last = $global:messageStore[-1];
                    foreach($call in $calls){
                        $cmd_args = $call.function.arguments | ConvertFrom-Json;
                        $global:messageStore[-1] = @{
                            role=$last.role
                            content="[Running Command]" + $cmd_args.message
                            tool_calls = $calls
                        }
                        $cmd = $cmd_args.command;
                        $calls_id = $call.id;
                        $null = $global:messageStore.Add(@{ role = "tool"; content = "Waiting for run command: `n $cmd"; tool_call_id = "$calls_id"});
                        Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY;
                        $runCheck = Get-InputMsg -tip "Enter Yes or Y to continue run command."
                        if ($runCheck -match "^(Yes|Y)$") {
                            Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY;
                            $ret = Invoke-Tool -invoke $call -callback $runtoolCallback;
                            $ret = ($ret|Out-String);
                            $ret = "Result: $ret";
                            $global:messageStore[-1].content = $ret;
                            Invoke-RenderMessage -message $global:messageStore -start $originY -end $currentY;
                        }else{
                            $global:messageStore[-1].content += "The user refused to execute the command. Please ask what happened!";
                        }
                    }
                }else{
                    $inputMsg = Get-InputMsg;
                    $null = $global:messageStore.Add(@{ role = "user"; content = "$inputMsg" });
                }
            }

        }
    }
}
