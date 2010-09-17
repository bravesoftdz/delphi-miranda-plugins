{Frame}
const
  FSC_BACKGROUND = 1;
  FSC_BEHAVIOUR  = 2;
  FSC_SHOW       = 4;
//  FSC_ALPHA      = 8;

function MakePicFilter:PWideChar;
var
  buf:array [0..255] of WideChar;
  size:integer;
  pc:pWideChar;
begin
  FillChar(buf,SizeOf(buf),0);
  pc:=StrCopyEW(StrCopyEW(buf,TranslateW('All Bitmaps')),' (*.bmp;*.jpg;*.gif;*.png)');
  pc:=StrCopyEW(pc+1,'*.BMP;*.RLE;*.JPG;*.JPEG;*.GIF;*.PNG');
  size:=(pc+2-@buf)*SizeOf(WideChar);
  mGetMem(result,size);
  move(buf,result^,size);
end;

procedure SwitchBk(Dialog:hwnd);
var
  en:boolean;
begin
  en:=IsDlgButtonChecked(Dialog,IDC_FRMUSEPIC)<>BST_UNCHECKED;
  EnableWindow(GetDlgItem(Dialog,IDC_FRMBKPIC ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_FRMPICBTN),en);
  EnableWindow(GetDlgItem(Dialog,IDC_CENTERX  ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_CENTERY  ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_TILEX    ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_TILEY    ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_STRETCHX ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_STRETCHY ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_PROP     ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_BOTTOM   ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_RIGHT    ),en);
  EnableWindow(GetDlgItem(Dialog,IDC_USECOVER ),en);
end;

