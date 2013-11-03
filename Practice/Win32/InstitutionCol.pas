unit InstitutionCol;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes;

type
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
    FModifiedDate: TDateTime;
    FName : WideString;
    FTypeCode: WideString;
    FTypeDescription: WideString;

    // Extra Properties not loaded from blopi
    FEnabled : Boolean;
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
    property ModifiedDate: TDateTime read FModifiedDate write FModifiedDate;
    property Name : WideString read FName write FName;
    property TypeCode: WideString read FTypeCode write FTypeCode;
    property TypeDescription: WideString read FTypeDescription write FTypeDescription;

    // Extra Properties not loaded from blopi
    property Enabled : Boolean read FEnabled write FEnabled;
  end;

  //----------------------------------------------------------------------------
  TInstitutions = class(TCollection)
  private
    fCountryCodes : TStringList;
    fCountryNames : TStringList;

    fLoaded : boolean;
  protected
    function LoadFromFile(aFileName : string) : boolean;
    function LoadFromBlopi() : boolean;
    function GetBoolFromString(aInStr: String; adefault : boolean): boolean;
  public
    destructor Destroy; override;

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
  BanklinkOnlineServices;

const
  INST_CODE         = 0;
  INST_COUNTRY_CODE = 1;
  INST_ENABLED      = 2;

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
begin
  if not fLoaded then
  begin
    fLoaded := LoadFromBlopi();
    if fLoaded then
      fLoaded := LoadFromFile(DataDir + INSTITUTIONS_FILENAME);
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
function TInstitutions.LoadFromBlopi: boolean;
var
  BloArrayOfInstitution : TBloArrayOfInstitution;
  NewInstitutionItem : TInstitutionItem;
  ItemIndex : integer;
  CountryIndex : integer;
begin
  Result := (ProductConfigService.GetInstitutionList(BloArrayOfInstitution) in [bloSuccess, bloFailedNonFatal] );

  if Result then
  begin
    Self.Clear;
    CountryCodes.clear;
    CountryNames.clear;
    for ItemIndex := 0 to length(BloArrayOfInstitution) - 1 do
    begin
      NewInstitutionItem := TInstitutionItem.Create(Self);
      NewInstitutionItem.AccountEditMask := BloArrayOfInstitution[ItemIndex].AccountEditMask;
      NewInstitutionItem.Active          := BloArrayOfInstitution[ItemIndex].Active;
      NewInstitutionItem.Attachments     := BloArrayOfInstitution[ItemIndex].Attachments;
      NewInstitutionItem.BSBTip          := BloArrayOfInstitution[ItemIndex].BSBTip;
      NewInstitutionItem.BrandName       := BloArrayOfInstitution[ItemIndex].BrandName;
      NewInstitutionItem.CanImportData   := BloArrayOfInstitution[ItemIndex].CanImportData;
      NewInstitutionItem.Code            := BloArrayOfInstitution[ItemIndex].Code;
      NewInstitutionItem.CountryCode     := BloArrayOfInstitution[ItemIndex].CountryCode;
      NewInstitutionItem.HelpfulHints    := BloArrayOfInstitution[ItemIndex].HelpfulHints;
      NewInstitutionItem.Historical      := BloArrayOfInstitution[ItemIndex].Historical;
      //NewInstitutionItem.ModifiedDate    := BloArrayOfInstitution[ItemIndex].ModifiedDate.asDateTime;
      NewInstitutionItem.Name            := BloArrayOfInstitution[ItemIndex].Name_;
      NewInstitutionItem.TypeCode        := BloArrayOfInstitution[ItemIndex].TypeCode;
      NewInstitutionItem.TypeDescription := BloArrayOfInstitution[ItemIndex].TypeDescription;

      //Defaults for file properties
      NewInstitutionItem.Enabled := true;

      if CountryCodes.Find(NewInstitutionItem.CountryCode, CountryIndex) = false then
      begin
        CountryCodes.Add(NewInstitutionItem.CountryCode);
        CountryNames.Add('');
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TInstitutions.LoadFromFile(aFileName: string): boolean;
var
  CsvFile   : TStringList;  //holds all lines in file
  CommaLine : TStringList;  //holds all fields for a line
  CsvParse  : TCsvParser;
  LineNo : integer;
  Index : integer;
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
        FoundInstitutionItem.Enabled := GetBoolFromString(CommaLine[INST_ENABLED], true); //defaults to true on error
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
