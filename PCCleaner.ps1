# PC Deep Cleaner v3.2
# Run via Run_PCCleaner.bat

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# XAML layout
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="PC Deep Cleaner v3.2" Height="620" Width="800"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanResizeWithGrip"
    MinWidth="600" MinHeight="460"
    UseLayoutRounding="True">

  <Grid Margin="12">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- HEADER -->
    <StackPanel Grid.Row="0" Margin="0,0,0,8">
      <TextBlock Text="PC Deep Cleaner v3.1" FontSize="16" FontWeight="Bold"/>
      <TextBlock Name="txtStatus" Text="Pick a mode, then click Run."
                 FontSize="11" Foreground="Gray" Margin="0,2,0,0"/>
    </StackPanel>

    <!-- Mode buttons -->
    <UniformGrid Grid.Row="1" Rows="1" Margin="0,0,0,8">
      <Button Name="cStandard" Content="Standard"    Margin="0,0,4,0" Padding="8,6"/>
      <Button Name="cDeep"     Content="Deep Scan"   Margin="0,0,4,0" Padding="8,6"/>
      <Button Name="cApps"     Content="App Reviewer" Margin="0,0,4,0" Padding="8,6"/>
      <Button Name="cSpeed"    Content="Speed Boost"  Margin="0,0,4,0" Padding="8,6"/>
      <Button Name="cAll"      Content="Full Nuke"    Padding="8,6"/>
    </UniformGrid>

    <!-- Main area -->
    <Grid Grid.Row="2">
      <Grid.RowDefinitions>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <!-- Log box -->
      <Border Grid.Row="0" BorderBrush="LightGray" BorderThickness="1">
        <ScrollViewer Name="scroller" VerticalScrollBarVisibility="Auto">
          <TextBox Name="txtLog"
                   Background="Transparent"
                   FontFamily="Consolas" FontSize="11"
                   BorderThickness="0" IsReadOnly="True"
                   TextWrapping="Wrap" Padding="6"
                   VerticalScrollBarVisibility="Disabled"/>
        </ScrollViewer>
      </Border>

      <!-- Stats, progress, and action buttons -->
      <Grid Grid.Row="1" Margin="0,6,0,0">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <!-- Stats -->
        <Border Grid.Column="0" BorderBrush="LightGray" BorderThickness="1" Padding="8,6" Margin="0,0,6,0">
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <TextBlock Text="Space Freed: " FontSize="11" Foreground="Gray" VerticalAlignment="Center"/>
            <TextBlock Name="txtFreed" Text="0 MB" FontSize="14" FontWeight="Bold" Margin="2,0,10,0" VerticalAlignment="Center"/>
            <TextBlock Name="txtFiles" Text="0 files removed" FontSize="10" Foreground="Gray" VerticalAlignment="Center"/>
          </StackPanel>
        </Border>

        <!-- Progress -->
        <Border Grid.Column="1" BorderBrush="LightGray" BorderThickness="1" Padding="8,6" Margin="0,0,6,0">
          <StackPanel VerticalAlignment="Center">
            <TextBlock Name="txtTask" Text="Idle" FontSize="10" Foreground="Gray" Margin="0,0,0,3" TextWrapping="Wrap"/>
            <ProgressBar Name="pb" Height="6" Minimum="0" Maximum="100" Value="0"/>
          </StackPanel>
        </Border>

        <!-- Action buttons -->
        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
          <!-- Hidden elements for script compatibility -->
          <Border Name="pnlDeep" Visibility="Collapsed">
            <StackPanel>
              <ListBox Name="lstDeep" Visibility="Collapsed"/>
              <Button Name="btnDelete"    Visibility="Collapsed"/>
              <Button Name="btnSwipeMode" Visibility="Collapsed"/>
            </StackPanel>
          </Border>
          <Button Name="btnRun"   Content="Run Selected Mode" Padding="10,8" Margin="0,0,4,0"
                  FontSize="12" IsEnabled="False"/>
          <Button Name="btnNukeContinue" Content="&#x2714; Done reviewing continue Full Nuke"
                  Padding="8,8" Margin="0,0,4,0" Visibility="Collapsed"
                  Background="#2E7D32" Foreground="White" FontWeight="Bold"/>
          <Button Name="btnClear" Content="Clear Log" Padding="8,8" Margin="0,0,4,0"/>
          <Button Name="btnExit"  Content="Exit"      Padding="8,8"/>
        </StackPanel>
      </Grid>
    </Grid>

    <!-- Admin warning -->
    <Border Grid.Row="3" Name="pnlAdminWarn" BorderBrush="DarkOrange"
            BorderThickness="1" Padding="6,4" Margin="0,6,0,0"
            Visibility="Collapsed">
      <TextBlock Text="Not running as Administrator some operations will be skipped. Use Run_PCCleaner.bat to auto-elevate."
                 FontSize="10" Foreground="DarkOrange" TextWrapping="Wrap"/>
    </Border>

    <!-- Status bar -->
    <Border Grid.Row="4" BorderBrush="LightGray" BorderThickness="1"
            Padding="6,3" Margin="0,6,0,0">
      <TextBlock Name="txtBar" Text="Ready." FontSize="10" Foreground="Gray"/>
    </Border>
  </Grid>
</Window>
'@

# Build window
$reader = [System.Xml.XmlNodeReader]::new($XAML)
$win    = [Windows.Markup.XamlReader]::Load($reader)

$txtStatus    = $win.FindName('txtStatus')
$txtLog       = $win.FindName('txtLog')
$scroller     = $win.FindName('scroller')
$txtFreed     = $win.FindName('txtFreed')
$txtFiles     = $win.FindName('txtFiles')
$txtTask      = $win.FindName('txtTask')
$txtBar       = $win.FindName('txtBar')
$pb           = $win.FindName('pb')
$btnRun       = $win.FindName('btnRun')
$btnClear     = $win.FindName('btnClear')
$btnExit      = $win.FindName('btnExit')
$btnDelete    = $win.FindName('btnDelete')
$btnSwipeMode = $win.FindName('btnSwipeMode')
$lstDeep      = $win.FindName('lstDeep')
$pnlDeep      = $win.FindName('pnlDeep')
$pnlAdminWarn = $win.FindName('pnlAdminWarn')
$cStandard    = $win.FindName('cStandard')
$cDeep        = $win.FindName('cDeep')
$cApps        = $win.FindName('cApps')
$cSpeed       = $win.FindName('cSpeed')
$cAll         = $win.FindName('cAll')
$btnNukeContinue = $win.FindName('btnNukeContinue')

# Script state
$script:mode      = ''
$script:freed     = 0
$script:fileCount = 0
$script:swipeItems     = @()
$script:swipeDecisions = @{}
$script:deepScanDone   = $false

# Helpers

function DoEvents {
    $win.Dispatcher.Invoke(
        [System.Windows.Threading.DispatcherPriority]::Background,
        [Action]{}
    )
}

function Log {
    param([string]$msg, [string]$pre = '   ')
    $ts = Get-Date -Format 'HH:mm:ss'
    $txtLog.AppendText("[$ts] $pre$msg`r`n")
    $scroller.ScrollToBottom()
    DoEvents
}
function LogOK   { param($m) Log $m 'OK   ' }
function LogWarn { param($m) Log $m 'WARN ' }
function LogErr  { param($m) Log $m 'ERR  ' }
function LogHead { param($m) Log "=== $m ===" '     ' }
function LogSkip { param($m) Log $m 'SKIP ' }

function SetProgress {
    param([string]$task, [int]$pct)
    $txtTask.Text = $task
    $txtBar.Text  = $task
    $pb.Value     = $pct
    DoEvents
}

