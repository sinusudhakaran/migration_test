// FogBugz case 5043
// Build up a list of uncoded transactions to send via email
// Enable compiler defn USEWORD to use a Word attachment
// Otherwise it uses plain text blocks
// This can currently only be accessed from the CES
unit QueryTx;

interface

uses baObj32;

procedure SendUncodedTransactions;

implementation

uses
  ForexHelpers,
  MoneyUtils,
  Windows, Classes, sysUtils, Globals, AccsDlg, BKUtil32, InfoMoreFrm,
  BKDefs, BKDateUtils, GenUtils, MailFrm, StDate, caUtils, ComObj, WinUtils,
  MainFrm, CodingFrm, bkConst, ToDoHandler, bkProduct;

const
{$IFDEF USEWORD}
      // Word automation constants
      wdAlignParagraphLeft = 0;
      wdAlignParagraphCenter = 1;
      wdAlignParagraphRight = 2;
      wdAlignParagraphJustify = 3;
      wdAdjustNone = 0;
      wdGray25 = 16;
      wdWhite = 0;
      wdOrientationLandscape = 1;
      FILENAME = 'QUERIES.DOC';
{$ENDIF}
      INSTRUCTION_TEXT  = 'Please provide further information regarding the transactions listed below:';
      NOTETEXT = 'email query sent on ';


// Appends a query note to a transaction if not already there (existing notes should not be touched)
procedure AppendQueryNote(Tx: pTransaction_Rec);
begin
  if Pos(NOTETEXT, Tx.txNotes) = 0 then
  begin
    if Tx.txNotes <> '' then
      Tx.txNotes := Tx.txNotes + #13#10;
    Tx.txNotes := Tx.txNotes + NOTETEXT + bkDate2Str(CurrentDate);
  end;
end;

{$IFDEF USEWORD}

// Create a word doc and set up initial text
procedure WordStartDoc(var wrdApp, wrdDoc, wrdSelection: Variant);
var
  s: string;
  i: Integer;
begin
  wrdApp := CreateOleObject('Word.Application');
  wrdApp.Visible := True;
  wrdDoc := wrdApp.Documents.Add();
  wrddoc.PageSetup.Orientation := wdOrientationLandscape;
  wrdDoc.Select;
  wrdSelection := wrdApp.Selection;
  s := INSTRUCTION_TEXT;
  wrdSelection.ParagraphFormat.Alignment := wdAlignParagraphLeft;
  wrdSelection.TypeText(s);
  for i := 1 to 4 do // newlines
     wrdApp.Selection.TypeParagraph;
end;

// Save the Word doc and quit
procedure WordEndDoc(var wrdApp, wrdDoc: Variant);
begin
  if BKFileExists(Globals.DataDir + FILENAME) then
    DeleteFile(Globals.DataDir + FILENAME);
  wrdDoc.SaveAs(Globals.DataDir + FILENAME);
  wrdDoc.Saved := True;
  wrdDoc.Close(False);
  wrdApp.Quit(False);
end;

// Fill a given Row number in a table with the supplied text fields
procedure WordFillRow(var wrdDoc, wrdSelection: Variant; var Row: Integer;
  EffDate, Amount, Ref, Narration, Notes: string);
