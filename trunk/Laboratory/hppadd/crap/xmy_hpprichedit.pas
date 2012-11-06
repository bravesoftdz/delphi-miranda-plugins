{ THPPRichEdit }

  THppRichEdit = class(TCustomRichEdit)
  private
    FVersion: Integer;
    FCodepage: Cardinal;
    FClickRange: TCharRange;
    FClickBtn: TMouseButton;
    FOnURLClick: TURLClickEvent;
    FRichEditOleCallback: TRichEditOleCallback;
    FRichEditOle: IRichEditOle;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMDestroy(var Msg: TWMDestroy); message WM_DESTROY;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMLangChange(var Message: TMessage); message WM_INPUTLANGCHANGE;
    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMKeyDown(var Message: TWMKey); message WM_KEYDOWN;
    procedure SetAutoKeyboard(Enabled: Boolean);
    procedure LinkNotify(Link: TENLink);
    procedure CloseObjects;
    function UpdateHostNames: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure URLClick(const URLText: String; Button: TMouseButton); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    //function GetTextRangeA(cpMin,cpMax: Integer): AnsiString;
    function GetTextRange(cpMin,cpMax: Integer): String;
    function GetTextLength: Integer;
    procedure ReplaceCharFormatRange(const fromCF, toCF: CHARFORMAT2; idx, len: Integer);
    procedure ReplaceCharFormat(const fromCF, toCF: CHARFORMAT2);
    property Codepage: Cardinal read FCodepage write FCodepage default CP_ACP;
    property Version: Integer read FVersion;
    property RichEditOle: IRichEditOle read FRichEditOle;
  published
    published
    property Align;
    property Alignment;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HideScrollBars;
    property ImeMode;
    property ImeName;
    property Constraints;
    property Lines;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PlainText;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property WantTabs;
    property WantReturns;
    property WordWrap;
    property OnChange;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSaveClipboard;
    property OnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
    property OnURLClick: TURLClickEvent read FOnURLClick write FOnURLClick;
  end;

constructor THppRichedit.Create(AOwner: TComponent);
begin
  FClickRange.cpMin := -1;
  FClickRange.cpMax := -1;
  FRichEditOleCallback := TRichEditOleCallback.Create(Self);
  inherited;
end;

destructor THppRichedit.Destroy;
begin
  inherited Destroy;
  FRichEditOleCallback.Free;
end;

procedure THppRichedit.CloseObjects;
var
  i: Integer;
  ReObject: TReObject;
begin
  if Assigned(FRichEditOle) then
  begin
    ZeroMemory(@ReObject, SizeOf(ReObject));
    ReObject.cbStruct := SizeOf(ReObject);
    with IRichEditOle(FRichEditOle) do
    begin
      for i := GetObjectCount - 1 downto 0 do
        if Succeeded(GetObject(i, ReObject, REO_GETOBJ_POLEOBJ)) then
        begin
          if ReObject.dwFlags and REO_INPLACEACTIVE <> 0 then
            IRichEditOle(FRichEditOle).InPlaceDeactivate;
          ReObject.poleobj.Close(OLECLOSE_NOSAVE);
          ReleaseObject(ReObject.poleobj);
        end;
    end;
  end;
end;

procedure THppRichedit.Clear;
begin
  CloseObjects;
  inherited;
end;

function THppRichedit.UpdateHostNames: Boolean;
var
  AppName: String;
  AnsiAppName:AnsiString;
begin
  Result := True;
  if HandleAllocated and Assigned(FRichEditOle) then
  begin
    AppName := Application.Title;
    if Trim(AppName) = '' then
      AppName := ExtractFileName(Application.ExeName);
    AnsiAppName:=AnsiString(AppName);
    try
      FRichEditOle.SetHostNames(PAnsiChar(AnsiAppName), PAnsiChar(AnsiAppName));
    except
      Result := false;
    end;
  end;
end;

type
  TAccessCustomMemo = class(TCustomMemo);
  InheritedCreateParams = procedure(var Params: TCreateParams) of object;

procedure THppRichedit.CreateParams(var Params: TCreateParams);
const
  aHideScrollBars: array[Boolean] of DWORD = (ES_DISABLENOSCROLL, 0);
  aHideSelections: array[Boolean] of DWORD = (ES_NOHIDESEL, 0);
  aWordWrap:       array[Boolean] of DWORD = (WS_HSCROLL, 0);
var
  Method: TMethod;
begin
  FVersion := InitRichEditLibrary;
  Method.Code := @TAccessCustomMemo.CreateParams;
  Method.Data := Self;
  InheritedCreateParams(Method)(Params);
  if FVersion >= 20 then
  begin
{$IFDEF AllowMSFTEDIT}
    if FVersion = 41 then
      CreateSubClass(Params, MSFTEDIT_CLASS)
    else
{$ENDIF}
      CreateSubClass(Params, RICHEDIT_CLASS20W);
  end;
  with Params do
  begin
    Style := Style or aHideScrollBars[HideScrollBars] or aHideSelections[HideSelection] and
      not aWordWrap[WordWrap]; // more compatible with RichEdit 1.0
    // Fix for repaint richedit in event details form
    // used if class inherits from TCustomRichEdit
    // WindowClass.style := WindowClass.style or (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THppRichedit.CreateWindowHandle(const Params: TCreateParams);
