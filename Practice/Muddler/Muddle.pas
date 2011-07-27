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
    function ReplaceNumbers(Instring : string; MinLength : integer) : string;
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
  protected
    procedure MuddlePracticeSys(var PracticeFields : tPractice_Details_Rec;
                                Name         : string;
                                Phone        : string;
                                Email        : string;
                                WebSite      : string;
                                BankLinkCode : string);

    procedure MuddleUserSys(UserFields   : pUser_Rec;
                            PracticeName : string);

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
  stDate;

const
  MIN_NUM_REPLACE_LENGTH = 4;
  FILE_EXT_LIST : Array[0..17] of string =
    ('bk5','Exe','Inf','rsm','html','db','dat','ini','chm','dll','map','prs',
     'ovl','current','Txn','tpm','bk!','xml');

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
    AssignFile(WorkFile, DataDir + 'Work\' + inttostr(Monthof(FirstDate)) + '-' +
                         inttostr(Yearof(FirstDate)) + '.csv');
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
function TMuddler.ReplaceNumbers(Instring : string; MinLength : integer) : string;
var
  StrIndex : integer;
  StartPos : integer;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  procedure ReplaceSection(FirstPos, LastPos : integer);
  var
    ReplaceIndex : integer;
  begin
    for ReplaceIndex := FirstPos to LastPos do
      Result[ReplaceIndex] := '#';
  end;
begin
  Result := Instring;

  if length(Instring) < MinLength  then
    Exit;

  StartPos := 0;

  for StrIndex := 1 to Length(Result) do
  begin
    if (Result[StrIndex] in ['0'..'9']) and
       (StartPos = 0) then
      StartPos := StrIndex
    else if not (Result[StrIndex] in ['0'..'9']) and
            (StartPos > 0) then
    begin
      if ((StrIndex-1) - StartPos) >= (MinLength-1) then
        ReplaceSection(StartPos, (StrIndex-1));

      StartPos := 0;
    end;
  end;

  if (StartPos > 0) and
     ((Length(Result) - StartPos) >= (MinLength-1)) then
    ReplaceSection(StartPos, Length(Result));
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
                                 PracticeName : string);
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
  ClientObj.clFields.clPIN_Number := 0;
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
  ClientObj.clFields.clGroup_Name := '';
  ClientObj.clFields.clPractice_Code := PracticeCode;
  ClientObj.clFields.clTFN := '';
  ClientObj.clFields.clTemp_FRS_Budget_To_Use := '';
  ClientObj.clFields.clTemp_FRS_Job_To_Use := '';


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
  AccountNumber := '1111' + fDataGenerator.GenerateCode(8);
  AccountName   := fDataGenerator.GeneratePersonName(1,2);

  // Accounts in Database
  for AccountIndex := 0 to AdminSystem.fdSystem_Bank_Account_List.ItemCount - 1 do
  begin
    AccountField := AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(AccountIndex);

    if AccountObj.baFields.baBank_Account_Number = AccountField.sbAccount_Number then
    begin
      AccountField.sbAccount_Number   := AccountNumber;
      AccountField.sbAccount_Name     := AccountName;
      AccountField.sbAccount_Password := '';
    end;
  end;

  AddAccountOldNew(AccountObj.baFields.baBank_Account_Number,
                   AccountNumber,
                   AccountName);

  AccountObj.baFields.baBank_Account_Number := AccountNumber;
  AccountObj.baFields.baBank_Account_Name   := AccountName;

  StDateToDMY(AccountObj.baFields.baTemp_New_Date_Last_Trx_Printed, Day, Month, Year);
  AddBillingInfo(ClientName,
                 AccountNumber,
                 AccountName,
                 Random(49),
                 AccountObj.baFields.baCurrent_Balance,
                 EncodeDate(Year, Month, Day),
                 fDataGenerator.GenerateCompanyName('Bank'));


  AccountObj.baFields.baBank_Account_Password := '';

  for TransIndex := 0 to AccountObj.baTransaction_List.ItemCount - 1 do
    MuddleTransactionBk5(AccountObj.baTransaction_List.Transaction_At(TransIndex));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMuddler.MuddleTransactionBk5(TransField : pTransaction_Rec);
