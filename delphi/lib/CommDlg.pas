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
{         Win32 Common Dialogs interface unit           }
{*******************************************************}

unit CommDlg;


interface

uses Windows, Messages, ShlObj;

type
  POpenFilenameA = ^TOpenFilenameA;
  POpenFilenameW = ^TOpenFilenameW;
  POpenFilename = POpenFilenameW;
  tagOFNA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  tagOFNW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PWideChar;
    lpstrCustomFilter: PWideChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PWideChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PWideChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PWideChar;
    lpstrTitle: PWideChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PWideChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PWideChar;
    pvReserved: Pointer;
    dwReserved: DWORD;
    FlagsEx: DWORD;
  end;
  tagOFN = tagOFNW;
  TOpenFilenameA = tagOFNA;
  TOpenFilenameW = tagOFNW;
  TOpenFilename = TOpenFilenameW;
  OPENFILENAMEA = tagOFNA;
  OPENFILENAMEW = tagOFNW;
  OPENFILENAME = OPENFILENAMEW;

function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall;
function GetOpenFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
function GetOpenFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall;
function GetSaveFileNameA(var OpenFile: TOpenFilenameA): Bool; stdcall;
function GetSaveFileNameW(var OpenFile: TOpenFilenameW): Bool; stdcall;
function GetFileTitle(FileName: PWideChar; Title: PWideChar; TitleSize: Word): Smallint; stdcall;
function GetFileTitleA(FileName: PAnsiChar; Title: PAnsiChar; TitleSize: Word): Smallint; stdcall;
function GetFileTitleW(FileName: PWideChar; Title: PWideChar; TitleSize: Word): Smallint; stdcall;

