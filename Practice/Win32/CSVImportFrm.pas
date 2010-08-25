unit CSVImportFrm;
//------------------------------------------------------------------------------
{
   Title:          CSV Import Form

   Description:    Import UI for creating a bank account from a CSV file

   Author:         Matthew Hopkins  Jun 2005

   Remarks:        FOR INTERNAL USE ONLY - Not for clients

                   Imports from CSV files directly into bank accounts.
                   For use by sales to create demo data


}
//------------------------------------------------------------------------------

interface

{$IFNDEF CSVImport}
   ..only for use by training.. not for clients!
{$ENDIF}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, baObj32;

type
  TfrmCSVImport = class(TForm)
    lblAccountNo: TLabel;
    lblAccountName: TLabel;
    edtAcctNo: TEdit;
    edtAcctName: TEdit;
    btnImport: TButton;
    btnCancel: TButton;
    Filename: TLabel;
    edtFilename: TEdit;
    OpenDialog1: TOpenDialog;
    btnBrowse: TButton;
    btnExport: TButton;
    cbAccounts: TComboBox;
    Label1: TLabel;
    btnView: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure FillList;
    procedure btnViewClick(Sender: TObject);
  private
    { Private declarations }
    function ImportFile( const ba : TBank_Account) : boolean;
  public
    { Public declarations }
  end;


  procedure ImportFromCSVFile;


implementation
uses
  {}ClientHomepageFrm,{}
  TransactionUtils,
  csvParser, globals, bkdefs, bktxio, bkDateUtils, bkConst, MoneyDef, GenUtils,
  trxList32;



const
  ColDate = 1;
  ColRef = 2;

  ColAmount = 3;
        {
  ColCode: Integer = 4;
  ColStatement = 5;
  ColNarration = 6;
  ColQuantity = 7;
  ColEntryType = 8;
  ColAnalysis = 9;
  ColOther = 10;
  ColParticulars = 11;
  ColSource = 12;
  ColLast = 13;
         }

var
  LastFileImported : string;

// Header line must contain the following columns in order!

const
   LHeader =
   //'H,DATE,REFERENCE,AMOUNT,BALANCE,STATEMENT DETAILS,NARRATION,QUANTITY,ENTRY TYPE,ANALYSIS,OTHER PARTY,PARTICULARS,LASTCOL';
   'H,DATE,REFERENCE,AMOUNT,CODE,STATEMENT DETAILS,NARRATION,QUANTITY,ENTRY TYPE,ANALYSIS,OTHER PARTY,PARTICULARS,SOURCE,LASTCOL';

   FHeader =
   'H,DATE,REFERENCE,LAMOUNT,ERATE,FAMOUNT,CODE,STATEMENT DETAILS,NARRATION,QUANTITY,ENTRY TYPE,ANALYSIS,OTHER PARTY,PARTICULARS,SOURCE,LASTCOL';


{$R *.dfm}

procedure ImportFromCSVFile;
begin
  with TfrmCSVImport.Create( Application) do
  begin
    try
      edtFilename.text := ExtractFilePath( LastFileImported);
      ShowModal;
    finally
      free;
    end;
  end;
  {} ClientHomepageFrm.RefreshHomepage; {}
end;

procedure TfrmCSVImport.btnCancelClick(Sender: TObject);
begin
   Close;
end;

const Sep = ',';
      Quote = '"';
procedure TfrmCSVImport.btnExportClick(Sender: TObject);
var  filename : string;
     ba: TBank_Account;
     f: TextFile;
     I: Integer;
     t: tTransaction_Rec;
     IsForex: Boolean;
