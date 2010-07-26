{******************************************************************************}
{                                                                              }
{                             GmLabelPrinter.pas                               }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmLabelPrinter;

interface

uses Windows, Classes, Graphics, GmPreview, SysUtils, Forms, GmTypes,
  GmCanvas, GmClasses, GmResource;

type
  {$I GMPS.INC}

  // events...
  TGmDrawLabelEvent       = procedure(Sender: TObject; LabelNum: integer; ARect: TGmValueRect; ACanvas: TGmCanvas) of object;
  TGmGetLabelHeightEvent  = procedure(Sender: TObject; LabelNum, Col, Row: integer; var Height, VertSpacing: TGmValue) of object;

  // *** Custom Types ***

  TGmLabelShape     = (gmLabelRect, gmLabelRoundRect, gmLabelEllipse);
  TGmLabelDrawOrder = (gmRows, gmColumns);
  TGmLabelTemplate  = (Custom_Template,
                       L7159_Address,
                       L7160_Address,
                       L7161_Address,
                       L7162_Address,
                       L7163_Address,
                       L7164_Address,
                       L7165_Parcel,
                       L7166_Parcel,
                       L7167_Shipping,
                       L7168_Shipping,
                       L7169_Parcel,
                       L7170_Eurofolio,
                       L7171_LeverArch,
                       L7172_RingBinder,
                       L7173_Shipping,
                       L7263_Address,
                       J8660_Diskette,
                       Avery_5160_Address,
                       Avery_8160_Address,
                       Herma_4209);

  // *** TGmLabelTemplateInfo ***

  TGmLabelTemplateInfo = class(TPersistent)
  private
    FTemplateID: TGmLabelTemplate;
    FTemplateName: string;
    FNumHorz: integer;
    FNumVert: integer;
    FLabelHeightInch: Extended;
    FLabelWidthInch: Extended;
    FLabelSpacingHorzInch: Extended;
    FLabelSpacingVertInch: Extended;
    FLabelShape: TGmLabelShape;
    FCornerRadiusInch: Extended;
    FOffsetXInch: Extended;
    FOffsetYInch: Extended;
    FPageExtent: TGmSize;
    FPaperSize: TGmPaperSize;
    FOrientation: TGmOrientation;
    function GetCornerRadius(Measurement: TGmMeasurement): Extended;
    function GetLabelHeight(Measurement: TGmMeasurement): Extended;
    function GetLabelSpacingHorz(Measurement: TGmMeasurement): Extended;
    function GetLabelWidth(Measurement: TGmMeasurement): Extended;
    function GetOffsetX(Measurement: TGmMeasurement): Extended;
    function GetOffsetY(Measurement: TGmMeasurement): Extended;
    function GetPageExtent(Measurement: TGmMeasurement): TGmSize;
    function GetSpacingVert(Measurement: TGmMeasurement): Extended;
    procedure SetCornerRadius(Measurement: TGmMeasurement; Value: Extended);
    procedure SetLabelHeight(Measurement: TGmMeasurement; Value: Extended);
    procedure SetLabelWidth(Measurement: TGmMeasurement; Value: Extended);
    procedure SetLabelSpacingHorz(Measurement: TGmMeasurement; Value: Extended);
    procedure SetLabelSpacingVert(Measurement: TGmMeasurement; Value: Extended);
    procedure SetNumLabelsHorz(Value: integer);
    procedure SetNumLabelsVert(Value: integer);
    procedure SetOffsetX(Measurement: TGmMeasurement; Value: Extended);
    procedure SetOffsetY(Measurement: TGmMeasurement; Value: Extended);
    procedure SetPageExtent(Measurement: TGmMeasurement; Value: TGmSize);
    procedure SetPaperSize(Value: TGmPaperSize);
    procedure SetTemplateName(Value: string);
  public
    constructor Create;
    property CornerRadius[Measurement: TGmMeasurement]: Extended read GetCornerRadius write SetCornerRadius;
    property TemplateID: TGmLabelTemplate read FTemplateID;
    property TemplateName: string read FTemplateName write SetTemplateName;
    property NumLabelsHorz: integer read FNumHorz write SetNumLabelsHorz;
    property NumLabelsVert: integer read FNumVert write SetNumLabelsVert;
    property LabelHeight[Measurement: TGmMeasurement]: Extended read GetLabelHeight write SetLabelHeight;
    property LabelWidth[Measurement: TGmMeasurement]: Extended read GetLabelWidth write SetLabelWidth;
    property LabelSpacingHorz[Measurement: TGmMeasurement]: Extended read GetLabelSpacingHorz write SetLabelSpacingHorz;
    property LabelSpacingVert[Measurement: TGmMeasurement]: Extended read GetSpacingVert write SetLabelSpacingVert;
    property LabelShape: TGmLabelShape read FLabelShape write FLabelShape;
    property OffsetX[Measurement: TGmMeasurement]: Extended read GetOffsetX write SetOffsetX;
    property OffsetY[Measurement: TGmMeasurement]: Extended read GetOffsetY write SetOffsetY;
    property PageExtent[Measurement: TGmMeasurement]: TGmSize read GetPageExtent write SetPageExtent;
    property PaperSize: TGmPaperSize read FPaperSize write SetPaperSize;
    property Orientation: TGmOrientation read FOrientation write FOrientation;
  end;

  //----------------------------------------------------------------------------

  // *** TGmLabelTemplateList ***

  TGmLabelTemplateList = class(TGmObjectList)
  private
    FDestroying: Boolean;
    function GetTemplate(index: integer): TGmLabelTemplateInfo;
    function GetTemplateFromName(ATemplateName: string): TGmLabelTemplateInfo;
    function GetTemplateIndex(ATemplate: TGmLabelTemplateInfo): integer;
    function AddTemplate(ATemplate: TGmLabelTemplate;
                         AName: string;
                         NumHorz,
                         NumVert: integer;
                         LabelWidth,
                         LabelHeight,
                         CornerRadius,
                         SpacingHorz,
                         SpacingVert,
                         OffsetX,
                         OffsetY: Extended;
                         PageExtent: PGmSize;
                         PaperSize: TGmPaperSize;
                         Orientation: TGmOrientation;
                         LabelShape: TGmLabelShape;
                         Measurement: TGmMeasurement): TGmLabelTemplateInfo;
    function PreDefinedTemplate(Value: TGmLabelTemplate): TGmLabelTemplateInfo;
    procedure AddStandardTemplates;
    { private declarations}
  public
    constructor Create;
    function AddCustomTemplate(AName: string;
                               NumHorz,
                               NumVert: integer;
                               LabelWidth,
                               LabelHeight,
                               CornerRadius,
                               SpacingHorz,
                               SpacingVert,
                               OffsetX,
                               OffsetY: Extended;
                               PageSize: PGmSize;
                               PaperSize: TGmPaperSize;
                               LabelShape: TGmLabelShape;
                               Measurement: TGmMeasurement): TGmLabelTemplateInfo;
    procedure ExportToFile(AFilename: string);
    procedure ImportFromFile(AFilename: string);
    procedure Templates(AStrings: TStrings);
    property IndexOfTemplate[Template: TGmLabelTemplateInfo]: integer read GetTemplateIndex;
    property Template[index: integer]: TGmLabelTemplateInfo read GetTemplate; default;
    property TemplateFromName[TemplateName: string]: TGmLabelTemplateInfo read GetTemplateFromName;
    { public declarations}
  end;

  //----------------------------------------------------------------------------

  // *** TGmLabelPrinter ***

  TGmLabelPrinter = class(TGmCustomLabelPrinter)
  private
    FBreakAdded: Boolean;
    FBrush: TBrush;
    FClipLabels: Boolean;
    FCurrentXY: TGmPoint;
    FDrawing: Boolean;
    FLabelDrawOrder: TGmLabelDrawOrder;
    FLabelTemplate: TGmLabelTemplate;
    FPen: TPen;
    FPreview: TGmPreview;
    FSelectedTemplate: TGmLabelTemplateInfo;
    FStartLabel: integer;
    FTemplateList: TGmLabelTemplateList;
    // events...
    FBeforeDrawLabels: TNotifyEvent;
    FOnDrawLabel: TGmDrawLabelEvent;
    FOnGetLabelHeight: TGmGetLabelHeightEvent;
    function GetLabelsPerPage: integer;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetLabelTemplate(Value: TGmLabelTemplate);
    procedure SetPreview(Value: TGmPreview);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DrawLabels(NumLabels: integer);
    procedure NewPage;
    procedure UseTemplate(ATemplate: TGmLabelTemplateInfo);
    property TemplateInfo: TGmLabelTemplateInfo read FSelectedTemplate;
    property TemplateList: TGmLabelTemplateList read FTemplateList;
  published
    property ClipLabels: Boolean read FClipLabels write FClipLabels default True;
    property DrawOrder: TGmLabelDrawOrder read FLabelDrawOrder write FLabelDrawOrder default gmRows;
    property LabelBrush: TBrush read FBrush write SetBrush;
    property LabelPen: TPen read FPen write SetPen;
    property LabelsPerPage: integer read GetLabelsPerPage;
    property Preview: TGmPreview read FPreview write SetPreview;
    property StartLabel: integer read FStartLabel write FStartLabel default 1;
    property Template: TGmLabelTemplate read FLabelTemplate write SetLabelTemplate default L7159_Address;
    // events...
    property BeforeDrawLabels: TNotifyEvent read FBeforeDrawLabels write FBeforeDrawLabels;
    property OnDrawLabel: TGmDrawLabelEvent read FOnDrawLabel write FOnDrawLabel;
    property OnGetLabelHeight: TGmGetLabelHeightEvent read FOnGetLabelHeight write FOnGetLabelHeight;
  end;

  //----------------------------------------------------------------------------

