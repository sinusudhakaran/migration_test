{  ---------------------------------------------------------  }

{ __revision_history__
  __revision_history__ }

{  ---------------------------------------------------------  }

Unit
 Software;

{$I COMPILER}
{$IFDEF DPMI}
   {$C MOVEABLE DEMANDLOAD DISCARDABLE}
{$ENDIF}

{  ---------------------------------------------------------  }
INTERFACE
{USES DOS;}  {mjch 200598}


type
   TSuperDialogMode = (sfTrans, sfMem, sfPayee);

{  ---------------------------------------------------------  }

Function CanExtractData( aCountry, aType : Byte ): Boolean;
Function CanExtractInNewFormat( aCountry, aType : Byte ): Boolean;

// BGL 360 Related
function IsBGL360( aCountry, aSystem : byte) : boolean;
Function CanExtractAccountNumberAs( aCountry, aType : Byte ) : boolean;

//MYOB Ledger
function IsMYOBLedger( aCountry, aSystem : byte) : boolean;

Function ContraCodeRequired( aCountry, aType : Byte ): Boolean;
//Function FloppyDiskRequired( aCountry, aType : Byte ): Boolean;
Function IsHAPAS( aCountry, aType : Byte ): Boolean;

function ApplyAccountGSTClassesFromMASTER( aCountry, aType : Byte ): Boolean;
function ApplyAccountTypesFromMASTER( aCountry, aType : Byte ): Boolean;
function CanRefreshChart( aCountry, aType : Byte ) : Boolean;
function ExtractDataFileNameRequired(aCountry, aType : Byte ) : Boolean;

function ExcludeFromAccSysList( aCountry, aType : byte) : boolean;
function ExcludeFromWebFormatList( aCountry, aType : byte) : boolean;
function IsSuperFund( aCountry, aSystem : byte) : boolean;
function CanUseSuperFundFields( aCountry, aType : byte; sdMode: TSuperDialogMode = sfTrans) : boolean;
function IsPA7Interface( aCountry, aType : byte) : boolean;
function HasSuperfundLegerID( aCountry, aType : byte) : boolean;
function HasSuperfundLegerCode( aCountry, aType : byte) : boolean;
function IsXPA8Interface( aCountry, aType : byte) : boolean;
function IsMYOBAO_DLL_Interface( aCountry, aType : byte) : boolean;
function CanUseMYOBAO_DLL_Refresh( aCountry, aType : byte) : boolean;
function IsMYOBAO_7( aCountry, aType : byte) : boolean;

function IsSol6_COM_Interface( aCountry, aType : byte) : boolean;

function UseSaveToField( aCountry, aType : byte) : boolean;


function GetMYOBAO_Name( aCountry : byte) : string;
function GetS6MAS_Name( aCountry : byte) : string;

function CanAlterGSTClass( aCountry, aType : byte) : boolean;

function HasAlternativeChartCode(aCountry, aType : byte) : boolean;
function AlternativeChartCodeName(aCountry, aType : byte) : ShortString;

function IsForexCode(aCountry: Byte; ACode: shortString): Boolean;

//******************************************************************************
IMPLEMENTATION
USES
   BKCONST,
   SysUtils,
   MYOBAO_Utils, Sol6_Utils, Globals;

var
  bcLinkFound : boolean;
  bcLinkChecked : boolean;
  s6ComFound : boolean;
  s6ComChecked : boolean;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function CanExtractData( aCountry, aType : Byte ): Boolean;
//default is true, the systems listed here are exceptions
Begin
   CanExtractData := TRUE;
   Case aCountry of
      whNewZealand   : If aType in [ snOTHER, snHAPAS, snLotus123 ] then
                          CanExtractData := FALSE;
      whAustralia    : If aType in [ saOTHER, saHAPAS, saLotus123 ] then
                          CanExtractData := FALSE;
      whUK           : If aType in [ suOther ] then
                          CanExtractData := FALSE;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ContraCodeRequired( aCountry, aType : Byte ): Boolean;

