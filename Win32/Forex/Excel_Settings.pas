unit Excel_Settings;

//-----------------------------------------------------------------------------
interface

uses

Classes;

{$TYPEINFO ON}

Type
  TExcelFileInfo = Class
  private
    fFileName : String;
    FWorksheet_Name: String;
    FBase_Currency: String;
    FData_Source: String;
    FDescription: String;
    FColumn_Names: String;
    FData_Starts_In_Row: Integer;
    procedure SetWorksheet_Name(const Value: String);
    procedure SetBase_Currency(const Value: String);
    procedure SetData_Source(const Value: String);
    procedure SetDescription(const Value: String);
    procedure SetColumn_Names(const Value: String);
    procedure SetData_Starts_In_Row(const Value: Integer);
  Public
    Function Load( FileName : String ): Boolean;
    Procedure Save;
    Property INIFileName : String Read fFileName;
  Published
    Property Worksheet_Name : String read FWorksheet_Name write SetWorksheet_Name; // Forex Lookup
    Property Base_Currency : String read FBase_Currency write SetBase_Currency; // NZD
    Property Data_Source : String read FData_Source write SetData_Source; // Staples Rodway
    Property Description : String read FDescription write SetDescription; // Daily Rates ex National Bank
    Property Column_Names : String read FColumn_Names write SetColumn_Names; //
    Property Data_Starts_In_Row : Integer read FData_Starts_In_Row write SetData_Starts_In_Row;
  end;

implementation

uses
   clSerializers,
   clRTTI,
   SysUtils;
//-----------------------------------------------------------------------------

{ TExcelFileInfo }

function TExcelFileInfo.Load(FileName: String): Boolean;
begin
  fFileName := FileName;
  if FileExists( FileName ) then
  Begin
    IniSerializer.LoadObjFromIniFile( Self, fFileName, 'Currency Conversion Settings' );
    Result := True;
  end
  else
    Result := False;
end;

procedure TExcelFileInfo.Save;
begin
  IniSerializer.SaveObjToIniFile( Self, fFileName, 'Currency Conversion Settings' );
end;

procedure TExcelFileInfo.SetBase_Currency(const Value: String);
begin
  FBase_Currency := Value;
end;

procedure TExcelFileInfo.SetColumn_Names(const Value: String);
begin
  FColumn_Names := Value;
end;

procedure TExcelFileInfo.SetData_Source(const Value: String);
begin
  FData_Source := Value;
end;

procedure TExcelFileInfo.SetData_Starts_In_Row(const Value: Integer);
begin
  FData_Starts_In_Row := Value;
end;

procedure TExcelFileInfo.SetDescription(const Value: String);
begin
  FDescription := Value;
end;

procedure TExcelFileInfo.SetWorksheet_Name(const Value: String);
begin
  FWorksheet_Name := Value;
end;

end.
