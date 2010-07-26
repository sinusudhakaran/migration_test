unit UXlsSections;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses Classes, SysUtils, UXlsBaseRecords, UXlsBaseRecordLists, UXlsOtherRecords,
     UXlsSST, XlsMessages, UFlxMessages;
type
  TBaseSection = class
  private
    FBOF: TBOFRecord;
    FEOF: TEOFRecord;
  protected
    property sBOF: TBOFRecord read FBOF write FBOF;   //renamed to sBOF to avoid conflicts with C++Builder
    property sEOF: TEOFRecord read FEOF write FEOF;
  published
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    function TotalSize:int64; virtual;
    function TotalRangeSize(const SheetIndex: integer; const CellRange: TXlsCellRange): int64; virtual;
    procedure LoadFromStream( const DataStream: TStream; const First: TBOFRecord; const SST: TSST);virtual;abstract;
    procedure SaveToStream(const DataStream: TStream);virtual;abstract;
    procedure SaveRangeToStream(const DataStream: TStream; const SheetIndex: integer; const CellRange: TXlsCellRange);virtual; abstract;
  end;

implementation

{ TBaseSection }

procedure TBaseSection.Clear;
begin
  FreeAndNil(FBOF);
  FreeAndNil(FEOF);
end;

constructor TBaseSection.Create;
begin
  inherited;
  FBOF:=nil;
  FEOF:=nil;
end;

destructor TBaseSection.Destroy;
begin
  Clear;
  inherited;
end;

function TBaseSection.TotalRangeSize(const SheetIndex: integer; const CellRange: TXlsCellRange): int64;
begin
  Result:=sEOF.TotalSize+ sBOF.TotalSize;
end;

function TBaseSection.TotalSize: int64;
begin
  Result:=sEOF.TotalSize+ sBOF.TotalSize;
end;



end.
