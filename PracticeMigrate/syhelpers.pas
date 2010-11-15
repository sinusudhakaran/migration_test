unit syhelpers;

interface
uses sydefs;


function GetSystem_Bank_Account_RecFields: string;
function GetSystem_Bank_Account_RecValues(id:TGuid; Value: pSystem_Bank_Account_Rec): string;


function GetClient_Group_RecFields: string;
function GetClient_Group_RecValues(id:TGuid; Value: pGroup_Rec): string;

function GetClient_Type_RecFields: string;
function GetClient_Type_RecValues(id:TGuid; Value: pClient_Type_Rec): string;

function GetSystem_Client_File_RecFields: string;
function GetSystem_Client_File_RecValues(myid:TGuid; Database:string; GroupID:tGuid; TypeID:tGuid; Value: tClient_File_Rec): string;

//function GetAccountingSystemID(Country,AccountingSystem):Tguid;

function GetUser_RecFields: string;
function GetUser_RecValues(MyId:TGuid; Value: pUser_Rec): string;

function GetClient_Account_Map_RecFields: string;
function GetClient_Account_Map_RecValues(MyId,ClientID,ClientAccID,SystemAccID:TGuid;
                   Value: pClient_Account_Map_Rec): string;

implementation

uses
  SysUtils,
  bkConst,
  PasswordHash,
  SQLHelpers;

(*
function GetAccountingSystemID(Country,AccountingSystem):Tguid;
begin

  case country of
    whNewZealand :
       case AccountingSystem of
          asNone          : result := StringToGuid('{}');
          asNoneName      : result := StringToGuid('{}');
          snOther         : result := StringToGuid('{}');
          snSolution6MAS42  : result := StringToGuid('{}');
          snHAPAS        : result := StringToGuid('{}');
          snGLMan        : result := StringToGuid('{}');
          snGlobal       : result := StringToGuid('{}');
          snMaster2000   : result := StringToGuid('{}');
          snAdvance      : result := StringToGuid('{}');
          snSmartLink    : result := StringToGuid('{}');
          snJobal        : result := StringToGuid('{}');
          snCashManager  : result := StringToGuid('{}');
          snAttache      : result := StringToGuid('{}');
          snASCIICSV     : result := StringToGuid('{}');
          snCharterQX    : result := StringToGuid('{}');
          snIntech       : result := StringToGuid('{}');
          snKelloggs     : result := StringToGuid('{}');
          snAclaim       : result := StringToGuid('{}');
          snIntersoft    : result := StringToGuid('{}');
          snLotus123     : result := StringToGuid('{}');
          snAccPac       : result := StringToGuid('{}');
          snCCM          : result := StringToGuid('{}');
          snMYOB         : result := StringToGuid('{}');
          snAccPacW      : result := StringToGuid('{}');
          snSmartBooks   : result := StringToGuid('{}');
          snBeyond       : result := StringToGuid('{}');
          snPastel       : result := StringToGuid('{}');
          snSolution6CLS3   : result := StringToGuid('{}');
          snSolution6CLS4   : result := StringToGuid('{}');
          snSolution6MAS41  : result := StringToGuid('{}');
          snAttacheBP       : result := StringToGuid('{}');
          snBK5CSV          : result := StringToGuid('{}');
          snCaseWare        : result := StringToGuid('{}');
          snSolution6CLSY2K : result := StringToGuid('{}');
          snConceptCash2000 : result := StringToGuid('{}');
          snQBWO            : result := StringToGuid('{}');
          snMYOBGen         : result := StringToGuid('{}');
          snXPA             : result := StringToGuid('{}');  //XPA 8
          snQIF             : result := StringToGuid('{}');
          snOFXV1           : result := StringToGuid('{}');
          snOFXV2           : result := StringToGuid('{}');
          snMYOB_AO_COM     : result := StringToGuid('{}');
          snQBWN            : result := StringToGuid('{}');
       end;
    whAustralia  : case True of
          saOther       : result := StringToGuid('{}');
          saSolution6MAS42: result := StringToGuid('{A4549BE0-424A-4509-BBC7-D771EB374FA5}');
          saHAPAS        : result := StringToGuid('{}');
          saCeeData      : result := StringToGuid('{8C420B25-6F06-42CF-9942-A9D5F2732274}');
          saGLMan        : result := StringToGuid('{09E22FA6-75E1-468B-85F6-6BB5CE6FDE68}');
          saOmicom       : result := StringToGuid('{}');
          saASCIICSV     : result := StringToGuid('{}');
          saLotus123     : result := StringToGuid('{}'); // Obsolete
          saAttache      : result := StringToGuid('{}');
          saHandiLedger  : result := StringToGuid('{}');
          saBGLSimpleFund: result := StringToGuid('{}');
          saMYOB         : result := StringToGuid('{}');
          saCeeDataCDS1  : result := StringToGuid('{}'); // Obsolete
          saSolution6CLS3   : result := StringToGuid('{}');
          saSolution6CLS4   : result := StringToGuid('{}');
          saSolution6MAS41  : result := StringToGuid('{}'); // Obsolete Apr 2003
          saQBWO            : result := StringToGuid('{}');
          saCaseware        : result := StringToGuid('{}');
          saBK5CSV          : result := StringToGuid('{}');
          saAccountSoft     : result := StringToGuid('{}');
          saProflex         : result := StringToGuid('{}'); // Obsolete
          saTeletaxLW       : result := StringToGuid('{}'); // Obsolete
          saAttacheBP       : result := StringToGuid('{}');
          saSolution6CLSY2K : result := StringToGuid('{}');
          saEasyBooks       : result := StringToGuid('{}');
          saMGL             : result := StringToGuid('{}');
          saComparto        : result := StringToGuid('{}');
          saXlon            : result := StringToGuid('{}');
          saCatSoft         : result := StringToGuid('{}');
          saBCSAccounting   : result := StringToGuid('{}');
          saMYOBAccountantsOffice : result := StringToGuid('{}');
          saSolution6SuperFund : result := StringToGuid('{}');
          saTaxAssistant    : result := StringToGuid('{}');
          saMYOBGen         : result := StringToGuid('{}');
          saAccomplishCashManager : result := StringToGuid('{}');
          saPraemium        : result := StringToGuid('{}');
          saSupervisor : result := StringToGuid('{}');
          saXPA : result := StringToGuid('{}');
          saQIF : result := StringToGuid('{}');
          saOFXV1 : result := StringToGuid('{}');
          saOFXV2 : result := StringToGuid('{}');
          saElite : result := StringToGuid('{}');
          saMYOB_AO_COM : result := StringToGuid('{}');
          saDesktopSuper : result := StringToGuid('{}');
          saBGLSimpleLedger : result := StringToGuid('{}');
          saClassSuperIP : result := StringToGuid('{}');
          saQBWN : result := StringToGuid('{}');
          saIRESSXplan : result := StringToGuid('{}');
          saSuperMate : result := StringToGuid('{}');
          saRewardSuper : result := StringToGuid('{}');
          saProSuper : result := StringToGuid('{}');
          saSageHandisoftSuperfund: result := StringToGuid('{}');
                   end;
    whUK         :
  end;

end;
  *)

