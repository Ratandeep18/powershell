#Path set for KA logs moved
$logl = "C:\scripts\greenarrow_pub_failure_logs\" + "ka_logs_" + (Get-date).ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";

# test if the directory exist if not it'll create it
$log_path = "C:\scripts\greenarrow_pub_failure_logs\";
if (-not (Test-Path $log_path)) {
    mkdir $log_path
}

#create catalog file and temp file
$log_file = "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt";
if (-not (Test-Path $log_file)) {
    New-Item -Path "C:\scripts\greenarrow_pub_failure_logs\" -Name "temp_logs_name.txt";
}
$temp_file = "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp";
if (-not (Test-Path $temp_file)) {
    New-Item -Path "C:\scripts\greenarrow_pub_failure_logs\" -Name "temp_logs_name.temp";
}
Set-Location 'C:\Shares\JB KA\ErrorFiles\PubFailure';
cmd /c "dir /b" | Select-String -Pattern 'KA_' | Select-String -Pattern '.zip' | Out-File -FilePath "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp";

#last logs of files in pub failure
$ka_logs = Get-Content "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt"

$global:move_ahead=$true;

# start-transcript
Start-Transcript -Path $logl;

$file_count = (Get-ChildItem 'C:\Shares\JB KA\ErrorFiles\PubFailure').count

if ($file_count -gt 0) {
    #UNITED FILES
    Get-ChildItem 'C:\Shares\JB KA\ErrorFiles\PubFailure' -Filter KA_United* | ForEach-Object {
        for ($i = 0; $i -eq $ka_logs.Length; $i++) {
            $name = $_.BaseName;
            if ($name -eq $ka_logs[$i]) {
                $global:move_ahead = $false;
                break;
            }}
            if ($global:move_ahead -eq $true) { 
                Move-Item -Destination 'C:\Shares\FileRouteDirectories' -Force -Verbose;

                break;
            }
    }
    #Jetblue FILES 
    Get-ChildItem 'C:\Shares\JB KA\ErrorFiles\PubFailure' -Filter KA_JetBlue* | ForEach-Object {
        for ($i = 0; $i -eq $ka_logs.Length; $i++) {
            $name = $_.BaseName;
            if ($name -eq $ka_logs[$i]) {
                $global:move_ahead = $false;
                break;
            }}
            if ($global:move_ahead -eq $true) { 
                Move-Item -Destination 'C:\Shares\JB KA' -Force -Verbose;
                break;
            }
    }
    #Spirit FILES 
    Get-ChildItem 'C:\Shares\JB KA\ErrorFiles\PubFailure' -Filter KA_Spirit* | ForEach-Object {
        for ($i = 0; $i -eq $ka_logs.Length; $i++) {
            $name = $_.BaseName;
            if ($name -eq $ka_logs[$i]) {
                $global:move_ahead = $false;
                break;
            }}
            if ($global:move_ahead -eq $true) { 
                Move-Item -Destination 'C:\Shares\SpiritKA' -Force -Verbose;
                break;
            }
    }
    Clear-Content "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt";
    Get-Content "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp" | Set-Content -Path "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt";
    Clear-Content "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp";    
}
Stop-Transcript;
