unit WPStyles;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to edit a style collection
    - either the styles used by a TWPRichText
    - or hosted by a TWPStyleCollection
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, WPUtil, WPTbar, WPPanel,
  Menus, Buttons, WPBltDlg, WPTabdlg, WpParBrd,
  WpParPrp, WP1Style, WPCTRStyleCol, WPRTEDefs, WPCTRMemo,
  WPCTRRich;

type
  TWPStyleDlg = class;
  TWPOnBeforeChangeStyleEvent =
    procedure(Sender: TObject;
    ThisStyleName: string;
    var CancelOperation: boolean) of object;

{$IFNDEF T2H}
  TWPStyleDefinition = class(TWPShadedForm)
    Bevel1: TBevel;
    ListBox1: TListBox;
    TemplateWP: TWPRichText;
    btnOk: TButton;
    btnCancel: TButton;
    labPreviewParagraph: TLabel;
    labPreviewFont: TLabel;
    WPRichText1: TWPRichText;
    labName: TLabel;
    NameEdit: TEdit;
    labBasedOn: TLabel;
    btnChangeStyle: TButton;
    BasedOn: TEdit;
    NewStyle: TSpeedButton;
    DelStyle: TSpeedButton;
    LoadStyleSheet: TSpeedButton;
    SaveStyleSheet: TSpeedButton;
    LocateThisStyleInText: TSpeedButton;
    ValueLines: TMemo;
    labPreviewText: TLabel;
    labReplaceWithMsg: TLabel;
    labNewStyleName: TLabel;
    ParCommands: TPopupMenu;
    NormalizethisParagraph1: TMenuItem;
    NormalizeAllParagraphs1: TMenuItem;
    procedure btnChangeStyleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure LoadStyleSheetClick(Sender: TObject);
    procedure SaveStyleSheetClick(Sender: TObject);
    procedure DelStyleClick(Sender: TObject);
    procedure NewStyleClick(Sender: TObject);
    procedure LocateThisStyleInTextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure NormalizethisParagraph1Click(Sender: TObject);
    procedure NormalizeAllParagraphs1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  protected
    Controller: TWPStyleDlg;
    WPOneStyleDlg1: TWPOneStyleDlg;
    FNeedFromStart : Boolean;
  public
    procedure UpdateList;
  end;
{$ENDIF}

  TWPStyleDlg = class(TWPCustomAttrDlg)
  private
    fOnBeforeStyleDelete: TWPOnBeforeChangeStyleEvent;
    fOnBeforeStyleEdit: TWPOnBeforeChangeStyleEvent;
    dia: TWPStyleDefinition;
    FStyleCollection: TWPStyleCollection;
    FFilterString: string;
    FShowValueList: Boolean;
    FSaveCSSAsWPCSS: Boolean;
    FOverwriteAttr : Boolean;
    FChangedStyles : TStringList;
    function GetChangedStyles : TStrings;
    procedure SetStyleCollection(x: TWPStyleCollection);
  protected
    procedure SetEditBox(x: TWPCustomRtfEdit); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; override;
    {:: The styles which were touched by the dialog will be listed here. }
    property ChangedStyles : TStrings read GetChangedStyles;
  published
    property EditBox;
    property StyleCollection: TWPStyleCollection read FStyleCollection write SetStyleCollection;
    property OnBeforeStyleDelete: TWPOnBeforeChangeStyleEvent read fOnBeforeStyleDelete write fOnBeforeStyleDelete;
    property OnBeforeStyleEdit: TWPOnBeforeChangeStyleEvent read fOnBeforeStyleEdit write fOnBeforeStyleEdit;
    property FilterString: string read FFilterString write FFilterString;
    property ShowValueList: Boolean read FShowValueList write FShowValueList;
    {:: If the user saves 'CSS' format a WPCSS file is written. That format preserves
        all attributes, something CSS cannot. At load time the WPCSS format is automatically detected.}
    property SaveCSSAsWPCSS: Boolean read FSaveCSSAsWPCSS write FSaveCSSAsWPCSS;
    {:: If this property is true the properties of all paragraphs which use styles
      which were modified using this dialog will be neutralized. So style changes are always
      visible since there are no locked attributes. }
    property OverwriteAttr : Boolean read FOverwriteAttr write FOverwriteAttr;
  end;

