unit ImportHist;
//------------------------------------------------------------------------------
{
   Title:          Import Historical Data Form

   Description:    Import UI for Importing Historical Data for a bank account from a CSV file

   Author:         Michelle Blyde 2008


}
//------------------------------------------------------------------------------

Not Used !!
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, baObj32, txul, HistoricalDlg;

type
  TfrmImportHist = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Filename: TLabel;
    edtFilename: TEdit;
    OpenDialog1: TOpenDialog;
    btnBrowse: TButton;
    btnView: TButton;
    lblAccountNo: TLabel;
    lblAccountName: TLabel;
    LblError: TLabel;
    ListBoxErrors: TListBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
  private
    FAccountNo: String;
    FHistTranList: TUnsorted_Transaction_List;
    FMaxHistTranDate: Integer;
    FHDEForm: TdlgHistorical;
    function ImportFile(const BankAccount: TBank_Account; HistTranList: TUnsorted_Transaction_List;
      ErrorList: TStringList): Boolean;
    function ValidFileName(): Boolean;
    function ValidHeader(aHeaderLine: String; var ErrorReason: String): Boolean;
    function ValidTransaction(aTransactionLine: TStringList; LineNo: Integer; var ErrorReason: string): Boolean;
    function LoadFile(HistoricalFileSL: TStringList):Boolean;
    function ValidateFile(HFileSL: TStringList; BankAccount: TBank_Account; ErrorList: TStringList): Boolean;
    function ProcessFile(HFileSL: TStringList; BankAccount: TBank_Account; HistTranList: TUnsorted_Transaction_List): Boolean;
    function ValidDate(aDate: Integer; var ErrorReason: string): Boolean;
    function GetEntryType(Amount: Comp): Byte;
  public
    function Import(HistTranList: TUnsorted_Transaction_List; AccountNo, AccountName: String;
      MaxHistTranDate: Integer; HDEForm: TdlgHistorical): boolean;
  end;


implementation
uses
//  {}ClientHomepageFrm,{}
  TransactionUtils,
  csvParser, globals, bkdefs, bktxio, bkDateUtils, bkConst, MoneyDef, GenUtils,
  trxList32, stDate, ErrorMoreFrm;

const
  ColDate = 0;
  ColRef = 1;
  ColAmount = 2;
  ColCode = 3;
  ColNarration = 4;
  ColQuantity = 5;
  ColEntryType = 6;
  ColAnalysis = 7;
  ColOther = 8;
  ColParticulars = 9; ColMax = 9;

  MaxQuanityAndAmount = 999999999.9999;

//Header line must contain the following columns in order!
const constHeader =
'DATE,REFERENCE,AMOUNT,CODE,NARRATION,QUANTITY,ENTRY TYPE,ANALYSIS,'+
'OTHER PARTY,PARTICULARS';

{$R *.dfm}


function TfrmImportHist.ValidFileName(): Boolean;
begin
  result := True;

  if Trim(edtFileName.Text)='' then
  begin
    HelpfulErrorMsg( 'The filename cannot be blank', 0);
    result := False;
    Exit;
  end;
  //see if file exists
  if not FileExists(edtFileName.Text) then
  begin
    HelpfulErrorMsg( 'The file ' + edtFileName.Text + ' cannot be found', 0);
    result := False;
  end;
end;

procedure TfrmImportHist.btnOKClick(Sender: TObject);
var
  ImportFileName: String;
  BankAccount : TBank_Account;
  ErrorList: TStringList;
