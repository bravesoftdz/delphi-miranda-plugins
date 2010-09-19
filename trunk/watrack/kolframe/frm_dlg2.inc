{Frame}

function FrameTextDlg(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
const
  DlgInited:boolean=false;
var
  tmp,tmp1:integer;
  tmpb:longbool;
  pcf:TCHOOSEFONT;
  lf:LOGFONT;
  redraw:boolean;
begin
  result:=0;
  case hMessage of
    WM_INITDIALOG: begin
      DlgInited:=false;
      TranslateDialogDefault(Dialog);
      case TextEffect of
        effWrap: tmp:=IDC_EFF_WRAP;
        effRoll: tmp:=IDC_EFF_ROLL;
        effPong: tmp:=IDC_EFF_PONG;
      else // like effCut
        tmp:=IDC_EFF_CUT;
      end;
      CheckDlgButton(Dialog,tmp,BST_CHECKED);

      SetDlgItemInt(Dialog,IDC_TIMER,vTxtTimer,false);

      SetDlgItemInt(Dialog,IDC_ROLLSTEP,RollStep,false);
      SetDlgItemInt(Dialog,IDC_ROLLGAP ,RollGap ,false);
//      SetDlgItemInt(Dialog,IDC_ROLLTAIL,RollTail,false);

      CheckDlgButton(Dialog,IDC_ALCENTER,AlignCenter);

      SetDlgItemTextW(Dialog,IDC_FRAME_TEXT,Template);

      SendDlgItemMessage(Dialog,IDC_MACRO_HELP,BM_SETIMAGE,IMAGE_ICON,
          CallService(MS_SKIN_LOADICON,SKINICON_OTHER_HELP,0));

      DlgInited:=true;
    end;

    WM_COMMAND: begin
      if (wParam shr 16)=BN_CLICKED then
      begin
        case LoWord(wParam) of
          IDC_MACRO_HELP: CallService(MS_WAT_MACROHELP,Dialog,0);
          IDC_FRMFONT: begin
            move(TextLF,lf,SizeOf(LOGFONT));
            FillChar(pcf,sizeOf(pcf),0);
            with pcf do
            begin
              lStructSize:=SizeOf(pcf);
              lpLogFont:=@lf;
              Flags:=CF_EFFECTS+CF_FORCEFONTEXIST+CF_LIMITSIZE+CF_NOVERTFONTS+
                     CF_SCREENFONTS+CF_INITTOLOGFONTSTRUCT;
              rgbColors:=TextColor;
              nSizeMin:=6;
              nSizeMax:=32;
            end;
            if ChooseFont(pcf) then
            begin
              move(lf,TextLF,SizeOf(LOGFONT));
              TextColor:=pcf.rgbColors;
              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
            end
            else
              exit;
          end;
        end;
      end;
      if DlgInited then
        case wParam shr 16 of
          BN_CLICKED,
          EN_CHANGE: begin
//          if ((wParam shr 16)=EN_CHANGE) and (loword(wParam)=IDC_FRMTEXT) then
//          Changed:=Changed or DLGED_CHGD or DLGED_PACK;
            SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
          end;
        end;
    end;

    WM_NOTIFY: begin
      if PNMHdr(lParam)^.code=PSN_APPLY then
      begin
        redraw:=false;

        tmp:=GetDlgItemInt(Dialog,IDC_TIMER,tmpb,false);
        if tmp>MaxTxtScrollSpeed then
          tmp:=MaxTxtScrollSpeed;
{!
        if dword(tmp)<>vTxtTimer then
        begin
          vTxtTimer:=tmp;
          if hTxtTimer<>0 then
            KillTimer(FrameWnd,hTxtTimer);
          if (vTxtTimer>0) and (FrameWnd<>0) then
            hTxtTimer:=SetTimer(FrameWnd,TMR_TEXT,(MaxTxtScrollSpeed+1-vTxtTimer)*100,nil)
          else
            hTxtTimer:=0;
        end;
}
        // Text effects
        if      IsDlgButtonChecked(Dialog,IDC_EFF_CUT )<>BST_UNCHECKED then tmp:=effCut
        else if IsDlgButtonChecked(Dialog,IDC_EFF_WRAP)<>BST_UNCHECKED then tmp:=effWrap
        else if IsDlgButtonChecked(Dialog,IDC_EFF_ROLL)<>BST_UNCHECKED then tmp:=effRoll
        else if IsDlgButtonChecked(Dialog,IDC_EFF_PONG)<>BST_UNCHECKED then tmp:=effPong;
        if dword(tmp)<>TextEffect then
        begin
          TextEffect:=tmp;
{!
        if ((tmp=effRoll) or (tmp=effPong)) and
           ((TextEffect=effCut) or (TextEffect=effWrap)) then
          begin
            if (vTxtTimer>0) and (FrameWnd<>0) then
              hTxtTimer:=SetTimer(FrameWnd,TMR_TEXT,(MaxTxtScrollSpeed+1-vTxtTimer)*100,nil)
          end;
        if ((TextEffect=effRoll) or (TextEffect=effPong)) and
           ((tmp=effCut) or (tmp=effWrap)) then
        begin
          if hTxtTimer<>0 then
            KillTimer(0,hTxtTimer);
          hTxtTimer:=0;
        end;
}
{!
          if (ShowControls and scShowText)<>0 then
            redraw:=true;
}        end;

        tmp1:=GetDlgItemInt(Dialog,IDC_ROLLSTEP,tmpb,false);
        if tmp1<>RollStep then
        begin
          RollStep:=tmp1;
          redraw:=true;
        end;
        tmp1:=GetDlgItemInt(Dialog,IDC_ROLLGAP ,tmpb,false);
        if tmp1<>RollGap then
        begin
          RollGap:=tmp1;
          redraw:=true;
        end;
{
        tmp1:=GetDlgItemInt(Dialog,IDC_ROLLTAIL,tmpb,false);
        if tmp1<>RollTail then
        begin
          RollTail:=tmp1;
          redraw:=true;
        end;
}
        tmp1:=IsDlgButtonChecked(Dialog,IDC_ALCENTER);
        if dword(tmp1)<>AlignCenter then
        begin
          AlignCenter:=tmp1;
          redraw:=true;
        end;

        mFreeMem(Template);
        Template:=GetDlgText(Dialog,IDC_FRAME_TEXT);
//      WAFrameProc(Dialog,WM_WAREFRESH,frcForce,0);
{!
        if FrameId>=0 then
        begin
          if (not IsFrameHidden) and redraw then
          begin
            InvalidateRect(FrameWnd,nil,true);
            UpdateWindow(FrameWnd);
          end;
        end;
}
        pTxtBlockData(FrameCtrl.TextBlock.CustomObj).SaveSettings;
      end;
    end;
  else
    {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;
