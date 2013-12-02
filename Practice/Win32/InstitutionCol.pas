unit InstitutionCol;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  BanklinkOnlineServices;

type
  TInstitutionExceptions = (ieNone, ieANZ, ieNAT);

  //----------------------------------------------------------------------------
  TInstitutionItem = class(TCollectionItem)
  private
    FAccountEditMask: WideString;
    FActive: Boolean;
    FAttachments: WideString;
    FBSBTip: WideString;
    FBrandName: WideString;
    FCanImportData: Integer;
    FCode: WideString;
    FCountryCode: WideString;
    FHelpfulHints: WideString;
    FHistorical: WideString;
    FName : WideString;
    FTypeCode: WideString;
    FTypeDescription: WideString;

    // Extra Properties not loaded from blopi
    FEnabled : Boolean;
    FHasRuralCode : Boolean;
    FRuralCode : string;
    fRuralMainItemCode : string;
    FHasNewName : Boolean;
    FNewName : String;
    FHasNewMask : Boolean;
    FNewMask : string;
  public
    property AccountEditMask: WideString read FAccountEditMask write FAccountEditMask;
    property Active: Boolean read FActive write FActive;
    property Attachments: WideString read FAttachments write FAttachments;
    property BSBTip: WideString read FBSBTip write FBSBTip;
    property BrandName: WideString read FBrandName write FBrandName;
    property CanImportData: Integer read FCanImportData write FCanImportData;
    property Code: WideString read FCode write FCode;
    property CountryCode: WideString read FCountryCode write FCountryCode;
    property HelpfulHints: WideString read FHelpfulHints write FHelpfulHints;
    property Historical: WideString read FHistorical write FHistorical;
    property Name : WideString read FName write FName;
    property TypeCode: WideString read FTypeCode write FTypeCode;
    property TypeDescription: WideString read FTypeDescription write FTypeDescription;

    // Extra Properties not loaded from blopi
    property Enabled : Boolean read FEnabled write FEnabled;
    property HasRuralCode : Boolean read FHasRuralCode write FHasRuralCode;
    property RuralCode : string read FRuralCode write FRuralCode;
    property RuralMainItemCode : string read FRuralMainItemCode write FRuralMainItemCode;
    property HasNewName : Boolean read FHasNewName write FHasNewName;
    property NewName : String read FNewName write FNewName;
    property HasNewMask : Boolean read FHasNewMask write FHasNewMask;
    property NewMask : string read FNewMask write FNewMask;
  end;

  //----------------------------------------------------------------------------
  TInstitutions = class(TCollection)
  private
    fCountryCodes : TStringList;
    fCountryNames : TStringList;

    fLoaded : boolean;
  protected
    function SaveToFile(aFileName: string): boolean;
    function GetBoolFromString(aInStr: String; adefault : boolean): boolean;
  public
    destructor Destroy; override;

    function LoadFromFile(aFileName : string) : boolean;
    procedure FillDataFromBlopi(aBloArrayOfInstitution : TBloArrayOfInstitution);
    function DoInstituionExceptionCode(aAccount, aCode : string) : TInstitutionExceptions;

    function Load() : boolean;
    function CountryCodes : TStringList;
    function CountryNames: TStringList;
    function FindItem(aCode, aCountryCode: WideString; out aInstitutionItem : TInstitutionItem) : boolean;
  end;

//------------------------------------------------------------------------------
function Institutions : TInstitutions;

//------------------------------------------------------------------------------
implementation

uses
  CsvParser,
  Globals,
  GenUtils,
  strutils;

const
  INST_CODE           = 0;
  INST_NAME           = 1;
  INST_COUNTRY_CODE   = 2;
  INST_ENABLED        = 3;
  RURAL_CODE          = 4;
  NEW_NAME            = 5;
  NEW_MASK            = 6;

var
  fInstitutions : TInstitutions;

//------------------------------------------------------------------------------
function Institutions : TInstitutions;
begin
  if Not Assigned(fInstitutions) then
  begin
    fInstitutions := TInstitutions.Create(TInstitutionItem);
  end;

  Result := fInstitutions;
end;

{ TInstitutions }
//------------------------------------------------------------------------------
function TInstitutions.Load: boolean;
var
  BloArrayOfInstitution : TBloArrayOfInstitution;
  InstIndex : integer;
