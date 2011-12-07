unit Migraters;

interface
uses
   Classes,
   DB,
   ADODB,
   MigrateActions,
   MigrateTable,
   GuidList;

type

TProvider = (AccountingSystem, TaxSystem, ManagementSystem, WebExport);

GuidProc = function (ForAction: TMigrateAction; Value: TGuidObject): boolean of object;


TMigrater = class(tObject)
private
    FConnection: TADOConnection;
    function GetConnectionString: string;
    procedure SetConnectionString(const Value: string);
    function DeleteQuery(Tablename: string; Truncate: boolean): string;
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
protected
    procedure OnConnected; virtual;
public
    constructor Create;
    destructor Destroy; override;
    //
    function ClearData(ForAction: TMigrateAction) : Boolean; virtual; abstract;

    // SQL Helpers..
    class function RunSQL(Connection : TADOConnection; ForAction: TMigrateAction; SQL: widestring; Action :string): Boolean; static;
    function DeleteTable(ForAction: TMigrateAction; Tablename: string; Truncate: boolean = false):Boolean; overload;
    function DeleteTable(ForAction: TMigrateAction; Table: TMigrateTable; Truncate: boolean = false):Boolean; overload;
    function InsertTable(ForAction: TMigrateAction; TableName, Fields, Values, Name: string): Boolean;

    // static Data...
    class function GetTaxClassGuid(Country, TaxClass: byte): TGuid; static;
    class function GetProviderID(provider: TProvider; Country,System: byte): Tguid; static;

    //helpers
    function GetMasterMemList(ForCountry: byte; List: TStrings): Integer;

    // Guidlist bits
    function RunGuidList(ForAction: TMigrateAction; Name: string; List: TGuidList; Proc: GuidProc; doLog: Boolean = false): Boolean;
    function NewGuid: TGuid;

    // Connection handeling
    property ConnectionString: string read GetConnectionString write SetConnectionString;
    property Connection: TADOConnection read  FConnection;
    property Connected: Boolean read GetConnected write SetConnected;
end;  

implementation
uses
  Globals,
  mxFiles32,
  bkConst,
  glconst,
  SysUtils;

{ TMigrater }

constructor TMigrater.Create;
begin
   inherited create;
   FConnection := TADOConnection.Create(nil);
   FConnection.LoginPrompt := false;
   FConnection.Provider := 'SQLNCLI10.1';
   FConnection.CommandTimeout := 120;
end;

function TMigrater.DeleteQuery(Tablename: string; Truncate: boolean): string;
begin
  if Truncate then
     Result := format('Truncate Table [%s]',[TableName])
  else
     Result := format('Delete From [%s]',[TableName]);

end;

function TMigrater.DeleteTable(ForAction: TMigrateAction; Table: TMigrateTable;
  Truncate: boolean): Boolean;
begin
   Result := DeleteTable(ForAction, Table.Tablename, Truncate);
end;

function TMigrater.DeleteTable(ForAction: TMigrateAction; Tablename: string;
  Truncate: boolean): Boolean;
var Action: TMigrateAction;
begin
   Action := ForAction.InsertAction( format('Delete %s',[Tablename]));
   Result := RunSQL (
                       connection,
                       ForAction,
                       DeleteQuery(TableName,Truncate),
                       ForAction.Title
                     );
   if Result then
      Action.Status := Success
   else
      Action.Status := Failed;
end;

destructor TMigrater.Destroy;
begin
  FreeAndNil(FConnection);
  inherited;
end;

function TMigrater.GetConnected: Boolean;
begin
   Result := fConnection.Connected;
end;

function TMigrater.GetConnectionString: string;
begin
   Result := Connection.ConnectionString;
end;

function TMigrater.GetMasterMemList(forCountry: byte; List: TStrings): Integer;
var
  Prefix: string;
  Prefixpos: Integer;
  Found: Integer;
  SearchRec: TSearchRec;
