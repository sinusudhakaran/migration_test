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
    fItemIndex : integer;
    fParentIndex : integer;
  protected
    function GetQuickPDF : TQuickPDF;
    function GetParentWinControl : TWinControl;
    function GetCheckboxTickOn : TPicture;
    function GetCheckboxTickOff : TPicture;
    function ScaleControl(const aControl : TControl) : double;

    function GetTitle : WideString;
    function GetType : integer;
    function GetTypeName : string;
    function GetFontName : WideString;
    function GetSubCount : integer;
    function GetTabOrder : integer;

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
    property CheckboxTickOn : TPicture read GetCheckboxTickOn;
    property CheckboxTickOff : TPicture read GetCheckboxTickOff;
    property ItemIndex : integer read fItemIndex write fItemIndex;
    property ParentIndex : integer read fParentIndex write fParentIndex;

    property Title : WideString read GetTitle;
    property CompType : integer read GetType;
    property CompTypeName : string read GetTypeName;
    property FontName : WideString read GetFontName;
    property SubCount : integer read GetSubCount;
    property TabOrder : integer read GetTabOrder;

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
    fOnChange : TNotifyEvent;
    fOnKeyPressed : TKeyPressEvent;

    fEdit : TEdit;
  protected
    procedure EditChanged(Sender: TObject);
    procedure EditKeyPressed(Sender: TObject; var Key: Char);

    function GetMaxLength : integer;
    procedure SetMaxLength(aValue : integer);
  public
    destructor Destroy; override;

    procedure Draw; override;
    procedure SetFocus;

    property OnChange : TNotifyEvent read fOnChange write fOnChange;
    property OnKeyPressed : TKeyPressEvent read fOnKeyPressed write fOnKeyPressed;
    property MaxLength : integer read GetMaxLength write SetMaxLength;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemCheckBox = class(TPDFFormFieldItem)
  private
    fImage : TImage;
  protected
    procedure UpdateCheck;

    procedure SetChecked(aValue : Boolean);
    function GetChecked : Boolean;

    procedure ImageClick(Sender: TObject);
  public
    destructor Destroy; override;

    procedure Draw; override;

    property Checked : Boolean read GetChecked write SetChecked;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemButton = class(TPDFFormFieldItem)
  private
    fButton : TButton;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemRadioButton = class(TPDFFormFieldItem)
  private
    fRadioButton : TRadioButton;
  public
    destructor Destroy; override;

    procedure Draw; override;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemComboBox = class(TPDFFormFieldItem)
  private
    fComboBox : TComboBox;
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
    FCheckBoxTickPicOn : TPicture;
    FCheckBoxTickPicOff : TPicture;
  protected
    procedure SetCheckBoxTickOn(const aValue: TPicture);
    procedure SetCheckBoxTickOff(const aValue: TPicture);
    procedure RefreshFormField(aFieldIndex: integer;
                               aFieldSubIndex: integer);
    procedure RefreshFormFields;

    procedure SetQuickPDF(Value : TQuickPDF);
  public
    destructor Destroy; override;

    procedure Init;
    procedure Draw(aPage : integer);
    function GetFieldByTitle(aTitle : WideString) : TPDFFormFieldItem;

    property QuickPDF : TQuickPDF read fQuickPDF write SetQuickPDF;
    property ParentWinControl : TWinControl read fParentWinControl write fParentWinControl;
    property Enabled : Boolean read fEnabled write fEnabled;
    property Zoom    : integer read fZoom    write fZoom;
    property DPI     : integer read fDPI     write fDPI;
    property HiddenIndex : integer read fHiddenIndex write fHiddenIndex;
    property CheckboxTickOn: TPicture read FCheckBoxTickPicOn write SetCheckBoxTickOn;
    property CheckboxTickOff: TPicture read FCheckBoxTickPicOff write SetCheckBoxTickOff;
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
    procedure SetCheckBoxTickOn(aValue: TPicture);
    function GetCheckBoxTickOn : TPicture;
    procedure SetCheckBoxTickOff(aValue: TPicture);
    function GetCheckBoxTickOff : TPicture;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function LoadPDF(aFilePath: WideString; aPassword : WideString = '') : Boolean;
    procedure Refresh;

    Procedure SaveToFile(aFilePath : WideString);
    Procedure Print(PrinterName : Widestring;
                    StartPage : integer;
                    EndPage : integer;
                    Options : integer);
    Procedure ResetForm;

    property PDFFormFields : TPDFFormFields read fPDFFormFields write fPDFFormFields;
  published
    property PDFFilePath : WideString read fPDFFilePath write fPDFFilePath;
    property PDFPassword : WideString read fPDFPassword write fPDFPassword;
    property Active      : Boolean    read fActive      write SetActive;
    property Page        : integer    read fPage        write SetPage;
    property Zoom        : integer    read fZoom        write SetZoom;
    property DPI         : integer    read fDPI;

    property CheckboxTickOn  : TPicture read GetCheckBoxTickOn write SetCheckBoxTickOn;
    property CheckboxTickOff : TPicture read GetCheckBoxTickOff write SetCheckBoxTickOff;
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

  FRM_FIELD_TYPE_UNKNOWN     = 0;
  FRM_FIELD_TYPE_TEXT        = 1;
  FRM_FIELD_TYPE_BUTTON      = 2;
  FRM_FIELD_TYPE_CHECKBOX    = 3;
  FRM_FIELD_TYPE_RADIOBUTTON = 4;
  FRM_FIELD_TYPE_CHOICE      = 5;
  FRM_FIELD_TYPE_SIGNATURE   = 6;
  FRM_FIELD_TYPE_PARENT      = 7;

  FRM_FIELD_DPI = 71.96;

  QUICK_PDF_LICENCE_KEY = 'j54g79ru33q4xo7gp7wt43j3y';

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
function TPDFFormFieldItem.GetCheckboxTickOn : TPicture;
begin
  Result := Nil;

  if Self.Collection is TPDFFormFields then
    Result := TPDFFormFields(Self.Collection).CheckboxTickOn;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetCheckboxTickOff : TPicture;
