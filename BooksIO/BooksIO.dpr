library BooksIO;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  SysUtils,
  Classes,
  ImportExport in 'ImportExport.pas',
  ProcTypes in 'ProcTypes.pas',
  WebUtils in '..\Practice\WebNotes\WebUtils.pas',
  Listhelpers in 'Listhelpers.pas',
  BK_XMLHelper in '..\Common\Database\BK_XMLHelper.PAS';

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

             SetErrorProc,
             ImportBooksFile,
             ExportBooksFile;

      begin


{$ENDIF}
     end.
