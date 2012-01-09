uses sedit,kol,strans,
 windows,
 io,messages, commctrl, common, wrapper{$IFDEF Miranda}, m_api{$ENDIF};

var
  CloseButton,form:PControl;

{$i i_const.inc}
{.$i i_opt_Struct.inc}

procedure CloseClick(Dummy:Pointer;Sender:PControl);
begin
  EditStructure('0|byte|word 1|b.arr 13 as$DF|w.ptr 100|param|native|', form.GetWindowHandle);
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
  run(form);
end.