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

unit hpp_external;

interface

uses
  Windows,
//  hpp_externalgrid,
  my_grid,
  m_api;

type
  TExternalGrid = THistoryGrid;

type
  TExternalGrids = class
  private
    FGrids: PSortedList;
    procedure SetGroupLinked(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ExtGrid: TExternalGrid);
    function Find(Handle: HWND): TExternalGrid;
    function Delete(Handle: HWND): Boolean;
    function Clear(): Boolean;
    procedure Perform(Msg: Cardinal; wParam: WPARAM; lParam: LPARAM);
    property GroupLinked: Boolean write SetGroupLinked;
  end;

const
  MS_HPP_EG_WINDOW         = 'History++/ExtGrid/NewWindow';
  MS_HPP_EG_EVENT	         = 'History++/ExtGrid/Event';
  MS_HPP_EG_NAVIGATE       = 'History++/ExtGrid/Navigate';
  ME_HPP_EG_OPTIONSCHANGED = 'History++/ExtGrid/OptionsChanged';

var
  ImitateIEView: boolean;
  ExternalGrids: TExternalGrids;

procedure RegisterExtGridServices;
procedure UnregisterExtGridServices;

implementation

uses
  dbsettings,
  hpp_global;

{$include m_ieview.inc}

var
  hExtWindowIE, hExtEventIE, hExtNavigateIE, hExtOptChangedIE: THandle;
  hExtWindow, hExtEvent, hExtNavigate, hExtOptChanged: THandle;

