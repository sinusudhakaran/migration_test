unit fcopy;

interface uses Classes, SysUtils;

Type
   EFCopyFailed = class(Exception);

   TFCopyProgressCallbackProc = procedure( BytesCopied : Int64; TotalSize : Int64);

procedure CopyFile(const FileName, DestName: string; ProgressProc : TFCopyProgressCallbackProc = nil);

//******************************************************************************
implementation
uses
  WinUtils, Windows;

const
  SFCreateError = 'Cannot create file %s';
  SFOpenError = 'Cannot open file %s';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CopyFile(const FileName, DestName: string; ProgressProc : TFCopyProgressCallbackProc = nil);
var
  CopyBuffer    : Pointer; { buffer for copying }
  BytesCopied   : Longint;
  BytesWritten  : Longint;
  Source, Dest  : Integer; { handles }
  TotalCopied   : Int64;
  TotalSize     : Int64;
  Destination   : TFileName; { holder for expanded destination name }
const
  ChunkSize: Longint = 8192; { copy in 8K chunks }
begin
   Destination := ExpandFileName(DestName); { expand the destination path }
   TotalCopied := 0;
   TotalSize := 0;

   //only need to get the size if we are going to do something with it
   if Assigned( ProgressProc) then
     TotalSize := WinUtils.GetFileSize( Filename);

   GetMem(CopyBuffer, ChunkSize); { allocate the buffer }

   try
      Source := FileOpen(FileName, fmShareDenyWrite); { open source file }
      if Source < 0 then raise EFCopyFailed.CreateFmt(SFOpenError, [FileName]);
      try
         Dest := SysUtils.FileCreate(Destination); { create output file; overwrite existing }
         if Dest < 0 then raise EFCopyFailed.CreateFmt(SFCreateError, [Destination]);
         try
            repeat
               BytesCopied := FileRead(Source, CopyBuffer^, ChunkSize); { read chunk }
               if BytesCopied > 0 then begin { if we read anything... }
                  BytesWritten := FileWrite(Dest, CopyBuffer^, BytesCopied); { ...write chunk }
                  if not ( BytesWritten = BytesCopied ) then
                     raise EFCopyFailed.CreateFmt('Unable to Write to file %s', [Destination]);

                  TotalCopied := TotalCopied + BytesCopied;
                  if Assigned( ProgressProc) then
                    ProgressProc( TotalCopied, TotalSize);
                end;
            until BytesCopied < ChunkSize; { until we run out of chunks }
         finally
            SysUtils.FileClose(Dest); { close the destination file }
         end;
      finally
         SysUtils.FileClose(Source); { close the source file }
      end;
   finally
      FreeMem(CopyBuffer, ChunkSize ); { free the buffer }
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
