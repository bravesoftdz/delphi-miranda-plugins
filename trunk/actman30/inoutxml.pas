unit inoutxml;

interface

uses windows, lowlevelc;

function Import(list:tMacroList;fname:PWideChar;aflags:dword):integer;
function aExport(list:tMacroList;fname:PWideChar;aflags:dword):integer;

implementation

uses
  io, common, m_api, question, inouttext,
  iac_global, global;

const
  ioAction = 'Action';
  ioClass  = 'class';
  ioName   = 'name';
  ioVolatile = 'volatile';
const
  imp_yes    = 1;
  imp_yesall = 2;
  imp_no     = 3;
  imp_noall  = 4;
  imp_append = 5;

function ImportAction(actnode:HXML):tBaseAction;
var
  pa:pActModule;
  buf:array [0..127] of AnsiChar;
begin
  result:=nil;
  if actnode=0 then exit;
  with xmlparser do
  begin
    pa:=GetLinkByName(FastWideToAnsiBuf(getAttrValue(actnode,ioClass),buf));
    if pa<>nil then
    begin
      result:=pa.Create;
      result.Load(pointer(actnode),1);
    end
    else
      result:=tBaseAction(1);
  end;
end;

function Import(list:tMacroList;fname:PWideChar;aflags:dword):integer;
var
  f:THANDLE;
  i,nodenum,actcnt:integer;
  tmp,res:pWideChar;
  root,actnode:HXML;
  impact:integer;
  buf:array [0..511] of WideChar;
  oldid:dword;
  arr:array [0..63] of tBaseAction;
  act:tBaseAction;
  p:pMacroRecord;
begin
  result:=0;

  for i:=0 to list.Count-1 do
    with list[i]^ do
      if (flags and (ACF_IMPORT or ACF_ASSIGNED))=
                    (ACF_IMPORT or ACF_ASSIGNED) then
        flags:=flags and not (ACF_IMPORT or ACF_OVERLOAD);

  if (fname=nil) or (fname^=#0) then
    exit;
  i:=GetFSize(fname);
  if i=0 then
    exit;
  mGetMem (res ,i+SizeOf(WideChar));
  FillChar(res^,i+SizeOf(WideChar),0);
  f:=Reset(fname);
  BlockRead(f,res^,i);
  CloseHandle(f);

//MessageBoxW(0,res,'SRC',0);
  xmlparser.cbSize:=SizeOf(TXML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,lparam(@xmlparser));
  with xmlparser do
  begin
    root:=parseString(ChangeUnicode(res),@i,nil);
    nodenum:=0;
    impact:=imp_yes;
    repeat
      actnode:=getNthChild(root,ioAction,nodenum);
      if actnode=0 then break;
//??      if StrCmpW(getName(actnode),ioAction)<>0 then break;
      tmp:=getAttrValue(actnode,ioName);
      if tmp<>nil then //!!
      begin
        p:=list.GetMacro(tmp);
        oldid:=$FFFFFFFF;
        if p<>nil then
        begin
          if (impact<>imp_yesall) and (impact<>imp_noall) then
          begin
            StrCopyW(buf,TranslateW('Action "$" exists, do you want to rewrite it?'));
            impact:=ShowQuestion(StrReplaceW(buf,'$',tmp));
          end;
          if (impact=imp_yesall) or (impact=imp_yes) then
          begin
            oldid:=p^.id;
            FreeMacro(p);
          end;
        end;
        // if new or overwriting then read macro details/actions
        if (p=nil) or (impact=imp_yesall) or (impact=imp_yes) or (impact=imp_append) then
        begin
          with List[list.NewMacro()]^ do
          begin
            if (p<>nil) and (oldid<>$FFFFFFFF) then // set old id to keep UseAction setting
            begin
              flags:=flags or ACF_IMPORT or ACF_OVERLOAD;
              id:=oldid;
            end
            else
              flags:=flags or ACF_IMPORT;
            if StrToInt(getAttrValue(actnode,ioVolatile))=1 then flags:=flags or ACF_VOLATILE;
            StrCopyW(descr,tmp,MacroNameLen-1);

            // reading actions
            actcnt:=0; // count in file 
            ActionCount:=0;      // amount of loaded
            repeat
              act:=ImportAction(getChild(actnode,actcnt));
              if act=nil then
                break;
              if uint_ptr(act)<>1 then
              begin
                arr[ActionCount]:=act;
                inc(ActionCount);
              end;
              inc(actcnt);
            until false;
            // moving actions to their place
            if Actioncount>0 then
            begin
              GetMem(ActionList,SizeOf(tBaseAction)*ActionCount);
              move(arr,ActionList^,SizeOf(tBaseAction)*ActionCount);
            end;
            inc(result);
          end;
        end;
      end;
      inc(nodenum);
    until false;
    destroyNode(root);
  end;
  mFreeMem(res);
end;

//=======================================================

procedure SaveActions(Macro:pMacroRecord;buf:tTextExport);
var
  p,p1:PAnsiChar;
  i:integer;
begin
  for i:=0 to Macro.ActionCount-1 do
  begin
    if i>0 then
      buf.AddNewLine();
    buf.AddFlag('ACTION');
    Macro.ActionList[i].Save(buf,13);
    buf.ShiftLeft;
    buf.AddFlag('ENDACTION');
    buf.AddNewLine();
  end;
{
  p:=StrEnd(section);
  StrCopy(p,opt_numacts); DBWriteWord(0,DBBranch,section,Macro^.ActionCount);

  // in: section = "Group#/"
  p1:=StrCopyE(p,opt_actions); // "Group#/Action"
  DBDeleteGroup(0,DBBranch,section);

  for i:=0 to Macro^.ActionCount-1 do
  begin
    p:=StrEnd(IntToStr(p1,i));
    p^:='/'; inc(p); // "Group#/Action#/"

//??    StrCopy(p,opt_uid); DBWriteDWord(0,DBBranch,section,Macro^.ActionList[i].uid);
    p^:=#0;
    Macro^.ActionList[i].Save(section,13);
  end;
}
end;

function aExport(list:tMacroList;fname:PWideChar;aflags:dword):integer;
var
  buf:tTextExport;
  f:THANDLE;
  
  Macro:pMacroRecord;
  NumMacro:integer;
  i,j:integer;
  section:array [0..127] of AnsiChar;
  p,p1:PAnsiChar;
begin
// even if crap in settings, skip on read
//  DBDeleteGroup(0,DBBranch,opt_group);
  Macro:=list[0];
  i:=list.Count;
  NumMacro:=0;

  buf:=tTextExport.Create(list.Count);

  j:=0;
  while i>0 do
  begin
    with Macro^ do
    begin
      if (flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED then
      begin
        buf.NextItem;

        buf.AddFlag('MACRO');
        buf.AddDWord('id'   ,id);
//        buf.AddDWord('flags',flags);
        buf.AddFlag('FirstRun',(flags and ACF_FIRSTRUN)<>0);
        buf.AddTextW('descr',descr);
        buf.AddNewLine();
        buf.ShiftRight();

        SaveActions(Macro,buf);

        buf.ShiftLeft;
        buf.AddFlag('ENDMACRO');
        buf.AddNewLine();
        buf.AddNewLine();
        buf.EndItem;
        inc(NumMacro);
      end;
    end;
    inc(Macro);
    inc(j);
    dec(i);
  end;

  f:=Rewrite(fname);
  for i:=0 to NumMacro-1 do
  begin
    p:=buf.Items[i];
    BlockWrite(f,p^,StrLen(p));
  end;
  CloseHandle(f);
  
  buf.Free;
end;

end.
