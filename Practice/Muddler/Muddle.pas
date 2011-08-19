//------------------------------------------------------------------------------
{
   Title:       Muddle

   Description: Used by the Muddle Application to Copy a practice folder to
                a new location then open all the required data, replace the
                Data with generated Data and the Save the files to the New
                Location.

   Remarks:

   Author:      Ralph Austen

}
//------------------------------------------------------------------------------
unit Muddle;

interface

uses
  Classes,
  SysObj32,
  Clobj32,
  baObj32,
  DataGenerator,
  SyDefs,
  BkDefs,
  PayeeObj,
  trxList32,
  ClientDetailCacheObj;

Const
  FILENAME_MUDDLE_DAT  = 'Muddler.dat';

Type
  TProgressEvent = procedure (ProgressPercent : single) of object;

  TAccountOldNew = record
    OldAccNumber : string;
    NewAccNumber : string;
    NewAccName   : string;
  end;

  TArrAccOldNew = Array of TAccountOldNew;

  TFileOldNew = record
    OldName : string;
    NewName : string;
  end;

  TArrFileOldNew = Array of TFileOldNew;

  TBillingInfo = record
    ClientName      : string;
    AccountNumber   : string;
    AccountName     : string;
    NumOfTrans      : integer;
    CurrentBalance  : Currency;
    LastTranDate    : TDateTime;
    InstitutionName : String;
  end;

  TArrBillingInfo = Array of TBillingInfo;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  TClientItem = class
  private
    fClientObj     : TClientObj;
    fFileName      : string;
    fDone          : boolean;
    fOldClientCode : string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open;
    procedure Save;

    property ClientObj     : TClientObj read fClientObj     write fClientObj;
    property FileName      : string     read fFileName      write fFileName;
    property Done          : Boolean    read fDone          write fDone;
    property OldClientCode : string     read fOldClientCode write fOldClientCode;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  TClientList = class(TList)
  protected
    function Get(Index: Integer): TClientItem;
    procedure Put(Index: Integer; Item: TClientItem);
  public
    destructor Destroy; override;

    function GetClientFromCodeandLRN(ClientCode : string ; LRN : Integer) : TClientItem;
    function GetClientFromOldClientCode(OldClientCode : string) : TClientItem;

    property Items[Index: Integer]: TClientItem read Get write Put; default;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  TMuddler = class
  private

    fClientList           : TClientList;
    fOnProgressUpdate     : TProgressEvent;
    fSourceDirectory      : string;
    fDestinationDirectory : string;
    fDataGenerator        : TDataGenerator;
    fArrAccOldNew         : TArrAccOldNew;
    fArrFileOldNew        : TArrFileOldNew;
    fArrBillingInfo       : TArrBillingInfo;
    fClientDetailsCache   : TClientDetailsCache;

    procedure SetProgressUpdate(ProgressPercent : single);
    procedure CopyFolder(SourceDirectory, DestinationDirectory: string; FileCount : integer; var FileIndex : integer);
    procedure CountItemsInFolder(SourceDirectory : string; var FileCount : integer);
    procedure ClearFilesInFolder(Directory : string; var FileCount : integer; var FileIndex : integer);
    procedure CountFilesToClearInFolder(Directory : string; var FileCount : integer);
    function IsClientFileNameUsed(FileName : string) : Boolean;
    function MuddleNumericData(Instring : string) : string;
    function GetFirstAlphaCharFromAcc(AccNumber : String) : String;
    procedure AddAccountOldNew(OldAccNumber, NewAccNumber, NewAccName : string);
    function FindOldAccount(OldAccNumber : string; var NewAccNumber, NewAccName : string) : boolean;
    procedure AddFileOldNew(OldName, NewName : string);
    procedure AddBillingInfo(ClientName      : string;
                             AccountNumber   : string;
                             AccountName     : string;
                             NumOfTrans      : integer;
                             CurrentBalance  : Currency;
                             LastTranDate    : TDateTime;
                             InstitutionName : String);
    function FileInCopyList(FileName : string) : Boolean;

    function GetFileExt(FileName : string) : string;
    procedure CreateWorkCsvFile;
    procedure AddSuperVisUser;
  protected
    procedure MuddlePracticeSys(var PracticeFields : tPractice_Details_Rec;
                                Name         : string;
                                Phone        : string;
                                Email        : string;
                                WebSite      : string;
                                BankLinkCode : string);

    procedure MuddleUserSys(UserFields   : pUser_Rec;
                            PracticeName : string;
                            var SupervisExists : boolean);

    procedure MuddleClientSys(ClientField : pClient_File_Rec;
                              Code        : string;
                              Name        : string);

    procedure MuddleClientBk5(const ClientObj : TClientObj;
                              PracticeName    : string;
                              PracticeEmail   : string;
                              PracticeWebSite : string;
                              PracticePhone   : string;
                              PracticeCode    : string;
                              BankLinkCode    : string;
                              Code            : string;
                              Name            : string;
                              InSystem        : boolean);

    procedure MuddlePayeeBk5(const PayeeObj : TPayee;
                             Name : string);

    procedure MuddleJobBk5(JobObj : pJob_Heading_Rec);

    procedure MuddleAccountBk5(AccountObj : TBank_Account;
                               ClientName : String);

    procedure MuddleTransactionBk5(TransField : pTransaction_Rec);

    procedure MuddleMemorizationSys(MemField : pSystem_Memorisation_List_Rec);

    procedure MuddleTXNFile(FullFileName : string);

    procedure SearchForTXNFiles(Directory : string);

    procedure MuddleDiskImageFile(FullFileName : string;
                                  Code         : string);

    procedure SearchForDiskImageFiles(Directory : string);

    Function CopyPractice : Boolean;
    procedure Open;
    procedure Muddle;
    procedure Save;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddBk5ExeToDataFile(Bk5File : string);
    procedure Execute(SourceDirectory, DestinationDirectory : string);
    procedure MakeBasicData;

    property OnProgressUpdate : TProgressEvent read fOnProgressUpdate write fOnProgressUpdate;
    property DataGenerator : TDataGenerator read fDataGenerator write fDataGenerator;
  end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation

uses
  SysUtils,
  Windows,
  ClientWrapper,
  upgConstants,
  FileCtrl,
  Globals,
  StrUtils,
  fCopy,
  ARCHUTIL32,
  NFDiskObj,
  dbObj,
  FHDEFS,
  GlobalDirectories,
  MemorisationsObj,
  Upgrade,
  Admin32,
  Progress,
  DateUtils,
  stDate,
  SYusIO,
  BkConst;

