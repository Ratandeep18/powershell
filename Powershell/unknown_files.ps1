$logl = "\\mlbfile\products\NOC\Users\Ratandeep\VABNK\" + (Get-date).ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";
Start-Transcript -Path $logl;
$patharchive = "\\mlbfile\Archive\KAFILES\";
Set-Location "C:\inetpub\wwwroot\webdav";
Get-ChildItem -Filter 'KA_UNKNOWN*.zip' | Where-Object { $_ -match 'Ka_UNK.*\wN\d{3,}NK' } | Foreach-object {
    Clear-Variable name, date, year;
    $name = $_.basename.split('_');
    $date = $name[8];
    $year = $date.Substring(0, 4);
    $month = $date.Substring(4, 2);
  
    $path = $patharchive + (Get-Culture).DateTimeFormat.GetMonthName($month) + $year + "\SPIRIT\" + $name[2] + "\";
		
    if (-not (Test-Path $path)) {
        mkdir $path
    }
    Move-Item -Path $_.fullname  -Destination $path -Force -Verbose
};
Stop-Transcript;