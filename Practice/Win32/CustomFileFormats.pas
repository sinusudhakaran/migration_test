unit CustomFileFormats;

interface

uses
  Windows,
  SysUtils,
  Classes;

type
  //----------------------------------------------------------------------------
  TCustomFormatCode = procedure(aFileName : string) of object;
  TCustomFormatValidation = procedure(var aResult : Boolean; var aMsg : string)  of object;

  //----------------------------------------------------------------------------
  TCustomFileFormat = class(TCollectionItem)
  private
    fName : string;
    fDescription : string;
    fFilename : string;
    fExtension : string;
    fSelected : boolean;
    fCustomFormatCode : TCustomFormatCode;
    fCustomFormatValidation : TCustomFormatValidation;
  public
    procedure DoCustomFormatCode(aFileName : string);
    procedure DoCustomFormatValidation(var aResult : Boolean; var aMsg : string);

    property Name : string read fName write fName;
    property Description : string read fDescription write fDescription;
    property Filename : string read fFilename write fFilename;
    property Extension : string read fExtension write fExtension;
    property Selected : boolean read fSelected write fSelected;
    property CustomFormatCode : TCustomFormatCode read fCustomFormatCode write fCustomFormatCode;
    property CustomFormatValidation : TCustomFormatValidation read fCustomFormatValidation write fCustomFormatValidation;
  end;

  //----------------------------------------------------------------------------
  TCustomFileFormats = class(TCollection)
  private
  public
    destructor Destroy; override;

    procedure AddCustomFormat(aName : string;
                              aDescription : string;
                              aFileName : string;
                              aExtension : string;
                              aCustomFormatCode : TCustomFormatCode;
                              aCustomFormatValidation : TCustomFormatValidation;
                              aSelected : boolean);
  end;

implementation

{ TCustomFileFormats }
//------------------------------------------------------------------------------
procedure TCustomFileFormat.DoCustomFormatCode(aFileName : string);
begin
  if Assigned(fCustomFormatCode) then
    fCustomFormatCode(aFileName);
end;

//------------------------------------------------------------------------------
procedure TCustomFileFormat.DoCustomFormatValidation(var aResult : Boolean; var aMsg : string);
begin
  if Assigned(fCustomFormatValidation) then
    fCustomFormatValidation(aResult, aMsg);
end;

{ TCustomFileFormats }
//------------------------------------------------------------------------------
procedure TCustomFileFormats.AddCustomFormat(aName,
                                             aDescription,
                                             aFileName,
                                             aExtension : string;
                                             aCustomFormatCode: TCustomFormatCode;
                                             aCustomFormatValidation : TCustomFormatValidation;
                                             aSelected : Boolean);
var
  NewCustomFormat : TCustomFileFormat;
begin
  NewCustomFormat := TCustomFileFormat.Create(Self);
  NewCustomFormat.Name                   := aName;
  NewCustomFormat.Description            := aDescription;
  NewCustomFormat.FileName               := aFileName;
  NewCustomFormat.Extension              := aExtension;
  NewCustomFormat.CustomFormatCode       := aCustomFormatCode;
  NewCustomFormat.CustomFormatValidation := aCustomFormatValidation;
  NewCustomFormat.Selected               := aSelected;
end;

//------------------------------------------------------------------------------
destructor TCustomFileFormats.Destroy;
begin

  inherited;
end;

end.
