# Load the HTML content of the webpage
$html = Invoke-WebRequest -Uri "https://www.zyxware.com/articles/4344/list-of-fortune-500-companies-and-their-websites"

# Extract the first 100 companies and their URLs from the table
$table = $html.ParsedHtml.getElementsByTagName('table')[0]
$rows = $table.getElementsByTagName('tr') | Select-Object -First 100

$companies = @()

foreach ($row in $rows) {
    $cells = $row.getElementsByTagName('td')
    $rank = $cells[0].innerText
    $name = $cells[1].innerText
    $url = $cells[2].getElementsByTagName('a')[0].href
    $companies += [PSCustomObject]@{
        Rank = $rank
        Name = $name
        URL = $url
    }
}

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
ForEach ($company in $companies) {
    $job = [powershell]::Create().AddScript({
        param (
            [string]$url,
            [string]$outputFilePath
        )
        Download-WebsiteContent -url $url -outputFilePath $outputFilePath
    })
    $job.AddArgument($company.URL)
    $outputFilePath = Join-Path -Path $fortune100Folder -ChildPath "$($company.Name -replace '[^\w\s]', '').html"
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
