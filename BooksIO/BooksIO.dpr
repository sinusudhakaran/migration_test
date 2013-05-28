library BooksIO;
{$DEFINE DLLONLY}   // Does not work here, make sure its set in the project options; stops the HMutex (oneinst)
{

         FastMM4 must be the first unit (to make it the Memory Mannager)
         Please rememeber that a Dll shares the Heap (and stack) with the hosting app.
         So if the host is not a Delphi app, we have to play nice.
         FastMM is much better at  that...

}

uses
  FastMM4,
  SysUtils,
  Classes,
  ImportExport in 'ImportExport.pas',
  ProcTypes in 'ProcTypes.pas',

  Listhelpers in 'Listhelpers.pas',

  logger in 'logger.pas';

{$R *.res}


{$IFDEF DEBUG}
       procedure OutputFileProc(Filename: pChar; Data: PChar)stdcall;
       var output : text;
       begin
          Assign(outPut,'output.xml');
          rewrite(outPut);
          write(output,Data);
          close(outPut);
       end;


       var data: pchar;
           ms: TFileStream;
       begin
          SetOutputFileProc(OutputFileProc);
          ms:= TFileStream.Create('cain.bk5', fmOpenRead);
          // Make the Data
          ImportBooksFile('cain',PChar(ImportExport.EnCodetext(ms)));
          ms.Free;

{$ELSE }
      
      exports

             SetOutputFileProc,

             SetStatusProc,
             ImportBooksFile,
             ExportBooksFile;

      begin


{$ENDIF}
     end.
