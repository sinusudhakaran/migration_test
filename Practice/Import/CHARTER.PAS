unit Charter;
      !!!! Not Used !!!!
interface
procedure ExtractData(FromDate, ToDate : integer; SaveTo : string);

implementation
uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm,
  bkDateUtils, BaUtils, Progress, GenUtils, 

  TravList, AccsDlg, classes, baObj32, TextStream, MoneyDef, LogUtil;

function N3(A : integer) : string;
var
  S :string[3];
  i : integer;
begin
  Str(A:3,S);
  for i := 1 to 3 do if s[i] = ' ' then s[i] := '0';
  result := S;
end;

procedure CountEntry(Sender : TObject);
var
  TravMgr : TTravManagerForExport;
  S       : String;
begin
  TravMgr := TTravManagerForExport(Sender);
  with TravMgr, TravMgr.Transaction^ do
  begin
    if txFirst_Dissection = nil then
    begin
      Inc(NoOfEntries);
      
      S := Trim(MakeComment( False, txOther_Party, txParticulars ) );
      if s <> '' then
        Inc(LineCount);  {comment count}
    end;
    SPCD := txDate_Effective;
  end;
end;

procedure CountDissection(Sender : TObject);
var
  TravMgr : TTravManagerForExport;
  S       : String;
begin
  TravMgr := TTravManagerForExport(Sender);
  with TravMgr, TravMgr.ExportStream, TravMgr.Transaction^, TravMgr.Dissection^ do
  begin
    Inc(NoOfEntries);
    S := Trim(dsNarration);
    if s <> '' then
      Inc(LineCount);  {comment count}
  end;
end;

procedure DoEntry(Sender : TObject);
var
  TravMgr : TTravManagerForExport;
  S       : ShortString;
  Reverse : Boolean;
begin
  TravMgr := TTravManagerForExport(Sender);
  with TravMgr, TravMgr.ExportStream, TravMgr.Transaction^, TravMgr.Dissection^ do
  begin
    if txFirst_Dissection = nil then
    begin
      Inc(NoOfEntries);

      WriteAdd( '"L",' );
      WriteAdd( inttoStr(NoOfEntries)+ ',1,1,' );
      WriteAdd( txAccount +',' );

      S := Trim(FillRefce( txReference ) );
      While Length( S ) > 6 do System.Delete( S, 1, 1 );
      While Length( S ) < 6 do S := ' '+S;
      WriteAdd( '"'+S+'",' );

      WriteAdd( '"'+ bkDate2Str( txDate_Effective )+'",0,' );

      Str( txAmount/100:10:2,S );  S := Trim( S );
      WriteAdd( S+',' );
      
      Case MyClient.clFields.clCountry of
         whNewZealand : 
            Begin
               Reverse :=  GenUtils.R{removeme}everseFields( Bank_Account.baFields.baBank_Account_Number );
               S := MakeComment( Reverse, txOther_Party, txParticulars);
            end;
         whAustralia  : S := tx{removeme}Narration;
      end;
      While Length( S ) > 20 do S[0]:=Pred( S[0] );
      Writeln('"'+S+'"' );
      Contra := Contra + txAmount;
    end;
    txDate_Transferred := CurrentDate;
  end;
end;

procedure DoDissection(Sender : TObject);
var
  TravMgr : TTravManagerForExport;
  S       : ShortString;
begin
  TravMgr := TTravManagerForExport(Sender);
  with TravMgr, TravMgr.ExportStream, TravMgr.Transaction^, TravMgr.Dissection^ do
  begin
     Inc( NoOfEntries );

     WriteAdd( '"L",' );
     WriteAdd( inttostr(NoOfEntries)+ ',1,1,' );
     WriteAdd( dsAccount +',' );

     S := Trim(FillRefce( txReference ) );
     While Length( S ) > 6 do System.Delete( S, 1, 1 );
     While Length( S ) < 6 do S := ' '+S;
     WriteAdd( '"'+S+'",' );

     WriteAdd( '"'+ bkDate2Str( txDate_Effective )+'",0,' );

     Str( dsAmount/100:10:2,S );  S := Trim( S );
     WriteAdd( S+',' );

     S := Trim( dsNarration);
     While Length( S ) > 20 do S[0]:=Pred( S[0] );
     Writeln('"'+ S+ '"' );
     Contra := Contra + dsAmount;
  end;
