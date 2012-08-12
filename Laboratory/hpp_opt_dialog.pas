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

var
  hDlg: HWND = 0;

implementation

uses
  Messages, CommCtrl,
  m_api,
  hpp_global,
  dbsettings,
  my_GridOptions,
  hpp_options
//  hpp_services,
//  hpp_database,
//  hpp_external,
//  HistoryForm, GlobalSearch
  ;

{$include resource.inc}
{$R 'hpp_opt_dialog.res' 'hpp_opt_dialog.rc'}

const
  URL_NEEDOPTIONS = 'http://code.google.com/p/historypp/wiki/AdditionalOptions';

procedure SetChecked(idCtrl: Integer; Checked: Boolean);
begin
  if Checked then
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_CHECKED,0)
  else
    SendDlgItemMessage(hDlg,idCtrl,BM_SETCHECK,BST_UNCHECKED,0);
end;

function GetChecked(idCtrl: Integer): Boolean;
begin
  Result := (SendDlgItemMessage(hDlg,idCtrl,BM_GETCHECK,0,0) = BST_CHECKED);
end;

function AreOptionsChanged: Boolean;
begin
  Result := True;

  if GetChecked(IDC_SHOWEVENTICONS) <> GridOptions.ShowIcons then exit;
  if GetChecked(IDC_RTLDEFAULT) <> GridOptions.RTLEnabled then exit;
  if GetChecked(IDC_OPENDETAILS) <> GridOptions.OpenDetailsMode then exit;
  if GetChecked(IDC_SHOWEVENTSCOUNT) <> ShowHistoryCount then exit;
  //if GetChecked(IDC_SHOWAVATARS) <> GridOptions.ShowAvatars then exit;

  if GetChecked(IDC_BBCODE) <> GridOptions.BBCodesEnabled then exit;
  if SmileyAddExists then
    if GetChecked(IDC_SMILEY) <> GridOptions.SmileysEnabled then exit;
  if MathModuleExists then
    if GetChecked(IDC_MATH) <> GridOptions.MathModuleEnabled then exit;
  if GetChecked(IDC_RAWRTF) <> GridOptions.RawRTFEnabled then exit;
  if GetChecked(IDC_AVATARSHISTORY) <> GridOptions.AvatarsHistoryEnabled then exit;

  if GetChecked(IDC_RECENTONTOP   ) <> (DBReadByte(0,hppDBName,'SortOrder',0)<>0) then exit;
  if GetChecked(IDC_GROUPHISTITEMS) <> (DBReadByte(0,hppDBName,'GroupHistoryItems',0)<>0) then exit;

  {$IFNDEF NO_EXTERNALGRID}
  if GetChecked(IDC_IEVIEWAPI)     <> (DBReadByte(0,hppDBName,'IEViewAPI',0)<>0) then exit;
  if GetChecked(IDC_GROUPLOGITEMS) <> (DBReadByte(0,hppDBName,'GroupLogItems',0)<>0) then exit;
  if GetChecked(IDC_DISABLEBORDER) <> (DBReadByte(0,hppDBName,'NoLogBorder',0)<>0) then exit;
  if GetChecked(IDC_DISABLESCROLL) <> (DBReadByte(0,hppDBName,'NoLogScrollBar',0)<>0) then exit;
  {$ENDIF}

  Result := False;
end;

procedure SaveChangedOptions;
var
  ShowRestart: Boolean;
  Checked: Boolean;
//  i: Integer;
begin
  ShowRestart := False;
  GridOptions.StartChange;
  try
    GridOptions.ShowIcons := GetChecked(IDC_SHOWEVENTICONS);
    GridOptions.RTLEnabled := GetChecked(IDC_RTLDEFAULT);
    GridOptions.OpenDetailsMode := GetChecked(IDC_OPENDETAILS);

    ShowHistoryCount := GetChecked(IDC_SHOWEVENTSCOUNT);
    if ShowHistoryCount <> (DBReadByte(0,hppDBName,'ShowHistoryCount',0)<>0) then
      DBWriteByte(0,hppDBName,'ShowHistoryCount',Ord(ShowHistoryCount));

    //GridOptions.ShowAvatars := GetChecked(IDC_SHOWAVATARS);

    GridOptions.BBCodesEnabled        := GetChecked(IDC_BBCODE);
    GridOptions.RawRTFEnabled         := GetChecked(IDC_RAWRTF);
    GridOptions.AvatarsHistoryEnabled := GetChecked(IDC_AVATARSHISTORY);

    if SmileyAddExists  then GridOptions.SmileysEnabled    := GetChecked(IDC_SMILEY);
    if MathModuleExists then GridOptions.MathModuleEnabled := GetChecked(IDC_MATH);

    GridOptions.SaveOptions;
  finally
    GridOptions.EndChange;
  end;

  Checked := GetChecked(IDC_RECENTONTOP);
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

  Checked := GetChecked(IDC_GROUPHISTITEMS);
  if Checked <> (DBReadByte(0,hppDBName,'GroupHistoryItems',0)<>0) then
  begin
    DBWriteByte(0,hppDBName,'GroupHistoryItems',Ord(Checked));
{
    for i := 0 to HstWindowList.Count - 1 do
      THistoryFrm(HstWindowList[i]).hg.GroupLinked := Checked;
}
  end;

  {$IFNDEF NO_EXTERNALGRID}
  Checked := GetChecked(IDC_IEVIEWAPI);
  if Checked <> (DBReadByte(0,hppDBName,'IEViewAPI',0)<>0) then
    DBWriteByte(0,hppDBName,'IEViewAPI',Ord(Checked));
