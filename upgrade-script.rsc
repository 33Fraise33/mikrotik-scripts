## based on https://github.com/massimo-filippi/mikrotik
# wait for boot to finish, otherwise notify does not work
:delay 100s;
:log info ("Running upgrade check")

########## Upgrade Routerboard

:local curFirmware "$[/system/routerboard/get current-firmware]";
:local upgFirmware "$[/system/routerboard/get upgrade-firmware]";
:if ($curFirmware != $upgFirmware) do={

    :global notifyMessage "Upgrading routerboard on $[/system/identity/get name] from $curFirmware to $upgFirmware";
    :log info ("$notifyMessage")
    /system script run "externalNotify";
   
    /system/routerboard/upgrade
    :delay 15s;
    /system reboot
}

########## Upgrade RouterOS
/system/package/update/set channel=stable
/system/package/update/check-for-updates

## Wait on slow connections
:delay 15s;

:local curSoftware "$[/system/package/update/get installed-version]";
:local upgSoftware "$[/system/package/update/get latest-version]";

## Important note: "installed-version" was "current-version" on older Roter OSes
:if ($curSoftware != $upgSoftware) do={
    # search for releases who have 2 dots (7.x.x, not 7.x)
    :local firstDot [:find $upgSoftware "."];
    :local secondDot -1; # A value of -1 means "not found"

    # Only search for a second dot if a first one was found
    :if ($firstDot > -1) do={
        :set secondDot [:find $upgSoftware "." ($firstDot + 1)];
    }

    # If secondDot is > -1, it means we found two dots (x.y.z format)
    :if ($secondDot > -1) do={
        # This IS a point release, so PROCEED with the upgrade.
        :global notifyMessage "Upgrading RouterOS on $[/system/identity/get name] from $curSoftware to $upgSoftware";
        :log info ("$notifyMessage")
        /system script run "externalNotify";
        ## Wait for notification to be sent
        :delay 5s;

        /system/package/update/install
    } else={
        # This is NOT a point release (it's an x.y release), so SKIP it.
        :log info ("Skipping upgrade to $upgSoftware because it is not a point release (x.y.z).");
    }
} else={
    :log info ("No routerboard or RouterOS upgrade found.")
}
