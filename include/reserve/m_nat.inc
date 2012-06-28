{$IFNDEF M_NAT}
{$DEFINE M_NAT}

type
  NETLIBIPINFO = record
	  cbSize:integer;
	  szIP  :PAnsiChar;   // IP the server returned, it maybe in any form, but assume IP4
	  szSite:PAnsiChar;   // where I got the IP from
  end;

const
{
  wParam=0
  lParam=(LPARAM)&NETLIBIPINFO

  Hook is fired when the IP is fetched from the server, it maybe still the old IP and I have
  no way of knowing you have the old IP or the newer one (or if it is new) so just check
  with the current and update if you need to.
}
  ME_NETLIB_EXTERNAL_IP_FETCHED = 'Miranda/Netlib/IpFetched';

{
  wParam=0
  lParam=0

  Forces the IP check, this will create a new thread to query the HTTP server and
  so you may get a few more updates (no more than 2 in a row though)
}
  MS_NETLIB_EXTERNAL_IP_FORCECHECK = 'Miranda/Netlib/ForceCheck';
{$ENDIF}
