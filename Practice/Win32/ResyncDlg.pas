unit ResyncDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  This dialog is only used if the transactions cannot be matched automatically.
  Its purpose is to show the user the list of transactions in both the clients
  bank account and in the admin bank account.  The user must then select which
  transactions to start downloading from
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, trxList32, bkDefs, ComCtrls, ExtCtrls,
  ImgList, OvcTCEdt, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcBase,
  OvcTable,
  OsFont;

type
  TdlgResync = class(TForm)
    pnlAdmin: TPanel;
    lblAdmin: TLabel;
    pnlClient: TPanel;
    lblClient: TLabel;
    Splitter1: TSplitter;
    tblClient: TOvcTable;
    OvcController1: TOvcController;
    tblAdmin: TOvcTable;
    clientColHeader: TOvcTCColHead;
    adminColHeader: TOvcTCColHead;
    ccolDate: TOvcTCString;
    cColRef: TOvcTCString;
    cColAnalysis: TOvcTCString;
    cColAmount: TOvcTCString;
    cColOther: TOvcTCString;
    cColPart: TOvcTCString;
    cColNarration: TOvcTCString;
    cColEntryType: TOvcTCString;
    cColBSDate: TOvcTCString;
    aColDate: TOvcTCString;
    aColRef: TOvcTCString;
    aColAnalysis: TOvcTCString;
    aColAmount: TOvcTCString;
    aColOther: TOvcTCString;
    aColPart: TOvcTCString;
    aColNarration: TOvcTCString;
    aColEntryType: TOvcTCString;
    aColBSDate: TOvcTCString;
    pnlBanner: TPanel;
    lblBanner: TLabel;
    pnlButtons: TPanel;
    Image1: TImage;
    Label3: TLabel;
    lblNew: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormResize(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tblClientGetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblAdminGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblClientActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblAdminActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblAdminGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure tblAdminEnteringRow(Sender: TObject; RowNum: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    tmpString : string;
    ReverseFieldOrder: boolean;
    OtherCol         : integer;
    PartCol          : integer;

    WasRow           : integer;
    SelectedLRN      : integer;
    DoingLineUp      : boolean;

    procedure InitTable;
    function RowNumOK( RowNum : integer;
                       aTable: TOvcTable;
                       TransList : TTransaction_List): boolean;

  public
    { Public declarations }
    AdminTransList  : TTransaction_List;
    ClientTransList : TTransaction_List;
    Country         : byte;
    AccountNo       : string;

    function GetLastLRN : integer; //return -1 if failed
  end;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkConst,
  bkdateUtils,
  bkXPThemes,
  GenUtils,
  Imagesfrm,
  stDatest,
  globals,
  YesNoDlg,
  MonitorUtils;

const
   {column constants}
   DateCol          = 0;
   RefCol           = 1;
   AnalysisCol      = 2;
   AmountCol        = 3;
   OtherPartCol     = 4;    {nz}
   PartOtherCol     = 5;    {nz}
   StmtDetCol       = 6;
   EntryCol         = 7;
   BSDateCol        = 8;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.FormCreate(Sender: TObject);
const
   Margin = 20;
var
//   Mon       : HMonitor;
//   pMonInfo  : pMonitorInfo;
   WorkArea : TRect;
begin
  bkXPThemes.ThemeForm( Self);
  lblBanner.Font.Name := Font.Name;
  LblNew.Font.Color := clred;
  //Find out what area we have to work with
  WorkArea := GetDesktopWorkArea;
  //Set Size and Position
  Top         := WorkArea.Top + Margin;
  Left        := WorkArea.Left + Margin;
  Width       := WorkArea.Right - WorkArea.Left - ( Margin * 2);
  Height      := WorkArea.Bottom - WorkArea.Top - ( Margin * 2);

  DoingLineUp := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.FormShow(Sender: TObject);
begin
   //Setup Tables
   with tblAdmin do
      topRow := RowLimit -1;

   with tblClient do
      topRow := RowLimit -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.FormResize(Sender: TObject);
begin
  pnlClient.height := ( Clientheight - pnlButtons.height - splitter1.height - pnlBanner.height ) div 3;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeAmount(f: Comp):string;
begin
   result := FormatFloat('#,##0.00;(#,##0.00)',f/100);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function MakeRef( S : String ): String;
{if this is a number then remove leading zeros}
Begin
   result := S;
   If IsNumeric( S ) then
   Begin
      {remove leading zeros}
      While ( Length( S )>0 ) and ( S[1]='0' ) do System.Delete(S,1,1);
      result:=S ;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.btnCancelClick(Sender: TObject);
begin
   if AskYesNo( 'Synchronise Account',
                'If you do not synchronise this Bank Account you will not be '+
                'able to synchronise the Client File.'#13#13+
                'Do really want to cancel this process?',DLG_NO,0) = DLG_YES then
   begin
      Close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblClientGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  Trans : pTransaction_Rec;   {use a temporary pointer for this}
begin
 Data := nil;

 {validate}
 if assigned(ClientTransList) then
 if RowNumOK(RowNum, tblClient, ClientTransList ) then
 {get data}
    with ClientTransList do begin
         Trans := Transaction_At(RowNum-1);
         case ColNum of

           DateCol:
              begin
                 tmpString := StDateToDateString(BKDATEFORMAT,Trans.txDate_Effective,false);
                 data := PChar(tmpString);
              end;

           RefCol:
              begin
                tmpString := GetFormattedReference( Trans);
                data := PChar(tmpString);
              end;

           AnalysisCol:
              data := @Trans.txAnalysis;


           AmountCol:
              begin
                tmpString := MakeAmount(Trans.txAmount);
                data := PChar(tmpString);
              end;

           StmtDetCol : begin
              tmpString := Trans.txStatement_Details;
              data := PChar( tmpString);
           end;

           OtherPartCol,PartOtherCol:         {default = other   reverse = part}
              if ColNum = OtherCol then
                data := @(Trans.txOther_Party)
              else
                data := @(Trans.txParticulars);


           EntryCol:
              begin
                 tmpString := IntToStr(Trans.txType); //+ ':' + MxClient.clFields.clShort_Name[Trans.txType];

                 data := PChar(tmpString);
              end;

           BSDateCol:
              begin
                 if Trans.txDate_Presented > 0 then
                    tmpString := StDateToDateString(BKDATEFORMAT,Trans.txDate_Presented,false)
                 else
                    tmpString := ' ';
                 data := PChar(tmpString);
              end;
         else
            data := nil;
         end;{case}
    end  ; { with do}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.InitTable;
begin
   ReverseFieldOrder := False;

   case Country of
      whNewZealand :
         Begin
            ReverseFieldOrder := GenUtils.ReverseFields( AccountNo );
         end;
      whAustralia :
         Begin
            tblClient.Columns[AnalysisCol].Hidden := true;
            tblClient.Columns[OtherPartCol].Hidden := true;
            tblClient.Columns[PartOtherCol].Hidden := true;

            tblAdmin.Columns[AnalysisCol].Hidden := true;
            tblAdmin.Columns[OtherPartCol].Hidden := true;
            tblAdmin.Columns[PartOtherCol].Hidden := true;
         end;
   end;

   {setup other and particulars cols}
   OtherCol := OtherPartCol;
   PartCol  := PartOtherCol;

   if ReverseFieldOrder then
   begin
     OtherCol := PartOtherCol;
     PartCol  := OtherPartCol;
   end;

   tblClient.Columns[OtherCol].DefaultCell := cColOther;
   tblClient.Columns[PartCol].DefaultCell  := cColPart;
   ClientColHeader.Headings[OtherCol]      := 'Other Party';
   ClientColHeader.Headings[PartCol]       := 'Particulars';

   tblAdmin.Columns[OtherCol].DefaultCell  := aColOther;
   tblAdmin.Columns[PartCol].DefaultCell   := aColPart;
   AdminColHeader.Headings[OtherCol]       := 'Other Party';
   AdminColHeader.Headings[PartCol]        := 'Particulars';

   if Assigned(AdminTransList) then
      tblAdmin.RowLimit := AdminTransList.ItemCount+1;

   if Assigned(ClientTransList) then
      tblClient.RowLimit := ClientTransList.ItemCount+1;

   WasRow := 1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgResync.RowNumOK(RowNum : integer; aTable: TOvcTable; TransList : TTransaction_List): boolean;
begin
   result := (1 <= RowNum) and (RowNum <= aTable.RowLimit-1) and ((RowNum-1) < TransList.ItemCount);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblAdminGetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  Trans : pTransaction_Rec;   {use a temporary pointer for this}
begin
 Data := nil;

 {validate}
 if assigned(AdminTransList) then
 if RowNumOK(RowNum, tblAdmin, AdminTransList ) then
 {get data}
    with AdminTransList do begin
         Trans := Transaction_At(RowNum-1);
         case ColNum of

           DateCol:
              begin
                 tmpString := StDateToDateString(BKDATEFORMAT,Trans.txDate_Effective,false);
                 data := PChar(tmpString);
              end;

           RefCol:
              begin
                tmpString := GetFormattedReference(Trans);
                data := PChar(tmpString);
              end;

           AnalysisCol:
              data := @Trans.txAnalysis;


           AmountCol:
              begin
                tmpString := MakeAmount(Trans.txAmount);
                data := PChar(tmpString);
              end;

           StmtDetCol : begin
              tmpString := Trans.txStatement_Details;
              data := PChar( tmpString);
           end;

           OtherPartCol,PartOtherCol:         {default = other   reverse = part}
              if ColNum = OtherCol then
                data := @(Trans.txOther_Party)
              else
                data := @(Trans.txParticulars);

           EntryCol:
              begin
                 tmpString := IntToStr(Trans.txType); //+ ':' + MxClient.clFields.clShort_Name[Trans.txType];

                 data := PChar(tmpString);
              end;

           BSDateCol:
              begin
                 if Trans.txDate_Presented > 0 then
                    tmpString := StDateToDateString(BKDATEFORMAT,Trans.txDate_Presented,false)
                 else
                    tmpString := ' ';
                 data := PChar(tmpString);
              end;
         else
            data := nil;
         end;{case}
    end  ; { with do}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblClientActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
//must check if lineup being done already, otherwise both tables try to line up
//each other
begin
  if not DoingLineUp then begin
     DoingLineUp := true;
     try
        tblAdmin.ActiveCol := ColNum;
     finally
        DoingLineUp := false;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblAdminActiveCellChanged(Sender: TObject; RowNum,
  ColNum: Integer);
//must check if lineup being done already, otherwise both tables try to line up
//each other
begin
  if not DoingLineUp then begin
     DoingLineUp := true;
     try
        if RowNum <= tblClient.RowLimit-1 then
           tblClient.ActiveRow := RowNum;

        tblClient.ActiveCol := ColNum;
        tblAdmin.invalidateTable;
     finally
        DoingLineUp := false;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblAdminGetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (RowNum > 0 ) then
     if (RowNum = tblAdmin.ActiveRow)then
     begin
        CellAttr.caColor     := clRed;
        CellAttr.caFontColor := clWhite;
     end
     else
     if (RowNum > tblAdmin.ActiveRow) then begin
        CellAttr.caColor     := clWhite;
        CellAttr.caFontColor := clRed;  //new transactions
     end
     else begin
        CellAttr.caColor     := clWindow;
        CellAttr.caFontColor := clWindowText;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.tblAdminEnteringRow(Sender: TObject; RowNum: Integer);
begin
   tblAdmin.InvalidateRow(WasRow);  //clear highlight
   tblAdmin.InvalidateRow(RowNum);
   WasRow := RowNum;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgResync.btnOKClick(Sender: TObject);
begin
   if RowNumOK(tblAdmin.ActiveRow, tblAdmin, AdminTransList) then begin
      SelectedLRN := AdminTransList.Transaction_At(tblAdmin.ActiveRow-1)^.txTemp_Admin_LRN -1;
      Close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgResync.GetLastLRN: integer;

   //-----------------------------------------------
   procedure PositionOnBestGuess;
   var
      i,j : integer;
      LastMatch : integer;
      MatchFound : boolean;
      at,
      ct         : pTransaction_Rec;
   begin
      //estimate which is the correct entry
      //starting at the second to last entry try to match the trx in
      //admin system with an entry in the client list.
      //when find a match select the next admin entry
      LastMatch := 0;
      MatchFound := false;

      for i := Pred(AdminTransList.ItemCount-1) downto 0 do begin
         at := AdminTransList.Transaction_At(i);

         for j := Pred( ClientTransList.ItemCount) downto 0 do begin
            ct := ClientTransList.Transaction_At(j);

               //try to match cheque no first if have one
               //if found exit

            if at^.txCheque_Number <> 0 then
               MatchFound := (at^.txCheque_Number = ct^.txCheque_Number );

            if MatchFound then break;

               //try to match amount, if get match then reference,
               //if get match then try to match entry type as long as ct is not a UPI

            if ( at^.txAmount = ct^.txAmount ) then
               if (at^.txReference = ct^.txReference ) then
                 if ( ct^.txSource = orBank ) then
                    MatchFound := ( at^.txType = ct^.txType )
                 else
                    MatchFound := true;

            if MatchFound then break;
         end;

         if MatchFound then begin
            LastMatch := i;
            break;
         end;
      end;

      if MatchFound then begin
         tblAdmin.ActiveRow := LastMatch+2;
      end;
   end;
   //--------------------------

begin
   SelectedLRN := -1;

   InitTable;
   PositionOnBestGuess;
   ShowModal;

   result := SelectedLRN;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
