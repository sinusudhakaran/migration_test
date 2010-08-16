unit ImportHistDlg;
//------------------------------------------------------------------------------
{
   Title:        BankLink Import History Dialog unit

   Description:  CSV import of Historical transactions.
                 Designed for internet banking download files.
                 Could easaly be updated for more fields, including Coding.

   Remarks:      The Date mask scope should be updated. It should be per reload, not per column.

                 Some of the UK files seem to be ';' Delimited, the Delimiter selection is hidden at the moment
                 Mainly because they seem to have ',' in the fields which may present a problem

                 In general that is what is missing anyway... the text fields are not parsed for invaid chars.

   Author:       Andre' Joosten, Feb 2009

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,Contnrs,
  BKDateUtils,
  Dialogs, ExtCtrls, VirtualTrees, StdCtrls, baObj32, txul, HistoricalDlg, OsFont,
  ComCtrls, moneyDef, Mask, RzEdit, RzSpnEdt,ImportHistClass;

type
  ControlList =  array of TControl;
  AmountType  =  (NotAmount, Amount, AmountWithSign);
  PMoney = ^Money;

type
  TImportHist = class(TForm)
    pFileinput: TPanel;
    pBtn: TPanel;
    pFile: TPanel;
    BTNBrowse: TButton;
    EPath: TEdit;
    OpenDlg: TOpenDialog;
    Label1: TLabel;
    chFirstline: TCheckBox;
    PFormat: TPanel;
    PCFormat: TPageControl;
    TSDate: TTabSheet;
    EDate: TEdit;
    Label2: TLabel;
    TSAmount: TTabSheet;
    TSReference: TTabSheet;
    LColumns: TLabel;
    tsAnalysis: TTabSheet;
    cbDate: TComboBox;
    Label4: TLabel;
    cbAmount: TComboBox;
    cbAmount2: TComboBox;
    lbAmount: TLabel;
    lbAmount2: TLabel;
    cbRef: TComboBox;
    TSNarration: TTabSheet;
    BtnCancel: TButton;
    btnOK: TButton;
    Label3: TLabel;
    cbAna: TComboBox;
    Label5: TLabel;
    cbNar1: TComboBox;
    Label6: TLabel;
    cbNar2: TComboBox;
    Label7: TLabel;
    cbNar3: TComboBox;
    cbSign: TCheckBox;
    SkipLine: TRzSpinEdit;
    Label9: TLabel;
    rbDebitCredit: TRadioButton;
    RBSign: TRadioButton;
    rbSingle: TRadioButton;
    pOut: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    ReloadTimer: TTimer;
    lbFile: TLabel;
    cbDelimiter: TComboBox;
    Label12: TLabel;
    vsOut: TVirtualStringTree;
    vsFile: TVirtualStringTree;
    procedure BTNBrowseClick(Sender: TObject);
    procedure chFirstlineClick(Sender: TObject);
    procedure PCFormatChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbSingleClick(Sender: TObject);
    procedure cbDateChange(Sender: TObject);
    procedure rbDebitCreditClick(Sender: TObject);
    procedure RBSignClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbAmountChange(Sender: TObject);
    procedure SkipLineChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbNar1Change(Sender: TObject);
    procedure cbRefChange(Sender: TObject);
    procedure cbAnaChange(Sender: TObject);


    procedure ReloadTimerTimer(Sender: TObject);
    procedure cbDelimiterChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vsFileGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vsOutGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vsFileChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vsOutChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vsFilePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vsFileBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vsOutPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vsOutBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vsFileHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vsOutHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  private
    FHDEForm: TdlgHistorical;
    FColumnControls: ControlList;
    FLockCount: Integer;
    FKeepCursor: Integer;
    FFormatsettings: TFormatSettings;
    FBankAccount: TBank_Account;
    FHistTranList: TUnsorted_Transaction_List;
    FReloading: Boolean;
    FValidDateRange: tDateRange;
    FOutLvChanged: Boolean;
    FFileLvChanged: Boolean;
    FSubAna: Integer;
    FSubNar: Integer;
    fFileList: TobjectList;
    fOutList: TobjectList;
    FCurrentDate: Integer;
    FDateMask: string;
    procedure BeginUpdate;
    procedure Endupdate;
    procedure ReloadFile;
    procedure SetHDEForm(const Value: TdlgHistorical);
    procedure SetColumnControls(const value: ControlList);
    function GetSelectedCol(index: Integer): Boolean;
    procedure SetSelectedCol(index: Integer; const Value: Boolean);
    procedure SetBankAccount(const Value: TBank_Account);
    procedure SetHistTranList(const Value: TUnsorted_Transaction_List);
    procedure SetFileLvChanged(const Value: Boolean);
    procedure SetOutLvChanged(const Value: Boolean);
    procedure SetDateMask(const Value: string);
    property SelectedCol [index : Integer]: Boolean read GetSelectedCol write SetSelectedCol;
    function GetFileText(const Row,Col: Integer; MaxLen: Integer = 0):string;
    property ColumnControls:ControlList read FColumnControls write SetColumnControls;

    // Some basic test/validation funtions;
    function IsNumericOnly(const Value: string): Boolean;overload;
    function IsNumericOnly(const Value: Integer): Boolean;overload;
    function IsAlphaOnly(const Value: string): Boolean;overload;
    function IsAlphaOnly(const Value: Integer): Boolean;overload;
    function IsDebitCredit(const Value: string): Boolean;overload;//IsSign
    function IsDebitCredit(const Value: Integer): Boolean;overload;
    function IsAmount(const Value: string): AmountType;overload;
    function IsAmount(const Value: Integer): AmountType;overload;
    function IsDate(const Value, Mask: string):Boolean; overload;
    function IsDate(const Value: Integer):string; overload;

    // Other Helpers
    function SwapMonth(const Value: string):string;
    function IsValidColumn(const Value: Integer): Boolean;
    function ColumnColor(const Value: Integer):tColor;
    function ReadNum(Var NumText: string):Integer;
    function ReadMonth(Var NumText: string):Integer;

    function StrtoCurr(Value: string): Currency;
    function StrtoDate(Value,Mask: string): Integer;
    function GetEntryType(Amount: Money): Byte;
    procedure SetDefault(Value: string; ComboBox: TComboBox; Default: integer = 0);
    procedure OutColResize(Value: Integer);
    property FileLvChanged: Boolean read FFileLvChanged write SetFileLvChanged;
    property OutLvChanged: Boolean read FOutLvChanged write SetOutLvChanged;
    property DateMask: string read FDateMask write SetDateMask;
    function CurrentDate: Integer;
    procedure SetUpHelp;
    { Private declarations }
  public
    property HDEForm: TdlgHistorical read FHDEForm write SetHDEForm;
    property BankAccount: TBank_Account read FBankAccount write SetBankAccount;
    property HistTranList: TUnsorted_Transaction_List read FHistTranList write SetHistTranList;
    { Public declarations }
  end;

 function ImportHist(HistTranList: TUnsorted_Transaction_List; BankAccount: TBank_Account;
                      HDEForm: TdlgHistorical): boolean;

implementation

{$R *.dfm}

uses
  Math,
  BKHelp,
  bkXPThemes,
  commCtrl,
  winutils,
  bkConst,
  TransactionUtils,
  bktxio,
  StrUtils,
  GenUtils,
  YesNoDlg,
  bkDefs,
  ErrorMoreFrm,
  Globals,
  stDate,
  ComBoUtils,
  UsageUtils,
  stDatest;

const
  tNone = ' ';
  // Tag for Column Types
  TagAlpha  = 1; // Has no Numbers, Cannot be Date or Amount..
  TagDebitCredit = 2; // Has No Numbers All Rows start with D C or M
  TagAmount = 3; // Has valid amounts  no Negatives
  TagAmountSign = 4; // Valid amounts with some Negatives (No Debit Or Credit Column)
  TagDate = 5; // Has Valid dates...

  TagDateOut = -1;
  TagAmountOut = -2;

  // Index into OutItem,
  SubDate   = 0;
  SubAmount = 1;
  SubRef    = 2;
  // Rest are fields..

  // PageIndex
  piDate = 0;
  piAmount = 1;
  piReference = 2;
  piAnalysis  = 3;
  piNarration = 4;

type
  TFileitem = class (TStringList)
  public
     ListNode: PVirtualNode;
  end;

  TOutitem = class (TFileitem)
  public
     OutMoney : money;
  end;


function ImportHist(HistTranList: TUnsorted_Transaction_List; BankAccount: TBank_Account;
                      HDEForm: TdlgHistorical): boolean;
var Ldlg: TImportHist;
begin
   Ldlg := TImportHist.Create(HDEForm);
   try
      Ldlg.HDEForm := HDEForm;
      Ldlg.BankAccount := BankAccount;
      Ldlg.HistTranList := HistTranList;
      Ldlg.SetBounds(HDEForm.Left + 20,HDEForm.Top + 20, HDEForm.Width - 40, HDEForm.Height - 40);


      Result := ldlg.ShowModal = mrOK;
   finally
      Ldlg.Free;
   end;
end;


procedure TImportHist.BeginUpdate;
begin
   if FLockCount = 0 then begin
      FKeepCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
   end;
   inc(FlockCount);
end;

procedure TImportHist.BTNBrowseClick(Sender: TObject);
begin
   OpenDLG.FileName := EPath.Text;
   if OpenDLG.Execute() then begin
       EPath.Text := OpenDLG.FileName;
       freloading := True; //Stop the triggers Check First...
          chFirstLine.Checked := false;
          SkipLine.IntValue := 0;
       freloading := False;
       
       ReloadFile;
   end;
end;


procedure TImportHist.btnOKClick(Sender: TObject);

   procedure ShowError(Text: string; TS: TTabsheet; Value: TWinControl);
   begin
      HelpfulErrorMsg(Text,0);
      PCFormat.ActivePage := TS;
      Value.SetFocus;
      PCFormatChange(nil);
   end;

   function AskSelection(Text1,Text2: string; TS: TTabsheet; Value: TWinControl): Boolean;
   begin
      if AskYesNo(Text1,Text2, DLG_NO,0) = DLG_YES then begin
         // Its OK to continue...
         Result := False;
      end else begin
         // Go Back and select one..
         PCFormat.ActivePage := TS;
         PCFormatChange(nil);
         Value.SetFocus;
         Result := True;
      end;
   end;

var R: Integer;
    tI: Integer;
    pT: pTransaction_Rec;

    FailCount,
    GoodCount: Integer;

begin
   if fOutlist.Count = 0 then begin
      HelpfulErrorMsg('No valid entries found, try a different file.',0);
      Exit;
   end;

   // Validate ..
   if CBDate.Items.Count = 0 then begin
      ShowError('No valid Date columns found, try a different file.',TSdate,CBDate);
      Exit;
   end;
   if CBDate.ItemIndex < 0 then begin
      ShowError('No Date column selected',TSdate,CBDate);
      Exit;
   end;
   //Amount
   if CBAmount.Items.Count = 0 then begin
      ShowError('No valid Amount columns found, try a different file.',TSAmount,CBAmount);
      Exit;
   end;
   if rbSingle.Checked then begin
      if CBAmount.ItemIndex < 0 then begin
         ShowError('No Amount column selected',TSAmount,CBAmount);
         Exit;
      end;
   end else if RBDebitCredit.Checked then begin
      if CBAmount.ItemIndex < 0 then begin
         ShowError('No Debit column selected',TSAmount,CBAmount);
         Exit;
      end;
      if CBAmount2.ItemIndex < 0 then begin
         ShowError('No Credit column selected',TSAmount,CBAmount2);
         Exit;
      end;
   end else if rbSign.Checked then begin
      if CBAmount.ItemIndex < 0 then begin
         ShowError('No Amount column selected',TSAmount,CBAmount);
         Exit;
      end;
      if CBAmount2.ItemIndex < 0 then begin
         ShowError('No Sign column selected',TSAmount,CBAmount2);
         Exit;
      end;
   end;

  FailCount := 0; //Used as temp Counts..
  GoodCount := 0;
  for R := 0 to fOutlist.Count - 1 do begin
     tI := Integer(TOutItem(fOutlist[R]).objects[0]); //Date..
     if (ti >= FValidDateRange.FromDate)
     and (ti <= FValidDateRange.ToDate) then
        Inc(GoodCount) // Will import
     else
        Inc(FailCount) // Wont Import

  end;

  if GoodCount = 0 then begin
     HelpfulErrorMsg('No dates found, before the first delivered transaction',0);
     Exit;
  end;

   // Optional
   if cbRef.ItemIndex < 1 then // First is blank
      if AskSelection('No Reference Column selected','Are you sure you do not want a Reference Column?', TSReference,cbRef) then
         Exit;

   if tsAnalysis.TabVisible then
     if cbAna.ItemIndex < 1 then
        if AskSelection('No Analysis Column selected','Are you sure you do not want a Analysis Column?', tsAnalysis,cbAna) then
           Exit;

   if (cbNar1.ItemIndex < 1)
   and (cbNar2.ItemIndex < 1)
   and (cbNar3.ItemIndex < 1)then
      if AskSelection('No Narration Column selected','Are you sure you do not want a Narration Column?', TSNarration,cbNar1) then
         Exit;

   if FailCount > 0 then
      if AskSelection('Transactions will be skipped',
         Format ('%D Transactions will be skipped, do you want to contiue?',[FailCount]) , TsDate,cbDate) then
            Exit;

   // We Shoul be good to go...
  


    for R := 0 to fOutlist.Count - 1 do begin
      if (Integer(TOutItem(fOutlist[R]).objects[0]) >= FValidDateRange.FromDate)
     and (Integer(TOutItem(fOutlist[R]).objects[0]) <= FValidDateRange.ToDate) then begin

        pT := BankAccount.baTransaction_List.New_Transaction;
        //Set Some defaults
        ClearSuperFundFields(Pt);
        pT^.txSource := orHistorical;
        PT^.txHas_Been_Edited := true;
        pT^.txBank_Seq := BankAccount.baFields.baNumber;
        //date
        pT^.txDate_Effective := Integer(Integer(TOutItem(fOutlist[R]).objects[0]));
        pT^.txDate_Presented := pT^.txDate_Effective;

        if BankAccount.IsAForexAccount then
        Begin
          pT.txForeign_Currency_Amount := TOutItem(fOutlist[R]).OutMoney;
          pT.txForex_Conversion_Rate := BankAccount.Default_Forex_Conversion_Rate( pT.txDate_Effective );
          If pT.txForex_Conversion_Rate <> 0.0 then
            pT.txAmount := Round( pT.txForeign_Currency_Amount / pT.txForex_Conversion_Rate )
          else
            pT.txAmount := 0;
        End
        else
        //Amount
          pt^.txAmount := TOutItem(fOutlist[R]).OutMoney;

        pT^.txType := FHDEForm.GetComboIndexForEntryType(GetEntryType(pT^.txAmount));

        pt^.txReference := TOutItem(fOutlist[R]).Strings[SubRef];


        if fSubAna >= 0 then
           pt^.txAnalysis := TOutItem(fOutlist[R]).Strings[fSubAna];

        pt^.txGL_Narration := TOutItem(fOutlist[R]).Strings[fSubnar];

        HistTranList.Insert(pT);
        FHDEForm.AmountEdited(pT,False);
        FHDEForm.UpdateChequeNo(pT);
        incUsage('Historic Transactions CSV');
      end;
    end;


    ModalResult := mrOK;
end;

procedure TImportHist.cbAmountChange(Sender: TObject);
var R, C, C2: integer;
    lm: Currency;

    procedure SetAmount(Value: Money);
    begin
       if cbSign.Checked then
          Value := - Value;

       with TOutItem(fOutlist.Items[R]) do begin
          OutMoney := Value;
          Strings[SubAmount] := Money2Str(Value);
       end;
    end;

    function IsDebit: boolean;
    var s: string;
    begin
      s := GetFileText(R,C2);
      if S > '' then
         Result := Upcase(S[1])= 'D'
      else
         Result := False;
    end;
begin
   BeginUpdate;
   vsOut.BeginUpdate;
   try
      // Update date column
      C := GetComboCurrentIntObject(cbAmount);
      if C >= 0 then begin

          if rbSingle.Checked then begin
              for R := 0 to fOutlist.Count - 1 do
                 SetAmount(StrtoCurr(GetFileText(R,C))*100 );
              Exit;
          end else if rbDebitCredit.Checked then begin
              C2 := GetComboCurrentIntObject(cbAmount2);
              if C2 >= 0 then begin
                 for R := 0 to fOutlist.Count - 1 do begin
                    lm := StrtoCurr(GetFileText(R,C2))*100;
                    SetAmount (lm-  StrtoCurr(GetFileText(R,C))*100);
                 end;
                 Exit;
              end;
          end else if RbSign.Checked then begin
              C2 := GetComboCurrentIntObject(cbAmount2);
              if C2 >= 0 then begin
                 for R := 0 to fOutlist.Count - 1 do begin
                    lm := StrtoCurr(GetFileText(R,C))*100;
                    if IsDebit then
                       lm := - lm;
                    SetAmount(lm);
                 end;
                 Exit;
              end;
          end
      end;

      // Still here, must have failed
      for R := 0 to fOutList.Count - 1 do
         with TOutItem(fOutlist.Items[R]) do begin
            OutMoney := 0;
            Strings[SubAmount] := '-';
         end;

   finally
      OutColResize(1);
      FileLVChanged := True;
      OutLVChanged := True;
      vsOut.EndUpdate;
      EndUpdate;
   end;
end;

procedure TImportHist.cbAnaChange(Sender: TObject);
var CAna, R: Integer;
begin
   if fSubAna < 0 then // savety net..
      Exit;
   BeginUpdate;
   try
      CAna  := GetComboCurrentIntObject(cbAna);
      if CAna >= 0 then begin
         for R := 0 to fOutList.Count - 1 do
            TOutItem(fOutlist.Items[R]).strings[fSubAna] := GetFiletext(R,CAna, 12);
      end else begin
         for R := 0 to fOutList.Count - 1 do
            TOutItem(fOutlist.Items[R]).strings[fSubAna]  := '';
      end;
      OutColResize(fSubAna+1);
      FileLVChanged := True;
      OutLVChanged := True;
   finally
      EndUpdate;
   end;
end;


procedure TImportHist.cbDateChange(Sender: TObject);
var R, C : integer;
    Format: string;

    function GetDateText: string;
    var D: Integer;
    begin
       try
          D := StrtoDate(GetFileText(R,C),Format);
          TOutItem(foutList[R]).Objects[0]  := TObject(D);
          if D = 0 then
             Result := '**/**/**' //so You can see it..
          else
             Result := bkDate2Str(D);
       except
          Result := '**/**/**' ;
       end;
    end;

begin
   BeginUpdate;
   try
      // Update date column
      C := GetComboCurrentIntObject(cbDate);
      if C >= 0 then begin
         Format := EDate.Text;
          for R := 0 to fOutList.Count - 1 do begin
             TOutItem(foutList[R]).Strings[SubDate] := GetDateText;
          end;
      end else
         for R := 0 to fOutList.Count - 1 do
             TOutItem(foutList[R]).Strings[SubDate] := '-';
      // Resize..
      OutColResize(0);
      FileLVChanged := True;
      OutLVChanged := True;
   finally
      EndUpdate;
   end;
end;

procedure TImportHist.cbDelimiterChange(Sender: TObject);
begin
  if EPath.Text > '' then
     ReloadFile;
end;

procedure TImportHist.cbNar1Change(Sender: TObject);
var CNar1,CNar2,CNar3, R : Integer;

    function GetNarration: string;
      procedure AddText(Value: string);
      begin
         if Value > '' then begin
           if Result > '' then
              Result := Result + ' ';
           Result := Result + Value;
         end;
      end;
    begin
       Result := '';
       if CNar1 >= 0 then
          AddText( Trim(GetFiletext(R,CNar1)));
       if CNar2 >= 0 then
          AddText( Trim(GetFiletext(R,CNar2)));
       if CNar3 >= 0 then
          AddText( Trim(GetFiletext(R,CNar3)));
    end;
begin
   BeginUpdate;
   try
      CNar1 := GetComboCurrentIntObject(cbNar1);
      CNar2 := GetComboCurrentIntObject(cbNar2);
      CNar3 := GetComboCurrentIntObject(cbNar3);
      for R := 0 to fOutList.Count - 1 do begin
          TOutItem(foutList[R]).Strings[FSubNar] := GetNarration;
      end;
      OutColResize(fSubNar+1);
      FileLVChanged := True;
      OutLVChanged := True;
   finally
      EndUpdate;
   end;
end;

procedure TImportHist.cbRefChange(Sender: TObject);
var CRef, R: Integer;
begin
   BeginUpdate;
   try
      CRef := GetComboCurrentIntObject(cbRef);
      if CRef >= 0 then begin
         for R := 0 to fOutList.Count - 1 do
           TOutItem(foutList[R]).Strings[SubRef] := GetFiletext(R,CRef,12);
      end else begin
         for R := 0 to fOutList.Count - 1 do
           TOutItem(foutList[R]).Strings[SubRef] := '';
      end;
      OutColResize(SubRef+1);
      FileLVChanged := True;
      OutLVChanged := True;
   finally
      EndUpdate;
   end;
end;

procedure TImportHist.chFirstlineClick(Sender: TObject);
begin
   if BkFileexists(ePath.Text) then
      ReLoadFile;
end;


function TImportHist.ColumnColor(const Value: Integer): tColor;
begin
   if SelectedCol[Value] then
      Result := clHighLight
   else
      Result := clWhite;
end;



function TImportHist.CurrentDate: Integer;
begin
   if fCurrentDate = 0 then  // so wo only do this once
     fCurrentDate := stdate.CurrentDate;
   Result := fCurrentDate;
end;

procedure TImportHist.Endupdate;
begin
   if FLockCount > 0 then begin
      Dec(FlockCount);
      if FLockCount = 0 then begin
         Screen.Cursor := FKeepCursor;
         if fFileLvChanged then begin
            fFileLvChanged := False;
            vsFile.Invalidate;
         end;
         if fOutLvChanged then begin
            fOutLvChanged := False;
            vsOut.Invalidate;
         end;
      end;
   end;
end;

procedure TImportHist.FormCreate(Sender: TObject);

   function AddColumn(Name: string; aTag: Integer):TVirtualTreeColumn;
    begin
       Result := vsOut.Header.Columns.Add;
       with Result do begin
          Text := Name;
          Width := 100;
          Minwidth := 100;
          Tag := aTag;
       end;
    end;

begin
   bkXPThemes.ThemeForm( Self);
   vsOut.Header.Font := Self.Font;
   vsFile.Header.Font := Self.Font;
   Tmaskedit(SkipLine).MaxLength := 2;
   fFileList := TobjectList.Create(True);
   fOutList := TobjectList.Create(True);
   FReloading := False;
   pcFormat.ActivePageIndex := 0;//Not the design time one..

   case MyClient.clFields.clCountry of
     whNewZealand:;
     whAustralia, whUK: tsAnalysis.TabVisible := False;
   end;
   lbFile.Height := 0;

   vsout.BeginUpdate;
   try
      vsout.Header.Columns.Clear;
      AddColumn('Date',piDate);
      AddColumn('Amount',PiAmount).Alignment := taRightJustify;
      AddColumn('Reference',piReference);
      if tsAnalysis.TabVisible then begin
         AddColumn('Analysis',PiAnalysis);
         FSubAna := 3;
         FSubNar := 4;
      end else begin
         FSubAna := -1;
         FSubNar := 3;
      end;

      AddColumn('Narration',PiNarration);

   finally
      vsout.EndUpdate;
   end;
   vsFile.SyncView := vsOut;
   vsOut.SyncView := vsFile;
   PCFormatChange(nil);
end;


procedure TImportHist.FormDestroy(Sender: TObject);
begin
   fFileList.Free;
   fOutList.Free;
end;

procedure TImportHist.FormResize(Sender: TObject);
var H: integer;
begin
   H := ClientHeight - (pFileinput.Height + PFormat.Height + pBtn.Height);
   pFile.Height := H div 2;
   
   // pFile is align client, so it will take up the rest
end;

function TImportHist.GetEntryType(Amount: Money): Byte;
begin
  case MyClient.clFields.clCountry of
    whNewZealand:
      begin
        if Amount >= 0 then
          Result := etWithdrawlNZ
        else
          Result := etDepositNZ;
      end;
    whAustralia:
      begin
        if Amount >= 0 then
          Result := etWithdrawlOZ
        else
          Result := etDepositOZ;
      end;
    whUK:
      begin
        if Amount >= 0 then
          Result := etWithdrawlUK
        else
          Result := etDepositUK;
      end
    else
      raise Exception.Create('Need to define GetEntryType for other countries');
  end;
end;

function TImportHist.GetFileText(const Row,Col: Integer; MaxLen: Integer = 0): string;
begin
   Result := '';
   if Row >= fFilelist.Count then
      Exit;
   with TFileItem(fFilelist[Row]) do begin
     if Col >= Count then
         Exit;
      Result := trim(Strings[Col]);
      if MaxLen > 0 then
         if Length(Result) > MaxLen then
           SetLength(Result,MaxLen)
   end;
end;

function TImportHist.GetSelectedcol(index: Integer): Boolean;
var C: Integer;
begin
   Result := True;
   for C := Low(FColumnControls) to High(FColumnControls) do
     if FColumnControls[C] is TComboBox then with TComboBox(FColumnControls[C] ) do
         if ItemIndex >=0 then
            if Integer(Items.Objects[ItemIndex]) = index then
               Exit;
   // Still here...
   Result := False;
end;


function TImportHist.IsAlphaOnly(const Value: string): boolean;
var I: integer;
begin
   Result := False;
   for I := 1 to Length(Value) do
      if Value[I] in ['0'..'9'] then
         Exit;
   Result := True;
end;

function TImportHist.IsNumericOnly(const Value: string): Boolean;
var I: integer;
begin
   Result := False;
   for I := 1 to Length(Value) do
      if Upcase(Value[I]) in ['A', 'B', {C,D} 'E' .. 'Q', {R} 'S'..'Z'] then  {DR, CR}
         Exit;
   Result := True;
end;

function TImportHist.IsAlphaOnly(const Value: Integer): boolean;
var I: Integer;
begin
   Result := False;
   for I := 0 to fFileList.Count-1 do
      if not IsAlphaOnly(GetFileText(I,Value)) then
         Exit;
   Result := true;
end;


function TImportHist.IsAmount(const Value: Integer): AmountType;
var I: Integer;
begin
   Result := Amount;
   for I := 0 to fFileList.Count-1 do
      case IsAmount(GetFileText(I,Value)) of
      NotAmount : begin
         Result :=  NotAmount;
         Exit;
      end;
      AmountWithSign : Result := AmountWithSign;
      Amount:;
      end;
end;

function TImportHist.IsAmount(const Value: string): AmountType;
begin
   try
      if StrToCurr(Value) < 0 then
         Result := AmountWithSign
      else
         Result := Amount
   except
       Result := NotAmount;
   end;
end;

function TImportHist.IsDebitCredit(const Value: string): Boolean;
var l: integer;
    V: PChar;
begin
   l := Length(Value);
   if l > 0 then begin

      Result := True;
      V := pchar(Value);

      if StrliComp(V,'debit',l) = 0 then
         Exit;
      if StrliComp(V,'credit',l) = 0 then
         Exit;
      if StrliComp(V,'m',l) = 0 then
         Exit;
   end;

   Result := False;
end;



function TImportHist.IsDate(const Value, Mask: string): Boolean;
var D: Integer;
begin
   D := StrtoDate(Value,Mask);
   Result := (D < CurrentDate)
          and (D > Date1980);

end;

function TImportHist.IsDate(const Value: Integer): string;
var I: Integer;
    ResMask,
    S: string;
    monthNotSwapped: Boolean;

   procedure BuildMask;
   var D: Integer;
       S: string;

       Mdone,Ddone,Ydone: Boolean;

       function FailNumber: Boolean;
       begin
          Result := true;

          if D = 0 then begin
             if ReadMonth(S) in [1..12] then begin
                if Mdone then begin
                   DDone := True;
                   ResMask := SwapMonth(ResMask);
                end;
                MDone := True;
                ResMask := ResMask + 'MMM'
             end else
                Exit;
          end else
          if D > 2100 then
             Exit // ??
          else if D > 1000 then begin
             if YDone then
                Exit;
             ResMask := ResMask + 'YYYY';
             YDone := true;
          end else if D > 31 then begin
             if MDone
             and DDone then begin
                ResMask := ResMask + 'YY';
                YDone := True;
             end;
          end else if D > 12 then begin
             if DDone then begin
                if Mdone  then begin
                   ResMask := ResMask + 'YY';
                   YDone := True;
                end else begin
                   ResMask := SwapMonth(ResMask);
                   ResMask := ResMask + 'DD';
                   MDone := True;
                end;
             end else begin
                ResMask := ResMask + 'DD';
                DDone := True;
             end;
          end else begin
             if MDone then begin
                if DDone  then begin
                   ResMask := ResMask + 'YY';
                   YDone := True;
                end else begin
                   ResMask := SwapMonth(ResMask);
                   ResMask := ResMask + 'MM';
                   DDone := True;
                end;
             end else begin
                if DDone then begin
                   ResMask := ResMask + 'MM';
                   MDone := true;
                end else begin
                   ResMask := ResMask + 'DD';
                   DDone := True;
                end;
             end;
          end;
          Result := False;
       end;
   begin
      Mdone := False;
      Ddone := False;
      Ydone := False;
      S := GetFileText(0,Value);
      ResMask := '';
      // read the first number..
      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      ResMask := ResMask + Copy(S,1,1);
      // read the second number
      S := Copy(S,2,255);
      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      ResMask := ResMask + Copy(S,1,1);
      S := Copy(S,2,255);

      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      if not( Mdone and Ddone and Ydone) then
         ResMask := 'Fail';
      
      if Pos('@',ResMask) > 0 then
         ResMask := 'Fail';

      if Pos(':',ResMask) > 0 then
         ResMask := 'Fail';
   end;


begin
  result := '';
  if fFileList.Count < 0 then
     Exit;


  BuildMask;
  monthNotSwapped := True;
  for I := 0 to fFileList.Count -1 do begin
      S :=  GetFileText(I,Value);
      if Length(S) > 0 then begin
         if Length(ResMask) = 0  then
            BuildMask;

         if IsDate(S,ResMask) then
         else begin
            // Have to Check a couple things
            if monthNotSwapped then begin
               if IsDate(S,SwapMonth( ResMask)) then begin
                  ResMask := SwapMonth( ResMask);
                  MonthNotSwapped := false;
               end;
            end else
               Exit;
         end;
      end;
  end;
  Result := ResMask;
end;

function TImportHist.IsDebitCredit(const Value: Integer): Boolean;
var I: Integer;
begin
   Result := False;
   for I := 0 to fFileList.Count -1 do
      if not IsDebitCredit(GetFileText(I,Value)) then
           Exit;

   Result := true;
end;

function TImportHist.IsNumericOnly(const Value: Integer): Boolean;
var I: Integer;
begin
   Result := False;
    for I := 0 to fFileList.Count -1 do
      if not IsNumericOnly(GetFileText(I,Value)) then
         Exit;
   Result := true;
end;

function TImportHist.IsValidColumn(const Value: Integer): Boolean;
begin

   Result := True;

   case PcFormat.ActivePageIndex of
   piDate: if vsFile.header.Columns[Value].Tag <> TagDate then
         Result := false;
   piAmount: if RBSign.Checked then begin
                if not (vsFile.header.Columns[Value].Tag in [TagDebitCredit, TagAmount, TagAmountSign]) then
                   Result := false;
             end else if RBDebitCredit.Checked then begin
                if not (vsFile.header.Columns[Value].Tag in [TagAmount]) then
                   Result := false;
             end else
              if not (vsFile.header.Columns[Value].Tag in [TagAmount, TagAmountSign]) then
                  Result := false;

   end;
end;





procedure TImportHist.OutColResize(Value: Integer);
begin
  vsOut.Header.AutoFitColumns(False);
end;

procedure TImportHist.PCFormatChange(Sender: TObject);
var ll: ControlList;
begin
  BeginUpdate;
  try

     SetLength(ll,1);
     case PCFormat.ActivePageIndex of
     piDate : ll[0] := cbDate;

     piAmount : begin
           SetLength(ll,2);
           ll[0] := cbAmount; //Could exclude if RBSingle, but its empty anyway..
           ll[1] := cbAmount2;
        end;

     piReference : ll[0] := cbRef;
     piAnalysis : ll[0] := cbAna;

     piNarration :begin
        SetLength(ll,3);
        ll[0] := cbNar1;
        ll[1] := cbNar2;
        ll[2] := cbNar3;
      end;

     else SetLength(ll,0);
     end;
     ColumnControls := ll;
     OutLvChanged := True;
     FileLvChanged := True;
  finally
     EndUpdate;
  end;
end;

procedure TImportHist.rbSingleClick(Sender: TObject);
var I: Integer;
begin
   BeginUpdate;
   try
      lbAmount.Caption := 'Amount';
      lbAmount.Visible := True;
      cbAmount.Visible := True;
      cbAmount2.Visible := False;
      lbAmount2.Visible := False;
      cbAmount2.Clear;
      cbAmount.Clear;
      for I := 0 to vsFile.header.Columns.Count - 1 do
         if vsFile.header.Columns[I].Tag in [ TagAmount,TagAmountSign ] then
           cbAmount.Items.AddObject(vsFile.header.Columns[I].Text , TObject(I));

      SetDefault('amount',cbAmount);
   finally
     EndUpdate;
   end;
end;


procedure TImportHist.rbDebitCreditClick(Sender: TObject);
var I: Integer;
begin
   BeginUpdate;
   try
      lbAmount.Caption := 'Debit';
      lbAmount.Visible := True;
      cbAmount.Visible := True;
      cbAmount2.Visible := True;
      lbAmount2.Caption := 'Credit';
      lbAmount2.Visible := True;
      cbAmount.Clear;
      cbAmount2.Clear;
      for I := 0 to vsFile.header.Columns.Count - 1 do
         if vsFile.header.Columns[I].Tag in [ TagAmount ] then begin
            cbAmount.Items.AddObject (vsFile.header.Columns[I].Text, TObject(I));
            cbAmount2.Items.AddObject(vsFile.header.Columns[I].Text, TObject(I));
         end;

      SetDefault('debit',cbAmount,0);
      SetDefault('credit',cbAmount2,1);
   finally
      EndUpdate;
   end;
end;

procedure TImportHist.RBSignClick(Sender: TObject);
var I: Integer;
begin
   BeginUpdate;
   try
      lbAmount.Caption := 'Amount';
      lbAmount.Visible := True;
      cbAmount.Visible := True;
      cbAmount2.Visible := True;
      lbAmount2.Caption := 'Sign';
      lbAmount2.Visible := True;
      cbAmount.Clear;
      cbAmount2.Clear;

      for I := 0 to vsFile.header.Columns.Count - 1 do
         if vsFile.header.Columns[I].Tag in [ TagAmount ] then
           cbAmount.Items.AddObject(vsFile.header.Columns[I].Text, TObject(I))
         else if vsFile.header.Columns[I].Tag in [ TagDebitCredit ] then
           cbAmount2.Items.AddObject(vsFile.header.Columns[I].Text, TObject(I));

       SetDefault('amount',cbAmount);
       SetDefault('',cbAmount2);
   finally
      EndUpdate;
   end;
end;



function TImportHist.ReadMonth(var NumText: string): Integer;
var I: Integer;
    Month: string;
begin
   Result := 0;
   try
      for I := 1 to Length(NumText) do
         if NumText[I] in ['a' .. 'z', 'A' .. 'Z'] then
            // Find all the Text
            Month := Month + NumText[I]
         else begin
            // Remove any Text we found
            NumText := Copy(NumText,I,255);
            Break;
         end;

      if Length(Month) >= 3 then
         // Find the Month text
         for I := 1 to 12 do
            if SameText(Copy(Month,1,3), ShortMonthNames[I]) then begin
               Result := I;
               Break;
            end;

   except
      Result := 0; //
   end;
end;

function TImportHist.ReadNum(var NumText: string): Integer;
var I: Integer;
begin
   Result := 0;
   try
      // May need to update to handle leading <space>
      for I := 1 to Length(NumText) do
         if NumText[I] in ['0' .. '9'] then
            // Find the starting Number
            Result := (Result * 10) + (Byte(NumText[I]) - Byte('0'))
         else begin
            // remove the starting number
            NumText := Copy(NumText,I,255);
            Break;
         end;
   except
      Result := 0; // overflow...
   end;
end;

procedure TImportHist.ReloadFile;
var lFile: TStringList;
    lLine: TStringList;
    InItem: TFileItem;
    OutItem: TOutitem;
    R,C: Integer;
    TestBool: Boolean;
    AmountColumnCount: Integer;

    procedure TryDate(Column: Integer);
    var DateMask: string;
    begin
       DateMask := ISdate(Column);
       if Pos('M',DateMask) > 0  then begin
          vsFile.header.Columns[Column].Tag := TagDate;
          cbDate.Items.AddObject( vsFile.header.Columns[Column].Text, TObject(Column));
          EDate.Text := DateMask;
       end;
    end;

    function NextLine(Keep: Boolean = False): Boolean;
    begin
       Result := False;
       while R < Pred(LFile.Count) do begin
          Inc(R);
          lLine.DelimitedText := LFile[R];
          if Keep then begin
             // Show the skipped lines
             if lbFile.Caption > '' then
                lbFile.Caption := LbFile.Caption + #13 + LFile[R]
             else
               lbFile.Caption := LFile[R];
          end;

          if lLine.Count > 1 then begin
             Result := True;
             Break;
          end;
       end;
    end;

    function AddColumn(Name: string; aTag: Integer):TVirtualTreeColumn;
    begin
       Result := vsfile.Header.Columns.Add;
       with Result do begin
          Text := Name;
          Width := 100;
          Minwidth := 50;
          Tag := aTag;
       end;
    end;

begin
   if FReloading then
      Exit;

   Freloading := True;
   BeginUpdate;
   vsFile.BeginUpdate;
   vsOut.BeginUpdate;
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
       // reset the dialog
       GetLocaleFormatSettings(0,FFormatsettings);
       vsFile.Clear;
       vsFile.Header.Columns.Clear;
       lbFile.Caption := '';
       lbFile.Height := 0;

       vsOut.Clear;

       cbDate.Clear;
       cbAna.Clear;
       cbRef.Clear;
       cbNar1.Clear;
       cbNar2.Clear;
       cbNar3.Clear;
       cbAmount.Clear;
       cbAmount2.Clear;

       fFileList.Clear;
       fOutlist.Clear;

       rbSingle.Enabled := False;
       RBSign.Enabled := False;
       RBDebitCredit.Enabled := False;

       rbSingle.Checked:= False;
       RBSign.Checked := False;
       RBDebitCredit.Checked := False;

       // Read the File into the grid.
       case cbDelimiter.ItemIndex of
       1 :   lline.Delimiter := ';';
       2 :   lline.Delimiter := #9;
       else  lline.Delimiter := ',';
       end;

       lLine.StrictDelimiter := True;
       try
          lFile.LoadFromFile(EPath.Text);
       except
          on e: exception do begin
             HelpfulErrorMsg(Format( 'Cannot open file %s: %s',[EPath.Text, e.Message]),0);
          end;
       end;
       if LFile.Count = 0 then
           Exit;
       // First Row;
       R := -1;
       for C := 1 to SkipLine.IntValue do begin
          if not NextLine(true) then
             Exit;
       end;

       if not NextLine then
          Exit; // Nothing found..

       TestBool := True;
       for C := 0 to lLine.Count - 1 do begin
          {if not (LLine[C] > ' ') then begin
             TestBool := False;
             Break;
          end else }
          if not IsAlphaOnly(LLine[C]) then
          if IsNumericOnly(LLine[C]) then begin
             TestBool := False;
             Break;
          end;
       end;
       if TestBool then begin
          // All Text, Must be header (No valid amount Or Date)
          CHFirstLine.Checked := True;
          CHFirstLine.Enabled := False;
       end else
          CHFirstLine.Enabled := True;

       // Fill in the First line

       cbAna.Items.AddObject(tNone, TObject(-1));
       cbRef.Items.AddObject(tNone, TObject(-1));
       cbNar1.Items.AddObject(tNone, TObject(-1));
       cbNar2.Items.AddObject(tNone, TObject(-1));
       cbNar3.Items.AddObject(tNone, TObject(-1));

       for C := 0 to lLine.Count - 1 do with AddColumn('',0) do begin
          if CHFirstLine.Checked
          and (lLine[C] > ' ') then
             Text := lLine[C]
          else
             Text := Format('Column %d',[C + 1]);

          // While we are here..
          cbAna.Items.AddObject(Text, TObject(C));
          cbRef.Items.AddObject(Text, TObject(C));
          cbNar1.Items.AddObject(Text, TObject(C));
          cbNar2.Items.AddObject(Text, TObject(C));
          cbNar3.Items.AddObject(Text, TObject(C));
       end;
       
       if CHFirstLine.Checked then
          if not NextLine then  //Get The first 'Real' Line
            Exit;
       // read the rest of the file...
       repeat
          InItem := TFileitem.Create;
          InItem.Assign(LLine);
          fFilelist.Add(InItem);
          InItem.ListNode := vsFile.AddChild(nil,nil);

          OutItem := TOutItem.Create;
          OutItem.OutMoney := 0;
          for C := 0 to vsOut.Header.Columns.Count - 1 do
             OutItem.Add('');
          fOutlist.Add(OutItem);
          outItem.ListNode := vsOut.AddChild(nil,nil);
       until not NextLine;

       vsFile.Header.AutoFitColumns(False);

       AmountColumnCount := 0;
       for C := 0 to vsFile.Header.Columns.Count - 1 do begin
          if IsAlphaOnly(C) then begin
             // has no digits.. cannot be a Date or amount
             // Could still be Debit or Credit Column
             if IsDebitCredit(C) then begin
                vsFile.Header.Columns[C].Tag := TagDebitCredit;
                RBSign.Enabled := True;
             end else
                vsFile.Header.Columns[C].Tag := TagAlpha;
          end else if IsNumericOnly(C) then begin
             // Has No Letters
             case IsAmount(C) of
             NotAmount : TryDate(C);
             Amount : begin
                   vsFile.Header.Columns[C].Tag := TagAmount;
                   rbSingle.Enabled := True;
                   inc(AmountColumnCount);
                   if AmountColumnCount >= 2 then
                      rbDebitCredit.Enabled := True;

                end;
             AmountWithSign :begin
                vsFile.Header.Columns[C].Tag := TagAmountSign;
                rbSingle.Enabled := True;
             end;
             end;
          end else begin
             // Can have Numbers and Letters
             // Could Be a Date...
             TryDate(C);
          end;

       end;

       // Do some obvious defaults.
       SetDefault('date',cbDate);

       if RBSign.Enabled then
          RBSign.Checked := true
       else if RBdebitCredit.Enabled then
          RBdebitCredit.Checked := true
       else if RBSingle.Enabled then
          RBSingle.Checked := true

   finally
      vsFile.EndUpdate;
      vsOut.EndUpdate;
      lFile.Free;
      lLine.Free;
      EndUpdate;
      Freloading := False;
   end;
end;


procedure TImportHist.ReloadTimerTimer(Sender: TObject);
begin
   ReloadTimer.Enabled := False;
   SkipLine.ValidateEdit;
   if ePath.Text > '' then
      ReloadFile;
end;

procedure TImportHist.SkipLineChange(Sender: TObject);
begin
   ReloadTimer.Enabled := False;
   ReloadTimer.Enabled := True;
end;

procedure TImportHist.SetSelectedCol(Index: Integer; const Value: Boolean);


   procedure SelectObject(Value: integer; InCombo:TComboBox);
   var I: Integer;
   begin
     I := InCombo.Items.IndexOfObject(TObject(Value));
     if I >=0 then begin
        InCombo.ItemIndex := I;
        InCombo.OnChange(InCombo);
     end;
   end;

begin

   case pcFormat.ActivePageIndex of
   piDate : SelectObject(Index, cbDate);
   piAmount : begin
           if rbSingle.Checked then begin
              SelectObject(Index, cbAmount);
           end else if rbDebitCredit.Checked then begin
               if SelectedCol[Index] then begin
                  // Turn it off
                  if GetComboCurrentIntObject(cbAmount) = Index then begin
                     cbAmount.ItemIndex := -1;
                     cbAmount.OnChange(nil);
                  end;
                  if GetComboCurrentIntObject(cbAmount2) = Index then begin
                     cbAmount2.ItemIndex := -1;
                     cbAmount2.OnChange(nil);
                  end;
               end else begin
                  // turn it on.
                  if cbAmount.ItemIndex < 0 then
                    SelectObject(Index,cbAmount)
                  else if cbAmount2.ItemIndex < 0 then
                    SelectObject(Index,cbAmount2)
               end;
           end else if rbSign.Checked then begin
               if vsFile.Header.Columns[Index].Tag = TagDebitCredit then
                  SelectObject(Index, cbAmount2)
               else begin
                  SelectObject(Index, cbAmount)
               end;   

           end;;
       end;
   piReference : if SelectedCol[Index] then begin
                   cbRef.ItemIndex := -1;
                   cbRef.OnChange(nil); // Dont ask...
                 end else
                   SelectObject(Index, cbRef);
   piAnalysis  :if SelectedCol[Index] then begin
                   cbAna.ItemIndex := -1;
                   cbAna.OnChange(nil);
                end else
                   SelectObject(Index, cbAna);

   piNarration : begin
             if SelectedCol[Index] then begin
                 // turn it off
                 if GetComboCurrentIntObject(cbNar1) = Index then
                    cbNar1.ItemIndex := -1;
                 if GetComboCurrentIntObject(cbNar2) = Index then
                    cbNar2.ItemIndex := -1;
                 if GetComboCurrentIntObject(cbNar3) = Index then
                    cbNar3.ItemIndex := -1;
                  cbNar1.OnChange(nil);
             end else begin
                 // Turn it on..
                 if cbNar1.ItemIndex < 0 then
                    SelectObject(Index,cbNar1)
                 else if cbNar2.ItemIndex < 0 then
                    SelectObject(Index,cbNar2)
                 else if cbNar3.ItemIndex < 0 then
                    SelectObject(Index,cbNar3)
                 
             end;
        end;
   end;
end;

procedure TImportHist.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Importing_historical_data;
end;

function TImportHist.StrToCurr(Value: string): Currency;
var I: Integer;
    S: string;
    IsNeg : Boolean;
begin
   Result := 0;
   if Value > '' then begin
      IsNeg := False;
      S := '';

      for I := 1 to Length(Value) do
         case Value[I] of
         '0'..'9',
         '.', '-' : S := S +  Value[I]; // Keep these

         '(' : IsNeg := True; // Braketed

         'd','D' : Isneg := True; //DR
         #0 .. ' ':;    //Trim
         #128 .. #255:; //Trim (Notably #160, fixed space) also includes  '£'
         'c','C','r','R', // DR, CR
         '$', ',', '+', ')':; // These are fine too...

         else raise Exception.Create(format( 'Illegal Char [%s]:%d',[Value[I],Integer(Value[I])]) );

         end;
      if S > '' then
         if S = '-' then
           Result := 0
         else
           Result := sysutils.StrToCurr(s);
      if IsNeg then
         Result := -Result;
   end;

end;

function TImportHist.StrtoDate(Value,Mask: string): Integer;
var p, I: Integer;

  M,D,Y : Integer;
  function NextMask: Char;
  begin
     Result := #0;
     while (P < Length(Mask)) do begin
        inc(p);
        if Result > '' then begin
           if Result <> Mask[p] then
              Exit;
        end else if Mask[p] in ['M','D','Y'] then
           Result := Mask[p];

     end;
  end;
begin
  P := 0;
  M := 0;
  D := 0;
  Y := 0;
  for I := 1 to 3 do

  case NextMask of
  'D' : begin
          D := ReadNum(Value);
          Value := Copy(Value,2,200);
        end;
  'M' : begin
          M := ReadNum(Value);
          if M = 0 then
             M := ReadMonth(Value);
           Value := Copy(Value,2,200);
        end;
  'Y' : begin
          Y := ReadNum(Value);
          Value := Copy(Value,2,200);
        end;
  end;

  Result := DMYtoStDate(D, M, Y, BKDATEEPOCH);
  if Result = BadDate then
     Result := 0;
end;

function TImportHist.SwapMonth(const Value: string): string;
var I: Integer;
begin
   SetLength(Result,Length(value));
   for I := 1 to Length(value) do
      case Value[I] of
      'M' : Result[I] := 'D';
      'D' : Result[I] := 'M';
      else Result[I] := Value[I];
      end;

end;


procedure TImportHist.vsFileBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
begin
   TargetCanvas.Brush.Color := ColumnColor(Column);
   TargetCanvas.FillRect(CellRect);
end;

procedure TImportHist.vsFileChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
   if Assigned(Node) then
      vsOut.Selected[TOutItem(fOutList[Node.Index]).ListNode] := true;
end;

procedure TImportHist.vsFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= fFilelist.Count then
      Exit;
   with TstringList( fFilelist[Node.Index]) do begin
      if Column >= Count then
         Exit;
      CellText := Strings[Column];
   end;
end;

procedure TImportHist.vsFileHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if IsValidColumn(Column) then begin
      SelectedCol [Column] := true;
      vsFile.Invalidate;
   end;
end;

procedure TImportHist.vsFilePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
   if Assigned(Node) then begin
      if (vsSelected in Node.States) then
         if (Sender.Focused) then
            TargetCanvas.Font.Color := clHighlightText
         else
            TargetCanvas.Font.Color := clwindowText
      else
         if SelectedCol[Column] then
            TargetCanvas.Font.Color := clHighlightText
         else
            if isValidColumn(Column) then
               TargetCanvas.Font.Color := clwindowText
            else
               TargetCanvas.Font.Color := clGrayText;
   end;

end;

procedure TImportHist.vsOutChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
   if Assigned(Node) then
      vsFile.Selected[TFileItem(fFileList[Node.Index]).ListNode] := true;
end;

procedure TImportHist.vsOutGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= fOutlist.Count then
      Exit;
   with TOutItem( fOutlist[Node.Index]) do begin
      if Column >= Count then
         Exit;
      CellText := Strings[Column];
   end;
end;

procedure TImportHist.vsOutHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PCFormat.ActivePageIndex :=  vsOut.header.Columns[Column].Tag;
  PCFormat.OnChange(nil);
end;

procedure TImportHist.vsOutBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
  procedure SetHighLight(Value: Boolean);
  begin
     if value then begin
        TargetCanvas.Brush.Color := clHighLight;
        TargetCanvas.FillRect(CellRect);
     end;
  end;
begin
   case PCFormat.ActivePageIndex of
     piDate:      SetHighLight(Column = Subdate);

     piAmount:    SetHighLight(Column = SubAmount);

     piReference: SetHighLight(Column = SubRef);

     piAnalysis:  SetHighLight(Column = fSubAna);

     piNarration: SetHighLight(Column = fSubNar);

     else SetHighLight(False);
  end;
end;


procedure TImportHist.vsOutPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);

  procedure SetHighLight(Value: Boolean);
  begin
     if (vsSelected in Node.States) then
        if Sender.Focused then
           TargetCanvas.Font.Color := clHighlightText
        else
           TargetCanvas.Font.Color := clWindowText
     else
        if Value then
           TargetCanvas.Font.Color := clHighlightText
        else
           TargetCanvas.Font.Color := clWindowText;
  end;
 