function FrameViewDlg(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
var
  tmp,tmp1:cardinal;
  buf1:PAnsiChar;
  buf:PAnsiChar;
  p:PAnsiChar;
  redraw:boolean;
  tmpb:longbool;
  pcw,tmpPicName:pWideChar;
begin
  result:=0;
  case hMessage of
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
//      Changed:=DLGED_INIT;
      with FrameCtrl^ do
      begin
        SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_SETRANGE,0,MAKELONG(0,255));
        SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_SETPOS,1,FrmAlpha);

        if (ShowControls and scButtons )<>0 then CheckDlgButton(Dialog,IDC_SHOWCTRLS,BST_CHECKED);
        if (ShowControls and scTrackBar)<>0 then CheckDlgButton(Dialog,IDC_SHOWBAR  ,BST_CHECKED);
        if (ShowControls and scText    )<>0 then CheckDlgButton(Dialog,IDC_SHOWTEXT ,BST_CHECKED);
        if (ShowControls and scVolume  )<>0 then CheckDlgButton(Dialog,IDC_SHOWVOLUM,BST_CHECKED);
        if (ShowControls and scGap     )<>0 then CheckDlgButton(Dialog,IDC_BTNGAP   ,BST_CHECKED);

        CheckDlgButton(Dialog,IDC_HIDEFRAMEPLAYER,ORD(HideNoPlayer));
        CheckDlgButton(Dialog,IDC_HIDEFRAMEMUSIC ,ORD(HideNoMusic));
        EnableWindow(GetDlgItem(Dialog,IDC_HIDEFRAMEMUSIC),HideNoPlayer);

        SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_SETCOLOUR,0,BkColor);
        SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_SETDEFAULTCOLOUR,0,GetSysColor(COLOR_BTNFACE));
        SetDlgItemInt(Dialog,IDC_FRMCOLOR,BkColor,false);

        if UseBkPicture then
          CheckDlgButton(Dialog,IDC_FRMUSEPIC,ORD(UseBkPicture));
        if BkDefFile=nil then
          p:=''
        else
          p:=BkDefFile;
        SetDlgItemTextA(Dialog,IDC_FRMBKPIC,p);
        CheckDlgButton(Dialog,IDC_USECOVER,ORD(UseCover));

        tmp:=UpdInterval;
        if (tmp>=1000) and (tmp mod 1000=0) then
          tmp:=tmp div 1000;
        SetDlgItemInt(Dialog,IDC_TIMER,tmp,false);

        SetDlgItemInt(Dialog,IDC_PADDING_LEFT  ,padding.left  ,false);
        SetDlgItemInt(Dialog,IDC_PADDING_TOP   ,padding.top   ,false);
        SetDlgItemInt(Dialog,IDC_PADDING_RIGHT ,padding.right ,false);
        SetDlgItemInt(Dialog,IDC_PADDING_BOTTOM,padding.bottom,false);

        if (BkMode and frbkCenterX     )<>0 then CheckDlgButton(Dialog,IDC_CENTERX ,BST_CHECKED);
        if (BkMode and frbkCenterY     )<>0 then CheckDlgButton(Dialog,IDC_CENTERY ,BST_CHECKED);
        if (BkMode and frbkTileX       )<>0 then CheckDlgButton(Dialog,IDC_TILEX   ,BST_CHECKED);
        if (BkMode and frbkTileY       )<>0 then CheckDlgButton(Dialog,IDC_TILEY   ,BST_CHECKED);
        if (BkMode and frbkStretchX    )<>0 then CheckDlgButton(Dialog,IDC_STRETCHX,BST_CHECKED);
        if (BkMode and frbkStretchY    )<>0 then CheckDlgButton(Dialog,IDC_STRETCHY,BST_CHECKED);
        if (BkMode and frbkProportional)<>0 then CheckDlgButton(Dialog,IDC_PROP    ,BST_CHECKED);
        if (BkMode and frbkBottom      )<>0 then CheckDlgButton(Dialog,IDC_BOTTOM  ,BST_CHECKED);
        if (BkMode and frbkRight       )<>0 then CheckDlgButton(Dialog,IDC_RIGHT   ,BST_CHECKED);
      end;
      SwitchBk(Dialog);

      changed:=0;
    end;

    WM_HSCROLL: begin
      SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
      changed:=2;
    end;

    WM_COMMAND: begin
      if (wParam shr 16)=BN_CLICKED then
      begin
        case LoWord(wParam) of
          IDC_HIDEFRAMEPLAYER: begin
            if IsDlgButtonChecked(Dialog,IDC_HIDEFRAMEPLAYER)<>BST_UNCHECKED then
              redraw:=true
            else
              redraw:=false;
            EnableWindow(GetDlgItem(Dialog,IDC_HIDEFRAMEMUSIC),redraw);
          end;

          IDC_FRMUSEPIC: begin
            SwitchBk(Dialog);
          end;

          IDC_FRMPICBTN: begin
            pcw:=MakePicFilter;
            tmpPicName:=GetDlgText(Dialog,IDC_FRMBKPIC);
            mGetMem(buf,1024);
            if ShowDlgW(pWideChar(buf),tmpPicName,pcw) then
              SetDlgItemTextW(Dialog,IDC_FRMBKPIC,pWideChar(buf));
            mFreeMem(buf);
            mFreeMem(tmpPicName);
            mFreeMem(pcw);
          end;
        end;
      end;

      if ((wParam shr 16)=BN_CLICKED) or
         ((wParam shr 16)=EN_CHANGE) or
         ((wParam shr 16)=CPN_COLOURCHANGED) then
      begin
        SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
        changed:=2;
      end;
    end;

    WM_NOTIFY: begin
      if (PNMHdr(lParam)^.code=PSN_APPLY) and (changed>0) then
      begin
        redraw:=false;
        with FrameCtrl^ do
        begin
          // Alpha channel
          tmp:=SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_GETPOS,0,0);
          if Cardinal(tmp)<>FrmAlpha then
          begin
            FrmAlpha:=tmp;
            if FrameId>=0 then
