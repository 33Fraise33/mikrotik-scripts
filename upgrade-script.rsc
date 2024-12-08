## based on https://github.com/massimo-filippi/mikrotik
:log info ("Running upgrade check")

########## Upgrade Routerboard

:local rebootReq false
:local curFirmware "$[/system/routerboard/get current-firmware]";
:local upgFirmware "$[/system/routerboard/get upgrade-firmware]";
:if ($curFirmware != $upgFirmware) do={

    :global notifyMessage "Upgrading routerboard on $[/system/identity/get name] from $curFirmware to $upgFirmware";
    :log info ("$notifyMessage")
    /system script run "externalNotify";
   
    /system/routerboard/upgrade
    :set rebootReq true
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

    :global notifyMessage "Upgrading RouterOS on $[/system/identity/get name] from $curSoftware to $upgSoftware";
    :log info ("$notifyMessage")
    /system script run "externalNotify";
    ## Wait for notification to be sent
    :delay 15s;

    /system/package/update/install

} else={
    :if ($rebootReq) do={
        /system reboot
    } else={
        :log info ("No routerboard or RouterOS upgrade found.")
    }
}
