(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

unit hpp_opt_dialog;

interface

uses
  Windows;

function OnOptInit(awParam: WPARAM; alParam: LPARAM): Integer; cdecl;

implementation

uses
  Messages, CommCtrl,
  common, wrapper,
  m_api,dbsettings,
  hpp_global,
  my_GridOptions
//  hpp_services,
//  hpp_database,
//  hpp_external,
//  HistoryForm, GlobalSearch
  ;

{$include resource.inc}
{$R 'hpp_opt_dialog.res' 'hpp_opt_dialog.rc'}

procedure SetChecked(hDlg:HWND; idCtrl: Integer; Checked: Boolean);
begin
  if Checked then
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_CHECKED,0)
  else
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_UNCHECKED,0);
end;

function GetChecked(hDlg: HWND; idCtrl: Integer): Boolean;
begin
  Result := (SendDlgItemMessage(hDlg,idCtrl,BM_GETCHECK,0,0) = BST_CHECKED);
end;

procedure SaveChangedOptions(hDlg:HWND);
var
  Checked: Boolean;
//  i: Integer;
begin
  GridOptions.StartChange;
//  try
    GridOptions.ShowIcons       := GetChecked(hDlg,IDC_SHOWEVENTICONS);
    GridOptions.RTLEnabled      := GetChecked(hDlg,IDC_RTLDEFAULT);
    GridOptions.OpenDetailsMode := GetChecked(hDlg,IDC_OPENDETAILS);

    ShowHistoryCount := GetChecked(hDlg,IDC_SHOWEVENTSCOUNT);
    DBWriteByte(0,hppDBName,'ShowHistoryCount',Ord(ShowHistoryCount));

    //GridOptions.ShowAvatars := GetChecked(IDC_SHOWAVATARS);

    GridOptions.BBCodesEnabled        := GetChecked(hDlg,IDC_BBCODE);
    GridOptions.RawRTFEnabled         := GetChecked(hDlg,IDC_RAWRTF);
    GridOptions.AvatarsHistoryEnabled := GetChecked(hDlg,IDC_AVATARSHISTORY);

    if ServiceExists(MS_SMILEYADD_REPLACESMILEYS)<>0 then
      GridOptions.SmileysEnabled := GetChecked(hDlg,IDC_SMILEY);

    GridOptions.SaveOptions;
//  finally
    GridOptions.EndChange;
//  end;

  Checked := GetChecked(hDlg,IDC_RECENTONTOP);
  if Checked <> (DBReadByte(0,hppDBName,'SortOrder',0)<>0) then
  begin
    DBWriteByte(0,hppDBName,'SortOrder',Ord(Checked));
{
    for i := 0 to HstWindowList.Count - 1 do
    begin
      THistoryFrm(HstWindowList[i]).SetRecentEventsPosition(Checked);
    end;
    if Assigned(fmGlobalSearch) then
      fmGlobalSearch.SetRecentEventsPosition(Checked);
}
  end;

  Checked := GetChecked(hDlg,IDC_GROUPHISTITEMS);
  if Checked <> (DBReadByte(0,hppDBName,'GroupHistoryItems',0)<>0) then
  begin
    DBWriteByte(0,hppDBName,'GroupHistoryItems',Ord(Checked));
{
    for i := 0 to HstWindowList.Count - 1 do
      THistoryFrm(HstWindowList[i]).hg.GroupLinked := Checked;
}
  end;

  DBWriteByte(0,hppDBName,'IEViewAPI',Ord(GetChecked(hDlg,IDC_IEVIEWAPI)));

  Checked := GetChecked(hDlg,IDC_GROUPLOGITEMS);
  DBWriteByte(0,hppDBName,'GroupLogItems',Ord(Checked));
//!!  ExternalGrids.GroupLinked := Checked;

  DBWriteByte(0,hppDBName,'NoLogBorder'   ,Ord(GetChecked(hDlg,IDC_DISABLEBORDER)));
  DBWriteByte(0,hppDBName,'NoLogScrollBar',Ord(GetChecked(hDlg,IDC_DISABLESCROLL)));

  DBWriteByte(0,hppDBName,'CheckIconPack',Ord(GetChecked(hDlg,IDC_ICONPACK)));

end;