Begin
   ContraCodeRequired := FALSE;
   Case aCountry of
      whNewZealand   :  ContraCodeRequired :=
                        aType in [  snGLMAN, snMYOB_AO_COM, snXPA,
                                    snAdvance, snCharterQX, snAclaim, snInterSoft,
                                    snSolution6CLS3, snSolution6CLS4,
                                    snSolution6MAS41, snSolution6MAS42,
                                    snSolution6CLSY2K,
                                    snCaseWare, snBK5CSV, snAcclipse, snMYOBOnlineLedger
                                     ];
                                     
      whAustralia    :  ContraCodeRequired :=
                        aType in [  saGLMAN, saOmicom, saHandiLedger, saXPA,
                                    saSolution6CLS3, saSolution6CLS4,
                                    saSolution6MAS41, saSolution6MAS42,
                                    saCaseWare, saProflex,
                                    saSolution6CLSY2K, saMGL,
                                    saComparto, saCatSoft,
                                    saMYOBAccountantsOffice, saMYOB_AO_COM,
                                    saXlon, saBK5CSV, saAcclipse, saMYOBOnlineLedger
                                  ];
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function CanExtractInNewFormat( aCountry, aType : Byte ): Boolean;
//this is only relevant for certain systems where we support both a pre GST
//and a post GST format
Begin
   CanExtractInNewFormat := FALSE;
   Case aCountry of
      whNewZealand   : If aType in [ snAdvance, snGLMAN, snGlobal, snMaster2000 ] then
                          CanExtractInNewFormat := TRUE;
      whAustralia    : If aType in [ saGLMAN, saOmicom ] then
                          CanExtractInNewFormat := TRUE;
   end;
end;
//-----------------------------------------------------------------------------
function IsMYOBLedger( aCountry, aSystem : byte) : boolean;
begin
  Result := False;
  Case aCountry of
    whNewZealand   : Result := (aSystem = snMYOBOnlineLedger );
    whAustralia    : Result := (aSystem = saMYOBOnlineLedger );
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsBGL360( aCountry, aSystem : byte) : boolean;
begin
   result := false;
   Case aCountry of
      whNewZealand   : result := false;
      whAustralia    : If aSystem in [ saBGL360 ] then
                          result := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//***************************************************************************//
// NB!!! This code has had to be duplicated in the                           //
// BulkExport/ExtractBGL360.pas file, for the BBE_BGL360 Bulk Export DLL.    //
// The reason is because this unit includes presentation layer unit's in     //
// it's uses clause  - DN 30/11/2015                                         //
//***************************************************************************//
Function CanExtractAccountNumberAs( aCountry, aType : Byte ) : boolean;
begin
   result := false;
   Case aCountry of
      whNewZealand   : result := false;
      whAustralia    : If aType in [ saBGL360 ] then
                          result := true;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function IsHAPAS( aCountry, aType : Byte ): Boolean;

Begin
   IsHAPAS := ( ( aCountry = whAustralia ) and ( aType = saHAPAS ) ) OR
         ( ( aCountry = whNewZealand ) and ( aType = snHAPAS ) );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
Function FloppyDiskRequired( aCountry, aType : Byte ): Boolean;
//mh 28/08/02 - function not used
Begin
   FloppyDiskRequired := FALSE;
   Case aCountry of
      whNewZealand   : If aType in [ snHAPAS, snSmartLink, snJobal ] then
                          FloppyDiskRequired := TRUE;
      whAustralia    : If aType in [ saHAPAS ] then
                          FloppyDiskRequired := TRUE;
   end;
end;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ApplyAccountGSTClassesFromMASTER( aCountry, aType : Byte ): Boolean;
Begin { Set this to TRUE when there is no GST Type information in the chart }
   result := false;
   Case aCountry of
      whNewZealand   : If aType in [ snAttache, snIntersoft, snAccPac, snCCM, snMYOB, snAttacheBP ] then
                          result := true;
      whAustralia    : Result := True ;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ApplyAccountTypesFromMASTER( aCountry, aType : Byte ): Boolean;
