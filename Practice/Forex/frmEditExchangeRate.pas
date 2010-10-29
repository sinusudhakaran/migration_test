unit frmEditExchangeRate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, VirtualTreeHandler, StdCtrls, ExtCtrls,
  ExchangeRateList, ovcbase, ovcef, ovcpb, ovcpf, Buttons, OSFont;

type
  TEditExchangeRateForm = class(TForm)
    pButtons: TPanel;
    btnCancel: TButton;
    BtnoK: TButton;
    Panel1: TPanel;
    vtRates: TVirtualStringTree;
    btnQuik: TSpeedButton;
    eDate: TOvcPictureField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnQuikClick(Sender: TObject);
    procedure vtRatesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vtRatesEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vtRatesClick(Sender: TObject);
    procedure vtRatesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FEditMode: Boolean;
    FExchangeSource: TExchangeSource;
    FTreeList: TTreeBaseList;
    function ValidExchangeRates: boolean;
    function AllZero: boolean;
  public
    { Public declarations }
  end;

  function EditExchangeRate(ExchangeSource: TExchangeSource;
                            ExchangeRecord: TExchangeRecord = nil): boolean;

implementation

uses
  ImagesFrm, StDate, Math, GenUtils, bkXPThemes, ErrorMoreFrm, DateUtils;

{$R *.dfm}

const
  COL_ISO_CODE = 0;
  COL_EXCHANGE_RATE = 1;

type
  TExchangeTreeItem = class(TTreeBaseItem)
  private
    FISOCode: string;
    FExchangeRate: Double;
  public
    constructor Create(aISOCode: string; aExchangeRate: Double);
    function GetTagText(const Tag: Integer): string; override;
    procedure AfterPaintCell(const Tag : integer; Canvas:
      TCanvas; CellRect: TRect);override;
 end;

function GetRateText(const Value: Double): string;
begin
  Result := '';
  if IsNAN(Value) then
    Exit;
  if Value = 0.0 then
    Exit;
  Result := Format('%2.4f',[Value])
end;

function EditExchangeRate(ExchangeSource: TExchangeSource;
                          ExchangeRecord: TExchangeRecord): boolean;
const
  TITLE = 'Exchange Rates';
var
  i, j: integer;
  EditExchangeRateForm: TEditExchangeRateForm;
  ExchangeTreeItem: TExchangeTreeItem;
begin
  Result := false;
  if not Assigned(ExchangeSource) then Exit;

  EditExchangeRateForm := TEditExchangeRateForm.Create(Application.MainForm);
  try
    with EditExchangeRateForm do begin
      FExchangeSource := ExchangeSource;
      FEditMode := Assigned(ExchangeRecord);
      if FEditMode then begin
        //Edit
        Caption := 'Edit ' + TITLE;
        btnQuik.Visible := False;
        eDate.AsStDate := ExchangeRecord.Date;
        eDate.Enabled := False;
      end else begin
        //Add
        EditExchangeRateForm.Caption := 'Add ' + TITLE;
        ExchangeRecord := TExchangeRecord.Create(CurrentDate,
                                                 ExchangeSource.Width);
      end;

      //Display rates
      for i := 1 to ExchangeSource.Width do
        if (ExchangeSource.Header.ehCur_Type[i] <> ct_Base) then begin
          ExchangeTreeItem :=
            TExchangeTreeItem.Create(ExchangeSource.Header.ehISO_Codes[i],
                                     ExchangeRecord.Rates[i]);
          FTreeList.AddNodeItem(nil, ExchangeTreeItem);
        end;

      if ShowModal = mrOk then begin
        //Save changes
        for i := 0 to FTreeList.Count - 1 do
          for j := 1 to ExchangeRecord.Width do begin
            ExchangeTreeItem := TExchangeTreeItem(FTreeList.Items[i]);
            if (ExchangeSource.Header.ehISO_Codes[j] = ExchangeTreeItem.FISOCode) then
              ExchangeRecord.Rates[j] := ExchangeTreeItem.FExchangeRate;
          end;
        if not FEditMode then begin
          //Add Exchange record to tree
          ExchangeRecord.Date := eDate.AsStDate;
          ExchangeSource.ExchangeTree.Insert(ExchangeRecord);
        end;
        Result := true;
      end;
    end;
  finally
    EditExchangeRateForm.Free;
  end;
