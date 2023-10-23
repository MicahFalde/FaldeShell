#variable declaration
$page = Invoke-WebRequest https://www.zyxware.com/articles/4344/list-of-fortune-500-companies-and-their-websites
$links = $page.links
$tables = @($page.ParsedHtml.getElementsByTagName("TABLE"))
$tableRows = $tables[0].rows

<#
foreach($link in $links){
    if($link.href -like '*www*com*'){
        
        #$link = $page.Links.href
        Write-Host $link.href
    }
}
#>


#loops through the table to get only the top 100 urls.
$i = 0
foreach ($tablerow in $tablerows){
    write-host ($tablerow.innerHTML).Split('"')[1]
    $i++
    if($i -eq 101){Break}
    
}




<#
$TableUrl = (($tables[0].rows[$rowNum].innerHTML).Split('"'))[1] 

foreach($tables in $tableRows, $rowNum +1){
        Write-Host $TableUrl
    
    }

#>