begin
  if NOT(ValidFileName()) then
    Exit;
  ImportFileName := edtFilename.Text;

  BankAccount := MyClient.clBank_Account_List.FindCode(FAccountNo);
  if BankAccount<>nil then
  begin
    ErrorList := TStringList.Create;
    try
      if ImportFile(BankAccount, FHistTranList, ErrorList) then
      begin
        if MessageDlg( 'Import Completed for account ' + BankAccount.bafields.baBank_Account_Number + ' ' +
                      BankAccount.baFields.baBank_Account_Name + #13#13 +
                      'Do you want to import more files?',
                      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        begin
         ModalResult := mrOk;
        end
        else
        begin
          if ListBoxErrors.Visible then
          begin
            LblError.Visible := false;
            ListBoxErrors.Visible := false;
            ListBoxErrors.Anchors := ListBoxErrors.Anchors - [akBottom];
            self.Height := Constraints.MinHeight;
          end;
        end;
      end
      else
      begin
        if not ListBoxErrors.Visible then
        begin
          LblError.Visible := true;
          ListBoxErrors.Visible := true;
          self.Height := self.Height + ListBoxErrors.Height + 26;
          ListBoxErrors.Anchors := ListBoxErrors.Anchors + [akBottom];
        end;
        ListBoxErrors.Clear;
        ListBoxErrors.Items.AddStrings(ErrorList);
      end;
    finally
      ErrorList.Free;
    end;
  end
  else
    HelpfulErrorMsg('Bank Account '+FAccountNo +' Not Found', 0);
end;

procedure TfrmImportHist.btnViewClick(Sender: TObject);
begin
  if not ValidFileName then
    Exit;
  WinExec(pChar('notepad ' + edtFilename.Text) , SW_SHOW);
end;

function TfrmImportHist.LoadFile(HistoricalFileSL: TStringList):Boolean;
begin
  result := True;
  try
    HistoricalFileSL.LoadFromFile(edtFilename.Text);

    if (HistoricalFileSL.Text = '') or (HistoricalFileSL.Count=0) then
    begin
      HelpfulErrorMsg('File is Empty', 0);
      result := False;
    end;

  except
    on e : exception do
    begin
      HelpfulErrorMsg('Error Reading file ' + E.Message, 0);
      result := False;
    end;
  end;

end;

function TfrmImportHist.ValidHeader(aHeaderLine: String; var ErrorReason: String): Boolean;
begin
  Result := True;
  if aHeaderLine <> constHeader then
  begin
    ErrorReason := 'File Header is different from expected';
    Result := False;
  end;
end;

function TfrmImportHist.ValidDate( aDate : Integer; var ErrorReason: string ) : Boolean;
begin
   Result := False;
   if ( aDate <= 0 ) then begin
      // No date entered
      exit;
   end;
   if (FMaxHistTranDate <> 0) and ( aDate > FMaxHistTranDate ) then
   begin
      ErrorReason := 'Date is greater than ' + bkDate2Str(FMaxHistTranDate);
      exit;
   end;
   //check date is within banklink allowable range
   if ( aDate < MinValidDate) or ( aDate > MaxValidDate) then
   begin
     ErrorReason := 'Date is less than ' +bkDate2Str(MinValidDate) + ' or greater than ' + bkDate2Str(MaxValidDate);
     exit;
   end;
   Result := True;
end;

function TfrmImportHist.ValidTransaction(aTransactionLine: TStringList; LineNo: Integer; var ErrorReason: string): Boolean;
var
  FieldNo: Integer;
  FieldValue: String;
  OutDate: TDateTime;
  OutFloat: Double;
begin
  Result := True;
  if aTransactionLine.Count <> ColMax then
  begin
    ErrorReason := 'Incorrect number of fields.  Expected '
      +IntToStr(ColMax) +' found ' + IntToStr(aTransactionLine.Count);
    Result := False;
  end
  else
  begin
    for FieldNo := 0 to aTransactionLine.Count - 1 do
    begin
      FieldValue :=  aTransactionLine[FieldNo];
      case fieldNo of
        ColDate :
          begin
            if NOT(TryStrToDate(FieldValue,OutDate)) then
            begin
              ErrorReason := 'Invalid Date: '''+FieldValue + '''';
              Result := False;
            end
            else
            begin
              if not ValidDate(DateTimeToStDate(OutDate), ErrorReason) then
                Result := false;
            end;
          end;
        ColAmount:
          begin
            //strip comma, change (1,000) to -1000
            FieldValue := StringReplace(FieldValue, ',', '', [rfReplaceAll]);
            FieldValue := StringReplace(FieldValue, '(', '-', [rfReplaceAll]);
            FieldValue := StringReplace(FieldValue, ')', '', [rfReplaceAll]);
            if NOT(TryStrToFloat(FieldValue,OutFloat)) then
            begin
              ErrorReason := 'Invalid Amount: '''+FieldValue+'''';
              Result := False;
            end
            else if OutFloat > MaxQuanityAndAmount then
            begin
              ErrorReason := 'Amount is too large: ''' + FieldValue + '''';
              Result := False;
            end;
          end;
        ColQuantity :
          begin
            //strip comma, change (1,000) to -1000
            FieldValue := StringReplace(FieldValue, ',', '', [rfReplaceAll]);
            FieldValue := StringReplace(FieldValue, '(', '-', [rfReplaceAll]);
            FieldValue := StringReplace(FieldValue, ')', '', [rfReplaceAll]);
            if NOT(TryStrToFloat(FieldValue,OutFloat)) then
            begin
              ErrorReason := 'Invalid Quantity: '''+FieldValue+'''';
              Result := False;
            end
            else if OutFloat > MaxQuanityAndAmount then
            begin
              ErrorReason := 'Quantity is too large: ''' + FieldValue + '''';
              Result := False;
            end;
        end;
      end;
    end;
  end;
end;

function TfrmImportHist.ValidateFile(HFileSL: TStringList; BankAccount: TBank_Account; ErrorList: TStringList): Boolean;
var
  LineNo: Integer;
  oCSVParser : csvParser.TCsvParser;
  FileLine: TStringList;
  ErrorReason: string;
  TransactionFound: boolean;

  function FormatError(LineNo: Integer; ErrorMsg: string): string;
  begin
    Result := Format('Line %d: %s', [LineNo + 1, ErrorMsg]);
  end;
begin
  FileLine := TStringList.Create;
  oCSVParser := TCsvParser.Create;
  Result := True;
  TransactionFound := false;

  try
    for lineNo := 0 to HFileSL.Count - 1 do
    begin
      if Trim(HFileSL[lineNo]) = '' then Continue;
      //assumes that single commas dont exist in file
      ErrorReason := '';
      if lineNo = 0 then
      begin
        if not ValidHeader(HFileSL[lineNo], ErrorReason) then
        begin
          ErrorList.Add(FormatError(lineNo, ErrorReason));
          Result := false;
        end;
      end
      else
      begin
        oCSVParser.ExtractFields(HFileSL[LineNo], FileLine);
        TransactionFound := true;
        if NOT(ValidTransaction(FileLine,LineNo, ErrorReason)) then
        begin
          ErrorList.Add(FormatError(lineNo, ErrorReason));
          Result := false;
        end
      end;
    end;

    if not TransactionFound then
    begin
      ErrorList.Add('No transactions found.');
      Result := false;
    end;
  finally
    FileLine.Free;
    oCSVParser.Free;
  end;
end;

function TfrmImportHist.ProcessFile(HFileSL: TStringList; BankAccount: TBank_Account; HistTranList: TUnsorted_Transaction_List): Boolean;
var LineNo,FieldNo: Integer;
    pT: pTransaction_Rec;
    oCSVParser: csvParser.TCsvParser;
    FileLine: TStringList;
    s: string;
    sEntryType: string;
    p: integer;
begin
  Result := False;
  FileLine := TStringList.Create;
  oCSVParser := TCsvParser.Create;
  pT := nil;
  try
    //process each line (skip the first heading line)
    if HFileSL.Count < 2 then
      Exit;
    for LineNo := 1 to HFileSL.Count - 1 do
    begin
      try
        pT := nil;

        if Trim( HFileSL[lineNo]) = '' then
          Continue;

        //split line into fields
        oCSVParser.ExtractFields(HFileSL[LineNo], FileLine);

        //cycle through fields, creating transactions
        pT := New_Transaction;
        //Set Some defaults
        ClearSuperFundFields(Pt);
        PT^.txSource := orHistorical;
        PT^.txHas_Been_Edited := true;
        for FieldNo := 0 to FileLine.Count - 1 do
        begin
          s := Trim(FileLine[fieldNo]);

          pT^.txBank_Seq := BankAccount.baFields.baNumber;

          case fieldNo of
            ColDate :
            begin
              //the date should be formated as dd/mm/yy, excel with change 01/04 to 1/04
              if pos( '/', s) = 2 then
                s := '0' + s;

              pT^.txDate_Effective :=  DateTimeToStDate(StrToDate(s));
              pT^.txDate_Presented := pT^.txDate_Effective;
            end;
            ColRef : pT^.txReference := trim(s);
            ColAmount :    begin
              //strip comma, change (1,000) to -1000
              s := StringReplace( s, ',', '', [rfReplaceAll]);
              s := StringReplace( s, '(', '-', [rfReplaceAll]);
              s := StringReplace( s, ')', '', [rfReplaceAll]);
              pT^.txAmount := StrToFloatDef( s, 0.00) * 100;
              pT^.txType := FHDEForm.GetComboIndexForEntryType(GetEntryType(pT^.txAmount)); 
            end;

            ColCode : begin
               pT^.txAccount := s;
               if pT^.tXAccount > '' then // So we 'keep' it
               begin
                  pT^.txCoded_By := cbManual;
                  pT^.txHas_Been_Edited := True
               end;
            end;
            ColNarration : pT^.txGL_Narration := s;
            ColQuantity :
            begin
              //strip comma, change (1,000) to -1000
              s := StringReplace( s, ',', '', [rfReplaceAll]);
              s := StringReplace( s, '(', '-', [rfReplaceAll]);
              s := StringReplace( s, ')', '', [rfReplaceAll]);
              pT^.txQuantity := ForceSignToMatchAmount( StrToFloatDef( s, 0.00) * 10000, pT^.txAmount);
            end;
            ColEntryType :
            begin
              p := pos( ':', s);
              if p > 0 then
                sEntryType := Copy( s, 1, p -1)
              else
                sEntryType := s;
              if sEntryType = '' then
                Continue; //if not entered, then don't override the default set when amount was set

              //need to convert actual entry type to the index for the combo box.
              //if will be converted back when the entries are posted (yes this is
              //a bit of a round about way of doing it, but the less changes the better).
              pT^.txType := FHDEForm.GetComboIndexForEntryType(StrToIntDef( sEntryType, 0));

              //set cheque no based on ref and entry type
              //construct the cheque number from the reference field
              case MyClient.clFields.clCountry of
                whAustralia : begin
                  if (pT^.txType = 1) then begin
                    S := Trim( FileLine[ ColRef]);
                    //cheque no is assumed to be last 6 digits
                    if Length( S) > MaxChequeLength then
                      S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                    pT^.txCheque_Number := Str2Long( S);
                  end;
                end;

                whNewZealand : begin
                  if (pT^.txType in [0,4..9]) then begin
                    S := Trim(FileLine[ ColRef]);
                    //cheque no is assumed to be last 6 digits
                    if Length( S) > MaxChequeLength then
                      S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                    pT^.txCheque_Number := Str2Long( S);
                  end;
                end;
              end;
            end;
            ColAnalysis : pT^.txAnalysis := s;

            ColOther : pT^.txOther_Party := s;

            ColParticulars : pT^.txParticulars := s;
          end;
        end;
        HistTranList.Insert(pT);
        //BankAccount.baTransaction_List.Insert_Transaction_Rec(pT);
      except
        on E : Exception do
        begin
          if Assigned( pT) then
            trxList32.Dispose_Transaction_Rec( pT);

          HelpfulErrorMsg('Error processing line ' + IntToStr(lineNo) + ' - ' + e.Message, 0);
          exit;
        end;

      end;
      result := true;
    end;
  finally
    oCSVParser.Free;
    FileLine.Free;
  end;
end;

function TfrmImportHist.GetEntryType(Amount: Comp): Byte;
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
    else
      raise Exception.Create('Need to define GetEntryType for other countries');
  end;
end;

function TfrmImportHist.Import(HistTranList: TUnsorted_Transaction_List; AccountNo, AccountName: String;
  MaxHistTranDate: Integer; HDEForm: TdlgHistorical): boolean;
begin
  FHistTranList := HistTranList;
  FHDEForm := HDEForm; //needed so that we can convert entry types to the index in the combo box
  LBLAccountNo.Caption := AccountNo;
  LBLAccountName.Caption := AccountName;
  FAccountNo := AccountNo;
  FMaxHistTranDate := MaxHistTranDate;
  self.Height := self.Constraints.MinHeight;
  Result := ShowModal = mrOk;
end;

function TfrmImportHist.ImportFile(const BankAccount: TBank_Account; HistTranList: TUnsorted_Transaction_List;
  ErrorList: TStringList): Boolean;
var
  HFileSL : TStringList; //holds all lines in file
begin
  Result := False;

  HFileSL := TStringList.Create;

  try
    if LoadFile(HFileSL) then
      if ValidateFile(HFileSL,BankAccount, ErrorList) then
        result := ProcessFile(HFileSL,BankAccount, HistTranList);
  finally
    HFileSL.Free;
  end;
end;

procedure TfrmImportHist.btnBrowseClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFileDir(edtFilename.Text);

  if OpenDialog1.Execute then
    edtFilename.Text := OpenDialog1.FileName;
end;



end.
