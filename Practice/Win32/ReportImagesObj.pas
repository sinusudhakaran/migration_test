//------------------------------------------------------------------------------
// ReportImagesObj
//
// Holds a database of images and image sizes that are accessed by the reports.
//
//------------------------------------------------------------------------------
unit ReportImagesObj;

interface

uses
  Classes,
  Graphics;

type
  TReportImageList = class(TObject)
  protected
    ImageList : TStringList;
    ImageWidth : TList;
    ImageHeight : TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetImage(Name : String; var ImgWidth, ImgHeight : Integer) : TPicture;
    procedure Add(Name : String; Image: TPicture; ImgWidth, ImgHeight : Integer);
    function HasName (Name: string): Boolean; 
  end;

var
  ReportImageList : TReportImageList;

implementation
uses
  sysutils;
{ TReportImageList }

//------------------------------------------------------------------------------
//
// Releases the memory taken by the images.
//
procedure TReportImageList.Clear;
var
  i : Integer;
begin
  for i := ImageList.Count-1 downto 0 do
    TPicture(ImageList.Objects[i]).Free;
  ImageList.Clear;
  ImageWidth.Clear;
  ImageHeight.Clear;
end;

//------------------------------------------------------------------------------
//
// Creates the objects to hold the images and image information.
//
constructor TReportImageList.Create;
begin
  ImageList := TStringList.Create;
  ImageWidth := TList.Create;
  ImageHeight := TList.Create;
end;

//------------------------------------------------------------------------------
//
// Destroys the objects that hold the images and image information.
//
destructor TReportImageList.Destroy;
var
  i : Integer;
begin
  ImageWidth.Free;
  ImageHeight.Free;
  for i := ImageList.Count-1 downto 0 do
    TPicture(ImageList.Objects[i]).Free;
  ImageList.Free;

  inherited;
end;

//------------------------------------------------------------------------------
//
// Searches for the image that matches the specified name and returns it as a TPicture.
//
function TReportImageList.GetImage(Name : String; var ImgWidth, ImgHeight : Integer) : TPicture;
var
  Index : Integer;
begin
  Index := ImageList.IndexOf(Name);
  if (Index <> -1) then
  begin
    Result := TPicture(ImageList.Objects[Index]);
    ImgWidth := Integer(ImageWidth[Index]);
    ImgHeight := Integer(ImageHeight[Index]);
  end else
    Result := nil;
end;

function TReportImageList.HasName(Name: string): Boolean;
begin
  Result := ImageList.IndexOf(uppercase(Name)) >= 0;
end;

//------------------------------------------------------------------------------
//
// Adds an image and image information to the database.
//
procedure TReportImageList.Add(Name : String; Image: TPicture; ImgWidth, ImgHeight : Integer);

begin
  ImageList.AddObject(uppercase(Name),Image);
  ImageWidth.Add(Pointer(ImgWidth));
  ImageHeight.Add(Pointer(ImgHeight));
end;

end.
