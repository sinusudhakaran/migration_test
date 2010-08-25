unit BKDBLookupComboBox;

interface

uses
  Windows,
  SysUtils,
  Forms,
  Messages,
  Classes,
  Controls,
  StdCtrls,
  Variants,
  DB,
  DBCtrls,
  RzCmboBx,
  Menus,
  RzDBCmbo;

type
  TBKDBLookupComboBox = class(TRzDBLookupComboBox)
  private

    FOriginalFilter: string;
    FDropDownFilter: string;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure SetOriginalFilter;
    procedure SetDropDownFilter(const Value: string);
    function GetDropDownFilter: string;
    function GetCurrentValue: string;
    procedure SetCurrentValue(const Value: string);
    function GetItemsAsText: string;
    function GetKeyFieldsAsText: string;
    { Private declarations }
  protected
    { Protected declarations }
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CMEnter(var Msg: TCMEnter); message cm_Enter;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure DropDown; override;
    procedure CloseUp(Accept: Boolean); override;
  published
    { Published declarations }
    property DropDownFilter: string read GetDropDownFilter write
      SetDropDownFilter;
    property CurrentValue: string read GetCurrentValue write SetCurrentValue;
    property ItemsAsText: string read GetItemsAsText;
    property KeyFieldsAsText: string read GetKeyFieldsAsText;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKDBLookupComboBox]);
end;

{ TBKDBLookupComboBox }

procedure TBKDBLookupComboBox.CloseUp(Accept: Boolean);
var
  fld: TField;
begin
  inherited;
  if (DataField <> '') and Assigned(DataSource) and Assigned(DataSource.DataSet)
    and (FDropDownFilter <> '') then
    begin
      fld := DataSource.DataSet.FindField(DataField);
      //if we are using a lookup field then apply the filter to the lookup field dataset
      if Assigned(fld.LookupDataSet) then
        begin
          fld.LookupDataSet.Filter := FOriginalFilter;
          fld.LookupDataSet.Filtered := (FOriginalFilter <> '');
          fld.RefreshLookupList;
        end
      else
        begin
          ListSource.DataSet.Filter := FOriginalFilter;
          ListSource.DataSet.Filtered := (FOriginalFilter <> '');
        end;
    end;
end;

procedure TBKDBLookupComboBox.DropDown;
var
  fld: TField;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) and (FDropDownFilter
    <> '') then
    begin
      //SetOriginalFilter;
      fld := DataSource.DataSet.FindField(DataField);
      if Assigned(fld) then
        //if we are using a lookup field then apply the filter to the lookup field dataset
        if Assigned(fld.LookupDataSet) then
          begin
            if FOriginalFilter <> '' then
              fld.LookupDataSet.Filter := FOriginalFilter + ' and ' +
                FDropDownFilter
            else
              fld.LookupDataSet.Filter := FDropDownFilter;
            fld.LookupDataSet.Filtered := true;
            fld.RefreshLookupList;
          end
        else
          begin
            if FOriginalFilter <> '' then
              ListSource.DataSet.Filter := FOriginalFilter + ' and ' +
                FDropDownFilter
            else
              ListSource.DataSet.Filter := FDropDownFilter;
            ListSource.DataSet.Filtered := true;
          end;
    end;
  inherited;
end;

function TBKDBLookupComboBox.GetDropDownFilter: string;
begin
  Result := FDropDownFilter;
end;

function TBKDBLookupComboBox.GetItemsAsText: string;
var
  fld: TField;
  sl: TStringList;
begin
  Result := '';
  sl := TStringList.Create;
  try
    if Assigned(DataSource) and Assigned(DataSource.DataSet) then
      begin
      //SetOriginalFilter;
        fld := DataSource.DataSet.FindField(DataField);
        if Assigned(fld) then
        //if we are using a lookup field then apply the filter to the lookup field dataset
          if Assigned(fld.LookupDataSet) then
            begin
              if (FDropDownFilter <> '') then
                begin
                  if FOriginalFilter <> '' then
                    fld.LookupDataSet.Filter := FOriginalFilter + ' and ' +
                      FDropDownFilter
                  else
                    fld.LookupDataSet.Filter := FDropDownFilter;
                  fld.LookupDataSet.Filtered := true;
                end;
              fld.LookupDataSet.First;
              while not fld.LookupDataSet.eof do
                begin
                  sl.Add(fld.LookupDataSet.FieldByName(fld.LookupResultField).AsString);
                  fld.LookupDataSet.Next;
                end;
            end
          else
            begin
              if FOriginalFilter <> '' then
                ListSource.DataSet.Filter := FOriginalFilter + ' and ' +
                  FDropDownFilter
              else
                ListSource.DataSet.Filter := FDropDownFilter;
              ListSource.DataSet.Filtered := true;
              ListSource.DataSet.First;
              while not ListSource.DataSet.eof do
                begin
                  sl.Add(ListSource.DataSet.FieldByName(ListField).AsString);
                  ListSource.DataSet.Next;
                end;
            end;
      end;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TBKDBLookupComboBox.GetKeyFieldsAsText: string;
