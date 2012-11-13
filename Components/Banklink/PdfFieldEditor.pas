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
  Mask,
  Graphics,
  QuickPDF;

type
  //----------------------------------------------------------------------------
  TPDFRect = record
    Left   : integer;
    Top    : integer;
    Width  : integer;
    Height : integer;
  end;

  //----------------------------------------------------------------------------
  // Base Form Field Item
  TPDFFormFieldItem = class(TCollectionItem)
  private
    fSelfIndex : integer;
    fParentIndex : integer;
    fScale : Double;
    fLinkedFields : TList;
  protected
    fControl : TControl;

    function GetQuickPDF : TQuickPDF;
    function GetParentWinControl : TWinControl;
    function GetCheckboxTickOn : TPicture;
    function GetCheckboxTickOff : TPicture;
    procedure ScaleControl;

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
    destructor Destroy; override;

    procedure Draw; virtual;

    Procedure AddLinkFieldByTitle(aTitle : Widestring);

    property QuickPDF : TQuickPDF  read GetQuickPDF;
    property ParentWinControl : TWinControl read GetParentWinControl;
    property CheckboxTickOn : TPicture read GetCheckboxTickOn;
    property CheckboxTickOff : TPicture read GetCheckboxTickOff;
    property SelfIndex : integer read fSelfIndex write fSelfIndex;
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
    property IsReadOnly : boolean read GetReadOnly  write SetReadOnly;
    property Visible  : boolean read GetVisible   write SetVisible;
    property Description : WideString read GetDescription write SetDescription;
    property Caption : WideString read GetCaption write SetCaption;

    property Scale : Double read fScale write fScale;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemEdit = class(TPDFFormFieldItem)
  private
    fshpClear : TShape;
  protected
    procedure EditOnChange(Sender: TObject);
    Procedure EditOnExit(Sender: TObject);

    function GetEdit : TEdit;
    procedure SetEdit(aValue : TEdit);
    function GetShpClear : TShape;
    procedure SetShpClear(aValue : TShape);
  public
    destructor Destroy; override;

    procedure Draw; override;

    property Edit : TEdit read GetEdit write SetEdit;
    property ShpClear : TShape read GetShpClear write SetShpClear;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemCheckBox = class(TPDFFormFieldItem)
  private
    fshpClear : TShape;
  protected
    Procedure CheckBoxClick(Sender: TObject);

    function GetCheckBox : TCheckBox;
    procedure SetCheckBox(aValue : TCheckBox);
  public
    destructor Destroy; override;

    procedure Draw; override;

    property CheckBox : TCheckBox read GetCheckBox write SetCheckBox;
    property ShpClear : TShape read fshpClear write fshpClear;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemButton = class(TPDFFormFieldItem)
  protected
    function GetButton : TButton;
    procedure SetButton(aValue : TButton);
  public
    procedure Draw; override;

    property Button : TButton read GetButton write SetButton;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemRadioButton = class(TPDFFormFieldItem)
  private
    fshpClear : TShape;
  protected
    function GetRadioButton : TRadioButton;
    procedure SetRadioButton(aValue : TRadioButton);
  public
    destructor Destroy; override;
    procedure Draw; override;

    property RadioButton : TRadioButton read GetRadioButton write SetRadioButton;
    property ShpClear : TShape read fshpClear write fshpClear;
  end;

  //----------------------------------------------------------------------------
  TPDFFormFieldItemComboBox = class(TPDFFormFieldItem)
  private
    fshpClear : TShape;
    FOnChange: TNotifyEvent;
  protected
    Procedure ComboOnCloseUp(Sender: TObject);
    procedure ComboOnSelect(Sender: TObject);

    function GetComboBox : TComboBox;
    procedure SetComboBox(aValue : TComboBox);
  public
    destructor Destroy; override;
    procedure Draw; override;

    property ComboBox : TComboBox read GetComboBox write SetComboBox;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
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
    fImagePage : integer;

    fQrCodeImage : TImage;
  protected
    procedure RenderPage;
    procedure SetActive(Value : Boolean);
    procedure SetPage(Value : integer);
    procedure SetZoom(Value : integer);
    procedure SetCheckBoxTickOn(aValue: TPicture);
    function GetCheckBoxTickOn : TPicture;
    procedure SetCheckBoxTickOff(aValue: TPicture);
    function GetCheckBoxTickOff : TPicture;
    procedure DrawQRCodeOnPDF(aQuickPDF : TQuickPDF);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function LoadPDF(aFilePath: WideString; aPassword : WideString = '') : Boolean;
    procedure Refresh;

    Procedure SaveToFile(aFilePath : WideString);
    Procedure SaveToFileFlattened(aFilePath : WideString);
    Procedure Print(aTempFilePath : String;
                    PrinterName : Widestring;
                    StartPage : integer;
                    EndPage : integer;
                    Options : integer);
    Function PrintOptions(aPageScaling: Integer;
                          aAutoRotateCenter: Integer;
                          aTitle: WideString): Integer;
    function PageCount : integer;
    Procedure ResetForm;
    procedure AutoSetControlTabs;
    procedure ScaleScreenToPDF(aInXPos, aInYPos, aInWidth, aInHeight : integer;
                               var aOutXPos, aOutYPos, aOutWidth, aOutHeight : double);
    procedure SetQrCodeImage(const aValue : TBitmap);
    procedure DrawQRCode(aXPos, aYPos, aWidth, aHeight, aPage : integer);

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

  QUICK_PDF_LICENCE_KEY = 'jz8dr7ow7gi4qu7z181e6e39y';

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
procedure TPDFFormFieldItem.AddLinkFieldByTitle(aTitle: Widestring);
var
  FieldToLink : TPDFFormFieldItem;
