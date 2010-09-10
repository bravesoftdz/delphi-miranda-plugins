{frame save/load options}
const
  opt_ModStatus  :PAnsiChar = 'module/frame';

  opt_HiddenByMe:PAnsiChar = 'frame/hiddenbyme';
  opt_ShowCtrls :PAnsiChar = 'frame/showcontrols';
  opt_FrmTxtClr :PAnsiChar = 'frame/frametextcolor';
  opt_FrmFont   :PAnsiChar = 'frame/framefont';
  opt_FrmUsePic :PAnsiChar = 'frame/frmusepic';
  opt_FrmUseCvr :PAnsiChar = 'frame/frmusecover';
  opt_FrmBkColor:PAnsiChar = 'frame/frmbkcolor';
  opt_FrmBkPic  :PAnsiChar = 'frame/frmbkpic';
  opt_FrmBkMode :PAnsiChar = 'frame/frmbkmode';
  opt_FrmHeight :PAnsiChar = 'frame/frmheight';
  opt_FrmAlpha  :PAnsiChar = 'frame/frmalpha';
  opt_StyledTrk :PAnsiChar = 'frame/styledtrackbar';
  opt_ButtonGap :PAnsiChar = 'frame/buttongap';
  opt_FrmEffect :PAnsiChar = 'frame/txteffect';
  opt_HideFrameM:PAnsiChar = 'frame/hideframem';
  opt_HideFrameP:PAnsiChar = 'frame/hideframep';
  opt_RollStep  :PAnsiChar = 'frame/rollstep';
  opt_RollGap   :PAnsiChar = 'frame/rollgap';
  opt_RollTail  :PAnsiChar = 'frame/rolltail';
  opt_AlgnCenter:PAnsiChar = 'frame/aligncenter';
  opt_FrmTimer  :PAnsiChar = 'frame/frametimer';
  opt_TxtTimer  :PAnsiChar = 'frame/texttimer';
  opt_PadLeft   :PAnsiChar = 'frame/paddingleft';
  opt_PadTop    :PAnsiChar = 'frame/paddingtop';
  opt_PadRight  :PAnsiChar = 'frame/paddingright';
  opt_PadBottom :PAnsiChar = 'frame/paddingbottom';
  opt_FrameText :PAnsiChar = 'frame/frametext';

  opt_oldfrmtxt :PAnsiChar = 'template/frametext';
  spref = 'strings/';

function GetModStatus:integer;
begin
  result:=DBReadByte(0,PluginShort,opt_ModStatus,1);
end;

procedure SetModStatus(stat:integer);
begin
  DBWriteByte(0,PluginShort,opt_modStatus,stat);
end;

procedure InitFrame;
begin
  FillChar(FrameLF,SizeOf(TLOGFONT),0);
  with FrameLF do
  begin
    lfCharSet       :=DEFAULT_CHARSET;
    lfOutPrecision  :=OUT_DEFAULT_PRECIS;
    lfClipPrecision :=CLIP_DEFAULT_PRECIS;
    lfQuality       :=DEFAULT_QUALITY;
    lfPitchAndFamily:=DEFAULT_PITCH or FF_DONTCARE;
//    dc:=GetDC(FrameWnd);
//    lfHeight     :=-(8*GetDeviceCaps(dc,LOGPIXELSY) div 72);
//    ReleaseDC(FrameWnd,dc);
    lfHeight     :=-10;
    lfWeight     :=FW_DONTCARE;
    lfItalic     :=0;
    lfUnderline  :=0;
    lfStrikeOut  :=0;
    lfFaceName[0]:=#0;
  end;
end;

procedure loadframe;
var
  setting:array [0..63] of AnsiChar;