implementation

uses GmConst, GmErrors, TypInfo, Controls, GmFuncs, GmObjects, IniFiles;

const
  DEFAULT_CORNER_INCH = 0.10;
  DEFAULT_CORNER_MM = 2.54;
  
//------------------------------------------------------------------------------

// *** TGmLabelTemplateInfo ***

constructor TGmLabelTemplateInfo.Create;
begin
  inherited Create;
end;

function TGmLabelTemplateInfo.GetCornerRadius(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FCornerRadiusInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetLabelHeight(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FLabelHeightInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetLabelWidth(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FLabelWidthInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetLabelSpacingHorz(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FLabelSpacingHorzInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetSpacingVert(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FLabelSpacingVertInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetOffsetX(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FOffsetXInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetOffsetY(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FOffsetYInch, gmInches, Measurement);
end;

function TGmLabelTemplateInfo.GetPageExtent(Measurement: TGmMeasurement): TGmSize;
begin
  Result := ConvertGmSize(FPageExtent, gmInches, Measurement);
end;

procedure TGmLabelTemplateInfo.SetCornerRadius(Measurement: TGmMeasurement; Value: Extended);
begin
  FCornerRadiusInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetLabelHeight(Measurement: TGmMeasurement; Value: Extended);
begin
  FLabelHeightInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetLabelWidth(Measurement: TGmMeasurement; Value: Extended);
begin
  FLabelWidthInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetLabelSpacingHorz(Measurement: TGmMeasurement; Value: Extended);
begin
  FLabelSpacingHorzInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetLabelSpacingVert(Measurement: TGmMeasurement; Value: Extended);
begin
  FLabelSpacingVertInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetNumLabelsHorz(Value: integer);
begin
  if (Value = 0) or (Value = FNumHorz) then Exit;
  FNumHorz := Value;
end;

procedure TGmLabelTemplateInfo.SetNumLabelsVert(Value: integer);
begin
  if (Value = 0) or (Value = FNumVert) then Exit;
  FNumVert := Value;
end;

procedure TGmLabelTemplateInfo.SetOffsetX(Measurement: TGmMeasurement; Value: Extended);
begin
  FOffsetXInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetOffsetY(Measurement: TGmMeasurement; Value: Extended);
begin
  FOffsetYInch := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetPageExtent(Measurement: TGmMeasurement; Value: TGmSize);
begin
  FPageExtent := ConvertGmSize(Value, Measurement, gmInches);
end;

procedure TGmLabelTemplateInfo.SetPaperSize(Value: TGmPaperSize);
begin
  if FPaperSize = Custom then Exit;
  FPaperSize := Value;
  FPageExtent := GetPaperSizeInch(FPaperSize);
end;

procedure TGmLabelTemplateInfo.SetTemplateName(Value: string);
begin
  if FTemplateName = Value then Exit;
  FTemplateName := Value;
  FTemplateID := Custom_Template;
end;

//------------------------------------------------------------------------------

// *** TGmLabelTemplateList ***

constructor TGmLabelTemplateList.Create;
begin
  inherited Create(True);
  FDestroying := False;
  AddStandardTemplates;
end;

function TGmLabelTemplateList.AddTemplate(ATemplate: TGmLabelTemplate;
                                          AName: string;
                                          NumHorz,
                                          NumVert: integer;
                                          LabelWidth,
                                          LabelHeight,
                                          CornerRadius,
                                          SpacingHorz,
                                          SpacingVert,
                                          OffsetX,
                                          OffsetY: Extended;
                                          PageExtent: PGmSize;
                                          PaperSize: TGmPaperSize;
                                          Orientation: TGmOrientation;
                                          LabelShape: TGmLabelShape;
                                          Measurement: TGmMeasurement): TGmLabelTemplateInfo;
var
  NewTemplate: TGmLabelTemplateInfo;
var
  PageSize: TGmSize;
begin
  if PaperSize <> Custom then
    PageSize := ConvertGmSize(GetPaperSizeInch(PaperSize), Measurement, gmInches)
  else
  begin
    if PageExtent <> nil then
      PageSize := ConvertGmSize(PageExtent^, Measurement, gmInches)
    else
      PageSize := ConvertGmSize(GetPaperSizeInch(A4), Measurement, gmInches);
  end;
  NewTemplate := TGmLabelTemplateInfo.Create;
  NewTemplate.FTemplateID           := ATemplate;
  NewTemplate.FTemplateName         := AName;
  NewTemplate.FNumHorz              := NumHorz;
  NewTemplate.FNumVert              := NumVert;
  NewTemplate.FLabelHeightInch      := ConvertValue(LabelHeight, Measurement, gmInches);
  NewTemplate.FLabelWidthInch       := ConvertValue(LabelWidth, Measurement, gmInches);
  NewTemplate.FLabelSpacingHorzInch := ConvertValue(SpacingHorz, Measurement, gmInches);
  NewTemplate.FLabelSpacingVertInch := ConvertValue(SpacingVert, Measurement, gmInches);
  NewTemplate.FOffsetXInch          := ConvertValue(OffsetX, Measurement, gmInches);
  NewTemplate.FOffsetYInch          := ConvertValue(OffsetY, Measurement, gmInches);
  NewTemplate.FPageExtent           := PageSize;
  NewTemplate.FPaperSize            := PaperSize;
  NewTemplate.FOrientation          := Orientation;
  NewTemplate.FLabelShape           := LabelShape;
  NewTemplate.FCornerRadiusInch     := ConvertValue(CornerRadius, Measurement, gmInches);
  Add(NewTemplate);
  Result := NewTemplate;
end;

function TGmLabelTemplateList.GetTemplate(index: integer): TGmLabelTemplateInfo;
begin
  if index = -1 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TGmLabelTemplateInfo(Items[index]);
end;

function TGmLabelTemplateList.GetTemplateFromName(ATemplateName: string): TGmLabelTemplateInfo;
var
  ICount: integer;
begin
  Result := nil;
  for ICount := 0 to Count-1 do
    if LowerCase(Template[ICount].TemplateName) = LowerCase(ATemplateName) then
      Result := Template[ICount];
end;

function TGmLabelTemplateList.GetTemplateIndex(ATemplate: TGmLabelTemplateInfo): integer;
begin
  Result := IndexOf(ATemplate);
end;

function TGmLabelTemplateList.PreDefinedTemplate(Value: TGmLabelTemplate): TGmLabelTemplateInfo;
var
  ICount: integer;
begin
  Result := nil;
  for ICount := 0 to Count-1 do
    if Template[ICount].TemplateID = Value then Result := Template[ICount];
end;

procedure TGmLabelTemplateList.AddStandardTemplates;
begin
  AddTemplate(L7159_Address, 'L7159_Address', 3, 8, 2.52, 1.33, DEFAULT_CORNER_INCH, 2.63, 1.33, 0.25, 0.54, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7160_Address, 'L7160_Address', 3, 7, 2.50, 1.50, DEFAULT_CORNER_INCH, 2.60, 1.50, 0.28, 0.63, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7161_Address, 'L7161_Address', 3, 6, 2.50, 1.83, DEFAULT_CORNER_INCH, 2.60, 1.83, 0.28, 0.38, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7162_Address, 'L7162_Address', 2, 8, 3.90, 1.33, DEFAULT_CORNER_INCH, 4.00, 1.33, 0.18, 0.54, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7163_Address, 'L7163_Address', 2, 7, 3.90, 1.50, DEFAULT_CORNER_INCH, 4.00, 1.50, 0.18, 0.63, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7164_Address, 'L7164_Address', 3, 4, 2.50, 2.83, DEFAULT_CORNER_INCH, 2.60, 2.83, 0.28, 0.21, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7165_Parcel,  'L7165_Parcel',  2, 4, 3.90, 2.67, DEFAULT_CORNER_INCH, 4.00, 2.67, 0.18, 0.54, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7166_Parcel,  'L7166_Parcel',  2, 3, 3.90, 3.67, DEFAULT_CORNER_INCH, 4.00, 3.67, 0.18, 0.38, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7167_Shipping, 'L7167_Shipping', 1, 1, 7.86, 11.38, DEFAULT_CORNER_INCH, 7.86, 11.38, 0.20, 0.18, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7168_Shipping, 'L7168_Shipping', 1, 2, 7.86, 5.65, DEFAULT_CORNER_INCH, 7.86, 5.65, 0.18, 0.22, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7169_Parcel, 'L7169_Parcel', 2, 2,   5.47,3.90, DEFAULT_CORNER_INCH, 5.47, 4.00, 0.40, 0.18, nil, A4, gmLandscape, gmLabelRoundRect, gmInches);
  AddTemplate(L7170_Eurofolio, 'L7170_Eurofolio', 1, 24,  5.28, 0.43, DEFAULT_CORNER_INCH, 5.28, 0.43, 1.50, 0.68, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7171_LeverArch, 'L7171_LeverArch', 4, 1,  2.36, 7.88, DEFAULT_CORNER_INCH, 2.36, 7.88, 1.15, 0.20, nil, A4, gmLandscape, gmLabelRoundRect, gmInches);
  AddTemplate(L7172_RingBinder, 'L7172_RingBinder', 2, 9,   3.94,1.18, DEFAULT_CORNER_INCH, 4.04, 1.18, 0.15, 0.56, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7173_Shipping, 'L7173_Shipping', 2, 5,   3.90, 2.24,DEFAULT_CORNER_INCH, 4.00, 2.24, 0.18, 0.26, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(L7263_Address, 'L7263_Address', 2, 7,   3.90, 1.50,DEFAULT_CORNER_INCH, 4.00, 1.50, 0.18, 0.63, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(J8660_Diskette, 'J8660_Diskette', 2, 5,  2.76, 2.05, DEFAULT_CORNER_INCH, 3.67, 2.05, 0.92, 0.76, nil, A4, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(Avery_5160_Address, 'Avery_5160_Address', 3, 10,  2.63, 1.00, DEFAULT_CORNER_INCH, 2.75, 1.00, 0.19, 0.50, nil, Letter, gmPortrait, gmLabelRoundRect, gmInches);
  AddTemplate(Herma_4209, 'Herma_4209',  2, 16,   96.0, 16.9, DEFAULT_CORNER_MM, 98.0, 16.90, 8.00, 12.0, nil, A4, gmPortrait, gmLabelRoundRect, gmMillimeters);

end;

function TGmLabelTemplateList.AddCustomTemplate(AName: string;
                                                NumHorz,
                                                NumVert: integer;
                                                LabelWidth,
                                                LabelHeight,
                                                CornerRadius,
                                                SpacingHorz,
                                                SpacingVert,
                                                OffsetX,
                                                OffsetY: Extended;
                                                PageSize: PGmSize;
                                                PaperSize: TGmPaperSize;
                                                LabelShape: TGmLabelShape;
                                                Measurement: TGmMeasurement): TGmLabelTemplateInfo;
begin
  Result := AddTemplate(Custom_Template, AName, NumHorz, NumVert, LabelWidth, LabelHeight, CornerRadius,
    SpacingHorz, SpacingVert, OffsetX, OffsetY, PageSize, PaperSize, gmPortrait, LabelShape, Measurement);
end;

procedure TGmLabelTemplateList.ImportFromFile(AFilename: string);
var
  ICount: integer;
  Ini: TIniFile;
  ASections: TStringList;
  ATemplate: TGmLabelTemplateInfo;
begin
  ASections := TStringList.Create;
  Clear;
  Ini := TIniFile.Create(AFilename);
  try
    Ini.ReadSections(ASections);
    for ICount := 0 to ASections.Count-1 do
    begin
      if TemplateFromName[ASections[ICount]] = nil then
      begin
        ATemplate := TGmLabelTemplateInfo.Create;
        ATemplate.TemplateName := ASections[ICount];
        ATemplate.FTemplateID := TGmLabelTemplate(Ini.ReadInteger(ATemplate.TemplateName, 'id', 0));
        ATemplate.FTemplateName := ASections[ICount];
        ATemplate.FNumHorz := Ini.ReadInteger(ATemplate.TemplateName, 'nh', 0);
        ATemplate.FNumVert := Ini.ReadInteger(ATemplate.TemplateName, 'nv', 0);
        ATemplate.FLabelHeightInch := Ini.ReadFloat(ATemplate.TemplateName, 'lh', 0);
        ATemplate.FLabelWidthInch := Ini.ReadFloat(ATemplate.TemplateName, 'lw', 0);
        ATemplate.FLabelSpacingHorzInch := Ini.ReadFloat(ATemplate.TemplateName, 'sh', 0);
        ATemplate.FLabelSpacingVertInch := Ini.ReadFloat(ATemplate.TemplateName, 'sv', 0);
        ATemplate.FOffsetXInch := Ini.ReadFloat(ATemplate.TemplateName, 'ox', 0);
        ATemplate.FOffsetYInch := Ini.ReadFloat(ATemplate.TemplateName, 'oy', 0);
        ATemplate.FPageExtent.Width  := Ini.ReadFloat(ATemplate.TemplateName, 'pw', 0);
        ATemplate.FPageExtent.Height := Ini.ReadFloat(ATemplate.TemplateName, 'ph', 0);
        ATemplate.FPaperSize := StrToPaperSize(Ini.ReadString(ATemplate.TemplateName, 'ps', 'A4'));
        ATemplate.FOrientation := TGmOrientation(Ini.ReadInteger(ATemplate.TemplateName, 'o', 0));
        ATemplate.FLabelShape  := TGmLabelShape(Ini.ReadInteger(ATemplate.TemplateName, 'ls', 0));
        ATemplate.FCornerRadiusInch := Ini.ReadFloat(ATemplate.TemplateName, 'cr', DEFAULT_CORNER_INCH);
        Add(ATemplate);
      end;
    end;
  finally
    Ini.Free;
    ASections.Free;
  end;
end;

procedure TGmLabelTemplateList.Templates(AStrings: TStrings);
var
  ICount: integer;
begin
  AStrings.Clear;
  try
    AStrings.BeginUpdate;
  for ICount := 0 to Count-1 do
    AStrings.Add(Template[ICount].TemplateName);
  finally
    AStrings.EndUpdate;
  end;
end;

procedure TGmLabelTemplateList.ExportToFile(AFilename: string);
var
  Ini: TIniFile;
  ATemplate: TGmLabelTemplateInfo;
  ICount: integer;
begin
  Ini := TIniFile.Create(AFilename);
  try
    for ICount := 0 to Count-1 do
    begin
      ATemplate := Template[ICount];
      Ini.WriteInteger(ATemplate.TemplateName, 'id', Ord(ATemplate.TemplateID));
      Ini.WriteInteger(ATemplate.TemplateName, 'nh', ATemplate.NumLabelsHorz);
      Ini.WriteInteger(ATemplate.TemplateName, 'nv', ATemplate.NumLabelsVert);
      Ini.WriteFloat(ATemplate.TemplateName, 'lh', ATemplate.LabelHeight[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'lw', ATemplate.LabelWidth[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'sh', ATemplate.LabelSpacingHorz[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'sv', ATemplate.LabelSpacingVert[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'ox', ATemplate.OffsetX[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'oy', ATemplate.OffsetY[gmInches]);
      Ini.WriteFloat(ATemplate.TemplateName, 'pw', ATemplate.PageExtent[gmInches].Width);
      Ini.WriteFloat(ATemplate.TemplateName, 'ph', ATemplate.PageExtent[gmInches].Height);
      Ini.WriteString(ATemplate.TemplateName, 'ps', PaperSizeToStr(ATemplate.PaperSize));
      Ini.WriteInteger(ATemplate.TemplateName,'o', Ord(ATemplate.Orientation));
      Ini.WriteInteger(ATemplate.TemplateName,'ls', Ord(ATemplate.LabelShape));
      Ini.WriteFloat(ATemplate.TemplateName, 'cr', ATemplate.CornerRadius[gmInches]);
    end;
  finally
    Ini.Free;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmLabelPrinter ***

constructor TGmLabelPrinter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTemplateList := TGmLabelTemplateList.Create;
  FBrush := TBrush.Create;
  FPen := TPen.Create;
  FSelectedTemplate := FTemplateList[0];
  FLabelDrawOrder := gmRows;
  FClipLabels := True;
  FStartLabel := 1;
  FLabelTemplate := L7159_Address;
  FBrush.Style := bsSolid;
end;

destructor TGmLabelPrinter.Destroy;
begin
  FTemplateList.FDestroying := True;
  FTemplateList.Free;
  FBrush.Free;
  FPen.Free;
  inherited Destroy;
end;

function TGmLabelPrinter.GetLabelsPerPage: integer;
begin
  Result := FSelectedTemplate.NumLabelsHorz * FSelectedTemplate.NumLabelsVert;
end;

procedure TGmLabelPrinter.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TGmLabelPrinter.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TGmLabelPrinter.SetLabelTemplate(Value: TGmLabelTemplate);
begin
  FSelectedTemplate := FTemplateList.PreDefinedTemplate(Value);
  FLabelTemplate := Value;
end;

procedure TGmLabelPrinter.SetPreview(Value: TGmPreview);
begin
  FPreview := Value;
end;

procedure TGmLabelPrinter.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then FPreview := nil;
end;

procedure TGmLabelPrinter.DrawLabels(NumLabels: integer);
var
  Corner: Extended;
  ARect: TGmRect;
  Origin: TGmPoint;
  LabelXYIndex: TPoint;
  LoopCount: integer;
  NumDrawn: integer;
  LastLabel: TPoint;
  AGmValueHeight: TGmValue;
  AGmValueVertSpacing: TGmValue;
  AGmValueRect: TGmValueRect;
  ALabelHeight: Extended;
  ALabelSpacingVert: Extended;
  SaveBrush: TBrush;
  SavePen: TPen;
begin
  if not Assigned(FPreview) then
  begin
    ShowGmError(Self, GM_NO_PREVIEW_ASSIGNED);
    Exit;
  end;
  if not Assigned(FSelectedTemplate) then Exit;
  if (FSelectedTemplate.NumLabelsHorz = 0) or (FSelectedTemplate.NumLabelsVert = 0) then Exit;

  FPreview.Canvas.SaveCanvasProperties;
  FPreview.BeginUpdate;
  FPreview.Canvas.CoordsRelativeTo := gmFromPage;
  FPreview.Canvas.RemoveClipRgn;
  SaveBrush := TBrush.Create;
  SavePen := TPen.Create;
  with FSelectedTemplate do
  begin

    FDrawing := True;
    if Assigned(FBeforeDrawLabels) then FBeforeDrawLabels(Self);
    FBreakAdded := False;
    Corner := CornerRadius[gmInches] * 2;
    if PaperSize <> Custom then
    begin
      FPreview.PaperSize := PaperSize;
      FPreview.Orientation := Orientation;
    end
    else
    begin
      with PageExtent[gmInches] do FPreview.SetCustomPageSize(Width, Height, gmInches);
    end;

    FCurrentXY := GmPoint(OffsetX[gmInches], OffsetY[gmInches]);
    Origin := FCurrentXY;

    LabelXYIndex := Point(1,1);
    LastLabel := Point(NumLabelsHorz, NumLabelsVert);
    LoopCount := 0;
    NumDrawn := 0;
    while NumDrawn < NumLabels do
    begin
      Inc(LoopCount);
      ALabelHeight := LabelHeight[gmInches];
      ALabelSpacingVert := LabelSpacingVert[gmInches];
      if (Assigned(FOnGetLabelHeight)) and (FLabelDrawOrder = gmColumns) then
      begin
        AGmValueHeight := TGmValue.Create(nil);
        AGmValueVertSpacing := TGmValue.Create(nil);
        try
          AGmValueHeight.AsInches := ALabelHeight;
          AGmValueVertSpacing.AsInches := ALabelSpacingVert;
          FOnGetLabelHeight(Self, NumDrawn+1, LabelXYIndex.X, LabelXYIndex.Y, AGmValueHeight, AGmValueVertSpacing);
          ALabelHeight := AGmValueHeight.AsInches;
          ALabelSpacingVert := AGmValueVertSpacing.AsInches;
        finally
          AGmValueHeight.Free;
          AGmValueVertSpacing.Free;
        end;
      end;
      ARect := GmRect(FCurrentXY.X, FCurrentXY.Y, FCurrentXY.X+LabelWidth[gmInches], FCurrentXY.Y+ALabelHeight);
      if LoopCount >= StartLabel then
      begin
        SaveBrush.Assign(FPreview.Canvas.Brush);
        SavePen.Assign(FPreview.Canvas.Pen);
        FPreview.Canvas.Brush.Assign(FBrush);
        FPreview.Canvas.Pen.Assign(FPen);
        case LabelShape of
          gmLabelRect     : FPreview.Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
          gmLabelEllipse  : FPreview.Canvas.Ellipse(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
          gmLabelRoundRect: FPreview.Canvas.RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, Corner, Corner, gmInches);
        end;
        FPreview.Canvas.Brush.Assign(SaveBrush);
        FPreview.Canvas.Pen.Assign(SavePen);
        FPreview.Canvas.LastObject.PrintThisObject := False;
        if FClipLabels then
        begin
          // set clipping region...
          case LabelShape of
            gmLabelRect     : FPreview.Canvas.SetClipRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
            gmLabelEllipse  : FPreview.Canvas.SetClipEllipse(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
            gmLabelRoundRect: FPreview.Canvas.SetClipRoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, Corner, Corner, gmInches);
          end;
        end;
        Inc(NumDrawn);
        FBreakAdded := False;
        if Assigned(FOnDrawLabel) then
        begin
          AGmValueRect := TGmValueRect.Create;
          try
            AGmValueRect.AsInchRect := ARect;
            // call ondraw method...
            FOnDrawLabel(Self, NumDrawn, AGmValueRect, FPreview.Canvas);
          finally
            AGmValueRect.Free;
          end;
        end;
        FPreview.Canvas.RemoveClipRgn;
      end;
      if ((EqualPoints(LabelXYIndex, LastLabel)) or (FBreakAdded)) and (NumDrawn < NumLabels) then
      begin
        FPreview.NewPage;
        FCurrentXY := Origin;
        LabelXYIndex := Point(1,1);
      end
      else
      begin
        if FLabelDrawOrder = gmRows then
        begin
          FCurrentXY.X := FCurrentXY.X + LabelSpacingHorz[gmInches];
          if LabelXYIndex.X = NumLabelsHorz then
          begin
            FCurrentXY.X := Origin.X;
            FCurrentXY.Y := FCurrentXY.Y + LabelSpacingVert[gmInches];
            LabelXYIndex.X := 1;
            LabelXYIndex.Y := LabelXYIndex.Y+1;
          end
          else
            LabelXYIndex.X := LabelXYIndex.X+1;
        end
        else
        begin
          // draw order = gmCols
          FCurrentXY.Y := FCurrentXY.Y + ALabelSpacingVert;
          if LabelXYIndex.Y = NumLabelsVert then
          begin
            FCurrentXY.Y := Origin.Y;
            FCurrentXY.X := FCurrentXY.X + LabelSpacingHorz[gmInches];
            LabelXYIndex.X := LabelXYIndex.X+1;
            LabelXYIndex.Y := 1;
          end
          else
            LabelXYIndex.Y := LabelXYIndex.Y+1;
        end;
      end;
    end;
  end;
  SaveBrush.Free;
  SavePen.Free;
  FPreview.Canvas.LoadCanvasProperties;
  FPreview.EndUpdate;
end;

procedure TGmLabelPrinter.NewPage;
begin
  FBreakAdded := True;
end;

procedure TGmLabelPrinter.UseTemplate(ATemplate: TGmLabelTemplateInfo);
begin
  if ATemplate <> nil then
    FSelectedTemplate := ATemplate;
end;

end.

