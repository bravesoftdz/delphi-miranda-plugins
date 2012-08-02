unit my_richedit;

interface

uses
  kol;

type
  TKOLRichEdit = PControl;

  PHPPRichEdit = ^THPPRichEdit;
  THPPRichEdit = TKOLRichEdit;

function NewHPPRichEdit(aParent:PControl; Options:TEditOptions):PControl;

implementation

uses KolOleRe2;

function NewHPPRichEdit(aParent:PControl; Options:TEditOptions):PControl;
begin
//  result:=NewRichEdit(aParent, Options);
  result:=NewOLERichEdit2(aParent, Options);
//  result.SubClassName:='THppRichEdit';
end;


end.
