#Importing Modules

Import-Module PoshRSJob

#variable declaration

$page = Invoke-WebRequest https://www.zyxware.com/articles/4344/list-of-fortune-500-companies-and-their-websites

$links = $page.links

$tables = @($page.ParsedHtml.getElementsByTagName("TABLE"))

$tableRows = $tables[0].rows



#loops through the table to get only the top 100 urls.

$urlArray = @()

foreach ($tablerow in $tablerows){
        
        $urlArray += New-Object psobject -Property @{'URLName' = $tablerow.innerHTML.Split('"')[1]}
        
        #write-host ($tablerow.innerHTML).Split('"')[1]

        $i++

        if($i -eq 101){Break}
}

#Number of Runspaces to use
$RunspaceThreads = 100

#Parameters
$parameters = {
        $urlArray
}
    #Accessing the URLs
    #Invoke-WebRequest $ParamList
    
    #BeginInvoke()
    
    #Start-RSJob
    
    #Get-Content $ParamList
    
    #EndInvoke()
