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
    fCode : string;
    fName : string;
    fCountryCode : string;
    fCountryDesc : string;
  public
    property Code : string read fCode write fCode;
    property Name : string read fName write fName;
    property CountryCode : string read fCountryCode write fCountryCode;
    property CountryDesc : string read fCountryDesc write fCountryDesc;
  end;

  //----------------------------------------------------------------------------
  TInstitutions = class(TCollection)
  private
    fCountryCodes : TStringList;
    fCountryNames : TStringList;
    fLoaded : boolean;
  protected
    function LoadFromFile(aFileName : string) : boolean;
  public
    destructor Destroy; override;

    function Load() : boolean;
    function CountryCodes : TStringList;
    function CountryNames: TStringList;
  end;

//------------------------------------------------------------------------------
function Institutions : TInstitutions;

//------------------------------------------------------------------------------
implementation

uses
  CsvParser,
  Globals;

const
  INST_CODE = 0;
  INST_NAME = 1;
  INST_COUNTRY_CODE = 2;
  INST_COUNTRY_DESCR = 3;

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
    fLoaded := fInstitutions.LoadFromFile(DataDir + INSTITUTIONS_FILENAME);

  Result := fLoaded;
end;

//------------------------------------------------------------------------------
destructor TInstitutions.Destroy;
begin
  if Assigned(fCountryCodes) then
    FreeAndNil(fCountryCodes);

  inherited;
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
function TInstitutions.LoadFromFile(aFileName: string): boolean;
var
  CsvFile   : TStringList;  //holds all lines in file
  CommaLine : TStringList;  //holds all fields for a line
  CsvParse  : TCsvParser;
  LineNo : integer;
  Index : integer;
  NewInstitutionItem : TInstitutionItem;
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

      NewInstitutionItem := TInstitutionItem.Create(Self);
      NewInstitutionItem.Code := CommaLine[INST_CODE];
      NewInstitutionItem.Name := CommaLine[INST_NAME];
      NewInstitutionItem.CountryCode := CommaLine[INST_COUNTRY_CODE];
      NewInstitutionItem.CountryDesc := CommaLine[INST_COUNTRY_DESCR];

      if CountryCodes.Find(CommaLine[INST_COUNTRY_CODE], Index) = false then
      begin
        CountryCodes.Add(CommaLine[INST_COUNTRY_CODE]);
        CountryNames.Add(CommaLine[INST_COUNTRY_DESCR]);
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
