unit WPStrDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to edit two strings, for example a hyperlink
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{$I WPINC.INC}

interface

uses Windows,  SysUtils, Messages, Classes, Graphics, Controls,
     Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil;

type
  {$IFNDEF T2H}
  TWPStringDialog = class(TWPShadedForm)
    btnOk: TButton;
    btnCancel: TButton;
    aText: TEdit;
    aData: TEdit;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
  end;
  {$ENDIF}

  TWPStringDlg = class(TWPCustomAttrDlg)
  private
    dia      : TWPStringDialog;
    FCaption, FUpperCaption, FLowerCaption : string;
    FUpperText, FLowerText : string;
    FUpperModified, FLowerModified : Boolean;
  public
    function Execute : Boolean; override;
    property UpperModified : Boolean read FUpperModified;
    property LowerModified : Boolean read FLowerModified;
  published
    property EditBox;
    property Caption : String read FCaption write FCaption;
    property UpperCaption : String read FUpperCaption write FUpperCaption;
    property LowerCaption : String read FLowerCaption write FLowerCaption;
    property UpperText : String read FUpperText write FUpperText;
    property LowerText : String read FLowerText write FLowerText;
  end;

implementation

{$R *.DFM}
function TWPStringDlg.Execute : Boolean;
begin
    Result := FALSE;
    if assigned(FEditBox)  and MayOpenDialog(dia) and Changing then
    begin
      dia := TWPStringDialog.Create(Self);
      FUpperModified := FALSE;
      FLowerModified := FALSE;
      try
        dia.Caption := FCaption;
        dia.Label1.Caption := FUpperCaption;
        dia.Label2.Caption := FLowerCaption;
        dia.aText.Text := FUpperText;
        dia.aData.Text := FLowerText;
        if dia.ShowModal = mrOK then
        begin
           FUpperModified := dia.aText.Text<>FUpperText;
           if FUpperModified then FUpperText := dia.aText.Text;
           FLowerModified := dia.aData.Text<>FLowerText;
           if FLowerModified then FLowerText := dia.aData.Text;
           Result := FUpperModified or FLowerModified;
        end;
      finally
        dia.Free;
      end;
    end;
end;

end.