begin
(*
  {$IFDEF AllowMSFTEDIT}
  if FVersion = 41 then
    CreateUnicodeHandle(Self, Params, MSFTEDIT_CLASS) else
  {$ENDIF}
    CreateUnicodeHandle(Self, Params, RICHEDIT_CLASS20W);
*)
inherited;
end;

procedure THppRichedit.CreateWnd;
const
  EM_SETEDITSTYLE         = WM_USER + 204;
  SES_EXTENDBACKCOLOR     = 4;
begin
  inherited;
  //SendMessage(Handle,EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  Perform(EM_SETMARGINS,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  //SendMessage(Handle,EM_SETEDITSTYLE,SES_EXTENDBACKCOLOR,SES_EXTENDBACKCOLOR);
  Perform(EM_SETEDITSTYLE,SES_EXTENDBACKCOLOR,SES_EXTENDBACKCOLOR);
  //SendMessage(Handle,EM_SETOPTIONS,ECOOP_OR,ECO_AUTOWORDSELECTION);
  Perform(EM_SETOPTIONS,ECOOP_OR,ECO_AUTOWORDSELECTION);
  //SendMessage(Handle,EM_AUTOURLDETECT,1,0);
  Perform(EM_AUTOURLDETECT,1,0);
  //SendMessage(Handle,EM_SETEVENTMASK,0,SendMessage(Handle,EM_GETEVENTMASK,0,0) or ENM_LINK);
  Perform(EM_SETEVENTMASK,0,Perform(EM_GETEVENTMASK,0,0) or ENM_LINK);
  RichEdit_SetOleCallback(Handle, FRichEditOleCallback as IRichEditOleCallback);
  if RichEdit_GetOleInterface(Handle, FRichEditOle) then UpdateHostNames;
end;

procedure THppRichedit.SetAutoKeyboard(Enabled: Boolean);
var
  re_options,new_options: DWord;
begin
  // re_options := SendMessage(Handle,EM_GETLANGOPTIONS,0,0);
  re_options := Perform(EM_GETLANGOPTIONS, 0, 0);
  if Enabled then
    new_options := re_options or IMF_AUTOKEYBOARD
  else
    new_options := re_options and not IMF_AUTOKEYBOARD;
  if re_options <> new_options then
    // SendMessage(Handle,EM_SETLANGOPTIONS,0,new_options);
    Perform(EM_SETLANGOPTIONS,0,new_options);
end;

procedure THppRichedit.ReplaceCharFormatRange(const fromCF, toCF: CHARFORMAT2; idx, len: Integer);
var
  cr: CHARRANGE;
  cf: CHARFORMAT2;
  loglen: Integer;
  res: DWord;
begin
  if len = 0 then
    exit;
  cr.cpMin := idx;
  cr.cpMax := idx + len;
  Perform(EM_EXSETSEL, 0, LPARAM(@cr));
  ZeroMemory(@cf, SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := fromCF.dwMask;
  res := Perform(EM_GETCHARFORMAT, SCF_SELECTION, LPARAM(@cf));
  if (res and fromCF.dwMask) = 0 then
  begin
    if len = 2 then
    begin
      // wtf, msdn tells that cf will get the format of the first AnsiChar,
      // and then we have to select it, if format match or second, if not
      // instead we got format of the last AnsiChar... weired
      if (cf.dwEffects and fromCF.dwEffects) = fromCF.dwEffects then
        Inc(cr.cpMin)
      else
        Dec(cr.cpMax);
      Perform(EM_EXSETSEL, 0, LPARAM(@cr));
      Perform(EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@toCF));
    end
    else
    begin
      loglen := len div 2;
      ReplaceCharFormatRange(fromCF, toCF, idx, loglen);
      ReplaceCharFormatRange(fromCF, toCF, idx + loglen, len - loglen);
    end;
  end
  else if (cf.dwEffects and fromCF.dwEffects) = fromCF.dwEffects then
    Perform(EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@toCF));
end;

procedure THppRichedit.ReplaceCharFormat(const fromCF, toCF: CHARFORMAT2);
begin
  ReplaceCharFormatRange(fromCF,toCF,0,GetTextLength);
end;

(*
function THppRichedit.GetTextRangeA(cpMin,cpMax: Integer): AnsiString;
var
  WideText: WideString;
  tr: TextRange;
begin
  tr.chrg.cpMin := cpMin;
  tr.chrg.cpMax := cpMax;
  SetLength(WideText,cpMax-cpMin);
  tr.lpstrText := @WideText[1];
  Perform(EM_GETTEXTRANGE,0,LPARAM(@tr));
  Result := WideToAnsiString(WideText,Codepage);
end;
*)

