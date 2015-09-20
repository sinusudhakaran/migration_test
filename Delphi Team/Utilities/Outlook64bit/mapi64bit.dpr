program mapi64bit;

{$APPTYPE CONSOLE}

uses
  System.StartUpCopy,
  FMX.Forms,
  System.Sysutils,
  System.Classes,
  EmailSender64 in 'EmailSender64.pas',
  OutlookOle in 'OutlookOle.pas',
  StrUtils;

{$R *.res}

{$R *.res}
{
   if more then 1 all the params should be comma separated
   -to receipts
   -cc copies
   -bcc blind copies
   -att pathes ti files
   -subject subject
   -body body
   -rtf is body is RTF  0 or 1 def = 0
   -html if body is HTML 0 or 1 def 0
   -ole is OLE
   -rtf is RTF
}

const
  PARAM_TO      = '-to';
  PARAM_CC      = '-cc';
  PARAM_BCC     = '-bcc';
  PARAM_ATT     = '-att';
  PARAM_SUBJECT = '-subject';
  PARAM_BODY    = '-body';
  PARAM_IS_RTF  = '-rtf';
  PARAM_IS_HTML = '-html';
  PARAM_IS_MAPI = '-mapi';
  PARAM_IS_OLE  = '-ole';

type
  TArrayType = (TO_ARR = 1, CC_ARR = 2, BCC_ARR = 3, ATT_ARR = 4);

function ParamsParsingSendEmail : integer; overload;
const
  comma = ';';
  space = ' ';
var
  i : integer;
  toArray : array of string;
  ccArray : array of string;
  bccArray : array of string;
  attArray : array of string;
  sbody : string;
  subj : string;
  sHtmlFilePath : string;
  sRTFFilePath : string;
  sParam : string;
  varStrList : TStringList;
  isOLE : boolean;
  isMAPI : boolean;
  EmailSender : TEmailSender64;
  EmailSenderOle : TOutlookOle;


  function GetCapacity(const sDelemitedText : TStrings) : integer;
  var
    i : integer;
  begin
    Result := 0;
    for i := 0 to sDelemitedText.Count - 1 do
    begin
      if not SameStr(sDelemitedText.Strings[i], '') then
      begin
        Inc(Result);
      end;
    end;
  end;

  procedure FillArrayAndClear(aDelimitedTxt : TStrings; const aArrType : TArrayType);
  var
    i : integer;
  begin
    case aArrType of
      TO_ARR :
        begin
          SetLength(toArray, GetCapacity(aDelimitedTxt));
          for i := 0 to aDelimitedTxt.Count - 1 do
          begin
            if not SameStr(aDelimitedTxt.Strings[i], '') then
              toArray[i] := Trim(aDelimitedTxt.Strings[i]);
          end;
        end;
      CC_ARR :
        begin
          SetLength(ccArray, GetCapacity(aDelimitedTxt));
          for i := 0 to aDelimitedTxt.Count - 1 do
          begin
            if not SameStr(aDelimitedTxt.Strings[i], '') then
              ccArray[i] := Trim(aDelimitedTxt.Strings[i]);
          end;
        end;
      BCC_ARR :
        begin
          SetLength(bccArray, GetCapacity(aDelimitedTxt));
          for i := 0 to aDelimitedTxt.Count - 1 do
          begin
            if not SameStr(aDelimitedTxt.Strings[i], '') then
              bccArray[i] := Trim(aDelimitedTxt.Strings[i]);
          end;
        end;
      ATT_ARR :
        begin
          SetLength(attArray, aDelimitedTxt.Count);
          for i := 0 to aDelimitedTxt.Count - 1 do
          begin
            if not SameStr(aDelimitedTxt.Strings[i], '') then
              attArray[i] := Trim(aDelimitedTxt.Strings[i]);
          end;
        end;
    end;
    aDelimitedTxt.Clear
  end;


  function ParseLongString(iParamIndex : integer; const aParamName : string) : string;
  var
    i : integer;
  begin
    Result := ParamStr(iParamIndex);
    if iParamIndex + 1 <= ParamCount then
      iParamIndex := iParamIndex + 1;

    for i := iParamIndex to ParamCount do
    begin
      if not SameStr(ParamStr(i), PARAM_TO) and
         not SameStr(ParamStr(i), PARAM_CC) and
         not SameStr(ParamStr(i), PARAM_BCC) and
         not SameStr(ParamStr(i), PARAM_ATT) and
         not SameStr(ParamStr(i), PARAM_SUBJECT) and
         not SameStr(ParamStr(i), PARAM_IS_RTF) and
         not SameStr(ParamStr(i), PARAM_IS_HTML) and
         not SameStr(ParamStr(i), PARAM_BODY) and
         not SameStr(ParamStr(i), PARAM_IS_MAPI) and
         not SameStr(ParamStr(i), PARAM_IS_OLE) then
      Result := Result + space + ParamStr(i) else
     Break;
    end;
    Result := Copy(Result, 0, Length(Result));
  end;

  procedure ParseAttachmentsString(iParamIndex : integer; var aStrList : TStringList);
  var
    sAttachment : string;
    i : integer;
    iPosition : integer;
  begin
    aStrList.Clear;
    for i := iParamIndex to ParamCount do
    begin
      if not SameStr(ParamStr(i), PARAM_TO) and
         not SameStr(ParamStr(i), PARAM_CC) and
         not SameStr(ParamStr(i), PARAM_BCC) and
         not SameStr(ParamStr(i), PARAM_ATT) and
         not SameStr(ParamStr(i), PARAM_SUBJECT) and
         not SameStr(ParamStr(i), PARAM_IS_RTF) and
         not SameStr(ParamStr(i), PARAM_IS_HTML) and
         not SameStr(ParamStr(i), PARAM_BODY) and
         not SameStr(ParamStr(i), PARAM_IS_MAPI) and
         not SameStr(ParamStr(i), PARAM_IS_OLE) then
      sAttachment := sAttachment + space + ParamStr(i) else
     Break;
    end;
    if Pos(comma, sAttachment) > 0 then
    begin
      while Pos(comma, sAttachment) > 0 do
      begin
        iPosition := Pos(comma, sAttachment) - 1;
        aStrList.Add(Trim(Copy(sAttachment, 0, iPosition)));
        sAttachment := StringReplace(sAttachment, Copy(sAttachment, 0, iPosition + 1), ' ', [rfIgnoreCase]);
      end;
    end else
     aStrList.Add(sAttachment);
  end;

  function GettingRidOfCommaAndTrim(sText : string) : string;
  var
    iPos : integer;
  begin
    Result := Trim(sText);
    if Pos(comma, Result) > 0 then
    begin
      iPos := Pos(comma, Result);
      Result := Trim(StringReplace(Result, comma, '', [rfReplaceAll]));
    end;
  end;

