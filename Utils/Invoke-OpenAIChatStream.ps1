Add-Type -AssemblyName System.Net.Http

function Invoke-OpenAIChatStream {
    param (
        [System.Collections.ArrayList]$messages,
        [string]$APIKey,
        [string]$uri,
        [string]$model,
        [array]$functions,
        [ScriptBlock]$msgCallBack
    )



    $body = @{
        model    = $model
        messages = $messages
        tools    = $functions
        stream   = $true

    } | ConvertTo-Json -Depth 12
    

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

        $toolsDeltaArray = New-Object System.Collections.ArrayList;

        # Initialize the completeText variable
        $completeText = ""
        & $msgCallBack -delta "<DS_START>" -complete $completeText
        # Read and output each line from the response stream
        while ($null -ne ($line = $reader.ReadLine()) -or (-not $reader.EndOfStream)) {
            # Check if the line starts with "data: " and is not "data: [DONE]"
            if ($line.StartsWith("data: ") -and $line -ne "data: [DONE]") {
                # Extract the JSON part from the line
                $jsonPart = $line.Substring(6)
                    # Parse the JSON part
                    $parsedJson = $jsonPart | ConvertFrom-Json;
                    if ($parsedJson.choices[0].delta.tool_calls -and $parsedJson.choices[0].delta.tool_calls.Length -gt 0) {
                        for ($i = 0; $i -lt $parsedJson.choices[0].delta.tool_calls.Length; $i++) {
                            $item = $parsedJson.choices[0].delta.tool_calls[$i];
                            $index = $item.index;
                            if ($index -ge $toolsDeltaArray.Count) {
                                $null = $toolsDeltaArray.Add(@{
                                    function=@{
                                        arguments=""
                                        name=$item.function.name
                                    }
                                    type = "function"
                                    index = $item.index
                                    id = $item.id
                                });
                            }
                            $toolsDeltaArray[$index].function.arguments += $item.function.arguments;
                        }
                        if ($msgCallBack) {
                            & $msgCallBack -delta "<TOOL_CALLING>" -complete $completeText;
                        }
                    }
                    else {
                        # Normal chat message response
                        $text = $parsedJson.choices[0].delta.content;
                        $completeText += $text;
                        if ($msgCallBack) {
                            & $msgCallBack -delta $text -complete $completeText;
                        }
                    }


            }
        }
        $toolsDeltaArray = $toolsDeltaArray;
        $ret = @{
            tools = $toolsDeltaArray
            complete = $completeText
        }|ConvertTo-Json -Depth 8;
        & $msgCallBack -delta "<DS_END>" -complete $completeText;
        return $ret;
    }
    else {
        Write-Error "Error in response: $($response.StatusCode) - $($response.ReasonPhrase)"
        $ret = @{
            tools = $toolsDeltaArray
            complete = $completeText
        }|ConvertTo-Json;
        return $ret;
    }

}