begin
   Result := 0;
   Prefix  := mmxPrefix + whShortNames[forCountry];
   PrefixPos := Length(Prefix) + 1;

   Found := FindFirst(DATADIR + Prefix + '*' + mmxExtn, faAnyFile, SearchRec);
   if assigned(List) then
      List.Clear;
   try
      while Found = 0 do begin
         //note:  searching for *.mxl will also return *.mxlold - Windows??!!@
         if SameText( ExtractFileExt( SearchRec.Name),mmxExtn) then begin
            Inc(Result);
            if assigned(List) then
               List.Add(copy(ChangeFileExt(SearchRec.Name,''),PrefixPos,255));
         end;
         Found := FindNext(SearchRec);
      end;
   finally
      FindClose(SearchRec);
   end;
end;

class function TMigrater.GetProviderID(provider: TProvider; Country, System: byte): Tguid;
begin
 Fillchar(result,Sizeof(result),0);
 case provider of
   AccountingSystem:
   case country of
    whNewZealand :
       case System of
          asNone            : result := StringToGuid('{43823DAE-F64C-4B90-9F8F-BF379EFD4760}');
          snOther           : result := StringToGuid('{13E53DD5-965B-451E-B1A6-B55F24A86A44}');
          snSolution6MAS42  : result := StringToGuid('{91FB467F-FB01-4924-9A7B-85477CC4C3C2}');
          //snHAPAS        : result := StringToGuid('{}');
          snGLMan           : result := StringToGuid('{EC8C1BB9-3768-4157-A6B0-3A254775330A}');
          snGlobal          : result := StringToGuid('{BD9B9B4D-2BC1-4F0B-9DF9-B0A81432442C}');
          snMaster2000      : result := StringToGuid('{168184B0-F563-4456-A343-01637D31453E}');
          snAdvance         : result := StringToGuid('{37FF38CC-C572-4EF4-8BC8-F16309CBB65B}');
          snSmartLink       : result := StringToGuid('{D5B48539-A754-41FD-AE2A-BFB651C39EDA}');
          snJobal           : result := StringToGuid('{56E4C57B-7F2E-466D-A369-3AC1B50384D5}');
          snCashManager     : result := StringToGuid('{35AC590B-0FE4-491E-A6A4-F9728FB41C48}');
          snAttache         : result := StringToGuid('{836740E2-E935-4933-8ACE-EAEC5D1434D2}');
          snASCIICSV        : result := StringToGuid('{E48D0503-298F-4E41-AEAE-8418C96F4653}');
          snCharterQX       : result := StringToGuid('{EEA40A68-DAF1-4A1D-8FE5-39D114E4D616}');
          snIntech          : result := StringToGuid('{34A7616B-AFE8-43BA-95C4-E1D228A7155F}');
          snKelloggs        : result := StringToGuid('{6271AD11-0556-48B2-B4AA-579FE47C016E}');
          //snAclaim        : result := StringToGuid('{}');  //Coopers & Lybrand Aclaim
          snIntersoft       : result := StringToGuid('{4503517A-6F61-45EB-8EEA-FC6847995336}');
          //snLotus123      : result := StringToGuid('{}');
          snAccPac          : result := StringToGuid('{97D8C97D-4596-4388-B6D7-82014CAAF918}');
          snCCM             : result := StringToGuid('{0F0D07BA-A658-483D-B9EA-F9D9040A16A1}');
          snMYOB            : result := StringToGuid('{54FEFFAC-FF75-4B33-BA1E-BCDEB63EF0FF}');
          snAccPacW         : result := StringToGuid('{10553C02-663E-483B-9687-1F9F0883EEE9}');
          //snSmartBooks    : result := StringToGuid('{}'); //SmartBooks 2000
          snBeyond          : result := StringToGuid('{F1336402-83CC-4F6A-91C4-A1A40D04501C}');
          //snPastel        : result := StringToGuid('{}'); // 'Pastel Accounting'
          //snSolution6CLS3 : result := StringToGuid('{}');
          //snSolution6CLS4 : result := StringToGuid('{}');
          //snSolution6MAS41: result := StringToGuid('{}');
          snAttacheBP       : result := StringToGuid('{C4E90E2A-2C83-4E84-AC0C-1DA061B29D77}');
          snBK5CSV          : result := StringToGuid('{7E964AAA-D1B8-41BF-ABAB-4A687744BCA8}');
          //snCaseWare        : result := StringToGuid('{}'); 'CaseWare'
          //snSolution6CLSY2K : result := StringToGuid('{}'); //Solution 6 MAS [CLSY2K]
          snConceptCash2000 : result := StringToGuid('{0B342B57-52B6-4CEB-B945-EEE53C3FC739}');
          //snQBWO            : result := StringToGuid('{}');
          snMYOBGen         : result := StringToGuid('{80C67C1D-6646-4413-969D-DC5729350158}');
          snXPA             : result := StringToGuid('{CE64A3DA-314B-4931-AE75-8651548D34B4}');  //XPA 8
          snQIF             : result := StringToGuid('{FF76113D-5BDD-442D-AFCC-E35DA6ED78A1}');
          snOFXV1           : result := StringToGuid('{21CC5CB1-FEB9-4437-B56E-FD9D47C6460A}');
          snOFXV2           : result := StringToGuid('{9726B7AE-BBA5-4B33-BF19-630B088521AC}');
          //snMYOB_AO_COM     : result := StringToGuid('{}');  'MYOB AO (manual posting)',
          //snQBWN            : result := StringToGuid('{}');  'QuickBooks 2008/2009'
       end;
    whAustralia  : case System of
          saOther           : result := StringToGuid('{BB6385B8-59A4-4F19-B12A-BB75E178284E}');
          saSolution6MAS42  : result := StringToGuid('{A4549BE0-424A-4509-BBC7-D771EB374FA5}');
          //saHAPAS         : result := StringToGuid('{}');
          saCeeData         : result := StringToGuid('{8C420B25-6F06-42CF-9942-A9D5F2732274}');
          saGLMan           : result := StringToGuid('{09E22FA6-75E1-468B-85F6-6BB5CE6FDE68}');
          saOmicom          : result := StringToGuid('{EBD934A6-F081-4EAA-B354-5E755331D781}');
          saASCIICSV        : result := StringToGuid('{0D60FB1E-37B4-4747-B50A-905B79E7CAE7}');
          //saLotus123      : result := StringToGuid('{}'); // Obsolete
          saAttache         : result := StringToGuid('{677DBCA1-14D9-44AC-98FF-1F2641E95E16}');
          saHandiLedger     : result := StringToGuid('{9ED981ED-0A55-4D92-AEDA-7215C7F3DCDA}');
          saBGLSimpleFund   : result := StringToGuid('{EED0EEDB-BC73-4053-BDC0-CEF582CE4EC8}');
          saMYOB            : result := StringToGuid('{7762B0C0-F18C-4B5D-974A-E825223FAF51}');
          //saCeeDataCDS1   : result := StringToGuid('{}'); // Obsolete
          //saSolution6CLS3   : result := StringToGuid('{}');
          //saSolution6CLS4   : result := StringToGuid('{}');
          //saSolution6MAS41  : result := StringToGuid('{}'); // Obsolete Apr 2003
          saQBWO            : result := StringToGuid('{70EAE229-8409-480F-A11A-A1ED5F2C6759}');
          saCaseware        : result := StringToGuid('{B03B396D-7779-4BCA-91C5-9AC392DC4002}');
          saBK5CSV          : result := StringToGuid('{9D971FA2-EDA6-4035-BC63-CED91F747F6F}');
          saAccountSoft     : result := StringToGuid('{4F557383-88B7-4E05-B372-6CCC1930B7BC}');
          //saProflex       : result := StringToGuid('{}'); // Obsolete
          //saTeletaxLW     : result := StringToGuid('{}'); // Obsolete
          saAttacheBP       : result := StringToGuid('{436DFF20-9B80-4D76-8E97-9412594AB893}');
          //saSolution6CLSY2K : result := StringToGuid('{}');
          saEasyBooks       : result := StringToGuid('{BA363920-A4AF-40C7-8C12-33B80EAD204E}');
          saMGL             : result := StringToGuid('{5E3071C9-C9D5-4F46-B8C6-5AC5C96DEF37}');
          saComparto        : result := StringToGuid('{AE23A6C6-C3E3-46D2-9B43-F7851CAB7908}');
          saXlon            : result := StringToGuid('{0097945A-3AF6-4A8E-A4A4-EF7C3B8F53E9}');
          saCatSoft         : result := StringToGuid('{EAE03EC9-B832-48B2-B76E-765B03D2982C}');
          saBCSAccounting   : result := StringToGuid('{80A13741-5C4C-4248-B353-77A885F2A908}');
          saMYOBAccountantsOffice
                            : result := StringToGuid('{8A37A89F-8D6F-45F6-8011-1D8BF11788BC}');
          saSolution6SuperFund
                            : result := StringToGuid('{0879B2F4-DB69-4199-9008-F03175C6EA5F}');
          saTaxAssistant    : result := StringToGuid('{05D3EB7B-68C5-49C0-A883-4D089BA29C89}');
          saMYOBGen         : result := StringToGuid('{0EDE834A-9E85-4A33-91B0-2A44359643DA}');
          saAccomplishCashManager
                            : result := StringToGuid('{490A5AC9-12DE-486C-92A4-B48E1F3170E8}');
          saPraemium        : result := StringToGuid('{9CFF5638-8B38-4147-A9B1-757B24D51EDF}');
          saSupervisor      : result := StringToGuid('{812D7136-9FA8-4C04-8A71-8A412BF072C8}');
          saXPA             : result := StringToGuid('{226BD4E3-04A3-4B19-8F16-050DC7721FD5}');
          saQIF             : result := StringToGuid('{0B9E4F56-3B54-4B4F-B558-2137DA79180D}');
          saOFXV1           : result := StringToGuid('{9BE08C6A-AB63-49BC-9979-D96754592A9D}');
          saOFXV2           : result := StringToGuid('{A12DAFB3-E768-4F19-A875-3F950CEA5311}');
          saElite           : result := StringToGuid('{241ACB76-C69C-4272-8358-40F9ACD48BC7}');
          //saMYOB_AO_COM : result := StringToGuid('{}');
          saDesktopSuper    : result := StringToGuid('{F5C6AFD8-DEE7-484F-9AD3-AEC568DC5F7E}');
          saBGLSimpleLedger : result := StringToGuid('{CF7F03D1-D424-4E4F-8CE8-D61C3560EA56}');
          saClassSuperIP    : result := StringToGuid('{0BFD02B9-C941-41BB-8233-0F117896E709}');
          saQBWN            : result := StringToGuid('{99BFC68D-C393-41FC-B28B-A45699CE4CCD}');
          //saIRESSXplan : result := StringToGuid('{}');
          saSuperMate       : result := StringToGuid('{7FB4338F-BD24-4F24-A21C-9C44A48FAEBB}');
          //saRewardSuper : result := StringToGuid('{}');
          //saProSuper : result := StringToGuid('{}');
          saSageHandisoftSuperfund
                            : result := StringToGuid('{D78426F0-C34F-4815-B5E8-32F6B5B11570}');
     end;
    whUK : case system of
          suOther           : result := StringToGuid('{422074AD-B5D8-487D-A874-C7060157EAFC}');
          //suPA7           : result := StringToGuid('{29830BE7-5745-4E2B-AA83-2C87049C1E1B}');
          //suXPA           : result := StringToGuid('{ADCAEDBD-5717-43B2-BA21-D532DFCC8EBF}');
          suQIF             : result := StringToGuid('{15A617EB-ABFB-4F42-B6E2-9E52BA2E574E}');
          suOFXV1           : result := StringToGuid('{DAC0F0B0-A686-4971-BDAA-F26E00D81F9D}');
          suOFXV2           : result := StringToGuid('{0EF6D347-7275-493A-B98E-19341B97511B}');
          suBK5CSV          : result := StringToGuid('{EAD167CC-86FB-436E-A47B-1644B83AA25E}');
          // suSolution6MAS42 : result := StringToGuid('{554D5BBB-EC02-4167-A65A-F2C8E06F637E}');
          //suMYOBAccountantsOffice : result := StringToGuid('{7B6C02BD-BE2C-40C1-8A63-9ADD08A53C5F}');
          // suMYOB_AO_COM : result := StringToGuid('{5CBF6424-55A0-48FC-B5E8-6F020304DF07}');
     end;

   end;
   TaxSystem: case country of
    whAustralia :
      case System of
          tsBAS_XML         : result := StringToGuid('{ECB190A8-5319-45A7-A07C-2F34E65C10B4}');
          tsBAS_Sol6ELS     : result := StringToGuid('{9A59247E-7D2A-4A76-9784-487F648013F8}');
          tsBAS_APS_XML     : result := StringToGuid('{8D34B23B-6758-416C-A3B1-7F7C1580C9F9}');
          tsElite_XML       : result := StringToGuid('{A6541B50-B6E4-4B21-AEB8-5E0BD8D998B5}');
          tsBAS_MYOB        : result := StringToGuid('{B87D3D4E-8661-42FF-8F76-AE7850001FCF}');
          tsBAS_HANDI       : result := StringToGuid('{D40F2660-8B6A-4588-8073-099878D4037E}');
          else result                := StringToGuid('{F96F0C8B-87B5-4512-BBFC-E39288E6BDEF}');
      end;
   end;

   ManagementSystem: case Country of

      whNewZealand : case System of
         xcOther            : result := StringToGuid('{bdaa0dd0-d38c-4101-902c-753c813ac581}');
         xcAPS              : result := StringToGuid('{f5f4d897-bde6-4612-a1fe-1e18d60bbc2c}');
         xcMYOB             : result := StringToGuid('{133ea5a3-5aaa-493f-aeed-a2940137cf15}');
         xcMYOBAO           : result := StringToGuid('{37f51f41-ea59-40cc-8471-56faa95bd039}');
         //xcHandi : result := StringToGuid('{}');
         else                 result := StringToGuid('{4bb85039-57b4-4651-b19d-a9bf4ca790f3}');
      end;

      whAustralia : case System of
         xcOther            : result := StringToGuid('{20c6e752-b0cc-4b04-baa1-ff6273f5f2b9}');
         xcAPS              : result := StringToGuid('{02612bf5-79a8-4cbf-a267-3ecc77c303f9}');
         xcMYOB             : result := StringToGuid('{431fb26a-1e49-47c9-a8f5-cfa53648d29a}');
         xcMYOBAO           : result := StringToGuid('{8635dc10-d9cf-4ab0-92e8-4836b84c8ba1}');
         xcHandi            : result := StringToGuid('{0f2da56b-af41-43ce-8a62-8f6488c89212}');
         else                 result := StringToGuid('{0570c4d1-6f79-4b01-a55f-c4f9d2d5cf53}');
      end;

      whUK : case system of
         xcOther            : result := StringToGuid('{ec73e0d6-7562-4305-8cc3-8912e46595ce}');
         xcAPS              : result := StringToGuid('{e0a9c6cd-f435-43f8-8b86-6c3be6fd8de7}');
         xcMYOB             : result := StringToGuid('{66b5649c-0b1c-4b4c-9718-1e0a48822c7a}');
         xcMYOBAO           : result := StringToGuid('{35031064-c338-41ad-b27d-d507a66b4a6f}');
         xcHandi            : result := StringToGuid('{42cfaa3c-f95e-42f0-b396-1267f3f641d2}');
         else                 result := StringToGuid('{27cfd2f4-fbde-4b98-8461-dd32208f25d6}');
      end;

   end;

   WebExport: case Country of

      whNewZealand : case System of
          wfWebX            : result := StringToGuid('{C9CEBA54-50B7-447A-8ACD-1CBD0DF3BAFA}');
          wfWebNotes        : result := StringToGuid('{56BFFE20-3DFC-4DB7-A80B-B0CB77991134}');
          else                result := StringToGuid('{C6C3348A-12B0-4869-A823-5521B0DD1609}');
      end;

      whAustralia : case System of
          wfWebX            : result := StringToGuid('{D77F3DC1-D639-47BA-A064-233AB71A76C1}');
          wfWebNotes        : result := StringToGuid('{EA06D604-DC10-4224-8A8E-B8467DF0FF7B}');
          else                result := StringToGuid('{2211C3E9-66E6-41BA-9AB0-4445BD2871DC}');
      end;

      whUK : case system of
          wfWebX            : result := StringToGuid('{32AAEBD0-785F-4CEB-AEFC-25917DD68AD1}');
          wfWebNotes        : result := StringToGuid('{1BA30927-4470-4EC1-93F4-66EE68157321}');
          else                result := StringToGuid('{848A4E7A-1EB7-4559-96EF-1B84B4DB56C1}');
      end;

   end;


 end;