var
  WPStyleDefinition: TWPStyleDefinition;

implementation

{$R *.DFM}

constructor TWPStyleDlg.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FFilterString := '';
  FChangedStyles := TStringList.Create;
end;

destructor TWPStyleDlg.Destroy;
begin
  FChangedStyles.Free;
  inherited Destroy;
end;

function TWPStyleDlg.GetChangedStyles : TStrings;
begin
  Result := TStrings(FChangedStyles);
end;

procedure TWPStyleDlg.SetStyleCollection(x: TWPStyleCollection);
begin
  FStyleCollection := x;
  if FStyleCollection <> nil then
  begin
    FStyleCollection.FreeNotification(Self);
    FEditBox := nil;
  end;
end;

procedure TWPStyleDlg.SetEditBox(x: TWPCustomRtfEdit);
begin
  inherited SetEditBox(x);
  if EditBox <> nil then FStyleCollection := nil;
end;

procedure TWPStyleDlg.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FStyleCollection) then
    FStyleCollection := nil;
  inherited Notification(AComponent, Operation);
end;

function TWPStyleDlg.Execute: Boolean;
var ele : TWPRTFStyleElement; i : Integer;
begin
  Result := FALSE;
  if (FStyleCollection = nil) and (FEditBox = nil) and (RTFProps = nil) then
    raise Exception.Create('Need Style Collection or Editor or runtime property RTFProps!');

  try
    dia := TWPStyleDefinition.Create(Self);
    dia.Controller := Self;
    FChangedStyles.Clear;
    if FStyleCollection <> nil then
      FStyleCollection.WriteStyles(dia.TemplateWP)
    else
      if FRTFProps <> nil then
      begin
        dia.TemplateWP.NumberStyles.Assign(FRTFProps.NumberStyles);
        dia.TemplateWP.ParStyles.Assign(FRTFProps.ParStyles);
        dia.LocateThisStyleInText.Visible := (FEditBox <> nil);
      end else
      begin
        dia.TemplateWP.NumberStyles.Assign(FEditBox.NumberStyles);
        dia.TemplateWP.ParStyles.Assign(FEditBox.ParStyles);
        if wpfNumberingControlledByStyles in FEditBox.FormatOptionsEx  then
           dia.TemplateWP.FormatOptionsEx :=
              dia.TemplateWP.FormatOptionsEx + [wpfNumberingControlledByStyles]
         else dia.TemplateWP.FormatOptionsEx :=
              dia.TemplateWP.FormatOptionsEx - [wpfNumberingControlledByStyles];
        dia.LocateThisStyleInText.Visible := (FEditBox <> nil);
      end;

    if not FCreateAndFreeDialog and MayOpenDialog(dia) then
    begin
      dia.UpdateList;
      if FEditBox <> nil then
      begin
        dia.ListBox1.ItemIndex :=
          dia.ListBox1.Items.IndexOf(FEditBox.ActiveStyleName);
        dia.ListBox1Click(nil);
      end;
       {  if FEditBox <> nil then
         begin
              checkp := FEditBox.Memo.UndoStack.SaveCheckpoint(dia.Caption);
              dia.TemplateWP.NumberStyles.Assign(FEditBox.NumberStyles);
         end
         else checkp := -1;}
      if dia.ShowModal = mrOK then
      begin
          { if FEditBox <> nil then
           begin
              FEditBox.Memo.StartUndolevel;
              FEditBox.Memo.UndoBufferObjSaveTo(sty,nil,wpuSetStyleCollection,wputChangeStyleSheet);
           end; }
        Result := TRUE;

        if FStyleCollection <> nil then
        begin
          FStyleCollection.ReadStyles(dia.TemplateWP);
          FStyleCollection.Update(nil);
        end
        else
          if FRTFProps <> nil then
          begin
            FRTFProps.NumberStyles.Assign(dia.TemplateWP.NumberStyles);
            FRTFProps.ParStyles.Assign(dia.TemplateWP.ParStyles);
            if OverwriteAttr then
            for i:=0 to FChangedStyles.Count-1 do
            begin
               ele := FRTFProps.ParStyles.FindStyle(FChangedStyles[i]);
               if ele<>nil then
                  ele.OverwritePar(true, true);
            end;
            FRTFProps.ReformatAll;
          end else
          begin
            FEditBox.NumberStyles.Assign(dia.TemplateWP.NumberStyles);
            FEditBox.ParStyles.Assign(dia.TemplateWP.ParStyles);
            if OverwriteAttr then
            for i:=0 to FChangedStyles.Count-1 do
            begin
               ele := FEditBox.ParStyles.FindStyle(FChangedStyles[i]);
               if ele<>nil then
                  ele.OverwritePar(true, true);
            end;
            FEditBox.ReformatAll(true);
            FEditBox.Invalidate;
            FEditBox.SetFocusValues(true);
          end;
      end;
        // if checkp>=0 then FEditBox.Memo.UndoStack.UndoToCheckpoint(checkp);
    end;
  finally
    dia.Free;
  end;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