const
  OFN_READONLY = $00000001;
  OFN_OVERWRITEPROMPT = $00000002;
  OFN_HIDEREADONLY = $00000004;
  OFN_NOCHANGEDIR = $00000008;
  OFN_SHOWHELP = $00000010;
  OFN_ENABLEHOOK = $00000020;
  OFN_ENABLETEMPLATE = $00000040;
  OFN_ENABLETEMPLATEHANDLE = $00000080;
  OFN_NOVALIDATE = $00000100;
  OFN_ALLOWMULTISELECT = $00000200;
  OFN_EXTENSIONDIFFERENT = $00000400;
  OFN_PATHMUSTEXIST = $00000800;
  OFN_FILEMUSTEXIST = $00001000;
  OFN_CREATEPROMPT = $00002000;
  OFN_SHAREAWARE = $00004000;
  OFN_NOREADONLYRETURN = $00008000;
  OFN_NOTESTFILECREATE = $00010000;
  OFN_NONETWORKBUTTON = $00020000;
  OFN_NOLONGNAMES = $00040000;
  OFN_EXPLORER = $00080000;
  OFN_NODEREFERENCELINKS = $00100000;
  OFN_LONGNAMES = $00200000;
  OFN_ENABLEINCLUDENOTIFY = $00400000;
  OFN_ENABLESIZING = $00800000;
  { #if (_WIN32_WINNT >= 0x0500) }
  OFN_DONTADDTORECENT = $02000000;
  OFN_FORCESHOWHIDDEN = $10000000;    // Show All files including System and hidden files
  { #endif // (_WIN32_WINNT >= 0x0500) }

  { FlagsEx Values }
  { #if (_WIN32_WINNT >= 0x0500) }
  OFN_EX_NOPLACESBAR = $00000001;
  { #endif // (_WIN32_WINNT >= 0x0500) }

{ Return values for the registered message sent to the hook function
  when a sharing violation occurs.  OFN_SHAREFALLTHROUGH allows the
  filename to be accepted, OFN_SHARENOWARN rejects the name but puts
  up no warning (returned when the app has already put up a warning
  message), and OFN_SHAREWARN puts up the default warning message
  for sharing violations.

  Note:  Undefined return values map to OFN_SHAREWARN, but are
         reserved for future use. }

  OFN_SHAREFALLTHROUGH = 2;
  OFN_SHARENOWARN = 1;
  OFN_SHAREWARN = 0;

type
  POFNotifyA = ^TOFNotifyA;
  POFNotifyW = ^TOFNotifyW;
  POFNotify = POFNotifyW;
  _OFNOTIFYA = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameA;
    pszFile: PAnsiChar;
  end;
  _OFNOTIFYW = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameW;
    pszFile: PWideChar;
  end;
  _OFNOTIFY = _OFNOTIFYW;
  TOFNotifyA = _OFNOTIFYA;
  TOFNotifyW = _OFNOTIFYW;
  TOFNotify = TOFNotifyW;
  OFNOTIFYA = _OFNOTIFYA;
  OFNOTIFYW = _OFNOTIFYW;
  OFNOTIFY = OFNOTIFYW;


  POFNotifyExA = ^TOFNotifyExA;
  POFNotifyExW = ^TOFNotifyExW;
  POFNotifyEx = POFNotifyExW;
  _OFNOTIFYEXA = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameA;
    psf: IShellFolder;
    pidl: Pointer;
  end;
  _OFNOTIFYEXW = packed record
    hdr: TNMHdr;
    lpOFN: POpenFilenameW;
    psf: IShellFolder;
    pidl: Pointer;
  end;
  _OFNOTIFYEX = _OFNOTIFYEXW;
  TOFNotifyExA = _OFNOTIFYEXA;
  TOFNotifyExW = _OFNOTIFYEXW;
  TOFNotifyEx = TOFNotifyExW;
  OFNOTIFYEXA = _OFNOTIFYEXA;
  OFNOTIFYEXW = _OFNOTIFYEXW;
  OFNOTIFYEX = OFNOTIFYEXW;

const
  CDN_FIRST = -601;
  CDN_LAST = -699;

{ Notifications when Open or Save dialog status changes }

  CDN_INITDONE = CDN_FIRST - 0;
  CDN_SELCHANGE = CDN_FIRST - 1;
  CDN_FOLDERCHANGE = CDN_FIRST - 2;
  CDN_SHAREVIOLATION = CDN_FIRST - 3;
  CDN_HELP = CDN_FIRST - 4;
  CDN_FILEOK = CDN_FIRST - 5;
  CDN_TYPECHANGE = CDN_FIRST - 6;
  CDN_INCLUDEITEM = CDN_FIRST - 7;

  CDM_FIRST = WM_USER + 100;
  CDM_LAST = WM_USER + 200;

{ Messages to query information from the Open or Save dialogs }

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  CDM_GETSPEC = CDM_FIRST + 0;

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  CDM_GETFILEPATH = CDM_FIRST + 1;

{ lParam = pointer to text buffer that gets filled in
  wParam = max number of characters of the text buffer (including NULL)
  return = < 0 if error; number of characters needed (including NULL) }

  CDM_GETFOLDERPATH = CDM_FIRST + 2;

{ lParam = pointer to ITEMIDLIST buffer that gets filled in
  wParam = size of the ITEMIDLIST buffer
  return = < 0 if error; length of buffer needed }

  CDM_GETFOLDERIDLIST = CDM_FIRST + 3;

{ lParam = pointer to a string
  wParam = ID of control to change
  return = not used }

  CDM_SETCONTROLTEXT = CDM_FIRST + 4;

{ lParam = not used
  wParam = ID of control to change
  return = not used }

  CDM_HIDECONTROL = CDM_FIRST + 5;

{ lParam = pointer to default extension (no dot)
  wParam = not used
  return = not used }

  CDM_SETDEFEXT = CDM_FIRST + 6;

type
  PChooseColorA = ^TChooseColorA;
  PChooseColorW = ^TChooseColorW;
  PChooseColor = PChooseColorW;
  tagCHOOSECOLORA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HWND;
    rgbResult: COLORREF;
    lpCustColors: ^COLORREF;
    Flags: DWORD;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
  end;
  tagCHOOSECOLORW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HWND;
    rgbResult: COLORREF;
    lpCustColors: ^COLORREF;
    Flags: DWORD;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PWideChar;
  end;
  tagCHOOSECOLOR = tagCHOOSECOLORW;
  TChooseColorA = tagCHOOSECOLORA;
  TChooseColorW = tagCHOOSECOLORW;
  TChooseColor = TChooseColorW;

function ChooseColor(var CC: TChooseColor): Bool; stdcall;
function ChooseColorA(var CC: TChooseColorA): Bool; stdcall;
function ChooseColorW(var CC: TChooseColorW): Bool; stdcall;

const
  CC_RGBINIT = $00000001;
  CC_FULLOPEN = $00000002;
  CC_PREVENTFULLOPEN = $00000004;
  CC_SHOWHELP = $00000008;
  CC_ENABLEHOOK = $00000010;
  CC_ENABLETEMPLATE = $00000020;
  CC_ENABLETEMPLATEHANDLE = $00000040;
  CC_SOLIDCOLOR = $00000080;
  CC_ANYCOLOR = $00000100;

type
  PFindReplaceA = ^TFindReplaceA;
  PFindReplaceW = ^TFindReplaceW;
  PFindReplace = PFindReplaceW;
  tagFINDREPLACEA = packed record
    lStructSize: DWORD;        { size of this struct $20 }
    hWndOwner: HWND;             { handle to owner's window }
    hInstance: HINST;        { instance handle of.EXE that
                                   contains cust. dlg. template }
    Flags: DWORD;                { one or more of the fr_?? }
    lpstrFindWhat: PAnsiChar;       { ptr. to search AnsiString    }
    lpstrReplaceWith: PAnsiChar;    { ptr. to replace AnsiString   }
    wFindWhatLen: Word;          { size of find buffer      }
    wReplaceWithLen: Word;       { size of replace buffer   }
    lCustData: LPARAM;           { data passed to hook fn.  }
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
                                 { ptr. to hook fn. or nil }
    lpTemplateName: PAnsiChar;     { custom template name     }
  end;
  tagFINDREPLACEW = packed record
    lStructSize: DWORD;        { size of this struct $20 }
    hWndOwner: HWND;             { handle to owner's window }
    hInstance: HINST;        { instance handle of.EXE that
                                   contains cust. dlg. template }
    Flags: DWORD;                { one or more of the fr_?? }
    lpstrFindWhat: PWideChar;       { ptr. to search UnicodeString    }
    lpstrReplaceWith: PWideChar;    { ptr. to replace UnicodeString   }
    wFindWhatLen: Word;          { size of find buffer      }
    wReplaceWithLen: Word;       { size of replace buffer   }
    lCustData: LPARAM;           { data passed to hook fn.  }
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
                                 { ptr. to hook fn. or nil }
    lpTemplateName: PWideChar;     { custom template name     }
  end;
  tagFINDREPLACE = tagFINDREPLACEW;
  TFindReplaceA = tagFINDREPLACEA;
  TFindReplaceW = tagFINDREPLACEW;
  TFindReplace = TFindReplaceW;
  FINDREPLACEA = tagFINDREPLACEA;
  FINDREPLACEW = tagFINDREPLACEW;
  FINDREPLACE = FINDREPLACEW;

const
  FR_DOWN = $00000001;
  FR_WHOLEWORD = $00000002;
  FR_MATCHCASE = $00000004;
  FR_FINDNEXT = $00000008;
  FR_REPLACE = $00000010;
  FR_REPLACEALL = $00000020;
  FR_DIALOGTERM = $00000040;
  FR_SHOWHELP = $00000080;
  FR_ENABLEHOOK = $00000100;
  FR_ENABLETEMPLATE = $00000200;
  FR_NOUPDOWN = $00000400;
  FR_NOMATCHCASE = $00000800;
  FR_NOWHOLEWORD = $00001000;
  FR_ENABLETEMPLATEHANDLE = $00002000;
  FR_HIDEUPDOWN = $00004000;
  FR_HIDEMATCHCASE = $00008000;
  FR_HIDEWHOLEWORD = $00010000;

function FindText(var FindReplace: TFindReplace): HWND; stdcall;
function FindTextA(var FindReplace: TFindReplaceA): HWND; stdcall;
function FindTextW(var FindReplace: TFindReplaceW): HWND; stdcall;
function ReplaceText(var FindReplace: TFindReplace): HWND; stdcall;
function ReplaceTextA(var FindReplace: TFindReplaceA): HWND; stdcall;
function ReplaceTextW(var FindReplace: TFindReplaceW): HWND; stdcall;

type
  PChooseFontA = ^TChooseFontA;
  PChooseFontW = ^TChooseFontW;
  PChooseFont = PChooseFontW;
  tagCHOOSEFONTA = packed record
    lStructSize: DWORD;
    hWndOwner: HWnd;            { caller's window handle }
    hDC: HDC;                   { printer DC/IC or nil }
    lpLogFont: PLogFontA;     { pointer to a LOGFONT struct }
    iPointSize: Integer;        { 10 * size in points of selected font }
    Flags: DWORD;               { dialog flags }
    rgbColors: COLORREF;        { returned text color }
    lCustData: LPARAM;          { data passed to hook function }
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
                                { pointer to hook function }
    lpTemplateName: PAnsiChar;    { custom template name }
    hInstance: HINST;       { instance handle of EXE that contains
                                  custom dialog template }
    lpszStyle: PAnsiChar;         { return the style field here
                                  must be lf_FaceSize or bigger }
    nFontType: Word;            { same value reported to the EnumFonts
                                  call back with the extra fonttype_
                                  bits added }
    wReserved: Word;
    nSizeMin: Integer;          { minimum point size allowed and }
    nSizeMax: Integer;          { maximum point size allowed if
                                  cf_LimitSize is used }
  end;
  tagCHOOSEFONTW = packed record
    lStructSize: DWORD;
    hWndOwner: HWnd;            { caller's window handle }
    hDC: HDC;                   { printer DC/IC or nil }
    lpLogFont: PLogFontW;     { pointer to a LOGFONT struct }
    iPointSize: Integer;        { 10 * size in points of selected font }
    Flags: DWORD;               { dialog flags }
    rgbColors: COLORREF;        { returned text color }
    lCustData: LPARAM;          { data passed to hook function }
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
                                { pointer to hook function }
    lpTemplateName: PWideChar;    { custom template name }
    hInstance: HINST;       { instance handle of EXE that contains
                                  custom dialog template }
    lpszStyle: PWideChar;         { return the style field here
                                  must be lf_FaceSize or bigger }
    nFontType: Word;            { same value reported to the EnumFonts
                                  call back with the extra fonttype_
                                  bits added }
    wReserved: Word;
    nSizeMin: Integer;          { minimum point size allowed and }
    nSizeMax: Integer;          { maximum point size allowed if
                                  cf_LimitSize is used }
  end;
  tagCHOOSEFONT = tagCHOOSEFONTW;
  TChooseFontA = tagCHOOSEFONTA;
  TChooseFontW = tagCHOOSEFONTW;
  TChooseFont = TChooseFontW;

function ChooseFont(var ChooseFont: TChooseFont): Bool; stdcall;
function ChooseFontA(var ChooseFont: TChooseFontA): Bool; stdcall;
function ChooseFontW(var ChooseFont: TChooseFontW): Bool; stdcall;

const
  CF_SCREENFONTS = $00000001;
  CF_PRINTERFONTS = $00000002;
  CF_BOTH = CF_SCREENFONTS OR CF_PRINTERFONTS;
  CF_SHOWHELP = $00000004;
  CF_ENABLEHOOK = $00000008;
  CF_ENABLETEMPLATE = $00000010;
  CF_ENABLETEMPLATEHANDLE = $00000020;
  CF_INITTOLOGFONTSTRUCT = $00000040;
  CF_USESTYLE = $00000080;
  CF_EFFECTS = $00000100;
  CF_APPLY = $00000200;
  CF_ANSIONLY = $00000400;
  CF_SCRIPTSONLY = CF_ANSIONLY;
  CF_NOVECTORFONTS = $00000800;
  CF_NOOEMFONTS = CF_NOVECTORFONTS;
  CF_NOSIMULATIONS = $00001000;
  CF_LIMITSIZE = $00002000;
  CF_FIXEDPITCHONLY = $00004000;
  CF_WYSIWYG = $00008000; { must also have CF_SCREENFONTS & CF_PRINTERFONTS }
  CF_FORCEFONTEXIST = $00010000;
  CF_SCALABLEONLY = $00020000;
  CF_TTONLY = $00040000;
  CF_NOFACESEL = $00080000;
  CF_NOSTYLESEL = $00100000;
  CF_NOSIZESEL = $00200000;
  CF_SELECTSCRIPT = $00400000;
  CF_NOSCRIPTSEL = $00800000;
  CF_NOVERTFONTS = $01000000;

{ these are extra nFontType bits that are added to what is returned to the
  EnumFonts callback routine }

  SIMULATED_FONTTYPE = $8000;
  PRINTER_FONTTYPE = $4000;
  SCREEN_FONTTYPE = $2000;
  BOLD_FONTTYPE = $0100;
  ITALIC_FONTTYPE = $0200;
  REGULAR_FONTTYPE = $0400;

  OPENTYPE_FONTTYPE = $10000;
  TYPE1_FONTTYPE = $20000;
  DSIG_FONTTYPE = $40000;

  WM_CHOOSEFONT_GETLOGFONT = WM_USER + 1;
  WM_CHOOSEFONT_SETLOGFONT = WM_USER + 101; { removed in 4.0 SDK }
  WM_CHOOSEFONT_SETFLAGS   = WM_USER + 102; { removed in 4.0 SDK }

{ strings used to obtain unique window message for communication
  between dialog and caller }

  LBSELCHSTRING = 'commdlg_LBSelChangedNotify';
  SHAREVISTRING = 'commdlg_ShareViolation';
  FILEOKSTRING  = 'commdlg_FileNameOK';
  COLOROKSTRING = 'commdlg_ColorOK';
  SETRGBSTRING  = 'commdlg_SetRGBColor';
  FINDMSGSTRING = 'commdlg_FindReplace';
  HELPMSGSTRING = 'commdlg_help';

{ HIWORD values for lParam of commdlg_LBSelChangeNotify message }

const
  CD_LBSELNOITEMS = -1;
  CD_LBSELCHANGE  = 0;
  CD_LBSELSUB     = 1;
  CD_LBSELADD     = 2;

type
  PPrintDlgA = ^TPrintDlgA;
  PPrintDlgW = ^TPrintDlgW;
  PPrintDlg = PPrintDlgW;
  tagPDA = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    hDC: HDC;
    Flags: DWORD;
    nFromPage: Word;
    nToPage: Word;
    nMinPage: Word;
    nMaxPage: Word;
    nCopies: Word;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPrintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPrintTemplateName: PAnsiChar;
    lpSetupTemplateName: PAnsiChar;
    hPrintTemplate: HGLOBAL;
    hSetupTemplate: HGLOBAL;
  end;
  tagPDW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    hDC: HDC;
    Flags: DWORD;
    nFromPage: Word;
    nToPage: Word;
    nMinPage: Word;
    nMaxPage: Word;
    nCopies: Word;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPrintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPrintTemplateName: PWideChar;
    lpSetupTemplateName: PWideChar;
    hPrintTemplate: HGLOBAL;
    hSetupTemplate: HGLOBAL;
  end;
  tagPD = tagPDW;
  TPrintDlgA = tagPDA;
  TPrintDlgW = tagPDW;
  TPrintDlg = TPrintDlgW;

function PrintDlg(var PrintDlg: TPrintDlg): Bool; stdcall;
function PrintDlgA(var PrintDlg: TPrintDlgA): Bool; stdcall;
function PrintDlgW(var PrintDlg: TPrintDlgW): Bool; stdcall;

const
  PD_ALLPAGES = $00000000;
  PD_SELECTION = $00000001;
  PD_PAGENUMS = $00000002;
  PD_NOSELECTION = $00000004;
  PD_NOPAGENUMS = $00000008;
  PD_COLLATE = $00000010;
  PD_PRINTTOFILE = $00000020;
  PD_PRINTSETUP = $00000040;
  PD_NOWARNING = $00000080;
  PD_RETURNDC = $00000100;
  PD_RETURNIC = $00000200;
  PD_RETURNDEFAULT = $00000400;
  PD_SHOWHELP = $00000800;
  PD_ENABLEPRINTHOOK = $00001000;
  PD_ENABLESETUPHOOK = $00002000;
  PD_ENABLEPRINTTEMPLATE = $00004000;
  PD_ENABLESETUPTEMPLATE = $00008000;
  PD_ENABLEPRINTTEMPLATEHANDLE = $00010000;
  PD_ENABLESETUPTEMPLATEHANDLE = $00020000;
  PD_USEDEVMODECOPIES = $00040000;
  PD_USEDEVMODECOPIESANDCOLLATE = $00040000;
  PD_DISABLEPRINTTOFILE = $00080000;
  PD_HIDEPRINTTOFILE = $00100000;
  PD_NONETWORKBUTTON = $00200000;

type
  PDevNames = ^TDevNames;
  tagDEVNAMES = record
    wDriverOffset: Word;
    wDeviceOffset: Word;
    wOutputOffset: Word;
    wDefault: Word;
  end;
  TDevNames = tagDEVNAMES;
  DEVNAMES = tagDEVNAMES;

const
  DN_DEFAULTPRN = $0001;

function CommDlgExtendedError: DWORD; stdcall;

const
  WM_PSD_PAGESETUPDLG     = WM_USER;
  WM_PSD_FULLPAGERECT     = WM_USER + 1;
  WM_PSD_MINMARGINRECT    = WM_USER + 2;
  WM_PSD_MARGINRECT       = WM_USER + 3;
  WM_PSD_GREEKTEXTRECT    = WM_USER + 4;
  WM_PSD_ENVSTAMPRECT     = WM_USER + 5;
  WM_PSD_YAFULLPAGERECT   = WM_USER + 6;

type
  PPageSetupDlgA = ^TPageSetupDlgA;
  PPageSetupDlgW = ^TPageSetupDlgW;
  PPageSetupDlg = PPageSetupDlgW;
  tagPSDA = packed record
    lStructSize: DWORD;
    hwndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    Flags: DWORD;
    ptPaperSize: TPoint;
    rtMinMargin: TRect;
    rtMargin: TRect;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPageSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnPagePaintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPageSetupTemplateName: PAnsiChar;
    hPageSetupTemplate: HGLOBAL;
  end;
  tagPSDW = packed record
    lStructSize: DWORD;
    hwndOwner: HWND;
    hDevMode: HGLOBAL;
    hDevNames: HGLOBAL;
    Flags: DWORD;
    ptPaperSize: TPoint;
    rtMinMargin: TRect;
    rtMargin: TRect;
    hInstance: HINST;
    lCustData: LPARAM;
    lpfnPageSetupHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpfnPagePaintHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpPageSetupTemplateName: PWideChar;
    hPageSetupTemplate: HGLOBAL;
  end;
  tagPSD = tagPSDW;
  TPageSetupDlgA = tagPSDA;
  TPageSetupDlgW = tagPSDW;
  TPageSetupDlg = TPageSetupDlgW;

function PageSetupDlg(var PgSetupDialog: TPageSetupDlg): BOOL; stdcall;
function PageSetupDlgA(var PgSetupDialog: TPageSetupDlgA): BOOL; stdcall;
function PageSetupDlgW(var PgSetupDialog: TPageSetupDlgW): BOOL; stdcall;

const
  PSD_DEFAULTMINMARGINS             = $00000000; { default (printer's) }
  PSD_INWININIINTLMEASURE           = $00000000; { 1st of 4 possible }

  PSD_MINMARGINS                    = $00000001; { use caller's }
  PSD_MARGINS                       = $00000002; { use caller's }
  PSD_INTHOUSANDTHSOFINCHES         = $00000004; { 2nd of 4 possible }
  PSD_INHUNDREDTHSOFMILLIMETERS     = $00000008; { 3rd of 4 possible }
  PSD_DISABLEMARGINS                = $00000010;
  PSD_DISABLEPRINTER                = $00000020;
  PSD_NOWARNING                     = $00000080; { must be same as PD_* }
  PSD_DISABLEORIENTATION            = $00000100;
  PSD_RETURNDEFAULT                 = $00000400; { must be same as PD_* }
  PSD_DISABLEPAPER                  = $00000200;
  PSD_SHOWHELP                      = $00000800; { must be same as PD_* }
  PSD_ENABLEPAGESETUPHOOK           = $00002000; { must be same as PD_* }
  PSD_ENABLEPAGESETUPTEMPLATE       = $00008000; { must be same as PD_* }
  PSD_ENABLEPAGESETUPTEMPLATEHANDLE = $00020000; { must be same as PD_* }
  PSD_ENABLEPAGEPAINTHOOK           = $00040000;
  PSD_DISABLEPAGEPAINTING           = $00080000;
  PSD_NONETWORKBUTTON               = $00200000; { must be same as PD_* }


{ Common dialog error return codes }

const
  CDERR_DIALOGFAILURE    = $FFFF;

  CDERR_GENERALCODES     = $0000;
  CDERR_STRUCTSIZE       = $0001;
  CDERR_INITIALIZATION   = $0002;
  CDERR_NOTEMPLATE       = $0003;
  CDERR_NOHINSTANCE      = $0004;
  CDERR_LOADSTRFAILURE   = $0005;
  CDERR_FINDRESFAILURE   = $0006;
  CDERR_LOADRESFAILURE   = $0007;
  CDERR_LOCKRESFAILURE   = $0008;
  CDERR_MEMALLOCFAILURE  = $0009;
  CDERR_MEMLOCKFAILURE   = $000A;
  CDERR_NOHOOK           = $000B;
  CDERR_REGISTERMSGFAIL  = $000C;

  PDERR_PRINTERCODES     = $1000;
  PDERR_SETUPFAILURE     = $1001;
  PDERR_PARSEFAILURE     = $1002;
  PDERR_RETDEFFAILURE    = $1003;
  PDERR_LOADDRVFAILURE   = $1004;
  PDERR_GETDEVMODEFAIL   = $1005;
  PDERR_INITFAILURE      = $1006;
  PDERR_NODEVICES        = $1007;
  PDERR_NODEFAULTPRN     = $1008;
  PDERR_DNDMMISMATCH     = $1009;
  PDERR_CREATEICFAILURE  = $100A;
  PDERR_PRINTERNOTFOUND  = $100B;
  PDERR_DEFAULTDIFFERENT = $100C;

  CFERR_CHOOSEFONTCODES  = $2000;
  CFERR_NOFONTS          = $2001;
  CFERR_MAXLESSTHANMIN   = $2002;

  FNERR_FILENAMECODES    = $3000;
  FNERR_SUBCLASSFAILURE  = $3001;
  FNERR_INVALIDFILENAME  = $3002;
  FNERR_BUFFERTOOSMALL   = $3003;

  FRERR_FINDREPLACECODES = $4000;
  FRERR_BUFFERLENGTHZERO = $4001;

  CCERR_CHOOSECOLORCODES = $5000;

implementation

const
  commdlg32 = 'comdlg32.dll';

function GetOpenFileName;      external commdlg32  name 'GetOpenFileNameW';
function GetOpenFileNameA;      external commdlg32  name 'GetOpenFileNameA';
function GetOpenFileNameW;      external commdlg32  name 'GetOpenFileNameW';
function GetSaveFileName;   external commdlg32  name 'GetSaveFileNameW';
function GetSaveFileNameA;   external commdlg32  name 'GetSaveFileNameA';
function GetSaveFileNameW;   external commdlg32  name 'GetSaveFileNameW';
function GetFileTitle;      external commdlg32  name 'GetFileTitleW';
function GetFileTitleA;      external commdlg32  name 'GetFileTitleA';
function GetFileTitleW;      external commdlg32  name 'GetFileTitleW';
function ChooseColor;       external commdlg32  name 'ChooseColorW';
function ChooseColorA;       external commdlg32  name 'ChooseColorA';
function ChooseColorW;       external commdlg32  name 'ChooseColorW';
function FindText;          external commdlg32  name 'FindTextW';
function FindTextA;          external commdlg32  name 'FindTextA';
function FindTextW;          external commdlg32  name 'FindTextW';
function ReplaceText;       external commdlg32  name 'ReplaceTextW';
function ReplaceTextA;       external commdlg32  name 'ReplaceTextA';
function ReplaceTextW;       external commdlg32  name 'ReplaceTextW';
function ChooseFont;        external commdlg32  name 'ChooseFontW';
function ChooseFontA;        external commdlg32  name 'ChooseFontA';
function ChooseFontW;        external commdlg32  name 'ChooseFontW';
function PrintDlg;          external commdlg32  name 'PrintDlgW';
function PrintDlgA;          external commdlg32  name 'PrintDlgA';
function PrintDlgW;          external commdlg32  name 'PrintDlgW';
function CommDlgExtendedError; external commdlg32  name 'CommDlgExtendedError';
function PageSetupDlg;      external commdlg32  name 'PageSetupDlgW';
function PageSetupDlgA;      external commdlg32  name 'PageSetupDlgA';
function PageSetupDlgW;      external commdlg32  name 'PageSetupDlgW';

end.

