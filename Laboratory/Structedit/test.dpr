uses sedit,kol,strans,
 windows,
 io,messages, commctrl, common, wrapper{$IFDEF Miranda}, m_api{$ENDIF};

var
  CloseButton,form:PControl;
  pc:pAnsiChar;

{$i i_const.inc}
{.$i i_opt_Struct.inc}

procedure CloseClick(Dummy:Pointer;Sender:PControl);
begin

  pc:=EditStructure(pc,form.GetWindowHandle);
  MessageboxA(0,pc,'',0);
end;

begin
  form:=NewForm(nil,'')
  .SetPosition(40,40)
  .SetSize(520,224)
  ;

  CloseButton:=NewButton(form,'Close')
    .PlaceRight
    .SetSize(62,22)
    .Anchor(false,true,true,false)
  ;
  CloseButton.OnClick:=TOnEvent(MakeMethod(nil,@CloseClick));
  pc:='0|byte|word (wchar) wAliasExample 1|b.arr (char[]) 13 as$DF|w.ptr 100|param|native';
  run(form);
end.