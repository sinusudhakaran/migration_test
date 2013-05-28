library BooksTokenIO;


uses
  //  fastMM4 must be the first one, for managed code compatibility
  fastMM4,
  SysUtils,
  Classes,
  TokenImportExport in 'TokenImportExport.pas',
  TokenProcTypes in 'TokenProcTypes.pas',
  Logger in 'Logger.pas';

{$R *.res}

exports

   SetOutputFileProc,
   SetStatusProc,
   ImportBooksFile,
   ExportBooksFile;

begin
end.