function GetSystem_Bank_Account_RecFields: string;
// Field names in the PracticeSystem.SystemAccount Table
begin
   Result := '[Id],[AccountNumber],[AccountName],[AccountPassword],[CurrentBalance],[LastTransactionId]'
   + ',[NewThisMonth],[NoOfEntriesThisMonth],[FromDateThisMonth],[ToDateThisMonth],[CostCode],[ChargesThisMonth]'
   + ',[OpeningBalanceFromDisk],[ClosingBalanceFromDisk],[AttachRequired],[WasOnLatestDisk],[LastEntryDate]'
   + ',[DateOfLastEntryPrinted],[MarkAsDeleted],[FileCode],[MatterID],[AssignmentID],[DisbursementID],[AccountType]'
   + ',[JobCode],[ActivityCode],[FirstAvailableDate],[NoChargeAccount],[CurrencyCode],[InstitutionName],[SecureCode],[Inactive]'
   + ',[Frequency],[FrequencyChangePending]';
end;

function GetSystem_Bank_Account_RecValues(id:TGuid; Value: pSystem_Bank_Account_Rec): string;

begin
  Result := ToSQL(Id) + ToSQL(Value.sbAccount_Number) + ToSQL(Value.sbAccount_Name) + ToSQL(Value.sbAccount_Password)
              + ToSQL(Value.sbCurrent_Balance) + toSQL(emptyGuid)

          + ToSQL(Value.sbNew_This_Month) + ToSQL(Value.sbNo_of_Entries_This_Month) + DateToSQL(Value.sbFrom_Date_This_Month)
              + DateToSQL(Value.sbTo_Date_This_Month) + ToSQL(Value.sbCost_Code) +  ToSQL(Value.sbCharges_This_Month)

          + ToSQL(Value.sbOpening_Balance_from_Disk) + ToSQL(Value.sbClosing_Balance_from_Disk)
              + ToSQL(Value.sbAttach_Required) + ToSQL(Value.sbWas_On_Latest_Disk) + DateToSQL(Value.sbLast_Entry_Date)

          + DateToSQL(Value.sbDate_Of_Last_Entry_Printed) + ToSQL(Value.sbMark_As_Deleted) + ToSQL(Value.sbFile_Code) + ToSQL(Value.sbMatter_ID)
              + ToSQL(Value.sbAssignment_ID) + ToSQL(Value.sbDisbursement_ID) + ToSQL(Value.sbAccount_Type)

          + ToSQL(Value.sbJob_Code) + ToSQL(Value.sbActivity_Code) +  DateToSQL(Value.sbFirst_Available_Date) + ToSQL(Value.sbNo_Charge_Account)
              + ToSQL(Value.sbCurrency_Code) + ToSQL(Value.sbInstitution) + ToSQL(Value.sbBankLink_Code) + toSQL(false)

          + ToSQL(Value.sbFrequency) + ToSQL(Value.sbFrequency_Change_Pending, false);