begin
  if not fLoaded then
  begin
    fLoaded := (ProductConfigService.GetInstitutionList(BloArrayOfInstitution) in [bloSuccess, bloFailedNonFatal] );

    if fLoaded then
    begin
      try
        FillDataFromBlopi(BloArrayOfInstitution);
        fLoaded := LoadFromFile(DataDir + INSTITUTIONS_FILENAME);
      finally
        for InstIndex := 0 to length(BloArrayOfInstitution) - 1 do
          FreeAndNil(BloArrayOfInstitution[InstIndex]);
        setlength(BloArrayOfInstitution,0);
      end;
    end;
  end;

  Result := fLoaded;
end;

//------------------------------------------------------------------------------
function TInstitutions.CountryCodes: TStringList;
begin
  if Not Assigned(fCountryCodes) then
    fCountryCodes := TStringList.Create;

  Result := fCountryCodes;
end;

//------------------------------------------------------------------------------
function TInstitutions.CountryNames: TStringList;
begin
  if Not Assigned(fCountryNames) then
    fCountryNames := TStringList.Create;

  Result := fCountryNames;
end;


//------------------------------------------------------------------------------
destructor TInstitutions.Destroy;
begin
  if Assigned(fCountryCodes) then
    FreeAndNil(fCountryCodes);
  if Assigned(fCountryNames) then
    FreeAndNil(fCountryNames);

  inherited;
end;

//------------------------------------------------------------------------------
function TInstitutions.FindItem(aCode, aCountryCode: WideString; out aInstitutionItem : TInstitutionItem) : boolean;
var
  Index : integer;
begin
  aInstitutionItem := nil;
  result := false;
  for Index := 0 to Self.Count - 1 do
  begin
    if (TInstitutionItem(self.Items[Index]).Code = aCode) and
       (TInstitutionItem(self.Items[Index]).CountryCode = aCountryCode) then
    begin
      Result := true;
      aInstitutionItem := TInstitutionItem(self.Items[Index]);
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TInstitutions.DoInstituionExceptionCode(aAccount, aCode : string) : TInstitutionExceptions;
var
  Bank : string;
begin
  if aCode = 'ANZ' then
  begin
    Bank := leftstr(aAccount, 2);
    if (Bank = '06') then
      Result := ieNAT
    else
      Result := ieANZ;
  end
  else
    Result := ieNone;
end;

//------------------------------------------------------------------------------
function TInstitutions.GetBoolFromString(aInStr: String; adefault : boolean): boolean;
begin
  if (trim(uppercase(aInStr)) = '0') or
     (trim(uppercase(aInStr)) = 'NO') or
     (trim(uppercase(aInStr)) = 'FALSE') then
    result := false
  else if (trim(uppercase(aInStr)) = '1') or
          (trim(uppercase(aInStr)) = 'YES') or
          (trim(uppercase(aInStr)) = 'TRUE') then
    result := true
  else
    result := adefault;
end;

//------------------------------------------------------------------------------
procedure TInstitutions.FillDataFromBlopi(aBloArrayOfInstitution : TBloArrayOfInstitution);
var
  NewInstitutionItem : TInstitutionItem;
  ItemIndex : integer;
  CountryIndex : integer;
begin
  Self.Clear;
  CountryCodes.clear;
  CountryNames.clear;
  for ItemIndex := 0 to length(aBloArrayOfInstitution) - 1 do
  begin
    // National Exception - don't show National Bank, this could not be fixed in Online
    // or Core so the only option I had was to fix it here.
    if (aBloArrayOfInstitution[ItemIndex].Code = 'NAT') and
       (aBloArrayOfInstitution[ItemIndex].CountryCode = 'NZ') then
      Continue;

    NewInstitutionItem := TInstitutionItem.Create(Self);
    NewInstitutionItem.AccountEditMask := aBloArrayOfInstitution[ItemIndex].AccountEditMask;
    NewInstitutionItem.Active          := aBloArrayOfInstitution[ItemIndex].Active;
    NewInstitutionItem.Attachments     := aBloArrayOfInstitution[ItemIndex].Attachments;
    NewInstitutionItem.BSBTip          := aBloArrayOfInstitution[ItemIndex].BSBTip;
    NewInstitutionItem.BrandName       := aBloArrayOfInstitution[ItemIndex].BrandName;
    NewInstitutionItem.CanImportData   := aBloArrayOfInstitution[ItemIndex].CanImportData;
    NewInstitutionItem.Code            := aBloArrayOfInstitution[ItemIndex].Code;
    NewInstitutionItem.CountryCode     := aBloArrayOfInstitution[ItemIndex].CountryCode;
    NewInstitutionItem.HelpfulHints    := aBloArrayOfInstitution[ItemIndex].HelpfulHints;
    NewInstitutionItem.Historical      := aBloArrayOfInstitution[ItemIndex].Historical;
    NewInstitutionItem.Name            := aBloArrayOfInstitution[ItemIndex].Name_;
    NewInstitutionItem.TypeCode        := aBloArrayOfInstitution[ItemIndex].TypeCode;
    NewInstitutionItem.TypeDescription := aBloArrayOfInstitution[ItemIndex].TypeDescription;

    //Defaults for file properties
    NewInstitutionItem.Enabled := true;
    NewInstitutionItem.HasRuralCode := false;
    NewInstitutionItem.RuralCode := '';
    NewInstitutionItem.RuralMainItemCode := '';
    NewInstitutionItem.HasNewName := false;
    NewInstitutionItem.NewName := '';
    NewInstitutionItem.HasNewMask := false;
    NewInstitutionItem.NewMask := '';

    if CountryCodes.Find(NewInstitutionItem.CountryCode, CountryIndex) = false then
    begin
      CountryCodes.Add(NewInstitutionItem.CountryCode);
      CountryNames.Add('');
    end;
  end;
