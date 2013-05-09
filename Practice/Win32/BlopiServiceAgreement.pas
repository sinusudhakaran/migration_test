unit BlopiServiceAgreement;

interface

uses
  SysUtils, LockUtils, BanklinkOnlineServices;

type
  TBlopiServiceAgreement = class
  public
    class function EnterServiceAgreement: Boolean;
    class procedure LeaveServiceAgreement;

    class function NewVersionAvailable: Boolean;
    class function SendServiceAgreementEmail(aPracticeName,
                                             aPracticeCode,
                                             aPrimaryUserName,
                                             aPrimaryUserEmail,
                                             aServiceAgreementVersion,
                                             aSigneeName,
                                             aSigneeTitle : string): Boolean;
    class function SignServiceAgreement: Boolean;
  end;

implementation

uses
  ServiceAgreementDlg, Globals, Admin32, LogUtil, Mailfrm;

{ TBlopiServiceAgreement }

class function TBlopiServiceAgreement.EnterServiceAgreement: Boolean;
begin
  Result := FileLocking.ObtainLock(ltBlopiServiceAgreement, 0);
end;

class procedure TBlopiServiceAgreement.LeaveServiceAgreement;
begin
  FileLocking.ReleaseLock(ltBlopiServiceAgreement);
end;

class function TBlopiServiceAgreement.NewVersionAvailable: Boolean;
var
  Version: String;
begin
  Version := ProductConfigService.GetServiceAgreementVersion();

  if Trim(Version) <> '' then
  begin
    if Trim(AdminSystem.fdFields.fdLast_Agreed_To_BLOSA) <> '' then
    begin
      Result := AdminSystem.fdFields.fdLast_Agreed_To_BLOSA <> Version;
    end
    else
    begin
      if LoadAdminSystem(True, 'BlopiServiceAgreement') then
      begin
        try
          AdminSystem.fdFields.fdLast_Agreed_To_BLOSA := Version;

          SaveAdminSystem;

          LogUtil.LogMsg(lmInfo, 'BlopiServiceAgreement', Format('Local BankLink Online service agreement version is currently blank - updated to version %s', [Version]), 0);

          Result := False;
        except
          if AdminIsLocked then
          begin
            UnLockAdmin;
          end;
        
          raise;
        end;
      end;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

class function TBlopiServiceAgreement.SendServiceAgreementEmail(aPracticeName,
                                                                aPracticeCode,
                                                                aPrimaryUserName,
                                                                aPrimaryUserEmail,
                                                                aServiceAgreementVersion,
                                                                aSigneeName,
                                                                aSigneeTitle : string): Boolean;
const
  ONE_LINE = #10;
  TWO_LINES = #10#10;
var
  Msg: string;
begin
  Msg := Format('Practice Name: %s%s' +
                'Practice Code: %s%s' +
                'I confirm that I am authorised to bind the Customer to this Service Agreement (including the terms and conditions), I have read the Service Agreement and terms and conditions and I confirm the Customer’s acceptance of them. %s' +
                'Signee Name: %s%s' +
                'Signee Title: %s%s' +
                'Service Agreement Version: %s%s',
                [aPracticeName, ONE_LINE,
                 aPracticeCode, TWO_LINES,
                 TWO_LINES,
                 aSigneeName, ONE_LINE,
                 aSigneeTitle, ONE_LINE,
                 aServiceAgreementVersion, TWO_LINES]);

  Result := SendMailTo('BankLink Online Service Agreement', GetSupportEmailAddress,
             'BankLink Online Service Agreement', Msg);
end;

class function TBlopiServiceAgreement.SignServiceAgreement: Boolean;
var
  ServiceAgreementVersion: String;
  SigneeName: String;
  SigneeTitle : String;
  UserObj : TBloUserRead;
  UserEmail : string;
  UserFullname : string;
begin
  if ServiceAgreementAccepted(ServiceAgreementVersion, SigneeName, SigneeTitle) then
  begin
    if LoadAdminSystem(True, 'BlopiServiceAgreement') then
    begin
      try
        AdminSystem.fdFields.fdLast_Agreed_To_BLOSA := ServiceAgreementVersion;

        UserObj := ProductConfigService.GetPrimaryContact(false);
        if Assigned(UserObj) then
        begin
          UserEmail := UserObj.EMail;
          UserFullname := UserObj.FullName;
        end
        else
        begin
          UserEmail := '';
          UserFullname := '';
        end;

        SendServiceAgreementEmail(AdminSystem.fdFields.fdPractice_Name_for_Reports,
                                  AdminSystem.fdFields.fdBankLink_Code,
                                  UserFullname,
                                  UserEmail,
                                  ServiceAgreementVersion,
                                  SigneeName,
                                  SigneeTitle);

        SaveAdminSystem;

        LogUtil.LogMsg(lmInfo, 'ServiceAgreementDlg', Format('BankLink Online service agreement accepted by - SigneeName: %s; SigneeTile: %s; Service Agreement Version: %s', [SigneeName, SigneeTitle, ServiceAgreementVersion]), 0);

        Result := True;
      except
        if AdminIsLocked then
        begin
          UnLockAdmin;
        end;
        
        raise;
      end;
    end
    else
    begin
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

end.
