Unit CeeData;

{..$I DEBUGME}

//------------------------------------------------------------------------------
Interface

//------------------------------------------------------------------------------
Procedure RefreshChart;
//------------------------------------------------------------------------------
Implementation

//------------------------------------------------------------------------------
Uses
   Globals, SysUtils, InfoMoreFrm, bkconst, bkdefs, 
   ErrorMoreFrm, Windows, ststrs, BK5Except, LogUtil,
   {   GenUtils, progress, bautils, bkDateUtils,} 
   CeeDataIni, DosExec, {      BkUtil32,} CSVChart, WinUtils;

Const
   UnitName = 'ceedata';
   DebugMe : boolean = false;

{..$DEFINE TESTING}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure ExtractCeeDataChart( ACode: string );
Const
   ThisMethodName = 'ExtractCeeDataChart';
Var
   Parameters : string;
   Msg        : string;
   FQExeName  : string;
   ChtFileName: string;
   ErrorCode  : longint;
Begin
   If DebugMe Then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

   FQExeName := Globals.ExecDir + cdExeName;

   If not BKFileExists(FQExeName) Then
   Begin
      Msg := Format('Unable to Import Chart. %s does not exist', [FQExeName]);
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EExtractData.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End;

   ChtFileName := ACode + '.CHT';

   SysUtils.DeleteFile(ChtFileName);

   Parameters := FQExeName;

   If cdActiveOnly Then
      Parameters := Parameters + ' -a';

   If cdGroupID <> '0' Then
      Parameters := Parameters + ' -g ' + cdGroupID;

   If cdHomeDir <> '' Then
      Parameters := Parameters + ' -d ' + cdHomeDir;

   If cdPrototypeDir <> '' Then
      Parameters := Parameters + ' -p ' + cdPrototypeDir;

   Parameters := Parameters + ' ' + ACode;
   Parameters := Parameters + ' ' + ChtFileName;

   ErrorCode := DosExec.RunDOSCommand(Parameters);

   If (ErrorCode <> 0) Then
   Begin
      Msg := Format('Unable to Import Chart. %s failed returned error number %d',
         [Parameters, ErrorCode]);
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EExtractData.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End;

   If not BKFileExists(ChtFileName) Then
   Begin
      Msg := Format('Unable to Import Chart. %s ran but did not produce the Chart File %s',
         [Parameters, ChtFileName]);
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EExtractData.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End;

   If DebugMe Then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure RefreshChart;

Const
   ThisMethodName = 'RefreshChart';
Var
   ChtFileName : String;
   Msg         : String;
Begin { RefreshChart } 
   If DebugMe Then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins'); 
   
   If not Assigned(MyClient) Then exit; 
   
   With MyClient.clFields Do 
   Begin 
      Try 
         ChtFileName := clCode + '.CHT'; 
{$IFNDEF TESTING} 
         SysUtils.DeleteFile(ChtFileName); 
         ExtractCeeDataChart( clCode );
{$ENDIF} 
      Except 
         On E : EExtractData Do 
         Begin 
            Msg := Format('Error Refreshing Chart %s.', [ChtFileName]);
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg); 
            HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.'#13, 0, False, E.Message, True); 
            exit;
         End; 
      End;
      
      If BKFileExists( ChtFileName ) then
      Begin
         clLoad_Client_Files_From := ChtFileName;
         CSVChart.RefreshChart( '*.CHT', 'XLON.TPM', iText );
         clLoad_Client_Files_From := '';
      end;
   end;
   
   If DebugMe Then 
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends'); 
End; { RefreshChart } 


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Initialization 
   DebugMe := LogUtil.DebugUnit(UnitName); 
End.           