procedure TWPStyleDefinition.btnChangeStyleClick(Sender: TObject);
var
  cancelEdit: Boolean;
begin
  CancelEdit := false;
  if (TemplateWP.ActiveStyleName <> '') and
    assigned(Controller.fOnBeforeStyleEdit) then
    Controller.fOnBeforeStyleEdit(Self,
      TemplateWP.ActiveStyleName
      , CancelEdit);
  if not CancelEdit then
  begin
    WPOneStyleDlg1.FWindowLeft := Left;
    WPOneStyleDlg1.FWindowTop := Top;
    WPOneStyleDlg1.StyleName := NameEdit.Text;
    WPOneStyleDlg1.ProcessUpdate := FALSE;
    //WPOneStyleDlg1.FNumberStyles := TemplateWP.NumberStyles;
    if WPOneStyleDlg1.Execute then
    begin
      UpdateList;
      ListBox1Click(nil);
    end;
    if Controller.FChangedStyles.IndexOf(WPOneStyleDlg1.StyleName)<0 then
       Controller.FChangedStyles.Add(WPOneStyleDlg1.StyleName);
  end;
end;

procedure TWPStyleDefinition.UpdateList;
begin
  ListBox1.Items.Clear;
  TemplateWP.ParStyles.GetStringList(ListBox1.Items);
  DelStyle.Enabled := ListBox1.Items.Count > 0;
  btnChangeStyle.Enabled := FALSE;
  ListBox1.ItemIndex := -1;
  ListBox1Click(nil);
end;

procedure TWPStyleDefinition.FormShow(Sender: TObject);
begin
  TemplateWP.SelectAll;
  TemplateWP.InputString(labPreviewText.Caption);
  TemplateWP.HideSelection;
  ListBox1.SetFocus;
end;

procedure TWPStyleDefinition.ListBox1Click(Sender: TObject);
var
  i: Integer;
  sty: TWPTextStyle;
  styele: TWPRTFStyleElement;