const
  MIN_NUM_REPLACE_LENGTH = 4;
  FILE_EXT_LIST : Array[0..17] of string =
    ('bk5','Exe','Inf','rsm','html','db','dat','ini','chm','dll','map','prs',
     'ovl','current','Txn','tpm','bk!','xml');
  ACC_TYPE_NOT_MUDDLED = [btCashJournals,
                          btAccrualJournals,
                          btGSTJournals,
                          btStockJournals,
                          btOpeningBalances,
                          btYearEndAdjustments,
                          btStockBalances];

{ TClientItem }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TClientItem.Create;
begin
  fClientObj := TClientObj.Create;
  fDone := false;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TClientItem.Destroy;
begin
  FreeAndNil(fClientObj);
  inherited;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientItem.Open;
begin
  fClientObj.Open(fFileName, FILEEXTN);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientItem.Save;
begin
  fClientObj.Save;
end;

{ TClientList }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientList.Get(Index: Integer): TClientItem;
begin
  Result := inherited Get(Index);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientList.GetClientFromCodeandLRN(ClientCode : string ; LRN : Integer) : TClientItem;
var
  ClientIndex : integer;
begin
  Result := nil;
  for ClientIndex := 0 to Count-1 do
  begin
    if (Self.Items[ClientIndex].ClientObj.clFields.clCode = ClientCode) and
       (Self.Items[ClientIndex].ClientObj.clFields.clSystem_LRN = LRN) and
       (Self.Items[ClientIndex].Done = False) then
    begin
      Result := Self.Items[ClientIndex];
      Exit;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientList.GetClientFromOldClientCode(OldClientCode : string) : TClientItem;
var
  ClientIndex : integer;
begin
  Result := nil;
  for ClientIndex := 0 to Count-1 do
  begin
    if Self.Items[ClientIndex].OldClientCode = OldClientCode then
    begin
      Result := Self.Items[ClientIndex];
      Exit;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientList.Put(Index: Integer; Item: TClientItem);
begin
  inherited Put(Index, Item);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TClientList.Destroy;
var
  ItemIndex : integer;
begin
  for ItemIndex := Count - 1 downto 0 do
  begin
    Items[ItemIndex].Free;
    Self.Remove(Items[ItemIndex]);
  end;

  inherited;
end;

{ TMuddler }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.SetProgressUpdate(ProgressPercent : single);
begin
  if assigned(fOnProgressUpdate) then
    fOnProgressUpdate(ProgressPercent);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.AddAccountOldNew(OldAccNumber, NewAccNumber, NewAccName : string);
var
  ArrIndex : integer;
begin
  SetLength(fArrAccOldNew,Length(fArrAccOldNew)+1);
  ArrIndex := Length(fArrAccOldNew)-1;

  fArrAccOldNew[ArrIndex].OldAccNumber := OldAccNumber;
  fArrAccOldNew[ArrIndex].NewAccNumber := NewAccNumber;
  fArrAccOldNew[ArrIndex].NewAccName   := NewAccName;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.FindOldAccount(OldAccNumber: string; var NewAccNumber, NewAccName: string): boolean;
var
  ArrIndex : integer;
begin
  Result := false;

  for ArrIndex := 0 to Length(fArrAccOldNew)-1 do
  begin
    if fArrAccOldNew[ArrIndex].OldAccNumber = OldAccNumber then
    begin
      NewAccNumber := fArrAccOldNew[ArrIndex].NewAccNumber;
      NewAccName   := fArrAccOldNew[ArrIndex].NewAccName;

      Result := True;
      Exit;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.AddFileOldNew(OldName, NewName : string);
var
  ArrIndex : integer;
begin
  SetLength(fArrFileOldNew,Length(fArrFileOldNew)+1);
  ArrIndex := Length(fArrFileOldNew)-1;

  fArrFileOldNew[ArrIndex].OldName := OldName;
  fArrFileOldNew[ArrIndex].NewName := NewName;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.AddBillingInfo(ClientName      : string;
                                  AccountNumber   : string;
                                  AccountName     : string;
                                  NumOfTrans      : integer;
                                  CurrentBalance  : Currency;
                                  LastTranDate    : TDateTime;
                                  InstitutionName : String);
var
  ArrIndex : integer;
begin
  SetLength(fArrBillingInfo,Length(fArrBillingInfo)+1);
  ArrIndex := Length(fArrBillingInfo)-1;

  fArrBillingInfo[ArrIndex].ClientName      := ClientName;
  fArrBillingInfo[ArrIndex].AccountNumber   := AccountNumber;
  fArrBillingInfo[ArrIndex].AccountName     := AccountName;
  fArrBillingInfo[ArrIndex].NumOfTrans      := NumOfTrans;
  fArrBillingInfo[ArrIndex].CurrentBalance  := CurrentBalance;
  fArrBillingInfo[ArrIndex].LastTranDate    := LastTranDate;
  fArrBillingInfo[ArrIndex].InstitutionName := InstitutionName;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.FileInCopyList(FileName : string) : Boolean;
var
  FileExt : string;
  Value : integer;

  //- - - - - - - - - - - - - - - - - - - - - -
  function FileExtUsed : Boolean;
  var
    ExtIndex : integer;
  begin
    Result := false;
    for ExtIndex := Low(FILE_EXT_LIST) to High(FILE_EXT_LIST) do
    begin
      if Uppercase(FILE_EXT_LIST[ExtIndex]) = uppercase(FileExt) then
      begin
        Result := true;
        Exit;
      end;
    end;
  end;
begin
  Result := false;

  FileExt := GetFileExt(FileName);

  if FileExtUsed then
    Result := true;

  if (Length(FileExt) = 3) and
    (trystrtoint(FileExt, Value)) then
    Result := true;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.GetFileExt(FileName : string) : string;
var
  StrIndex : integer;
begin
  Result := '';

  if pos('.',FileName) = 0 then
    Exit;

  for StrIndex := Length(FileName) downto 1 do
  begin
    if FileName[StrIndex] = '.' then
    begin
      Result := RightStr(FileName, Length(FileName) - StrIndex);
      Exit;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.CreateWorkCsvFile;
