unit WPDocPropDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 4
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to edit the document variables
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, WPPanel, WPUtil,
  WPRTEDefs, WPCTRMemo, WPCTRRich;

type
  TWPDocProperties = class(TWPShadedForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    WordCount: TLabel;
    ParCount: TLabel;
    LineCount: TLabel;
    CWordCount: TLabel;
    CParCount: TLabel;
    CLineCount: TLabel;
    PageCount: TLabel;
    CPageCount: TLabel;
    WPEditFields: TWPRichText;
    Label1: TLabel;
    AddField: TButton;
    CharCount: TLabel;
    CCharCount: TLabel;
    CharCountSPC: TLabel;
    CCharCountSPC: TLabel;
    procedure FormShow(Sender: TObject);
    procedure AddFieldClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure WPEditFieldsMailMergeGetText(Sender: TObject;
      const inspname: String; const Contents: TWPMMInsertTextContents);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    Source: TWPCustomRichText;
    procedure ReadFieldsToEditfields;
    procedure SaveEditFields;
  end;

var
  WPDocProperties: TWPDocProperties;

implementation

{$R *.DFM}

procedure TWPDocProperties.FormShow(Sender: TObject);
var CChar, CCharSpc, Pos : Integer;  c : Char;
begin
  if Source = nil then
    raise EWPEngineModeError.Create('Assign TWPRichText to "Source"')
  else
  begin
    CWordCount.Caption := IntToStr(Source.CountWords);
    CLineCount.Caption := IntToStr(Source.CountLines);
    CParCount.Caption := IntToStr(Source.CountParagraphs);
    CPageCount.Caption := IntToStr(Source.CountPages);
    Pos := Source.CPPosition;
    Source.CPPosition := 0;
    Source.LockScreen;
    CChar := 0;
    CCharSpc := 0;
    repeat
      c := Source.CPChar;
      if c>#32 then inc(CChar);
      if (c>=#32) or (c=#9) then inc(CCharSpc);
    until not Source.CPMoveNext;
    Source.CPPosition := pos;
    Source.UnLockScreen(true);
    CCharCount.Caption := IntToStr(CChar);
    CCharCountSPC.Caption := IntToStr(CCharSpc);
    ReadFieldsToEditfields;
  end;
end;

procedure TWPDocProperties.ReadFieldsToEditfields;
var
  i: Integer;
  s : String;
begin
  WPEditFields.ProtectedProp := [];
  WPEditFields.BeginUpdate;
  WPEditFields.Clear;
  // Set font to first label on first page 
  WPEditFields.ApplyFont( WordCount.Font );
  WPEditFields.SetTabPos(1440, tkLeft, false);
  s := '';
  try
    for i := 0 to Source.RTFVariables.Count - 1 do
    if not (wpxInvisible in Source.RTFVariables[i].Options) then 
    begin
      WPEditFields.InputString(s + Source.RTFVariables[i].Name + #9 + ':');
      s := #13;
      WPEditFields.InputEditField(Source.RTFVariables[i].Name, Source.RTFVariables[i].Text, false);
    end;
  finally
    WPEditFields.ProtectedProp := [ppAllExceptForEditFields];
    WPEditFields.CPPosition := 0;
    WPEditFields.EndUpdate;
  end;
end;

// We read out the EditFields
procedure TWPDocProperties.SaveEditFields;
begin
   WPEditFields.MergeEnumFields('');
end;

procedure TWPDocProperties.WPEditFieldsMailMergeGetText(Sender: TObject;
  const inspname: String; const Contents: TWPMMInsertTextContents);
var S : String;
begin
    S := Contents.OldText;
    Source.RTFVariables.AddString(inspname,S, false);
end;

procedure TWPDocProperties.AddFieldClick(Sender: TObject);
var
  s : string;
begin
  s := '';
  PageControl1.ActivePage := TabSheet2;
  if not InputQuery('Add Document Field', 'Name', s) or (S='') then exit;
  WPEditFields.ProtectedProp := [];
  WPEditFields.BeginUpdate;
  WPEditFields.CPPosition := MaxInt;
  try
    WPEditFields.InputString(#13 + s + #9 + ':');
    WPEditFields.InputEditField(s, #32, true);
  finally
    WPEditFields.ProtectedProp := [ppAllExceptForEditFields];
    WPEditFields.EndUpdate;
    WPEditFields.SetFocus;
  end;
end;

procedure TWPDocProperties.Button1Click(Sender: TObject);
begin
  SaveEditFields;
  ModalResult := mrOK;
end;



procedure TWPDocProperties.PageControl1Change(Sender: TObject);
begin
  AddField.Visible := PageControl1.ActivePage=TabSheet2;
end;

end.