begin
  Inc(Row);
  if Row = 1 then // Shade and bold the headers
  begin
    wrdDoc.Tables.Item(1).Rows.Item(Row).Cells.Shading.BackgroundPatternColorIndex := wdGray25;
    wrdDoc.Tables.Item(1).Rows.Item(Row).Range.Bold := True;
  end
  else if Row = 2 then // Must reset the shading and bold when we reach the next row
  begin
    wrdDoc.Tables.Item(1).Rows.Item(Row).Cells.Shading.BackgroundPatternColorIndex := wdWhite;
    wrdDoc.Tables.Item(1).Rows.Item(Row).Range.Bold := False;
  end;
  wrdSelection.InsertRowsBelow(1);
  wrdDoc.Tables.Item(1).Cell(Row, 1).Range.InsertAfter(EffDate);
  wrdDoc.Tables.Item(1).Cell(Row, 2).Range.InsertAfter(Amount);
  wrdDoc.Tables.Item(1).Cell(Row, 2).Range.ParagraphFormat.Alignment := wdAlignParagraphRight;
  wrdDoc.Tables.Item(1).Cell(Row, 3).Range.InsertAfter(Ref);
  wrdDoc.Tables.Item(1).Cell(Row, 4).Range.InsertAfter(Narration);
  wrdDoc.Tables.Item(1).Cell(Row, 4).Range.ParagraphFormat.Alignment := wdAlignParagraphLeft;
  wrdDoc.Tables.Item(1).Cell(Row, 5).Range.InsertAfter(Notes);
  wrdDoc.Tables.Item(1).Cell(Row, 5).Range.ParagraphFormat.Alignment := wdAlignParagraphLeft;
end;

// Create a table in the Word document
procedure WordStartTable(var wrdDoc, wrdSelection: Variant; var Row: Integer);
begin
  Row := 0;
  wrdDoc.Tables.Add(wrdSelection.Range, 1, 5);
  wrdDoc.Tables.Item(1).Columns.Item(1).SetWidth(60, wdAdjustNone);
  wrdDoc.Tables.Item(1).Columns.Item(2).SetWidth(90, wdAdjustNone);
  wrdDoc.Tables.Item(1).Columns.Item(3).SetWidth(90, wdAdjustNone);
  wrdDoc.Tables.Item(1).Columns.Item(4).SetWidth(225, wdAdjustNone);
  wrdDoc.Tables.Item(1).Columns.Item(5).SetWidth(225, wdAdjustNone);
  // Header row
  WordFillRow(wrdDoc, wrdSelection, Row, 'Date', 'Amount', 'Reference', 'Narration', 'Notes');
end;

{$ELSE}

// Remove duplicate new lines from notes
function TrimExtraNewlines(s: string): string;
var
  x: Integer;
