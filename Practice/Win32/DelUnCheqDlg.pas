unit DelUnCheqDlg;
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcTCHdr, OvcTCBEF, OvcTCNum, OvcTCmmn, OvcTCell, OvcTCStr,
  OvcBase, OvcTable, ovcConst, globals, BAObj32, UEList32, ExtCtrls,
  ExistingChequesFme,
  OSFont;

type
  pUnChqArray = ^tUnChqArray;
  tUnChqArray = Array[1..MaxUnChq] of record
                          SN1,SN2 : integer;
                        end;

type
  TdlgDelUnCheque = class(TForm)
    tblFromTo: TOvcTable;
    OvcController1: TOvcController;
    OvcTCColHead1: TOvcTCColHead;
    ColFrom: TOvcTCNumericField;
    Col2: TOvcTCNumericField;                                                   
    OvcTCRowHead1: TOvcTCRowHead;
    btnOK: TButton;
    btnCancel: TButton;
    Shape1: TShape;
    fmeCheques: TfmeExistingCheques;
    label1: TLabel;
    Label5: TLabel;
    InfoBmp: TImage;
    lblCodingRange: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure tblFromToGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblFromToActiveCellMoving(Sender: TObject; Command: Word;
      var RowNum, ColNum: Integer);
    procedure tblFromToActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tblFromToEnter(Sender: TObject);
    procedure tblFromToExit(Sender: TObject);
  private
    { Private declarations }
     FData : pUnChqArray;
     procedure SetUpHelp;
     function NoOverlaps : boolean;
  public
    { Public declarations }
  end;

  function EnterChequeRangeToDelete( BA : TBank_Account;
                                     FromDate, ToDate : LongInt;
                                     DeleteList : TSeqList ): Boolean;

//******************************************************************************
implementation

uses
  BKCONST,
  bkDateUtils,
  BKHelp,
  bkXPThemes,
  InfoMoreFrm,
  LogUtil,
  UpdateMF, bkBranding;

{$R *.DFM}

CONST
   UnitName = 'DelUnCheqDlg';
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  lblCodingRange.Font := Font;
  lblCodingRange.Font.Style := [fsBold];
  tblFromTo.RowLimit := MaxUnChq+1;  {+1 for header}
  tblFromTo.CommandOnEnter := ccright;

  bkBranding.StyleOvcTableGrid(tblFromTo);
  bkBranding.StyleTableHeading(OvcTCColHead1);

  SetUpHelp;
  ColFrom.PictureMask := ChequeNoMask;
  Col2.PictureMask    := ChequeNoMask;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   tblFromTo.Hint   :=
                    'Enter the cheque number range(s) to delete|'+
                    'Enter the cheque number range(s) to delete of the Unpresented Cheques';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.tblFromToGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  Data := nil;
  if Assigned(FData) then
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
procedure TdlgDelUnCheque.tblFromToActiveCellMoving(Sender: TObject;
  Command: Word; var RowNum, ColNum: Integer);
begin
  if (tblFromTo.ActiveCol = 2) and (command = ccRight) then begin
     if Rownum+1 <= tblFromTo.RowLimit then begin
        Inc(RowNum);
        ColNum := 1;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.tblFromToActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
begin
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.tblFromToEnter(Sender: TObject);
// Set Default Behaviours for Buttons Off when entering Grid
begin
   btnOk.Default := False;
   btnCancel.Cancel := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.tblFromToExit(Sender: TObject);
// Set Default Behaviours for Buttons back on
begin
   btnOk.Default := True;
   btnCancel.Cancel := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgDelUnCheque.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   CanClose := True;
   if ModalResult = mrOk then begin
      with tblFromTo do begin
         if InEditingState then
            StopEditingState( True );
      end;
      if not NoOverlaps then begin
         CanClose := False;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgDelUnCheque.NoOverlaps :boolean;
var
  range, diff, i : integer;
  overlap        : boolean;
  OverlapWith    : integer;
  S : String;
begin
   result := False;
   overlap := False;
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
        S := Format( 'Cheque range %d overlaps cheque range %d.', [ Range, OverlapWith ] );
        HelpFulInfoMsg( S, 0 );
        Exit;
      end;
   end;
   Result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EnterChequeRangeToDelete( BA : TBank_Account;
                                   FromDate, ToDate : LongInt;
                                   DeleteList : TSeqList ): Boolean;
//DeleteList is filled with Ranges of Cheques to Delete
var
  DeleteArray : tUnChqArray;
  DelUnCheque : TdlgDelUnCheque;
  Range, i    : Integer;
  ps          : pSeqInfo;
begin
   DeleteList.DeleteAll;
   FillChar(DeleteArray,SizeOf(DeleteArray),#0);
   DelUnCheque := TdlgDelUnCheque.Create(Application.MainForm);
   with DelUnCheque do begin
      try
         BKHelpSetUp(DelUnCheque, BKH_Deleting_unpresented_cheques);
         FData := @DeleteArray;
         lblCodingRange.caption := bkDate2Str(FromDate)+' - ' + bkDate2Str(ToDate);
         fmeCheques.Fill( BA, FromDate, ToDate);
         //show upc page by default
         fmeCheques.pgCheques.ActivePage := fmeCheques.tbsUnpresented;
         //----------------
         ShowModal;
         //----------------
         Result := ( ModalResult = mrOk );
         If Result then begin
            //Fill Delete List with Range Data
            for Range := 1 to MaxUnChq do begin
               with DeleteArray[Range] do begin
                  if not ( ( sn1=0 ) or ( sn2=0 ) ) then begin
                     LogUtil.LogMsg( lmInfo, UnitName, 'Delete UPC Cheque Range '+inttostr(sn1)+'-'+inttostr(sn2) +
                                                       ' period ' + bkDate2str( FromDate) + '-' + bkDate2Str( ToDate));
                     // Other checks on rnages performed above
                     for i := sn1 to sn2 do begin
                        ps := NewSeqInfo(i);
                        if Assigned(ps) then
                           DeleteList.Insert(ps);
                     end;
                  end;
               end;
            end;
         end;
      finally
         Free;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
