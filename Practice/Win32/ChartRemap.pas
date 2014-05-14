unit ChartRemap;

interface

uses
  Windows,
  SysUtils,
  Classes;

type
  //----------------------------------------------------------------------------
  TChartRemap = class
  private
  public
    function LoadChartGstFile(var aFileLines : TStringList; const aFileName : string; var aError : string) : Boolean;
  end;

const
  // Columns in the file..
  fcOldCode = 0;
  fcOldName = 1;
  fcNewCode = 2;
  fcNewName = 3;
  fcNewPost = 4;

//------------------------------------------------------------------------------
function ChartRemapLib() : TChartRemap;

implementation

var
  fChartRemap : TChartRemap;

//------------------------------------------------------------------------------
function ChartRemapLib() : TChartRemap;
begin
  if not Assigned(fChartRemap) then
    fChartRemap := TChartRemap.Create;

  Result := fChartRemap;
end;

{ TChartRemap }


//------------------------------------------------------------------------------
initialization
  fChartRemap := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil( fChartRemap );

end.
