unit my_IDObject;

interface

uses
  Windows, ActiveX;

type
  TImageDataObject = class(TInterfacedObject,IDataObject)
  private
    FBmp:hBitmap;
    FMedium:TStgMedium;
    FFormatEtc: TFormatEtc;
    procedure SetBitmap(bmp:hBitmap);
    function GetOleObject(OleClientSite:IOleClientSite; Storage:IStorage):IOleObject;
    // IDataObject
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc: IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint; const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  public
    destructor Destroy; override;
    function InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
  end;

function RichEdit_InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;


implementation

uses
  RichEdit;

const
  IID_IOleObject: TGUID = '{00000112-0000-0000-C000-000000000046}';

type
  TReObject = packed record
    cbStruct: DWORD;          // Size of structure
    cp      : Integer;        // Character position of object
    clsid   : TCLSID;         // Class ID of object
    poleobj : IOleObject;     // OLE object interface
    pstg    : IStorage;       // Associated storage interface
    polesite: IOLEClientSite; // Associated client site interface
    sizel   : TSize;          // Size of object (may be 0,0)
    dvaspect: DWORD;          // Display aspect to use
    dwFlags : DWORD;          // Object status flags
    dwUser  : DWORD;          // Dword for user's use
  end;

type
  IRichEditOle = interface(IUnknown)
    ['{00020d00-0000-0000-c000-000000000046}']
    function GetClientSite(out clientSite: IOleClientSite): HResult; stdcall;
    function GetObjectCount: HResult; stdcall;
    function GetLinkCount: HResult; stdcall;
    function GetObject(iob: Longint; out ReObject: TReObject; dwFlags: DWORD): HResult; stdcall;
    function InsertObject(var ReObject: TReObject): HResult; stdcall;
    function ConvertObject(iob: Longint; rclsidNew: TIID; lpstrUserTypeNew: LPCSTR): HResult; stdcall;
    function ActivateAs(rclsid: TIID; rclsidAs: TIID): HResult; stdcall;
    function SetHostNames(lpstrContainerApp: LPCSTR; lpstrContainerObj: LPCSTR): HResult; stdcall;
    function SetLinkAvailable(iob: Longint; fAvailable: BOOL): HResult; stdcall;
    function SetDvaspect(iob: Longint; dvaspect: DWORD): HResult; stdcall;
    function HandsOffStorage(iob: Longint): HResult; stdcall;
    function SaveCompleted(iob: Longint; const stg: IStorage): HResult; stdcall;
    function InPlaceDeactivate: HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetClipboardData(var chrg: TCharRange; reco: DWORD; out dataobj: IDataObject): HResult; stdcall;
    function ImportDataObject(dataobj: IDataObject; cf: TClipFormat; hMetaPict: HGLOBAL): HResult; stdcall;
  end;

procedure ReleaseObject(var Obj);
begin
  if IUnknown(Obj) <> nil then IUnknown(Obj) := nil;
end;

procedure CreateStorage(var Storage: IStorage);
var
  LockBytes: ILockBytes;
begin
  {OleCheck}(CreateILockBytesOnHGlobal(0, True, LockBytes));
  try
    {OleCheck}(StgCreateDocfileOnILockBytes(LockBytes,
      STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, Storage));
  finally
    ReleaseObject(LockBytes);
  end;
end;

function RichEdit_GetOleInterface(Wnd: HWND; out Intf: IRichEditOle): Boolean;
begin
  Result := SendMessage(Wnd, EM_GETOLEINTERFACE, 0, LPARAM(@Intf)) <> 0;
end;

function TImageDataObject.DAdvise(const formatetc: TFormatEtc; advf: Integer; const advSink: IAdviseSink; out dwConnection: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.DUnadvise(dwConnection: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.EnumFormatEtc(dwDirection: Integer; out enumFormatEtc: IEnumFormatEtc): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult;
begin
  Result := E_NOTIMPL;
end;

function TImageDataObject.QueryGetData(const formatetc: TFormatEtc): HResult;
begin
  Result := E_NOTIMPL;
end;

destructor TImageDataObject.Destroy;
begin
  ReleaseStgMedium(FMedium);
end;

function TImageDataObject.GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult;
begin
  medium.tymed := TYMED_GDI;
  medium.hBitmap :=  FMedium.hBitmap;
  medium.unkForRelease := nil;
  Result:=S_OK;
end;

function TImageDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult;
begin
  FFormatEtc := formatetc;
  FMedium := medium;
  Result:= S_OK;
end;

procedure TImageDataObject.SetBitmap(bmp: hBitmap);
var
  stgm: TStgMedium;
  fm: TFormatEtc;
begin
  stgm.tymed         := TYMED_GDI;
  stgm.hBitmap       := bmp;
  stgm.UnkForRelease := nil;
  fm.cfFormat := CF_BITMAP;
  fm.ptd      := nil;
  fm.dwAspect := DVASPECT_CONTENT;
  fm.lindex   := -1;
  fm.tymed    := TYMED_GDI;
  SetData(fm, stgm, FALSE);
end;

function TImageDataObject.GetOleObject(OleClientSite: IOleClientSite; Storage: IStorage):IOleObject;
begin
  if (FMedium.hBitmap = 0) then
    Result := nil
  else
    OleCreateStaticFromData(Self, IID_IOleObject, OLERENDER_FORMAT, @FFormatEtc, OleClientSite,
      Storage, Result);
end;

function TImageDataObject.InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
var
  RichEditOLE: IRichEditOLE;
  OleClientSite: IOleClientSite;
  Storage: IStorage;
  OleObject: IOleObject;
  ReObject: TReObject;
  clsid: TGUID;
begin
  Result := false;
  if Bitmap = 0 then
    exit;
  if not RichEdit_GetOleInterface(Wnd, RichEditOle) then
    exit;
  FBmp := CopyImage(Bitmap, IMAGE_BITMAP, 0, 0, 0);
  try
    SetBitmap(FBmp);
    RichEditOle.GetClientSite(OleClientSite);
    Storage := nil;
    try
      CreateStorage(Storage);
      if not(Assigned(OleClientSite) and Assigned(Storage)) then
        exit;
      try
        OleObject := GetOleObject(OleClientSite, Storage);
        if OleObject = nil then
          exit;
        OleSetContainedObject(OleObject, True);
        OleObject.GetUserClassID(clsid);
        ZeroMemory(@ReObject, SizeOf(ReObject));
        ReObject.cbStruct := SizeOf(ReObject);
        ReObject.clsid    := clsid;
        ReObject.cp       := cp;
        ReObject.dvaspect := DVASPECT_CONTENT;
        ReObject.poleobj  := OleObject;
        ReObject.polesite := OleClientSite;
        ReObject.pstg := Storage;
        Result := (RichEditOle.InsertObject(ReObject) = NOERROR);
      finally
        ReleaseObject(OleObject);
      end;
    finally
      ReleaseObject(OleClientSite);
      ReleaseObject(Storage);
    end;
  finally
    DeleteObject(FBmp);
    ReleaseObject(RichEditOLE);
  end;
end;

function RichEdit_InsertBitmap(Wnd: HWND; Bitmap: hBitmap; cp: Cardinal): Boolean;
begin
  with TImageDataObject.Create do
    try
      Result := InsertBitmap(Wnd,Bitmap,cp);
    finally
      Free;
    end
end;

end.
