unit StringListHelper;

interface

uses Classes;

{ Class Helpers }

type
  TStringsHelper = class helper for TStrings
  private
    function GetID(Index: Integer): Integer;
    procedure SetID(Index: Integer; const Value: Integer);
    function GetDescFromID(ID: Integer): string;
    function GetIDFromDesc(const Desc: string): Integer;
  public
    function AddID(const Desc: string; PrimaryKey: Integer ): Integer;
    function ContainsString(const Text: string): boolean;
    function IndexOfID( ID: Integer ): integer;
    property DescFromID[ID:Integer]: string read GetDescFromID;
    property IDFromDesc[const Desc: string]: Integer read GetIDFromDesc;
    property IDs[Index: Integer]: Integer read GetID write SetID;
  end;


implementation uses SysUtils;

{ TStringsHelper }

function TStringsHelper.ContainsString(const Text: string): boolean;
begin
  Result := self.IndexOf(Text) <> -1;
end;

function TStringsHelper.AddID(const Desc: string; PrimaryKey: Integer ): Integer;
begin
  // Store in the object pointer
  result := AddObject(Desc, TObject(PrimaryKey));
end;

function TStringsHelper.GetDescFromID(ID: Integer): string;
var
  index: integer;
begin
  index := IndexOfObject( TObject(ID) );
  Assert( index <> -1, 'Cannot find ID ' + IntToStr(ID) + ' in List' );
  result := Strings[ index ];
end;

function TStringsHelper.GetID(Index: Integer): Integer;
begin
  result := Integer( Objects[index] );
end;

function TStringsHelper.GetIDFromDesc(const Desc: string): Integer;
begin
  result := IDs[IndexOf(Desc)];
end;

function TStringsHelper.IndexOfID(ID: Integer): integer;
begin
  result := IndexOfObject( TObject(ID) );
end;

procedure TStringsHelper.SetID(Index: Integer; const Value: Integer);
begin
  Objects[ index ] := TObject( value );
end;

{ TStreamHelper }
end.

