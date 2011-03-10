
{*******************************************************}
{                                                       }
{       CodeGear Delphi Runtime Library                 }
{       URL Moniker support interface unit              }
{                                                       }
{       Copyright (C) 1995-1998, Microsoft Corporation. }
{       All Rights Reserved.                            }
{                                                       }
{       Obtained on behalf of Borland through:          }
{       Joint Endeavour of Delphi Innovators (JEDI)     }
{       http://www.delphi-jedi.org                      }
{       Translator: Rudolph Velthuis                    }
{                                                       }
{*******************************************************}

unit UrlMon;

interface

uses
  Windows, ActiveX;

const
  SZ_URLCONTEXT: POLEStr   = 'URL Context';
  SZ_ASYNC_CALLEE: POLEStr = 'AsyncCallee';

  MKSYS_URLMONIKER = 6;

const
  // GUIDs for interfaces declared in this unit

  IID_IPersistMoniker:       TGUID = '{79eac9c9-baf9-11ce-8c82-00aa004ba90b}';
  IID_IBinding:              TGUID = '{79eac9c0-baf9-11ce-8c82-00aa004ba90b}';
  IID_IBindStatusCallback:   TGUID = '{79eac9c1-baf9-11ce-8c82-00aa004ba90b}';
  IID_IAuthenticate:         TGUID = '{79eac9d0-baf9-11ce-8c82-00aa004ba90b}';
  IID_IHttpNegotiate:        TGUID = '{79eac9d2-baf9-11ce-8c82-00aa004ba90b}';
  IID_IWindowForBindingUI:   TGUID = '{79eac9d5-bafa-11ce-8c82-00aa004ba90b}';
  IID_ICodeInstall:          TGUID = '{79eac9d1-baf9-11ce-8c82-00aa004ba90b}';
  IID_IWinInetInfo:          TGUID = '{79eac9d6-bafa-11ce-8c82-00aa004ba90b}';
  IID_IHttpSecurity:         TGUID = '{79eac9d7-bafa-11ce-8c82-00aa004ba90b}';
  IID_IWinInetHttpInfo:      TGUID = '{79eac9d8-bafa-11ce-8c82-00aa004ba90b}';

  IID_IBindHost:             TGUID = '{fc4801a1-2ba9-11cf-a229-00aa003d7352}';

  IID_IInternet:             TGUID = '{79eac9e0-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetBindInfo:     TGUID = '{79eac9e1-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetProtocolRoot: TGUID = '{79eac9e3-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetProtocol:     TGUID = '{79eac9e4-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetProtocolSink: TGUID = '{79eac9e5-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetSession:      TGUID = '{79eac9e7-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetThreadSwitch: TGUID = '{79eac9e8-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetPriority:     TGUID = '{79eac9eb-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetProtocolInfo: TGUID = '{79eac9ec-baf9-11ce-8c82-00aa004ba90b}';

  SID_IBindHost:             TGUID = '{fc4801a1-2ba9-11cf-a229-00aa003d7352}';
  SID_SBindHost:             TGUID = '{fc4801a1-2ba9-11cf-a229-00aa003d7352}';

  IID_IOInet:                TGUID = '{79eac9e0-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetBindInfo:        TGUID = '{79eac9e1-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetProtocolRoot:    TGUID = '{79eac9e3-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetProtocol:        TGUID = '{79eac9e4-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetProtocolSink:    TGUID = '{79eac9e5-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetProtocolInfo:    TGUID = '{79eac9ec-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetSession:         TGUID = '{79eac9e7-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetPriority:        TGUID = '{79eac9eb-baf9-11ce-8c82-00aa004ba90b}';
  IID_IOInetThreadSwitch:    TGUID = '{79eac9e8-baf9-11ce-8c82-00aa004ba90b}';

  IID_IInternetSecurityMgrSite:     TGUID = '{79eac9ed-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetSecurityManager:     TGUID = '{79eac9ee-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetSecurityManagerEx:   TGUID = '{F164EDF1-CC7C-4f0d-9A94-34222625C393}';
  IID_IInternetHostSecurityManager: TGUID = '{3af280b6-cb3f-11d0-891e-00c04fb6bfc4}';

  // This service is used for delegation support on the Security Manager interface
  SID_IInternetSecurityManager:     TGUID = '{79eac9ee-baf9-11ce-8c82-00aa004ba90b}';
  SID_IInternetSecurityManagerEx:   TGUID = '{F164EDF1-CC7C-4f0d-9A94-34222625C393}';
  SID_IInternetHostSecurityManager: TGUID = '{3af280b6-cb3f-11d0-891e-00c04fb6bfc4}';

  IID_IInternetZoneManager:   TGUID = '{79eac9ef-baf9-11ce-8c82-00aa004ba90b}';
  IID_IInternetZoneManagerEx: TGUID = '{A4C23339-8E06-431e-9BF4-7E711C085648}';

  IID_ISoftDistExt:           TGUID = '{B15B8DC1-C7E1-11d0-8680-00AA00BDCB71}';
  IID_IDataFilter:            TGUID = '{69d14c80-c18e-11d0-a9ce-006097942311}';
  IID_IEncodingFilterFactory: TGUID = '{70bdde00-c18e-11d0-a9ce-006097942311}';

// Originally (in the .h) these were enumeration types
type
  TBindVerb = ULONG;
  TBindInfoF = ULONG;
  TBindF = ULONG;
  TBSCF = ULONG;
  TBindStatus = ULONG;
  TCIPStatus = ULONG;
  TBindString = ULONG;
  TPiFlags = ULONG;
  TOIBdgFlags = ULONG;
  TParseAction = ULONG;
  TPSUAction = ULONG;
  TQueryOption = ULONG;
  TPUAF = ULONG;
  TSZMFlags = ULONG;
  TUrlZone = ULONG;
  TUrlTemplate = ULONG;
  TZAFlags = ULONG;
  TUrlZoneReg = ULONG;

const
  // URLMON-specific defines for UrlMkSetSessionOption
  URLMON_OPTION_USERAGENT         = $10000001;
  URLMON_OPTION_USERAGENT_REFRESH = $10000002;
  URLMON_OPTION_URL_ENCODING      = $10000004;
  URLMON_OPTION_USE_BINDSTRINGCREDS = $10000008;

  CF_NULL = 0;

  CFSTR_MIME_NULL        = 0;
  CFSTR_MIME_TEXT        = 'text/plain';
  CFSTR_MIME_RICHTEXT    = 'text/richtext';
  CFSTR_MIME_X_BITMAP    = 'image/x-xbitmap';
  CFSTR_MIME_POSTSCRIPT  = 'application/postscript';
  CFSTR_MIME_AIFF        = 'audio/aiff';
  CFSTR_MIME_BASICAUDIO  = 'audio/basic';
  CFSTR_MIME_WAV         = 'audio/wav';
  CFSTR_MIME_X_WAV       = 'audio/x-wav';
  CFSTR_MIME_GIF         = 'image/gif';
  CFSTR_MIME_PJPEG       = 'image/pjpeg';
  CFSTR_MIME_JPEG        = 'image/jpeg';
  CFSTR_MIME_TIFF        = 'image/tiff';
  CFSTR_MIME_X_PNG       = 'image/x-png';
  CFSTR_MIME_BMP         = 'image/bmp';
  CFSTR_MIME_X_ART       = 'image/x-jg';
  CFSTR_MIME_X_EMF       = 'image/x-emf';
  CFSTR_MIME_X_WMF       = 'image/x-wmf';
  CFSTR_MIME_AVI         = 'video/avi';
  CFSTR_MIME_MPEG        = 'video/mpeg';
  CFSTR_MIME_FRACTALS    = 'application/fractals';
  CFSTR_MIME_RAWDATA     = 'application/octet-stream';
  CFSTR_MIME_RAWDATASTRM = 'application/octet-stream';
  CFSTR_MIME_PDF         = 'application/pdf';
  CFSTR_MIME_X_AIFF      = 'audio/x-aiff';
  CFSTR_MIME_X_REALAUDIO = 'audio/x-pn-realaudio';
  CFSTR_MIME_XBM         = 'image/xbm';
  CFSTR_MIME_QUICKTIME   = 'video/quicktime';
  CFSTR_MIME_X_MSVIDEO   = 'video/x-msvideo';
  CFSTR_MIME_X_SGI_MOVIE = 'video/x-sgi-movie';
  CFSTR_MIME_HTML        = 'text/html';

// MessageId: MK_S_ASYNCHRONOUS
// MessageText: Operation is successful, but will complete asynchronously.

  MK_S_ASYNCHRONOUS = $000401E8;
  S_ASYNCHRONOUS    = MK_S_ASYNCHRONOUS;

  E_PENDING = $8000000A;

// WinINet and protocol specific errors are mapped to one of the following
// error which are returned in IBSC.OnStopBinding
//
// Note: FACILITY C is split into ranges of 1k
// C0000 - C03FF  INET_E_ (URLMON's original hresult)
// C0400 - C07FF  INET_E_CLIENT_xxx
// C0800 - C0BFF  INET_E_SERVER_xxx
// C0C00 - C0FFF  INET_E_????
// C1000 - C13FF  INET_E_AGENT_xxx (info delivery agents)

// $$$ Original Borland translation:
// INET_E_INVALID_URL: HResult = $800C0002;
// This is not a direct copy of the .h

const
  INET_E_INVALID_URL                 = HResult($800C0002);
  INET_E_NO_SESSION                  = HResult($800C0003);
  INET_E_CANNOT_CONNECT              = HResult($800C0004);
  INET_E_RESOURCE_NOT_FOUND          = HResult($800C0005);
  INET_E_OBJECT_NOT_FOUND            = HResult($800C0006);
  INET_E_DATA_NOT_AVAILABLE          = HResult($800C0007);
  INET_E_DOWNLOAD_FAILURE            = HResult($800C0008);
  INET_E_AUTHENTICATION_REQUIRED     = HResult($800C0009);
  INET_E_NO_VALID_MEDIA              = HResult($800C000A);
  INET_E_CONNECTION_TIMEOUT          = HResult($800C000B);
  INET_E_INVALID_REQUEST             = HResult($800C000C);
  INET_E_UNKNOWN_PROTOCOL            = HResult($800C000D);
  INET_E_SECURITY_PROBLEM            = HResult($800C000E);
  INET_E_CANNOT_LOAD_DATA            = HResult($800C000F);
  INET_E_CANNOT_INSTANTIATE_OBJECT   = HResult($800C0010);
  INET_E_REDIRECT_FAILED             = HResult($800C0014);
  INET_E_REDIRECT_TO_DIR             = HResult($800C0015);
  INET_E_CANNOT_LOCK_REQUEST         = HResult($800C0016);
  INET_E_USE_EXTEND_BINDING          = HResult($800C0017);
  INET_E_TERMINATED_BIND             = HResult($800C0018);
  INET_E_CODE_DOWNLOAD_DECLINED      = HResult($800C0100);
  INET_E_RESULT_DISPATCHED           = HResult($800C0200);
  INET_E_CANNOT_REPLACE_SFP_FILE     = HResult($800C0300);
  INET_E_CODE_INSTALL_SUPPRESSED     = HResult($800C0400);
  INET_E_ERROR_FIRST                 = HResult($800C0002);
  INET_E_ERROR_LAST                  = INET_E_CODE_INSTALL_SUPPRESSED;


type
  IBinding = interface; // forward

  IPersistMoniker = interface
    ['{79eac9c9-baf9-11ce-8c82-00aa004ba90b}']
    function GetClassID(out ClassID: TCLSID): HResult; stdcall;
    function IsDirty: HResult; stdcall;
    function Load(fFullyAvailable: BOOL; pimkName: IMoniker; pibc: IBindCtx;
      grfMode: DWORD): HResult; stdcall;
    function Save(pimkName: IMoniker; pbc: IBindCtx; fRemember: BOOL): HResult; stdcall;
    function SaveCompleted(pimkName: IMoniker; pibc: IBindCtx): HResult; stdcall;
    function GetCurMoniker(ppimkName: IMoniker): HResult; stdcall;
   end;

  IBindProtocol = interface
    ['{79eac9cd-baf9-11ce-8c82-00aa004ba90b}']
    function CreateBinding(szUrl: LPCWSTR; pbc: IBindCtx;
      out ppb: IBinding): HResult; stdcall;
  end;

  IBinding = interface
    ['{79eac9c0-baf9-11ce-8c82-00aa004ba90b}']
    function Abort: HResult; stdcall;
    function Suspend: HResult; stdcall;
    function Resume: HResult; stdcall;
    function SetPriority(nPriority: Longint): HResult; stdcall;
    function GetPriority(out nPriority: Longint): HResult; stdcall;
    function GetBindResult(out clsidProtocol: TCLSID; out dwResult: DWORD;
      out szResult: POLEStr; dwReserved: DWORD): HResult; stdcall;
  end;

const
  BINDVERB_GET    = $00000000;
  BINDVERB_POST   = $00000001;
  BINDVERB_PUT    = $00000002;
  BINDVERB_CUSTOM = $00000003;

  BINDINFOF_URLENCODESTGMEDDATA  = $00000001;
  BINDINFOF_URLENCODEDEXTRAINFO  = $00000002;

  BINDF_ASYNCHRONOUS             = $00000001;
  BINDF_ASYNCSTORAGE             = $00000002;
  BINDF_NOPROGRESSIVERENDERING   = $00000004;
  BINDF_OFFLINEOPERATION         = $00000008;
  BINDF_GETNEWESTVERSION         = $00000010;
  BINDF_NOWRITECACHE             = $00000020;
  BINDF_NEEDFILE                 = $00000040;
  BINDF_PULLDATA                 = $00000080;
  BINDF_IGNORESECURITYPROBLEM    = $00000100;
  BINDF_RESYNCHRONIZE            = $00000200;
  BINDF_HYPERLINK                = $00000400;
  BINDF_NO_UI                    = $00000800;
  BINDF_SILENTOPERATION          = $00001000;
  BINDF_PRAGMA_NO_CACHE          = $00002000;
  BINDF_FREE_THREADED            = $00010000;
  BINDF_DIRECT_READ              = $00020000;
  BINDF_FORMS_SUBMIT             = $00040000;
  BINDF_GETFROMCACHE_IF_NET_FAIL = $00080000;
  
  // These are for backwards compatibility with previous URLMON versions 
  BINDF_DONTUSECACHE             = BINDF_GETNEWESTVERSION;
  BINDF_DONTPUTINCACHE           = BINDF_NOWRITECACHE;
  BINDF_NOCOPYDATA               = BINDF_PULLDATA;

  BSCF_FIRSTDATANOTIFICATION        = $00000001;
  BSCF_INTERMEDIATEDATANOTIFICATION = $00000002;
  BSCF_LASTDATANOTIFICATION         = $00000004;
  BSCF_DATAFULLYAVAILABLE           = $00000008;
  BSCF_AVAILABLEDATASIZEUNKNOWN     = $00000010;

  BINDSTATUS_FINDINGRESOURCE           = 1;
  BINDSTATUS_CONNECTING                = BINDSTATUS_FINDINGRESOURCE + 1;
  BINDSTATUS_REDIRECTING               = BINDSTATUS_CONNECTING + 1;
  BINDSTATUS_BEGINDOWNLOADDATA         = BINDSTATUS_REDIRECTING + 1;
  BINDSTATUS_DOWNLOADINGDATA           = BINDSTATUS_BEGINDOWNLOADDATA + 1;
  BINDSTATUS_ENDDOWNLOADDATA           = BINDSTATUS_DOWNLOADINGDATA + 1;
  BINDSTATUS_BEGINDOWNLOADCOMPONENTS   = BINDSTATUS_ENDDOWNLOADDATA + 1;
  BINDSTATUS_INSTALLINGCOMPONENTS      = BINDSTATUS_BEGINDOWNLOADCOMPONENTS + 1;
  BINDSTATUS_ENDDOWNLOADCOMPONENTS     = BINDSTATUS_INSTALLINGCOMPONENTS + 1;
  BINDSTATUS_USINGCACHEDCOPY           = BINDSTATUS_ENDDOWNLOADCOMPONENTS + 1;
  BINDSTATUS_SENDINGREQUEST            = BINDSTATUS_USINGCACHEDCOPY + 1;
  BINDSTATUS_CLASSIDAVAILABLE          = BINDSTATUS_SENDINGREQUEST + 1;
  BINDSTATUS_MIMETYPEAVAILABLE         = BINDSTATUS_CLASSIDAVAILABLE + 1;
  BINDSTATUS_CACHEFILENAMEAVAILABLE    = BINDSTATUS_MIMETYPEAVAILABLE + 1;
  BINDSTATUS_BEGINSYNCOPERATION        = BINDSTATUS_CACHEFILENAMEAVAILABLE + 1;
  BINDSTATUS_ENDSYNCOPERATION          = BINDSTATUS_BEGINSYNCOPERATION + 1;
  BINDSTATUS_BEGINUPLOADDATA           = BINDSTATUS_ENDSYNCOPERATION + 1;
  BINDSTATUS_UPLOADINGDATA             = BINDSTATUS_BEGINUPLOADDATA + 1;
  BINDSTATUS_ENDUPLOADDATA             = BINDSTATUS_UPLOADINGDATA + 1;
  BINDSTATUS_PROTOCOLCLASSID           = BINDSTATUS_ENDUPLOADDATA + 1;
  BINDSTATUS_ENCODING                  = BINDSTATUS_PROTOCOLCLASSID + 1;
  BINDSTATUS_VERIFIEDMIMETYPEAVAILABLE = BINDSTATUS_ENCODING + 1;
  BINDSTATUS_CLASSINSTALLLOCATION      = BINDSTATUS_VERIFIEDMIMETYPEAVAILABLE + 1;
  BINDSTATUS_DECODING                  = BINDSTATUS_CLASSINSTALLLOCATION + 1;
  BINDSTATUS_LOADINGMIMEHANDLER        = BINDSTATUS_DECODING + 1;
  BINDSTATUS_CONTENTDISPOSITIONATTACH = BINDSTATUS_LOADINGMIMEHANDLER + 1;
  BINDSTATUS_FILTERREPORTMIMETYPE = BINDSTATUS_CONTENTDISPOSITIONATTACH + 1;
  BINDSTATUS_CLSIDCANINSTANTIATE = BINDSTATUS_FILTERREPORTMIMETYPE + 1;
  BINDSTATUS_IUNKNOWNAVAILABLE = BINDSTATUS_CLSIDCANINSTANTIATE + 1;
  BINDSTATUS_DIRECTBIND = BINDSTATUS_IUNKNOWNAVAILABLE + 1;
  BINDSTATUS_RAWMIMETYPE = BINDSTATUS_DIRECTBIND + 1;
  BINDSTATUS_PROXYDETECTING = BINDSTATUS_RAWMIMETYPE + 1;
  BINDSTATUS_ACCEPTRANGES = BINDSTATUS_PROXYDETECTING + 1;
  BINDSTATUS_COOKIE_SENT = BINDSTATUS_ACCEPTRANGES + 1;
  BINDSTATUS_COMPACT_POLICY_RECEIVED      = BINDSTATUS_COOKIE_SENT + 1;
  BINDSTATUS_COOKIE_SUPPRESSED = BINDSTATUS_COMPACT_POLICY_RECEIVED + 1;
  BINDSTATUS_COOKIE_STATE_UNKNOWN = BINDSTATUS_COOKIE_SUPPRESSED + 1;
  BINDSTATUS_COOKIE_STATE_ACCEPT = BINDSTATUS_COOKIE_STATE_UNKNOWN + 1;
  BINDSTATUS_COOKIE_STATE_REJECT = BINDSTATUS_COOKIE_STATE_ACCEPT + 1;
  BINDSTATUS_COOKIE_STATE_PROMPT = BINDSTATUS_COOKIE_STATE_REJECT + 1;
  BINDSTATUS_COOKIE_STATE_LEASH = BINDSTATUS_COOKIE_STATE_PROMPT + 1;
  BINDSTATUS_COOKIE_STATE_DOWNGRADE = BINDSTATUS_COOKIE_STATE_LEASH + 1;
  BINDSTATUS_POLICY_HREF = BINDSTATUS_COOKIE_STATE_DOWNGRADE + 1;
  BINDSTATUS_P3P_HEADER = BINDSTATUS_POLICY_HREF + 1;
  BINDSTATUS_SESSION_COOKIE_RECEIVED = BINDSTATUS_P3P_HEADER + 1;
  BINDSTATUS_PERSISTENT_COOKIE_RECEIVED = BINDSTATUS_SESSION_COOKIE_RECEIVED + 1;
  BINDSTATUS_SESSION_COOKIES_ALLOWED = BINDSTATUS_PERSISTENT_COOKIE_RECEIVED + 1;
  BINDSTATUS_CACHECONTROL = BINDSTATUS_SESSION_COOKIES_ALLOWED + 1;
  BINDSTATUS_CONTENTDISPOSITIONFILENAME = BINDSTATUS_CACHECONTROL + 1;
  BINDSTATUS_MIMETEXTPLAINMISMATCH = BINDSTATUS_CONTENTDISPOSITIONFILENAME + 1;
  BINDSTATUS_PUBLISHERAVAILABLE = BINDSTATUS_MIMETEXTPLAINMISMATCH + 1;
  BINDSTATUS_DISPLAYNAMEAVAILABLE = BINDSTATUS_PUBLISHERAVAILABLE + 1;

type
  PBindInfo = ^TBindInfo;
  _tagBINDINFO = record
    cbSize: ULONG;
    szExtraInfo: LPWSTR;
    stgmedData: TStgMedium;
    grfBindInfoF: DWORD;
    dwBindVerb: DWORD;
    szCustomVerb: LPWSTR;
    cbstgmedData: DWORD;
    dwOptions: DWORD;
    dwOptionsFlags: DWORD;
    dwCodePage: DWORD;
    securityAttributes: TSecurityAttributes;
    iid: TGUID;
    pUnk: IUnknown;
    dwReserved: DWORD;
  end;
  TBindInfo = _tagBINDINFO;
  BINDINFO = _tagBINDINFO;

  PRemSecurityAttributes = ^TRemSecurityAttributes;
  _REMSECURITY_ATTRIBUTES = packed record
    nLength: DWORD;
    lpSecurityDescriptor: DWORD;
    bInheritHandle: BOOL;
  end;
  TRemSecurityAttributes = _REMSECURITY_ATTRIBUTES;
  REMSECURITY_ATTRIBUTES = _REMSECURITY_ATTRIBUTES;

  PRemBindInfo = ^TRemBindInfo;
  _tagRemBINDINFO = record
    cbSize: ULONG;
    szExtraInfo: LPWSTR;
    grfBindInfoF: DWORD;
    dwBindVerb: DWORD;
    szCustomVerb: LPWSTR;
    cbstgmedData: DWORD;
    dwOptions: DWORD;
    dwOptionsFlags: DWORD;
    dwCodePage: DWORD;
    securityAttributes: TRemSecurityAttributes;
    iid: TGUID;
    pUnk: IUnknown;
    dwReserved: DWORD;
  end;
  TRemBindInfo = _tagRemBINDINFO; 
  RemBINDINFO = _tagRemBINDINFO;
  
  PRemFormatEtc = ^TRemFormatEtc;
  tagRemFORMATETC = packed record
    cfFormat: DWORD;
    ptd: DWORD;
    dwAspect: DWORD;
    lindex: Longint;
    tymed: DWORD;
  end;
  TRemFormatEtc = tagRemFORMATETC;
  RemFORMATETC = tagRemFORMATETC;

  IBindStatusCallback = interface
    ['{79eac9c1-baf9-11ce-8c82-00aa004ba90b}']
    function OnStartBinding(dwReserved: DWORD; pib: IBinding): HResult; stdcall;
    function GetPriority(out nPriority): HResult; stdcall;
    function OnLowResource(reserved: DWORD): HResult; stdcall;
    function OnProgress(ulProgress, ulProgressMax, ulStatusCode: ULONG;
      szStatusText: LPCWSTR): HResult; stdcall;
    function OnStopBinding(hresult: HResult; szError: LPCWSTR): HResult; stdcall;
    function GetBindInfo(out grfBINDF: DWORD; var bindinfo: TBindInfo): HResult; stdcall;
    function OnDataAvailable(grfBSCF: DWORD; dwSize: DWORD; formatetc: PFormatEtc;
      stgmed: PStgMedium): HResult; stdcall;
    function OnObjectAvailable(const iid: TGUID; punk: IUnknown): HResult; stdcall;
  end;

  IAuthenticate = interface
    ['{79eac9d0-baf9-11ce-8c82-00aa004ba90b}']
    function Authenticate(var hwnd: HWnd; var szUserName, szPassWord: LPWSTR): HResult; stdcall;
  end;

  IHttpNegotiate = interface
    ['{79eac9d2-baf9-11ce-8c82-00aa004ba90b}']
    function BeginningTransaction(szURL, szHeaders: LPCWSTR; dwReserved: DWORD;
      out szAdditionalHeaders: LPWSTR): HResult; stdcall;
    function OnResponse(dwResponseCode: DWORD; szResponseHeaders, szRequestHeaders: LPCWSTR;
      out szAdditionalRequestHeaders: LPWSTR): HResult; stdcall;
  end;

  IWindowForBindingUI = interface
    ['{79eac9d5-bafa-11ce-8c82-00aa004ba90b}']
    function GetWindow(const guidReason: TGUID; out hwnd): HResult; stdcall;
  end;

const
  CIP_DISK_FULL                            = 0;
  CIP_ACCESS_DENIED                        = CIP_DISK_FULL + 1;
  CIP_NEWER_VERSION_EXISTS                 = CIP_ACCESS_DENIED + 1;
  CIP_OLDER_VERSION_EXISTS                 = CIP_NEWER_VERSION_EXISTS + 1;
  CIP_NAME_CONFLICT                        = CIP_OLDER_VERSION_EXISTS + 1;
  CIP_TRUST_VERIFICATION_COMPONENT_MISSING = CIP_NAME_CONFLICT + 1;
  CIP_EXE_SELF_REGISTERATION_TIMEOUT       = CIP_TRUST_VERIFICATION_COMPONENT_MISSING + 1;
  CIP_UNSAFE_TO_ABORT                      = CIP_EXE_SELF_REGISTERATION_TIMEOUT + 1;
  CIP_NEED_REBOOT                          = CIP_UNSAFE_TO_ABORT + 1;
  CIP_NEED_REBOOT_UI_PERMISSION            = CIP_NEED_REBOOT + 1;

type
  ICodeInstall = interface(IWindowForBindingUI)
    ['{79eac9d1-baf9-11ce-8c82-00aa004ba90b}']
    function OnCodeInstallProblem(ulStatusCode: ULONG; szDestination, szSource: LPCWSTR;
      dwReserved: DWORD): HResult; stdcall;
  end;

  IWinInetInfo = interface
    ['{79eac9d6-bafa-11ce-8c82-00aa004ba90b}']
    function QueryOption(dwOption: DWORD; Buffer: Pointer; var cbBuf: DWORD): HResult; stdcall;
  end;

const
  WININETINFO_OPTION_LOCK_HANDLE   = 65534;

type
  IHttpSecurity = interface(IWindowForBindingUI)
    ['{79eac9d7-bafa-11ce-8c82-00aa004ba90b}']
    function OnSecurityProblem(dwProblem: DWORD): HResult; stdcall;
  end;

  IWinInetHttpInfo = interface(IWinInetInfo)
    ['{79eac9d8-bafa-11ce-8c82-00aa004ba90b}']
    function QueryInfo(dwOption: DWORD; Buffer: Pointer;
      var cbBuf, dwFlags, dwReserved: DWORD): HResult; stdcall;
  end;

  IBindHost = interface
    ['{fc4801a1-2ba9-11cf-a229-00aa003d7352}']
    function CreateMoniker(szName: POLEStr; BC: IBindCtx; out mk: IMoniker; dwReserved: DWORD): HResult; stdcall;
    function MonikerBindToStorage(Mk: IMoniker; BC: IBindCtx; BSC: IBindStatusCallback;
      const iid: TGUID; out pvObj): HResult; stdcall;
    function MonikerBindToObject(Mk: IMoniker; BC: IBindCtx; BSC: IBindStatusCallback;
      const iid: TGUID; out pvObj): HResult; stdcall;
  end;

const
  URLOSTRM_USECACHEDCOPY_ONLY = $00000001;      // Only get from cache
  URLOSTRM_USECACHEDCOPY      = $00000002;      // Get from cache if available else download
  URLOSTRM_GETNEWESTVERSION   = $00000003;      // Get new version only. But put it in cache too


function HlinkSimpleNavigateToString(
  szTarget,                           // required - target document - null if local jump w/in doc
  szLocation,                         // optional, for navigation into middle of a doc
  szTargetFrameName: LPCWSTR;         // optional, for targeting frame-sets
  Unk: IUnknown;                      // required - we'll search this for other necessary interfaces
  pbc: IBindCtx;                      // optional. caller may register an IBSC in this
  BSC: IBindStatusCallback;
  grfHLNF,                            // flags
  dwReserved: DWORD): HResult; stdcall;

function HlinkSimpleNavigateToMoniker(
  mkTarget: Imoniker;                 // required - target document - (may be null
  szLocation,                         // optional, for navigation into middle of a doc
  szTargetFrameName: LPCWSTR;         // optional, for targeting frame-sets
  Unk: IUnknown;                      // required - we'll search this for other necessary interfaces
  bc: IBindCtx;                       // optional. caller may register an IBSC in this
  BSC: IBindStatusCallback;
  grfHLNF,                            // flags
  dwReserved: DWORD): HResult; stdcall;

function CreateURLMoniker(MkCtx: IMoniker; szURL: LPCWSTR; out mk: IMoniker): HResult; stdcall;
function GetClassURL(szURL: LPCWSTR; const ClsID: TCLSID): HResult; stdcall;
function CreateAsyncBindCtx(reserved: DWORD; pBSCb: IBindStatusCallback; pEFetc: IEnumFORMATETC;
  out ppBC: IBindCtx): HResult; stdcall;
function CreateAsyncBindCtxEx(pbc: IBindCtx; dwOptions: DWORD; BSCb: IBindStatusCallback; Enum: IEnumFORMATETC;
  out ppBC: IBindCtx; reserved: DWORD): HResult; stdcall;
function MkParseDisplayNameEx(pbc: IBindCtx; szDisplayName: LPCWSTR; out pchEaten: ULONG;
  out ppmk: IMoniker): HResult; stdcall;
function RegisterBindStatusCallback(pBC: IBindCtx; pBSCb: IBindStatusCallback;
  out ppBSCBPrev: IBindStatusCallback; dwReserved: DWORD): HResult; stdcall;
function RevokeBindStatusCallback(pBC: IBindCtx; pBSCb: IBindStatusCallback): HResult; stdcall;
function GetClassFileOrMime(pBC: IBindCtx; szFilename: LPCWSTR; pBuffer: Pointer; cbSize: DWORD;
  szMime: LPCWSTR; dwReserved: DWORD; out pclsid: TCLSID): HResult; stdcall;
function IsValidURL(pBC: IBindCtx; szURL: LPCWSTR; dwReserved: DWORD): HResult; stdcall;
function CoGetClassObjectFromURL(const rCLASSID: TCLSID; szCODE: LPCWSTR;
  dwFileVersionMS, dwFileVersionLS: DWORD; szTYPE: LPCWSTR; pBindCtx: IBindCtx; dwClsContext: DWORD;
  pvReserved: Pointer; const riid: TGUID; out ppv): HResult; stdcall;

//helper apis
function IsAsyncMoniker(pmk: IMoniker): HResult; stdcall;
function CreateURLBinding(lpszUrl: LPCWSTR; pbc: IBindCtx; out ppBdg: IBinding): HResult; stdcall;

function RegisterMediaTypes(ctypes: UINT; const rgszTypes: LPCSTR; const rgcfTypes: TClipFormat): HResult; stdcall;
function FindMediaType(rgszTypes: LPCSTR; rgcfTypes: PClipFormat): HResult; stdcall;
function CreateFormatEnumerator(cfmtetc: UINT; const rgfmtetc: TFormatEtc; out ppenumfmtetc: IEnumFormatEtc): HResult; stdcall;
function RegisterFormatEnumerator(pBC: IBindCtx; pEFetc: IEnumFormatEtc; reserved: DWORD): HResult; stdcall;
function RevokeFormatEnumerator(pBC: IBindCtx; pEFetc: IEnumFormatEtc): HResult; stdcall;
function RegisterMediaTypeClass(pBC: IBindCtx; ctypes: UINT; const rgszTypes: LPCSTR; rgclsID: PCLSID; reserved: DWORD): HResult; stdcall;
function FindMediaTypeClass(pBC: IBindCtx; szType: LPCSTR; const pclsID: TCLSID; reserved: DWORD): HResult; stdcall;
function UrlMkSetSessionOption(dwOption: DWORD; pBuffer: Pointer; dwBufferLength, dwReserved: DWORD): HResult; stdcall;
function UrlMkGetSessionOption(dwOption: DWORD; pBuffer: Pointer; dwBufferLength: DWORD; out pdwBufferLength: DWORD; dwReserved: DWORD): HResult; stdcall;
function FindMimeFromData(
    pBC: IBindCtx;                      // bind context - can be nil
    pwzUrl: LPCWSTR;                    // url - can be nil
    pBuffer: Pointer;                   // buffer with data to sniff - can be nil (pwzUrl must be valid)
    cbSize: DWORD;                      // size of buffer
    pwzMimeProposed: LPCWSTR;           // proposed mime if - can be nil
    dwMimeFlags: DWORD;                 // will be defined
    out ppwzMimeOut: LPWSTR;            // the suggested mime
    dwReserved: DWORD                   // must be 0
  ): HResult; stdcall;
function ObtainUserAgentString(dwOption: DWORD; pszUAOut: LPSTR; var cbSize: DWORD): HResult; stdcall;

function URLOpenStream(p1: IUnknown; p2: PWideChar; p3: DWORD; p4: IBindStatusCallback): HResult; stdcall;
function URLOpenStreamA(p1: IUnknown; p2: PAnsiChar; p3: DWORD; p4: IBindStatusCallback): HResult; stdcall;
function URLOpenStreamW(p1: IUnknown; p2: PWideChar; p3: DWORD; p4: IBindStatusCallback): HResult; stdcall;
function URLOpenPullStream(p1: IUnknown; p2: PWideChar; p3: DWORD; BSC: IBindStatusCallback): HResult; stdcall;
function URLOpenPullStreamA(p1: IUnknown; p2: PAnsiChar; p3: DWORD; BSC: IBindStatusCallback): HResult; stdcall;
function URLOpenPullStreamW(p1: IUnknown; p2: PWideChar; p3: DWORD; BSC: IBindStatusCallback): HResult; stdcall;
function URLDownloadToFile(Caller: IUnknown; URL: PWideChar; FileName: PWideChar; Reserved: DWORD; StatusCB: IBindStatusCallback): HResult; stdcall;
function URLDownloadToFileA(Caller: IUnknown; URL: PAnsiChar; FileName: PAnsiChar; Reserved: DWORD; StatusCB: IBindStatusCallback): HResult; stdcall;
function URLDownloadToFileW(Caller: IUnknown; URL: PWideChar; FileName: PWideChar; Reserved: DWORD; StatusCB: IBindStatusCallback): HResult; stdcall;
function URLDownloadToCacheFile(p1: IUnknown; p2: PWideChar; p3: PWideChar; p4: DWORD; p5: DWORD; p6: IBindStatusCallback): HResult; stdcall;
function URLDownloadToCacheFileA(p1: IUnknown; p2: PAnsiChar; p3: PAnsiChar; p4: DWORD; p5: DWORD; p6: IBindStatusCallback): HResult; stdcall;
function URLDownloadToCacheFileW(p1: IUnknown; p2: PWideChar; p3: PWideChar; p4: DWORD; p5: DWORD; p6: IBindStatusCallback): HResult; stdcall;
function URLOpenBlockingStream(p1: IUnknown; p2: PWideChar; out p3: IStream; p4: DWORD; p5: IBindStatusCallback): HResult; stdcall;
function URLOpenBlockingStreamA(p1: IUnknown; p2: PAnsiChar; out p3: IStream; p4: DWORD; p5: IBindStatusCallback): HResult; stdcall;
function URLOpenBlockingStreamW(p1: IUnknown; p2: PWideChar; out p3: IStream; p4: DWORD; p5: IBindStatusCallback): HResult; stdcall;

function HlinkGoBack(unk: IUnknown): HResult; stdcall;
function HlinkGoForward(unk: IUnknown): HResult; stdcall;
function HlinkNavigateString(unk: IUnknown; szTarget: LPCWSTR): HResult; stdcall;
function HlinkNavigateMoniker(Unk: IUnknown; mkTarget: IMoniker): HResult; stdcall;

type
  IInternet = interface
    ['{79eac9e0-baf9-11ce-8c82-00aa004ba90b}']
  end;

const
  BINDSTRING_HEADERS          = 1;
  BINDSTRING_ACCEPT_MIMES     = BINDSTRING_HEADERS + 1;
  BINDSTRING_EXTRA_URL        = BINDSTRING_ACCEPT_MIMES + 1;
  BINDSTRING_LANGUAGE         = BINDSTRING_EXTRA_URL + 1;
  BINDSTRING_USERNAME         = BINDSTRING_LANGUAGE + 1;
  BINDSTRING_PASSWORD         = BINDSTRING_USERNAME + 1;
  BINDSTRING_UA_PIXELS        = BINDSTRING_PASSWORD + 1;
  BINDSTRING_UA_COLOR         = BINDSTRING_UA_PIXELS + 1;
  BINDSTRING_OS               = BINDSTRING_UA_COLOR + 1;
  BINDSTRING_USER_AGENT       = BINDSTRING_OS + 1;
  BINDSTRING_ACCEPT_ENCODINGS = BINDSTRING_USER_AGENT + 1;
  BINDSTRING_POST_COOKIE      = BINDSTRING_ACCEPT_ENCODINGS + 1;
  BINDSTRING_POST_DATA_MIME   = BINDSTRING_POST_COOKIE + 1;
  BINDSTRING_URL              = BINDSTRING_POST_DATA_MIME + 1;

type
  {$NODEFINE POLEStrArray}
  POLEStrArray = ^TOLESTRArray;
  {$NODEFINE TOLEStrArray}
  TOLEStrArray = array[0..MaxLongint div SizeOf(POLEStr) - 1] of POLEStr;

  IInternetBindInfo = interface
    ['{79eac9e1-baf9-11ce-8c82-00aa004ba90b}']
    function GetBindInfo(out grfBINDF: DWORD; var bindinfo: TBindInfo): HResult; stdcall;
    function GetBindString(ulStringType: ULONG; wzStr: POLEStrArray; cEl: ULONG;
      var cElFetched: ULONG): HResult; stdcall;
  end;

const
  PI_PARSE_URL                = $00000001;
  PI_FILTER_MODE              = $00000002;
  PI_FORCE_ASYNC              = $00000004;
  PI_USE_WORKERTHREAD         = $00000008;
  PI_MIMEVERIFICATION         = $00000010;
  PI_CLSIDLOOKUP              = $00000020;
  PI_DATAPROGRESS             = $00000040;
  PI_SYNCHRONOUS              = $00000080;
  PI_APARTMENTTHREADED        = $00000100;
  PI_CLASSINSTALL             = $00000200;
  PD_FORCE_SWITCH             = $00010000;

  PI_DOCFILECLSIDLOOKUP       = PI_CLSIDLOOKUP;

type
  PProtocolData = ^TProtocolData;
  _tagPROTOCOLDATA = packed record
    grfFlags: DWORD;
    dwState: DWORD;
    pData: Pointer;
    cbData: ULONG;
  end;
  TProtocolData = _tagPROTOCOLDATA;
  PROTOCOLDATA = _tagPROTOCOLDATA;

  IInternetProtocolSink = interface; // forward

  IInternetProtocolRoot = interface
    ['{79eac9e3-baf9-11ce-8c82-00aa004ba90b}']
    function Start(szUrl: LPCWSTR; OIProtSink: IInternetProtocolSink;
      OIBindInfo: IInternetBindInfo; grfPI, dwReserved: DWORD): HResult; stdcall;
    function Continue(const ProtocolData: TProtocolData): HResult; stdcall;
    function Abort(hrReason: HResult; dwOptions: DWORD): HResult; stdcall;
    function Terminate(dwOptions: DWORD): HResult; stdcall;
    function Suspend: HResult; stdcall;
    function Resume: HResult; stdcall;
  end;

  IInternetProtocol = interface(IInternetProtocolRoot)
    ['{79eac9e4-baf9-11ce-8c82-00aa004ba90b}']
    function Read(pv: Pointer; cb: ULONG; out cbRead: ULONG): HResult; stdcall;
    function Seek(dlibMove: LARGE_INTEGER; dwOrigin: DWORD; out libNewPosition: ULARGE_INTEGER): HResult; stdcall;
    function LockRequest(dwOptions: DWORD): HResult; stdcall;
    function UnlockRequest: HResult; stdcall;
  end;

  IInternetProtocolSink = interface
    ['{79eac9e5-baf9-11ce-8c82-00aa004ba90b}']
    function Switch(const ProtocolData: TProtocolData): HResult; stdcall;
    function ReportProgress(ulStatusCode: ULONG; szStatusText: LPCWSTR): HResult; stdcall;
    function ReportData(grfBSCF: DWORD; ulProgress, ulProgressMax: ULONG): HResult; stdcall;
    function ReportResult(hrResult: HResult; dwError: DWORD; szResult: LPCWSTR): HResult; stdcall;
  end;

const
  OIBDG_APARTMENTTHREADED     = $00000100;

type
  {$NODEFINE TLPCWSTRArray}
  TLPCWSTRArray = array[0..MaxLongInt div SizeOf(LPCWSTR) - 1] of LPCWSTR;
  {$NODEFINE PLPCWSTRArray}
  PLPCWSTRArray = ^TLPCWSTRArray;

  IInternetSession = interface
    ['{79eac9e7-baf9-11ce-8c82-00aa004ba90b}']
    function RegisterNameSpace(CF: IClassFactory; const clsid: TCLSID; pwzProtocol: LPCWSTR;
      cPatterns: ULONG; const pwzPatterns: PLPCWSTRArray; dwReserved: DWORD): HResult; stdcall;
    function UnregisterNameSpace(CF: IClassFactory; pszProtocol: LPCWSTR): HResult; stdcall;
    function RegisterMimeFilter(CF: IClassFactory; const rclsid: TCLSID;
      pwzType: LPCWSTR): HResult; stdcall;
    function UnregisterMimeFilter(CF: IClassFactory; pwzType: LPCWSTR): HResult; stdcall;
    function CreateBinding(BC: IBindCtx; szUrl: LPCWSTR; UnkOuter: IUnknown; out Unk: IUnknown;
      out OINetProt: IInternetProtocol; dwOption: DWORD): HResult; stdcall;
    function SetSessionOption(dwOption: DWORD; pBuffer: Pointer; dwBufferLength: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function GetSessionOption(dwOption: DWORD; pBuffer: Pointer; var dwBufferLength: DWORD;
      dwReserved: DWORD): HResult; stdcall;
  end;

  IInternetThreadSwitch = interface
    ['{79eac9e8-baf9-11ce-8c82-00aa004ba90b}']
    function Prepare: HResult; stdcall;
    function Continue: HResult; stdcall;
  end;

  IInternetPriority = interface
    ['{79eac9eb-baf9-11ce-8c82-00aa004ba90b}']
    function SetPriority(nPriority: Longint): HResult; stdcall;
    function GetPriority(out nPriority: Longint): HResult; stdcall;
  end;

const
  PARSE_CANONICALIZE    = 1;
  PARSE_FRIENDLY        = PARSE_CANONICALIZE + 1;
  PARSE_SECURITY_URL    = PARSE_FRIENDLY + 1;
  PARSE_ROOTDOCUMENT    = PARSE_SECURITY_URL + 1;
  PARSE_DOCUMENT        = PARSE_ROOTDOCUMENT + 1;
  PARSE_ANCHOR          = PARSE_DOCUMENT + 1;
  PARSE_ENCODE          = PARSE_ANCHOR + 1;
  PARSE_DECODE          = PARSE_ENCODE + 1;
  PARSE_PATH_FROM_URL   = PARSE_DECODE + 1;
  PARSE_URL_FROM_PATH   = PARSE_PATH_FROM_URL + 1;
  PARSE_MIME            = PARSE_URL_FROM_PATH + 1;
  PARSE_SERVER          = PARSE_MIME + 1;
  PARSE_SCHEMA          = PARSE_SERVER + 1;
  PARSE_SITE            = PARSE_SCHEMA + 1;
  PARSE_DOMAIN          = PARSE_SITE + 1;
  PARSE_LOCATION        = PARSE_DOMAIN + 1;
  PARSE_SECURITY_DOMAIN = PARSE_LOCATION + 1;

  PSU_DEFAULT           = 1;
  PSU_SECURITY_URL_ONLY = PSU_DEFAULT + 1;

  QUERY_EXPIRATION_DATE     = 1;
  QUERY_TIME_OF_LAST_CHANGE = QUERY_EXPIRATION_DATE + 1;
  QUERY_CONTENT_ENCODING    = QUERY_TIME_OF_LAST_CHANGE + 1;
  QUERY_CONTENT_TYPE        = QUERY_CONTENT_ENCODING + 1;
  QUERY_REFRESH             = QUERY_CONTENT_TYPE + 1;
  QUERY_RECOMBINE           = QUERY_REFRESH + 1;
  QUERY_CAN_NAVIGATE        = QUERY_RECOMBINE + 1;
  QUERY_USES_NETWORK        = QUERY_CAN_NAVIGATE + 1;
  QUERY_IS_CACHED           = QUERY_USES_NETWORK + 1;
  QUERY_IS_INSTALLEDENTRY   = QUERY_IS_CACHED + 1;
  QUERY_IS_CACHED_OR_MAPPED = QUERY_IS_INSTALLEDENTRY + 1;
  QUERY_USES_CACHE          = QUERY_IS_CACHED_OR_MAPPED + 1;
  QUERY_IS_SECURE = QUERY_USES_CACHE + 1;
  QUERY_IS_SAFE = QUERY_IS_SECURE + 1;

type
  IInternetProtocolInfo = interface
    ['{79eac9ec-baf9-11ce-8c82-00aa004ba90b}']
    function ParseUrl(pwzUrl: LPCWSTR; ParseAction: TParseAction; dwParseFlags: DWORD;
      pwzResult: LPWSTR; cchResult: DWORD; out pcchResult: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function CombineUrl(pwzBaseUrl, pwzRelativeUrl: LPCWSTR; dwCombineFlags: DWORD;
      pwzResult: LPWSTR; cchResult: DWORD; out pcchResult: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function CompareUrl(pwzUrl1, pwzUrl2: LPCWSTR; dwCompareFlags: DWORD): HResult; stdcall;
    function QueryInfo(pwzUrl: LPCWSTR; QueryOption: TQueryOption; dwQueryFlags: DWORD;
      pBuffer: Pointer; cbBuffer: DWORD; var cbBuf: DWORD; dwReserved: DWORD): HResult; stdcall;
  end;

type
  IOInet =               IInternet;
  IOInetBindInfo =       IInternetBindInfo;
  IOInetProtocolRoot =   IInternetProtocolRoot;
  IOInetProtocol =       IInternetProtocol;
  IOInetProtocolSink =   IInternetProtocolSink;
  IOInetProtocolInfo =   IInternetProtocolInfo;
  IOInetSession =        IInternetSession;
  IOInetPriority =       IInternetPriority;
  IOInetThreadSwitch =   IInternetThreadSwitch;

function CoInternetParseUrl(pwzUrl: LPCWSTR; ParseAction: TParseAction;
  dwFlags: DWORD; pszResult: LPWSTR; cchResult: DWORD; var pcchResult: DWORD;
  dwReserved: DWORD): HResult; stdcall;
function CoInternetCombineUrl(pwzBaseUrl, pwzRelativeUrl: LPCWSTR;
  dwCombineFlags: DWORD; pszResult: LPWSTR; cchResult: DWORD;
  var pcchResult: DWORD; dwReserved: DWORD): HResult ; stdcall;
function CoInternetCompareUrl(pwzUrl1, pwzUrl2: LPCWSTR; dwFlags: DWORD): HResult; stdcall;
function CoInternetGetProtocolFlags(pwzUrl: LPCWSTR; var dwFlags: DWORD;
  dwReserved: DWORD): HResult; stdcall;
function CoInternetQueryInfo(pwzUrl: LPCWSTR; QueryOptions: TQueryOption; dwQueryFlags: DWORD;
  pvBuffer: Pointer; cbBuffer: DWORD; var pcbBuffer: DWORD; dwReserved: DWORD): HResult; stdcall;
function CoInternetGetSession(dwSessionMode: DWORD; var pIInternetSession: IInternetSession;
  dwReserved: DWORD): HResult; stdcall;
function CoInternetGetSecurityUrl(pwzUrl: LPCWSTR; var pwzSecUrl: LPWSTR; psuAction: TPSUAction;
  dwReserved: DWORD): HResult; stdcall;

// OInetXXX are synonyms for the previous functions
function OInetParseUrl(pwzUrl: LPCWSTR; ParseAction: TParseAction; dwFlags: DWORD;
  pszResult: LPWSTR; cchResult: DWORD; var pcchResult: DWORD;
  dwReserved: DWORD): HResult; stdcall;
function OInetCombineUrl(pwzBaseUrl, pwzRelativeUrl: LPCWSTR; dwCombineFlags: DWORD;
  pszResult: LPWSTR; cchResult: DWORD; var pcchResult: DWORD;
  dwReserved: DWORD): HResult ; stdcall;
function OInetCompareUrl(pwzUrl1, pwzUrl2: LPCWSTR; dwFlags: DWORD): Hresult; stdcall;
function OInetGetProtocolFlags(pwzUrl: LPCWSTR; var dwFlags: DWORD;
  dwReserved: DWORD): HResult; stdcall;
function OInetQueryInfo(pwzUrl: LPCWSTR; QueryOptions: TQueryOption; dwQueryFlags: DWORD;
  pvBuffer: Pointer; cbBuffer: DWORD; var pcbBuffer: DWORD; dwReserved: DWORD): HResult; stdcall;
function OInetGetSession(dwSessionMode: DWORD; var pIInternetSession: IInternetSession;
  dwReserved: DWORD): HResult; stdcall;
function OInetGetSecurityUrl(pwzUrl: LPCWSTR; var pwzSecUrl: LPWSTR; psuAction: TPSUAction;
  dwReserved: DWORD): HResult; stdcall;

function CopyStgMedium(const cstgmedSrc: TStgMedium; var stgmedDest: TStgMedium): HResult; stdcall;
function CopyBindInfo(const cbiSrc: TBindInfo; var biDest: TBindInfo): HResult; stdcall;
procedure ReleaseBindInfo(const bindinfo: TBindInfo); stdcall;

const
  INET_E_USE_DEFAULT_PROTOCOLHANDLER = HResult($800C0011);
  INET_E_USE_DEFAULT_SETTING         = HResult($800C0012);
  INET_E_DEFAULT_ACTION              = HResult($800C0011);
  INET_E_QUERYOPTION_UNKNOWN         = HResult($800C0013);
  INET_E_REDIRECTING                 = HResult($800C0014);

  PROTOCOLFLAG_NO_PICS_CHECK     = $00000001;

type
  IInternetSecurityMgrSite = interface
    ['{79eac9ed-baf9-11ce-8c82-00aa004ba90b}']
    function GetWindow(out hwnd: HWnd): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
  end;

const
  MUTZ_NOSAVEDFILECHECK        = $00000001; // don't check file: for saved file comment
  MUTZ_ISFILE                  = $00000002; // Assume URL if File, url does not need file://
  MUTZ_ACCEPT_WILDCARD_SCHEME  = $00000080; // Accept a wildcard scheme
  MUTZ_ENFORCERESTRICTED       = $00000100; // enforce restricted zone independent of URL
  MUTZ_REQUIRESAVEDFILECHECK   = $00000400; // always check the file for MOTW (overriding FEATURE_UNC_SAVEDFILECHECK)
  // MapUrlToZone returns the zone index given a URL

  MAX_SIZE_SECURITY_ID    = 512; // bytes;

  // MapUrlToZone returns the zone index given a URL
  PUAF_DEFAULT              = $00000000;
  PUAF_NOUI                 = $00000001;
  PUAF_ISFILE               = $00000002;
  PUAF_WARN_IF_DENIED       = $00000004;
  PUAF_FORCEUI_FOREGROUND   = $00000008;
  PUAF_CHECK_TIFS           = $00000010;
  PUAF_DONTCHECKBOXINDIALOG = $00000020;
  PUAF_TRUSTED              = $00000040;
  PUAF_ACCEPT_WILDCARD_SCHEME = $00000080;
  PUAF_ENFORCERESTRICTED    = $00000100;
  PUAF_NOSAVEDFILECHECK     = $00000200;
  PUAF_REQUIRESAVEDFILECHECK= $00000400;
  PUAF_LMZ_UNLOCKED         = $00010000;
  PUAF_LMZ_LOCKED           = $00020000;
  PUAF_DEFAULTZONEPOL       = $00040000;
  PUAF_NPL_USE_LOCKED_IF_RESTRICTED = $00080000;
  PUAF_NOUIIFLOCKED         = $00100000;

  PUAFOUT_DEFAULT	          = $0;
	PUAFOUT_ISLOCKZONEPOLICY	= $1;

// This is the wrapper function that most clients will use.
// It figures out the current Policy for the passed in Action,
// and puts up UI if the current Policy indicates that the user
// should be queried. It returns back the Policy which the caller
// will use to determine if the action should be allowed
// This is the wrapper function to conveniently read a custom policy.

// SetZoneMapping
//    lpszPattern: string denoting a URL pattern
//        Examples of valid patterns:
//            *://*.msn.com
//            http://*.sony.co.jp
//            *://et.msn.com
//            ftp://157.54.23.41/
//            https://localsvr
//            file:\localsvr\share
//            *://157.54.100-200.*
//        Examples of invalid patterns:
//            http://*.lcs.mit.edu
//            ftp://*
//    dwFlags: SZM_FLAGS values

  SZM_CREATE= $00000000;
  SZM_DELETE= $00000001;

type  
  IInternetSecurityManager = interface
    ['{79eac9ee-baf9-11ce-8c82-00aa004ba90b}']
    function SetSecuritySite(Site: IInternetSecurityMgrSite): HResult; stdcall;
    function GetSecuritySite(out Site: IInternetSecurityMgrSite): HResult; stdcall;
    function MapUrlToZone(pwszUrl: LPCWSTR; out dwZone: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetSecurityId(pwszUrl: LPCWSTR; pbSecurityId: Pointer;
      var cbSecurityId: DWORD; dwReserved: DWORD): HResult; stdcall;
    function ProcessUrlAction(pwszUrl: LPCWSTR; dwAction: DWORD;
      pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
      dwFlags, dwReserved: DWORD): HResult; stdcall;
    function QueryCustomPolicy(pwszUrl: LPCWSTR; const guidKey: TGUID;
      out pPolicy: Pointer; out cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function SetZoneMapping(dwZone: DWORD; lpszPattern: LPCWSTR;
      dwFlags: DWORD): HResult; stdcall;
    function GetZoneMappings(dwZone: DWORD; out enumString: IEnumString;
      dwFlags: DWORD): HResult; stdcall;
  end;

  IInternetHostSecurityManager = interface
    ['{3af280b6-cb3f-11d0-891e-00c04fb6bfc4}']
    function GetSecurityId(pbSecurityId: Pointer; var cbSecurityId: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function ProcessUrlAction(dwAction: DWORD; pPolicy: Pointer; cbPolicy: DWORD;
      pContext: Pointer; cbContext, dwFlags, dwReserved: DWORD): HResult; stdcall;
    function QueryCustomPolicy(const guidKey: TGUID; out pPolicy: Pointer; out cbPolicy: DWORD;
      pContext: Pointer; cbContext, dwReserved: DWORD): HResult; stdcall;
  end;

  IInternetSecurityManagerEx = interface(IInternetSecurityManager)
    ['{F164EDF1-CC7C-4f0d-9A94-34222625C393}']
    function ProcessUrlActionEx(pwszUrl: LPCWSTR; dwAction: DWORD;
      pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
      dwFlags, dwReserved: DWORD; out pdwOutFlags: DWORD): HResult; stdcall;
  end;

const
  URLACTION_MIN                                = $00001000;

  URLACTION_DOWNLOAD_MIN                       = $00001000;
  URLACTION_DOWNLOAD_SIGNED_ACTIVEX            = $00001001;
  URLACTION_DOWNLOAD_UNSIGNED_ACTIVEX          = $00001004;
  URLACTION_DOWNLOAD_CURR_MAX                  = $00001004;
  URLACTION_DOWNLOAD_MAX                       = $000011FF;

  URLACTION_ACTIVEX_MIN                        = $00001200;
  URLACTION_ACTIVEX_RUN                        = $00001200;
  URLACTION_ACTIVEX_OVERRIDE_OBJECT_SAFETY     = $00001201; // aggregate next four
  URLACTION_ACTIVEX_OVERRIDE_DATA_SAFETY       = $00001202; //
  URLACTION_ACTIVEX_OVERRIDE_SCRIPT_SAFETY     = $00001203; //
  URLACTION_SCRIPT_OVERRIDE_SAFETY             = $00001401; //
  URLACTION_ACTIVEX_CONFIRM_NOOBJECTSAFETY     = $00001204; //
  URLACTION_ACTIVEX_TREATASUNTRUSTED           = $00001205;
  URLACTION_ACTIVEX_NO_WEBOC_SCRIPT            = $00001206;
  URLACTION_ACTIVEX_CURR_MAX                   = $00001206;
  URLACTION_ACTIVEX_MAX                        = $000013FF;

  URLACTION_SCRIPT_MIN                         = $00001400;
  URLACTION_SCRIPT_RUN                         = $00001400;
  URLACTION_SCRIPT_JAVA_USE                    = $00001402;
  URLACTION_SCRIPT_SAFE_ACTIVEX                = $00001405;
  URLACTION_SCRIPT_CURR_MAX                    = $00001405;
  URLACTION_SCRIPT_MAX                         = $000015FF;

  URLACTION_HTML_MIN                           = $00001600;
  URLACTION_HTML_SUBMIT_FORMS                  = $00001601; // aggregate next two
  URLACTION_HTML_SUBMIT_FORMS_FROM             = $00001602; //
  URLACTION_HTML_SUBMIT_FORMS_TO               = $00001603; //
  URLACTION_HTML_FONT_DOWNLOAD                 = $00001604;
  URLACTION_HTML_JAVA_RUN                      = $00001605; // derive from Java custom policy;
  URLACTION_HTML_CURR_MAX                      = $00001605;
  URLACTION_HTML_MAX                           = $000017FF;

  URLACTION_SHELL_MIN                          = $00001800;
  URLACTION_SHELL_INSTALL_DTITEMS              = $00001800;
  URLACTION_SHELL_MOVE_OR_COPY                 = $00001802;
  URLACTION_SHELL_FILE_DOWNLOAD                = $00001803;
  URLACTION_SHELL_VERB                         = $00001804;
  URLACTION_SHELL_WEBVIEW_VERB                 = $00001805;
  URLACTION_SHELL_SHELLEXECUTE                 = $00001806;
  URLACTION_SHELL_EXECUTE_HIGHRISK             = $00001806;
  URLACTION_SHELL_EXECUTE_MODRISK              = $00001807;
  URLACTION_SHELL_EXECUTE_LOWRISK              = $00001808;
  URLACTION_SHELL_POPUPMGR                     = $00001809;
  URLACTION_SHELL_CURR_MAX                     = $00001809;
  URLACTION_SHELL_MAX                          = $000019ff;

  URLACTION_NETWORK_MIN                        = $00001A00;

  URLACTION_CREDENTIALS_USE                    = $00001A00;
  URLPOLICY_CREDENTIALS_SILENT_LOGON_OK        = $00000000;
  URLPOLICY_CREDENTIALS_MUST_PROMPT_USER       = $00010000;
  URLPOLICY_CREDENTIALS_CONDITIONAL_PROMPT     = $00020000;
  URLPOLICY_CREDENTIALS_ANONYMOUS_ONLY         = $00030000;

  URLACTION_AUTHENTICATE_CLIENT                = $00001A01;
  URLPOLICY_AUTHENTICATE_CLEARTEXT_OK          = $00000000;
  URLPOLICY_AUTHENTICATE_CHALLENGE_RESPONSE    = $00010000;
  URLPOLICY_AUTHENTICATE_MUTUAL_ONLY           = $00030000;

  URLACTION_NETWORK_CURR_MAX                   = $00001A01;
  URLACTION_NETWORK_MAX                        = $00001BFF;

  URLACTION_JAVA_MIN                           = $00001C00;
  URLACTION_JAVA_PERMISSIONS                   = $00001C00;
  URLPOLICY_JAVA_PROHIBIT                      = $00000000;
  URLPOLICY_JAVA_HIGH                          = $00010000;
  URLPOLICY_JAVA_MEDIUM                        = $00020000;
  URLPOLICY_JAVA_LOW                           = $00030000;
  URLPOLICY_JAVA_CUSTOM                        = $00800000;
  URLACTION_JAVA_CURR_MAX                      = $00001C00;
  URLACTION_JAVA_MAX                           = $00001CFF;

// The following Infodelivery actions should have no default policies
// in the registry.  They assume that no default policy means fall
// back to the global restriction.  If an admin sets a policy per
// zone, then it overrides the global restriction.

  URLACTION_INFODELIVERY_MIN                       = $00001D00;
  URLACTION_INFODELIVERY_NO_ADDING_CHANNELS        = $00001D00;
  URLACTION_INFODELIVERY_NO_EDITING_CHANNELS       = $00001D01;
  URLACTION_INFODELIVERY_NO_REMOVING_CHANNELS      = $00001D02;
  URLACTION_INFODELIVERY_NO_ADDING_SUBSCRIPTIONS   = $00001D03;
  URLACTION_INFODELIVERY_NO_EDITING_SUBSCRIPTIONS  = $00001D04;
  URLACTION_INFODELIVERY_NO_REMOVING_SUBSCRIPTIONS = $00001D05;
  URLACTION_INFODELIVERY_NO_CHANNEL_LOGGING        = $00001D06;
  URLACTION_INFODELIVERY_CURR_MAX                  = $00001D06;
  URLACTION_INFODELIVERY_MAX                       = $00001Dff;
  URLACTION_CHANNEL_SOFTDIST_MIN                   = $00001E00;
  URLACTION_CHANNEL_SOFTDIST_PERMISSIONS           = $00001E05;
  URLPOLICY_CHANNEL_SOFTDIST_PROHIBIT              = $00010000;
  URLPOLICY_CHANNEL_SOFTDIST_PRECACHE              = $00020000;
  URLPOLICY_CHANNEL_SOFTDIST_AUTOINSTALL           = $00030000;
  URLACTION_CHANNEL_SOFTDIST_MAX                   = $00001EFF;

  URLACTION_BEHAVIOR_MIN                           = $00002000;
  URLACTION_BEHAVIOR_RUN                           = $00002000;
  URLPOLICY_BEHAVIOR_CHECK_LIST                    = $00010000;

  // The following actions correspond to the Feature options above.
  // However, they are NOT in the same order.
  URLACTION_FEATURE_MIN                            = $00002100;
  URLACTION_FEATURE_MIME_SNIFFING                  = $00002100;
  URLACTION_FEATURE_ZONE_ELEVATION                 = $00002101;
  URLACTION_FEATURE_WINDOW_RESTRICTIONS            = $00002102;

  URLACTION_AUTOMATIC_DOWNLOAD_UI_MIN              = $00002200;
  URLACTION_AUTOMATIC_DOWNLOAD_UI                  = $00002200;
  URLACTION_AUTOMATIC_ACTIVEX_UI                   = $00002201;

  URLACTION_ALLOW_RESTRICTEDPROTOCOLS              = $00002300;

// For each action specified above the system maintains
// a set of policies for the action.
// The only policies supported currently are permissions (i.e. is something allowed)
// and logging status.
// IMPORTANT: If you are defining your own policies don't overload the meaning of the
// loword of the policy. You can use the hiword to store any policy bits which are only
// meaningful to your action.
// For an example of how to do this look at the URLPOLICY_JAVA above

// Permissions
  URLPOLICY_ALLOW                = $00;
  URLPOLICY_QUERY                = $01;
  URLPOLICY_DISALLOW             = $03;

// Notifications are not done when user already queried.
  URLPOLICY_NOTIFY_ON_ALLOW      = $10;
  URLPOLICY_NOTIFY_ON_DISALLOW   = $20;

// Logging is done regardless of whether user was queried.
  URLPOLICY_LOG_ON_ALLOW         = $40;
  URLPOLICY_LOG_ON_DISALLOW      = $80;

  URLPOLICY_MASK_PERMISSIONS     = $0f;

function GetUrlPolicyPermissions(dw: DWORD): DWORD;
function SetUrlPolicyPermissions(dw, dw2: DWORD): DWORD;

// The ordinal #'s that define the predefined zones internet explorer knows about.
// When we support user-defined zones their zone numbers should be between
// URLZONE_USER_MIN and URLZONE_USER_MAX
  
const  
  URLZONE_PREDEFINED_MIN =     0;
  URLZONE_LOCAL_MACHINE  =     0;
  URLZONE_INTRANET       = URLZONE_LOCAL_MACHINE + 1;
  URLZONE_TRUSTED        = URLZONE_INTRANET + 1;
  URLZONE_INTERNET       = URLZONE_TRUSTED + 1;
  URLZONE_UNTRUSTED      = URLZONE_INTERNET + 1;
  URLZONE_PREDEFINED_MAX =   999;
  URLZONE_USER_MIN       =  1000;
  URLZONE_USER_MAX       = 10000;

  URLTEMPLATE_CUSTOM         = $00000000;
  URLTEMPLATE_PREDEFINED_MIN = $00010000;
  URLTEMPLATE_LOW            = $00010000;
  URLTEMPLATE_MEDIUM         = $00011000;
  URLTEMPLATE_HIGH           = $00012000;
  URLTEMPLATE_PREDEFINED_MAX = $00020000;

  MAX_ZONE_PATH              = 260;
  MAX_ZONE_DESCRIPTION       = 200;

  ZAFLAGS_CUSTOM_EDIT            = $00000001;
  ZAFLAGS_ADD_SITES              = $00000002;
  ZAFLAGS_REQUIRE_VERIFICATION   = $00000004;
  ZAFLAGS_INCLUDE_PROXY_OVERRIDE = $00000008;
  ZAFLAGS_INCLUDE_INTRANET_SITES = $00000010;
  ZAFLAGS_NO_UI                  = $00000020;
  ZAFLAGS_SUPPORTS_VERIFICATION  = $00000040;
  ZAFLAGS_UNC_AS_INTRANET        = $00000080;
  ZAFLAGS_USE_LOCKED_ZONES       = $00010000;

type
  PZoneAttributes = ^TZoneAttributes;
  _ZONEATTRIBUTES = record
    cbSize: ULONG;
    szDisplayName: array [0..260 - 1] of WideChar;
    szDescription: array [0..200 - 1] of WideChar;
    szIconPath: array [0..260 - 1] of WideChar;
    dwTemplateMinLevel: DWORD;
    dwTemplateRecommended: DWORD;
    dwTemplateCurrentLevel: DWORD;
    dwFlags: DWORD;
  end;
  TZoneAttributes = _ZONEATTRIBUTES;
  ZONEATTRIBUTES = _ZONEATTRIBUTES;

// Gets the zone attributes (information in registry other than actual security 
// policies associated with the zone).  Zone attributes are fixed as: 
// Sets the zone attributes (information in registry other than actual security 
// policies associated with the zone).  Zone attributes as above. 
// Returns S_OK or ??? if failed to write the zone attributes. 
{  Registry Flags 

    When reading, default behavior is: 
        If HKLM allows override and HKCU value exists 
            Then use HKCU value 
            Else use HKLM value 
    When writing, default behavior is same as HKCU 
        If HKLM allows override 
           Then Write to HKCU 
           Else Fail 
} 

const
  URLZONEREG_DEFAULT = 0;
  URLZONEREG_HKLM    = URLZONEREG_DEFAULT + 1;
  URLZONEREG_HKCU    = URLZONEREG_HKLM + 1;

// Gets a named custom policy associated with a zone; 
// e.g. the Java VM settings can be defined with a unique key such as 'Java'. 
// Custom policy support is intended to allow extensibility from the predefined 
// set of policies that IE4 has built in. 
//  
// pwszKey is the string name designating the custom policy.  Components are 
//   responsible for having unique names.
// ppPolicy is the callee allocated buffer for the policy byte blob; caller is
//   responsible for freeing this buffer eventually. 
// pcbPolicy is the size of the byte blob returned. 
// dwRegFlags determines how registry is accessed (see above). 
// Returns S_OK if key is found and buffer allocated; ??? if key is not found (no buffer alloced). 
// Sets a named custom policy associated with a zone;
// e.g. the Java VM settings can be defined with a unique key such as 'Java'. 
// Custom policy support is intended to allow extensibility from the predefined 
// set of policies that IE4 has built in.   
//  
// pwszKey is the string name designating the custom policy.  Components are 
//   responsible for having unique names. 
// ppPolicy is the caller allocated buffer for the policy byte blob. 
// pcbPolicy is the size of the byte blob to be set. 
// dwRegFlags determines if HTCU or HKLM is set. 
// Returns S_OK or ??? if failed to write the zone custom policy. 
// Gets action policy associated with a zone, the builtin, fixed-length policies info. 
 
// dwAction is the action code for the action as defined above. 
// pPolicy is the caller allocated buffer for the policy data. 
// cbPolicy is the size of the caller allocated buffer. 
// dwRegFlags determines how registry is accessed (see above). 
// Returns S_OK if action is valid; ??? if action is not valid. 

type
  IInternetZoneManager = interface
    ['{79eac9ef-baf9-11ce-8c82-00aa004ba90b}']

    // Gets the zone attributes (information in registry other than actual security
    // policies associated with the zone).  Zone attributes are fixed as:
    function GetZoneAttributes(dwZone: DWORD;
      var ZoneAttributes: TZoneAttributes): HResult; stdcall;

    // Sets the zone attributes (information in registry other than actual security
    // policies associated with the zone).  Zone attributes as above.
    // Returns S_OK or ??? if failed to write the zone attributes.
    function SetZoneAttributes(dwZone: DWORD;
      const ZoneAttributes: TZoneAttributes): HResult; stdcall;
    function GetZoneCustomPolicy(dwZone: DWORD; const guidKey: TGUID; out pPolicy: Pointer;
      out cbPolicy: DWORD; urlZoneReg: TUrlZoneReg): HResult; stdcall;
    function SetZoneCustomPolicy(dwZone: DWORD; const guidKey: TGUID; pPolicy: Pointer;
      cbPolicy: DWORD; urlZoneReg: TUrlZoneReg): HResult; stdcall;
    function GetZoneActionPolicy(dwZone, dwAction: DWORD; pPolicy: Pointer;
      cbPolicy: DWORD; urlZoneReg: TUrlZoneReg): HResult; stdcall;
    function SetZoneActionPolicy(dwZone, dwAction: DWORD; pPolicy: Pointer;
      cbPolicy: DWORD; urlZoneReg: TUrlZoneReg): HResult; stdcall;
    function PromptAction(dwAction: DWORD; hwndParent: HWnd; pwszUrl, pwszText: LPCWSTR;
      dwPromptFlags: DWORD): HResult; stdcall;
    function LogAction(dwAction: DWORD; pwszUrl, pwszText: LPCWSTR;
      dwLogFlags: DWORD): HResult; stdcall;
    function CreateZoneEnumerator(out dwEnum, dwCount: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetZoneAt(dwEnum, dwIndex: DWORD; out dwZone: DWORD): HResult; stdcall;
    function DestroyZoneEnumerator(dwEnum: DWORD): HResult; stdcall;
    function CopyTemplatePoliciesToZone(dwTemplate, dwZone, dwReserved: DWORD): HResult; stdcall;
  end;

  IInternetZoneManagerEx = interface(IInternetZoneManager)
    ['{A4C23339-8E06-431e-9BF4-7E711C085648}']
    function GetZoneActionPolicyEx(dwZone, dwAction: DWORD; pPolicy: Pointer;
      cbPolicy: DWORD; urlZoneReg: TUrlZoneReg; dwFlags: DWORD): HResult; stdcall;
    function SetZoneActionPolicyEx(dwZone, dwAction: DWORD; pPolicy: Pointer;
      cbPolicy: DWORD; urlZoneReg: TUrlZoneReg; dwFlags: DWORD): HResult; stdcall;
  end;

// Creates the security manager object. The first argument is the Service provider
// to allow for delegation
function CoInternetCreateSecurityManager(SP: IServiceProvider; var SM: IInternetSecurityManager;
  dwReserved: DWORD): HResult; stdcall;
function CoInternetCreateZoneManager(SP: IServiceProvider; var ZM: IInternetZoneManager;
  dwReserved: DWORD): HResult; stdcall;

const
  SOFTDIST_FLAG_USAGE_EMAIL         = $00000001;
  SOFTDIST_FLAG_USAGE_PRECACHE      = $00000002;
  SOFTDIST_FLAG_USAGE_AUTOINSTALL   = $00000004;
  SOFTDIST_FLAG_DELETE_SUBSCRIPTION = $00000008;

  SOFTDIST_ADSTATE_NONE             = $00000000;
  SOFTDIST_ADSTATE_AVAILABLE        = $00000001;
  SOFTDIST_ADSTATE_DOWNLOADED       = $00000002;
  SOFTDIST_ADSTATE_INSTALLED        = $00000003;

type
  PCodeBaseHold = ^TCodeBaseHold;
  _tagCODEBASEHOLD = record
    cbSize: ULONG;
    szDistUnit: LPWSTR;
    szCodeBase: LPWSTR;
    dwVersionMS: DWORD;
    dwVersionLS: DWORD;
    dwStyle: DWORD;
  end;
  TCodeBaseHold = _tagCODEBASEHOLD;
  CODEBASEHOLD = _tagCODEBASEHOLD;

  PSoftDistInfo = ^TSoftDistInfo;
  _tagSOFTDISTINFO = record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwAdState: DWORD;
    szTitle: LPWSTR;
    szAbstract: LPWSTR;
    szHREF: LPWSTR;
    dwInstalledVersionMS: DWORD;
    dwInstalledVersionLS: DWORD;
    dwUpdateVersionMS: DWORD;
    dwUpdateVersionLS: DWORD;
    dwAdvertisedVersionMS: DWORD;
    dwAdvertisedVersionLS: DWORD;
    dwReserved: DWORD;
  end;
  TSoftDistInfo = _tagSOFTDISTINFO;
  SOFTDISTINFO = _tagSOFTDISTINFO;

  ISoftDistExt = interface
    ['{B15B8DC1-C7E1-11d0-8680-00AA00BDCB71}']
    function ProcessSoftDist(szCDFURL: LPCWSTR; SoftDistElement: Pointer {IXMLElement};
      var lpdsi: TSoftDistInfo): HResult; stdcall;
    function GetFirstCodeBase(var szCodeBase: LPWSTR;
      const dwMaxSize: DWORD): HResult; stdcall;
    function GetNextCodeBase(var szCodeBase: LPWSTR;
      const dwMaxSize: DWORD): HResult; stdcall;
    function AsyncInstallDistributionUnit(bc: IBindCtx; pvReserved: Pointer;
      flags: DWORD; const cbh: TCodeBaseHold): HResult; stdcall;
  end;

function GetSoftwareUpdateInfo(szDistUnit: LPCWSTR; var dsi: TSoftDistInfo): HResult; stdcall;
function SetSoftwareUpdateAdvertisementState(szDistUnit: LPCWSTR;
  dwAdState, dwAdvertisedVersionMS, dwAdvertisedVersionLS: DWORD): HResult; stdcall;

type
  IDataFilter = interface
    ['{69d14c80-c18e-11d0-a9ce-006097942311}']
    function DoEncode(dwFlags: DWORD; lInBufferSize: Longint; pbInBuffer: Pointer;
      lOutBufferSize: Longint; pbOutBuffer: Pointer; lInBytesAvailable: Longint;
      out lInBytesRead, lOutBytesWritten: Longint; dwReserved: DWORD): HResult; stdcall;
    function DoDecode(dwFlags: DWORD; lInBufferSize: Longint; pbInBuffer: Pointer;
      lOutBufferSize: Longint; pbOutBuffer: Pointer; lInBytesAvailable: Longint;
      out lInBytesRead, lOutBytesWritten: Longint; dwReserved: DWORD): HResult; stdcall;
    function SetEncodingLevel(dwEncLevel: DWORD): HResult; stdcall;
  end;

  PProtocolFilterData = ^TProtocolFilterData;
  _tagPROTOCOLFILTERDATA = packed record
    cbSize: DWORD;
    ProtocolSink: IInternetProtocolSink;
    Protocol: IInternetProtocol;
    Unk: IUnknown;
    dwFilterFlags: DWORD;
  end;
  TProtocolFilterData = _tagPROTOCOLFILTERDATA;
  PROTOCOLFILTERDATA = _tagPROTOCOLFILTERDATA;
  
  PDataInfo = ^TDataInfo;
  _tagDATAINFO = packed record
    ulTotalSize: ULONG;
    ulavrPacketSize: ULONG;
    ulConnectSpeed: ULONG;
    ulProcessorSpeed: ULONG;
  end;
  TDataInfo = _tagDATAINFO;
  DATAINFO = _tagDATAINFO;

  IEncodingFilterFactory = interface
    ['{70bdde00-c18e-11d0-a9ce-006097942311}']
    function FindBestFilter(pwzCodeIn, pwzCodeOut: LPCWSTR; info: TDataInfo;
      out DF: IDataFilter): HResult; stdcall;
    function GetDefaultFilter(pwzCodeIn, pwzCodeOut: LPCWSTR; info: TDataInfo;
      out DF: IDataFilter): HResult; stdcall;
  end;

// Logging-specific apis
function IsLoggingEnabled(pszUrl: PWideChar): BOOL; stdcall;
function IsLoggingEnabledA(pszUrl: PAnsiChar): BOOL; stdcall;
function IsLoggingEnabledW(pszUrl: PWideChar): BOOL; stdcall;

type
  PHitLoggingInfo = ^THitLoggingInfo;
  _tagHIT_LOGGING_INFO = packed record
    dwStructSize: DWORD;
    lpszLoggedUrlName: LPSTR;
    StartTime: TSystemTime;
    EndTime: TSystemTime;
    lpszExtendedInfo: LPSTR;
  end;
  THitLoggingInfo = _tagHIT_LOGGING_INFO;
  HIT_LOGGING_INFO = _tagHIT_LOGGING_INFO;

function WriteHitLogging(const Logginginfo: THitLoggingInfo): BOOL; stdcall;

implementation

const
  UrlMonLib = 'URLMON.DLL';

// Macro implementations
function GetUrlPolicyPermissions(dw: DWORD): DWORD;
begin
  Result := dw and URLPOLICY_MASK_PERMISSIONS;
end;

function SetUrlPolicyPermissions(dw, dw2: DWORD): DWORD;
begin
  dw := (dw and not (URLPOLICY_MASK_PERMISSIONS)) or dw2;
  Result := dw;
end;

function CreateURLMoniker;                external UrlMonLib name 'CreateURLMoniker';
function GetClassURL;                     external UrlMonLib name 'GetClassURL';
function CreateAsyncBindCtx;              external UrlMonLib name 'CreateAsyncBindCtx';
function CreateAsyncBindCtxEx;            external UrlMonLib name 'CreateAsyncBindCtxEx';
function MkParseDisplayNameEx;            external UrlMonLib name 'MkParseDisplayNameEx';
function RegisterBindStatusCallback;      external UrlMonLib name 'RegisterBindStatusCallback';
function RevokeBindStatusCallback;        external UrlMonLib name 'RevokeBindStatusCallback';
function GetClassFileOrMime;              external UrlMonLib name 'GetClassFileOrMime';
function IsValidURL;                      external UrlMonLib name 'IsValidURL';
function CoGetClassObjectFromURL;         external UrlMonLib name 'CoGetClassObjectFromURL';
function IsAsyncMoniker;                  external UrlMonLib name 'IsAsyncMoniker';
function CreateURLBinding;                external UrlMonLib name 'CreateURLBinding';
function RegisterMediaTypes;              external UrlMonLib name 'RegisterMediaTypes';
function FindMediaType;                   external UrlMonLib name 'FindMediaType';
function CreateFormatEnumerator;          external UrlMonLib name 'CreateFormatEnumerator';
function RegisterFormatEnumerator;        external UrlMonLib name 'RegisterFormatEnumerator';
function RevokeFormatEnumerator;          external UrlMonLib name 'RevokeFormatEnumerator';
function RegisterMediaTypeClass;          external UrlMonLib name 'RegisterMediaTypeClass';
function FindMediaTypeClass;              external UrlMonLib name 'FindMediaTypeClass';
function UrlMkSetSessionOption;           external UrlMonLib name 'UrlMkSetSessionOption';
function UrlMkGetSessionOption;           external UrlMonLib name 'UrlMkGetSessionOption';
function FindMimeFromData;                external UrlMonLib name 'FindMimeFromData';
function ObtainUserAgentString;           external UrlMonLib name 'ObtainUserAgentString';
function HlinkSimpleNavigateToString;     external UrlMonLib name 'HlinkSimpleNavigateToString';
function HlinkSimpleNavigateToMoniker;    external UrlMonLib name 'HlinkSimpleNavigateToMoniker';
function URLOpenStream;                  external UrlMonLib name 'URLOpenStreamW';
function URLOpenStreamA;                  external UrlMonLib name 'URLOpenStreamA';
function URLOpenStreamW;                  external UrlMonLib name 'URLOpenStreamW';
function URLOpenPullStream;              external UrlMonLib name 'URLOpenPullStreamW';
function URLOpenPullStreamA;              external UrlMonLib name 'URLOpenPullStreamA';
function URLOpenPullStreamW;              external UrlMonLib name 'URLOpenPullStreamW';
function URLDownloadToFile;              external UrlMonLib name 'URLDownloadToFileW';
function URLDownloadToFileA;              external UrlMonLib name 'URLDownloadToFileA';
function URLDownloadToFileW;              external UrlMonLib name 'URLDownloadToFileW';
function URLDownloadToCacheFile;         external UrlMonLib name 'URLDownloadToCacheFileW';
function URLDownloadToCacheFileA;         external UrlMonLib name 'URLDownloadToCacheFileA';
function URLDownloadToCacheFileW;         external UrlMonLib name 'URLDownloadToCacheFileW';
function URLOpenBlockingStream;          external UrlMonLib name 'URLOpenBlockingStreamW';
function URLOpenBlockingStreamA;          external UrlMonLib name 'URLOpenBlockingStreamA';
function URLOpenBlockingStreamW;          external UrlMonLib name 'URLOpenBlockingStreamW';
function HlinkGoBack;                     external UrlMonLib name 'HlinkGoBack';
function HlinkGoForward;                  external UrlMonLib name 'HlinkGoForward';
function HlinkNavigateString;             external UrlMonLib name 'HlinkNavigateString';
function HlinkNavigateMoniker;            external UrlMonLib name 'HlinkNavigateMoniker';
function CoInternetParseUrl;              external UrlMonLib name 'CoInternetParseUrl';
function CoInternetCombineUrl;            external UrlMonLib name 'CoInternetCombineUrl';
function CoInternetCompareUrl;            external UrlMonLib name 'CoInternetCompareUrl';
function CoInternetGetProtocolFlags;      external UrlMonLib name 'CoInternetGetProtocolFlags';
function CoInternetQueryInfo;             external UrlMonLib name 'CoInternetQueryInfo';
function CoInternetGetSession;            external UrlMonLib name 'CoInternetGetSession';
function CoInternetGetSecurityUrl;        external UrlMonLib name 'CoInternetGetSecurityUrl';
function OInetParseUrl;                   external UrlMonLib name 'CoInternetParseUrl';
function OInetCombineUrl;                 external UrlMonLib name 'CoInternetCombineUrl';
function OInetCompareUrl;                 external UrlMonLib name 'CoInternetCompareUrl';
function OInetQueryInfo;                  external UrlMonLib name 'CoInternetQueryInfo';
function OInetGetSession;                 external UrlMonLib name 'CoInternetGetSession';
function OInetGetProtocolFlags;           external UrlMonLib name 'OInetGetProtocolFlags';
function OInetGetSecurityUrl;             external UrlMonLib name 'OInetGetSecurityUrl';
function CopyStgMedium;                   external UrlMonLib name 'CopyStgMedium';
function CopyBindInfo;                    external UrlMonLib name 'CopyBindInfo';
procedure ReleaseBindInfo;                external UrlMonLib name 'ReleaseBindInfo';
function CoInternetCreateSecurityManager; external UrlMonLib name 'CoInternetCreateSecurityManager';
function CoInternetCreateZoneManager;     external UrlMonLib name 'CoInternetCreateZoneManager';
function GetSoftwareUpdateInfo;           external UrlMonLib name 'GetSoftwareUpdateInfo';
function IsLoggingEnabled;               external UrlMonLib name 'IsLoggingEnabledW';
function IsLoggingEnabledA;               external UrlMonLib name 'IsLoggingEnabledA';
function IsLoggingEnabledW;               external UrlMonLib name 'IsLoggingEnabledW';
function WriteHitLogging;                 external UrlMonLib name 'WriteHitLogging';
function SetSoftwareUpdateAdvertisementState; external UrlMonLib name 'SetSoftwareUpdateAdvertisementState';

end.