//  ShowRestart := ShowRestart or (Checked <> ImitateIEView);

  Checked := GetChecked(IDC_GROUPLOGITEMS);
  if Checked <> (DBReadByte(0,hppDBName,'GroupLogItems',0)<>0) then
  begin
    DBWriteByte(0,hppDBName,'GroupLogItems',Ord(Checked));
//!    ExternalGrids.GroupLinked := Checked;
  end;

  Checked := GetChecked(IDC_DISABLEBORDER);
  if Checked <> (DBReadByte(0,hppDBName,'NoLogBorder',0)<>0) then
    DBWriteByte(0,hppDBName,'NoLogBorder',Ord(Checked));
  //ShowRestart := ShowRestart or (Checked <> DisableLogBorder);

  Checked := GetChecked(IDC_DISABLESCROLL);
  if Checked <> (DBReadByte(0,hppDBName,'NoLogScrollBar',0)<>0) then
    DBWriteByte(0,hppDBName,'NoLogScrollBar',Ord(Checked));
  //ShowRestart := ShowRestart or (Checked <> DisableLogScrollbar);
  {$ENDIF}

  if ShowRestart then
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_SHOW)
  else
    ShowWindow(GetDlgItem(hDlg,ID_NEED_RESTART),SW_HIDE);
end;

function OptDialogProc(hwndDlg: HWND; uMsg: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
begin
  Result := 0;
  case uMsg of
    WM_DESTROY: hDlg := 0;

    WM_INITDIALOG: begin
      hDlg := hwndDlg;
      SetChecked(IDC_SHOWEVENTICONS,GridOptions.ShowIcons);
      SetChecked(IDC_RTLDEFAULT,GridOptions.RTLEnabled);
      SetChecked(IDC_OPENDETAILS,GridOptions.OpenDetailsMode);
      SetChecked(IDC_SHOWEVENTSCOUNT,ShowHistoryCount);
      //SetChecked(IDC_SHOWAVATARS,GridOptions.ShowAvatars);

      SetChecked(IDC_BBCODE,GridOptions.BBCodesEnabled);
      EnableWindow(GetDlgItem(hDlg,IDC_SMILEY),SmileyAddExists);
      if SmileyAddExists then
        SetChecked(IDC_SMILEY,GridOptions.SmileysEnabled);
      EnableWindow(GetDlgItem(hDlg,IDC_MATH),MathModuleExists);
      if MathModuleExists then
        SetChecked(IDC_MATH,GridOptions.MathModuleEnabled);
      SetChecked(IDC_RAWRTF,GridOptions.RawRTFEnabled);
      SetChecked(IDC_AVATARSHISTORY,GridOptions.AvatarsHistoryEnabled);

      SetChecked(IDC_RECENTONTOP,DBReadByte(0,hppDBName,'SortOrder',0)<>0);
      SetChecked(IDC_GROUPHISTITEMS,DBReadByte(0,hppDBName,'GroupHistoryItems',0)<>0);

      SetChecked(IDC_IEVIEWAPI    ,DBReadByte(0,hppDBName,'IEViewAPI',0)<>0);
      SetChecked(IDC_GROUPLOGITEMS,DBReadByte(0,hppDBName,'GroupLogItems',0)<>0);
      SetChecked(IDC_DISABLEBORDER,DBReadByte(0,hppDBName,'NoLogBorder',0)<>0);
      SetChecked(IDC_DISABLESCROLL,DBReadByte(0,hppDBName,'NoLogScrollBar',0)<>0);

      TranslateDialogDefault(hwndDlg);
    end;

    WM_NOTIFY: begin
      if PNMHDR(lParam)^.code = PSN_APPLY then
      begin
        Result := 1;
        // apply changes here
        SaveChangedOptions;
      end;
    end;

    WM_COMMAND: begin
      case LoWord(wParam) of
        ID_NEEDOPTIONS_LINK: begin
          CallService(MS_UTILS_OPENURL,TWPARAM(True),TLPARAM(PAnsiChar(URL_NEEDOPTIONS)));
          Result := 1;
        end;
      else
        if AreOptionsChanged then
        begin
          Result := 1;
          SendMessage(GetParent(hwndDlg),PSM_CHANGED,hwndDlg,0);
        end;
      end;
    end;

  end;
end;

function GetText(hDlg: HWND; idCtrl: Integer): WideString;
var
  dlg_text: array[0..1023] of WideChar;
begin
  ZeroMemory(@dlg_text,SizeOf(dlg_text));
  GetDlgItemTextW(hDlg,idCtrl,@dlg_text,1023);
  Result := dlg_text;
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
            end;
            IDC_DATE_HELP: begin
            end;
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      if PNMHDR(lParam)^.code = PSN_APPLY then
      begin
        Result := 1;

        GridOptions.ClipCopyFormat       :=GetText(hwndDlg,IDC_TMPL_COPY);
        GridOptions.ClipCopyTextFormat   :=GetText(hwndDlg,IDC_TMPL_COPYTEXT);
        GridOptions.ReplyQuotedFormat    :=GetText(hwndDlg,IDC_TMPL_QUOTED);
        GridOptions.ReplyquotedTextFormat:=GetText(hwndDlg,IDC_TMPL_QUOTEDTEXT);
        GridOptions.SelectionFormat      :=GetText(hwndDlg,IDC_TMPL_SELECTION);

        GridOptions.DateTimeFormat:=GetText(hwndDlg,IDC_TMPL_DATETIME);

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