const
  WORK_FILE_HEADER = '"Client","Account No","Account Name","File Code","Cost Code",' +
                     '"Charges","No Of Transactions","New Account","Load Charge Billed"' +
                     ',"Off-site charge included","Is Active","Current Balance",'+
                     '"Last Transaction Date","Currency","Institution Name"';
  WORK_FILE_DATA = '"%s","%s","%s","","",%s,%s,No,No,No,Yes,%s,%s/%s/%s,"%s","%s"';
var
  WorkFile  : TextFile;
  FirstDate : TDateTime;
  FileIndex : integer;
  ArrIndex  : integer;
  LoopLength : integer;

  //- - - - - - - - - - - - - - - - - - - - - - - -
  function GetFirstDate : TDateTime;
  var
    ArrIndex : integer;
    Year     : word;
    Month    : word;
    Day      : word;
  begin
    Result := encodedate(2000,1,1);
    for ArrIndex := 0 to length(fArrBillingInfo) - 1 do
    begin
      DecodeDate(fArrBillingInfo[ArrIndex].LastTranDate, Year, Month, Day);
      if (Year > Yearof(Result)) then
        Result := fArrBillingInfo[ArrIndex].LastTranDate
      else if (Year = Yearof(Result)) and
              (Month > Monthof(Result)) then
        Result := fArrBillingInfo[ArrIndex].LastTranDate;
    end;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - -
  function GetCharge : string;
  begin
    Result := inttostr(random(13)+1) + '.' +
              inttostr(random(9)) +
              inttostr(random(9));
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - -
  function LastMonth(InDate : TDateTime) : TDateTime;
  var
    Year     : word;
    Month    : word;
    Day      : word;
  begin
    DecodeDate(InDate, Year, Month, Day);
    Dec(Month);
    if Month = 0 then
    begin
      Month := 12;
      Dec(Year);
    end;
    Result := encodedate(Year,Month,1);
  end;
