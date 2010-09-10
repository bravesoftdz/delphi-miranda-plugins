{
Miranda IM: the free IM client for Microsoft* Windows*

Copyright 2000-2009 Miranda ICQ/IM project,
all portions of this codebase are copyrighted to the people
listed in contributors.txt.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

$Id: m_timezones.h 86 2010-04-25 04:08:45Z silvercircle $

implements time zone services for Miranda IM
}

{$IFNDEF M_TIMEZONES}
{$DEFINE M_TIMEZONES}

const
  MIM_TZ_NAMELEN    = 64;
  MIM_TZ_DISPLAYLEN = 128;

{
  the time zone information structure. One per TZ
  most values are READ ONLY, do not touch them
}

type
  TMIM_TIMEZONE = record
    cbSize      :dword;       // caller must supply this
    tszName     :array [0..MIM_TZ_NAMELEN   -1] of AnsiChar; // windows name for the time zone
    tszDisplay  :array [0..MIM_TZ_DISPLAYLEN-1] of AnsiChar; // more descriptive display name
                                                             // (what usually appears in dialogs)
    Bias        :longword;    // Standardbias (gmt offset)
    DaylightBias:longword;    // daylight Bias (dst offset, relative to standard bias, -60 for most time zones)
    StandardTime:TSYSTEMTIME; // when DST ends (month/dayofweek/time)
    DaylightTime:TSYSTEMTIME; // when DST begins (month/dayofweek/time)
    GMT_Offset  :AnsiChar;    // simple GMT offset (+/-, measured in half-hours, may be incorrect for DST timezones)
    Offset      :longword;    // time offset to local time, in seconds. It is relativ to the
                              // current local time, NOT GMT. The sign is inverted, so you have
                              // to subtract it from the current time.
    CurrentTime :TSYSTEMTIME; // current system time. only updated when forced by the caller
    now         :time_t;      // same in unix time format (seconds since 1970).
  end;
  TMIM_TIMEZONEW = record
    cbSize      :dword;       // caller must supply this
    tszName     :array [0..MIM_TZ_NAMELEN   -1] of WideChar; // windows name for the time zone
    tszDisplay  :array [0..MIM_TZ_DISPLAYLEN-1] of WideChar; // more descriptive display name
                                                             // (what usually appears in dialogs)
    Bias        :longword;    // Standardbias (gmt offset)
    DaylightBias:longword;    // daylight Bias (dst offset, relative to standard bias, -60 for most time zones)
    StandardTime:TSYSTEMTIME; // when DST ends (month/dayofweek/time)
    DaylightTime:TSYSTEMTIME; // when DST begins (month/dayofweek/time)
    GMT_Offset  :AnsiChar;    // simple GMT offset (+/-, measured in half-hours, may be incorrect for DST timezones)
    Offset      :longword;    // time offset to local time, in seconds. It is relativ to the
                              // current local time, NOT GMT. The sign is inverted, so you have
                              // to subtract it from the current time.
    CurrentTime :TSYSTEMTIME; // current system time. only updated when forced by the caller
    now         :time_t;      // same in unix time format (seconds since 1970).
  end;
  tagTimeZone = TMIM_TIMEZONE;

const
  MIM_TZ_PLF_CB = 1; // UI element is assumed to be a combo box
  MIM_TZ_PLF_LB = 2; // UI element is assumed to be a list box

type
  TMIM_TZ_PREPARELIST = record
    cbSize:dword;     // caller must supply this
    hWnd:HWND;        // window handle of the combo or list box
    tszName:array [0..MIM_TZ_NAMELEN-1] of AnsiChar; // tz name (for preselecting)
    dwFlags:dword;    // flags - if neither PLF_CB or PLF_LB is set, the window class name will
                      // be used to figure out the type of control.
    hContact:THANDLE; // contact handle (for preselecting)
                      // the contact handle has precendence over tszName[].
                      // data will be read from the database (if present). Otherwise, the
                      // <unspecified> entry will be preselected.
  end;
  tagPrepareList = TMIM_TZ_PREPARELIST;
  TMIM_TZ_PREPARELISTW = record
    cbSize:dword;     // caller must supply this
    hWnd:HWND;        // window handle of the combo or list box
    tszName:array [0..MIM_TZ_NAMELEN-1] of WideChar; // tz name (for preselecting)
    dwFlags:dword;    // flags - if neither PLF_CB or PLF_LB is set, the window class name will
                      // be used to figure out the type of control.
    hContact:THANDLE; // contact handle (for preselecting)
                      // the contact handle has precendence over tszName[].
                      // data will be read from the database (if present). Otherwise, the
                      // <unspecified> entry will be preselected.
  end;

{
 services
}
const
 	MIM_PLF_FORCE = 4; // update MIM_TIMEZONE.CurrentTime
                     // if not set, only the offsets are kept current

{
  Obtain time zone information by time zone name
  wParam = (TCHAR *)tszName
  lParam =  dwFlags
 
  returns pointer to MIM_TIMEZONE if everything ok, 0 otherwise.
}
  MS_TZ_GETINFOBYNAME:PAnsiChar = 'TZ/GetInfoByName';

{
  Obtain time zone information by contact handle
  wParam = (HANDLE)hContact
  lParam =  dwFlags
 
  returns MIM_TIMEZONE if everything ok, 0 otherwise.
}
  MS_TZ_GETINFOBYCONTACT:PAnsiChar = 'TZ/GetInfoByContact';

{
  this service fills a combo or list box with time zone information
  optionally, it can preselect a value based on the tszName[] and hContact members.
  the name member has precendence over the contact handle. If neither one is present,
  no preselection will be performed.
 
  wParam = 0 (not used)
  lParam = MIM_TZ_PREPARELIST *
 
  returns: 0 on failure, != otherwise
 
  How to obtain the entry selected by the user?
 
  1) send CB_GETCURSEL / LB_GETCURSEL to the list/combo box to obtain the selection
  2) use CB_GETITEMDATA / LB_GETITEMDATA with the selection to get a pointer to a
  	  MIM_TIMEZONE structure.  This pointer CAN be NULL (when the user did not
  	  select a valid time zone, so check it.)
 
  	  DO NOT modify the data inside the struct. It's supposed to be read-only.
}
  MS_TZ_PREPARELIST:PAnsiChar = 'TZ/PrepareList';

{$ENDIF}
