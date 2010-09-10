{Frame}

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

function DlgProcOptions5(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
var
  tmp,tmp1:cardinal;
  buf1:PAnsiChar;
  buf:PAnsiChar;
  p:PAnsiChar;
  redraw:boolean;
  tmpb:longbool;
  tmpBuf2:pWideChar;
begin
  result:=0;
  mGetMem(buf,1024{*SizeOf(WideChar)});
  case hMessage of
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
//      Changed:=DLGED_INIT;
      SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_SETRANGE,0,MAKELONG(0,255));
      SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_SETPOS,1,FrmAlpha);
      if (ShowControls and scShowButtons)<>0 then
        CheckDlgButton(Dialog,IDC_SHOWCTRLS,BST_CHECKED);
      if (ShowControls and scShowTrackBar)<>0 then
        CheckDlgButton(Dialog,IDC_SHOWBAR,BST_CHECKED);
      if (ShowControls and scShowText)<>0 then
        CheckDlgButton(Dialog,IDC_SHOWTEXT,BST_CHECKED);
      if (ShowControls and scShowVolume)<>0 then
        CheckDlgButton(Dialog,IDC_SHOWVOLUM,BST_CHECKED);
      CheckDlgButton(Dialog,IDC_TRACKBAR,StyledTrack);
      CheckDlgButton(Dialog,IDC_BTNGAP,ButtonGap);
      CheckDlgButton(Dialog,IDC_HIDEFRAMEPLAYER,HideFrameNoPlayer);
      CheckDlgButton(Dialog,IDC_HIDEFRAMEMUSIC ,HideFrameNoMusic);
      if HideFrameNoPlayer=BST_CHECKED then
        redraw:=true
      else
        redraw:=false;
      EnableWindow(GetDlgItem(Dialog,IDC_HIDEFRAMEMUSIC),redraw);

      SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_SETCOLOUR,0,FrmBkColor);
      SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_SETDEFAULTCOLOUR,0,GetSysColor(COLOR_BTNFACE));
      SetDlgItemInt(Dialog,IDC_FRMCOLOR,FrmBkColor,false);
      if FrmUsePic<>BST_UNCHECKED then
        CheckDlgButton(Dialog,IDC_FRMUSEPIC,FrmUsePic);
      if FrmBkPic=nil then
        p:=''
      else
        p:=FrmBkPic;
      SetDlgItemTextA(Dialog,IDC_FRMBKPIC,p);
      CheckDlgButton(Dialog,IDC_USECOVER,FrmUseCover);

      tmp:=vFrmTimer;
      if (tmp>=1000) and (tmp mod 1000=0) then
        tmp:=tmp div 1000;
      SetDlgItemInt(Dialog,IDC_TIMER,tmp,false);

      SetDlgItemInt(Dialog,IDC_PADDING_LEFT  ,padding.left  ,false);
      SetDlgItemInt(Dialog,IDC_PADDING_TOP   ,padding.top   ,false);
      SetDlgItemInt(Dialog,IDC_PADDING_RIGHT ,padding.right ,false);
      SetDlgItemInt(Dialog,IDC_PADDING_BOTTOM,padding.bottom,false);

      if (FrmBkMode and frbkCenterX     )<>0 then CheckDlgButton(Dialog,IDC_CENTERX ,BST_CHECKED);
      if (FrmBkMode and frbkCenterY     )<>0 then CheckDlgButton(Dialog,IDC_CENTERY ,BST_CHECKED);
      if (FrmBkMode and frbkTileX       )<>0 then CheckDlgButton(Dialog,IDC_TILEX   ,BST_CHECKED);
      if (FrmBkMode and frbkTileY       )<>0 then CheckDlgButton(Dialog,IDC_TILEY   ,BST_CHECKED);
      if (FrmBkMode and frbkStretchX    )<>0 then CheckDlgButton(Dialog,IDC_STRETCHX,BST_CHECKED);
      if (FrmBkMode and frbkStretchY    )<>0 then CheckDlgButton(Dialog,IDC_STRETCHY,BST_CHECKED);
      if (FrmBkMode and frbkProportional)<>0 then CheckDlgButton(Dialog,IDC_PROP    ,BST_CHECKED);
      if (FrmBkMode and frbkBottom      )<>0 then CheckDlgButton(Dialog,IDC_BOTTOM  ,BST_CHECKED);
      if (FrmBkMode and frbkRight       )<>0 then CheckDlgButton(Dialog,IDC_RIGHT   ,BST_CHECKED);
      SwitchBk(Dialog);
      result:=0;
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
            AnsiToWide(FrmBkPic,tmpBuf2);
            if ShowDlgW(pWideChar(buf),tmpBuf2,BMPFilter) then
              SetDlgItemTextW(Dialog,IDC_FRMBKPIC,pWideChar(buf));
            mFreeMem(tmpBuf2);
          end;
        end;
      end;
      if ((wParam shr 16)=BN_CLICKED) or {((Changed and DLGED_INIT)=0) and}
         ((wParam shr 16)=EN_CHANGE) or
         ((wParam shr 16)=CPN_COLOURCHANGED) then
      begin
