#Path set for logs
$logl = "C:\scripts\UNKNOWN_LOGS\" + "ka_logs_" + (Get-date).ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";

# test if the directory exist if not it'll create it
$log_path = "C:\scripts\UNKNOWN_LOGS\";
if (-not (Test-Path $log_path)) {
    mkdir $log_path
}

# start-transcript
Start-Transcript -Path $logl;

#path for archive
$patharchive = "\\mlbfile\Archive\KAFILES\";

#path for checking the aircraft logs
Set-Location "E:\NKS\in";

<# look for following tails in the unknown file
    - N...NK
    - SPIR0
    - TH-SP
    - TH-NK
#>
Get-ChildItem -Filter 'KA_UNKNOWN*.zip' | Where-Object { $_ -match 'Ka_UNK.*_\wN*\d{3,}.Z?\B' } | Foreach-object {
  
    $name = $_.basename.split('_');
    $date = $name[8];
    $year = $date.Substring(0, 4);
    $month = $date.Substring(4, 2);

    for ($num = 0 ; $num -le 10 ; $num++) {
        # If unknown file has tail number mentioned
        if (($name[$num] -match '^N...NK$') -or ($name[$num] -match '^SPIR0') -or ($name[$num] -match '^TH-?SP') -or ($name[$num] -match '^TH-?NK')) {
            $path = $patharchive + (Get-Culture).DateTimeFormat.GetMonthName($month) + $year + "\SPIRIT\" + $name[$num] + "\";
            if (-not (Test-Path $path)) {
                mkdir $path
            }
            Move-Item -Path $_.fullname  -Destination $path -Force -Verbose
            break
        }
    }       
};

# if tails not found it'll move the rest of the unknown in archive

Get-ChildItem -Filter 'KA_UNKNOWN*.zip' | Where-Object { $_ -match 'Ka_UNK.*_\wN*\d{3,}.Z?\B' } | Foreach-object {
    Clear-Variable name, date, year;
    $name = $_.basename.split('_');
    $date = $name[8];
    $year = $date.Substring(0, 4);
    $month = $date.Substring(4, 2);

    $path_unknown = $patharchive + (Get-Culture).DateTimeFormat.GetMonthName($month) + $year + "\SPIRIT\" + $name[2] + "\";
    if (-not (Test-Path $path_unknown)) {
        mkdir $path_unknown
    }
    Move-Item -Path $_.fullname  -Destination $path_unknown -Force -Verbose;
} 

# Move 0kb logs to archive
Get-ChildItem -Filter 'Ka_*.zip' | Where-Object { $_.Length -eq 0 } | Foreach-object {
  
    $name = $_.basename.split('_');
    $date = $name[8];
    $year = $date.Substring(0, 4);
    $month = $date.Substring(4, 2);
  
    for ($num = 0 ; $num -le 10 ; $num++) {
        if (($name[$num] -match '^N...NK$') -or ($name[$num] -match '^SPIR0') -or ($name[$num] -match '^TH-?SP') -or ($name[$num] -match '^TH-?NK')) {
            $path = $patharchive + (Get-Culture).DateTimeFormat.GetMonthName($month) + $year + "\SPIRIT\" + $name[$num] + "\";
            if (-not (Test-Path $path)) {
                mkdir $path
            }
            Move-Item -Path $_.fullname  -Destination $path -Force -Verbose;
            break;
        }
    }       
};

# remove filepart & temp for more than 3 days
Get-ChildItem -Filter '*.filepart' | Where-Object { $_.CreationTime -lt (Get-date).AddDays(-3) } | Remove-Item -Force -Verbose;
Get-ChildItem -Filter '*.temp' | Where-Object { $_.CreationTime -lt (Get-date).AddDays(-3) } | Remove-Item -Force -Verbose;

Stop-Transcript;