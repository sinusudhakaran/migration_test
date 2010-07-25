library ParseBK5Win;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$DEFINE ParserDll}
{$R *.res} 
uses
  SysUtils,
  Windows,
  Clobj32,
  ClientWrapper,
  upgConstants,
  SysObj32,

  Classes;


function ParserApp
             (CallingApp: PChar;
              aHandle: THandle;
              ApplicationID: longInt;
              ReplyBuffer: PChar;
              ReplyBufferSize: longInt;
              out ReplySize: LongInt) : LongInt; stdcall;

   var ClientCode,
       PracticeCode,
       PracticeName,
       BankLinkCode,
       ReplyString : string;

   function GetPracticeDetails: Boolean;
   var LS: TSystemObj;
   begin
      Result := False;
      LS := TSystemObj.Create;
      try try
         LS.Open;
         BankLinkCode := LS.fdFields.fdBankLink_Code;
         PracticeName := LS.fdFields.fdPractice_Name_for_Reports;
         Result := True;
      except
         on E: Exception do
            ReplyString := E.Message;
      end;
      finally
         LS.Free;
      end;
   end;


   function GetBooksDetails: Boolean;
   var
      ClientFilename: string;
      Wrapper: TClientWrapper;
      LC: TClientObj;
   begin
      Result := False;
      if ClientCode = '' then
         Exit; // No Show...

      ClientFilename := DataDir+ClientCode+FILEEXTN;
      if not bkFileExists(ClientFilename) then
         Exit; // Still No show

      LC :=  TClientObj.Create;
      try try
         LC.Open(ClientCode, FILEEXTN);
         PracticeName := LC.clFields.clPractice_Name;
         if LC.clFields.clDownload_From = 1 {dlBankLinkConnect} then
            BankLinkCode := LC.clFields.clBankLink_Code;
         if LC.clFields.clFile_Version >= 138 then  // Was clUpgrade_server
            PracticeCode := LC.clFields.clPractice_Code;

         Result := True;
      except
         on E: Exception do
            ReplyString := E.Message;
      end;
      finally
         LC.Free;
      end;

   end;

   function GetBooksOpenClientCode: Boolean;
   var lt,bp: PChar;
   const ls = 350;  // We should have atleast the code...
   begin
      Result := False;
      if AHandle = 0 then
         Exit;
      GetMem(lt,ls);
      try
         GetWindowText(aHandle,lt,pred(ls));
         bp := strPos(lt,': '); // The separator beteen Code and Name
         if bp <> nil then begin
            // Find the last Non space Char
            repeat
               dec(bp)
            until (bp <= lt)
            or (bp^ > ' ');
            (bp + 1)^ := #0; // Terminate
            repeat
               while (bp > lt)
               and (bp^ > ' ') do
                  Dec(bp);
               if StrLen(bp) > 9 then // With Space..
                  Break;
               ClientCode := string(bp+1);
               if GetBooksDetails then begin
                  Result := True;
                  Break;
               end else
                  Dec(bp); // Try some more.
                  // You can actualy have a space as part of the name.
            until false;
            if not Result then
               ReplyString := 'Can''t open <' + ClientCode + '>';
         end else
            ReplyString := 'No Client file Open'

      finally
         FreeMem(lt,ls);
      end;
   end;

   function GetNewestClientFile: Boolean;
   var SR: TSearchRec;
       LatestDate : Integer;
   begin
      Result := False;
      ClientCode := '';
      if FindFirst(DataDir+'*'+FILEEXTN,faAnyfile,sr) = 0 then try
         LatestDate := SR.Time;
         ClientCode := SR.Name;
         while FindNext(SR) = 0 do begin
            if SR.Time > LatestDate then begin
               ClientCode := SR.Name;
               LatestDate := SR.Time;
            end;
         end;
      finally
         Sysutils.FindClose(SR);
      end;

      if ClientCode > '' then begin
         ClientCode := ChangeFileExt(ClientCode,'');
         Result := GetBooksDetails;
      end else
         ReplyString := 'No Client files found'
   end;


   function GetBooksClientCode: Boolean;
   begin
      Result := GetBooksOpenClientCode;
      if Result then
         Exit;
      Result := GetNewestClientFile;
      if Result then
         Exit;
   end;

   function BuildReply : Integer;
   var P: Integer;
   begin
      ReplyString := '';
      Result := 0;
      if PracticeCode > '' then begin
         Result := Result + Pa_PracticeCode;
         ReplyString := eiPracticeCode + '=' + PracticeCode;
      end;
      if PracticeName > '' then begin
         Result := Result + Pa_PracticeName;
         repeat
            P := Pos(',',PracticeName);
            if P > 0 then
               PracticeName[P] := '_';
         until P = 0;
         if ReplyString > '' then
            ReplyString := ReplyString + ',';
         ReplyString := ReplyString + eiPracticeName + '=' + PracticeName;
      end;
      if ClientCode > '' then begin
         Result := Result + Pa_ClientCode;
         if ReplyString > '' then
            ReplyString := ReplyString + ',';
         ReplyString := ReplyString + eiClientCode + '=' + ClientCode;
      end;
      if BankLinkCode > '' then begin
         Result := Result + Pa_BankLinkCode;
         if ReplyString > '' then
            ReplyString := ReplyString + ',';
         ReplyString := ReplyString + eiBankLinkCode + '=' + BankLinkCode;
      end;

   end;

begin
   Result := Pa_DllFailed;
   ReplySize := 0;
   ClientCode := '';
   PracticeCode := '';
   PracticeName := '';
   BankLinkCode := '';
   ReplyString := '';
   case ApplicationID of
     aidBK5_Practice : if GetPracticeDetails then
             Result := BuildReply;

     aidBK5_Offsite : if GetBooksClientCode then
             Result := BuildReply;

     else ReplyString := 'Wrong Appicaltion ID';
   end;

   // Return the Reply
   ReplySize := Length(ReplyString);
   StrCopy(ReplyBuffer,pchar(ReplyString));

   
end;


exports
   ParserApp;

begin
end.
