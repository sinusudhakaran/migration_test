unit UnCheqDlg;
//------------------------------------------------------------------------------
{
   Title:       Add Unpresented Cheques Dialog

   Description: Dialog where user inputs range of cheque numbers to add to the
                current Coding Period

   Remarks:     The caption is set by the calling routine before execute is called
                Dialog is called by OUTSTAND.PAS
                
   Author:

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcTCHdr, OvcTCBEF, OvcTCNum, OvcTCmmn, OvcTCell, OvcTCStr,
  OvcBase, OvcTable, ovcConst, globals, ExtCtrls, ComCtrls,
  ExistingChequesFme,
  OsFont;

type
  pUnChqArray = ^tUnChqArray;
  tUnChqArray = Array[1..MaxUnChq] of record
                          SN1,SN2 : integer;
                        end;

type
  TdlgUnCheque = class(TForm)
    tblFromTo: TOvcTable;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    ColFrom: TOvcTCNumericField;
    Col2: TOvcTCNumericField;
    OvcTCRowHead1: TOvcTCRowHead;
    label1: TLabel;
    lblCodingRange: TLabel;
    ShapeBorder: TShape;
    fmeCheques: TfmeExistingCheques;
    pnlChequeDate: TPanel;
    InfoBmp: TImage;
    Label5: TLabel;
    lblChequesDate: TLabel;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ShapeBottom: TShape;

    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tblFromToGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblFromToActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure tblFromToExit(Sender: TObject);
    procedure tblFromToBeginEdit(Sender: TObject; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblFromToEndEdit(Sender: TObject;
      Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
      var AllowIt: Boolean);
    procedure tblFromToEnter(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     okPressed : boolean;
     FData : pUnChqArray;
     FPtr  : pointer;
     EditMode : boolean;

     function NoOverlaps : boolean;
  public
    { Public declarations }
    function Execute(P : pointer) : boolean;
  end;

//******************************************************************************
implementation

uses
  BKCONST,
  BKHelp,
  InfoMoreFrm,
  updateMF, bkXPThemes, bkBranding;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
   lblCodingRange.Font.Style := [fsBold];
   lblChequesDate.Font.Style := [FSBold];
   tblFromTo.RowLimit := MaxUnChq+1;  {+1 for header}
   tblFromTo.CommandOnEnter := ccright;

   bkBranding.StyleOvcTableGrid(tblFromTo);
   bkBranding.StyleTableHeading(OvcTCColHead1);

   Editmode := false;

   with tblFromTo.Controller.EntryCommands do begin
     {remove F2 functionallity}
     DeleteCommand('Grid',VK_F2,0,0,0);

     {add our commands}
     AddCommand('Grid',VK_F6,0,0,0,ccTableEdit);
   end;

   SetUpHelp;
   BKHelpSetUp(Self, BKH_Adding_unpresented_cheques);

   ColFrom.PictureMask := BKCONST.ChequeNoMask;
   Col2.PictureMask    := BKCONST.ChequeNoMask;
end;

procedure TdlgUnCheque.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key = char(VK_Escape) then begin
      Key := #0;
      Close;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tblFromTo.Hint :=
      'Enter the cheque number range(s)|'+
      'Enter the cheque number range(s) used in this accounting period';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.btnOKClick(Sender: TObject);
begin
   if NoOverlaps then
   begin
     okPressed := true;
     Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.btnCancelClick(Sender: TObject);
begin
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  Data := nil;

  if Assigned(FPtr) then
  begin
      if not ((RowNum>0) and (RowNum <= tblFromTo.RowLimit)) then exit;

      case ColNum of
        1:
           Data := @FData^[RowNum].SN1;
        2:
           Data := @FData^[RowNum].SN2;
      end;    // case
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
  if (tblFromTo.ActiveCol = 2) and (command = ccRight) then
     if Rownum+1 <= tblFromTo.RowLimit then
     begin
       Inc(RowNum);
       ColNum := 1;
     end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgUnCheque.NoOverlaps :boolean;
var
  range, diff, i : integer;
  overlap        : boolean;
  OverlapWith    : integer;
  S : String;
begin
   Result := false;
   overlap := false;
   overlapWith := 0;

   for Range := 1 to MaxUnChq do with FData^[Range] do begin
      if not ( (sn1 = 0) and (sn2 = 0) ) then begin
         Diff := sn2-sn1;
         if (Diff <0) or (Diff>1000) then begin
            S := Format( '%d to %d is not a valid range.'#13, [ sn1, sn2 ] );
            if (Diff < 0) then
               S := S + Format( '%d is larger than %d.', [ sn1, sn2 ] );
            if (Diff > 1000 ) then 
               S := S + 'It contains more than 1000 cheques.';
            Helpfulinfomsg( S, 0 );
            Exit;
         end;
      end;

      {overlap check}
      for i := 1 to MaxUnChq do begin
        if (i <> range) then with FData^[i] do begin
          if (sn1<>0) and (sn2<>0) then begin
            if ((sn1 >= FData^[Range].SN1) and (sn1<=FData^[Range].SN2)) or
               ((sn2 >= FData^[Range].Sn1) and (sn2<=FData^[Range].Sn2)) then begin
              OverLap := true;
              OverLapWith := i;
              Break;
            end;
          end;
        end;
      end;

      if OverLap then begin
        HelpFulInfoMsg('Range '+inttostr(range)+' overlaps cheque range ' + inttostr(OverlapWith), 0 );
        exit;
      end;
   end;
   Result := true;
end;    //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToExit(Sender: TObject);
var
  Msg : TWMKey;
begin
  {lost focus so finalise edit if in edit mode}
   if EditMode then
   begin
      Msg.CharCode := vk_f6;
      ColFrom.SendKeyToTable(Msg);
   end;

   btnOk.Default := true;
   btnCancel.Cancel := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToBeginEdit(Sender: TObject; RowNum,
  ColNum: Integer; var AllowIt: Boolean);
begin
  EditMode := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToEndEdit(Sender: TObject;
  Cell: TOvcTableCellAncestor; RowNum, ColNum: Integer;
  var AllowIt: Boolean);
begin
  EditMode := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUnCheque.tblFromToEnter(Sender: TObject);
begin
   btnOk.Default    := false;
   btnCancel.Cancel := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgUnCheque.Execute(p:pointer):boolean;
begin
   Editmode := false;
   FPtr  := p;
   FData := pUnChqArray(p);
   ShowModal;
   result := OKPressed;
end; 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
