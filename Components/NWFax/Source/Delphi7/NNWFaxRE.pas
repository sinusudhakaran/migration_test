unit NNWFaxRE;

interface

uses
  Windows, Classes, SysUtils, Controls, Forms, StdCtrls, ExtCtrls, Mask,
  Dialogs, NNWFax;

type

  TRecipientsDialog = class(TForm)
    PanelRecipientProperties: TPanel;
    PanelButtons: TPanel;
    ListBoxRecipients: TListBox;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonAdd: TButton;
    ButtonDelete: TButton;
    LabelName: TLabel;
    EditName: TEdit;
    LabelCompany: TLabel;
    EditCompany: TEdit;
    GroupBoxDialingInfo: TGroupBox;
    LabelCountryCode: TLabel;
    EditCountryCode: TEdit;
    LabelAreaCode: TLabel;
    EditAreaCode: TEdit;
    LabelLocalNumber: TLabel;
    EditLocalNumber: TEdit;
    RadioGroupPriority: TRadioGroup;
    RadioGroupDelivery: TRadioGroup;
    MaskEditDate: TMaskEdit;
    MaskEditTime: TMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditCompanyExit(Sender: TObject);
    procedure EditCountryCodeExit(Sender: TObject);
    procedure EditAreaCodeExit(Sender: TObject);
    procedure EditLocalNumberExit(Sender: TObject);
    procedure RadioGroupPriorityExit(Sender: TObject);
    procedure RadioGroupDeliveryExit(Sender: TObject);
    procedure MaskEditDateExit(Sender: TObject);
    procedure MaskEditTimeExit(Sender: TObject);
    procedure EditNumberKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ListBoxRecipientsClick(Sender: TObject);
  private
    FRecipients: TRecipients;
    procedure ShowRecipientData;
  public
    function GetRecipients: TRecipients;
    procedure SetRecipients(const R: TRecipients);
  end;


implementation

{$R *.DFM}


procedure TRecipientsDialog.FormCreate(Sender: TObject);
begin
  FRecipients := TRecipients.Create(Self)
end;


procedure TRecipientsDialog.FormDestroy(Sender: TObject);
begin
  FRecipients.Free
end;


function TRecipientsDialog.GetRecipients: TRecipients;
begin
  Result := FRecipients
end;


procedure TRecipientsDialog.SetRecipients(const R: TRecipients);
begin
  FRecipients.Assign(R)
end;


procedure TRecipientsDialog.ListBoxRecipientsClick(Sender: TObject);
begin
  ShowRecipientData
end;


procedure TRecipientsDialog.ShowRecipientData;
var
  R: TRecipient;
begin
  if ListBoxRecipients.Items.Count = 0 then
  begin
    EditAreaCode.Clear;
    EditCompany.Clear;
    EditName.Clear;
    EditCountryCode.Clear;
    EditLocalNumber.Clear;
    MaskEditDate.Clear;
    MaskEditTime.Clear;
    RadioGroupPriority.ItemIndex := 1;
    RadioGroupDelivery.ItemIndex := 0;
  end
  else
  begin
    R := FRecipients.Items[ListBoxRecipients.ItemIndex];
    EditAreaCode.Text := R.AreaCode;
    EditCompany.Text := R.Company;
    EditName.Text := R.Name;
    EditCountryCode.Text := R.CountryCode;
    EditLocalNumber.Text := R.LocalNumber;
    MaskEditDate.Text := DateToStr(R.ScheduledDate);
    MaskEditTime.Text := FormatDateTime('t', R.ScheduledTime);
    case R.Delivery of
      dSendNow: RadioGroupDelivery.ItemIndex := 0;
      dHold: RadioGroupDelivery.ItemIndex := 1;
      dOffPeak: RadioGroupDelivery.ItemIndex := 2;
      dScheduled: RadioGroupDelivery.ItemIndex := 3;
    end;
    case R.Priority of
      pNormal: RadioGroupPriority.ItemIndex := 1;
      pHigh: RadioGroupPriority.ItemIndex := 0;
      pLow: RadioGroupPriority.ItemIndex := 2;
    end;
  end;

  ButtonDelete.Enabled := (ListBoxRecipients.ItemIndex >= 0);
  EditName.Enabled := (ListBoxRecipients.Items.Count > 0);
  EditCompany.Enabled := EditName.Enabled;
  EditCountryCode.Enabled := EditName.Enabled;
  EditAreaCode.Enabled := EditName.Enabled;
  EditLocalNumber.Enabled := EditName.Enabled;
  RadioGroupPriority.Enabled := EditName.Enabled;
  RadioGroupDelivery.Enabled := EditName.Enabled;
  MaskEditDate.Enabled := EditName.Enabled;
  MaskEditTime.Enabled := EditName.Enabled;
  LabelName.Enabled := EditName.Enabled;
  LabelCompany.Enabled := EditCompany.Enabled;
  LabelCountryCode.Enabled := EditCountryCode.Enabled;
  LabelAreaCode.Enabled := EditAreaCode.Enabled;
  LabelLocalNumber.Enabled := EditLocalNumber.Enabled;