Begin
   result := true;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  CanRefreshChart( aCountry, aType : Byte ) : Boolean;
begin
   Result := False;
   Case aCountry of
      whNewZealand   : begin
         If ( aType in [ snSolution6CLS3,
                         snSolution6CLS4,
                         snSolution6MAS41,
                         snSolution6MAS42,
                         snSolution6CLSY2K,
                         snGLMan,
                         snMYOB_AO_COM,
                         snXPA,
                         snGlobal,
                         snMaster2000,
                         snAdvance,
                         snAttache,
                         snCCM,
                         snConceptCash2000,
                         snCharterQX,
                         snIntech,
                         snAclaim,
                         snIntersoft,
                         snAccPac,
                         snMYOB,
                         snMYOBGen,
                         snAccPacW,
                         snBK5CSV,
                         snBeyond,
                         snAttacheBP,
                         snQBWO,
                         snQBWN,
                         snCashManager,
                         snAcclipse,
                         snMYOBAccRight,
                         snMYOBOnlineLedger ] ) then
            Result := True;
      end;
      whAustralia    : begin
         If ( aType in [ saSolution6CLS3,
                         saSolution6CLS4,
                         saSolution6MAS41,
                         saSolution6MAS42,
                         saSolution6CLSY2K,
                         saCeeData,
                         saGLMan,
                         saXPA,
                         saMYOBAccountantsOffice, saMYOB_AO_COM,
                         saOmicom,
                         saAttache,
                         saBGLSimpleFund,
                         saMYOB,
                         saMYOBGen,
                         saQBWN,
                         saQBWO,
                         saAccountSoft,
                         saCaseWare,
                         saProFlex,
                         saHandiLedger,
                         saAttacheBP,
                         saMGL,
                         saComparto,
                         saXlon,
                         saCatsoft,
                         saBk5CSV,
                         saBCSAccounting,
                         saTaxAssistant,
                         saElite,
                         saSolution6SuperFund,
                         saSupervisor,
                         saAccomplishCashManager,
                         saDesktopSuper,
                         saBGLSimpleLedger,
                         saIRESSXplan,
                         saSuperMate,
                         saProSuper,
                         saClassSuperIP,
                         saAcclipse,
                         saMYOBAccRight,
                         saBGL360,
                         saMYOBOnlineLedger  ] ) then
            Result := True;
      end;
      whUK    : begin
         if (AType in [suBK5CSV,
                       suQuickBooks,
                       suSageLine50,
                       suTASBooks
                       ]) then
            Result := True;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ExtractDataFileNameRequired(aCountry, aType : Byte ) : Boolean;
//by default all system require a filename, except those listed here
begin
   Result := true;
   Case aCountry of
      whNewZealand   : begin
         If ( aType in [ snSmartLink,
                         snJobal,
                         snQIF ]) then
            Result := false;
      end;
      whAustralia    : begin
         If ( aType in [ saQIF,
                         saBGL360 ]) then
            Result := false;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsBCLinkAvailable : boolean;
//see if we have checked for bcLink, if so use the cached value, this is done
//so that we dont need to initialize the object everytime we want to see if
//it is available.
begin
  if bcLinkChecked then  //debug - for alway to check
    result := bcLinkFound
  else
  begin
    bcLinkChecked := true;
    bcLinkFound := myobao_utils.MYOBAO_bcLink_Exists;

    result := bcLinkFound;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ExcludeFromAccSysList( aCountry, aType : byte) : boolean;

