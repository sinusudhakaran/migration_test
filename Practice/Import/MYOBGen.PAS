unit MYOBGen;

//------------------------------------------------------------------------------
//  Chart inport for MYOB General Journal format
//
//  Scott Wilson 27-Oct-2009
//
//  See Case #1491
//------------------------------------------------------------------------------

interface

procedure RefreshChart;

implementation

uses
  Globals, glConst, SysUtils, bkconst, chList32, bkchio, InfoMoreFrm,
  bkdefs, ovcDate, ErrorMoreFrm, WarningMoreFrm, stDateSt,
  classes, LogUtil, bk5Except, ChartUtils, GenUtils, bkDateUtils,
  WinUtils, Templates;

const
  MYOB_GEN_EXTN = 'TXT';
  MYOB_MASK     = '#-####';
  UNIT_NAME     = 'MYOBGen';
  DebugMe: Boolean = False;

  //GST Classes
  GST_NON_TAXABLE   = 'N-T';
  GST_TAXABLE       = 'GST';
  GST_EXPORT        = 'GSTE';
  GST_FREE          = 'FRE';
  GST_INPUT_TAXED   = 'INP';
  GST_CAPITAL       = 'CAP';

function GetGstClass(AGstClassCode: string): Byte;
var
  i: integer;
begin
  Result := 0;
  if Trim(AGstClassCode) = '' then Exit;
  for i := 1 to MAX_GST_CLASS do
    if AGstClassCode = UpperCase(MyClient.clFields.clGST_Class_Codes[i]) then begin
      Result := i;
      Exit;
    end;
end;

procedure RefreshChart;
const
  THIS_METHOD_NAME = 'RefreshChart';
  //FileDelim = ','; //or #9
  FileDelim = #9;
  // Columns
  c_ChartCode = 0;
  c_Desc      = 1;
  c_Header    = 2;
  //Balance   3
  c_reportGroup = 4;
  // Last Cheque number 5
  c_TaxCode   = 6;
  STR_BRACKETS = '{}';

var
  ChartFileName       : string;
  ChartFilePath       : string;
  HCtx                : integer;
  F                   : TextFile;
  Buffer              : array[ 1..8192 ] of Byte;
  Line                : string;
  NewChart            : TChart;
  NewAccount          : pAccount_Rec;
  p                   : integer;
  ACode               : Bk5CodeStr;
  ADesc, AType        : string[80];
  AGstClassCode       : string;
  AGstClass           : integer;
  Msg                 : string;
  OK                  : Boolean;
  CodeRec: TStringList;
  TemplateFileName: string;
  FirstLine : Boolean;
  TemplateError : TTemplateError;
begin
  OK := False;

  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  with MyClient.clFields do begin
    ChartFileName := clLoad_Client_Files_From;

    //User only specified a directory - we need a filename
    if DirectoryExists(ChartFileName) then begin
      ChartFileName := '';
      ChartFilePath := AddSlash(clLoad_Client_Files_From);
    end else
      ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;   //      hcMYOB001
      ChartFileName := RemoveSlash(ChartFileName);
      if not LoadChartFrom( clCode,
                            ChartFileName,
                            ExtractFilePath(ChartFilePath),
                            'MYOB General Chart|*.TXT',
                            'TXT',
                            HCtx ) then
        Exit;
    end;

    //Load GST template - AU only
    if MyClient.clFields.clCountry = whAustralia then begin
      if not (MyClient.GSTHasBeenSetup) then
      begin
        TemplateFileName := GLOBALS.TemplateDir + 'MYOBACC.TPM';
        if BKFileExists(TemplateFileName) then
          Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
      end;
    end;

    try {except}
      AssignFile(F,ChartFileName);
      SetTextBuf( F, Buffer );
      Reset(F);
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      try
        CodeRec := TStringList.Create;
        try

//Don't know if tab-delimited version contains header row
//          Readln( F, Line ); //Column headers
//          if not (UpperCase(Copy(Line, 1, 14)) = 'ACCOUNT NUMBER') then begin
//            Msg := Format('Column headers not found in chart file "%s".', [ChartFileName]);
//            LogUtil.LogMsg(lmError, UNIT_NAME, Msg);
//            Reset(F);
//          end;

          FirstLine := true;
          while not EOF( F ) do begin
            Readln( F, Line );

            if (FirstLine) and (trim(Line) = STR_BRACKETS) then
            begin
              FirstLine := false;
              continue;
            end;

            //Check file format
            p := Pos(FileDelim, Line);
            if (p = 0) then begin
              Msg := 'The file is not in the correct format.';
              LogUtil.LogMsg(lmError, UNIT_NAME, THIS_METHOD_NAME + ' : ' + Msg);
              raise EExtractData.CreateFmt('%s - %s : %s', [UNIT_NAME, THIS_METHOD_NAME, Msg]);
            end;


            //Get information from this line
            CodeRec.Clear;
            CodeRec.Delimiter := FileDelim;
            CodeRec.StrictDelimiter := True;
            CodeRec.DelimitedText := Line;

            ACode := Trim(CodeRec.Strings[c_ChartCode]);
            if pos('ACCOUNT',Acode) <> 0 then
              Continue;

            //Apply MYOB mask #-####
            ACode := Format('%s-%s', [ACode[1], Copy(ACode, 2, 10)]);

            ADesc := CodeRec.Strings[c_Desc];
            AType := CodeRec.Strings[c_Header];

            //GST class
            AGstClass := 0;
            AGstClassCode := Trim(CodeRec.Strings[c_TaxCode]);
            if (AGstClassCode <> '') then begin
              if TryStrToInt(ACode[1], AGstClass) then begin
                case AGstClass of
                  5, 6, 9: AGstClassCode := UpperCase(AGstClassCode) + 'P'; //Taxable Purchases
                  4, 8   : AGstClassCode := UpperCase(AGstClassCode) + 'S'; //Taxable Supplies
                end;
              end;
              AGstClass := GetGstClass(AGstClassCode);
            end;

            if (NewChart.FindCode(ACode) <> nil) then begin
               Msg := Format('Duplicate Code %s found in %s', [ACode, ChartFileName]);
               LogUtil.LogMsg(lmError, UNIT_NAME, Msg);
            end else begin
               //Insert new account into chart
               NewAccount := New_Account_Rec;
               with NewAccount^ do begin
                  chAccount_Code        := ACode;
                  chAccount_Description := ADesc;
                  chGST_Class           := AGstClass;
                  chPosting_Allowed     := (AType <> 'H');
              end;
              NewChart.Insert(NewAccount);
            end;

          end;//while not EOF( F )
        finally
          CodeRec.Free;
        end;

        if NewChart.ItemCount > 0 then begin
          MergeCharts(NewChart, MyClient);

          clLoad_Client_Files_From := ChartFileName;
          clChart_Last_Updated     := CurrentDate;

          if clAccount_Code_Mask = '' then
            clAccount_Code_Mask := MYOB_MASK;
          OK := True;
        end;
      finally
        NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
        CloseFile( F );
        if OK then
          HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
       end;
    except
      on E : exception do begin
        Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
        LogUtil.LogMsg( lmError, UNIT_NAME, THIS_METHOD_NAME + ' : ' + Msg );
        HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
      end;
    end;
  end;  {with }

  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;

end.