begin
  TransField.txReference            := ReplaceNumbers(TransField.txReference,MIN_NUM_REPLACE_LENGTH);
  TransField.txParticulars          := ReplaceNumbers(TransField.txParticulars,MIN_NUM_REPLACE_LENGTH);
  TransField.txAnalysis             := ReplaceNumbers(TransField.txAnalysis,MIN_NUM_REPLACE_LENGTH);
  TransField.txOrigBB               := ReplaceNumbers(TransField.txOrigBB,MIN_NUM_REPLACE_LENGTH);
  TransField.txOther_Party          := ReplaceNumbers(TransField.txOther_Party,MIN_NUM_REPLACE_LENGTH);
  TransField.txOld_Narration        := ReplaceNumbers(TransField.txOld_Narration,MIN_NUM_REPLACE_LENGTH);
  TransField.txOriginal_Reference   := ReplaceNumbers(TransField.txOriginal_Reference,MIN_NUM_REPLACE_LENGTH);
  TransField.txNotes                := ReplaceNumbers(TransField.txNotes,MIN_NUM_REPLACE_LENGTH);
  TransField.txECoding_Import_Notes := ReplaceNumbers(TransField.txECoding_Import_Notes,MIN_NUM_REPLACE_LENGTH);
  TransField.txGL_Narration         := ReplaceNumbers(TransField.txGL_Narration,MIN_NUM_REPLACE_LENGTH);
  TransField.txStatement_Details    := ReplaceNumbers(TransField.txStatement_Details,MIN_NUM_REPLACE_LENGTH);
  TransField.txDocument_Title       := ReplaceNumbers(TransField.txDocument_Title,MIN_NUM_REPLACE_LENGTH);
  TransField.txSpare_string         := ReplaceNumbers(TransField.txSpare_string,MIN_NUM_REPLACE_LENGTH);
  TransField.txTemp_Prov_Entered_By := ReplaceNumbers(TransField.txTemp_Prov_Entered_By,MIN_NUM_REPLACE_LENGTH);
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

    Memorisation.mdFields.mdReference         := ReplaceNumbers(Memorisation.mdFields.mdReference, MIN_NUM_REPLACE_LENGTH);
    Memorisation.mdFields.mdParticulars       := ReplaceNumbers(Memorisation.mdFields.mdParticulars, MIN_NUM_REPLACE_LENGTH);
    Memorisation.mdFields.mdAnalysis          := ReplaceNumbers(Memorisation.mdFields.mdAnalysis, MIN_NUM_REPLACE_LENGTH);
    Memorisation.mdFields.mdOther_Party       := ReplaceNumbers(Memorisation.mdFields.mdOther_Party, MIN_NUM_REPLACE_LENGTH);
    Memorisation.mdFields.mdStatement_Details := ReplaceNumbers(Memorisation.mdFields.mdStatement_Details, MIN_NUM_REPLACE_LENGTH);
    Memorisation.mdFields.mdNotes             := ReplaceNumbers(Memorisation.mdFields.mdNotes, MIN_NUM_REPLACE_LENGTH);
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

        Trans_Record.aReference         := ReplaceNumbers(Trans_Record.aReference,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aParticulars       := ReplaceNumbers(Trans_Record.aParticulars,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aAnalysis          := ReplaceNumbers(Trans_Record.aAnalysis,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aOrigBB            := ReplaceNumbers(Trans_Record.aOrigBB,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aOther_Party       := ReplaceNumbers(Trans_Record.aOther_Party,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aNarration         := ReplaceNumbers(Trans_Record.aNarration,MIN_NUM_REPLACE_LENGTH);
        Trans_Record.aStatement_Details := ReplaceNumbers(Trans_Record.aStatement_Details,MIN_NUM_REPLACE_LENGTH);

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

        DiskTxn.dtReference           := ReplaceNumbers(DiskTxn.dtReference, MIN_NUM_REPLACE_LENGTH);
        DiskTxn.dtParticulars_NZ_Only := ReplaceNumbers(DiskTxn.dtParticulars_NZ_Only, MIN_NUM_REPLACE_LENGTH);
        DiskTxn.dtOther_Party_NZ_Only := ReplaceNumbers(DiskTxn.dtOther_Party_NZ_Only, MIN_NUM_REPLACE_LENGTH);
        DiskTxn.dtOrig_BB             := ReplaceNumbers(DiskTxn.dtOrig_BB, MIN_NUM_REPLACE_LENGTH);
        DiskTxn.dtNarration           := ReplaceNumbers(DiskTxn.dtNarration, MIN_NUM_REPLACE_LENGTH);
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

  AccountIndex : integer;
  AccMapIndex  : integer;

  MemorizationIndex : integer;
begin
  PracticeName       := fDataGenerator.GenerateCompanyName('Accountants');
  PracticePersonName := fDataGenerator.GeneratePersonName(1,2);
  PracticeUserName   := fDataGenerator.GetUserNameFromPersonName(PracticePersonName);
  PracticeEmail      := fDataGenerator.GenerateEmail(PracticeUserName,PracticeName,'co','nz');
  PracticeWebSite    := fDataGenerator.GenerateWebSite(PracticeName,'co','nz');
  PracticePhone      := fDataGenerator.GeneratePhoneNumber;
  PracticeCode       := 'Prac0001';
  BankLinkCode       := 'Bank0001';

  MuddlePracticeSys(AdminSystem.fdFields,
                    PracticeName,
                    PracticePhone,
                    PracticeEmail,
                    PracticeWebSite,
                    BankLinkCode);

  //  Users in Database
  for UserIndex := 0 to AdminSystem.fdSystem_User_List.ItemCount-1 do
  begin
    UserDBItem := AdminSystem.fdSystem_User_List.User_At(UserIndex);

    MuddleUserSys(AdminSystem.fdSystem_User_List.User_At(UserIndex),
                  PracticeName);
  end;

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
