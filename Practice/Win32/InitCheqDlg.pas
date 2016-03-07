unit InitCheqDlg;
//------------------------------------------------------------------------------
{
   Title:       Initial Cheques Dialog

   Description:

   Remarks:     Called by OUTSTAND.PAS

   Author:

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcTCmmn, OvcTable, OvcTCell, OvcTCStr, OvcTCBEF,
  OvcTCNum, ExtCtrls, globals, ExistingChequesFme,
  OSFont;

type
  pInitChqArray = ^tInitChqArray;
  tInitChqArray = Array[1..Max_Init_Chq] of  integer;

type
  TdlgInitCheq = class(TForm)
    tblCheques: TOvcTable;
    OvcController1: TOvcController;
    ColNumeric: TOvcTCNumericField;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    ShapeBorder: TShape;
    InfoBmp: TImage;
    Label5: TLabel;
    lblChequesDate: TLabel;
    ShapeBottom: TShape;
    Shape2: TShape;
    fmeCheques: TfmeExistingCheques;

    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tblChequesActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum:  Integer);
    procedure tblChequesGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tblChequesExit(Sender: TObject);
    procedure tblChequesBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblChequesEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblChequesEnter(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    MaxWidth  : integer;
    okPressed : boolean;
    FData     : pInitChqArray;
    FPtr      : pointer;
    EditMode  : boolean;
  public
    { Public declarations }
    function Execute(P : pointer) : boolean;
  end;

//******************************************************************************
implementation

uses
  bkXPThemes,
  OvcConst,
  bkConst,
  BKHelp,
  ErrorMorefrm, bkBranding;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgInitCheq.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
function TdlgInitCheq.Execute(p:pointer):boolean;
begin
   result := false;
   EditMode := false;

   if tblCheques.Columns.Count <> Max_Init_Chq_Cols then
      begin HelpfulErrorMsg('InitCheqDlg: MaxCols <> ColCount',0); exit; end;

   FPtr  := p;
   FData := pInitChqArray(p);
   ShowModal;
   result := OKPressed;
end;    //
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
  if (tblCheques.ActiveRow = (tblCheques.RowLimit-1)) and (command = ccDown) then
  begin
     Inc(ColNum);
     RowNum := 0;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  DataCell : integer;
begin
  Data := nil;

  if Assigned(FPtr) then
     if ((RowNum>=0) and (RowNum <= tblCheques.RowLimit-1)) then
     begin

       DataCell := (ColNum+1)+(RowNum * Max_Init_Chq_Cols);
       if DataCell <= Max_Init_Chq then
          Data     := @FData^[DataCell];
     end;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);

  bkBranding.StyleOvcTableGrid(tblCheques);

  lblChequesDate.Font.Style := [fsBold];
  fmeCheques.lblDates.Font.Style := [fsBold];
  fmeCheques.lblDates.Top := fmeCheques.lblDates.Top + 3;
  if tblCheques.Columns.Count <> Max_Init_Chq_Cols then
     tblCheques.RowLimit := 1
   else
     tblCheques.RowLimit := Max_Init_Chq_Rows;

   MaxWidth := Max_Init_Chq_Cols;

   tblCheques.Controller.EntryCommands.AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
   SetUpHelp;


   ColNumeric.PictureMask := ChequeNoMask;
end;
procedure TdlgInitCheq.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key = char(VK_Escape) then begin
      Key := #0;
      Close;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgInitCheq.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Adding_initial_unpresented_cheques;
   //Components
   tblCheques.Hint :=
                   'Enter the cheque serial number(s)|' +
                   'Enter the serial numbers for the Initial Unpresented Cheques';
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      ColNumeric.SendKeyToTable(Msg);
   end;

   btnOk.Default := true;
   btnCancel.Cancel := true;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
   EditMode := true;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
   EditMode := false;
end;
//------------------------------------------------------------------------------
procedure TdlgInitCheq.tblChequesEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

end.