function THppRichedit.GetTextRange(cpMin,cpMax: Integer): String;
var
  tr: TextRange;
begin
  tr.chrg.cpMin := cpMin;
  tr.chrg.cpMax := cpMax;
  SetLength(Result,cpMax-cpMin);
  tr.lpstrText := @Result[1];

  Perform(EM_GETTEXTRANGE,0,LPARAM(@tr));
end;

function THppRichedit.GetTextLength: Integer;
var
  gtxl: GETTEXTLENGTHEX;
begin
  gtxl.flags := GTL_DEFAULT or GTL_PRECISE;
  gtxl.codepage := 1200;
  gtxl.flags := gtxl.flags or GTL_NUMCHARS;
  Result := Perform(EM_GETTEXTLENGTHEX, WPARAM(@gtxl), 0);
end;

procedure THppRichedit.URLClick(const URLText: String; Button: TMouseButton);
begin
  if Assigned(OnURLClick) then
    OnURLClick(Self, URLText, Button);
end;

procedure THppRichedit.LinkNotify(Link: TENLink);
begin
  case Link.msg of
    WM_RBUTTONDOWN: begin
      FClickRange := Link.chrg;
      FClickBtn := mbRight;
    end;
    WM_RBUTTONUP: begin
      if (FClickBtn = mbRight) and
         (FClickRange.cpMin = Link.chrg.cpMin) and (FClickRange.cpMax = Link.chrg.cpMax) then
        URLClick(GetTextRange(Link.chrg.cpMin, Link.chrg.cpMax), mbRight);
      FClickRange.cpMin := -1;
      FClickRange.cpMax := -1;
    end;
    WM_LBUTTONDOWN: begin
      FClickRange := Link.chrg;
      FClickBtn := mbLeft;
    end;
    WM_LBUTTONUP: begin
      if (FClickBtn = mbLeft) and
         (FClickRange.cpMin = Link.chrg.cpMin) and (FClickRange.cpMax = Link.chrg.cpMax) then
        URLClick(GetTextRange(Link.chrg.cpMin, Link.chrg.cpMax), mbLeft);
      FClickRange.cpMin := -1;
      FClickRange.cpMax := -1;
    end;
  end;
end;

procedure THppRichedit.CNNotify(var Message: TWMNotify);
begin
  case Message.NMHdr^.code of
    EN_LINK: LinkNotify(TENLINK(Pointer(Message.NMHdr)^));
  else
    inherited;
  end;
end;

procedure THppRichedit.WMDestroy(var Msg: TWMDestroy);
begin
  CloseObjects;
  ReleaseObject(FRichEditOle);
  inherited;
end;

type
  InheritedWMRButtonUp = procedure(var Message: TWMRButtonUp) of object;

procedure THppRichedit.WMRButtonUp(var Message: TWMRButtonUp);

  function GetDynamicMethod(AClass: TClass; Index: Integer): Pointer;
  asm call System.@FindDynaClass end;

var
  Method: TMethod;
begin
  Method.Code := GetDynamicMethod(TCustomMemo,WM_RBUTTONUP);
  Method.Data := Self;
  InheritedWMRButtonUp(Method)(Message);
  // RichEdit does not pass the WM_RBUTTONUP message to defwndproc,
  // so we get no WM_CONTEXTMENU message.
  // Simulate message here, after EN_LINK defwndproc's notyfy message
{!!
  if Assigned(FRichEditOleCallback) or (Win32MajorVersion < 5) then
    Perform(WM_CONTEXTMENU, Handle, LParam(PointToSmallPoint(
      ClientToScreen(SmallPointToPoint(TWMMouse(Message).Pos)))));
}
end;

procedure THppRichedit.WMSetFocus(var Message: TWMSetFocus);
begin
  SetAutoKeyboard(False);
  inherited;
end;

procedure THppRichedit.WMLangChange(var Message: TMessage);
begin
  SetAutoKeyboard(False);
  Message.Result:=1;
end;

procedure THppRichedit.WMCopy(var Message: TWMCopy);
var
  Text: String;
begin
  inherited;
  // do not empty clip to not to loose rtf data
  //EmptyClipboard();
  Text := GetRichString(Handle,True);
  CopyToClip(Text,Handle,FCodepage,False);
end;

procedure THppRichedit.WMKeyDown(var Message: TWMKey);
begin
  if (KeyDataToShiftState(Message.KeyData) = [ssCtrl]) then
    case Message.CharCode of
      Ord('E'), Ord('J'):
        Message.Result := 1;
      Ord('C'), VK_INSERT:
        begin
          PostMessage(Handle, WM_COPY, 0, 0);
          Message.Result := 1;
        end;
    end;
  if Message.Result = 1 then
    exit;
  inherited;
end;
