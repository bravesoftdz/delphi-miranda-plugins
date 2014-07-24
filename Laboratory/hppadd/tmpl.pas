unit tmpl;

interface

uses
  windows,
  m_api,
  my_grid;

function Sample(hContact:TMCONTACT):int_ptr;

implementation

uses
  messages,
  hpp_global, hpp_events, hpp_itemprocess, hpp_contacts;

type
  tTmplWindow = class
  private
    Handle:HWND;
    Grid: THistoryGrid;
    FContact   : TMCONTACT;
    FSubContact: TMCONTACT;
    FProtocol   : PAnsiChar;
    FSubProtocol: PAnsiChar;
    harray:array of THANDLE;
    HistoryLength:integer;

    procedure hgItemData (Index: Integer; var Item: THistoryItem);
    function  GetItemData(Index: Integer): THistoryItem;

    procedure hgProcessRichText(Handle: THANDLE; Item: Integer);

  public
    procedure WndCreate;

    function FillHistory(hContact:TMCONTACT):integer;
  end;
{
OnDblClick = hgDblClick
OnPopup = hgPopup
OnTranslateTime = hgTranslateTime
OnSearchFinished = hgSearchFinished

*OnItemData = hgItemData
OnItemDelete = hgItemDelete
OnItemFilter = hgItemFilter
OnSearchItem = hgSearchItem

OnKeyDown = hgKeyDown
OnKeyUp = hgKeyUp
OnChar = hgChar

OnInlineKeyDown = hgInlineKeyDown
OnInlinePopup = hgInlinePopup
OnProcessInlineChange = hgProcessInlineChange

OnOptionsChange = hgOptionsChange
OnState = hgState
OnSelect = hgSelect
OnRTLChange = hgRTLEnabled
OnUrlClick = hgUrlClick
OnBookmarkClick = hgBookmarkClick
OnFilterChange = hgFilterChange
*OnProcessRichText = hgProcessRichText
}
{
FContact:THANDLE;
harray:array of THANDLE;
HistoryLength:integer;

procedure hgItemData(Index: Integer; var Item: THistoryItem);
function GetItemData(Index: Integer): THistoryItem;
procedure GridProcessRichText(Handle: THANDLE; Item: Integer);
}

function tTmplWindow.GetItemData(Index: Integer): THistoryItem;
begin
  ReadEvent(harray[Index], Result);
end;

procedure tTmplWindow.hgItemData(Index: Integer; var Item: THistoryItem);
begin
  Item := GetItemData(Index);
  Item.HasHeader := true;
end;

