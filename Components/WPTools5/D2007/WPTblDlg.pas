unit WPTblDlg;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPStyles - Copyright (C) 2004 by wpcubed GmbH
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  Dialog to create a table
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{ Create Table - This unit used to work for WPTools 4. WPTools 5 offers
  optimized methods to create and manage a table.
  Please see the source of this unit to compare the 'old' and the 'new' code }

{$I WPINC.INC}
{$DEFINE WPTools5}

interface

uses Windows,  SysUtils, Messages, Classes, Graphics, Controls,
     Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, WPUtil, WPCtrMemo, WPRTEDefs;

//REMOVED: WPDefs, WPRtfPA, WPWinctr, WPRich
//ADDED: WPCtrMemo, WPRTEDefs

type
  TWPTableDlgOptions = set of (
    wpNestingAsInEditOptions, // "AllowTableInTable" as specified in TWPRichText.EditOptions
    wpAllowTableInTable,     // Display the checkbox to create a nested table
    wpDefaultTableInTable    // If possible set "nested" = checked
    );

  {$IFNDEF T2H}
  TWPTableDialog = class(TWPShadedForm)
    labColumns: TLabel;
    labRows: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    seColumns: TWPValueEdit;
    seRows: TWPValueEdit;
    ShowBord: TSpeedButton;
    labAlignment: TLabel;
    labWidth: TLabel;
    labBorder: TLabel;
    CmbBxAlignment: TComboBox;
    CmbBxBorder: TComboBox;
    seWidth: TWPValueEdit;
    cbNestTable: TCheckBox;
    procedure FormActivate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure seColumnsChange(Sender: TObject);
    procedure seWidthChange(Sender: TObject);
  public
    FOptions : TWPTableDlgOptions;
  {$IFDEF WPTools5}
    fsEditBox : TWPCustomRtfEdit;
  {$ELSE}
   { fsEditBox : TWPCustomRichText;
    RtfText   : TWPRtfTextPaint; }
  {$ENDIF}
  end;
  {$ENDIF}

  TWPTableDlg = class(TWPCustomAttrDlg)
  private
    dia      : TWPTableDialog;
    FOptions : TWPTableDlgOptions;
  public
    function Execute : Boolean; override;
    constructor Create(AOwner: TComponent); override;
  published
    property EditBox;
    property Options : TWPTableDlgOptions read FOptions write FOptions default [];
  end;


implementation

{$R *.DFM}

constructor TWPTableDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Options := [wpNestingAsInEditOptions];
end;

function TWPTableDlg.Execute : Boolean;
begin
  Result := FALSE;
  if assigned(FEditBox) and Changing then
    begin
      dia := TWPTableDialog.Create(Self);
      try
        // dia.RtfText            := (FEditBox.RtfText as TWPRtfTextPaint);
        dia.fsEditBox          := FEditBox;
        dia.FOptions           := FOptions;
        if wpNestingAsInEditOptions in FOptions then
             dia.cbNestTable.Visible :=  (wpAllowCreateTableInTable  in FEditBox.EditOptions) and FEditBox.InTable
        else dia.cbNestTable.Visible :=  (wpAllowTableInTable in FOptions) and FEditBox.InTable;
        dia.cbNestTable.Checked :=  FEditBox.InTable and (wpDefaultTableInTable in FOptions);

        dia.CmbBxBorder.Items.Clear;
        dia.CmbBxBorder.Items.Add( WPLoadStr(meDiaYes) );
        dia.CmbBxBorder.Items.Add( WPLoadStr(meDiaNo) );

        dia.CmbBxAlignment.Items.Clear;
        dia.CmbBxAlignment.Items.Add( WPLoadStr(meDiaAlCenter) );
        dia.CmbBxAlignment.Items.Add( WPLoadStr(meDiaAlLeft) );
        dia.CmbBxAlignment.Items.Add( WPLoadStr(meDiaAlRight) );
        if not FCreateAndFreeDialog  and MayOpenDialog(dia) and (dia.ShowModal=ID_OK) then Result := TRUE
        else FEditBox.Modified := FOldModified;
      finally
        dia.Free;
      end;
    end;
end;

procedure TWPTableDialog.FormActivate(Sender: TObject);
begin
  // if RtfText.Header.UsedUnit = UnitCm then GlobalValueUnit := euCM
  // else GlobalValueUnit := euInch;
  seColumns.Value     := 2;
  seRows.Value        := 2;
  seWidth.Value       := 100;
  CmbBxAlignment.ItemIndex := 1;
  CmbBxBorder.ItemIndex := 0;

end;

procedure TWPTableDialog.btnOkClick(Sender: TObject);
 var
   bdr : Boolean;
   r,c : Integer;
   opt : TWPTableAddOptions;
   FirstCell : TParagraph;
   pagew : Integer;
begin
  r  := seRows.Value;
  C := seColumns.Value;
  if CmbBxBorder.ItemIndex = 0 then bdr := True else bdr := False;

  opt := [];
  if cbNestTable.Checked then
        include(opt,wptblAllowNestedTables);
  if bdr then include(opt,wptblActivateBorders);

  FirstCell := fsEditBox.TableAdd(c,r,opt);
  fsEditBox.ActiveParagraph := FirstCell;
  if seWidth.Value<100 then
  begin
      pagew := fsEditBox.Header.PageWidth -
         fsEditBox.Header.LeftMargin - fsEditBox.Header.RightMargin;
      FirstCell.ParentTable.ASet(WPAT_BoxWidth_PC, seWidth.Value*100);
      if CmbBxAlignment.ItemIndex=0 then  // Center
         FirstCell.ParentTable.ASet(
             WPAT_BoxMarginLeft,
               MulDiv( pagew, seWidth.Value, 100) div 2)
      else if CmbBxAlignment.ItemIndex=2 then  // Right
         FirstCell.ParentTable.ASet(
             WPAT_BoxMarginLeft,
               MulDiv( pagew, seWidth.Value, 100) );

  end;

  if (FirstCell<>nil) and (FirstCell.ParentTable<>nil) then   //V5.22.2
  begin
     FirstCell := FirstCell.ParentTable;
     if FirstCell.NextPar=nil then
        FirstCell.NextPar := TParagraph.Create(FirstCell.RTFData);
  end;

  fsEditBox.Refresh;
  ModalResult := mrOk
end;

procedure TWPTableDialog.FormCreate(Sender: TObject);
begin
   seColumns.NoUnitText := TRUE;
   seRows.NoUnitText := TRUE;
   seWidth.NoUnitText := TRUE;
   CmbBxAlignment.ItemIndex := 0;
   CmbBxBorder.ItemIndex := 0;
end;


procedure TWPTableDialog.seColumnsChange(Sender: TObject);
begin
  if (Sender as TWPValueEdit).Value<1 then
       TWPValueEdit(Sender).Value := 1;
end;

procedure TWPTableDialog.seWidthChange(Sender: TObject);
begin
  if (Sender as TWPValueEdit).Value>100 then
       TWPValueEdit(Sender).Value := 100;
end;

end.
