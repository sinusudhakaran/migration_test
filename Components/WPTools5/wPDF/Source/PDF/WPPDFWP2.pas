unit WPPDFWP2;
// ------------------------------------------------------------------
// wPDF PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 1, 2000 Copyright (C) by Julian Ziersch, Berlin
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.pdfcontrol.com
// ------------------------------------------------------------------
{$I wpdf_inc.inc}

interface

uses Windows, Messages, SysUtils, Classes,WPPDFWP, Forms, WPWinCTR,
WPDefs, WPrtfTXT, WPrtfIO, syncobjs, WPReadHT, WPEmobj;


type
  TWPToolsPDFExportFormat = (
     wpLoadFromFile,
     wpLoadFromString,
     wpLoadRTFFromString,
     wpLoadANSIFromString,
     wpLoadHTMLFromString,
     wpDontLoadAndClear );

TWPToolsPDFExport = class(TWPPDFExport)
private
  FWP : TWPCustomRtfEdit;
  FLock : TCriticalSection;
  FLockCount : Integer;
public
  constructor Create(aOwner : TComponent); override;
  destructor  Destroy; override;
  function    CreatePDFAsStream(const Source : String;
           Format : TWPToolsPDFExportFormat;  DoMailMerge : Boolean) : TMemoryStream;
protected
    property Filename;
    property Stream;
public
    property Source : TWPCustomRtfEdit read FWP;
    procedure LockThread;
    procedure UnlockThread;
published
    property OnBeforePrintPage;
    property OnAfterPrintPage;
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
    property MergeStart;
    property OnMergeText;
end;

procedure Register;

implementation

  procedure Register;
  begin
   RegisterComponents('wPDF',[TWPToolsPDFExport]);
  end;

  var ParentForm : TForm;

  constructor TWPToolsPDFExport.Create(aOwner : TComponent);
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
     FWP   := TWPCustomRtfEdit.CreateParented(ParentForm.Handle);
     FWP.InsertpointAttr.Hidden := TRUE;
     FWP.ScreenResMode          := rm1440;
     FWP.WYSIWYG                := TRUE;
     FWP.Visible                := TRUE;
     FWP.Refresh;
     FWP.Memo.PaintMode         := [];
     FWP.ViewOptions := [];
     inherited Source := FWP;
  end;

  procedure TWPToolsPDFExport.LockThread;
  begin
    inc(FLockCount);
    if FLockCount = 1 then
       FLock.Acquire;
  end;

  procedure TWPToolsPDFExport.UnlockThread;
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

  destructor  TWPToolsPDFExport.Destroy;
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

  function TWPToolsPDFExport.CreatePDFAsStream(
           const Source : String;
           Format : TWPToolsPDFExportFormat;
           DoMailMerge : Boolean) : TMemoryStream;
  var FIMM : Boolean;
      FOldTextLoad : String;
  begin
    Result := TMemoryStream.Create;
    try
    LockThread;
    FIMM := InMemoryMode;
    InMemoryMode := TRUE;
    try
    FOldTextLoad := FWP.TextLoadFormat;
    FWP.TextLoadFormat := 'AUTO';
    try
    FWP.BeginUpdate;
    case Format of
        wpLoadFromFile :
        begin FWP.Clear;
              FWP.Memo.LoadFromFile(Source);
        end;
        wpLoadFromString:
              FWP.AsString := Source;
        wpLoadRTFFromString :
        begin
          FWP.TextLoadFormat := 'RTF';
          FWP.AsString := Source;
        end;
        wpLoadANSIFromString :
        begin
          FWP.TextLoadFormat := 'ANSI';
          FWP.AsString := Source;
        end;
        wpLoadHTMLFromString :
        begin
          FWP.TextLoadFormat := 'HTML';
          FWP.AsString := Source;
        end;
        wpDontLoadAndClear :
        begin
        end;
     end;
     if DoMailMerge then FWP.FastMergeText;
     finally
       FWP.EndUpdate;
     end;
     Stream := Result;
     Print; 
   finally
     FWP.Clear;
     FWP.TextLoadFormat := FOldTextLoad;
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

finalization
  if ParentForm<>nil then
  begin
     ParentForm.Free;
     ParentForm := nil;
  end;


end.
