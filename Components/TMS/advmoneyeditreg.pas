{********************************************************************}
{ TAdvMoneyEdit component                                            }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ Written by :                                                       }
{   TMS Software                                                     }
{   Copyright © 2006                                                 }
{   Email : info@tmssoftware.com                                     }
{   Website : http://www.tmssoftware.com                             }
{********************************************************************}
unit AdvMoneyEditReg;

interface

{$I TMSDEFS.INC}

uses
  Classes
  , AdvMoneyEdit
  {$IFNDEF TMSDOTNET}
  , DBAdvMoneyEdit
  {$ENDIF}
  ;

{$IFDEF TMSDOTNET}
{$R TAdvMoneyEdit.bmp}
{$ENDIF}
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvMoneyEdit
  {$IFNDEF TMSDOTNET}
    , TDBAdvMoneyEdit
  {$ENDIF}  
  ]);
end;



end.


