unit ProcTypes;

interface
uses Sysutils;

type
   OutputFileProc = procedure (FileType: Integer; Data: PChar); stdcall;
   OutputStatusProc = procedure (Status: Integer; StatusText: PChar); stdcall;




implementation

end.
