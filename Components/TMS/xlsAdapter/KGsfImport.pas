unit KGsfImport;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$A8}{$Z4}

interface
uses Libc, KGlibImport;
const
  libgsf = 'libgsf-1.so.1';
  libxml='libxml2.so.2';

type
  TGsfInput= pointer;
  TGsfOutput=pointer;
  TGsfInFile=pointer;
  TGsfOutFile=pointer;

  PGsfInput=^TGsfInput;
  PGsfOutput=^TGsfOutput;
  PGsfInFile=^TGsfInFile;
  PGsfOutFile=^TGsfOutFile;

  GSeekType=  (
    G_SEEK_CUR,
    G_SEEK_SET,
    G_SEEK_END
  );

  procedure xmlParserError;cdecl;external libxml; //this is not to be called... just to load the lib

type
  TXmlLoader=class //not to be called...
  protected
    procedure xmlParserError1;virtual;
  end;

  {$I libgsfHdr.inc}
implementation

{ TXmlLoader }

procedure TXmlLoader.xmlParserError1;
begin
  xmlParserError;
end;

end.
