unit CopyMemorisationsDlg;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  baObj32,
  OSFont;

type
  TdlgCopyMemorisations = class(TForm)
    Label1: TLabel;
    cmbMemorisations: TComboBox;
    lblAccountMemorisations: TLabel;
    radCopyAll: TRadioButton;
    radCopySelected: TRadioButton;
    btnCopy: TButton;
    btnCancel: TButton;
    procedure cmbMemorisationsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Setup(BAFrom : tBank_Account);
  end;

//******************************************************************************
implementation

uses
  Globals, clObj32, BaList32, bkConst, bkXPThemes;

{$R *.dfm}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyMemorisations.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
end;

procedure TdlgCopyMemorisations.Setup(BAFrom : tBank_Account);
var
  i : Integer;
  BA : tBank_Account;
begin
  cmbMemorisations.Clear;
  if Assigned(MyClient) then
  begin
    with MyClient.clBank_Account_List do
      for i := 0 to Pred(itemCount) do
      begin
        BA := Bank_Account_At(i);
        if (BA <> BAFrom) and ( Ba.baFields.baAccount_Type = btBank) then
          cmbMemorisations.Items.AddObject(BA.Title, BA);
      end;
      //automatically select the first item
      if (cmbMemorisations.Items.Count > 0) then
        cmbMemorisations.ItemIndex := 0;

    cmbMemorisationsChange(cmbMemorisations);
  end else
    lblAccountMemorisations.Caption := '';

  radCopySelected.Checked := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCopyMemorisations.cmbMemorisationsChange(Sender: TObject);
var
  BA : tBank_Account;
begin
  if cmbMemorisations.ItemIndex > -1 then
  begin
    BA := tBank_Account(cmbMemorisations.Items.Objects[cmbMemorisations.ItemIndex]);
    if BA.baMemorisations_List.ItemCount > 0 then

        lblAccountMemorisations.Caption := 'Note: This Account already contains ' +
        IntToStr(BA.baMemorisations_List.ItemCount) + ' memorisations.'
    else
       lblAccountMemorisations.Caption := 'Note: This Account does not contain memorisations yet'
  end
  else
    lblAccountMemorisations.Caption := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
