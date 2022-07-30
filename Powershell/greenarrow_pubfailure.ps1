# Script Logs
$logl = "C:\scripts\greenarrow_pub_failure_logs\" + "ka_logs_" + (Get-date).ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";
$log_path = "C:\scripts\greenarrow_pub_failure_logs\";
if (-not (Test-Path $log_path)) {
    mkdir $log_path
}

# KA file logs for compare
$log_file = "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt";
if (-not (Test-Path $log_file)) {
    New-Item -Path "C:\scripts\greenarrow_pub_failure_logs\" -Name "temp_logs_name.txt";
}
$temp_file = "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp";
if (-not (Test-Path $temp_file)) {
    New-Item -Path "C:\scripts\greenarrow_pub_failure_logs\" -Name "temp_logs_name.temp";
}

# Move Logs back for file router
function move-ka ($global:name) {
    if ($current_file.name -match 'KA_[Uu][Nn][Ii]\w{3}') {
        #United Logs
        Move-item $current_file -Destination 'C:\Shares\FileRouteDirectories' -Force -Verbose;
    }
    elseif ($current_file.name -match 'KA_[Ss][Pp][Ii]\w{3}') {
        #Spirit Logs
        Move-item $current_file -Destination 'C:\Shares\SpiritKA' -Force -Verbose;
    }
    elseif ($current_file.name -match "KA_[Aa][Ii][Rr][Cc]\w{5}") {
        #AirCanada Logs
        Move-item $current_file -Destination 'C:\Shares\AirCanadaKA' -Force -Verbose;
    }
    else {
        # Jet Blue, RAM & RBA Logs
        Move-item $current_file -Destination 'C:\Shares\JB KA' -Force -Verbose;
    }
}

# Path & Permision Check
function file_check ($global:name) {
    $flag_check = $false;
    $zip_subfile = [io.compression.zipfile]::OpenRead("C:\Shares\JB KA\ErrorFiles\PubFailure\$global:name").Entries.Name
    if ($flag_check -eq $false) {
        # Path length check
        foreach ($ka_item in $zip_subfile) {
            $max_length = ("C:\Shares\JB KA\ErrorFiles\PubFailure\" + $global:name + "\" + $ka_item);
            if ($max_length.Length -gt 260) {
                Write-Output "Path length error & move file to archive";
                $flag_check = $true;
            }
        }
        $user_profile = 'ltvasn\nocprod1';
        $perm_temp = Get-Acl $global:name | Select-Object AccessToString
        $perm_var = $perm_temp.AccessToString;
        foreach ($perm_file in $perm_var) {
            if ($perm_file -notmatch $user_profile) {
                icacls *.* /c /t /grant "ltvasn\nocprod1:(ci)(oi)f"
                Write-Output 'File Permission Changed ' + $user_profile;
            }
        }
    }
}

Set-Location 'C:\Shares\JB KA\ErrorFiles\PubFailure';
cmd /c "dir /b" | Select-String -Pattern 'KA_' | Select-String -Pattern '.zip' | Out-File -FilePath "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.temp";

$ka_logs = Get-Content "C:\scripts\greenarrow_pub_failure_logs\temp_logs_name.txt"

# start-transcript
Start-Transcript -Path $logl;

#KA FILES
Get-ChildItem 'C:\Shares\JB KA\ErrorFiles\PubFailure' -Filter 'KA_*.zip' | ForEach-Object {
    $global:move_ahead = $true;
    foreach ($ka_item in $ka_logs) {
        $global:name = $_.BaseName;
        if ($global:name -eq $ka_item) {
            $global:move_ahead = $false;
            break;
        }
    }
    if ($global:move_ahead -eq $true) { 
        move-ka $global:name;
        break;
    }
    else {
        file_check($global:name)
    }
}
