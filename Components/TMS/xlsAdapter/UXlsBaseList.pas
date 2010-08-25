unit UXlsBaseList;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses Classes, Contnrs;
type

  TBaseList = class (TObjectList)
  end;

implementation

end.