begin
  i := ListBox1.ItemIndex;
  TemplateWP.FirstPar.ClearCharAttributes;
  TemplateWP.FirstPar.ClearProps;
  TemplateWP.FirstPar.ABaseStyleName := '';
  WPRichText1.FirstPar.NextPar.ClearProps;
  WPRichText1.NumberStyles.Assign(TemplateWP.NumberStyles);
  NameEdit.Text := '';
  BasedOn.Text := '';
  if i < 0 then
  begin
    btnOk.Default := TRUE;
    btnChangeStyle.Default := FALSE;
    btnChangeStyle.Enabled := FALSE;
    LocateThisStyleInText.Enabled := FALSE;
    if Controller.FShowValueList then ValueLines.Visible := FALSE;
  end else
  begin
    btnOk.Default := FALSE;
    btnChangeStyle.Default := TRUE;
    btnChangeStyle.Enabled := TRUE;
    LocateThisStyleInText.Enabled := TRUE;
    NameEdit.Text := ListBox1.Items[i];
      // TemplateWP.FirstPar.ABaseStyleName := ListBox1.Items[i];
    styele := TemplateWP.ParStyles.FindStyle(ListBox1.Items[i]);
    if styele <> nil then
    begin
      sty := styele.TextStyle;
      NameEdit.Text := styele.Name;
      BasedOn.Text := sty.ABaseStyleName;
      TemplateWP.FirstPar.ACopy(sty, 1, 16);
      WPRichText1.FirstPar.NextPar.Assign(sty, false);
      WPRichText1.FirstPar.NextPar.ADelAllFromTo(1, 16);

      if Controller.FShowValueList then
      begin
        ValueLines.Text := sty.ABaseStyleString;
        ValueLines.Visible := TRUE;
        labPreviewFont.Visible := FALSE;
      end;
    end;
  end;
  TemplateWP.ReformatAll(true, true);
  WPRichText1.ReformatAll(true, true);

  ListBox1.Invalidate;
end;

procedure TWPStyleDefinition.LoadStyleSheetClick(Sender: TObject);
var
  WPStyleCollection1: TWPStyleCollection;
  f: TFileStream;
  s: string;
  a, b: Integer;
  IsWPCSS: Boolean;
begin
  with TOpenDialog.Create(Self) do
  try
    if Controller.FFilterString = '' then
      Filter := WPLoadStr(meFilterCSS)
    else Filter := Controller.FFilterString;
    if Execute then
    begin
      f := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
      try
        // Autodetect WPCSS:
        // It contains the '=' sign before any '[' or '{'
        SetLength(s, 300);
        SetLength(s, f.Read(s[1], 300));
        IsWPCSS := FALSE;
        if (Length(s) > 10) and (s[1] <> '[') then // Quickly check for INI format
        begin
          a := Pos('=', s);
          if a > 0 then
          begin
            b := Pos('{', s);
            if b <= 0 then b := Pos('[', s);
            if (a < b) or (b <= 0) then IsWPCSS := TRUE;
          end;
        end;
      finally
        f.Free;
      end;

      if IsWPCSS then TemplateWP.ParStyles.LoadFromFile(FileName) else
      begin
        WPStyleCollection1 := TWPStyleCollection.Create(nil);
        try
          WPStyleCollection1.LoadFromFile(Filename);
        // TemplateWP.ParStyles.Clear;     NO!!!!
          WPStyleCollection1.WriteStyles(TemplateWP);
        finally
          WPStyleCollection1.Free;
        end;
      end;
      UpdateList;
      ListBox1Click(nil);
    end;
  finally
    Free;
  end;
end;

procedure TWPStyleDefinition.SaveStyleSheetClick(Sender: TObject);
var WPStyleCollection1: TWPStyleCollection;
begin
  with TSaveDialog.Create(Self) do
  try
    if Controller.FFilterString = '' then
      Filter := WPLoadStr(meFilterCSS)
    else Filter := Controller.FFilterString;
    if Execute then
    begin
      if (CompareText(ExtractFileExt(Filename), '.wpcss') = 0) or
        (Controller.FSaveCSSAsWPCSS and (CompareText(ExtractFileExt(Filename), '.css') = 0)) then
      begin
        TemplateWP.ParStyles.SaveToFile(FileName);
      end else
      begin
        WPStyleCollection1 := TWPStyleCollection.Create(nil);
        WPStyleCollection1.ControlledMemos.Add.EditBox := TemplateWP;
        try
          WPStyleCollection1.ReadStyles(TemplateWP);
          WPStyleCollection1.SaveToFile(Filename);
        finally
          WPStyleCollection1.Free;
        end;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TWPStyleDefinition.DelStyleClick(Sender: TObject);
var
  i: Integer;
  CancelDeletion: Boolean;
  sname: string;
