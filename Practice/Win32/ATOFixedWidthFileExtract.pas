unit ATOFixedWidthFileExtract;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  MoneyDef;

type
  //----------------------------------------------------------------------------
  {TATOPayeeData = class
  private
    fPayeeNonIndividualBusinessName : string;
    fPayeeAddress1 : string;
    fPayeeSuburb : string;
    fPayeeState : string;
    fPayeePostCode : longword;
    fPayeeGrossAmountPaid : longword;
    fPayeeTaxWithheld : longword;
    fPayeeTotalGst : longword;
    fPayeeAmendmentIndicator : string;
  end;}

  //----------------------------------------------------------------------------
  TATOFixedWidthFileExtract = class
  private
    fFile : TextFile;
    fFileOpened : Boolean;
    fTotalRecords : longword;

  protected
    function RemoveMultiSpaces(aInstring : string) : string;

    // Ato Data Fields
    procedure WriteNumericData(aValue : longword; aLength : integer);
    procedure WriteNumericDataFromText(aValue : string; aLength : integer);
    procedure WriteAlphaNumericData(aValue : string; aLength : integer);
    procedure WriteAlphaData(aValue : string; aLength : integer);
    procedure WriteDateData(aValue : TDateTime);
    procedure WriteFillerData(aLength : integer);
    procedure WriteTelphoneData(aValue : string; aLength : integer);
    procedure WriteMoneyData(aValue : Money; aLength : integer);
    procedure WritePostCode(aValue : string);
  public
    constructor Create;
    destructor Destroy; override;

    // Open and Close File

    procedure OpenATOFile(aFileName : string);
    procedure CloseATOFile();

    // ATO Data Records
    procedure WriteSupplierDataRecord1(aSupplierABNNumber : string;
                                       aRunType : char;
                                       aReportEndDate : TDateTime);
    procedure WriteSupplierDataRecord2(aSupplierName : string;
                                       aSupplierContactName : string;
                                       aSupplierContactTelephone : string;
                                       aSupplierfacsimile : string;
                                       aSupplierFileReference : string);
    procedure WriteSupplierDataRecord3(aSupplierStreetAddress1 : string;
                                       aSupplierStreetAddress2 : string;
                                       aSupplierStreetSuburb : string;
                                       aSupplierStreetState : string;
                                       aSupplierStreetPostCode : string;
                                       aSupplierStreetCountry : string;
                                       aSupplierPostAddress1 : string;
                                       aSupplierPostAddress2 : string;
                                       aSupplierPostSuburb : string;
                                       aSupplierPostState : string;
                                       aSupplierPostPostCode : string;
                                       aSupplierPostCountry : string;
                                       aSupplierEmailAddress : string);
    procedure WritePayerIdentityDataRecord(aPayerABNNumber : string;
                                           aPayerBranchNumber : string;
                                           aPayerFinancialYear : longword;
                                           aPayerName : string;
                                           aPayerTradingName : string;
                                           aPayerAddress1 : string;
                                           aPayerAddress2 : string;
                                           aPayerSuburb : string;
                                           aPayerState : string;
                                           aPayerPostCode : string;
                                           aPayerCountry : string;
                                           aPayerContactName : string;
                                           aPayerContactTelephone : string;
                                           aPayerFacimileNumber : string;
                                           aPayerEmailAddress : string);
    procedure WriteSoftwareDataRecord(aSoftwareProductType : string);
    procedure WritePayeeDataRecord(aPayeeABNNumber : string;
                                   aPayeeSurname : string;
                                   aPayeeFirstGivenName : string;
                                   aPayeeSecondGivenName : string;
                                   aPayeeNonIndividualBusinessName : string;
                                   aPayeeTradingName : string;
                                   aPayeeAddress1 : string;
                                   aPayeeAddress2 : string;
                                   aPayeeSuburb : string;
                                   aPayeeState : string;
                                   aPayeePostCode : string;
                                   aPayeeCountry : string;
                                   aPayerContactTelephone : string;
                                   aPayeeFinancialInstitutionBsb : string;
                                   aPayeeFinancialInstitutionAccount : string;
                                   aPayeeGrossAmountPaid : Money;
                                   aPayeeTaxWithheld : Money;
                                   aPayeeTotalGst : Money;
                                   aPayeeAmendmentIndicator : string);
    procedure WriteFileTotalDataRecord();
  end;

//------------------------------------------------------------------------------
implementation

uses
  GenUtils,
  LogUtil;

const
  UnitName = 'ATOFixedWidthFileExtract';

{ TATOFixedWidthFileExtract }
//------------------------------------------------------------------------------
function TATOFixedWidthFileExtract.RemoveMultiSpaces(aInstring: string): string;
var
  StrIndex : integer;
  LastCharIsSpace : boolean;
begin
  Result := '';
  LastCharIsSpace := false;
  for StrIndex := 1 to length(aInstring) do
  begin
    if not (aInstring[StrIndex] = ' ') then
      LastCharIsSpace := false;

    if (not LastCharIsSpace) then
      Result := Result + aInstring[StrIndex]
    else
      Result := Result;

    if aInstring[StrIndex] = ' ' then
      LastCharIsSpace := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WritePostCode(aValue: string);
