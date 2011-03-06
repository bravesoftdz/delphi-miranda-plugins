{structure editor}
{
  <STE_* set> <len> <data>
}
const
  char_return = '*';
  char_script = '%';
type
  TStructType = record
    typ  :dword;
    short:PWideChar;
    full :PAnsiChar;
  end;
const
  MaxStructTypes = 9;
const
  StructElems: array [0..MaxStructTypes-1] of TStructType = (
    (typ:SST_BYTE ; short:'byte' ; full:'Byte'),
    (typ:SST_WORD ; short:'word' ; full:'Word'),
    (typ:SST_DWORD; short:'dword'; full:'DWord'),
    (typ:SST_BARR ; short:'b.arr'; full:'Byte Array'),
    (typ:SST_WARR ; short:'w.arr'; full:'Word Array'),
    (typ:SST_BPTR ; short:'b.ptr'; full:'Pointer to bytes'),
    (typ:SST_WPTR ; short:'w.ptr'; full:'Pointer to words'),
    (typ:SST_LAST ; short:'last' ; full:'Last result'),
    (typ:SST_PARAM; short:'param'; full:'Parameter'));

const
  STE_BYTE    = $01;
  STE_WORD    = $00;
  STE_DWORD   = $02;
  STE_POINTER = $00;
  STE_ARRAY   = $04;
  STE_LAST    = $08;
  STE_PARAM   = $10;
  STE_RETURN  = $80;

const
  col_type =0;
  col_len  =1;
  col_flag =2;
  col_data =3;
var
  OldLVProc:pointer;

function GetOneElement(txt:pWideChar;var len:integer;var value:pWideChar):integer;
var
  tmp:array [0..31] of WideChar;
  pc:pWideChar;
  i:integer;
begin
  if txt^=char_return then inc(txt);
  if txt^=char_script then inc(txt);

  pc:=StrScanW(txt,' ');
  StrCopyW(tmp,txt,pc-txt);

  i:=0;
  while i<MaxStructTypes do
  begin
    if StrCmpW(tmp,StructElems[i].short)=0 then //!!
      break;
    inc(i);
  end;
  result:=StructElems[i].typ;
  case result of
    SST_LAST,SST_PARAM: ;
    SST_BYTE,SST_WORD,SST_DWORD: begin
      value:=pc+1;
    end;
    SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
      len:=StrToInt(pc+1);
      txt:=pc+1;
      pc:=StrScanW(txt,' ');
      if (pc<>txt) and (pc<>nil) then
        value:=pc+1
      else
        value:=nil;
    end;
  end;

  case result of
    SST_LAST,SST_PARAM: len:=4;
    SST_BYTE : len:=1;
    SST_WORD : len:=2;
    SST_DWORD: len:=4;
//    SST_BARR : len:=len;
    SST_WARR : len:=len;
//    SST_BPTR,SST_WPTR: len:=4;
  end;
end;

procedure TranslateBlob(dst:pByte;src:pWideChar;isbyte:boolean);
var
  buf:array [0..9] of AnsiChar;
  p,pc:pAnsiChar;