begin
  varStrList := TStringList.Create;
  varStrList.Delimiter := comma;
  Result := 10000;

  try
    for i := 0 to ParamCount do
    begin
      sParam := ParamStr(i);

      if SameStr(PARAM_TO, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        FillArrayAndClear(varStrList, TO_ARR);
      end;

      if SameStr(PARAM_CC, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        FillArrayAndClear(varStrList, CC_ARR);
      end;

      if SameStr(PARAM_BCC, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        FillArrayAndClear(varStrList, BCC_ARR);
      end;

      if SameStr(PARAM_ATT, sParam) then
      begin
        //attachments are parsed differently
        ParseAttachmentsString(i + 1, varStrList);
        FillArrayAndClear(varStrList, ATT_ARR);
      end;

      if SameStr(PARAM_SUBJECT, sParam) then
      begin
        subj := ParseLongString(i + 1, PARAM_SUBJECT);
      end;

      if SameStr(PARAM_BODY, sParam) then
      begin
        sbody := ParseLongString(i + 1, PARAM_BODY);
      end;

      if SameStr(PARAM_IS_RTF, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        sRTFFilePath := Trim(varStrList.Strings[0]);
        varStrList.Clear;
      end;

      if SameStr(PARAM_IS_OLE, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        TryStrToBool(GettingRidOfCommaAndTrim(varStrList.Strings[0]), isOLE);
        varStrList.Clear;
      end;

      if SameStr(PARAM_IS_MAPI, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        TryStrToBool(GettingRidOfCommaAndTrim(varStrList.Strings[0]), isMAPI);
        varStrList.Clear;
      end;


      if SameStr(PARAM_IS_HTML, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        sHtmlFilePath := Trim(varStrList.Strings[0]);
        varStrList.Clear;
      end;
    end;

    if isOle then
    begin
      EmailSenderOle := TOutlookOle.Create;
      try
        if (Length(toArray) > 0) and (subj <> '') then
        begin
          for i := 0 to Length(toArray) - 1  do
            EmailSenderOle.AddToRecipient(toArray[i]);

          for i := 0 to Length(ccArray) - 1  do
            EmailSenderOle.AddCCRecipient(ccArray[i]);

          for i := 0 to Length(bccArray) - 1  do
            EmailSenderOle.AddBCCRecipient(bccArray[i]);

          for i := 0 to Length(attArray) - 1  do
            EmailSenderOle.AddAttachment(attArray[i]);

          EmailSenderOle.EmailSubject := subj;
          EmailSenderOle.EmailBody := '';
          EmailSenderOle.RTFBodyFilePath := sRTFFilePath;
          EmailSenderOle.HtmlBodyFilePath := sHtmlFilePath;
          Result := EmailSenderOle.SendEmail;
        end;
      finally
        EmailSenderOle.Free;
      end;
    end;

    if isMAPI then
    begin
      EmailSender := TEmailSender64.Create;
      try
        if (Length(toArray) > 0) and (subj <> '') then
        begin
          for i := 0 to Length(toArray) - 1  do
            EmailSender.AddTO(toArray[i]);

          for i := 0 to Length(ccArray) - 1  do
            EmailSender.AddCC(ccArray[i]);

          for i := 0 to Length(bccArray) - 1  do
            EmailSender.AddBCC(bccArray[i]);

          for i := 0 to Length(attArray) - 1  do
            EmailSender.AddAttchment(attArray[i]);

          EmailSender.Subject := subj;
          EmailSender.Body := sbody;
          Result := EmailSender.SendEmail;
        end;
      finally
        EmailSenderOle.Free;
      end;
    end

    else
      WriteLn('parameters set incorrectly!!!!!');
      WriteLn;

  finally
    SetLength(toArray, 0);
    SetLength(ccArray, 0);
    SetLength(bccArray, 0);
    SetLength(attArray, 0);
    varStrList.Free;
  end;
end;

begin
  Application.Initialize;
  if ParamCount = 0 then
  begin
    WriteLn('No parameters found');
    WriteLn;
    Application.Terminate;
  end
  else
  begin
    try
      ExitCode := ParamsParsingSendEmail;
    finally
      Application.Terminate;
    end;
  end;
end.
