unit PdfFieldEditor;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  Controls,
  Forms,
  ExtCtrls,
  StdCtrls,
  Graphics,
  QuickPDF;

type
  TPDFRect = record
    Left   : integer;
    Top    : integer;
    Width  : integer;
    Height : integer;
  end;

  TPDFProperty = class
    private
      HasValue : Boolean;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItem = class(TCollectionItem)
  private
    fIndex : integer;
  protected
    function GetQuickPDF : TQuickPDF;
    function GetParentWinControl : TWinControl;
    procedure ScaleControl(const aControl : TControl);

    function GetTitle : WideString;
    function GetType : integer;
    function GetFontName : WideString;
    function GetSubCount : integer;

    function GetValue : WideString;
    procedure SetValue(Value : WideString);
    function GetBound : TPDFRect;
    procedure SetBound(Value : TPDFRect);
    function GetPage : integer;
    procedure SetPage(Value : integer);
    function GetTextSize : integer;
    procedure SetTextSize(Value : integer);
    function GetMaxLen : integer;
    procedure SetMaxLen(Value : integer);
    function GetReadOnly : boolean;
    procedure SetReadOnly(Value : boolean);
    function GetVisible : boolean;
    procedure SetVisible(Value : boolean);
    function GetDescription : WideString;
    procedure SetDescription(Value : WideString);
    function GetCaption : WideString;
    procedure SetCaption(Value : WideString);
  public
    constructor Create(Collection: TCollection); override;
    procedure Draw; virtual;

    property QuickPDF : TQuickPDF  read GetQuickPDF;
    property ParentWinControl : TWinControl read GetParentWinControl;
    property Index    : integer    read fIndex write fIndex;

    property Title : WideString read GetTitle;
    property CompType : integer read GetType;
    property FontName : WideString read GetFontName;
    property SubCount : integer read GetSubCount;

    property Value : WideString read GetValue write SetValue;
    property Bound : TPDFRect   read GetBound write SetBound;
    property Page  : integer    read GetPage  write SetPage;
    property TextSize : integer read GetTextSize  write SetTextSize;
    property MaxLen   : integer read GetMaxLen    write SetMaxLen;
    property ReadOnly : boolean read GetReadOnly  write SetReadOnly;
    property Visible  : boolean read GetVisible   write SetVisible;
    property Description : WideString read GetDescription write SetDescription;
    property Caption : WideString read GetCaption write SetCaption;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemEdit = class(TPDFFormFieldItem)
  private
    fEdit : TEdit;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemCheckBox = class(TPDFFormFieldItem)
  private
    fCheckBox : TCheckBox;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  TPDFFormFieldItemButton = class(TPDFFormFieldItem)
  private
    fButton : TButton;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemShape = class(TPDFFormFieldItem)
  private
    fShape : TShape;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFields = class(TCollection)
  private
    fQuickPDF : TQuickPDF;
    fParentWinControl : TWinControl;
    fEnabled : Boolean;
    fZoom    : Integer;
    fDPI     : integer;
    fHiddenIndex : integer;
  protected
    procedure RefreshFormField(aFieldIndex : integer);
    procedure RefreshFormFields;

    procedure SetQuickPDF(Value : TQuickPDF);
  public


    procedure Draw(Page : integer);
    function GetFieldByTitle(aTitle : WideString) : TPDFFormFieldItem;

    property QuickPDF : TQuickPDF read fQuickPDF write SetQuickPDF;
    property ParentWinControl : TWinControl read fParentWinControl write fParentWinControl;
    property Enabled : Boolean read fEnabled write fEnabled;
    property Zoom    : integer read fZoom    write fZoom;
    property DPI     : integer read fDPI     write fDPI;
    property HiddenIndex : integer read fHiddenIndex write fHiddenIndex;
  end;

  //----------------------------------------------------------------------------
  TPdfFieldEdit = class(TScrollBox)
  private
    fQuickPDF : TQuickPDF;
    fPDFImage : TImage;
    fPage     : Integer;
    fZoom     : Integer;
    fPDFFilePath : WideString;
    fPDFPassword : WideString;
    fActive : boolean;
    fDPI    : integer;

    fPDFFormFields : TPDFFormFields;
  protected
    procedure RenderPage;
    procedure SetActive(Value : Boolean);
    procedure SetPage(Value : integer);
    procedure SetZoom(Value : integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function LoadPDF(aFilePath: WideString; aPassword : WideString = '') : Boolean;
    procedure Refresh;

    property PDFFormFields : TPDFFormFields read fPDFFormFields write fPDFFormFields;
  published
    property PDFFilePath : WideString read fPDFFilePath write fPDFFilePath;
    property PDFPassword : WideString read fPDFPassword write fPDFPassword;
    property Active      : Boolean    read fActive      write SetActive;
    property Page        : integer    read fPage        write SetPage;
    property Zoom        : integer    read fZoom        write SetZoom;
    property DPI         : integer    read fDPI;
  end;

procedure Register;

//------------------------------------------------------------------------------
implementation

uses
  strutils;

const
  FRM_FIELD_BOUND_LEFT   = 0;
  FRM_FIELD_BOUND_TOP    = 1;
  FRM_FIELD_BOUND_WIDTH  = 2;
  FRM_FIELD_BOUND_HEIGHT = 3;

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('BankLink', [TPdfFieldEdit]);
end;

//------------------------------------------------------------------------------
function IntToBool(Value : integer) : Boolean;
begin
  Result := (Value = 1);
end;

//------------------------------------------------------------------------------
function BoolToInt(Value : Boolean) : integer;
begin
  if Value then
    Result := 1
  else
    Result := 0;
end;

{ TPDFFormField }
//------------------------------------------------------------------------------
constructor TPDFFormFieldItem.Create(Collection: TCollection);
begin
  inherited;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetParentWinControl: TWinControl;
begin
  Result := Nil;

  if Self.Collection is TPDFFormFields then
    Result := TPDFFormFields(Self.Collection).ParentWinControl;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetQuickPDF: TQuickPDF;
begin
  Result := Nil;

  if Self.Collection is TPDFFormFields then
    Result := TPDFFormFields(Self.Collection).QuickPDF;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.Draw;
begin
  //---------------------------
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.ScaleControl(const aControl: TControl);
var
  Scale : double;
  CompTypeStr : string;
  VisibleStr : string;
  ReadOnlyStr : string;
begin
  Scale := TPDFFormFields(self.Collection).DPI / 72;

  aControl.Left   := round(Bound.Left   * Scale);
  aControl.Top    := round(Bound.Top    * Scale);
  aControl.Width  := round(Bound.Width  * Scale);
  aControl.Height := round(Bound.Height * Scale);

  if (aControl.Width <= 0) or
     (aControl.Height <= 0) or
     (aControl.Top < 0) or
     (aControl.Left < 0) then
  begin
    aControl.Left   := (TPDFFormFields(Collection).HiddenIndex * 12);
    aControl.Top    := 0;
    aControl.Width  := 10;
    aControl.Height := 10;

    TPDFFormFields(Collection).HiddenIndex := TPDFFormFields(Collection).HiddenIndex + 1;
  end;

  case CompType of
    0 : CompTypeStr := 'Unknown';
    1 : CompTypeStr := 'Text';
    2 : CompTypeStr := 'Pushbutton';
    3 : CompTypeStr := 'Checkbox';
    4 : CompTypeStr := 'Radiobutton';
    5 : CompTypeStr := 'Choice';
    6 : CompTypeStr := 'Signature';
    7 : CompTypeStr := 'Parent';
  end;

  if Visible then
    VisibleStr := 'Yes'
  else
    VisibleStr := 'No';

  if ReadOnly then
    ReadOnlyStr := 'Yes'
  else
    ReadOnlyStr := 'No';

  aControl.Hint := 'Index       : ' + inttostr(Index) + #10 +
                   'Sub Count   : ' + inttostr(SubCount) + #10 +
                   'Title       : ' + Title + #10 +
                   'Value       : ' + Value + #10 +
                   'Type        : ' + CompTypeStr + #10 +
                   'Visible     : ' + VisibleStr + #10 +
                   'ReadOnly    : ' + ReadOnlyStr + #10 +
                   'Description : ' + Description + #10 +
                   'Caption     : ' + Caption;

  aControl.ShowHint := true;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTitle: WideString;
begin
  Result := QuickPDF.GetFormFieldTitle(fIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetType: Integer;
begin
  Result := QuickPDF.GetFormFieldType(fIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetFontName : WideString;
begin
  Result := QuickPDF.GetFormFieldFontName(fIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetSubCount : integer;
begin
  Result := QuickPDF.GetFormFieldSubCount(fIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetValue: WideString;
begin
  Result := QuickPDF.GetFormFieldValue(fIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetValue(Value: WideString);
begin
  QuickPDF.SetFormFieldValue(fIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetBound: TPDFRect;
begin
  Result.Left   := Round(QuickPDF.GetFormFieldBound(fIndex, FRM_FIELD_BOUND_LEFT));
  Result.Top    := Round(QuickPDF.GetFormFieldBound(fIndex, FRM_FIELD_BOUND_TOP));
  Result.Width  := Round(QuickPDF.GetFormFieldBound(fIndex, FRM_FIELD_BOUND_WIDTH));
  Result.Height := Round(QuickPDF.GetFormFieldBound(fIndex, FRM_FIELD_BOUND_HEIGHT));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetBound(Value: TPDFRect);
begin
  QuickPDF.SetFormFieldBounds(fIndex, Value.Left, Value.Top, Value.Width, Value.Height);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetPage: integer;
begin
  Result := QuickPDF.GetFormFieldPage(fIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetPage(Value: integer);
begin
  QuickPDF.SetFormFieldPage(fIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTextSize : integer;
begin
  Result := round(QuickPDF.GetFormFieldTextSize(fIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetTextSize(Value : integer);
begin
  QuickPDF.SetFormFieldTextSize(fIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetMaxLen : integer;
begin
  Result := QuickPDF.GetFormFieldMaxLen(fIndex);
end;
//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetMaxLen(Value : integer);
begin
  QuickPDF.SetFormFieldMaxLen(fIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetReadOnly : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldReadOnly(fIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetReadOnly(Value : boolean);
begin
  QuickPDF.SetFormFieldReadOnly(fIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetVisible : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldVisible(fIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetVisible(Value : boolean);
begin
  QuickPDF.SetFormFieldVisible(fIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetDescription: WideString;
begin
  Result := QuickPDF.GetFormFieldDescription(fIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetDescription(Value: WideString);
begin
  QuickPDF.SetFormFieldDescription(fIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetCaption : WideString;
begin
  Result := QuickPDF.GetFormFieldCaption(fIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetCaption(Value : WideString);
begin
  QuickPDF.SetFormFieldCaption(fIndex, Value);
end;

{ TPDFFormFieldItemEdit }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemEdit.Destroy;
begin
  FreeAndNil(fEdit);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.Draw;
begin
  inherited;

  if not assigned(fEdit) then
    fEdit := TEdit.Create(nil);

  fEdit.Parent := ParentWinControl;
  ScaleControl(fEdit);
  fEdit.Text := Value;
end;

{ TPDFFormFieldItemCheckBox }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemCheckBox.Destroy;
begin
  FreeAndNil(fCheckBox);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.Draw;
begin
  inherited;

  if not assigned(fCheckBox) then
    fCheckBox := TCheckBox.Create(nil);

  fCheckBox.Parent  := ParentWinControl;
  ScaleControl(fCheckBox);
  fCheckBox.Caption := Caption;
end;

{ TPDFFormFieldItemButton }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemButton.Destroy;
begin
  FreeAndNil(fButton);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemButton.Draw;
begin
  inherited;

  if not assigned(fButton) then
    fButton := TButton.Create(nil);

  fButton.Parent := ParentWinControl;
  ScaleControl(fButton);
  fButton.Caption := Caption;
end;

{ TPDFFormFieldItemShape }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemShape.Destroy;
begin
  FreeAndNil(fShape);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemShape.Draw;
begin
  inherited;
  if not assigned(fShape) then
    fShape := TShape.Create(nil);

  fShape.Parent  := ParentWinControl;
  ScaleControl(fShape);
  fShape.Pen.Color := $00FF0000;
end;

{ TPDFFormFields }
//------------------------------------------------------------------------------
procedure TPDFFormFields.Draw(Page : integer);
var
  ItemIndex : integer;
  CurrItem  : TPDFFormFieldItem;
begin
  if Self.Enabled then
  begin
    for ItemIndex := 0 to Self.Count-1 do
    begin
      CurrItem := TPDFFormFieldItem(Self.Items[ItemIndex]);

      if CurrItem.Page = Page then
        CurrItem.Draw;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPDFFormFields.GetFieldByTitle(aTitle: WideString): TPDFFormFieldItem;
var
  FormFieldIndex : integer;
  ItemIndex : integer;
  CurrItem  : TPDFFormFieldItem;
begin
  Result := Nil;

  if Enabled then
  begin
    FormFieldIndex := fQuickPDF.FindFormFieldByTitle(aTitle);

    for ItemIndex := 0 to Self.Count-1 do
    begin
      CurrItem := TPDFFormFieldItem(Self.Items[ItemIndex]);

      if CurrItem.Index = FormFieldIndex then
      begin
        Result := CurrItem;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.RefreshFormField(aFieldIndex: integer);
var
  FieldType     : integer;
  FieldVisible  : Boolean;
  FieldReadonly : Boolean;

  NewPDFFormFieldItemEdit     : TPDFFormFieldItemEdit;
  NewPDFFormFieldItemCheckBox : TPDFFormFieldItemCheckBox;
  NewPDFFormFieldItem         : TPDFFormFieldItem;
  NewPDFFormFieldItemButton   : TPDFFormFieldItemButton;
  NewPDFFormFieldItemShape    : TPDFFormFieldItemShape;
begin
  FieldType     := fQuickPDF.GetFormFieldType(aFieldIndex);
  FieldVisible  := IntToBool(fQuickPDF.GetFormFieldVisible(aFieldIndex));
  FieldReadonly := IntToBool(fQuickPDF.GetFormFieldReadonly(aFieldIndex));

  if (FieldVisible) and
     (not FieldReadonly) then
  begin
    case FieldType of
      1 : begin
        NewPDFFormFieldItemEdit := TPDFFormFieldItemEdit.Create(self);
        NewPDFFormFieldItemEdit.Index := aFieldIndex;
      end;
      2 : begin
        NewPDFFormFieldItemButton := TPDFFormFieldItemButton.Create(self);
        NewPDFFormFieldItemButton.Index := aFieldIndex;
      end;
      3 : begin
        NewPDFFormFieldItemCheckBox := TPDFFormFieldItemCheckBox.Create(self);
        NewPDFFormFieldItemCheckBox.Index := aFieldIndex;
      end;
      else
      begin
        NewPDFFormFieldItemShape := TPDFFormFieldItemShape.Create(self);
        NewPDFFormFieldItemShape.Index := aFieldIndex;
      end;
    end;
  end
  else
  begin
    NewPDFFormFieldItemShape := TPDFFormFieldItemShape.Create(self);
    NewPDFFormFieldItemShape.Index := aFieldIndex;
  end;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.RefreshFormFields;
var
  FormFieldIndex : integer;
  FieldSubCount  : integer;
  FieldSubIndex  : integer;
  TempSubIndex   : integer;
begin
  HiddenIndex := 0;
  Self.Clear;

  if Enabled then
  begin
    for FormFieldIndex := 1 to fQuickPDF.FormFieldCount do
    begin
      RefreshFormField(FormFieldIndex);

      FieldSubCount := fQuickPDF.GetFormFieldSubCount(FormFieldIndex);

      for FieldSubIndex := 1 to FieldSubCount do
      begin
        TempSubIndex := fQuickPDF.GetFormFieldSubTempIndex(FormFieldIndex, FieldSubIndex);

        RefreshFormField(TempSubIndex);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.SetQuickPDF(Value: TQuickPDF);
begin
  fQuickPDF := Value;

  RefreshFormFields;
end;

{ TPdfFieldEdit }
//------------------------------------------------------------------------------
constructor TPdfFieldEdit.Create(AOwner: TComponent);
begin
  inherited;
  fQuickPDF := TQuickPDF.Create;
  fPDFImage := TImage.Create(nil);
  fPDFFormFields := TPDFFormFields.Create(TPDFFormFieldItem);
  fPDFFormFields.QuickPDF := fQuickPDF;
  fPDFFormFields.Enabled := true;
  fPDFFormFields.fParentWinControl := Self;

  fPDFImage.Parent := Self;

  fPDFImage.Top := 0;
  fPDFImage.Left := 0;

  fPage := 1;
  fZoom := 2;
  fDPI  := 0;
end;

//------------------------------------------------------------------------------
destructor TPdfFieldEdit.Destroy;
begin
  FreeAndNil(fPDFFormFields);
  FreeAndNil(fPDFImage);
  FreeAndNil(fQuickPDF);
  inherited;
end;

//------------------------------------------------------------------------------
function TPdfFieldEdit.LoadPDF(aFilePath: WideString; aPassword : WideString) : Boolean;
begin
  Result := false;
  Try
    if fQuickPDF.UnlockKey('j54g79ru33q4xo7gp7wt43j3y') = 1 then
    begin
      fQuickPDF.SetNeedAppearances(1);
      fQuickPDF.LoadFromFile(aFilePath, aPassword);
      fPDFFormFields.RefreshFormFields;
      Result := True;
    end;
  except
    Result := false;
  End;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.Refresh;
begin
  fQuickPDF.SetOrigin(1);
  fQuickPDF.NormalizePage(0);

  RenderPage;

  fPDFFormFields.RefreshFormFields;
  fPDFFormFields.Draw(fPage);
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.RenderPage;
var
  Bmp : TBitmap;
  MemStr: TMemoryStream;
begin
  fDPI := 0;
  Bmp := TBitmap.Create;
  try
    fPDFImage.Picture.Assign(Bmp);
    Self.HorzScrollBar.Position := 0;
    Self.VertScrollBar.Position := 0;
    fPDFImage.Left := 0;
    fPDFImage.Top := 0;
  finally
    FreeAndNil(Bmp);
  end;

  if Assigned(fQuickPDF) then
  begin
    MemStr := TMemoryStream.Create;
    try
      fDPI := ((fZoom + 1) * 25 * 96) div 100;
      PDFFormFields.DPI := fDPI;
      fQuickPDF.RenderPageToStream(fDPI, fPage, 0, MemStr);
      MemStr.Seek(0, soFromBeginning);
      Bmp := TBitmap.Create;
      try
        Bmp.LoadFromStream(MemStr);
        fPDFImage.AutoSize := True;
        fPDFImage.Picture.Assign(Bmp);
      finally
        FreeAndNil(Bmp);
      end;
    finally
      FreeAndNil(MemStr);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SetActive(Value: Boolean);
begin
  if (Value) and (not fActive) then
  begin
    if not LoadPDF(fPDFFilePath, fPDFPassword) then
      Exit;

    fPDFImage.Visible := true;

    Refresh;
  end;

  if (not Value) and (fActive) then
  begin
    fPDFImage.Visible := false;

    PDFFormFields.Clear;
  end;

  fActive := Value;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SetPage(Value: integer);
begin
  if (Value <> fPage) then
  begin
    if fQuickPDF.SetOpenActionDestination(Value, fZoom) = 0 then
      Exit;

    fPage := Value;
    Refresh;
  end;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SetZoom(Value: integer);
begin
  if (Value <> fZoom) then
  begin
    if fQuickPDF.SetOpenActionDestination(fPage, Value) = 0 then
      Exit;

    fZoom := Value;
    PDFFormFields.Zoom := fZoom;
    Refresh;
  end;
end;

end.
