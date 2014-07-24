{}

function THistoryGrid.HintShow(X, Y: integer):integer;
var
  Hint: WideString;
  TI:TToolInfoW;
  Item: Integer;
begin
  result := 0;
  if ghtButton in HintHitTests then
  begin
    if ghtBookmark in HintHitTests then
    begin
      Item := FindItemAt(X, Y);
      if FItems[Item].Bookmarked then
        Hint := TranslateW('Remove Bookmark')
      else
        Hint := TranslateW('Set Bookmark')
    end
    else if ghtSessHideButton in HintHitTests then
      Hint := TranslateW('Hide headers')
    else if ghtSessShowButton in HintHitTests then
      Hint := TranslateW('Show headers');
  end
  else if (ghtUnknown in HintHitTests) and
    GetHintAtPoint(X, Y, Hint) then
  begin
  end
  else
    Result := 1;

  if result=0 then
  begin
    with TI do
    begin
      cbSize   := SizeOf(TI);
      uFlags   := TTF_SUBCLASS;
      hWnd     := FClient;
      hInst    := 0;
      uId      := FClient;
      lpszText := PWideChar(Hint);
      rect     := FHintRect;
    end;
    SendMessageW(FHintWindow,TTM_SETTOOLINFOW,0,tlparam(@TI));
    SendMessageW(FHintWindow,TTM_POPUP,0,0);
  end;
end;

const
  IID_ITooltipData:TGUID = '{58B32D03-1BD2-4840-992E-9AE799FD4ADE}';

type
  ITooltipData = interface(IUnknown)
   ['{58B32D03-1BD2-4840-992E-9AE799FD4ADE}']
   function SetTooltip(const bstrHint: WideString): HRESULT; stdcall;
   function GetTooltip(out   bstrHint: WideString): HRESULT; stdcall;
  end;

procedure ReleaseObject(var Obj);
begin
  if IUnknown(Obj) <> nil then IUnknown(Obj) := nil;
end;

function Supports(const Instance: IUnknown; const IID: TGUID): Boolean;
var
  Temp: pointer;
begin
  Result := (Instance <> nil) and (Instance.QueryInterface(IID, Temp) = 0);
end;

function THistoryGrid.GetHintAtPoint(X, Y: Integer; var ObjectHint: WideString): Boolean;
var
  P: TPoint;
  RichEditRect: TRect;
  textDoc: ITextDocument;
  textRange: ITextRange;
  iObject: IUnknown;
  iTooltipCtrl: ITooltipData;
  FRich: PHPPRichEdit;
  cp, Item: Integer;
begin
  ObjectHint := '';
  Result := False;

  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  RichEditRect := GetRichEditRect(Item, True);
  Point(P, X - RichEditRect.Left, Y - RichEditRect.Top);
  FRich := GetRichFromCache(Item);

  if not Assigned(FRich.iOle) then
    exit;

  repeat // just to use "break" command
    if FRich.iOle.QueryInterface(IID_ITextDocument, textDoc) <> S_OK then
      break;

    ClientToScreen(FClient, P);
    textRange := textDoc.RangeFromPoint(P.X, P.Y);
    if not Assigned(textRange) then
      break;
    iObject := textRange.GetEmbeddedObject;
    if not Assigned(iObject) then
    begin
      cp := textRange.Start;
      textRange.Start := cp - 1;
      textRange.End_  := cp;
      iObject := textRange.GetEmbeddedObject;
    end;
    if not Assigned(iObject) then
      break;

    if iObject.QueryInterface(IID_ITooltipData, iTooltipCtrl) = S_OK then
      iTooltipCtrl.GetTooltip(ObjectHint);

  until True;

  Result := ObjectHint <> '';

  ReleaseObject(iTooltipCtrl);
  ReleaseObject(iObject);
  ReleaseObject(textRange);
  ReleaseObject(textDoc);
end;