//        Changed:=Changed or DLGED_CHGD or DLGED_PACK;
        SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
        changed:=2;
      end;
    end;

    WM_NOTIFY: begin
      if (PNMHdr(lParam)^.code=PSN_APPLY) and (changed>0) then
      begin
        redraw:=false;
        // Alpha channel
        tmp:=SendDlgItemMessage(Dialog,IDC_FRMALPHA,TBM_GETPOS,0,0);
        if tmp<>FrmAlpha then
        begin
          FrmAlpha:=tmp;
          if FrameId>=0 then
            SendMessage(FrameWnd,WM_WAREFRESH,frcSetAlpha,0);
        end;
        // show/hide controls
        tmp:=0;
        if IsDlgButtonChecked(Dialog,IDC_SHOWCTRLS)<>BST_UNCHECKED then
          tmp:=tmp or scShowButtons;
        if IsDlgButtonChecked(Dialog,IDC_SHOWBAR  )<>BST_UNCHECKED then
          tmp:=tmp or scShowTrackBar;
        if IsDlgButtonChecked(Dialog,IDC_SHOWTEXT )<>BST_UNCHECKED then
          tmp:=tmp or scShowText;
        if IsDlgButtonChecked(Dialog,IDC_SHOWVOLUM)<>BST_UNCHECKED then
          tmp:=tmp or scShowVolume;
        tmp1:=0;
        if ((ShowControls and scShowText    )<>0) xor ((tmp and scShowText    )<>0) then
          tmp1:=scShowText;
        if ((ShowControls and scShowButtons )<>0) xor ((tmp and scShowButtons )<>0) then
          tmp1:=tmp1 or scShowButtons;
        if ((ShowControls and scShowTrackBar)<>0) xor ((tmp and scShowTrackBar)<>0) then
          tmp1:=tmp1 or scShowTrackBar;
        if ((ShowControls and scShowVolume  )<>0) xor ((tmp and scShowVolume  )<>0) then
          tmp1:=tmp1 or scShowVolume;
        ShowControls:=tmp;
        if (tmp1<>0) and (FrameId>=0) then
          SendMessage(FrameWnd,WM_WAREFRESH,frcShowHide,tmp1);
        // buttons
        tmp:=IsDlgButtonchecked(Dialog,IDC_BTNGAP);
        if tmp<>ButtonGap then
        begin
          ButtonGap:=tmp;
          redraw:=true;
        end;
        if (FrameId>=0) and ((tmp1<>0) or redraw) then
        begin
          SendMessage(FrameWnd,WM_SIZE,0,0);
          redraw:=false;
        end;
        // Frame background
        tmp1:=0;
        tmp:=IsDlgButtonChecked(Dialog,IDC_USECOVER);
        if tmp<>FrmUseCover then
        begin
          FrmUseCover:=tmp;
          tmp1:=1;
        end;
        tmp:=IsDlgButtonChecked(Dialog,IDC_FRMUSEPIC);
        if tmp<>FrmUsePic then
        begin
          FrmUsePic:=tmp;
          tmp1:=1;
        end;
        tmp:=SendDlgItemMessage(Dialog,IDC_FRMCOLOR,CPM_GETCOLOUR,0,0);
        if tmp<>FrmBkColor then
        begin
          FrmBkColor:=tmp;
          tmp1:=1;
          if FrameId>=0 then
          begin
            DeleteObject(FrmBrush);
            FrmBrush:=CreateSolidBrush(FrmBkColor);
          end;
        end;
        mGetMem(buf1,1024{*SizeOf(WideChar)});
        buf^ :=#0;
        buf1^:=#0;
        GetDlgItemTextA(Dialog,IDC_FRMBKPIC,buf,1024);
        PluginLink^.CallService(MS_UTILS_PATHTORELATIVE,dword(buf),dword(buf1));
        if StrCmp(buf1,FrmBkPic)<>0 then
        begin
          mFreeMem(FrmBkPic);
          StrDup(FrmBkPic,buf1);
          tmp1:=1;
        end;
        mFreeMem(buf1);
        // Picture effects
        tmp:=0;
        if IsDlgButtonchecked(Dialog,IDC_CENTERX)<>BST_UNCHECKED then
          tmp:=tmp or frbkCenterX;
        if IsDlgButtonchecked(Dialog,IDC_CENTERY)<>BST_UNCHECKED then
          tmp:=tmp or frbkCenterY;