begin
  Result := Nil;

  if Self.Collection is TPDFFormFields then
    Result := TPDFFormFields(Self.Collection).CheckboxTickOff;
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
function TPDFFormFieldItem.ScaleControl(const aControl: TControl) : double;
var
  CompTypeStr : string;
  VisibleStr : string;
  ReadOnlyStr : string;
begin
  Result := TPDFFormFields(self.Collection).DPI / FRM_FIELD_DPI;

  aControl.Left   := round(Bound.Left   * Result);
  aControl.Top    := round(Bound.Top    * Result);
  aControl.Width  := round(Bound.Width  * Result);
  aControl.Height := round(Bound.Height * Result);

  {if (aControl.Width <= 0) or
     (aControl.Height <= 0) or
     (aControl.Top < 0) or
     (aControl.Left < 0) then
  begin
    aControl.Left   := (TPDFFormFields(Collection).HiddenIndex * 12);
    aControl.Top    := 0;
    aControl.Width  := 10;
    aControl.Height := 10;

    TPDFFormFields(Collection).HiddenIndex := TPDFFormFields(Collection).HiddenIndex + 1;
  end;}

  {CompTypeStr := GetTypeName;

  if Visible then
    VisibleStr := 'Yes'
  else
    VisibleStr := 'No';

  if ReadOnly then
    ReadOnlyStr := 'Yes'
  else
    ReadOnlyStr := 'No';

  aControl.Hint := 'ItemIndex   : ' + inttostr(ItemIndex) + #10 +
                   'ParentIndex : ' + inttostr(ParentIndex) + #10 +
                   'Sub Count   : ' + inttostr(SubCount) + #10 +
                   'Title       : ' + Title + #10 +
                   'Value       : ' + Value + #10 +
                   'Type        : ' + CompTypeStr + #10 +
                   'Visible     : ' + VisibleStr + #10 +
                   'ReadOnly    : ' + ReadOnlyStr + #10 +
                   'Description : ' + Description + #10 +
                   'Caption     : ' + Caption;

  aControl.ShowHint := true;}
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTitle: WideString;
begin
  Result := QuickPDF.GetFormFieldTitle(fItemIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetType: Integer;
begin
  Result := QuickPDF.GetFormFieldType(fItemIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTypeName: string;
begin
  case CompType of
    FRM_FIELD_TYPE_UNKNOWN     : Result := 'Unknown';
    FRM_FIELD_TYPE_TEXT        : Result := 'Text';
    FRM_FIELD_TYPE_BUTTON      : Result := 'Pushbutton';
    FRM_FIELD_TYPE_CHECKBOX    : Result := 'Checkbox';
    FRM_FIELD_TYPE_RADIOBUTTON : Result := 'Radiobutton';
    FRM_FIELD_TYPE_CHOICE      : Result := 'Choice';
    FRM_FIELD_TYPE_SIGNATURE   : Result := 'Signature';
    FRM_FIELD_TYPE_PARENT      : Result := 'Parent';
  end;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetFontName : WideString;
begin
  Result := QuickPDF.GetFormFieldFontName(fItemIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetSubCount : integer;
begin
  Result := QuickPDF.GetFormFieldSubCount(fItemIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTabOrder : integer;
begin
  Result := QuickPDF.GetFormFieldTabOrder(fItemIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetValue: WideString;
begin
  Result := QuickPDF.GetFormFieldValue(fItemIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetValue(Value: WideString);
begin
  QuickPDF.SetFormFieldValue(fItemIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetBound: TPDFRect;
begin
  Result.Left   := Round(QuickPDF.GetFormFieldBound(fItemIndex, FRM_FIELD_BOUND_LEFT));
  Result.Top    := Round(QuickPDF.GetFormFieldBound(fItemIndex, FRM_FIELD_BOUND_TOP));
  Result.Width  := Round(QuickPDF.GetFormFieldBound(fItemIndex, FRM_FIELD_BOUND_WIDTH));
  Result.Height := Round(QuickPDF.GetFormFieldBound(fItemIndex, FRM_FIELD_BOUND_HEIGHT));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetBound(Value: TPDFRect);
begin
  QuickPDF.SetFormFieldBounds(fItemIndex, Value.Left, Value.Top, Value.Width, Value.Height);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetPage: integer;
begin
  Result := QuickPDF.GetFormFieldPage(fItemIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetPage(Value: integer);
begin
  QuickPDF.SetFormFieldPage(fItemIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTextSize : integer;
begin
  Result := round(QuickPDF.GetFormFieldTextSize(fItemIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetTextSize(Value : integer);
begin
  QuickPDF.SetFormFieldTextSize(fItemIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetMaxLen : integer;
begin
  Result := QuickPDF.GetFormFieldMaxLen(fItemIndex);
end;
//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetMaxLen(Value : integer);
begin
  QuickPDF.SetFormFieldMaxLen(fItemIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetReadOnly : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldReadOnly(fItemIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetReadOnly(Value : boolean);
begin
  QuickPDF.SetFormFieldReadOnly(fItemIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetVisible : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldVisible(fItemIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetVisible(Value : boolean);
begin
  QuickPDF.SetFormFieldVisible(fItemIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetDescription: WideString;
begin
  Result := QuickPDF.GetFormFieldDescription(fItemIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetDescription(Value: WideString);
begin
  QuickPDF.SetFormFieldDescription(fItemIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetCaption : WideString;
begin
  Result := QuickPDF.GetFormFieldCaption(fItemIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetCaption(Value : WideString);
begin
  QuickPDF.SetFormFieldCaption(fItemIndex, Value);
end;

{ TPDFFormFieldItemEdit }
//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.EditChanged(Sender: TObject);
begin
  if Assigned(fOnChange) then
    fOnChange(Sender);

  Value := fEdit.Text;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.EditKeyPressed(Sender: TObject; var Key: Char);
begin
  if Assigned(fOnKeyPressed) then
    fOnKeyPressed(Sender, Key);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItemEdit.GetMaxLength: integer;
begin
  Result := fEdit.MaxLength;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.SetFocus;
begin
  fEdit.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.SetMaxLength(aValue: integer);
begin
  fEdit.MaxLength := aValue;
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItemEdit.Destroy;
begin
  FreeAndNil(fEdit);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.Draw;
var
  Scale : Double;
  DPI : double;
  TextHeight : integer;
  TextExtra  : integer;
begin
  inherited;

  if not assigned(fEdit) then
  begin
    fEdit := TEdit.Create(nil);
    fEdit.OnChange := EditChanged;
    fEdit.OnKeyPress := EditKeyPressed;
  end;

  fEdit.Parent := ParentWinControl;
  Scale := ScaleControl(fEdit);
  fEdit.Text := Value;
  fEdit.visible := ((not self.ReadOnly) and (self.Visible));
  fEdit.BorderStyle := bsNone;
  DPI := fEdit.Font.PixelsPerInch;

  fEdit.Font.Size := trunc(self.TextSize * ((FRM_FIELD_DPI/DPI)*Scale));

  TextHeight := round(fEdit.Font.Size * 1.5);
  TextExtra := fEdit.Height - TextHeight;

  fEdit.Top := fEdit.Top + round(TextExtra/2);
  fEdit.Height := TextHeight;
  fEdit.Left := fEdit.Left + round(2*Scale);
  fEdit.Width := fEdit.Width - round(4*Scale);

  fEdit.TabOrder := TabOrder;
end;

{ TPDFFormFieldItemCheckBox }
//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.SetChecked(aValue : Boolean);
begin
  if aValue then
    Value := 'Yes'
  else
    Value := 'Off';

  UpdateCheck;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.UpdateCheck;
begin
  if (Value = 'Yes') then
    fImage.Picture.Assign(GetCheckboxTickOn)
  else
    fImage.Picture.Assign(GetCheckboxTickOff);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItemCheckBox.GetChecked : Boolean;
begin
  Result := (Value = 'Yes');
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.ImageClick(Sender: TObject);
begin
  Checked := Not Checked;
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItemCheckBox.Destroy;
begin
  FreeAndNil(fImage);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.Draw;
var
  Scale : double;
begin
  inherited;

  if not assigned(fImage) then
  begin
    fImage := TImage.Create(nil);
    fImage.OnClick := ImageClick;
  end;

  fImage.Parent := ParentWinControl;
  Scale := ScaleControl(fImage);

  fImage.Top := fImage.Top + round(2*Scale);
  fImage.Height := fImage.Height - round(4*Scale);
  fImage.Left := fImage.Left + round(2*Scale);
  fImage.Width := fImage.Width - round(4*Scale);

  fImage.Stretch := true;
  UpdateCheck;
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

{ TPDFFormFieldItemRadioButton }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemRadioButton.Destroy;
begin
  FreeAndNil(fRadioButton);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemRadioButton.Draw;
begin
  inherited;

  if not assigned(fRadioButton) then
    fRadioButton := TRadioButton.Create(nil);

  fRadioButton.Parent := ParentWinControl;
  ScaleControl(fRadioButton);
  fRadioButton.Caption := Caption;
end;

{ TPDFFormFieldItemButton }
//------------------------------------------------------------------------------
destructor TPDFFormFieldItemComboBox.Destroy;
begin
  FreeAndNil(fComboBox);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemComboBox.Draw;
begin
  inherited;

  if not assigned(fComboBox) then
    fComboBox := TComboBox.Create(nil);

  fComboBox.Parent := ParentWinControl;
  ScaleControl(fComboBox);
  fComboBox.Text := Caption;
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
destructor TPDFFormFields.Destroy;
begin
  FreeAndNil(FCheckBoxTickPicOn);
  FreeAndNil(FCheckBoxTickPicOff);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.Draw(aPage : integer);
var
  FormFieldIndex : integer;
  CurrItem  : TPDFFormFieldItem;
begin
  if Self.Enabled then
  begin
    for FormFieldIndex := 0 to Self.Count-1 do
    begin
      CurrItem := TPDFFormFieldItem(Self.Items[FormFieldIndex]);

      if CurrItem.Page = aPage then
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

      if CurrItem.ItemIndex = FormFieldIndex then
      begin
        Result := CurrItem;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.Init;
begin
  fCheckBoxTickPicOn := TPicture.Create;
  fCheckBoxTickPicOff := TPicture.Create;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.SetCheckBoxTickOn(const aValue: TPicture);
begin
  FCheckBoxTickPicOn := aValue;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.SetCheckBoxTickOff(const aValue: TPicture);
begin
  FCheckBoxTickPicOff := aValue;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.RefreshFormField(aFieldIndex: integer;
                                          aFieldSubIndex: integer);
var
  FieldType     : integer;

  NewPDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  NewPDFFormFieldItemButton      : TPDFFormFieldItemButton;
  NewPDFFormFieldItemCheckBox    : TPDFFormFieldItemCheckBox;
  NewPDFFormFieldItemRadioButton : TPDFFormFieldItemRadioButton;
  NewPDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;

  NewPDFFormFieldItem            : TPDFFormFieldItem;

  ParentIndex : integer;
  FieldIndex  : integer;

  FieldSubCount  : integer;
  FieldSubIndex  : integer;
  TempSubIndex   : integer;
begin
  if aFieldSubIndex = -1 then
  begin
    ParentIndex := -1;
    FieldIndex  := aFieldIndex;
  end
  else
  begin
    ParentIndex := aFieldIndex;
    FieldIndex  := aFieldSubIndex;
  end;

  FieldType := fQuickPDF.GetFormFieldType(FieldIndex);

  case FieldType of
    FRM_FIELD_TYPE_TEXT : begin
      NewPDFFormFieldItemEdit := TPDFFormFieldItemEdit.Create(self);
      NewPDFFormFieldItemEdit.ItemIndex   := FieldIndex;
      NewPDFFormFieldItemEdit.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_BUTTON : begin
      NewPDFFormFieldItemButton := TPDFFormFieldItemButton.Create(self);
      NewPDFFormFieldItemButton.ItemIndex   := FieldIndex;
      NewPDFFormFieldItemButton.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_CHECKBOX : begin
      NewPDFFormFieldItemCheckBox := TPDFFormFieldItemCheckBox.Create(self);
      NewPDFFormFieldItemCheckBox.ItemIndex   := FieldIndex;
      NewPDFFormFieldItemCheckBox.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_RADIOBUTTON : begin
      NewPDFFormFieldItemRadioButton := TPDFFormFieldItemRadioButton.Create(self);
      NewPDFFormFieldItemRadioButton.ItemIndex   := FieldIndex;
      NewPDFFormFieldItemRadioButton.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_CHOICE : begin
      NewPDFFormFieldItemComboBox := TPDFFormFieldItemComboBox.Create(self);
      NewPDFFormFieldItemComboBox.ItemIndex   := FieldIndex;
      NewPDFFormFieldItemComboBox.ParentIndex := ParentIndex;
    end;
    else
    begin
      NewPDFFormFieldItem := TPDFFormFieldItem.Create(self);
      NewPDFFormFieldItem.ItemIndex   := FieldIndex;
      NewPDFFormFieldItem.ParentIndex := ParentIndex;
    end;
  end;

  FieldSubCount := fQuickPDF.GetFormFieldSubCount(FieldIndex);

  for FieldSubIndex := 1 to FieldSubCount do
  begin
    TempSubIndex := fQuickPDF.GetFormFieldSubTempIndex(FieldIndex, FieldSubIndex);

    RefreshFormField(FieldIndex, TempSubIndex);
  end;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFields.RefreshFormFields;
var
  FormFieldIndex : integer;
begin
  HiddenIndex := 0;
  Self.Clear;

  if Enabled then
  begin
    for FormFieldIndex := 1 to fQuickPDF.FormFieldCount do
      RefreshFormField(FormFieldIndex, -1);
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
  fPDFFormFields.Init;
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
    if fQuickPDF.UnlockKey(QUICK_PDF_LICENCE_KEY) = 1 then
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
  fQuickPDF.NormalizePage(fPage);

  RenderPage;

  fPDFFormFields.RefreshFormFields;
  fPDFFormFields.Draw(fPage);
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.ResetForm;
begin
  if not LoadPDF(fPDFFilePath, fPDFPassword) then
      Exit;

  fPDFImage.Visible := true;

  Refresh;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SaveToFile(aFilePath: WideString);
begin
  fQuickPDF.SaveToFile(aFilePath);
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.Print(PrinterName : Widestring;
                              StartPage : integer;
                              EndPage : integer;
                              Options : integer);
begin
  fQuickPDF.PrintDocument(PrinterName, StartPage, EndPage, Options);
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
procedure TPdfFieldEdit.SetCheckBoxTickOn(aValue: TPicture);
begin
  PDFFormFields.CheckboxTickOn.Assign(aValue);
end;

//------------------------------------------------------------------------------
function TPdfFieldEdit.GetCheckBoxTickOn: TPicture;
begin
  Result := PDFFormFields.CheckboxTickOn;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SetCheckBoxTickOff(aValue: TPicture);
begin
  PDFFormFields.CheckboxTickOff.Assign(aValue);
end;

//------------------------------------------------------------------------------
function TPdfFieldEdit.GetCheckBoxTickOff: TPicture;
begin
  Result := PDFFormFields.CheckboxTickOff;
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
