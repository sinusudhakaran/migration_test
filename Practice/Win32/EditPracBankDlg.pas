unit EditPracBankDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkOKCancelDlg, OvcBase, StdCtrls, sydefs,
  OsFont;

type
  TdlgEditPracBank = class(TbkOKCancelDlgForm)
    Label1: TLabel;
    Label3: TLabel;
    eName: TEdit;
    stNumber: TStaticText;
    OvcController1: TOvcController;
    ePassword: TEdit;
    eConfirm: TEdit;
    Label7: TLabel;
    chkAccountDeleted: TCheckBox;
    Label20: TLabel;
    Label2: TLabel;
    chkNoChargeAccount: TCheckBox;

    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function EditPracticeBankAccount( ba : pSystem_Bank_Account_Rec) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  WarningMoreFrm,
  Admin32,
  globals,
  ErrorMorefrm,
  enterPwdDlg,
  bkXPThemes,
  LogUtil,
  AuditMgr;

{$R *.DFM}

const
   UnitName = 'EditPracBankDlg';
var
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function EditPracticeBankAccount( ba : pSystem_Bank_Account_Rec) : boolean;
const
   ThisMethodName = 'EditPracticeBankAccount';
var
  MyDlg : TdlgEditPracBank;
  DetailChanged : boolean;
  AdminBankAccount : pSystem_Bank_Account_Rec;
  AccountKey : string;
  PassOK : Boolean;
begin
  result := false;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if not Assigned(ba) then exit;

  //check password is valid
  PassOK := false;
  if ba^.sbAccount_Password <> '' then
  begin
    if EnterPassword('Edit Bank Account Details',ba^.sbAccount_Password,0,false,true) then
      passOK := true
    else
      HelpfulErrorMsg('Invalid Password.  Permission to edit this account is denied.',0);
  end
  else
    PassOK := true;

  if not PassOK then exit;

  //---------------------------------------
  myDlg := TdlgEditPracBank.Create(Application.MainForm);
  try
    with MyDlg do begin
      stNumber.Caption      := ba^.sbAccount_Number;
      eName.Text            := ba^.sbAccount_Name;
      ePassword.Text        := ba^.sbAccount_Password;
      eConfirm.Text         := ba^.sbAccount_Password;

      AccountKey            := ba^.sbAccount_Number;
      chkAccountDeleted.Checked := ba^.sbMark_As_Deleted;
      chkNoChargeAccount.Checked := ba^.sbNo_Charge_Account;

      ShowModal;

      if (ModalResult = mrOK) then
      begin
        detailChanged := (eName.text <> ba^.sbAccount_Name) or
                         (ePassword.Text <> ba^.sbAccount_Password) or
                         (chkAccountDeleted.Checked <> ba^.sbMark_As_Deleted) or
                         (chkNoChargeAccount.Checked <> ba^.sbNo_Charge_Account);

        if detailChanged then
        begin
          //now save the bank account back into the admin system
          if LoadAdminSystem(true, ThisMethodName ) then
          begin
            result := true;  //reload of list needed after reload

            AdminBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(AccountKey);
            if Assigned(AdminBankAccount) then
            begin
              //account found in reloaded admin so update
              AdminBankAccount^.sbAccount_Name := eName.Text;
              AdminBankAccount^.sbAccount_Password := ePassword.Text;
              AdminBankAccount^.sbMark_As_Deleted  := chkAccountDeleted.Checked;
              AdminBankAccount^.sbNo_Charge_Account := chkNoChargeAccount.Checked;

              //*** Flag Audit ***
              SystemAuditMgr.FlagAudit(arSystemBankAccounts);

              SaveAdminSystem;
            end
            else
            begin
              UnlockAdmin;
              HelpfulErrorMsg('Bank Account '+AccountKey+' no longer found in Admin System.  Account not updated.',0);
            end;
          end
          else
            HelpfulErrorMsg('Unable to Update Bank Account Information.  Admin System cannot be loaded',0);
        end;
      end;
    end; //with
  finally
    myDlg.free;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracBank.btnOKClick(Sender: TObject);
begin
  if btnOK.ModalResult = mrOK then exit;

  //verify passwords ok
  if (ePassword.Text = eConfirm.Text) then
  begin
    btnOK.ModalResult := mrOK;
    btnOK.Click;
  end
  else
  begin
    HelpfulWarningMsg('The Passwords you have entered do not match. Please Re-enter them.',0);
    ePassword.SetFocus;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEditPracBank.FormCreate(Sender: TObject);
begin
  inherited;
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;
  SetPasswordFont(ePassword);
  SetPasswordFont(eConfirm);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditPracBank.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Bank_Accounts;
   //Components
   eName.Hint       :=
                    'Edit Account Name if necessary|' +
                    'Account name for this Bank Account';
   ePassword.Hint   :=
                    'Enter a Password|' +
                    'Enter a Password to restrict access to this Bank Account';
   eConfirm.Hint    :=
                    'Confirm the Password entered above|' +
                    'Re-enter the Password entered above to confirm it';
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

initialization
   DebugMe := DebugUnit(UnitName);
end.
