unit MigrateStats;

interface
uses
   MigrateTable,
   VirtualTrees,
   VirtualTreeHandler;


type

TMigrateTableStat = class (TTreeBaseItem)
  private
    FTable: TMigrateTable;
    procedure SetTable(const Value: TMigrateTable);

  public
    property Table: TMigrateTable read FTable write SetTable;
    function GetTagText(const Tag: Integer): string; override;
end;

implementation

uses
sysUtils;

const
 t_Name = 0;
 t_Count = 2;

{ TMigrateAction }


{ TMigrateTableStat }

function TMigrateTableStat.GetTagText(const Tag: Integer): string;
begin
  if not assigned(FTable) then
     Exit;
  case tag of
  t_Name : Result := FTable.Tablename;
  t_Count : Result := IntToStr(FTable.Count);
  end;
end;

procedure TMigrateTableStat.SetTable(const Value: TMigrateTable);
begin
  FTable := Value;
end;

end.
