unit Proctypes;

interface
uses Sysutils;

type
   OutputFile = procedure (FileType: Integer; Filename: pChar; Data: PChar); stdcall;
   OutputError = procedure (Error: Integer; ErrorText: pChar); stdcall;

implementation

end.
