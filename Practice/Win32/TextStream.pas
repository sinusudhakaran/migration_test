unit TextStream;

interface
uses
  Classes, Sysutils;

type
 TTextfileStream = class(TFileStream)
 private
   CurrLine : string;
 public
   procedure   WriteLn(Output : string);
   procedure   WriteAdd(AddString : string);
   constructor Create(const FileName: string; Mode: Word);
 end;

implementation

{ TTextfileStream }

constructor TTextfileStream.Create(const FileName: string; Mode: Word);
begin
   inherited Create(FileName,Mode);
   CurrLine := '';
end;

procedure TTextfileStream.WriteAdd(AddString: string);
begin
  CurrLine := CurrLine + AddString;
end;

procedure TTextfileStream.WriteLn(Output: string);
begin
  Output := CurrLine + Output + #13#10;
  Write(PChar(Output)^,Length(Output));

  CurrLine := '';
end;

end.
