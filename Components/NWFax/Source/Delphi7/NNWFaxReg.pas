unit NNWFaxReg;

interface

uses
  Classes, DesignIntf, DesignEditors, NNWFax, NNWFaxRE;

type

  TRecipientsProperty = class(TPropertyEditor)
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

  TAboutProperty = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
  end;


procedure Register;


implementation

uses
  Forms, Controls;


procedure TRecipientsProperty.Edit;
var
  RecipientsDialog: TRecipientsDialog;
begin
  RecipientsDialog := TRecipientsDialog.Create(Application);
  try
    RecipientsDialog.SetRecipients(TRecipients(GetOrdValue));
    if RecipientsDialog.ShowModal = mrOk then
    begin
      TRecipients(GetOrdValue).Assign(RecipientsDialog.GetRecipients);
      Modified
    end
  finally
    RecipientsDialog.Free
  end
end;


function TRecipientsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly]
end;


function TRecipientsProperty.GetValue: string;
begin
  Result := '(' + GetPropType^.Name + ')'
end;


function TAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paReadOnly]
end;


procedure Register;
begin
  RegisterComponents('Fractal', [TNNWFax]);
  RegisterPropertyEditor(TypeInfo(TRecipients), TNNWFax, '', TRecipientsProperty);
  RegisterPropertyEditor(TypeInfo(string), TNNWFax, 'About', TAboutProperty);
end;


end.