begin
  if isbyte then
  begin
    dst^:=0;
    WideToAnsi(src,pc,MirandaCP);
    p:=pc;
    buf[2]:=#0;
    while pc^<>#0 do
    begin
      if (pc^='$') and ((pc+1)^ in sHexNum) and ((pc+2)^ in sHexNum) then
      begin
        buf[0]:=(pc+1)^;
        buf[1]:=(pc+2)^;
        inc(pc,2);
        dst^:=HexToInt(buf);
      end
      else
        dst^:=ord(pc^);
      inc(pc);
      inc(dst);
    end;
    mFreeMem(p);
  end
  else // u
  begin
    pWideChar(dst)^:=#0;
    pWideChar(@buf)[4]:=#0;
    while src^<>#0 do
    begin
      if (src^='$') and
         (ord((src+1)^)<255) and (AnsiChar((src+1)^)in sHexNum) and
         (ord((src+2)^)<255) and (AnsiChar((src+2)^)in sHexNum) then
      begin
        pWideChar(@buf)[0]:=(src+1)^;
        pWideChar(@buf)[1]:=(src+2)^;
        if (ord((src+3)^)<255) and (AnsiChar((src+3)^)in sHexNum) and
           (ord((src+4)^)<255) and (AnsiChar((src+4)^)in sHexNum) then
        begin
          pWideChar(@buf)[2]:=(src+3)^;
          pWideChar(@buf)[3]:=(src+4)^;
          pWord(dst)^:=HexToInt(pWideChar(@buf));
          inc(src,4);
        end
        else
        begin
          pWideChar(@buf)[2]:=#0;
          dst^:=HexToInt(buf);
          dec(dst);
          inc(src,2);
        end;
      end
      else
        pWideChar(dst)^:=src^;
      inc(src);
      inc(dst,2);
    end;
  end;
end;

function MakeStructure(txt:dword;aparam,alast:integer;
         var code,alen,ofs:integer; restype:integer=rtInt):integer;
var
  i,summ,len:integer;
  value,lsrc:pWideChar;
  res:integer;
  ppc,p,pc:pWideChar;
  buf:array [0..31] of WideChar;
  pLast: pWideChar;
begin
  mGetMem(pc,4096);
  ppc:=pc;
  summ:=0;
  lsrc:=pWideChar(txt);
  if restype=rtInt then
    pLast:=IntToStr(buf,alast)
  else
    pLast:=pWideChar(alast);

  while lsrc^<>#0 do
  begin
    p:=StrScanW(lsrc,'|');
    StrCopyW(pc,lsrc,p-lsrc);
    i:=GetOneElement(pc,len,value);
    if (pc^=char_return) and (code<0) then
    begin
      code:=i;
      alen:=len;
      ofs :=summ;
    end;
    if (i=SST_BPTR) or (i=SST_WPTR) then
      len:=4;
    inc(summ,len);
    if p=nil then break;
    lsrc:=p+1;
  end;
  mGetMem (PAnsiChar(result) ,summ);
  FillChar(PAnsiChar(result)^,summ,0);
  res:=result;

  lsrc:=pWideChar(txt);
  while lsrc^<>#0 do
  begin
    p:=StrScanW(lsrc,'|');
    pc:=ppc;
    StrCopyW(pc,lsrc,p-lsrc);
    i:=GetOneElement(pc,len,value);
    if pc^=char_return then inc(pc);
    if pc^=char_script then
    begin
      value:=ParseVarString(value,aparam,pLast);
    end;

    case i of
      SST_LAST: begin
        pDWord(res)^:=alast;
      end;
      SST_PARAM: begin
        pDWord(res)^:=aparam;
      end;
      SST_BYTE: begin
        pByte(res)^:=StrToInt(value);
      end;
      SST_WORD: begin
        pWord(res)^:=StrToInt(value);
      end;
      SST_DWORD: begin
        pDWord(res)^:=StrToInt(value);
      end;
      SST_BARR: begin
        TranslateBlob(pByte(res),value,true);
      end;
      SST_WARR: begin
        TranslateBlob(pByte(res),value,false);
      end;
      SST_BPTR: begin
        if len=0 then
          pDWord(res)^:=0
        else
        begin
          mGetMem (lsrc ,len+1);
          FillChar(lsrc^,len+1,0);
          TranslateBlob(pByte(lsrc),value,true);
          pDWord(res)^:=dword(lsrc);
        end;
        len:=4;
      end;
      SST_WPTR: begin
        if len=0 then
          pDWord(res)^:=0
        else
        begin
          mGetMem (lsrc ,len+2);
          FillChar(lsrc^,len+2,0);
          TranslateBlob(pByte(lsrc),value,false);
          pDWord(res)^:=dword(lsrc);
        end;
        len:=4;
      end;
    end;
    if pc^=char_script then
    begin
      mFreeMem(value);
    end;
    inc(res,len);

    if p=nil then break;
    lsrc:=p+1;
  end;
  mFreeMem(ppc);