//              SendMessage(FrameWnd,WM_WAREFRESH,frcSetAlpha,0);
          end;

          // show/hide controls
          tmp:=0;
          if IsDlgButtonChecked(Dialog,IDC_SHOWCTRLS)<>BST_UNCHECKED then tmp:=tmp or scButtons;
          if IsDlgButtonChecked(Dialog,IDC_SHOWBAR  )<>BST_UNCHECKED then tmp:=tmp or scTrackBar;
          if IsDlgButtonChecked(Dialog,IDC_SHOWTEXT )<>BST_UNCHECKED then tmp:=tmp or scText;
          if IsDlgButtonChecked(Dialog,IDC_SHOWVOLUM)<>BST_UNCHECKED then tmp:=tmp or scVolume;
          if IsDlgButtonChecked(Dialog,IDC_BTNGAP   )<>BST_UNCHECKED then tmp:=tmp or scGap;

          tmp1:=0; // mask, what was changed
          if ((ShowControls and scText    )<>0) xor ((tmp and scText    )<>0) then tmp1:=tmp1 or scText;
          if ((ShowControls and scButtons )<>0) xor ((tmp and scButtons )<>0) then tmp1:=tmp1 or scButtons;
          if ((ShowControls and scTrackBar)<>0) xor ((tmp and scTrackBar)<>0) then tmp1:=tmp1 or scTrackBar;
          if ((ShowControls and scVolume  )<>0) xor ((tmp and scVolume  )<>0) then tmp1:=tmp1 or scVolume;
          ShowControls:=tmp;
(*  {}
          if (tmp1<>0) and (FrameId>=0) then
            SendMessage(FrameWnd,WM_WAREFRESH,frcShowHide,tmp1);
  {}
          if (FrameId>=0) and ((tmp1<>0) or redraw) then
          begin
            SendMessage(FrameWnd,WM_SIZE,0,0);
            redraw:=false;
          end;
*)  {}
          // Frame background
          tmp1:=0;
          tmpb:=IsDlgButtonChecked(Dialog,IDC_USECOVER)<>BST_UNCHECKED;
          if tmpb<>UseCover then
          begin
            UseCover:=tmpb;
            tmp1:=1;
          end;
          tmpb:=IsDlgButtonChecked(Dialog,IDC_FRMUSEPIC)<>BST_UNCHECKED;
          if tmpb<>UseBkPicture then
          begin
            UseBkPicture:=tmpb;
            tmp1:=1;
          end;
          tmp:=SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_GETCOLOUR,0,0);
          if tmp<>BkColor then
          begin
            BkColor:=tmp;
            tmp1:=1;
          end;

          mGetMem(buf1,1024{*SizeOf(WideChar)});
          buf1^:=#0;
          buf:=GetDlgText(Dialog,IDC_FRMBKPIC,true);
          PluginLink^.CallService(MS_UTILS_PATHTORELATIVE,dword(buf),dword(buf1));
          if StrCmp(buf1,BkDefFile)<>0 then
          begin
            mFreeMem(BkDefFile);
            StrDup(BkDefFile,buf1);
            tmp1:=1;
          end;
          mFreeMem(buf);
          mFreeMem(buf1);

          // Picture effects
          tmp:=0;
          if IsDlgButtonchecked(Dialog,IDC_CENTERX )<>BST_UNCHECKED then tmp:=tmp or frbkCenterX;
          if IsDlgButtonchecked(Dialog,IDC_CENTERY )<>BST_UNCHECKED then tmp:=tmp or frbkCenterY;
          if IsDlgButtonchecked(Dialog,IDC_BOTTOM  )<>BST_UNCHECKED then tmp:=tmp or frbkBottom;
          if IsDlgButtonchecked(Dialog,IDC_RIGHT   )<>BST_UNCHECKED then tmp:=tmp or frbkRight;
          if IsDlgButtonchecked(Dialog,IDC_TILEX   )<>BST_UNCHECKED then tmp:=tmp or frbkTileX;
          if IsDlgButtonchecked(Dialog,IDC_TILEY   )<>BST_UNCHECKED then tmp:=tmp or frbkTileY;
          if IsDlgButtonchecked(Dialog,IDC_STRETCHX)<>BST_UNCHECKED then tmp:=tmp or frbkStretchX;
          if IsDlgButtonchecked(Dialog,IDC_STRETCHY)<>BST_UNCHECKED then tmp:=tmp or frbkStretchY;
          if IsDlgButtonchecked(Dialog,IDC_PROP    )<>BST_UNCHECKED then tmp:=tmp or frbkProportional;

          if (tmp<>BkMode) or (tmp1<>0) then
          begin
            BkMode:=tmp;
            if FrameId>=0 then
            begin
