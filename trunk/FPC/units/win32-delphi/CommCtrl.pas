{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{     Copyright (c) 1985-1999, Microsoft Corporation    }
{                                                       }
{       Translator: Borland Software Corporation        }
{                                                       }
{*******************************************************}

{*******************************************************}
{         Win32 Common Controls Interface Unit          }
{*******************************************************}

unit CommCtrl;

{$WEAKPACKAGEUNIT}

interface


uses Messages, Windows, ActiveX;

{ From prsht.h -- Interface for the Windows Property Sheet Pages }

const
  MAXPROPPAGES = 100;

  PSP_DEFAULT             = $00000000;
  PSP_DLGINDIRECT         = $00000001;
  PSP_USEHICON            = $00000002;
  PSP_USEICONID           = $00000004;
  PSP_USETITLE            = $00000008;
  PSP_RTLREADING          = $00000010;
  PSP_HASHELP             = $00000020;
  PSP_USEREFPARENT        = $00000040;
  PSP_USECALLBACK         = $00000080;
  PSP_PREMATURE           = $00000400;
  PSP_HIDEHEADER          = $00000800;
  PSP_USEHEADERTITLE      = $00001000;
  PSP_USEHEADERSUBTITLE   = $00002000;

  PSPCB_RELEASE           = 1;
  PSPCB_CREATE            = 2;

  PSH_DEFAULT             = $00000000;
  PSH_PROPTITLE           = $00000001;
  PSH_USEHICON            = $00000002;
  PSH_USEICONID           = $00000004;
  PSH_PROPSHEETPAGE       = $00000008;
  PSH_WIZARDHASFINISH     = $00000010;
  PSH_MULTILINETABS       = $00000010;
  PSH_WIZARD              = $00000020;
  PSH_USEPSTARTPAGE       = $00000040;
  PSH_NOAPPLYNOW          = $00000080;
  PSH_USECALLBACK         = $00000100;
  PSH_HASHELP             = $00000200;
  PSH_MODELESS            = $00000400;
  PSH_RTLREADING          = $00000800;
  PSH_WIZARDCONTEXTHELP   = $00001000;
  PSH_WIZARD97            = $00002000;
  PSH_WATERMARK           = $00008000;
  PSH_USEHBMWATERMARK     = $00010000;  // user pass in a hbmWatermark instead of pszbmWatermark
  PSH_USEHPLWATERMARK     = $00020000;  //
  PSH_STRETCHWATERMARK    = $00040000;  // stretchwatermark also applies for the header
  PSH_HEADER              = $00080000;
  PSH_USEHBMHEADER        = $00100000;
  PSH_USEPAGELANG         = $00200000;  // use frame dialog template matched to page

  PSCB_INITIALIZED  = 1;
  PSCB_PRECREATE    = 2;

  PSN_FIRST               = -200;
  PSN_LAST                = -299;

  PSN_SETACTIVE           = PSN_FIRST - 0;
  PSN_KILLACTIVE          = PSN_FIRST - 1;
  PSN_APPLY               = PSN_FIRST - 2;
  PSN_RESET               = PSN_FIRST - 3;
  PSN_HELP                = PSN_FIRST - 5;
  PSN_WIZBACK             = PSN_FIRST - 6;
  PSN_WIZNEXT             = PSN_FIRST - 7;
  PSN_WIZFINISH           = PSN_FIRST - 8;
  PSN_QUERYCANCEL         = PSN_FIRST - 9;
  PSN_GETOBJECT           = PSN_FIRST - 10;

  PSNRET_NOERROR              = 0;
  PSNRET_INVALID              = 1;
  PSNRET_INVALID_NOCHANGEPAGE = 2;

  PSM_SETCURSEL           = WM_USER + 101;
  PSM_REMOVEPAGE          = WM_USER + 102;
  PSM_ADDPAGE             = WM_USER + 103;
  PSM_CHANGED             = WM_USER + 104;
  PSM_RESTARTWINDOWS      = WM_USER + 105;
  PSM_REBOOTSYSTEM        = WM_USER + 106;
  PSM_CANCELTOCLOSE       = WM_USER + 107;
  PSM_QUERYSIBLINGS       = WM_USER + 108;
  PSM_UNCHANGED           = WM_USER + 109;
  PSM_APPLY               = WM_USER + 110;
  PSM_SETTITLE            = WM_USER + 111;
  PSM_SETTITLEW           = WM_USER + 120;
  PSM_SETWIZBUTTONS       = WM_USER + 112;
  PSM_PRESSBUTTON         = WM_USER + 113;
  PSM_SETCURSELID         = WM_USER + 114;
  PSM_SETFINISHTEXT       = WM_USER + 115;
  PSM_SETFINISHTEXTW      = WM_USER + 121;
  PSM_GETTABCONTROL       = WM_USER + 116;
  PSM_ISDIALOGMESSAGE     = WM_USER + 117;

  PSWIZB_BACK             = $00000001;
  PSWIZB_NEXT             = $00000002;
  PSWIZB_FINISH           = $00000004;
  PSWIZB_DISABLEDFINISH   = $00000008;

  PSBTN_BACK              = 0;
  PSBTN_NEXT              = 1;
  PSBTN_FINISH            = 2;
  PSBTN_OK                = 3;
  PSBTN_APPLYNOW          = 4;
  PSBTN_CANCEL            = 5;
  PSBTN_HELP              = 6;
  PSBTN_MAX               = 6;

  ID_PSRESTARTWINDOWS     = 2;
  ID_PSREBOOTSYSTEM       = ID_PSRESTARTWINDOWS or 1;

  WIZ_CXDLG               = 276;
  WIZ_CYDLG               = 140;

  WIZ_CXBMP               = 80;

  WIZ_BODYX               = 92;
  WIZ_BODYCX              = 184;

  PROP_SM_CXDLG           = 212;
  PROP_SM_CYDLG           = 188;

  PROP_MED_CXDLG          = 227;
  PROP_MED_CYDLG          = 215;

  PROP_LG_CXDLG           = 252;
  PROP_LG_CYDLG           = 218;

type
  HPropSheetPage = Pointer;

  PPropSheetPageA = ^TPropSheetPageA;
  PPropSheetPageW = ^TPropSheetPageW;
  PPropSheetPage = PPropSheetPageW;

  LPFNPSPCALLBACKA = function(Wnd: HWnd; Msg: Integer;
    PPSP: PPropSheetPageA): Integer stdcall;
  LPFNPSPCALLBACKW = function(Wnd: HWnd; Msg: Integer;
    PPSP: PPropSheetPageW): Integer stdcall;
  LPFNPSPCALLBACK = LPFNPSPCALLBACKW;
  TFNPSPCallbackA = LPFNPSPCALLBACKA;
  TFNPSPCallbackW = LPFNPSPCALLBACKW;
  TFNPSPCallback = TFNPSPCallbackW;

  _PROPSHEETPAGEA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hInstance: THandle;
    case Integer of
      0: (
        pszTemplate: PAnsiChar);
      1: (
        pResource: Pointer;
        case Integer of
          0: (
            hIcon: THandle);
          1: (
            pszIcon: PAnsiChar;
            pszTitle: PAnsiChar;
            pfnDlgProc: Pointer;
            lParam: Longint;
            pfnCallback: TFNPSPCallbackA;
            pcRefParent: PInteger;
            pszHeaderTitle: PAnsiChar;      // this is displayed in the header
            pszHeaderSubTitle: PAnsiChar)); //
  end;
  _PROPSHEETPAGEW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hInstance: THandle;
    case Integer of
      0: (
        pszTemplate: PWideChar);
      1: (
        pResource: Pointer;
        case Integer of
          0: (
            hIcon: THandle);
          1: (
            pszIcon: PWideChar;
            pszTitle: PWideChar;
            pfnDlgProc: Pointer;
            lParam: Longint;
            pfnCallback: TFNPSPCallbackW;
            pcRefParent: PInteger;
            pszHeaderTitle: PWideChar;      // this is displayed in the header
            pszHeaderSubTitle: PWideChar)); //
  end;
  _PROPSHEETPAGE = _PROPSHEETPAGEW;
  TPropSheetPageA = _PROPSHEETPAGEA;
  TPropSheetPageW = _PROPSHEETPAGEW;
  TPropSheetPage = TPropSheetPageW;
  PROPSHEETPAGEA = _PROPSHEETPAGEA;
  PROPSHEETPAGEW = _PROPSHEETPAGEW;
  PROPSHEETPAGE = PROPSHEETPAGEW;


  PFNPROPSHEETCALLBACK = function(Wnd: HWnd; Msg: Integer;
    LParam: Integer): Integer stdcall;
  TFNPropSheetCallback = PFNPROPSHEETCALLBACK;

  PPropSheetHeaderA = ^TPropSheetHeaderA;
  PPropSheetHeaderW = ^TPropSheetHeaderW;
  PPropSheetHeader = PPropSheetHeaderW;
  _PROPSHEETHEADERA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hwndParent: HWnd;
    hInstance: THandle;
    case Integer of
      0: (
	hIcon: THandle);
      1: (
	pszIcon: PAnsiChar;
	pszCaption: PAnsiChar;
	nPages: Integer;
	case Integer of
	  0: (
	    nStartPage: Integer);
	  1: (
	    pStartPage: PAnsiChar;
	    case Integer of
	      0: (
		ppsp: PPropSheetPageA);
	      1: (
		phpage: Pointer;
		pfnCallback: TFNPropSheetCallback;
                case Integer of
                  0: (
                    hbmWatermark: HBITMAP);
                  1: (
                    pszbmWatermark: PAnsiChar;
                    hplWatermark: HPALETTE;
                    // Header bitmap shares the palette with watermark
                    case Integer of
                      0: (
                        hbmHeader: HBITMAP);
                      1: (
                        pszbmHeader: PAnsiChar)))));
  end;
  _PROPSHEETHEADERW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hwndParent: HWnd;
    hInstance: THandle;
    case Integer of
      0: (
	hIcon: THandle);
      1: (
	pszIcon: PWideChar;
	pszCaption: PWideChar;
	nPages: Integer;
	case Integer of
	  0: (
	    nStartPage: Integer);
	  1: (
	    pStartPage: PWideChar;
	    case Integer of
	      0: (
		ppsp: PPropSheetPageW);
	      1: (
		phpage: Pointer;
		pfnCallback: TFNPropSheetCallback;
                case Integer of
                  0: (
                    hbmWatermark: HBITMAP);
                  1: (
                    pszbmWatermark: PWideChar;
                    hplWatermark: HPALETTE;
                    // Header bitmap shares the palette with watermark
                    case Integer of
                      0: (
                        hbmHeader: HBITMAP);
                      1: (
                        pszbmHeader: PWideChar)))));
  end;
  _PROPSHEETHEADER = _PROPSHEETHEADERW;
  TPropSheetHeaderA = _PROPSHEETHEADERA;
  TPropSheetHeaderW = _PROPSHEETHEADERW;
  TPropSheetHeader = TPropSheetHeaderW;

  LPFNADDPROPSHEETPAGE = function(hPSP: HPropSheetPage;
    lParam: Longint): BOOL stdcall;
  TFNAddPropSheetPage = LPFNADDPROPSHEETPAGE;

  LPFNADDPROPSHEETPAGES = function(lpvoid: Pointer; pfn: TFNAddPropSheetPage;
    lParam: Longint): BOOL stdcall;
  TFNAddPropSheetPages = LPFNADDPROPSHEETPAGES;

function CreatePropertySheetPage(var PSP: TPropSheetPage): HPropSheetPage; stdcall;
function CreatePropertySheetPageA(var PSP: TPropSheetPageA): HPropSheetPage; stdcall;
function CreatePropertySheetPageW(var PSP: TPropSheetPageW): HPropSheetPage; stdcall;
function DestroyPropertySheetPage(hPSP: HPropSheetPage): BOOL; stdcall;
function PropertySheet(var PSH: TPropSheetHeader): Integer; stdcall;
function PropertySheetA(var PSH: TPropSheetHeaderA): Integer; stdcall;
function PropertySheetW(var PSH: TPropSheetHeaderW): Integer; stdcall;

{ From commctrl.h }

type
  tagINITCOMMONCONTROLSEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;
  
const
  ICC_LISTVIEW_CLASSES   = $00000001; // listview, header
  ICC_TREEVIEW_CLASSES   = $00000002; // treeview, tooltips
  ICC_BAR_CLASSES        = $00000004; // toolbar, statusbar, trackbar, tooltips
  ICC_TAB_CLASSES        = $00000008; // tab, tooltips
  ICC_UPDOWN_CLASS       = $00000010; // updown
  ICC_PROGRESS_CLASS     = $00000020; // progress
  ICC_HOTKEY_CLASS       = $00000040; // hotkey
  ICC_ANIMATE_CLASS      = $00000080; // animate
  ICC_WIN95_CLASSES      = $000000FF;
  ICC_DATE_CLASSES       = $00000100; // month picker, date picker, time picker, updown
  ICC_USEREX_CLASSES     = $00000200; // comboex
  ICC_COOL_CLASSES       = $00000400; // rebar (coolbar) control
  ICC_INTERNET_CLASSES   = $00000800;
  ICC_PAGESCROLLER_CLASS = $00001000; // page scroller
  ICC_NATIVEFNTCTL_CLASS = $00002000; // native font control
  { For Windows >= XP }
  ICC_STANDARD_CLASSES   = $00004000;
  ICC_LINK_CLASS         = $00008000;

procedure InitCommonControls; stdcall;
function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool; { Re-defined below }

const
  IMAGE_BITMAP = 0;

const
  ODT_HEADER              = 100;
  ODT_TAB                 = 101;
  ODT_LISTVIEW            = 102;


{ ====== Ranges for control message IDs ======================= }

const
  LVM_FIRST               = $1000;      { ListView messages }
  TV_FIRST                = $1100;      { TreeView messages }
  HDM_FIRST               = $1200;      { Header messages }
  TCM_FIRST               = $1300;      { Tab control messages }
  PGM_FIRST               = $1400;      { Pager control messages }
  { For Windows >= XP }
  ECM_FIRST               = $1500;      { Edit control messages }
  BCM_FIRST               = $1600;      { Button control messages }
  CBM_FIRST               = $1700;      { Combobox control messages }

  CCM_FIRST               = $2000;      { Common control shared messages }
  CCM_LAST                = CCM_FIRST + $200;

  CCM_SETBKCOLOR          = CCM_FIRST + 1; // lParam is bkColor

type
  tagCOLORSCHEME = packed record
    dwSize: DWORD;
    clrBtnHighlight: COLORREF;    // highlight color
    clrBtnShadow: COLORREF;       // shadow color
  end;
  PColorScheme = ^TColorScheme;
  TColorScheme = tagCOLORSCHEME;

const
  CCM_SETCOLORSCHEME      = CCM_FIRST + 2; // lParam is color scheme
  CCM_GETCOLORSCHEME      = CCM_FIRST + 3; // fills in COLORSCHEME pointed to by lParam
  CCM_GETDROPTARGET       = CCM_FIRST + 4;
  CCM_SETUNICODEFORMAT    = CCM_FIRST + 5;
  CCM_GETUNICODEFORMAT    = CCM_FIRST + 6;
  CCM_SETVERSION          = CCM_FIRST + $7;
  CCM_GETVERSION          = CCM_FIRST + $8;
  CCM_SETNOTIFYWINDOW     = CCM_FIRST + $9;   { wParam == hwndParent. }
  { For Windows >= XP }
  CCM_SETWINDOWTHEME      = CCM_FIRST + $B;
  CCM_DPISCALE            = CCM_FIRST + $C;   { wParam == Awareness }

  INFOTIPSIZE = 1024;  // for tooltips

{ ====== WM_NOTIFY codes (NMHDR.code values) ================== }

const
  NM_FIRST                 = 0-  0;       { generic to all controls }
  NM_LAST                  = 0- 99;

  LVN_FIRST                = 0-100;       { listview }
  LVN_LAST                 = 0-199;

  HDN_FIRST                = 0-300;       { header }
  HDN_LAST                 = 0-399;

  TVN_FIRST                = 0-400;       { treeview }
  TVN_LAST                 = 0-499;

  TTN_FIRST                = 0-520;       { tooltips }
  TTN_LAST                 = 0-549;

  TCN_FIRST                = 0-550;       { tab control }
  TCN_LAST                 = 0-580;

{ Shell reserved           (0-580) -  (0-589) }

  CDN_FIRST                = 0-601;       { common dialog (new) }
  CDN_LAST                 = 0-699;

  TBN_FIRST                = 0-700;       { toolbar }
  TBN_LAST                 = 0-720;

  UDN_FIRST                = 0-721;       { updown }
  UDN_LAST                 = 0-740;

  MCN_FIRST                = 0-750;       { monthcal }
  MCN_LAST                 = 0-759;

  DTN_FIRST                = 0-760;       { datetimepick }
  DTN_LAST                 = 0-799;

  CBEN_FIRST               = 0-800;       { combo box ex }
  CBEN_LAST                = 0-830;

  RBN_FIRST                = 0-831;       { coolbar }
  RBN_LAST                 = 0-859;

  IPN_FIRST               = 0-860;       { internet address }
  IPN_LAST                = 0-879;       { internet address }

  SBN_FIRST               = 0-880;       { status bar }
  SBN_LAST                = 0-899;

  PGN_FIRST               = 0-900;       { Pager Control }
  PGN_LAST                = 0-950;

  WMN_FIRST               = 0-1000;
  WMN_LAST                = 0-1200;

  { For Windows >= XP }
  BCN_FIRST               = 0-1250;
  BCN_LAST                = 0-1350;

  { For Windows >= Vista }
  TRBN_FIRST              = 0-1501;          { trackbar }
  TRBN_LAST               = 0-1519;

  MSGF_COMMCTRL_BEGINDRAG     = $4200;
  MSGF_COMMCTRL_SIZEHEADER    = $4201;
  MSGF_COMMCTRL_DRAGSELECT    = $4202;
  MSGF_COMMCTRL_TOOLBARCUST   = $4203;


{ ====== Generic WM_NOTIFY notification codes ================= }

const
  NM_OUTOFMEMORY           = NM_FIRST-1;
  NM_CLICK                 = NM_FIRST-2;
  NM_DBLCLK                = NM_FIRST-3;
  NM_RETURN                = NM_FIRST-4;
  NM_RCLICK                = NM_FIRST-5;
  NM_RDBLCLK               = NM_FIRST-6;
  NM_SETFOCUS              = NM_FIRST-7;
  NM_KILLFOCUS             = NM_FIRST-8;
  NM_CUSTOMDRAW            = NM_FIRST-12;
  NM_HOVER                 = NM_FIRST-13;
  NM_NCHITTEST             = NM_FIRST-14;   // uses NMMOUSE struct
  NM_KEYDOWN               = NM_FIRST-15;   // uses NMKEY struct
  NM_RELEASEDCAPTURE       = NM_FIRST-16;
  NM_SETCURSOR             = NM_FIRST-17;   // uses NMMOUSE struct
  NM_CHAR                  = NM_FIRST-18;   // uses NMCHAR struct
  NM_TOOLTIPSCREATED       = NM_FIRST-19;    { notify of when the tooltips window is create }
  NM_LDOWN                 = NM_FIRST-20;
  NM_RDOWN                 = NM_FIRST-21;
  NM_THEMECHANGED          = NM_FIRST-22;
  { For Windows >= Vista }
  NM_FONTCHANGED          = NM_FIRST-23;
  NM_CUSTOMTEXT           = NM_FIRST-24;    { uses NMCUSTOMTEXT struct }
  NM_TVSTATEIMAGECHANGING = NM_FIRST-24;    { uses NMTVSTATEIMAGECHANGING struct, defined after HTREEITEM }

type
  tagNMMOUSE = packed record
    hdr: TNMHdr;
    dwItemSpec: DWORD;
    dwItemData: DWORD;
    pt: TPoint;
    dwHitInfo: DWORD; // any specifics about where on the item or control the mouse is
  end;
  PNMMouse = ^TNMMouse;
  TNMMouse = tagNMMOUSE;

  PNMClick = ^TNMClick;
  TNMClick = tagNMMOUSE;

  // Generic structure to request an object of a specific type.
  tagNMOBJECTNOTIFY = packed record
    hdr: TNMHdr;
    iItem: Integer;
    piid: PGUID;
    pObject: Pointer;
    hResult: HRESULT;
    dwFlags: DWORD;    // control specific flags (hints as to where in iItem it hit)
  end;
  PNMObjectNotify = ^TNMObjectNotify;
  TNMObjectNotify = tagNMOBJECTNOTIFY;

  // Generic structure for a key
  tagNMKEY = packed record
    hdr: TNMHdr;
    nVKey: UINT;
    uFlags: UINT;
  end;
  PNMKey = ^TNMKey;
  TNMKey = tagNMKEY;

  // Generic structure for a character
  tagNMCHAR = packed record
    hdr: TNMHdr;
    ch: UINT;
    dwItemPrev: DWORD;     // Item previously selected
    dwItemNext: DWORD;     // Item to be selected
  end;
  PNMChar = ^TNMChar;
  TNMChar = tagNMCHAR;

  { For IE >= 0x0600 }
  { $EXTERNALSYM tagNMCUSTOMTEXT}
  tagNMCUSTOMTEXT = record
    hdr: NMHDR;
    hDC: HDC;
    lpString: LPCWSTR;
    nCount: Integer;
    lpRect: PRect;
    uFormat: UINT;
    fLink: BOOL;
  end;
  PNMCustomText = ^TNMCustomText;
  TNMCustomText = tagNMCUSTOMTEXT;

{ ==================== CUSTOM DRAW ========================================== }

const
  // custom draw return flags
  // values under 0x00010000 are reserved for global custom draw values.
  // above that are for specific controls
  CDRF_DODEFAULT          = $00000000;
  CDRF_NEWFONT            = $00000002;
  CDRF_SKIPDEFAULT        = $00000004;

  CDRF_NOTIFYPOSTPAINT    = $00000010;
  CDRF_NOTIFYITEMDRAW     = $00000020;
  CDRF_NOTIFYSUBITEMDRAW  = $00000020;  // flags are the same, we can distinguish by context
  CDRF_NOTIFYPOSTERASE    = $00000040;

  // drawstage flags
  // values under = $00010000 are reserved for global custom draw values.
  // above that are for specific controls
  CDDS_PREPAINT           = $00000001;
  CDDS_POSTPAINT          = $00000002;
  CDDS_PREERASE           = $00000003;
  CDDS_POSTERASE          = $00000004;
  // the = $000010000 bit means it's individual item specific
  CDDS_ITEM               = $00010000;
  CDDS_ITEMPREPAINT       = CDDS_ITEM or CDDS_PREPAINT;
  CDDS_ITEMPOSTPAINT      = CDDS_ITEM or CDDS_POSTPAINT;
  CDDS_ITEMPREERASE       = CDDS_ITEM or CDDS_PREERASE;
  CDDS_ITEMPOSTERASE      = CDDS_ITEM or CDDS_POSTERASE;
  CDDS_SUBITEM            = $00020000;

  // itemState flags
  CDIS_SELECTED       = $0001;
  CDIS_GRAYED         = $0002;
  CDIS_DISABLED       = $0004;
  CDIS_CHECKED        = $0008;
  CDIS_FOCUS          = $0010;
  CDIS_DEFAULT        = $0020;
  CDIS_HOT            = $0040;
  CDIS_MARKED         = $0080;
  CDIS_INDETERMINATE  = $0100;
  { For Windows >= XP }
  CDIS_SHOWKEYBOARDCUES = $0200;
  { For Windows >= Vista }
  CDIS_NEARHOT          = $0400;
  CDIS_OTHERSIDEHOT     = $0800;
  CDIS_DROPHILITED      = $1000;

type
  tagNMCUSTOMDRAWINFO = packed record
    hdr: TNMHdr;
    dwDrawStage: DWORD;
    hdc: HDC;
    rc: TRect;
    dwItemSpec: DWORD;  // this is control specific, but it's how to specify an item.  valid only with CDDS_ITEM bit set
    uItemState: UINT;
    lItemlParam: LPARAM;
  end;
  PNMCustomDraw = ^TNMCustomDraw;
  TNMCustomDraw = tagNMCUSTOMDRAWINFO;

  tagNMTTCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    uDrawFlags: UINT;
  end;
  PNMTTCustomDraw = ^TNMTTCustomDraw;
  TNMTTCustomDraw = tagNMTTCUSTOMDRAW;

{ ====== IMAGE LIST =========================================== }

const
  CLR_NONE                = $FFFFFFFF;
  CLR_DEFAULT             = $FF000000;

type
  HIMAGELIST = THandle;

  _IMAGELISTDRAWPARAMS = packed record
    cbSize: DWORD;
    himl: HIMAGELIST;
    i: Integer;
    hdcDst: HDC;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    xBitmap: Integer;        // x offest from the upperleft of bitmap
    yBitmap: Integer;        // y offset from the upperleft of bitmap
    rgbBk: COLORREF;
    rgbFg: COLORREF;
    fStyle: UINT;
    dwRop: DWORD;
                                 
    { For IE >= 0x0501 }
    {fState: DWORD;
    Frame: DWORD;
    crEffect: COLORREF;}
  end;
  PImageListDrawParams = ^TImageListDrawParams;
  TImageListDrawParams = _IMAGELISTDRAWPARAMS;

const
  ILC_MASK                = $0001;
  ILC_COLOR               = $0000;
  ILC_COLORDDB            = $00FE;
  ILC_COLOR4              = $0004;
  ILC_COLOR8              = $0008;
  ILC_COLOR16             = $0010;
  ILC_COLOR24             = $0018;
  ILC_COLOR32             = $0020;
  ILC_PALETTE             = $0800;
  { For Windows >= XP }
  ILC_MIRROR              = $00002000;      { Mirror the icons contained, if the process is mirrored }
  ILC_PERITEMMIRROR       = $00008000;      { Causes the mirroring code to mirror each item when inserting a set of images, verses the whole strip }
  { For Windows >= Vista }
  ILC_ORIGINALSIZE        = $00010000;      { Imagelist should accept smaller than set images and apply OriginalSize based on image added }
  ILC_HIGHQUALITYSCALE    = $00020000;      { Imagelist should enable use of the high quality scaler. }

function ImageList_Create(CX, CY: Integer; Flags: UINT;
  Initial, Grow: Integer): HIMAGELIST; stdcall;
function ImageList_Destroy(ImageList: HIMAGELIST): Bool; stdcall;
function ImageList_GetImageCount(ImageList: HIMAGELIST): Integer; stdcall;
function ImageList_SetImageCount(himl: HIMAGELIST; uNewCount: UINT): Integer; stdcall;
function ImageList_Add(ImageList: HIMAGELIST; Image, Mask: HBitmap): Integer; stdcall;
function ImageList_ReplaceIcon(ImageList: HIMAGELIST; Index: Integer;
  Icon: HIcon): Integer; stdcall;
function ImageList_SetBkColor(ImageList: HIMAGELIST; ClrBk: TColorRef): TColorRef; stdcall;
function ImageList_GetBkColor(ImageList: HIMAGELIST): TColorRef; stdcall;
function ImageList_SetOverlayImage(ImageList: HIMAGELIST; Image: Integer;
  Overlay: Integer): Bool; stdcall;

function ImageList_AddIcon(ImageList: HIMAGELIST; Icon: HIcon): Integer; {inline;}

const
  ILD_NORMAL              = $0000;
  ILD_TRANSPARENT         = $0001;
  ILD_MASK                = $0010;
  ILD_IMAGE               = $0020;
  ILD_ROP                 = $0040;
  ILD_BLEND25             = $0002;
  ILD_BLEND50             = $0004;
  ILD_OVERLAYMASK         = $0F00;
  ILD_PRESERVEALPHA       = $00001000;  // This preserves the alpha channel in dest
  ILD_SCALE               = $00002000;  // Causes the image to be scaled to cx, cy instead of clipped
  ILD_DPISCALE            = $00004000;
  { For Windows >= Vista }
  ILD_ASYNC               = $00008000;

function IndexToOverlayMask(Index: Integer): Integer; {inline;}

const
  ILD_SELECTED            = ILD_BLEND50;
  ILD_FOCUS               = ILD_BLEND25;
  ILD_BLEND               = ILD_BLEND50;
  CLR_HILIGHT             = CLR_DEFAULT;

  ILS_NORMAL              = $00000000;
  ILS_GLOW                = $00000001;
  ILS_SHADOW              = $00000002;
  ILS_SATURATE            = $00000004;
  ILS_ALPHA               = $00000008;

  { For Windows >= Vista }
  ILGT_NORMAL             = $00000000;
  ILGT_ASYNC              = $00000001;

function ImageList_Draw(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y: Integer; Style: UINT): Bool; stdcall;

const
  { For Windows >= Vista }
  HBITMAP_CALLBACK               = HBITMAP(-1);     // only for SparseImageList

function ImageList_Replace(ImageList: HIMAGELIST; Index: Integer;
  Image, Mask: HBitmap): Bool; stdcall;
function ImageList_AddMasked(ImageList: HIMAGELIST; Image: HBitmap;
  Mask: TColorRef): Integer; stdcall;
function ImageList_DrawEx(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y, DX, DY: Integer; Bk, Fg: TColorRef; Style: Cardinal): Bool; stdcall;
function ImageList_DrawIndirect(pimldp: PImageListDrawParams): Integer; stdcall;
function ImageList_Remove(ImageList: HIMAGELIST; Index: Integer): Bool; stdcall;
function ImageList_GetIcon(ImageList: HIMAGELIST; Index: Integer;
  Flags: Cardinal): HIcon; stdcall;
function ImageList_LoadImage(Instance: THandle; Bmp: PWideChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
function ImageList_LoadImageA(Instance: THandle; Bmp: PAnsiChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
function ImageList_LoadImageW(Instance: THandle; Bmp: PWideChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;

const
  ILCF_MOVE   = $00000000;
  ILCF_SWAP   = $00000001;

function ImageList_Copy(himlDst: HIMAGELIST; iDst: Integer; himlSrc: HIMAGELIST;
  Src: Integer; uFlags: UINT): Integer; stdcall;

function ImageList_BeginDrag(ImageList: HIMAGELIST; Track: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
function ImageList_EndDrag: Bool; stdcall;
function ImageList_DragEnter(LockWnd: HWnd; X, Y: Integer): Bool; stdcall;
function ImageList_DragLeave(LockWnd: HWnd): Bool; stdcall;
function ImageList_DragMove(X, Y: Integer): Bool; stdcall;
function ImageList_SetDragCursorImage(ImageList: HIMAGELIST; Drag: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
function ImageList_DragShowNolock(Show: Bool): Bool; stdcall;
function ImageList_GetDragImage(Point, HotSpot: PPoint): HIMAGELIST; overload; stdcall;
function ImageList_GetDragImage(Point: PPoint; out HotSpot: TPoint): HIMAGELIST; overload; stdcall;

{ macros }
procedure ImageList_RemoveAll(ImageList: HIMAGELIST); {inline;}
function ImageList_ExtractIcon(Instance: THandle; ImageList: HIMAGELIST;
  Image: Integer): HIcon; {inline;}
function ImageList_LoadBitmap(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;
function ImageList_LoadBitmapA(Instance: THandle; Bmp: PAnsiChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;
function ImageList_LoadBitmapW(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; MasK: TColorRef): HIMAGELIST;

function ImageList_Read(Stream: IStream): HIMAGELIST; stdcall;
function ImageList_Write(ImageList: HIMAGELIST; Stream: IStream): BOOL; stdcall;

const
  { For Windows >= XP }
  ILP_NORMAL          = 0;          { Writes or reads the stream using new sematics for this version of comctl32 }
  ILP_DOWNLEVEL       = 1;          { Write or reads the stream using downlevel sematics. }

{ For Windows >= XP }
function ImageList_ReadEx(dwFlags: DWORD; pstm: IStream; const riid: TIID;
  var ppv: Pointer): HResult;
function ImageList_WriteEx(himl: HIMAGELIST; dwFlags: DWORD;
  pstm: IStream): HResult;


type
  PImageInfo = ^TImageInfo;
  _IMAGEINFO = packed record
    hbmImage: HBitmap;
    hbmMask: HBitmap;
    Unused1: Integer;
    Unused2: Integer;
    rcImage: TRect;
  end;
  TImageInfo = _IMAGEINFO;
  IMAGEINFO = _IMAGEINFO;

function ImageList_GetIconSize(ImageList: HIMAGELIST; var CX, CY: Integer): Bool; stdcall;
function ImageList_SetIconSize(ImageList: HIMAGELIST; CX, CY: Integer): Bool; stdcall;
function ImageList_GetImageInfo(ImageList: HIMAGELIST; Index: Integer;
  var ImageInfo: TImageInfo): Bool; stdcall;
function ImageList_Merge(ImageList1: HIMAGELIST; Index1: Integer;
  ImageList2: HIMAGELIST; Index2: Integer; DX, DY: Integer): HIMAGELIST; stdcall;
function ImageList_Duplicate(himl: HIMAGELIST): HIMAGELIST; stdcall;

function HIMAGELIST_QueryInterface(himl: HIMAGELIST; const riid: TIID;
  var ppv: Pointer): HResult;

{ ====== HEADER CONTROL ========================== }

const
  WC_HEADER = 'SysHeader32';

  HDS_HORZ                = $0000;
  HDS_BUTTONS             = $0002;
  HDS_HOTTRACK            = $0004;
  HDS_HIDDEN              = $0008;
  HDS_DRAGDROP            = $0040;
  HDS_FULLDRAG            = $0080;
  HDS_FILTERBAR           = $0100;
  { For Windows >= XP }
  HDS_FLAT                = $0200;
  { For Windows >= Vista }
  HDS_CHECKBOXES          = $0400;
  HDS_NOSIZING            = $0800;
  HDS_OVERFLOW            = $1000;

type
  PHDItemA = ^THDItemA;
  PHDItemW = ^THDItemW;
  PHDItem = PHDItemW;
  _HD_ITEMA = record
    Mask: Cardinal;
    cxy: Integer;
    pszText: PAnsiChar;
    hbm: HBITMAP;
    cchTextMax: Integer;
    fmt: Integer;
    lParam: LPARAM;
    iImage: Integer;        // index of bitmap in ImageList
    iOrder: Integer;        // where to draw this item
                                                        
  { For IE >= 0x0500 }
//    type: UINT;             // [in] filter type (defined what pvFilter is a pointer to)
//    pvFilter: PVOID;        // [in] filter data see above
                                                         
  { For Windows >= Vista }
//    state: UINT;
  end;
  _HD_ITEMW = record
    Mask: Cardinal;
    cxy: Integer;
    pszText: PWideChar;
    hbm: HBITMAP;
    cchTextMax: Integer;
    fmt: Integer;
    lParam: LPARAM;
    iImage: Integer;        // index of bitmap in ImageList
    iOrder: Integer;        // where to draw this item
                                                        
  { For IE >= 0x0500 }
//    type: UINT;             // [in] filter type (defined what pvFilter is a pointer to)
//    pvFilter: PVOID;        // [in] filter data see above
                                                         
  { For Windows >= Vista }
//    state: UINT;
  end;
  _HD_ITEM = _HD_ITEMW;
  THDItemA = _HD_ITEMA;
  THDItemW = _HD_ITEMW;
  THDItem = THDItemW;
  HD_ITEMA = _HD_ITEMA;
  HD_ITEMW = _HD_ITEMW;
  HD_ITEM = HD_ITEMW;

const
  HDI_WIDTH               = $0001;
  HDI_HEIGHT              = HDI_WIDTH;
  HDI_TEXT                = $0002;
  HDI_FORMAT              = $0004;
  HDI_LPARAM              = $0008;
  HDI_BITMAP              = $0010;
  HDI_IMAGE               = $0020;
  HDI_DI_SETITEM          = $0040;
  HDI_ORDER               = $0080;
  { For IE >= 0x0500 }
  HDI_FILTER              = $0100;
  { For Windows >= Vista }
  HDI_STATE               = $0200;

  HDF_LEFT                = $0000; { Same as LVCFMT_LEFT }
  HDF_RIGHT               = $0001; { Same as LVCFMT_RIGHT }
  HDF_CENTER              = $0002; { Same as LVCFMT_CENTER }
  HDF_JUSTIFYMASK         = $0003; { Same as LVCFMT_JUSTIFYMASK }
  HDF_RTLREADING          = $0004; { Same as LVCFMT_LEFT }

  HDF_BITMAP              = $2000; 
  HDF_STRING              = $4000;
  HDF_OWNERDRAW           = $8000; { Same as LVCFMT_COL_HAS_IMAGES }

  HDF_IMAGE               = $0800; { Same as LVCFMT_IMAGE }
  HDF_BITMAP_ON_RIGHT     = $1000; { Same as LVCFMT_BITMAP_ON_RIGHT }

  { For Windows >= XP }
  HDF_SORTUP              = $0400;
  HDF_SORTDOWN            = $0200;

  { For Windows >= Vista }
  HDF_CHECKBOX            = $0040;
  HDF_CHECKED             = $0080;
  HDF_FIXEDWIDTH          = $0100; { Can't resize the column; same as LVCFMT_FIXED_WIDTH }
  HDF_SPLITBUTTON         = $1000000; { Column is a split button; same as LVCFMT_SPLITBUTTON }

  { For Windows >= Vista }
  HDIS_FOCUSED            = $00000001; 

  HDM_GETITEMCOUNT        = HDM_FIRST + 0;

function Header_GetItemCount(Header: HWnd): Integer; {inline;}

const
  HDM_INSERTITEMW          = HDM_FIRST + 10;
  HDM_INSERTITEMA          = HDM_FIRST + 1;
{$IFDEF UNICODE}
  HDM_INSERTITEM           = HDM_INSERTITEMW;
{$ELSE}
  HDM_INSERTITEM           = HDM_INSERTITEMA;
{$ENDIF}

function Header_InsertItem(Header: HWnd; Index: Integer;
  const Item: THDItem): Integer; {inline;}
function Header_InsertItemA(Header: HWnd; Index: Integer;
  const Item: THDItemA): Integer; {inline;}
function Header_InsertItemW(Header: HWnd; Index: Integer;
  const Item: THDItemW): Integer; {inline;}

const
  HDM_DELETEITEM          = HDM_FIRST + 2;

function Header_DeleteItem(Header: HWnd; Index: Integer): Bool; {inline;}

const
  HDM_GETITEMW             = HDM_FIRST + 11;
  HDM_GETITEMA             = HDM_FIRST + 3;
{$IFDEF UNICODE}
  HDM_GETITEM              = HDM_GETITEMW;
{$ELSE}
  HDM_GETITEM              = HDM_GETITEMA;
{$ENDIF}

function Header_GetItem(Header: HWnd; Index: Integer;
  var Item: THDItem): Bool; {inline;}
function Header_GetItemA(Header: HWnd; Index: Integer;
  var Item: THDItemA): Bool; {inline;}
function Header_GetItemW(Header: HWnd; Index: Integer;
  var Item: THDItemW): Bool; {inline;}

const
  HDM_SETITEMA            = HDM_FIRST + 4;
  HDM_SETITEMW            = HDM_FIRST + 12;
{$IFDEF UNICODE}
  HDM_SETITEM             = HDM_SETITEMW;
{$ELSE}
  HDM_SETITEM             = HDM_SETITEMA;
{$ENDIF}

function Header_SetItem(Header: HWnd; Index: Integer; const Item: THDItem): Bool; {inline;}
function Header_SetItemA(Header: HWnd; Index: Integer; const Item: THDItemA): Bool; {inline;}
function Header_SetItemW(Header: HWnd; Index: Integer; const Item: THDItemW): Bool; {inline;}

type
  PHDLayout = ^THDLayout;
  _HD_LAYOUT = packed record
    Rect: ^TRect;
    WindowPos: PWindowPos;
  end;
  THDLayout = _HD_LAYOUT;
  HD_LAYOUT = _HD_LAYOUT;

const
  HDM_LAYOUT              = HDM_FIRST + 5;

function Header_Layout(Header: HWnd; Layout: PHDLayout): Bool; {inline;}

const
  HHT_NOWHERE             = $0001;
  HHT_ONHEADER            = $0002;
  HHT_ONDIVIDER           = $0004;
  HHT_ONDIVOPEN           = $0008;
  HHT_ABOVE               = $0100;
  HHT_BELOW               = $0200;
  HHT_TORIGHT             = $0400;
  HHT_TOLEFT              = $0800;
  { For Windows >= Vista }
  HHT_ONITEMSTATEICON     = $1000;
  HHT_ONDROPDOWN          = $2000;
  HHT_ONOVERFLOW          = $4000;

type
  PHDHitTestInfo = ^THDHitTestInfo;
  _HD_HITTESTINFO = packed record
    Point: TPoint;
    Flags: Cardinal;
    Item: Integer;
  end;
  THDHitTestInfo = _HD_HITTESTINFO;
  HD_HITTESTINFO = _HD_HITTESTINFO;

const
  HDM_HITTEST             = HDM_FIRST + 6;
  HDM_GETITEMRECT         = HDM_FIRST + 7;
  HDM_SETIMAGELIST        = HDM_FIRST + 8;
  HDM_GETIMAGELIST        = HDM_FIRST + 9;
  HDM_ORDERTOINDEX        = HDM_FIRST + 15;
  HDM_CREATEDRAGIMAGE     = HDM_FIRST + 16;  // wparam = which item = by index;
  HDM_GETORDERARRAY       = HDM_FIRST + 17;
  HDM_SETORDERARRAY       = HDM_FIRST + 18;
  HDM_SETHOTDIVIDER       = HDM_FIRST + 19;
  HDM_SETUNICODEFORMAT    = CCM_SETUNICODEFORMAT;
  HDM_GETUNICODEFORMAT    = CCM_GETUNICODEFORMAT;

  { For IE >= 0x0500 }
  HDM_SETBITMAPMARGIN          = HDM_FIRST + 20;
  HDM_GETBITMAPMARGIN          = HDM_FIRST + 21;
  HDM_SETFILTERCHANGETIMEOUT   = HDM_FIRST + 22;
  HDM_EDITFILTER               = HDM_FIRST + 23;
  HDM_CLEARFILTER              = HDM_FIRST + 24;

  { For Windows >= 0x0600 }
  // Not currently implemented
  //HDM_TRANSLATEACCELERATOR    = CCM_TRANSLATEACCELERATOR;

  { For Windows >= Vista}
  HDM_GETITEMDROPDOWNRECT     = HDM_FIRST + 25;   // rect of item's drop down button
  HDM_GETOVERFLOWRECT         = HDM_FIRST + 26;   // rect of overflow button
  HDM_GETFOCUSEDITEM          = HDM_FIRST + 27;
  HDM_SETFOCUSEDITEM          = HDM_FIRST + 28;

function Header_GetItemRect(hwnd: HWND; iItem: Integer; lprc: PRect): Integer; {inline;}
function Header_SetImageList(hwnd: HWND; himl: HIMAGELIST): HIMAGELIST; {inline;}
function Header_GetImageList(hwnd: HWND): HIMAGELIST; {inline;}
function Header_OrderToIndex(hwnd: HWND; i: Integer): Integer; {inline;}
function Header_CreateDragImage(hwnd: HWND; i: Integer): HIMAGELIST; {inline;}
function Header_GetOrderArray(hwnd: HWND; iCount: Integer; lpi: PInteger): Integer; {inline;}
function Header_SetOrderArray(hwnd: HWND; iCount: Integer; lpi: PInteger): Integer; {inline;}

// lparam = int array of size HDM_GETITEMCOUNT
// the array specifies the order that all items should be displayed.
// e.g.  { 2, 0, 1}
// says the index 2 item should be shown in the 0ths position
//      index 0 should be shown in the 1st position
//      index 1 should be shown in the 2nd position

function Header_SetHotDivider(hwnd: HWND; fPos: BOOL; dw: DWORD): Integer; {inline;}

// convenience message for external dragdrop
// wParam = BOOL  specifying whether the lParam is a dwPos of the cursor
//              position or the index of which divider to hotlight
// lParam = depends on wParam  (-1 and wParm = FALSE turns off hotlight)

function Header_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): Integer; {inline;}
function Header_GetUnicodeFormat(hwnd: HWND): Integer; {inline;}

{ For IE >= 0x0500 }
function Header_SetBitmapMargin(hwnd: HWND; iWidth: Integer): Integer; {inline;}
function Header_GetBitmapMargin(hwnd: HWND): Integer; {inline;}
function Header_SetFilterChangeTimeout(hwnd: HWND; i: Integer): Integer; {inline;}
function Header_EditFilter(hwnd: HWND; i: Integer; fDiscardChanges: BOOL): Integer; {inline;}
function Header_ClearFilter(hwnd: HWND; i: Integer): Integer; {inline;}
function Header_ClearAllFilters(hwnd: HWND): Integer; {inline;}

{ For Windows >= Vista}
function Header_GetItemDropDownRect(hwnd: HWND; iItem: Integer; var lprc: TRect): BOOL; {inline;}
function Header_GetOverflowRect(hwnd: HWND; var lprc: TRect): BOOL; {inline;}
function Header_GetFocusedItem(hwnd: HWND): Integer; {inline;}
function Header_SetFocusedItem(hwnd: HWND; iItem: Integer): BOOL; {inline;}

const
  HDN_ITEMCHANGINGA        = HDN_FIRST-0;
  HDN_ITEMCHANGEDA         = HDN_FIRST-1;
  HDN_ITEMCLICKA           = HDN_FIRST-2;
  HDN_ITEMDBLCLICKA        = HDN_FIRST-3;
  HDN_DIVIDERDBLCLICKA     = HDN_FIRST-5;
  HDN_BEGINTRACKA          = HDN_FIRST-6;
  HDN_ENDTRACKA            = HDN_FIRST-7;
  HDN_TRACKA               = HDN_FIRST-8;
  HDN_GETDISPINFOA         = HDN_FIRST-9;
  HDN_BEGINDRAG            = HDN_FIRST-10;
  HDN_ENDDRAG              = HDN_FIRST-11;

  { For IE >= 0x0500 }
  HDN_FILTERCHANGE         = HDN_FIRST-12;
  HDN_FILTERBTNCLICK       = HDN_FIRST-13;

  { For IE >= 0x0600 }
  HDN_BEGINFILTEREDIT      = HDN_FIRST-14;
  HDN_ENDFILTEREDIT        = HDN_FIRST-15;

  { For Windows >= Vista }
  HDN_ITEMSTATEICONCLICK   = HDN_FIRST-16;
  HDN_ITEMKEYDOWN          = HDN_FIRST-17;
  HDN_DROPDOWN             = HDN_FIRST-18;
  HDN_OVERFLOWCLICK        = HDN_FIRST-19;

  HDN_ITEMCHANGINGW        = HDN_FIRST-20;
  HDN_ITEMCHANGEDW         = HDN_FIRST-21;
  HDN_ITEMCLICKW           = HDN_FIRST-22;
  HDN_ITEMDBLCLICKW        = HDN_FIRST-23;
  HDN_DIVIDERDBLCLICKW     = HDN_FIRST-25;
  HDN_BEGINTRACKW          = HDN_FIRST-26;
  HDN_ENDTRACKW            = HDN_FIRST-27;
  HDN_TRACKW               = HDN_FIRST-28;
  HDN_GETDISPINFOW         = HDN_FIRST-29;

{$IFDEF UNICODE}
  HDN_ITEMCHANGING        = HDN_ITEMCHANGINGW;
  HDN_ITEMCHANGED         = HDN_ITEMCHANGEDW;
  HDN_ITEMCLICK           = HDN_ITEMCLICKW;
  HDN_ITEMDBLCLICK        = HDN_ITEMDBLCLICKW;
  HDN_DIVIDERDBLCLICK     = HDN_DIVIDERDBLCLICKW;
  HDN_BEGINTRACK          = HDN_BEGINTRACKW;
  HDN_ENDTRACK            = HDN_ENDTRACKW;
  HDN_TRACK               = HDN_TRACKW;
  HDN_GETDISPINFO         = HDN_GETDISPINFOW;
{$ELSE}
  HDN_ITEMCHANGING        = HDN_ITEMCHANGINGA;
  HDN_ITEMCHANGED         = HDN_ITEMCHANGEDA;
  HDN_ITEMCLICK           = HDN_ITEMCLICKA;
  HDN_ITEMDBLCLICK        = HDN_ITEMDBLCLICKA;
  HDN_DIVIDERDBLCLICK     = HDN_DIVIDERDBLCLICKA;
  HDN_BEGINTRACK          = HDN_BEGINTRACKA;
  HDN_ENDTRACK            = HDN_ENDTRACKA;
  HDN_TRACK               = HDN_TRACKA;
  HDN_GETDISPINFO         = HDN_GETDISPINFOA;
{$ENDIF}

type
  tagNMHEADERA = packed record
    Hdr: TNMHdr;
    Item: Integer;
    Button: Integer;
    PItem: PHDItemA;
  end;
  tagNMHEADERW = packed record
    Hdr: TNMHdr;
    Item: Integer;
    Button: Integer;
    PItem: PHDItemW;
  end;
  tagNMHEADER = tagNMHEADERW;
  HD_NOTIFYA = tagNMHEADERA;
  HD_NOTIFYW = tagNMHEADERW;
  HD_NOTIFY = HD_NOTIFYW;
  PHDNotifyA = ^THDNotifyA;
  PHDNotifyW = ^THDNotifyW;
  PHDNotify = PHDNotifyW;
  THDNotifyA = tagNMHEADERA;
  THDNotifyW = tagNMHEADERW;
  THDNotify = THDNotifyW;

  tagNMHDDISPINFOA = record
    hdr: TNMHdr;
    iItem: Integer;
    mask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  tagNMHDDISPINFOW = record
    hdr: TNMHdr;
    iItem: Integer;
    mask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  tagNMHDDISPINFO = tagNMHDDISPINFOW;
  PNMHDispInfoA = ^TNMHDispInfoA;
  PNMHDispInfoW = ^TNMHDispInfoW;
  PNMHDispInfo = PNMHDispInfoW;
  TNMHDispInfoA = tagNMHDDISPINFOA;
  TNMHDispInfoW = tagNMHDDISPINFOW;
  TNMHDispInfo = TNMHDispInfoW;


{ ====== TOOLBAR CONTROL =================== }

const
  TOOLBARCLASSNAME = 'ToolbarWindow32';

type
  PTBButton = ^TTBButton;
  _TBBUTTON = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte;
    dwData: Longint;
    iString: Integer;
  end;
  TTBButton = _TBBUTTON;

  PColorMap = ^TColorMap;
  _COLORMAP = packed record
    cFrom: TColorRef;
    cTo: TColorRef;
  end;
  TColorMap = _COLORMAP;
  COLORMAP = _COLORMAP;

function CreateToolBarEx(Wnd: HWnd; ws: Longint; ID: UINT;
  Bitmaps: Integer; BMInst: THandle; BMID: Cardinal; Buttons: PTBButton;
  NumButtons: Integer; dxButton, dyButton: Integer;
  dxBitmap, dyBitmap: Integer; StructSize: UINT): HWnd; stdcall;

function CreateMappedBitmap(Instance: THandle; Bitmap: Integer;
  Flags: UINT; ColorMap: PColorMap; NumMaps: Integer): HBitmap; stdcall;

const

  CMB_MASKED              = $02;

  TBSTATE_CHECKED         = $01;
  TBSTATE_PRESSED         = $02;
  TBSTATE_ENABLED         = $04;
  TBSTATE_HIDDEN          = $08;
  TBSTATE_INDETERMINATE   = $10;
  TBSTATE_WRAP            = $20;
  TBSTATE_ELLIPSES        = $40;
  TBSTATE_MARKED          = $80;

  TBSTYLE_BUTTON          = $00;
  TBSTYLE_SEP             = $01;
  TBSTYLE_CHECK           = $02;
  TBSTYLE_GROUP           = $04;
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  TBSTYLE_DROPDOWN        = $08;
  TBSTYLE_AUTOSIZE        = $0010; // automatically calculate the cx of the button
  TBSTYLE_NOPREFIX        = $0020; // if this button should not have accel prefix

  TBSTYLE_TOOLTIPS        = $0100;
  TBSTYLE_WRAPABLE        = $0200;
  TBSTYLE_ALTDRAG         = $0400;
  TBSTYLE_FLAT            = $0800;
  TBSTYLE_LIST            = $1000;
  TBSTYLE_CUSTOMERASE     = $2000;
  TBSTYLE_REGISTERDROP    = $4000;
  TBSTYLE_TRANSPARENT     = $8000;
  TBSTYLE_EX_DRAWDDARROWS = $00000001;

  { For IE >= 0x0500 }
  BTNS_BUTTON             = TBSTYLE_BUTTON;
  BTNS_SEP                = TBSTYLE_SEP;
  BTNS_CHECK              = TBSTYLE_CHECK;
  BTNS_GROUP              = TBSTYLE_GROUP;
  BTNS_CHECKGROUP         = TBSTYLE_CHECKGROUP;
  BTNS_DROPDOWN           = TBSTYLE_DROPDOWN;
  BTNS_AUTOSIZE           = TBSTYLE_AUTOSIZE;
  BTNS_NOPREFIX           = TBSTYLE_NOPREFIX;
  { For IE >= 0x0501 }
  BTNS_SHOWTEXT           = $0040;  // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set

  { For IE >= 0x0500 }
  BTNS_WHOLEDROPDOWN      = $0080;  // draw drop-down arrow, but without split arrow section

  { For IE >= 0x0501 }
  TBSTYLE_EX_MIXEDBUTTONS = $00000008;
  TBSTYLE_EX_HIDECLIPPEDBUTTONS = $00000010;  // don't show partially obscured buttons

  { For Windows >= XP }
  TBSTYLE_EX_DOUBLEBUFFER = $00000080; // Double Buffer the toolbar

type
  // Custom Draw Structure
  _NMTBCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    hbrMonoDither: HBRUSH;
    hbrLines: HBRUSH;                // For drawing lines on buttons
    hpenLines: HPEN;                 // For drawing lines on buttons
    clrText: COLORREF;               // Color of text
    clrMark: COLORREF;               // Color of text bk when marked. (only if TBSTATE_MARKED)
    clrTextHighlight: COLORREF;      // Color of text when highlighted
    clrBtnFace: COLORREF;            // Background of the button
    clrBtnHighlight: COLORREF;       // 3D highlight
    clrHighlightHotTrack: COLORREF;  // In conjunction with fHighlightHotTrack
                                     // will cause button to highlight like a menu
    rcText: TRect;                   // Rect for text
    nStringBkMode: Integer;
    nHLStringBkMode: Integer;
                                      
    { For Windows >= XP }
    //iListGap: Integer;
  end;
  PNMTBCustomDraw = ^TNMTBCustomDraw;
  TNMTBCustomDraw = _NMTBCUSTOMDRAW;

const
  // Toolbar custom draw return flags
  TBCDRF_NOEDGES              = $00010000;  // Don't draw button edges
  TBCDRF_HILITEHOTTRACK       = $00020000;  // Use color of the button bk when hottracked
  TBCDRF_NOOFFSET             = $00040000;  // Don't offset button if pressed
  TBCDRF_NOMARK               = $00080000;  // Don't draw default highlight of image/text for TBSTATE_MARKED
  TBCDRF_NOETCHEDEFFECT       = $00100000;  // Don't draw etched effect for disabled items

  { For IE >= 0x0500 }
  TBCDRF_BLENDICON            = $00200000;  // Use ILD_BLEND50 on the icon image
  TBCDRF_NOBACKGROUND         = $00400000;  // Use ILD_BLEND50 on the icon image

  { For Windows >= Vista }
  TBCDRF_USECDCOLORS          = $00800000;  // Use CustomDrawColors to RenderText regardless of VisualStyle

  TB_ENABLEBUTTON         = WM_USER + 1;
  TB_CHECKBUTTON          = WM_USER + 2;
  TB_PRESSBUTTON          = WM_USER + 3;
  TB_HIDEBUTTON           = WM_USER + 4;
  TB_INDETERMINATE        = WM_USER + 5;
  TB_MARKBUTTON           = WM_USER + 6;
  TB_ISBUTTONENABLED      = WM_USER + 9;
  TB_ISBUTTONCHECKED      = WM_USER + 10;
  TB_ISBUTTONPRESSED      = WM_USER + 11;
  TB_ISBUTTONHIDDEN       = WM_USER + 12;
  TB_ISBUTTONINDETERMINATE = WM_USER + 13;
  TB_ISBUTTONHIGHLIGHTED   = WM_USER + 14;
  TB_SETSTATE             = WM_USER + 17;
  TB_GETSTATE             = WM_USER + 18;
  TB_ADDBITMAP            = WM_USER + 19;

type
  PTBAddBitmap = ^TTBAddBitmap;
  tagTBADDBITMAP = packed record
    hInst: THandle;
    nID: UINT;
  end;
  TTBAddBitmap = tagTBADDBITMAP;
  TBADDBITMAP = tagTBADDBITMAP;

const
  HINST_COMMCTRL = THandle(-1);

  IDB_STD_SMALL_COLOR     = 0;
  IDB_STD_LARGE_COLOR     = 1;
  IDB_VIEW_SMALL_COLOR    = 4;
  IDB_VIEW_LARGE_COLOR    = 5;
  IDB_HIST_SMALL_COLOR    = 8;
  IDB_HIST_LARGE_COLOR    = 9;

{ icon indexes for standard bitmap }
  STD_CUT                 = 0;
  STD_COPY                = 1;
  STD_PASTE               = 2;
  STD_UNDO                = 3;
  STD_REDOW               = 4;
  STD_DELETE              = 5;
  STD_FILENEW             = 6;
  STD_FILEOPEN            = 7;
  STD_FILESAVE            = 8;
  STD_PRINTPRE            = 9;
  STD_PROPERTIES          = 10;
  STD_HELP                = 11;
  STD_FIND                = 12;
  STD_REPLACE             = 13;
  STD_PRINT               = 14;

{ icon indexes for standard view bitmap }

  VIEW_LARGEICONS         = 0;
  VIEW_SMALLICONS         = 1;
  VIEW_LIST               = 2;
  VIEW_DETAILS            = 3;
  VIEW_SORTNAME           = 4;
  VIEW_SORTSIZE           = 5;
  VIEW_SORTDATE           = 6;
  VIEW_SORTTYPE           = 7;
  VIEW_PARENTFOLDER       = 8;
  VIEW_NETCONNECT         = 9;
  VIEW_NETDISCONNECT      = 10;
  VIEW_NEWFOLDER          = 11;
  VIEW_VIEWMENU           = 12;

{ icon indexes for history bitmap }

  HIST_BACK               = 0;
  HIST_FORWARD            = 1;
  HIST_FAVORITES          = 2;
  HIST_ADDTOFAVORITES     = 3;
  HIST_VIEWTREE           = 4;

  TB_ADDBUTTONSA          = WM_USER + 20;
  TB_INSERTBUTTONA        = WM_USER + 21;
  TB_DELETEBUTTON         = WM_USER + 22;
  TB_GETBUTTON            = WM_USER + 23;
  TB_BUTTONCOUNT          = WM_USER + 24;
  TB_COMMANDTOINDEX       = WM_USER + 25;

type
  PTBSaveParamsA = ^TTBSaveParamsA;
  PTBSaveParamsW = ^TTBSaveParamsW;
  PTBSaveParams = PTBSaveParamsW;
  tagTBSAVEPARAMSA = record
    hkr: THandle;
    pszSubKey: PAnsiChar;
    pszValueName: PAnsiChar;
  end;
  tagTBSAVEPARAMSW = record
    hkr: THandle;
    pszSubKey: PWideChar;
    pszValueName: PWideChar;
  end;
  tagTBSAVEPARAMS = tagTBSAVEPARAMSW;
  TTBSaveParamsA = tagTBSAVEPARAMSA;
  TTBSaveParamsW = tagTBSAVEPARAMSW;
  TTBSaveParams = TTBSaveParamsW;
  TBSAVEPARAMSA = tagTBSAVEPARAMSA;
  TBSAVEPARAMSW = tagTBSAVEPARAMSW;
  TBSAVEPARAMS = TBSAVEPARAMSW;

const
  TB_SAVERESTOREA          = WM_USER + 26;
  TB_ADDSTRINGA            = WM_USER + 28;
  TB_GETBUTTONTEXTA        = WM_USER + 45;
  TBN_GETBUTTONINFOA       = TBN_FIRST-0;

  TB_SAVERESTOREW          = WM_USER + 76;
  TB_ADDSTRINGW            = WM_USER + 77;
  TB_GETBUTTONTEXTW        = WM_USER + 75;
  TBN_GETBUTTONINFOW       = TBN_FIRST-20;

{$IFDEF UNICODE}
  TB_SAVERESTORE          = TB_SAVERESTOREW;
  TB_ADDSTRING            = TB_ADDSTRINGW;
  TB_GETBUTTONTEXT        = TB_GETBUTTONTEXTW;
  TBN_GETBUTTONINFO       = TBN_GETBUTTONINFOW;
{$ELSE}
  TB_SAVERESTORE          = TB_SAVERESTOREA;
  TB_ADDSTRING            = TB_ADDSTRINGA;
  TB_GETBUTTONTEXT        = TB_GETBUTTONTEXTA;
  TBN_GETBUTTONINFO       = TBN_GETBUTTONINFOA;
{$ENDIF}

  TB_CUSTOMIZE            = WM_USER + 27;
  TB_GETITEMRECT          = WM_USER + 29;
  TB_BUTTONSTRUCTSIZE     = WM_USER + 30;
  TB_SETBUTTONSIZE        = WM_USER + 31;
  TB_SETBITMAPSIZE        = WM_USER + 32;
  TB_AUTOSIZE             = WM_USER + 33;
  TB_GETTOOLTIPS          = WM_USER + 35;
  TB_SETTOOLTIPS          = WM_USER + 36;
  TB_SETPARENT            = WM_USER + 37;
  TB_SETROWS              = WM_USER + 39;
  TB_GETROWS              = WM_USER + 40;
  TB_SETCMDID             = WM_USER + 42;
  TB_CHANGEBITMAP         = WM_USER + 43;
  TB_GETBITMAP            = WM_USER + 44;
  TB_REPLACEBITMAP        = WM_USER + 46;
  TB_SETINDENT            = WM_USER + 47;
  TB_SETIMAGELIST         = WM_USER + 48;
  TB_GETIMAGELIST         = WM_USER + 49;
  TB_LOADIMAGES           = WM_USER + 50;
  TB_GETRECT              = WM_USER + 51; { wParam is the Cmd instead of index }
  TB_SETHOTIMAGELIST      = WM_USER + 52;
  TB_GETHOTIMAGELIST      = WM_USER + 53;
  TB_SETDISABLEDIMAGELIST = WM_USER + 54;
  TB_GETDISABLEDIMAGELIST = WM_USER + 55;
  TB_SETSTYLE             = WM_USER + 56;
  TB_GETSTYLE             = WM_USER + 57;
  TB_GETBUTTONSIZE        = WM_USER + 58;
  TB_SETBUTTONWIDTH       = WM_USER + 59;
  TB_SETMAXTEXTROWS       = WM_USER + 60;
  TB_GETTEXTROWS          = WM_USER + 61;

  TB_GETOBJECT            = WM_USER + 62;  // wParam == IID, lParam void **ppv
  TB_GETHOTITEM           = WM_USER + 71;
  TB_SETHOTITEM           = WM_USER + 72;  // wParam == iHotItem
  TB_SETANCHORHIGHLIGHT   = WM_USER + 73;  // wParam == TRUE/FALSE
  TB_GETANCHORHIGHLIGHT   = WM_USER + 74;
  TB_MAPACCELERATORA      = WM_USER + 78;  // wParam == ch, lParam int * pidBtn

type
  TBINSERTMARK = packed record
    iButton: Integer;
    dwFlags: DWORD;
  end;
  PTBInsertMark = ^TTBInsertMark;
  TTBInsertMark = TBINSERTMARK;

const
  TBIMHT_AFTER      = $00000001; // TRUE = insert After iButton, otherwise before
  TBIMHT_BACKGROUND = $00000002; // TRUE iff missed buttons completely

  TB_GETINSERTMARK        = WM_USER + 79;  // lParam == LPTBINSERTMARK
  TB_SETINSERTMARK        = WM_USER + 80;  // lParam == LPTBINSERTMARK
  TB_INSERTMARKHITTEST    = WM_USER + 81;  // wParam == LPPOINT lParam == LPTBINSERTMARK
  TB_MOVEBUTTON           = WM_USER + 82;
  TB_GETMAXSIZE           = WM_USER + 83;  // lParam == LPSIZE
  TB_SETEXTENDEDSTYLE     = WM_USER + 84;  // For TBSTYLE_EX_*
  TB_GETEXTENDEDSTYLE     = WM_USER + 85;  // For TBSTYLE_EX_*
  TB_GETPADDING           = WM_USER + 86;
  TB_SETPADDING           = WM_USER + 87;
  TB_SETINSERTMARKCOLOR   = WM_USER + 88;
  TB_GETINSERTMARKCOLOR   = WM_USER + 89;

  TB_SETCOLORSCHEME       = CCM_SETCOLORSCHEME;  // lParam is color scheme
  TB_GETCOLORSCHEME       = CCM_GETCOLORSCHEME;	// fills in COLORSCHEME pointed to by lParam

  TB_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;
  TB_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

  TB_MAPACCELERATORW      = WM_USER + 90;  // wParam == ch, lParam int * pidBtn
{$IFDEF UNICODE}
  TB_MAPACCELERATOR       = TB_MAPACCELERATORW;
{$ELSE}
  TB_MAPACCELERATOR       = TB_MAPACCELERATORA;
{$ENDIF}

type
  TBREPLACEBITMAP = packed record
    hInstOld: THandle;
    nIDOld: Cardinal;
    hInstNew: THandle;
    nIDNew: Cardinal;
    nButtons: Integer;
  end;
  PTBReplaceBitmap = ^TTBReplaceBitmap;
  TTBReplaceBitmap = TBREPLACEBITMAP;

const
  TBBF_LARGE              = $0001;

  TB_GETBITMAPFLAGS       = WM_USER + 41;

  TBIF_IMAGE              = $00000001;
  TBIF_TEXT               = $00000002;
  TBIF_STATE              = $00000004;
  TBIF_STYLE              = $00000008;
  TBIF_LPARAM             = $00000010;
  TBIF_COMMAND            = $00000020;
  TBIF_SIZE               = $00000040;
  TBIF_BYINDEX            = $80000000;

type
  TBBUTTONINFOA = record
    cbSize: UINT;
    dwMask: DWORD;
    idCommand: Integer;
    iImage: Integer;
    fsState: Byte;
    fsStyle: Byte;
    cx: Word;
    lParam: DWORD;
    pszText: PAnsiChar;
    cchText: Integer;
  end;
  TBBUTTONINFOW = record
    cbSize: UINT;
    dwMask: DWORD;
    idCommand: Integer;
    iImage: Integer;
    fsState: Byte;
    fsStyle: Byte;
    cx: Word;
    lParam: DWORD;
    pszText: PWideChar;
    cchText: Integer;
  end;
  TBBUTTONINFO = TBBUTTONINFOW;
  PTBButtonInfoA = ^TTBButtonInfoA;
  PTBButtonInfoW = ^TTBButtonInfoW;
  PTBButtonInfo = PTBButtonInfoW;
  TTBButtonInfoA = TBBUTTONINFOA;
  TTBButtonInfoW = TBBUTTONINFOW;
  TTBButtonInfo = TTBButtonInfoW;

const
  // BUTTONINFO APIs do NOT support the string pool.
  TB_GETBUTTONINFOW        = WM_USER + 63;
  TB_SETBUTTONINFOW        = WM_USER + 64;
  TB_GETBUTTONINFOA        = WM_USER + 65;
  TB_SETBUTTONINFOA        = WM_USER + 66;
{$IFDEF UNICODE}
  TB_GETBUTTONINFO         = TB_GETBUTTONINFOW;
  TB_SETBUTTONINFO         = TB_SETBUTTONINFOW;
{$ELSE}
  TB_GETBUTTONINFO         = TB_GETBUTTONINFOA;
  TB_SETBUTTONINFO         = TB_SETBUTTONINFOA;
{$ENDIF}

  TB_INSERTBUTTONW        = WM_USER + 67;
  TB_ADDBUTTONSW          = WM_USER + 68;

  TB_HITTEST              = WM_USER + 69;

  // New post Win95/NT4 for InsertButton and AddButton.  if iString member
  // is a pointer to a string, it will be handled as a string like listview
  // = although LPSTR_TEXTCALLBACK is not supported;.
{$IFDEF UNICODE}
  TB_INSERTBUTTON         = TB_INSERTBUTTONW;
  TB_ADDBUTTONS           = TB_ADDBUTTONSW;
{$ELSE}
  TB_INSERTBUTTON         = TB_INSERTBUTTONA;
  TB_ADDBUTTONS           = TB_ADDBUTTONSA;
{$ENDIF}

  TB_SETDRAWTEXTFLAGS     = WM_USER + 70;  // wParam == mask lParam == bit values

  TB_GETSTRINGW           = WM_USER + 91;
  TB_GETSTRINGA           = WM_USER + 92;
{$IFDEF UNICODE}
  TB_GETSTRING            = TB_GETSTRINGW;
{$ELSE}
  TB_GETSTRING            = TB_GETSTRINGA;
{$ENDIF}

  { For Windows >= XP }
  TBMF_PAD                = $00000001;
  TBMF_BARPAD             = $00000002;
  TBMF_BUTTONSPACING      = $00000004;

type
  { For Windows >= XP }
  { $EXTERNALSYM TBMETRICSA}
  TBMETRICSA = packed record
    cbSize: Integer;
    dwMask: DWORD;

    cxPad: Integer;   { PAD }
    cyPad: Integer;
    cxBarPad: Integer;{ BARPAD }
    cyBarPad: Integer;
    cxButtonSpacing: Integer;{ BUTTONSPACING }
    cyButtonSpacing: Integer;
  end;
  { $EXTERNALSYM TBMETRICSW}
  TBMETRICSW = packed record
    cbSize: Integer;
    dwMask: DWORD;

    cxPad: Integer;   { PAD }
    cyPad: Integer;
    cxBarPad: Integer;{ BARPAD }
    cyBarPad: Integer;
    cxButtonSpacing: Integer;{ BUTTONSPACING }
    cyButtonSpacing: Integer;
  end;
  TBMETRICS = TBMETRICSW;
  PTBMetricsA = ^TTBMetricsA;
  PTBMetricsW = ^TTBMetricsW;
  PTBMetrics = PTBMetricsW;
  TTBMetricsA = TBMETRICSA;
  TTBMetricsW = TBMETRICSW;
  TTBMetrics = TTBMetricsW;

const
  { For Windows >= XP }
  TB_GETMETRICS           = WM_USER + 101;
  TB_SETMETRICS           = WM_USER + 102;

  { For Windows >= Vista }
  TB_SETPRESSEDIMAGELIST  = WM_USER + 104;
  TB_GETPRESSEDIMAGELIST  = WM_USER + 105;

  { For Windows >= XP }
  TB_SETWINDOWTHEME       = CCM_SETWINDOWTHEME;

const
  TBN_BEGINDRAG           = TBN_FIRST-1;
  TBN_ENDDRAG             = TBN_FIRST-2;
  TBN_BEGINADJUST         = TBN_FIRST-3;
  TBN_ENDADJUST           = TBN_FIRST-4;
  TBN_RESET               = TBN_FIRST-5;
  TBN_QUERYINSERT         = TBN_FIRST-6;
  TBN_QUERYDELETE         = TBN_FIRST-7;
  TBN_TOOLBARCHANGE       = TBN_FIRST-8;
  TBN_CUSTHELP            = TBN_FIRST-9;
  TBN_DROPDOWN            = TBN_FIRST-10;
  TBN_CLOSEUP             = TBN_FIRST-11;
  TBN_GETOBJECT           = TBN_FIRST-12;
  TBN_RESTORE             = TBN_FIRST-21;
  TBN_SAVE                = TBN_FIRST-22;


type
  // Structure for TBN_HOTITEMCHANGE notification
  tagNMTBHOTITEM = packed record
    hdr: TNMHdr;
    idOld: Integer;
    idNew: Integer;
    dwFlags: DWORD;           // HICF_*
  end;
  PNMTBHotItem = ^TNMTBHotItem;
  TNMTBHotItem = tagNMTBHOTITEM;

const
  // Hot item change flags
  HICF_OTHER          = $00000000;
  HICF_MOUSE          = $00000001;          // Triggered by mouse
  HICF_ARROWKEYS      = $00000002;          // Triggered by arrow keys
  HICF_ACCELERATOR    = $00000004;          // Triggered by accelerator
  HICF_DUPACCEL       = $00000008;          // This accelerator is not unique
  HICF_ENTERING       = $00000010;          // idOld is invalid
  HICF_LEAVING        = $00000020;          // idNew is invalid
  HICF_RESELECT       = $00000040;          // hot item reselected

  TBN_HOTITEMCHANGE       = TBN_FIRST - 13;
  TBN_DRAGOUT             = TBN_FIRST - 14; // this is sent when the user clicks down on a button then drags off the button
  TBN_DELETINGBUTTON      = TBN_FIRST - 15; // uses TBNOTIFY
  TBN_GETDISPINFOA        = TBN_FIRST - 16; // This is sent when the  toolbar needs  some display information
  TBN_GETDISPINFOW        = TBN_FIRST - 17; // This is sent when the  toolbar needs  some display information
  TBN_GETINFOTIPA         = TBN_FIRST - 18;
  TBN_GETINFOTIPW         = TBN_FIRST - 19;

type
  tagNMTBGETINFOTIPA = record
    hdr: TNMHdr;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iItem: Integer;
    lParam: LPARAM;
  end;
  tagNMTBGETINFOTIPW = record
    hdr: TNMHdr;
    pszText: PWideChar;
    cchTextMax: Integer;
    iItem: Integer;
    lParam: LPARAM;
  end;
  tagNMTBGETINFOTIP = tagNMTBGETINFOTIPW;
  PNMTBGetInfoTipA = ^TNMTBGetInfoTipA;
  PNMTBGetInfoTipW = ^TNMTBGetInfoTipW;
  PNMTBGetInfoTip = PNMTBGetInfoTipW;
  TNMTBGetInfoTipA = tagNMTBGETINFOTIPA;
  TNMTBGetInfoTipW = tagNMTBGETINFOTIPW;
  TNMTBGetInfoTip = TNMTBGetInfoTipW;

const
  TBNF_IMAGE              = $00000001;
  TBNF_TEXT               = $00000002;
  TBNF_DI_SETITEM         = $10000000;

type
  NMTBDISPINFOA = record
    hdr: TNMHdr;
    dwMask: DWORD;      // [in] Specifies the values requested .[out] Client ask the data to be set for future use
    idCommand: Integer; // [in] id of button we're requesting info for
    lParam: DWORD;      // [in] lParam of button
    iImage: Integer;    // [out] image index
    pszText: PAnsiChar;    // [out] new text for item
    cchText: Integer;   // [in] size of buffer pointed to by pszText
  end;
  NMTBDISPINFOW = record
    hdr: TNMHdr;
    dwMask: DWORD;      // [in] Specifies the values requested .[out] Client ask the data to be set for future use
    idCommand: Integer; // [in] id of button we're requesting info for
    lParam: DWORD;      // [in] lParam of button
    iImage: Integer;    // [out] image index
    pszText: PWideChar;    // [out] new text for item
    cchText: Integer;   // [in] size of buffer pointed to by pszText
  end;
  NMTBDISPINFO = NMTBDISPINFOW;
  PNMTBDispInfoA = ^TNMTBDispInfoA;
  PNMTBDispInfoW = ^TNMTBDispInfoW;
  PNMTBDispInfo = PNMTBDispInfoW;
  TNMTBDispInfoA = NMTBDISPINFOA;
  TNMTBDispInfoW = NMTBDISPINFOW;
  TNMTBDispInfo = TNMTBDispInfoW;

const
  // Return codes for TBN_DROPDOWN
  TBDDRET_DEFAULT         = 0;
  TBDDRET_NODEFAULT       = 1;
  TBDDRET_TREATPRESSED    = 2;       // Treat as a standard press button

type
  tagNMTOOLBARA = record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PAnsiChar;
  end;
  tagNMTOOLBARW = record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PWideChar;
  end;
  tagNMTOOLBAR = tagNMTOOLBARW;
  PNMToolBarA = ^TNMToolBarA;
  PNMToolBarW = ^TNMToolBarW;
  PNMToolBar = PNMToolBarW;
  TNMToolBarA = tagNMTOOLBARA;
  TNMToolBarW = tagNMTOOLBARW;
  TNMToolBar = TNMToolBarW;

{ ====== REBAR CONTROL =================== }

const
  REBARCLASSNAME = 'ReBarWindow32';

type
  tagREBARINFO = packed record
    cbSize: UINT;
    fMask: UINT;
    himl: HIMAGELIST;
  end;
  PReBarInfo = ^TReBarInfo;
  TReBarInfo = tagREBARINFO;

const
  RBIM_IMAGELIST    = $00000001;

  RBS_TOOLTIPS      = $00000100;
  RBS_VARHEIGHT     = $00000200;
  RBS_BANDBORDERS   = $00000400;
  RBS_FIXEDORDER    = $00000800;

  RBS_REGISTERDROP  = $00001000;
  RBS_AUTOSIZE      = $00002000;
  RBS_VERTICALGRIPPER = $00004000;  // this always has the vertical gripper (default for horizontal mode)
  RBS_DBLCLKTOGGLE  = $00008000;

  RBBS_BREAK        = $00000001;  // break to new line
  RBBS_FIXEDSIZE    = $00000002;  // band can't be sized
  RBBS_CHILDEDGE    = $00000004;  // edge around top and bottom of child window
  RBBS_HIDDEN       = $00000008;  // don't show
  RBBS_NOVERT       = $00000010;  // don't show when vertical
  RBBS_FIXEDBMP     = $00000020;  // bitmap doesn't move during band resize
  RBBS_VARIABLEHEIGHT = $00000040;  // allow autosizing of this child vertically
  RBBS_GRIPPERALWAYS  = $00000080;  // always show the gripper
  RBBS_NOGRIPPER      = $00000100;  // never show the gripper
  { For IE >= 0x0500 }
  RBBS_USECHEVRON     = $00000200;  { display drop-down button for this band if it's sized smaller than ideal width }
  { For IE >= 0x0501 }
  RBBS_HIDETITLE      = $00000400;  { keep band title hidden }
  RBBS_TOPALIGN       = $00000800;  { keep band in top row }

  RBBIM_STYLE       = $00000001;
  RBBIM_COLORS      = $00000002;
  RBBIM_TEXT        = $00000004;
  RBBIM_IMAGE       = $00000008;
  RBBIM_CHILD       = $00000010;
  RBBIM_CHILDSIZE   = $00000020;
  RBBIM_SIZE        = $00000040;
  RBBIM_BACKGROUND  = $00000080;
  RBBIM_ID          = $00000100;
  RBBIM_IDEALSIZE     = $00000200;
  RBBIM_LPARAM        = $00000400;
  RBBIM_HEADERSIZE    = $00000800;  // control the size of the header
  { For Windows >= Vista }
  RBBIM_CHEVRONLOCATION = $00001000;
  RBBIM_CHEVRONSTATE    = $00002000;

type
  tagREBARBANDINFOA = record
    cbSize: UINT;
    fMask: UINT;
    fStyle: UINT;
    clrFore: TColorRef;
    clrBack: TColorRef;
    lpText: PAnsiChar;
    cch: UINT;
    iImage: Integer;
    hwndChild: HWnd;
    cxMinChild: UINT;
    cyMinChild: UINT;
    cx: UINT;
    hbmBack: HBitmap;
    wID: UINT;
    cyChild: UINT;
    cyMaxChild: UINT;
    cyIntegral: UINT;
    cxIdeal: UINT;
    lParam: LPARAM;
    cxHeader: UINT;
                                                            
    //rcChevronLocation: TRect;       // the rect is in client co-ord wrt hwndChild
    //uChevronState: UINT;            // STATE_SYSTEM_*
  end;
  tagREBARBANDINFOW = record
    cbSize: UINT;
    fMask: UINT;
    fStyle: UINT;
    clrFore: TColorRef;
    clrBack: TColorRef;
    lpText: PWideChar;
    cch: UINT;
    iImage: Integer;
    hwndChild: HWnd;
    cxMinChild: UINT;
    cyMinChild: UINT;
    cx: UINT;
    hbmBack: HBitmap;
    wID: UINT;
    cyChild: UINT;
    cyMaxChild: UINT;
    cyIntegral: UINT;
    cxIdeal: UINT;
    lParam: LPARAM;
    cxHeader: UINT;
                                                            
    //rcChevronLocation: TRect;       // the rect is in client co-ord wrt hwndChild
    //uChevronState: UINT;            // STATE_SYSTEM_*
  end;
  tagREBARBANDINFO = tagREBARBANDINFOW;
  PReBarBandInfoA = ^TReBarBandInfoA;
  PReBarBandInfoW = ^TReBarBandInfoW;
  PReBarBandInfo = PReBarBandInfoW;
  TReBarBandInfoA = tagREBARBANDINFOA;
  TReBarBandInfoW = tagREBARBANDINFOW;
  TReBarBandInfo = TReBarBandInfoW;

                               
(*const
  REBARBANDINFOA_V3_SIZE = CCSIZEOF_STRUCT(REBARBANDINFOA, wID);
  REBARBANDINFOW_V3_SIZE = CCSIZEOF_STRUCT(REBARBANDINFOW, wID);

  REBARBANDINFOA_V6_SIZE = CCSIZEOF_STRUCT(REBARBANDINFOA, cxHeader);
  REBARBANDINFOW_V6_SIZE = CCSIZEOF_STRUCT(REBARBANDINFOW, cxHeader); *)

const
  RB_INSERTBANDA     = WM_USER +  1;
  RB_DELETEBAND      = WM_USER +  2;
  RB_GETBARINFO      = WM_USER +  3;
  RB_SETBARINFO      = WM_USER +  4;
  RB_GETBANDINFO_PRE_IE4     = WM_USER +  5;
  RB_SETBANDINFOA    = WM_USER +  6;
  RB_SETPARENT       = WM_USER +  7;
  RB_HITTEST         = WM_USER +  8;
  RB_GETRECT         = WM_USER +  9;
  RB_INSERTBANDW     = WM_USER +  10;
  RB_SETBANDINFOW    = WM_USER +  11;
  RB_GETBANDCOUNT    = WM_USER +  12;
  RB_GETROWCOUNT     = WM_USER +  13;
  RB_GETROWHEIGHT    = WM_USER +  14;
  RB_IDTOINDEX       = WM_USER +  16; // wParam == id
  RB_GETTOOLTIPS     = WM_USER +  17;
  RB_SETTOOLTIPS     = WM_USER +  18;
  RB_SETBKCOLOR      = WM_USER +  19; // sets the default BK color
  RB_GETBKCOLOR      = WM_USER +  20; // defaults to CLR_NONE
  RB_SETTEXTCOLOR    = WM_USER +  21;
  RB_GETTEXTCOLOR    = WM_USER +  22; // defaults to 0x00000000
  RB_SIZETORECT      = WM_USER +  23; // resize the rebar/break bands and such to this rect (lparam;

  { For Windows >= XP }
  RBSTR_CHANGERECT            = $0001;   { flags for RB_SIZETORECT }

  RB_SETCOLORSCHEME   = CCM_SETCOLORSCHEME; { lParam is color scheme }
  RB_GETCOLORSCHEME   = CCM_GETCOLORSCHEME; { fills in COLORSCHEME pointed to by lParam }

  // for manual drag control
  // lparam == cursor pos
        // -1 means do it yourself.
        // -2 means use what you had saved before
  RB_BEGINDRAG    = WM_USER + 24;
  RB_ENDDRAG      = WM_USER + 25;
  RB_DRAGMOVE     = WM_USER + 26;
  RB_GETBARHEIGHT = WM_USER + 27;
  RB_GETBANDINFOW = WM_USER + 28;
  RB_GETBANDINFOA = WM_USER + 29;

  RB_MINIMIZEBAND = WM_USER + 30;
  RB_MAXIMIZEBAND = WM_USER + 31;

  RB_GETDROPTARGET = CCM_GETDROPTARGET;

  RB_GETBANDBORDERS = WM_USER + 34;  // returns in lparam = lprc the amount of edges added to band wparam

  RB_SHOWBAND     = WM_USER + 35;      // show/hide band
  RB_SETPALETTE   = WM_USER + 37;
  RB_GETPALETTE   = WM_USER + 38;
  RB_MOVEBAND     = WM_USER + 39;

  RB_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;
  RB_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

  { For Windows >= XP }
  RB_GETBANDMARGINS   = WM_USER + 40;
  RB_SETWINDOWTHEME   = CCM_SETWINDOWTHEME;

  { For Windows >= Vista }
  RB_SETEXTENDEDSTYLE = WM_USER + 41;
  RB_GETEXTENDEDSTYLE = WM_USER + 42;

  { For IE >= 0x0500 }
  RB_PUSHCHEVRON      = WM_USER + 43;

  { For Windows >= Vista }
  RB_SETBANDWIDTH     = WM_USER + 44;    { set width for docked band }

{$IFDEF UNICODE}
  RB_INSERTBAND      = RB_INSERTBANDW;
  RB_SETBANDINFO     = RB_SETBANDINFOW;
  RB_GETBANDINFO     = RB_GETBANDINFOW;
{$ELSE}
  RB_INSERTBAND      = RB_INSERTBANDA;
  RB_SETBANDINFO     = RB_SETBANDINFOA;
  RB_GETBANDINFO     = RB_GETBANDINFOA;
{$ENDIF}

  RBN_HEIGHTCHANGE   = RBN_FIRST - 0;

  RBN_GETOBJECT       = RBN_FIRST - 1;
  RBN_LAYOUTCHANGED   = RBN_FIRST - 2;
  RBN_AUTOSIZE        = RBN_FIRST - 3;
  RBN_BEGINDRAG       = RBN_FIRST - 4;
  RBN_ENDDRAG         = RBN_FIRST - 5;
  RBN_DELETINGBAND    = RBN_FIRST - 6;     // Uses NMREBAR
  RBN_DELETEDBAND     = RBN_FIRST - 7;     // Uses NMREBAR
  RBN_CHILDSIZE       = RBN_FIRST - 8;

  { For IE >= 0x0500 }
  RBN_CHEVRONPUSHED   = RBN_FIRST - 10;

  { For IE >= 0x0600 }
  RBN_SPLITTERDRAG    = RBN_FIRST - 11;

  { For IE >= 0x0500 }
  RBN_MINMAX          = RBN_FIRST - 21;

  { For Windows >= XP }
  RBN_AUTOBREAK       = RBN_FIRST - 22;

type
  tagNMREBARCHILDSIZE = packed record
    hdr: TNMHdr;
    uBand: UINT;
    wID: UINT;
    rcChild: TRect;
    rcBand: TRect;
  end;
  PNMReBarChildSize = ^TNMReBarChildSize;
  TNMReBarChildSize = tagNMREBARCHILDSIZE;

  tagNMREBAR = packed record
    hdr: TNMHdr;
    dwMask: DWORD;           // RBNM_*
    uBand: UINT;
    fStyle: UINT;
    wID: UINT;
    lParam: LPARAM;
  end;
  PNMReBar = ^TNMReBar;
  TNMReBar = tagNMREBAR;

const
  // Mask flags for NMREBAR
  RBNM_ID         = $00000001;
  RBNM_STYLE      = $00000002;
  RBNM_LPARAM     = $00000004;

type
  tagNMRBAUTOSIZE = packed record
    hdr: TNMHdr;
    fChanged: BOOL;
    rcTarget: TRect;
    rcActual: TRect;
  end;
  PNMRBAutoSize = ^TNMRBAutoSize;
  TNMRBAutoSize = tagNMRBAUTOSIZE;

  { For IE >= 0x0500 }
  tagNMREBARCHEVRON = packed record
    hdr: NMHDR;
    uBand: UINT;
    wID: UINT;
    lParam: LPARAM;
    rc: TRect;
    lParamNM: LPARAM;
  end;
  PNMReBarChevron = ^TNMReBarChevron;
  TNMReBarChevron = tagNMREBARCHEVRON;

  { For IE >= 0x0600 }
  { $EXTERNALSYM tagNMREBARSPLITTER}
  tagNMREBARSPLITTER = packed record
    hdr: NMHDR;
    rcSizing: TRect;
  end;
  PNMReBarSplitter = ^TNMReBarSplitter;
  TNMReBarSplitter = tagNMREBARSPLITTER;

const
  { For Windows >= XP }
  RBAB_AUTOSIZE   = $0001;   { These are not flags and are all mutually exclusive }
  RBAB_ADDBAND    = $0002;

type
  { $EXTERNALSYM tagNMREBARAUTOBREAK}
  tagNMREBARAUTOBREAK = packed record
    hdr: NMHDR;
    uBand: UINT;
    wID: UINT;
    lParam: LPARAM;
    uMsg: UINT;
    fStyleCurrent: UINT;
    fAutoBreak: BOOL;
  end;
  PNMReBarAutoBreak = ^TNMReBarAutoBreak;
  TNMReBarAutoBreak = tagNMREBARAUTOBREAK;

const
  RBHT_NOWHERE    = $0001;
  RBHT_CAPTION    = $0002;
  RBHT_CLIENT     = $0003;
  RBHT_GRABBER    = $0004;
  { For IE >= 0x0500 }
  RBHT_CHEVRON    = $0008;
  { For IE >= 0x0600 }
  RBHT_SPLITTER   = $0010;

type
  _RB_HITTESTINFO = packed record
    pt: TPoint;
    flags: UINT;
    iBand: Integer;
  end;
  PRBHitTestInfo = ^TRBHitTestInfo;
  TRBHitTestInfo = _RB_HITTESTINFO;

{ ====== TOOLTIPS CONTROL ========================== }

const
  TOOLTIPS_CLASS = 'tooltips_class32';

type
  PToolInfoA = ^TToolInfoA;
  PToolInfoW = ^TToolInfoW;
  PToolInfo = PToolInfoW;
  tagTOOLINFOA = record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PAnsiChar;
    lParam: LPARAM;
                     
    { For Windows >= XP }
    //lpReserved: Pointer;
  end;
  tagTOOLINFOW = record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PWideChar;
    lParam: LPARAM;
                     
    { For Windows >= XP }
    //lpReserved: Pointer;
  end;
  tagTOOLINFO = tagTOOLINFOW;
  TToolInfoA = tagTOOLINFOA;
  TToolInfoW = tagTOOLINFOW;
  TToolInfo = TToolInfoW;
  TOOLINFOA = tagTOOLINFOA;
  TOOLINFOW = tagTOOLINFOW;
  TOOLINFO = TOOLINFOW;

const
  TTS_ALWAYSTIP           = $01;
  TTS_NOPREFIX            = $02;
  { For IE >= 0x0500 }
  TTS_NOANIMATE           = $10;
  TTS_NOFADE              = $20;
  TTS_BALLOON             = $40;
  TTS_CLOSE               = $80;
  { For Windows >= Vista }
  TTS_USEVISUALSTYLE      = $100;  // Use themed hyperlinks

  TTF_IDISHWND            = $0001;

  // Use this to center around trackpoint in trackmode
  // -OR- to center around tool in normal mode.
  // Use TTF_ABSOLUTE to place the tip exactly at the track coords when
  // in tracking mode.  TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP
  // to center the tip absolutely about the track point.

  TTF_CENTERTIP           = $0002;
  TTF_RTLREADING          = $0004;
  TTF_SUBCLASS            = $0010;
  TTF_TRACK               = $0020;
  TTF_ABSOLUTE            = $0080;
  TTF_TRANSPARENT         = $0100;
  TTF_PARSELINKS          = $1000;  // For IE >= 0x0501 
  TTF_DI_SETITEM          = $8000;       // valid only on the TTN_NEEDTEXT callback

  TTDT_AUTOMATIC          = 0;
  TTDT_RESHOW             = 1;
  TTDT_AUTOPOP            = 2;
  TTDT_INITIAL            = 3;

  // ToolTip Icons (Set with TTM_SETTITLE)
  TTI_NONE                = 0;
  TTI_INFO                = 1;
  TTI_WARNING             = 2;
  TTI_ERROR               = 3;
  { For Windows >= Vista }
  TTI_INFO_LARGE          = 4;
  TTI_WARNING_LARGE       = 5;
  TTI_ERROR_LARGE         = 6;

  // Tool Tip Messages
  TTM_ACTIVATE            = WM_USER + 1;
  TTM_SETDELAYTIME        = WM_USER + 3;

  TTM_ADDTOOLA             = WM_USER + 4;
  TTM_DELTOOLA             = WM_USER + 5;
  TTM_NEWTOOLRECTA         = WM_USER + 6;
  TTM_GETTOOLINFOA         = WM_USER + 8;
  TTM_SETTOOLINFOA         = WM_USER + 9;
  TTM_HITTESTA             = WM_USER + 10;
  TTM_GETTEXTA             = WM_USER + 11;
  TTM_UPDATETIPTEXTA       = WM_USER + 12;
  TTM_ENUMTOOLSA           = WM_USER + 14;
  TTM_GETCURRENTTOOLA      = WM_USER + 15;

  TTM_ADDTOOLW             = WM_USER + 50;
  TTM_DELTOOLW             = WM_USER + 51;
  TTM_NEWTOOLRECTW         = WM_USER + 52;
  TTM_GETTOOLINFOW         = WM_USER + 53;
  TTM_SETTOOLINFOW         = WM_USER + 54;
  TTM_HITTESTW             = WM_USER + 55;
  TTM_GETTEXTW             = WM_USER + 56;
  TTM_UPDATETIPTEXTW       = WM_USER + 57;
  TTM_ENUMTOOLSW           = WM_USER + 58;
  TTM_GETCURRENTTOOLW      = WM_USER + 59;
  TTM_WINDOWFROMPOINT      = WM_USER + 16;
  TTM_TRACKACTIVATE        = WM_USER + 17;  // wParam = TRUE/FALSE start end  lparam = LPTOOLINFO
  TTM_TRACKPOSITION        = WM_USER + 18;  // lParam = dwPos
  TTM_SETTIPBKCOLOR        = WM_USER + 19;
  TTM_SETTIPTEXTCOLOR      = WM_USER + 20;
  TTM_GETDELAYTIME         = WM_USER + 21;
  TTM_GETTIPBKCOLOR        = WM_USER + 22;
  TTM_GETTIPTEXTCOLOR      = WM_USER + 23;
  TTM_SETMAXTIPWIDTH       = WM_USER + 24;
  TTM_GETMAXTIPWIDTH       = WM_USER + 25;
  TTM_SETMARGIN            = WM_USER + 26;  // lParam = lprc
  TTM_GETMARGIN            = WM_USER + 27;  // lParam = lprc
  TTM_POP                  = WM_USER + 28;
  TTM_UPDATE               = WM_USER + 29;

  { For IE >= 0X0500 }
  TTM_GETBUBBLESIZE       = WM_USER + 30;
  TTM_ADJUSTRECT          = WM_USER + 31;
  TTM_SETTITLEA           = WM_USER + 32;   { wParam = TTI_*, lParam = char* szTitle }
  TTM_SETTITLEW           = WM_USER + 33;   { wParam = TTI_*, lParam = wchar* szTitle }

  { For Windows >= XP }
  TTM_POPUP               = WM_USER + 34;
  TTM_GETTITLE            = WM_USER + 35;  { wParam = 0, lParam = TTGETTITLE* }

type
  { For Windows >= XP }
  { $EXTERNALSYM _TTGETTITLE}
  _TTGETTITLE = record
    dwSize: DWORD;
    uTitleBitmap: Integer;
    cch: Integer;
    pszTitle: PWCHAR;
  end;
  PTTGetTitle = ^TTTGetTitle;
  TTTGetTitle = _TTGETTITLE;

const  
{$IFDEF UNICODE}
  TTM_ADDTOOL             = TTM_ADDTOOLW;
  TTM_DELTOOL             = TTM_DELTOOLW;
  TTM_NEWTOOLRECT         = TTM_NEWTOOLRECTW;
  TTM_GETTOOLINFO         = TTM_GETTOOLINFOW;
  TTM_SETTOOLINFO         = TTM_SETTOOLINFOW;
  TTM_HITTEST             = TTM_HITTESTW;
  TTM_GETTEXT             = TTM_GETTEXTW;
  TTM_UPDATETIPTEXT       = TTM_UPDATETIPTEXTW;
  TTM_ENUMTOOLS           = TTM_ENUMTOOLSW;
  TTM_GETCURRENTTOOL      = TTM_GETCURRENTTOOLW;
{$ELSE}
  TTM_ADDTOOL             = TTM_ADDTOOLA;
  TTM_DELTOOL             = TTM_DELTOOLA;
  TTM_NEWTOOLRECT         = TTM_NEWTOOLRECTA;
  TTM_GETTOOLINFO         = TTM_GETTOOLINFOA;
  TTM_SETTOOLINFO         = TTM_SETTOOLINFOA;
  TTM_HITTEST             = TTM_HITTESTA;
  TTM_GETTEXT             = TTM_GETTEXTA;
  TTM_UPDATETIPTEXT       = TTM_UPDATETIPTEXTA;
  TTM_ENUMTOOLS           = TTM_ENUMTOOLSA;
  TTM_GETCURRENTTOOL      = TTM_GETCURRENTTOOLA;
{$ENDIF}

  { For IE >= 0X0500 }
  TTM_SETTITLE            = TTM_SETTITLEW;

  { For Windows >= XP }
  TTM_SETWINDOWTHEME      = CCM_SETWINDOWTHEME;

  TTM_RELAYEVENT          = WM_USER + 7;
  TTM_GETTOOLCOUNT        = WM_USER +13;


type
  PTTHitTestInfoA = ^TTTHitTestInfoA;
  PTTHitTestInfoW = ^TTTHitTestInfoW;
  PTTHitTestInfo = PTTHitTestInfoW;
  _TT_HITTESTINFOA = record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoA;
  end;
  _TT_HITTESTINFOW = record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoW;
  end;
  _TT_HITTESTINFO = _TT_HITTESTINFOW;
  TTTHitTestInfoA = _TT_HITTESTINFOA;
  TTTHitTestInfoW = _TT_HITTESTINFOW;
  TTTHitTestInfo = TTTHitTestInfoW;
  TTHITTESTINFOA = _TT_HITTESTINFOA;
  TTHITTESTINFOW = _TT_HITTESTINFOW;
  TTHITTESTINFO = TTHITTESTINFOW;


const
  TTN_NEEDTEXTA            = TTN_FIRST - 0;
  TTN_NEEDTEXTW            = TTN_FIRST - 10;

{$IFDEF UNICODE}
  TTN_NEEDTEXT            = TTN_NEEDTEXTW;
{$ELSE}
  TTN_NEEDTEXT            = TTN_NEEDTEXTA;
{$ENDIF}

  TTN_SHOW                = TTN_FIRST - 1;
  TTN_POP                 = TTN_FIRST - 2;

type
  tagNMTTDISPINFOA = record
    hdr: TNMHdr;
    lpszText: PAnsiChar;
    szText: array[0..79] of AnsiChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
  tagNMTTDISPINFOW = record
    hdr: TNMHdr;
    lpszText: PWideChar;
    szText: array[0..79] of WideChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
  tagNMTTDISPINFO = tagNMTTDISPINFOW;
  PNMTTDispInfoA = ^TNMTTDispInfoA;
  PNMTTDispInfoW = ^TNMTTDispInfoW;
  PNMTTDispInfo = PNMTTDispInfoW;
  TNMTTDispInfoA = tagNMTTDISPINFOA;
  TNMTTDispInfoW = tagNMTTDISPINFOW;
  TNMTTDispInfo = TNMTTDispInfoW;

  tagTOOLTIPTEXTA = tagNMTTDISPINFOA;
  tagTOOLTIPTEXTW = tagNMTTDISPINFOW;
  tagTOOLTIPTEXT = tagTOOLTIPTEXTW;
  TOOLTIPTEXTA = tagNMTTDISPINFOA;
  TOOLTIPTEXTW = tagNMTTDISPINFOW;
  TOOLTIPTEXT = TOOLTIPTEXTW;
  TToolTipTextA = tagNMTTDISPINFOA;
  TToolTipTextW = tagNMTTDISPINFOW;
  TToolTipText = TToolTipTextW;
  PToolTipTextA = ^TToolTipTextA;
  PToolTipTextW = ^TToolTipTextW;
  PToolTipText = PToolTipTextW;
{ ====== STATUS BAR CONTROL ================= }

const
  SBARS_SIZEGRIP          = $0100;

procedure DrawStatusText(hDC: HDC; lprc: PRect; pzsText: PWideChar;
  uFlags: UINT); stdcall;
procedure DrawStatusTextA(hDC: HDC; lprc: PRect; pzsText: PAnsiChar;
  uFlags: UINT); stdcall;
procedure DrawStatusTextW(hDC: HDC; lprc: PRect; pzsText: PWideChar;
  uFlags: UINT); stdcall;
function CreateStatusWindow(Style: Longint; lpszText: PWideChar;
  hwndParent: HWND; wID: UINT): HWND; stdcall;
function CreateStatusWindowA(Style: Longint; lpszText: PAnsiChar;
  hwndParent: HWND; wID: UINT): HWND; stdcall;
function CreateStatusWindowW(Style: Longint; lpszText: PWideChar;
  hwndParent: HWND; wID: UINT): HWND; stdcall;

const
  STATUSCLASSNAME = 'msctls_statusbar32';

const
  SB_SETTEXTA             = WM_USER+1;
  SB_GETTEXTA             = WM_USER+2;
  SB_GETTEXTLENGTHA       = WM_USER+3;
  SB_SETTIPTEXTA          = WM_USER+16;
  SB_GETTIPTEXTA          = WM_USER+18;

  SB_SETTEXTW             = WM_USER+11;
  SB_GETTEXTW             = WM_USER+13;
  SB_GETTEXTLENGTHW       = WM_USER+12;
  SB_SETTIPTEXTW          = WM_USER+17;
  SB_GETTIPTEXTW          = WM_USER+19;

{$IFDEF UNICODE}
  SB_SETTEXT             = SB_SETTEXTW;
  SB_GETTEXT             = SB_GETTEXTW;
  SB_GETTEXTLENGTH       = SB_GETTEXTLENGTHW;
  SB_SETTIPTEXT          = SB_SETTIPTEXTW;
  SB_GETTIPTEXT          = SB_GETTIPTEXTW;
{$ELSE}
  SB_SETTEXT             = SB_SETTEXTA;
  SB_GETTEXT             = SB_GETTEXTA;
  SB_GETTEXTLENGTH       = SB_GETTEXTLENGTHA;
  SB_SETTIPTEXT          = SB_SETTIPTEXTA;
  SB_GETTIPTEXT          = SB_GETTIPTEXTA;
{$ENDIF}

  SB_SETPARTS             = WM_USER+4;
  SB_GETPARTS             = WM_USER+6;
  SB_GETBORDERS           = WM_USER+7;
  SB_SETMINHEIGHT         = WM_USER+8;
  SB_SIMPLE               = WM_USER+9;
  SB_GETRECT              = WM_USER + 10;
  SB_ISSIMPLE             = WM_USER+14;
  SB_SETICON              = WM_USER+15;
  SB_GETICON              = WM_USER+20;
  SB_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;
  SB_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

  SBT_OWNERDRAW            = $1000;
  SBT_NOBORDERS            = $0100;
  SBT_POPOUT               = $0200;
  SBT_RTLREADING           = $0400;
  SBT_TOOLTIPS             = $0800;

  SB_SETBKCOLOR            = CCM_SETBKCOLOR;      // lParam = bkColor

  // status bar notifications
  SBN_SIMPLEMODECHANGE     = SBN_FIRST - 0;

{ ====== MENU HELP ========================== }

procedure MenuHelp(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  hMainMenu: HMENU; hInst: THandle; hwndStatus: HWND; lpwIDs: PUINT); stdcall;
function ShowHideMenuCtl(hWnd: HWND; uFlags: UINT; lpInfo: PINT): Bool; stdcall;
procedure GetEffectiveClientRect(hWnd: HWND; lprc: PRect; lpInfo: PINT); stdcall;

const
  MINSYSCOMMAND   = SC_SIZE;


{ ====== TRACKBAR CONTROL =================== }

  TRACKBAR_CLASS = 'msctls_trackbar32';

const
  TBS_AUTOTICKS           = $0001;
  TBS_VERT                = $0002;
  TBS_HORZ                = $0000;
  TBS_TOP                 = $0004;
  TBS_BOTTOM              = $0000;
  TBS_LEFT                = $0004;
  TBS_RIGHT               = $0000;
  TBS_BOTH                = $0008;
  TBS_NOTICKS             = $0010;
  TBS_ENABLESELRANGE      = $0020;
  TBS_FIXEDLENGTH         = $0040;
  TBS_NOTHUMB             = $0080;
  TBS_TOOLTIPS            = $0100;

  { For IE >= 0x0500 }
  TBS_REVERSED            = $0200;  { Accessibility hint: the smaller number (usually the min value) means "high" and the larger number (usually the max value) means "low" }

  { For IE >= 0x0501 }
  TBS_DOWNISLEFT          = $0400;  { Down=Left and Up=Right (default is Down=Right and Up=Left) }

  { For IE >= 0x0600 }
  TBS_NOTIFYBEFOREMOVE    = $0800;  { Trackbar should notify parent before repositioning the slider due to user action (enables snapping) }

  { For NTDDI_VERSION >= NTDDI_LONGHORN }
  TBS_TRANSPARENTBKGND    = $1000;  { Background is painted by the parent via WM_PRINTCLIENT }

  TBM_GETPOS              = WM_USER;
  TBM_GETRANGEMIN         = WM_USER+1;
  TBM_GETRANGEMAX         = WM_USER+2;
  TBM_GETTIC              = WM_USER+3;
  TBM_SETTIC              = WM_USER+4;
  TBM_SETPOS              = WM_USER+5;
  TBM_SETRANGE            = WM_USER+6;
  TBM_SETRANGEMIN         = WM_USER+7;
  TBM_SETRANGEMAX         = WM_USER+8;
  TBM_CLEARTICS           = WM_USER+9;
  TBM_SETSEL              = WM_USER+10;
  TBM_SETSELSTART         = WM_USER+11;
  TBM_SETSELEND           = WM_USER+12;
  TBM_GETPTICS            = WM_USER+14;
  TBM_GETTICPOS           = WM_USER+15;
  TBM_GETNUMTICS          = WM_USER+16;
  TBM_GETSELSTART         = WM_USER+17;
  TBM_GETSELEND           = WM_USER+18;
  TBM_CLEARSEL            = WM_USER+19;
  TBM_SETTICFREQ          = WM_USER+20;
  TBM_SETPAGESIZE         = WM_USER+21;
  TBM_GETPAGESIZE         = WM_USER+22;
  TBM_SETLINESIZE         = WM_USER+23;
  TBM_GETLINESIZE         = WM_USER+24;
  TBM_GETTHUMBRECT        = WM_USER+25;
  TBM_GETCHANNELRECT      = WM_USER+26;
  TBM_SETTHUMBLENGTH      = WM_USER+27;
  TBM_GETTHUMBLENGTH      = WM_USER+28;
  TBM_SETTOOLTIPS         = WM_USER+29;
  TBM_GETTOOLTIPS         = WM_USER+30;
  TBM_SETTIPSIDE          = WM_USER+31;

  // TrackBar Tip Side flags
  TBTS_TOP                = 0;
  TBTS_LEFT               = 1;
  TBTS_BOTTOM             = 2;
  TBTS_RIGHT              = 3;

  TBM_SETBUDDY            = WM_USER+32; // wparam = BOOL fLeft; (or right)
  TBM_GETBUDDY            = WM_USER+33; // wparam = BOOL fLeft; (or right)
  TBM_SETUNICODEFORMAT    = CCM_SETUNICODEFORMAT;
  TBM_GETUNICODEFORMAT    = CCM_GETUNICODEFORMAT;

  TB_LINEUP               = 0;
  TB_LINEDOWN             = 1;
  TB_PAGEUP               = 2;
  TB_PAGEDOWN             = 3;
  TB_THUMBPOSITION        = 4;
  TB_THUMBTRACK           = 5;
  TB_TOP                  = 6;
  TB_BOTTOM               = 7;
  TB_ENDTRACK             = 8;

  // custom draw item specs
  TBCD_TICS    = $0001;
  TBCD_THUMB   = $0002;
  TBCD_CHANNEL = $0003;
  { For Windows >= Vista }
  TRBN_THUMBPOSCHANGING       = TRBN_FIRST-1;

{ ====== DRAG LIST CONTROL ================== }

type
  PDragListInfo = ^TDragListInfo;
  tagDRAGLISTINFO = packed record
    uNotification: UINT;
    hWnd: HWND;
    ptCursor: TPoint;
  end;
  TDragListInfo = tagDRAGLISTINFO;
  DRAGLISTINFO = tagDRAGLISTINFO;

const
  DL_BEGINDRAG            = WM_USER+133;
  DL_DRAGGING             = WM_USER+134;
  DL_DROPPED              = WM_USER+135;
  DL_CANCELDRAG           = WM_USER+136;

  DL_CURSORSET            = 0;
  DL_STOPCURSOR           = 1;
  DL_COPYCURSOR           = 2;
  DL_MOVECURSOR           = 3;

const
  DRAGLISTMSGSTRING = 'commctrl_DragListMsg';

procedure MakeDragList(hLB: HWND); stdcall;
procedure DrawInsert(hwndParent: HWND; hLB: HWND; nItem: Integer); stdcall;
function LBItemFromPt(hLB: HWND; pt: TPoint; bAutoScroll: Bool): Integer; stdcall;


{ ====== UPDOWN CONTROL ========================== }

const
  UPDOWN_CLASS = 'msctls_updown32';

type
  PUDAccel = ^TUDAccel;
  _UDACCEL = packed record
    nSec: UINT;
    nInc: UINT;
  end;
  TUDAccel = _UDACCEL;
  UDACCEL = _UDACCEL;

const
  UD_MAXVAL               = $7fff;
  UD_MINVAL               = -UD_MAXVAL;

  UDS_WRAP                = $0001;
  UDS_SETBUDDYINT         = $0002;
  UDS_ALIGNRIGHT          = $0004;
  UDS_ALIGNLEFT           = $0008;
  UDS_AUTOBUDDY           = $0010;
  UDS_ARROWKEYS           = $0020;
  UDS_HORZ                = $0040;
  UDS_NOTHOUSANDS         = $0080;
  UDS_HOTTRACK            = $0100;


  UDM_SETRANGE            = WM_USER+101;
  UDM_GETRANGE            = WM_USER+102;
  UDM_SETPOS              = WM_USER+103;
  UDM_GETPOS              = WM_USER+104;
  UDM_SETBUDDY            = WM_USER+105;
  UDM_GETBUDDY            = WM_USER+106;
  UDM_SETACCEL            = WM_USER+107;
  UDM_GETACCEL            = WM_USER+108;
  UDM_SETBASE             = WM_USER+109;
  UDM_GETBASE             = WM_USER+110;
  UDM_SETRANGE32          = WM_USER+111;
  UDM_GETRANGE32          = WM_USER+112; // wParam & lParam are LPINT
  UDM_SETUNICODEFORMAT    = CCM_SETUNICODEFORMAT;
  UDM_GETUNICODEFORMAT    = CCM_GETUNICODEFORMAT;

function CreateUpDownControl(dwStyle: Longint; X, Y, CX, CY: Integer;
  hParent: HWND;  nID: Integer; hInst: THandle; hBuddy: HWND;
  nUpper, nLower, nPos: Integer): HWND; stdcall;

type
  PNMUpDown = ^TNMUpDown;
  _NM_UPDOWN = packed record
    hdr: TNMHDR;
    iPos: Integer;
    iDelta: Integer;
  end;
  TNMUpDown = _NM_UPDOWN;
  NM_UPDOWN = _NM_UPDOWN;

const
  UDN_DELTAPOS = UDN_FIRST - 1;


{ ====== PROGRESS CONTROL ========================= }

const
  PROGRESS_CLASS = 'msctls_progress32';

type
  PBRANGE = record
    iLow: Integer;
    iHigh: Integer;
  end;
  PPBRange = ^TPBRange;
  TPBRange = PBRANGE;

const
  PBS_SMOOTH              = 01;
  PBS_VERTICAL            = 04;
  
  PBM_SETRANGE            = WM_USER+1;
  PBM_SETPOS              = WM_USER+2;
  PBM_DELTAPOS            = WM_USER+3;
  PBM_SETSTEP             = WM_USER+4;
  PBM_STEPIT              = WM_USER+5;
  PBM_SETRANGE32          = WM_USER+6;   // lParam = high, wParam = low
  PBM_GETRANGE            = WM_USER+7;   // lParam = PPBRange or Nil
					 // wParam = False: Result = high
					 // wParam = True: Result = low
  PBM_GETPOS              = WM_USER+8;
  PBM_SETBARCOLOR         = WM_USER+9;		// lParam = bar color
  PBM_SETBKCOLOR          = CCM_SETBKCOLOR;  // lParam = bkColor

  { For Windows >= XP }
  PBS_MARQUEE             = $08;
  PBM_SETMARQUEE          = WM_USER+10;

  { For Windows >= Vista }
  PBS_SMOOTHREVERSE       = $10;

  { For Windows >= Vista }
  PBM_GETSTEP             = WM_USER+13;
  PBM_GETBKCOLOR          = WM_USER+14;
  PBM_GETBARCOLOR         = WM_USER+15;
  PBM_SETSTATE            = WM_USER+16;  { wParam = PBST_[State] (NORMAL, ERROR, PAUSED) }
  PBM_GETSTATE            = WM_USER+17;

  { For Windows >= Vista }
  PBST_NORMAL             = $0001;
  PBST_ERROR              = $0002;
  PBST_PAUSED             = $0003;


{  ====== HOTKEY CONTROL ========================== }

const
  HOTKEYF_SHIFT           = $01;
  HOTKEYF_CONTROL         = $02;
  HOTKEYF_ALT             = $04;
  HOTKEYF_EXT             = $08;

  HKCOMB_NONE             = $0001;
  HKCOMB_S                = $0002;
  HKCOMB_C                = $0004;
  HKCOMB_A                = $0008;
  HKCOMB_SC               = $0010;
  HKCOMB_SA               = $0020;
  HKCOMB_CA               = $0040;
  HKCOMB_SCA              = $0080;


  HKM_SETHOTKEY           = WM_USER+1;
  HKM_GETHOTKEY           = WM_USER+2;
  HKM_SETRULES            = WM_USER+3;

const
  HOTKEYCLASS = 'msctls_hotkey32';


{ ====== COMMON CONTROL STYLES ================ }

const
  CCS_TOP                 = $00000001;
  CCS_NOMOVEY             = $00000002;
  CCS_BOTTOM              = $00000003;
  CCS_NORESIZE            = $00000004;
  CCS_NOPARENTALIGN       = $00000008;
  CCS_ADJUSTABLE          = $00000020;
  CCS_NODIVIDER           = $00000040;
  CCS_VERT                = $00000080;
  CCS_LEFT                = (CCS_VERT or CCS_TOP);
  CCS_RIGHT               = (CCS_VERT or CCS_BOTTOM);
  CCS_NOMOVEX             = (CCS_VERT or CCS_NOMOVEY);


// ====== SysLink control =========================================


const
  { For Windows >= XP }
  INVALID_LINK_INDEX  = -1;
  MAX_LINKID_TEXT     = 48;
  L_MAX_URL_LENGTH    = 2048 + 32 + sizeof('://');

  { For Windows >= XP }
  WC_LINK         = 'SysLink';

  { For Windows >= XP }
  LWS_TRANSPARENT     = $0001;
  LWS_IGNORERETURN    = $0002;
  { For Windows >= Vista }
  LWS_NOPREFIX        = $0004;
  LWS_USEVISUALSTYLE  = $0008;
  LWS_USECUSTOMTEXT   = $0010;
  LWS_RIGHT           = $0020;

  { For Windows >= XP }
  LIF_ITEMINDEX    = $00000001;
  LIF_STATE        = $00000002;
  LIF_ITEMID       = $00000004;
  LIF_URL          = $00000008;

  { For Windows >= XP }
  LIS_FOCUSED         = $00000001;
  LIS_ENABLED         = $00000002;
  LIS_VISITED         = $00000004;
  { For Windows >= Vista }
  LIS_HOTTRACK        = $00000008;
  LIS_DEFAULTCOLORS   = $00000010; // Don't use any custom text colors

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLITEM}
  tagLITEM = record
    mask: UINT;
    iLink: Integer;
    state: UINT;
    stateMask: UINT;
    szID: packed array[0..MAX_LINKID_TEXT-1] of WCHAR;
    szUrl: packed array[0..L_MAX_URL_LENGTH-1] of WCHAR;
  end;
  PLItem = ^TLItem;
  TLItem = tagLITEM;

  { For Windows >= XP }
  { $EXTERNALSYM tagLHITTESTINFO}
  tagLHITTESTINFO = record
    pt: TPoint;
    item: TLItem;
  end;
  PLHitTestInfo = ^TLHitTestInfo;
  TLHitTestInfo = tagLHITTESTINFO;

  { For Windows >= XP }
  { $EXTERNALSYM tagNMLINK}
  tagNMLINK = record
    hdr: NMHDR;
    item: TLItem;
  end;
  PNMLink = ^TNMLink;
  TNMLink = tagNMLINK;

//  SysLink notifications
//  NM_CLICK   // wParam: control ID, lParam: PNMLINK, ret: ignored.

//  LinkWindow messages
const
  { For Windows >= XP }
  LM_HITTEST         = WM_USER+$300;    // wParam: n/a, lparam: PLHITTESTINFO, ret: BOOL
  LM_GETIDEALHEIGHT  = WM_USER+$301;    // wParam: cxMaxWidth, lparam: n/a, ret: cy
  LM_SETITEM         = WM_USER+$302;    // wParam: n/a, lparam: LITEM*, ret: BOOL
  LM_GETITEM         = WM_USER+$303;    // wParam: n/a, lparam: LITEM*, ret: BOOL
  LM_GETIDEALSIZE    = LM_GETIDEALHEIGHT;   // wParam: cxMaxWidth, lparam: SIZE*, ret: cy

  
{ ====== LISTVIEW CONTROL ====================== }


const
  WC_LISTVIEW = 'SysListView32';

const

  { List View Styles }
  LVS_ICON                = $0000;
  LVS_REPORT              = $0001;
  LVS_SMALLICON           = $0002;
  LVS_LIST                = $0003;
  LVS_TYPEMASK            = $0003;
  LVS_SINGLESEL           = $0004;
  LVS_SHOWSELALWAYS       = $0008;
  LVS_SORTASCENDING       = $0010;
  LVS_SORTDESCENDING      = $0020;
  LVS_SHAREIMAGELISTS     = $0040;
  LVS_NOLABELWRAP         = $0080;
  LVS_AUTOARRANGE         = $0100;
  LVS_EDITLABELS          = $0200;
  LVS_OWNERDATA           = $1000; 
  LVS_NOSCROLL            = $2000;

  LVS_TYPESTYLEMASK       = $FC00;

  LVS_ALIGNTOP            = $0000;
  LVS_ALIGNLEFT           = $0800;
  LVS_ALIGNMASK           = $0c00;

  LVS_OWNERDRAWFIXED      = $0400;
  LVS_NOCOLUMNHEADER      = $4000;
  LVS_NOSORTHEADER        = $8000;

  { List View Extended Styles }
  LVS_EX_GRIDLINES        = $00000001;
  LVS_EX_SUBITEMIMAGES    = $00000002;
  LVS_EX_CHECKBOXES       = $00000004;
  LVS_EX_TRACKSELECT      = $00000008;
  LVS_EX_HEADERDRAGDROP   = $00000010;
  LVS_EX_FULLROWSELECT    = $00000020; // applies to report mode only
  LVS_EX_ONECLICKACTIVATE = $00000040;
  LVS_EX_TWOCLICKACTIVATE = $00000080;
  LVS_EX_FLATSB           = $00000100;
  LVS_EX_REGIONAL         = $00000200;
  LVS_EX_INFOTIP          = $00000400; // listview does InfoTips for you
  LVS_EX_UNDERLINEHOT     = $00000800;
  LVS_EX_UNDERLINECOLD    = $00001000;
  LVS_EX_MULTIWORKAREAS   = $00002000;

  { For IE >= 0x0500 }
  LVS_EX_LABELTIP         = $00004000; { listview unfolds partly hidden labels if it does not have infotip text }
  LVS_EX_BORDERSELECT     = $00008000; { border selection style instead of highlight }

  { For Windows >= XP }
  LVS_EX_DOUBLEBUFFER     = $00010000;
  LVS_EX_HIDELABELS       = $00020000;
  LVS_EX_SINGLEROW        = $00040000;
  LVS_EX_SNAPTOGRID       = $00080000;  { Icons automatically snap to grid. }
  LVS_EX_SIMPLESELECT     = $00100000;  { Also changes overlay rendering to top right for icon mode. }

  { For Windows >= Vista }
  LVS_EX_JUSTIFYCOLUMNS   = $00200000;  { Icons are lined up in columns that use up the whole view area. }
  LVS_EX_TRANSPARENTBKGND = $00400000;  { Background is painted by the parent via WM_PRINTCLIENT }
  LVS_EX_TRANSPARENTSHADOWTEXT = $00800000;  { Enable shadow text on transparent backgrounds only (useful with bitmaps) }
  LVS_EX_AUTOAUTOARRANGE  = $01000000;  { Icons automatically arrange if no icon positions have been set }
  LVS_EX_HEADERINALLVIEWS = $02000000;  { Display column header in all view modes }
  LVS_EX_AUTOCHECKSELECT  = $08000000;
  LVS_EX_AUTOSIZECOLUMNS  = $10000000;
  LVS_EX_COLUMNSNAPPOINTS = $40000000;
  LVS_EX_COLUMNOVERFLOW   = $80000000; 

const
  LVM_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;

function ListView_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL; {inline;}

const
  LVM_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

function ListView_GetUnicodeFormat(hwnd: HWND): BOOL; {inline;}

const
  LVM_GETBKCOLOR          = LVM_FIRST + 0;

function ListView_GetBkColor(hWnd: HWND): TColorRef; {inline;}

const
  LVM_SETBKCOLOR          = LVM_FIRST + 1;

function ListView_SetBkColor(hWnd: HWND; clrBk: TColorRef): Bool; {inline;}

const
  LVM_GETIMAGELIST        = LVM_FIRST + 2;

function ListView_GetImageList(hWnd: HWND; iImageList: Integer): HIMAGELIST; {inline;}

const
  LVSIL_NORMAL            = 0;
  LVSIL_SMALL             = 1;
  LVSIL_STATE             = 2;
  LVSIL_GROUPHEADER       = 3; 

const
  LVM_SETIMAGELIST        = LVM_FIRST + 3;

function ListView_SetImageList(hWnd: HWND; himl: HIMAGELIST;
  iImageList: Integer): HIMAGELIST; {inline;}

const
  LVM_GETITEMCOUNT        = LVM_FIRST + 4;

function ListView_GetItemCount(hWnd: HWND): Integer; {inline;}

const
  LVIF_TEXT               = $0001;
  LVIF_IMAGE              = $0002;
  LVIF_PARAM              = $0004;
  LVIF_STATE              = $0008;
  LVIF_INDENT             = $0010;
  LVIF_NORECOMPUTE        = $0800;
  { For Windows >= XP }
  LVIF_GROUPID            = $00000100;
  LVIF_COLUMNS            = $00000200;

  { For Windows >= Vista }
  LVIF_COLFMT             = $00010000; { The piColFmt member is valid in addition to puColumns }

  LVIS_FOCUSED            = $0001;
  LVIS_SELECTED           = $0002;
  LVIS_CUT                = $0004;
  LVIS_DROPHILITED        = $0008;
  LVIS_ACTIVATING         = $0020;

  LVIS_OVERLAYMASK        = $0F00;
  LVIS_STATEIMAGEMASK     = $F000;

function IndexToStateImageMask(I: Longint): Longint; {inline;}

const
  I_INDENTCALLBACK        = -1;
  I_IMAGENONE             = -2;
  { For Windows >= XP }
  I_COLUMNSCALLBACK       = -1;
  I_GROUPIDCALLBACK   = -1;
  I_GROUPIDNONE       = -2;

(*                                                                                                                                                                                                                                                                                                                                                                         
  LVITEMA_V5_SIZE = CCSIZEOF_STRUCT(LVITEMA, puColumns);
  LVITEMW_V5_SIZE = CCSIZEOF_STRUCT(LVITEMW, puColumns);

  LVITEM_V5_SIZE = LVITEMW_V5_SIZE;
*)

type
  PLVItemA = ^TLVItemA;
  PLVItemW = ^TLVItemW;
  PLVItem = PLVItemW;
  tagLVITEMA = record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
                                                            
    iGroupId: Integer;
    cColumns: Integer;{ tile view columns }
    puColumns: PUINT;
                                                                                                                                            
    //piColFmt: PInteger;
    //iGroup: Integer;{ readonly. only valid for owner data. }
  end;
  tagLVITEMW = record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    iIndent: Integer;
                                                            
    iGroupId: Integer;
    cColumns: Integer;{ tile view columns }
    puColumns: PUINT;
                                                                                                                                            
    //piColFmt: PInteger;
    //iGroup: Integer;{ readonly. only valid for owner data. }
  end;
  tagLVITEM = tagLVITEMW;
  _LV_ITEMA = tagLVITEMA;
  _LV_ITEMW = tagLVITEMW;
  _LV_ITEM = _LV_ITEMW;
  TLVItemA = tagLVITEMA;
  TLVItemW = tagLVITEMW;
  TLVItem = TLVItemW;
  LV_ITEMA = tagLVITEMA;
  LV_ITEMW = tagLVITEMW;
  LV_ITEM = LV_ITEMW;

const
  LPSTR_TEXTCALLBACKA = LPSTR(-1);
  LPSTR_TEXTCALLBACKW = LPWSTR(-1);

{$IFDEF UNICODE}
  LPSTR_TEXTCALLBACK = LPSTR_TEXTCALLBACKW;
{$ELSE}
  LPSTR_TEXTCALLBACK = LPSTR_TEXTCALLBACKA;
{$ENDIF}

  I_IMAGECALLBACK         = -1;

const
  LVM_GETITEMA            = LVM_FIRST + 5;
  LVM_SETITEMA            = LVM_FIRST + 6;
  LVM_INSERTITEMA         = LVM_FIRST + 7;

  LVM_GETITEMW            = LVM_FIRST + 75;
  LVM_SETITEMW            = LVM_FIRST + 76;
  LVM_INSERTITEMW         = LVM_FIRST + 77;

{$IFDEF UNICODE}
  LVM_GETITEM            = LVM_GETITEMW;
  LVM_SETITEM            = LVM_SETITEMW;
  LVM_INSERTITEM         = LVM_INSERTITEMW;
{$ELSE}
  LVM_GETITEM            = LVM_GETITEMA;
  LVM_SETITEM            = LVM_SETITEMA;
  LVM_INSERTITEM         = LVM_INSERTITEMA;
{$ENDIF}

  LVM_DELETEITEM          = LVM_FIRST + 8;
  LVM_DELETEALLITEMS      = LVM_FIRST + 9;
  LVM_GETCALLBACKMASK     = LVM_FIRST + 10;
  LVM_SETCALLBACKMASK     = LVM_FIRST + 11;

function ListView_GetItem(hWnd: HWND; var pItem: TLVItem): Bool; {inline;}
function ListView_GetItemA(hWnd: HWND; var pItem: TLVItemA): Bool; {inline;}
function ListView_GetItemW(hWnd: HWND; var pItem: TLVItemW): Bool; {inline;}
function ListView_SetItem(hWnd: HWND; const pItem: TLVItem): Bool; {inline;}
function ListView_SetItemA(hWnd: HWND; const pItem: TLVItemA): Bool; {inline;}
function ListView_SetItemW(hWnd: HWND; const pItem: TLVItemW): Bool; {inline;}
function ListView_InsertItem(hWnd: HWND; const pItem: TLVItem): Integer; {inline;}
function ListView_InsertItemA(hWnd: HWND; const pItem: TLVItemA): Integer; {inline;}
function ListView_InsertItemW(hWnd: HWND; const pItem: TLVItemW): Integer; {inline;}
function ListView_DeleteItem(hWnd: HWND; i: Integer): Bool; {inline;}
function ListView_DeleteAllItems(hWnd: HWND): Bool; {inline;}
function ListView_GetCallbackMask(hWnd: HWND): UINT; {inline;}
function ListView_SetCallbackMask(hWnd: HWND; mask: UINT): Bool; {inline;}

const
  LVNI_ALL                = $0000;
  LVNI_FOCUSED            = $0001;
  LVNI_SELECTED           = $0002;
  LVNI_CUT                = $0004;
  LVNI_DROPHILITED        = $0008;

  LVNI_ABOVE              = $0100;
  LVNI_BELOW              = $0200;
  LVNI_TOLEFT             = $0400;
  LVNI_TORIGHT            = $0800;


const
  LVM_GETNEXTITEM         = LVM_FIRST + 12;

function ListView_GetNextItem(hWnd: HWND; iStart: Integer; Flags: UINT): Integer;

const
  LVFI_PARAM              = $0001;
  LVFI_STRING             = $0002;
  LVFI_PARTIAL            = $0008;
  LVFI_WRAP               = $0020;
  LVFI_NEARESTXY          = $0040;


type
  PLVFindInfoA = ^TLVFindInfoA;
  PLVFindInfoW = ^TLVFindInfoW;
  PLVFindInfo = PLVFindInfoW;
  tagLVFINDINFOA = record
    flags: UINT;
    psz: PAnsiChar;
    lParam: LPARAM;
    pt: TPoint;
    vkDirection: UINT;
  end;
  tagLVFINDINFOW = record
    flags: UINT;
    psz: PWideChar;
    lParam: LPARAM;
    pt: TPoint;
    vkDirection: UINT;
  end;
  tagLVFINDINFO = tagLVFINDINFOW;
  _LV_FINDINFOA = tagLVFINDINFOA;
  _LV_FINDINFOW = tagLVFINDINFOW;
  _LV_FINDINFO = _LV_FINDINFOW;
  TLVFindInfoA = tagLVFINDINFOA;
  TLVFindInfoW = tagLVFINDINFOW;
  TLVFindInfo = TLVFindInfoW;
  LV_FINDINFOA = tagLVFINDINFOA;
  LV_FINDINFOW = tagLVFINDINFOW;
  LV_FINDINFO = LV_FINDINFOW;

const
  LVM_FINDITEMA            = LVM_FIRST + 13;
  LVM_FINDITEMW            = LVM_FIRST + 83;
{$IFDEF UNICODE}
  LVM_FINDITEM            = LVM_FINDITEMW;
{$ELSE}
  LVM_FINDITEM            = LVM_FINDITEMA;
{$ENDIF}

function ListView_FindItem(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfo): Integer; {inline;}
function ListView_FindItemA(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfoA): Integer; {inline;}
function ListView_FindItemW(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfoW): Integer; {inline;}

const
  LVIR_BOUNDS             = 0;
  LVIR_ICON               = 1;
  LVIR_LABEL              = 2;
  LVIR_SELECTBOUNDS       = 3;


const
  LVM_GETITEMRECT         = LVM_FIRST + 14;

function ListView_GetItemRect(hWnd: HWND; i: Integer; var prc: TRect;
  Code: Integer): Bool;

const
  LVM_SETITEMPOSITION     = LVM_FIRST + 15;

function ListView_SetItemPosition(hWnd: HWND; i, x, y: Integer): Bool;

const
  LVM_GETITEMPOSITION     = LVM_FIRST + 16;

function ListView_GetItemPosition(hwndLV: HWND; i: Integer; var ppt: TPoint): Bool; {inline;}

const
  LVM_GETSTRINGWIDTHA      = LVM_FIRST + 17;
  LVM_GETSTRINGWIDTHW      = LVM_FIRST + 87;
{$IFDEF UNICODE}
  LVM_GETSTRINGWIDTH      = LVM_GETSTRINGWIDTHW;
{$ELSE}
  LVM_GETSTRINGWIDTH      = LVM_GETSTRINGWIDTHA;
{$ENDIF}

function ListView_GetStringWidth(hwndLV: HWND; psz: PWideChar): Integer; {inline;}
function ListView_GetStringWidthA(hwndLV: HWND; psz: PAnsiChar): Integer; {inline;}
function ListView_GetStringWidthW(hwndLV: HWND; psz: PWideChar): Integer; {inline;}

const
  LVHT_NOWHERE            = $0001;
  LVHT_ONITEMICON         = $0002;
  LVHT_ONITEMLABEL        = $0004;
  LVHT_ONITEMSTATEICON    = $0008;
  LVHT_ONITEM             = LVHT_ONITEMICON or LVHT_ONITEMLABEL or
			    LVHT_ONITEMSTATEICON;
  LVHT_ABOVE              = $0008;
  LVHT_BELOW              = $0010;
  LVHT_TORIGHT            = $0020;
  LVHT_TOLEFT             = $0040;

type
  PLVHitTestInfo = ^TLVHitTestInfo;
  tagLVHITTESTINFO = packed record
    pt: TPoint;
    flags: UINT;
    iItem: Integer;
    iSubItem: Integer;    // this is was NOT in win95.  valid only for LVM_SUBITEMHITTEST
                                                         
    { For Windows >= Vista }
    //iGroup: Integer; // readonly. index of group. only valid for owner data.
                     // supports single item in multiple groups.
  end;
  TLVHitTestInfo = tagLVHITTESTINFO;
  LV_HITTESTINFO = tagLVHITTESTINFO;
  _LV_HITTESTINFO = tagLVHITTESTINFO;

const
  LVM_HITTEST             = LVM_FIRST + 18;

function ListView_HitTest(hwndLV: HWND; var pinfo: TLVHitTestInfo): Integer; {inline;}

const
  LVM_ENSUREVISIBLE       = LVM_FIRST + 19;

function ListView_EnsureVisible(hwndLV: HWND; i: Integer; fPartialOK: Bool): Bool;

const
  LVM_SCROLL              = LVM_FIRST + 20;

function ListView_Scroll(hwndLV: HWnd; DX, DY: Integer): Bool; {inline;}

const
  LVM_REDRAWITEMS         = LVM_FIRST + 21;

function ListView_RedrawItems(hwndLV: HWND; iFirst, iLast: Integer): Bool; {inline;}

const
  LVA_DEFAULT             = $0000;
  LVA_ALIGNLEFT           = $0001;
  LVA_ALIGNTOP            = $0002;
  LVA_ALIGNRIGHT          = $0003;
  LVA_ALIGNBOTTOM         = $0004;
  LVA_SNAPTOGRID          = $0005;

  LVA_SORTASCENDING       = $0100;
  LVA_SORTDESCENDING      = $0200;

  LVM_ARRANGE             = LVM_FIRST + 22;

function ListView_Arrange(hwndLV: HWND; Code: UINT): Bool; {inline;}


const
  LVM_EDITLABELA           = LVM_FIRST + 23;
  LVM_EDITLABELW           = LVM_FIRST + 118;
{$IFDEF UNICODE}
  LVM_EDITLABEL           = LVM_EDITLABELW;
{$ELSE}
  LVM_EDITLABEL           = LVM_EDITLABELA;
{$ENDIF}

function ListView_EditLabel(hwndLV: HWND; i: Integer): HWND; {inline;}
function ListView_EditLabelA(hwndLV: HWND; i: Integer): HWND; {inline;}
function ListView_EditLabelW(hwndLV: HWND; i: Integer): HWND; {inline;}

const
  LVM_GETEDITCONTROL      = LVM_FIRST + 24;

function ListView_GetEditControl(hwndLV: HWND): HWND; {inline;}

type
  PLVColumnA = ^TLVColumnA;
  PLVColumnW = ^TLVColumnW;
  PLVColumn = PLVColumnW;
  tagLVCOLUMNA = record
    mask: UINT;
    fmt: Integer;
    cx: Integer;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iSubItem: Integer;
    iImage: Integer;
    iOrder: Integer;
                                                         
    { For Windows >= Vista }
    //cxMin: Integer;     // min snap point
    //cxDefault: Integer; // default snap point
    //cxIdeal: Integer;   // read only. ideal may not eqaul current width if auto sized (LVS_EX_AUTOSIZECOLUMNS) to a lesser width.
  end;
  tagLVCOLUMNW = record
    mask: UINT;
    fmt: Integer;
    cx: Integer;
    pszText: PWideChar;
    cchTextMax: Integer;
    iSubItem: Integer;
    iImage: Integer;
    iOrder: Integer;
                                                         
    { For Windows >= Vista }
    //cxMin: Integer;     // min snap point
    //cxDefault: Integer; // default snap point
    //cxIdeal: Integer;   // read only. ideal may not eqaul current width if auto sized (LVS_EX_AUTOSIZECOLUMNS) to a lesser width.
  end;
  tagLVCOLUMN = tagLVCOLUMNW;
  _LV_COLUMNA = tagLVCOLUMNA;
  _LV_COLUMNW = tagLVCOLUMNW;
  _LV_COLUMN = _LV_COLUMNW;
  TLVColumnA = tagLVCOLUMNA;
  TLVColumnW = tagLVCOLUMNW;
  TLVColumn = TLVColumnW;
  LV_COLUMNA = tagLVCOLUMNA;
  LV_COLUMNW = tagLVCOLUMNW;
  LV_COLUMN = LV_COLUMNW;

const
  LVCF_FMT                = $0001;
  LVCF_WIDTH              = $0002;
  LVCF_TEXT               = $0004;
  LVCF_SUBITEM            = $0008;
  LVCF_IMAGE              = $0010;
  LVCF_ORDER              = $0020;
  { For Windows >= Vista }
  LVCF_MINWIDTH           = $0040;
  LVCF_DEFAULTWIDTH       = $0080;
  LVCF_IDEALWIDTH         = $0100;

// LVCFMT_ flags up to FFFF are shared with the header control (HDF_ flags).
// Flags above FFFF are listview-specific.

  LVCFMT_LEFT             = $0000; 
  LVCFMT_RIGHT            = $0001;
  LVCFMT_CENTER           = $0002; 
  LVCFMT_JUSTIFYMASK      = $0003;
  LVCFMT_IMAGE            = $0800;
  LVCFMT_BITMAP_ON_RIGHT  = $1000;
  LVCFMT_COL_HAS_IMAGES   = $8000;
  { For Windows >= Vista }
  LVCFMT_FIXED_WIDTH          = $00100;  // Can't resize the column; same as HDF_FIXEDWIDTH
  LVCFMT_NO_DPI_SCALE         = $40000;  // If not set, CCM_DPISCALE will govern scaling up fixed width
  LVCFMT_FIXED_RATIO          = $80000;  // Width will augment with the row height

  { For Windows >= Vista }
  // The following flags
  LVCFMT_LINE_BREAK           = $100000; // Move to the top of the next list of columns
  LVCFMT_FILL                 = $200000; // Fill the remainder of the tile area. Might have a title.
  LVCFMT_WRAP                 = $400000; // This sub-item can be wrapped.
  LVCFMT_NO_TITLE             = $800000; // This sub-item doesn't have an title.
  LVCFMT_TILE_PLACEMENTMASK   = LVCFMT_LINE_BREAK or LVCFMT_FILL;

  { For Windows >= Vista }
  LVCFMT_SPLITBUTTON          = $1000000; // Column is a split button; same as HDF_SPLITBUTTON

  LVM_GETCOLUMNA          = LVM_FIRST + 25;
  LVM_GETCOLUMNW          = LVM_FIRST + 95;
{$IFDEF UNICODE}
  LVM_GETCOLUMN           = LVM_GETCOLUMNW;
{$ELSE}
  LVM_GETCOLUMN           = LVM_GETCOLUMNA;
{$ENDIF}

function ListView_GetColumn(hwnd: HWND; iCol: Integer;
  var pcol: TLVColumn): Bool; {inline;}
function ListView_GetColumnA(hwnd: HWND; iCol: Integer;
  var pcol: TLVColumnA): Bool; {inline;}
function ListView_GetColumnW(hwnd: HWND; iCol: Integer;
  var pcol: TLVColumnW): Bool; {inline;}

const
  LVM_SETCOLUMNA           = LVM_FIRST + 26;
  LVM_SETCOLUMNW           = LVM_FIRST + 96;
{$IFDEF UNICODE}
  LVM_SETCOLUMN           = LVM_SETCOLUMNW;
{$ELSE}
  LVM_SETCOLUMN           = LVM_SETCOLUMNA;
{$ENDIF}

function ListView_SetColumn(hwnd: HWnd; iCol: Integer; const pcol: TLVColumn): Bool; {inline;}
function ListView_SetColumnA(hwnd: HWnd; iCol: Integer; const pcol: TLVColumnA): Bool; {inline;}
function ListView_SetColumnW(hwnd: HWnd; iCol: Integer; const pcol: TLVColumnW): Bool; {inline;}

const
  LVM_INSERTCOLUMNA        = LVM_FIRST + 27;
  LVM_INSERTCOLUMNW        = LVM_FIRST + 97;
{$IFDEF UNICODE}
  LVM_INSERTCOLUMN        = LVM_INSERTCOLUMNW;
{$ELSE}
  LVM_INSERTCOLUMN        = LVM_INSERTCOLUMNA;
{$ENDIF}

function ListView_InsertColumn(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumn): Integer; {inline;}
function ListView_InsertColumnA(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumnA): Integer; {inline;}
function ListView_InsertColumnW(hwnd: HWND; iCol: Integer;
  const pcol: TLVColumnW): Integer; {inline;}

const
  LVM_DELETECOLUMN        = LVM_FIRST + 28;

function ListView_DeleteColumn(hwnd: HWND; iCol: Integer): Bool; {inline;}

const
  LVM_GETCOLUMNWIDTH      = LVM_FIRST + 29;

function ListView_GetColumnWidth(hwnd: HWND; iCol: Integer): Integer; {inline;}

const
  LVSCW_AUTOSIZE              = -1;
  LVSCW_AUTOSIZE_USEHEADER    = -2;
  LVM_SETCOLUMNWIDTH          = LVM_FIRST + 30;

function ListView_SetColumnWidth(hwnd: HWnd; iCol: Integer; cx: Integer): Bool;

const
  LVM_GETHEADER               = LVM_FIRST + 31;

function ListView_GetHeader(hwnd: HWND): HWND;

const
  LVM_CREATEDRAGIMAGE     = LVM_FIRST + 33;

function ListView_CreateDragImage(hwnd: HWND; i: Integer;
  const lpptUpLeft: TPoint): HIMAGELIST; {inline;}

const
  LVM_GETVIEWRECT         = LVM_FIRST + 34;

function ListView_GetViewRect(hwnd: HWND; var prc: TRect): Bool; {inline;}

const
  LVM_GETTEXTCOLOR        = LVM_FIRST + 35;

function ListView_GetTextColor(hwnd: HWND): TColorRef; {inline;}

const
  LVM_SETTEXTCOLOR        = LVM_FIRST + 36;

function ListView_SetTextColor(hwnd: HWND; clrText: TColorRef): Bool; {inline;}

const
  LVM_GETTEXTBKCOLOR      = LVM_FIRST + 37;

function ListView_GetTextBkColor(hwnd: HWND): TColorRef; {inline;}

const
  LVM_SETTEXTBKCOLOR      = LVM_FIRST + 38;

function ListView_SetTextBkColor(hwnd: HWND; clrTextBk: TColorRef): Bool; {inline;}

const
  LVM_GETTOPINDEX         = LVM_FIRST + 39;

function ListView_GetTopIndex(hwndLV: HWND): Integer; {inline;}

const
  LVM_GETCOUNTPERPAGE     = LVM_FIRST + 40;

function ListView_GetCountPerPage(hwndLV: HWND): Integer; {inline;}

const
  LVM_GETORIGIN           = LVM_FIRST + 41;

function ListView_GetOrigin(hwndLV: HWND; var ppt: TPoint): Bool; {inline;}

const
  LVM_UPDATE              = LVM_FIRST + 42;

function ListView_Update(hwndLV: HWND; i: Integer): Bool; {inline;}

const
  LVM_SETITEMSTATE        = LVM_FIRST + 43;

function ListView_SetItemState(hwndLV: HWND; i: Integer; data, mask: UINT): Bool;

const
  LVM_GETITEMSTATE        = LVM_FIRST + 44;

function ListView_GetItemState(hwndLV: HWND; i, mask: Integer): Integer; {inline;}

function ListView_GetCheckState(hwndLV: HWND; i: Integer): UINT; {inline;}
procedure ListView_SetCheckState(hwndLV: HWND; i: Integer; Checked: Boolean);

const
  LVM_GETITEMTEXTA         = LVM_FIRST + 45;
  LVM_GETITEMTEXTW         = LVM_FIRST + 115;
{$IFDEF UNICODE}
  LVM_GETITEMTEXT         = LVM_GETITEMTEXTW;
{$ELSE}
  LVM_GETITEMTEXT         = LVM_GETITEMTEXTA;
{$ENDIF}

function ListView_GetItemText(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar; cchTextMax: Integer): Integer;
function ListView_GetItemTextA(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PAnsiChar; cchTextMax: Integer): Integer;
function ListView_GetItemTextW(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar; cchTextMax: Integer): Integer;

const
  LVM_SETITEMTEXTA         = LVM_FIRST + 46;
  LVM_SETITEMTEXTW         = LVM_FIRST + 116;
{$IFDEF UNICODE}
  LVM_SETITEMTEXT         = LVM_SETITEMTEXTW;
{$ELSE}
  LVM_SETITEMTEXT         = LVM_SETITEMTEXTA;
{$ENDIF}

function ListView_SetItemText(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar): Bool;
function ListView_SetItemTextA(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PAnsiChar): Bool;
function ListView_SetItemTextW(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar): Bool;

const
  // these flags only apply to LVS_OWNERDATA listviews in report or list mode
  LVSICF_NOINVALIDATEALL  = $00000001;
  LVSICF_NOSCROLL         = $00000002;

  LVM_SETITEMCOUNT        = LVM_FIRST + 47;

procedure ListView_SetItemCount(hwndLV: HWND; cItems: Integer); {inline;}

procedure ListView_SetItemCountEx(hwndLV: HWND; cItems: Integer; dwFlags: DWORD); {inline;}

type
  PFNLVCOMPARE = function(lParam1, lParam2, lParamSort: Integer): Integer stdcall;
  TLVCompare = PFNLVCOMPARE;

const
  LVM_SORTITEMS           = LVM_FIRST + 48;

function ListView_SortItems(hwndLV: HWND; pfnCompare: TLVCompare;
  lPrm: Longint): Bool; {inline;}

const
  LVM_SETITEMPOSITION32   = LVM_FIRST + 49;

procedure ListView_SetItemPosition32(hwndLV: HWND; i, x, y: Integer);

const
  LVM_GETSELECTEDCOUNT    = LVM_FIRST + 50;

function ListView_GetSelectedCount(hwndLV: HWND): UINT; {inline;}

const
  LVM_GETITEMSPACING      = LVM_FIRST + 51;

function ListView_GetItemSpacing(hwndLV: HWND; fSmall: Integer): Longint; {inline;}

const
  LVM_GETISEARCHSTRINGA    = LVM_FIRST + 52;
  LVM_GETISEARCHSTRINGW    = LVM_FIRST + 117;
{$IFDEF UNICODE}
  LVM_GETISEARCHSTRING    = LVM_GETISEARCHSTRINGW;
{$ELSE}
  LVM_GETISEARCHSTRING    = LVM_GETISEARCHSTRINGA;
{$ENDIF}

function ListView_GetISearchString(hwndLV: HWND; lpsz: PWideChar): Bool; {inline;}
function ListView_GetISearchStringA(hwndLV: HWND; lpsz: PAnsiChar): Bool; {inline;}
function ListView_GetISearchStringW(hwndLV: HWND; lpsz: PWideChar): Bool; {inline;}

const
  LVM_SETICONSPACING      = LVM_FIRST + 53;

// -1 for cx and cy means we'll use the default (system settings)
// 0 for cx or cy means use the current setting (allows you to change just one param)
function ListView_SetIconSpacing(hwndLV: HWND; cx, cy: Word): DWORD;

const
  LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54;

function ListView_SetExtendedListViewStyle(hwndLV: HWND; dw: DWORD): BOOL; {inline;}

const
  LVM_GETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 55;

function ListView_GetExtendedListViewStyle(hwndLV: HWND): DWORD; {inline;}

const
  LVM_GETSUBITEMRECT      = LVM_FIRST + 56;

function ListView_GetSubItemRect(hwndLV: HWND; iItem, iSubItem: Integer;
  code: DWORD; prc: PRect): BOOL;

const
  LVM_SUBITEMHITTEST      = LVM_FIRST + 57;

function ListView_SubItemHitTest(hwndLV: HWND; plvhti: PLVHitTestInfo): Integer; {inline;}

const
  LVM_SETCOLUMNORDERARRAY = LVM_FIRST + 58;

function ListView_SetColumnOrderArray(hwndLV: HWND; iCount: Integer;
  pi: PInteger): BOOL; {inline;}

const
  LVM_GETCOLUMNORDERARRAY = LVM_FIRST + 59;

function ListView_GetColumnOrderArray(hwndLV: HWND; iCount: Integer;
  pi: PInteger): BOOL; {inline;}

const
  LVM_SETHOTITEM  = LVM_FIRST + 60;

function ListView_SetHotItem(hwndLV: HWND; i: Integer): Integer; {inline;}

const
  LVM_GETHOTITEM  = LVM_FIRST + 61;

function ListView_GetHotItem(hwndLV: HWND): Integer; {inline;}

const
  LVM_SETHOTCURSOR  = LVM_FIRST + 62;

function ListView_SetHotCursor(hwndLV: HWND; hcur: HCURSOR): HCURSOR; {inline;}

const
  LVM_GETHOTCURSOR  = LVM_FIRST + 63;

function ListView_GetHotCursor(hwndLV: HWND): HCURSOR; {inline;}

const
  LVM_APPROXIMATEVIEWRECT = LVM_FIRST + 64;

function ListView_ApproximateViewRect(hwndLV: HWND; iWidth, iHeight: Word;
  iCount: Integer): DWORD;

const
  LV_MAX_WORKAREAS        = 16;
  LVM_SETWORKAREA         = LVM_FIRST + 65;

function ListView_SetWorkAreas(hwndLV: HWND; nWorkAreas: Integer; prc: PRect): BOOL; {inline;}

const
  LVM_GETSELECTIONMARK    = LVM_FIRST + 66;

function ListView_GetSelectionMark(hwnd: HWND): Integer; {inline;}

const
  LVM_SETSELECTIONMARK    = LVM_FIRST + 67;

function ListView_SetSelectionMark(hwnd: HWND; i: Integer): Integer; {inline;}

const
  LVM_GETWORKAREAS        = LVM_FIRST + 70;

function ListView_GetWorkAreas(hwnd: HWND; nWorkAreas: Integer; prc: PRect): BOOL; {inline;}

const
  LVM_SETHOVERTIME        = LVM_FIRST + 71;

function ListView_SetHoverTime(hwndLV: HWND; dwHoverTimeMs: DWORD): DWORD; {inline;}

const
  LVM_GETHOVERTIME        = LVM_FIRST + 72;

function ListView_GetHoverTime(hwndLV: HWND): Integer; {inline;}

const
  LVM_GETNUMBEROFWORKAREAS  = LVM_FIRST + 73;

function ListView_GetNumberOfWorkAreas(hwnd: HWND; pnWorkAreas: PInteger): Integer; {inline;}

const
  LVM_SETTOOLTIPS       = LVM_FIRST + 74;

function ListView_SetToolTips(hwndLV: HWND; hwndNewHwnd: HWND): HWND; {inline;}

const
  LVM_GETTOOLTIPS       = LVM_FIRST + 78;

function ListView_GetToolTips(hwndLV: HWND): HWND; {inline;}

type
  tagLVBKIMAGEA = record
    ulFlags: ULONG;              // LVBKIF_*
    hbm: HBITMAP;
    pszImage: PAnsiChar;
    cchImageMax: UINT;
    xOffsetPercent: Integer;
    yOffsetPercent: Integer;
  end;
  tagLVBKIMAGEW = record
    ulFlags: ULONG;              // LVBKIF_*
    hbm: HBITMAP;
    pszImage: PWideChar;
    cchImageMax: UINT;
    xOffsetPercent: Integer;
    yOffsetPercent: Integer;
  end;
  tagLVBKIMAGE = tagLVBKIMAGEW;
  PLVBKImageA = ^TLVBKImageA;
  PLVBKImageW = ^TLVBKImageW;
  PLVBKImage = PLVBKImageW;
  TLVBKImageA = tagLVBKIMAGEA;
  TLVBKImageW = tagLVBKIMAGEW;
  TLVBKImage = TLVBKImageW;

const
  LVBKIF_SOURCE_NONE      = $00000000;
  LVBKIF_SOURCE_HBITMAP   = $00000001;
  LVBKIF_SOURCE_URL       = $00000002;
  LVBKIF_SOURCE_MASK      = $00000003;
  LVBKIF_STYLE_NORMAL     = $00000000;
  LVBKIF_STYLE_TILE       = $00000010;
  LVBKIF_STYLE_MASK       = $00000010;
  { For Windows >= XP }
  LVBKIF_FLAG_TILEOFFSET  = $00000100;
  LVBKIF_TYPE_WATERMARK   = $10000000;
  LVBKIF_FLAG_ALPHABLEND  = $20000000;

  LVM_SETBKIMAGEA         = LVM_FIRST + 68;
  LVM_SETBKIMAGEW         = LVM_FIRST + 138;
  LVM_GETBKIMAGEA         = LVM_FIRST + 69;
  LVM_GETBKIMAGEW         = LVM_FIRST + 139;
  { For Windows >= XP }
  LVM_SETSELECTEDCOLUMN   = LVM_FIRST + 140;
  LVM_SETVIEW             = LVM_FIRST + 142;
  LVM_GETVIEW             = LVM_FIRST + 143;

{ For Windows >= XP }
function ListView_SetSelectedColumn(hwnd: HWND; iCol: Integer): Integer; {inline;}
function ListView_SetView(hwnd: HWND; iView: Integer): Integer; {inline;}
function ListView_GetView(hwnd: HWND): Integer; {inline;}

const
  { For Windows >= XP }
  LV_VIEW_ICON            = $0000;
  LV_VIEW_DETAILS         = $0001;
  LV_VIEW_SMALLICON       = $0002;
  LV_VIEW_LIST            = $0003;
  LV_VIEW_TILE            = $0004;
  LV_VIEW_MAX             = $0004;

  { For Windows >= XP }
  LVGF_NONE           = $00000000;
  LVGF_HEADER         = $00000001;
  LVGF_FOOTER         = $00000002;
  LVGF_STATE          = $00000004;
  LVGF_ALIGN          = $00000008;
  LVGF_GROUPID        = $00000010;

  { For Windows >= Vista }
  LVGF_SUBTITLE           = $00000100;  { pszSubtitle is valid }
  LVGF_TASK               = $00000200;  { pszTask is valid }
  LVGF_DESCRIPTIONTOP     = $00000400;  { pszDescriptionTop is valid }
  LVGF_DESCRIPTIONBOTTOM  = $00000800;  { pszDescriptionBottom is valid }
  LVGF_TITLEIMAGE         = $00001000;  { iTitleImage is valid }
  LVGF_EXTENDEDIMAGE      = $00002000;  { iExtendedImage is valid }
  LVGF_ITEMS              = $00004000;  { iFirstItem and cItems are valid }
  LVGF_SUBSET             = $00008000;  { pszSubsetTitle is valid }
  LVGF_SUBSETITEMS        = $00010000;  { readonly, cItems holds count of items in visible subset, iFirstItem is valid }

  { For Windows >= XP }
  LVGS_NORMAL             = $00000000;
  LVGS_COLLAPSED          = $00000001;
  LVGS_HIDDEN             = $00000002;
  LVGS_NOHEADER           = $00000004;
  LVGS_COLLAPSIBLE        = $00000008;
  LVGS_FOCUSED            = $00000010;
  LVGS_SELECTED           = $00000020;
  LVGS_SUBSETED           = $00000040;
  LVGS_SUBSETLINKFOCUSED  = $00000080;

  { For Windows >= XP }
  LVGA_HEADER_LEFT    = $00000001;
  LVGA_HEADER_CENTER  = $00000002;
  LVGA_HEADER_RIGHT   = $00000004;  { Don't forget to validate exclusivity }
  LVGA_FOOTER_LEFT    = $00000008;
  LVGA_FOOTER_CENTER  = $00000010;
  LVGA_FOOTER_RIGHT   = $00000020;  { Don't forget to validate exclusivity }

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVGROUP}
  tagLVGROUP = record
    cbSize: UINT;
    mask: UINT;
    pszHeader: LPWSTR;
    cchHeader: Integer;

    pszFooter: LPWSTR;
    cchFooter: Integer;

    iGroupId: Integer;

    stateMask: UINT;
    state: UINT;
    uAlign: UINT;
                                                         
    pszSubtitle: LPWSTR;
    cchSubtitle: UINT;
    pszTask: LPWSTR;
    cchTask: UINT;
    pszDescriptionTop: LPWSTR;
    cchDescriptionTop: UINT;
    pszDescriptionBottom: LPWSTR;
    cchDescriptionBottom: UINT;
    iTitleImage: Integer;
    iExtendedImage: Integer;
    iFirstItem: Integer;     { Read only }
    cItems: UINT;            { Read only }
    pszSubsetTitle: LPWSTR;  { NULL if group is not subset }
    cchSubsetTitle: UINT; 
  end;
  PLVGroup = ^TLVGroup;
  TLVGroup = tagLVGROUP;

const
  { For Windows >= XP }
  LVM_INSERTGROUP         = LVM_FIRST + 145;
  LVM_SETGROUPINFO        = LVM_FIRST + 147;
  LVM_GETGROUPINFO        = LVM_FIRST + 149;
  LVM_REMOVEGROUP         = LVM_FIRST + 150;
  LVM_MOVEGROUP           = LVM_FIRST + 151;

  { For Windows >= Vista }
  LVM_GETGROUPCOUNT       = LVM_FIRST + 152;
  LVM_GETGROUPINFOBYINDEX = LVM_FIRST + 153;
  LVM_MOVEITEMTOGROUP     = LVM_FIRST + 154;

{ For Windows >= XP }
function ListView_InsertGroup(hwnd: HWND; index: Integer; const pgrp: TLVGroup): Integer; {inline;}
function ListView_SetGroupInfo(hwnd: HWND; iGroupId: Integer; const pgrp: TLVGroup): Integer; {inline;}
function ListView_GetGroupInfo(hwnd: HWND; iGroupId: Integer; var pgrp: TLVGroup): Integer; {inline;}
function ListView_RemoveGroup(hwnd: HWND; iGroupId: Integer): Integer; {inline;}
function ListView_MoveGroup(hwnd: HWND; iGroupId, toIndex: Integer): Integer; {inline;}

{ For Windows >= Vista }
function ListView_GetGroupCount(hwnd: HWND): Integer; {inline;}
function ListView_GetGroupInfoByIndex(hwnd: HWND; iIndex: Integer; var pgrp: TLVGroup): Integer; {inline;}
function ListView_MoveItemToGroup(hwnd: HWND; idItemFrom, idGroupTo: Integer): Integer; {inline;}

const
  { For Windows >= Vista }
  LVGGR_GROUP         = 0; // Entire expanded group
  LVGGR_HEADER        = 1; // Header only (collapsed group)
  LVGGR_LABEL         = 2; // Label only
  LVGGR_SUBSETLINK    = 3; // subset link only

  { For Windows >= Vista }
  LVM_GETGROUPRECT               = LVM_FIRST + 98;

{ For Windows >= Vista }
function ListView_GetGroupRect(hwnd: HWND; iGroupId, iType: Integer;
  var prc: TRect): Integer; {inline;}

const
  { For Windows >= XP }
  LVGMF_NONE          = $00000000;
  LVGMF_BORDERSIZE    = $00000001;
  LVGMF_BORDERCOLOR   = $00000002;
  LVGMF_TEXTCOLOR     = $00000004;

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVGROUPMETRICS}
  tagLVGROUPMETRICS = packed record
    cbSize: UINT;
    mask: UINT;
    Left: UINT;
    Top: UINT;
    Right: UINT;
    Bottom: UINT;
    crLeft: COLORREF;
    crTop: COLORREF;
    crRight: COLORREF;
    crBottom: COLORREF;
    crHeader: COLORREF;
    crFooter: COLORREF;
  end;
  PLVGroupMetrics = ^TLVGroupMetrics;
  TLVGroupMetrics = tagLVGROUPMETRICS;

const
  { For Windows >= XP }
  LVM_SETGROUPMETRICS         = LVM_FIRST + 155;
  LVM_GETGROUPMETRICS         = LVM_FIRST + 156;
  LVM_ENABLEGROUPVIEW         = LVM_FIRST + 157;
  LVM_SORTGROUPS              = LVM_FIRST + 158;

type
  { For Windows >= XP }
  { $EXTERNALSYM PFNLVGROUPCOMPARE}
  PFNLVGROUPCOMPARE = function(Group1_ID: Integer; Group2_ID: Integer;
    pvData: Pointer): Integer; stdcall;
  TFNLVGroupCompare = PFNLVGROUPCOMPARE;

{ For Windows >= XP }
function ListView_SetGroupMetrics(hwnd: HWND; const pGroupMetrics: TLVGroupMetrics): Integer; {inline;}
function ListView_GetGroupMetrics(hwnd: HWND; var pGroupMetrics: TLVGroupMetrics): Integer; {inline;}
function ListView_EnableGroupView(hwnd: HWND; fEnable: BOOL): Integer; {inline;}
function ListView_SortGroups(hwnd: HWND; pfnGroupCompare: TFNLVGroupCompare; plv: Pointer): Integer; {inline;}

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVINSERTGROUPSORTED}
  tagLVINSERTGROUPSORTED = record
    pfnGroupCompare: PFNLVGROUPCOMPARE;
    pvData: Pointer;
    lvGroup: TLVGroup;
  end;
  PLVInsertGroupSorted = ^TLVInsertGroupSorted;
  TLVInsertGroupSorted = tagLVINSERTGROUPSORTED;

const
  { For Windows >= XP }
  LVM_INSERTGROUPSORTED           = LVM_FIRST + 159;
  LVM_REMOVEALLGROUPS             = LVM_FIRST + 160;
  LVM_HASGROUP                    = LVM_FIRST + 161;
  { For Windows >= Vista }
  LVM_GETGROUPSTATE               = LVM_FIRST + 92;
  LVM_GETFOCUSEDGROUP             = LVM_FIRST + 93;

{ For Windows >= XP }
function ListView_InsertGroupSorted(hwnd: HWND; const structInsert: TLVInsertGroupSorted): Integer; {inline;}
function ListView_RemoveAllGroups(hwnd: HWND): Integer; {inline;}
function ListView_HasGroup(hwnd: HWND; dwGroupId: Integer): Integer; {inline;}
{ For Windows >= Vista }
function ListView_SetGroupState(hwnd: HWND; dwGroupId, dwMask, dwState: UINT): Integer;
function ListView_GetGroupState(hwnd: HWND; dwGroupId, dwMask: UINT): Integer; {inline;}
function ListView_GetFocusedGroup(hwnd: HWND): Integer; {inline;}

const
  { For Windows >= XP }
  LVTVIF_AUTOSIZE       = $00000000;
  LVTVIF_FIXEDWIDTH     = $00000001;
  LVTVIF_FIXEDHEIGHT    = $00000002;
  LVTVIF_FIXEDSIZE      = $00000003;
  { For Windows >= Vista }
  LVTVIF_EXTENDED       = $00000004;

  { For Windows >= XP }
  LVTVIM_TILESIZE       = $00000001;
  LVTVIM_COLUMNS        = $00000002;
  LVTVIM_LABELMARGIN    = $00000004;

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVTILEVIEWINFO}
  tagLVTILEVIEWINFO = packed record
    cbSize: UINT;
    dwMask: DWORD;      // LVTVIM_*
    dwFlags: DWORD;     // LVTVIF_*
    sizeTile: SIZE;
    cLines: Integer;
    rcLabelMargin: TRect;
  end;
  PLVTileViewInfo = ^TLVTileViewInfo;
  TLVTileViewInfo = tagLVTILEVIEWINFO;

  { For Windows >= XP }
  { $EXTERNALSYM tagLVTILEINFO}
  tagLVTILEINFO = packed record
    cbSize: UINT;
    iItem: Integer;
    cColumns: UINT;
    puColumns: PUINT;
                                                         
    { For Windows >= Vista }
    //piColFmt: PInteger;
  end;
  PLVTileInfo = ^TLVTileInfo;
  TLVTileInfo = tagLVTILEINFO;

const
                               
//  LVTILEINFO_V5_SIZE = CCSIZEOF_STRUCT(LVTILEINFO, puColumns);

  { For Windows >= XP }
  LVM_SETTILEVIEWINFO                 = LVM_FIRST + 162;
  LVM_GETTILEVIEWINFO                 = LVM_FIRST + 163;
  LVM_SETTILEINFO                     = LVM_FIRST + 164;
  LVM_GETTILEINFO                     = LVM_FIRST + 165;

{ For Windows >= XP }
function ListView_SetTileViewInfo(hwnd: HWND; const ptvi: TLVTileViewInfo): Integer; {inline;}
function ListView_GetTileViewInfo(hwnd: HWND; var ptvi: TLVTileViewInfo): Integer; {inline;}
function ListView_SetTileInfo(hwnd: HWND; const pti: TLVTileInfo): Integer; {inline;}
function ListView_GetTileInfo(hwnd: HWND; var pti: TLVTileInfo): Integer; {inline;}

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVINSERTMARK}
  tagLVINSERTMARK = packed record
    cbSize: UINT;
    dwFlags: DWORD;
    iItem: Integer;
    dwReserved: DWORD;
  end;
  PLVInsertMark = ^TLVInsertMark;
  TLVInsertMark = tagLVINSERTMARK;

const
  { For Windows >= XP }
  LVIM_AFTER      = $00000001; // TRUE = insert After iItem, otherwise before

  { For Windows >= XP }
  LVM_SETINSERTMARK                   = LVM_FIRST + 166;
  LVM_GETINSERTMARK                   = LVM_FIRST + 167;
  LVM_INSERTMARKHITTEST               = LVM_FIRST + 168;
  LVM_GETINSERTMARKRECT               = LVM_FIRST + 169;
  LVM_SETINSERTMARKCOLOR              = LVM_FIRST + 170;
  LVM_GETINSERTMARKCOLOR              = LVM_FIRST + 171;

{ For Windows >= XP }
function ListView_SetInsertMark(hwnd: HWND; const lvim: TLVInsertMark): BOOL; {inline;}
function ListView_GetInsertMark(hwnd: HWND; var lvim: TLVInsertMark): BOOL; {inline;}
function ListView_InsertMarkHitTest(hwnd: HWND; const point: TPoint;
  const lvim: TLVInsertMark): Integer; {inline;}
function ListView_GetInsertMarkRect(hwnd: HWND; var rc: TRect): Integer; {inline;}
function ListView_SetInsertMarkColor(hwnd: HWND; color: TColorRef): TColorRef; {inline;}
function ListView_GetInsertMarkColor(hwnd: HWND): TColorRef; {inline;}

type
  { For Windows >= XP }
  { $EXTERNALSYM tagLVSETINFOTIP}
  tagLVSETINFOTIP = record
    cbSize: UINT;
    dwFlags: DWORD;
    pszText: LPWSTR;
    iItem: Integer;
    iSubItem: Integer;
  end;
  PLVSetInfoTip = ^TLVSetInfoTip;
  TLVSetInfoTip = tagLVSETINFOTIP;

const
  { For Windows >= XP }
  LVM_SETINFOTIP          = LVM_FIRST + 173;
  LVM_GETSELECTEDCOLUMN   = LVM_FIRST + 174;
  LVM_ISGROUPVIEWENABLED  = LVM_FIRST + 175;
  LVM_GETOUTLINECOLOR     = LVM_FIRST + 176;
  LVM_SETOUTLINECOLOR     = LVM_FIRST + 177;
  LVM_CANCELEDITLABEL     = LVM_FIRST + 179;
  LVM_MAPINDEXTOID        = LVM_FIRST + 180;
  LVM_MAPIDTOINDEX        = LVM_FIRST + 181;
  { For Windows >= Vista }
  LVM_ISITEMVISIBLE       = LVM_FIRST + 182;

{ For Windows >= XP }
function ListView_SetInfoTip(hwndLV: HWND; const plvInfoTip: TLVSetInfoTip): BOOL; {inline;}
function ListView_GetSelectedColumn(hwnd: HWND): UINT; {inline;}
function ListView_IsGroupViewEnabled(hwnd: HWND): BOOL; {inline;}
function ListView_GetOutlineColor(hwnd: HWND): TColorRef; {inline;}
function ListView_SetOutlineColor(hwnd: HWND; color: TColorRef): TColorRef; {inline;}
function ListView_CancelEditLabel(hwnd: HWND): Integer; {inline;}

// These next two methods make it easy to identify an item that can be repositioned
// within listview. For example: Many developers use the lParam to store an identifier that is
// unique. Unfortunatly, in order to find this item, they have to iterate through all of the items
// in the listview. Listview will maintain a unique identifier.  The upper bound is the size of a DWORD.
function ListView_MapIndexToID(hwnd: HWND; index: UINT): UINT; {inline;}
function ListView_MapIDToIndex(hwnd: HWND; id: UINT): UINT; {inline;}

{ For Windows >= Vista }
function ListView_IsItemVisible(hwnd: HWND; index: UINT): UINT; {inline;}
function ListView_SetGroupHeaderImageList(hwnd: HWND; himl: HIMAGELIST): HIMAGELIST; {inline;}
function ListView_GetGroupHeaderImageList(hwnd: HWND): HIMAGELIST; {inline;}

const
  { For Windows >= Vista }
  LVM_GETEMPTYTEXT  = LVM_FIRST + 204;
  LVM_GETFOOTERRECT = LVM_FIRST + 205;

{ For Windows >= Vista }
function ListView_GetEmptyText(hwnd: HWND; pszText: LPWSTR; cchText: UINT): BOOL; {inline;}
function ListView_GetFooterRect(hwnd: HWND; var prc: TRect): BOOL; {inline;}

const
  // footer flags
  { For Windows >= Vista }
  LVFF_ITEMCOUNT          = $00000001;

type
  { For Windows >= Vista }
  { $EXTERNALSYM tagLVFOOTERINFO}
  tagLVFOOTERINFO = record
    mask: UINT;         // LVFF_*
    pszText: LPWSTR;
    cchTextMax: Integer;
    cItems: UINT;
  end;
  PLVFooterInfo = ^TLVFooterInfo;
  TLVFooterInfo = tagLVFOOTERINFO;

const
  { For Windows >= Vista }
  LVM_GETFOOTERINFO = LVM_FIRST + 206;
  LVM_GETFOOTERITEMRECT = LVM_FIRST + 207;

{ For Windows >= Vista }
function ListView_GetFooterInfo(hwnd: HWND; var plvfi: TLVFooterInfo): BOOL; {inline;}
function ListView_GetFooterItemRect(hwnd: HWND; iItem: UINT; var prc: TRect): BOOL; {inline;}

const
  { For Windows >= Vista }
  // footer item flags
  LVFIF_TEXT               = $00000001;
  LVFIF_STATE              = $00000002;

  { For Windows >= Vista }
  // footer item state
  LVFIS_FOCUSED            = $0001;

type
  { For Windows >= Vista }
  { $EXTERNALSYM tagLVFOOTERITEM}
  tagLVFOOTERITEM = record
    mask: UINT;         // LVFIF_*
    iItem: Integer;
    pszText: LPWSTR;
    cchTextMax: Integer;
    state: UINT;        // LVFIS_*
    stateMask: UINT;    // LVFIS_*
  end;
  PLVFooterItem = ^TLVFooterItem;
  TLVFooterItem = tagLVFOOTERITEM;

const
  { For Windows >= Vista }
  LVM_GETFOOTERITEM = LVM_FIRST + 208;

function ListView_GetFooterItem(hwnd: HWND; iItem: UINT; var pfi: TLVFooterItem): BOOL; {inline;}

// supports a single item in multiple groups.
type
  { For Windows >= Vista }
  { $EXTERNALSYM tagLVITEMINDEX}
  tagLVITEMINDEX = packed record
    iItem: Integer;     // listview item index
    iGroup: Integer;    // group index (must be -1 if group view is not enabled)
  end;
  PLVItemIndex = ^TLVItemIndex;
  TLVItemIndex = tagLVITEMINDEX;

const
  { For Windows >= Vista }
  LVM_GETITEMINDEXRECT    = LVM_FIRST + 209;
  LVM_SETITEMINDEXSTATE   = LVM_FIRST + 210;
  LVM_GETNEXTITEMINDEX    = LVM_FIRST + 211;

{ For Windows >= Vista }
function ListView_GetItemIndexRect(hwnd: HWND; const plvii: TLVItemIndex;
  iSubItem, code: Integer; var prc: TRect): BOOL; {inline;}
function ListView_SetItemIndexState(hwnd: HWND; const plvii: TLVItemIndex;
  data, mask: UINT): HRESULT;
function ListView_GetNextItemIndex(hwnd: HWND; var plvii: TLVItemIndex;
  flags: LPARAM): BOOL; {inline;}

const  
{$IFDEF UNICODE}
  LVM_SETBKIMAGE = LVM_SETBKIMAGEW;
  LVM_GETBKIMAGE = LVM_GETBKIMAGEW;
{$ELSE}
  LVM_SETBKIMAGE = LVM_SETBKIMAGEA;
  LVM_GETBKIMAGE = LVM_GETBKIMAGEA;
{$ENDIF}

function ListView_SetBkImage(hwnd: HWND; plvbki: PLVBKImage): BOOL; {inline;}
function ListView_SetBkImageA(hwnd: HWND; plvbki: PLVBKImageA): BOOL; {inline;}
function ListView_SetBkImageW(hwnd: HWND; plvbki: PLVBKImageW): BOOL; {inline;}

function ListView_GetBkImage(hwnd: HWND; plvbki: PLVBKImage): BOOL; {inline;}
function ListView_GetBkImageA(hwnd: HWND; plvbki: PLVBKImageA): BOOL; {inline;}
function ListView_GetBkImageW(hwnd: HWND; plvbki: PLVBKImageW): BOOL; {inline;}

type
  tagNMLISTVIEW = packed record
    hdr: TNMHDR;
    iItem: Integer;
    iSubItem: Integer;
    uNewState: UINT;
    uOldState: UINT;
    uChanged: UINT;
    ptAction: TPoint;
    lParam: LPARAM;
  end;
  _NM_LISTVIEW = tagNMLISTVIEW;
  NM_LISTVIEW = tagNMLISTVIEW;
  PNMListView = ^TNMListView;
  TNMListView = tagNMLISTVIEW;

  // NMITEMACTIVATE is used instead of NMLISTVIEW in IE >= 0x400
  // therefore all the fields are the same except for extra uKeyFlags
  // they are used to store key flags at the time of the single click with
  // delayed activation - because by the time the timer goes off a user may
  // not hold the keys (shift, ctrl) any more
  tagNMITEMACTIVATE = packed record
    hdr: TNMHdr;
    iItem: Integer;
    iSubItem: Integer;
    uNewState: UINT;
    uOldState: UINT;
    uChanged: UINT;
    ptAction: TPoint;
    lParam: LPARAM;
    uKeyFlags: UINT;
  end;
  PNMItemActivate = ^TNMItemActivate;
  TNMItemActivate = tagNMITEMACTIVATE;

const
  // key flags stored in uKeyFlags
  LVKF_ALT       = $0001;
  LVKF_CONTROL   = $0002;
  LVKF_SHIFT     = $0004;

type
  tagNMLVCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    clrText: COLORREF;
    clrTextBk: COLORREF;
    iSubItem: Integer;
                                                           
(*    dwItemType: DWORD;

    // Item custom draw
    clrFace: COLORREF;
    iIconEffect: Integer;
    iIconPhase: Integer;
    iPartId: Integer;
    iStateId: Integer;

    // Group Custom Draw
    rcText: TRect;
    uAlign: UINT;     // Alignment. Use LVGA_HEADER_CENTER, LVGA_HEADER_RIGHT, LVGA_HEADER_LEFT
*)  end;
  PNMLVCustomDraw = ^TNMLVCustomDraw;
  TNMLVCustomDraw = tagNMLVCUSTOMDRAW;

  tagNMLVCACHEHINT = packed record
    hdr: TNMHDR;
    iFrom: Integer;
    iTo: Integer;
  end;
  PNMLVCacheHint = ^TNMLVCacheHint;
  TNMLVCacheHint = tagNMLVCACHEHINT;
  PNMCacheHint = ^TNMCacheHint;
  TNMCacheHint = tagNMLVCACHEHINT;

  tagNMLVFINDITEMA = record // WIN2K
    hdr: TNMHdr;
    iStart: Integer;
    lvfi: TLVFindInfoA;
  end;
  tagNMLVFINDITEMW = record // WIN2K
    hdr: TNMHdr;
    iStart: Integer;
    lvfi: TLVFindInfoW;
  end;
  tagNMLVFINDITEM = tagNMLVFINDITEMW;
  PNMLVFinditemA = ^TNMLVFinditemA;
  PNMLVFinditemW = ^TNMLVFinditemW;
  PNMLVFinditem = PNMLVFinditemW;
  TNMLVFinditemA = tagNMLVFINDITEMA; // WIN2K
  TNMLVFinditemW = tagNMLVFINDITEMW; // WIN2K
  TNMLVFinditem = TNMLVFinditemW;

  PNMFinditemA = ^TNMFinditemA;
  PNMFinditemW = ^TNMFinditemW;
  PNMFinditem = PNMFinditemW;
  TNMFinditemA = tagNMLVFINDITEMA; // WIN2K
  TNMFinditemW = tagNMLVFINDITEMW; // WIN2K
  TNMFinditem = TNMFinditemW;

  tagNMLVODSTATECHANGE = packed record
    hdr: TNMHdr;
    iFrom: Integer;
    iTo: Integer;
    uNewState: UINT;
    uOldState: UINT;
  end;
  PNMLVODStateChange = ^TNMLVODStateChange;
  TNMLVODStateChange = tagNMLVODSTATECHANGE;

const
  LVN_ITEMCHANGING        = LVN_FIRST-0;
  LVN_ITEMCHANGED         = LVN_FIRST-1;
  LVN_INSERTITEM          = LVN_FIRST-2;
  LVN_DELETEITEM          = LVN_FIRST-3;
  LVN_DELETEALLITEMS      = LVN_FIRST-4;
  LVN_COLUMNCLICK         = LVN_FIRST-8;
  LVN_BEGINDRAG           = LVN_FIRST-9;
  LVN_BEGINRDRAG          = LVN_FIRST-11;

  LVN_ODCACHEHINT         = LVN_FIRST-13;
  LVN_ODFINDITEMA         = LVN_FIRST-52;
  LVN_ODFINDITEMW         = LVN_FIRST-79;

  LVN_ITEMACTIVATE        = LVN_FIRST-14;
  LVN_ODSTATECHANGED      = LVN_FIRST-15;

{$IFDEF UNICODE}
  LVN_ODFINDITEM          = LVN_ODFINDITEMW; 
{$ELSE}
  LVN_ODFINDITEM          = LVN_ODFINDITEMA; 
{$ENDIF}

  LVN_BEGINLABELEDITA      = LVN_FIRST-5;
  LVN_ENDLABELEDITA        = LVN_FIRST-6;
  LVN_BEGINLABELEDITW      = LVN_FIRST-75;
  LVN_ENDLABELEDITW        = LVN_FIRST-76;
{$IFDEF UNICODE}
  LVN_BEGINLABELEDIT      = LVN_BEGINLABELEDITW;
  LVN_ENDLABELEDIT        = LVN_ENDLABELEDITW;
{$ELSE}
  LVN_BEGINLABELEDIT      = LVN_BEGINLABELEDITA;
  LVN_ENDLABELEDIT        = LVN_ENDLABELEDITA;
{$ENDIF}

  LVN_HOTTRACK            = LVN_FIRST-21;
  
  LVN_GETDISPINFOA        = LVN_FIRST-50;
  LVN_SETDISPINFOA        = LVN_FIRST-51;
  LVN_GETDISPINFOW        = LVN_FIRST-77;
  LVN_SETDISPINFOW        = LVN_FIRST-78;
{$IFDEF UNICODE}
  LVN_GETDISPINFO        = LVN_GETDISPINFOW;
  LVN_SETDISPINFO        = LVN_SETDISPINFOW;
{$ELSE}
  LVN_GETDISPINFO        = LVN_GETDISPINFOA;
  LVN_SETDISPINFO        = LVN_SETDISPINFOA;
{$ENDIF}

  LVIF_DI_SETITEM         = $1000;

type
{$IFNDEF UNICODE}
  PLVDispInfoA = ^TLVDispInfoA;
  PLVDispInfoW = ^TLVDispInfoW;
  PLVDispInfo = PLVDispInfoA;
  tagLVDISPINFO = record
    hdr: TNMHDR;
    item: TLVItemA;
  end;
  _LV_DISPINFO = tagLVDISPINFO;
  tagLVDISPINFOW = record
    hdr: TNMHDR;
    item: TLVItemW;
  end;
  _LV_DISPINFOW = tagLVDISPINFOW;
  TLVDispInfoA = tagLVDISPINFO;
  TLVDispInfoW = tagLVDISPINFOW;
  TLVDispInfo = TLVDispInfoA;
  LV_DISPINFOA = tagLVDISPINFO;
  LV_DISPINFOW = tagLVDISPINFOW;
  LV_DISPINFO = LV_DISPINFOA;
{$ELSE}
  PLVDispInfoA = ^TLVDispInfoA;
  PLVDispInfoW = ^TLVDispInfoW;
  PLVDispInfo = PLVDispInfoW;
  tagLVDISPINFOW = record
    hdr: TNMHDR;
    item: TLVItemW;
  end;
  tagLVDISPINFO = tagLVDISPINFOW;
  _LV_DISPINFO = tagLVDISPINFOW;
  tagLVDISPINFOA = record
    hdr: TNMHDR;
    item: TLVItemA;
  end;
  _LV_DISPINFOW = tagLVDISPINFO;
  TLVDispInfoW = tagLVDISPINFO;
  TLVDispInfoA = tagLVDISPINFO;
  TLVDispInfo = TLVDispInfoW;
  LV_DISPINFOW = tagLVDISPINFOW;
  LV_DISPINFOA = tagLVDISPINFO;
  LV_DISPINFO = LV_DISPINFOW;
{$ENDIF}

const
  LVN_KEYDOWN             = LVN_FIRST-55;

type
  PLVKeyDown = ^TLVKeyDown;
  tagLVKEYDOWN = packed record
    hdr: TNMHDR;
    wVKey: Word;
    flags: UINT;
  end;
  _LV_KEYDOWN = tagLVKEYDOWN;
  TLVKeyDown = tagLVKEYDOWN;
  LV_KEYDOWN = tagLVKEYDOWN;

const
  LVN_MARQUEEBEGIN        = LVN_FIRST-56;

type
  { For Windows >= Vista }
  { $EXTERNALSYM tagNMLVLINK}
  tagNMLVLINK = record
    hdr: NMHDR;
    link: TLItem;
    iItem: Integer;
    iSubItem: Integer;
  end;
  PNMLVLink = ^TNMLVLink;
  TNMLVLink = tagNMLVLINK;

type
  tagNMLVGETINFOTIPA = record
    hdr: TNMHdr;
    dwFlags: DWORD;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iItem: Integer;
    iSubItem: Integer;
    lParam: LPARAM;
  end;
  tagNMLVGETINFOTIPW = record
    hdr: TNMHdr;
    dwFlags: DWORD;
    pszText: PWideChar;
    cchTextMax: Integer;
    iItem: Integer;
    iSubItem: Integer;
    lParam: LPARAM;
  end;
  tagNMLVGETINFOTIP = tagNMLVGETINFOTIPW;
  PNMLVGetInfoTipA = ^TNMLVGetInfoTipA;
  PNMLVGetInfoTipW = ^TNMLVGetInfoTipW;
  PNMLVGetInfoTip = PNMLVGetInfoTipW;
  TNMLVGetInfoTipA = tagNMLVGETINFOTIPA;
  TNMLVGetInfoTipW = tagNMLVGETINFOTIPW;
  TNMLVGetInfoTip = TNMLVGetInfoTipW;

const
  // NMLVGETINFOTIPA.dwFlag values
  LVGIT_UNFOLDED  = $0001;

  LVN_GETINFOTIPA          = LVN_FIRST-57;
  LVN_GETINFOTIPW          = LVN_FIRST-58;

{$IFDEF UNICODE}
  LVN_GETINFOTIP          = LVN_GETINFOTIPW;
{$ELSE}
  LVN_GETINFOTIP          = LVN_GETINFOTIPA;
{$ENDIF}


// 
//  LVN_INCREMENTALSEARCH gives the app the opportunity to customize
//  incremental search.  For example, if the items are numeric,
//  the app can do numerical search instead of string search.
// 
//  ListView notifies the app with NMLVFINDITEM.
//  The app sets pnmfi->lvfi.lParam to the result of the incremental search,
//  or to LVNSCH_DEFAULT if ListView should do the default search,
//  or to LVNSCH_ERROR to fail the search and just beep,
//  or to LVNSCH_IGNORE to stop all ListView processing.
// 
//  The return value is not used.

  LVNSCH_DEFAULT  = -1; 
  LVNSCH_ERROR    = -2; 
  LVNSCH_IGNORE   = -3; 

  LVN_INCREMENTALSEARCHA   = LVN_FIRST-62; 
  LVN_INCREMENTALSEARCHW   = LVN_FIRST-63; 

                                                  
  LVN_INCREMENTALSEARCH    = LVN_INCREMENTALSEARCHW;

  { For Windows >= Vista }
  LVN_COLUMNDROPDOWN       = LVN_FIRST-64;

  { For Windows >= Vista }
  LVN_COLUMNOVERFLOWCLICK  = LVN_FIRST-66;

type
  { For Windows >= XP }
  { $EXTERNALSYM tagNMLVSCROLL}
  tagNMLVSCROLL = packed record
    hdr: NMHDR;
    dx: Integer;
    dy: Integer;
  end;
  PNMLVScroll = ^TNMLVScroll;
  TNMLVScroll = tagNMLVSCROLL;

const
  { For Windows >= XP }
  LVN_BEGINSCROLL          = LVN_FIRST-80;
  LVN_ENDSCROLL            = LVN_FIRST-81;

  { For Windows >= Vista }
  LVN_LINKCLICK           = LVN_FIRST-84;

  { For Windows >= Vista }
  EMF_CENTERED            = $00000001;  // render markup centered in the listview area

type
  { For Windows >= Vista }
  { $EXTERNALSYM tagNMLVEMPTYMARKUP}
  tagNMLVEMPTYMARKUP = record
    hdr: NMHDR;
    // out params from client back to listview
    dwFlags: DWORD;                     // EMF_*
    szMarkup: packed array[0..L_MAX_URL_LENGTH-1] of WCHAR;// markup displayed
  end;
  PNMLVEmptyMarkup = ^TNMLVEmptyMarkup;
  TNMLVEmptyMarkup = tagNMLVEMPTYMARKUP;

const
  { For Windows >= Vista }
  LVN_GETEMPTYMARKUP      = LVN_FIRST-87;


{ ====== TREEVIEW CONTROL =================== }

const
  WC_TREEVIEW = 'SysTreeView32';

const
  TVS_HASBUTTONS          = $0001;
  TVS_HASLINES            = $0002;
  TVS_LINESATROOT         = $0004;
  TVS_EDITLABELS          = $0008;
  TVS_DISABLEDRAGDROP     = $0010;
  TVS_SHOWSELALWAYS       = $0020;
  TVS_RTLREADING          = $0040;
  TVS_NOTOOLTIPS          = $0080;
  TVS_CHECKBOXES          = $0100;
  TVS_TRACKSELECT         = $0200;
  TVS_SINGLEEXPAND        = $0400;
  TVS_INFOTIP             = $0800;
  TVS_FULLROWSELECT       = $1000;
  TVS_NOSCROLL            = $2000;
  TVS_NONEVENHEIGHT       = $4000;
  { For IE >= 0x0500 }
  TVS_NOHSCROLL           = $8000;  // TVS_NOSCROLL overrides this

  { For Windows >= Vista }
  TVS_EX_MULTISELECT          = $0002;
  TVS_EX_DOUBLEBUFFER         = $0004;
  TVS_EX_NOINDENTSTATE        = $0008;
  TVS_EX_RICHTOOLTIP          = $0010;
  TVS_EX_AUTOHSCROLL          = $0020;
  TVS_EX_FADEINOUTEXPANDOS    = $0040;
  TVS_EX_PARTIALCHECKBOXES    = $0080;
  TVS_EX_EXCLUSIONCHECKBOXES  = $0100;
  TVS_EX_DIMMEDCHECKBOXES     = $0200;
  TVS_EX_DRAWIMAGEASYNC       = $0400;

type
  HTREEITEM = ^_TREEITEM;
  _TREEITEM = packed record
  end;

const
  TVIF_TEXT               = $0001;
  TVIF_IMAGE              = $0002;
  TVIF_PARAM              = $0004;
  TVIF_STATE              = $0008;
  TVIF_HANDLE             = $0010;
  TVIF_SELECTEDIMAGE      = $0020;
  TVIF_CHILDREN           = $0040;
  TVIF_INTEGRAL           = $0080;
  { For Windows >= Vista }
  TVIF_STATEEX            = $0100;
  TVIF_EXPANDEDIMAGE      = $0200;

  TVIS_FOCUSED            = $0001;
  TVIS_SELECTED           = $0002;
  TVIS_CUT                = $0004;
  TVIS_DROPHILITED        = $0008;
  TVIS_BOLD               = $0010;
  TVIS_EXPANDED           = $0020;
  TVIS_EXPANDEDONCE       = $0040;
  TVIS_EXPANDPARTIAL      = $0080;

  TVIS_OVERLAYMASK        = $0F00;
  TVIS_STATEIMAGEMASK     = $F000;
  TVIS_USERMASK           = $F000;

  { For IE >= 0x0600 }
  TVIS_EX_FLAT            = $0001;
  TVIS_EX_ALL             = $0002;
  { For Windows >= Vista }
  TVIS_EX_DISABLED        = $0002;

// Structure for TreeView's NM_TVSTATEIMAGECHANGING notification
type
  { For IE >= 0x0600 }
  { $EXTERNALSYM tagNMTVSTATEIMAGECHANGING}
  tagNMTVSTATEIMAGECHANGING = packed record
    hdr: NMHDR;
    hti: HTREEITEM;
    iOldStateImageIndex: Integer;
    iNewStateImageIndex: Integer;
  end;
  PNMTVStateImageChanging = ^TNMTVStateImageChanging;
  TNMTVStateImageChanging = tagNMTVSTATEIMAGECHANGING;

const
  I_CHILDRENCALLBACK  = -1;

type
  PTVItemA = ^TTVItemA;
  PTVItemW = ^TTVItemW;
  PTVItem = PTVItemW;
  tagTVITEMA = record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  tagTVITEMW = record
    mask: UINT;
    hItem: HTreeItem;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
  end;
  tagTVITEM = tagTVITEMW;
  _TV_ITEMA = tagTVITEMA;
  _TV_ITEMW = tagTVITEMW;
  _TV_ITEM = _TV_ITEMW;
  TTVItemA = tagTVITEMA;
  TTVItemW = tagTVITEMW;
  TTVItem = TTVItemW;
  TV_ITEMA = tagTVITEMA;
  TV_ITEMW = tagTVITEMW;
  TV_ITEM = TV_ITEMW;

  // only used for Get and Set messages.  no notifies
  tagTVITEMEXA = record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
                                                        
    { For Windows >= Vista }
    uStateEx: UINT;
    hwnd: HWND;
    iExpandedImage: Integer;
  end;
  tagTVITEMEXW = record
    mask: UINT;
    hItem: HTREEITEM;
    state: UINT;
    stateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    cChildren: Integer;
    lParam: LPARAM;
    iIntegral: Integer;
                                                        
    { For Windows >= Vista }
    uStateEx: UINT;
    hwnd: HWND;
    iExpandedImage: Integer;
  end;
  tagTVITEMEX = tagTVITEMEXW;
  PTVItemExA = ^TTVItemExA;
  PTVItemExW = ^TTVItemExW;
  PTVItemEx = PTVItemExW;
  TTVItemExA = tagTVITEMEXA;
  TTVItemExW = tagTVITEMEXW;
  TTVItemEx = TTVItemExW;

const
  TVI_ROOT                = HTreeItem($FFFF0000);
  TVI_FIRST               = HTreeItem($FFFF0001);
  TVI_LAST                = HTreeItem($FFFF0002);
  TVI_SORT                = HTreeItem($FFFF0003);

type
  PTVInsertStructA = ^TTVInsertStructA;
  PTVInsertStructW = ^TTVInsertStructW;
  PTVInsertStruct = PTVInsertStructW;
  tagTVINSERTSTRUCTA = record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExA);
      1: (item: TTVItemA);
  end;
  tagTVINSERTSTRUCTW = record
    hParent: HTreeItem;
    hInsertAfter: HTreeItem;
    case Integer of
      0: (itemex: TTVItemExW);
      1: (item: TTVItemW);
  end;
  tagTVINSERTSTRUCT = tagTVINSERTSTRUCTW;
  _TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  _TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  _TV_INSERTSTRUCT = _TV_INSERTSTRUCTW;
  TTVInsertStructA = tagTVINSERTSTRUCTA;
  TTVInsertStructW = tagTVINSERTSTRUCTW;
  TTVInsertStruct = TTVInsertStructW;
  TV_INSERTSTRUCTA = tagTVINSERTSTRUCTA;
  TV_INSERTSTRUCTW = tagTVINSERTSTRUCTW;
  TV_INSERTSTRUCT = TV_INSERTSTRUCTW;

const
  TVM_INSERTITEMA          = TV_FIRST + 0;
  TVM_INSERTITEMW          = TV_FIRST + 50;
{$IFDEF UNICODE}
  TVM_INSERTITEM          = TVM_INSERTITEMW;
{$ELSE}
  TVM_INSERTITEM          = TVM_INSERTITEMA;
{$ENDIF}

function TreeView_InsertItem(hwnd: HWND; const lpis: TTVInsertStruct): HTreeItem; {inline;}
function TreeView_InsertItemA(hwnd: HWND; const lpis: TTVInsertStructA): HTreeItem; {inline;}
function TreeView_InsertItemW(hwnd: HWND; const lpis: TTVInsertStructW): HTreeItem; {inline;}

const
  TVM_DELETEITEM          = TV_FIRST + 1;

function TreeView_DeleteItem(hwnd: HWND; hitem: HTreeItem): Bool; {inline;}

function TreeView_DeleteAllItems(hwnd: HWND): Bool; {inline;}

const
  TVM_EXPAND              = TV_FIRST + 2;

function TreeView_Expand(hwnd: HWND; hitem: HTreeItem; code: Integer): Bool; {inline;}

const
  TVE_COLLAPSE            = $0001;
  TVE_EXPAND              = $0002;
  TVE_TOGGLE              = $0003;
  TVE_EXPANDPARTIAL       = $4000;
  TVE_COLLAPSERESET       = $8000;

const
  TVM_GETITEMRECT         = TV_FIRST + 4;

function TreeView_GetItemRect(hwnd: HWND; hitem: HTreeItem;
  var prc: TRect; code: Bool): Bool;

const
  TVM_GETCOUNT            = TV_FIRST + 5;

function TreeView_GetCount(hwnd: HWND): UINT; {inline;}

const
  TVM_GETINDENT           = TV_FIRST + 6;

function TreeView_GetIndent(hwnd: HWND): UINT; {inline;}

const
  TVM_SETINDENT           = TV_FIRST + 7;

function TreeView_SetIndent(hwnd: HWND; indent: Integer): Bool; {inline;}

const
  TVM_GETIMAGELIST        = TV_FIRST + 8;

function TreeView_GetImageList(hwnd: HWND; iImage: Integer): HIMAGELIST; {inline;}

const
  TVSIL_NORMAL            = 0;
  TVSIL_STATE             = 2;


const
  TVM_SETIMAGELIST        = TV_FIRST + 9;

function TreeView_SetImageList(hwnd: HWND; himl: HIMAGELIST;
  iImage: Integer): HIMAGELIST; {inline;}

const
  TVM_GETNEXTITEM         = TV_FIRST + 10;

function TreeView_GetNextItem(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem; {inline;}

const
  TVGN_ROOT               = $0000;
  TVGN_NEXT               = $0001;
  TVGN_PREVIOUS           = $0002;
  TVGN_PARENT             = $0003;
  TVGN_CHILD              = $0004;
  TVGN_FIRSTVISIBLE       = $0005;
  TVGN_NEXTVISIBLE        = $0006;
  TVGN_PREVIOUSVISIBLE    = $0007;
  TVGN_DROPHILITE         = $0008;
  TVGN_CARET              = $0009;
  TVGN_LASTVISIBLE        = $000A;
  { For IE >= 0x0600 }
  TVGN_NEXTSELECTED       = $000B;

  { For Windows >= XP }
  TVSI_NOSINGLEEXPAND     = $8000; // Should not conflict with TVGN flags.

function TreeView_GetChild(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetNextSibling(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetPrevSibling(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetParent(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetFirstVisible(hwnd: HWND): HTreeItem;
function TreeView_GetNextVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetPrevVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_GetSelection(hwnd: HWND): HTreeItem;
function TreeView_GetDropHilite(hwnd: HWND): HTreeItem;
function TreeView_GetRoot(hwnd: HWND): HTreeItem;
function TreeView_GetLastVisible(hwnd: HWND): HTreeItem;
{ For Windows >= Vista }
function TreeView_GetNextSelected(hwnd: HWND; hitem: HTreeItem): HTreeItem; {inline;}

const
  TVM_SELECTITEM          = TV_FIRST + 11;

function TreeView_Select(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem; {inline;}

function TreeView_SelectItem(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_SelectDropTarget(hwnd: HWND; hitem: HTreeItem): HTreeItem;
function TreeView_SelectSetFirstVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;

const
  TVM_GETITEMA             = TV_FIRST + 12;
  TVM_GETITEMW             = TV_FIRST + 62;
{$IFDEF UNICODE}
  TVM_GETITEM             = TVM_GETITEMW;
{$ELSE}
  TVM_GETITEM             = TVM_GETITEMA;
{$ENDIF}

function TreeView_GetItem(hwnd: HWND; var pitem: TTVItem): Bool; {inline;}
function TreeView_GetItemA(hwnd: HWND; var pitem: TTVItemA): Bool; {inline;}
function TreeView_GetItemW(hwnd: HWND; var pitem: TTVItemW): Bool; {inline;}

const
  TVM_SETITEMA             = TV_FIRST + 13;
  TVM_SETITEMW             = TV_FIRST + 63;
{$IFDEF UNICODE}
  TVM_SETITEM             = TVM_SETITEMW;
{$ELSE}
  TVM_SETITEM             = TVM_SETITEMA;
{$ENDIF}

function TreeView_SetItem(hwnd: HWND; const pitem: TTVItem): Bool; {inline;} overload;
function TreeView_SetItem(hwnd: HWND; const pitem: TTVItemEx): Bool; {inline;} overload;
function TreeView_SetItemA(hwnd: HWND; const pitem: TTVItemA): Bool; {inline;} overload;
function TreeView_SetItemA(hwnd: HWND; const pitem: TTVItemExA): Bool; {inline;} overload;
function TreeView_SetItemW(hwnd: HWND; const pitem: TTVItemW): Bool; {inline;} overload;
function TreeView_SetItemW(hwnd: HWND; const pitem: TTVItemExW): Bool; {inline;} overload;

const
  TVM_EDITLABELA           = TV_FIRST + 14;
  TVM_EDITLABELW           = TV_FIRST + 65;
{$IFDEF UNICODE}
  TVM_EDITLABEL           = TVM_EDITLABELW;
{$ELSE}
  TVM_EDITLABEL           = TVM_EDITLABELA;
{$ENDIF}

function TreeView_EditLabel(hwnd: HWND; hitem: HTreeItem): HWND; {inline;}
function TreeView_EditLabelA(hwnd: HWND; hitem: HTreeItem): HWND; {inline;}
function TreeView_EditLabelW(hwnd: HWND; hitem: HTreeItem): HWND; {inline;}

const
  TVM_GETEDITCONTROL      = TV_FIRST + 15;

function TreeView_GetEditControl(hwnd: HWND): HWND; {inline;}


const
  TVM_GETVISIBLECOUNT     = TV_FIRST + 16;

function TreeView_GetVisibleCount(hwnd: HWND): UINT; {inline;}

const
  TVM_HITTEST             = TV_FIRST + 17;

type
  PTVHitTestInfo = ^TTVHitTestInfo;
  tagTVHITTESTINFO = packed record
    pt: TPoint;
    flags: UINT;
    hItem: HTreeItem;
  end;
  _TV_HITTESTINFO = tagTVHITTESTINFO;
  TTVHitTestInfo = tagTVHITTESTINFO;
  TV_HITTESTINFO = tagTVHITTESTINFO;

function TreeView_HitTest(hwnd: HWND; var lpht: TTVHitTestInfo): HTreeItem; {inline;}

const
  TVHT_NOWHERE            = $0001;
  TVHT_ONITEMICON         = $0002;
  TVHT_ONITEMLABEL        = $0004;
  TVHT_ONITEMINDENT       = $0008;
  TVHT_ONITEMBUTTON       = $0010;
  TVHT_ONITEMRIGHT        = $0020;
  TVHT_ONITEMSTATEICON    = $0040;

  TVHT_ONITEM             = TVHT_ONITEMICON or TVHT_ONITEMLABEL or
			      TVHT_ONITEMSTATEICON;

  TVHT_ABOVE              = $0100;
  TVHT_BELOW              = $0200;
  TVHT_TORIGHT            = $0400;
  TVHT_TOLEFT             = $0800;

const
  TVM_CREATEDRAGIMAGE     = TV_FIRST + 18;

function TreeView_CreateDragImage(hwnd: HWND; hitem: HTreeItem): HIMAGELIST; {inline;}

const
  TVM_SORTCHILDREN        = TV_FIRST + 19;

function TreeView_SortChildren(hwnd: HWND; hitem: HTreeItem;
  recurse: Integer): Bool; {inline;}

const
  TVM_ENSUREVISIBLE       = TV_FIRST + 20;

function TreeView_EnsureVisible(hwnd: HWND; hitem: HTreeItem): Bool; {inline;}

const
  TVM_SORTCHILDRENCB      = TV_FIRST + 21;

type
  PFNTVCOMPARE = function(lParam1, lParam2, lParamSort: Longint): Integer stdcall;
  TTVCompare = PFNTVCOMPARE;

type
  tagTVSORTCB = packed record
    hParent: HTreeItem;
    lpfnCompare: TTVCompare;
    lParam: LPARAM;
  end;
  _TV_SORTCB = tagTVSORTCB;
  TTVSortCB = tagTVSORTCB;
  TV_SORTCB = tagTVSORTCB;

function TreeView_SortChildrenCB(hwnd: HWND; const psort: TTVSortCB;
  recurse: Integer): Bool; {inline;}

const
  TVM_ENDEDITLABELNOW     = TV_FIRST + 22;

function TreeView_EndEditLabelNow(hwnd: HWND; fCancel: Bool): Bool; {inline;}

const
  TVM_GETISEARCHSTRINGA    = TV_FIRST + 23;
  TVM_GETISEARCHSTRINGW    = TV_FIRST + 64;
{$IFDEF UNICODE}
  TVM_GETISEARCHSTRING    = TVM_GETISEARCHSTRINGW;
{$ELSE}
  TVM_GETISEARCHSTRING    = TVM_GETISEARCHSTRINGA;
{$ENDIF}

function TreeView_GetISearchString(hwndTV: HWND; lpsz: PWideChar): Bool; {inline;}
function TreeView_GetISearchStringA(hwndTV: HWND; lpsz: PAnsiChar): Bool; {inline;}
function TreeView_GetISearchStringW(hwndTV: HWND; lpsz: PWideChar): Bool; {inline;}

const
  TVM_SETTOOLTIPS         = TV_FIRST + 24;

function TreeView_SetToolTips(wnd: HWND; hwndTT: HWND): HWND; {inline;}

const
  TVM_GETTOOLTIPS         = TV_FIRST + 25;

function TreeView_GetToolTips(wnd: HWND): HWND; {inline;}

const
  TVM_SETINSERTMARK       = TV_FIRST + 26;

function TreeView_SetInsertMark(hwnd: HWND; hItem: Integer; fAfter: BOOL): BOOL; {inline;}

const
  TVM_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;

function TreeView_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL; {inline;}

const
  TVM_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

function TreeView_GetUnicodeFormat(hwnd: HWND): BOOL; {inline;}

const
  TVM_SETITEMHEIGHT         = TV_FIRST + 27;

function TreeView_SetItemHeight(hwnd: HWND; iHeight: Integer): Integer; {inline;}

const
  TVM_GETITEMHEIGHT         = TV_FIRST + 28;

function TreeView_GetItemHeight(hwnd: HWND): Integer; {inline;}

const
  TVM_SETBKCOLOR              = TV_FIRST + 29;

function TreeView_SetBkColor(hwnd: HWND; clr: COLORREF): COLORREF; {inline;}

const
  TVM_SETTEXTCOLOR              = TV_FIRST + 30;

function TreeView_SetTextColor(hwnd: HWND; clr: COLORREF): COLORREF; {inline;}

const
  TVM_GETBKCOLOR              = TV_FIRST + 31;

function TreeView_GetBkColor(hwnd: HWND): COLORREF; {inline;}

const
  TVM_GETTEXTCOLOR              = TV_FIRST + 32;

function TreeView_GetTextColor(hwnd: HWND): COLORREF; {inline;}

const
  TVM_SETSCROLLTIME              = TV_FIRST + 33;

function TreeView_SetScrollTime(hwnd: HWND; uTime: UINT): UINT; {inline;}

const
  TVM_GETSCROLLTIME              = TV_FIRST + 34;

function TreeView_GetScrollTime(hwnd: HWND): UINT; {inline;}

const
  TVM_SETINSERTMARKCOLOR         = TV_FIRST + 37;

function TreeView_SetInsertMarkColor(hwnd: HWND; clr: COLORREF): COLORREF; {inline;}

const
  TVM_GETINSERTMARKCOLOR         = TV_FIRST + 38;

function TreeView_GetInsertMarkColor(hwnd: HWND): COLORREF; {inline;}

{ For IE >= 0x0500 }
// tvm_?etitemstate only uses mask, state and stateMask.
// so unicode or ansi is irrelevant.
function TreeView_SetItemState(hwndTV: HWND; hti: HTreeItem; State, Mask: UINT): UINT;
function TreeView_SetCheckState(hwndTV: HWND; hti: HTreeItem; fCheck: BOOL): UINT; {inline;}

const
  { For IE >= 0x0500 }
  TVM_GETITEMSTATE        = TV_FIRST + 39;

{ For IE >= 0x0500 }
function TreeView_GetItemState(hwndTV: HWND; hti: HTreeItem; mask: UINT): UINT; {inline;}
function TreeView_GetCheckState(hwndTV: HWND; hti: HTreeItem): UINT; {inline;}

const
  { For IE >= 0x0500 }
  TVM_SETLINECOLOR            = TV_FIRST + 40;
  TVM_GETLINECOLOR            = TV_FIRST + 41;

  { For Windows >= XP }
  TVM_MAPACCIDTOHTREEITEM     = TV_FIRST + 42;
  TVM_MAPHTREEITEMTOACCID     = TV_FIRST + 43;
  TVM_SETEXTENDEDSTYLE        = TV_FIRST + 44;
  TVM_GETEXTENDEDSTYLE        = TV_FIRST + 45;
  TVM_SETAUTOSCROLLINFO       = TV_FIRST + 59;

  { For Windows >= Vista }
  TVM_GETSELECTEDCOUNT        = TV_FIRST + 70;
  TVM_SHOWINFOTIP             = TV_FIRST + 71;

{ For IE >= 0x0500 }
function TreeView_SetLineColor(hwnd: HWND; clr: TColorRef): TColorRef; {inline;}
function TreeView_GetLineColor(hwnd: HWND): Integer; {inline;}

{ For Windows >= XP }
function TreeView_MapAccIDToHTREEITEM(hwnd: HWND; id: UINT): HTreeItem; {inline;}
function TreeView_MapHTREEITEMToAccID(hwnd: HWND; hti: HTreeItem): UINT; {inline;}
function TreeView_SetExtendedStyle(hwnd: HWND; dw: DWORD; mask: UINT): UINT; {inline;}
function TreeView_GetExtendedStyle(hwnd: HWND): DWORD; {inline;}
function TreeView_SetAutoScrollInfo(hwnd: HWND; uPixPerSec, uUpdateTime: UINT): LRESULT; {inline;}

{ For Windows >= Vista }
function TreeView_GetSelectedCount(hwnd: HWND): DWORD; {inline;}
function TreeView_ShowInfoTip(hwnd: HWND; hti: HTreeItem): DWORD; {inline;}

type
  { For Windows >= Vista }
  TVITEMPART = (TVGIPR_DUMMY, TVGIPR_BUTTON);
  TTVItemPart = TVITEMPART;

type
  { For Windows >= Vista }
  tagTVGETITEMPARTRECTINFO = packed record
    hti: HTREEITEM;
    prc: PRect;
    partID: TVITEMPART;
  end;
  PTVGetItemPartRectInfo = ^TTVGetItemPartRectInfo;
  TTVGetItemPartRectInfo = tagTVGETITEMPARTRECTINFO;

const
  { For Windows >= Vista }
  TVM_GETITEMPARTRECT         = TV_FIRST + 72;

function TreeView_GetItemPartRect(hwnd: HWND; hitem: HTreeItem; var prc: TRect;
  partid: TTVItemPart): BOOL;

type
  PNMTreeViewA = ^TNMTreeViewA;
  PNMTreeViewW = ^TNMTreeViewW;
  PNMTreeView = PNMTreeViewW;
  tagNMTREEVIEWA = record
    hdr: TNMHDR;
    action: UINT;
    itemOld: TTVItemA;
    itemNew: TTVItemA;
    ptDrag: TPoint;
  end;
  tagNMTREEVIEWW = record
    hdr: TNMHDR;
    action: UINT;
    itemOld: TTVItemW;
    itemNew: TTVItemW;
    ptDrag: TPoint;
  end;
  tagNMTREEVIEW = tagNMTREEVIEWW;
  _NM_TREEVIEWA = tagNMTREEVIEWA;
  _NM_TREEVIEWW = tagNMTREEVIEWW;
  _NM_TREEVIEW = _NM_TREEVIEWW;
  TNMTreeViewA  = tagNMTREEVIEWA;
  TNMTreeViewW  = tagNMTREEVIEWW;
  TNMTreeView = TNMTreeViewW;
  NM_TREEVIEWA  = tagNMTREEVIEWA;
  NM_TREEVIEWW  = tagNMTREEVIEWW;
  NM_TREEVIEW = NM_TREEVIEWW;

const
  TVN_SELCHANGINGA         = TVN_FIRST-1;
  TVN_SELCHANGEDA          = TVN_FIRST-2;
  TVN_SELCHANGINGW         = TVN_FIRST-50;
  TVN_SELCHANGEDW          = TVN_FIRST-51;
{$IFDEF UNICODE}
  TVN_SELCHANGING         = TVN_SELCHANGINGW;
  TVN_SELCHANGED          = TVN_SELCHANGEDW;
{$ELSE}
  TVN_SELCHANGING         = TVN_SELCHANGINGA;
  TVN_SELCHANGED          = TVN_SELCHANGEDA;
{$ENDIF}

const
  TVC_UNKNOWN             = $0000;
  TVC_BYMOUSE             = $0001;
  TVC_BYKEYBOARD          = $0002;

const
  TVN_GETDISPINFOA         = TVN_FIRST-3;
  TVN_SETDISPINFOA         = TVN_FIRST-4;
  TVN_GETDISPINFOW         = TVN_FIRST-52;
  TVN_SETDISPINFOW         = TVN_FIRST-53;
{$IFDEF UNICODE}
  TVN_GETDISPINFO         = TVN_GETDISPINFOW;
  TVN_SETDISPINFO         = TVN_SETDISPINFOW;
{$ELSE}
  TVN_GETDISPINFO         = TVN_GETDISPINFOA;
  TVN_SETDISPINFO         = TVN_SETDISPINFOA;
{$ENDIF}

  TVIF_DI_SETITEM         = $1000;

type
  PTVDispInfoA = ^TTVDispInfoA;
  PTVDispInfoW = ^TTVDispInfoW;
  PTVDispInfo = PTVDispInfoW;
  tagTVDISPINFOA = record
    hdr: TNMHDR;
    item: TTVItemA;
  end;
  tagTVDISPINFOW = record
    hdr: TNMHDR;
    item: TTVItemW;
  end;
  tagTVDISPINFO = tagTVDISPINFOW;
  _TV_DISPINFOA = tagTVDISPINFOA;
  _TV_DISPINFOW = tagTVDISPINFOW;
  _TV_DISPINFO = _TV_DISPINFOW;
  TTVDispInfoA = tagTVDISPINFOA;
  TTVDispInfoW = tagTVDISPINFOW;
  TTVDispInfo = TTVDispInfoW;
  TV_DISPINFOA = tagTVDISPINFOA;
  TV_DISPINFOW = tagTVDISPINFOW;
  TV_DISPINFO = TV_DISPINFOW;

type
  { For IE >= 0x0600 }
  PNMTVDispInfoExA = ^TNMTVDispInfoExA;
  PNMTVDispInfoExW = ^TNMTVDispInfoExW;
  PNMTVDispInfoEx = PNMTVDispInfoExW;
  { $EXTERNALSYM tagNMTVDISPINFOEXA}
  tagNMTVDISPINFOEXA = record
    hdr: NMHDR;
    item: TTVItemExA;
  end;
  { $EXTERNALSYM tagNMTVDISPINFOEXW}
  tagNMTVDISPINFOEXW = record
    hdr: NMHDR;
    item: TTVItemExW;
  end;
  tagNMTVDISPINFOEX = tagNMTVDISPINFOEXW;
  TV_DISPINFOEXA = tagNMTVDISPINFOEXA;
  TV_DISPINFOEXW = tagNMTVDISPINFOEXW;
  TV_DISPINFOEX = TV_DISPINFOEXW;
  TNMTVDispInfoExA = tagNMTVDISPINFOEXA;
  TNMTVDispInfoExW = tagNMTVDISPINFOEXW;
  TNMTVDispInfoEx = TNMTVDispInfoExW;

const
  TVN_ITEMEXPANDINGA       = TVN_FIRST-5;
  TVN_ITEMEXPANDEDA        = TVN_FIRST-6;
  TVN_BEGINDRAGA           = TVN_FIRST-7;
  TVN_BEGINRDRAGA          = TVN_FIRST-8;
  TVN_DELETEITEMA          = TVN_FIRST-9;
  TVN_BEGINLABELEDITA      = TVN_FIRST-10;
  TVN_ENDLABELEDITA        = TVN_FIRST-11;
  TVN_GETINFOTIPA          = TVN_FIRST-13;
  TVN_ITEMEXPANDINGW       = TVN_FIRST-54;
  TVN_ITEMEXPANDEDW        = TVN_FIRST-55;
  TVN_BEGINDRAGW           = TVN_FIRST-56;
  TVN_BEGINRDRAGW          = TVN_FIRST-57;
  TVN_DELETEITEMW          = TVN_FIRST-58;
  TVN_BEGINLABELEDITW      = TVN_FIRST-59;
  TVN_ENDLABELEDITW        = TVN_FIRST-60;
  TVN_GETINFOTIPW          = TVN_FIRST-14;
{$IFDEF UNICODE}
  TVN_ITEMEXPANDING       = TVN_ITEMEXPANDINGW;
  TVN_ITEMEXPANDED        = TVN_ITEMEXPANDEDW;
  TVN_BEGINDRAG           = TVN_BEGINDRAGW;
  TVN_BEGINRDRAG          = TVN_BEGINRDRAGW;
  TVN_DELETEITEM          = TVN_DELETEITEMW;
  TVN_BEGINLABELEDIT      = TVN_BEGINLABELEDITW;
  TVN_ENDLABELEDIT        = TVN_ENDLABELEDITW;
  TVN_GETINFOTIP         = TVN_GETINFOTIPW;
{$ELSE}
  TVN_ITEMEXPANDING       = TVN_ITEMEXPANDINGA;
  TVN_ITEMEXPANDED        = TVN_ITEMEXPANDEDA;
  TVN_BEGINDRAG           = TVN_BEGINDRAGA;
  TVN_BEGINRDRAG          = TVN_BEGINRDRAGA;
  TVN_DELETEITEM          = TVN_DELETEITEMA;
  TVN_BEGINLABELEDIT      = TVN_BEGINLABELEDITA;
  TVN_ENDLABELEDIT        = TVN_ENDLABELEDITA;
  TVN_GETINFOTIP         = TVN_GETINFOTIPA;
{$ENDIF}

const
  TVN_KEYDOWN             = TVN_FIRST-12;
  TVN_SINGLEEXPAND        = TVN_FIRST-15;

  TVNRET_DEFAULT          = 0;
  TVNRET_SKIPOLD          = 1;
  TVNRET_SKIPNEW          = 2;

  { For IE >= 0x0600 }
  TVN_ITEMCHANGINGA       = TVN_FIRST-16;
  TVN_ITEMCHANGINGW       = TVN_FIRST-17;
  TVN_ITEMCHANGEDA        = TVN_FIRST-18;
  TVN_ITEMCHANGEDW        = TVN_FIRST-19;
  TVN_ASYNCDRAW           = TVN_FIRST-20;

{$IFDEF UNICODE}
  TVN_ITEMCHANGING        = TVN_ITEMCHANGINGW;
  TVN_ITEMCHANGED         = TVN_ITEMCHANGEDW;
{$ELSE}
  TVN_ITEMCHANGING        = TVN_ITEMCHANGINGA;
  TVN_ITEMCHANGED         = TVN_ITEMCHANGEDA;
{$ENDIF}

type
  tagTVKEYDOWN = packed record
    hdr: TNMHDR;
    wVKey: Word;
    flags: UINT;
  end;
  _TV_KEYDOWN = tagTVKEYDOWN;
  TTVKeyDown = tagTVKEYDOWN;
  TV_KEYDOWN = tagTVKEYDOWN;

  tagNMTVCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    clrText: COLORREF;
    clrTextBk: COLORREF;
    iLevel: Integer;
  end;
  PNMTVCustomDraw = ^TNMTVCustomDraw;
  TNMTVCustomDraw = tagNMTVCUSTOMDRAW;

  // for tooltips
  tagNMTVGETINFOTIPA = record
    hdr: TNMHdr;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    hItem: HTREEITEM;
    lParam: LPARAM;
  end;
  tagNMTVGETINFOTIPW = record
    hdr: TNMHdr;
    pszText: PWideChar;
    cchTextMax: Integer;
    hItem: HTREEITEM;
    lParam: LPARAM;
  end;
  tagNMTVGETINFOTIP = tagNMTVGETINFOTIPW;
  PNMTVGetInfoTipA = ^TNMTVGetInfoTipA;
  PNMTVGetInfoTipW = ^TNMTVGetInfoTipW;
  PNMTVGetInfoTip = PNMTVGetInfoTipW;
  TNMTVGetInfoTipA = tagNMTVGETINFOTIPA;
  TNMTVGetInfoTipW = tagNMTVGETINFOTIPW;
  TNMTVGetInfoTip = TNMTVGetInfoTipW;

const
  // treeview's customdraw return meaning don't draw images.  valid on CDRF_NOTIFYITEMPREPAINT
  TVCDRF_NOIMAGES         = $00010000;

type
  { For IE >= 0x0600 }
  { $EXTERNALSYM tagNMTVITEMCHANGE}
  tagNMTVITEMCHANGE = packed record
    hdr: NMHDR;
    uChanged: UINT;
    hItem: HTREEITEM;
    uStateNew: UINT;
    uStateOld: UINT;
    lParam: LPARAM;
  end;
  PNMTVItemChange = ^TNMTVItemChange;
  TNMTVItemChange = tagNMTVITEMCHANGE;


{ ====== ComboBoxEx ======================== }

const
  WC_COMBOBOXEX = 'ComboBoxEx32';

  CBEIF_TEXT              = $00000001;
  CBEIF_IMAGE             = $00000002;
  CBEIF_SELECTEDIMAGE     = $00000004;
  CBEIF_OVERLAY           = $00000008;
  CBEIF_INDENT            = $00000010;
  CBEIF_LPARAM            = $00000020;

  CBEIF_DI_SETITEM        = $10000000;

type
  tagCOMBOBOXEXITEMA = record
    mask: UINT;
    iItem: Integer;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    iOverlay: Integer;
    iIndent: Integer;
    lParam: LPARAM;
  end;
  tagCOMBOBOXEXITEMW = record
    mask: UINT;
    iItem: Integer;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    iSelectedImage: Integer;
    iOverlay: Integer;
    iIndent: Integer;
    lParam: LPARAM;
  end;
  tagCOMBOBOXEXITEM = tagCOMBOBOXEXITEMW;
  PComboBoxExItemA = ^TComboBoxExItemA;
  PComboBoxExItemW = ^TComboBoxExItemW;
  PComboBoxExItem = PComboBoxExItemW;
  TComboBoxExItemA = tagCOMBOBOXEXITEMA;
  TComboBoxExItemW = tagCOMBOBOXEXITEMW;
  TComboBoxExItem = TComboBoxExItemW;

const
  CBEM_INSERTITEMA        = WM_USER + 1;
  CBEM_SETIMAGELIST       = WM_USER + 2;
  CBEM_GETIMAGELIST       = WM_USER + 3;
  CBEM_GETITEMA           = WM_USER + 4;
  CBEM_SETITEMA           = WM_USER + 5;
  CBEM_DELETEITEM         = CB_DELETESTRING;
  CBEM_GETCOMBOCONTROL    = WM_USER + 6;
  CBEM_GETEDITCONTROL     = WM_USER + 7;
  CBEM_SETEXSTYLE         = WM_USER + 8;  // use SETEXTENDEDSTYLE instead
  CBEM_GETEXSTYLE         = WM_USER + 9;  // use GETEXTENDEDSTYLE instead
  CBEM_GETEXTENDEDSTYLE   = WM_USER + 9;
  CBEM_HASEDITCHANGED     = WM_USER + 10;
  CBEM_INSERTITEMW        = WM_USER + 11;
  CBEM_SETITEMW           = WM_USER + 12;
  CBEM_GETITEMW           = WM_USER + 13;
  CBEM_SETEXTENDEDSTYLE   = WM_USER + 14; // lparam == new style, wParam (optional) == mask
  CBEM_SETUNICODEFORMAT   = CCM_SETUNICODEFORMAT;
  CBEM_GETUNICODEFORMAT   = CCM_GETUNICODEFORMAT;
  { For Windows >= XP }
  CBEM_SETWINDOWTHEME     = CCM_SETWINDOWTHEME;

{$IFDEF UNICODE}
  CBEM_INSERTITEM         = CBEM_INSERTITEMW;
  CBEM_SETITEM            = CBEM_SETITEMW;
  CBEM_GETITEM            = CBEM_GETITEMW;
{$ELSE}
  CBEM_INSERTITEM         = CBEM_INSERTITEMA;
  CBEM_SETITEM            = CBEM_SETITEMA;
  CBEM_GETITEM            = CBEM_GETITEMA;
{$ENDIF}

  CBES_EX_NOEDITIMAGE          = $00000001;
  CBES_EX_NOEDITIMAGEINDENT    = $00000002;
  CBES_EX_PATHWORDBREAKPROC    = $00000004;
  CBES_EX_NOSIZELIMIT          = $00000008;
  CBES_EX_CASESENSITIVE        = $00000010;
  { For Windows >= Vista }
  CBES_EX_TEXTENDELLIPSIS      = $00000020;

type
  NMCOMBOBOXEXA = record
    hdr: TNMHdr;
    ceItem: TComboBoxExItemA;
  end;
  NMCOMBOBOXEXW = record
    hdr: TNMHdr;
    ceItem: TComboBoxExItemW;
  end;
  NMCOMBOBOXEX = NMCOMBOBOXEXW;
  PNMComboBoxExA = ^TNMComboBoxExA;
  PNMComboBoxExW = ^TNMComboBoxExW;
  PNMComboBoxEx = PNMComboBoxExW;
  TNMComboBoxExA = NMCOMBOBOXEXA;
  TNMComboBoxExW = NMCOMBOBOXEXW;
  TNMComboBoxEx = TNMComboBoxExW;

const
  CBEN_GETDISPINFOA       = CBEN_FIRST - 0;
  CBEN_INSERTITEM         = CBEN_FIRST - 1;
  CBEN_DELETEITEM         = CBEN_FIRST - 2;
  CBEN_BEGINEDIT          = CBEN_FIRST - 4;
  CBEN_ENDEDITA           = CBEN_FIRST - 5; // lParam specifies why the endedit is happening
  CBEN_ENDEDITW           = CBEN_FIRST - 6;
  CBEN_GETDISPINFOW       = CBEN_FIRST - 7;
  CBEN_DRAGBEGINA			    = CBEN_FIRST - 8;
  CBEN_DRAGBEGINW			    = CBEN_FIRST - 9;

{$IFDEF UNICODE}
  CBEN_ENDEDIT            = CBEN_ENDEDITW;
  CBEN_GETDISPINFO        = CBEN_GETDISPINFOW;
  CBEN_DRAGBEGIN          = CBEN_DRAGBEGINW;
{$ELSE}
  CBEN_ENDEDIT            = CBEN_ENDEDITA;
  CBEN_GETDISPINFO        = CBEN_GETDISPINFOA;
  CBEN_DRAGBEGIN          = CBEN_DRAGBEGINA;
{$ENDIF}

  CBENF_KILLFOCUS         = 1;
  CBENF_RETURN            = 2;
  CBENF_ESCAPE            = 3;
  CBENF_DROPDOWN          = 4;

  CBEMAXSTRLEN = 260;

type
  // CBEN_DRAGBEGIN sends this information ...
  NMCBEDRAGBEGINA = record
    hdr: TNMHdr;
    iItemid: Integer;
    szText: array[0..CBEMAXSTRLEN - 1] of AnsiChar;
  end;
  NMCBEDRAGBEGINW = record
    hdr: TNMHdr;
    iItemid: Integer;
    szText: array[0..CBEMAXSTRLEN - 1] of WideChar;
  end;
  NMCBEDRAGBEGIN = NMCBEDRAGBEGINW;
  PNMCBEDragBeginA = ^TNMCBEDragBeginA;
  PNMCBEDragBeginW = ^TNMCBEDragBeginW;
  PNMCBEDragBegin = PNMCBEDragBeginW;
  TNMCBEDragBeginA = NMCBEDRAGBEGINA;
  TNMCBEDragBeginW = NMCBEDRAGBEGINW;
  TNMCBEDragBegin = TNMCBEDragBeginW;

  // CBEN_ENDEDIT sends this information...
  // fChanged if the user actually did anything
  // iNewSelection gives what would be the new selection unless the notify is failed
  //                      iNewSelection may be CB_ERR if there's no match
  NMCBEENDEDITA = record
    hdr: TNMHdr;
    fChanged: BOOL;
    iNewSelection: Integer;
    szText: array[0..CBEMAXSTRLEN - 1] of AnsiChar;
    iWhy: Integer;
  end;
  NMCBEENDEDITW = record
    hdr: TNMHdr;
    fChanged: BOOL;
    iNewSelection: Integer;
    szText: array[0..CBEMAXSTRLEN - 1] of WideChar;
    iWhy: Integer;
  end;
  NMCBEENDEDIT = NMCBEENDEDITW;
  PNMCBEEndEditA = ^TNMCBEEndEditA;
  PNMCBEEndEditW = ^TNMCBEEndEditW;
  PNMCBEEndEdit = PNMCBEEndEditW;
  TNMCBEEndEditA = NMCBEENDEDITA;
  TNMCBEEndEditW = NMCBEENDEDITW;
  TNMCBEEndEdit = TNMCBEEndEditW;

{ ====== TAB CONTROL ======================== }

const
  WC_TABCONTROL = 'SysTabControl32';

const
  TCS_SCROLLOPPOSITE    = $0001;  // assumes multiline tab
  TCS_BOTTOM            = $0002;
  TCS_RIGHT             = $0002;
  TCS_MULTISELECT       = $0004;  // allow multi-select in button mode
  TCS_FLATBUTTONS       = $0008;
  TCS_FORCEICONLEFT     = $0010;
  TCS_FORCELABELLEFT    = $0020;
  TCS_HOTTRACK          = $0040;
  TCS_VERTICAL          = $0080;
  TCS_TABS              = $0000;
  TCS_BUTTONS           = $0100;
  TCS_SINGLELINE        = $0000;
  TCS_MULTILINE         = $0200;
  TCS_RIGHTJUSTIFY      = $0000;
  TCS_FIXEDWIDTH        = $0400;
  TCS_RAGGEDRIGHT       = $0800;
  TCS_FOCUSONBUTTONDOWN = $1000;
  TCS_OWNERDRAWFIXED    = $2000;
  TCS_TOOLTIPS          = $4000;
  TCS_FOCUSNEVER        = $8000;

  TCS_EX_FLATSEPARATORS = $00000001;
  TCS_EX_REGISTERDROP   = $00000002;

  TCM_GETIMAGELIST       = TCM_FIRST + 2;
  TCM_SETIMAGELIST       = TCM_FIRST + 3;
  TCM_GETITEMCOUNT       = TCM_FIRST + 4;
  TCM_DELETEITEM         = TCM_FIRST + 8;
  TCM_DELETEALLITEMS     = TCM_FIRST + 9;
  TCM_GETITEMRECT        = TCM_FIRST + 10;
  TCM_GETCURSEL          = TCM_FIRST + 11;
  TCM_SETCURSEL          = TCM_FIRST + 12;
  TCM_HITTEST            = TCM_FIRST + 13;
  TCM_SETITEMEXTRA       = TCM_FIRST + 14;
  TCM_ADJUSTRECT         = TCM_FIRST + 40;
  TCM_SETITEMSIZE        = TCM_FIRST + 41;
  TCM_REMOVEIMAGE        = TCM_FIRST + 42;
  TCM_SETPADDING         = TCM_FIRST + 43;
  TCM_GETROWCOUNT        = TCM_FIRST + 44;
  TCM_GETTOOLTIPS        = TCM_FIRST + 45;
  TCM_SETTOOLTIPS        = TCM_FIRST + 46;
  TCM_GETCURFOCUS        = TCM_FIRST + 47;
  TCM_SETCURFOCUS        = TCM_FIRST + 48;
  TCM_SETMINTABWIDTH     = TCM_FIRST + 49;
  TCM_DESELECTALL        = TCM_FIRST + 50;
  TCM_HIGHLIGHTITEM      = TCM_FIRST + 51;
  TCM_SETEXTENDEDSTYLE   = TCM_FIRST + 52;  // optional wParam == mask
  TCM_GETEXTENDEDSTYLE   = TCM_FIRST + 53;
  TCM_SETUNICODEFORMAT   = CCM_SETUNICODEFORMAT;
  TCM_GETUNICODEFORMAT   = CCM_GETUNICODEFORMAT;

  TCIF_TEXT       = $0001;
  TCIF_IMAGE      = $0002;
  TCIF_RTLREADING = $0004;
  TCIF_PARAM      = $0008;
  TCIF_STATE      = $0010;

  TCIS_BUTTONPRESSED      = $0001;
  TCIS_HIGHLIGHTED        = $0002;

type
  PTCItemHeaderA = ^TTCItemHeaderA;
  PTCItemHeaderW = ^TTCItemHeaderW;
  PTCItemHeader = PTCItemHeaderW;
  tagTCITEMHEADERA = record
    mask: UINT;
    lpReserved1: UINT;
    lpReserved2: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
  end;
  tagTCITEMHEADERW = record
    mask: UINT;
    lpReserved1: UINT;
    lpReserved2: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
  end;
  tagTCITEMHEADER = tagTCITEMHEADERW;
  _TC_ITEMHEADERA = tagTCITEMHEADERA;
  _TC_ITEMHEADERW = tagTCITEMHEADERW;
  _TC_ITEMHEADER = _TC_ITEMHEADERW;
  TTCItemHeaderA = tagTCITEMHEADERA;
  TTCItemHeaderW = tagTCITEMHEADERW;
  TTCItemHeader = TTCItemHeaderW;
  TC_ITEMHEADERA = tagTCITEMHEADERA;
  TC_ITEMHEADERW = tagTCITEMHEADERW;
  TC_ITEMHEADER = TC_ITEMHEADERW;

  PTCItemA = ^TTCItemA;
  PTCItemW = ^TTCItemW;
  PTCItem = PTCItemW;
  tagTCITEMA = record
    mask: UINT;
    dwState: UINT;
    dwStateMask: UINT;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  tagTCITEMW = record
    mask: UINT;
    dwState: UINT;
    dwStateMask: UINT;
    pszText: PWideChar;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
  end;
  tagTCITEM = tagTCITEMW;
  _TC_ITEMA = tagTCITEMA;
  _TC_ITEMW = tagTCITEMW;
  _TC_ITEM = _TC_ITEMW;
  TTCItemA = tagTCITEMA;
  TTCItemW = tagTCITEMW;
  TTCItem = TTCItemW;
  TC_ITEMA = tagTCITEMA;
  TC_ITEMW = tagTCITEMW;
  TC_ITEM = TC_ITEMW;

const
  TCM_GETITEMA             = TCM_FIRST + 5;
  TCM_SETITEMA             = TCM_FIRST + 6;
  TCM_INSERTITEMA          = TCM_FIRST + 7;
  TCM_GETITEMW             = TCM_FIRST + 60;
  TCM_SETITEMW             = TCM_FIRST + 61;
  TCM_INSERTITEMW          = TCM_FIRST + 62;
{$IFDEF UNICODE}
  TCM_GETITEM             = TCM_GETITEMW;
  TCM_SETITEM             = TCM_SETITEMW;
  TCM_INSERTITEM          = TCM_INSERTITEMW;
{$ELSE}
  TCM_GETITEM             = TCM_GETITEMA;
  TCM_SETITEM             = TCM_SETITEMA;
  TCM_INSERTITEM          = TCM_INSERTITEMA;
{$ENDIF}

const
  TCHT_NOWHERE     = $0001;
  TCHT_ONITEMICON  = $0002;
  TCHT_ONITEMLABEL = $0004;
  TCHT_ONITEM      = TCHT_ONITEMICON or TCHT_ONITEMLABEL;

type
  PTCHitTestInfo = ^TTCHitTestInfo;
  tagTCHITTESTINFO = packed record
    pt: TPoint;
    flags: UINT;
  end;
  _TC_HITTESTINFO = tagTCHITTESTINFO;
  TTCHitTestInfo = tagTCHITTESTINFO;
  TC_HITTESTINFO = tagTCHITTESTINFO;

  tagTCKEYDOWN = packed record
    hdr: TNMHDR;
    wVKey: Word;
    flags: UINT;
  end;
  _TC_KEYDOWN = tagTCKEYDOWN;
  TTCKeyDown = tagTCKEYDOWN;
  TC_KEYDOWN = tagTCKEYDOWN;

const
  TCN_KEYDOWN             = TCN_FIRST - 0;
  TCN_SELCHANGE           = TCN_FIRST - 1;
  TCN_SELCHANGING         = TCN_FIRST - 2;
  TCN_GETOBJECT           = TCN_FIRST - 3;

function TabCtrl_HitTest(hwndTC: HWND; pinfo: PTCHitTestInfo): Integer; overload; {inline;}
function TabCtrl_HitTest(hwndTC: HWND; const pinfo: TTCHitTestInfo): Integer; overload; {inline;}
function TabCtrl_SetItemExtra(hwndTC: HWND; cb: Integer): BOOL; {inline;}
function TabCtrl_AdjustRect(hwnd: HWND; bLarger: BOOL; prc: PRect): Integer; {inline;}
function TabCtrl_SetItemSize(hwnd: HWND; x, y: Integer): DWORD;
procedure TabCtrl_RemoveImage(hwnd: HWND; i: Integer);
procedure TabCtrl_SetPadding(hwnd: HWND; cx, cy: Integer);
function TabCtrl_GetRowCount(hwnd: HWND): Integer; {inline;}
function TabCtrl_GetToolTips(wnd: HWND): HWND; {inline;}
procedure TabCtrl_SetToolTips(hwnd: HWND; hwndTT: HWND);
function TabCtrl_GetCurFocus(hwnd: HWND): Integer; {inline;}
procedure TabCtrl_SetCurFocus(hwnd: HWND; i: Integer);
function TabCtrl_SetMinTabWidth(hwnd: HWND; x: Integer): Integer; {inline;}
procedure TabCtrl_DeselectAll(hwnd: HWND; fExcludeFocus: BOOL);
function TabCtrl_HighlightItem(hwnd: HWND; i: Integer; fHighlight: WordBool): BOOL;
function TabCtrl_SetExtendedStyle(hwnd: HWND; dw: DWORD): DWORD; {inline;}
function TabCtrl_GetExtendedStyle(hwnd: HWND): DWORD; {inline;}
function TabCtrl_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL; {inline;}
function TabCtrl_GetUnicodeFormat(hwnd: HWND): BOOL; {inline;}
function TabCtrl_GetItemRect(hwnd: HWND; i: Integer; var prc: TRect): BOOL; {inline;}

{ ====== ANIMATE CONTROL ================= }

const
  ANIMATE_CLASS = 'SysAnimate32';

const
  ACS_CENTER              = $0001;
  ACS_TRANSPARENT         = $0002;
  ACS_AUTOPLAY            = $0004;
  ACS_TIMER               = $0008;  { don't use threads... use timers }

  ACM_OPENA                = WM_USER + 100;
  ACM_OPENW                = WM_USER + 103;
{$IFDEF UNICODE}
  ACM_OPEN                = ACM_OPENW;
{$ELSE}
  ACM_OPEN                = ACM_OPENA;
{$ENDIF}

  ACM_PLAY                = WM_USER + 101;
  ACM_STOP                = WM_USER + 102;

  ACN_START               = 1;
  ACN_STOP                = 2;

function Animate_Create(hwndP: HWND; id: HMENU; dwStyle: DWORD; hInstance: HINST): HWND;
function Animate_Open(hwnd: HWND; szName: PChar): BOOL; {inline;}
function Animate_OpenEx(hwnd: HWND; hInst: HINST; szName: PChar): BOOL; {inline;}
function Animate_Play(hwnd: HWND; from, _to: Word; rep: UINT): BOOL;
function Animate_Stop(hwnd: HWND): BOOL; {inline;}
function Animate_Close(hwnd: HWND): BOOL; {inline;}
function Animate_Seek(hwnd: HWND; frame: Word): BOOL; {inline;}

{ ====== MONTHCAL CONTROL ========= }

const
  MONTHCAL_CLASS          = 'SysMonthCal32';

const  
  // Message constants
  MCM_FIRST             = $1000;
  MCM_GETCURSEL         = MCM_FIRST + 1;
  MCM_SETCURSEL         = MCM_FIRST + 2;
  MCM_GETMAXSELCOUNT    = MCM_FIRST + 3;
  MCM_SETMAXSELCOUNT    = MCM_FIRST + 4;
  MCM_GETSELRANGE       = MCM_FIRST + 5;
  MCM_SETSELRANGE       = MCM_FIRST + 6;
  MCM_GETMONTHRANGE     = MCM_FIRST + 7;
  MCM_SETDAYSTATE       = MCM_FIRST + 8;
  MCM_GETMINREQRECT     = MCM_FIRST + 9;
  MCM_SETCOLOR          = MCM_FIRST + 10;
  MCM_GETCOLOR          = MCM_FIRST + 11;
  MCM_SETTODAY          = MCM_FIRST + 12;
  MCM_GETTODAY          = MCM_FIRST + 13;
  MCM_HITTEST           = MCM_FIRST + 14;
  MCM_SETFIRSTDAYOFWEEK = MCM_FIRST + 15;
  MCM_GETFIRSTDAYOFWEEK = MCM_FIRST + 16;
  MCM_GETRANGE          = MCM_FIRST + 17;
  MCM_SETRANGE          = MCM_FIRST + 18;
  MCM_GETMONTHDELTA     = MCM_FIRST + 19;
  MCM_SETMONTHDELTA     = MCM_FIRST + 20;
  MCM_GETMAXTODAYWIDTH  = MCM_FIRST + 21;
  MCM_SETUNICODEFORMAT  = CCM_SETUNICODEFORMAT;
  MCM_GETUNICODEFORMAT  = CCM_GETUNICODEFORMAT;

  // Hit test flags
  MCHT_TITLE            = $00010000;
  MCHT_CALENDAR         = $00020000;
  MCHT_TODAYLINK        = $00030000;
  MCHT_NEXT             = $01000000;  // these indicate that hitting
  MCHT_PREV             = $02000000;  // here will go to the next/prev month
  MCHT_NOWHERE          = $00000000;
  MCHT_TITLEBK          = MCHT_TITLE;
  MCHT_TITLEMONTH       = MCHT_TITLE or $0001;
  MCHT_TITLEYEAR        = MCHT_TITLE or $0002;
  MCHT_TITLEBTNNEXT     = MCHT_TITLE or MCHT_NEXT or $0003;
  MCHT_TITLEBTNPREV     = MCHT_TITLE or MCHT_PREV or $0003;
  MCHT_CALENDARBK       = MCHT_CALENDAR;
  MCHT_CALENDARDATE     = MCHT_CALENDAR or $0001;
  MCHT_CALENDARDATENEXT = MCHT_CALENDARDATE or MCHT_NEXT;
  MCHT_CALENDARDATEPREV = MCHT_CALENDARDATE or MCHT_PREV;
  MCHT_CALENDARDAY      = MCHT_CALENDAR or $0002;
  MCHT_CALENDARWEEKNUM  = MCHT_CALENDAR or $0003;

  // Color codes
  MCSC_BACKGROUND       = 0;   // the background color (between months)
  MCSC_TEXT             = 1;   // the dates
  MCSC_TITLEBK          = 2;   // background of the title
  MCSC_TITLETEXT        = 3;
  MCSC_MONTHBK          = 4;   // background within the month cal
  MCSC_TRAILINGTEXT     = 5;   // the text color of header & trailing days

  // Notification codes
  MCN_SELCHANGE         = MCN_FIRST + 1;
  MCN_GETDAYSTATE       = MCN_FIRST + 3;
  MCN_SELECT            = MCN_FIRST + 4;

  // Style flags
  MCS_DAYSTATE          = $0001;
  MCS_MULTISELECT       = $0002;
  MCS_WEEKNUMBERS       = $0004;
  MCS_NOTODAY_PRE_IE4   = $0008;
  MCS_NOTODAYCIRCLE     = $0008;
  MCS_NOTODAY           = $0010;

  GMR_VISIBLE           = 0;       // visible portion of display
  GMR_DAYSTATE          = 1;       // above plus the grayed out parts of
                                   // partially displayed months
                                   
type
  // bit-packed array of "bold" info for a month
  // if a bit is on, that day is drawn bold
  MONTHDAYSTATE = DWORD;
  PMonthDayState = ^TMonthDayState;
  TMonthDayState = MONTHDAYSTATE;

  MCHITTESTINFO = packed record
    cbSize: UINT;
    pt: TPoint;
    uHit: UINT;      // out param
    st: TSystemTime;
  end;
  PMCHitTestInfo = ^TMCHitTestInfo;
  TMCHitTestInfo = MCHITTESTINFO;

  // MCN_SELCHANGE is sent whenever the currently displayed date changes
  // via month change, year change, keyboard navigation, prev/next button
  tagNMSELCHANGE = packed record
    nmhdr: TNmHdr;  // this must be first, so we don't break WM_NOTIFY
    stSelStart: TSystemTime;
    stSelEnd: TSystemTime;
  end;
  PNMSelChange = ^TNMSelChange;
  TNMSelChange = tagNMSELCHANGE;

  // MCN_GETDAYSTATE is sent for MCS_DAYSTATE controls whenever new daystate
  // information is needed (month or year scroll) to draw bolding information.
  // The app must fill in cDayState months worth of information starting from
  // stStart date. The app may fill in the array at prgDayState or change
  // prgDayState to point to a different array out of which the information
  // will be copied. (similar to tooltips)
  tagNMDAYSTATE = packed record
    nmhdr: TNmHdr;  // this must be first, so we don't break WM_NOTIFY
    stStart: TSystemTime;
    cDayState: Integer;
    prgDayState: PMonthDayState; // points to cDayState TMONTHDAYSTATEs
  end;
  PNMDayState = ^TNMDayState;
  TNMDayState = tagNMDAYSTATE;

  // MCN_SELECT is sent whenever a selection has occured (via mouse or keyboard)
  NMSELECT = tagNMSELCHANGE;
  PNMSelect = ^TNMSelect;
  TNMSelect = NMSELECT;

  TSystemTimeRangeArray = array[0..1] of TSystemTime;

//   returns FALSE if MCS_MULTISELECT
//   returns TRUE and sets *pst to the currently selected date otherwise
function MonthCal_GetCurSel(hmc: HWND; var pst: TSystemTime): BOOL; {inline;}

//   returns FALSE if MCS_MULTISELECT
//   returns TURE and sets the currently selected date to *pst otherwise
function MonthCal_SetCurSel(hmc: HWND; const pst: TSystemTime): BOOL; {inline;}

//   returns the maximum number of selectable days allowed
function MonthCal_GetMaxSelCount(hmc: HWND): DWORD; {inline;}

//   sets the max number days that can be selected iff MCS_MULTISELECT
function MonthCal_SetMaxSelCount(hmc: HWND; n: UINT): BOOL; {inline;}

//   sets rgst[0] to the first day of the selection range
//   sets rgst[1] to the last day of the selection range
function MonthCal_GetSelRange(hmc: HWND; rgst: PSystemTime): BOOL; {inline;}

//   selects the range of days from rgst[0] to rgst[1]
function MonthCal_SetSelRange(hmc: HWND; rgst: PSystemTime): BOOL; {inline;}

//   if rgst specified, sets rgst[0] to the starting date and
//      and rgst[1] to the ending date of the the selectable (non-grayed)
//      days if GMR_VISIBLE or all the displayed days (including grayed)
//      if GMR_DAYSTATE.
//   returns the number of months spanned by the above range.
function MonthCal_GetMonthRange(hmc: HWND; gmr: DWORD; rgst: PSystemTime): DWORD; {inline;}

//   cbds is the count of DAYSTATE items in rgds and it must be equal
//   to the value returned from MonthCal_GetMonthRange(hmc, GMR_DAYSTATE, NULL)
//   This sets the DAYSTATE bits for each month (grayed and non-grayed
//   days) displayed in the calendar. The first bit in a month's DAYSTATE
//   corresponts to bolding day 1, the second bit affects day 2, etc.
function MonthCal_SetDayState(hmc: HWND; cbds: Integer; const rgds: TNMDayState): BOOL; {inline;}

//   sets prc the minimal size needed to display one month
function MonthCal_GetMinReqRect(hmc: HWND; var prc: TRect): BOOL; {inline;}

// set what day is "today"   send NULL to revert back to real date
function MonthCal_SetToday(hmc: HWND; const pst: TSystemTime): BOOL; {inline;}

// get what day is "today"
// returns BOOL for success/failure
function MonthCal_GetToday(hmc: HWND; var pst: TSystemTime): BOOL; {inline;}

// determine what pinfo->pt is over
function MonthCal_HitTest(hmc: HWND; var info: TMCHitTestInfo): DWORD; {inline;}

// set colors to draw control with -- see MCSC_ bits below
function MonthCal_SetColor(hmc: HWND; iColor: Integer; clr: TColorRef): TColorRef; {inline;}

function MonthCal_GetColor(hmc: HWND; iColor: Integer): TColorRef; {inline;}

// set first day of week to iDay:
// 0 for Monday, 1 for Tuesday, ..., 6 for Sunday
// -1 for means use locale info
function MonthCal_SetFirstDayOfWeek(hmc: HWND; iDay: Integer): Integer; {inline;}

// DWORD result...  low word has the day.  high word is bool if this is app set
// or not (FALSE == using locale info)
function MonthCal_GetFirstDayOfWeek(hmc: HWND): Integer; {inline;}

//   modifies rgst[0] to be the minimum ALLOWABLE systemtime (or 0 if no minimum)
//   modifies rgst[1] to be the maximum ALLOWABLE systemtime (or 0 if no maximum)
//   returns GDTR_MIN|GDTR_MAX if there is a minimum|maximum limit
function MonthCal_GetRange(hmc: HWND; rgst: PSystemTime): DWORD; {inline;}

//   if GDTR_MIN, sets the minimum ALLOWABLE systemtime to rgst[0], otherwise removes minimum
//   if GDTR_MAX, sets the maximum ALLOWABLE systemtime to rgst[1], otherwise removes maximum
//   returns TRUE on success, FALSE on error (such as invalid parameters)
function Monthcal_SetRange(hmc: HWND; gdtr: DWORD; rgst: PSystemTime): BOOL; {inline;}

//   returns the number of months one click on a next/prev button moves by
function MonthCal_GetMonthDelta(hmc: HWND): Integer; {inline;}

//   sets the month delta to n. n = 0 reverts to moving by a page of months
//   returns the previous value of n.
function MonthCal_SetMonthDelta(hmc: HWND; n: Integer): Integer; {inline;}

//   sets *psz to the maximum width/height of the "Today" string displayed
//   at the bottom of the calendar (as long as MCS_NOTODAY is not specified)
function MonthCal_GetMaxTodayWidth(hmc: HWND): DWORD; {inline;}

function MonthCal_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL; {inline;}

function MonthCal_GetUnicodeFormat(hwnd: HWND): BOOL; {inline;}

{ ====== DATETIMEPICK CONTROL =============== }

const
  DATETIMEPICK_CLASS = 'SysDateTimePick32';

  // Message constants
  DTM_FIRST         = $1000;
  DTM_GETSYSTEMTIME = DTM_FIRST + 1;
  DTM_SETSYSTEMTIME = DTM_FIRST + 2;
  DTM_GETRANGE      = DTM_FIRST + 3;
  DTM_SETRANGE      = DTM_FIRST + 4;
  DTM_SETFORMATA    = DTM_FIRST + 5;
  DTM_SETMCCOLOR    = DTM_FIRST + 6;
  DTM_GETMCCOLOR    = DTM_FIRST + 7;
  DTM_GETMONTHCAL   = DTM_FIRST + 8;
  DTM_SETMCFONT     = DTM_FIRST + 9;
  DTM_GETMCFONT     = DTM_FIRST + 10;
  DTM_SETFORMATW    = DTM_FIRST + 50;
{$IFDEF UNICODE}
  DTM_SETFORMAT     = DTM_SETFORMATW;
{$ELSE}
  DTM_SETFORMAT     = DTM_SETFORMATA;
{$ENDIF}

  // Style Flags
  DTS_UPDOWN          = $0001;  // use UPDOWN instead of MONTHCAL
  DTS_SHOWNONE        = $0002;  // allow a NONE selection
  DTS_SHORTDATEFORMAT = $0000;  // use the short date format
                                // (app must forward WM_WININICHANGE messages)
  DTS_LONGDATEFORMAT  = $0004;  // use the long date format
                                // (app must forward WM_WININICHANGE messages)
  DTS_TIMEFORMAT      = $0009;  // use the time format
                                // (app must forward WM_WININICHANGE messages)
  DTS_APPCANPARSE     = $0010;  // allow user entered strings
                                // (app MUST respond to DTN_USERSTRING)
  DTS_RIGHTALIGN      = $0020;  // right-align popup instead of left-align it

  // Notification codes
  DTN_DATETIMECHANGE = DTN_FIRST + 1;  // the systemtime has changed
  DTN_USERSTRINGA    = DTN_FIRST + 2;  // the user has entered a string
  DTN_USERSTRINGW    = DTN_FIRST + 15;
  DTN_WMKEYDOWNA     = DTN_FIRST + 3;  // modify keydown on app format field (X)
  DTN_WMKEYDOWNW     = DTN_FIRST + 16;
  DTN_FORMATA        = DTN_FIRST + 4;  // query display for app format field (X)
  DTN_FORMATW        = DTN_FIRST + 17;
  DTN_FORMATQUERYA   = DTN_FIRST + 5;  // query formatting info for app format field (X)
  DTN_FORMATQUERYW   = DTN_FIRST + 18;
  DTN_DROPDOWN       = DTN_FIRST + 6;  // MonthCal has dropped down
  DTN_CLOSEUP        = DTN_FIRST + 7;  // MonthCal is popping up
{$IFDEF UNICODE}
  DTN_USERSTRING     = DTN_USERSTRINGW;
  DTN_WMKEYDOWN      = DTN_WMKEYDOWNW;
  DTN_FORMAT         = DTN_FORMATW;
  DTN_FORMATQUERY    = DTN_FORMATQUERYW;
{$ELSE}
  DTN_USERSTRING     = DTN_USERSTRINGA;
  DTN_WMKEYDOWN      = DTN_WMKEYDOWNA;
  DTN_FORMAT         = DTN_FORMATA;
  DTN_FORMATQUERY    = DTN_FORMATQUERYA;
{$ENDIF}

  // Ranges
  GDTR_MIN = $0001;
  GDTR_MAX = $0002;

  // Return Values
  GDT_ERROR = -1;
  GDT_VALID = 0;
  GDT_NONE  = 1;

type
  tagNMDATETIMECHANGE = packed record
    nmhdr: TNmHdr;
    dwFlags: DWORD;         // GDT_VALID or GDT_NONE
    st: TSystemTime;        // valid iff dwFlags = GDT_VALID
  end;
  PNMDateTimeChange = ^TNMDateTimeChange;
  TNMDateTimeChange = tagNMDATETIMECHANGE;

  tagNMDATETIMESTRINGA = record
    nmhdr: TNmHdr;
    pszUserString: PAnsiChar;     // AnsiString user entered
    st: TSystemTime;           // app fills this in
    dwFlags: DWORD;            // GDT_VALID or GDT_NONE
  end;
  tagNMDATETIMESTRINGW = record
    nmhdr: TNmHdr;
    pszUserString: PWideChar;     // UnicodeString user entered
    st: TSystemTime;           // app fills this in
    dwFlags: DWORD;            // GDT_VALID or GDT_NONE
  end;
  tagNMDATETIMESTRING = tagNMDATETIMESTRINGW;
  PNMDateTimeStringA = ^TNMDateTimeStringA;
  PNMDateTimeStringW = ^TNMDateTimeStringW;
  PNMDateTimeString = PNMDateTimeStringW;
  TNMDateTimeStringA = tagNMDATETIMESTRINGA;
  TNMDateTimeStringW = tagNMDATETIMESTRINGW;
  TNMDateTimeString = TNMDateTimeStringW;

  tagNMDATETIMEWMKEYDOWNA = record
    nmhdr: TNmHdr;
    nVirtKey: Integer; // virtual key code of WM_KEYDOWN which MODIFIES an X field
    pszFormat: PAnsiChar; // format substring
    st: TSystemTime;   // current systemtime, app should modify based on key
  end;
  tagNMDATETIMEWMKEYDOWNW = record
    nmhdr: TNmHdr;
    nVirtKey: Integer; // virtual key code of WM_KEYDOWN which MODIFIES an X field
    pszFormat: PWideChar; // format substring
    st: TSystemTime;   // current systemtime, app should modify based on key
  end;
  tagNMDATETIMEWMKEYDOWN = tagNMDATETIMEWMKEYDOWNW;
  PNMDateTimeWMKeyDownA = ^TNMDateTimeWMKeyDownA;
  PNMDateTimeWMKeyDownW = ^TNMDateTimeWMKeyDownW;
  PNMDateTimeWMKeyDown = PNMDateTimeWMKeyDownW;
  TNMDateTimeWMKeyDownA = tagNMDATETIMEWMKEYDOWNA;
  TNMDateTimeWMKeyDownW = tagNMDATETIMEWMKEYDOWNW;
  TNMDateTimeWMKeyDown = TNMDateTimeWMKeyDownW;

  tagNMDATETIMEFORMATA = record
    nmhdr: TNmHdr;
    pszFormat: PAnsiChar;                // format substring
    st: TSystemTime;                  // current systemtime
    pszDisplay: PAnsiChar;               // AnsiString to display
    szDisplay: array[0..63] of AnsiChar; // buffer pszDisplay originally points at
  end;
  tagNMDATETIMEFORMATW = record
    nmhdr: TNmHdr;
    pszFormat: PWideChar;                // format substring
    st: TSystemTime;                  // current systemtime
    pszDisplay: PWideChar;               // UnicodeString to display
    szDisplay: array[0..63] of WideChar; // buffer pszDisplay originally points at
  end;
  tagNMDATETIMEFORMAT = tagNMDATETIMEFORMATW;
  PNMDateTimeFormatA = ^TNMDateTimeFormatA;
  PNMDateTimeFormatW = ^TNMDateTimeFormatW;
  PNMDateTimeFormat = PNMDateTimeFormatW;
  TNMDateTimeFormatA = tagNMDATETIMEFORMATA;
  TNMDateTimeFormatW = tagNMDATETIMEFORMATW;
  TNMDateTimeFormat = TNMDateTimeFormatW;

  tagNMDATETIMEFORMATQUERYA = record
    nmhdr: TNmHdr;
    pszFormat: PAnsiChar; // format substring
    szMax: TSize;      // max bounding rectangle app will use for this format AnsiString
  end;
  tagNMDATETIMEFORMATQUERYW = record
    nmhdr: TNmHdr;
    pszFormat: PWideChar; // format substring
    szMax: TSize;      // max bounding rectangle app will use for this format UnicodeString
  end;
  tagNMDATETIMEFORMATQUERY = tagNMDATETIMEFORMATQUERYW;
  PNMDateTimeFormatQueryA = ^TNMDateTimeFormatQueryA;
  PNMDateTimeFormatQueryW = ^TNMDateTimeFormatQueryW;
  PNMDateTimeFormatQuery = PNMDateTimeFormatQueryW;
  TNMDateTimeFormatQueryA = tagNMDATETIMEFORMATQUERYA;
  TNMDateTimeFormatQueryW = tagNMDATETIMEFORMATQUERYW;
  TNMDateTimeFormatQuery = TNMDateTimeFormatQueryW;

//   returns GDT_NONE if "none" is selected (DTS_SHOWNONE only)
//   returns GDT_VALID and modifies pst to be the currently selected value
function DateTime_GetSystemTime(hdp: HWND; var pst: TSystemTime): DWORD; {inline;}

//   if gd = GDT_NONE, sets datetimepick to None (DTS_SHOWNONE only)
//   if gd = GDT_VALID, sets datetimepick to pst
//   returns TRUE on success, FALSE on error (such as bad params)
function DateTime_SetSystemTime(hdp: HWND; gd: DWORD; const pst: TSystemTime): BOOL; {inline;}

//   modifies rgst[0] to be the minimum ALLOWABLE systemtime (or 0 if no minimum)
//   modifies rgst[1] to be the maximum ALLOWABLE systemtime (or 0 if no maximum)
//   returns GDTR_MIN or GDTR_MAX if there is a minimum or maximum limit
function DateTime_GetRange(hdp: HWND; rgst: PSystemTime): DWORD; {inline;}

//   if GDTR_MIN, sets the minimum ALLOWABLE systemtime to rgst[0], otherwise removes minimum
//   if GDTR_MAX, sets the maximum ALLOWABLE systemtime to rgst[1], otherwise removes maximum
//   returns TRUE on success, FALSE on error (such as invalid parameters)
function DateTime_SetRange(hdp: HWND; gdtr: DWORD; rgst: PSystemTime): BOOL; {inline;}

//   sets the display formatting string to sz (see GetDateFormat and GetTimeFormat for valid formatting chars)
//   NOTE: 'X' is a valid formatting character which indicates that the application
//   will determine how to display information. Such apps must support DTN_WMKEYDOWN,
//   DTN_FORMAT, and DTN_FORMATQUERY.
function DateTime_SetFormat(hdp: HWND; sz: PWideChar): BOOL; overload; {inline;}
function DateTime_SetFormatA(hdp: HWND; sz: PAnsiChar): BOOL; overload; {inline;}
function DateTime_SetFormatW(hdp: HWND; sz: PWideChar): BOOL; overload; {inline;}
function DateTime_SetFormat(hdp: HWND; const sz: UnicodeString): BOOL; overload; {inline;}
function DateTime_SetFormatA(hdp: HWND; const sz: AnsiString): BOOL; overload; {inline;}
function DateTime_SetFormatW(hdp: HWND; const sz: UnicodeString): BOOL; overload; {inline;}

function DateTime_SetMonthCalColor(hdp: HWND; iColor: DWORD; clr: TColorRef): TColorRef; {inline;}

function DateTime_GetMonthCalColor(hdp: HWND; iColor: DWORD): TColorRef; {inline;}

// returns the HWND of the MonthCal popup window. Only valid
// between DTN_DROPDOWN and DTN_CLOSEUP notifications.
function DateTime_GetMonthCal(hdp: HWND): HWND; {inline;}

procedure DateTime_SetMonthCalFont(hdp: HWND; hfont: HFONT; fRedraw: BOOL); {inline;}

function DateTime_GetMonthCalFont(hdp: HWND): HFONT; {inline;}

{  ====================== IP Address edit control ============================= }

const
  WC_IPADDRESS         = 'SysIPAddress32';

  // Messages sent to IPAddress controls
  IPM_CLEARADDRESS     = WM_USER+100;  { no parameters }
  IPM_SETADDRESS       = WM_USER+101;  { lparam = TCP/IP address }
  IPM_GETADDRESS       = WM_USER+102;  { lresult = # of non black fields.  lparam = LPDWORD for TCP/IP address }
  IPM_SETRANGE         = WM_USER+103;  { wparam = field, lparam = range }
  IPM_SETFOCUS         = WM_USER+104;  { wparam = field }
  IPM_ISBLANK          = WM_USER+105;  { no parameters }

  IPN_FIELDCHANGED     = IPN_FIRST - 0;

type
  tagNMIPADDRESS = packed record
    hdr: NMHDR;
    iField: Integer;
    iValue: Integer;
  end;
  PNMIPAddress = ^TNMIPAddress;
  TNMIPAddress = tagNMIPADDRESS;

{ The following is a useful macro for passing the range values in the }
{ IPM_SETRANGE message. }
function MAKEIPRANGE(low, high: Byte): LPARAM; {inline;}

{ And this is a useful macro for making the IP Address to be passed }
{ as a LPARAM. }
function MAKEIPADDRESS(b1, b2, b3, b4: DWORD): LPARAM;

{ Get individual number }
function FIRST_IPADDRESS(x: DWORD): DWORD; {inline;}

function SECOND_IPADDRESS(x: DWORD): DWORD; {inline;}

function THIRD_IPADDRESS(x: DWORD): DWORD; {inline;}

function FOURTH_IPADDRESS(x: DWORD): DWORD; {inline;}

{  ====================== Pager Control ============================= }

const
  { Pager Class Name }
  WC_PAGESCROLLER               = 'SysPager';

  { Pager Control Styles }
  PGS_VERT                    = $00000000;
  PGS_HORZ                    = $00000001;
  PGS_AUTOSCROLL              = $00000002;
  PGS_DRAGNDROP               = $00000004;

  { Pager Button State }
  { The scroll can be in one of the following control State }
  PGF_INVISIBLE        = 0;     { Scroll button is not visible }
  PGF_NORMAL           = 1;     { Scroll button is in normal state }
  PGF_GRAYED           = 2;     { Scroll button is in grayed state }
  PGF_DEPRESSED        = 4;     { Scroll button is in depressed state }
  PGF_HOT              = 8;     { Scroll button is in hot state }

  { The following identifiers specifies the button control }
  PGB_TOPORLEFT           = 0;
  PGB_BOTTOMORRIGHT       = 1;

  { Pager Control  Messages }
  PGM_SETCHILD                = PGM_FIRST + 1;   { lParam == hwnd }
  PGM_RECALCSIZE              = PGM_FIRST + 2;
  PGM_FORWARDMOUSE            = PGM_FIRST + 3;
  PGM_SETBKCOLOR              = PGM_FIRST + 4;
  PGM_GETBKCOLOR              = PGM_FIRST + 5;
  PGM_SETBORDER              = PGM_FIRST + 6;
  PGM_GETBORDER              = PGM_FIRST + 7;
  PGM_SETPOS                  = PGM_FIRST + 8;
  PGM_GETPOS                  = PGM_FIRST + 9;
  PGM_SETBUTTONSIZE           = PGM_FIRST + 10;
  PGM_GETBUTTONSIZE           = PGM_FIRST + 11;
  PGM_GETBUTTONSTATE          = PGM_FIRST + 12;
  PGM_GETDROPTARGET           = CCM_GETDROPTARGET;

procedure Pager_SetChild(hwnd: HWND; hwndChild: HWND); {inline;}
procedure Pager_RecalcSize(hwnd: HWND); {inline;}
procedure Pager_ForwardMouse(hwnd: HWND; bForward: BOOL); {inline;}
function Pager_SetBkColor(hwnd: HWND; clr: COLORREF): COLORREF; {inline;}
function Pager_GetBkColor(hwnd: HWND): COLORREF; {inline;}
function Pager_SetBorder(hwnd: HWND; iBorder: Integer): Integer; {inline;}
function Pager_GetBorder(hwnd: HWND): Integer; {inline;}
function Pager_SetPos(hwnd: HWND; iPos: Integer): Integer; {inline;}
function Pager_GetPos(hwnd: HWND): Integer; {inline;}
function Pager_SetButtonSize(hwnd: HWND; iSize: Integer): Integer; {inline;}
function Pager_GetButtonSize(hwnd: HWND): Integer; {inline;}
function Pager_GetButtonState(hwnd: HWND; iButton: Integer): DWORD; {inline;}
procedure Pager_GetDropTarget(hwnd: HWND; ppdt: Pointer{!!}); {inline;}

const
  { Pager Control Notification Messages }

  { PGN_SCROLL Notification Message }
  PGN_SCROLL              = PGN_FIRST-1;

  PGF_SCROLLUP            = 1;
  PGF_SCROLLDOWN          = 2;
  PGF_SCROLLLEFT          = 4;
  PGF_SCROLLRIGHT         = 8;

  { Keys down }
  PGK_SHIFT               = 1;
  PGK_CONTROL             = 2;
  PGK_MENU                = 4;

type
  { This structure is sent along with PGN_SCROLL notifications }
  NMPGSCROLL = packed record
    hdr: NMHDR;
    fwKeys: Word;           { Specifies which keys are down when this notification is send }
    rcParent: TRect;        { Contains Parent Window Rect }
    iDir: Integer;          { Scrolling Direction }
    iXpos: Integer;         { Horizontal scroll position }
    iYpos: Integer;         { Vertical scroll position }
    iScroll: Integer;       { [in/out] Amount to scroll }
  end;
  PNMPGScroll = ^TNMPGScroll;
  TNMPGScroll = NMPGSCROLL;

const
  { PGN_CALCSIZE Notification Message }
  PGN_CALCSIZE            = PGN_FIRST-2;

  PGF_CALCWIDTH           = 1;
  PGF_CALCHEIGHT          = 2;

type
  NMPGCALCSIZE = packed record
    hdr: NMHDR;
    dwFlag: DWORD;
    iWidth: Integer;
    iHeight: Integer;
  end;
  PNMPGCalcSize = ^TNMPGCalcSize;
  TNMPGCalcSize = NMPGCALCSIZE;

{ ======================  Native Font Control ============================== }

const
  WC_NATIVEFONTCTL            = 'NativeFontCtl';

  { style definition }
  NFS_EDIT                    = $0001;
  NFS_STATIC                  = $0002;
  NFS_LISTCOMBO               = $0004;
  NFS_BUTTON                  = $0008;
  NFS_ALL                     = $0010;

// ====================== Button Control =============================

// Button Class Name
const
  WC_BUTTON               = 'Button';


// *** The following Button control declarations require Windows >= XP ***


  BUTTON_IMAGELIST_ALIGN_LEFT     = 0;
  BUTTON_IMAGELIST_ALIGN_RIGHT    = 1;
  BUTTON_IMAGELIST_ALIGN_TOP      = 2;
  BUTTON_IMAGELIST_ALIGN_BOTTOM   = 3;
  BUTTON_IMAGELIST_ALIGN_CENTER   = 4;      // Doesn't draw text

type
  { $EXTERNALSYM BUTTON_IMAGELIST}
  BUTTON_IMAGELIST = packed record
    himl: HIMAGELIST;   // Images: Normal, Hot, Pushed, Disabled. If count is less than 4, we use index 1
    margin: TRect;      // Margin around icon.
    uAlign: UINT;
  end;
  PButtonImageList = ^TButtonImageList;
  TButtonImageList = BUTTON_IMAGELIST;

const
  BCM_GETIDEALSIZE        = BCM_FIRST + $0001; 
  BCM_SETIMAGELIST        = BCM_FIRST + $0002;
  BCM_GETIMAGELIST        = BCM_FIRST + $0003;
  BCM_SETTEXTMARGIN       = BCM_FIRST + $0004;
  BCM_GETTEXTMARGIN       = BCM_FIRST + $0005;

function Button_GetIdealSize(hwnd: HWND; var psize: TSize): BOOL; {inline;}
function Button_SetImageList(hwnd: HWND; const pbuttonImagelist: TButtonImageList): BOOL; {inline;}
function Button_GetImageList(hwnd: HWND; var pbuttonImagelist: TButtonImageList): BOOL; {inline;}
function Button_SetTextMargin(hwnd: HWND; const pmargin: TRect): BOOL; {inline;}
function Button_GetTextMargin(hwnd: HWND; var pmargin: TRect): BOOL; {inline;}

type
  { $EXTERNALSYM tagNMBCHOTITEM}
  tagNMBCHOTITEM = packed record
    hdr: NMHDR;
    dwFlags: DWORD;            // HICF_*
  end;
  PNMBCHotItem = ^TNMBCHotItem;
  TNMBCHotItem = tagNMBCHOTITEM;

const
  BCN_HOTITEMCHANGE       = BCN_FIRST + $0001;

  BST_HOT                 = $0200;


// *** The following Button control declarations require Windows >= Vista ***


// BUTTON STATE FLAGS
  BST_DROPDOWNPUSHED      = $0400;

// BUTTON STYLES
  BS_SPLITBUTTON          = $0000000C;
  BS_DEFSPLITBUTTON       = $0000000D;
  BS_COMMANDLINK          = $0000000E;
  BS_DEFCOMMANDLINK       = $0000000F;

// SPLIT BUTTON INFO mask flags
  BCSIF_GLYPH             = $0001;
  BCSIF_IMAGE             = $0002;
  BCSIF_STYLE             = $0004;
  BCSIF_SIZE              = $0008;

// SPLIT BUTTON STYLE flags
  BCSS_NOSPLIT            = $0001;
  BCSS_STRETCH            = $0002;
  BCSS_ALIGNLEFT          = $0004;
  BCSS_IMAGE              = $0008;

// BUTTON STRUCTURES
type
  { $EXTERNALSYM tagBUTTON_SPLITINFO}
  tagBUTTON_SPLITINFO = packed record
    mask: UINT;
    himlGlyph: HIMAGELIST;         // interpreted as WCHAR if BCSIF_GLYPH is set
    uSplitStyle: UINT;
    size: SIZE;
  end;
  PButtonSplitinfo = ^TButtonSplitinfo;
  TButtonSplitinfo = tagBUTTON_SPLITINFO;

// BUTTON MESSAGES
const
  BCM_SETDROPDOWNSTATE     = BCM_FIRST + $0006;
  BCM_SETSPLITINFO         = BCM_FIRST + $0007;
  BCM_GETSPLITINFO         = BCM_FIRST + $0008;
  BCM_SETNOTE              = BCM_FIRST + $0009;
  BCM_GETNOTE              = BCM_FIRST + $000A;
  BCM_GETNOTELENGTH        = BCM_FIRST + $000B;
  BCM_SETSHIELD            = BCM_FIRST + $000C;

function Button_SetDropDownState(hwnd: HWND; fDropDown: BOOL): BOOL; {inline;}
function Button_SetSplitInfo(hwnd: HWND; const pInfo: TButtonSplitinfo): BOOL; {inline;}
function Button_GetSplitInfo(hwnd: HWND; var pInfo: TButtonSplitinfo): BOOL; {inline;}
function Button_SetNote(hwnd: HWND; psz: LPCWSTR): BOOL; {inline;} overload;
function Button_SetNote(hwnd: HWND; const psz: UnicodeString): BOOL; {inline;} overload;
function Button_GetNote(hwnd: HWND; psz: LPCWSTR; var pcc: Integer): BOOL; {inline;}
function Button_GetNoteLength(hwnd: HWND): LRESULT; {inline;}
// Macro to use on a button or command link to display an elevated icon
function Button_SetElevationRequiredState(hwnd: HWND; fRequired: BOOL): LRESULT; {inline;}

// Value to pass to BCM_SETIMAGELIST to indicate that no glyph should be
// displayed
const
  BCCL_NOGLYPH  = HIMAGELIST(-1);

// NOTIFICATION MESSAGES
type
  { $EXTERNALSYM tagNMBCDROPDOWN}
  tagNMBCDROPDOWN = packed record
    hdr: NMHDR;
    rcButton: TRect;
  end;
  PNMBCDropDown = ^TNMBCDropDown;
  TNMBCDropDown = tagNMBCDROPDOWN;

const
  BCN_DROPDOWN            = BCN_FIRST + $0002;


/// ====================== Edit Control =============================

// Edit Class Name
const
  WC_EDIT                 = 'Edit';


// *** The following Edit control declarations require Windows >= XP ***


const
  EM_SETCUEBANNER             = ECM_FIRST + 1;   // Set the cue banner with the lParm = LPCWSTR
  EM_GETCUEBANNER             = ECM_FIRST + 2;   // Set the cue banner with the lParm = LPCWSTR

function Edit_SetCueBannerText(hwnd: HWND; lpwText: LPCWSTR): BOOL; {inline;}
function Edit_GetCueBannerText(hwnd: HWND; lpwText: LPCWSTR; cchText: Longint): BOOL; {inline;}

type
  { $EXTERNALSYM _tagEDITBALLOONTIP}
  _tagEDITBALLOONTIP = record
    cbStruct: DWORD;
    pszTitle: LPCWSTR;
    pszText: LPCWSTR;
    ttiIcon: Integer; // From TTI_*
  end;
  PEditBalloonTip = ^TEditBalloonTip;
  TEditBalloonTip = _tagEDITBALLOONTIP;

const
  EM_SHOWBALLOONTIP          = ECM_FIRST + 3;   // Show a balloon tip associated to the edit control
  EM_HIDEBALLOONTIP          = ECM_FIRST + 4;   // Hide any balloon tip associated with the edit control

function Edit_ShowBalloonTip(hwnd: HWND; const peditballoontip: TEditBalloonTip): BOOL; {inline;}
function Edit_HideBalloonTip(hwnd: HWND): BOOL; {inline;}


// *** The following Edit control declarations require Windows >= Vista ***


const
  EM_SETHILITE        = ECM_FIRST + 5;
  EM_GETHILITE        = ECM_FIRST + 6;

procedure Edit_SetHilite(hwndCtl: HWND; ichStart, ichEnd: Integer); {inline;}
function Edit_GetHilite(hwndCtl: HWND): LRESULT; {inline;}


// ====================== Combobox Control =============================


// Combobox Class Name
const
  WC_COMBOBOX             = 'ComboBox';


// *** The following Combobox control declarations require Windows >= Vista ***


// custom combobox control messages
const
  CB_SETMINVISIBLE        = CBM_FIRST + 1;
  CB_GETMINVISIBLE        = CBM_FIRST + 2;
  CB_SETCUEBANNER         = CBM_FIRST + 3;
  CB_GETCUEBANNER         = CBM_FIRST + 4;

function ComboBox_SetMinVisible(hwnd: HWND; iMinVisible: Integer): BOOL; {inline;}
function ComboBox_GetMinVisible(hwnd: HWND): Integer; {inline;}
function ComboBox_SetCueBannerText(hwnd: HWND; lpcwText: LPCWSTR): BOOL; {inline;}
function ComboBox_GetCueBannerText(hwnd: HWND; lpwText: LPCWSTR; cchText: Integer): BOOL; {inline;}


// ===================== Task Dialog =========================


// *** The Task Dialog declarations require Windows >= Vista ***


type
  { $EXTERNALSYM PFTASKDIALOGCALLBACK}
  PFTASKDIALOGCALLBACK = function(hwnd: HWND; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; lpRefData: LONG_PTR): HResult; stdcall;
  TFTaskDialogCallback = PFTASKDIALOGCALLBACK;

const
  { Task Dialog Flags }

  TDF_ENABLE_HYPERLINKS               = $0001;
  TDF_USE_HICON_MAIN                  = $0002;
  TDF_USE_HICON_FOOTER                = $0004;
  TDF_ALLOW_DIALOG_CANCELLATION       = $0008;
  TDF_USE_COMMAND_LINKS               = $0010;
  TDF_USE_COMMAND_LINKS_NO_ICON       = $0020;
  TDF_EXPAND_FOOTER_AREA              = $0040;
  TDF_EXPANDED_BY_DEFAULT             = $0080;
  TDF_VERIFICATION_FLAG_CHECKED       = $0100;
  TDF_SHOW_PROGRESS_BAR               = $0200;
  TDF_SHOW_MARQUEE_PROGRESS_BAR       = $0400;
  TDF_CALLBACK_TIMER                  = $0800;
  TDF_POSITION_RELATIVE_TO_WINDOW     = $1000;
  TDF_RTL_LAYOUT                      = $2000;
  TDF_NO_DEFAULT_RADIO_BUTTON         = $4000;
  TDF_CAN_BE_MINIMIZED                = $8000;

  { Task Dialog Messages }

  TDM_NAVIGATE_PAGE                   = WM_USER+101;
  TDM_CLICK_BUTTON                    = WM_USER+102; // wParam = Button ID
  TDM_SET_MARQUEE_PROGRESS_BAR        = WM_USER+103; // wParam = 0 (nonMarque) wParam != 0 (Marquee)
  TDM_SET_PROGRESS_BAR_STATE          = WM_USER+104; // wParam = new progress state
  TDM_SET_PROGRESS_BAR_RANGE          = WM_USER+105; // lParam = MAKELPARAM(nMinRange, nMaxRange)
  TDM_SET_PROGRESS_BAR_POS            = WM_USER+106; // wParam = new position
  TDM_SET_PROGRESS_BAR_MARQUEE        = WM_USER+107; // wParam = 0 (stop marquee), wParam != 0 (start marquee), lparam = speed (milliseconds between repaints)
  TDM_SET_ELEMENT_TEXT                = WM_USER+108; // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
  TDM_CLICK_RADIO_BUTTON              = WM_USER+110; // wParam = Radio Button ID
  TDM_ENABLE_BUTTON                   = WM_USER+111; // lParam = 0 (disable), lParam != 0 (enable), wParam = Button ID
  TDM_ENABLE_RADIO_BUTTON             = WM_USER+112; // lParam = 0 (disable), lParam != 0 (enable), wParam = Radio Button ID
  TDM_CLICK_VERIFICATION              = WM_USER+113; // wParam = 0 (unchecked), 1 (checked), lParam = 1 (set key focus)
  TDM_UPDATE_ELEMENT_TEXT             = WM_USER+114; // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
  TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE = WM_USER+115; // wParam = Button ID, lParam = 0 (elevation not required), lParam != 0 (elevation required)
  TDM_UPDATE_ICON                     = WM_USER+116; // wParam = icon element (TASKDIALOG_ICON_ELEMENTS), lParam = new icon (hIcon if TDF_USE_HICON_* was set, PCWSTR otherwise)

  { Task Dialog Notifications }

  TDN_CREATED                = 0;
  TDN_NAVIGATED              = 1;
  TDN_BUTTON_CLICKED         = 2;            // wParam = Button ID
  TDN_HYPERLINK_CLICKED      = 3;            // lParam = (LPCWSTR)pszHREF
  TDN_TIMER                  = 4;            // wParam = Milliseconds since dialog created or timer reset
  TDN_DESTROYED              = 5;
  TDN_RADIO_BUTTON_CLICKED   = 6;            // wParam = Radio Button ID
  TDN_DIALOG_CONSTRUCTED     = 7;
  TDN_VERIFICATION_CLICKED   = 8;            // wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0
  TDN_HELP                   = 9;
  TDN_EXPANDO_BUTTON_CLICKED = 10;           // wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded)

type
  { $EXTERNALSYM TASKDIALOG_BUTTON}
  TASKDIALOG_BUTTON = packed record
    nButtonID: Integer;
    pszButtonText: LPCWSTR;
  end;
  { $EXTERNALSYM _TASKDIALOG_BUTTON}
  _TASKDIALOG_BUTTON = TASKDIALOG_BUTTON;
  PTaskDialogButton = ^TTaskDialogButton;
  TTaskDialogButton = TASKDIALOG_BUTTON;

const
  { Task Dialog Elements }

  TDE_CONTENT              = 0;
  TDE_EXPANDED_INFORMATION = 1;
  TDE_FOOTER               = 2;
  TDE_MAIN_INSTRUCTION     = 3;

  { Task Dialog Icon Elements }

  TDIE_ICON_MAIN           = 0;
  TDIE_ICON_FOOTER         = 1;

  { Task Dialog Common Icons }

  TD_WARNING_ICON         = MAKEINTRESOURCEW(Word(-1));
  TD_ERROR_ICON           = MAKEINTRESOURCEW(Word(-2));
  TD_INFORMATION_ICON     = MAKEINTRESOURCEW(Word(-3));
  TD_SHIELD_ICON          = MAKEINTRESOURCEW(Word(-4));

  { Task Dialog Button Flags }

  TDCBF_OK_BUTTON            = $0001;  // selected control return value IDOK
  TDCBF_YES_BUTTON           = $0002;  // selected control return value IDYES
  TDCBF_NO_BUTTON            = $0004;  // selected control return value IDNO
  TDCBF_CANCEL_BUTTON        = $0008;  // selected control return value IDCANCEL
  TDCBF_RETRY_BUTTON         = $0010;  // selected control return value IDRETRY
  TDCBF_CLOSE_BUTTON         = $0020;  // selected control return value IDCLOSE

type
  { $EXTERNALSYM TASKDIALOGCONFIG}
  TASKDIALOGCONFIG = packed record
    cbSize: UINT;
    hwndParent: HWND;
    hInstance: HINST;                     // used for MAKEINTRESOURCE() strings
    dwFlags: DWORD;                       // TASKDIALOG_FLAGS (TDF_XXX) flags
    dwCommonButtons: DWORD;               // TASKDIALOG_COMMON_BUTTON (TDCBF_XXX) flags
    pszWindowTitle: LPCWSTR;              // string or MAKEINTRESOURCE()
    case Integer of
      0: (hMainIcon: HICON);
      1: (pszMainIcon: LPCWSTR;
          pszMainInstruction: LPCWSTR;
          pszContent: LPCWSTR;
          cButtons: UINT;
          pButtons: PTaskDialogButton;
          nDefaultButton: Integer;
          cRadioButtons: UINT;
          pRadioButtons: PTaskDialogButton;
          nDefaultRadioButton: Integer;
          pszVerificationText: LPCWSTR;
          pszExpandedInformation: LPCWSTR;
          pszExpandedControlText: LPCWSTR;
          pszCollapsedControlText: LPCWSTR;
          case Integer of
            0: (hFooterIcon: HICON);
            1: (pszFooterIcon: LPCWSTR;
                pszFooter: LPCWSTR;
                pfCallback: TFTaskDialogCallback;
                lpCallbackData: LONG_PTR;
                cxWidth: UINT  // width of the Task Dialog's client area in DLU's.
                               // If 0, Task Dialog will calculate the ideal width.
              );
          );
  end;
  _TASKDIALOGCONFIG = TASKDIALOGCONFIG;
  PTaskDialogConfig = ^TTaskDialogConfig;
  TTaskDialogConfig = TASKDIALOGCONFIG;

function TaskDialogIndirect(const pTaskConfig: TTaskDialogConfig;
  pnButton: PInteger; pnRadioButton: PInteger; pfVerificationFlagChecked: PBOOL): HRESULT;

function TaskDialog(hwndParent: HWND; hInstance: HINST; pszWindowTitle,
  pszMainInstruction, pszContent: LPCWSTR; dwCommonButtons: DWORD;
  pszIcon: LPCWSTR; pnButton: PInteger): HRESULT;


{ ====== TrackMouseEvent  ================================================== }

const
  WM_MOUSEHOVER                       = $02A1;
  WM_MOUSELEAVE                       = $02A3;

  TME_HOVER           = $00000001;
  TME_LEAVE           = $00000002;
  TME_NONCLIENT       = $00000010;
  TME_QUERY           = $40000000;
  TME_CANCEL          = $80000000;

  HOVER_DEFAULT       = $FFFFFFFF;

type
  tagTRACKMOUSEEVENT = packed record
    cbSize: DWORD;
    dwFlags: DWORD;
    hwndTrack: HWND;
    dwHoverTime: DWORD;
  end;
  PTrackMouseEvent = ^TTrackMouseEvent;
  TTrackMouseEvent = tagTRACKMOUSEEVENT;

{ Declare _TrackMouseEvent.  This API tries to use the window manager's }
{ implementation of TrackMouseEvent if it is present, otherwise it emulates. }
function _TrackMouseEvent(lpEventTrack: PTrackMouseEvent): BOOL; stdcall;

{ ====== Flat Scrollbar APIs========================================= }

const
  WSB_PROP_CYVSCROLL      = $00000001;
  WSB_PROP_CXHSCROLL      = $00000002;
  WSB_PROP_CYHSCROLL      = $00000004;
  WSB_PROP_CXVSCROLL      = $00000008;
  WSB_PROP_CXHTHUMB       = $00000010;
  WSB_PROP_CYVTHUMB       = $00000020;
  WSB_PROP_VBKGCOLOR      = $00000040;
  WSB_PROP_HBKGCOLOR      = $00000080;
  WSB_PROP_VSTYLE         = $00000100;
  WSB_PROP_HSTYLE         = $00000200;
  WSB_PROP_WINSTYLE       = $00000400;
  WSB_PROP_PALETTE        = $00000800;
  WSB_PROP_MASK           = $00000FFF;

  FSB_FLAT_MODE               = 2;
  FSB_ENCARTA_MODE            = 1;
  FSB_REGULAR_MODE            = 0;

function FlatSB_EnableScrollBar(hWnd: HWND; wSBflags, wArrows: UINT): BOOL; stdcall;
function FlatSB_ShowScrollBar(hWnd: HWND; wBar: Integer; bShow: BOOL): BOOL; stdcall;

function FlatSB_GetScrollRange(hWnd: HWND; nBar: Integer; var lpMinPos,
  lpMaxPos: Integer): BOOL; stdcall;
function FlatSB_GetScrollInfo(hWnd: HWND; BarFlag: Integer;
  var ScrollInfo: TScrollInfo): BOOL; stdcall;
function FlatSB_GetScrollPos(hWnd: HWND; nBar: Integer): Integer; stdcall;
function FlatSB_GetScrollProp(p1: HWND; propIndex: Integer;
  p3: PInteger): Bool; stdcall;

function FlatSB_SetScrollPos(hWnd: HWND; nBar, nPos: Integer;
  bRedraw: BOOL): Integer; stdcall;
function FlatSB_SetScrollInfo(hWnd: HWND; BarFlag: Integer;
  const ScrollInfo: TScrollInfo; Redraw: BOOL): Integer; stdcall;
function FlatSB_SetScrollRange(hWnd: HWND; nBar, nMinPos, nMaxPos: Integer;
  bRedraw: BOOL): BOOL; stdcall;
function FlatSB_SetScrollProp(p1: HWND; index: Integer; newValue: Integer;
  p4: Bool): Bool; stdcall;

function InitializeFlatSB(hWnd: HWND): Bool; stdcall;
procedure UninitializeFlatSB(hWnd: HWND); stdcall;

//
// subclassing stuff
//
type
  { For Windows >= XP }
  { $EXTERNALSYM SUBCLASSPROC}
  SUBCLASSPROC = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
    lParam: LPARAM; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
  TSubClassProc = SUBCLASSPROC;

{ For Windows >= XP }
function SetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL;
function GetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL;
function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR): BOOL;
function DefSubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;

{ For NTDDI_VERSION >= NTDDI_LONGHORN }
const
  LIM_SMALL = 0; // corresponds to SM_CXSMICON/SM_CYSMICON
  LIM_LARGE = 1; // corresponds to SM_CXICON/SM_CYICON

{ For NTDDI_VERSION >= NTDDI_LONGHORN }
function LoadIconMetric(hinst: HINST; pszName: LPCWSTR; lims: Integer;
  var phico: HICON): HResult;
function LoadIconWithScaleDown(hinst: HINST; pszName: LPCWSTR; cx: Integer;
  cy: Integer; var phico: HICON): HResult;

{ For Windows >= XP }
function DrawShadowText(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
  dwFlags: DWORD; crText, crShadow: COLORREF; ixOffset, iyOffset: Integer): Integer;

const
  { For Windows >= Vista }
  DCHF_TOPALIGN       = $00000002;  // default is center-align
  DCHF_HORIZONTAL     = $00000004;  // default is vertical
  DCHF_HOT            = $00000008;  // default is flat
  DCHF_PUSHED         = $00000010;  // default is flat
  DCHF_FLIPPED        = $00000020;  // if horiz, default is pointing right
                                        // if vert, default is pointing up
  { For Windows >= Vista }
  DCHF_TRANSPARENT    = $00000040;
  DCHF_INACTIVE       = $00000080;
  DCHF_NOBORDER       = $00000100;

{ For Windows >= Vista }
procedure DrawScrollArrow(hdc: HDC; lprc: PRect; wControlState: UINT;
  rgbOveride: COLORREF);


// Utilities to simplify .NET/Win32 single code base

type
  TWMNotifyHC = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (HDNotify: PHDNotify;
          Result: LRESULT);
    end;

  TWMNotifyTV = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMCustomDraw: PNMCustomDraw);
      2: (NMTreeView: PNMTreeView);
      3: (NMTVCustomDraw: PNMTVCustomDraw);
      4: (ToolTipTextW: PToolTipTextW);
      5: (TVDispInfo: PTVDispInfo;
          Result: LRESULT);
  end;

  TWMNotifyTRB = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMCustomDraw: PNMCustomDraw;
          Result: LRESULT);
  end;

  TWMNotifyUD = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMUpDown: PNMUpDown;
          Result: LRESULT);
  end;

  TWMNotifyLV = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (HDNotify: PHDNotify);
      2: (LVDispInfo: PLVDispInfo);
      3: (NMCustomDraw: PNMCustomDraw);
      4: (NMListView: PNMListView);
      5: (NMLVCacheHint: PNMLVCacheHint);
      6: (NMLVCustomDraw: PNMLVCustomDraw);
      7: (NMLVFindItem: PNMLVFindItem);
      8: (NMLVODStateChange: PNMLVODStateChange;
          Result: LRESULT);
  end;

  TWMNotifyTLB = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMTBCustomDraw: PNMTBCustomDraw);
      2: (NMToolBar: PNMToolBar;
          Result: LRESULT);
  end;

  TWMNotifyMC = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMDayState: PNMDayState);
      2: (NMSelChange: PNMSelChange;
          Result: LRESULT);
  end;

  TWMNotifyDT = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMDateTimeChange: PNMDateTimeChange);
      2: (NMDateTimeString: PNMDateTimeString;
          Result: LRESULT);
  end;

  TWMNotifyPS = packed record { TWMNotify }
    Msg: Cardinal;
    IDCtrl: Longint;
    case Integer of
      0: (NMHdr: PNMHdr);
      1: (NMPGCalcSize: PNMPGCalcSize);
      2: (NMPGScroll: PNMPGScroll;
          Result: LRESULT);
  end;

  TTCMAdjustRect = packed record
    Msg: Cardinal;
    Larger: LongBool;
    case Integer of
      0: (lpPrc: PRect);
      1: (Prc: PRect; 
          Result: LRESULT);
  end;

implementation

const
  cctrl = comctl32; { From Windows.pas }

var
  ComCtl32DLL: THandle;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool stdcall;

procedure InitCommonControls; external cctrl name 'InitCommonControls';

procedure InitComCtl;
begin
  if ComCtl32DLL = 0 then
  begin
    ComCtl32DLL := GetModuleHandle(cctrl);
    if ComCtl32DLL <> 0 then
      @_InitCommonControlsEx := GetProcAddress(ComCtl32DLL, PAnsiChar('InitCommonControlsEx'));
  end;
end;

function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool;
begin
  if ComCtl32DLL = 0 then InitComCtl;
  Result := Assigned(_InitCommonControlsEx) and _InitCommonControlsEx(ICC);
end;

{ Property Sheets }
function CreatePropertySheetPage; external cctrl name 'CreatePropertySheetPageW';
function CreatePropertySheetPageA; external cctrl name 'CreatePropertySheetPageA';
function CreatePropertySheetPageW; external cctrl name 'CreatePropertySheetPageW';
function DestroyPropertySheetPage; external cctrl name 'DestroyPropertySheetPage';
function PropertySheet; external cctrl name 'PropertySheetW';
function PropertySheetA; external cctrl name 'PropertySheetA';
function PropertySheetW; external cctrl name 'PropertySheetW';

{ Image List }
function ImageList_Create; external cctrl name 'ImageList_Create';
function ImageList_Destroy; external cctrl name 'ImageList_Destroy';
function ImageList_GetImageCount; external cctrl name 'ImageList_GetImageCount';
function ImageList_SetImageCount; external cctrl name 'ImageList_SetImageCount';
function ImageList_Add; external cctrl name 'ImageList_Add';
function ImageList_ReplaceIcon; external cctrl name 'ImageList_ReplaceIcon';
function ImageList_SetBkColor; external cctrl name 'ImageList_SetBkColor';
function ImageList_GetBkColor; external cctrl name 'ImageList_GetBkColor';
function ImageList_SetOverlayImage; external cctrl name 'ImageList_SetOverlayImage';

function ImageList_AddIcon(ImageList: HIMAGELIST; Icon: HIcon): Integer;
begin
  Result := ImageList_ReplaceIcon(ImageList, -1, Icon);
end;

function IndexToOverlayMask(Index: Integer): Integer;
begin
  Result := Index shl 8;
end;

function ImageList_Draw; external cctrl name 'ImageList_Draw';

function ImageList_Replace; external cctrl name 'ImageList_Replace';
function ImageList_AddMasked; external cctrl name 'ImageList_AddMasked';
function ImageList_DrawEx; external cctrl name 'ImageList_DrawEx';
function ImageList_DrawIndirect; external cctrl name 'ImageList_DrawIndirect';
function ImageList_Remove; external cctrl name 'ImageList_Remove';
function ImageList_GetIcon; external cctrl name 'ImageList_GetIcon';
function ImageList_LoadImage; external cctrl name 'ImageList_LoadImageW';
function ImageList_LoadImageA; external cctrl name 'ImageList_LoadImageA';
function ImageList_LoadImageW; external cctrl name 'ImageList_LoadImageW';
function ImageList_Copy; external cctrl name 'ImageList_Copy';
function ImageList_BeginDrag; external cctrl name 'ImageList_BeginDrag';
function ImageList_EndDrag; external cctrl name 'ImageList_EndDrag';
function ImageList_DragEnter; external cctrl name 'ImageList_DragEnter';
function ImageList_DragLeave; external cctrl name 'ImageList_DragLeave';
function ImageList_DragMove; external cctrl name 'ImageList_DragMove';
function ImageList_SetDragCursorImage; external cctrl name 'ImageList_SetDragCursorImage';
function ImageList_DragShowNolock; external cctrl name 'ImageList_DragShowNolock';
function ImageList_GetDragImage(Point, HotSpot: PPoint): HIMAGELIST; external cctrl name 'ImageList_GetDragImage';
function ImageList_GetDragImage(Point: PPoint; out HotSpot: TPoint): HIMAGELIST; external cctrl name 'ImageList_GetDragImage';

{ macros }
procedure ImageList_RemoveAll(ImageList: HIMAGELIST);
begin
  ImageList_Remove(ImageList, -1);
end;

function ImageList_ExtractIcon(Instance: THandle; ImageList: HIMAGELIST;
  Image: Integer): HIcon;
begin
  Result := ImageList_GetIcon(ImageList, Image, 0);
end;

function ImageList_LoadBitmap(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImage(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;
function ImageList_LoadBitmapA(Instance: THandle; Bmp: PAnsiChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImageA(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;
function ImageList_LoadBitmapW(Instance: THandle; Bmp: PWideChar;
  CX, Grow: Integer; Mask: TColorRef): HIMAGELIST;
begin
  Result := ImageList_LoadImageW(Instance, Bmp, CX, Grow, Mask,
    IMAGE_BITMAP, 0);
end;

function ImageList_Read; external cctrl name 'ImageList_Read';
function ImageList_Write; external cctrl name 'ImageList_Write';

var
  _ImageList_ReadEx: function(dwFlags: DWORD; pstm: IStream; const riid: TIID;
    var ppv: Pointer): HResult; stdcall;

function ImageList_ReadEx(dwFlags: DWORD; pstm: IStream; const riid: TIID;
  var ppv: Pointer): HResult;
begin
  if Assigned(_ImageList_ReadEx) then
    Result := _ImageList_ReadEx(dwFlags, pstm, riid, ppv)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _ImageList_ReadEx := GetProcAddress(ComCtl32DLL, PAnsiChar('ImageList_ReadEx')); // Do not localize
      if Assigned(_ImageList_ReadEx) then
        Result := _ImageList_ReadEx(dwFlags, pstm, riid, ppv);
    end;
  end;
end;

var
  _ImageList_WriteEx: function(himl: HIMAGELIST; dwFlags: DWORD;
    pstm: IStream): HResult; stdcall;

function ImageList_WriteEx(himl: HIMAGELIST; dwFlags: DWORD; pstm: IStream): HResult;
begin
  if Assigned(_ImageList_WriteEx) then
    Result := _ImageList_WriteEx(himl, dwFlags, pstm)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _ImageList_WriteEx := GetProcAddress(ComCtl32DLL, PAnsiChar('ImageList_WriteEx')); // Do not localize
      if Assigned(_ImageList_WriteEx) then
        Result := _ImageList_WriteEx(himl, dwFlags, pstm);
    end;
  end;
end;

function ImageList_GetIconSize; external cctrl name 'ImageList_GetIconSize';
function ImageList_SetIconSize; external cctrl name 'ImageList_SetIconSize';
function ImageList_GetImageInfo; external cctrl name 'ImageList_GetImageInfo';
function ImageList_Merge; external cctrl name 'ImageList_Merge';
function ImageList_Duplicate(himl: HIMAGELIST): HIMAGELIST; stdcall; external cctrl name 'ImageList_Duplicate';

var
  _HIMAGELIST_QueryInterface: function(himl: HIMAGELIST; const riid: TIID;
    var ppv: Pointer): HResult; stdcall;

function HIMAGELIST_QueryInterface(himl: HIMAGELIST; const riid: TIID;
  var ppv: Pointer): HResult;
begin
  if Assigned(_HIMAGELIST_QueryInterface) then
    Result := _HIMAGELIST_QueryInterface(himl, riid, ppv)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _HIMAGELIST_QueryInterface := GetProcAddress(ComCtl32DLL,
        PAnsiChar('HIMAGELIST_QueryInterface')); // Do not localize
      if Assigned(_HIMAGELIST_QueryInterface) then
        Result := _HIMAGELIST_QueryInterface(himl, riid, ppv);
    end;
  end;
end;

{ Headers }

function Header_GetItemCount(Header: HWnd): Integer;
begin
  Result := SendMessage(Header, HDM_GETITEMCOUNT, 0, 0);
end;

function Header_InsertItem(Header: HWnd; Index: Integer;
  const Item: THDItem): Integer;
begin
  Result := SendMessage(Header, HDM_INSERTITEM, Index, Longint(@Item));
end;
function Header_InsertItemA(Header: HWnd; Index: Integer;
  const Item: THDItemA): Integer;
begin
  Result := SendMessageA(Header, HDM_INSERTITEM, Index, Longint(@Item));
end;
function Header_InsertItemW(Header: HWnd; Index: Integer;
  const Item: THDItemW): Integer;
begin
  Result := SendMessageW(Header, HDM_INSERTITEM, Index, Longint(@Item));
end;

function Header_DeleteItem(Header: HWnd; Index: Integer): Bool;
begin
  Result := Bool( SendMessage(Header, HDM_DELETEITEM, Index, 0) );
end;

function Header_GetItem(Header: HWnd; Index: Integer; var Item: THDItem): Bool;
begin
  Result := Bool( SendMessage(Header, HDM_GETITEM, Index, Longint(@Item)) );
end;
function Header_GetItemA(Header: HWnd; Index: Integer; var Item: THDItemA): Bool;
begin
  Result := Bool( SendMessageA(Header, HDM_GETITEM, Index, Longint(@Item)) );
end;
function Header_GetItemW(Header: HWnd; Index: Integer; var Item: THDItemW): Bool;
begin
  Result := Bool( SendMessageW(Header, HDM_GETITEM, Index, Longint(@Item)) );
end;

function Header_SetItem(Header: HWnd; Index: Integer; const Item: THDItem): Bool;
begin
  Result := Bool( SendMessage(Header, HDM_SETITEM, Index, Longint(@Item)) );
end;
function Header_SetItemA(Header: HWnd; Index: Integer; const Item: THDItemA): Bool;
begin
  Result := Bool( SendMessageA(Header, HDM_SETITEM, Index, Longint(@Item)) );
end;
function Header_SetItemW(Header: HWnd; Index: Integer; const Item: THDItemW): Bool;
begin
  Result := Bool( SendMessageW(Header, HDM_SETITEM, Index, Longint(@Item)) );
end;

function Header_Layout(Header: HWnd; Layout: PHDLayout): Bool;
begin
  Result := Bool( SendMessage(Header, HDM_LAYOUT, 0, Longint(Layout)) );
end;

function Header_GetItemRect(hwnd: HWND; iItem: Integer; lprc: PRect): Integer;
begin
  Result := SendMessage(hwnd, HDM_GETITEMRECT, iItem, LPARAM(lprc));
end;

function Header_SetImageList(hwnd: HWND; himl: HIMAGELIST): HIMAGELIST;
begin
  Result := SendMessage(hwnd, HDM_SETIMAGELIST, 0, LPARAM(himl));
end;

function Header_GetImageList(hwnd: HWND): HIMAGELIST;
begin
  Result := SendMessage(hwnd, HDM_GETIMAGELIST, 0, 0);
end;

function Header_OrderToIndex(hwnd: HWND; i: Integer): Integer;
begin
  Result := SendMessage(hwnd, HDM_ORDERTOINDEX, i, 0);
end;

function Header_CreateDragImage(hwnd: HWND; i: Integer): HIMAGELIST;
begin
  Result := SendMessage(hwnd, HDM_CREATEDRAGIMAGE, i, 0);
end;

function Header_GetOrderArray(hwnd: HWND; iCount: Integer; lpi: PInteger): Integer;
begin
  Result := SendMessage(hwnd, HDM_GETORDERARRAY, iCount, LPARAM(lpi));
end;

function Header_SetOrderArray(hwnd: HWND; iCount: Integer; lpi: PInteger): Integer;
begin
  Result := SendMessage(hwnd, HDM_SETORDERARRAY, iCount, LPARAM(lpi));
end;

function Header_SetHotDivider(hwnd: HWND; fPos: BOOL; dw: DWORD): Integer;
begin
  Result := SendMessage(hwnd, HDM_SETHOTDIVIDER, Integer(fPos), dw);
end;

function Header_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): Integer;
begin
  Result := SendMessage(hwnd, HDM_SETUNICODEFORMAT, Integer(fUnicode), 0);
end;

function Header_GetUnicodeFormat(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, HDM_GETUNICODEFORMAT, 0, 0);
end;

function Header_SetBitmapMargin(hwnd: HWND; iWidth: Integer): Integer;
begin
  Result := SendMessage(hwnd, HDM_SETBITMAPMARGIN, WPARAM(iWidth), 0);
end;

function Header_GetBitmapMargin(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, HDM_GETBITMAPMARGIN, 0, 0);
end;

function Header_SetFilterChangeTimeout(hwnd: HWND; i: Integer): Integer;
begin
  Result := SendMessage(hwnd, HDM_SETFILTERCHANGETIMEOUT, 0, LPARAM(i));
end;

function Header_EditFilter(hwnd: HWND; i: Integer; fDiscardChanges: BOOL): Integer;
begin
  Result := SendMessage(hwnd, HDM_EDITFILTER, WPARAM(i), MAKELPARAM(Word(fDiscardChanges), 0));
end;

function Header_ClearFilter(hwnd: HWND; i: Integer): Integer;
begin
  Result := SendMessage(hwnd, HDM_CLEARFILTER, WPARAM(i), 0);
end;

function Header_ClearAllFilters(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, HDM_CLEARFILTER, WPARAM(-1), 0);
end;

function Header_GetItemDropDownRect(hwnd: HWND; iItem: Integer; var lprc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, HDM_GETITEMDROPDOWNRECT, WPARAM(iItem), LPARAM(@lprc)));
end;

function Header_GetOverflowRect(hwnd: HWND; var lprc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, HDM_GETOVERFLOWRECT, 0, LPARAM(@lprc)));
end;

function Header_GetFocusedItem(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, HDM_GETFOCUSEDITEM, 0, 0);
end;

function Header_SetFocusedItem(hwnd: HWND; iItem: Integer): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, HDM_SETFOCUSEDITEM, 0, LPARAM(iItem)));
end;


{ Toolbar }

function CreateToolBarEx; external cctrl name 'CreateToolbarEx';
function CreateMappedBitmap; external cctrl name 'CreateMappedBitmap';

{ Status bar }
procedure DrawStatusText; external cctrl name 'DrawStatusTextW';
procedure DrawStatusTextA; external cctrl name 'DrawStatusTextA';
procedure DrawStatusTextW; external cctrl name 'DrawStatusTextW';
function CreateStatusWindow; external cctrl name 'CreateStatusWindowW';
function CreateStatusWindowA; external cctrl name 'CreateStatusWindowA';
function CreateStatusWindowW; external cctrl name 'CreateStatusWindowW';

{ Menu Help }
procedure MenuHelp; external cctrl name 'MenuHelp';
function ShowHideMenuCtl; external cctrl name 'ShowHideMenuCtl';
procedure GetEffectiveClientRect; external cctrl name 'GetEffectiveClientRect';

{ Drag List Box }
procedure MakeDragList; external cctrl name 'MakeDragList';
procedure DrawInsert; external cctrl name 'DrawInsert';
function LBItemFromPt; external cctrl name 'LBItemFromPt';

{ UpDown control }
function CreateUpDownControl; external cctrl name 'CreateUpDownControl';

{ List View }
function ListView_GetUnicodeFormat(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETUNICODEFORMAT, 0, 0));
end;

function ListView_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_SETUNICODEFORMAT, Integer(fUnicode), 0));
end;

function ListView_GetBkColor(hWnd: HWND): TColorRef;
begin
  Result := SendMessage(hWnd, LVM_GETBKCOLOR, 0, 0);
end;

function ListView_SetBkColor(hWnd: HWND; clrBk: TColorRef): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_SETBKCOLOR, 0, clrBk) );
end;

function ListView_GetImageList(hWnd: HWND; iImageList: Integer): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hWnd, LVM_GETIMAGELIST, iImageList, 0) );
end;

function ListView_SetImageList(hWnd: HWND; himl: HIMAGELIST; iImageList: Integer): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hWnd, LVM_SETIMAGELIST, iImageList, Longint(himl)) );
end;

function ListView_GetItemCount(hWnd: HWND): Integer;
begin
  Result := SendMessage(hWnd, LVM_GETITEMCOUNT, 0, 0);
end;

function IndexToStateImageMask(I: Longint): Longint;
begin
  Result := I shl 12;
end;

function ListView_GetItem(hWnd: HWND; var pItem: TLVItem): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_GETITEM, 0, Longint(@pItem)) );
end;
function ListView_GetItemA(hWnd: HWND; var pItem: TLVItemA): Bool;
begin
  Result := Bool( SendMessageA(hWnd, LVM_GETITEMA, 0, Longint(@pItem)) );
end;
function ListView_GetItemW(hWnd: HWND; var pItem: TLVItemW): Bool;
begin
  Result := Bool( SendMessageW(hWnd, LVM_GETITEMW, 0, Longint(@pItem)) );
end;

function ListView_SetItem(hWnd: HWND; const pItem: TLVItem): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_SETITEM, 0, Longint(@pItem)) );
end;
function ListView_SetItemA(hWnd: HWND; const pItem: TLVItemA): Bool;
begin
  Result := Bool( SendMessageA(hWnd, LVM_SETITEMA, 0, Longint(@pItem)) );
end;
function ListView_SetItemW(hWnd: HWND; const pItem: TLVItemW): Bool;
begin
  Result := Bool( SendMessageW(hWnd, LVM_SETITEMW, 0, Longint(@pItem)) );
end;

function ListView_InsertItem(hWnd: HWND; const pItem: TLVItem): Integer;
begin
  Result := Integer( SendMessage(hWnd, LVM_INSERTITEM, 0, Longint(@pItem)) );
end;
function ListView_InsertItemA(hWnd: HWND; const pItem: TLVItemA): Integer;
begin
  Result := Integer( SendMessageA(hWnd, LVM_INSERTITEMA, 0, Longint(@pItem)) );
end;
function ListView_InsertItemW(hWnd: HWND; const pItem: TLVItemW): Integer;
begin
  Result := Integer( SendMessageW(hWnd, LVM_INSERTITEMW, 0, Longint(@pItem)) );
end;

function ListView_DeleteItem(hWnd: HWND; i: Integer): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_DELETEITEM, i, 0) );
end;

function ListView_DeleteAllItems(hWnd: HWND): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_DELETEALLITEMS, 0, 0) );
end;

function ListView_GetCallbackMask(hWnd: HWND): UINT;
begin
  Result := SendMessage(hWnd, LVM_GETCALLBACKMASK, 0, 0);
end;

function ListView_SetCallbackMask(hWnd: HWND; mask: UINT): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_SETCALLBACKMASK, mask, 0) );
end;

function ListView_GetNextItem(hWnd: HWND; iStart: Integer; Flags: UINT): Integer;
begin
  Result := SendMessage(hWnd, LVM_GETNEXTITEM, iStart, MakeLong(Word(Flags), 0));
end;

function ListView_FindItem(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfo): Integer;
begin
  Result := SendMessage(hWnd, LVM_FINDITEM, iStart, Longint(@plvfi));
end;
function ListView_FindItemA(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfoA): Integer;
begin
  Result := SendMessageA(hWnd, LVM_FINDITEMA, iStart, Longint(@plvfi));
end;
function ListView_FindItemW(hWnd: HWND; iStart: Integer;
  const plvfi: TLVFindInfoW): Integer;
begin
  Result := SendMessageW(hWnd, LVM_FINDITEMW, iStart, Longint(@plvfi));
end;

function ListView_GetItemRect(hWnd: HWND; i: Integer; var prc: TRect;
  Code: Integer): Bool;
begin
  if @prc <> nil then
  begin
    prc.left := Code;
    Result := Bool( SendMessage(hWnd, LVM_GETITEMRECT, i, Longint(@prc)) );
  end
  else
    Result := Bool( SendMessage(hWnd, LVM_GETITEMRECT, i, 0) );
end;

function ListView_SetItemPosition(hWnd: HWND; i, x, y: Integer): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_SETITEMPOSITION, i, MakeLong(Word(x), Word(y))) );
end;

function ListView_GetItemPosition(hwndLV: HWND; i: Integer;
  var ppt: TPoint): Bool;
begin
  Result := Bool( SendMessage(hWndLV, LVM_GETITEMPOSITION, i, Longint(@ppt)) );
end;

function ListView_GetStringWidth(hwndLV: HWND; psz: PWideChar): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETSTRINGWIDTH, 0, Longint(psz));
end;
function ListView_GetStringWidthA(hwndLV: HWND; psz: PAnsiChar): Integer;
begin
  Result := SendMessageA(hwndLV, LVM_GETSTRINGWIDTHA, 0, Longint(psz));
end;
function ListView_GetStringWidthW(hwndLV: HWND; psz: PWideChar): Integer;
begin
  Result := SendMessageW(hwndLV, LVM_GETSTRINGWIDTHW, 0, Longint(psz));
end;

function ListView_HitTest(hwndLV: HWND; var pinfo: TLVHitTestInfo): Integer;
begin
  Result := SendMessage(hwndLV, LVM_HITTEST, 0, Longint(@pinfo));
end;

function ListView_EnsureVisible(hwndLV: HWND; i: Integer; fPartialOK: Bool): Bool;
begin
  Result := SendMessage(hwndLV, LVM_ENSUREVISIBLE, i,
    MakeLong(Word(fPartialOK), 0)) <> 0;
end;

function ListView_Scroll(hwndLV: HWnd; DX, DY: Integer): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_SCROLL, DX, DY) );
end;

function ListView_RedrawItems(hwndLV: HWND; iFirst, iLast: Integer): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_REDRAWITEMS, iFirst, iLast) );
end;

function ListView_Arrange(hwndLV: HWND; Code: UINT): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_ARRANGE, Code, 0) );
end;

function ListView_EditLabel(hwndLV: HWND; i: Integer): HWND;
begin
  Result := HWND( SendMessage(hwndLV, LVM_EDITLABEL, i, 0) );
end;
function ListView_EditLabelA(hwndLV: HWND; i: Integer): HWND;
begin
  Result := HWND( SendMessageA(hwndLV, LVM_EDITLABELA, i, 0) );
end;
function ListView_EditLabelW(hwndLV: HWND; i: Integer): HWND;
begin
  Result := HWND( SendMessageW(hwndLV, LVM_EDITLABELW, i, 0) );
end;

function ListView_GetEditControl(hwndLV: HWND): HWND;
begin
  Result := HWND( SendMessage(hwndLV, LVM_GETEDITCONTROL, 0, 0) );
end;

function ListView_GetColumn(hwnd: HWND; iCol: Integer; var pcol: TLVColumn): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_GETCOLUMN, iCol, Longint(@pcol)) );
end;
function ListView_GetColumnA(hwnd: HWND; iCol: Integer; var pcol: TLVColumnA): Bool;
begin
  Result := Bool( SendMessageA(hwnd, LVM_GETCOLUMNA, iCol, Longint(@pcol)) );
end;
function ListView_GetColumnW(hwnd: HWND; iCol: Integer; var pcol: TLVColumnW): Bool;
begin
  Result := Bool( SendMessageW(hwnd, LVM_GETCOLUMNW, iCol, Longint(@pcol)) );
end;

function ListView_SetColumn(hwnd: HWND; iCol: Integer; const pcol: TLVColumn): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_SETCOLUMN, iCol, Longint(@pcol)) );
end;
function ListView_SetColumnA(hwnd: HWND; iCol: Integer; const pcol: TLVColumnA): Bool;
begin
  Result := Bool( SendMessageA(hwnd, LVM_SETCOLUMNA, iCol, Longint(@pcol)) );
end;
function ListView_SetColumnW(hwnd: HWND; iCol: Integer; const pcol: TLVColumnW): Bool;
begin
  Result := Bool( SendMessageW(hwnd, LVM_SETCOLUMNW, iCol, Longint(@pcol)) );
end;

function ListView_InsertColumn(hwnd: HWND; iCol: Integer; const pcol: TLVColumn): Integer;
begin
  Result := SendMessage(hWnd, LVM_INSERTCOLUMN, iCol, Longint(@pcol));
end;
function ListView_InsertColumnA(hwnd: HWND; iCol: Integer; const pcol: TLVColumnA): Integer;
begin
  Result := SendMessageA(hWnd, LVM_INSERTCOLUMNA, iCol, Longint(@pcol));
end;
function ListView_InsertColumnW(hwnd: HWND; iCol: Integer; const pcol: TLVColumnW): Integer;
begin
  Result := SendMessageW(hWnd, LVM_INSERTCOLUMNW, iCol, Longint(@pcol));
end;

function ListView_DeleteColumn(hwnd: HWND; iCol: Integer): Bool;
begin
  Result := Bool( SendMessage(hWnd, LVM_DELETECOLUMN, iCol, 0) );
end;

function ListView_GetColumnWidth(hwnd: HWND; iCol: Integer): Integer;
begin
  Result := Integer( SendMessage(hwnd, LVM_GETCOLUMNWIDTH, iCol, 0) );
end;

function ListView_SetColumnWidth(hwnd: HWnd; iCol: Integer; cx: Integer): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_SETCOLUMNWIDTH, iCol,
    MakeLong(Word(cx), 0)) );
end;

function ListView_GetHeader(hwnd: HWND): HWND;
begin
  Result := SendMessage(hwnd, LVM_GETHEADER, 0, 0);
end;

function ListView_CreateDragImage(hwnd: HWND; i: Integer;
  const lpptUpLeft: TPoint): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hwnd, LVM_CREATEDRAGIMAGE, i,
    Longint(@lpptUpLeft)));
end;

function ListView_GetViewRect(hwnd: HWND; var prc: TRect): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_GETVIEWRECT, 0, Longint(@prc)) );
end;

function ListView_GetTextColor(hwnd: HWND): TColorRef;
begin
  Result := SendMessage(hwnd, LVM_GETTEXTCOLOR, 0, 0);
end;

function ListView_SetTextColor(hwnd: HWND; clrText: TColorRef): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_SETTEXTCOLOR, 0, clrText) );
end;

function ListView_GetTextBkColor(hwnd: HWND): TColorRef;
begin
  Result := SendMessage(hwnd, LVM_GETTEXTBKCOLOR, 0, 0);
end;

function ListView_SetTextBkColor(hwnd: HWND; clrTextBk: TColorRef): Bool;
begin
  Result := Bool( SendMessage(hwnd, LVM_SETTEXTBKCOLOR, 0, clrTextBk) );
end;

function ListView_GetTopIndex(hwndLV: HWND): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETTOPINDEX, 0, 0);
end;

function ListView_GetCountPerPage(hwndLV: HWND): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETCOUNTPERPAGE, 0, 0);
end;

function ListView_GetOrigin(hwndLV: HWND; var ppt: TPoint): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_GETORIGIN, 0, Longint(@ppt)) );
end;

function ListView_Update(hwndLV: HWND; i: Integer): Bool;
begin
  Result := SendMessage(hwndLV, LVM_UPDATE, i, 0) <> 0;
end;

function ListView_SetItemState(hwndLV: HWND; i: Integer; data, mask: UINT): Bool;
var
  Item: TLVItem;
begin
  Item.stateMask := mask;
  Item.state := data;
  Result := Bool( SendMessage(hwndLV, LVM_SETITEMSTATE, i, Longint(@Item)) );
end;

function ListView_GetItemState(hwndLV: HWND; i, mask: Integer): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETITEMSTATE, i, mask);
end;

function ListView_GetCheckState(hwndLV: HWND; i: Integer): UINT;
begin
  Result := (SendMessage(hwndLV, LVM_GETITEMSTATE, i, LVIS_STATEIMAGEMASK) shr 12) - 1 ;
end;

procedure ListView_SetCheckState(hwndLV: HWND; i: Integer; Checked: Boolean);
var
  Item: TLVItem;
begin
  Item.statemask := LVIS_STATEIMAGEMASK;
  Item.State := ((Integer(Checked) and 1) + 1) shl 12;
  SendMessage(hwndLV, LVM_SETITEMSTATE, i, Integer(@Item));
end;

function ListView_GetItemText(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar; cchTextMax: Integer): Integer;
var
  Item: TLVItem;
begin
  Item.iSubItem := iSubItem;
  Item.cchTextMax := cchTextMax;
  Item.pszText := pszText;
  Result := SendMessage(hwndLV, LVM_GETITEMTEXT, i, Longint(@Item));
end;
function ListView_GetItemTextA(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PAnsiChar; cchTextMax: Integer): Integer;
var
  Item: TLVItemA;
begin
  Item.iSubItem := iSubItem;
  Item.cchTextMax := cchTextMax;
  Item.pszText := pszText;
  Result := SendMessageA(hwndLV, LVM_GETITEMTEXTA, i, Longint(@Item));
end;
function ListView_GetItemTextW(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar; cchTextMax: Integer): Integer;
var
  Item: TLVItemW;
begin
  Item.iSubItem := iSubItem;
  Item.cchTextMax := cchTextMax;
  Item.pszText := pszText;
  Result := SendMessageW(hwndLV, LVM_GETITEMTEXTW, i, Longint(@Item));
end;

function ListView_SetItemText(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar): Bool;
var
  Item: TLVItem;
begin
  Item.iSubItem := iSubItem;
  Item.pszText := pszText;
  Result := Bool( SendMessage(hwndLV, LVM_SETITEMTEXT, i, Longint(@Item)) );
end;
function ListView_SetItemTextA(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PAnsiChar): Bool;
var
  Item: TLVItemA;
begin
  Item.iSubItem := iSubItem;
  Item.pszText := pszText;
  Result := Bool( SendMessageA(hwndLV, LVM_SETITEMTEXTA, i, Longint(@Item)) );
end;
function ListView_SetItemTextW(hwndLV: HWND; i, iSubItem: Integer;
  pszText: PWideChar): Bool;
var
  Item: TLVItemW;
begin
  Item.iSubItem := iSubItem;
  Item.pszText := pszText;
  Result := Bool( SendMessageW(hwndLV, LVM_SETITEMTEXTW, i, Longint(@Item)) );
end;

procedure ListView_SetItemCount(hwndLV: HWND; cItems: Integer);
begin
  SendMessage(hwndLV, LVM_SETITEMCOUNT, cItems, 0);
end;

procedure ListView_SetItemCountEx(hwndLV: HWND; cItems: Integer; dwFlags: DWORD);
begin
  SendMessage(hwndLV, LVM_SETITEMCOUNT, cItems, dwFlags);
end;

function ListView_SortItems(hwndLV: HWND; pfnCompare: TLVCompare;
  lPrm: Longint): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_SORTITEMS, lPrm,
    Longint(@pfnCompare)) );
end;

procedure ListView_SetItemPosition32(hwndLV: HWND; i, x, y: Integer);
var
  ptNewPos: TPoint;
begin
  ptNewPos.x := x;
  ptNewPos.y := y;
  SendMessage(hwndLV, LVM_SETITEMPOSITION32, i, Longint(@ptNewPos));
end;

function ListView_GetSelectedCount(hwndLV: HWND): UINT;
begin
  Result := SendMessage(hwndLV, LVM_GETSELECTEDCOUNT, 0, 0);
end;

function ListView_GetItemSpacing(hwndLV: HWND; fSmall: Integer): Longint;
begin
  Result := SendMessage(hwndLV, LVM_GETITEMSPACING, fSmall, 0);
end;

function ListView_GetISearchString(hwndLV: HWND; lpsz: PWideChar): Bool;
begin
  Result := Bool( SendMessage(hwndLV, LVM_GETISEARCHSTRING, 0,
    Longint(lpsz)) );
end;
function ListView_GetISearchStringA(hwndLV: HWND; lpsz: PAnsiChar): Bool;
begin
  Result := Bool( SendMessageA(hwndLV, LVM_GETISEARCHSTRINGA, 0,
    Longint(lpsz)) );
end;
function ListView_GetISearchStringW(hwndLV: HWND; lpsz: PWideChar): Bool;
begin
  Result := Bool( SendMessageW(hwndLV, LVM_GETISEARCHSTRINGW, 0,
    Longint(lpsz)) );
end;

function ListView_SetIconSpacing(hwndLV: HWND; cx, cy: Word): DWORD;
begin
  Result := SendMessage(hwndLV, LVM_SETICONSPACING, 0, MakeLong(cx, cy));
end;

function ListView_SetExtendedListViewStyle(hwndLV: HWND; dw: DWORD): BOOL;
begin
  Result := BOOL(SendMessage(hwndLV, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, dw));
end;

function ListView_GetExtendedListViewStyle(hwndLV: HWND): DWORD;
begin
  Result := SendMessage(hwndLV, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
end;

function ListView_GetSubItemRect(hwndLV: HWND; iItem, iSubItem: Integer;
  code: DWORD; prc: PRect): BOOL;
begin
  if prc <> nil then
  begin
    prc^.Top := iSubItem;
    prc^.Left := code;
  end;
  Result := BOOL(SendMessage(hwndLV, LVM_GETSUBITEMRECT, iItem, Longint(prc)));
end;

function ListView_SubItemHitTest(hwndLV: HWND; plvhti: PLVHitTestInfo): Integer;
begin
  Result := SendMessage(hwndLV, LVM_SUBITEMHITTEST, 0, Longint(plvhti));
end;

function ListView_SetColumnOrderArray(hwndLV: HWND; iCount: Integer;
  pi: PInteger): BOOL;
begin
  Result := BOOL(SendMessage(hwndLV, LVM_SETCOLUMNORDERARRAY, iCount,
    Longint(pi)));
end;

function ListView_GetColumnOrderArray(hwndLV: HWND; iCount: Integer;
  pi: PInteger): BOOL;
begin
  Result := BOOL(SendMessage(hwndLV, LVM_GETCOLUMNORDERARRAY, iCount,
    Longint(pi)));
end;

function ListView_SetHotItem(hwndLV: HWND; i: Integer): Integer;
begin
  Result := SendMessage(hwndLV, LVM_SETHOTITEM, i, 0);
end;

function ListView_GetHotItem(hwndLV: HWND): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETHOTITEM, 0, 0);
end;

function ListView_SetHotCursor(hwndLV: HWND; hcur: HCURSOR): HCURSOR;
begin
  Result := SendMessage(hwndLV, LVM_SETHOTCURSOR, 0, hcur);
end;

function ListView_GetHotCursor(hwndLV: HWND): HCURSOR;
begin
  Result := SendMessage(hwndLV, LVM_GETHOTCURSOR, 0, 0);
end;

function ListView_ApproximateViewRect(hwndLV: HWND; iWidth, iHeight: Word;
  iCount: Integer): DWORD;
begin
  Result := SendMessage(hwndLV, LVM_APPROXIMATEVIEWRECT, iCount,
    MakeLParam(iWidth, iHeight));
end;

function ListView_SetWorkAreas(hwndLV: HWND; nWorkAreas: Integer; prc: PRect): BOOL;
begin
  Result := BOOL(SendMessage(hwndLV, LVM_SETWORKAREA, nWorkAreas, Longint(prc)));
end;

function ListView_GetSelectionMark(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETSELECTIONMARK, 0, 0);
end;

function ListView_SetSelectionMark(hwnd: HWND; i: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETSELECTIONMARK, 0, i);
end;

function ListView_GetWorkAreas(hwnd: HWND; nWorkAreas: Integer; prc: PRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETWORKAREAS, nWorkAreas, Integer(prc)));
end;

function ListView_SetHoverTime(hwndLV: HWND; dwHoverTimeMs: DWORD): DWORD;
begin
  Result := SendMessage(hwndLV, LVM_SETHOVERTIME, 0, dwHoverTimeMs);
end;

function ListView_GetHoverTime(hwndLV: HWND): Integer;
begin
  Result := SendMessage(hwndLV, LVM_GETHOVERTIME, 0, 0);
end;

function ListView_GetNumberOfWorkAreas(hwnd: HWND; pnWorkAreas: PInteger): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETNUMBEROFWORKAREAS, 0, Integer(pnWorkAreas));
end;

function ListView_SetToolTips(hwndLV: HWND; hwndNewHwnd: HWND): HWND;
begin
  Result := HWND(SendMessage(hwndLV, LVM_SETTOOLTIPS, WPARAM(hwndNewHwnd), 0));
end;

function ListView_GetToolTips(hwndLV: HWND): HWND;
begin
  Result := HWND(SendMessage(hwndLV, LVM_GETTOOLTIPS, 0, 0));
end;

function ListView_SetSelectedColumn(hwnd: HWND; iCol: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETSELECTEDCOLUMN, WPARAM(iCol), 0);
end;

function ListView_SetView(hwnd: HWND; iView: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETVIEW, WPARAM(DWORD(iView)), 0);
end;

function ListView_GetView(hwnd: HWND): Integer;
begin
  Result := DWORD(SendMessage(hwnd, LVM_GETVIEW, 0, 0));
end;

function ListView_InsertGroup(hwnd: HWND; index: Integer; const pgrp: TLVGroup): Integer;
begin
  Result := SendMessage(hwnd, LVM_INSERTGROUP, WPARAM(index), LPARAM(@pgrp));
end;

function ListView_SetGroupInfo(hwnd: HWND; iGroupId: Integer; const pgrp: TLVGroup): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETGROUPINFO, WPARAM(iGroupId), LPARAM(@pgrp));
end;

function ListView_GetGroupInfo(hwnd: HWND; iGroupId: Integer; var pgrp: TLVGroup): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETGROUPINFO, WPARAM(iGroupId), LPARAM(@pgrp));
end;

function ListView_RemoveGroup(hwnd: HWND; iGroupId: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_REMOVEGROUP, WPARAM(iGroupId), 0);
end;

function ListView_MoveGroup(hwnd: HWND; iGroupId, toIndex: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_MOVEGROUP, WPARAM(iGroupId), LPARAM(toIndex));
end;

function ListView_GetGroupCount(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETGROUPCOUNT, 0, 0);
end;

function ListView_GetGroupInfoByIndex(hwnd: HWND; iIndex: Integer; var pgrp: TLVGroup): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETGROUPINFOBYINDEX, WPARAM(iIndex), LPARAM(@pgrp));
end;

function ListView_MoveItemToGroup(hwnd: HWND; idItemFrom, idGroupTo: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_MOVEITEMTOGROUP, WPARAM(idItemFrom), LPARAM(idGroupTo));
end;

function ListView_GetGroupRect(hwnd: HWND; iGroupId, iType: Integer; var prc: TRect): Integer;
begin
  prc.Top := iType;
  Result := SendMessage(hwnd, LVM_GETGROUPRECT, WPARAM(iGroupId), LPARAM(@prc));
end;

function ListView_SetGroupMetrics(hwnd: HWND; const pGroupMetrics: TLVGroupMetrics): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETGROUPMETRICS, 0, LPARAM(@pGroupMetrics));
end;

function ListView_GetGroupMetrics(hwnd: HWND; var pGroupMetrics: TLVGroupMetrics): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETGROUPMETRICS, 0, LPARAM(@pGroupMetrics));
end;

function ListView_EnableGroupView(hwnd: HWND; fEnable: BOOL): Integer;
begin
  Result := SendMessage(hwnd, LVM_ENABLEGROUPVIEW, WPARAM(fEnable), 0);
end;

function ListView_SortGroups(hwnd: HWND; pfnGroupCompare: TFNLVGroupCompare; plv: Pointer): Integer;
begin
  Result := SendMessage(hwnd, LVM_SORTGROUPS, WPARAM(@pfnGroupCompare), LPARAM(plv));
end;

function ListView_InsertGroupSorted(hwnd: HWND; const structInsert: TLVInsertGroupSorted): Integer;
begin
  Result := SendMessage(hwnd, LVM_INSERTGROUPSORTED, WPARAM(@structInsert), 0);
end;

function ListView_RemoveAllGroups(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, LVM_REMOVEALLGROUPS, 0, 0);
end;

function ListView_HasGroup(hwnd: HWND; dwGroupId: Integer): Integer;
begin
  Result := SendMessage(hwnd, LVM_HASGROUP, dwGroupId, 0);
end;

function ListView_SetGroupState(hwnd: HWND; dwGroupId, dwMask, dwState: UINT): Integer;
var
 LGroup: TLVGroup;
begin
  LGroup.cbSize := SizeOf(LGroup);
  LGroup.mask := LVGF_STATE;
  LGroup.stateMask := dwMask;
  LGroup.state := dwState;
  Result := SendMessage(hwnd, LVM_SETGROUPINFO, WPARAM(dwGroupId), LPARAM(@LGroup));
end;

function ListView_GetGroupState(hwnd: HWND; dwGroupId, dwMask: UINT): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETGROUPSTATE, WPARAM(dwGroupId), LPARAM(dwMask));
end;

function ListView_GetFocusedGroup(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETFOCUSEDGROUP, 0, 0);
end;

function ListView_SetTileViewInfo(hwnd: HWND; const ptvi: TLVTileViewInfo): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETTILEVIEWINFO, 0, LPARAM(@ptvi));
end;

function ListView_GetTileViewInfo(hwnd: HWND; var ptvi: TLVTileViewInfo): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETTILEVIEWINFO, 0, LPARAM(@ptvi));
end;

function ListView_SetTileInfo(hwnd: HWND; const pti: TLVTileInfo): Integer;
begin
  Result := SendMessage(hwnd, LVM_SETTILEINFO, 0, LPARAM(@pti));
end;

function ListView_GetTileInfo(hwnd: HWND; var pti: TLVTileInfo): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETTILEINFO, 0, LPARAM(@pti));
end;

function ListView_SetInsertMark(hwnd: HWND; const lvim: TLVInsertMark): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_SETINSERTMARK, 0, LPARAM(@lvim)));
end;

function ListView_GetInsertMark(hwnd: HWND; var lvim: TLVInsertMark): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETINSERTMARK, 0, LPARAM(@lvim)));
end;

function ListView_InsertMarkHitTest(hwnd: HWND; const point: TPoint;
  const lvim: TLVInsertMark): Integer;
begin
  Result := SendMessage(hwnd, LVM_INSERTMARKHITTEST, WPARAM(@point), LPARAM(@lvim));
end;

function ListView_GetInsertMarkRect(hwnd: HWND; var rc: TRect): Integer;
begin
  Result := SendMessage(hwnd, LVM_GETINSERTMARKRECT, 0, LPARAM(@rc));
end;

function ListView_SetInsertMarkColor(hwnd: HWND; color: TColorRef): TColorRef;
begin
  Result := TColorRef(SendMessage(hwnd, LVM_SETINSERTMARKCOLOR, 0, LPARAM(color)));
end;

function ListView_GetInsertMarkColor(hwnd: HWND): TColorRef;
begin
  Result := TColorRef(SendMessage(hwnd, LVM_GETINSERTMARKCOLOR, 0, 0));
end;

function ListView_SetInfoTip(hwndLV: HWND; const plvInfoTip: TLVSetInfoTip): BOOL;
begin
  Result := BOOL(SendMessage(hwndLV, LVM_SETINFOTIP, 0, LPARAM(@plvInfoTip)));
end;

function ListView_GetSelectedColumn(hwnd: HWND): UINT;
begin
  Result := UINT(SendMessage(hwnd, LVM_GETSELECTEDCOLUMN, 0, 0));
end;

function ListView_IsGroupViewEnabled(hwnd: HWND): BOOL;
begin
Result := BOOL(SendMessage(hwnd, LVM_ISGROUPVIEWENABLED, 0, 0));
end;

function ListView_GetOutlineColor(hwnd: HWND): TColorRef;
begin
  Result := TColorRef(SendMessage(hwnd, LVM_GETOUTLINECOLOR, 0, 0));
end;

function ListView_SetOutlineColor(hwnd: HWND; color: TColorRef): TColorRef;
begin
  Result := TColorRef(SendMessage(hwnd, LVM_SETOUTLINECOLOR, 0, LPARAM(color)));
end;

function ListView_CancelEditLabel(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, LVM_CANCELEDITLABEL, 0, 0);
end;

function ListView_MapIndexToID(hwnd: HWND; index: UINT): UINT;
begin
  Result := UINT(SendMessage(hwnd, LVM_MAPINDEXTOID, WPARAM(index), 0));
end;

function ListView_MapIDToIndex(hwnd: HWND; id: UINT): UINT;
begin
  Result := UINT(SendMessage(hwnd, LVM_MAPIDTOINDEX, WPARAM(id), 0));
end;

function ListView_IsItemVisible(hwnd: HWND; index: UINT): UINT;
begin
  Result := UINT(SendMessage(hwnd, LVM_ISITEMVISIBLE, WPARAM(index), 0));
end;

function ListView_SetGroupHeaderImageList(hwnd: HWND; himl: HIMAGELIST): HIMAGELIST;
begin
  Result := HIMAGELIST(SendMessage(hwnd, LVM_SETIMAGELIST, LVSIL_GROUPHEADER, LPARAM(himl)));
end;

function ListView_GetGroupHeaderImageList(hwnd: HWND): HIMAGELIST;
begin
  Result := HIMAGELIST(SendMessage(hwnd, LVM_GETIMAGELIST, LVSIL_GROUPHEADER, 0));
end;

function ListView_GetEmptyText(hwnd: HWND; pszText: LPWSTR; cchText: UINT): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETEMPTYTEXT, WPARAM(cchText), LPARAM(pszText)));
end;

function ListView_GetFooterRect(hwnd: HWND; var prc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETFOOTERRECT, 0, LPARAM(@prc)));
end;

function ListView_GetFooterInfo(hwnd: HWND; var plvfi: TLVFooterInfo): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETFOOTERINFO, 0, LPARAM(@plvfi)));
end;

function ListView_GetFooterItemRect(hwnd: HWND; iItem: UINT; var prc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETFOOTERITEMRECT, iItem, LPARAM(@prc)));
end;

function ListView_GetFooterItem(hwnd: HWND; iItem: UINT; var pfi: TLVFooterItem): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETFOOTERITEM, iItem, LPARAM(@pfi)));
end;

function ListView_GetItemIndexRect(hwnd: HWND; const plvii: TLVItemIndex;
  iSubItem, code: Integer; var prc: TRect): BOOL;
begin
  prc.Top := iSubItem;
  prc.Left := Code;
  Result := BOOL(SendMessage(hwnd, LVM_GETITEMINDEXRECT, WPARAM(@plvii), LPARAM(@prc)));
end;

function ListView_SetItemIndexState(hwnd: HWND; const plvii: TLVItemIndex;
  data, mask: UINT): HRESULT;
var
  LItem: TLVItem;
begin
  LItem.stateMask := mask;
  LItem.state := data;
  Result := HRESULT(SendMessage(hwnd, LVM_SETITEMSTATE, WPARAM(@plvii), LPARAM(@LItem)));
end;

function ListView_GetNextItemIndex(hwnd: HWND; var plvii: TLVItemIndex;
  flags: LPARAM): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETNEXTITEMINDEX, WPARAM(@plvii),
    MakeLParam(flags, 0)));
end;

function ListView_SetBkImage(hwnd: HWND; plvbki: PLVBKImage): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_SETBKIMAGE, 0, LPARAM(plvbki)));
end;
function ListView_SetBkImageA(hwnd: HWND; plvbki: PLVBKImageA): BOOL;
begin
  Result := BOOL(SendMessageA(hwnd, LVM_SETBKIMAGEA, 0, LPARAM(plvbki)));
end;
function ListView_SetBkImageW(hwnd: HWND; plvbki: PLVBKImageW): BOOL;
begin
  Result := BOOL(SendMessageW(hwnd, LVM_SETBKIMAGEW, 0, LPARAM(plvbki)));
end;

function ListView_GetBkImage(hwnd: HWND; plvbki: PLVBKImage): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, LVM_GETBKIMAGE, 0, LPARAM(plvbki)));
end;
function ListView_GetBkImageA(hwnd: HWND; plvbki: PLVBKImageA): BOOL;
begin
  Result := BOOL(SendMessageA(hwnd, LVM_GETBKIMAGEA, 0, LPARAM(plvbki)));
end;
function ListView_GetBkImageW(hwnd: HWND; plvbki: PLVBKImageW): BOOL;
begin
  Result := BOOL(SendMessageW(hwnd, LVM_GETBKIMAGEW, 0, LPARAM(plvbki)));
end;

{ Tree View }

function TreeView_InsertItem(hwnd: HWND; const lpis: TTVInsertStruct): HTreeItem;
begin
  Result := HTreeItem( SendMessage(hwnd, TVM_INSERTITEM, 0, Longint(@lpis)) );
end;
function TreeView_InsertItemA(hwnd: HWND; const lpis: TTVInsertStructA): HTreeItem;
begin
  Result := HTreeItem( SendMessageA(hwnd, TVM_INSERTITEMA, 0, Longint(@lpis)) );
end;
function TreeView_InsertItemW(hwnd: HWND; const lpis: TTVInsertStructW): HTreeItem;
begin
  Result := HTreeItem( SendMessageW(hwnd, TVM_INSERTITEMW, 0, Longint(@lpis)) );
end;

function TreeView_DeleteItem(hwnd: HWND; hitem: HTreeItem): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_DELETEITEM, 0, Longint(hitem)) );
end;

function TreeView_DeleteAllItems(hwnd: HWND): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_DELETEITEM, 0, Longint(TVI_ROOT)) );
end;

function TreeView_Expand(hwnd: HWND; hitem: HTreeItem; code: Integer): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_EXPAND, code, Longint(hitem)) );
end;

function TreeView_GetItemRect(hwnd: HWND; hitem: HTreeItem;
  var prc: TRect; code: Bool): Bool;
begin
  HTreeItem(Pointer(@prc)^) := hitem;
  Result := Bool( SendMessage(hwnd, TVM_GETITEMRECT, Integer(code), Longint(@prc)) );
end;

function TreeView_GetCount(hwnd: HWND): UINT;
begin
  Result := SendMessage(hwnd, TVM_GETCOUNT, 0, 0);
end;

function TreeView_GetIndent(hwnd: HWND): UINT;
begin
  Result := SendMessage(hwnd, TVM_GETINDENT, 0, 0);
end;

function TreeView_SetIndent(hwnd: HWND; indent: Integer): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_SETINDENT, indent, 0) );
end;

function TreeView_GetImageList(hwnd: HWND; iImage: Integer): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hwnd, TVM_GETIMAGELIST, iImage, 0) );
end;

function TreeView_SetImageList(hwnd: HWND; himl: HIMAGELIST;
  iImage: Integer): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hwnd, TVM_SETIMAGELIST, iImage,
    Longint(himl)) );
end;

function TreeView_GetNextItem(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem;
begin
  Result := HTreeItem( SendMessage(hwnd, TVM_GETNEXTITEM, code,
    Longint(hitem)) );
end;

function TreeView_GetChild(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_CHILD);
end;

function TreeView_GetNextSibling(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_NEXT);
end;

function TreeView_GetPrevSibling(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_PREVIOUS);
end;

function TreeView_GetParent(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_PARENT);
end;

function TreeView_GetFirstVisible(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil,  TVGN_FIRSTVISIBLE);
end;

function TreeView_GetNextVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_NEXTVISIBLE);
end;

function TreeView_GetPrevVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_PREVIOUSVISIBLE);
end;

function TreeView_GetSelection(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil, TVGN_CARET);
end;

function TreeView_GetDropHilite(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil, TVGN_DROPHILITE);
end;

function TreeView_GetRoot(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil, TVGN_ROOT);
end;

function TreeView_GetLastVisible(hwnd: HWND): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, nil,  TVGN_LASTVISIBLE);
end;

function TreeView_GetNextSelected(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_GetNextItem(hwnd, hitem, TVGN_NEXTSELECTED);
end;

function TreeView_Select(hwnd: HWND; hitem: HTreeItem;
  code: Integer): HTreeItem;
begin
  Result := HTreeItem( SendMessage(hwnd, TVM_SELECTITEM, code,
    Longint(hitem)) );
end;

function TreeView_SelectItem(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_Select(hwnd, hitem, TVGN_CARET);
end;

function TreeView_SelectDropTarget(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_Select(hwnd, hitem, TVGN_DROPHILITE);
end;

function TreeView_SelectSetFirstVisible(hwnd: HWND; hitem: HTreeItem): HTreeItem;
begin
  Result := TreeView_Select(hwnd, hitem, TVGN_FIRSTVISIBLE);
end;

function TreeView_GetItem(hwnd: HWND; var pitem: TTVItem): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_GETITEM, 0, Longint(@pitem)) );
end;
function TreeView_GetItemA(hwnd: HWND; var pitem: TTVItemA): Bool;
begin
  Result := Bool( SendMessageA(hwnd, TVM_GETITEMA, 0, Longint(@pitem)) );
end;
function TreeView_GetItemW(hwnd: HWND; var pitem: TTVItemW): Bool;
begin
  Result := Bool( SendMessageW(hwnd, TVM_GETITEMW, 0, Longint(@pitem)) );
end;

function TreeView_SetItem(hwnd: HWND; const pitem: TTVItem): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_SETITEM, 0, Longint(@pitem)) );
end;

function TreeView_SetItem(hwnd: HWND; const pitem: TTVItemEx): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_SETITEM, 0, Longint(@pitem)) );
end;
function TreeView_SetItemA(hwnd: HWND; const pitem: TTVItemA): Bool;
begin
  Result := Bool( SendMessageA(hwnd, TVM_SETITEMA, 0, Longint(@pitem)) );
end;

function TreeView_SetItemA(hwnd: HWND; const pitem: TTVItemExA): Bool;
begin
  Result := Bool( SendMessageA(hwnd, TVM_SETITEMA, 0, Longint(@pitem)) );
end;
function TreeView_SetItemW(hwnd: HWND; const pitem: TTVItemW): Bool;
begin
  Result := Bool( SendMessageW(hwnd, TVM_SETITEMW, 0, Longint(@pitem)) );
end;

function TreeView_SetItemW(hwnd: HWND; const pitem: TTVItemExW): Bool;
begin
  Result := Bool( SendMessageW(hwnd, TVM_SETITEMW, 0, Longint(@pitem)) );
end;

function TreeView_EditLabel(hwnd: HWND; hitem: HTreeItem): HWND;
begin
  Result := Windows.HWND( SendMessage(hwnd, TVM_EDITLABEL, 0, Longint(hitem)) );
end;
function TreeView_EditLabelA(hwnd: HWND; hitem: HTreeItem): HWND;
begin
  Result := Windows.HWND( SendMessageA(hwnd, TVM_EDITLABELA, 0, Longint(hitem)) );
end;
function TreeView_EditLabelW(hwnd: HWND; hitem: HTreeItem): HWND;
begin
  Result := Windows.HWND( SendMessageW(hwnd, TVM_EDITLABELW, 0, Longint(hitem)) );
end;

function TreeView_GetEditControl(hwnd: HWND): HWND;
begin
  Result := Windows.HWND( SendMessage(hwnd, TVM_GETEDITCONTROL, 0, 0) );
end;

function TreeView_GetVisibleCount(hwnd: HWND): UINT;
begin
  Result := SendMessage(hwnd, TVM_GETVISIBLECOUNT, 0, 0);
end;

function TreeView_HitTest(hwnd: HWND; var lpht: TTVHitTestInfo): HTreeItem;
begin
  Result := HTreeItem( SendMessage(hwnd, TVM_HITTEST, 0, Longint(@lpht)) );
end;

function TreeView_CreateDragImage(hwnd: HWND; hitem: HTreeItem): HIMAGELIST;
begin
  Result := HIMAGELIST( SendMessage(hwnd, TVM_CREATEDRAGIMAGE, 0,
    Longint(hitem)) );
end;

function TreeView_SortChildren(hwnd: HWND; hitem: HTreeItem;
  recurse: Integer): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_SORTCHILDREN, recurse,
    Longint(hitem)) );
end;

function TreeView_EnsureVisible(hwnd: HWND; hitem: HTreeItem): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_ENSUREVISIBLE, 0, Longint(hitem)) );
end;

function TreeView_SortChildrenCB(hwnd: HWND; const psort: TTVSortCB;
  recurse: Integer): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_SORTCHILDRENCB, recurse,
    Longint(@psort)) );
end;

function TreeView_EndEditLabelNow(hwnd: HWND; fCancel: Bool): Bool;
begin
  Result := Bool( SendMessage(hwnd, TVM_ENDEDITLABELNOW, Integer(fCancel),
    0) );
end;

function TreeView_GetISearchString(hwndTV: HWND; lpsz: PWideChar): Bool;
begin
  Result := Bool( SendMessage(hwndTV, TVM_GETISEARCHSTRING, 0,
    Longint(lpsz)) );
end;
function TreeView_GetISearchStringA(hwndTV: HWND; lpsz: PAnsiChar): Bool;
begin
  Result := Bool( SendMessageA(hwndTV, TVM_GETISEARCHSTRINGA, 0,
    Longint(lpsz)) );
end;
function TreeView_GetISearchStringW(hwndTV: HWND; lpsz: PWideChar): Bool;
begin
  Result := Bool( SendMessageW(hwndTV, TVM_GETISEARCHSTRINGW, 0,
    Longint(lpsz)) );
end;

function TreeView_SetToolTips(wnd: HWND; hwndTT: HWND): HWND;
begin
  Result := HWND(SendMessage(wnd, TVM_SETTOOLTIPS, WPARAM(hwndTT), 0));
end;

function TreeView_GetToolTips(wnd: HWND): HWND;
begin
  Result := HWND(SendMessage(wnd, TVM_GETTOOLTIPS, 0, 0));
end;

function TreeView_SetInsertMark(hwnd: HWND; hItem: Integer; fAfter: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TVM_SETINSERTMARK, WPARAM(fAfter), LPARAM(hItem)));
end;

function TreeView_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TVM_SETUNICODEFORMAT, WPARAM(fUnicode), 0));
end;

function TreeView_GetUnicodeFormat(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TVM_GETUNICODEFORMAT, 0, 0));
end;

function TreeView_SetItemHeight(hwnd: HWND; iHeight: Integer): Integer;
begin
  Result := SendMessage(hwnd, TVM_SETITEMHEIGHT, iHeight, 0);
end;

function TreeView_GetItemHeight(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, TVM_GETITEMHEIGHT, 0, 0);
end;

function TreeView_SetBkColor(hwnd: HWND; clr: COLORREF): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_SETBKCOLOR, 0, LPARAM(clr)));
end;

function TreeView_SetTextColor(hwnd: HWND; clr: COLORREF): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_SETTEXTCOLOR, 0, LPARAM(clr)));
end;

function TreeView_GetBkColor(hwnd: HWND): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_GETBKCOLOR, 0, 0));
end;

function TreeView_GetTextColor(hwnd: HWND): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_GETTEXTCOLOR, 0, 0));
end;

function TreeView_SetScrollTime(hwnd: HWND; uTime: UINT): UINT;
begin
  Result := SendMessage(hwnd, TVM_SETSCROLLTIME, uTime, 0);
end;

function TreeView_GetScrollTime(hwnd: HWND): UINT;
begin
  Result := SendMessage(hwnd, TVM_GETSCROLLTIME, 0, 0);
end;

function TreeView_SetInsertMarkColor(hwnd: HWND; clr: COLORREF): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_SETINSERTMARKCOLOR, 0, LPARAM(clr)));
end;

function TreeView_GetInsertMarkColor(hwnd: HWND): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, TVM_GETINSERTMARKCOLOR, 0, 0));
end;

function TreeView_SetItemState(hwndTV: HWND; hti: HTreeItem; State, Mask: UINT): UINT;
var
  LItem: TTVItem;
begin
  LItem.mask := TVIF_STATE;
  LItem.hItem := hti;
  LItem.stateMask := Mask;
  LItem.state := State;
  Result := SendMessage(hwndTV, TVM_SETITEM, 0, LPARAM(@LItem));
end;

function TreeView_SetCheckState(hwndTV: HWND; hti: HTreeItem; fCheck: BOOL): UINT;
var
  LState: UINT;
begin
  if IndexToStateImageMask(Integer(fCheck)) = 0 then
    LState := 1
  else
    LState := 2;
  Result := TreeView_SetItemState(hwndTV, hti, LState, TVIS_STATEIMAGEMASK);
end;

function TreeView_GetItemState(hwndTV: HWND; hti: HTreeItem; mask: UINT): UINT;
begin
  Result := UINT(SendMessage(hwndTV, TVM_GETITEMSTATE, WPARAM(hti), LPARAM(mask)));
end;

function TreeView_GetCheckState(hwndTV: HWND; hti: HTreeItem): UINT;
begin
  Result := (UINT(SendMessage(hwndTV, TVM_GETITEMSTATE, WPARAM(hti), TVIS_STATEIMAGEMASK)) shr 12) - 1; 
end;

function TreeView_SetLineColor(hwnd: HWND; clr: TColorRef): TColorRef;
begin
  Result := TColorRef(SendMessage(hwnd, TVM_SETLINECOLOR, 0, LPARAM(clr)));
end;

function TreeView_GetLineColor(hwnd: HWND): Integer;
begin
  Result := TColorRef(SendMessage(hwnd, TVM_GETLINECOLOR, 0, 0));
end;

function TreeView_MapAccIDToHTREEITEM(hwnd: HWND; id: UINT): HTreeItem;
begin
  Result := HTreeItem(SendMessage(hwnd, TVM_MAPACCIDTOHTREEITEM, id, 0));
end;

function TreeView_MapHTREEITEMToAccID(hwnd: HWND; hti: HTreeItem): UINT;
begin
  Result := UINT(SendMessage(hwnd, TVM_MAPHTREEITEMTOACCID, WPARAM(hti), 0));
end;

function TreeView_SetExtendedStyle(hwnd: HWND; dw: DWORD; mask: UINT): UINT;
begin
  Result := DWORD(SendMessage(hwnd, TVM_SETEXTENDEDSTYLE, mask, dw));
end;

function TreeView_GetExtendedStyle(hwnd: HWND): DWORD;
begin
  Result := DWORD(SendMessage(hwnd, TVM_GETEXTENDEDSTYLE, 0, 0));
end;

function TreeView_SetAutoScrollInfo(hwnd: HWND; uPixPerSec, uUpdateTime: UINT): LRESULT;
begin
  Result := SendMessage(hwnd, TVM_SETAUTOSCROLLINFO, WPARAM(uPixPerSec), LPARAM(uUpdateTime));
end;

function TreeView_GetSelectedCount(hwnd: HWND): DWORD;
begin
  Result := DWORD(SendMessage(hwnd, TVM_GETSELECTEDCOUNT, 0, 0));
end;

function TreeView_ShowInfoTip(hwnd: HWND; hti: HTreeItem): DWORD;
begin
  Result := DWORD(SendMessage(hwnd, TVM_SHOWINFOTIP, 0, LPARAM(hti)));
end;

function TreeView_GetItemPartRect(hwnd: HWND; hitem: HTreeItem; var prc: TRect;
  partid: TTVItemPart): BOOL;
var
  Info: TTVGetItemPartRectInfo;
begin
  Info.hti := hitem;
  Info.prc := @prc;
  Info.partID := partid;
  Result := BOOL(SendMessage(hwnd, TVM_GETITEMPARTRECT, 0, LPARAM(@Info)));
end;


{ Tab control }

function TabCtrl_HitTest(hwndTC: HWND; pinfo: PTCHitTestInfo): Integer;
begin
  Result := SendMessage(hwndTC, TCM_HITTEST, 0, LPARAM(pinfo));
end;

function TabCtrl_HitTest(hwndTC: HWND; const pinfo: TTCHitTestInfo): Integer;
begin
  Result := SendMessage(hwndTC, TCM_HITTEST, 0, LPARAM(@pinfo));
end;

function TabCtrl_SetItemExtra(hwndTC: HWND; cb: Integer): BOOL;
begin
  Result := BOOL(SendMessage(hwndTC, TCM_SETITEMEXTRA, cb, 0));
end;

function TabCtrl_AdjustRect(hwnd: HWND; bLarger: BOOL; prc: PRect): Integer;
begin
  Result := SendMessage(hwnd, TCM_ADJUSTRECT, WPARAM(bLarger), LPARAM(prc));
end;

function TabCtrl_SetItemSize(hwnd: HWND; x, y: Integer): DWORD;
begin
  Result := SendMessage(hwnd, TCM_SETITEMSIZE, 0, MAKELPARAM(x, y));
end;

procedure TabCtrl_RemoveImage(hwnd: HWND; i: Integer);
begin
  SendMessage(hwnd, TCM_REMOVEIMAGE, i, 0);
end;

procedure TabCtrl_SetPadding(hwnd: HWND; cx, cy: Integer);
begin
  SendMessage(hwnd, TCM_SETPADDING, 0, MAKELPARAM(cx, cy));
end;

function TabCtrl_GetRowCount(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, TCM_GETROWCOUNT, 0, 0);
end;

function TabCtrl_GetToolTips(wnd: HWND): HWND;
begin
  Result := HWND(SendMessage(wnd, TCM_GETTOOLTIPS, 0, 0));
end;

procedure TabCtrl_SetToolTips(hwnd: HWND; hwndTT: HWND);
begin
  SendMessage(hwnd, TCM_SETTOOLTIPS, WPARAM(hwndTT), 0);
end;

function TabCtrl_GetCurFocus(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, TCM_GETCURFOCUS, 0, 0);
end;

procedure TabCtrl_SetCurFocus(hwnd: HWND; i: Integer);
begin
  SendMessage(hwnd,TCM_SETCURFOCUS, i, 0);
end;

function TabCtrl_SetMinTabWidth(hwnd: HWND; x: Integer): Integer;
begin
  Result := SendMessage(hwnd, TCM_SETMINTABWIDTH, 0, x);
end;

procedure TabCtrl_DeselectAll(hwnd: HWND; fExcludeFocus: BOOL);
begin
  SendMessage(hwnd, TCM_DESELECTALL, WPARAM(fExcludeFocus), 0)
end;

function TabCtrl_HighlightItem(hwnd: HWND; i: Integer; fHighlight: WordBool): BOOL;
begin
  Result :=  BOOL(SendMessage(hwnd, TCM_HIGHLIGHTITEM, i, MAKELONG(Word(fHighlight), 0)));
end;

function TabCtrl_SetExtendedStyle(hwnd: HWND; dw: DWORD): DWORD;
begin
  Result := SendMessage(hwnd, TCM_SETEXTENDEDSTYLE, 0, dw);
end;

function TabCtrl_GetExtendedStyle(hwnd: HWND): DWORD;
begin
  Result := SendMessage(hwnd, TCM_GETEXTENDEDSTYLE, 0, 0);
end;

function TabCtrl_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TCM_SETUNICODEFORMAT, WPARAM(fUnicode), 0));
end;

function TabCtrl_GetUnicodeFormat(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TCM_GETUNICODEFORMAT, 0, 0));
end;

function TabCtrl_GetItemRect(hwnd: HWND; i: Integer; var prc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, TCM_GETITEMRECT, i, LPARAM(@prc)));
end;

{ Animate control }

function Animate_Create(hwndP: HWND; id: HMENU; dwStyle: DWORD; hInstance: HINST): HWND;
begin
  Result := CreateWindow(ANIMATE_CLASS, nil, dwStyle, 0, 0, 0, 0, hwndP, id,
    hInstance, nil);
end;

function Animate_Open(hwnd: HWND; szName: PChar): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, ACM_OPENA, 0, LPARAM(szName)));
end;

function Animate_OpenEx(hwnd: HWND; hInst: HINST; szName: PChar): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, ACM_OPENA, WPARAM(hInst), LPARAM(szName)));
end;

function Animate_Play(hwnd: HWND; from, _to: Word; rep: UINT): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, ACM_PLAY, rep, MAKELONG(from, _to)));
end;

function Animate_Stop(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, ACM_STOP, 0, 0));
end;

function Animate_Close(hwnd: HWND): BOOL;
begin
  Result := Animate_Open(hwnd, nil);
end;

function Animate_Seek(hwnd: HWND; frame: Word): BOOL;
begin
  Result := Animate_Play(hwnd, frame, frame, 1);
end;

{ MonthCal control }

function MonthCal_GetCurSel(hmc: HWND; var pst: TSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_GETCURSEL, 0, Longint(@pst)));
end;

function MonthCal_SetCurSel(hmc: HWND; const pst: TSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETCURSEL, 0, Longint(@pst)));
end;

function MonthCal_GetMaxSelCount(hmc: HWND): DWORD;
begin
  Result := SendMessage(hmc, MCM_GETMAXSELCOUNT, 0, 0);
end;

function MonthCal_SetMaxSelCount(hmc: HWND; n: UINT): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETMAXSELCOUNT, n, 0));
end;

function MonthCal_GetSelRange(hmc: HWND; rgst: PSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_GETSELRANGE, 0, Longint(rgst)));
end;

function MonthCal_SetSelRange(hmc: HWND; rgst: PSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETSELRANGE, 0, Longint(rgst)));
end;

function MonthCal_GetMonthRange(hmc: HWND; gmr: DWORD; rgst: PSystemTime): DWORD;
begin
  Result := SendMessage(hmc, MCM_GETMONTHRANGE, gmr, Longint(rgst));
end;

function MonthCal_SetDayState(hmc: HWND; cbds: Integer; const rgds: TNMDayState): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETDAYSTATE, cbds, Longint(@rgds)));
end;

function MonthCal_GetMinReqRect(hmc: HWND; var prc: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_GETMINREQRECT, 0, Longint(@prc)));
end;

function MonthCal_SetToday(hmc: HWND; const pst: TSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETTODAY, 0, Longint(@pst)));
end;

function MonthCal_GetToday(hmc: HWND; var pst: TSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_GETTODAY, 0, Longint(@pst)));
end;

function MonthCal_HitTest(hmc: HWND; var info: TMCHitTestInfo): DWORD;
begin
  Result := SendMessage(hmc, MCM_HITTEST, 0, Longint(@info));
end;

function MonthCal_SetColor(hmc: HWND; iColor: Integer; clr: TColorRef): TColorRef;
begin
  Result := TColorRef(SendMessage(hmc, MCM_SETCOLOR, iColor, clr));
end;

function MonthCal_GetColor(hmc: HWND; iColor: Integer): TColorRef;
begin
  Result := TColorRef(SendMessage(hmc, MCM_SETCOLOR, iColor, 0));
end;

function MonthCal_SetFirstDayOfWeek(hmc: HWND; iDay: Integer): Integer;
begin
  Result := SendMessage(hmc, MCM_SETFIRSTDAYOFWEEK, 0, iDay);
end;

function MonthCal_GetFirstDayOfWeek(hmc: HWND): Integer;
begin
  Result := SendMessage(hmc, MCM_GETFIRSTDAYOFWEEK, 0, 0);
end;

function MonthCal_GetRange(hmc: HWND; rgst: PSystemTime): DWORD;
begin
  Result := SendMessage(hmc, MCM_GETRANGE, 0, Longint(rgst));
end;

function Monthcal_SetRange(hmc: HWND; gdtr: DWORD; rgst: PSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hmc, MCM_SETRANGE, gdtr, Longint(rgst)));
end;

function MonthCal_GetMonthDelta(hmc: HWND): Integer;
begin
  Result := SendMessage(hmc, MCM_GETMONTHDELTA, 0, 0);
end;

function MonthCal_SetMonthDelta(hmc: HWND; n: Integer): Integer;
begin
  Result := SendMessage(hmc, MCM_SETMONTHDELTA, n, 0);
end;

function MonthCal_GetMaxTodayWidth(hmc: HWND): DWORD;
begin
  Result := SendMessage(hmc, MCM_GETMAXTODAYWIDTH, 0, 0);
end;

function MonthCal_SetUnicodeFormat(hwnd: HWND; fUnicode: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, MCM_SETUNICODEFORMAT, WPARAM(fUnicode), 0));
end;

function MonthCal_GetUnicodeFormat(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, MCM_GETUNICODEFORMAT, 0, 0));
end;

{ Date/Time Picker }

function DateTime_GetSystemTime(hdp: HWND; var pst: TSystemTime): DWORD;
begin
  Result := SendMessage(hdp, DTM_GETSYSTEMTIME, 0, Longint(@pst));
end;

function DateTime_SetSystemTime(hdp: HWND; gd: DWORD; const pst: TSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hdp, DTM_SETSYSTEMTIME, gd, Longint(@pst)));
end;

function DateTime_GetRange(hdp: HWND; rgst: PSystemTime): DWORD;
begin
  Result := SendMessage(hdp, DTM_GETRANGE, 0, Longint(rgst));
end;

function DateTime_SetRange(hdp: HWND; gdtr: DWORD; rgst: PSystemTime): BOOL;
begin
  Result := BOOL(SendMessage(hdp, DTM_SETRANGE, gdtr, Longint(rgst)));
end;

function DateTime_SetFormat(hdp: HWND; sz: PWideChar): BOOL;
begin
  Result := BOOL(SendMessage(hdp, DTM_SETFORMAT, 0, Longint(sz)));
end;
function DateTime_SetFormatA(hdp: HWND; sz: PAnsiChar): BOOL;
begin
  Result := BOOL(SendMessageA(hdp, DTM_SETFORMATA, 0, Longint(sz)));
end;
function DateTime_SetFormatW(hdp: HWND; sz: PWideChar): BOOL;
begin
  Result := BOOL(SendMessageW(hdp, DTM_SETFORMATW, 0, Longint(sz)));
end;

function DateTime_SetFormat(hdp: HWND; const sz: UnicodeString): BOOL;
begin
  Result := BOOL(SendMessage(hdp, DTM_SETFORMAT, 0, LPARAM(PWideChar(sz))));
end;
function DateTime_SetFormatA(hdp: HWND; const sz: AnsiString): BOOL;
begin
  Result := BOOL(SendMessageA(hdp, DTM_SETFORMATA, 0, LPARAM(PAnsiChar(sz))));
end;
function DateTime_SetFormatW(hdp: HWND; const sz: UnicodeString): BOOL;
begin
  Result := BOOL(SendMessageW(hdp, DTM_SETFORMATW, 0, LPARAM(PWideChar(sz))));
end;

function DateTime_SetMonthCalColor(hdp: HWND; iColor: DWORD; clr: TColorRef): TColorRef;
begin
  Result := TColorRef(SendMessage(hdp, DTM_SETMCCOLOR, iColor, clr));
end;

function DateTime_GetMonthCalColor(hdp: HWND; iColor: DWORD): TColorRef;
begin
  Result := SendMessage(hdp, DTM_GETMCCOLOR, iColor, 0);
end;

function DateTime_GetMonthCal(hdp: HWND): HWND;
begin
  Result := SendMessage(hdp, DTM_GETMONTHCAL, 0, 0);
end;

procedure DateTime_SetMonthCalFont(hdp: HWND; hfont: HFONT; fRedraw: BOOL);
begin
  SendMessage(hdp, DTM_SETMCFONT, WPARAM(hfont), LPARAM(fRedraw));
end;

function DateTime_GetMonthCalFont(hdp: HWND): HFONT;
begin
  Result := HFONT(SendMessage(hdp, DTM_GETMCFONT, 0, 0));
end;

{ IP Address edit control }

function MAKEIPRANGE(low, high: Byte): LPARAM;
begin
  Result := high;
  Result := (Result shl 8) + low;
end;

function MAKEIPADDRESS(b1, b2, b3, b4: DWORD): LPARAM;
begin
  Result := (b1 shl 24) + (b2 shl 16) + (b3 shl 8) + b4;
end;

function FIRST_IPADDRESS(x: DWORD): DWORD;
begin
  Result := (x shr 24) and $FF;
end;

function SECOND_IPADDRESS(x: DWORD): DWORD;
begin
  Result := (x shr 16) and $FF;
end;

function THIRD_IPADDRESS(x: DWORD): DWORD;
begin
  Result := (x shr 8) and $FF;
end;

function FOURTH_IPADDRESS(x: DWORD): DWORD;
begin
  Result := x and $FF;
end;

{ Pager control }

procedure Pager_SetChild(hwnd: HWND; hwndChild: HWND);
begin
  SendMessage(hwnd, PGM_SETCHILD, 0, LPARAM(hwndChild));
end;

procedure Pager_RecalcSize(hwnd: HWND);
begin
  SendMessage(hwnd, PGM_RECALCSIZE, 0, 0);
end;

procedure Pager_ForwardMouse(hwnd: HWND; bForward: BOOL);
begin
  SendMessage(hwnd, PGM_FORWARDMOUSE, WPARAM(bForward), 0);
end;

function Pager_SetBkColor(hwnd: HWND; clr: COLORREF): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, PGM_SETBKCOLOR, 0, LPARAM(clr)));
end;

function Pager_GetBkColor(hwnd: HWND): COLORREF;
begin
  Result := COLORREF(SendMessage(hwnd, PGM_GETBKCOLOR, 0, 0));
end;

function Pager_SetBorder(hwnd: HWND; iBorder: Integer): Integer;
begin
  Result := SendMessage(hwnd, PGM_SETBORDER, 0, iBorder);
end;

function Pager_GetBorder(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, PGM_GETBORDER, 0, 0);
end;

function Pager_SetPos(hwnd: HWND; iPos: Integer): Integer;
begin
  Result := SendMessage(hwnd, PGM_SETPOS, 0, iPos);
end;

function Pager_GetPos(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, PGM_GETPOS, 0, 0);
end;

function Pager_SetButtonSize(hwnd: HWND; iSize: Integer): Integer;
begin
  Result := SendMessage(hwnd, PGM_SETBUTTONSIZE, 0, iSize);
end;

function Pager_GetButtonSize(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, PGM_GETBUTTONSIZE, 0,0);
end;

function Pager_GetButtonState(hwnd: HWND; iButton: Integer): DWORD;
begin
  Result := SendMessage(hwnd, PGM_GETBUTTONSTATE, 0, iButton);
end;

procedure Pager_GetDropTarget(hwnd: HWND; ppdt: Pointer{!!});
begin
  SendMessage(hwnd, PGM_GETDROPTARGET, 0, LPARAM(ppdt));
end;

{ Button Control Functions }

function Button_GetIdealSize(hwnd: HWND; var psize: TSize): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_GETIDEALSIZE, 0, LPARAM(@psize)));
end;

function Button_SetImageList(hwnd: HWND; const pbuttonImagelist: TButtonImagelist): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETIMAGELIST, 0, LPARAM(@pbuttonImagelist)));
end;

function Button_GetImageList(hwnd: HWND; var pbuttonImagelist: TButtonImageList): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_GETIMAGELIST, 0, LPARAM(@pbuttonImagelist)));
end;

function Button_SetTextMargin(hwnd: HWND; const pmargin: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETTEXTMARGIN, 0, LPARAM(@pmargin)));
end;

function Button_GetTextMargin(hwnd: HWND; var pmargin: TRect): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_GETTEXTMARGIN, 0, LPARAM(@pmargin)));
end;

function Button_SetDropDownState(hwnd: HWND; fDropDown: BOOL): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETDROPDOWNSTATE, WPARAM(fDropDown), 0));
end;

function Button_SetSplitInfo(hwnd: HWND; const pInfo: TButtonSplitinfo): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETSPLITINFO, 0, LPARAM(@pInfo)));
end;

function Button_GetSplitInfo(hwnd: HWND; var pInfo: TButtonSplitinfo): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_GETSPLITINFO, 0, LPARAM(@pInfo)));
end;

function Button_SetNote(hwnd: HWND; psz: LPCWSTR): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETNOTE, 0, LPARAM(psz)));
end;

function Button_SetNote(hwnd: HWND; const psz: UnicodeString): BOOL; overload;
begin
  Result := BOOL(SendMessage(hwnd, BCM_SETNOTE, 0, LPARAM(PWideChar(psz))));
end;

function Button_GetNote(hwnd: HWND; psz: LPCWSTR; var pcc: Integer): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, BCM_GETNOTE, WPARAM(@pcc), LPARAM(psz)));
end;

function Button_GetNoteLength(hwnd: HWND): LRESULT;
begin
  Result := SendMessage(hwnd, BCM_GETNOTELENGTH, 0, 0);
end;

function Button_SetElevationRequiredState(hwnd: HWND; fRequired: BOOL): LRESULT;
begin
  Result := SendMessage(hwnd, BCM_SETSHIELD, 0, LPARAM(fRequired));
end;

{ Edit Control Functions }

function Edit_SetCueBannerText(hwnd: HWND; lpwText: LPCWSTR): BOOL; {inline;}
begin
  Result := BOOL(SendMessage(hwnd, EM_SETCUEBANNER, 0, lParam(lpwText)));
end;

function Edit_GetCueBannerText(hwnd: HWND; lpwText: LPCWSTR; cchText: Longint): BOOL; {inline;}
begin
  Result := BOOL(SendMessage(hwnd, EM_GETCUEBANNER, wParam(lpwText), lParam(cchText)));
end;

function Edit_ShowBalloonTip(hwnd: HWND; const peditballoontip: TEditBalloonTip): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, EM_SHOWBALLOONTIP, 0, lParam(@peditballoontip)));
end;

function Edit_HideBalloonTip(hwnd: HWND): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, EM_HIDEBALLOONTIP, 0, 0));
end;

procedure Edit_SetHilite(hwndCtl: HWND; ichStart, ichEnd: Integer);
begin
  SendMessage(hwndCtl, EM_SETHILITE, ichStart, ichEnd);
end;

function Edit_GetHilite(hwndCtl: HWND): LRESULT;
begin
  Result := SendMessage(hwndCtl, EM_GETHILITE, 0, 0);
end;

{ ComboBox Control Functions }

function ComboBox_SetMinVisible(hwnd: HWND; iMinVisible: Integer): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, CB_SETMINVISIBLE, WPARAM(iMinVisible), 0));
end;

function ComboBox_GetMinVisible(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, CB_GETMINVISIBLE, 0, 0);
end;

function ComboBox_SetCueBannerText(hwnd: HWND; lpcwText: LPCWSTR): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, CB_SETCUEBANNER, 0, LPARAM(lpcwText)));
end;

function ComboBox_GetCueBannerText(hwnd: HWND; lpwText: LPCWSTR; cchText: Integer): BOOL;
begin
  Result := BOOL(SendMessage(hwnd, CB_GETCUEBANNER, WPARAM(lpwText), LPARAM(@cchText)));
end;

{ TrackMouseEvent }

function _TrackMouseEvent;              external cctrl name '_TrackMouseEvent';

{ Flat Scrollbar APIs }

function FlatSB_EnableScrollBar;        external cctrl name 'FlatSB_EnableScrollBar';
function FlatSB_GetScrollInfo;          external cctrl name 'FlatSB_GetScrollInfo';
function FlatSB_GetScrollPos;           external cctrl name 'FlatSB_GetScrollPos';
function FlatSB_GetScrollProp;          external cctrl name 'FlatSB_GetScrollProp';
function FlatSB_GetScrollRange;         external cctrl name 'FlatSB_GetScrollRange';
function FlatSB_SetScrollInfo;          external cctrl name 'FlatSB_SetScrollInfo';
function FlatSB_SetScrollPos;           external cctrl name 'FlatSB_SetScrollPos';
function FlatSB_SetScrollProp;          external cctrl name 'FlatSB_SetScrollProp';
function FlatSB_SetScrollRange;         external cctrl name 'FlatSB_SetScrollRange';
function FlatSB_ShowScrollBar;          external cctrl name 'FlatSB_ShowScrollBar';
function InitializeFlatSB;              external cctrl name 'InitializeFlatSB';
procedure UninitializeFlatSB;           external cctrl name 'UninitializeFlatSB';

{ Subclassing }

var
  _SetWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC; 
    uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL; stdcall;

  _GetWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
    uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL; stdcall;

  _RemoveWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
    uIdSubclass: UINT_PTR): BOOL; stdcall;

  _DefSubclassProc: function(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
    lParam: LPARAM): LRESULT; stdcall;

function SetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL;
begin
  if Assigned(_SetWindowSubclass) then
    Result := _SetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, dwRefData)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _SetWindowSubclass := GetProcAddress(ComCtl32DLL, PAnsiChar('SetWindowSubclass')); // Do not localize
      if Assigned(_SetWindowSubclass) then
        Result := _SetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, dwRefData);
    end;
  end;
end;

function GetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL;
begin
  if Assigned(_GetWindowSubclass) then
    Result := _GetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, pdwRefData)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _GetWindowSubclass := GetProcAddress(ComCtl32DLL, PAnsiChar('GetWindowSubclass')); // Do not localize
      if Assigned(_GetWindowSubclass) then
        Result := _GetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, pdwRefData);
    end;
  end;
end;

function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR): BOOL;
begin
  if Assigned(_RemoveWindowSubclass) then
    Result := _RemoveWindowSubclass(hWnd, pfnSubclass, uIdSubclass)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _RemoveWindowSubclass := GetProcAddress(ComCtl32DLL, PAnsiChar('RemoveWindowSubclass')); // Do not localize
      if Assigned(_RemoveWindowSubclass) then
        Result := _RemoveWindowSubclass(hWnd, pfnSubclass, uIdSubclass);
    end;
  end;
end;

function DefSubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
begin
  if Assigned(_DefSubclassProc) then
    Result := _DefSubclassProc(hWnd, uMsg, wParam, lParam)
  else
  begin
    Result := 0;
    if ComCtl32DLL > 0 then
    begin
      _DefSubclassProc := GetProcAddress(ComCtl32DLL, PAnsiChar('DefSubclassProc')); // Do not localize
      if Assigned(_DefSubclassProc) then
        Result := _DefSubclassProc(hWnd, uMsg, wParam, lParam);
    end;
  end;
end;

var
  _LoadIconMetric: function(hinst: HINST; pszName: LPCWSTR; lims: Integer;
    var phico: HICON): HResult; stdcall;

  _LoadIconWithScaleDown: function(hinst: HINST; pszName: LPCWSTR; cx: Integer;
    cy: Integer; var phico: HICON): HResult; stdcall;

  _DrawShadowText: function(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
    dwFlags: DWORD; crText: COLORREF; crShadow: COLORREF; ixOffset: Integer;
    iyOffset: Integer): Integer; stdcall;

function LoadIconMetric(hinst: HINST; pszName: LPCWSTR; lims: Integer;
  var phico: HICON): HResult;
begin
  if Assigned(_LoadIconMetric) then
    Result := _LoadIconMetric(hinst, pszName, lims, phico)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _LoadIconMetric := GetProcAddress(ComCtl32DLL, PAnsiChar('LoadIconMetric')); // Do not localize
      if Assigned(_LoadIconMetric) then
        Result := _LoadIconMetric(hinst, pszName, lims, phico);
    end;
  end;
end;

function LoadIconWithScaleDown(hinst: HINST; pszName: LPCWSTR; cx: Integer;
  cy: Integer; var phico: HICON): HResult;
begin
  if Assigned(_LoadIconWithScaleDown) then
    Result := _LoadIconWithScaleDown(hinst, pszName, cx, cy, phico)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _LoadIconWithScaleDown := GetProcAddress(ComCtl32DLL, PAnsiChar('LoadIconWithScaleDown')); // Do not localize
      if Assigned(_LoadIconWithScaleDown) then
        Result := _LoadIconWithScaleDown(hinst, pszName, cx, cy, phico);
    end;
  end;
end;

function DrawShadowText(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
  dwFlags: DWORD; crText: COLORREF; crShadow: COLORREF; ixOffset: Integer;
  iyOffset: Integer): Integer;
begin
  if Assigned(_DrawShadowText) then
    Result := _DrawShadowText(hdc, pszText, cch, prc, dwFlags, crText, crShadow,
      ixOffset, iyOffset)
  else
  begin
    Result := 0;
    if ComCtl32DLL > 0 then
    begin
      _DrawShadowText := GetProcAddress(ComCtl32DLL, PAnsiChar('DrawShadowText')); // Do not localize
      if Assigned(_DrawShadowText) then
        Result := _DrawShadowText(hdc, pszText, cch, prc, dwFlags, crText,
          crShadow, ixOffset, iyOffset);
    end;
  end;
end;

var
  _DrawScrollArrow: procedure(hdc: HDC; lprc: PRect; wControlState: UINT;
    rgbOveride: COLORREF); stdcall;

procedure DrawScrollArrow(hdc: HDC; lprc: PRect; wControlState: UINT;
  rgbOveride: COLORREF);
begin
  if Assigned(_DrawScrollArrow) then
    _DrawScrollArrow(hdc, lprc, wControlState, rgbOveride)
  else
  begin
    if ComCtl32DLL > 0 then
    begin
      _DrawScrollArrow := GetProcAddress(ComCtl32DLL, PAnsiChar('DrawScrollArrow')); // Do not localize
      if Assigned(_DrawScrollArrow) then
        _DrawScrollArrow(hdc, lprc, wControlState, rgbOveride);
    end;
  end;
end;


{ Task Dialog }

var
  _TaskDialogIndirect: function(const pTaskConfig: TTaskDialogConfig;
    pnButton: PInteger; pnRadioButton: PInteger;
    pfVerificationFlagChecked: PBOOL): HRESULT; stdcall;

  _TaskDialog: function(hwndParent: HWND; hInstance: HINST;
    pszWindowTitle: LPCWSTR; pszMainInstruction: LPCWSTR; pszContent: LPCWSTR;
    dwCommonButtons: DWORD; pszIcon: LPCWSTR; pnButton: PInteger): HRESULT; stdcall;

function TaskDialogIndirect(const pTaskConfig: TTaskDialogConfig;
  pnButton: PInteger; pnRadioButton: PInteger; pfVerificationFlagChecked: PBOOL): HRESULT;
begin
  if Assigned(_TaskDialogIndirect) then
    Result := _TaskDialogIndirect(pTaskConfig, pnButton, pnRadioButton,
      pfVerificationFlagChecked)
  else
  begin
    InitComCtl;
    Result := E_NOTIMPL;
    if ComCtl32DLL <> 0 then
    begin
      @_TaskDialogIndirect := GetProcAddress(ComCtl32DLL, PAnsiChar('TaskDialogIndirect'));
      if Assigned(_TaskDialogIndirect) then
        Result := _TaskDialogIndirect(pTaskConfig, pnButton, pnRadioButton,
          pfVerificationFlagChecked)
    end;
  end;
end;

function TaskDialog(hwndParent: HWND; hInstance: HINST; pszWindowTitle,
  pszMainInstruction, pszContent: LPCWSTR; dwCommonButtons: DWORD;
  pszIcon: LPCWSTR; pnButton: PInteger): HRESULT;
begin
  if Assigned(_TaskDialog) then
    Result := _TaskDialog(hwndParent, hInstance, pszWindowTitle, pszMainInstruction,
      pszContent, dwCommonButtons, pszIcon, pnButton)
  else
  begin
    InitComCtl;
    Result := E_NOTIMPL;
    if ComCtl32DLL <> 0 then
    begin
      @_TaskDialog := GetProcAddress(ComCtl32DLL, PAnsiChar('TaskDialog'));
      if Assigned(_TaskDialog) then
        Result := _TaskDialog(hwndParent, hInstance, pszWindowTitle, pszMainInstruction,
          pszContent, dwCommonButtons, pszIcon, pnButton);
    end;
  end;
end;

end.