end;

procedure FreeStructure(var struct;descr:pWideChar);
var
  summ,len:integer;
  value,lsrc:pWideChar;
  p,pc:pWideChar;
begin
  mGetMem(pc,4096);

  lsrc:=pWideChar(descr);
  summ:=0;
  while lsrc^<>#0 do
  begin
    p:=StrScanW(lsrc,'|');
    StrCopyW(pc,lsrc,p-lsrc);
    case GetOneElement(pc,len,value) of
      SST_BPTR,SST_WPTR: begin
        value:=pWideChar(pAnsiChar(struct)+summ);
        mFreeMem(value);
      end;
    end;
    inc(summ,len);

    if p=nil then break;
    lsrc:=p+1;
  end;
  mFreeMem(pc);

  mFreeMem(struct);
end;

procedure SetDataButtonIcons(Dialog:HWND);
var
  ti:TTOOLINFOW;
  hwndTooltip:HWND;
begin
  hwndTooltip:=CreateWindowW(TOOLTIPS_CLASS,nil,TTS_ALWAYSTIP,
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      Dialog,0,hInstance,nil);

  FillChar(ti,SizeOf(ti),0);
  ti.cbSize  :=sizeof(TOOLINFO);
  ti.uFlags  :=TTF_IDISHWND or TTF_SUBCLASS;
  ti.hwnd    :=dialog;
  ti.hinst   :=hInstance;
  ti.uId     :=GetDlgItem(Dialog,IDC_DATA_NEW);
  ti.lpszText:=TranslateW('New');
  SetIcon(ti.uId,ACI_NEW);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
  ti.uId     :=GetDlgItem(Dialog,IDC_DATA_UP);
  ti.lpszText:=TranslateW('Up');
  SetIcon(ti.uId,ACI_UP);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
  ti.uId     :=GetDlgItem(Dialog,IDC_DATA_DOWN);
  ti.lpszText:=TranslateW('Down');
  SetIcon(ti.uId,ACI_DOWN);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
  ti.uId     :=GetDlgItem(Dialog,IDC_DATA_DELETE);
  ti.lpszText:=TranslateW('Delete');
  SetIcon(ti.uId,ACI_DELETE);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
end;

function NewLVProc(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
begin
  result:=0;
  case hMessage of
    WM_KEYDOWN: begin
      if (lParam and (1 shl 30))=0 then
      begin
        case wParam of
          VK_UP: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              SendMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_DATA_UP,0);
              exit;
            end;
          end;
          VK_DOWN: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              SendMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_DATA_DOWN,0);
              exit;
            end;
          end;
          VK_INSERT: begin
            SendMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_DATA_NEW,0);
            exit;
          end;
          VK_DELETE: begin
            SendMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_DATA_DELETE,0);
            exit;
          end;
        end;
      end;
    end;
  end;
  result:=CallWindowProc(OldLVProc,Dialog,hMessage,wParam,lParam);
end;

function MakeLVStructList(list:HWND):HWND;
var
  lv:LV_COLUMNW;
begin
  SendMessage(list,LVM_SETUNICODEFORMAT,1,0);
  SendMessage(list,LVM_SETEXTENDEDLISTVIEWSTYLE,
    LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or LVS_EX_CHECKBOXES,
    LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or LVS_EX_CHECKBOXES);

  zeromemory(@lv,sizeof(lv));
  lv.mask:=LVCF_WIDTH;
  lv.cx  :=62; SendMessageW(list,LVM_INSERTCOLUMNW,col_type,integer(@lv)); // type
  lv.cx  :=32; SendMessageW(list,LVM_INSERTCOLUMNW,col_len ,integer(@lv)); // length
  lv.cx  :=20; SendMessageW(list,LVM_INSERTCOLUMNW,col_flag,integer(@lv)); // variables flag
  lv.cx  :=72; SendMessageW(list,LVM_INSERTCOLUMNW,col_data,integer(@lv)); // value

  SendMessageW(list,LVM_SETCOLUMNWIDTH,col_data,LVSCW_AUTOSIZE_USEHEADER);

  OldLVProc:=pointer(SetWindowLong(list,GWL_WNDPROC,integer(@NewLVProc)));
  result:=list;
