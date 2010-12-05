unit ExUtil;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(* 

This replaces the CheckExtractFileName(const PathName, Filename: string) : string;
function in ExUtils.PAS

*)

function DefaultFileName : ShortString;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses BKConst, Globals;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function DefaultFileName : ShortString;

   Procedure AddDirSymbol( Var S : ShortString );
   Var p : Byte;
   Begin
      p:=Ord( S[0] );
      If ( p>0 ) and ( S[p]<>'\' ) then S:=S+'\';
   end;

   

Var
   DefaultDir  : ShortString;
Begin
   Result := '';
   
   With MyClient.clFields do
   Begin
      If clSave_Client_Files_To <> '' then
      Begin
         Result := clSave_Client_Files_To;
         exit;
      end;

      DefaultDir := '';

      if Assigned( Globals.AdminSystem ) then with AdminSystem.fdFields do
      Begin
         If ( clAccounting_System_Used = fdAccounting_System_Used ) then
         Begin
            DefaultDir := fdSave_Client_Files_To;
            If DefaultDir = '' then DefaultDir := fdLoad_Client_Files_From;
            If DefaultDir <> '' then AddDirSymbol( DefaultDir );
         end;
      end;

      Case clCountry of
         whNewZealand :
            Case clAccounting_System_Used of
               snOther            : ;
               snSolution6MAS42   : begin
                 if clUse_Alterate_ID_for_extract then
                   result := clAlternate_Extract_ID + '.TXT'
                 else
                   Result := clCode + '.TXT';
               end;
               snHAPAS            : ;
               snGLMan,
               snMYOB_AO_COM      : Result := clCode + '.TXT';
               snGlobal           : Result := DefaultDir + clCode + '.DAT';
               snMaster2000       : Result := DefaultDir + clCode + '.TXN';
               snAdvance          : Result := DefaultDir + clCode + '.BNK';
               snXPA              : Result := '';
               snSmartLink        : Result := 'A:\';
               snJobal            : Result := 'A:\';
               snCashManager      : Result := DefaultDir + clCode + '.DAT';
               snAttache          : Result := DefaultDir + clCode + '\BANKLINK.CSV';
               snASCIICSV         : Result := DefaultDir + clCode + '.CSV';
               snCharterQX        : Result := DefaultDir + 'BATCH01.GL';
               snIntech           : Result := DefaultDir + clCode + '.TXN';
               snKelloggs         : Result := DefaultDir + clCode + '.DAT';
               snAclaim           : ;
               snIntersoft        : Result := DefaultDir + clCode + '.CSV';
               snLotus123         : ;
               snAccPac           : Result := DefaultDir + clCode + '\GLBATCH.SAM';
               snCCM              : Result := DefaultDir + clCode + '.TXT';
               snMYOB             : Result := DefaultDir + clCode + '.TXT';
               snAccPacW          : Result := DefaultDir + clCode + '\GLBATCH.CSV';
               snSmartBooks       : Result := 'A:\';
               snBeyond           : Result := DefaultDir + clCode + '.CSV';
               snPastel           : ;
               snSolution6CLS3    : Result := clCode + '.TXT';
               snSolution6CLS4    : Result := clCode + '.TXT';
               snSolution6MAS41   : Result := clCode + '.TXT';
               snAttacheBP        : Result := DefaultDir + clCode + '.KFI';
               snBK5CSV           : Result := DefaultDir + clCode + '.CSV';
               snSolution6CLSY2K  : Result := clCode + '.TXT';
               snConceptCash2000  : Result := DefaultDir + clCode + '.CSV';
               snQBWn,
               snQBWo	            : Result := DefaultDir + clCode + '.IIF';
               snQIF              : Result := DefaultDir + clCode + '\';
               snOFXV1            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV1];
               snOFXV2            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV2];
            end;
         whAustralia :
            Case clAccounting_System_Used of
               saOther            : ;
               saSolution6MAS42   : begin
                 if clUse_Alterate_ID_for_extract then
                   result := clAlternate_Extract_ID + '.TXT'
                 else
                   Result := clCode + '.TXT';
               end;
               saHAPAS            : ;
               saCeeData          : Result := '<AUTO>';
               saGLMan            : Result := clCode + '.TXT';
               saOmicom           : Result := DefaultDir + clCode + '.BNK';
               saXPA              : Result := '';
               saASCIICSV         : Result := clCode + '.CSV';
               saLotus123         : ;
               saAttache          : Result := DefaultDir + clCode + '\BANKLINK.CSV';
               saHandiLedger      : Result := DefaultDir + clCode + '.ASC';
               saBGLSimpleFund, saBGLSimpleLedger    : Result := DefaultDir + clCode + '\BANKLINK.CSV';
               saMYOB             : Result := DefaultDir + clCode + '.TXT';
               saCeeDataCDS1      : ;
               saSolution6CLS3    : Result := clCode + '.TXT';
               saSolution6CLS4    : Result := clCode + '.TXT';
               saSolution6MAS41   : Result := clCode + '.TXT';
               saQBWn,
               saQBWo		  : Result := DefaultDir + clCode + '.IIF';
               saCaseWare         : Result := DefaultDir + clCode + '.CSV';
               saBK5CSV           : Result := DefaultDir + clCode + '.CSV';
               saAccountSoft      : Result := DefaultDir + clCode + '.CSV';
               saProflex          : Result := DefaultDir + clCode + '.CSV';
               saTeletaxLW        : Result := DefaultDir + clCode + '.TXT';
               saAttacheBP        : Result := DefaultDir + clCode + '.KFI';
               saSolution6CLSY2K  : Result := clCode + '.TXT';
               saEasyBooks        : Result := DefaultDir + clCode + '.EZD';
               saMGL              : Result := DefaultDir + clCode + '.BLT';
               saComparto         : Result := DefaultDir + clCode + '.CSV';
               saXlon             : Result := DefaultDir + clCode + '.Xlon2';
               saCatsoft          : Result := DefaultDir + clCode + '.TXT';
               saBCSAccounting    : Result := DefaultDir + clCode + '.TFR';
               saMYOBAccountantsOffice,
               saMYOB_AO_COM      : Result := clCode + '.TXT';
               saSolution6SuperFund : Result := DefaultDir;
               saSupervisor, saSuperMate : Result := DefaultDir;
               saTaxAssistant     : Result := DefaultDir + clCode + '.CSV';
               saElite            : Result := DefaultDir + clCode + '.CSV';
               saAccomplishCashManager : Result := DefaultDir + clCode + '.CSV';
               saPraemium         : Result := DefaultDir + clCode + '.CSV';
               saQIF              : Result := DefaultDir + clCode + '\';
               saOFXV1            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV1];
               saOFXV2            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV2];
               saDesktopSuper     : Result := DefaultDir + clCode + '.CSV';
            end;

         whUK :
            Case clAccounting_System_Used of
               suOther            : ;
               suSageLine50       : ;
               suQuickBooks       : Result := DefaultDir + clCode + '.IIF';
               suQIF              : Result := DefaultDir + clCode + '\';
               suOFXV1            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV1];
               suOFXV2            : Result := DefaultDir + clCode + bpFileExtn[bpOFXV2];
               suBK5CSV           : Result := DefaultDir + clCode + '.CSV';
               suTASBooks         : ;


            end;

      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
