program mapi64bit;

{$APPTYPE CONSOLE}

uses
  System.StartUpCopy,
  FMX.Forms,
  System.Sysutils,
  System.Classes,
  EmailSender64 in 'EmailSender64.pas';

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

type
  TArrayType = (TO_ARR = 1, CC_ARR = 2, BCC_ARR = 3, ATT_ARR = 4);

function ParamsParsingSendEmail(varEmailSender : TEmailSender64) : integer;
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
  isRTF : boolean;
  isHTML : boolean;
  sParam : string;
  varStrList : TStringList;

  procedure FillArrayAndClear(aDelimitedTxt : TStrings; aArrType : TArrayType);
  var
    i : integer;
  begin
    case aArrType of
      TO_ARR :
        begin
          SetLength(toArray, aDelimitedTxt.Count);
          for i := 0 to aDelimitedTxt.Count - 1 do
            toArray[i] := Trim(aDelimitedTxt.Strings[i]);
        end;
      CC_ARR :
        begin
          SetLength(ccArray, aDelimitedTxt.Count);
          for i := 0 to aDelimitedTxt.Count - 1 do
            ccArray[i] := Trim(aDelimitedTxt.Strings[i]);
        end;
      BCC_ARR :
        begin
          SetLength(bccArray, aDelimitedTxt.Count);
          for i := 0 to aDelimitedTxt.Count - 1 do
            bccArray[i] := Trim(aDelimitedTxt.Strings[i]);
        end;
      ATT_ARR :
        begin
          SetLength(attArray, aDelimitedTxt.Count);
          for i := 0 to aDelimitedTxt.Count - 1 do
            attArray[i] := Trim(aDelimitedTxt.Strings[i]);
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
         not SameStr(ParamStr(i), PARAM_BODY) then
      Result := Result + space + ParamStr(i) else
     exit;
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
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
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
        TryStrToBool(Trim(varStrList.Strings[0]), isRTF);
        varStrList.Clear;
      end;

      if SameStr(PARAM_IS_HTML, sParam) then
      begin
        sParam := ParamStr(i + 1);
        varStrList.DelimitedText := sParam;
        TryStrToBool(Trim(varStrList.Strings[0]), isHTML);
        varStrList.Clear;
      end;
    end;

    if (Length(toArray) > 0) and (subj <> '') then
    begin
      for i := 0 to Length(toArray) - 1  do
        varEmailSender.AddTO(toArray[i]);

      for i := 0 to Length(ccArray) - 1  do
        varEmailSender.AddCC(ccArray[i]);

      for i := 0 to Length(bccArray) - 1  do
        varEmailSender.AddBCC(bccArray[i]);

      for i := 0 to Length(attArray) - 1  do
        varEmailSender.AddAttchment(attArray[i]);

      varEmailSender.Subject := subj;
      varEmailSender.Body := sbody;
      varEmailSender.IsRTF := isRTF;
      varEmailSender.IsHTML := isHTML;
      Result := varEmailSender.SendEmail;
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

var
  EmailSender : TEmailSender64;
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
    EmailSender := TEmailSender64.Create;
    try
      ExitCode := ParamsParsingSendEmail(EmailSender);
    finally
      EmailSender.Free;
      Application.Terminate;
    end;
  end;
end.