end;




function GetClient_Group_RecFields: string;
begin
    Result := '[Id],[Name]';
end;

function GetClient_Group_RecValues(id:TGuid; Value: pGroup_Rec): string;
begin
   Result := ToSQL(Id) + ToSQL(Value.grName, false);
end;

function GetClient_Type_RecFields: string;
begin
    Result := '[Id],[Name]';
end;

function GetClient_Type_RecValues(id:TGuid; Value: pClient_Type_Rec): string;
begin
   Result := ToSQL(Id) + ToSQL(Value.ctName, false);
end;


function GetSystem_Client_File_RecFields: string;
begin
    Result :=  '[Id],[ClientName],[ClientDB],[Code],[ClientGroups_Id],[ClientTypes_Id]';
end;

function GetSystem_Client_File_RecValues(myid:TGuid; Database:string; GroupID:tGuid; TypeID:tGuid; Value: tClient_File_Rec): string;
begin
  Result := ToSQL(MyId) + ToSQL(Value.cfFile_Name) + ToSQL(Database) + ToSql(Value.cfFile_Code)
               + ToSQL(GroupID) +  ToSQL(TypeID, false);
end;

function GetUser_RecFields: string;
begin
     Result := '[Id],[Code],[Name],[Password],[EmailAddress],[SystemAccess],[DialogColour]'
            + ',[ReverseMouseButtons],[MASTERAccess],[IsRemoteUser],[DirectDial]'
            + ',[ShowCMOnOpen],[ShowPrinterChoice],[EULAVersion]'
            + ',[SuppressHF],[ShowPracticeLogo]'
            + ',[IsDeleted],[CanAccessAllClients],[IncorrectLoginCount],[IsLockedOut]';

end;

function GetUser_RecValues(MyId:TGuid; Value: pUser_Rec): string;
begin  with Value^ do
   Result := ToSQL(MyId) + ToSQL(usCode) + ToSQL(usName) + ToSQL(ComputePWHash(usPassword,MyId))
               + ToSQL(usEMail_Address) + ToSQL(usSystem_Access) + ToSQL(usDialog_Colour)
          + ToSQL(usReverse_Mouse_Buttons) + ToSQL(usMASTER_Access) + ToSQL(usIs_Remote_User) + ToSQL(usDirect_Dial)
          + ToSQL(usShow_CM_on_open) + ToSQL(usShow_Printer_Choice) + ToSQL(usEULA_Version)
          + ToSQL(usSuppress_HF) + ToSQL(usShow_Practice_Logo)
          + ToSQL(False) + ToSQL(usSystem_Access) + ToSQL(0) + ToSQL(False, False);

end;

function GetClient_Account_Map_RecFields: string;


begin
  Result := '[Id],[PracticeClientId],[ClientAccount],[SystemBankAccount_Id]'
         +  ',[LastDatePrinted],[TempLastDatePrinted],[EarliestDownloadDate]'

end;

function GetClient_Account_Map_RecValues(MyId,ClientID,ClientAccID,SystemAccID:TGuid;
                   Value: pClient_Account_Map_Rec): string;
begin
   Result := ToSQL(MyID) + ToSQL(ClientID) + ToSQL(ClientAccID) + ToSQL(SystemAccID)
          + DateToSQL(Value.amLast_Date_Printed) + DateToSQL(Value.amTemp_Last_Date_Printed)
                 + DateToSQL(Value.amEarliest_Download_Date, false);
end;


end.
