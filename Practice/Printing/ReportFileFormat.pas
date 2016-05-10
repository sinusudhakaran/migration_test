unit ReportFileFormat;

//------------------------------------------------------------------------------
interface

uses
  Classes;

type
  //----------------------------------------------------------------------------
  TReportFileFormat = class
  private
    fExcelVer : single;
  protected
    function GetName(aIndex : integer) : string;
    function GetExtension(aIndex : integer) : string;

    procedure UpdateExcelVersion();
    function UseXLSXasExcelFormat() : boolean;
  public
    constructor Create();

    property Names[Index: Integer]: string read GetName;
    property Extensions[Index: Integer]: string read GetExtension;
  end;

  //------------------------------------------------------------------
  function RptFileFormat : TReportFileFormat;

//------------------------------------------------------------------------------
implementation

uses
  OfficeDM,
  SysUtils,
  LogUtil,
  bkConst,
  OpExcel;

const
  UnitName = 'ReportFileFormat';

var
  fRptFileFormat : TReportFileFormat;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function RptFileFormat : TReportFileFormat;
begin
  if not assigned(fRptFileFormat) then
  begin
    fRptFileFormat := TReportFileFormat.Create;
  end;

  result := fRptFileFormat;
end;

{ TReportFileFormat }
//------------------------------------------------------------------------------
function TReportFileFormat.GetName(aIndex: integer): string;
begin
  case aIndex of
    rfCSV        : Result := 'Comma Separated (CSV)';
    rfFixedWidth : Result := 'Fixed Width Text (TXT)';
    rfExcel      : begin
      if UseXLSXasExcelFormat then
        Result := 'Microsoft Excel (XLSX)'
      else
        Result := 'Microsoft Excel (XLS)';
    end;
    rfPDF        : Result := 'Adobe Acrobat Format (PDF)';
    rfAcclipse   : Result := 'CCH Web Manager';
  end;
end;

//------------------------------------------------------------------------------
function TReportFileFormat.UseXLSXasExcelFormat: boolean;
begin
  Result := (fExcelVer >= 12); // Excel 2007 (v12.0) uses xlsx as the default
end;

//------------------------------------------------------------------------------
function TReportFileFormat.GetExtension(aIndex: integer): string;
begin
  case aIndex of
    rfCSV        : Result := '.CSV';
    rfFixedWidth : Result := '.TXT';
    rfExcel      : begin
      if UseXLSXasExcelFormat then
        Result := '.XLSX'
      else
        Result := '.XLS';
    end;
    rfPDF        : Result := '.PDF';
    rfAcclipse   : Result := '.PDF';
  end;
end;

//------------------------------------------------------------------------------
procedure TReportFileFormat.UpdateExcelVersion;
var
  OfficeDataModule : TDataModuleOffice;
begin
  try
    OfficeDataModule := TDataModuleOffice.Create( nil);
    try
      OfficeDataModule.OpExcel1.Visible := False;
      OfficeDataModule.OpExcel1.Interactive := False;
      OfficeDataModule.OpExcel1.Connected := true;
      fExcelVer := StrToFloat(OfficeDataModule.OpExcel1.Server.Version[0]);

    finally
      FreeAndNil(OfficeDataModule);
    end;
  except
    fExcelVer := 0;
  end;
end;

//------------------------------------------------------------------------------
constructor TReportFileFormat.Create;
begin
  UpdateExcelVersion;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  fRptFileFormat := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fRptFileFormat);
end;

end.
