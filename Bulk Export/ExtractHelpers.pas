unit ExtractHelpers;

///------------------------------------------------------------------------------
///  Title:   Bulk Export Helper bits
///
///  Written: June 2009
///
///  Authors: Andre' Joosten
///
///  Purpose: Just some simple common helpers, to use in the extral dlls
///
///  Notes:  Mainly around the handling of the comma seperated fields
///          And some file handling
///
///
///------------------------------------------------------------------------------


interface

uses
   SysUtils,
   Classes,
   Controls,
   Windows;

type

  TExtractFieldHelper = class(TObject)
  private
     FFields: TStringlist;
  public
     constructor Create;
     destructor Destroy; override;
     procedure SetFields(const Value: Pchar); overload;
     procedure SetFields(const Value: string); overload;

     function GetField(const Value: string): string; overload;
     function GetField(const Value, Default: string): string; overload;

     function GetMoney(const Value: string): currency;

     // Some extra helpers
     function ReplaceQuotesAndCommas(Value: string): string;
     function ForceQuotes(const Value: string): string;
     function RemoveQuotes(const Value: string): string;
  end;

function MakeFilePath(const Path, Filename: string):string;
function ValidFilePath(AFileName: string): boolean;
function FilenameNoExt(AFilename: string): string;

implementation

{ ExtractFieldHelper }

function TExtractFieldHelper.ForceQuotes(const Value: string): string;
begin
   if Value > '' then begin
      // Check
      if Value[1] = '"' then
         Result := Value
      else
         Result := '"' + Value + '"'
   end else
      Result := '""'; // empty
end;

constructor TExtractFieldHelper.Create;
begin
   inherited Create;
   FFields := TStringlist.Create;
   FFields.Delimiter := ',';
   FFields.StrictDelimiter := True;
end;

destructor TExtractFieldHelper.Destroy;
begin
   FFields.Free;
   inherited;
end;


function TExtractFieldHelper.GetField(const Value, Default: string): string;
begin
    Result := FFields.Values[value];
    if (Result = '')
   and (Default > '') then
      Result := Default

end;

function TExtractFieldHelper.GetMoney(const Value: string): currency;
var s: string;
begin
   s := GetField(Value,'0.0');
   Result := StrToCurr(S);
end;

function TExtractFieldHelper.RemoveQuotes(const Value: string): string;
begin
   if length(Value) > 1 then begin
      if Value[1] = '"' then
         Result := Copy(Value,2,length(Value)-2)
      else
         Result := Value;
   end else
      Result := Value;
end;

function TExtractFieldHelper.ReplaceQuotesAndCommas(Value: string): string;
//replaces double quotes with space and commas with fullstop
var
  i : integer;
begin
   for i := 1 to length( Value) do begin
      if (Value[i] = '"') then
         Value[i] := ' '
      else if ( Value[i] = ',') then
         Value[i] := '.';
   end;
   Result := Value;
end;

function TExtractFieldHelper.GetField(const Value: string): string;
begin
   Result := FFields.Values[value];
end;

procedure TExtractFieldHelper.SetFields(const Value: Pchar);
begin
   SetFields(string(Value));
end;

procedure TExtractFieldHelper.SetFields(const Value: string);
begin
   FFields.Clear;
   FFields.DelimitedText := Value;
end;

function MakeFilePath(const Path, Filename: string):string;
begin
   // Make sur the directory exsists
   ForceDirectories(ExcludeTrailingBackslash(ExtractFilePath(Path)));
   if Pos('.',Path) > 0 then
      // is already a full path..
      Result := Path
   else
      // Add The path name
      Result := ExtractFilePath(Path) + FileName;
end;

function ValidFilePath(AFileName: string): boolean;
var
  Path, Msg: string;
begin
  Result := True;
  if AFilename <> '' then begin
    Path := ExtractFilePath(AFilename);
    if (Path <> '') then begin
      if (not DirectoryExists(Path)) then begin
        Msg := Format('The following directory does not exist. Do you want to create it?%s%s%s',
                      [#10, #10, ExtractFilePath(AFilename)]);
        if MessageBox(0, PChar(Msg), 'Create Directory', MB_ICONQUESTION or MB_YESNO) = mrYes then begin
          ForceDirectories(Path);
          if DirectoryExists(Path) then
            MessageBox(0 ,'Directory Created','New data extract directory created OK.', mb_ok )
          else begin
            Msg := 'New directory create failed with error : ' + IntToStr(GetLastError);
            MessageBox(0 ,'Directory Error', PChar(Msg), mb_ok );
            Result := False;  //Couldn't create folder
          end;
        end else
          Result := False; //User didn't want to create folder
      end;
    end else
      Result := False; //Path is blank
  end else
    Result := False; //Filename is blank
end;

function FilenameNoExt(AFilename: string): string;
begin
  Result := ChangeFileExt(ExtractFilename(AFilename), '');
end;


end.
