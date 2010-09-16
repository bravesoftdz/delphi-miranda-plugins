{Frame data}
const
  WS_EX_LAYERED = $00080000;
const
  DF_TEXT     = $0001;
  DF_BUTTON   = $0002;
  DF_TRACKBAR = $0004;
  DF_ALL      = DF_TEXT or DF_BUTTON or DF_TRACKBAR;
const
  TMR_FRAME  = 1;
  TMR_TEXT   = 2;
  TMR_BUTTON = 3;

const
  MaxTxtScrollSpeed = 20;

const
  WM_WAREFRESH = WM_USER+13;

const
  AlphaColor = $FF00FF;

  //show controls
  scButtons    = $0001;
  scTrackBar   = $0002;
  scText       = $0004;
  scVolume     = $0008;
  scGap        = $0010;
//  scAll        = $000F;

  ppLeft   = 0;
  ppRight  = 1;
  //effects
  effCut  = 0;
  effWrap = 1;
  effRoll = 2;
  effPong = 3;
  // chunk
  CT_TEXT    = $01;
  CT_TAB     = $09;
  CT_SPACE   = $20;
  CT_NEWLINE = $0D;
  // Frame Control codes
  frcInit     = 0;
  frcClear    = 1;
  frcRefresh  = 2;
  frcShowHide = 3;
  frcBackPic  = 4;
  frcForce    = 5;
  frcTimer    = 6;
  frcSetAlpha = 7;
  // Back bitmap mode
  frbkCenterX      = $0001;
  frbkCenterY      = $0002;
  frbkCenter       = frbkCenterX or frbkCenterY;
  frbkTileX        = $0004;
  frbkTileY        = $0008;
  frbkTile         = frbkTileX or frbkTileY;
  frbkStretchX     = $0010;
  frbkStretchY     = $0020;
  frbkStretch      = frbkStretchX or frbkStretchY;
  frbkProportional = $0040;
  frbkBottom       = $0080;
  frbkRight        = $0100;
  // Size changes
  fscHideInfo = 1;
  fscShowInfo = 2;
  fscHideCtrl = 4;
  fscShowCtrl = 8;