begin
  i := ListBox1.ItemIndex;
  if i >= 0 then
  begin
    CancelDeletion := false;
    sname := ListBox1.Items[i];
    if assigned(Controller.fOnBeforeStyleDelete) then
      Controller.fOnBeforeStyleDelete(Self, sname, CancelDeletion);
    if not CancelDeletion and
      (MessageDlg(DelStyle.Hint + #32 + sname,
      mtWarning, [mbYes, mbNo], 0) = ID_Yes) then
    begin
      if TemplateWP.ParStyles.FindStyle(sname) <> nil then
        TemplateWP.ParStyles.FindStyle(sname).Free;
      UpdateList;
      ListBox1Click(nil);
    end;
  end;
end;

procedure TWPStyleDefinition.NewStyleClick(Sender: TObject);
begin
  WPOneStyleDlg1.FWindowLeft := Left;
  WPOneStyleDlg1.FWindowTop := Top;
  WPOneStyleDlg1.StyleName := labNewStyleName.Caption;
  WPOneStyleDlg1.ProcessUpdate := FALSE;
  WPOneStyleDlg1.CreateNewStyleDlg;
  if Controller.FChangedStyles.IndexOf(WPOneStyleDlg1.StyleName)<0 then
       Controller.FChangedStyles.Add(WPOneStyleDlg1.StyleName);
  UpdateList;
end;

// We locate in the text the first or the next paragraph which is using this style

procedure TWPStyleDefinition.LocateThisStyleInTextClick(Sender: TObject);
begin
  if (Controller.EditBox <> nil) and (ListBox1.ItemIndex >= 0) then
  begin
    if FNeedFromStart then
         FNeedFromStart := not Controller.EditBox.ParStyleLocateFirst(NameEdit.Text)
    else FNeedFromStart := not Controller.EditBox.ParStyleCPMoveTo(NameEdit.Text);
  end;
end;

procedure TWPStyleDefinition.FormCreate(Sender: TObject);
begin
  WPOneStyleDlg1 := TWPOneStyleDlg.Create(Self);
  WPOneStyleDlg1.EditBox := TemplateWP;
  TemplateWP.Readonly := FALSE;
  TemplateWP.Clear;
  TemplateWP.FirstPar.SetText('Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd Abcd.');
  TemplateWP.Readonly := TRUE;
  TemplateWP.ViewOptions := TemplateWP.ViewOptions - [wpNoEndOfDocumentLine];
  WPRichText1.ViewOptions := WPRichText1.ViewOptions - [wpNoEndOfDocumentLine];
end;

procedure TWPStyleDefinition.ListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  ListBox1.Canvas.Brush.Style := bsSolid;
  if Index = ListBox1.ItemIndex then
    ListBox1.Canvas.Brush.Color := TemplateWP.HighLightColor
  else ListBox1.Canvas.Brush.Color := ListBox1.Color;
  ListBox1.Canvas.FillRect(rect);

  TemplateWP.ParStylePaint(ListBox1.Items[Index], ListBox1.Canvas, Rect);
  if Index = ListBox1.ItemIndex then
  begin
    ListBox1.Canvas.Pen.Color := clBtnShadow;
    ListBox1.Canvas.Pen.Width := 0;
    ListBox1.Canvas.Pen.Style := psSolid;
    ListBox1.Canvas.Brush.Style := bsClear;
    ListBox1.Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  end;
end;

procedure TWPStyleDefinition.NormalizethisParagraph1Click(Sender: TObject);
begin
  if (Controller.EditBox <> nil) and (Controller.EditBox.ActiveParagraph <> nil) then
  begin
    Controller.EditBox.ActiveParagraph.ClearCharAttributes(true);
    Controller.EditBox.DelayedReformat;
  end;
end;

procedure TWPStyleDefinition.NormalizeAllParagraphs1Click(Sender: TObject);
begin
  if (Controller.EditBox <> nil) and (ListBox1.ItemIndex >= 0) then
  begin
    Controller.EditBox.ParStyleNormalizePar(NameEdit.Text);
  end;
end;

procedure TWPStyleDefinition.ListBox1DblClick(Sender: TObject);
begin
 if ListBox1.ItemIndex>=0 then
    btnChangeStyleClick(nil);
end;

end.