end;

function TEditExchangeRateForm.AllZero: boolean;
var
  i: integer;
begin
  Result := true;
  for i := 0 to FTreeList.Count - 1 do
    if TExchangeTreeItem(FTreeList.Items[i]).FExchangeRate <> 0 then begin
      Result := false;
      Exit;
    end;
end;

procedure TEditExchangeRateForm.btnQuikClick(Sender: TObject);
var
  Date: Integer;
begin
  Date := eDate.AsStDate;
  PopUpCalendar(TEdit(eDate), Date);
  eDate.AsStDate := Date;
end;

procedure TEditExchangeRateForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := true;
  if (ModalResult = mrOk) then
    CanClose := ValidExchangeRates;
end;

procedure TEditExchangeRateForm.FormCreate(Sender: TObject);
begin
  ThemeForm(Self);
  vtRates.Header.Font := Font;
  vtRates.Header.Height := Abs(vtRates.Header.Font.height) * 10 div 6;
  //So the editor fits
  vtRates.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8);

  FTreeList := TTreeBaseList.Create(vtRates);

  AppImages.Misc.GetBitmap(MISC_CALENDAR_BMP, btnQuik.Glyph);
  eDate.AsStDate := CurrentDate;
end;

procedure TEditExchangeRateForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTreeList);
end;

procedure TEditExchangeRateForm.FormShow(Sender: TObject);
begin
  if FEditMode and (FTreeList.Count > 0) then
    vtRates.EditNode(vtRates.GetFirst, COL_EXCHANGE_RATE);
end;

function TEditExchangeRateForm.ValidExchangeRates: boolean;
begin
  Result := False;
  if (not FEditMode) then begin
    if (FExchangeSource.GetDateRates(eDate.AsStDate) <> nil) then begin
      //Existing date
      HelpfulErrorMsg('The date entered already exists in the Exchange Rate information. '+
                      'Duplicates cannot be entered.', 0);
      eDate.SetFocus;
      Exit;
    end else if (eDate.AsStDate > CurrentDate) then begin
      //Future date
      HelpfulErrorMsg('The date entered is in the future. '+
                      'Please enter a valid date.', 0);
      eDate.SetFocus;
      Exit;
    end else if AllZero then begin
      //All rates are zero
      HelpfulErrorMsg('You must enter at least one exchange rate. ', 0);
      vtRates.EditNode(vtRates.GetFirst, COL_EXCHANGE_RATE);
      Exit;
    end;
  end;
  Result := True;
end;

procedure TEditExchangeRateForm.vtRatesClick(Sender: TObject);
begin
  if vtRates.FocusedNode <> nil then // edit selected node
  begin
    vtRates.EditNode(vtRates.FocusedNode, vtRates.FocusedColumn);
  end;
end;

procedure TEditExchangeRateForm.vtRatesCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
var
  StringEditLink: TStringEditLink;
begin
  StringEditLink := TStringEditLink.Create;
  StringEditLink.Edit.MaxLength := 20;
  EditLink := StringEditLink;
end;

procedure TEditExchangeRateForm.vtRatesEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := (Column <> 0);
end;

procedure TEditExchangeRateForm.vtRatesNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
var
  Data : TExchangeTreeItem;
  ExchangeRate: double;
begin
  if Trim(NewText) = '' then
    NewText := '0';
  
  if Assigned(FTreeList) then begin
    if TryStrToFloat(NewText, ExchangeRate) then begin
      Data := TExchangeTreeItem(FTreeList.Items[Node.Index]);
      case column of
        1 : Data.FExchangeRate := ExchangeRate;
      end;
    end else begin
      HelpfulErrorMsg('Please enter a valid exchange rate', 0);
      vtRates.EditNode(Node, Column);
    end;
  end;
end;

{ TExchangeTreeItem }

procedure TExchangeTreeItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
begin
  inherited;

end;

constructor TExchangeTreeItem.Create(aISOCode: string; aExchangeRate: Double);
begin
  inherited Create(aISOCode ,0);

  FISOCode := aISOCode;
  FExchangeRate := aExchangeRate;
end;

function TExchangeTreeItem.GetTagText(const Tag: Integer): string;
begin
  Result := '';
  case Tag of
    0: Result := FISOCode;
    1: Result := GetRateText(FExchangeRate);
  end;
end;

end.


