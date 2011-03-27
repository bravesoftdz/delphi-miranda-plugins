unit global;

interface

type
  tAddOption = function(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
type
  PActionLink=^TActionLink;
  TActionLink=record
    next     :pActionLink;
    Init     :procedure;
    DeInit   :procedure;
    AddOption:tAddOption;
  end;

const
  ActionLink:PActionLink=nil;

implementation

end.