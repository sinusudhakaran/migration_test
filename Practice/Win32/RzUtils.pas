unit RzUtils;

// ---------------------------------------------------------------------------
interface uses RzCmboBx, RzEdit;
// ---------------------------------------------------------------------------

Type
  TRzComboBoxHelper = class helper for TRzComboBox
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

Type
  TRzDateTimeEditHelper = class helper for TRzDateTimeEdit
  private
    function GetJulianDate: Integer;
    procedure SetJulianDate(const Value: Integer);
  published
    Property JulianDate : Integer read GetJulianDate write SetJulianDate;
  end;

// ---------------------------------------------------------------------------
implementation uses StDate;
// ---------------------------------------------------------------------------

{ TRzComboBoxHelper }

procedure TRzComboBoxHelper.AddComboItem(S: String; Value: Integer);
begin
  Items.AddObject( S, TObject( Value ) );
end;

function TRzComboBoxHelper.GetIntValue: Integer;
begin
  If ItemIndex >= 0 then
    Result := Integer( Items.Objects[ ItemIndex ] )
  else
    Result := -1;
end;

function TRzComboBoxHelper.GetObjValue: TObject;
begin
  If ItemIndex >= 0 then
    Result := Items.Objects[ ItemIndex ]
  else
    Result := NIL;
end;

function TRzComboBoxHelper.GetStrValue: String;
Begin
  If ItemIndex >= 0 then
    Result := Items[ ItemIndex ]
  else
    Result := '';
end;

function TRzComboBoxHelper.GetValue(Idx: Integer): Integer;
Begin
  If ( Idx >= 0 ) and ( Idx < Items.Count ) then
    Result := Integer( Items.Objects[ Idx ] )
  else
    Result := -1;
end;

procedure TRzComboBoxHelper.SetIntValue(Value: Integer);
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

{ TRzDateTimeEditHelper }

function TRzDateTimeEditHelper.GetJulianDate: Integer;
Begin
  If Date > 0 then
    Result := DateTimeToStDate( Date )
  else
    Result := 0;
end;

procedure TRzDateTimeEditHelper.SetJulianDate(const Value: Integer);
Begin
  If Value > 0 then
    Date := StDateToDateTime( Value )
  else
    Clear;
end;

end.