begin
  if not Assigned(Node) then
     Exit;
  if (Column = SubDate) then begin
     if (Integer(TOutItem(FOutList[Node.Index]).Objects[0]) > FValidDateRange.ToDate )
     or (Integer(TOutItem(FOutList[Node.Index]).Objects[0]) < FValidDateRange.FromDate ) then
        TargetCanvas.Font.Color := clRed
     else
        SetHighLight(PCFormat.ActivePageIndex = piDate);

  end else

  case PCFormat.ActivePageIndex of
     piDate: ; // Already handeled
     piAmount:    SetHighLight(Column = SubAmount);

     piReference: SetHighLight(Column = SubRef);

     piAnalysis:  SetHighLight(Column = fSubAna);

     piNarration: SetHighLight(Column = fSubNar);

     else SetHighLight(False);
  end;
end;



procedure TImportHist.SetBankAccount(const Value: TBank_Account);
var lMaxHistDate: Integer;
begin
  FBankAccount := Value;
  if FBankAccount = nil then
     Exit; // ??

  Caption := Format('Import Historical Transactions into Bank Account: %s',[FBankAccount.Title]);
  lMaxHistDate := FBankAccount.MaxHistoricalDate;
  FValidDateRange := FBankAccount.Default_Forex_Concersion_DateRange;

  if lMaxHistDate > 0 then
     FValidDateRange.ToDate := min(lMaxHistDate,FValidDateRange.ToDate);