begin
  FieldToLink := TPDFFormFields(Collection).GetFieldByTitle(aTitle);
  if Assigned(FieldToLink) then
  begin
    fLinkedFields.Add(FieldToLink);
  end;
end;

//----------------------------------------------------------------------------
constructor TPDFFormFieldItem.Create(Collection: TCollection);
begin
  inherited;

  fLinkedFields := TList.Create;
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItem.Destroy;
begin
  FreeAndNil(fLinkedFields);
  FreeAndNil(fControl);
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
  fControl.Parent := ParentWinControl;
  ScaleControl;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.ScaleControl;
begin
  fScale := TPDFFormFields(self.Collection).DPI / FRM_FIELD_DPI;

  fControl.Left   := round(Bound.Left   * fScale);
  fControl.Top    := round(Bound.Top    * fScale);
  fControl.Width  := round(Bound.Width  * fScale);
  fControl.Height := round(Bound.Height * fScale);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTitle: WideString;
begin
  Result := QuickPDF.GetFormFieldTitle(fSelfIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetType: Integer;
begin
  Result := QuickPDF.GetFormFieldType(fSelfIndex);
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
  Result := QuickPDF.GetFormFieldFontName(fSelfIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetSubCount : integer;
begin
  Result := QuickPDF.GetFormFieldSubCount(fSelfIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTabOrder : integer;
begin
  Result := QuickPDF.GetFormFieldTabOrder(fSelfIndex);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetValue: WideString;
begin
  Result := QuickPDF.GetFormFieldValue(fSelfIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetValue(Value: WideString);
var
  LinkIndex : integer;
begin
  QuickPDF.SetFormFieldValue(fSelfIndex, Value);

  if assigned(fLinkedFields) then
  begin
    for LinkIndex := 0 to fLinkedFields.Count - 1 do
    begin
      if (Assigned(fLinkedFields.Items[LinkIndex])) then
        TPDFFormFieldItem(fLinkedFields.Items[LinkIndex]).Value := Value;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetBound: TPDFRect;
begin
  Result.Left   := Round(QuickPDF.GetFormFieldBound(fSelfIndex, FRM_FIELD_BOUND_LEFT));
  Result.Top    := Round(QuickPDF.GetFormFieldBound(fSelfIndex, FRM_FIELD_BOUND_TOP));
  Result.Width  := Round(QuickPDF.GetFormFieldBound(fSelfIndex, FRM_FIELD_BOUND_WIDTH));
  Result.Height := Round(QuickPDF.GetFormFieldBound(fSelfIndex, FRM_FIELD_BOUND_HEIGHT));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetBound(Value: TPDFRect);
begin
  QuickPDF.SetFormFieldBounds(fSelfIndex, Value.Left, Value.Top, Value.Width, Value.Height);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetPage: integer;
begin
  Result := QuickPDF.GetFormFieldPage(fSelfIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetPage(Value: integer);
begin
  QuickPDF.SetFormFieldPage(fSelfIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetTextSize : integer;
begin
  Result := round(QuickPDF.GetFormFieldTextSize(fSelfIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetTextSize(Value : integer);
begin
  QuickPDF.SetFormFieldTextSize(fSelfIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetMaxLen : integer;
begin
  Result := QuickPDF.GetFormFieldMaxLen(fSelfIndex);
end;
//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetMaxLen(Value : integer);
begin
  QuickPDF.SetFormFieldMaxLen(fSelfIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetReadOnly : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldReadOnly(fSelfIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetReadOnly(Value : boolean);
begin
  QuickPDF.SetFormFieldReadOnly(fSelfIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetVisible : boolean;
begin
  Result := IntToBool(QuickPDF.GetFormFieldVisible(fSelfIndex));
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetVisible(Value : boolean);
begin
  QuickPDF.SetFormFieldVisible(fSelfIndex, BooltoInt(Value));
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetDescription: WideString;
begin
  Result := QuickPDF.GetFormFieldDescription(fSelfIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetDescription(Value: WideString);
begin
  QuickPDF.SetFormFieldDescription(fSelfIndex, Value);
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItem.GetCaption : WideString;
begin
  Result := QuickPDF.GetFormFieldCaption(fSelfIndex);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItem.SetCaption(Value : WideString);
begin
  QuickPDF.SetFormFieldCaption(fSelfIndex, Value);
end;

{ TPDFFormFieldItemEdit }
//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.EditOnChange(Sender: TObject);
begin
  // WORKAROUND:
  // Use the OnChange event to keep the Value and the Edit.Text in sync. This
  // solves the problem when an ALT-shortcut is used, and the OnExit is never
  // called.
  Value := Edit.Text;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.EditOnExit(Sender: TObject);
begin
  Value := Edit.Text;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItemEdit.GetEdit: TEdit;
begin
  if not Assigned(fControl) then
    fControl := TEdit.create(nil);

  Result := TEdit(fControl);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.SetEdit(aValue: TEdit);
begin
  TEdit(fControl) := aValue;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItemEdit.GetShpClear : TShape;
begin
  if not Assigned(fshpClear) then
  begin
    fshpClear := TShape.create(nil);
    fshpClear.Parent := ParentWinControl;
  end;

  Result := TShape(fshpClear);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.SetShpClear(aValue : TShape);
begin
  fshpClear := aValue;
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItemEdit.Destroy;
begin
  FreeAndNil(fshpClear);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemEdit.Draw;
var
  DPI : double;
  TextHeight : integer;
  TextExtra  : integer;
begin
  Edit.Tag := 0;

  inherited;
  
  Edit.BringToFront;

  Edit.Text := Value;
  Edit.visible := ((not self.IsReadOnly) and (self.Visible));
  Edit.BorderStyle := bsNone;
  DPI := Edit.Font.PixelsPerInch;

  Edit.Font.Size := trunc(self.TextSize * ((FRM_FIELD_DPI/DPI)*Scale));

  TextHeight := round(Edit.Font.Size * 1.7);
  TextExtra := Edit.Height - TextHeight;

  Edit.Top := Edit.Top + round(TextExtra/2);
  Edit.Height := TextHeight;
  Edit.Left := Edit.Left + round(2*Scale);
  Edit.Width := (Edit.Width - round(4*Scale)) - 1;

  Edit.Color := $00EEEEDD;
  Edit.TabOrder := TabOrder;
  Edit.OnChange := EditOnChange;
  Edit.OnExit := EditOnExit;
end;

{ TPDFFormFieldItemCheckBox }
//------------------------------------------------------------------------------
function TPDFFormFieldItemCheckBox.GetCheckBox: TCheckBox;
begin
  if not Assigned(fControl) then
  begin
    fshpClear := TShape.Create(nil);
    fControl := TCheckBox.Create(nil);
  end;

  Result := TCheckBox(fControl);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.SetCheckBox(aValue: TCheckBox);
begin
  TCheckBox(fControl) := aValue;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.CheckBoxClick(Sender: TObject);
begin
  if Checkbox.Checked then
    Value := 'Yes'
  else
    Value := 'Off';
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItemCheckBox.Destroy;
begin
  FreeAndNil(fshpClear);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemCheckBox.Draw;
begin
  CheckBox.Tag := 0;

  fshpClear.Parent := ParentWinControl;
  CheckBox.Parent := ParentWinControl;
  CheckBox.BringToFront;

  ScaleControl;
  CheckBox.OnClick := CheckBoxClick;

  fshpClear.Top    := CheckBox.Top - 1;
  fshpClear.Left   := CheckBox.Left - 1;
  fshpClear.Width  := CheckBox.Width + 2;
  fshpClear.Height := CheckBox.Height + 2;

  fshpClear.Brush.Color := clWhite;
  fshpClear.Pen.Color := clWhite;

  CheckBox.TabOrder := TabOrder;
  CheckBox.Width    := CheckBox.Height;
  CheckBox.Left     := CheckBox.Left + 6;
end;

{ TPDFFormFieldItemButton }
//------------------------------------------------------------------------------
function TPDFFormFieldItemButton.GetButton: TButton;
begin
  if not Assigned(fControl) then
    fControl := TButton.create(nil);

  Result := TButton(fControl);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemButton.SetButton(aValue: TButton);
begin
  TButton(fControl) := aValue;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemButton.Draw;
begin
  Button.Tag := 0;

  inherited;

  Button.Caption := Caption;
end;

{ TPDFFormFieldItemRadioButton }
//------------------------------------------------------------------------------
function TPDFFormFieldItemRadioButton.GetRadioButton: TRadioButton;
begin
  if not Assigned(fControl) then
  begin
    fshpClear := TShape.Create(nil);
    fControl := TRadioButton.Create(nil);
  end;

  Result := TRadioButton(fControl);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemRadioButton.SetRadioButton(aValue: TRadioButton);
begin
  TRadioButton(fControl) := aValue;
end;

//------------------------------------------------------------------------------
destructor TPDFFormFieldItemRadioButton.Destroy;
begin
  FreeAndNil(fshpClear);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemRadioButton.Draw;
begin
  RadioButton.Tag := 0;

  fshpClear.Parent := ParentWinControl;
  RadioButton.Parent := ParentWinControl;
  RadioButton.BringToFront;

  ScaleControl;

  fshpClear.Top    := RadioButton.Top - 1;
  fshpClear.Left   := RadioButton.Left - 1;
  fshpClear.Width  := RadioButton.Width + 2;
  fshpClear.Height := RadioButton.Height + 2;

  fshpClear.Brush.Color := clWhite;
  fshpClear.Pen.Color := clWhite;

  RadioButton.TabOrder := TabOrder;
  RadioButton.Width    := RadioButton.Height;
  RadioButton.Top  := RadioButton.Top - 2;
  RadioButton.Left := RadioButton.Left + 8;
end;

{ TPDFFormFieldItemButton }
//------------------------------------------------------------------------------
procedure TPDFFormFieldItemComboBox.ComboOnCloseUp(Sender: TObject);
begin
  Value := ComboBox.Text;
end;

//------------------------------------------------------------------------------
function TPDFFormFieldItemComboBox.GetComboBox: TComboBox;
begin
  if not Assigned(fControl) then
  begin
    fshpClear := TShape.Create(nil);
    fControl := TComboBox.create(nil);
  end;

  Result := TComboBox(fControl);
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemComboBox.SetComboBox(aValue: TComboBox);
begin
  TComboBox(fControl) := aValue;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemComboBox.ComboOnSelect(Sender: TObject);
begin
  Value := ComboBox.Text;

  if Assigned(FOnChange) then
  begin
    FOnChange(Sender);
  end;
end;

destructor TPDFFormFieldItemComboBox.Destroy;
begin
  FreeAndNil(fshpClear);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TPDFFormFieldItemComboBox.Draw;
begin
  ComboBox.Tag := 0;

  fshpClear.Parent := ParentWinControl;
  ComboBox.Parent := ParentWinControl;
  ComboBox.BringToFront;

  ScaleControl;

  fshpClear.Top    := ComboBox.Top - 2;
  fshpClear.Left   := ComboBox.Left - 2;
  fshpClear.Width  := ComboBox.Width + 4;
  fshpClear.Height := round(Bound.Height * fScale) + 4;

  fshpClear.Brush.Color := clWhite;
  fshpClear.Pen.Color := clWhite;

  ComboBox.TabOrder := TabOrder;
  ComboBox.OnSelect := ComboOnSelect;
  ComboBox.Top  := ComboBox.Top + 8;
  ComboBox.Left := ComboBox.Left + 2;
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

      if CurrItem.SelfIndex = FormFieldIndex then
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
      NewPDFFormFieldItemEdit.SelfIndex   := FieldIndex;
      NewPDFFormFieldItemEdit.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_BUTTON : begin
      NewPDFFormFieldItemButton := TPDFFormFieldItemButton.Create(self);
      NewPDFFormFieldItemButton.SelfIndex   := FieldIndex;
      NewPDFFormFieldItemButton.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_CHECKBOX : begin
      NewPDFFormFieldItemCheckBox := TPDFFormFieldItemCheckBox.Create(self);
      NewPDFFormFieldItemCheckBox.SelfIndex   := FieldIndex;
      NewPDFFormFieldItemCheckBox.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_RADIOBUTTON : begin
      NewPDFFormFieldItemRadioButton := TPDFFormFieldItemRadioButton.Create(self);
      NewPDFFormFieldItemRadioButton.SelfIndex   := FieldIndex;
      NewPDFFormFieldItemRadioButton.ParentIndex := ParentIndex;
    end;
    FRM_FIELD_TYPE_CHOICE : begin
      NewPDFFormFieldItemComboBox := TPDFFormFieldItemComboBox.Create(self);
      NewPDFFormFieldItemComboBox.SelfIndex   := FieldIndex;
      NewPDFFormFieldItemComboBox.ParentIndex := ParentIndex;
    end;
    else
    begin
      NewPDFFormFieldItem := TPDFFormFieldItem.Create(self);
      NewPDFFormFieldItem.SelfIndex   := FieldIndex;
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
procedure TPdfFieldEdit.AutoSetControlTabs;
  procedure FixTabOrder(const aParentControl: TWinControl);
  var
    CtrlIndex, ListIndex: Integer;
    List: TList;
    WinCtrl : TWinControl;
  begin
    List := TList.Create;
    try
      for CtrlIndex := 0 to aParentControl.ControlCount - 1 do
      begin
        if (aParentControl.Controls[CtrlIndex] is TWinControl) then
        begin
          WinCtrl := TWinControl(aParentControl.Controls[CtrlIndex]);
          if List.Count = 0 then
            ListIndex := 0
          else
          begin
            for ListIndex := 0 to List.Count - 1 do
            begin
              if ((WinCtrl.Top + WinCtrl.Height) < TControl(List[ListIndex]).Top) or
                 ((WinCtrl.Top <= TControl(List[ListIndex]).Top + TControl(List[ListIndex]).Height) and
                  ((WinCtrl.Top + WinCtrl.Height) >= TControl(List[ListIndex]).Top) and
                  (WinCtrl.Left < TControl(List[ListIndex]).Left)) then
                Break;
            end;
          end;

          List.Insert(ListIndex, WinCtrl) ;
          FixTabOrder(WinCtrl) ;
        end;
      end;

      for CtrlIndex := 0 to List.Count - 1 do
        TWinControl(List[CtrlIndex]).TabOrder := CtrlIndex;
    finally
      FreeAndNil(List);
    end;
  end;
begin
  FixTabOrder(Self);
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.ScaleScreenToPDF(aInXPos, aInYPos, aInWidth, aInHeight : integer;
                                         var aOutXPos, aOutYPos, aOutWidth, aOutHeight : double);
var
  Scale : double;
begin
  Scale := DPI / FRM_FIELD_DPI;

  aOutXPos   := aInXPos   / Scale;
  aOutYPos   := aInYPos   / Scale;
  aOutWidth  := aInWidth  / Scale;
  aOutHeight := aInHeight / Scale;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SetQRCodeImage(const aValue: TBitmap);
var
  MemStream : TMemoryStream;
begin
  MemStream := TMemoryStream.Create;

  try
    aValue.SaveToStream(MemStream);
    MemStream.Position := 0;

    if not Assigned(fQrCodeImage) then
    begin
      fQrCodeImage := TImage.Create(nil);
      fQrCodeImage.Parent := self;
      fQrCodeImage.Stretch := true;
    end;
    fQrCodeImage.Picture.Bitmap.LoadFromStream(MemStream);

  finally
    FreeAndNil(MemStream);
  end;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.DrawQRCode(aXPos, aYPos, aWidth, aHeight, aPage : integer);
begin
  fQrCodeImage.Stretch := false;
  fQrCodeImage.Left   := aXPos - self.HorzScrollBar.Position;
  fQrCodeImage.Top    := aYPos - self.VertScrollBar.Position;
  fQrCodeImage.Width  := aWidth;
  fQrCodeImage.Height := aHeight;
  fImagePage := aPage;
  fQrCodeImage.Visible := (fImagePage = 1);
  fQrCodeImage.Stretch := true;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.DrawQRCodeOnPDF(aQuickPDF : TQuickPDF);
var
  MemStream : TMemoryStream;
  ImageId : integer;
  OutXPos, OutYPos, OutWidth, OutHeight : double;
begin
  if not Assigned(fQrCodeImage.Picture.Bitmap) then
    Exit;

  aQuickPDF.SetOrigin(1);
  MemStream := TMemoryStream.Create;
  try
    fQrCodeImage.Picture.Bitmap.SaveToStream(MemStream);
    MemStream.Position := 0;
    ImageId := aQuickPDF.AddImageFromStream(MemStream, 0);

    ScaleScreenToPDF(fQrCodeImage.left + Self.HorzScrollBar.Position,
                     fQrCodeImage.top  + Self.VertScrollBar.Position,
                     fQrCodeImage.Width,
                     fQrCodeImage.Height,
                     OutXPos,
                     OutYPos,
                     OutWidth,
                     OutHeight);

    if aQuickPDF.SelectImage(ImageId) = 1 then
    begin
      if fImagePage > 1 then
        aQuickPDF.SelectPage(fImagePage);

      aQuickPDF.DrawImage(OutXPos, OutYPos, OutWidth, OutHeight);
    end;

  finally
    FreeAndNil(MemStream);
  end;
end;

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
  if Assigned(fQrCodeImage) then
    FreeAndNil(fQrCodeImage);

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
var
  tempQuickPDF : TQuickPDF;
begin
  tempQuickPDF := TQuickPDF.Create;
  try
    if fQuickPDF.SaveToFile(aFilePath) = 1 then
    begin
      if tempQuickPDF.UnlockKey(QUICK_PDF_LICENCE_KEY) = 1 then
      begin
        if tempQuickPDF.LoadFromFile(aFilePath,'') = 1 then
        begin
          if Assigned(fQrCodeImage) then
          begin
            DrawQRCodeOnPDF(tempQuickPDF);
          end;

          tempQuickPDF.SaveToFile(aFilePath);
        end;
      end;
    end;
  finally
    FreeAndNil(tempQuickPDF);
  end;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.SaveToFileFlattened(aFilePath : WideString);
var
  tempQuickPDF : TQuickPDF;
  FieldIndex : integer;
  FieldSubCount : integer;
  TempSubIndex : integer;
  FieldSubIndex : integer;
begin
  tempQuickPDF := TQuickPDF.Create;
  try
    if fQuickPDF.SaveToFile(aFilePath) = 1 then
    begin
      if tempQuickPDF.UnlockKey(QUICK_PDF_LICENCE_KEY) = 1 then
      begin
        if tempQuickPDF.LoadFromFile(aFilePath,'') = 1 then
        begin
          for FieldIndex := tempQuickPDF.FormFieldCount downto 1 do
          begin
            FieldSubCount := tempQuickPDF.GetFormFieldSubCount(FieldIndex);

            for FieldSubIndex := FieldSubCount downto 1 do
            begin
              TempSubIndex := tempQuickPDF.GetFormFieldSubTempIndex(FieldIndex, FieldSubIndex);

              tempQuickPDF.FlattenFormField(TempSubIndex);
            end;

            tempQuickPDF.FlattenFormField(FieldIndex);
          end;

          if Assigned(fQrCodeImage) then
          begin
            DrawQRCodeOnPDF(tempQuickPDF);
          end;

          tempQuickPDF.SaveToFile(aFilePath);
        end;
      end;
    end;
  finally
    FreeAndNil(tempQuickPDF);
  end;
end;

//------------------------------------------------------------------------------
procedure TPdfFieldEdit.Print(aTempFilePath : String;
                              PrinterName : Widestring;
                              StartPage : integer;
                              EndPage : integer;
                              Options : integer);
var
  tempQuickPDF : TQuickPDF;
  FieldIndex : integer;
  FieldSubCount : integer;
  TempSubIndex : integer;
  FieldSubIndex : integer;
begin
  tempQuickPDF := TQuickPDF.Create;
  try
    if fQuickPDF.SaveToFile(aTempFilePath) = 1 then
    begin
      try
        if tempQuickPDF.UnlockKey(QUICK_PDF_LICENCE_KEY) = 1 then
        begin
          if tempQuickPDF.LoadFromFile(aTempFilePath,'') = 1 then
          begin
            for FieldIndex := tempQuickPDF.FormFieldCount downto 1 do
            begin
              FieldSubCount := tempQuickPDF.GetFormFieldSubCount(FieldIndex);

              for FieldSubIndex := FieldSubCount downto 1 do
              begin
                TempSubIndex := tempQuickPDF.GetFormFieldSubTempIndex(FieldIndex, FieldSubIndex);

                tempQuickPDF.FlattenFormField(TempSubIndex);
              end;

              tempQuickPDF.FlattenFormField(FieldIndex);
            end;

            if Assigned(fQrCodeImage) then
            begin
              DrawQRCodeOnPDF(tempQuickPDF);
            end;

            tempQuickPDF.PrintDocument(PrinterName, StartPage, EndPage, Options);
          end;
        end;
      finally
        SysUtils.DeleteFile(aTempFilePath);
      end;
    end;
  finally
    FreeAndNil(tempQuickPDF);
  end;
end;

//------------------------------------------------------------------------------
function TPdfFieldEdit.PrintOptions(aPageScaling: Integer;
                                    aAutoRotateCenter: Integer;
                                    aTitle: WideString): Integer;
begin
  Result := fQuickPDF.PrintOptions(aPageScaling, aAutoRotateCenter, aTitle);
end;

//------------------------------------------------------------------------------
function TPdfFieldEdit.PageCount : integer;
begin
  Result := fQuickPDF.PageCount;
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
