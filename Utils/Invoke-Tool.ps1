






function Invoke-Tool {
    param (
        $invoke,
        [scriptblock]$callback
    )
    $fun = $invoke.function;
    $name = $fun.name;
    $cmd_args = $fun.arguments;
    switch ($name) {
        "run_command" { 
            $cmd_args = $cmd_args | ConvertFrom-Json;
            $command = $cmd_args.command;
            $ret = "Run " + $cmd_args.command + "`nReturn:";
            if ($callback) {
                & $callback -delta $ret;
            }
            $process = New-Object System.Diagnostics.Process;
            $process.StartInfo.FileName = "powershell.exe";
            $process.StartInfo.Arguments = "-Command `"$command`"";
            $process.StartInfo.RedirectStandardOutput = $true;
            $process.StartInfo.UseShellExecute = $false;
            $process.StartInfo.CreateNoWindow = $true;
            $process.Start();

            while (!$process.StandardOutput.EndOfStream) {
                $line = $process.StandardOutput.ReadLine();
                if ($callback) {
                    & $callback -delta "`n$line";
                }
                $ret += $line;
            }

            while ($pythonProcess.StandardError -and !$process.StandardError.EndOfStream) {
                $line = $process.StandardError.ReadLine();
                if ($callback) {
                    & $callback -delta "`n[Error] $line";
                }
                $ret += "`n[Error] $line";
            }
            
            $process.WaitForExit();
            return $ret;
        }
        "run_python"{
            $cmd_args = $cmd_args | ConvertFrom-Json;
            $code = $cmd_args.command;
            $ret = "Run Python Script`n" + $code + "`nReturn:";
            if ($callback) {
                & $callback -delta $ret;
            }

            $tempFile = [System.IO.Path]::GetTempFileName() + ".py"

            Write-Host $tempFile
            $ret += "`n Run File $tempFile `n Std Out: `n";

            Set-Content -Path $tempFile -Value $code

            $pythonProcess = New-Object System.Diagnostics.Process;
            $pythonProcess.StartInfo.FileName = "python";
            $pythonProcess.StartInfo.Arguments = "`"$tempFile`"";
            $pythonProcess.StartInfo.RedirectStandardOutput = $true;
            $pythonProcess.StartInfo.RedirectStandardError = $true;
            $pythonProcess.StartInfo.UseShellExecute = $false;
            $pythonProcess.StartInfo.CreateNoWindow = $true;
            $pythonProcess.Start();

            while (!$pythonProcess.StandardOutput.EndOfStream) {
                $line = $pythonProcess.StandardOutput.ReadLine();
                if ($callback) {
                    & $callback -delta "`n$line";
                }
                $ret += "`n$line";
            }

            while ($pythonProcess.StandardError -and !$pythonProcess.StandardError.EndOfStream) {
                $line = $pythonProcess.StandardError.ReadLine();
                if ($callback) {
                    & $callback -delta "`n[Error] $line";
                }
                $ret += "`n[Error] $line";
            }

            $pythonProcess.WaitForExit();
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue;
            return $ret;
        }
        Default {}
    }
    return ""
}