//              SendMessage(FrameWnd,WM_WAREFRESH,frcBackPic,0);
              redraw:=true;
            end;
          end;

          // Hide frame option
          tmpb :=IsDlgButtonChecked(Dialog,IDC_HIDEFRAMEPLAYER)<>BST_UNCHECKED;
          if tmpb<>HideNoPlayer then
          begin
            HideNoPlayer:=tmpb;
            tmp1:=1;
          end;
          tmpb:=IsDlgButtonChecked(Dialog,IDC_HIDEFRAMEMUSIC)<>BST_UNCHECKED;
          if tmpb<>HideNoMusic then
          begin
            HideNoMusic:=tmpb;
            tmp1:=1;
          end;

{
          if (tmp<>HideNoPlayer) or (tmp1<>HideNoMusic) then
          begin
            HideNoMusic :=tmp1;
            HideNoPlayer:=tmp;
            tmp:=CallService(MS_WAT_GETMUSICINFO,0,0);
            if (FrameId>=0) and
               (((HideNoPlayer<>BST_UNCHECKED) and (integer(tmp)=WAT_PLS_NOTFOUND)) or
               (( HideNoMusic <>BST_UNCHECKED) and (tmp<>WAT_PLS_NORMAL))) then
              HideFrame
            else
              ShowFrame;
          end;
}
          // Padding
          tmp:=GetDlgItemInt(Dialog,IDC_PADDING_LEFT,tmpb,false);
          if integer(tmp)<>padding.left then
          begin
            padding.left:=tmp;
            redraw:=true;
          end;
          tmp:=GetDlgItemInt(Dialog,IDC_PADDING_TOP,tmpb,false);
          if integer(tmp)<>padding.top then
          begin
            padding.top:=tmp;
            redraw:=true;
          end;
          tmp:=GetDlgItemInt(Dialog,IDC_PADDING_RIGHT,tmpb,false);
          if integer(tmp)<>padding.right then
          begin
            padding.right:=tmp;
            redraw:=true;
          end;
          tmp:=GetDlgItemInt(Dialog,IDC_PADDING_BOTTOM,tmpb,false);
          if integer(tmp)<>padding.bottom then
          begin
            padding.bottom:=tmp;
            redraw:=true;
          end;

          tmp:=GetDlgItemInt(Dialog,IDC_TIMER,tmpb,false);
          if tmp>0 then
          begin
            if tmp<100 then
              tmp:=tmp*1000;
            if tmp<200 then
              tmp:=200;
          end;

          if tmp<>UpdInterval then
          begin
            UpdInterval:=tmp;
{
            if hFrmTimer<>0 then // FrameWnd MUST be present
              KillTimer(FrameWnd,hFrmTimer);
            if (vFrmTimer>0) and (FrameWnd<>0) then
            begin
              hFrmTimer:=SetTimer(FrameWnd,TMR_FRAME,vFrmTimer,nil);
              SendMessage(FrameWnd,WM_WAREFRESH,frcTimer,0);
            end
            else
              hFrmTimer:=0;
}
          end;

        end;
{
        if FrameId>=0 then
        begin
          if (not IsFrameHidden) and redraw then
          begin
            InvalidateRect(FrameWnd,nil,true);
            UpdateWindow(FrameWnd);
          end;
        end;
}
        FrameCtrl.SaveSettings;
      end;
    end;
  else
    {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;
