chcp 65001
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$csvPath = Join-Path $PSScriptRoot (Get-ChildItem $PSScriptRoot -Filter '*.csv' | Select-Object -First 1).Name
$csv = [System.IO.File]::ReadAllLines($csvPath, [System.Text.Encoding]::UTF8)
$csv = $csv | Where-Object { $_.Trim() -ne '' }

$groupSize = 40
$totalGroups = [Math]::Ceiling($csv.Count / $groupSize)
$sb = [System.Text.StringBuilder]::new(200000)

[void]$sb.AppendLine('const groupsData = [')

for ($g = 0; $g -lt $totalGroups; $g++) {
    $start = $g * $groupSize
    $end = [Math]::Min($start + $groupSize, $csv.Count) - 1
    $gnum = $g + 1
    $wcount = $end - $start + 1

    [void]$sb.AppendLine('  {')
    [void]$sb.Append('    id: ').Append($gnum).AppendLine(',')
    [void]$sb.Append('    name: ').Append([char]34).Append([char]0x30B0).Append([char]0x30EB).Append([char]0x30FC).Append([char]0x30D7).Append($gnum).Append(' (').Append($wcount).Append([char]0x8A9E).Append(')').Append([char]34).AppendLine(',')
    [void]$sb.AppendLine('    words: [')

    for ($w = $start; $w -le $end; $w++) {
        $line = $csv[$w].Trim()
        $idx = $line.IndexOf(',')
        $ko = $line.Substring(0, $idx)
        $ja = $line.Substring($idx + 1)
        $ko = $ko -replace '\\', '\\' -replace '"', '\"'
        $ja = $ja -replace '\\', '\\' -replace '"', '\"'
        [void]$sb.Append('      { ko: ').Append([char]34).Append($ko).Append([char]34).Append(', ja: ').Append([char]34).Append($ja).Append([char]34).Append(' }')
        if ($w -lt $end) { [void]$sb.Append(',') }
        [void]$sb.AppendLine()
    }

    [void]$sb.AppendLine('    ]')
    [void]$sb.Append('  }')
    if ($g -lt $totalGroups - 1) { [void]$sb.Append(',') }
    [void]$sb.AppendLine()
}

[void]$sb.AppendLine('];')

$outPath = Join-Path $PSScriptRoot 'data.js'
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
Write-Host ('Done: ' + $csv.Count + ' words, ' + $totalGroups + ' groups')
