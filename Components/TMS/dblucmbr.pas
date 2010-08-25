{********************************************************************}
{ TDBLUCOMBO component                                               }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3.0,4.0,5.0                }
{ version 1.0                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000                                                 }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit dblucmbr;

interface

{$I TMSDEFS.INC}
uses
  DBLuComb, Classes;

{$IFDEF TMSDOTNET}
{$R TDBLUCombo.bmp}
{$R TDBLUEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TDBLUCombo,TDBLUEdit]);
end;




end.