// These accounting systems are either obsolete, untested or reserved
// for future use.
// The ExcludeFromAccSysList function is used to exclude them from the drop-down lists on the
// client accounting system dialog and the practice details dialog.
begin
   Result := False;
   Case aCountry of
      whNewZealand :
         begin
            If aType in [
                          snSolution6MAS41,     // removed Apr 2003
                          snHapas,              // Obsolete
                          snLotus123,           // Unsupported in BK5
                          {$IFNDEF MYOB_AO_COM}
                          snMYOB_AO_COM,
                          {$ENDIF}

                          {$IFNDEF SmartBooks}
                          snSmartBooks,
                          {$ENDIF}
                          snAclaim,             // Obsolete
                          snPastel,             // Poss future use
                          snCaseware,           //not a NZ GL!!!
                          snQbwO,snQbwN                //on hold
//                          snMYOBGen             //on hold
                        ] then Result := True
            // switch off legacy Sol6 CLS systems unless asked for in the INI file
            else if (aType in [snSolution6CLS3,snSolution6CLS4,snSolution6CLSY2K]) then begin
               if (not PRACINI_ShowSol6Systems) then
                     Result := True;
            end;

         end;
      whAustralia    :
         begin
            If aType in [
                          saSolution6MAS41,    // removed apr 2003
                          saHapas,             // Obsolete
                          saLotus123,          // Unsupported in BK5
                          saCeeDataCDS1,       // Obsolete
                          saProflex,           // Obsolete
                          saTeletaxLW         // Obsolete
                     {$IFDEF SmartLink}
                          //smartlink is a citrix based as so cannot export
                          //to systems that use an exe, com object or dll
                          //to transfer data
                     {$ENDIF}
//                          saMYOBGen            //on hold
                        ] then Result := True
            // switch off legacy Sol6 CLS systems unless asked for in the INI file
            else if (aType in [saSolution6CLS3,saSolution6CLS4,saSolution6CLSY2K]) then begin
               if (not PRACINI_ShowSol6Systems) then
                   Result := True;
            end else if aType in [saMYOB_AO_COM] then begin
               if (not PRACINI_MYOB_AO_Systems) then
                     Result := True;
            end else if aType = saProSuper then begin
               if (not PRACINI_ShowProSuper) then
                   Result := True;
            end else if aType = saRewardSuper then begin
               if (not PRACINI_ShowRewardSuper) then
                   Result := True;
            end;
         end;
      whUK: begin
              Result := aType in [suQIF, suOFXV1, suOFXV2];

      end;
   end;
end;

// Put web export formats here to remove them from the selection in Maintain Accounting System
function ExcludeFromWebFormatList( aCountry, aType : byte) : boolean;
begin
  Result := False;
  case aCountry of
    // Add other countries and types as necessary
    whUK: begin
      Result := aType in [wfWebX]; // No Acclipse for UK
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsSuperFund( aCountry, aSystem : byte) : boolean;
//returns true if the accounting system is for a superfund
begin
  result := False;
  case aCountry of
    whAustralia : result := aSystem in [ saBGLSimpleFund, saClassSuperIP,
                                         saDesktopSuper, saSolution6SuperFund,
                                         saPraemium, saSupervisor, saIRESSXplan,
                                         saSuperMate, saRewardSuper, saProSuper,
                                         saSageHandisoftSuperfund, saBGL360];
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CanUseSuperFundFields( aCountry, aType : byte; sdMode: TSuperDialogMode = sfTrans) : boolean;
//returns true if the interface supports superfund fields
begin
  result := false;
  case aCountry of
    whAustralia: Result := aType in [ saBGLSimpleFund, saSupervisor,
                                      saSolution6SuperFund, saDesktopSuper,
                                      saBGLSimpleLedger, saSuperMate,
                                      saSageHandisoftSuperfund, saClassSuperIP,
                                      saBGL360];
  end;
  if Result then
     if (sdMode in [sfMem])
     and (aType = saSageHandisoftSuperfund) then
        Result := False;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UseSaveToField( aCountry, aType : byte) : boolean;
begin
   if IsMYOBAO_DLL_Interface( aCountry, aType) then
      Result := false
   else
      case aCountry of
        whUK : Result := not (aType in [suTASBooks, suSageLine50])
        else Result := true;
      end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsPA7Interface( aCountry, aType : byte) : boolean;
begin
  result := ((aCountry = whNewZealand) and ( aType = snAdvance)) or
            ((aCountry = whAustralia) and ( aType = saOmicom));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function HasSuperfundLegerID( aCountry, aType : byte) : boolean;
