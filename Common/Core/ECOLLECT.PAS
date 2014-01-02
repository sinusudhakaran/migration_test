unit ECollect;
//------------------------------------------------------------------------------
{
   Title:       Extended Collection Object

   Description: extended container and sorted container objects for delphi

   Author:

   Remarks:     Used by BankLink Client and Production

}
//------------------------------------------------------------------------------
interface
uses
  Windows,
  Classes,
  Sysutils;

const
  coIndexError     = -1;  { Index out of range }
  coOverflow       = -2;  { Overflow }
  coInvalidPointer = -4;  { try to add invalid pointer}
  coDuplicate      = -16; { try to add duplicate in sorted}

type
  CollException = class( Exception );

  TExtdCollection = class( TObject )
  protected
    FList  : PPointerList;
    FCount : integer; {Current Number of Items}
    FLimit : integer;

    function  At( Index : integer ) : Pointer;
    procedure AtPut( Index : integer; Item : Pointer );
    procedure Error( Code, Info : Integer ); virtual;
    procedure FreeItem( Item : Pointer ); virtual;
    procedure Grow; virtual;
    procedure SetLimit( NewLimit : integer ); virtual;
    procedure SetCount( NewCount : integer );
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AtInsert( Index : integer; Item : Pointer );
    function  Insert( Item : Pointer ) : integer; virtual;
    procedure AtFree( Index : Integer );
    procedure AtDelete( Index : integer );
    procedure Delete( Item : Pointer );
    procedure DeleteAll;
    procedure DelFreeItem( Item : Pointer );
    function  First : Integer;
    function  Last : Integer;
    procedure FreeAll; virtual;
    function  IndexOf( Item : Pointer ) : integer; virtual;

    property  Items[ Index : integer ] : pointer read At write AtPut; default;
    property  ItemCount : integer read FCount write SetCount;
    property  Limit : integer read FLimit write SetLimit;
    property  List : PPointerList read FList;
  end;

  TExtdSortedCollection = class( TExtdCollection )
  protected
    FCompare: TListSortCompare;
  public
    Duplicates : boolean;
    constructor Create; override;
    function Compare( Item1, Item2 : Pointer ) : Integer; virtual; abstract;
    function IndexOf( Item : Pointer ) : integer; override; //virtual;
    procedure Insert( Item : Pointer ); reintroduce; virtual;
    function Search( Item : Pointer; var Index : integer ) : Boolean; virtual;
    procedure Sort(DropDuplicates: Boolean = false); overload;
    procedure Sort(Compare: TListSortCompare); overload;
  end;

//******************************************************************************
implementation
{----------------------------------------------------------}
{                      Collection Object                   }
{----------------------------------------------------------}

constructor TExtdCollection.Create;
begin
  inherited Create;
  FLimit := 0;
  FCount := 0;
  FList  := nil;
end;

{----------------------------------------------------------}

destructor TExtdCollection.Destroy;
//dispose all items and resize collection to zero
begin
  FreeAll;
  SetLimit( 0 ); {resize to zero}
  inherited Destroy;
end;

{----------------------------------------------------------}

function TExtdCollection.At( Index : Integer ) : Pointer;
begin
  if ( Index < First ) or ( Index > Last ) then
  begin
    Error( coIndexError, Index );
    Result := nil;
  end
  else Result := FList^[ Index ];
end;

{----------------------------------------------------------}

procedure TExtdCollection.AtPut( Index : Integer; Item : Pointer );
//store item at index
begin
  if ( Item = nil ) then Error( coInvalidPointer, 0 );
  if ( Index < First ) or ( Index > Last ) then Error( coIndexError, Index );

  FList^[ Index ] := Item;
end;

{----------------------------------------------------------}

procedure TExtdCollection.AtDelete( Index : Integer );
//delete the pointer but don't dispose of the item
//to dispose of the item use at Free}
begin
  if ( Index < First ) or ( Index > Last ) then
  begin
    Error( coIndexError, index );
    exit;
  end;
  if Index < Last then
    move( FList^[ succ( Index ) ], FList^[ Index ], ( Fcount - index ) * sizeof( pointer ) );
  Dec( FCount );
end;

{----------------------------------------------------------}

procedure TExtdCollection.AtInsert( Index : integer; Item : pointer );
begin
  if ( Index < First ) or ( Index > FCount ) then
  begin
    Error( coIndexError, 0 );
    exit;
  end;
  if FLimit = FCount then Grow;

  if Index <> FCount then {move compensates for overlaps}
    move( FList^[ Index ], FList^[ Index + 1 ], ( Fcount - index ) * sizeof( pointer ) );
  FList^[ Index ] := Item;
  Inc( FCount );
end;

{----------------------------------------------------------}

procedure TExtdCollection.Delete( Item : pointer );
//delete item but don't free
begin
  AtDelete( Indexof( Item ) );
end;

{----------------------------------------------------------}

procedure TExtdCollection.DeleteAll;
//remove all items from the list, do not free the items
begin
  FCount := 0
end;

{----------------------------------------------------------}

