{}
(*
procedure ClearInfo(dlg:HWND);
begin
  SetDlgItemTextW(dlg,IDC_DATA_ARTIST,'');
  SetDlgItemTextW(dlg,IDC_DATA_ALBUM ,'');
  SetDlgItemTextW(dlg,IDC_DATA_TRACK ,'');
  SetDlgItemTextW(dlg,IDC_DATA_TAGS  ,'');
  SetDlgItemTextW(dlg,IDC_DATA_INFO  ,'');
end;

procedure ClearData(data:tLastFMInfo);
begin
  mFreeMem(data.artist);
  mFreeMem(data.album);
  mFreeMem(data.title);
  mFreeMem(data.tags);
  mFreeMem(data.info);
  mFreeMem(data.image);
end;
*)
function DlgProcOptions(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  tmp:longbool;
  bmp,wnd:HWND;
  lang:integer;
//  data:tMyShowsInfo;
begin
  result:=0;
  case hMessage of
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);

      SetDlgItemTextA(Dialog,IDC_LOGIN,msh_login);
      SetDlgItemTextA(Dialog,IDC_PASS ,msh_password);
      SetDlgItemInt  (Dialog,IDC_TRIES,msh_tries,false);
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
         BN_CLICKED: begin
//           ClearInfo(Dialog);
//           FillChar(data,SizeOf(data),0);
{
           if loword(wParam)=IDC_INFO_ARTIST then
           begin
             SetDlgItemTextW(Dialog,IDC_ALT,TranslateW('Similar artists'));
             GetArtistInfo(data,msh_lang);
             SetDlgItemTextW(Dialog,IDC_DATA_ALBUM,data.similar);
           end
           else
           begin
             SetDlgItemTextW(Dialog,IDC_ALT,TranslateW('Album'));
             if loword(wParam)=IDC_INFO_TRACK then
               GetTrackInfo (data,msh_lang)
             else
               GetAlbumInfo (data,msh_lang);
             SetDlgItemTextW(Dialog,IDC_DATA_ALBUM,data.album);
           end;
}
{
           SetDlgItemTextW(Dialog,IDC_DATA_ARTIST,data.artist);
           SetDlgItemTextW(Dialog,IDC_DATA_TRACK ,data.title);
           SetDlgItemTextW(Dialog,IDC_DATA_TAGS  ,data.tags);
           SetDlgItemTextW(Dialog,IDC_DATA_INFO  ,data.info);
}
{
           bmp:=LoadImageURL(data.image,64);
           if bmp<>0 then
             DeleteObject(SendDlgItemMessage(Dialog,IDC_DATA_PIC,STM_SETIMAGE,IMAGE_BITMAP,bmp));
}
//           ClearData(data);
         end;
         EN_CHANGE: 
           case loword(wParam) of
             IDC_LOGIN,IDC_PASS,IDC_TRIES:
               SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
           end;
      end;
    end;

    WM_NOTIFY: begin
      if integer(PNMHdr(lParam)^.code)=PSN_APPLY then
      begin
        mFreeMem(msh_login   ); msh_login   :=GetDlgText(Dialog,IDC_LOGIN,true);
        mFreeMem(msh_password); msh_password:=GetDlgText(Dialog,IDC_PASS ,true);
        mFreeMem(session_id);
        mFreeMem(np_url);
        mFreeMem(sub_url);
        msh_tries:=GetDlgItemInt(Dialog,IDC_TRIES,tmp,false);

        SaveOpt;
      end;
    end;
  else
    {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;
