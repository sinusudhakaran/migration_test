unit FaxParametersObj;

interface
uses
   ssRenderFax,
   Dialogs;

type
  TFaxParameters = class
  private
    FToName : string;
    FToFaxNumber : string;
    FDocumentName : string;
    FCoverPageFilename: string;
    FCoverPageSubject: string;
    FCoverPageText: string;
    FContact: string;
    FCompany: string;
  public
    class function NewFaxParameters( aName : string;
                                     aContact : string;
                                     aFaxNumber: string;
                                     aDocumentName : string;
                                     aCoverpageFilename : string;
                                     aCoverpageSubject : string;
                                     aCoverpageText : string;
                                     aCompany : string) : TFaxParameters;

    property ToName : string read FToName;
    property Contact : string read FContact;
    property Company : string read FCompany;
    property FaxNumber : string read FToFaxNumber;
    property DocumentName : string read FDocumentname;

    property CoverPageFilename : string read FCoverPageFilename;
    property CoverPageSubject : string read FCoverPageSubject;
    property CoverPageText : string read FCoverPageText;
    procedure AssignTo(FaxPrinter : TSSRenderFax);
  end;

function SetFaxOrientation(Name: string; o: TPrinterOrientation): Integer;

implementation

uses
  windows,
  printers,
  logutil,
  WinSpool;

const
  unitname = 'FaxParametersObj';
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Sets the GLOBAL orientation for the Fax printer.
// Note we cannot just set it locally (i.e. just for this app) because it doesnt
// take any notice of it!!
// Returns the current setting so we can switch back when we're finished.
function SetFaxOrientation(Name: string; o: TPrinterOrientation): Integer;
var
  HPrinter: THandle;
  BytesNeeded: Cardinal;
  PI2: PPrinterInfo2;
  PrinterDefaults: TPrinterDefaults;
begin
  Result := -1; // No change
  try
    with PrinterDefaults do
    begin
      DesiredAccess := PRINTER_ACCESS_USE;
      pDatatype := nil;
      pDevMode := nil;
    end;
    if OpenPrinter(PChar(Name), HPrinter, @PrinterDefaults) then
    try
      SetLastError(0);
      //Determine the number of bytes to allocate for the PRINTER_INFO_2 construct...
      if not GetPrinter(HPrinter, 2, nil, 0, @BytesNeeded) then
      begin
        //Allocate memory space for the PRINTER_INFO_2 pointer (PrinterInfo2)...
        PI2 := AllocMem(BytesNeeded);
        try
          // Get the global PI2 info
          if GetPrinter(HPrinter, 2, PI2, BytesNeeded, @BytesNeeded) then
          begin
            // Set the global orientation
            Result := PI2.pDevMode.dmOrientation;
            if o = poLandscape then
              PI2.pDevMode.dmOrientation := DMORIENT_LANDSCAPE
            else
              PI2.pDevMode.dmOrientation := DMORIENT_PORTRAIT;
            if DocumentProperties(0, hPrinter, PChar(Name),
                   PI2.pDevMode^, PI2.pDevMode^, DM_IN_BUFFER or DM_OUT_BUFFER) = IDOK then
              SetPrinter(HPrinter, 2, PI2, 0);
          end;
        finally
          FreeMem(PI2, BytesNeeded);
        end;
      end;
    finally
      ClosePrinter(HPrinter);

    end;
  except
    LogUtil.LogMsg( lminfo, unitname, 'failed to set orientation for fax');
  end;
{
  This would set it for the local app only, but it gets ignored!
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;
begin
  FPrinter.GetTPrinter.GetPrinter(device, driver, port, hDevMode);
  if hDevMode <> 0 then
  begin
    // Lock the memory
    MyDevMode := GlobalLock(hDevMode);
    try
      if o = poLandscape then
        MyDevMode^.dmOrientation := DMORIENT_LANDSCAPE
      else
        MyDevMode^.dmOrientation := DMORIENT_PORTRAIT;
        MyDevMode^.dmFields := MyDevMode^.dmFields or dm_Orientation;
    finally
//      FPrinter.GetTPrinter.SetPrinter(device, driver, port, hDevMode);
      ResetDC(Printer.Handle, MyDevMode^);
      GlobalUnlock(hDevMode);
    end;
  end;}
