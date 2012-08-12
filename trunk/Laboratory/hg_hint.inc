{}
{
procedure THistoryGrid.CMHintShow(var Message: TMessage);
var
  Item: Integer;
  tempHint: WideString;
  tempRect: TRect;
begin
  With TCMHintShow(Message).HintInfo^ do
  begin
    if ghtButton in HintHitTests then
    begin
      CursorRect := FHintRect;
      if ghtBookmark in HintHitTests then
      begin
        Item := FindItemAt(CursorPos);
        if FItems[Item].Bookmarked then
          Hint := TranslateW('Remove Bookmark')
        else
          Hint := TranslateW('Set Bookmark')
      end
      else if ghtSessHideButton in HintHitTests then
        Hint := TranslateW('Hide headers')
      else if ghtSessShowButton in HintHitTests then
        Hint := TranslateW('Show headers');
      Message.Result := 0;
    end
    else if (ghtUnknown in HintHitTests) and
      GetHintAtPoint(CursorPos.X, CursorPos.Y, tempHint, tempRect) then
    begin
//!!      Hint := StringReplace(tempHint, '|', 'æ', [rfReplaceAll]);
      CursorRect := tempRect;
      Message.Result := 0;
    end
    else
      Message.Result := 1;
  end;
  // !!  ProcessCMHintShowMsg(Message);
  inherited;
end;
}
const
  IID_ITooltipData:     TGUID = '{58B32D03-1BD2-4840-992E-9AE799FD4ADE}';
  IID_IGifSmileyCtrl:   TGUID = '{CB64102B-8CE4-4A55-B050-131C435A3A3F}';
  IID_ISmileyAddSmiley: TGUID = '{105C56DF-6455-4705-A501-51F1CCFCF688}';
  IID_IEmoticonsImage:  TGUID = '{2FD9449B-7EBB-476a-A9DD-AE61382CCE08}';

type
  ITooltipData = interface(IUnknown)
   ['{58B32D03-1BD2-4840-992E-9AE799FD4ADE}']
   function SetTooltip(const bstrHint: WideString): HRESULT; stdcall;
   function GetTooltip(out bstrHint: WideString): HRESULT; stdcall;
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

function THistoryGrid.GetHintAtPoint(X, Y: Integer; var ObjectHint: WideString; var ObjectRect: TRect): Boolean;
var
  P: TPoint;
  RichEditRect: TRect;
  cp, Item: Integer;
  textDoc: ITextDocument;
  textRange: ITextRange;
  iObject: IUnknown;
  iTooltipCtrl: ITooltipData;
  Size: TPoint;

begin
  ObjectHint := '';
  Result := False;

  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  RichEditRect := GetRichEditRect(Item, True);
  P := MakePoint(X - RichEditRect.Left, Y - RichEditRect.Top);
  ApplyItemToRich(Item);

  if not Assigned(FRich.RichEditOle) then
    exit;

  repeat
    if FRich.RichEditOle.QueryInterface(IID_ITextDocument, textDoc) <> S_OK then
      break;
    P := FRich.Client2Screen(P);
    textRange := textDoc.RangeFromPoint(P.X, P.Y);
    if not Assigned(textRange) then
      break;
    iObject := textRange.GetEmbeddedObject;
    if not Assigned(iObject) then
    begin
      cp := textRange.Start;
      textRange.Start := cp - 1;
      textRange.End_ := cp;
      iObject := textRange.GetEmbeddedObject;
    end;
    if not Assigned(iObject) then
      break;

    if iObject.QueryInterface(IID_ITooltipData, iTooltipCtrl) = S_OK then
      iTooltipCtrl.GetTooltip(ObjectHint)
    else if Supports(iObject, IID_IGifSmileyCtrl)   then ObjectHint := TranslateW('Running version of AniSmiley is not supported')
    else if Supports(iObject, IID_ISmileyAddSmiley) then ObjectHint := TranslateW('Running version of SmileyAdd is not supported')
    else if Supports(iObject, IID_IEmoticonsImage)  then ObjectHint := TranslateW('Running version of Emoticons is not supported')
    else
      break;
    if ObjectHint = '' then
      break;

    textRange.GetPoint(tomStart + TA_TOP + TA_LEFT, Size.X, Size.Y);
    Size := FRich.Screen2Client(Size);
    ObjectRect.TopLeft := Size;

    textRange.GetPoint(tomStart + TA_BOTTOM + TA_RIGHT, Size.X, Size.Y);
    Size := FRich.Screen2Client(Size);
    ObjectRect.BottomRight := Size;

    OffsetRect(ObjectRect, RichEditRect.Left, RichEditRect.Top);
    InflateRect(ObjectRect, 1, 1);

    Result := PtInRect(ObjectRect, MakePoint(X, Y));
  until True;

  if not Result then
    ObjectHint := '';

  ReleaseObject(iTooltipCtrl);
  ReleaseObject(iObject);
  ReleaseObject(textRange);
  ReleaseObject(textDoc);
end;