function AddFreed {
    param([long]$bytes, [int]$files = 1)
    $script:freed     += $bytes
    $script:fileCount += $files
    $mb = [math]::Round($script:freed / 1MB, 1)
    $gb = [math]::Round($script:freed / 1GB, 2)
    $txtFreed.Text = if ($mb -ge 1024) { "$gb GB" } else { "$mb MB" }
    $txtFiles.Text = "$($script:fileCount) files removed"
    DoEvents
}

function CleanFolder {
    param([string]$path)
    if (-not (Test-Path $path)) { LogSkip "Not found: $path"; return }
    try {
        $items = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue
        $bytes = ($items | Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
        $count = ($items | Where-Object { -not $_.PSIsContainer }).Count
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        $freed = if (Test-Path $path) {
            $rem = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue |
                    Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
            [Math]::Max(0, $bytes - $rem)
        } else { $bytes }
        AddFreed -bytes $freed -files $count
        LogOK "$path  ($([math]::Round($freed/1MB,1)) MB, $count files)"
    } catch {
        LogErr "$path"
    }
}

function SelectCard {
    param([string]$m)
    $script:mode = $m
    $desc = @{
        Standard = 'Standard: Temp files, caches, update cache, browser cache, recycle bin, DISM cleanup'
        Deep     = 'Deep Scan: Finds large and old files. Interactive you pick what to delete.'
        Apps     = 'App Reviewer: Finds installed programs not used in 30+ days. Review and uninstall interactively.'
        Speed    = 'Speed Boost: Power plan, visual effects, DNS flush, RAM purge, Game Bar off, SFC scan'
        All      = 'Full Nuke: Runs Standard, Deep Scan (you review files), App Reviewer, then Speed Boost'
    }
    $txtStatus.Text   = $desc[$m]
    $btnRun.IsEnabled = $true
}

# Clean routines

function Run-Standard {
    LogHead 'STANDARD CLEAN'

    SetProgress 'Checking CompactOS status...' 5
    try {
        $q = & compact.exe /CompactOS:query 2>&1 | Out-String
        if ($q -match 'system is in the Compact state') {
            LogWarn 'CompactOS already active, skipping.'
        } else {
            Log 'OS not compressed. Running CompactOS (may take a few minutes)...'
            SetProgress 'Running CompactOS...' 8
            & compact.exe /CompactOS:always 2>&1 | Out-Null
            LogOK 'CompactOS complete.'
        }
    } catch { LogErr "CompactOS: $_" }

    SetProgress 'Cleaning user profile temp folders...' 18
    LogHead 'User Profile Folders'
    $users = Get-ChildItem "$env:SystemDrive\Users" -Directory -ErrorAction SilentlyContinue
    foreach ($u in $users) {
        $base = $u.FullName
        CleanFolder "$base\AppData\Local\Temp"
        CleanFolder "$base\AppData\Local\Microsoft\Windows\INetCache"
        CleanFolder "$base\AppData\Local\Microsoft\Windows\INetCookies"
        CleanFolder "$base\AppData\Local\CrashDumps"
        CleanFolder "$base\AppData\Local\Microsoft\Windows\WER"
    }

    SetProgress 'Cleaning system temp and Windows Update cache...' 35
    LogHead 'System Temp and Windows Update'
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    CleanFolder "$env:SystemDrive\Temp"
    CleanFolder "$env:WINDIR\Temp"
    CleanFolder "$env:WINDIR\Prefetch"
    CleanFolder "$env:WINDIR\SoftwareDistribution\Download"
    New-Item "$env:WINDIR\SoftwareDistribution\Download" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    LogOK 'Windows Update cache cleared and service restarted.'

    SetProgress 'Cleaning browser caches...' 52
    LogHead 'Browser Caches'
    foreach ($u in $users) {
        $b = $u.FullName
        CleanFolder "$b\AppData\Local\Google\Chrome\User Data\Default\Cache"
        CleanFolder "$b\AppData\Local\Google\Chrome\User Data\Default\Code Cache"
        CleanFolder "$b\AppData\Local\Google\Chrome\User Data\Default\GPUCache"
        CleanFolder "$b\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
        CleanFolder "$b\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache"
        CleanFolder "$b\AppData\Roaming\Mozilla\Firefox\Profiles"
        CleanFolder "$b\AppData\Roaming\Opera Software\Opera Stable\Cache"
        CleanFolder "$b\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache"
    }

    SetProgress 'Emptying Recycle Bin...' 65
    LogHead 'Recycle Bin'
    try {
        $rb = "$env:SystemDrive\`$Recycle.Bin"
        if (Test-Path $rb) {
            $sz = (Get-ChildItem $rb -Recurse -Force -ErrorAction SilentlyContinue |
                   Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
            Remove-Item $rb -Recurse -Force -ErrorAction SilentlyContinue
            AddFreed -bytes $sz -files 0
            LogOK 'Recycle Bin emptied.'
        } else { LogSkip 'Recycle Bin already empty.' }
    } catch { LogErr "Recycle Bin: $_" }

    SetProgress 'Clearing event logs...' 72
    LogHead 'Event Logs'
    try {
        Get-EventLog -List -ErrorAction SilentlyContinue | ForEach-Object {
            Clear-EventLog -LogName $_.Log -ErrorAction SilentlyContinue
        }
        LogOK 'Event logs cleared.'
    } catch { LogWarn 'Could not clear some event logs.' }

    SetProgress 'Running DISM WinSxS cleanup (may take 5-15 minutes)...' 80
    LogHead 'DISM / WinSxS Component Store'
    Log 'Please wait, this is the slowest step...'
    try {
        & Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 |
            ForEach-Object { if ($_ -match '\d+\.\d+%|complete|error') { Log "  DISM: $_" } }
        LogOK 'DISM cleanup complete.'
    } catch { LogErr "DISM: $_" }

    SetProgress 'Running Windows Disk Cleanup...' 95
    LogHead 'Windows Disk Cleanup (cleanmgr)'
    $rk = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
    Get-ChildItem $rk -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty $_.PSPath StateFlags0001 2 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Start-Process cleanmgr.exe -ArgumentList '/sagerun:1' -Wait -ErrorAction SilentlyContinue
    LogOK 'Windows Disk Cleanup complete.'

    SetProgress 'Standard clean done!' 100
    LogHead 'STANDARD CLEAN COMPLETE'
}

function Run-DeepScan {
    LogHead 'DEEP SCAN'
    SetProgress 'Starting smart background scan...' 5
    Log 'Analysing your drive intelligently, dev tools, SDKs and libraries are protected.'
    DoEvents

    # Scan script runs off the UI thread. Returns PSCustomObjects so file metadata
    # survives the runspace boundary (FileInfo objects don't serialise cleanly).
    $scanScript = {
        param($systemDrive, $userProfile)

        # Folders whose contents are always protected
        $protectedFolderPatterns = @(
            # Flutter / Dart
            '\.pub\b', 'flutter\b', 'dart\b', 'pub-cache',
            # Arduino / embedded
            'arduino', 'libraries\\', 'hardware\\',
            # Android / Gradle / ADB
            '\.gradle', 'android\\sdk', 'android-sdk', 'platform-tools',
            # Node / JS tooling
            'node_modules',
            # Python envs
            '\.venv', 'virtualenv', 'site-packages', 'conda', 'miniconda', 'anaconda',
            # Java / Maven / Kotlin
            '\.m2\\repository', '\.ivy2', 'jdk', 'jre',
            # Rust
            '\.cargo\\registry', '\.rustup',
            # Go
            'go\\pkg\\mod',
            # Visual Studio / .NET SDKs
            'microsoft visual studio', '\.nuget\\packages', 'dotnet\\sdk',
            # Games / big launchers (let user decide themselves)
            'steam\\steamapps', 'epicgames', 'battle\.net',
            # Source control data
            '\.git\\objects', '\.git\\lfs',
            # VM images
            'virtualbox vms', 'vmware'
        )

        # Extensions that are almost always safe to delete
        $junkExtensions = @(
            '.tmp', '.temp', '.log', '.old', '.bak', '.dmp', '.mdmp',
            '.etl', '.wer', '.cab'   # Windows error/diagnostic
        )

        # Extensions typically safe to remove from Downloads/Desktop only
        $installerExtensions = @(
            '.exe', '.msi', '.msix', '.iso', '.img', '.dmg',
            '.zip', '.7z', '.rar', '.tar', '.gz', '.xz'
        )

        # High-value junk target directories
        $junkTargets = @(
            "$userProfile\Downloads",
            "$userProfile\Desktop",
            "$userProfile\Videos",          # large personal media often forgotten
            "$systemDrive\Users\Public\Downloads",
            "$env:LOCALAPPDATA\Temp",
            "$env:LOCALAPPDATA\CrashDumps",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
            "$env:LOCALAPPDATA\Microsoft\Windows\WER",
            # Game / app crash dumps
            "$env:LOCALAPPDATA\Packages"
        )

        $cutoff6m  = (Get-Date).AddMonths(-6)
        $cutoff12m = (Get-Date).AddMonths(-12)
        $results   = [System.Collections.Generic.List[object]]::new()

        function Is-Protected([string]$path) {
            $lower = $path.ToLower()
            foreach ($pat in $protectedFolderPatterns) {
                if ($lower -match $pat) { return $true }
            }
            return $false
        }

        function Score-File($f) {
            # Returns integer score. Higher = more worth deleting. Negative = skip.
            if (Is-Protected $f.FullName) { return -99 }

            $ext   = $f.Extension.ToLower()
            $lower = $f.FullName.ToLower()
            $mbSize = $f.Length / 1MB
            $ageDays = ((Get-Date) - $f.LastWriteTime).TotalDays
            $score = 0

            # Always-junk extensions get a big bonus
            if ($junkExtensions -contains $ext) { $score += 40 }

            # Installers/archives in Downloads/Desktop are likely stale
            if ($installerExtensions -contains $ext) {
                if ($lower -match 'downloads|desktop') { $score += 30 }
                else { return -1 }  # installers elsewhere = skip
            }

            # Video files outside of protected paths: only surface if >100MB
            if ($ext -in @('.mp4','.mkv','.avi','.mov','.wmv')) {
                if ($mbSize -lt 100) { return -1 }
                $score += 10
            }

            # Size scoring (MB)
            $score += [math]::Min(40, [int]($mbSize / 25))

            # Age scoring
            if ($ageDays -gt 365) { $score += 20 }
            elseif ($ageDays -gt 180) { $score += 10 }

            # Penalise common false-positive patterns (project assets, fonts, docs)
            if ($lower -match 'project|workspace|source|src|assets|fonts|icons|images|docs|documents') {
                $score -= 20
            }
            # Penalise anything in a path that looks like a dev repo
            if ($lower -match '\\repos\\|\\projects\\|\\dev\\|\\code\\|\\workspace\\') {
                $score -= 30
            }

            return $score
        }

        # Scan junk targets
        foreach ($dir in $junkTargets) {
            if (-not (Test-Path $dir)) { continue }
            try {
                Get-ChildItem $dir -Recurse -File -Force -ErrorAction SilentlyContinue |
                    Where-Object { $_.Length -gt 1MB } |
                    ForEach-Object {
                        $s = Score-File $_
                        if ($s -ge 10) {
                            $results.Add([PSCustomObject]@{
                                FullName      = $_.FullName
                                Name          = $_.Name
                                Length        = $_.Length
                                LastWriteTime = $_.LastWriteTime
                                Score         = $s
                                Reason        = if ($_.Extension -in $junkExtensions) { 'Junk/temp file' }
                                               elseif ($_.Extension -in $installerExtensions) { 'Old installer/archive' }
                                               else { 'Large unused file' }
                            })
                        }
                    }
            } catch {}
        }

        # Secondary pass: catch large crash dumps / logs anywhere in Users
        try {
            Get-ChildItem "$systemDrive\Users" -Recurse -File -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.Length -gt 50MB -and
                               ($junkExtensions -contains $_.Extension.ToLower()) } |
                Where-Object { -not (Is-Protected $_.FullName) } |
                ForEach-Object {
                    # Avoid duplicates from first pass
                    if (-not ($results | Where-Object { $_.FullName -eq $_.FullName })) {
                        $results.Add([PSCustomObject]@{
                            FullName      = $_.FullName
                            Name          = $_.Name
                            Length        = $_.Length
                            LastWriteTime = $_.LastWriteTime
                            Score         = 60
                            Reason        = 'Large junk/log/dump file'
                        })
                    }
                }
        } catch {}

        # Return top 250, sorted by score desc then size desc
        $results |
            Sort-Object Score -Descending |
            Select-Object -First 250
    }

    # Start background runspace
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript($scanScript)
    [void]$ps.AddArgument($env:SystemDrive)
    [void]$ps.AddArgument($env:USERPROFILE)
    $asyncResult = $ps.BeginInvoke()

    # DispatcherTimer keeps UI responsive while scan runs in background
    $phases = @(
        @{ pct=12; msg='Scanning Downloads & Desktop...' },
        @{ pct=25; msg='Scanning Videos & Public folders...' },
        @{ pct=38; msg='Checking crash dumps & logs...' },
        @{ pct=50; msg='Filtering dev/SDK paths...' },
        @{ pct=62; msg='Scoring and ranking files...' },
        @{ pct=74; msg='Almost done...' }
    )
    $script:_phaseIdx = 0
    $script:_sw       = [System.Diagnostics.Stopwatch]::StartNew()

    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(150)

    $timer.Add_Tick({
        if (-not $asyncResult.IsCompleted) {
            # Advance phase label every ~4 s
            if ($script:_sw.ElapsedMilliseconds -gt 4000) {
                $script:_sw.Restart()
                if ($script:_phaseIdx -lt $phases.Count) {
                    $p = $phases[$script:_phaseIdx]
                    SetProgress $p.msg $p.pct
                    $script:_phaseIdx++
                }
            }
            return   # still running cum on me next tick
        }

        # Scan finished collect results
        $timer.Stop()

        $all = @($ps.EndInvoke($asyncResult))
        $ps.Dispose()
        $rs.Close()
        $rs.Dispose()

        $script:deepItems  = $all
        $script:swipeItems = @($all)

        $skipped = ($all | Where-Object { $_.Reason -eq $null }).Count
        Log "Smart scan complete. Found $($all.Count) candidate files (dev/SDK folders protected)."
        if ($all.Count -eq 0) {
            Log 'Nothing suspicious(nice, theres no cp) found your drive looks clean!'
        } else {
            # Group by reason for a quick summary
            $all | Group-Object Reason | ForEach-Object {
                $totalMB = [math]::Round(($_.Group | Measure-Object Length -Sum).Sum / 1MB, 0)
                Log "  $($_.Name): $($_.Count) file(s) - ${totalMB} MB"
            }
        }
        SetProgress 'Scan complete.' 85
        DoEvents

        $lstDeep.Items.Clear()
        foreach ($f in $all) {
            $mb  = [math]::Round($f.Length / 1MB, 1)
            $age = [math]::Round(((Get-Date) - $f.LastWriteTime).TotalDays)
            $tag = if ($f.Reason) { $f.Reason } else { 'Large file' }
            [void]$lstDeep.Items.Add("[$mb MB | ${age}d | $tag]  $($f.FullName)")
        }

        $pnlDeep.Visibility      = 'Collapsed'
        $btnDelete.Visibility    = 'Collapsed'
        $btnSwipeMode.Visibility = 'Collapsed'
        SetProgress 'Scan done! Opening File Reviewer...' 100
        LogHead 'DEEP SCAN COMPLETE, opening reviewer'
        DoEvents
        # Auto-open the reviewer immediately
        if ($script:swipeItems.Count -gt 0) {
            Open-FileReviewer
        }
    })

    $timer.Start()

    # Push a nested dispatcher frame so WPF keeps processing events while we wait
    $frame = [System.Windows.Threading.DispatcherFrame]::new($true)
    $timer.Add_Tick({
        if (-not $timer.IsEnabled) {
            $frame.Continue = $false
        }
    })
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

function Run-AppReviewer {
    LogHead 'APP REVIEWER'
    SetProgress 'Scanning installed applications...' 5
    Log 'Looking for programs that have not been used in 30+ days...'
    DoEvents

    # Collect installed apps from registry (covers both 32-bit and 64-bit)
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    # Apps we never flag system components, runtimes, drivers, security tools
    $systemPatterns = @(
        'microsoft visual c\+\+', 'microsoft .net', 'windows sdk', 'windows kits',
        'directx', 'vcredist', 'dotnet', 'windows defender', 'malwarebytes',
        'intel', 'amd ', 'nvidia', 'realtek', 'broadcom', 'qualcomm',
        'driver', 'update for windows', 'security update', 'hotfix',
        'redistributable', 'runtime', 'framework', 'service pack',
        'microsoft edge', 'webview2', 'onedrive setup'
    )

    $now    = Get-Date
    $cutoff = $now.AddDays(-30)

    $candidates = [System.Collections.Generic.List[object]]::new()

    foreach ($path in $regPaths) {
        try {
            Get-ItemProperty $path -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.DisplayName -and
                    -not $_.SystemComponent -and
                    $_.UninstallString
                } |
                ForEach-Object {
                    $name    = $_.DisplayName
                    $lower   = $name.ToLower()
                    $version = $_.DisplayVersion
                    $size    = $_.EstimatedSize   # KB, may be missing
                    $uninst  = $_.UninstallString

                    # Skip system components
                    foreach ($pat in $systemPatterns) {
                        if ($lower -match $pat) { return }
                    }

                    # Try to find the install location and check last-used date
                    $installDir  = $_.InstallLocation
                    $lastUsedDays = $null

                    if ($installDir -and (Test-Path $installDir)) {
                        try {
                            $newest = Get-ChildItem $installDir -Recurse -File -Force -ErrorAction SilentlyContinue |
                                      Sort-Object LastAccessTime -Descending |
                                      Select-Object -First 1
                            if ($newest) {
                                $lastUsedDays = [math]::Round(($now - $newest.LastAccessTime).TotalDays)
                            }
                        } catch {}
                    }

                    # Fall back to install date from registry if we couldn't check files
                    $installDateStr = $_.InstallDate   # format: YYYYMMDD
                    $installDate    = $null
                    if ($installDateStr -match '^\d{8}$') {
                        try { $installDate = [datetime]::ParseExact($installDateStr, 'yyyyMMdd', $null) } catch {}
                    }

                    # Only include if we have evidence it hasn't been touched in 30+ days
                    $flag = $false
                    $reason = ''
                    if ($lastUsedDays -ne $null -and $lastUsedDays -ge 30) {
                        $flag   = $true
                        $reason = "Last file access: ${lastUsedDays} days ago"
                    } elseif ($lastUsedDays -eq $null -and $installDate -ne $null -and $installDate -lt $cutoff) {
                        $flag   = $true
                        $reason = "Installed $([math]::Round(($now - $installDate).TotalDays)) days ago, no usage data"
                    }

                    if ($flag) {
                        $sizeMB = if ($size) { [math]::Round($size / 1024, 1) } else { $null }
                        $candidates.Add([PSCustomObject]@{
                            Name         = $name
                            Version      = $version
                            SizeMB       = $sizeMB
                            Reason       = $reason
                            LastUsedDays = $lastUsedDays
                            InstallDate  = $installDate
                            UninstallCmd = $uninst
                        })
                    }
                }
        } catch {}
    }

    # Deduplicate by name (same app can appear in multiple registry hives)
    $seen = @{}
    $unique = [System.Collections.Generic.List[object]]::new()
    foreach ($a in $candidates) {
        if (-not $seen.ContainsKey($a.Name)) {
            $seen[$a.Name] = $true
            $unique.Add($a)
        }
    }

    # Sort: longest unused first
    $sorted = @($unique | Sort-Object { if ($_.LastUsedDays) { $_.LastUsedDays } else { 9999 } } -Descending)

    SetProgress 'Scan complete.' 80
    Log "Found $($sorted.Count) potentially unused application(s)."
    DoEvents

    if ($sorted.Count -eq 0) {
        Log 'No unused applications found, everything looks actively used!'
        SetProgress 'App review done.' 100
        LogHead 'APP REVIEWER COMPLETE'
        return
    }

    # Show the interactive App Reviewer popup
    Open-AppReviewer $sorted
    LogHead 'APP REVIEWER COMPLETE'
    SetProgress 'App review done.' 100
}

function Open-AppReviewer {
    param($apps)

    if ($apps.Count -eq 0) { return }

    [xml]$arXAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="App Reviewer" Height="620" Width="760"
    WindowStartupLocation="CenterOwner"
    ResizeMode="CanResizeWithGrip"
    MinWidth="560" MinHeight="460">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- App name and badge -->
    <Border Grid.Row="0" Background="#F5F5F5" BorderBrush="#DDDDDD"
            BorderThickness="0,0,0,1" Padding="14,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
          <TextBlock Name="arAppName" Text="" FontSize="15" FontWeight="Bold" TextWrapping="Wrap"/>
          <TextBlock Name="arVersion" Text="" FontSize="10" Foreground="#888" Margin="0,2,0,0"/>
        </StackPanel>
        <Border Grid.Column="1" Name="arBadge" CornerRadius="4"
                Padding="10,4" Margin="10,0,0,0" VerticalAlignment="Center" Background="#EEEEEE">
          <TextBlock Name="arBadgeText" Text="Undecided" FontSize="12" FontWeight="Bold" Foreground="#888"/>
        </Border>
      </Grid>
    </Border>

    <!-- Meta bar -->
    <Border Grid.Row="1" Background="#FAFAFA" BorderBrush="#DDDDDD"
            BorderThickness="0,0,0,1" Padding="14,6">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Orientation="Horizontal" Grid.Column="0">
          <TextBlock Name="arSize"   FontSize="11" Foreground="#555" Margin="0,0,16,0"/>
          <TextBlock Name="arReason" FontSize="11" Foreground="#E67E22" FontWeight="SemiBold"/>
        </StackPanel>
        <TextBlock Name="arCounter" Grid.Column="1" FontSize="11" Foreground="#888" VerticalAlignment="Center"/>
      </Grid>
    </Border>

    <!-- App list overview -->
    <Border Grid.Row="2" Margin="12,10,12,0" BorderBrush="#CCCCCC" BorderThickness="1" Background="White">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#EEEEEE" BorderBrush="#CCCCCC"
                BorderThickness="0,0,0,1" Padding="8,5">
          <TextBlock Text="All unused apps found on this PC, current app highlighted"
                     FontSize="11" Foreground="#333"/>
        </Border>
        <ListBox Name="arList" Grid.Row="1" BorderThickness="0"
                 FontFamily="Consolas" FontSize="11"
                 ScrollViewer.HorizontalScrollBarVisibility="Auto"
                 ScrollViewer.VerticalScrollBarVisibility="Auto"
                 HorizontalContentAlignment="Left"
                 IsHitTestVisible="False"/>
      </Grid>
    </Border>

    <!-- Bottom buttons -->
    <Border Grid.Row="3" Background="#F0F0F0" BorderBrush="#DDDDDD"
            BorderThickness="0,1,0,0" Padding="12,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Button Name="arPrev"   Grid.Column="0" Content="&lt; Prev"  Width="90"  Padding="0,10" FontSize="13"/>
        <Button Name="arKeep"   Grid.Column="2" Content="Keep"       Width="130" Padding="0,10" FontSize="14"
                FontWeight="Bold" Background="#2E7D32" Foreground="White" Margin="0,0,8,0"/>
        <Button Name="arUninstall" Grid.Column="3" Content="Uninstall" Width="130" Padding="0,10" FontSize="14"
                FontWeight="Bold" Background="#C62828" Foreground="White" Margin="8,0,0,0"/>
        <Button Name="arNext"   Grid.Column="5" Content="Next &gt;"  Width="90"  Padding="0,10" FontSize="13"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

    $arReader  = [System.Xml.XmlNodeReader]::new($arXAML)
    $arWin     = [Windows.Markup.XamlReader]::Load($arReader)
    $arWin.Owner = $win

    $arAppName   = $arWin.FindName('arAppName')
    $arVersion   = $arWin.FindName('arVersion')
    $arBadge     = $arWin.FindName('arBadge')
    $arBadgeText = $arWin.FindName('arBadgeText')
    $arSize      = $arWin.FindName('arSize')
    $arReason    = $arWin.FindName('arReason')
    $arCounter   = $arWin.FindName('arCounter')
    $arList      = $arWin.FindName('arList')
    $arPrev      = $arWin.FindName('arPrev')
    $arNext      = $arWin.FindName('arNext')
    $arKeep      = $arWin.FindName('arKeep')
    $arUninstall = $arWin.FindName('arUninstall')

    $script:arItems     = $apps
    $script:arIdx       = 0
    $script:arDecisions = @{}   # name -> 'keep'|'uninstall'

    $brushConv = [System.Windows.Media.BrushConverter]::new()

    function ar_ShowCard {
        $i   = $script:arIdx
        $app = $script:arItems[$i]
        $dec = if ($script:arDecisions.ContainsKey($app.Name)) { $script:arDecisions[$app.Name] } else { '' }

        $arAppName.Text  = $app.Name
        $arVersion.Text  = if ($app.Version) { "Version $($app.Version)" } else { 'Version unknown' }
        $arSize.Text     = if ($app.SizeMB)  { "$($app.SizeMB) MB" } else { 'Size unknown' }
        $arReason.Text   = $app.Reason
        $arCounter.Text  = "App $($i + 1) of $($script:arItems.Count)"

        switch ($dec) {
            'uninstall' {
                $arBadge.Background     = $brushConv.ConvertFromString('#FFEBEE')
                $arBadgeText.Foreground = $brushConv.ConvertFromString('#C62828')
                $arBadgeText.Text       = '[UNINSTALL]'
            }
            'keep' {
                $arBadge.Background     = $brushConv.ConvertFromString('#E8F5E9')
                $arBadgeText.Foreground = $brushConv.ConvertFromString('#2E7D32')
                $arBadgeText.Text       = '[KEEP]'
            }
            default {
                $arBadge.Background     = $brushConv.ConvertFromString('#EEEEEE')
                $arBadgeText.Foreground = $brushConv.ConvertFromString('#888888')
                $arBadgeText.Text       = 'Undecided'
            }
        }

        # Refresh app list, highlighting current
        $arList.Items.Clear()
        for ($d = 0; $d -lt $script:arItems.Count; $d++) {
            $a      = $script:arItems[$d]
            $adec   = if ($script:arDecisions.ContainsKey($a.Name)) { $script:arDecisions[$a.Name] } else { '' }
            $isCur  = ($d -eq $script:arIdx)
            $prefix = if ($isCur) { '>>' } else { '  ' }
            $tag    = switch ($adec) { 'uninstall'{'[X]'} 'keep'{'[K]'} default{'[ ]'} }
            $sizeTxt= if ($a.SizeMB) { "$($a.SizeMB) MB" } else { '??  MB' }

            $tb = [System.Windows.Controls.TextBlock]::new()
            $tb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
            $tb.FontSize   = 11
            $tb.Padding    = [System.Windows.Thickness]::new(6,3,6,3)
            $tb.Text       = "$prefix $tag  $($a.Name.PadRight(40))  $sizeTxt"

            if ($isCur) {
                $tb.Background = $brushConv.ConvertFromString('#FFF3E0')
                $tb.Foreground = $brushConv.ConvertFromString('#E65100')
                $tb.SetValue(
                    [System.Windows.Controls.TextBlock]::FontWeightProperty,
                    [System.Windows.FontWeights]::Bold
                )
            } elseif ($adec -eq 'uninstall') {
                $tb.Foreground = $brushConv.ConvertFromString('#C62828')
            } elseif ($adec -eq 'keep') {
                $tb.Foreground = $brushConv.ConvertFromString('#2E7D32')
            } else {
                $tb.Foreground = $brushConv.ConvertFromString('#333333')
            }

            $li = [System.Windows.Controls.ListBoxItem]::new()
            $li.Content = $tb
            if ($isCur) { $li.Background = $brushConv.ConvertFromString('#FFF3E0') }
            [void]$arList.Items.Add($li)
            if ($isCur) { $arList.ScrollIntoView($li) }
        }
    }

    function ar_Mark ([string]$dec) {
        $script:arDecisions[$script:arItems[$script:arIdx].Name] = $dec
        if ($script:arIdx -lt ($script:arItems.Count - 1)) {
            $script:arIdx++
        }
        ar_ShowCard
    }

    $arKeep.Add_Click({      ar_Mark 'keep' })
    $arUninstall.Add_Click({ ar_Mark 'uninstall' })
    $arNext.Add_Click({ if ($script:arIdx -lt ($script:arItems.Count - 1)) { $script:arIdx++; ar_ShowCard } })
    $arPrev.Add_Click({ if ($script:arIdx -gt 0) { $script:arIdx--; ar_ShowCard } })

    $arWin.Add_KeyDown({
        param($s, $e)
        switch ($e.Key) {
            'Right' { if ($script:arIdx -lt ($script:arItems.Count - 1)) { $script:arIdx++; ar_ShowCard } }
            'Left'  { if ($script:arIdx -gt 0) { $script:arIdx--; ar_ShowCard } }
            'K'     { ar_Mark 'keep' }
            'U'     { ar_Mark 'uninstall' }
        }
    })

    # On close: run uninstalls for marked apps
    $arWin.Add_Closing({
        $toUninstall = @($script:arDecisions.GetEnumerator() |
                         Where-Object { $_.Value -eq 'uninstall' } |
                         ForEach-Object { $_.Key })

        if ($toUninstall.Count -eq 0) {
            Log 'App Reviewer closed. No apps marked for uninstall.'
            return
        }

        $ans = [System.Windows.MessageBox]::Show(
            "You marked $($toUninstall.Count) app(s) for uninstall:`n`n" +
            ($toUninstall -join "`n") +
            "`n`nLaunch their uninstallers now?",
            'Confirm Uninstall', 'YesNo', 'Warning')

        if ($ans -eq 'Yes') {
            foreach ($appName in $toUninstall) {
                $app = $script:arItems | Where-Object { $_.Name -eq $appName } | Select-Object -First 1
                if (-not $app) { continue }
                try {
                    Log "Launching uninstaller for: $appName"
                    $cmd = $app.UninstallCmd
                    # MsiExec needs /I replaced with /X and run via Start-Process
                    if ($cmd -match 'msiexec' -and $cmd -match '\{[A-F0-9\-]+\}') {
                        $guid = [regex]::Match($cmd, '\{[A-F0-9\-]+\}').Value
                        Start-Process 'msiexec.exe' -ArgumentList "/X $guid" -Wait -ErrorAction Stop
                    } elseif ($cmd -match '^"(.+?)"(.*)$') {
                        Start-Process $Matches[1] -ArgumentList $Matches[2].Trim() -Wait -ErrorAction Stop
                    } else {
                        Start-Process 'cmd.exe' -ArgumentList "/c `"$cmd`"" -Wait -ErrorAction Stop
                    }
                    LogOK "Uninstall launched: $appName"
                } catch {
                    LogErr "Could not launch uninstaller for $appName try via Settings > Apps."
                }
            }
            Log 'All selected uninstallers have been launched.'
        } else {
            Log "App Reviewer closed. $($toUninstall.Count) app(s) skipped."
        }
    })

    ar_ShowCard
    [void]$arWin.ShowDialog()
}

function Run-Speed {
    LogHead 'SPEED BOOST'

    SetProgress 'Auditing startup programs...' 10
    LogHead 'Startup Entries'
    $startKeys = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
    )
    $safeNames = @('SecurityHealth','WindowsDefender','ctfmon','Realtek','NVIDIA','AMD','Intel')
    foreach ($k in $startKeys) {
        $props = Get-ItemProperty $k -ErrorAction SilentlyContinue
        if ($props) {
            $props.PSObject.Properties |
                Where-Object { $_.Name -notmatch '^PS' -and $_.Name -notin $safeNames } |
                ForEach-Object { LogWarn "Startup: [$($_.Name)]  review in Task Manager > Startup tab" }
        }
    }
    LogOK 'Startup audit done.'

    SetProgress 'Setting visual effects to Performance mode...' 22
    LogHead 'Visual Effects'
    try {
        $vk = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
        if (-not (Test-Path $vk)) { New-Item $vk -Force | Out-Null }
        Set-ItemProperty $vk VisualFXSetting 2 -Type DWord -Force
        LogOK 'Visual effects: Best Performance mode set.'
    } catch { LogErr "Visual effects: $_" }

    SetProgress 'Activating High Performance power plan...' 34
    LogHead 'Power Plan'
    try {
        & powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Out-Null
        LogOK 'Power plan set to High Performance.'
    } catch { LogWarn 'Could not set power plan (may already be set).' }

    SetProgress 'Flushing DNS cache...' 44
    LogHead 'DNS Cache'
    & ipconfig /flushdns 2>&1 | Out-Null
    LogOK 'DNS cache flushed.'

    SetProgress 'Purging RAM standby list...' 54
    LogHead 'RAM Standby'
    try {
        $src = @'
using System;
using System.Runtime.InteropServices;
public class RamHelper {
    [DllImport("ntdll.dll")]
    public static extern int NtSetSystemInformation(int InfoClass, IntPtr Info, int Length);
    public static void PurgeStandby() {
        IntPtr p = Marshal.AllocHGlobal(4);
        Marshal.WriteInt32(p, 4);
        NtSetSystemInformation(80, p, 4);
        Marshal.FreeHGlobal(p);
    }
}
'@
        Add-Type -TypeDefinition $src -ErrorAction SilentlyContinue
        [RamHelper]::PurgeStandby()
        LogOK 'RAM standby list purged.'
    } catch { LogWarn 'RAM purge unavailable.' }

    SetProgress 'Checking SysMain (Superfetch)...' 63
    LogHead 'SysMain'
    try {
        $disk = Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($disk -and $disk.MediaType -eq 'HDD') {
            Stop-Service SysMain -Force -ErrorAction SilentlyContinue
            Set-Service  SysMain -StartupType Disabled -ErrorAction SilentlyContinue
            LogOK 'SysMain disabled (HDD detected).'
        } else {
            LogSkip 'SSD detected SysMain kept on (beneficial for SSDs).'
        }
    } catch { LogWarn 'Could not check disk type.' }

    SetProgress 'Disabling Xbox Game Bar and DVR...' 73
    LogHead 'Xbox Game Bar'
    Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar'  AllowAutoGameMode 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty 'HKCU:\System\GameConfigStore'       GameDVR_Enabled   0 -Type DWord -Force -ErrorAction SilentlyContinue
    LogOK 'Xbox Game Bar and DVR disabled.'

    SetProgress 'Running System File Checker (sfc /scannow)...' 85
    LogHead 'SFC System Scan'
    Log 'Running sfc /scannow this can take several minutes...'
    try {
        $sfc = & sfc /scannow 2>&1 | Out-String
        if ($sfc -match 'did not find any integrity violations') {
            LogOK 'SFC: No integrity violations. System files are healthy.'
        } elseif ($sfc -match 'successfully repaired') {
            LogOK 'SFC: Corrupted files found and repaired.'
        } elseif ($sfc -match 'could not repair') {
            LogWarn 'SFC: Some files could not be repaired. Try DISM /RestoreHealth then re-run SFC.'
        } else {
            LogWarn 'SFC finished. Check C:\Windows\Logs\CBS\CBS.log for details.'
        }
    } catch { LogErr "SFC failed: $_" }

    SetProgress 'Speed boost complete!' 100
    LogHead 'SPEED BOOST COMPLETE'
}

# Events

$cStandard.Add_Click({ SelectCard 'Standard' })
$cDeep.Add_Click({     SelectCard 'Deep' })
$cApps.Add_Click({     SelectCard 'Apps' })
$cSpeed.Add_Click({    SelectCard 'Speed' })
$cAll.Add_Click({      SelectCard 'All' })

# File Reviewer session decisions saved to .tmp for free navigation, yes im fucking lazy stfu
$script:sessionFile = [System.IO.Path]::Combine($env:TEMP, 'PCCleaner_review.tmp')

function Save-Decisions {
    try {
        $script:swipeDecisions | ConvertTo-Json -Compress | Set-Content $script:sessionFile -Encoding UTF8
    } catch {}
}

function Load-Decisions {
    if (Test-Path $script:sessionFile) {
        try {
            $loaded = Get-Content $script:sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $script:swipeDecisions = @{}
            $loaded.PSObject.Properties | ForEach-Object { $script:swipeDecisions[$_.Name] = $_.Value }
        } catch { $script:swipeDecisions = @{} }
    }
}

function Open-FileReviewer {
    if ($script:swipeItems.Count -eq 0) { return }
    Load-Decisions

    # File Reviewer popup XAML
    [xml]$rwXAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="File Reviewer" Height="620" Width="740"
    WindowStartupLocation="CenterOwner"
    ResizeMode="CanResizeWithGrip"
    MinWidth="560" MinHeight="460">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- File name and badge -->
    <Border Grid.Row="0" Background="#F5F5F5" BorderBrush="#DDDDDD"
            BorderThickness="0,0,0,1" Padding="14,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
          <TextBlock Name="rwFileName" Text="" FontSize="15" FontWeight="Bold" TextWrapping="Wrap"/>
          <TextBlock Name="rwFilePath" Text="" FontSize="10" Foreground="#888" TextWrapping="Wrap" Margin="0,3,0,0"/>
        </StackPanel>
        <Border Grid.Column="1" Name="rwBadge" CornerRadius="4"
                Padding="10,4" Margin="10,0,0,0" VerticalAlignment="Center" Background="#EEEEEE">
          <TextBlock Name="rwBadgeText" Text="Undecided" FontSize="12" FontWeight="Bold" Foreground="#888"/>
        </Border>
      </Grid>
    </Border>

    <!-- Meta bar -->
    <Border Grid.Row="1" Background="#FAFAFA" BorderBrush="#DDDDDD"
            BorderThickness="0,0,0,1" Padding="14,6">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <StackPanel Orientation="Horizontal" Grid.Column="0">
          <TextBlock Name="rwSize"   FontSize="11" Foreground="#555" Margin="0,0,16,0"/>
          <TextBlock Name="rwAge"    FontSize="11" Foreground="#555" Margin="0,0,16,0"/>
          <TextBlock Name="rwReason" FontSize="11" Foreground="#E67E22" FontWeight="SemiBold"/>
        </StackPanel>
        <TextBlock Name="rwCounter" Grid.Column="1" FontSize="11" Foreground="#888" VerticalAlignment="Center"/>
      </Grid>
    </Border>

    <!-- Folder view -->
    <Border Grid.Row="2" Margin="12,10,12,0" BorderBrush="#CCCCCC" BorderThickness="1" Background="White">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#EEEEEE" BorderBrush="#CCCCCC"
                BorderThickness="0,0,0,1" Padding="8,5">
          <TextBlock Name="rwFolder" FontSize="11" Foreground="#333"
                     FontFamily="Consolas" TextWrapping="NoWrap" TextTrimming="CharacterEllipsis"/>
        </Border>
        <ListBox Name="rwSiblings" Grid.Row="1" BorderThickness="0"
                 FontFamily="Consolas" FontSize="11"
                 ScrollViewer.HorizontalScrollBarVisibility="Auto"
                 ScrollViewer.VerticalScrollBarVisibility="Auto"
                 HorizontalContentAlignment="Left"
                 IsHitTestVisible="False"/>
      </Grid>
    </Border>

    <!-- Progress dots -->
    <Border Grid.Row="3" Padding="12,6" BorderBrush="#DDDDDD" BorderThickness="0,1,0,0" Margin="0,8,0,0">
      <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Hidden" Height="20">
        <ItemsControl Name="rwDots">
          <ItemsControl.ItemsPanel>
            <ItemsPanelTemplate>
              <StackPanel Orientation="Horizontal"/>
            </ItemsPanelTemplate>
          </ItemsControl.ItemsPanel>
        </ItemsControl>
      </ScrollViewer>
    </Border>

    <!-- Bottom buttons -->
    <Border Grid.Row="4" Background="#F0F0F0" BorderBrush="#DDDDDD"
            BorderThickness="0,1,0,0" Padding="12,10">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Button Name="rwPrev"   Grid.Column="0" Content="&lt; Prev"    Width="90"  Padding="0,10" FontSize="13"/>
        <Button Name="rwKeep"   Grid.Column="2" Content="Keep"         Width="130" Padding="0,10" FontSize="14"
                FontWeight="Bold" Background="#2E7D32" Foreground="White" Margin="0,0,8,0"/>
        <Button Name="rwDelete" Grid.Column="3" Content="Delete"       Width="130" Padding="0,10" FontSize="14"
                FontWeight="Bold" Background="#C62828" Foreground="White" Margin="8,0,0,0"/>
        <Button Name="rwNext"   Grid.Column="5" Content="Next &gt;"    Width="90"  Padding="0,10" FontSize="13"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

    $rwReader = [System.Xml.XmlNodeReader]::new($rwXAML)
    $rwWin    = [Windows.Markup.XamlReader]::Load($rwReader)
    $rwWin.Owner = $win

    $rwFileName  = $rwWin.FindName('rwFileName')
    $rwFilePath  = $rwWin.FindName('rwFilePath')
    $rwBadge     = $rwWin.FindName('rwBadge')
    $rwBadgeText = $rwWin.FindName('rwBadgeText')
    $rwSize      = $rwWin.FindName('rwSize')
    $rwAge       = $rwWin.FindName('rwAge')
    $rwReason    = $rwWin.FindName('rwReason')
    $rwCounter   = $rwWin.FindName('rwCounter')
    $rwFolder    = $rwWin.FindName('rwFolder')
    $rwSiblings  = $rwWin.FindName('rwSiblings')
    $rwDots      = $rwWin.FindName('rwDots')
    $rwPrev      = $rwWin.FindName('rwPrev')
    $rwNext      = $rwWin.FindName('rwNext')
    $rwKeep      = $rwWin.FindName('rwKeep')
    $rwDelete    = $rwWin.FindName('rwDelete')

    # Use $script: vars for mutable state closures in PS don't capture [ref] reliably
    $script:rwItems = $script:swipeItems
    $script:rwIdx   = 0

    $brushConv = [System.Windows.Media.BrushConverter]::new()

    # Progress dots
    function rw_RebuildDots {
        $rwDots.Items.Clear()
        for ($d = 0; $d -lt $script:rwItems.Count; $d++) {
            $p   = $script:rwItems[$d].FullName
            $dec = if ($script:swipeDecisions.ContainsKey($p)) { $script:swipeDecisions[$p] } else { '' }
            $col = switch ($dec) { 'delete'{'#C62828'} 'keep'{'#2E7D32'} default{'#BBBBBB'} }
            $isCur = ($d -eq $script:rwIdx)

            $dot = [System.Windows.Shapes.Ellipse]::new()
            if ($isCur) {
                $dot.Width  = 12; $dot.Height = 12
                $dot.Margin = [System.Windows.Thickness]::new(2,1,2,0)
                $dot.Stroke = $brushConv.ConvertFromString('#333333')
                $dot.StrokeThickness = 1.5
            } else {
                $dot.Width  = 8; $dot.Height = 8
                $dot.Margin = [System.Windows.Thickness]::new(2,3,2,0)
            }
            $dot.Fill = $brushConv.ConvertFromString($col)
            [void]$rwDots.Items.Add($dot)
        }
    }

    # Render card
    function rw_ShowCard {
        $i      = $script:rwIdx
        $f      = $script:rwItems[$i]
        $path   = $f.FullName
        $dir    = [System.IO.Path]::GetDirectoryName($path)
        $mb     = [math]::Round($f.Length / 1MB, 1)
        $age    = [math]::Round(((Get-Date) - $f.LastWriteTime).TotalDays)
        $reason = if ($f.Reason) { $f.Reason } else { 'Large file' }
        $dec    = if ($script:swipeDecisions.ContainsKey($path)) { $script:swipeDecisions[$path] } else { '' }

        $rwFileName.Text = $f.Name
        $rwFilePath.Text = $dir
        $rwFolder.Text   = $dir
        $rwSize.Text     = "$mb MB"
        $rwAge.Text      = "${age} days old"
        $rwReason.Text   = $reason
        $rwCounter.Text  = "File $($i + 1) of $($script:rwItems.Count)"

        switch ($dec) {
            'delete' {
                $rwBadge.Background     = $brushConv.ConvertFromString('#FFEBEE')
                $rwBadgeText.Foreground = $brushConv.ConvertFromString('#C62828')
                $rwBadgeText.Text = '[DELETE]'
            }
            'keep' {
                $rwBadge.Background     = $brushConv.ConvertFromString('#E8F5E9')
                $rwBadgeText.Foreground = $brushConv.ConvertFromString('#2E7D32')
                $rwBadgeText.Text = '[KEEP]'
            }
            default {
                $rwBadge.Background     = $brushConv.ConvertFromString('#EEEEEE')
                $rwBadgeText.Foreground = $brushConv.ConvertFromString('#888888')
                $rwBadgeText.Text = 'Undecided'
            }
        }

        # Folder siblings
        $rwSiblings.Items.Clear()
        try {
            $siblings = @(Get-ChildItem $dir -File -Force -ErrorAction SilentlyContinue | Sort-Object Name)
            foreach ($s in $siblings) {
                $smb   = [math]::Round($s.Length / 1MB, 2)
                $isMe  = ($s.FullName -eq $path)

                $tb = [System.Windows.Controls.TextBlock]::new()
                $tb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
                $tb.FontSize   = 11
                $tb.Padding    = [System.Windows.Thickness]::new(6,3,6,3)

                if ($isMe) {
                    $tb.Text       = ">> $($s.Name)   ($smb MB)"
                    $tb.Background = $brushConv.ConvertFromString('#FFF3E0')
                    $tb.Foreground = $brushConv.ConvertFromString('#E65100')
                    # Set bold via FontWeight property correctly
                    $tb.SetValue(
                        [System.Windows.Controls.TextBlock]::FontWeightProperty,
                        [System.Windows.FontWeights]::Bold
                    )
                } else {
                    $tb.Text       = "   $($s.Name)   ($smb MB)"
                    $tb.Foreground = $brushConv.ConvertFromString('#333333')
                }

                $li = [System.Windows.Controls.ListBoxItem]::new()
                $li.Content = $tb
                if ($isMe) {
                    $li.Background = $brushConv.ConvertFromString('#FFF3E0')
                    [void]$rwSiblings.Items.Add($li)
                    $rwSiblings.ScrollIntoView($li)
                } else {
                    [void]$rwSiblings.Items.Add($li)
                }
            }
            if ($rwSiblings.Items.Count -eq 0) { [void]$rwSiblings.Items.Add('(folder is empty or inaccessible)') }
        } catch {
            [void]$rwSiblings.Items.Add("(could not read folder)")
        }

        rw_RebuildDots
    }

    # Navigation and decision helpers
    function rw_MarkAndStay ([string]$dec) {
        $path = $script:rwItems[$script:rwIdx].FullName
        $script:swipeDecisions[$path] = $dec
        Save-Decisions
        # Auto-advance to next file
        if ($script:rwIdx -lt ($script:rwItems.Count - 1)) {
            $script:rwIdx++
            rw_ShowCard
        } else {
            rw_ShowCard   # refresh badge on last card
        }
    }
    function rw_GoNext {
        if ($script:rwIdx -lt ($script:rwItems.Count - 1)) { $script:rwIdx++; rw_ShowCard }
    }
    function rw_GoPrev {
        if ($script:rwIdx -gt 0) { $script:rwIdx--; rw_ShowCard }
    }

    # Button and keyboard handlers
    $rwKeep.Add_Click({   rw_MarkAndStay 'keep'   })
    $rwDelete.Add_Click({ rw_MarkAndStay 'delete' })
    $rwNext.Add_Click({   rw_GoNext })
    $rwPrev.Add_Click({   rw_GoPrev })

    $rwWin.Add_KeyDown({
        param($s, $e)
        switch ($e.Key) {
            'Right' { rw_GoNext }
            'Left'  { rw_GoPrev }
            'K'     { rw_MarkAndStay 'keep'   }
            'D'     { rw_MarkAndStay 'delete' }
        }
    })

    # On close: commit deletions
    $rwWin.Add_Closing({
        $toDelete = @($script:swipeDecisions.GetEnumerator() |
                      Where-Object { $_.Value -eq 'delete' } |
                      ForEach-Object { $_.Key })

        if ($toDelete.Count -eq 0) {
            Log 'Reviewer closed. No files marked for deletion.'
            return
        }

        $totalBytes = 0
        foreach ($p in $toDelete) {
            try { $totalBytes += (Get-Item $p -ErrorAction SilentlyContinue).Length } catch {}
        }
        $totalMB = [math]::Round($totalBytes / 1MB, 1)

        $ans = [System.Windows.MessageBox]::Show(
            "You marked $($toDelete.Count) file(s) for deletion ($totalMB MB total).`n`nDelete them now?`n`nThis cannot be undone.",
            'Confirm Deletions', 'YesNoCancel', 'Warning')

        if ($ans -eq 'Yes') {
            foreach ($p in $toDelete) {
                if (Test-Path $p) {
                    try {
                        $sz = (Get-Item $p -ErrorAction SilentlyContinue).Length
                        Remove-Item $p -Force -ErrorAction Stop
                        AddFreed -bytes $sz -files 1
                        LogOK "Deleted: $p  ($([math]::Round($sz/1MB,2)) MB)"
                    } catch { LogErr "Could not delete: $p" }
                }
            }
            $script:swipeDecisions = @{}
            try { Remove-Item $script:sessionFile -Force -ErrorAction SilentlyContinue } catch {}
            $lstDeep.Items.Clear()
            foreach ($f in $script:swipeItems) {
                if (Test-Path $f.FullName) {
                    $mb  = [math]::Round($f.Length / 1MB, 1)
                    $age = [math]::Round(((Get-Date) - $f.LastWriteTime).TotalDays)
                    $tag = if ($f.Reason) { $f.Reason } else { 'Large file' }
                    [void]$lstDeep.Items.Add("[$mb MB | ${age}d | $tag]  $($f.FullName)")
                }
            }
            Log 'Review complete. Deletions committed.'
        } elseif ($ans -eq 'No') {
            Log "Reviewer closed. $($toDelete.Count) file(s) kept decisions saved for next time."
        }
    })

    rw_ShowCard
    [void]$rwWin.ShowDialog()
}

$btnSwipeMode.Add_Click({
    if ($script:swipeItems.Count -eq 0) { return }
    Open-FileReviewer
})

$btnNukeContinue.Add_Click({
    $script:deepScanDone         = $true
    $btnNukeContinue.Visibility  = 'Collapsed'
    Log 'Review complete continuing Full Nuke with Speed Boost...'
    DoEvents
})

$btnRun.Add_Click({
    if (-not $script:mode) { return }

    $btnRun.IsEnabled     = $false
    $script:freed         = 0
    $script:fileCount     = 0
    $txtLog.Text          = ''
    $txtFreed.Text        = '0 MB'
    $txtFiles.Text        = '0 files removed'
    $pb.Value             = 0
    $pnlDeep.Visibility   = 'Collapsed'
    $btnDelete.Visibility = 'Collapsed'
    DoEvents

    try {
        switch ($script:mode) {
            'Standard' { Run-Standard }
            'Deep'     { Run-DeepScan $false }
            'Apps'     { Run-AppReviewer }
            'Speed'    { Run-Speed }
            'All'      {
                Run-Standard
                Run-DeepScan

                $script:deepScanDone        = $true
                $btnNukeContinue.Visibility = 'Collapsed'
                Log 'Review complete continuing Full Nuke with App Reviewer...'
                DoEvents

                Run-AppReviewer
                Run-Speed
                LogHead 'FULL NUKE COMPLETE'
            }
        }
    } catch {
        LogErr "Unexpected error: $_"
    }

    $btnRun.IsEnabled = $true
    $txtTask.Text = 'Done! Ready for another run.'
    DoEvents
})

$btnDelete.Add_Click({
    $sel = @($lstDeep.SelectedItems)
    if ($sel.Count -eq 0) {
        [System.Windows.MessageBox]::Show(
            'No files selected. Click items in the list to select them (Ctrl+Click for multiple).',
            'Nothing Selected','OK','Information')
        return
    }
    $ans = [System.Windows.MessageBox]::Show(
        "Permanently delete $($sel.Count) file(s)?`n`nThis cannot be undone.",
        'Confirm Delete','YesNo','Warning')
    if ($ans -ne 'Yes') { return }

    $toRemove = @()
    foreach ($item in $sel) {
        if ($item -match '\]\s+(.+)$') {
            $path = $Matches[1].Trim()
            if (Test-Path $path) {
                try {
                    $sz = (Get-Item $path -ErrorAction SilentlyContinue).Length
                    Remove-Item $path -Force -ErrorAction Stop
                    AddFreed -bytes $sz -files 1
                    LogOK "Deleted: $path  ($([math]::Round($sz/1MB,2)) MB)"
                    $toRemove += $item
                } catch { LogErr "Could not delete: $path" }
            } else {
                $toRemove += $item
            }
        }
    }
    foreach ($i in $toRemove) { [void]$lstDeep.Items.Remove($i) }
})

$btnClear.Add_Click({
    $txtLog.Text  = ''
    $pb.Value     = 0
    $txtTask.Text = 'Log cleared.'
    DoEvents
})

$btnExit.Add_Click({ $win.Close() })

# Startup checks
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $pnlAdminWarn.Visibility = 'Visible'
}

Log "PC Deep Cleaner v3.2 ready."
Log "Running as Administrator: $isAdmin"
Log "OS: $([System.Environment]::OSVersion.VersionString)"
Log ''
Log "Click a mode button above, then click Run Selected Mode."

[void]$win.ShowDialog()