begin
  result := ((aCountry = whAustralia) and ( aType = saDesktopSuper));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function HasSuperfundLegerCode( aCountry, aType : byte) : boolean;
begin
  result := ((aCountry = whAustralia) and ( aType = saClassSuperIP));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsXPA8Interface( aCountry, aType : byte) : boolean;
begin
  result := ((aCountry = whNewZealand) and ( aType = snXPA)) or
            ((aCountry = whAustralia) and ( aType = saXPA));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsMYOBAO_7( aCountry, aType : byte) : boolean;
begin
  result := (
              ((aCountry = whNewZealand) and ( aType = snGLMan ))
              or
              ((aCountry = whAustralia) and ( aType = saMYOBAccountantsOffice))
             );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsMYOBAO_DLL_Interface( aCountry, aType : byte) : boolean;
//returns true if is full DLL interface
//currently disabled for NZ and AU until issues resolved with UI in
//AO product
begin
  result := (
              ((aCountry = whNewZealand) and ( aType = snMYOB_AO_COM))
              or
              ((aCountry = whAustralia) and ( aType = saMYOB_AO_COM))
             );
            //and IsBCLinkAvailable;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CanUseMYOBAO_DLL_Refresh( aCountry, aType : byte) : boolean;
//the com dll interface will be used for chart refresh if available
begin
  result := IsMYOBAO_DLL_Interface( aCountry, aType) or
            (IsMYOBAO_7( aCountry, aType) and IsBCLinkAvailable);
end;

function GetMYOBAO_Name( aCountry : byte) : string;
begin
  if aCountry = whNewZealand then
    result := bkconst.snNames[ snGLMan]
  else
    result := bkConst.saNames[ saMYOBAccountantsOffice];
end;

function GetS6MAS_Name( aCountry : byte) : string;
begin
  if aCountry = whNewZealand then
    result := bkconst.snNames[ snSolution6MAS42]
  else
    result := bkConst.saNames[ saSolution6MAS42];
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsS6COMAvailable : boolean;
//see if we have checked for bcLink, if so use the cached value, this is done
//so that we dont need to initialize the object everytime we want to see if
//it is available.
begin
  if false and s6ComChecked then  //debug - for alway to check
    result := s6ComFound
  else
  begin
    s6ComChecked := true;
    s6ComFound := Sol6_utils.MAS_S6BNK_DLL_Exists;

    result := s6ComFound;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function IsSol6_COM_Interface( aCountry, aType : byte) : boolean;
begin
  result := (((aCountry = whNewZealand) and ( aType = snSolution6MAS42)) or
            ((aCountry = whAustralia) and ( aType = saSolution6MAS42)))
            and IsS6COMAvailable;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CanAlterGSTClass( aCountry, aType : byte) : boolean;
begin
  Result := True;
  if ( aCountry = whAustralia ) and
     ( aType = saElite) then
    Result := False;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function HasAlternativeChartCode(aCountry, aType : byte) : boolean;
begin
   case aCountry of
//DN BGL360 API - Does not have ASX codes, only check for SimpleFund   whAustralia : Result := (aType in [saBGLSimpleFund , saBGL360 ])

     whAustralia : Result := (aType in [ saBGLSimpleFund ])

   else Result := False;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function AlternativeChartCodeName(aCountry, aType : byte) : ShortString;
begin
   Result := '';
   case aCountry of
   whAustralia :
       case aType of
//DN BGL360 API - Does not have ASX codes, only check for SimpleFund          saBGLSimpleFund, saBGL360 : Result := 'ASX Code';

         saBGLSimpleFund : Result := 'ASX Code';


       end
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsForexCode(aCountry: Byte; ACode: shortString): Boolean;
begin
   Result := not Sametext(ACode, whCurrencyCodes[aCountry])
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
  //initialise cached value to determine if MYOB AO bcLink interface is available
  bcLinkFound := false;
  bcLinkChecked := false;

  s6ComFound := false;
  s6ComChecked := false;
END.