end;

procedure FillDataTypeList(wnd:HWND);
var
  i:integer;
begin
  SendMessage(wnd,CB_RESETCONTENT,0,0);

  for i:=0 to MaxStructTypes-1 do
    InsertString(wnd,StructElems[i].typ,StructElems[i].full);

  SendMessage(wnd,CB_SETCURSEL,0,0);
end;

//----- Data show -----

function InsertLVLine(list:HWND):integer;
var
  li:TLVITEMW;
begin
  li.mask    :=0;//LVIF_PARAM;
  li.iItem   :=SendMessage(list,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)+1;
  li.iSubItem:=0;
  result:=SendMessageW(list,LVM_INSERTITEMW,0,dword(@li));
end;

procedure FillLVLine(list:HWND;item:integer;txt:pWideChar);
var
  tmp,tmp1:array [0..31] of WideChar;
  li:TLVITEMW;
  i,j:integer;
  pc:pWideChar;
  lscript:boolean;
begin
  if txt^=char_return then
  begin
    inc(txt);
    ListView_SetCheckState(list,item,true);
  end;

  if txt^=char_script then
  begin
    inc(txt);
    lscript:=true;
  end
  else
    lscript:=false;

  pc:=StrScanW(txt,' ');
  StrCopyW(tmp,txt,pc-txt);

  i:=0;
  while i<MaxStructTypes do
  begin
    if StrCmpW(tmp,StructElems[i].short)=0 then //!!
      break;
    inc(i);
  end;

  if i<MaxStructTypes then
  begin
    li.iItem:=item;
    j:=0;
    li.mask:=LVIF_TEXT;
    if lscript then
    begin
      li.iSubItem:=col_flag;
      li.pszText :='*';
      SendMessageW(list,LVM_SETITEMW,0,dword(@li));
    end;
    case StructElems[i].typ of
      SST_LAST,SST_PARAM: ;
      SST_BYTE,SST_WORD,SST_DWORD: begin
        if (pc<>txt) and (pc<>nil) then
        begin
          li.iSubItem:=col_data;
          li.pszText :=pc+1;
          SendMessageW(list,LVM_SETITEMW,0,dword(@li));
        end;
      end;
      SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
        txt:=pc+1;
        pc:=StrScanW(txt,' ');
        StrCopyW(tmp1,txt,pc-txt);
        li.iSubItem:=col_len;
        li.pszText :=tmp1;
        SendMessageW(list,LVM_SETITEMW,0,dword(@li));

        j:=StrToInt(tmp1);
        if (pc<>txt) and (pc<>nil) then
        begin
          li.iSubItem:=col_data;
          li.pszText :=pc+1;
          SendMessageW(list,LVM_SETITEMW,0,dword(@li));
        end;
      end;
    end;
    i:=StructElems[i].typ+(dword(j) shl 16);
    li.mask    :=LVIF_TEXT+LVIF_PARAM;
    li.pszText :=@tmp;
    li.iSubItem:=col_type;
    li.lParam  :=i;
    SendMessageW(list,LVM_SETITEMW,0,dword(@li));
  end;

  ListView_SetItemState(list,item,LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

procedure FillLVStruct(list:HWND;txt:PWideChar);
var
  p,pc:pWideChar;
begin
  while txt^<>#0 do
  begin
    p:=StrScanW(txt,'|');
    StrDupW(pc,txt,p-txt);
    FillLVLine(list,InsertLVLine(list),pc);
    mFreeMem(pc);
    if p=nil then break;
    txt:=p+1;
  end;
  ListView_SetItemState(list,0,LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

//----- Data save -----

function GetLVRow(var dst:pWideChar;list:HWND;item:integer):integer;
var
  li:TLVITEMW;
  buf:array [0..31] of WideChar;
  ofs:integer;
begin
  ofs:=2;
  li.iItem:=item;
  
  li.mask      :=LVIF_TEXT;
  li.iSubItem  :=col_flag;
  li.cchTextMax:=32;
  li.pszText   :=@buf[1];
  if SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li))>0 then
  begin
    dec(ofs);
    buf[ofs]:=char_script;
  end;

  li.mask      :=LVIF_TEXT or LVIF_PARAM or LVIF_STATE;
  li.cchTextMax:=HIGH(buf);
  li.iSubItem  :=col_type;
  li.pszText   :=@buf[2];
  li.stateMask :=LVIS_STATEIMAGEMASK;
  SendMessageW(list,LVM_GETITEMW,item,dword(@li));
  result:=loword(li.lParam);
  if (li.state shr 12)>1 then // "return" value
  begin
    dec(ofs);
    buf[ofs]:=char_return;
  end;

  StrCopyW(dst,@buf[ofs]);
  dst:=StrEndW(dst);

  case loword(li.lParam) of
    SST_LAST,SST_PARAM: exit;

    SST_BYTE,SST_WORD,SST_DWORD: begin
      li.iSubItem  :=col_data;
      li.cchTextMax:=32;
      li.pszText   :=@buf;
      if SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li))>0 then
      begin
        dst^:=' '; inc(dst);
        StrCopyW(dst,buf);
      end;
    end;

    SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
      dst^:=' '; inc(dst);
      ofs:=hiword(li.lParam);

      li.iSubItem  :=col_len;
      li.cchTextMax:=32;
      li.pszText   :=dst;
      if SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li))=0 then
        IntToStr(dst,ofs);

      if ofs>0 then
      begin
        dst:=StrEndW(dst);
        dst^:=' '; inc(dst);
        li.iSubItem  :=col_data;
        li.cchTextMax:=ofs+1;
        li.pszText   :=dst;
        SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li));
      end;
    end;
  end;
  dst:=StrEndW(dst);