end;

procedure ExtractData(FromDate, ToDate : integer; SaveTo : string);
var
  BankAccount  : TBank_Account;
  TravMgr      : TTravManagerForExport;
  TextFileStream : TTextFileStream;
  S              : String;
begin
  with MyClient, MyClient.clFields do begin

    {check things here}
    TravMgr        := nil;
    try
      BankAccount := SelectBankAccount('Select Bank Accounts to Extract From', SelectForTrans, FromDate,ToDate,true,0);
      if not Assigned(BankAccount) then exit;

      {create text file}
      textFileStream := TTextfileStream.Create(SaveTo,fmCreate);
      try
        TravMgr := TTravManagerForExport.Create;

        with TravMgr do begin
          NoOfEntries := 0;
          CrValue     := 0;
          DrValue     := 0;
          Contra      := 0;
          LineCount   := 0;

          ExportStream      := TextFileStream;
          SortType          := csDateEffective;
          SelectionCriteria := twAllNewEntries;
        end;

        UpdateAppStatus('Extracting Data','Processing',0);
        LogUtil.LogMsg(lmInfo,'CHARTER','Extracting Data from '+bkDate2Str(fromDate)+ ' to '+ bkDate2Str(toDate));

        UpdateAppStatusLine2(bankAccount.baFields.baBank_Account_Number+' '+BankAccount.baFields.baBank_Account_Name);
        LogUtil.LogMsg(lmInfo,'CHARTER','Extracting Account '+bankAccount.baFields.baBank_Account_Number);

        {---------- count entries ------------------}
        with TravMgr do
        begin
          OnEnterEntry      := CountEntry;
          OnEnterDissection := CountDissection;

          AccountToTraverse := BankAccount;
          TraverseAccount(BankAccount, fromDate, toDate);

          Inc(NoOfEntries);
          Inc(NoOfEntries);
          Inc(LineCount);
        end;

        {write headers}
        with TravMgr, TravMgr.ExportStream do
        begin
          Writeadd('"GL",');
          WriteAdd(N3(NoofEntries)+',');
          WriteAdd(N3(LineCount)+',');
          Writeln('000');

          WriteAdd('"H",1,"From Banklink   ","J",1,');
          Writeln('"'+bkDate2Str(SPCD)+'",0.00');

          NoofEntries := 0;
          LineCount   := 0;
        end;

        {---------- extract entries ------------------}
        with TravMgr do
        begin
          Clear;

          OnEnterEntry      := DoEntry;
          OnEnterDissection := DoDissection;

          AccountToTraverse := BankAccount;
          TraverseAccount(BankAccount, fromDate, ToDate);
        end;

        {write trailer}
        with TravMgr, TravMgr.ExportStream do
        begin
          Inc(NoOfEntries);

          WriteAdd('"L",');
          WriteAdd(inttostr(NoofEntries)+',1,1,');
          WriteAdd(AccountToTraverse.baFields.baContra_Account_Code+',');
          WriteAdd('"CONTRA",');
          WriteAdd('"'+bkDate2Str(SPCD)+'",0,');
          Str(-Contra/100:10:2,S);
          S := Trim(S);
          WriteAdd(S+',');
          Writeln('"Contra to Bank"');
        end;

        ClearStatus(True);
        LogUtil.LogMsg(lmInfo,'CHARTER','Extracting Data Completed '+inttostr(TravMgr.NoOfEntries)+' Entries');
        HelpfulInfoMsg('Extract Data completed OK, '+inttostr(TravMgr.NoOfEntries)+' entries transferred.',0);
      finally
        TextFileStream.Free;
      end;
    finally
      TravMgr.Free;
      ClearStatus(True);
    end;
  end; {with}
end;


end.
