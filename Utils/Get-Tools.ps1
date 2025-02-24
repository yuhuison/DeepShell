
function Get-Tools {
    $functions = @(
        @{
            "type"     = "function"
            "function" = @{
                "name"        = "run_command"
                "description" = "Execute a single command in PowerShell and return its output.Will run by Invoke-Expression;"
                "parameters"  = @{
                    "type"       = "object"
                    "properties" = @{
                        "command"   = @{
                            "type"        = "string"
                            "description" = "The command to execute.If there are multiple commands, please separate them with a semicolon (;)."
                        }
                        "message" = @{
                            "type"        = "string"
                            "description" = "(use User's lang)The message to the user, asking if they are willing to execute this command, should be brief and simply describe the command you are about to execute."
                        }
                    }
                }
                "required"    = "command", "description"
            }
        }
    )

    return $functions
    
}