var
  Data : string;
begin
  if not (Trim(aValue) = '') then
  begin
    Data := Trim(RemoveNonNumericData(aValue));
    Data := InsFillerZeros(Data, 4);
  end
  else
    Data := '9999';

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteNumericData(aValue : longword; aLength : integer);
var
  Data : string;
begin
  Data := trim(inttostr(aValue));
  Data := InsFillerZeros(Data, aLength);

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteNumericDataFromText(aValue : string; aLength : integer);
var
  Data : string;
begin
  Data := Trim(RemoveNonNumericData(aValue));
  Data := InsFillerZeros(Data, aLength);

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteAlphaNumericData(aValue : string; aLength : integer);
var
  Data : string;
begin
  Data := Trim(RemoveMultiSpaces(aValue));
  Data := AddFillerSpaces(Data, aLength);

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteAlphaData(aValue : string; aLength : integer);
var
  Data : string;
begin
  Data := Trim(RemoveMultiSpaces(aValue));
  Data := AddFillerSpaces(Data, aLength);

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteDateData(aValue : TDateTime);
var
  Year, Month, Day : word;
  YearStr, MonthStr, DayStr : string;
  Data  : string;
begin
  Decodedate(aValue, Year, Month, Day);

  YearStr := inttostr(Year);
  YearStr := InsFillerZeros(YearStr, 4);

  MonthStr := inttostr(Month);
  MonthStr := InsFillerZeros(MonthStr, 2);

  DayStr := inttostr(Day);
  DayStr := InsFillerZeros(DayStr, 2);

  // DDMMCCYY date format
  Data := DayStr + MonthStr + YearStr;

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteFillerData(aLength : integer);
var
  Data : string;
begin
  Data := '';
  Data := AddFillerSpaces(Data, aLength);

  write(fFile, Data);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteMoneyData(aValue : Money; aLength : integer);
var
  Data : longword;
begin
  Data := Trunc(aValue/100);;

  WriteNumericData(Data, aLength);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteTelphoneData(aValue : string; aLength : integer);
var
  Data : string;