begin
  if length(fArrBillingInfo) < 4 then
    Exit;

  FirstDate := GetFirstDate;

  for FileIndex := 1 to 3 do
  begin
    AssignFile(WorkFile, DataDir + 'Work\' + FormatDateTime('mmmyyyy', FirstDate) + rfFileExtn[rfCSV]);
    ReWrite(WorkFile);

    Try
      WriteLn(WorkFile, WORK_FILE_HEADER);

      LoopLength := Length(fArrBillingInfo)-1;

      if LoopLength > 50 then
        LoopLength := 50;

      for ArrIndex := 0 to LoopLength do
      begin
        WriteLn(WorkFile, Format(WORK_FILE_DATA,[fArrBillingInfo[ArrIndex].ClientName,
                                                 fArrBillingInfo[ArrIndex].AccountNumber,
                                                 fArrBillingInfo[ArrIndex].AccountName,
                                                 GetCharge,
                                                 inttostr(round(fArrBillingInfo[ArrIndex].NumOfTrans/FileIndex)),
                                                 currtostr(fArrBillingInfo[ArrIndex].CurrentBalance/FileIndex),
                                                 inttostr(Random(28)),
                                                 inttostr(Monthof(FirstDate)),
                                                 inttostr(Yearof(FirstDate)),
                                                 'N$',
                                                 fArrBillingInfo[ArrIndex].InstitutionName]));
      end;
    Finally
      CloseFile(WorkFile);
    End;

    FirstDate := LastMonth(FirstDate);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.AddSuperVisUser;
var
  pu : pUser_Rec;
begin
  pu := New_User_Rec;

  if not Assigned(pu) then
    exit;

  Inc(AdminSystem.fdFields.fdUser_LRN_Counter);
  pu.usCode           := 'SUPERVIS';
  pu.usName           := 'Supervisor';
  pu.usPassword       := 'INSECURE';
  pu.usEMail_Address  := '';
  pu.usDirect_Dial    := '';
  pu.usShow_Printer_Choice := false;
  pu.usSuppress_HF    := 0;
  pu.usShow_Practice_Logo := false;
  pu.usSystem_Access  := True;
  pu.usIs_Remote_User := False;
  pu.usMASTER_Access  := true;
  pu.usLogged_In      := false;
  pu.usLRN            := AdminSystem.fdFields.fdUser_LRN_Counter;

  AdminSystem.fdSystem_User_List.Insert( pu );
  AdminSystem.fdSystem_File_Access_List.Delete_User( pu^.usLRN );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.CopyFolder(SourceDirectory, DestinationDirectory: string; FileCount : integer; var FileIndex : integer);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
begin
  SysUtils.ForceDirectories(DestinationDirectory);

  FindResult := FindFirst(SourceDirectory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          CopyFolder(SourceDirectory + '\' + SearchRec.Name,
                     DestinationDirectory + '\' + SearchRec.Name,
                     FileCount, FileIndex);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        if FileInCopyList(SearchRec.Name) then
        begin
          fCopy.CopyFile(SourceDirectory + '\' + SearchRec.Name,
                         DestinationDirectory + '\' + SearchRec.Name);

          inc(FileIndex);
          SetProgressUpdate(((FileIndex/FileCount) * 15) + 10);
        end;
      end;
      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.CountItemsInFolder(SourceDirectory : string; var FileCount : integer);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
begin
  FindResult := FindFirst(SourceDirectory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          CountItemsInFolder(SourceDirectory + '\' + SearchRec.Name, FileCount);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
        if FileInCopyList(SearchRec.Name) then
          inc(FileCount);

      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.ClearFilesInFolder(Directory : string; var FileCount : integer; var FileIndex : integer);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
begin
  FindResult := FindFirst(Directory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          ClearFilesInFolder(Directory + '\' + SearchRec.Name, FileCount, FileIndex);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        DeleteFile(PChar(Directory + '\' + SearchRec.Name));
        inc(FileIndex);
        SetProgressUpdate(((FileIndex/FileCount) * 10));
      end;

      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.CountFilesToClearInFolder(Directory : string; var FileCount : integer);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
begin
  FindResult := FindFirst(Directory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          CountFilesToClearInFolder(Directory + '\' + SearchRec.Name, FileCount);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
        inc(FileCount);

      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.IsClientFileNameUsed(FileName: string): Boolean;
var
  ClientIndex : integer;
begin
  Result := False;
  for ClientIndex := 0 to fClientList.Count - 1 do
  begin
    if fClientList[ClientIndex].ClientObj.clFields.clCode = FileName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.MuddleNumericData(Instring : string) : string;
var
  StrIndex : integer;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  function MuddleDigit(InNumber : integer) : integer;
  const
    NumSet : Array[0..9] of integer = (6,2,4,3,1,0,9,2,8,7);
  var
    ReplaceIndex : integer;
  begin
    Result := NumSet[InNumber];
  end;
begin
  Result := '';
  for StrIndex := 1 to Length(Instring) do
  begin
    if (Instring[StrIndex] in ['0'..'9']) then
    begin
      Result := Result + inttostr(MuddleDigit(strtoint(Instring[StrIndex])));
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMuddler.GetFirstAlphaCharFromAcc(AccNumber : String) : String;
var
  Max4Length : integer;
  Index : integer;
begin
  Result := '';
  Max4Length := length(AccNumber);
  if Max4Length > 4 then
    Max4Length := 4;

  for Index := 1 to Max4Length do
  begin
    if not (AccNumber[Index] in ['0'..'9']) then
      Result := Result + AccNumber[Index]
    else
      Exit;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddlePracticeSys(var PracticeFields : tPractice_Details_Rec;
                                     Name         : string;
                                     Phone        : string;
                                     Email        : string;
                                     WebSite      : string;
                                     BankLinkCode : string);
begin
  PracticeFields.fdPractice_Name_for_Reports := Name;
  PracticeFields.fdPractice_Phone            := Phone;
  PracticeFields.fdPractice_EMail_Address    := Email;
  PracticeFields.fdPractice_Web_Site         := WebSite;
  PracticeFields.fdBankLink_Code             := BankLinkCode;
  PracticeFields.fdPractice_Logo_Filename    := '';
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleUserSys(UserFields   : pUser_Rec;
                                 PracticeName : string;
                                 var SupervisExists : boolean);
var
  Code     : string;
  Name     : string;
  Password : string;
begin
  if Uppercase(UserFields.usCode) = 'SUPERVIS' then
  begin
    Code     := UserFields.usCode;
    Name     := UserFields.usName;
    Password := 'INSECURE';
    SupervisExists := True;
  end
  else
  begin
    Name := fDataGenerator.GeneratePersonName(1,2);
    Code := fDataGenerator.GetUserNameFromPersonName(Name);
    Password := '1';
  end;

  RenameFile(fDestinationDirectory + '\' + UserFields.usCode + '.ini' ,
             fDestinationDirectory + '\' + Code + '.ini' );

  UserFields.usCode          := Code;
  UserFields.usName          := Name;
  UserFields.usPassword      := Password;
  UserFields.usEMail_Address := fDataGenerator.GenerateEmail(Code, PracticeName, 'co', 'nz');
  UserFields.usDirect_Dial   := fDataGenerator.GeneratePhoneNumber;
  UserFields.usLogged_In     := False;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleClientSys(ClientField : pClient_File_Rec;
                                   Code        : string;
                                   Name        : string);
begin
  ClientField.cfFile_Code         := Code;
  ClientField.cfFile_Name         := Name;
  ClientField.cfFile_Password     := '';
  ClientField.cfNext_ToDo_Desc    := '';
  ClientField.cfBank_Accounts     := '';
  ClientField.cfBulk_Extract_Code := '';
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleClientBk5(const ClientObj : TClientObj;
                                   PracticeName    : string;
                                   PracticeEmail   : string;
                                   PracticeWebSite : string;
                                   PracticePhone   : string;
                                   PracticeCode    : string;
                                   BankLinkCode    : string;
                                   Code            : string;
                                   Name            : string;
                                   InSystem        : boolean);
var
  ContactName : string;
  ContactUser : string;

  StaffName  : string;
  StaffUser  : string;
  StaffEmail : string;

  CustName : string;
  CustUser : string;

  PayeeIndex : integer;
  PayeeList  : TstringList;
  JobIndex : integer;

  AccountIndex : integer;
begin
  ContactName  := fDataGenerator.GeneratePersonName(1,2);
  ContactUser  := fDataGenerator.GetUserNameFromPersonName(ContactName);

  StaffName  := fDataGenerator.GeneratePersonName(1,2);
  StaffUser  := fDataGenerator.GetUserNameFromPersonName(StaffUser);
  StaffEmail := fDataGenerator.GenerateEmail(StaffUser,Name,'co','nz');

  CustName  := fDataGenerator.GeneratePersonName(1,2);
  CustUser  := fDataGenerator.GetUserNameFromPersonName(CustName);

  ClientObj.clFields.clCode := Code;
  ClientObj.clFields.clName := Name;
  ClientObj.clFields.clAddress_L1 := fDataGenerator.GenerateStreetAddress;
  ClientObj.clFields.clAddress_L2 := 'BankLink City';
  ClientObj.clFields.clAddress_L3 := fDataGenerator.GenerateCode(4);
  ClientObj.clFields.clContact_Name := ContactName;
  ClientObj.clFields.clPhone_No := fDataGenerator.GeneratePhoneNumber;
  ClientObj.clFields.clFax_No := fDataGenerator.GeneratePhoneNumber;
  ClientObj.clFields.clFile_Password := '';
  ClientObj.clFields.clPractice_Name := PracticeName;
  ClientObj.clFields.clStaff_Member_Name := StaffName;
  ClientObj.clFields.clPractice_EMail_Address := PracticeEmail;
  ClientObj.clFields.clStaff_Member_EMail_Address := StaffEmail;
  ClientObj.clFields.clClient_EMail_Address := fDataGenerator.GenerateEmail(ContactUser,Name,'co','nz');
  ClientObj.clFields.clFile_Name := Code;
  ClientObj.clFields.clBankLink_Connect_Password := '';
  ClientObj.clFields.clGST_Number := 'GST' + fDataGenerator.GenerateCode(5);
  ClientObj.clFields.clBankLink_Code := BankLinkCode;
  ClientObj.clFields.clECoding_Default_Password := '';
  ClientObj.clFields.clPractice_Web_Site := PracticeWebSite;
  ClientObj.clFields.clPractice_Phone := PracticePhone;
  ClientObj.clFields.clPractice_Logo := '';
  ClientObj.clFields.clWeb_Site_Login_URL := fDataGenerator.GenerateWebSite(Name,'co','nz');;
  ClientObj.clFields.clStaff_Member_Direct_Dial := fDataGenerator.GeneratePhoneNumber;
  ClientObj.clFields.clCustom_Contact_Name := CustName;
  ClientObj.clFields.clCustom_Contact_EMail_Address := fDataGenerator.GenerateEmail(CustUser,Name,'co','nz');
  ClientObj.clFields.clCustom_Contact_Phone := fDataGenerator.GeneratePhoneNumber;
  ClientObj.clFields.clClient_CC_EMail_Address := StaffEmail;
  ClientObj.clFields.clMobile_No := fDataGenerator.GeneratePhoneNumber;
  ClientObj.clFields.clPractice_Code := PracticeCode;

  // Go through Cache for each System Client
  if (InSystem) and
    (fClientDetailsCache.Load(ClientObj.clFields.clSystem_LRN)) then
  begin
    fClientDetailsCache.Code          := Code;
    fClientDetailsCache.Name          := Name;
    fClientDetailsCache.Address_L1    := ClientObj.clFields.clAddress_L1;
    fClientDetailsCache.Address_L2    := ClientObj.clFields.clAddress_L2;
    fClientDetailsCache.Address_L3    := ClientObj.clFields.clAddress_L3;
    fClientDetailsCache.Contact_Name  := ContactName;
    fClientDetailsCache.Phone_No      := ClientObj.clFields.clPhone_No;
    fClientDetailsCache.Fax_No        := ClientObj.clFields.clFax_No;
    fClientDetailsCache.Email_Address := ClientObj.clFields.clClient_EMail_Address;

    fClientDetailsCache.Save(ClientObj.clFields.clSystem_LRN);
  end;

  // Goes Through Payee List, Each Name must be unique and the names must be sorted
  PayeeList := TstringList.Create;
  try
    for PayeeIndex := 0 to ClientObj.clPayee_List.ItemCount-1 do
      PayeeList.Add(fDataGenerator.GeneratePersonName(2,3));

    PayeeList.Sort;

    for PayeeIndex := 0 to ClientObj.clPayee_List.ItemCount-1 do
      MuddlePayeeBk5(ClientObj.clPayee_List.Payee_At(PayeeIndex), PayeeList.strings[PayeeIndex]);

  finally
    FreeAndNil(PayeeList);
  end;

  // jobs
  for JobIndex := 0 to ClientObj.clJobs.ItemCount - 1 do
  begin
    MuddleJobBk5(ClientObj.clJobs.Job_At(JobIndex));
  end;

  //Accounts
  for AccountIndex := 0 to ClientObj.clBank_Account_List.ItemCount-1 do
  begin
    MuddleAccountBk5(ClientObj.clBank_Account_List.Bank_Account_At(AccountIndex), Name);
  end;
  ClientObj.clBank_Account_List.Sort;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddlePayeeBk5(const PayeeObj : TPayee;
                                  Name : string);
begin
  PayeeObj.pdFields.pdName := Name;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleJobBk5(JobObj : pJob_Heading_Rec);
begin
  JobObj.jhCode    := 'Job' + fDataGenerator.GenerateCode(5);
  JobObj.jhHeading := 'Job(' + fDataGenerator.GeneratePersonName(1,1) + ')';
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleAccountBk5(AccountObj : TBank_Account;
                                    ClientName : String);
var
  TransIndex    : integer;
  AccountField  : pSystem_Bank_Account_Rec;
  AccountNumber : string;
  AccountName   : string;
  AccountIndex  : integer;
  Day   : integer;
  Month : integer;
  Year  : integer;
begin
  if not (AccountObj.baFields.baAccount_Type in ACC_TYPE_NOT_MUDDLED) then
  begin
    AccountNumber := '1111' + fDataGenerator.GenerateCode(6);
    AccountName   := fDataGenerator.GeneratePersonName(1,2);

    AccountNumber := GetFirstAlphaCharFromAcc(AccountObj.baFields.baBank_Account_Number) + AccountNumber;

    AddAccountOldNew(AccountObj.baFields.baBank_Account_Number,
                     AccountNumber,
                     AccountName);

    AccountObj.baFields.baBank_Account_Number := AccountNumber;
    AccountObj.baFields.baBank_Account_Name   := AccountName;



    if AccountObj.baTransaction_List.LastPresDate > 0 then
    begin
      StDateToDMY(AccountObj.baTransaction_List.LastPresDate, Day, Month, Year);
      AddBillingInfo(ClientName,
                     AccountNumber,
                     AccountName,
                     Random(49),
                     AccountObj.baFields.baCurrent_Balance,
                     EncodeDate(Year, Month, Day),
                     fDataGenerator.GenerateCompanyName('Bank'));
    end;
  end
  else
    AccountObj.baFields.baBank_Account_Name := fDataGenerator.GeneratePersonName(1,2);

  AccountObj.baFields.baBank_Account_Password := '';

  for TransIndex := 0 to AccountObj.baTransaction_List.ItemCount - 1 do
    MuddleTransactionBk5(AccountObj.baTransaction_List.Transaction_At(TransIndex));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleTransactionBk5(TransField : pTransaction_Rec);
begin
  TransField.txReference            := MuddleNumericData(TransField.txReference);
  TransField.txParticulars          := MuddleNumericData(TransField.txParticulars);
  TransField.txAnalysis             := MuddleNumericData(TransField.txAnalysis);
  TransField.txOrigBB               := MuddleNumericData(TransField.txOrigBB);
  TransField.txOther_Party          := MuddleNumericData(TransField.txOther_Party);
  TransField.txOld_Narration        := MuddleNumericData(TransField.txOld_Narration);
  TransField.txOriginal_Reference   := MuddleNumericData(TransField.txOriginal_Reference);
  TransField.txNotes                := MuddleNumericData(TransField.txNotes);
  TransField.txECoding_Import_Notes := MuddleNumericData(TransField.txECoding_Import_Notes);
  TransField.txGL_Narration         := MuddleNumericData(TransField.txGL_Narration);
  TransField.txStatement_Details    := MuddleNumericData(TransField.txStatement_Details);
  TransField.txDocument_Title       := MuddleNumericData(TransField.txDocument_Title);
  TransField.txSpare_string         := MuddleNumericData(TransField.txSpare_string);
  TransField.txTemp_Prov_Entered_By := MuddleNumericData(TransField.txTemp_Prov_Entered_By);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleMemorizationSys(MemField : pSystem_Memorisation_List_Rec);
var
  Memorisations_List : TMemorisations_List;
  Memorisation : TMemorisation;
  MemIndex : integer;
begin
  Memorisations_List := TMemorisations_List(MemField.smMemorisations);

  for MemIndex := 0 to Memorisations_List.ItemCount-1 do
  begin
    Memorisation := Memorisations_List.Memorisation_At(MemIndex);

    Memorisation.mdFields.mdReference         := MuddleNumericData(Memorisation.mdFields.mdReference);
    Memorisation.mdFields.mdParticulars       := MuddleNumericData(Memorisation.mdFields.mdParticulars);
    Memorisation.mdFields.mdAnalysis          := MuddleNumericData(Memorisation.mdFields.mdAnalysis);
    Memorisation.mdFields.mdOther_Party       := MuddleNumericData(Memorisation.mdFields.mdOther_Party);
    Memorisation.mdFields.mdStatement_Details := MuddleNumericData(Memorisation.mdFields.mdStatement_Details);
    Memorisation.mdFields.mdNotes             := MuddleNumericData(Memorisation.mdFields.mdNotes);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleTXNFile(FullFileName : string);
var
  InArchiveFile  : File of tArchived_Transaction;
  OutArchiveFile : File of tArchived_Transaction;
  Trans_Record   : tArchived_Transaction;
  FilePath       : string;
  FileName       : string;
begin
  FilePath := sysutils.ExtractFilePath(FullFileName);
  FileName := sysutils.ExtractFileName(FullFileName);
  AddFileOldNew(FullFileName, FullFileName + '$$$');

  Assignfile(InArchiveFile, FullFileName);
  Reset(InArchiveFile);
  try
    Assignfile(OutArchiveFile, FullFileName + '$$$');
    Rewrite(OutArchiveFile);
    try
      while not Eof(InArchiveFile) do
      begin
        Read( InArchiveFile, Trans_Record );

        Trans_Record.aReference         := MuddleNumericData(Trans_Record.aReference);
        Trans_Record.aParticulars       := MuddleNumericData(Trans_Record.aParticulars);
        Trans_Record.aAnalysis          := MuddleNumericData(Trans_Record.aAnalysis);
        Trans_Record.aOrigBB            := MuddleNumericData(Trans_Record.aOrigBB);
        Trans_Record.aOther_Party       := MuddleNumericData(Trans_Record.aOther_Party);
        Trans_Record.aNarration         := MuddleNumericData(Trans_Record.aNarration);
        Trans_Record.aStatement_Details := MuddleNumericData(Trans_Record.aStatement_Details);

        Write( OutArchiveFile, Trans_Record );
      end;

    finally
      CloseFile(OutArchiveFile);
    end;
  finally
    CloseFile(InArchiveFile);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.SearchForTXNFiles(Directory : string);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
  FileIndex  : integer;
begin
  SetLength(fArrFileOldNew, 0);

  FindResult := FindFirst(Directory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          SearchForTXNFiles(Directory + '\' + SearchRec.Name);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        if RightStr(SearchRec.Name,3) = 'TXN' then
          MuddleTXNFile(Directory + '\' + SearchRec.Name);
      end;

      FindResult := FindNext(SearchRec);
    end;

    for FileIndex := 0 to Length(fArrFileOldNew) - 1 do
    begin
      DeleteFile(PChar(fArrFileOldNew[FileIndex].OldName));
      RenameFile(PChar(fArrFileOldNew[FileIndex].NewName),
                 PChar(fArrFileOldNew[FileIndex].OldName));
    end;

  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleDiskImageFile(FullFileName : string;
                                       Code         : string);
var
  DiskImage      : TUpdateDiskReader;
  DiskAccount    : TDisk_Bank_Account;
  DiskTxn        : pDisk_Transaction_Rec;
  dTNo           : integer;   //disk transaction no
  BankAccount    : TBank_Account;
  NewAccNumber   : string;
  NewAccName     : string;
  AccountIndex   : integer;
  TransIndex     : integer;
  ClientItem     : TClientItem;
  FilePath       : string;
  FileName       : string;
begin
  DiskImage := TUpdateDiskReader.Create;
  try
    //load update file
    try
      DiskImage.LoadFromUpdateFile( FullFileName);
      DiskImage.Validate;
    except
      On E : Exception do
      begin
        Exit;
      end;
    end;

    FilePath := sysutils.ExtractFilePath(FullFileName);
    FileName := sysutils.ExtractFileName(FullFileName);
    DeleteFile(PChar(FullFileName));

    // Try Find Client Code
    ClientItem := fClientList.GetClientFromOldClientCode(DiskImage.dhFields.dhClient_Code);
    if Assigned(ClientItem) then
    begin
      DiskImage.dhFields.dhClient_Code := ClientItem.ClientObj.clFields.clCode;
      DiskImage.dhFields.dhClient_Name := ClientItem.ClientObj.clFields.clName;
    end
    else
    begin
      DiskImage.dhFields.dhClient_Code := 'Cl' + fDataGenerator.GenerateCode(6);
      DiskImage.dhFields.dhClient_Name := fDataGenerator.GenerateCompanyName;
    end;

    AddFileOldNew(FilePath + 'BK_' + DiskImage.dhFields.dhClient_Code + leftstr(FileName,4),
                  FilePath + '$$$BK_' + DiskImage.dhFields.dhClient_Code + leftstr(FileName,4));

    for AccountIndex := 0 to DiskImage.dhAccount_List.ItemCount-1 do
    begin
      DiskAccount := DiskImage.dhAccount_List.Disk_Bank_Account_At(AccountIndex);

      // Try Find Account Number in Array of Muddled Accounts
      if FindOldAccount(DiskAccount.dbFields.dbAccount_Number, NewAccNumber, NewAccName) then
      begin
        DiskAccount.dbFields.dbAccount_Number := NewAccNumber;
        DiskAccount.dbFields.dbAccount_Name   := NewAccName;
      end
      else
      begin
        DiskAccount.dbFields.dbAccount_Number := '1111' + fDataGenerator.GenerateCode(8);;
        DiskAccount.dbFields.dbAccount_Name   := fDataGenerator.GeneratePersonName(1,2);
      end;

      // Muddle Transactions for each account
      for TransIndex := 0 to DiskAccount.dbTransaction_List.ItemCount-1 do
      begin
        DiskTxn := DiskAccount.dbTransaction_List.Disk_Transaction_At(TransIndex);

        DiskTxn.dtReference           := MuddleNumericData(DiskTxn.dtReference);
        DiskTxn.dtParticulars_NZ_Only := MuddleNumericData(DiskTxn.dtParticulars_NZ_Only);
        DiskTxn.dtOther_Party_NZ_Only := MuddleNumericData(DiskTxn.dtOther_Party_NZ_Only);
        DiskTxn.dtOrig_BB             := MuddleNumericData(DiskTxn.dtOrig_BB);
        DiskTxn.dtNarration           := MuddleNumericData(DiskTxn.dtNarration);
      end;
    end;

    DiskImage.SaveToFile(FilePath + '$$$BK_' + DiskImage.dhFields.dhClient_Code + leftstr(FileName,4),
                         nil);

  finally
    FreeAndNil(DiskImage);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.SearchForDiskImageFiles(Directory : string);
var
  SearchRec  : TSearchRec;
  FindResult : integer;
  FileIndex  : integer;
begin
  SetLength(fArrFileOldNew, 0);

  FindResult := FindFirst(Directory + '\*.*', (faAnyfile and faDirectory) , SearchRec);
  try
    while FindResult = 0 do
    begin
      if ((SearchRec.Attr and faDirectory) <> 0) then
      begin
        if not (SearchRec.Name = '.') and
           not (SearchRec.Name = '..') then
          SearchForDiskImageFiles(Directory + '\' + SearchRec.Name);
      end
      else if ((SearchRec.Attr and faAnyfile) <> 0) then
      begin
        if (length(SearchRec.Name) > 7) and
           (LeftStr(SearchRec.Name,3) = 'BK_') then
          MuddleDiskImageFile(Directory + '\' + SearchRec.Name,
                              MidStr(SearchRec.Name, 4, length(SearchRec.Name)-7));
      end;

      FindResult := FindNext(SearchRec);
    end;

    for FileIndex := 0 to Length(fArrFileOldNew) - 1 do
    begin
      RenameFile(PChar(fArrFileOldNew[FileIndex].NewName),
                 PChar(fArrFileOldNew[FileIndex].OldName));
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function TMuddler.CopyPractice : Boolean;
var
  FileCount : integer;
  FileIndex : integer;
begin
  if SysUtils.DirectoryExists(fDestinationDirectory) then
  begin
    FileCount := 0;
    FileIndex := 0;

    CountFilesToClearInFolder(fDestinationDirectory, FileCount);
    ClearFilesInFolder(fDestinationDirectory, FileCount, FileIndex);
  end;

  FileCount := 0;
  FileIndex := 0;

  CountItemsInFolder(fSourceDirectory, FileCount);

  CopyFolder(fSourceDirectory, fDestinationDirectory, FileCount, FileIndex);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.Open;
var
  SearchRec  : TSearchRec;
  FindResult : integer;
  ClientCode : string;
  NewClient  : TClientItem;
  FileCount  : integer;
  FileIndex  : integer;
begin
  // Upgrade DB
  LoadAdminSystem(false, 'StartUp');

  Progress.StatusSilent := True;
  Progress.OnUpdateMessageBar := nil;

  UpgradeAdminToLatestVersion;
  UpgradeExchangeRatesToLatestVersion;

  SetProgressUpdate(35);

  FileCount := 0;
  FindResult := FindFirst(DataDir + '*' + FILEEXTN, faAnyfile, SearchRec);
  try
    // Count the Client Files
    while FindResult = 0 do
    begin
      inc(FileCount);
      FindResult := FindNext(SearchRec);
    end;

    // Open All Client Files
    FileIndex := 0;
    FindResult := FindFirst(DataDir + '*' + FILEEXTN, faAnyfile, SearchRec);

    while FindResult = 0 do
    begin
      NewClient := TClientItem.Create;
      NewClient.FileName := LeftStr(SearchRec.Name,Pos('.',SearchRec.Name)-1);
      NewClient.Open;
      fClientList.Add(NewClient);
      inc(FileIndex);

      SetProgressUpdate(35 + ((FileIndex/FileCount) * 15));
      FindResult := FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.Muddle;
var
  PracticeName       : string;
  PracticePersonName : string;
  PracticeUserName   : string;
  PracticeEmail      : string;
  PracticeWebSite    : string;
  PracticePhone      : string;
  PracticeCode       : string;
  BankLinkCode       : string;

  UserIndex    : integer;
  UserDBItem   : pUser_Rec;

  ClientIndex    : integer;
  ClientFileBase : TClientItem;
  ClientObj      : TClientObj;
  ClientDBItem   : pClient_File_Rec;
  ClientCode     : string;
  ClientName     : string;

  AccountIndex   : integer;
  SysBankAccItem : pSystem_Bank_Account_Rec;
  AccMapIndex    : integer;
  NewAccNumber   : String;
  NewAccName     : String;

  MemorizationIndex : integer;
  SuperVisExists : boolean;
begin
  PracticeName       := fDataGenerator.GenerateCompanyName('Accountants');
  PracticePersonName := fDataGenerator.GeneratePersonName(1,2);
  PracticeUserName   := fDataGenerator.GetUserNameFromPersonName(PracticePersonName);
  PracticeEmail      := fDataGenerator.GenerateEmail(PracticeUserName,PracticeName,'co','nz');
  PracticeWebSite    := fDataGenerator.GenerateWebSite(PracticeName,'co','nz');
  PracticePhone      := fDataGenerator.GeneratePhoneNumber;
  PracticeCode       := 'Prac0001';
  BankLinkCode       := UpperCase('Bank0001');

  MuddlePracticeSys(AdminSystem.fdFields,
                    PracticeName,
                    PracticePhone,
                    PracticeEmail,
                    PracticeWebSite,
                    BankLinkCode);

  //  Users in Database
  SuperVisExists := false;
  for UserIndex := 0 to AdminSystem.fdSystem_User_List.ItemCount-1 do
  begin
    UserDBItem := AdminSystem.fdSystem_User_List.User_At(UserIndex);

    MuddleUserSys(AdminSystem.fdSystem_User_List.User_At(UserIndex),
                  PracticeName,
                  SuperVisExists);
  end;

  // Add Supervisor user and password if it does not exist already
  if not SuperVisExists then
    AddSuperVisUser;

  // Clients in Database
  for ClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
  begin
    ClientDBItem := AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex);
    // Look for Client File with the Same Code
    ClientFileBase := fClientList.GetClientFromCodeandLRN(ClientDBItem.cfFile_Code,
                                                          ClientDBItem.cfLRN);

    ClientCode := 'Cl' + fDataGenerator.GenerateCode(6);
    ClientName := fDataGenerator.GenerateCompanyName;

    MuddleClientSys(ClientDBItem,
                    ClientCode,
                    ClientName);

    if Assigned(ClientFileBase) then
    begin
      ClientObj := ClientFileBase.ClientObj;

      MuddleClientBk5(ClientObj,
                      PracticeName,
                      PracticeEmail,
                      PracticeWebSite,
                      PracticePhone,
                      PracticeCode,
                      BankLinkCode,
                      ClientCode,
                      ClientName,
                      True);

      ClientFileBase.Done := True;
    end;
  end;

  // Go through any Clients that could not be matched above
  for ClientIndex := 0 to fClientList.Count - 1 do
  begin
    if fClientList[ClientIndex].fDone = false then
    begin
      PracticeName       := fDataGenerator.GenerateCompanyName('Accountants');
      PracticePersonName := fDataGenerator.GeneratePersonName(1,2);
      PracticeUserName   := fDataGenerator.GetUserNameFromPersonName(PracticePersonName);
      PracticeEmail      := fDataGenerator.GenerateEmail(PracticeUserName,PracticeName,'co','nz');
      PracticeWebSite    := fDataGenerator.GenerateWebSite(PracticeName,'co','nz');

      MuddleClientBk5(fClientList[ClientIndex].ClientObj,
                      PracticeName,
                      PracticeEmail,
                      PracticeWebSite,
                      fDataGenerator.GeneratePhoneNumber,
                      'Prac' + fDataGenerator.GenerateCode(4),
                      'Bank' + fDataGenerator.GenerateCode(4),
                      'Cl' + fDataGenerator.GenerateCode(6),
                      fDataGenerator.GenerateCompanyName,
                      False);
    end;
  end;

  // System Bank Accounts
  for AccountIndex := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount-1 do
  begin
    SysBankAccItem := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(AccountIndex);

    if not (SysBankAccItem.sbAccount_Type in ACC_TYPE_NOT_MUDDLED) then
    begin

      if not FindOldAccount(SysBankAccItem.sbAccount_Number,
                            NewAccNumber,
                            NewAccName) then
      begin
        NewAccNumber := '1111' + fDataGenerator.GenerateCode(6);
        NewAccName   := fDataGenerator.GeneratePersonName(1,2);

        NewAccNumber := GetFirstAlphaCharFromAcc(SysBankAccItem.sbAccount_Number) + NewAccNumber;
      end;

      SysBankAccItem.sbAccount_Number := NewAccNumber;
      SysBankAccItem.sbAccount_Name   := NewAccName;
    end
    else
      SysBankAccItem.sbAccount_Name := fDataGenerator.GeneratePersonName(1,2);

    SysBankAccItem.sbAccount_Password := '';
  end;

  // Admin Memorizations
  for MemorizationIndex := 0 to AdminSystem.fSystem_Memorisation_List.ItemCount - 1 do
  begin
    MuddleMemorizationSys(AdminSystem.fSystem_Memorisation_List.System_Memorisation_At(MemorizationIndex));
  end;

  //Muddle all TXN files
  SearchForTXNFiles(fDestinationDirectory);

  // Billing csv files in work Directory
  CreateWorkCsvFile;

  SetProgressUpdate(75);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.Save;
var
  ClientIndex : integer;
begin
  // Save Admin DB
  AdminSystem.Save;
  FreeAndNil(AdminSystem);
  SetProgressUpdate(85);

  // Save Client Files
  for ClientIndex := 0 to fClientList.Count-1 do
  begin
    fClientList[ClientIndex].Save;
    SetProgressUpdate(85 + (((ClientIndex+1)/fClientList.Count) * 15));

    if not IsClientFileNameUsed(fClientList[ClientIndex].FileName) then
      DeleteFile(PCHar(DataDir + fClientList[ClientIndex].FileName + FILEEXTN));
  end;

  //Copy Bk5Exe if it exists
  if fDataGenerator.Bk5Exe.Size > 0 then
    fDataGenerator.Bk5Exe.SaveToFile(fDestinationDirectory + '\BK5WIN.EXE');

  SetProgressUpdate(100);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TMuddler.Create;
begin
  fClientList := TClientList.Create;
  fDataGenerator := TDataGenerator.Create;
  fClientDetailsCache := TClientDetailsCache.Create;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TMuddler.Destroy;
begin
  FreeAndNil(fClientDetailsCache);
  FreeAndNil(fDataGenerator);
  FreeAndNil(fClientList);
  inherited;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.AddBk5ExeToDataFile(Bk5File: string);
var
  MuddleDataFile : String;
begin
  MuddleDataFile := ExtractFilePath(ParamStr(0)) + FILENAME_MUDDLE_DAT;

  // Loads Data File, Adds in BK5Exe and then Saves Data File
  DataGenerator.Load(MuddleDataFile);
  DataGenerator.Bk5Exe.LoadFromFile(Bk5File);
  DataGenerator.Save(MuddleDataFile);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.Execute(SourceDirectory, DestinationDirectory : string);
begin
  fSourceDirectory      := SourceDirectory;
  fDestinationDirectory := DestinationDirectory;
  DataDir := fDestinationDirectory + '\';
  GlobalDirectories.glDataDir := DataDir;

  CopyPractice;
  Open;
  Muddle;
  Save;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MakeBasicData;
begin
  fDataGenerator.NameList.Clear;
  fDataGenerator.NameList.Add('bob');
  fDataGenerator.NameList.Add('DoNovan');
  fDataGenerator.NameList.Add('MaRk');
  fDataGenerator.NameList.Add('frank');
  fDataGenerator.NameList.Add('MILL');
  fDataGenerator.NameList.Add('BiLL');
  fDataGenerator.NameList.Add('Chad');
  fDataGenerator.NameList.Add('Rodney');

  fDataGenerator.SurNameList.Clear;
  fDataGenerator.SurNameList.Add('Austen');
  fDataGenerator.SurNameList.Add('Nagel');
  fDataGenerator.SurNameList.Add('Maden');
  fDataGenerator.SurNameList.Add('Hill');
  fDataGenerator.SurNameList.Add('Kegan');
  fDataGenerator.SurNameList.Add('Fry');

  fDataGenerator.CompanyTypeList.Clear;
  fDataGenerator.CompanyTypeList.Add('Electonics');
  fDataGenerator.CompanyTypeList.Add('Computers');
  fDataGenerator.CompanyTypeList.Add('Plumbers');
  fDataGenerator.CompanyTypeList.Add('Panel Beaters');
  fDataGenerator.CompanyTypeList.Add('Software');
end;

end.
