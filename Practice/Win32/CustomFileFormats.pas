unit CustomFileFormats;

interface

uses
  Windows,
  SysUtils,
  Classes;

type
  //----------------------------------------------------------------------------
  TCustomFormatCode = procedure(aFileName : string) of object;

  //----------------------------------------------------------------------------
  TCustomFileFormat = class(TCollectionItem)
  private
    fName : string;
    fDescription : string;
    fFilename : string;
    fExtension : string;
    fSelected : boolean;
    fCustomFormatCode : TCustomFormatCode;
  public
    procedure DoCustomFormatCode(aFileName : string);

    property Name : string read fName write fName;
    property Description : string read fDescription write fDescription;
    property Filename : string read fFilename write fFilename;
    property Extension : string read fExtension write fExtension;
    property Selected : boolean read fSelected write fSelected;
    property CustomFormatCode : TCustomFormatCode read fCustomFormatCode write fCustomFormatCode;
  end;

  //----------------------------------------------------------------------------
  TCustomFileFormats = class(TCollection)
  private
  public
    destructor Destroy; override;

    procedure AddCustomFormat(aName : string; aDescription : string; aFileName : string; aExtension : string; aCustomFormatCode : TCustomFormatCode; aSelected : boolean);
  end;

implementation

{ TCustomFileFormats }
//------------------------------------------------------------------------------
procedure TCustomFileFormat.DoCustomFormatCode(aFileName : string);
begin
  if Assigned(fCustomFormatCode) then
    fCustomFormatCode(aFileName);
end;

{ TCustomFileFormats }
//------------------------------------------------------------------------------
procedure TCustomFileFormats.AddCustomFormat(aName, aDescription, aFileName, aExtension : string; aCustomFormatCode: TCustomFormatCode; aSelected : Boolean);
var
  NewCustomFormat : TCustomFileFormat;
begin
  NewCustomFormat := TCustomFileFormat.Create(Self);
  NewCustomFormat.Name             := aName;
  NewCustomFormat.Description      := aDescription;
  NewCustomFormat.FileName         := aFileName;
  NewCustomFormat.Extension        := aExtension;
  NewCustomFormat.Selected         := aSelected;
  NewCustomFormat.CustomFormatCode := aCustomFormatCode;
end;

//------------------------------------------------------------------------------
destructor TCustomFileFormats.Destroy;
begin

  inherited;
end;

end.
