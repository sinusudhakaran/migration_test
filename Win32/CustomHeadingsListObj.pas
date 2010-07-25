unit CustomHeadingsListObj;
//------------------------------------------------------------------------------
{
   Title:       Custom Headings List Object

   Description: Stores a list of custom heading objects.  The heading list is used
                to store Sub Group Headings and Division headings.

   Author:      Matthew Hopkins  Jun 2002

   Remarks:     The custom headings list is basically a list of pointers.  Normally
                all items in the list are of the same type, however I have choosen
                to make the list generic so that it can hold different types of
                headings.

                The list is designed to hold objects that descend from a base
                object.  The base object defines a number of abstract methods
                that are used to load, sort and save each of the elements in the
                list.

                Elements in the list are accessed through specific set and get
                routines that allow you to retrieve or set a specific type of
                heading.

                Each object in the list must be able to tell you its sort key.
                The first element in the sort key is the "type" of heading that
                this element represents.

                A class function has been added so that a sort key can be obtained
                for a particular type of object without actually creating that object.
}
//------------------------------------------------------------------------------

interface
uses
  eCollect,
  IOSTREAM,
  BKDEFS;

type
  TPointerListBaseObj = class
    constructor Create;
    destructor  Destroy; override;
  private
    procedure VerifyRecord;                      virtual; abstract;
  public
    function  SortKey : string;                  virtual; abstract;
    procedure SaveToFile( Var S : TIOStream );   virtual; abstract;
    procedure LoadFromFile( Var S : TIOStream ); virtual; abstract;
    procedure UpdateCRC( var CRC : LongWord);    virtual; abstract;

    class function ClassSortKey : string; virtual; abstract;
  end;

  TSubGroupHeading = class( TPointerListBaseObj)
  private
    procedure VerifyRecord;                      override;
  public
    shFields : tSubGroup_Heading_Rec;

    function  SortKey : string;                  override;
    procedure SaveToFile( Var S : TIOStream );   override;
    procedure LoadFromFile( Var S : TIOStream ); override;
    procedure UpdateCRC( var CRC : LongWord);    override;

    class function ClassSortKey( ReportGroupNo : integer; SubGroupNo : integer) : string; reintroduce;
  end;

  TDivisionHeading = class( TPointerListBaseObj)
  private
    procedure VerifyRecord;                      override;
  public
    dhFields : tDivision_Heading_Rec;

    function  SortKey : string;                  override;
    procedure SaveToFile( Var S : TIOStream );   override;
    procedure LoadFromFile( Var S : TIOStream ); override;
    procedure UpdateCRC( var CRC : LongWord);    override;

    class function ClassSortKey( DivisionNo : integer) : string; reintroduce;
  end;

{
   A simple list object to hold the report headings. Each item in the list is a pointer pCustom_Heading_Rec that
   points to a TCustom_Heading_Rec structure:
}

type
  tNew_Custom_Headings_List = class ( TExtdCollection )
  protected
    procedure FreeItem(Item : Pointer); override;
    function  Custom_Heading_At(Index : Integer): pCustom_Heading_Rec;
    function  Find_Heading( const HeadingType, MajorID, MinorID : integer ): pCustom_Heading_Rec;
  public
    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S : TIOStream);
    procedure UpdateCRC(var CRC : LongWord);
    procedure CheckIntegrity;

    function    Get_SubGroup_Heading( const SubGroupNo : integer ) : string;
    procedure   Set_SubGroup_Heading( const SubGroupNo : integer; Heading : string );

    function    Get_Division_Heading( const DivisionNo : integer) : string;
    procedure   Set_Division_Heading( const DivisionNo : integer; Heading : string);
  end;

//******************************************************************************
implementation
uses
  bk5Except,
  bkcrc,
  bkdbExcept,
  GenUtils,
  LogUtil,
  bkshio,
  bkdhio,
  bkhdio,
  malloc,
  SysUtils,
  Tokens;

const
  Unitname = 'CustomHeadingsListObj';

const
  htBase            = 0;
  htSubGroupHeading = 1;
  htDivisionHeading = 2;

  SUnknownToken = 'HDList Error: Unknown token %d';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TPointerListBaseObj }

constructor TPointerListBaseObj.Create;
begin
  inherited Create;
end;

destructor TPointerListBaseObj.Destroy;
begin
  inherited;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TSubGroupHeading }

class function TSubGroupHeading.ClassSortKey(ReportGroupNo,
  SubGroupNo: integer): string;
begin
  result := LongToKey( htSubGroupHeading) +
            LongtoKey( ReportGroupNo) +
            LongtoKey( SubGroupNo);
end;

procedure TSubGroupHeading.LoadFromFile(var S: TIOStream);
begin
  Read_SubGroup_Heading_Rec( shFields, s);
end;

procedure TSubGroupHeading.SaveToFile(var S: TIOStream);
begin
  Write_SubGroup_Heading_Rec( shFields, S);
end;

function TSubGroupHeading.SortKey: string;
begin
  result := LongToKey( htSubGroupHeading) +
            LongtoKey( shFields.shReport_Group_No) +
            LongtoKey( shFields.shSub_Group_No);
end;

procedure TSubGroupHeading.UpdateCRC(var CRC: LongWord);
begin
  BKCRC.UpdateCRC( shFields, CRC);
end;

procedure TSubGroupHeading.VerifyRecord;
var
  P : Pointer;
begin
  P := @Self.shFields;
  bkshio.IsASubGroup_Heading_Rec( P);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TDivisionHeading }

class function TDivisionHeading.ClassSortKey(DivisionNo: integer): string;
begin
  result := LongToKey( htDivisionHeading) +
            LongtoKey( DivisionNo);
