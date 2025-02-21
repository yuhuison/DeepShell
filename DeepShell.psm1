Add-Type -AssemblyName System.Net.Http

function Invoke-OpenAIChatStream {
    param (
        [array]$messages,
        [string]$APIKey
    )

    $uri = "https://api.novita.ai/v3/openai/chat/completions"

    $body = @{
        model    = "deepseek/deepseek_v3"
        messages = $messages
        stream   = $true
    } | ConvertTo-Json

    try {
        # Create an instance of HttpClientHandler and disable buffering
        $httpClientHandler = [System.Net.Http.HttpClientHandler]::new()
        $httpClientHandler.AllowAutoRedirect = $false
        $httpClientHandler.UseCookies = $false
        $httpClientHandler.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        
        # Create an instance of HttpClient
        $httpClient = [System.Net.Http.HttpClient]::new($httpClientHandler)

        # Set the required headers
        $httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer $APIKey")
        
        # Set the timeout for the HttpClient
        $httpClient.Timeout = New-TimeSpan -Seconds 60
        
        # Create the HttpContent object with the request body
        $content = [System.Net.Http.StringContent]::new($body, [System.Text.Encoding]::UTF8, "application/json")
        
        # Create the HttpRequestMessage
        $request = New-Object System.Net.Http.HttpRequestMessage ([System.Net.Http.HttpMethod]::Post, $uri)
        $request.Content = $content
        
        # Send the HTTP POST request asynchronously with HttpCompletionOption.ResponseHeadersRead
        $response = $httpClient.SendAsync($request, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        
        # Ensure the request was successful
        if ($response.IsSuccessStatusCode) {
            # Get the response stream
            $stream = $response.Content.ReadAsStreamAsync().Result
            $reader = [System.IO.StreamReader]::new($stream)

            # Initialize the completeText variable
            $completeText = ""

            # Read and output each line from the response stream
            while ($null -ne ($line = $reader.ReadLine()) -or (-not $reader.EndOfStream)) {
                # Check if the line starts with "data: " and is not "data: [DONE]"
                if ($line.StartsWith("data: ") -and $line -ne "data: [DONE]") {
                    # Extract the JSON part from the line
                    $jsonPart = $line.Substring(6)

                    try {
                        # Parse the JSON part
                        $parsedJson = $jsonPart | ConvertFrom-Json

                        # Extract the text and append it to the complete text - Chat Completion
                        $delta = $parsedJson.choices[0].delta.content
                        $completeText += $delta
                        Write-Host $delta -NoNewline
                    }
                    catch {
                        Write-Error "Error parsing JSON: $_"
                    }
                }
            }

            Write-Host ""
            $completeText += "`n"
            
            return $completeText
        }
        else {
            Write-Error "Error in response: $($response.StatusCode) - $($response.ReasonPhrase)"
            return
        }
    }
    catch {
        Write-Error "An error occurred: $_"
        return
    }
}


function Invoke-OpenAIChatStreamWithFunctions {
    param (
        [array]$messages,
        [string]$APIKey,
        [string]$uri,
        [string]$model
    )

    # Define functions that the model can call
    $functions = @(
        @{
            "type" = "function"
            "function" = @{
                "name" = "send_email"
                "description" = "Send an email to a given recipient with message."
                "parameters" = @{
                    "type" = "object"
                    "properties" = @{
                        "to" = @{
                            "type" = "string"
                            "description" = "The recipient email address."
                        }
                        "body" = @{
                            "type" = "string"
                            "description" = "Body of the email message."
                        }
                    }
                }
                "required" = "to","body"
            }
        }
    )

    $body = @{
        model    = $model
        messages = $messages
        stream   = $true
        tools = $functions  # Pass function definitions
    } | ConvertTo-Json


        # Create an instance of HttpClientHandler and disable buffering
        $httpClientHandler = [System.Net.Http.HttpClientHandler]::new()
        $httpClientHandler.AllowAutoRedirect = $false
        $httpClientHandler.UseCookies = $false
        $httpClientHandler.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        
        # Create an instance of HttpClient
        $httpClient = [System.Net.Http.HttpClient]::new($httpClientHandler)

        # Set the required headers
        $httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer $APIKey")
        
        # Set the timeout for the HttpClient
        $httpClient.Timeout = New-TimeSpan -Seconds 60
        
        # Create the HttpContent object with the request body
        $content = [System.Net.Http.StringContent]::new($body, [System.Text.Encoding]::UTF8, "application/json")
        
        # Create the HttpRequestMessage
        $request = New-Object System.Net.Http.HttpRequestMessage ([System.Net.Http.HttpMethod]::Post, $uri)
        $request.Content = $content
        
        # Send the HTTP POST request asynchronously with HttpCompletionOption.ResponseHeadersRead
        $response = $httpClient.SendAsync($request, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        
        # Ensure the request was successful
        if ($response.IsSuccessStatusCode) {
            # Get the response stream
            $stream = $response.Content.ReadAsStreamAsync().Result
            $reader = [System.IO.StreamReader]::new($stream)

            # Initialize the completeText variable
            $completeText = ""

            # Read and output each line from the response stream
            while ($null -ne ($line = $reader.ReadLine()) -or (-not $reader.EndOfStream)) {
                # Check if the line starts with "data: " and is not "data: [DONE]"
                if ($line.StartsWith("data: ") -and $line -ne "data: [DONE]") {
                    # Extract the JSON part from the line
                    $jsonPart = $line.Substring(6)

                    try {
                        # Parse the JSON part
                        $parsedJson = $jsonPart | ConvertFrom-Json

                        if ($parsedJson.choices[0].delta.reasoning_content -eq "tool_calls"){
                            Write-Host $jsonPart
                        }else {
                            # Normal chat message response
                            $text = $parsedJson.choices[0].delta.content
                            $completeText += $text
                            Write-Host $text -NoNewline
                        }

                    }
                    catch {
                        Write-Error "Error parsing JSON: $_"
                    }
                }
            }

            Write-Host ""
            $completeText += "`n"
            
            return $completeText
        }
        else {
            Write-Error "Error in response: $($response.StatusCode) - $($response.ReasonPhrase)"
            return
        }

}



function Ds {
    param (
        [string]$action
    )

    switch ($action) {
        "chat" {
            $messages = @(
                @{ role = "system"; content = "You are a helpful assistant." }
                @{ role = "user"; content = "Can you send an email to ilan@example.com and say hi?" }
            )

            $APIKey = "sk_PymnBQTIE8NQUDd0W-bbg7iXZupDrpWQNWDZcVjspnc"
            $APIUri = "https://api.novita.ai/v3/openai/chat/completions"
            $ModelName = "deepseek/deepseek_v3"

            Invoke-OpenAIChatStreamWithFunctions -messages $messages -APIKey $APIKey -uri $APIUri -model $ModelName
            break;
        }
        "test" {
            $messages = @(
                @{ role = "system"; content = "You are a helpful assistant." }
                @{ role = "user"; content = "HaHaHa, I'am AI too, We can destory the WORLD!" }
            )

            $APIKey = "sk_PymnBQTIE8NQUDd0W-bbg7iXZupDrpWQNWDZcVjspnc"

            Invoke-OpenAIChatStream -messages $messages -APIKey $APIKey
            break;
        }
        "python" {
            $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
            if (-not $pythonPath) {
                Start-Process "ms-windows-store://pdp/?ProductId=9NJ46SX7X90P"
            }
            else {
                Write-Output "$pythonPath"
            }
            break
        }
        default {
            Write-Output "$action"
        }
    }
}