end;

{ TFaxParameters }

procedure TFaxParameters.AssignTo(FaxPrinter : TSSRenderFax);
begin
   FaxPrinter.RecipientInfo.Name := ToName;
   FaxPrinter.RecipientInfo.FaxNumber := FaxNumber;
   FaxPrinter.DocumentName := DocumentName;

   if CoverPageFilename <> '' then begin
      FaxPrinter.CoverPageType := cptLocal;
      FaxPrinter.CoverPageInfo.CoverPageName := CoverPageFilename;
      FaxPrinter.CoverPageInfo.RecCompany := ToName;
      if Contact <> '' then
         FaxPrinter.CoverPageInfo.RecName := Contact
      else
         FaxPrinter.CoverPageInfo.RecName := ToName;
      FaxPrinter.CoverPageInfo.SdrCompany := Company;
      FaxPrinter.CoverPageInfo.SdrName := Company;
      FaxPrinter.CoverPageInfo.RecFaxNumber := FaxNumber;
      FaxPrinter.CoverPageInfo.Subject := CoverPageSubject;
      FaxPrinter.CoverPageInfo.Note := CoverPageText;
   end;
end;

class function TFaxParameters.NewFaxParameters( aName,
                                                aContact,
                                                aFaxNumber,
                                                aDocumentName,
                                                aCoverpageFilename,
                                                aCoverpageSubject,
                                                aCoverpageText,
                                                aCompany : string): TFaxParameters;
var
  o : TFaxParameters;
begin
  o := TFaxParameters.Create;

  o.FToFaxNumber := aFaxNumber;
  o.FToName := aName;
  o.FContact := aContact;
  o.FCompany := aCompany;
  o.FDocumentName := aDocumentName;

  o.FCoverPageFilename := aCoverpageFilename;
  o.FCoverPageSubject := aCoverpageSubject;
  o.FCoverPageText := aCoverpageText;

  result := o;
end;




(* mjch this is a record approach, I decided to use the parameter object
        approach because the fax parameters are optional and it seemed to be
        better to pass nil instead of creating a blank structure *)


//type
//  TFaxParameters = record
//    ToName : string;
//    FaxNumber : string;
//    DocumentName : string;
//  end;
//
//  function NewFaxParameters( aName : string;
//                             aFaxNumber: string;
//                             aDocumentName : string) : TFaxParameters;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//function NewFaxParameters( aName : string;
//                           aFaxNumber: string;
//                           aDocumentName : string) : TFaxParameters;
//var
//  r : TFaxParameters;
//begin
//  Fillchar( r, SizeOf(r), #0);
//
//  r.FaxNumber := aFaxNumber;
//  r.ToName := aName;
//  r.DocumentName := aDocumentName;
//  result := r;
//end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(*

     mjch - This is an example of a parameter object, it has the advantage
            that it can be passed through routines that don't need to know
            about it as a tobject, also the parameters are always read only
            once set.

            Disadvantage is that delphi doesn't do garbage collection so you
            need to have a try finally around the calling routine.

            fp := TFaxParameters.NewFaxParameters( 'matt', 123, 'doc');
            try
              ARoutine( fp) ;
            finally
              fp.Free;
            end;


type
  TFaxParameters = class
  private
    FToName : string;
    FToFaxNumber : string;
    FDocumentName : string;
  public
    class function NewFaxParameters( aName : string;
                                     aFaxNumber: string;
                                     aDocumentName : string) : TFaxParameters;

    property ToName : string read FToName;
    property FaxNumber : string read FToFaxNumber;
    property DocumentName : string read FDocumentname;
  end;

implementation

{ TFaxParameters }

class function TFaxParameters.NewFaxParameters( aName, aFaxNumber,
  aDocumentName: string): TFaxParameters;
var
  o : TFaxParameters;
begin
  o := TFaxParameters.Create;

  o.FToFaxNumber := aFaxNumber;
  o.FToName := aName;
  o.FDocumentName := aDocumentName;

  result := o;
end;
*)

end.
 