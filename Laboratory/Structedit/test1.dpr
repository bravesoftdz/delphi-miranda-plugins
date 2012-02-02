uses strans;

var
  descr:pAnsiChar;
  struct:pointer;
begin
  descr:='0|byte|word (wchar) wAliasExample 1|b.arr (char[]) 13 as$DF|w.ptr 100 sebastian|param|native';
  struct:=MakeStructure(descr,0,0);
  FreeStructure(struct);
end.
