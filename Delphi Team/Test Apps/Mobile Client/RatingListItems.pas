unit RatingListItems;

interface

uses
  FMX.Objects,
  FMX.Graphics,
  FMX.ListView.Types,
  Generics.Collections;

type

  TListItemCodingIcon = class( TListItemObject )
  private
    FCodingType: Integer;
    FRatingPaths: TObjectList<TPathData>;
  public
    constructor Create( const AOwner: TListItem ); override;
    destructor Destroy; override;

    procedure Render( const Canvas: TCanvas; const DrawItemIndex: Integer;
                      const DrawStates: TListItemDrawStates;
                      const SubPassNo: Integer = 0 ); override;

    property CodingType: Integer read FCodingType write FCodingType;
  end;

implementation

uses
  System.UITypes;


{=================================}
{== TListItemRatingIcon Methods ==}
{=================================}

constructor TListItemCodingIcon.Create( const AOwner: TListItem );
var
  PathData: TPathData;
begin
  inherited;

  Align := TListItemAlign.Trailing;
  VertAlign := TListItemAlign.Center;
  PlaceOffset.Y := 0;
  Width := 16;
  Height := 16;
  CodingType := 0;
  FRatingPaths := TObjectList<TPathData>.Create;
  FRatingPaths.Capacity := 5;

  PathData := TPathData.Create;
  PathData.Data := 'M2002,0 C3107,0 4003,896 4003,2002 C4003,3107 3107,4003 2002,4003 C896,4003 0,3107 0,2002 C0,896 896,0 2002,0 Z';
  FRatingPaths.Add( PathData );

  PathData := TPathData.Create;
  PathData.Data := 'M3000,998 C4106,998 5002,1894 5002,3000 C5002,4106 4106,5002 3000,5002 C1894,5002 998,4106 998,3000 C998,1894 1894,998 3000,998 Z M3000,1448 C3857,1448 4552,2143 4552,3000 L1448,3000 C1448,2143 2143,1448 3000,1448 Z';
  FRatingPaths.Add( PathData );

  PathData := TPathData.Create;
  PathData.Data := 'M2002,0 C3107,0 4003,896 4003,2002 C4003,3107 3107,4003 2002,4003 C896,4003 0,3107 0,2002 C0,896 896,0 2002,0 Z M2002,450 C2859,450 3554,1145 3554,2002 C3554,2859 2859,3554 2002,3554 C1145,3554 450,2859 450,2002 C450,1145 1145,450 2002,450 Z';
  FRatingPaths.Add( PathData );

  PathData := TPathData.Create;
  PathData.Data := 'M2002,0 C3107,0 4003,896 4003,2002 C4003,3107 3107,4003 2002,4003 C896,4003 0,3107 0,2002 C0,896 896,0 2002,0 Z M3554,2002 C3554,2859 2859,3554 2002,3554 C1145,3554 450,2859 450,2002 L3554,2002 Z';
  FRatingPaths.Add( PathData );

  PathData := TPathData.Create;
  PathData.Data := 'M2002,0 C3107,0 4003,896 4003,2002 C4003,3107 3107,4003 2002,4003 C896,4003 0,3107 0,2002 C0,896 896,0 2002,0 Z M2002,1513 C2272,1513 2490,1732 2490,2002 C2490,2272 2272,2490 2002,2490 C1732,2490 1513,2272 1513,2002 C1513,1732 1732,1513 2002,1513 Z';
  FRatingPaths.Add( PathData );
end;


destructor TListItemCodingIcon.Destroy;
begin
  FRatingPaths.Free;
  inherited;
end;

procedure TListItemCodingIcon.Render( const Canvas: TCanvas; const DrawItemIndex: Integer;
                                      const DrawStates: TListItemDrawStates;
                                      const SubPassNo: Integer );
var
  PathData: TPathData;
begin
  if SubPassNo <> 0 then
    Exit;
  if FCodingType < 1 then
    Exit;

  PathData := FRatingPaths.Items[ FCodingType - 1 ];

  case FCodingType of
    0 : Canvas.Fill.Color := TAlphaColors.Aliceblue;
    1 : Canvas.Fill.Color := TAlphaColors.Purple;
    2 : Canvas.Fill.Color := TAlphaColors.Green;
    3 : Canvas.Fill.Color := TAlphaColors.Brown;
  end;

  PathData.FitToRect( LocalRect );
  Canvas.FillPath( PathData, 1.0 );
end;


end.
