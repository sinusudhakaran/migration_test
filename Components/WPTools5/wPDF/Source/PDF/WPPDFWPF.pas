unit WPPDFWPF;
// ------------------------------------------------------------------
// wPDF PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 1, 2002 Copyright (C) by wpcubed GmbH
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.pdfcontrol.com
// ------------------------------------------------------------------
{$I wpdf_inc.inc}

interface

uses Windows, Messages, SysUtils, Classes, Forms, syncobjs, WPFrm
{$IFDEF WPDF_SOURCE} ,WPPDFR1_src {$ELSE} ,WPPDFR1 {$ENDIF} WPPDFr2;


type

TWPFormPDFExport = class(TWPPDFPrinter)
private
  FWP : TWPFormEditor;
  FLock : TCriticalSection;
  FLockCount : Integer;
public
  constructor Create(aOwner : TComponent); override;
  destructor  Destroy; override;
  function    CreatePDFAsStream(const FileName : String;
                  DoMailMerge : Boolean) : TMemoryStream;
protected
    property Filename;
    property Stream;
public
    property Source : TWPFormEditor read FWP;
    procedure LockThread;
    procedure UnlockThread;
published
    property EncodeStreamMethod;
    property CompressStreamMethod;
    property ConvertJPEGData;
    property Info;
    property CreateThumbnails;
    property CreateOutlines;
    property ExcludedFonts;
    property BeforeBeginDoc;
    property PageMode;
    property FontMode;
    property Encryption;
    property UserPassword;
    property OwnerPassword;
    property InMemoryMode;
    property FastCompress;
    property ExtraMessages;
    property HeaderFooterColor;
    property InputfileMode;
    property InputFile;
    property OnUpdateGauge;
    property OnError;
end;

procedure Register;

implementation

  procedure Register;
  begin
   RegisterComponents('wPDF',[TWPFormPDFExport]);
  end;

  var ParentForm : TForm;

  constructor TWPFormPDFExport.Create(aOwner : TComponent);
  begin
     inherited Create(aOwner);
     FLock := TCriticalSection.Create;
     FLockCount := 0;
     if ParentForm=nil then
     begin
          ParentForm := TForm.Create(nil);
          ParentForm.Tag := 1;  // Reference Counter
     end
     else ParentForm.Tag := ParentForm.Tag + 1;
     GraphicDriverMode := [wpLazyTextOutAPI];

     FWP   := TWPFormEditor.CreateParented(ParentForm.Handle);
  end;

  procedure TWPFormPDFExport.LockThread;
  begin
    inc(FLockCount);
    if FLockCount = 1 then
       FLock.Acquire;
  end;

  procedure TWPFormPDFExport.UnlockThread;
  begin
    dec(FLockCount);
    if FLockCount = 0 then
       FLock.Release
    else if FLockCount<0 then
    begin
       FLockCount := 0;
       raise Exception.Create('Too many "UnlockThread"!'); 
    end;
  end;

  destructor  TWPFormPDFExport.Destroy;
  begin
    if ParentForm<>nil then
    begin
       ParentForm.Tag := ParentForm.Tag-1;
       if ParentForm.Tag<=0 then
       begin
          ParentForm.Free;
          ParentForm := nil;
       end;
    end;
    FLock.Free;
    FWP.Free;
    inherited Destroy;
  end;

  function TWPFormPDFExport.CreatePDFAsStream(
           const FileName : String;
           DoMailMerge : Boolean) : TMemoryStream;
  var FIMM : Boolean;  i : Integer;
  begin
    Result := TMemoryStream.Create;
    try
    LockThread;
    FIMM := InMemoryMode;
    InMemoryMode := TRUE;
    try
    try
      FWP.BeginUpdate;
      FWP.Clear;
      FWP.LoadFromFile(FileName);
      if DoMailMerge then FWP.RefreshData(true);
    finally
       FWP.EndUpdate;
    end;
    Stream := Result;

    BeginDoc;
    try
      with FWP do
      for i := 1 to PageCount do
      begin
        StartPage(
          MulDiv(PageSize(i).PageWidthTW,72,1440),
          MulDiv(PageSize(i).PageHeightTW,72,1440), 72,72, 0);
        PrintPageOnCanvas(Canvas, i, 0, 0);
        EndPage;
      end;
   finally
      EndDoc;
   end;

   finally
    FWP.Clear;
    InMemoryMode := FIMM;
    Stream := nil;
    UnLockThread;
   end;
  except
    on e : Exception do
    begin
       Result.Clear;
       Result.Write(PChar(e.Message)^, Length(e.Message));
    end;
  end;
end;

initialization
  ParentForm := nil;
  WPFDontUsePrinter := TRUE;  // requires WPForm V2.06

finalization
  if ParentForm<>nil then
  begin
     ParentForm.Free;
     ParentForm := nil;
  end;


end.