end;

procedure TImportHist.SetColumnControls(const value: ControlList);
begin
   FColumnControls := value;
end;



procedure TImportHist.SetDateMask(const Value: string);
begin
  FDateMask := Value;
  EDate.Text := Value;
end;

procedure TImportHist.SetDefault(Value: string; ComboBox: TComboBox; default: integer = 0);
var I: Integer;
begin
   if ComboBox.Items.Count > 0 then begin

      for I := 0 to ComboBox.Items.Count - 1 do begin
         if pos(Value, Lowercase(ComboBox.Items[I])) > 0 then begin
            ComboBox.ItemIndex := I;
            break;
         end;
      end;
      if ComboBox.ItemIndex < 0  then begin
         if Default >= 0 then
            ComboBox.Itemindex := default
         else    
      end;

   end;
   if Assigned(ComboBox.OnChange) then
      ComboBox.OnChange(nil)
end;

procedure TImportHist.SetFileLvChanged(const Value: Boolean);
begin
  if value <> FFileLvChanged then begin
     if Value then
        if fLockCount = 0 then begin
           vsFile.Invalidate;
           Exit;
        end;
     FFileLvChanged := Value;
  end;
end;


procedure TImportHist.SetHDEForm(const Value: TdlgHistorical);
begin
  FHDEForm := Value;
end;



procedure TImportHist.SetHistTranList(const Value: TUnsorted_Transaction_List);
begin
  FHistTranList := Value;
end;

procedure TImportHist.SetOutLvChanged(const Value: Boolean);
begin
  if value <> FOutLvChanged then begin
     if Value then
        if fLockCount = 0 then begin
           vsOut.Invalidate;
           Exit;
        end;
     FOutLvChanged := Value;
  end;
end;



end.
