//------------------------------------------------------------------------------
{
   Title:       DataGenerator

   Description: Used by the Muddle Unit to Generate Data from 3 main name
                Lists : Name List
                        Surname List
                        Company Type List
                All of the List can be loaded and saved, either individully or
                as one main data file.

   Remarks:

   Author:      Ralph Austen

}
//------------------------------------------------------------------------------
unit DataGenerator;

interface

uses
  Classes;

type
  TDataGenerator = class
  private
    fNameIndex     : integer;
    fNameList      : TStringList;
    fSurnameIndex  : integer;
    fSurnameList   : TStringList;
    fCompTypeIndex : integer;
    fCompTypeList  : TStringList;
    fCodeNumber    : integer;

    procedure WriteStreamInt(Stream : TStream; Num : integer);
    function ReadStreamInt(Stream : TStream; var Num : integer) : boolean;

    function GenerateFromList(var Index : integer; const List : TStringList) : string;
    procedure ShuffleList(const List : TStringList);
  protected
    procedure Initialize;
    function GenerateName     : string;
    function GenerateSurname  : string;
    function GenerateCompType : string;

    function GetFirstName(FullName : string) : string;
    function GetLastName(FullName : string) : string;
    function RemoveSpaces(InString : string) : string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(FullFileName : string);
    procedure Save(FullFileName : string);

    procedure ShuffleLists;

    function GenerateCode(CodeLength : integer) : string;
    function GenerateCompanyName(CompanyType : string = '') : string;
    function GeneratePersonName(MinNames, MaxNames : integer) : string;
    function GeneratePhoneNumber : string;
    function GenerateEmail(UserName, MailServer, SubDomain, Domain : string) : string;
    function GenerateWebSite(Server, SubDomain, Domain: string): string;
    function GenerateStreetAddress : string;

    function GetUserNameFromPersonName(PersonName : string) : string;

    property NameList        : TStringList read fNameList     write fNameList;
    property SurnameList     : TStringList read fSurnameList  write fSurnameList;
    property CompanyTypeList : TStringList read fCompTypeList write fCompTypeList;
  end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation

uses
  SysUtils,
  StrUtils;

{ TDataGenerator }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.WriteStreamInt(Stream : TStream; Num : integer);
begin
  Stream.Write(Num, SizeOf(integer));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.ReadStreamInt(Stream : TStream; var Num : integer) : boolean;
begin
  Result := (Stream.Read(Num, SizeOf(integer)) = SizeOf(integer));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateFromList(var Index : integer; const List : TStringList) : string;
begin
  Result := '';

  if List.Count = 0 then
    Exit;

  Result := List.strings[Index];
  Result := UpperCase(LeftStr(Result,1)) +
            LowerCase(RightStr(Result,Length(Result)-1));

  inc(Index);
  if Index > (List.Count-1) then
    Index := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.ShuffleList(const List : TStringList);
var
  ItemIndex1 : integer;
  ItemIndex2 : integer;
  SuffleIndex : integer;
  Holderstring : string;
begin
  if List.Count < 3 then
    Exit;

  for SuffleIndex := 0 to List.Count-3 do
  begin
    ItemIndex1 := Random(List.Count);
    ItemIndex2 := ItemIndex1;

    while ItemIndex2 = ItemIndex1 do
      ItemIndex2 := Random(List.Count);

    Holderstring := List[ItemIndex1];
    List[ItemIndex1] := List[ItemIndex2];
    List[ItemIndex2] := Holderstring;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.Initialize;
begin
  Randomize;

  fNameIndex     := 0;
  fSurnameIndex  := 0;
  fCompTypeIndex := 0;
  fCodeNumber    := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.RemoveSpaces(Instring: string): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to Length(Instring) do
  begin
    if not (Instring[Index] = ' ') then
      Result := Result + Instring[Index];
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateName: string;
begin
  Result := GenerateFromList(fNameIndex, fNameList);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateSurName: string;
begin
  Result := GenerateFromList(fSurnameIndex, fSurnameList);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateCompType: string;
begin
  Result := GenerateFromList(fCompTypeIndex, fCompTypeList);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GetFirstName(FullName : string) : string;
var
  FirstSpacePos : integer;
begin
  FirstSpacePos := Pos(' ', FullName);
  if FirstSpacePos = 0 then
    Result := FullName
  else
    Result := LeftStr(FullName, FirstSpacePos-1);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GetLastName(FullName : string) : string;
var
  LastSpacePos : integer;
  NameIndex : integer;
begin
  LastSpacePos := 0;
  for NameIndex := Length(FullName) downto 1 do
  begin
    if FullName[NameIndex] = ' ' then
    begin
      LastSpacePos := NameIndex;
      break;
    end;
  end;

  if LastSpacePos = 0 then
    Result := FullName
  else
    Result := RightStr(FullName, Length(FullName) - LastSpacePos);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.ShuffleLists;
begin
  ShuffleList(fNameList);
  ShuffleList(fSurnameList);
  ShuffleList(fCompTypeList);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateCode(CodeLength : integer) : string;
var
  Index : integer;
begin
  inc(fCodeNumber);
  Result := inttostr(fCodeNumber);

  if CodeLength > Length(Result) then
  begin
    for Index := 1 to (CodeLength - Length(Result)) do
      Result := '0' + Result;
  end
  else if CodeLength < Length(Result) then
    Result := RightStr(Result, CodeLength);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateCompanyName(CompanyType : string = '') : string;