end;


procedure TRecipientsDialog.ButtonOkClick(Sender: TObject);
var
  R: TRecipient;
  i: Integer;
begin
  if ActiveControl <> ButtonOk then
  begin
    if ActiveControl is TEdit then
      (ActiveControl as TEdit).OnExit(Sender)
    else if ActiveControl is TMaskEdit then
      (ActiveControl as TMaskEdit).OnExit(Sender)
    else if ActiveControl.Parent is TRadioGroup then
        ((ActiveControl.Parent) as TRadioGroup).OnExit(Sender);
  end;
  for i := 0 to ListBoxRecipients.Items.Count-1 do
  begin
    R := FRecipients.Items[i];
    if Trim(R.LocalNumber) = '' then
    begin
      ShowMessage('Please specify fax number for recipient "' + R.Name + '"');
      ListBoxRecipients.ItemIndex := i;
      ShowRecipientData;
      ActiveControl := EditLocalNumber;
      Exit;
    end;
  end;
  ModalResult := mrOk;
end;


procedure TRecipientsDialog.MaskEditDateExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.ScheduledDate := StrToDate(MaskEditDate.Text);
end;


procedure TRecipientsDialog.MaskEditTimeExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.ScheduledTime := StrToTime(MaskEditTime.Text);
end;


procedure TRecipientsDialog.RadioGroupDeliveryExit(Sender: TObject);
begin
  with FRecipients.Items[ListBoxRecipients.ItemIndex] do
    case RadioGroupDelivery.ItemIndex of
      0: Delivery := dSendNow;
      1: Delivery := dHold;
      2: Delivery := dOffPeak;
      3: Delivery := dScheduled;
    end
end;


procedure TRecipientsDialog.EditCountryCodeExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.CountryCode := EditCountryCode.Text;
end;


procedure TRecipientsDialog.EditAreaCodeExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.AreaCode := EditAreaCode.Text;
end;


procedure TRecipientsDialog.RadioGroupPriorityExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  case RadioGroupPriority.ItemIndex of
    0: R.Priority := pHigh;
    1: R.Priority := pNormal;
    2: R.Priority := pLow;
  end;
end;


procedure TRecipientsDialog.EditNameExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.Name := EditName.Text;
  ListBoxRecipients.Items[ListBoxRecipients.ItemIndex] := EditName.Text;
end;


procedure TRecipientsDialog.EditCompanyExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.Company := EditCompany.Text;
end;


procedure TRecipientsDialog.FormShow(Sender: TObject);
var
  i: Integer;
begin
  if FRecipients.Count > 0 then
  begin
    for i := 0 to FRecipients.Count - 1 do
      ListBoxRecipients.Items.Add(FRecipients.Items[i].Name);
    ListBoxRecipients.ItemIndex := 0;
    ActiveControl := ListBoxRecipients;
  end
  else
    ActiveControl := ButtonAdd;
  ShowRecipientData;
end;


procedure TRecipientsDialog.EditNumberKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0
end;


procedure TRecipientsDialog.ButtonAddClick(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Add;
  R.Name := 'Recipient ' + IntToStr(ListBoxRecipients.Items.Count + 1);
  ListBoxRecipients.Items.Add(R.Name);
  ListBoxRecipients.ItemIndex := ListBoxRecipients.Items.Count - 1;
  ShowRecipientData;
  ActiveControl := EditName;
end;


procedure TRecipientsDialog.ButtonDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  I := ListBoxRecipients.ItemIndex;
  if I >= 0 then
  begin
    ListBoxRecipients.Items.Delete(I);
    FRecipients.Items[I].Free;
    if ListBoxRecipients.Items.Count > 0 then
      if i = ListBoxRecipients.Items.Count then
        ListBoxRecipients.ItemIndex := I - 1
      else
        ListBoxRecipients.ItemIndex := I;
    ShowRecipientData
  end
end;


procedure TRecipientsDialog.EditLocalNumberExit(Sender: TObject);
var
  R: TRecipient;
begin
  R := FRecipients.Items[ListBoxRecipients.ItemIndex];
  R.LocalNumber := EditLocalNumber.Text;
end;


end.