end;

function SaveStructure(list:HWND):pWideChar;
var
  p:PWideChar;
  i:integer;
begin
  mGetMem(p,32768);
  result:=p;
  FillChar(p^,32768,0);
  for i:=0 to SendMessage(list,LVM_GETITEMCOUNT,0,0)-1 do
  begin
    GetLVRow(result,list,i);
    result^:='|'; inc(result);
  end;
  dec(result); result^:=#0;
  i:=(result+2-p)*SizeOf(WideChar);
  mGetMem(result,i);
  move(p^,result^,i);
  mFreeMem(p);
end;

function FindAddDlgResizer(Dialog:HWND;lParam:LPARAM;urc:PUTILRESIZECONTROL):int; cdecl;
begin
  case urc^.wId of
    IDC_DATA_FULL:   result:=RD_ANCHORX_LEFT  or RD_ANCHORY_HEIGHT;
    IDC_DATA_TYPE:   result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_LEN:    result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_EDIT:   result:=RD_ANCHORX_WIDTH or RD_ANCHORY_TOP;
    IDC_DATA_VARS:   result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_NEW:    result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_UP:     result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_DOWN:   result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_DELETE: result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_CHANGE: result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDOK:            result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDCANCEL:        result:=RD_ANCHORX_LEFT  or RD_ANCHORY_TOP;
    IDC_DATA_HELP:   result:=RD_ANCHORX_WIDTH or RD_ANCHORY_TOP;
  else
    result:=0;
  end;
end;

procedure CheckReturns(wnd:HWND;item:integer);
var
  li:TLVITEMW;
  i:integer;