procedure tTmplWindow.hgProcessRichText(Handle: THANDLE; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
  lItem:THistoryItem;
begin
  lItem:=Grid.Items[Item];

  ZeroMemory(@ItemRenderDetails, SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize      := SizeOf(ItemRenderDetails);
  ItemRenderDetails.hContact    := FContact;
  ItemRenderDetails.hDBEvent    := harray[Item];
  ItemRenderDetails.pProto      := PAnsiChar(lItem.Proto);
  ItemRenderDetails.pModule     := PAnsiChar(lItem.Module);
  ItemRenderDetails.pText       := nil;
  ItemRenderDetails.pExtended   := PAnsiChar(lItem.Extended);
  ItemRenderDetails.dwEventTime := lItem.Time;
  ItemRenderDetails.wEventType  := lItem.EventType;
  ItemRenderDetails.IsEventSent := IsOutgoingEvent(lItem);

  if Grid.IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;
  ItemRenderDetails.bHistoryWindow := IRDHW_CONTACTHISTORY;//IRDHW_EXTERNALGRID;
  AllHistoryRichEditProcess(WParam(Handle), LParam(@ItemRenderDetails));
//  NotifyEventHooks(hHppRichEditItemProcess, WParam(Handle), LParam(@ItemRenderDetails));
end;


function tTmplWindow.FillHistory(hContact:TMCONTACT):integer;
var
  i:integer;
  hDBEvent:THANDLE;
begin
//  FContact:=hContact;
FContact:=0;
  HistoryLength := db_event_count(hContact);
  SetLength(harray,HistoryLength);
  hDBEvent := db_event_first(hContact);
  for i:=0 to HistoryLength-1 do
  begin
    harray[i]:=hDBEvent;
    hDBEvent := db_event_next(hContact,hDBEvent);
  end;
  result:=HistoryLength;

  FProtocol := GetContactProto(hContact, FSubContact, FSubProtocol);
  // hContact,hSubContact,Protocol,SubProtocol should be
  // already filled by calling hContact := Value;
  Grid.ProfileName := 'Me';//GetContactDisplayName(0, FSubProtocol);
  Grid.ContactName := pWideChar(GetContactDisplayName(hContact, FProtocol, True));

  Grid.Allocate(result);

//  Messageboxw(0,pWideChar(Grid.SelectionString),nil,0);
end;

{
function OpenContactHistory(hContact: THANDLE; Index: Integer = -1): THistoryFrm;
var
  wHistory: THistoryFrm;
  NewWindow: Boolean;
begin
  // check if window exists, otherwise create one
  wHistory := FindContactWindow(hContact);
  NewWindow := not Assigned(wHistory);
  if NewWindow then
  begin
    wHistory := THistoryFrm.Create(nil);
    HstWindowList.Add(wHistory);
    wHistory.WindowList := HstWindowList;
    wHistory.hg.Options := GridOptions;
    wHistory.hContact   := hContact;
    wHistory.Load;
  end;
  if Index <> -1 then
  begin
    wHistory.ShowAllEvents;
    wHistory.ShowItem(index);
  end;
  if NewWindow then
    wHistory.Show
  else
    BringFormToFront(wHistory); // restore even if minimized
  Result := wHistory;
end;
}

{}
function TmplWndProc(Dialog: HWND; hMessage: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
var
  tmpl:TTmplWindow;
  rc:TRect;
  dc:HDC;
  x,w:integer;
  ps:tPaintStruct;
begin
  result:=0;
  tmpl:=tTmplWindow(GetWindowLongPtrW(Dialog,GWLP_USERDATA));

  case hMessage of
    WM_DESTROY: begin
      tmpl.Grid.Free;
    end;

    WM_INITDIALOG: begin
    end;

    WM_SIZE: begin
      GetClientRect(Dialog,rc);

      // Resize ScrollBar
      w:=rc.Right-40;
      x:=rc.Right-w;
      MoveWindow(tmpl.Grid.Handle, x, rc.Top, w, rc.Bottom, false);

    end;

    WM_PAINT: begin
      dc := BeginPaint(Dialog, ps);
      FillRect(dc,ps.rcPaint,GetSysColorBrush(COLOR_WINDOW));
      EndPaint(Dialog, ps);
    end;

    WM_COMMAND: begin
{
      case wParam shr 16 of
      end;
}
    end;

    WM_HELP: begin
      result:=1;
    end;

    WM_NOTIFY: begin
{
      if integer(PNMHDR(lParam)^.code) = PSN_APPLY then
      begin
      end;
}
    end;
  else
    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

procedure tTmplWindow.WndCreate;
begin
  // Create Main window
  Handle:=CreateWindowExW(0,'STATIC',nil,WS_VISIBLE +WS_BORDER+WS_DLGFRAME+WS_SYSMENU+WS_SIZEBOX,
      0,0,400,200,
      0,0,hInstance,nil);
  SetWindowLongPtrW(Handle,GWL_WNDPROC,LONG_PTR(@TmplWndProc));
  SetWindowLongPtrW(Handle,GWLP_USERDATA,long_ptr(Self));

  Grid:=NewHistoryGrid(Handle);

  Grid.BeginUpdate;

  Grid.SBHidden:=true;

  Grid.OnItemData := hgItemData;
//  Grid.OnNameData := ;

  Grid.OnProcessRichText := hgProcessRichText;

  Grid.ShowHeaders := true;
  
  SendMessage(Handle,WM_SIZE,0,0);
  Grid.EndUpdate;
end;

function Sample(hContact:TMCONTACT):int_ptr;
var
  twnd:tTmplWindow;
begin
  twnd:=tTmplWindow.Create;
  twnd.WndCreate;
  twnd.FillHistory(hContact);

  result:=0;
end;

end.