end;

procedure TDivisionHeading.LoadFromFile(var S: TIOStream);
begin
  Read_Division_Heading_Rec( dhFields, S);
end;

procedure TDivisionHeading.SaveToFile(var S: TIOStream);
begin
  Write_Division_Heading_Rec( dhFields, S);
end;

function TDivisionHeading.SortKey: string;
begin
  result := LongToKey( htDivisionHeading) +
            LongtoKey( dhFields.dhDivision_No);
end;

procedure TDivisionHeading.UpdateCRC(var CRC: LongWord);
begin
  BKCRC.UpdateCRC( dhFields, CRC);
end;

procedure TDivisionHeading.VerifyRecord;
var
  P : Pointer;
begin
  P := @Self.dhFields;
  bkdhio.IsADivision_Heading_Rec( P);
end;

{ tNew_Custom_Headings_List }

procedure tNew_Custom_Headings_List.CheckIntegrity;
var
  i : integer;
begin
  for i := First to Last do
    with Custom_Heading_At( i )^ do;
end;

function tNew_Custom_Headings_List.Custom_Heading_At(
  Index: Integer): pCustom_Heading_Rec;
var
  P: Pointer;
begin
  result := nil;
  P := At( Index );
  if BKHDIO.IsACustom_Heading_Rec( P ) then
    result := P;
end;

function tNew_Custom_Headings_List.Find_Heading(const HeadingType, MajorID, MinorID: integer): pCustom_Heading_Rec;
Var
  i : Integer;
  P : pCustom_Heading_Rec;
begin
  Result := NIL;
  For i := 0 to Pred( ItemCount ) do
  Begin
    P := Custom_Heading_At( i );
    If ( P^.hdHeading_Type = HeadingType ) and
       ( P^.hdMajor_ID = MajorID ) and
       ( P^.hdMinor_ID = MinorID ) then
    Begin
      Result := P;
      exit;
    end;
  end;
end;

procedure tNew_Custom_Headings_List.FreeItem(Item: Pointer);
begin
  if BKHDIO.IsACustom_Heading_Rec( Item ) then
  begin
     BKhdIO.Free_Custom_Heading_Rec_Dynamic_Fields( pCustom_Heading_Rec( Item)^ );
     SafeFreeMem( Item, Custom_Heading_Rec_Size );
  end;
end;

function tNew_Custom_Headings_List.Get_Division_Heading(
  const DivisionNo: integer): string;
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htDivisionHeading, DivisionNo, 0 );
  If Assigned( P ) then
    Result := P^.hdHeading
  else
    Result := '';
end;

function tNew_Custom_Headings_List.Get_SubGroup_Heading(
  const SubGroupNo: integer): string;
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htSubgroupHeading, 0, SubGroupNo );
  If Assigned( P ) then
    Result := P^.hdHeading
  else
    Result := '';
end;

procedure tNew_Custom_Headings_List.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  pH: pCustom_Heading_Rec;
begin
  Token := S.ReadToken;
  while ( Token <> tkEndSection ) do
  begin
    case Token of
      tkBegin_Custom_Heading :
        begin
          pH := New_Custom_Heading_Rec;
          Read_Custom_Heading_Rec( pH^, S );
          Insert( pH );
        end;
      else
        Raise Exception.CreateFmt( SUnknownToken, [ Token ] );
    end; { of Case }
    Token := S.ReadToken;
  end;
end;

procedure tNew_Custom_Headings_List.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
  S.WriteToken( tkBeginCustomHeadingsListEx );
  for i := 0 to Pred( ItemCount ) do BKHDIO.Write_Custom_Heading_Rec( Custom_Heading_At( i )^, S );
  S.WriteToken( tkEndSection );
end;

procedure tNew_Custom_Headings_List.Set_Division_Heading(
  const DivisionNo: integer; Heading: string);
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htDivisionHeading, DivisionNo, 0 );

  If ( Trim( Heading ) = '' ) then
  begin { Deletion }
    If Assigned( P ) then
      DelFreeItem( P );
    exit;
  end;

  If Assigned( P ) then
  Begin { Change Current Heading }
    P^.hdHeading := Trim( Heading );
    exit;
  end;

  { Add a new Heading}
  P := New_Custom_Heading_Rec;
  P^.hdHeading_Type     := htDivisionHeading;
  P^.hdMajor_ID         := DivisionNo;
  P^.hdMinor_ID         := 0;
  P^.hdHeading          := Trim( Heading );
  Insert( P );
end;

procedure tNew_Custom_Headings_List.Set_SubGroup_Heading(
  const SubGroupNo: integer; Heading: string);
Var
  P : pCustom_Heading_Rec;
begin
  P := Find_Heading( htSubgroupHeading, 0, SubGroupNo );

  If ( Trim( Heading ) = '' ) then
  begin { Deletion }
    If Assigned( P ) then
      DelFreeItem( P );
    exit;
  end;

  If Assigned( P ) then
  Begin { Change Current Heading }
    P^.hdHeading := Trim( Heading );
    exit;
  end;

  { Add a new Heading}
  P := New_Custom_Heading_Rec;
  P^.hdHeading_Type     := htSubgroupHeading;
  P^.hdMajor_ID         := 0;
  P^.hdMinor_ID         := SubGroupNo;
  P^.hdHeading          := Trim( Heading );
  Insert( P );
end;

procedure tNew_Custom_Headings_List.UpdateCRC(var CRC: LongWord);
var
  i: Integer;
begin
  for i := 0 to Pred( ItemCount ) do
    BKCRC.UpdateCRC( Custom_Heading_At( i )^, CRC );
end;

end.