function ExtWindow(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
var
  par: PIEVIEWWINDOW;
  ExtGrid: TExternalGrid;
  ControlID: Cardinal;
begin
  Result := 0;

  par := PIEVIEWWINDOW(lParam);
//  Assert(par <> nil, 'Empty IEVIEWWINDOW structure');
  case par.iType of
    IEW_CREATE: begin
      case par.dwMode of
        IEWM_TABSRMM: ControlID := 1006;  // IDC_LOG from tabSRMM
        IEWM_SCRIVER: ControlID := 1001;  // IDC_LOG from Scriver
        IEWM_MUCC:    ControlID := 0;
        IEWM_CHAT:    ControlID := 0;
        IEWM_HISTORY: ControlID := 0;
      else            ControlID := 0;
      end;
//!!      ExtGrid := TExternalGrid.Create(par.Parent,ControlID);
      case par.dwMode of
        IEWM_MUCC,IEWM_CHAT: begin
{!!
          ExtGrid.ShowHeaders   := False;
          ExtGrid.GroupLinked   := False;
          ExtGrid.ShowBookmarks := False;
}
        end;
        IEWM_HISTORY:
//!!          ExtGrid.GroupLinked := False;
      end;
{!!
      ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
      ExternalGrids.Add(ExtGrid,GridMode);
      par.Hwnd := ExtGrid.GridHandle;
}
    end;

    IEW_DESTROY: begin
      ExternalGrids.Delete(par.Hwnd);
    end;

    IEW_SETPOS: begin
      ExtGrid := ExternalGrids.Find(par.Hwnd);
      if ExtGrid <> nil then
//!!        ExtGrid.SetPosition(par.x,par.y,par.cx,par.cy);
    end;

    IEW_SCROLLBOTTOM: begin
      ExtGrid := ExternalGrids.Find(par.Hwnd);
      if ExtGrid <> nil then
        ExtGrid.ScrollToBottom;
    end;
  end;
end;

function ExtEvent(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
var
  event: PIEVIEWEVENT;
  customEvent: PIEVIEWEVENTDATA;
  UsedCodepage: Cardinal;
  hDBNext: THandle;
  eventCount: Integer;
  ExtGrid: TExternalGrid;
//!!  CustomItem: TExtCustomItem;
begin
  Result := 0;

  event := PIEVIEWEVENT(lParam);
//  Assert(event <> nil, 'Empty IEVIEWEVENT structure');
  ExtGrid := ExternalGrids.Find(event.Hwnd);
  if ExtGrid = nil then exit;

  case event.iType of
    IEE_LOG_DB_EVENTS: begin
      if event.cbSize >= IEVIEWEVENT_SIZE_V2 then
        UsedCodepage := event.Codepage
      else
        UsedCodepage := CP_ACP;
      eventCount := event.Count;
      hDBNext := event.Event.hDBEventFirst;
      ExtGrid.BeginUpdate;
      while (eventCount <> 0) and (hDBNext <> 0) do
      begin
{!!
        ExtGrid.AddEvent(event.hContact, hDBNext, UsedCodepage,
                         boolean(event.dwFlags and IEEF_RTL),
                         not boolean(event.dwFlags and IEEF_NO_SCROLLING));
}
        if eventCount > 0 then Dec(eventCount);
        if eventCount <> 0 then
          hDBNext := db_event_next(hDBNext);
      end;
      ExtGrid.EndUpdate;
    end;

    IEE_LOG_MEM_EVENTS: begin
      if event.cbSize >= IEVIEWEVENT_SIZE_V2 then
        UsedCodepage := event.Codepage
      else
        UsedCodepage := CP_ACP;
      eventCount := event.Count;
      customEvent := event.Event.eventData;
      ExtGrid.BeginUpdate;
      while (eventCount <> 0) and (customEvent <> nil) do
      begin
{!!
        if boolean(customEvent.dwFlags and IEEDF_UNICODE_TEXT) then
          SetString(CustomItem.Text,customEvent.Text.w,lstrlenW(customEvent.Text.w))
        else
          CustomItem.Text := AnsiToWideString(AnsiString(customEvent.Text.a),UsedCodepage);

        if boolean(customEvent.dwFlags and IEEDF_UNICODE_NICK) then
          SetString(CustomItem.Nick,customEvent.Nick.w,lstrlenW(customEvent.Nick.w))
        else
          CustomItem.Nick := AnsiToWideString(AnsiString(customEvent.Nick.a),UsedCodepage);

        CustomItem.Sent := boolean(customEvent.bIsMe);
        CustomItem.Time := customEvent.time;
        ExtGrid.AddCustomEvent(event.hContact, CustomItem, UsedCodepage,
                           boolean(event.dwFlags and IEEF_RTL),
                           not boolean(event.dwFlags and IEEF_NO_SCROLLING));
}
        if eventCount > 0 then Dec(eventCount);
        customEvent := customEvent.next;
      end;
      ExtGrid.EndUpdate;
    end;

    IEE_CLEAR_LOG: begin
      ExtGrid.BeginUpdate;
//!!      ExtGrid.Clear;
      ExtGrid.EndUpdate;
    end;

    IEE_GET_SELECTION: begin
//!!      Result := int_ptr(ExtGrid.GetSelection(boolean(event.dwFlags and IEEF_NO_UNICODE)));
    end;

    IEE_SAVE_DOCUMENT: begin
//!!      ExtGrid.SaveSelected;
    end;
  end;
end;

function ExtNavigate(wParam:WPARAM; lParam: LPARAM): int_ptr; cdecl;
begin
  Result := 0;
end;

procedure RegisterExtGridServices;
begin
  ExternalGrids := TExternalGrids.Create;
  ImitateIEView := DBReadByte(0,hppDBName,'IEViewAPI',0)<>0;
  if ImitateIEView then
  begin
    hExtWindowIE     := CreateServiceFunction(MS_IEVIEW_WINDOW,ExtWindow);
    hExtEventIE      := CreateServiceFunction(MS_IEVIEW_EVENT,ExtEvent);
    hExtNavigateIE   := CreateServiceFunction(MS_IEVIEW_NAVIGATE,ExtNavigate);
    hExtOptChangedIE := CreateHookableEvent(ME_IEVIEW_OPTIONSCHANGED);
  end;
  hExtWindow     := CreateServiceFunction(MS_HPP_EG_WINDOW,ExtWindow);
  hExtEvent      := CreateServiceFunction(MS_HPP_EG_EVENT,ExtEvent);
  hExtNavigate   := CreateServiceFunction(MS_HPP_EG_NAVIGATE,ExtNavigate);
  hExtOptChanged := CreateHookableEvent(ME_HPP_EG_OPTIONSCHANGED);
end;

procedure UnregisterExtGridServices;
begin
  if ImitateIEView then
  begin
    DestroyServiceFunction(hExtWindowIE);
    DestroyServiceFunction(hExtEventIE);
    DestroyServiceFunction(hExtNavigateIE);
    DestroyHookableEvent(hExtOptChangedIE);
  end;
  DestroyServiceFunction(hExtWindow);
  DestroyServiceFunction(hExtEvent);
  DestroyServiceFunction(hExtNavigate);
  DestroyHookableEvent(hExtOptChanged);
  ExternalGrids.Destroy;
end;

constructor TExternalGrids.Create;
begin
  FGrids := List_Create(8, 8);
end;

destructor TExternalGrids.Destroy;
begin
  Clear;
  List_Destroy(FGrids);

  inherited;
end;

procedure TExternalGrids.Add(const ExtGrid: TExternalGrid);
begin
  List_InsertPtr(FGrids,ExtGrid);
end;

function TExternalGrids.Find(Handle: HWND): TExternalGrid;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := nil;
  for i := 0 to FGrids.realCount-1 do
  begin
    ExtGrid := TExternalGrid(FGrids.Items[i]);
    if ExtGrid.Handle = Handle then
    begin
      Result := ExtGrid;
      break;
    end;
  end;
end;

function TExternalGrids.Delete(Handle: HWND): Boolean;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := True;
  for i := 0 to FGrids.realCount-1 do
  begin
    ExtGrid := TExternalGrid(FGrids.Items[i]);
    if ExtGrid.Handle = Handle then
    begin
      try
        ExtGrid.Free;
      except
        Result := False;
      end;
      List_Remove(FGrids,i);
      break;
    end;
  end;
end;

function TExternalGrids.Clear(): Boolean;
var
  i: Integer;
  ExtGrid: TExternalGrid;
begin
  Result := True;
  for i := 0 to FGrids.realCount-1 do
  begin
    ExtGrid := TExternalGrid(FGrids.Items[i]);
    try
      ExtGrid.Free;
    except
      Result := False;
    end;
  end;
//!!  FGrids.Clear;
end;

procedure TExternalGrids.Perform(Msg: Cardinal; wParam: WPARAM; lParam: LPARAM);
var
  i: Integer;
begin
  for i := FGrids.realCount-1 downto 0 do
    SendMessageW(TExternalGrid(FGrids.Items[i]).Handle,Msg,wParam,lParam);
end;

procedure TExternalGrids.SetGroupLinked(Value: Boolean);
var
  i: Integer;
begin
  for i := FGrids.realCount-1 downto 0 do
    TExternalGrid(FGrids.Items[i]).GroupLinked := Value;
end;

end.
