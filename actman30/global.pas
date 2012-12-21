unit global;

interface

const
  DBBranch = 'ActMan';
const
  ACF_EXPORT   = $08000000;
  ACF_IMPORT   = $08000000;
  ACF_SELECTED = $08000000;
  ACF_OVERLOAD = $01000000;

type
  tAddOption = function(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
type
  pActionLink=^tActionLink;
  tActionLink=record
    Next     :pActionLink;
    Init     :procedure;
    DeInit   :procedure;
    AddOption:tAddOption;
  end;

const
  ActionLink:pActionLink=nil;

implementation

end.