function Get-SystemPrompt {
    $prompt = ""

    $prompt += "You are a helpful assistant."

    $prompt += "You must respond to the user in their language, unless the user specifies tasks such as translation."
    
    $prompt += "You are running in a PowerShell environment."

    $info =  Get-ComputerInfo | Out-String

    $prompt += "Below is the environment information of the user's host: $info"

    $prompt += "You have some commands available to run instructions in the PowerShell terminal, but please make sure to consider carefully."
    
    $prompt += "You can run commands directly if you need."
    
    return $prompt
}

function Get-ChatSystemPrompt {

}