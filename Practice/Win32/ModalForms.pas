unit ModalForms;

//------------------------------------------------------------------------------
interface

uses
  Forms,
  Controls,
  Windows,
  OSFont;

type
  TModalForm = class(OSFont.TForm)
  protected
    procedure CreateParams(var params: TCreateParams); override;
  end;

//------------------------------------------------------------------------------
implementation

//------------------------------------------------------------------------------
procedure TModalForm.CreateParams(var params: TCreateParams);
begin
  inherited;

  params.WndParent := Screen.ActiveForm.Handle;
  if (params.WndParent <> 0) and (IsIconic(params.WndParent)
    or not IsWindowVisible(params.WndParent)
    or not IsWindowEnabled(params.WndParent)) then
    params.WndParent := 0;

  if params.WndParent = 0 then
    params.WndParent := Application.Handle;
end;

end.
