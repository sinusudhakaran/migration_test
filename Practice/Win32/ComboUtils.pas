unit ComboUtils;
//------------------------------------------------------------------------------
{
   Title:       Combo Box Utilities

   Description:

   Author:      Matthew Hopkins Jul 2002

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  StdCtrls;

Type
  TComboBoxHelper = class helper for TComboBox
  private
    Function GetIntValue: Integer;
    Procedure SetIntValue( Value : Integer );
    Function GetValue( Idx : Integer ): Integer;
  public
    Function GetObjValue: TObject;
    Function GetStrValue: String;
    Procedure AddComboItem( S : String; Value : Integer );
    Property IntValue : Integer read GetIntValue write SetIntValue;
  end;

procedure SetComboIndexByIntObject( const Value: integer; const aCombo: TComboBox; Forced: Boolean = False);
function GetComboCurrentIntObject( const aCombo : TComboBox; Default: Integer = -1) : integer;

implementation

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetComboIndexByIntObject( const Value : integer; const aCombo : TComboBox; Forced: Boolean = False);
//used for location the item index of a combo by matching up an integer that
//has been stored in the Objects[] property.
var
   i : integer;
begin
   for i := 0 to Pred( aCombo.Items.Count) do
      if Integer( aCombo.Items.Objects[ i]) = Value then begin
         aCombo.ItemIndex := i;
         exit;
      end;
   // Still here .. Not Found
   if Forced then
      aCombo.ItemIndex := -1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetComboCurrentIntObject( const aCombo : TComboBox; Default: Integer = -1) : integer;
//returns the integer that has been stored in the Objects[] property
//returns default if no item selected
begin
   if aCombo.ItemIndex > -1 then
      result := Integer( aCombo.Items.Objects[ aCombo.ItemIndex])
   else
      result := Default;
end;

{ TComboBoxHelper }

procedure TComboBoxHelper.AddComboItem(S: String; Value: Integer);
begin
  Items.AddObject( S, TObject( Value ) );
end;

function TComboBoxHelper.GetIntValue: Integer;
begin
  If ItemIndex >= 0 then
    Result := Integer( Items.Objects[ ItemIndex ] )
  else
    Result := -1;
end;

function TComboBoxHelper.GetObjValue: TObject;
begin
  If ItemIndex >= 0 then
    Result := Items.Objects[ ItemIndex ]
  else
    Result := NIL;
end;

function TComboBoxHelper.GetStrValue: String;
begin
  If ItemIndex >= 0 then
    Result := Items[ ItemIndex ]
  else
    Result := '';
end;

function TComboBoxHelper.GetValue(Idx: Integer): Integer;
begin
  If ( Idx >= 0 ) and ( Idx < Items.Count ) then
    Result := Integer( Items.Objects[ Idx ] )
  else
    Result := -1;
end;

procedure TComboBoxHelper.SetIntValue(Value: Integer);
Var
  Idx : Integer;
Begin
  For Idx := 0 to Items.Count-1 do
  Begin
    If GetValue( Idx ) = Value then
    Begin
      ItemIndex := Idx;
      exit;
    end;
  end;
  ItemIndex := -1;
end;

end.
 