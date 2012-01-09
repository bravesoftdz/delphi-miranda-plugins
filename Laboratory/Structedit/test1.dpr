uses strans;

var
  descr:pAnsiChar;
  struct:pointer;
begin
  descr:='0|byte|word 1|b.arr 13 as$DF|w.ptr 100|param|native';
  struct:=MakeStructure(descr,0,0);
  FreeStructure(struct,descr);
end.