begin
  li.mask     :=LVIF_STATE;
  li.iSubItem :=0;
  li.stateMask:=LVIS_STATEIMAGEMASK;
  li.state    :=1 shl 12;
  for i:=0 to SendMessageW(wnd,LVM_GETITEMCOUNT,0,0)-1 do
  begin
    if i<>item then
    begin
      SendMessageW(wnd,LVM_SETITEMSTATE,i,dword(@li));
{
      li.iItem:=i;
      SendMessageW(list,LVM_GETITEMSTATE,i,dword(@li));
      if (li.state shr 12)>1 then
      begin
        li.state:=1 shl 12;
        SendMessageW(wnd,LVM_SETITEMSTATE,i,dword(@li));
      end;
}
    end;
  end;
end;

// enable/disable navigation chain buttons
procedure CheckList(Dialog:HWND; num:integer=-1);
begin
  if num<0 then
    num:=SendDlgItemMessage(Dialog,IDC_DATA_FULL,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
  EnableWindow(GetDlgItem(Dialog,IDC_DATA_UP),num>0);
  EnableWindow(GetDlgItem(Dialog,IDC_DATA_DOWN),
      (num+1)<SendDlgItemMessage(Dialog,IDC_DATA_FULL,LVM_GETITEMCOUNT,0,0));
end;

procedure FillLVData(Dialog:HWND;list:HWND;item:integer);
var
  i:dword;
  p:array [0..1023] of WideChar;
  b,b1:boolean;
  li:TLVITEMW;
begin
  i:=loword(LV_GetLParam(list,item));

  CB_SelectData(GetDlgItem(Dialog,IDC_DATA_TYPE),i);
  case i of
    SST_LAST,SST_PARAM: begin
      b :=false;
      b1:=false;
    end;
    SST_BYTE,SST_WORD,SST_DWORD: begin
      b :=true;
      b1:=false;
    end;
    SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
      b :=true;
      b1:=true;
    end;
  else
    b :=false;
    b1:=false;
  end;
  li.cchTextMax:=HIGH(p)+1;
  li.pszText   :=@p;
  if b then
  begin
    li.iSubItem:=col_flag;
    if SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li))>0 then
      CheckDlgButton(Dialog,IDC_DATA_VARS,BST_CHECKED)
    else
      CheckDlgButton(Dialog,IDC_DATA_VARS,BST_UNCHECKED);
    
    li.iSubItem:=col_data;
    SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li));
  end
  else
    p[0]:=#0;
  SetDlgItemTextW(Dialog,IDC_DATA_EDIT,p);

  if b1 then
  begin
    li.iSubItem:=col_len;
    SendMessage(list,LVM_GETITEMTEXTW,item,dword(@li));
  end
  else
    p[0]:=#0;
  SetDlgItemTextW(Dialog,IDC_DATA_LEN,p);

  EnableWindow(GetDlgItem(Dialog,IDC_DATA_EDIT),b);
  EnableWindow(GetDlgItem(Dialog,IDC_DATA_VARS),b);
  EnableWindow(GetDlgItem(Dialog,IDC_DATA_LEN ),b1);
end;

procedure FillLVRow(Dialog:hwnd;list:HWND;item:integer);
var
  i,j:dword;
  wnd:HWND;
  buf:array [0..63] of WideChar;
  tmp:pWideChar;
begin
  wnd:=GetDlgItem(Dialog,IDC_DATA_TYPE);
  i:=SendMessage(wnd,CB_GETITEMDATA,SendMessage(wnd,CB_GETCURSEL,0,0),0);
  for j:=0 to MaxStructTypes-1 do
    if StructElems[j].typ=i then break;

  LV_SetItemW(list,StructElems[j].short,item);

  if IsDlgButtonChecked(Dialog,IDC_DATA_VARS)<>BST_UNCHECKED then
    LV_SetItemW(list,'*',item,col_flag);
  
  tmp:=nil;
  case i of
    SST_LAST,SST_PARAM: begin
    end;
    SST_BYTE,SST_WORD,SST_DWORD: begin
      tmp:=GetDlgText(Dialog,IDC_DATA_EDIT);
      LV_SetItemW(list,tmp,item,col_data);
    end;
    SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin

      SendDlgItemMessageW(Dialog,IDC_DATA_LEN,WM_GETTEXT,15,dword(@buf));
      LV_SetItemW(list,buf,item,col_len);

      tmp:=GetDlgText(Dialog,IDC_DATA_EDIT);
      LV_SetItemW(list,tmp,item,col_data);

      j:=StrLenW(tmp) shl 16;
      if (i=SST_WARR) or (i=SST_WPTR) then j:=j*2;
      i:=i or j;
    end;
  end;
  mFreeMem(tmp);
  LV_SetLParam(list,i,item);
