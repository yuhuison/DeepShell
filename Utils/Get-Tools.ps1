function Get-Tools {
    $functions = @(
        @{
            "type"     = "function"
            "function" = @{
                "name"        = "run_command"
                "description" = "Execute a single command in PowerShell and return its output. The command will be executed using `Invoke-Expression`."
                "parameters"  = @{
                    "type"       = "object"
                    "properties" = @{
                        "command"   = @{
                            "type"        = "string"
                            "description" = "The command to execute. If there are multiple commands, please separate them with a semicolon (;)."
                        }
                        "message" = @{
                            "type"        = "string"
                            "description" = "The message should be in the user's language. It should briefly describe the command being executed and ask for confirmation."
                        }
                    }
                    "required"    = @("command","message")
                }
            }
        },
        @{
            "type"     = "function"
            "function" = @{
                "name"        = "run_python"
                "description" = "Execute a Python script using the system's Python environment.This is the actual code to be executed. Do not include any comments!"
                "parameters"  = @{
                    "type"       = "object"
                    "properties" = @{
                        "command"   = @{
                            "type"        = "string"
                            "description" = "The Python code to execute,If there are multiple commands,please separate them with a semicolon (;).DO NOT USE \n.everything that needs to be printed must be explicitly wrapped in print();Please note that this code will be executed in the Temp directory, so when working with relative paths, set the working directory explicitly.Be sure to consider escaping strings, such as using double backslashes for directories (e.g., os.listdir(F:\\))."
                        }
                        "message" = @{
                            "type"        = "string"
                            "description" = "The message should be in the user's language. It should briefly describe the script being executed and ask for confirmation."
                        }
                    }
                    "required"    = @("command","message")
                }
            }
        }
    )

    return $functions
}
