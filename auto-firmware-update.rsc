# -------------------------------------------------------------------------
# SCRIPT: Automated Firmware Downloader
# DESCRIPTION: Checks for new RouterOS stable versions and downloads packages
#              for multiple architectures automatically.
# -------------------------------------------------------------------------

:local firmwaresDir "data/firmwares";
:local logTag "firmware-downloader";
:local baseRouterOSVersion "7.16";

:log info "[$logTag] Starting firmware download sequence.";

# Check/Create Directory
:if ([:len [/file find name=$firmwaresDir]] = 0) do={
    /file add type=directory name=$firmwaresDir;
    :log info "[$logTag] Directory '$firmwaresDir' created.";
}

# Check Updates
/system package update set channel="stable";
/system package update check-for-updates once;
:delay 5s;

:local detectedLatestStableVersion [/system package update get latest-version];

# Version Logic
:if ([:len $detectedLatestStableVersion] > 0) do={
    :if ($detectedLatestStableVersion != $baseRouterOSVersion) do={
        :log info "[$logTag] New stable version detected ($detectedLatestStableVersion). Updating target.";
        :set baseRouterOSVersion $detectedLatestStableVersion;
    } else={
        :log info "[$logTag] Local version is up to date ($detectedLatestStableVersion).";
    }
}

# Download Loop for Architectures (ARM, MIPS, x86, TILE)
:local firmwaresToDownload ({});
:set firmwaresToDownload ($firmwaresToDownload, ("arm64:" . $baseRouterOSVersion));
:set firmwaresToDownload ($firmwaresToDownload, ("arm:" . $baseRouterOSVersion));
:set firmwaresToDownload ($firmwaresToDownload, ("mipsbe:" . $baseRouterOSVersion));
:set firmwaresToDownload ($firmwaresToDownload, ("x86:" . $baseRouterOSVersion));
:set firmwaresToDownload ($firmwaresToDownload, ("tile:" . $baseRouterOSVersion));

:foreach firmwareEntry in=$firmwaresToDownload do={
    :local arch [:pick $firmwareEntry 0 [:find $firmwareEntry ":"]];
    :local version [:pick $firmwareEntry ([:find $firmwareEntry ":"] + 1) [:len $firmwareEntry]];
    :local fileName "routeros-$version-$arch.npk";
    
    :if ($arch = "x86") do={ :set fileName "routeros-$version.npk"; }

    :local downloadUrl "https://download.mikrotik.com/routeros/$version/$fileName";
    :local filePath "$firmwaresDir/$fileName";

    :log info "[$logTag] Downloading: $fileName from $downloadUrl";
    
    # Fetch Tool
    /tool fetch url=$downloadUrl dst-path=$filePath;
}

:log info "[$logTag] Download sequence finished.";
