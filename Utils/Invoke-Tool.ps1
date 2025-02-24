






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

            $process.WaitForExit();
            return $ret;
        }
        Default {}
    }
    return ""
}