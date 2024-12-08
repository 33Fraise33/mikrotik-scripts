## based on https://github.com/massimo-filippi/mikrotik

:global notifyMessage;

# CF-Access-Client-Id:
:local id ""
# CF-Access-Client-Secret:
:local secret ""
:local appriseUrl ""
:global urlEncode do={

  :local string $1;
  :local stringEncoded "";

  :for i from=0 to=([:len $string] - 1) do={
    :local char [:pick $string $i]
    :if ($char = " ")  do={ :set $char "%20" }
    :if ($char = "\"") do={ :set $char "%22" }
    :if ($char = "#")  do={ :set $char "%23" }
    :if ($char = "\$") do={ :set $char "%24" }
    :if ($char = "%")  do={ :set $char "%25" }
    :if ($char = "&")  do={ :set $char "%26" }
    :if ($char = "+")  do={ :set $char "%2B" }
    :if ($char = ",")  do={ :set $char "%2C" }
    :if ($char = "-")  do={ :set $char "%2D" }
    :if ($char = ":")  do={ :set $char "%3A" }
    :if ($char = "[")  do={ :set $char "%5B" }
    :if ($char = "]")  do={ :set $char "%5D" }
    :if ($char = "{")  do={ :set $char "%7B" }
    :if ($char = "}")  do={ :set $char "%7D" }
    :set stringEncoded ($stringEncoded . $char)
  }
  :return $stringEncoded;
}

:local message [$urlEncode $notifyMessage];

/tool fetch \
    http-method="post" \
    http-header-field="CF-Access-Client-Id:$id,CF-Access-Client-Secret:$secret" \
    http-data="tag=all&body=$message" \
    url="https://$appriseUrl/notify/mikrotik";