begin
{
  HiddenByMe       :=bool(DBReadByte(0,PluginShort,opt_HiddenByMe,ord(true)));
  HideFrameNoMusic :=DBReadByte(0,PluginShort,opt_HideFrameM,BST_UNCHECKED);
  HideFrameNoPlayer:=DBReadByte(0,PluginShort,opt_HideFrameP,BST_UNCHECKED);
  RollStep    :=DBReadByte (0,PluginShort,opt_RollStep  ,2);
  RollGap     :=DBReadByte (0,PluginShort,opt_RollGap   ,16);
  RollTail    :=DBReadByte (0,PluginShort,opt_RollTail  ,20);
  ShowControls:=DBReadDWord(0,PluginShort,opt_ShowCtrls ,scShowAll);
  FrmUsePic   :=DBReadByte (0,PluginShort,opt_FrmUsePic ,BST_UNCHECKED);
  FrmUseCover :=DBReadByte (0,PluginShort,opt_FrmUseCvr ,BST_UNCHECKED);
  FrmTxtColor :=DBReadDWord(0,PluginShort,opt_FrmTxtClr ,0);
  FrmBkColor  :=DBReadDWord(0,PluginShort,opt_FrmBkColor,$00E0E0E0);
  FrmBkMode   :=DBReadWord (0,PluginShort,opt_FrmBkMode ,0);
  FrmAlpha    :=DBReadByte (0,PluginShort,opt_FrmAlpha  ,255);
  FrmEffect   :=DBReadByte (0,PluginShort,opt_FrmEffect ,effCut);
  StyledTrack :=DBReadByte (0,PluginShort,opt_StyledTrk ,BST_UNCHECKED);
  ButtonGap   :=DBReadByte (0,PluginShort,opt_ButtonGap ,BST_UNCHECKED);
  AlignCenter :=DBReadByte (0,PluginShort,opt_AlgnCenter,BST_UNCHECKED);

  if DBGetSettingType(0,PluginShort,opt_FrameText)=DBVT_DELETED then
  begin
    IntToStr(StrCopyE(setting,spref),DBReadWord(0,PluginShort,opt_oldfrmtxt,3));
    FrameText:=DBReadUnicode(0,PluginShort,setting,nil);
  end
  else
    FrameText:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
  padding.left  :=DBReadWord(0,PluginShort,opt_PadLeft  ,0);
  padding.top   :=DBReadWord(0,PluginShort,opt_PadTop   ,0);
  padding.right :=DBReadWord(0,PluginShort,opt_PadRight ,0);
  padding.bottom:=DBReadWord(0,PluginShort,opt_PadBottom,0);

  vTxtTimer:=DBReadWord(0,PluginShort,opt_TxtTimer,10);
  vFrmTimer:=DBReadWord(0,PluginShort,opt_FrmTimer,200);
  if vFrmTimer<100 then
    vFrmTimer:=vFrmTimer*1000;
//  if vFrmTimer<100 then
//   vFrmTimer:=200;
  FrmBkPic:=DBReadString(0,PluginShort,opt_FrmBkPic,nil);
  if DBReadStruct(0,PluginShort,opt_FrmFont,@FrameLF,SizeOf(FrameLF))=0 then
    InitFrame;
}
end;

procedure saveframe;
begin
{
  DBWriteByte  (0,PluginShort,opt_HideFrameM,HideFrameNoMusic);
  DBWriteByte  (0,PluginShort,opt_HideFrameP,HideFrameNoPlayer);
  DBWriteDWord (0,PluginShort,opt_ShowCtrls ,ShowControls);
  DBWriteByte  (0,PluginShort,opt_FrmUsePic ,FrmUsePic);
  DBWriteByte  (0,PluginShort,opt_FrmUseCvr ,FrmUseCover);
  DBWriteDWord (0,PluginShort,opt_FrmTxtClr ,FrmTxtColor);
  DBWriteDWord (0,PluginShort,opt_FrmBkColor,FrmBkColor);
  DBWriteWord  (0,PluginShort,opt_FrmBkMode ,FrmBkMode);
  DBWriteByte  (0,PluginShort,opt_FrmAlpha  ,FrmAlpha);
  DBWriteByte  (0,PluginShort,opt_StyledTrk ,StyledTrack);
  DBWriteByte  (0,PluginShort,opt_ButtonGap ,ButtonGap);
  DBWriteWord  (0,PluginShort,opt_FrmTimer  ,vFrmTimer);
  DBWriteWord  (0,PluginShort,opt_PadLeft   ,padding.left);
  DBWriteWord  (0,PluginShort,opt_PadTop    ,padding.top);
  DBWriteWord  (0,PluginShort,opt_PadRight  ,padding.right);
  DBWriteWord  (0,PluginShort,opt_PadBottom ,padding.bottom);
  DBWriteString(0,PluginShort,opt_FrmBkPic,FrmBkPic);
  DBWriteStruct(0,PluginShort,opt_FrmFont,@FrameLF,SizeOf(FrameLF));
}
end;

procedure saveframe2;
begin
{
  DBWriteByte    (0,PluginShort,opt_RollStep  ,RollStep);
  DBWriteByte    (0,PluginShort,opt_RollGap   ,RollGap);
  DBWriteByte    (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteByte    (0,PluginShort,opt_FrmEffect ,FrmEffect);
  DBWriteByte    (0,PluginShort,opt_AlgnCenter,AlignCenter);
  DBWriteWord    (0,PluginShort,opt_TxtTimer  ,vTxtTimer);

  DBWriteDWord   (0,PluginShort,opt_FrmTxtClr ,FrmTxtColor);
  DBWriteDWord   (0,PluginShort,opt_FrmBkColor,FrmBkColor);
  DBWriteWord    (0,PluginShort,opt_FrmBkMode ,FrmBkMode);
  DBWriteByte    (0,PluginShort,opt_FrmAlpha  ,FrmAlpha);
  DBWriteByte    (0,PluginShort,opt_StyledTrk ,StyledTrack);
  DBWriteWord    (0,PluginShort,opt_FrmTimer  ,vFrmTimer);
  DBWriteWord    (0,PluginShort,opt_PadLeft   ,padding.left);
  DBWriteWord    (0,PluginShort,opt_PadTop    ,padding.top);
  DBWriteWord    (0,PluginShort,opt_PadRight  ,padding.right);
  DBWriteWord    (0,PluginShort,opt_PadBottom ,padding.bottom);
  DBWriteUnicode (0,PluginShort,opt_FrameText ,FrameText);
  DBWriteStruct  (0,PluginShort,opt_FrmFont   ,@FrameLF,SizeOf(FrameLF));
}
end;
