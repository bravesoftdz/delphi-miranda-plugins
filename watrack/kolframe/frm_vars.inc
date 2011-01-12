{Frame variables}
var
  sic,
  PlStatusHook:cardinal;

  HiddenByMe:bool;

  FrameHeight:dword;

type
  PWATFrame = ^TWATFrame;
  TWATFrame = object(TObj)
    BkDC        :HDC;       // "buffer" DC and associated bitmap
    BkBitmap    :HBITMAP;   // original bitmap
    BkFile      :PAnsiChar; // original bitmap filename
    BkDefFile   :PAnsiChar; // default background picture filename
    BkMode      :cardinal;
    BkTimer     :cardinal;  // timer to free original picture buffer
    BkColor     :TCOLORREF;
    padding     :TRect;
    ShowControls:dword;
    UseBkPicture:bool;
    UseCover    :bool;
    HideNoMusic :bool;
    HideNoPlayer:bool;

    // not sure what will keep here
    FrameId     :integer;
    FrmAlpha    :integer;
    UpdInterval :cardinal;
    UpdTimer    :cardinal;  

    Form     :PControl;
    Trackbar :PTrackbar;
    Buttons  :PControl;
    TextBlock:PTextBlock;

    destructor Destroy; virtual;
    procedure Paint(Sender: PControl; DC: HDC);
    procedure FrameResize(Sender: PObj);
    procedure MouseDown(Sender:PControl;var Mouse:TMouseEventData);
    procedure RefreshAllFrameIcons;
    procedure ResetFrame;

    procedure PreparePicture(dc:HDC;rc:TRECT);
    function LoadBkPicture(CoverFName:PAnsiChar;check:boolean=false;
             BackFName:PAnsiChar=nil):integer;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure SetAlpha(value:integer);
    procedure RefreshPicture(cover:PAnsiChar=nil);
    procedure AdjustFrame;
  end;

var
  FrameCtrl:PWATFrame;