begin
  Data := Trim(aValue);

  WriteAlphaNumericData(Data, aLength);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteSupplierDataRecord1(aSupplierABNNumber : string;
                                                             aRunType : char;
                                                             aReportEndDate : TDateTime);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaNumericData('IDENTREGISTER1', 14);
  WriteNumericDataFromText(aSupplierABNNumber, 11);
  WriteAlphaData(aRunType, 1);
  WriteDateData(aReportEndDate);
  WriteAlphaData('P', 1);
  WriteAlphaData('C', 1);
  WriteAlphaData('M', 1);
  WriteAlphaNumericData('FPAIVV01.0', 10);
  WriteFillerData(654);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteSupplierDataRecord2(aSupplierName : string;
                                                             aSupplierContactName : string;
                                                             aSupplierContactTelephone : string;
                                                             aSupplierfacsimile : string;
                                                             aSupplierFileReference : string);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaNumericData('IDENTREGISTER2', 14);
  WriteAlphaNumericData(aSupplierName, 200);
  WriteAlphaNumericData(aSupplierContactName, 38);
  WriteTelphoneData(aSupplierContactTelephone, 15);
  WriteTelphoneData(aSupplierfacsimile, 15);
  WriteAlphaNumericData(aSupplierFileReference, 16);
  WriteFillerData(403);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteSupplierDataRecord3(aSupplierStreetAddress1 : string;
                                                             aSupplierStreetAddress2 : string;
                                                             aSupplierStreetSuburb : string;
                                                             aSupplierStreetState : string;
                                                             aSupplierStreetPostCode : string;
                                                             aSupplierStreetCountry : string;
                                                             aSupplierPostAddress1 : string;
                                                             aSupplierPostAddress2 : string;
                                                             aSupplierPostSuburb : string;
                                                             aSupplierPostState : string;
                                                             aSupplierPostPostCode : string;
                                                             aSupplierPostCountry : string;
                                                             aSupplierEmailAddress : string);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaNumericData('IDENTREGISTER3', 14);
  WriteAlphaNumericData(aSupplierStreetAddress1, 38);
  WriteAlphaNumericData(aSupplierStreetAddress2, 38);
  WriteAlphaNumericData(aSupplierStreetSuburb, 27);
  WriteAlphaData(aSupplierStreetState, 3);
  WritePostCode(aSupplierStreetPostCode);
  WriteAlphaNumericData(aSupplierStreetCountry, 20);
  WriteAlphaNumericData(aSupplierPostAddress1, 38);
  WriteAlphaNumericData(aSupplierPostAddress2, 38);
  WriteAlphaNumericData(aSupplierPostSuburb, 27);
  WriteAlphaData(aSupplierPostState, 3);
  WritePostCode(aSupplierPostPostCode);
  WriteAlphaNumericData(aSupplierPostCountry, 20);
  WriteAlphaNumericData(aSupplierEmailAddress, 76);
  WriteFillerData(351);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WritePayerIdentityDataRecord(aPayerABNNumber : string;
                                                                 aPayerBranchNumber : string;
                                                                 aPayerFinancialYear : longword;
                                                                 aPayerName : string;
                                                                 aPayerTradingName : string;
                                                                 aPayerAddress1 : string;
                                                                 aPayerAddress2 : string;
                                                                 aPayerSuburb : string;
                                                                 aPayerState : string;
                                                                 aPayerPostCode : string;
                                                                 aPayerCountry : string;
                                                                 aPayerContactName : string;
                                                                 aPayerContactTelephone : string;
                                                                 aPayerFacimileNumber : string;
                                                                 aPayerEmailAddress : string);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaData('IDENTITY', 8);
  WriteNumericDataFromText(aPayerABNNumber, 11);

  // Branch Condition
  if aPayerBranchNumber = '' then
    aPayerBranchNumber := '001';

  WriteNumericDataFromText(aPayerBranchNumber, 3);
  WriteNumericData(aPayerFinancialYear, 4);
  WriteAlphaNumericData(aPayerName, 200);
  WriteAlphaNumericData(aPayerTradingName, 200);
  WriteAlphaNumericData(aPayerAddress1, 38);
  WriteAlphaNumericData(aPayerAddress2, 38);
  WriteAlphaNumericData(aPayerSuburb, 27);
  WriteAlphaData(aPayerState, 3);
  WritePostCode(aPayerPostCode);
  WriteAlphaNumericData(aPayerCountry, 20);
  WriteAlphaNumericData(aPayerContactName, 38);
  WriteTelphoneData(aPayerContactTelephone, 15);
  WriteTelphoneData(aPayerFacimileNumber, 15);
  WriteAlphaNumericData(aPayerEmailAddress, 76);
  WriteFillerData(1);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteSoftwareDataRecord(aSoftwareProductType : string);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaData('SOFTWARE', 8);
  WriteAlphaNumericData(aSoftwareProductType, 80);
  WriteFillerData(613);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WritePayeeDataRecord(aPayeeABNNumber : string;
                                                         aPayeeSurname : string;
                                                         aPayeeFirstGivenName : string;
                                                         aPayeeSecondGivenName : string;
                                                         aPayeeNonIndividualBusinessName : string;
                                                         aPayeeTradingName : string;
                                                         aPayeeAddress1 : string;
                                                         aPayeeAddress2 : string;
                                                         aPayeeSuburb : string;
                                                         aPayeeState : string;
                                                         aPayeePostCode : string;
                                                         aPayeeCountry : string;
                                                         aPayerContactTelephone : string;
                                                         aPayeeFinancialInstitutionBsb : string;
                                                         aPayeeFinancialInstitutionAccount : string;
                                                         aPayeeGrossAmountPaid : Money;
                                                         aPayeeTaxWithheld : Money;
                                                         aPayeeTotalGst : Money;
                                                         aPayeeAmendmentIndicator : string);
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaData('DPAIVS', 6);
  WriteNumericDataFromText(aPayeeABNNumber, 11);
  WriteAlphaNumericData(aPayeeSurname, 30);
  WriteAlphaNumericData(aPayeeFirstGivenName, 15);
  WriteAlphaNumericData(aPayeeSecondGivenName, 15);
  WriteAlphaNumericData(aPayeeNonIndividualBusinessName, 200);
  WriteAlphaNumericData(aPayeeTradingName, 200);
  WriteAlphaNumericData(aPayeeAddress1, 38);
  WriteAlphaNumericData(aPayeeAddress2, 38);
  WriteAlphaNumericData(aPayeeSuburb, 27);
  WriteAlphaData(aPayeeState, 3);
  WritePostCode(aPayeePostCode);
  WriteAlphaNumericData(aPayeeCountry, 20);
  WriteTelphoneData(aPayerContactTelephone, 15);
  WriteNumericDataFromText(aPayeeFinancialInstitutionBsb, 6);
  WriteNumericDataFromText(aPayeeFinancialInstitutionAccount, 9);
  WriteMoneyData(aPayeeGrossAmountPaid, 11);
  WriteMoneyData(aPayeeTaxWithheld, 11);
  WriteMoneyData(aPayeeTotalGst, 11);
  WriteAlphaData(aPayeeAmendmentIndicator, 1);
  WriteFillerData(30);
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.WriteFileTotalDataRecord;
begin
  inc(fTotalRecords);

  WriteNumericData(704, 3);
  WriteAlphaData('FILE-TOTAL', 10);
  WriteNumericData(fTotalRecords, 8);
  WriteFillerData(683);
end;

//------------------------------------------------------------------------------
constructor TATOFixedWidthFileExtract.Create;
begin
  fFileOpened := false;
end;

//------------------------------------------------------------------------------
destructor TATOFixedWidthFileExtract.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.OpenATOFile(aFileName: string);
begin
  if fFileOpened then
    Exit;

  AssignFile(fFile, aFileName);
  Rewrite(fFile);
  fFileOpened := true;
end;

//------------------------------------------------------------------------------
procedure TATOFixedWidthFileExtract.CloseATOFile();
begin
  if not fFileOpened then
    Exit;

  CloseFile(fFile);
  fFileOpened := false;
end;

end.
