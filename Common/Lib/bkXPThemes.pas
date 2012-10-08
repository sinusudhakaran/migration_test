unit bkXPThemes;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

            Add this into the form create of forms to make sure that the
            appears of edit boxes etc is correct for XP

            bkXPThemes.ThemeForm( Self);
}
//------------------------------------------------------------------------------

// Delphi 7 has built-in XP theme support, there is no ThemeManager component
// available so just conditionally compile out..


interface
uses
forms;

procedure ThemeForm( aForm : TForm);



//******************************************************************************
implementation

uses
  Controls,
  Mask,
  StdCtrls,
  WinUtils,
  RZCommon,
  RZPanel,
  Classes,
  OvcPf,
  OvcNf,
  BKNumericEdit;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ThemeComponent( aComponent : TComponent);
var
  i : integer;
begin
  if aComponent is TWinControl then
  begin
    if aComponent.ComponentCount > 0 then
    begin
      for i := 0 to aComponent.ComponentCount - 1 do
      begin
        ThemeComponent( aComponent.Components[i])
      end;
    end
    else
    if aComponent is TEdit then
    begin
      TEdit(aComponent).BorderStyle := bsSingle;
      TEdit(aComponent).Ctl3D       := true;
    end
    else
    if aComponent is TMaskEdit then
    begin
      TMaskEdit(aComponent).BorderStyle := bsSingle;
      TMaskEdit(aComponent).Ctl3D       := true;
    end
    else
    if aComponent is TOvcPictureField then
    begin
      TOvcPictureField(aComponent).BorderStyle := bsSingle;
      TOvcPictureField(aComponent).Ctl3D       := true;
    end
    else
    if aComponent is TOvcNumericField then
    begin
      TOvcNumericField(aComponent).BorderStyle := bsSingle;
      TOvcNumericField(aComponent).Ctl3D       := true;
    end
    else
    if aComponent is TMemo then
    begin
      TMemo(aComponent).Ctl3D := true;
    end
    else if aComponent is TRzToolbar then
    begin
      TRzToolbar(aComponent).BorderInner := fsNone;
    end
    else if aComponent is TBKNumericEdit then
    begin
      TBKNumericEdit(aComponent).BorderStyle := bsSingle;
      TBKNumericEdit(aComponent).Ctl3D := true;    
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ThemeForm( aForm : TForm);
var
  i : integer;
  aComponent : TComponent;
begin

   if (Pos('XP', WinUtils.GetWinVer) = 0) and (Pos('Vista', WinUtils.GetWinVer) = 0) then exit;

  for i := 0 to aForm.ComponentCount - 1 do
  begin
    aComponent := aForm.Components[i];
    ThemeComponent( aComponent);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
