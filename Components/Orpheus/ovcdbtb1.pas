{*********************************************************}
{*                  OVCDBTB1.PAS 4.05                    *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovcdbtb1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, OvcBase, OvcEF, OvcSF, ExtCtrls, OvcIntl;

type
  TOvcfrmProperties = class(TForm)
    edPictureMask: TOvcSimpleField;
    OvcController1: TOvcController;
    Label1: TLabel;
    Label2: TLabel;
    edDecimalPlaces: TOvcSimpleField;
    rgDateOrTime: TRadioGroup;
    Button1: TButton;
    Button2: TButton;
    procedure rgDateOrTimeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TOvcfrmProperties.rgDateOrTimeClick(Sender: TObject);
var
  ForceCentury : Boolean;
begin
   ForceCentury := Pos('yyyy', ShortDateFormat) > 0;
   if rgDateOrTime.ItemIndex = 0 then
     edPictureMask.AsString := OvcIntlSup.InternationalDate(ForceCentury)
   else
     edPictureMask.AsString := OvcIntlSup.InternationalTime(False);
end;

end.
