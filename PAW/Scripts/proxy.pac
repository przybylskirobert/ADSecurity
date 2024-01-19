function FindProxyForURL(url, host) {
 
if (shExpMatch(host, "*.aspnetcdn.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.aadrm.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.appex.bing.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.appex-rf.msn.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.assets-yammer.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.azure.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.azurecomcdn.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.cloudappsecurity.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.c.bing.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.gfx.ms")) { return "DIRECT"; }
if (shExpMatch(host, "*.live.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.live.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.lync.com")) { return "DIRECT"; }
if (shExpMatch(host, "maodatafeedsservice.cloudapp.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoft.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoftonline.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoftonline-p.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoftonline-p.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoftonlineimages.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.microsoftonlinesupport.net")) { return "DIRECT"; }
if (shExpMatch(host, "ms.tific.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.msecnd.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.msedge.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.msft.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.msocdn.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.onenote.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.outlook.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.office365.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.office.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.office.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.onmicrosoft.com")) { return "DIRECT"; }
if (shExpMatch(host, "partnerservices.getmicrosoftkey.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.passport.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.phonefactor.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.s-microsoft.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.s-msn.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.sharepoint.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.sharepointonline.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.s-msn.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.symcb.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.yammer.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.yammerusercontent.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.verisign.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.windows.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.windows.net")) { return "DIRECT"; }
if (shExpMatch(host, "*.windowsazure.com")) { return "DIRECT"; }
if (shExpMatch(host, "*.windowsupdate.com")) { return "DIRECT"; }
 
return "PROXY 127.0.0.2:8080";
}