var
  fld: TField;
  sl: TStringList;
begin
  Result := '';
  sl := TStringList.Create;
  try
    if Assigned(DataSource) and Assigned(DataSource.DataSet) then
      begin
      //SetOriginalFilter;
        fld := DataSource.DataSet.FindField(DataField);
        if Assigned(fld) then
        //if we are using a lookup field then apply the filter to the lookup field dataset
          if Assigned(fld.LookupDataSet) then
            begin
              if (FDropDownFilter <> '') then
                begin
                  if FOriginalFilter <> '' then
                    fld.LookupDataSet.Filter := FOriginalFilter + ' and ' +
                      FDropDownFilter
                  else
                    fld.LookupDataSet.Filter := FDropDownFilter;
                  fld.LookupDataSet.Filtered := true;
                end;
              fld.LookupDataSet.First;
              while not fld.LookupDataSet.eof do
                begin
                  sl.Add(fld.LookupDataSet.FieldByName(fld.LookupKeyFields).AsString);
                  fld.LookupDataSet.Next;
                end;
            end
          else
            begin
              if FOriginalFilter <> '' then
                ListSource.DataSet.Filter := FOriginalFilter + ' and ' +
                  FDropDownFilter
              else
                ListSource.DataSet.Filter := FDropDownFilter;
              ListSource.DataSet.Filtered := true;
              ListSource.DataSet.First;
              while not ListSource.DataSet.eof do
                begin
                  sl.Add(ListSource.DataSet.FieldByName(KeyField).AsString);
                  ListSource.DataSet.Next;
                end;
            end;
      end;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TBKDBLookupComboBox.GetCurrentValue: string;
begin
  Result := '';
  if Assigned(Field) then
    Result := Field.AsString;
end;

procedure TBKDBLookupComboBox.SetDropDownFilter(const Value: string);
begin
  if FDropDownFilter <> Value then
    FDropDownFilter := Value;
end;

procedure TBKDBLookupComboBox.KeyDown(var Key: Word; Shift: TShiftState);
var
  OldKey: word;
begin
  //OK if the key is the down arrow then we need to display the list no matter what
  OldKey := 0;

  {TB check the list source, because if there is none then this will cause a stack overflow}
  if Assigned(ListSource) then
  begin
    if Assigned(ListSource.DataSet) and (ListSource.DataSet.State <> dsInactive) then
    begin
      if not ListVisible and not (ssCtrl in Shift) then
      begin
        if (Key in [$30..$39, $41..$5A]) and not (ssAlt in Shift) then
          begin
            OldKey := Key;
            Key := vk_Down;
          end;
        if (Key in [vk_Up, vk_Down]) and not (ssAlt in Shift) then
          Include(Shift, ssAlt);
      end;
    end;
  end;

  inherited;

  if (OldKey <> 0) then
    begin
      Exclude(Shift, ssAlt);
      KeyDown(OldKey, Shift);
    end;
end;

procedure TBKDBLookupComboBox.SetCurrentValue(const Value: string);
var
  v: variant;
  fld: TField;
begin
  if DataLink.Edit then
    begin
      v := null;
      fld := DataSource.DataSet.FindField(DataField);
      if Assigned(fld) then
        if Assigned(fld.LookupDataSet) then
          v := fld.LookupDataSet.Lookup(DataField, VarArrayOf([Value]),
            fld.LookupKeyFields)
        else
          v := ListSource.DataSet.Lookup(ListField, VarArrayOf([Value]),
            KeyField);
      if not VarIsNull(v) then
        Field.AsVariant := v;
    end;
end;

constructor TBKDBLookupComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FOriginalFilter := '';
end;

procedure TBKDBLookupComboBox.SetOriginalFilter;
var
  fld: TField;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    begin
      fld := DataSource.DataSet.FindField(DataField);
      if Assigned(fld) then
        //if we are using a lookup field then apply the filter to the lookup field dataset
        if Assigned(fld.LookupDataSet) then
          FOriginalFilter := fld.LookupDataSet.Filter
        else
          FOriginalFilter := ListSource.DataSet.Filter;
    end;
end;

procedure TBKDBLookupComboBox.WMKeyDown(var Message: TWMKeyDown);
var
  fld: TField;
begin
  //This is to fix a cockup in the Field.Clear routine, if it is a lookup field it does nothing.
  if (NullValueKey <> 0) and
    CanModify and
    (NullValueKey = ShortCut(Message.CharCode,
    KeyDataToShiftState(Message.KeyData))) and
    (Field.FieldKind = fkLookup) then
    begin
      if Assigned(DataSource) and Assigned(DataSource.DataSet) and
        (Field.KeyFields <> '') then
        begin
          fld := DataSource.DataSet.FindField(Field.KeyFields);
          if Assigned(fld) then
            begin
              DataLink.Edit;
              fld.Clear;
              Message.CharCode := 0;
            end;
        end;
    end;
  inherited;
end;

procedure TBKDBLookupComboBox.CMEnter(var Msg: TCMEnter);
begin
  inherited;
  SetOriginalFilter;
end;

end.