end;

class function TMigrater.GetTaxClassGuid(Country, TaxClass: byte): TGuid;
begin
  fillchar(result,SizeOf(TGuid), 0);
  case Country of
     whNewZealand : begin
        case TaxClass of
         //gtUndefined           : Result := StringToGuid('{C84C13A5-4F06-4CC5-9757-000AEBC34C9C}');
         gtIncomeGST           : Result := StringToGuid('{E3CEC74B-735D-45F7-8D6C-0010E56E4E16}');
         gtExpenditureGST      : Result := StringToGuid('{CCC94EFB-91C3-401C-9FDE-002982BDEE62}');
         gtExempt              : Result := StringToGuid('{360240FC-9E69-489E-9C80-0039EF7D72B8}');
         gtZeroRated           : Result := StringToGuid('{E7119A9E-0D86-46A8-B37B-004333E9FF9D}');
         gtCustoms             : Result := StringToGuid('{3D555C88-FD32-460E-9EBD-005EA5291290}');
        end;
     end;
     whUK: begin
       case TaxClass of
        //vtNoVAT                : Result := StringToGuid('{99991C52-22BF-462C-81C8-006D22A09CD8}');
        vtSalesStandard        : Result := StringToGuid('{2781E33A-5409-4B13-9D5E-00768C4956A6}');
        vtSalesReduced         : Result := StringToGuid('{A60B11F8-6300-4261-B8B4-008E5B2A1E6E}');
        vtSalesZeroRated       : Result := StringToGuid('{DAEF3463-6208-464F-8BCE-0095E1C6F986}');
        vtSalesExempt          : Result := StringToGuid('{81D35314-0898-429A-87C6-00AA57F9AEA8}');
        vtSalesECStandard      : Result := StringToGuid('{44204C0C-5AA9-4247-A83C-00B96E4FA5E9}');
        vtSalesECReduced       : Result := StringToGuid('{89E58AAC-F109-4893-B1F7-00C4867E67F2}');
        vtSalesECZeroRated     : Result := StringToGuid('{CD59C725-D523-45B3-81DA-00D517E401FC}');
        vtSalesECExempt        : Result := StringToGuid('{1FEB07C1-3204-4B81-A738-00E7A8BBEE11}');
        vtPurchasesStandard    : Result := StringToGuid('{4EA484E6-C3C9-45E8-84A3-00F97331AF33}');
        vtPurchasesReduced     : Result := StringToGuid('{89E58AAC-F109-4893-B1F7-0104867E67F2}');
        vtPurchasesZeroRated   : Result := StringToGuid('{3D2A5782-F2CA-4502-9F7B-011669099DE4}');
        vtPurchasesExempt      : Result := StringToGuid('{B1AD3B1E-0942-4088-92B2-012EDC240E7D}');
        vtPurchasesECStandard  : Result := StringToGuid('{0E68182A-24C3-422B-B857-0136AF24153F}');
        vtPurchasesECReduced   : Result := StringToGuid('{158AFB49-8E46-4481-B113-014C9794E21A}');
        vtPurchasesECZeroRated : Result := StringToGuid('{D25ADBD0-8A7B-4B09-BA75-015A2B1773AB}');
        vtPurchasesECExempt    : Result := StringToGuid('{8FDC1A37-F62A-48B3-BD19-01636D9A7D44}');
       end;
     end;
     whAustralia: begin
        case TaxClass of
         1 :   Result := StringToGuid('{7C29B926-9909-455A-AE2C-01767B5BE631}'); //Company tax...
         else Result := StringToGuid('{5950CDE9-3E66-485A-B71C-018DCEE760EB}'); // GST
        end;
     end;
  end;