end;

function StructEdit(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
var
  wnd:HWND;
  i:integer;
  li:TLVITEMW;
//  rc,rc1:TRECT;
  b,b1:boolean;
  urd:TUTILRESIZEDIALOG;
begin
  result:=0;
  case hMessage of

    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
      wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
      MakeLVStructList(wnd);
      SetDataButtonIcons(Dialog);
      FillDataTypeList(GetDlgItem(Dialog,IDC_DATA_TYPE));
      if lParam<>0 then
        FillLVStruct(wnd,pWideChar(lParam)) // fill lv with current structure
      else
        SendMessage(Dialog,WM_COMMAND,(CBN_SELCHANGE shl 16)+IDC_DATA_TYPE,
            GetDlgItem(Dialog,IDC_DATA_TYPE));
      CheckList(Dialog,-1);
    end;

    WM_GETMINMAXINFO: begin
      with PMINMAXINFO(lParam)^ do
      begin
        ptMinTrackSize.x:=500;
        ptMinTrackSize.y:=300;
      end;
    end;

    WM_SIZE: begin
      FillChar(urd,SizeOf(TUTILRESIZEDIALOG),0);
      urd.cbSize    :=SizeOf(urd);
      urd.hwndDlg   :=Dialog;
      urd.hInstance :=hInstance;
      urd.lpTemplate:=MAKEINTRESOURCEA(IDD_STRUCTURE);
      urd.lParam    :=0;
      urd.pfnResizer:=@FindAddDlgResizer;
      CallService(MS_UTILS_RESIZEDIALOG,0,dword(@urd));
      InvalidateRect(GetDlgItem(Dialog,IDC_DATA_HELP),nil,true);
    end;
{
    WM_SIZE: begin
      GetWindowRect(Dialog,rc);

      wnd:=GetDlgItem(Dialog,IDC_DATA_EDIT);
      GetWindowRect(wnd,rc1);
      SetWindowPos(wnd,0,0,0,rc.right-rc1.left-8,rc1.bottom-rc1.top,
          SWP_NOMOVE or SWP_NOZORDER or SWP_SHOWWINDOW);
      
      wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
      GetWindowRect(wnd,rc1);
      SetWindowPos(wnd,0,0,0,rc1.right-rc1.left, rc.bottom-rc1.top-8,
          SWP_NOMOVE or SWP_NOZORDER or SWP_SHOWWINDOW);

      wnd:=GetDlgItem(Dialog,IDC_DATA_HELP);
      GetWindowRect(wnd,rc1);
      SetWindowPos(wnd,0,0,0,rc.right-rc1.left-8, rc.bottom-rc1.top-8,
          SWP_NOMOVE or SWP_NOZORDER or SWP_SHOWWINDOW);
      InvalidateRect(wnd,nil,true);
    end;
}

    WM_COMMAND: begin
      case wParam shr 16 of

        CBN_SELCHANGE:  begin
          case loword(wParam) of
            IDC_DATA_TYPE: begin
              case CB_GetData(lParam) of
                SST_LAST,SST_PARAM: begin
                  b :=false;
                  b1:=false;
                end;
                SST_BYTE,SST_WORD,SST_DWORD: begin
                  b :=true;
                  b1:=false;
                end;
                SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
                  b :=true;
                  b1:=true;
                end;
              else
                b :=false;
                b1:=false;
              end;
              EnableWindow(GetDlgItem(Dialog,IDC_DATA_EDIT),b);
              EnableWindow(GetDlgItem(Dialog,IDC_DATA_VARS),b);
              EnableWindow(GetDlgItem(Dialog,IDC_DATA_LEN ),b1);
            end;
          end;
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_DATA_NEW: begin
              wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
              i:=InsertLVLine(wnd);
              FillLVRow(Dialog,wnd,i);
              EnableWindow(GetDlgItem(Dialog,IDC_DATA_DELETE),true);
//              CheckList(Dialog,i);
              if SendMessage(wnd,LVM_GETITEMCOUNT,0,0)=1 then
              begin
                li.mask     :=LVIF_STATE;
                li.iItem    :=0;
                li.iSubItem :=0;
                li.StateMask:=LVIS_FOCUSED+LVIS_SELECTED;
                li.State    :=LVIS_FOCUSED+LVIS_SELECTED;
                SendMessageW(wnd,LVM_SETITEMW,0,dword(@li));
              end;
              CheckList(Dialog);
            end;

            IDC_DATA_DELETE: begin
              wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
              i:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED); //??
              if i<>-1 then
              begin
                SendMessage(wnd,LVM_DELETEITEM,i,0);
                CheckList(Dialog,-1);
              end;