begin
  x := Pos(#13#10#13#10, s);
  while x > 0 do
  begin
    Delete(s, x, 2);
    x := Pos('#13#10#13#10', s);
  end;
  Result := s;
end;

// Create a text block for a transaction
function BuildTransactionBlock(T: pTransaction_Rec; B: TBank_Account ): string; overload;
begin
  Result := #13#13;
  if Trim(bkDate2Str(T.txDate_Effective)) <> '' then
    Result := Result + 'Date: ' + bkDate2Str(T.txDate_Effective) + #13;

  if Trim(MakeAmount(T.txAmount)) <> '' then
        Result := Result + 'Amount: ' + MoneyStrBrackets(T.Statement_Amount,B.baFields.baCurrency_Code) + #13;

  if Trim(T.txReference) <> '' then
    Result := Result + 'Reference: ' + T.txReference + #13;
  if Trim(T.txGL_Narration) <> '' then
    Result := Result + 'Narration: ' + T.txGL_Narration + #13;
  if Trim(T.txNotes) <> '' then
    Result := Result + 'Notes: ' + TrimExtraNewlines(T.txNotes) + #13;
end;

// Create a text block for a dissection
function BuildTransactionBlock(D: pDissection_Rec; B: TBank_Account): string; overload;
begin
  Result := #9 + 'DISSECTED' + #13;
  if Trim(MakeAmount(D.dsAmount)) <> '' then
    Result := Result + #9 + 'Amount: ' + MoneyStrBrackets(D.Statement_Amount,B.baFields.baCurrency_Code) + #13;
  if Trim(D.dsReference) <> '' then
    Result := Result + #9 + 'Reference: ' + D.dsReference + #13;
  if Trim(D.dsGL_Narration) <> '' then
    Result := Result + #9 + 'Narration: ' + D.dsGL_Narration + #13;
  if Trim(D.dsNotes) <> '' then
    Result := Result + #9 + 'Notes: ' + TrimExtraNewlines(D.dsNotes) + #13;
end;

{$ENDIF}

// Returns TRUE if the given transaction record is a cheque type
function IsCheque(T: pTransaction_Rec): Boolean;
begin
  Result := ((MyClient.clFields.clCountry = whAustralia) and (T.txType = 1)) or
            ((MyClient.clFields.clCountry = whNewZealand) and (T.txType in [0,4..9]));
end;

// Send uncoded transactions via an email
// Uses existing BK5 send mail form to do the sending, with fields auto-filled
// Uses CES date range
procedure SendUncodedTransactions;
var
  B: TBank_Account;
  SelectedList: TStringList;
  i, j, k, StartDate, EndDate: Integer;
  s: string;
  T: pTransaction_Rec;
  D: pDissection_Rec;
  Uncoded, Coded, AddedHeading: Boolean;
  cf: TfrmCoding;
  IsActive: boolean;  
{$IFDEF USEWORD}
  wrdSelection, wrdApp, wrdDoc: Variant;
  Row: Integer;
{$ENDIF}
begin
  StartDate := MinValidDate;
  EndDate := MaxValidDate;
  SelectedList  := TStringList.Create;

  try
    // Auto-tick any bank accounts that are open in a CES and get the CES date range
    for i := 0 to Pred(frmMain.MDIChildCount) do
    begin
      if frmMain.MDIChildren[i] is TfrmCoding then
      begin
        cf := TfrmCoding(frmMain.MDIChildren[i]);
        StartDate := cf.StartDate;
        EndDate := cf.EndDate;
        if Assigned(cf.Bank_Account) then
          SelectedList.AddObject(cf.Bank_Account.baFields.baBank_Account_Number, cf.Bank_Account);
      end;
    end;

    // Make sure there is something to do
    if not ClientHasUncodedTransactions(StartDate, EndDate) then
    begin
      HelpfulInfoMsg( 'There are no bank accounts with uncoded transactions.', 0 );
      exit;
    end;

    // Use the standard bank account selection dialog - auto-handles the case where there is only one bank account to select
    if SelectBankAccounts('Select Bank Accounts to Query Uncoded Transactions', SelectedList, selectWithUncodedTrx, StartDate, EndDate, false, 0) then
    begin
{$IFDEF USEWORD}
      WordStartDoc(wrdApp, wrdDoc, wrdSelection);
{$ELSE}
      s := INSTRUCTION_TEXT;
{$ENDIF}
      for i := 0 to Pred(SelectedList.Count) do // For each selected bank account
      begin
        B := TBank_Account(SelectedList.Objects[i]);
        // Add the bank account heading
{$IFNDEF USEWORD}
        s := s + #13#13#13 + '------------------------------------------------------------' + #13;
{$ENDIF}
        s := s + 'Bank Account Number: ' + B.baFields.baBank_Account_Number + #13 +
                 'Bank Account Name: ' + B.AccountName;
{$IFDEF USEWORD}
        wrdSelection.ParagraphFormat.Alignment := wdAlignParagraphCenter;
        wrdSelection.Font.Bold := True;
        wrdSelection.TypeText(s);
        wrdSelection.Font.Bold := False;
        WordStartTable(wrdDoc, wrdSelection, Row);
        Row := 1;
{$ELSE}
        s := s + #13 + '------------------------------------------------------------' + #13;
{$ENDIF}
        for k := 0 to 1 do // First do cheques, then other transactions
        begin
          AddedHeading := False;
          for j := B.baTransaction_List.First to B.baTransaction_List.Last do // check every transaction
          begin
            T := B.baTransaction_List.Transaction_At(j);

            // Skip if out of date range, or if not the correct transaction type for this loop
            if (T.txDate_Effective < StartDate) or (T.txDate_Effective > EndDate) then Continue;
            if (k = 0) and (not IsCheque(T)) then Continue;
            if (k = 1) and IsCheque(T) then Continue;

            // Work out if the transaction is uncoded
            if MyClient.clChart.itemCount > 0 then
              Uncoded := IsUncoded(T)
            else
              Uncoded := (T.txAccount = '');

            if not Uncoded then Continue;

{$IFNDEF USEWORD}
            // Add the transaction type heading
            if (k = 0) and (not AddedHeading) then
            begin
              AddedHeading := True;
              s := s + #13#13 + 'CHEQUES' + #13;
            end;
            if (k = 1) and (not AddedHeading) then
            begin
              AddedHeading := True;
              s := s + #13#13 + 'OTHER TRANSACTIONS' + #13;
            end;              
{$ENDIF}
            if Uncoded then // Uncoded transaction
            begin
              if T.txFirst_Dissection <> nil then // Dissected - show main line and uncoded dissect lines
              begin
{$IFDEF USEWORD}
                WordFillRow(wrddoc, wrdSelection, Row, bkDate2Str(T.txDate_Effective),
                  MakeAmount(T.txAmount), T.txReference, T.txGL_Narration, T.txNotes);
{$ELSE}
                s := s + BuildTransactionBlock(T, B);
{$ENDIF}
                D := T.txFirst_Dissection;
                while D <> nil do // Check every dissection line
                begin
                  // Work out if the dissection is uncoded
                  Coded := MyClient.clChart.CanCodeTo(D.dsAccount, IsActive);
                  if IsCASystems(MyClient) and (not CASystemsGSTOK(MyClient, D.dsGST_Class)) then
                    Coded := False;

                  if not Coded then // Uncoded dissection
                  begin
{$IFDEF USEWORD}
                    WordFillRow(wrddoc, wrdSelection, Row, 'DISSECT', MakeAmount(D.dsAmount),
                      D.dsReference, D.dsGL_Narration, D.dsNotes);
{$ELSE}
                    s := s + BuildTransactionBlock(D, B);
{$ENDIF}
                  end;
                  D := D.dsNext;
                end;
              end
              else // Show main line
{$IFDEF USEWORD}
                WordFillRow(wrddoc, wrdSelection, Row, bkDate2Str(T.txDate_Effective),
                  MakeAmount(T.txAmount), T.txReference, T.txGL_Narration, T.txNotes);
{$ELSE}
                s := s + BuildTransactionBlock(T,B);
{$ENDIF}
            end;
          end;
        end;
      end;
{$IFDEF USEWORD}
      WordEndDoc(wrdApp, wrdDoc);

      // Now send the mail with to, from, subject and body filled in
      if MailFrm.SendMailTo('Query Uncoded Transactions', MyClient.clFields.clClient_EMail_Address, TProduct.BrandName + ' Transaction Query',
           'Please view the attached Word document from your accountant', Globals.DataDir + FILENAME, False) then
{$ELSE}
      if MailFrm.SendMailTo('Query Uncoded Transactions', MyClient.clFields.clClient_EMail_Address, TProduct.BrandName + ' Transaction Query', s, '', False) then
{$ENDIF}
      begin
        // Sent OK - Add notes to all sent transactions
        for i := 0 to Pred(SelectedList.Count) do
        begin
          B := TBank_Account(SelectedList.Objects[i]);
          for j := B.baTransaction_List.First to B.baTransaction_List.Last do
          begin
            T := B.baTransaction_List.Transaction_At(j);
            if (T.txDate_Effective < StartDate) or (T.txDate_Effective > EndDate) then Continue;            
            // Work out if the transaction is uncoded
            if MyClient.clChart.itemCount > 0 then
              Uncoded := IsUncoded(T)
            else
              Uncoded := (T.txAccount = '');
            if Uncoded then // Uncoded transaction
              AppendQueryNote(T);
          end;
        end;
        AddAutomaticToDoItem(MyClient.clFields.clCode, ttyQueryEmail,
          Format(ToDoMsg_QueryEmail, [bkDate2Str(StartDate), bkDate2Str(EndDate), bkDate2Str(CurrentDate)]), 0, 0, true);
        
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;

end.
