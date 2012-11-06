unit my_richedit;

interface

uses
  KolOleRe2,
  kol;

type
  PHPPRichEdit = ^THPPRichEdit;
  THPPRichEdit = TKOLOleRichEdit2;

function NewHPPRichEdit(aParent:PControl; Options:TEditOptions):PHPPRichEdit;

implementation

function NewHPPRichEdit(aParent:PControl; Options:TEditOptions):PHPPRichEdit;
begin
//  result:=NewRichEdit(aParent, Options);
  result:=NewOLERichEdit2(aParent, Options);
//  result.SubClassName:='THppRichEdit';
end;


end.