end;

function TMigrater.InsertTable(ForAction: TMigrateAction; TableName, Fields,
  Values, Name: string): Boolean;
begin
    Result := RunSQL (
              connection,
              ForAction,
              Format('Insert into [%s] (%s) Values (%s)',[TableName, Fields,Values]),
               Format('Insert into %s',[TableName])
                      );
end;

function TMigrater.NewGuid: TGuid;
begin
   CreateGuid(Result);
end;

procedure TMigrater.OnConnected;
begin
  //
end;

function TMigrater.RunGuidList(ForAction: TMigrateAction; Name: string; List: TGuidList; Proc: GuidProc; doLog: Boolean = false): Boolean;
var
   MyAction: TMigrateAction;
   I: Integer;
begin
   if ForAction.CheckCanceled then begin
      Result := False;
      Exit;
   end;

   // Have a go..
   Result := True;

   if List.Count = 0 then
      Exit; // Nothing to do.. but did not fail..

   if (Name > '') then
      // Make my own action
      MyAction := Foraction.InsertAction (Name,ForAction.Item)
   else
      MyAction := ForAction;

   try
      if list.CheckSpeed then
         MyAction.TotSize := List.TotSize;

      MyAction.Target := List.Count;
      for I := 0 to List.Count - 1 do begin
         // iterate trough the list
         if Proc(MyAction,TGuidobject(List[I])) then
            MyAction.AddCount
         else
            MyAction.SkipCount;

         if list.CheckSpeed then
            MyAction.AddRunSize(TGuidobject(List[I]).Size);
         // General flow handeling
         if ForAction.CheckCanceled then
            Break;
      end;
      MyAction.Count := I;
      if doLog then
        MyAction.LogMessage(format( 'Completed %d',[MyAction.Count]) );

   except
      on E: Exception do
         Myaction.Error := format('Incomplete :%s', [E.Message]);
   end;
end;

class function TMigrater.RunSQL(Connection : TADOConnection; ForAction: TMigrateAction; SQL: widestring; Action :string): Boolean;
begin
  Result := False;
  try
     Connection.Execute(SQL,cmdText);
     Result := True;
  except
     on e:Exception do begin
         if Assigned(ForAction) then
            ForAction.Exception(E,Action)
         else
            raise exception.Create(E.Message);
     end;
  end;
end;

procedure TMigrater.SetConnected(const Value: Boolean);
begin
    Connection.Connected := Value;
    if Connected then
       OnConnected;
end;

procedure TMigrater.SetConnectionString(const Value: string);
begin
    Connection.ConnectionString := Value;
end;

end.
