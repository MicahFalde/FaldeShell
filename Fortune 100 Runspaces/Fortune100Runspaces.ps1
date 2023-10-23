# Load the HTML content of the webpage
$html = Invoke-WebRequest -Uri "https://www.zyxware.com/articles/4344/list-of-fortune-500-companies-and-their-websites"

# Extract all the links from the page
$urls = $html.Links | Where-Object { $_.href -like "http*" } | Select-Object -ExpandProperty href

# Filter out the non-company links based on common patterns in URLs
$companyUrls = $urls | Where-Object { $_ -match "https:\/\/www\.fortune\.com\/company\/" }

# Create a Fortune100 folder if it doesn't exist
$fortune100Folder = "C:\path\to\Fortune100"
if (-not (Test-Path $fortune100Folder)) {
    New-Item -ItemType Directory -Path $fortune100Folder | Out-Null
}

# Define a function to download content to a file
Function Download-WebsiteContent {
    param (
        [string]$url,
        [string]$outputFilePath
    )
    
    $response = Invoke-WebRequest -Uri $url
    $response.Content | Out-File -FilePath $outputFilePath
}

# Create a runspace for parallel execution
$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()

$jobs = @()

# Start parallel downloads
ForEach ($url in $companyUrls) {
    $job = [powershell]::Create().AddScript({
        param (
            [string]$url,
            [string]$outputFilePath
        )
        Download-WebsiteContent -url $url -outputFilePath $outputFilePath
    })
    $job.AddArgument($url)
    $outputFilePath = Join-Path -Path $fortune100Folder -ChildPath "$($url -replace 'https?://','').html"
    $job.AddArgument($outputFilePath)
    $job.Runspace = $runspace
    $jobs += $job
    [void]$job.BeginInvoke()
}

# Wait for all jobs to complete
$jobs | ForEach-Object { $_.EndInvoke($_.BeginInvoke()) }

# Clean up runspace
$runspace.Close()
$runspace.Dispose()
