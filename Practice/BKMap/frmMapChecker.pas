unit frmMapChecker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    btnCheck: TButton;
    sbStatus: TStatusBar;
    moResults: TMemo;
    Label1: TLabel;
    procedure btnCheckClick(Sender: TObject);
  private
    { Private declarations }
    FErrors: Boolean;
    function AddToMap(ClientLRN, AccountLRN: Integer): Boolean;
    function CheckClientFile(Code: string; LRN: Integer): Boolean;    
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses Admin32, Globals, SyDefs, clobj32, SYamIO, Files, WinUtils;

{$R *.dfm}

// Add an entry to the client-account map if its not already there
// Returns TRUE if changes were made
function TMainForm.AddToMap(ClientLRN, AccountLRN: Integer): Boolean;
var
  pM: pClient_Account_Map_Rec;
begin
  Result := False;
  if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindLRN(AccountLRN, ClientLRN)) then
  begin
    pM := New_Client_Account_Map_Rec;
    if Assigned(pM) then
    begin
      pM.amClient_LRN := ClientLRN;
      pM.amAccount_LRN := AccountLRN;
      pM.amLast_Date_Printed := 0;
      AdminSystem.fdSystem_Client_Account_Map.Insert(pM);
      Result := True;
    end;
  end;
end;

// Read the bank accounts of each client file, if the bank account exists in the
// admin system then make sure there is a client account map entry for it
// Returns TRUE if changes were made
function TMainForm.CheckClientFile(Code: string; LRN: Integer): Boolean;
var
  i: Integer;
  ac: string;
  Client: TClientObj;
  pS: pSystem_Bank_Account_Rec;
begin
  {$Define MAPCHECK}
  Result := False;
  OpenAClientForRead(Code, Client);
  try
    if Assigned(Client) then
    begin
      for i := 0 to Pred(Client.clBank_Account_List.ItemCount) do
      begin
        // Is account in admin system?
        ac := Client.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number;
        pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(ac);
        if Assigned(pS) then // Yes - add to map if not there already
        begin
          if AddToMap(LRN, pS.sbLRN) then
          begin
            FErrors := True;
            moResults.Lines.Add('Client Code "' + Code + '" had account number "' + ac + '" missing -> added');
            pS.sbAttach_Required := False;
            Result := True;
          end;
        end;
      end;
    end;
  finally
    Client.Free;
    Client := nil;
  end;
  {$UnDef MAPCHECK}   
end;

procedure TMainForm.btnCheckClick(Sender: TObject);
var
  i: Integer;
  Msg: string;
  pF: pClient_File_Rec;
  pM: pClient_Account_Map_Rec;
  pS: pSystem_Bank_Account_Rec;
  pC: pClient_File_Rec;
begin
  FErrors := False;
  moResults.Lines.Clear;
  btnCheck.Enabled := False;
  try
    // Make sure we're in a BK5 folder
    if not AdminExists then
    begin
      MessageDlg('The BankLink Admin System (SYSTEM.DB) cannot be found.'#13'Please make sure ' +
        ExtractFileName(Application.ExeName) + ' is running from your BankLink Data Directory.',
        mtError, [mbOk], 0);
      exit;
    end;

    // Backup admin
    sbStatus.SimpleText := 'Backing up existing admin system...';
    CopyFile(PChar(DATADIR + SYSFILENAME), PChar(DATADIR + ChangeFileExt(SYSFILENAME, '.MAP')), False);

    // Load admin
    sbStatus.SimpleText := 'Loading admin system...';
    LoadAdminSystem(True, 'StartUp');

    // Look thru each client file in the admin system, make sure there is a
    // client-account map entry for every attached bank account as long as the bank
    // account is in the admin system
    sbStatus.SimpleText := 'Checking client files...';
    for i := 0 to Pred(AdminSystem.fdSystem_Client_File_List.ItemCount) do
    begin
      pF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
      if not CheckClientFile(pF.cfFile_Code, pF.cfLRN) then
        moResults.Lines.Add('Client Code "' + pF.cfFile_Code + '" OK');
    end;

    // Read through each client account map entry and remove entries that have an
    // a client LRN that no longer exists in the admin system
    sbStatus.SimpleText := 'Checking client-account map...';
    i := 0;
    while i < AdminSystem.fdSystem_Client_Account_Map.ItemCount do
    begin
      pM := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
      pS := AdminSystem.fdSystem_Bank_Account_List.FindLRN(pM.amAccount_LRN);
      pC := AdminSystem.fdSystem_Client_File_List.FindLRN(pM.amClient_LRN);
      if not Assigned(pS) then // map record exists for non-existant account
      begin
        AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
        moResults.Lines.Add('Client LRN "' + IntToStr(pM.amClient_LRN) + '" and account LRN "' + IntToStr(pM.amClient_LRN) + '" orphaned -> deleted');
        FErrors := True;
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pM.amAccount_LRN)) then
        begin
          pS.sbAttach_Required := True;
          moResults.Lines.Add('Account LRN "' + IntToStr(pM.amAccount_LRN) + '" orphaned -> unattached');
          FErrors := True;
        end;
      end
      else if not Assigned(pC) then // map record exists for non-existant client
      begin
        AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
        moResults.Lines.Add('Client LRN "' + IntToStr(pM.amClient_LRN) + '" and account number "' + pS.sbAccount_Number + '" orphaned -> deleted');
        FErrors := True;
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pS.sbLRN)) then
        begin
          pS.sbAttach_Required := True;
          moResults.Lines.Add('Account number "' + pS.sbAccount_Number + '" orphaned -> unattached');
          FErrors := True;
        end;
      end
      else if (ps.sbAttach_Required) then
      begin
        moResults.Lines.Add('Account number "' + pS.sbAccount_Number +
                            '" was marked as attached to Client Code "' + pC.cfFile_Code + '".');
        pS.sbAttach_Required := False; // Fix for Escalation 18654
        FErrors := True;
        Inc(i);
      end
      else
        Inc(i);
    end;

    //Save updated admin
    sbStatus.SimpleText := 'Saving admin system...';
    if FErrors then
      SaveAdminSystem
    else
      UnLockAdmin;

    // save fixes
    moResults.Lines.SaveToFile('bkmap.txt');

    if FErrors then
      Msg := ' - any problems have been resolved.'
    else
      Msg := ' - no problems were found.';
    MessageDlg('The BankLink client-account map has been verified' + Msg, mtInformation, [mbOk], 0);

  finally
    btnCheck.Enabled := True;
    sbStatus.SimpleText := '';
  end;
end;

end.
