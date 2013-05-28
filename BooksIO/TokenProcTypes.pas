unit TokenProcTypes;

interface

uses
Sysutils;


type
   OutputFileProc = procedure (DataType: integer; aByteArray: PByteArray; size: integer); stdcall;
   OutputStatusProc = procedure (Status: Integer; StatusText: PChar); stdcall;


implementation

end.