//            SendMessageW(Dialog,LVM_DELETEITEM,ListView_GetNextItem(Dialog,-1,LVNI_FOCUSED),0);
//select next and set field (auto?)
{
    i:=SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
    if i>0 then
    begin
      if next=i then
        dec(next);
      ListView_SetItemState(wnd,next,LVIS_FOCUSED or LVIS_SELECTED,
        LVIS_FOCUSED or LVIS_SELECTED);
}
            end;

            IDC_DATA_UP: begin
              wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
              li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
//              if li.iItem>0 then
                LV_MoveItem(wnd,-1,li.iItem);
                CheckList(Dialog);
            end;

            IDC_DATA_DOWN: begin
              wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
              li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
//              if li.iItem<(SendMessage(wnd,LVM_GETITEMCOUNT,0,0)-1) then
                LV_MoveItem(wnd,1,li.iItem);
                CheckList(Dialog);
            end;

            IDOK: begin // save result
              EndDialog(Dialog,dword(SaveStructure(GetDlgItem(Dialog,IDC_DATA_FULL))));
            end;
            IDCANCEL: begin // clear result / restore old value
              EndDialog(Dialog,0);
            end;

            IDC_DATA_CHANGE: begin
              wnd:=GetDlgItem(Dialog,IDC_DATA_FULL);
              if SendMessage(wnd,LVM_GETITEMCOUNT,0,0)=0 then
              begin
                PostMessage(Dialog,hMessage,IDC_DATA_NEW,lParam);
                exit;
              end;
              i:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED); //??
              if i<>-1 then
                FillLVRow(Dialog,wnd,i);
            end;

          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      if PNMHdr(lParam)^.code=PSN_APPLY then
      begin
      end
      else if wParam=IDC_DATA_FULL then
      begin
        case PNMHdr(lParam)^.code of
          LVN_ITEMCHANGED: begin
            i:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_FOCUSED)-
               (PNMLISTVIEW(lParam)^.uNewState and LVNI_FOCUSED);
            if i>0 then // old focus - do nothing
            else if i<0 then // new focus - fill fields
            begin
              //save
              FillLVData(Dialog,PNMHdr(lParam)^.hwndFrom,PNMLISTVIEW(lParam)^.iItem);
              CheckList(Dialog,PNMLISTVIEW(lParam)^.iItem);
            end
            else
            begin
              if (PNMLISTVIEW(lParam)^.uOldState or PNMLISTVIEW(lParam)^.uNewState)=$3000 then
              begin
                if PNMLISTVIEW(lParam)^.uOldState=$1000 then // check
                  CheckReturns(GetDlgItem(Dialog,IDC_DATA_FULL),PNMLISTVIEW(lParam)^.iItem);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;