begin
  Result := GenerateSurname + ' ';

  if CompanyType = '' then
    Result := Result + GenerateCompType
  else
    Result := Result + CompanyType;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GeneratePersonName(MinNames, MaxNames: integer): string;
var
  NameIndex : integer;
  First : boolean;
  NumberOfNames : integer;
begin
  NumberOfNames := Random(MaxNames-MinNames)+MinNames;
  if NumberOfNames < 1 then
    NumberOfNames := 1;

  Result := '';
  First := True;
  for NameIndex := 0 to NumberOfNames-1 do
  begin
    if First then
      First := False
    else
      Result := Result + ' ';

    Result := Result + GenerateName;
  end;

  Result := Result + ' ' + GenerateSurname;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GeneratePhoneNumber: string;
begin
  Result := '000 ' + GenerateCode(3) + ' ' + GenerateCode(4);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateEmail(UserName, MailServer, SubDomain, Domain: string): string;
begin
  if UserName = '' then
    UserName := GetUserNameFromPersonName(GeneratePersonName(1,1));

  UserName := RemoveSpaces(UserName);

  if MailServer = '' then
    MailServer := GenerateCompanyName;

  MaiLServer := RemoveSpaces(MailServer);

  if Domain = '' then
    Domain := 'com';

  Result := UserName + '@' + MailServer;
  if not (SubDomain = '') then
    Result := Result + '.' + SubDomain;
  Result := Result + '.' + Domain;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateWebSite(Server, SubDomain, Domain: string): string;
begin
  if Server = '' then
    Server := GenerateCompanyName;

  Server := RemoveSpaces(Server);

  if Domain = '' then
    Domain := 'com';

  Result := 'http://www.' + Server;
  if not (SubDomain = '') then
    Result := Result + '.' + SubDomain;
  Result := Result + '.' + Domain;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GenerateStreetAddress: string;
begin
  Result := inttostr(Random(199) + 1) + ' ' +
            GenerateName + ' ';

  case Random(2) of
    0 : Result := Result + 'Road';
    1 : Result := Result + 'Street';
    2 : Result := Result + 'Avenue';
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TDataGenerator.GetUserNameFromPersonName(PersonName : string) : string;
begin
  Result := GetFirstName(PersonName) + LeftStr(GetLastName(PersonName),1);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TDataGenerator.Create;
begin
  fNameList     := TStringList.Create;
  fSurnameList  := TStringList.Create;
  fCompTypeList := TStringList.Create;

  Initialize;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.Load(FullFileName: string);
var
  FileStream      : TFileStream;
  MemoryStream    : TMemoryStream;
  FirstNameSize   : integer;
  SurnameSize     : integer;
  CompanyTypeSize : integer;
begin
  FileStream   := TFileStream.Create(FullFileName, fmOpenRead);
  MemoryStream := TMemoryStream.Create;

  try
    FileStream.Position := 0;

    ReadStreamInt(FileStream, FirstNameSize);
    ReadStreamInt(FileStream, SurnameSize);
    ReadStreamInt(FileStream, CompanyTypeSize);

    MemoryStream.Clear;
    MemoryStream.CopyFrom(FileStream, FirstNameSize);
    MemoryStream.Position := 0;
    fNameList.LoadFromStream(MemoryStream);

    MemoryStream.Clear;
    MemoryStream.CopyFrom(FileStream, SurnameSize);
    MemoryStream.Position := 0;
    fSurnameList.LoadFromStream(MemoryStream);

    MemoryStream.Clear;
    MemoryStream.CopyFrom(FileStream, CompanyTypeSize);
    MemoryStream.Position := 0;
    fCompTypeList.LoadFromStream(MemoryStream);
  finally
    FreeAndNil(MemoryStream);
    FreeAndNil(FileStream);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDataGenerator.Save(FullFileName: string);
var
  FileStream   : TFileStream;
  FirstNameStr : TMemoryStream;
  SurnameStr   : TMemoryStream;
  CompanyStr   : TMemoryStream;
  FirstNameSize   : integer;
  SurnameSize     : integer;
  CompanyTypeSize : integer;
begin
  FileStream   := TFileStream.Create(FullFileName, fmCreate);
  FirstNameStr := TMemoryStream.Create;
  SurnameStr   := TMemoryStream.Create;
  CompanyStr   := TMemoryStream.Create;

  try
    fNameList.SaveToStream(FirstNameStr);
    fSurnameList.SaveToStream(SurnameStr);
    fCompTypeList.SaveToStream(CompanyStr);

    FirstNameSize   := FirstNameStr.Size;
    SurnameSize     := SurnameStr.Size;
    CompanyTypeSize := CompanyStr.Size;

    WriteStreamInt(FileStream, FirstNameSize);
    WriteStreamInt(FileStream, SurnameSize);
    WriteStreamInt(FileStream, CompanyTypeSize);

    FileStream.CopyFrom(FirstNameStr, 0);
    FileStream.CopyFrom(SurnameStr, 0);
    FileStream.CopyFrom(CompanyStr, 0);
  finally
    FreeAndNil(FirstNameStr);
    FreeAndNil(SurnameStr);
    FreeAndNil(CompanyStr);
    FreeAndNil(FileStream);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TDataGenerator.Destroy;
begin
  FreeAndNil(fNameList);
  FreeAndNil(fSurnameList);
  FreeAndNil(fCompTypeList);

  inherited;
end;

end.