function OptDialogProc(hwndDlg: HWND; uMsg: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
var
  SmileyAddExists:boolean;
begin
  Result := 0;
  case uMsg of
    WM_INITDIALOG: begin
      SetChecked(hwndDlg,IDC_SHOWEVENTICONS,GridOptions.ShowIcons);
      SetChecked(hwndDlg,IDC_RTLDEFAULT,GridOptions.RTLEnabled);
      SetChecked(hwndDlg,IDC_OPENDETAILS,GridOptions.OpenDetailsMode);
      SetChecked(hwndDlg,IDC_SHOWEVENTSCOUNT,ShowHistoryCount);
      //SetChecked(hwndDlg,IDC_SHOWAVATARS,GridOptions.ShowAvatars);

      SetChecked(hwndDlg,IDC_BBCODE,GridOptions.BBCodesEnabled);

      SmileyAddExists := ServiceExists(MS_SMILEYADD_REPLACESMILEYS)<>0;
      EnableWindow(GetDlgItem(hwndDlg,IDC_SMILEY),SmileyAddExists);
      if SmileyAddExists then
        SetChecked(hwndDlg,IDC_SMILEY,GridOptions.SmileysEnabled);

      SetChecked(hwndDlg,IDC_RAWRTF,GridOptions.RawRTFEnabled);
      SetChecked(hwndDlg,IDC_AVATARSHISTORY,GridOptions.AvatarsHistoryEnabled);

      SetChecked(hwndDlg,IDC_RECENTONTOP   ,DBReadByte(0,hppDBName,'SortOrder',0)<>0);
      SetChecked(hwndDlg,IDC_GROUPHISTITEMS,DBReadByte(0,hppDBName,'GroupHistoryItems',0)<>0);

      SetChecked(hwndDlg,IDC_IEVIEWAPI    ,DBReadByte(0,hppDBName,'IEViewAPI',0)<>0);
      SetChecked(hwndDlg,IDC_GROUPLOGITEMS,DBReadByte(0,hppDBName,'GroupLogItems',0)<>0);
      SetChecked(hwndDlg,IDC_DISABLEBORDER,DBReadByte(0,hppDBName,'NoLogBorder',0)<>0);
      SetChecked(hwndDlg,IDC_DISABLESCROLL,DBReadByte(0,hppDBName,'NoLogScrollBar',0)<>0);

      SetChecked(hwndDlg,IDC_ICONPACK,DBReadByte(0,hppDBName,'CheckIconPack',1)<>0);

      TranslateDialogDefault(hwndDlg);
    end;

    WM_NOTIFY: begin
      if integer(PNMHDR(lParam)^.code) = PSN_APPLY then
      begin
        Result := 1;
        // apply changes here
        SaveChangedOptions(hwndDlg);
      end;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        BN_CLICKED: SendMessage(GetParent(hwndDlg),PSM_CHANGED,hwndDlg,0);
      end;
    end;

  end;
end;

function OptDialogProc2(hwndDlg: HWND; uMsg: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
const
  inited:boolean=false;
begin
  Result := 0;
  case uMsg of
    WM_INITDIALOG: begin
      inited:=false;
      TranslateDialogDefault(hwndDlg);

      SetDlgItemTextW(hwndDlg,IDC_TMPL_COPY      ,PWideChar(GridOptions.ClipCopyFormat));
      SetDlgItemTextW(hwndDlg,IDC_TMPL_COPYTEXT  ,PWideChar(GridOptions.ClipCopyTextFormat));
      SetDlgItemTextW(hwndDlg,IDC_TMPL_QUOTED    ,PWideChar(GridOptions.ReplyQuotedFormat));
      SetDlgItemTextW(hwndDlg,IDC_TMPL_QUOTEDTEXT,PWideChar(GridOptions.ReplyQuotedTextFormat));
      SetDlgItemTextW(hwndDlg,IDC_TMPL_SELECTION ,PWideChar(GridOptions.SelectionFormat));

      SetDlgItemTextW(hwndDlg,IDC_TMPL_DATETIME  ,PWideChar(GridOptions.DateTimeFormat));
    
      inited:=true;
    end;

    WM_COMMAND: begin
      if not inited then exit;
      case wParam shr 16 of
        EN_CHANGE: SendMessage(GetParent(hwndDlg),PSM_CHANGED,hwndDlg,0);
        BN_CLICKED: begin
          case loword(wParam) of
            IDC_TMPL_HELP: begin
{
Formatting variables
\n -- new line 
\t -- tab 
\\ -- backslash (if you need to output backslash, instead of "Me\You" write "Me\\You") 
\% -- percent sign (if you need to output percent sign, instead of "Me%You" write "Me\%You") 
%nick% -- default contact's nickname text 
%from_nick% -- nick of the sender 
%to_nick% -- nick of the reciever 
%mes% -- plain message text 
%adj_mes% -- message adjusted to fit in 72 symbols 
%quot_mes% -- the same as %adj_mes%, but every line is prefixed with "> " 
%selmes% -- the same as %mes% or selected text in pseudo-edit mode 
%adj_selmes% -- the same as %adj_mes% or applied to selected text in pseudo-edit mode 
%quot_selmes% -- the same as %quot_mes% or applied to selected text in pseudo-edit mode 
%datetime% -- date and time of the event 
%smart_datetime% -- works for only for several messages. Outputs full date & time only for messages with unique date. For other events outputs only time. 
%date% -- date of the event 
%time% -- time of the event
}
            end;
            IDC_DATE_HELP: begin
{
http://msdn.microsoft.com/en-us/library/windows/desktop/dd317787(v=vs.85).aspx
The following table defines the format types used to represent days.Format type	Meaning
d	Day of the month as digits without leading zeros for single-digit days.
dd	Day of the month as digits with leading zeros for single-digit days.
ddd	Abbreviated day of the week as specified by a LOCALE_SABBREVDAYNAME* value, for example, "Mon" in English (United States).

Windows Vista and later: If a short version of the day of the week is required, your application should use the LOCALE_SSHORTESTDAYNAME* constants.
dddd	Day of the week as specified by a LOCALE_SDAYNAME* value.


 

The following table defines the format types used to represent months.Format type	Meaning
M	Month as digits without leading zeros for single-digit months.
MM	Month as digits with leading zeros for single-digit months.
MMM	Abbreviated month as specified by a LOCALE_SABBREVMONTHNAME* value, for example, "Nov" in English (United States).
MMMM	Month as specified by a LOCALE_SMONTHNAME* value, for example, "November" for English (United States), and "Noviembre" for Spanish (Spain).


 

The following table defines the format types used to represent years.Format type	Meaning
y	Year represented only by the last digit.
yy	Year represented only by the last two digits. A leading zero is added for single-digit years.
yyyy	Year represented by a full four or five digits, depending on the calendar used. Thai Buddhist and Korean calendars have five-digit years. The "yyyy" pattern shows five digits for these two calendars, and four digits for all other supported calendars. Calendars that have single-digit or two-digit years, such as for the Japanese Emperor era, are represented differently. A single-digit year is represented with a leading zero, for example, "03". A two-digit year is represented with two digits, for example, "13". No additional leading zeros are displayed.
yyyyy	Behaves identically to "yyyy".


 
http://msdn.microsoft.com/en-us/library/windows/desktop/dd318131(v=vs.85).aspx
The following table defines the format types used to represent a period or era.Format type	Meaning
g, gg	Period/era string formatted as specified by the CAL_SERASTRING value. The "g" and "gg" format pictures in a date string are ignored if there is no associated era or period string.
Picture	Meaning
h	Hours with no leading zero for single-digit hours; 12-hour clock
hh	Hours with leading zero for single-digit hours; 12-hour clock
H	Hours with no leading zero for single-digit hours; 24-hour clock
HH	Hours with leading zero for single-digit hours; 24-hour clock
m	Minutes with no leading zero for single-digit minutes
mm	Minutes with leading zero for single-digit minutes
s	Seconds with no leading zero for single-digit seconds
ss	Seconds with leading zero for single-digit seconds
t	One character time marker string, such as A or P
tt	Multi-character time marker string, such as AM or PM
}
            end;
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      if integer(PNMHDR(lParam)^.code) = PSN_APPLY then
      begin
        Result := 1;

        GridOptions.ClipCopyFormat       :=GetDlgText(hwndDlg,IDC_TMPL_COPY);
        GridOptions.ClipCopyTextFormat   :=GetDlgText(hwndDlg,IDC_TMPL_COPYTEXT);
        GridOptions.ReplyQuotedFormat    :=GetDlgText(hwndDlg,IDC_TMPL_QUOTED);
        GridOptions.ReplyquotedTextFormat:=GetDlgText(hwndDlg,IDC_TMPL_QUOTEDTEXT);
        GridOptions.SelectionFormat      :=GetDlgText(hwndDlg,IDC_TMPL_SELECTION);
        GridOptions.DateTimeFormat       :=GetDlgText(hwndDlg,IDC_TMPL_DATETIME);

        GridOptions.SaveTemplates;
      end;
    end;
  end;
end;

function OnOptInit(awParam: WPARAM; alParam: LPARAM): Integer; cdecl;
var
  odp: TOPTIONSDIALOGPAGE;
begin
  ZeroMemory(@odp,SizeOf(odp));
  odp.cbSize      := sizeof(odp);
  odp.flags       := ODPF_BOLDGROUPS;
  odp.Position    := 0;
  odp.hInstance   := hInstance;
  odp.szGroup.a   := nil;
  odp.szTitle.a   := 'History';
  odp.pszTemplate := MakeIntResourceA(IDD_OPT_HISTORYPP);
  odp.szTab.a     := 'History';
  odp.pfnDlgProc  := @OptDialogProc;
  Options_AddPage(awParam,@odp);

  odp.pszTemplate := MakeIntResourceA(IDD_OPT_HISTORYPP2);
  odp.szTab.a     := 'Templates';
  odp.pfnDlgProc  := @OptDialogProc2;
  Options_AddPage(awParam,@odp);
  Result:=0;
end;

end.
