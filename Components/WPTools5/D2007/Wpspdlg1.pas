unit Wpspdlg1;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit demonstrates how to use the spelling interface
  functions of WPRichText.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$I WPINC.INC}

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, WPCtrMemo, WPUtil;

type
  {$IFNDEF T2H}
  TWPSpDialog = class(TWPShadedForm)
    WordList: TListBox;
    Word: TEdit;
    ReplaceAs: TEdit;
    Ignore: TBitBtn;
    Replace: TBitBtn;
    Cancel: TBitBtn;
    procedure IgnoreClick(Sender: TObject);
    procedure ReplaceClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
    fsFirstCall : Boolean;
    fsEditBox   : TWPCustomRtfEdit;
    procedure SetEditBox(x : TWPCustomRtfEdit);
  public
    { Public-Deklarationen }
    property EditBox : TWPCustomRtfEdit read fsEditBox write SetEditBox;
  end;
  {$ENDIF}

TWPSpellCheckDlg = class(TWPCustomAttrDlg)
private
  dia       : TWPSpDialog;
public
  destructor  Destroy; override;
  function Execute : Boolean; override;
published
  property EditBox;
end;


implementation

{$R *.DFM}

destructor TWPSpellCheckDlg.Destroy;
begin
  if dia<>nil then
  begin
        if dia.visible then dia.Close;
        dia.Free;
  end;
  inherited Destroy;
end;

function TWPSpellCheckDlg.Execute : Boolean;  { Will not free the Dialogbox because it is nnon modal ! }
begin
 Result := FALSE;
 if assigned(FEditBox)  and MayOpenDialog(dia) and Changing then
 begin
   if dia=nil then dia := TWPSpDialog.Create(Self);
   dia.EditBox := FEditBox;
   FEditBox.Spell_FromCursorPos;
   if not FCreateAndFreeDialog then
   begin
     dia.Show;
     Result := TRUE;
   end;
 end;
end;

procedure TWPSpDialog.SetEditBox(x : TWPCustomRtfEdit);
begin
  fsEditBox := x;
  if x<>nil then x.Spell_FromCursorPos;
end;


procedure TWPSpDialog.IgnoreClick(Sender: TObject);
var
 s : String;
 x,y : Integer;
begin
 while TRUE do
 begin
  EditBox.Spell_FromCursorPos;
  s := EditBox.Spell_GetNextWord;
  if s='' then break;
  { test Dictionary .... ################################
    if not InDictionary(s) then
    begin
       EditBox.Spell_SelectWord;
       WordList.Strings.Assign( GuessList );
       break;
    end
    else continue;
    ##################################################### }
   { without a dictonary any word is unknown: }
      x := Left;
      y := Top;
      EditBox.Spell_SelectWordXY(x,y);
      if y>Screen.Height div 2 then y := y - Height - 30;
      Top  := y;
      Left := x;
      break;
 end;
 Word.Text      := s;
 ReplaceAs.Text := s;
 if (s='') and (fsFirstCall=FALSE) then close;
end;

{ Replace will replace the selected Text.
  If you use the procedure
  EditBox.Spell_ReplaceWord(s : string) the replacment will be done
  invisibly.
  If you have a non modal spell dialog, the use of Spell_ReplaceWord might
  cause errors if the user has changed the text meanwhile.
}

procedure TWPSpDialog.ReplaceClick(Sender: TObject);
begin
  EditBox.SelText := ReplaceAs.Text;
  IgnoreClick(Sender);
end;

procedure TWPSpDialog.CancelClick(Sender: TObject);
begin
  EditBox.Spell_FromCursorPos;
  Close;
end;

procedure TWPSpDialog.FormShow(Sender: TObject);
begin
  fsFirstCall := TRUE;
  IgnoreClick(Sender);
  fsFirstCall := FALSE;
end;

end.