begin
   if cbAccounts.ItemIndex < 0 then begin
      ShowMessage( 'No Account selected');
      cbAccounts.SetFocus;
      exit;
   end;
   filename := edtFilename.Text;
   if filename = '' then begin
      ShowMessage( 'Please enter filename');
      edtFilename.SetFocus;
      exit;
   end;

   if FileExists( filename) then begin
       if MessageDlg( filename + ' already exists'#13#13 +
                    'Do you want to overwrite ?',
                    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
       exit;
   end;

   ba := TBank_Account(cbAccounts.Items.objects[cbAccounts.ItemIndex]);
   IsForex := ba.IsAForexAccount;
   AssignFile(f,FileName);
   try
   ReWrite(f);
   try
      // Header line
      if IsForex then
         writeln(f,FHeader)
      else
         writeln(f,LHeader);

      //Account Line
      Write(f,'A', sep,
                Quote, ba.baFields.baBank_Account_Number, Quote, Sep,
                ba.baFields.baBank_Account_Name, Sep,
                ba.baFields.baContra_Account_Code, Sep,
                CurrToStr( ba.baFields.baCurrent_Balance / 100)
                      );
      if IsForex then
         WriteLn(f, Sep,  ba.baFields.baCurrency_Code)
      else
         WriteLn(f);

      // Do the transactions
      for I := 0 to ba.baTransaction_List.ItemCount - 1 do begin
         t := ba.baTransaction_List.Transaction_At(I)^;
         //Transaction Line
         Write(f,'T',Sep,
                  bkDateUtils.bkDate2Str(t.txDate_Effective), Sep,
                  Quote,t.txReference,Quote, Sep,
                  CurrToStr( t.txAmount / 100), Sep);

         if IsForex then
            Write(f,Format('%.5f',[t.txForex_Conversion_Rate] ), Sep,
                    CurrToStr( t.txForeign_Currency_Amount / 100),Sep);

         writeln(f,
                  Quote, t.txAccount,Quote, sep,
                  Quote, t.txStatement_Details,Quote, Sep,
                  Quote, t.txGL_Narration,Quote, Sep,
                  CurrToStr( t.txQuantity / 10000), Sep,
                  t.txType, Sep,
                  Quote, t.txAnalysis, Quote, Sep,
                  Quote, t.txOther_Party, Quote, Sep,
                  Quote, t.txParticulars,Quote,Sep,
                  t.txSource,Sep);

      end;

      ShowMessage(IntToStr(ba.baTransaction_List.ItemCount) +' Transactions Exported');
   finally
      Closefile(f);
   end;
   except
       ShowMessage( 'Could not write to ' + filename);
   end;
end;

procedure TfrmCSVImport.btnImportClick(Sender: TObject);
var
  filename : string;
  ba : TBank_Account;
begin
   filename := edtFilename.Text;

   //see if file exists
   if not FileExists( filename) then
   begin
     ShowMessage( 'The file ' + filename + ' cannot be found');
     exit;
   end;

   //see if bank account already exists
   ba := MyClient.clBank_Account_List.FindCode( edtAcctNo.Text);
   if ba <> nil then
   begin
     if MessageDlg( 'Account ' + edtAcctNo.Text + ' already exists in this client file.'#13#13 +
                    'Do you want to delete it and continue importing?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
     begin
       MyClient.clBank_Account_List.DelFreeItem( ba);
     end
     else
       exit;
   end;

   ba := TBank_Account.Create;

   ba.baFields.baBank_Account_Number     := Trim( edtAcctNo.Text);
   ba.baFields.baBank_Account_Name       := Trim( edtAcctName.Text);
   ba.baFields.baCurrent_Balance         := Unknown; //don't assign balance until have all trx
   ba.baFields.baApply_Master_Memorised_Entries := true;
   ba.baFields.baAccount_Type            :=  btBank;
   ba.baFields.baDesktop_Super_Ledger_ID := -1;
   ba.baFields.baCurrency_Code           := MyClient.clExtra.ceLocal_Currency_Code;


   if ImportFile( ba) then
   begin
     MyClient.clBank_Account_List.Insert( ba);

     if MessageDlg( 'Import Completed for account ' + ba.bafields.baBank_Account_Number + ' ' +
                    ba.baFields.baBank_Account_Name + #13#13 +
                    'Do you want to import more files?',
                    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
       Close;
   end
   else
   begin
     ba.Free;
   end;
   FillList; // may have changed...
end;

procedure TfrmCSVImport.btnViewClick(Sender: TObject);
begin
    winexec(pchar('notepad ' + EdtFilename.Text  ),SW_SHOW);
end;

procedure TfrmCSVImport.FillList;
var I : Integer;
begin
  CBAccounts.Clear;
   with MyClient.clBank_Account_List do
     for I := 0 to ItemCount - 1 do
       with Bank_Account_At(I) do
          CBAccounts.Items.AddObject
          (baFields.baBank_Account_Number, Bank_Account_At(I));
end;

procedure TfrmCSVImport.FormCreate(Sender: TObject);
begin
   FillList;
end;

function TfrmCSVImport.ImportFile(const ba : TBank_Account) : boolean;
var
  csvfile : TStringList;    //holds all lines in file
  commaline : TStringList;  //holds all fields for a line
  lineNo : integer;
  fieldNo : integer;
  s : string;
  sEntryType : string;
  pT : pTransaction_Rec;
  p : integer;
  AccountInfoFound : boolean;
  ValidLineFound : boolean;
  AccountNumber: string;
  AccountName: string;
  ExistingAccount : TBank_Account;
  IsForex: Boolean;
  ColERate,
  ColFAmount,
  ColCode,
  ColStatement,
  ColNarration,
  ColQuantity,
  ColEntryType,
  ColAnalysis,
  ColOther,
  ColParticulars,
  ColSource,
  ColLast : Integer;



  oCSVParser : csvParser.TCsvParser;
begin
  LastFileImported := edtFilename.text;

  result := false;
  // set the defaults //keep the
  IsForex := False;
  ColERate   := 0;
  ColFAmount := 0;
  ColCode    := 4;
  ColStatement := 5;
  ColNarration := 6;
  ColQuantity := 7;
  ColEntryType := 8;
  ColAnalysis := 9;
  ColOther := 10;
  ColParticulars := 11;
  ColSource := 12;
  ColLast :=  13;
  //load file into csv file
  csvfile := TStringList.Create;
  commaline := TStringlist.Create;
  oCSVParser := TCsvParser.Create;
  try
    try
      csvFile.LoadFromFile( edtFilename.Text);
    except
      on e : exception do
      begin
        ShowMessage('Error Reading file: ' + E.Message);
        exit;
      end;
    end;

    //check header line
    if csvFile.Text = '' then
    begin
      ShowMessage('File is empty!');
      exit;
    end;

    //validate lines
    AccountInfoFound := false;
    AccountNumber := '';
    AccountName := '';
    ValidLineFound := false;

    for lineNo := 0 to csvFile.Count - 1 do
    begin
      if Trim( csvFile[lineNo]) = '' then
        Continue;

      //assumes that single commas dont exist in file
      oCSVParser.ExtractFields( csvFile[LineNo], CommaLine);

      if commaLine[0] = 'H' then
      begin
        if (csvFile[lineNo] = Lheader) then begin


        end else if (csvFile[lineNo] = Fheader) then begin
           IsForex := True ;
           ColERate   := 4;
           ColFAmount := 5;
           ColCode    := 6;
           ColStatement := 7;
           ColNarration := 8;
           ColQuantity := 9;
           ColEntryType := 10;
           ColAnalysis := 11;
           ColOther := 12;
           ColParticulars := 13;
           ColSource := 14;
           ColLast :=  15;

        end else begin
          ShowMessage('File header is incorrect: '#13#13+ csvFile[LineNo]);
          exit;
        end;
        ValidLineFound := true;
      end;

      if (commaLine[0] = 'T')
      or (commaLine[0] = 'D') then // Dissection
      begin
        if CommaLine.Count <> colLast then
        begin
          ShowMessage('Line ' + inttostr( lineNo) + ' has an incorrect number of fields.  Expected '
                                +inttostr(ColLast) +' found ' + inttostr( CommaLine.count));
          exit;
        end;
        ValidLineFound := true;
      end;

      if (commaLine[0] = 'A') and (ba.baFields.baBank_Account_Number = '') then
      begin
        if CommaLine.Count < 4 then
        begin
          ShowMessage('Line ' + inttostr( lineNo) + ' has an incorrect number of fields.  Expected 3 found ' + inttostr( CommaLine.count));
          exit;
        end;

        AccountNumber := trim( commaLine[1]);
        Accountname := trim( commaLine[2]);


        if AccountNumber = '' then
        begin
          ShowMessage('Account number not specified - ' + commaline.Text);
          exit;
        end
        else
          AccountInfoFound := true;

        ValidLineFound := true;
      end;
    end;

    if not ValidLineFound then
    begin
      Showmessage( 'File format is incorrect, no valid lines found.');
      exit;
    end;

    if (ba.baFields.baBank_Account_Number = '') then
    begin
      if ( not AccountInfoFound) then
      begin
        ShowMessage('Account information row not found');
        exit;
      end
      else
      begin
        //info was found make sure account doesn't already exist
        ExistingAccount := MyClient.clBank_Account_List.FindCode( AccountNumber);
        if ExistingAccount <> nil then
        begin
          if MessageDlg( 'Account ' + AccountNumber + ' already exists in this client file.'#13#13 +
                         'Do you want to delete it and continue importing?',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            MyClient.clBank_Account_List.DelFreeItem( ExistingAccount);
          end
          else
            exit;
        end
        else
        begin
          //using details from file so confirm with user
          if MessageDlg( 'Do you want to enter transaction into account ' + AccountNumber + ' ' +
                          AccountName + '?',
                          mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
             exit;
        end;
      end;
    end;

    //process each line
    for lineNo := 0 to csvFile.Count - 1 do
    begin
      try
        pT := nil;

        if Trim( csvFile[lineNo]) = '' then
          Continue;

        //split line into fields
        oCSVParser.ExtractFields( csvFile[LineNo], CommaLine);

        if CommaLine[0] = 'T' then
        begin
          //cycle through fields, creating transactions
          pT := ba.baTransaction_List.New_Transaction;
          //Set Some defaults
          PT.txSource := orBank;

          for fieldNo := 1 to CommaLine.Count - 1 do
          begin
            s := Trim(CommaLine[fieldNo]);
            //pT^.txSource := bkConst.orManual;


            pT^.txBank_Seq := ba.baFields.baNumber;

            if fieldNo = ColDate  then begin
                //the date should be formated as dd/mm/yy, excel with change 01/04 to 1/04
                if pos( '/', s) = 2 then
                  s := '0' + s;

                pT^.txDate_Effective := bkDateUtils.bkStr2Date( s);
                pT^.txDate_Presented := pT^.txDate_Effective;
            end else if fieldNo = ColRef then
                pT^.txReference := s
            else if fieldNo = ColAmount then begin
                //strip comma, change (1,000) to -1000
                s := StringReplace( s, ',', '', [rfReplaceAll]);
                s := StringReplace( s, '(', '-', [rfReplaceAll]);
                s := StringReplace( s, ')', '', [rfReplaceAll]);
                pT^.txAmount := StrToFloatDef( s, 0.00) * 100;
            end else if fieldNo = ColFAmount then begin
                //strip comma, change (1,000) to -1000
                s := StringReplace( s, ',', '', [rfReplaceAll]);
                s := StringReplace( s, '(', '-', [rfReplaceAll]);
                s := StringReplace( s, ')', '', [rfReplaceAll]);
                pT^.txForeign_Currency_Amount := StrToFloatDef( s, 0.00) * 100;
            end else if fieldNo = ColERate then begin
                //strip comma, change (1,000) to -1000
                s := StringReplace( s, ',', '', [rfReplaceAll]);
                s := StringReplace( s, '(', '-', [rfReplaceAll]);
                s := StringReplace( s, ')', '', [rfReplaceAll]);
                pT^.txForex_Conversion_Rate := StrToFloatDef( s, 0.00000);
            end else if fieldNo = ColCode then begin
                pT^.txAccount := s;
                if pT^.tXAccount > '' then // So we 'keep' it
                    pT^.txHas_Been_Edited := True
            end else if fieldNo = ColStatement then
                pT^.txStatement_Details := s
            else if fieldNo = ColNarration then
                pT^.txGL_Narration := s
            else if fieldNo = ColQuantity then begin
                //strip comma, change (1,000) to -1000
                s := StringReplace( s, ',', '', [rfReplaceAll]);
                s := StringReplace( s, '(', '-', [rfReplaceAll]);
                s := StringReplace( s, ')', '', [rfReplaceAll]);
                pT^.txQuantity := ForceSignToMatchAmount( StrToFloatDef( s, 0.0000) * 10000, pT^.txAmount);
            end else if fieldNo = ColEntryType then begin
                p := pos( ':', s);
                if p > 0 then
                  sEntryType := Copy( s, 1, p -1)
                else
                  sEntryType := s;

                pT^.txType := StrToIntDef( sEntryType, 0);

                //set cheque no based on ref and entry type
                //construct the cheque number from the reference field
                case MyClient.clFields.clCountry of
                  whAustralia, whUK : begin
                    if (pT^.txType = 1) then begin
                      S := Trim( CommaLine[ ColRef]);
                      //cheque no is assumed to be last 6 digits
                      if Length( S) > MaxChequeLength then
                        S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                      pT^.txCheque_Number := Str2Long( S);
                    end;
                  end;

                  whNewZealand : begin
                    if (pT^.txType in [0,4..9]) then begin
                      S := Trim( CommaLine[ ColRef]);
                      //cheque no is assumed to be last 6 digits
                      if Length( S) > MaxChequeLength then
                        S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

                      pT^.txCheque_Number := Str2Long( S);
                    end;
                  end;
                end;
            end else if fieldNo = ColAnalysis then
                pT^.txAnalysis := s
            else if fieldNo = ColOther then
                pT^.txOther_Party := s
            else if fieldNo = ColParticulars then
                pT^.txParticulars := s
            else if fieldNo = ColSource then
                pT^.txSource := StrToIntDef(s, orbank);

          end;
          ba.baTransaction_List.Insert_Transaction_Rec( pT);
        end;

        if (CommaLine[0] = 'A') then begin
          // Pickup any account details

          if ba.baFields.baBank_Account_Number = '' then
             ba.baFields.baBank_Account_Number := commaline[1];

          if ba.baFields.baBank_Account_Name = '' then
             ba.baFields.baBank_Account_Name := commaline[2];

          if ba.baFields.baContra_Account_Code = '' then
             if CommaLine.Count > 3 then
                ba.baFields.baContra_Account_Code := trim(commaLine[3]);

          if CommaLine.Count > 4 then begin
             s :=  CommaLine[4];
             if s <> '' then begin
                s := StringReplace( s, ',', '', [rfReplaceAll]);
                s := StringReplace( s, '(', '-', [rfReplaceAll]);
                s := StringReplace( s, ')', '', [rfReplaceAll]);
                ba.baFields.baCurrent_Balance := StrToFloatDef( s, 0.00) * 100;
             end;
           end;

           if (CommaLine.Count > 5)
           and IsForex
           and (CommaLine[5] > '') then begin
               ba.baFields.baCurrency_Code := CommaLine[5];
           end;
        end;

      except
      on e : exception do
      begin
        if Assigned( pT) then
          trxList32.Dispose_Transaction_Rec( pT);

        ShowMessage('Error processing line ' + inttostr(lineNo) + ' - ' + e.Message);
        exit;
      end;

      end;
      result := true;
    end;
  finally
    oCSVParser.Free;
    csvFile.Free;
    commaline.Free;
  end;
end;

procedure TfrmCSVImport.btnBrowseClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFileDir( edtFilename.Text);

  if OpenDialog1.Execute then
    edtFilename.Text := OpenDialog1.FileName;
end;

initialization
  LastFileImported := '';

end.