end;

//------------------------------------------------------------------------------
function TInstitutions.SaveToFile(aFileName: string): boolean;
var
  BloArrayOfInstitution : TBloArrayOfInstitution;
  NewInstitutionItem : TInstitutionItem;
  ItemIndex : integer;
  CountryIndex : integer;
  CsvFile   : TStringList;
begin
  Result := (ProductConfigService.GetInstitutionList(BloArrayOfInstitution) in [bloSuccess, bloFailedNonFatal] );

  CsvFile := TStringList.Create;

  try
    CsvFile.Add('CODE, NAME, COUNTRY_CODE, ENABLED, RURAL_MAIN_CODE, NEW_NAME, NEW_MASK');

    for ItemIndex := 0 to length(BloArrayOfInstitution) - 1 do
    begin
      CsvFile.Add(BloArrayOfInstitution[ItemIndex].Code + ',' +
                  RemoveInvalidCharacters(BloArrayOfInstitution[ItemIndex].Name_) + ',' +
                  BloArrayOfInstitution[ItemIndex].CountryCode + ',1, , , ');
    end;

    CsvFile.SaveToFile(aFileName);
    Result := true;

  finally
    FreeAndNil(CsvFile);
  end;
end;

//------------------------------------------------------------------------------
function TInstitutions.LoadFromFile(aFileName: string): boolean;
var
  CsvFile   : TStringList;  //holds all lines in file
  CommaLine : TStringList;  //holds all fields for a line
  CsvParse  : TCsvParser;
  LineNo    : integer;
  Index     : integer;
  FoundInstitutionItem : TInstitutionItem;
begin
  Result := false;
  CsvFile   := TStringList.Create;
  CommaLine := TStringlist.Create;
  CsvParse  := TCsvParser.Create;

  Try
    CsvFile.LoadFromFile(aFileName);

    for LineNo := 0 to CsvFile.Count - 1 do
    begin
      if LineNo = 0 then
        Continue;

      CSVParse.ExtractFields( csvFile[LineNo], CommaLine);

      if FindItem(CommaLine[INST_CODE], CommaLine[INST_COUNTRY_CODE], FoundInstitutionItem) then
      begin
        FoundInstitutionItem.Enabled      := GetBoolFromString(CommaLine[INST_ENABLED], true); //defaults to true on error
        FoundInstitutionItem.HasRuralCode := (length(trim(CommaLine[RURAL_CODE])) > 0);
        FoundInstitutionItem.RuralCode    := CommaLine[RURAL_CODE];
        FoundInstitutionItem.HasNewName   := (length(trim(CommaLine[NEW_NAME])) > 0);
        FoundInstitutionItem.NewName      := CommaLine[NEW_NAME];
        FoundInstitutionItem.HasNewMask   := (length(trim(CommaLine[NEW_MASK])) > 0);
        FoundInstitutionItem.NewMask      := CommaLine[NEW_MASK];
      end;
    end;

    Result := true;

  Finally
    FreeAndNil(CsvParse);
    FreeAndNil(CsvFile);
    FreeAndNil(CommaLine);
  end;
end;

//------------------------------------------------------------------------------
initialization
  fInstitutions := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fInstitutions);

end.