//        if (tmp and frbkCenterY)=0 then
          if IsDlgButtonchecked(Dialog,IDC_BOTTOM)<>BST_UNCHECKED then
            tmp:=tmp or frbkBottom;

//        if (tmp and frbkCenterX)=0 then
          if IsDlgButtonchecked(Dialog,IDC_RIGHT)<>BST_UNCHECKED then
            tmp:=tmp or frbkRight;

//        if ((tmp and frbkCenterX)=0) and
//           ((tmp and frbkRight  )=0) then
          if IsDlgButtonchecked(Dialog,IDC_TILEX)<>BST_UNCHECKED then
            tmp:=tmp or frbkTileX;

//        if ((tmp and frbkCenterY)=0) and
//           ((tmp and frbkBottom )=0) then
          if IsDlgButtonchecked(Dialog,IDC_TILEY)<>BST_UNCHECKED then
            tmp:=tmp or frbkTileY;

//        if ((tmp and frbkTileX  )=0) and
//           ((tmp and frbkCenterX)=0) and
//           ((tmp and frbkRight  )=0) then
          if IsDlgButtonchecked(Dialog,IDC_STRETCHX)<>BST_UNCHECKED then
            tmp:=tmp or frbkStretchX;

//        if ((tmp and frbkTileY  )=0) and
//           ((tmp and frbkCenterY)=0) and
//           ((tmp and frbkBottom )=0) then
          if IsDlgButtonchecked(Dialog,IDC_STRETCHY)<>BST_UNCHECKED then
            tmp:=tmp or frbkStretchY;

        if (tmp and frbkStretch)<>0 then
          if IsDlgButtonchecked(Dialog,IDC_PROP)<>BST_UNCHECKED then
            tmp:=tmp or frbkProportional;
        if (tmp<>FrmBkMode) or (tmp1<>0) then
        begin
          FrmBkMode:=tmp;
          if FrameId>=0 then
          begin
            SendMessage(FrameWnd,WM_WAREFRESH,frcBackPic,0);
            redraw:=true;
          end;
        end;

        // Trackbar
        StyledTrack:=IsDlgButtonChecked(Dialog,IDC_TRACKBAR);
        if FrameWnd<>0 then
        begin
          tmp:=GetDlgItem(FrameWnd,IDC_FRM_POS);
          if StyledTrack=BST_UNCHECKED then
          begin
            SetWindowLong(tmp,GWL_EXSTYLE,
                GetWindowLong(tmp,GWL_EXSTYLE) and not WS_EX_TRANSPARENT);
          end
          else
          begin
            SetWindowLong(tmp,GWL_EXSTYLE,
                GetWindowLong(tmp,GWL_EXSTYLE) or WS_EX_TRANSPARENT);
          end;
          InvalidateRect(tmp,nil,true);
//          SendMessage(tmp,WM_SIZE,0,0);
        end;

        // Hide frame option
        tmp :=IsDlgButtonChecked(Dialog,IDC_HIDEFRAMEPLAYER);
        tmp1:=IsDlgButtonChecked(Dialog,IDC_HIDEFRAMEMUSIC);
        if (tmp<>HideFrameNoPlayer) or (tmp1<>HideFrameNoMusic) then
        begin
          HideFrameNoMusic :=tmp1;
          HideFrameNoPlayer:=tmp;
          tmp:=CallService(MS_WAT_GETMUSICINFO,0,0);
          if (FrameId>=0) and
             (((HideFrameNoPlayer<>BST_UNCHECKED) and (integer(tmp)=WAT_PLS_NOTFOUND)) or
             (( HideFrameNoMusic <>BST_UNCHECKED) and (tmp<>WAT_PLS_NORMAL))) then
            HideFrame
          else
            ShowFrame;
        end;

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
        if tmp<>vFrmTimer then
        begin
          vFrmTimer:=tmp;
          if hFrmTimer<>0 then // FrameWnd MUST be present
            KillTimer(FrameWnd,hFrmTimer);
          if (vFrmTimer>0) and (FrameWnd<>0) then
          begin
            hFrmTimer:=SetTimer(FrameWnd,TMR_FRAME,vFrmTimer,nil);
            SendMessage(FrameWnd,WM_WAREFRESH,frcTimer,0);
          end
          else
            hFrmTimer:=0;
        end;

        if FrameId>=0 then
        begin
          if (not IsFrameHidden) and redraw then
          begin
            InvalidateRect(FrameWnd,nil,true);
            UpdateWindow(FrameWnd);
          end;
        end;

        saveframe;
      end;
    end;
  else
    {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
  mFreeMem(buf);
end;