procedure TExtdCollection.Error( Code, Info : Integer );
{raise exception}
begin
  case Code of
    coIndexError     : raise CollException.Create( Format( 'Index out of Range: %d', [ Info ] ) );
    coOverflow       : raise CollException.Create( Format( 'Index Overflow: %d', [ Info ] ) );
    coInvalidPointer : raise CollException.Create( 'Trying to add NIL pointer' );
    coDuplicate      : raise CollException.Create( 'Trying to add duplicate key' );
  end
end;

{----------------------------------------------------------}

function TExtdCollection.First : Integer;
begin
  Result := 0; { First Item in the Collection }
end;

{----------------------------------------------------------}

procedure TExtdCollection.DelFreeItem( Item : Pointer );
{delete and dispose of item}
begin
  Delete( Item );
  FreeItem( Item );
end;

{----------------------------------------------------------}

procedure TExtdCollection.FreeAll;
//free all the items in the list and set the count to zero
var
  i : integer;
begin
  for I := First to Last do FreeItem( At( I ) );
  SetCount( 0 );
end;

{----------------------------------------------------------}

procedure TExtdCollection.FreeItem( Item : Pointer );
begin
  if Item <> nil then TObject( Item ).Free;
end;

{----------------------------------------------------------}

function TExtdCollection.IndexOf( Item : Pointer ) : integer;
var
  i : integer;
begin
  Result := -1;
  for i := First to Last do
    if Item = FList^[ i ] then
    begin
      Result := i;
      break
    end
end;

{----------------------------------------------------------}

function TExtdCollection.Insert( Item : Pointer ) : integer;
begin
  if ( Item = nil ) then Error( coInvalidPointer, 0 );
  Result := FCount;
  AtInsert( FCount, Item );
end;

{----------------------------------------------------------}

function TExtdCollection.Last : Integer;
begin
  Result := FCount - 1; { Last Item in the Collection }
end;

{----------------------------------------------------------}

procedure TExtdCollection.Grow;
var
  Delta : integer;
begin
  if FLimit > 64 then delta := FLimit div 8 else
    if FLimit > 16 then delta := 8 else
      Delta := 4;

  if Delta > 8192 then delta := 8192; {max growth 8k}
  SetLimit( FLimit + delta );
end;

{----------------------------------------------------------}

procedure TExtdCollection.SetLimit( newLimit : Integer );
begin
  if ( newLimit < FCount ) or ( newLimit > MaxListSize ) then Error( coOverFlow, newLimit );
  if newLimit <> FLimit then
  begin
    ReallocMem( FList, newLimit * SizeOf( Pointer ) );
    FLimit := newLimit;
  end;
end;

{----------------------------------------------------------}

procedure TExtdCollection.SetCount( newCount : integer );
begin
  if ( newCount < 0 ) or ( NewCount > MaxListSize ) then Error( coOverFlow, NewCount );
  if NewCount > FLimit then SetLimit( NewCount );
  if NewCount > FCount then FillChar( FList^[ FCount ], ( NewCount - FCount ) * SizeOF( Pointer ), 0 );
  FCount := NewCount;
end;

{----------------------------------------------------------}

procedure TExtdCollection.AtFree( Index : Integer );
{deletes and disposes the item given by index}
var
  Item : Pointer;
begin
  Item := At( Index );
  AtDelete( Index );
  FreeItem( Item );
end;

{----------------------------------------------------------}
{              Sorted Collection Object                    }
{----------------------------------------------------------}

constructor TExtdSortedCollection.Create;
begin
  inherited Create;
  Duplicates := false;
  FCompare := nil;
end;

function TExtdSortedCollection.IndexOf( Item : Pointer ) : Integer;
var
  i : Integer;
begin
  {binary search}
  result := -1;
  if Search( Item, i ) then
  begin
    if Duplicates then
      while ( i < FCount ) and ( Item <> FList^[ I ] ) do Inc( i );
    if i < FCount then result := i;
  end;
end;

{----------------------------------------------------------}

procedure TExtdSortedCollection.Insert( Item : Pointer );
var
  i : integer;
  found : boolean;
begin
  found := Search( Item, I );
  if ( found and ( not Duplicates ) ) then
  begin //raise exception if trying to add duplicate
    Error( coDuplicate, 0 );
  end
  else
    AtInsert( I, Item );
end;

{----------------------------------------------------------}

function TExtdSortedCollection.Search;
var
  L, H, I, C : Integer;
begin
  Search := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := ( L + H ) shr 1;
    //Use a custom compare is one is assigned
    if Assigned(FCompare) then
      C := FCompare( Item, FList^[ I ] )
    else
      C := Compare( Item, FList^[ I ] );
    if C > 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Search := True;
        if not Duplicates then L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TExtdSortedCollection.Sort(Compare: TListSortCompare);
begin
  FCompare := Compare;
  Sort;
end;

procedure TExtdSortedCollection.Sort(DropDuplicates: Boolean = false);
var LL: PPointerList;
    I,K,P: Integer;

begin
    K := ItemCount;
    getmem(LL,K * Sizeof(Pointer));
    Move(FList^,LL^,K * Sizeof(Pointer));
    ItemCount := 0;
    for I := 0 to k-1 do
      if DropDuplicates
      and (Search(LL[I],P)) then
         FreeItem(LL[I])
      else
         Insert(LL[I]);
    Freemem(LL,K * Sizeof(Pointer));   
end;

{----------------------------------------------------------}
end.

