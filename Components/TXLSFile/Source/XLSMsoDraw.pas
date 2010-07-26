unit XLSMsoDraw;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    MS Office Drawing: Header

    Rev history:
    2008-11-19  Fix:  delete image shapes without blips
    2008-11-23  Add:  process empty BLIPs

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, Streams, XLSBase;

const
  MSOInstContainer              = $000F;

  { MSODrawing fbt's }
  MSOFBT_DggContainer           = $F000; // Drawing Group Container
  MSOFBT_Dgg                    = $F006;
  MSOFBT_CLSID                  = $F016;
  MSOFBT_OPT                    = $F00B;
  MSOFBT_ColorMRU               = $F11A;
  MSOFBT_SplitMenuColors        = $F11E;
  MSOFBT_BStoreContainer        = $F001;
  MSOFBT_BSE                    = $F007;
  MSOFBT_Blip_START             = $F018; // Blip types are between
  MSOFBT_Blip_END               = $F117; // these two values
  MSOFBT_DgContainer            = $F002; // Drawing Container
  MSOFBT_Dg                     = $F008;
  MSOFBT_RegroupItems           = $F118;
  MSOFBT_ColorScheme            = $F120;
  MSOFBT_SpgrContainer          = $F003;
  MSOFBT_SpContainer            = $F004;
  MSOFBT_Spgr                   = $F009;
  MSOFBT_Sp                     = $F00A;
  MSOFBT_Textbox                = $F00C;
  MSOFBT_ClientTextbox          = $F00D;
  MSOFBT_Anchor                 = $F00E;
  MSOFBT_ChildAnchor            = $F00F;
  MSOFBT_ClientAnchor           = $F010;
  MSOFBT_ClientData             = $F011;
  MSOFBT_OleObject              = $F11F;
  MSOFBT_DeletedPspl            = $F11D;
  MSOFBT_SolverContainer        = $F005;
  MSOFBT_ConnectorRule          = $F012;
  MSOFBT_AlignRule              = $F013;
  MSOFBT_ArcRule                = $F014;
  MSOFBT_ClientRule             = $F015;
  MSOFBT_CalloutRule            = $F017;
  MSOFBT_Selection              = $F119;

  { BLIP types }
  MSOBLIP_ERROR                 = 0;    // An error occured during loading
  MSOBLIP_UNKNOWN               = 1;    // An unknown blip type
  MSOBLIP_EMF                   = 2;    // Windows Enhanced Metafile
  MSOBLIP_WMF                   = 3;    // Windows Metafile
  MSOBLIP_PICT                  = 4;    // Macintosh PICT
  MSOBLIP_JPEG                  = 5;    // JFIF
  MSOBLIP_PNG                   = 6;    // PNG
  MSOBLIP_DIB                   = 7;    // Windows DIB (BMP)
  MSOBLIP_FirstClient           = 32;   // First client defined blip type
  MSOBLIP_LastClient            = 255;  // Last client defined blip type

  { BLIP signatures }
  MSOBLIPSIG_DIB                = $7A80;
  MSOBLIPSIG_JPEG               = $46A0;
  MSOBLIPSIG_PNG                = $6E00;
  MSOBLIPSIG_WMF                = $2160;
  MSOBLIPSIG_EMF                = $3D40;

  { Property codes }
  FOPTE_pib                     = $104; // BLIP ID

  { Shape types }
  MSOSPT_Min = 0;
  MSOSPT_NotPrimitive = 0;
  MSOSPT_Rectangle = 1;
  MSOSPT_RoundRectangle = 2;
  MSOSPT_Ellipse = 3;
  MSOSPT_Diamond = 4;
  MSOSPT_IsocelesTriangle = 5;
  MSOSPT_RightTriangle = 6;
  MSOSPT_Parallelogram = 7;
  MSOSPT_Trapezoid = 8;
  MSOSPT_Hexagon = 9;
  MSOSPT_Octagon = 10;
  MSOSPT_Plus = 11;
  MSOSPT_Star = 12;
  MSOSPT_Arrow = 13;
  MSOSPT_ThickArrow = 14;
  MSOSPT_HomePlate = 15;
  MSOSPT_Cube = 16;
  MSOSPT_Balloon = 17;
  MSOSPT_Seal = 18;
  MSOSPT_Arc = 19;
  MSOSPT_Line = 20;
  MSOSPT_Plaque = 21;
  MSOSPT_Can = 22;
  MSOSPT_Donut = 23;
  MSOSPT_TextSimple = 24;
  MSOSPT_TextOctagon = 25;
  MSOSPT_TextHexagon = 26;
  MSOSPT_TextCurve = 27;
  MSOSPT_TextWave = 28;
  MSOSPT_TextRing = 29;
  MSOSPT_TextOnCurve = 30;
  MSOSPT_TextOnRing = 31;
  MSOSPT_StraightConnector1 = 32;
  MSOSPT_BentConnector2 = 33;
  MSOSPT_BentConnector3 = 34;
  MSOSPT_BentConnector4 = 35;
  MSOSPT_BentConnector5 = 36;
  MSOSPT_CurvedConnector2 = 37;
  MSOSPT_CurvedConnector3 = 38;
  MSOSPT_CurvedConnector4 = 39;
  MSOSPT_CurvedConnector5 = 40;
  MSOSPT_Callout1 = 41;
  MSOSPT_Callout2 = 42;
  MSOSPT_Callout3 = 43;
  MSOSPT_AccentCallout1 = 44;
  MSOSPT_AccentCallout2 = 45;
  MSOSPT_AccentCallout3 = 46;
  MSOSPT_BorderCallout1 = 47;
  MSOSPT_BorderCallout2 = 48;
  MSOSPT_BorderCallout3 = 49;
  MSOSPT_AccentBorderCallout1 = 50;
  MSOSPT_AccentBorderCallout2 = 51;
  MSOSPT_AccentBorderCallout3 = 52;
  MSOSPT_Ribbon = 53;
  MSOSPT_Ribbon2 = 54;
  MSOSPT_Chevron = 55;
  MSOSPT_Pentagon = 56;
  MSOSPT_NoSmoking = 57;
  MSOSPT_Seal8 = 58;
  MSOSPT_Seal16 = 59;
  MSOSPT_Seal32 = 60;
  MSOSPT_WedgeRectCallout = 61;
  MSOSPT_WedgeRRectCallout = 62;
  MSOSPT_WedgeEllipseCallout = 63;
  MSOSPT_Wave = 64;
  MSOSPT_FoldedCorner = 65;
  MSOSPT_LeftArrow = 66;
  MSOSPT_DownArrow = 67;
  MSOSPT_UpArrow = 68;
  MSOSPT_LeftRightArrow = 69;
  MSOSPT_UpDownArrow = 70;
  MSOSPT_IrregularSeal1 = 71;
  MSOSPT_IrregularSeal2 = 72;
  MSOSPT_LightningBolt = 73;
  MSOSPT_Heart = 74;
  MSOSPT_PictureFrame = 75;
  MSOSPT_QuadArrow = 76;
  MSOSPT_LeftArrowCallout = 77;
  MSOSPT_RightArrowCallout = 78;
  MSOSPT_UpArrowCallout = 79;
  MSOSPT_DownArrowCallout = 80;
  MSOSPT_LeftRightArrowCallout = 81;
  MSOSPT_UpDownArrowCallout = 82;
  MSOSPT_QuadArrowCallout = 83;
  MSOSPT_Bevel = 84;
  MSOSPT_LeftBracket = 85;
  MSOSPT_RightBracket = 86;
  MSOSPT_LeftBrace = 87;
  MSOSPT_RightBrace = 88;
  MSOSPT_LeftUpArrow = 89;
  MSOSPT_BentUpArrow = 90;
  MSOSPT_BentArrow = 91;
  MSOSPT_Seal24 = 92;
  MSOSPT_StripedRightArrow = 93;
  MSOSPT_NotchedRightArrow = 94;
  MSOSPT_BlockArc = 95;
  MSOSPT_SmileyFace = 96;
  MSOSPT_VerticalScroll = 97;
  MSOSPT_HorizontalScroll = 98;
  MSOSPT_CircularArrow = 99;
  MSOSPT_NotchedCircularArrow = 100;
  MSOSPT_UturnArrow = 101;
  MSOSPT_CurvedRightArrow = 102;
  MSOSPT_CurvedLeftArrow = 103;
  MSOSPT_CurvedUpArrow = 104;
  MSOSPT_CurvedDownArrow = 105;
  MSOSPT_CloudCallout = 106;
  MSOSPT_EllipseRibbon = 107;
  MSOSPT_EllipseRibbon2 = 108;
  MSOSPT_FlowChartProcess = 109;
  MSOSPT_FlowChartDecision = 110;
  MSOSPT_FlowChartInputOutput = 111;
  MSOSPT_FlowChartPredefinedProcess = 112;
  MSOSPT_FlowChartInternalStorage = 113;
  MSOSPT_FlowChartDocument = 114;
  MSOSPT_FlowChartMultidocument = 115;
  MSOSPT_FlowChartTerminator = 116;
  MSOSPT_FlowChartPreparation = 117;
  MSOSPT_FlowChartManualInput = 118;
  MSOSPT_FlowChartManualOperation = 119;
  MSOSPT_FlowChartConnector = 120;
  MSOSPT_FlowChartPunchedCard = 121;
  MSOSPT_FlowChartPunchedTape = 122;
  MSOSPT_FlowChartSummingJunction = 123;
  MSOSPT_FlowChartOr = 124;
  MSOSPT_FlowChartCollate = 125;
  MSOSPT_FlowChartSort = 126;
  MSOSPT_FlowChartExtract = 127;
  MSOSPT_FlowChartMerge = 128;
  MSOSPT_FlowChartOfflineStorage = 129;
  MSOSPT_FlowChartOnlineStorage = 130;
  MSOSPT_FlowChartMagneticTape = 131;
  MSOSPT_FlowChartMagneticDisk = 132;
  MSOSPT_FlowChartMagneticDrum = 133;
  MSOSPT_FlowChartDisplay = 134;
  MSOSPT_FlowChartDelay = 135;
  MSOSPT_TextPlainText = 136;
  MSOSPT_TextStop = 137;
  MSOSPT_TextTriangle = 138;
  MSOSPT_TextTriangleInverted = 139;
  MSOSPT_TextChevron = 140;
  MSOSPT_TextChevronInverted = 141;
  MSOSPT_TextRingInside = 142;
  MSOSPT_TextRingOutside = 143;
  MSOSPT_TextArchUpCurve = 144;
  MSOSPT_TextArchDownCurve = 145;
  MSOSPT_TextCircleCurve = 146;
  MSOSPT_TextButtonCurve = 147;
  MSOSPT_TextArchUpPour = 148;
  MSOSPT_TextArchDownPour = 149;
  MSOSPT_TextCirclePour = 150;
  MSOSPT_TextButtonPour = 151;
  MSOSPT_TextCurveUp = 152;
  MSOSPT_TextCurveDown = 153;
  MSOSPT_TextCascadeUp = 154;
  MSOSPT_TextCascadeDown = 155;
  MSOSPT_TextWave1 = 156;
  MSOSPT_TextWave2 = 157;
  MSOSPT_TextWave3 = 158;
  MSOSPT_TextWave4 = 159;
  MSOSPT_TextInflate = 160;
  MSOSPT_TextDeflate = 161;
  MSOSPT_TextInflateBottom = 162;
  MSOSPT_TextDeflateBottom = 163;
  MSOSPT_TextInflateTop = 164;
  MSOSPT_TextDeflateTop = 165;
  MSOSPT_TextDeflateInflate = 166;
  MSOSPT_TextDeflateInflateDeflate = 167;
  MSOSPT_TextFadeRight = 168;
  MSOSPT_TextFadeLeft = 169;
  MSOSPT_TextFadeUp = 170;
  MSOSPT_TextFadeDown = 171;
  MSOSPT_TextSlantUp = 172;
  MSOSPT_TextSlantDown = 173;
  MSOSPT_TextCanUp = 174;
  MSOSPT_TextCanDown = 175;
  MSOSPT_FlowChartAlternateProcess = 176;
  MSOSPT_FlowChartOffpageConnector = 177;
  MSOSPT_Callout90 = 178;
  MSOSPT_AccentCallout90 = 179;
  MSOSPT_BorderCallout90 = 180;
  MSOSPT_AccentBorderCallout90 = 181;
  MSOSPT_LeftRightUpArrow = 182;
  MSOSPT_Sun = 183;
  MSOSPT_Moon = 184;
  MSOSPT_BracketPair = 185;
  MSOSPT_BracePair = 186;
  MSOSPT_Seal4 = 187;
  MSOSPT_DoubleWave = 188;
  MSOSPT_ActionButtonBlank = 189;
  MSOSPT_ActionButtonHome = 190;
  MSOSPT_ActionButtonHelp = 191;
  MSOSPT_ActionButtonInformation = 192;
  MSOSPT_ActionButtonForwardNext = 193;
  MSOSPT_ActionButtonBackPrevious = 194;
  MSOSPT_ActionButtonEnd = 195;
  MSOSPT_ActionButtonBeginning = 196;
  MSOSPT_ActionButtonReturn = 197;
  MSOSPT_ActionButtonDocument = 198;
  MSOSPT_ActionButtonSound = 199;
  MSOSPT_ActionButtonMovie = 200;
  MSOSPT_HostControl = 201;
  MSOSPT_TextBox = 202;
  MSOSPT_Max = $0FFF;
  MSOSPT_Nil = $0FFF;

  { Describes graphic object codes }
  MSO_ftEnd      = $00;  // End of OBJ record
  MSO_ftMacro    = $04;  // Fmla-style macro
  MSO_ftButton   = $05;  // Command button
  MSO_ftGmo      = $06;  // Group marker
  MSO_ftCf       = $07;  // Clipboard format
  MSO_ftPioGrbit = $08;  // Picture option flags
  MSO_ftPictFmla = $09;  // Picture fmla-style macro
  MSO_ftCbls     = $0A;  // Check box link
  MSO_ftRbo      = $0B;  // Radio button
  MSO_ftSbs      = $0C;  // Scroll bar
  MSO_ftNts      = $0D;  // Note structure
  MSO_ftSbsFmla  = $0E;  // Scroll bar fmla-style macro
  MSO_ftGboData  = $0F;  // Group box data
  MSO_ftEdoData  = $10;  // Edit control data
  MSO_ftRboData  = $11;  // Radio button data
  MSO_ftCblsData = $12;  // Check box data
  MSO_ftLbsData  = $13;  // List box data
  MSO_ftCblsFmla = $14;  // Check box link fmla-style macro
  MSO_ftCmo      = $15;  // Common object data

  { Object types }
  MSOOBJ_Group      = $00;
  MSOOBJ_Line       = $01;
  MSOOBJ_Rectangle  = $02;
  MSOOBJ_Oval       = $03;
  MSOOBJ_Arc        = $04;
  MSOOBJ_Chart      = $05;
  MSOOBJ_Text       = $06;
  MSOOBJ_Button     = $07;
  MSOOBJ_Picture    = $08;
  MSOOBJ_Polygon    = $09;
  MSOOBJ_Checkbox   = $0B;
  MSOOBJ_Option     = $0C;
  MSOOBJ_Edit       = $0D;
  MSOOBJ_Label      = $0E;
  MSOOBJ_Dialog     = $0F;
  MSOOBJ_Spinner    = $10;
  MSOOBJ_Scrollbar  = $11;
  MSOOBJ_Listbox    = $12;
  MSOOBJ_Groupbox   = $13;
  MSOOBJ_Combo      = $14;
  MSOOBJ_Comment    = $19;
  MSOOBJ_MSODrawing = $1E;

  OBJECTID_NOTASSIGNED = Integer(-1);
  BLIPID_NOTASSIGNED = 0;

type
  { TMSORecordHeader }
  TMSORecordHeader = packed record
    Version: Byte;
    Instance: Word;
    FBT: Word;
    Length: Integer;
  end;

  { TMSOClientAnchor }
  TMSOClientAnchor = packed record
    ColumnFrom         : Integer;
    ColumnFromAddition : Integer;
    RowFrom            : Integer;
    RowFromAddition    : Integer;
    ColumnTo           : Integer;
    ColumnToAddition   : Integer;
    RowTo              : Integer;
    RowToAddition      : Integer;
  end;

  { TMSOBLIP }
  TMSOBLIP = class
  protected
    FImageData: TEasyStream;
  public
    FileName: WideString;
    RefCount: Integer;
    OriginalWidthPx: Integer;
    OriginalHeightPx: Integer;
    BLIPType: Byte;
    BLIPID: Integer;
    IsEmpty: Boolean;
    constructor Create;
    destructor Destroy; override;
    property ImageData: TEasyStream read FImageData;
  end;

  { TMSOShape }
  TMSOShape = class
  public
    SheetIndex: Integer;
    Anchor: TMSOClientAnchor;
    ObjectID: Integer;
    SPID: Integer;
  end;

  { TMSOShapeImage }
  TMSOShapeImage = class(TMSOShape)
  public
    BLIPID: Integer;
    constructor Create;
  end;

  { TMSOShapeComment }
  TMSOShapeComment = class(TMSOShape)
    LinkedToRow, LinkedToColumn: Integer;
    Text: WideString;
    Author: WideString;
    RichFormat: AnsiString;
  end;

  { TMSOShapeMap }
  TMSOShapeMap = class
  protected
    FSheetClusters: TList;
    FMaxSPID: Integer;
    FMaxSheetIndex: Integer;
    function GetNonemptyClustersCount: Integer;
    function GetSheetCluster(SheetIndex: Integer): TList;
    function GetSheetMaxSPID(SheetIndex: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddShape(const AShape: TMSOShape);
    property MaxSPID: Integer read FMaxSPID;
    property MaxSheetIndex: Integer read FMaxSheetIndex;
    property ClustersCount: Integer read GetNonemptyClustersCount;
    property SheetCluster[SheetIndex: Integer]: TList read GetSheetCluster;
    property SheetMaxSPID[SheetIndex: Integer]: Integer read GetSheetMaxSPID;
  end;

  { TMSOData }
  TMSOData = class
  protected
    FBLIPs: TList;
    FShapes: TList;
    FShapeMap: TMSOShapeMap;
    FRecord: TMSORecordHeader;
    FCurrentSheetIndex: Integer;
    FLastMSOOBJ: Integer;
    FCurrentSpIsParsed: Boolean;
    function GetBLIP(Index: Integer): TMSOBLIP;
    function GetBLIPCount: Integer;
    function GetShape(Index: Integer): TMSOShape;
    function GetShapesCount: Integer;
    procedure ReadRecordHeader(AStream: TEasyStream);
    procedure ParseBSE(AStream: TEasyStream);
    procedure ParseOPT(AStream: TEasyStream);
    procedure ParseSp(AStream: TEasyStream);
    procedure ParseClientAnchor(AStream: TEasyStream);
    function FindShapeIndexByObjectID(const ObjectID: Integer; const ASheetIndex: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    { read methods }
    procedure AddMSODrawingGroupData(AStream: TEasyStream);
    procedure AddMSODrawingData(AStream: TEasyStream; const ASheetIndex: Integer);
    procedure AddDescribesObjectData(AStream: TEasyStream; const ASheetIndex: Integer);
    procedure AddTextObjectData(AStream: TEasyStream; const ASheetIndex: Integer;
      const ContinueNumber: Byte);
    procedure AddCommentData(AStream: TEasyStream; const ASheetIndex: Integer);
    procedure DeleteUnconfirmedShapes;

    { write methods }
    procedure AddBLIPData(
       const AFileName: WideString;
       const AImageData: TEasyStream;
       var BLIPID: Integer;
       var OriginalWidthPx: Integer;
       var OriginalHeightPx: Integer);

    procedure AddShapeImage(
       const ASheetIndex: Integer;
       const BLIPID: Integer;
       const ColumnFrom         : Integer;
       const ColumnFromAddition : Integer;
       const RowFrom            : Integer;
       const RowFromAddition    : Integer;
       const ColumnTo           : Integer;
       const ColumnToAddition   : Integer;
       const RowTo              : Integer;
       const RowToAddition      : Integer);

    procedure AddShapeComment(
       const ASheetIndex: Integer;
       const LinkedToRow, LinkedToColumn: Integer;
       const Text: WideString;
       const Author: WideString;
       const RichFormat: AnsiString;
       const ColumnFrom         : Integer;
       const ColumnFromAddition : Integer;
       const RowFrom            : Integer;
       const RowFromAddition    : Integer;
       const ColumnTo           : Integer;
       const ColumnToAddition   : Integer;
       const RowTo              : Integer;
       const RowToAddition      : Integer);

    procedure PrepareWriteMSOData;
    procedure WriteMSODataGlobal(AStream: TEasyStream);
    procedure WriteMSODataSheet(AStream: TEasyStream; const ASheetIndex: Integer);

    property BLIP[Index: Integer]: TMSOBLIP read GetBLIP;
    property BLIPCount: Integer read GetBLIPCount;
    property Shape[Index: Integer]: TMSOShape read GetShape;
    property ShapesCount: Integer read GetShapesCount;
  end;

{ Help functions }
function ColumnAdditionToOffsetPx(const ColumnAddition: Integer; ColumnWidthPx: Integer): Integer;
function ColumnOffsetPxToAddition(const OffsetPx: Integer; ColumnWidthPx: Integer): Integer;
function RowAdditionToOffsetPx(const RowAddition: Integer; RowHeightPx: Integer): Integer;
function RowOffsetPxToAddition(const OffsetPx: Integer; RowHeightPx: Integer): Integer;
function RecognizeBLIPType(const ImageData: PAnsiChar): Integer;
procedure SaveImageStreamToFile(const ImageData: TEasyStream;
  const FileName: AnsiString;
  const BLIPType: Integer);


implementation
uses SysUtils
   , Unicode
   , XLSError
   ;

{ Help functions }
function ColumnAdditionToOffsetPx(const ColumnAddition: Integer; ColumnWidthPx: Integer): Integer;
begin
  Result:= round( ( 1.00 * ColumnAddition * ColumnWidthPx) / $400);
end;

function ColumnOffsetPxToAddition(const OffsetPx: Integer; ColumnWidthPx: Integer): Integer;
begin
  if (ColumnWidthPx = 0) then
    Result:= 0
  else
    Result:= round((1.00 * $400 * OffsetPx) / ColumnWidthPx);
end;

function RowAdditionToOffsetPx(const RowAddition: Integer; RowHeightPx: Integer): Integer;
begin
  Result:= round( (1.00 * RowAddition * RowHeightPx) / $100);
end;

function RowOffsetPxToAddition(const OffsetPx: Integer; RowHeightPx: Integer): Integer;
begin
  if (RowHeightPx = 0) then
    Result:= 0
  else
    Result:= round((1.00 * $100 * OffsetPx) / RowHeightPx);
end;

function RecognizeBLIPType(const ImageData: PAnsiChar): Integer;
{ recognizes image type by first 10 bytes }
var
  Buff: array[0..10-1] of Byte;
  FileSign: AnsiString;
begin
  Result:= MSOBLIP_ERROR;
  FillChar(Buff, SizeOf(Buff), 0);
  Move(ImageData^, Buff[0], 10);

  { try BMP }
  FileSign:= 'BM';
  if CompareMem(@FileSign[1], @Buff[0], 2) then
    Result:= MSOBLIP_DIB;
  { try JPEG }
  FileSign:= 'JFIF';
  if CompareMem(@FileSign[1], @Buff[6], 4) then
    Result:= MSOBLIP_JPEG;
  { try PNG }
  FileSign:= 'PNG';
  if CompareMem(@FileSign[1], @Buff[1], 3) then
    Result:= MSOBLIP_PNG;
  { try WMF (only if it has been read from XLS file) }
  FileSign:= #$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF + AnsiChar(MSOBLIP_WMF) +#$FF;
  if CompareMem(@FileSign[1], @Buff[0], 10) then
    Result:= MSOBLIP_WMF;
  { try EMF (only if it has been read from XLS file) }
  FileSign:= #$FF#$FF#$FF#$FF#$FF#$FF#$FF#$FF + AnsiChar(MSOBLIP_EMF) +#$FF;
  if CompareMem(@FileSign[1], @Buff[0], 10) then
    Result:= MSOBLIP_EMF;
end;

procedure SaveImageStreamToFile(const ImageData: TEasyStream;
  const FileName: AnsiString;
  const BLIPType: Integer);
var
  FileSize: Integer;
  FileStream: TStream;
begin
  ImageData.Position:= 0;
  
  { WMF, EMF - skip $34 bytes}
  if (BLIPType = MSOBLIP_EMF) or (BLIPType = MSOBLIP_WMF) then
  begin
    if (ImageData.Size >= $34) then
      ImageData.Position:= $34
    else
      raise EXLSError.Create(EXLS_INVALIDDRAWING);

    if (BLIPType = MSOBLIP_EMF) then
    begin
      ImageData.WriteDWord($088B1F);
      ImageData.WriteDWord($0);
      ImageData.WriteWord($0B00);
      ImageData.Position:= $34;           
    end;
  end;

  { BMP requires some data to be calculated }
  if BLIPType = MSOBLIP_DIB then
  begin
    FileSize:= ImageData.ReadableSize;
    ImageData.Position:= 2;
    ImageData.WriteDWord(FileSize);
    ImageData.Position:= 10;
    ImageData.WriteDWord($36);
    ImageData.Position:= 0;
  end;

  { Save data }
  FileStream := TFileStream.Create(String(FileName), fmCreate);
  try
    FileStream.WriteBuffer(
        (PAnsiChar(ImageData.Memory) + ImageData.Position)^
      , ImageData.Size - ImageData.Position
      );
  finally
    FileStream.Free;
  end;
end;

{ TMSOBLIP }
constructor TMSOBLIP.Create;
begin
  FImageData:= TEasyStream.Create;
  FileName:= '';
  RefCount:= 0;
  OriginalWidthPx:= 0;
  OriginalHeightPx:= 0;
  BLIPID:= BLIPID_NOTASSIGNED;
  BLIPType:= MSOBLIP_ERROR;
  IsEmpty:= False;
end;

destructor TMSOBLIP.Destroy;
begin
  FImageData.Destroy;
  inherited;
end;

constructor TMSOShapeImage.Create;
begin
  inherited;
  BLIPID:= BLIPID_NOTASSIGNED;
end;

{ TMSOShapeMap }
constructor TMSOShapeMap.Create;
begin
  FSheetClusters:= TList.Create;
  FMaxSPID:= 0;
  FMaxSheetIndex:= -1;
end;

destructor TMSOShapeMap.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FSheetClusters.Count - 1 do
    if Assigned(FSheetClusters[I]) then
      TList(FSheetClusters[I]).Destroy;

  FSheetClusters.Destroy;
  inherited;
end;

procedure TMSOShapeMap.AddShape(const AShape: TMSOShape);
var
  SheetIndex, I, SPID: Integer;
  NewCluster: TList;
begin
  SheetIndex:= AShape.SheetIndex;

  { Create new clusters if required }
  for I:= FSheetClusters.Count to SheetIndex do
    FSheetClusters.Add(nil);

  { Get sheet cluster }
  if not Assigned(FSheetClusters[SheetIndex]) then
  begin
    NewCluster:= TList.Create;
    FSheetClusters[SheetIndex]:= NewCluster;
  end;
  
  { Add shape to cluster}
  TList(FSheetClusters[SheetIndex]).Add(AShape);

  { Set SPID }
  SPID:= (SheetIndex + 1) * $400 + TList(FSheetClusters[SheetIndex]).Count;
  AShape.SPID:= SPID;

  { Set ObjectID.
    ObjectID number is an item's number in sheet cluster.
    It is important for MS Excel. }
  AShape.ObjectID:= TList(FSheetClusters[SheetIndex]).Count;

  if (SPID > FMaxSPID) then FMaxSPID:= SPID;
  if (SheetIndex > FMaxSheetIndex) then FMaxSheetIndex:= SheetIndex;
end;

function TMSOShapeMap.GetNonemptyClustersCount: Integer;
var
  I: Integer;
begin
  Result:= 0;
  for I:= 0 to FSheetClusters.Count - 1 do
    if Assigned(FSheetClusters[I]) then
      Result:= Result + 1;
end;

function TMSOShapeMap.GetSheetCluster(SheetIndex: Integer): TList;
begin
  if (SheetIndex>= 0) and (SheetIndex < FSheetClusters.Count) then
    Result:= TList(FSheetClusters[SheetIndex])
  else
    Result:= nil;
end;

function TMSOShapeMap.GetSheetMaxSPID(SheetIndex: Integer): Integer;
begin
  if Assigned(SheetCluster[SheetIndex]) then
    Result:= (SheetIndex + 1) * $400 + SheetCluster[SheetIndex].Count
  else
    Result:= 0;  
end;

{ TMSOData }
constructor TMSOData.Create;
begin
  FBLIPs:= TList.Create;
  FShapes:= TList.Create;
  FShapeMap:= TMSOShapeMap.Create;
  FLastMSOOBJ:= -1;
  FCurrentSpIsParsed:= False;
end;

destructor TMSOData.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FBLIPs.Count - 1 do
    TMSOBLIP(FBLIPs[I]).Destroy;
  FBLIPs.Destroy;

  for I:= 0 to FShapes.Count - 1 do
    TMSOShape(FShapes[I]).Destroy;
  FShapes.Destroy;

  FShapeMap.Destroy;
  inherited;
end;

function TMSOData.GetBLIP(Index: Integer): TMSOBLIP;
begin
  Result:= TMSOBLIP(FBLIPs[Index]);
end;

function TMSOData.GetBLIPCount: Integer;
begin
  Result:= FBLIPs.Count;
end;

function TMSOData.GetShape(Index: Integer): TMSOShape;
begin
  Result:= TMSOShape(FShapes[Index]);
end;

function TMSOData.GetShapesCount: Integer;
begin
  Result:= FShapes.Count;
end;

function TMSOData.FindShapeIndexByObjectID(const ObjectID: Integer; const ASheetIndex: Integer): Integer;
var
  I: Integer;
begin
  Result:= -1;

  for I:= 0 to Self.ShapesCount - 1 do
    if (    (Self.Shape[I].ObjectID = ObjectID)
        and (Self.Shape[I].SheetIndex = ASheetIndex) ) then
    begin
      Result:= I;
      Exit;
    end;
end;

procedure TMSOData.ReadRecordHeader(AStream: TEasyStream);
var
  L: Longword;
begin
  AStream.ReadDWord(L);
  FRecord.Version:= (L and $0F);
  FRecord.Instance:= (L shr 4) and $0FFF;
  FRecord.FBT:= (L shr 16) and $FFFF;

  AStream.ReadDWord(L);
  FRecord.Length:= L;   
end;

procedure TMSOData.ParseBSE(AStream: TEasyStream);
var
  BLIPType: Byte;
  BLIPSize, ImageSize: Longword;
  NameSize: Byte;
  NewBLIP: TMSOBLIP;
  I: Integer;
  SkipBytesInHeader: Word;
begin
  { BSE header

  btWin32: Byte;                 // Required type on Win32
  btMacOS: Byte;                 // Required type on Mac
  rgbUid: array[1..16] of Byte;  // Identifier of blip
  tag: Word;                     // currently unused
  size: Longword;                // Blip size in stream
  cRef: Longword;                // Reference count on the blip
  foDelay: Longword;             // File offset in the delay stream
  usage: Byte;                   // How this blip is used (MSOBLIPUSAGE)
  cbName: Byte;                  // length of the blip name
  unused2: Byte;                 // for the future
  unused3: Byte;                 // for the future

  }
  AStream.SkipBytes(20);
  AStream.ReadDWord(BLIPSize);
  AStream.SkipBytes(9);
  AStream.ReadByte(NameSize);
  AStream.SkipBytes(2);

  BLIPType:= Byte(FRecord.Instance and $0F);

  { Skip null-terminated unicode string }
  if (NameSize > 0) then
    AStream.SkipBytes(NameSize * 2 + 2);

  case BLIPType of
    MSOBLIP_EMF,
    MSOBLIP_WMF:  SkipBytesInHeader:= 8;
    MSOBLIP_DIB,
    MSOBLIP_JPEG,
    MSOBLIP_PNG:  SkipBytesInHeader:= 16 + 9;
    else SkipBytesInHeader := 0;
  end;

  ImageSize:= BLIPSize - SkipBytesInHeader;
  AStream.SkipBytes(SkipBytesInHeader);

  { Create new BLIP in list }
  NewBLIP:= TMSOBLIP.Create;
  NewBLIP.BLIPType:= BLIPType;

  { BLIP record may be empty }
  NewBLIP.IsEmpty:= (BLIPSize = 0);
  
  { Read all data as binary BLIP data }
  if (BLIPSize > 0) then
  begin
    { for BMP add header }
    if (BLIPType = MSOBLIP_DIB) then
    begin
      NewBLIP.ImageData.WriteByte(Byte('B'));
      NewBLIP.ImageData.WriteByte(Byte('M'));
      NewBLIP.ImageData.WriteByte(Byte('K'));
      for I:= 1 to 11 do
        NewBLIP.ImageData.WriteByte(0);
    end;

    { for WMF, EMF add our special 10-byte labels for further parsing }
    if (   (BLIPType = MSOBLIP_EMF)
        or (BLIPType = MSOBLIP_WMF)
       ) then
    begin
      NewBLIP.ImageData.WriteWord($FFFF);
      NewBLIP.ImageData.WriteWord($FFFF);
      NewBLIP.ImageData.WriteWord($FFFF);
      NewBLIP.ImageData.WriteWord($FFFF);

      NewBLIP.ImageData.WriteByte(BlipType);
      NewBLIP.ImageData.WriteByte($FF);
    end;

    NewBLIP.ImageData.CopyFrom(AStream, ImageSize);
  end;

  FBLIPs.Add(NewBLIP);
end;

procedure TMSOData.AddMSODrawingGroupData(AStream: TEasyStream);
begin
  while (AStream.ReadableSize >= 8) do
  begin
    ReadRecordHeader(AStream);

    case FRecord.FBT of
      { Skip containers' headers }
      MSOFBT_DggContainer,
      MSOFBT_BStoreContainer,
      MSOFBT_DgContainer,
      MSOFBT_SpgrContainer,
      MSOFBT_SpContainer,
      MSOFBT_SolverContainer: ;

      { Known FBTs -> read and parse }
      MSOFBT_BSE         : ParseBSE(AStream);

      { Other FBTs -> read and ignore data }
      else                AStream.SkipBytes(FRecord.Length);
    end;
  end;
end;

procedure TMSOData.ParseSp(AStream: TEasyStream);
var
  SPID: Longword;
  ShapeType: Word;
  NewShapeImage: TMSOShapeImage;
  NewShapeComment: TMSOShapeComment;
  NewGenericShape: TMSOShape;
begin
  ShapeType:= FRecord.Instance;
  AStream.ReadDWord(SPID);

  { Skip other bytes }
  AStream.SkipBytes(FRecord.Length - 4);

  FCurrentSpIsParsed:= False;
    
  { Add new shape object }
  if (ShapeType = MSOSPT_TextBox) then
  begin
    NewShapeComment:= TMSOShapeComment.Create;
    NewShapeComment.SheetIndex:= Self.FCurrentSheetIndex;
    NewShapeComment.ObjectID:= OBJECTID_NOTASSIGNED;
    FShapes.Add(NewShapeComment);
    FCurrentSpIsParsed:= True;
  end
  else
  if (ShapeType = MSOSPT_PictureFrame) then
  begin
    NewShapeImage:= TMSOShapeImage.Create;
    NewShapeImage.SheetIndex:= Self.FCurrentSheetIndex;
    NewShapeImage.ObjectID:= OBJECTID_NOTASSIGNED;
    FShapes.Add(NewShapeImage);
    FCurrentSpIsParsed:= True;
  end
  else
  begin
    NewGenericShape:= TMSOShape.Create;
    NewGenericShape.SheetIndex:= Self.FCurrentSheetIndex;
    NewGenericShape.ObjectID:= OBJECTID_NOTASSIGNED;
    FShapes.Add(NewGenericShape);
    FCurrentSpIsParsed:= True;
  end;
end;

procedure TMSOData.ParseOPT(AStream: TEasyStream);
var
  PropertyCount, I: Word;
  PropertyCode: Word;
  PropertyValue: Longword;
  fBid: Boolean;
  fComplex: Boolean;
  StartPosition: Integer;
begin
  StartPosition:= AStream.Position;

  PropertyCount:= FRecord.Instance;
  for I:= 1 to PropertyCount do
    if (AStream.ReadableSize >= 6) then
    begin
      AStream.ReadWord(PropertyCode);
      AStream.ReadDWord(PropertyValue);

      fBid:= ((PropertyCode and $4000) <> 0);
      fComplex:= ((PropertyCode and $8000) <> 0);
      PropertyCode:= (PropertyCode and $3FFF);

      { get BLIP ID}
      if (PropertyCode = FOPTE_pib) then
        if (fBid and (not fComplex)) then
        begin
          { Assign BLIP ID to last shape in list }
          if (Self.ShapesCount > 0 ) then
          begin
            if (Self.Shape[Self.ShapesCount - 1] is TMSOShapeImage) then
              TMSOShapeImage(Self.Shape[Self.ShapesCount - 1]).BLIPID := PropertyValue;
          end;   
        end;

      { ignore other properties so far }
    end;

  { Skip remaining bytes }
  AStream.SkipBytes(FRecord.Length - (AStream.Position - StartPosition));
end;

procedure TMSOData.ParseClientAnchor(AStream: TEasyStream);
var
  Anchor: TMSOClientAnchor;
  W: Word;
begin
  if (AStream.ReadableSize < 18) then
   raise EXLSError.Create(EXLS_INVALIDDRAWING);

  AStream.SkipBytes(2);
   
  AStream.ReadWord(W);
  Anchor.ColumnFrom:=W;
  AStream.ReadWord(W);
  Anchor.ColumnFromAddition:= W;

  AStream.ReadWord(W);
  Anchor.RowFrom:= W;
  AStream.ReadWord(W);
  Anchor.RowFromAddition:= W;

  AStream.ReadWord(W);
  Anchor.ColumnTo:=W;
  AStream.ReadWord(W);
  Anchor.ColumnToAddition:= W;

  AStream.ReadWord(W);
  Anchor.RowTo:= W;
  AStream.ReadWord(W);
  Anchor.RowToAddition:= W;

  { Set anchor to last parsed shape }
  if FCurrentSpIsParsed then
  begin
    if (Self.ShapesCount <= 0) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);
    Self.Shape[Self.ShapesCount - 1].Anchor:= Anchor;
  end;
end;


procedure TMSOData.AddMSODrawingData(AStream: TEasyStream; const ASheetIndex: Integer);
begin
  FCurrentSheetIndex:= ASheetIndex;
  
  while (AStream.ReadableSize >= 8) do
  begin
    ReadRecordHeader(AStream);

    case FRecord.FBT of
      { Skip containers' headers }
      MSOFBT_DggContainer,
      MSOFBT_BStoreContainer,
      MSOFBT_DgContainer,
      MSOFBT_SpgrContainer,
      MSOFBT_SpContainer,
      MSOFBT_SolverContainer: ;

      { Known FBTs -> read and parse }
      MSOFBT_OPT         : ParseOPT(AStream);
      MSOFBT_Sp          : ParseSp(AStream);
      MSOFBT_ClientAnchor: ParseClientAnchor(AStream);

      { Other FBTs -> read and ignore data }
      else                AStream.SkipBytes(FRecord.Length);
    end;
  end;
end;

procedure TMSOData.AddDescribesObjectData(AStream: TEasyStream; const ASheetIndex: Integer);
var
  FT: Word;
  DataSize: Word;
  Data: AnsiString;

  procedure ParseCmo;
  var
    ObjectType: Word;
    ObjectID: Word;
  begin
    if Length(Data) < 4 then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);

    Move(Data[1], ObjectType, 2);
    Move(Data[3], ObjectID, 2);

    { Set ObjectID to last Shape }
    if   (ObjectType = MSOOBJ_Comment)
      or (ObjectType = MSOOBJ_Picture) then
    begin
      if (Self.ShapesCount > 0) then
      begin
        Self.Shape[Self.ShapesCount - 1].ObjectID:= ObjectID;
      end;  
    end;

    FLastMSOOBJ:= ObjectType;
  end;

begin
  while (AStream.ReadableSize >= 4) do
  begin
    AStream.ReadWord(FT);
    AStream.ReadWord(DataSize);
    if DataSize > 0 then
      AStream.ReadString(Data, DataSize)
    else
      Data:= '';

    { Use only ftCmo }
    case FT of
      MSO_ftCmo: ParseCmo;
    end;
  end;
end;

procedure TMSOData.AddTextObjectData(AStream: TEasyStream; const ASheetIndex: Integer;
  const ContinueNumber: Byte);
var
  Unicode: Byte;
  S: AnsiString;
  WS: WideString;
begin
  { Use TXO only if it is related to cell comment}
  if not (FLastMSOOBJ = MSOOBJ_Comment) then
    Exit;

  { text }
  if (ContinueNumber = 1) then
  begin
    AStream.ReadByte(Unicode);
    SetLength(S, AStream.Size - 1);
    AStream.ReadString(S, AStream.Size - 1);

    if (Unicode <> 0) then
      WS:= ANSIWideStringToWideString(S)
    else
      WS:= StringToWideString(S);

    { set text to last comment shape }
    if (Self.ShapesCount <=0 ) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);
    if not (Self.Shape[Self.ShapesCount - 1] is TMSOShapeComment) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);
    TMSOShapeComment(Self.Shape[Self.ShapesCount - 1]).Text:= WS;
  end
  else
  { formatting runs }
  if (ContinueNumber = 2) then
  begin
    SetLength(S, AStream.Size);
    if AStream.Size > 0 then
      AStream.ReadString(S, AStream.Size);

    TMSOShapeComment(Self.Shape[Self.ShapesCount - 1]).RichFormat:= S;
  end;
end;

procedure TMSOData.AddCommentData(AStream: TEasyStream; const ASheetIndex: Integer);
var
  W: Word;
  Row, Column: Integer;
  ObjectID: Integer;
  S: AnsiString;
  WS: WideString;
  Unicode: Byte;
  Len, ShapeIndex: Integer;
begin
  if (AStream.ReadableSize < 10) then
    raise EXLSError.Create(EXLS_INVALIDDRAWING);

  AStream.ReadWord(W);
  Row:= W;
  AStream.ReadWord(W);
  Column:= W;
  AStream.SkipBytes(2);
  AStream.ReadWord(W);
  ObjectID:= W;

  AStream.ReadWord(W);
  Len:= W;
  if (Len > 0) then
  begin
    AStream.ReadByte(Unicode);
    if (Unicode <> 0) then
    begin
      SetLength(S, Len * 2);
      AStream.ReadString(S, Len * 2);
      WS:= ANSIWideStringToWideString(S);
    end
    else
    begin
      SetLength(S, Len);
      AStream.ReadString(S, Len);
      WS:= StringToWideString(S);
    end;
  end
  else
    WS:= '';
    
  { find shape by ObjectID }
  ShapeIndex:= FindShapeIndexByObjectID(ObjectID, ASheetIndex);
  if (ShapeIndex < 0) then
    raise EXLSError.Create(EXLS_INVALIDDRAWING);
  if not (Self.Shape[ShapeIndex] is TMSOShapeComment) then
    raise EXLSError.Create(EXLS_INVALIDDRAWING);

  with TMSOShapeComment(Self.Shape[ShapeIndex]) do
  begin
    Author:= WS;
    LinkedToRow:= Row;
    LinkedToColumn:= Column;
    SheetIndex:= ASheetIndex;
  end;
end;

procedure TMSOData.DeleteUnconfirmedShapes;
var
  I: Integer;
  ToDelete: Boolean;
  BLIPID: Integer;
begin
  { After file reading some shapes may have no ObjectID.

    - TextBox have the same shape data as Comment. But its shape data
      does not contain ObjectID, because BIFF_OBJ for this shape
      have MSOOBJ_Text object type, not MSOOBJ_Comment.

    - Picture may mot contain BLIPID in OPT array

    - BLIP may be empty

    - Shape is not BLIP or comment

    Delete such shapes here. Deleting in other place is incorrect, because
    shapes' order is important, and "last shape" is used sometimes.
   }

  for I:= Self.ShapesCount - 1 downto 0 do
  begin
    ToDelete:= False;

    if (Self.Shape[I].ObjectID = OBJECTID_NOTASSIGNED) then
      ToDelete:= True;

    if not (  (Self.Shape[I] is TMSOShapeImage)
           or (Self.Shape[I] is TMSOShapeComment)
           ) then
      ToDelete:= True;

    if (Self.Shape[I] is TMSOShapeImage) then
    begin
      { BLIPID is 1-based here}
      BLIPID:= TMSOShapeImage(Self.Shape[I]).BLIPID;

      if (BLIPID <= 0) or (BLIPID > Self.BLIPCount) then
        ToDelete:= True;

      if Self.BLIP[BLIPID - 1].IsEmpty then
        ToDelete:= True;
    end;

    if ToDelete then
    begin
      Shape[I].Destroy;
      FShapes.Delete(I);
    end;
  end;
end;

procedure TMSOData.AddBLIPData(
   const AFileName: WideString;
   const AImageData: TEasyStream;
   var BLIPID: Integer;
   var OriginalWidthPx: Integer;
   var OriginalHeightPx: Integer);
var
  F: TFileStream;
  InStream: TStream;
  OutStream: TEasyStream;
  BLIPType: Integer;
  BLIP: TMSOBLIP;

  function FindExistingBLIP: Boolean;
  var
    BLIPIndex: Integer;
  begin
    if (AFileName <> '') then
    begin
      for BLIPIndex:= 0 to BLIPCount - 1 do
      begin
        if (Self.BLIP[BLIPIndex].FileName = AFileName) then
        begin
          BLIPID:= BLIPIndex;
          Break;
        end
      end
    end
    else
    begin
      for BLIPIndex:= 0 to BLIPCount - 1 do
      begin
        if (Self.BLIP[BLIPIndex].ImageData.Size = OutStream.Size) then
        begin
          Self.BLIP[BLIPIndex].ImageData.Position:= 0;
          AImageData.Position:= 0;
          if CompareMem(Self.BLIP[BLIPIndex].ImageData.Memory
                      , OutStream.Memory
                      , OutStream.Size) then
          begin
            BLIPID:= BLIPIndex;
            Break;
          end
        end;
      end;
    end ;

    Result:= (BLIPID >=0);
  end;

  procedure ParseImageData;
  var
    Buff: array[0..50000-1] of Byte;
    BytesRead, I: Integer;
    W: Word;
    B1, B2: Byte;
  begin
    FillChar(Buff, SizeOf(Buff), 0);
    InStream.ReadBuffer(Buff[0], 10);

    BLIPType:= RecognizeBLIPType(@Buff[0]);
    if BLIPType = MSOBLIP_ERROR then
      raise Exception.Create('Unsupported image file format');

    case BLIPType of
      MSOBLIP_DIB:
        begin
          { read BMP }
          InStream.ReadBuffer(Buff[0], 4);
          { header size }
          InStream.ReadBuffer(I, 4);
          OutStream.WriteBuffer(I, 4);
          { width }
          InStream.ReadBuffer(I, 4);
          OriginalWidthPx:= I;
          OutStream.WriteBuffer(I, 4);
          { height }
          InStream.ReadBuffer(I, 4);
          OriginalHeightPx:= I;
          OutStream.WriteBuffer(I, 4);

          while (InStream.Position < InStream.Size) do
          begin
            BytesRead:= InStream.Read(Buff[0], SizeOf(Buff));
            if BytesRead <> 0 then
              OutStream.WriteBuffer(Buff, BytesRead);
          end;
        end;
      MSOBLIP_JPEG:
        begin
          { 10 bytes already read }
          OutStream.WriteBuffer(Buff, 10);

          { Find image size: find a section with marker 'FF Cx'
          }
          B1:= 0;
          B2:= 0;
          while (InStream.Position < InStream.Size)
            and (not ((B1 = $FF) and (B2 and $F0 = $C0))) do
          begin
            B1:= B2;
            InStream.ReadBuffer(B2, 1);
            OutStream.WriteBuffer(B2, 1);
          end;

          if ((InStream.Position = InStream.Size)) then
            raise Exception.Create('Invalid JPEG file format');

          InStream.ReadBuffer(Buff[0], 3);
          OutStream.WriteBuffer(Buff, 3);

          { height }
          InStream.ReadBuffer(W, 2);
          OriginalHeightPx:= Swap(W);
          OutStream.WriteBuffer(W, 2);
          { width }
          InStream.ReadBuffer(W, 2);
          OriginalWidthPx:= Swap(W);
          OutStream.WriteBuffer(W, 2);

          while (InStream.Position < InStream.Size) do
          begin
            BytesRead:= InStream.Read(Buff[0], SizeOf(Buff));
            if BytesRead <> 0 then
              OutStream.WriteBuffer(Buff, BytesRead);
          end;
        end;
      MSOBLIP_PNG:
        begin
          { 10 bytes already read }
          OutStream.WriteBuffer(Buff, 10);

          { skip 8 bytes }
          InStream.ReadBuffer(Buff[0], 8);
          OutStream.WriteBuffer(Buff, 8);

          { width }
          InStream.ReadBuffer(W, 2);
          OriginalWidthPx:= Swap(W);
          OutStream.WriteBuffer(W, 2);

          { skip 2 bytes }
          InStream.ReadBuffer(Buff[0], 2);
          OutStream.WriteBuffer(Buff, 2);

          { height }
          InStream.ReadBuffer(W, 2);
          OriginalHeightPx:= Swap(W);
          OutStream.WriteBuffer(W, 2);

          while (InStream.Position < InStream.Size) do
          begin
            BytesRead:= InStream.Read(Buff[0], SizeOf(Buff));
            if BytesRead <> 0 then
              OutStream.WriteBuffer(Buff, BytesRead);
          end;
        end;
      MSOBLIP_WMF,
      MSOBLIP_EMF :
        begin
          { 10 bytes already read, ignore them }

          { width }
          OriginalWidthPx:= 1;
          { height }
          OriginalHeightPx:= 1;

          while (InStream.Position < InStream.Size) do
          begin
            BytesRead:= InStream.Read(Buff[0], SizeOf(Buff));
            if BytesRead <> 0 then
              OutStream.WriteBuffer(Buff, BytesRead);
          end;
        end;
    end;
  end;

begin
  F:= nil;
  BLIPID:= -1;
  OriginalWidthPx:= 0;
  OriginalHeightPx:= 0;
  
  { Open file or stream }
  if (AFileName <> '' ) then
  begin
    { open image file for read only }
    F:= TFileStream.Create(AFileName, fmOpenRead);
    InStream:= F;
  end
  else
  begin
    InStream:= AImageData;
    InStream.Position:= 0;
  end;

  OutStream:= TEasyStream.Create;

  try
    { Parse image }
    ParseImageData;

    { Try to find existing BLIP }
    if FindExistingBLIP then
    begin
      OriginalWidthPx:= Self.BLIP[BLIPID].OriginalWidthPx;
      OriginalHeightPx:= Self.BLIP[BLIPID].OriginalHeightPx;
    end
    else
    begin
      { create new BLIP }
      BLIP:= TMSOBLIP.Create;
      Self.FBLIPs.Add(BLIP);
      BLIP.BLIPType:= BLIPType;
      BLIP.FileName:= AFileName;
      BLIP.OriginalWidthPx:= OriginalWidthPx;
      BLIP.OriginalHeightPx:= OriginalHeightPx;
      BLIPID:= Self.BLIPCount - 1;
      
      { Copy data }
      OutStream.Position:= 0;
      BLIP.ImageData.CopyFrom(OutStream, OutStream.Size);
    end;
  finally
    if Assigned(F) then F.Destroy;
    OutStream.Destroy;
  end;
end;

procedure TMSOData.AddShapeImage(
   const ASheetIndex: Integer;
   const BLIPID: Integer;
   const ColumnFrom         : Integer;
   const ColumnFromAddition : Integer;
   const RowFrom            : Integer;
   const RowFromAddition    : Integer;
   const ColumnTo           : Integer;
   const ColumnToAddition   : Integer;
   const RowTo              : Integer;
   const RowToAddition      : Integer);
var
  ShapeImage: TMSOShapeImage;
begin
  ShapeImage:= TMSOShapeImage.Create;
  Self.FShapes.Add(ShapeImage);

  ShapeImage.BLIPID:= BLIPID;
  ShapeImage.SheetIndex:= ASheetIndex;
  ShapeImage.ObjectID:= Self.ShapesCount;
  ShapeImage.Anchor.ColumnFrom         := ColumnFrom;
  ShapeImage.Anchor.ColumnFromAddition := ColumnFromAddition;
  ShapeImage.Anchor.RowFrom            := RowFrom;
  ShapeImage.Anchor.RowFromAddition    := RowFromAddition;
  ShapeImage.Anchor.ColumnTo           := ColumnTo;
  ShapeImage.Anchor.ColumnToAddition   := ColumnToAddition;
  ShapeImage.Anchor.RowTo              := RowTo;
  ShapeImage.Anchor.RowToAddition      := RowToAddition;

  { Inc BLIP references }
  BLIP[BLIPID].RefCount:= BLIP[BLIPID].RefCount + 1;
end;

procedure TMSOData.AddShapeComment(
   const ASheetIndex: Integer;
   const LinkedToRow, LinkedToColumn: Integer;
   const Text: WideString;
   const Author: WideString;
   const RichFormat: AnsiString;
   const ColumnFrom         : Integer;
   const ColumnFromAddition : Integer;
   const RowFrom            : Integer;
   const RowFromAddition    : Integer;
   const ColumnTo           : Integer;
   const ColumnToAddition   : Integer;
   const RowTo              : Integer;
   const RowToAddition      : Integer);
var
  ShapeComment: TMSOShapeComment;
begin
  ShapeComment:= TMSOShapeComment.Create;
  Self.FShapes.Add(ShapeComment);
  ShapeComment.SheetIndex:= ASheetIndex;
  ShapeComment.ObjectID:= Self.ShapesCount;
  ShapeComment.LinkedToRow:= LinkedToRow;
  ShapeComment.LinkedToColumn:= LinkedToColumn;
  ShapeComment.Text:= Text;
  ShapeComment.Author:= Author;
  ShapeComment.RichFormat:= RichFormat;

  ShapeComment.Anchor.ColumnFrom         := ColumnFrom;
  ShapeComment.Anchor.ColumnFromAddition := ColumnFromAddition;
  ShapeComment.Anchor.RowFrom            := RowFrom;
  ShapeComment.Anchor.RowFromAddition    := RowFromAddition;
  ShapeComment.Anchor.ColumnTo           := ColumnTo;
  ShapeComment.Anchor.ColumnToAddition   := ColumnToAddition;
  ShapeComment.Anchor.RowTo              := RowTo;
  ShapeComment.Anchor.RowToAddition      := RowToAddition;
end;

procedure TMSOData.PrepareWriteMSOData;
var
  I: Integer;
begin
  { Fill shapes map }
  for I:= 0 to Self.ShapesCount - 1 do
    FShapeMap.AddShape(Shape[I]);
end;

procedure TMSOData.WriteMSODataGlobal(AStream: TEasyStream);
const
  Opt: array[0..17] of Byte =
    ($BF, $00, $08, $00, $08, $00, $81, $01, $41, $00, $00, $08, $C0, $01, $40, $00, $00, $08);
  SplitMenuColors: array[0..15] of Byte =
    ($0D, $00, $00, $08, $0C, $00, $00, $08, $17, $00, $00, $08, $F7, $00, $00, $10);
var
  CurrentPosition: Longint;
  PositionDggSize: Longint;
  PositionBStoreSize: Longint;
  I: Integer;
  ClustersCount: Integer;

  procedure WriteBLIP(BLIP: TMSOBLIP);
  var
    PositionBSESize: Longint;
    UID: TGUID;
    BLIPSize: Longint;
  begin

    AStream.WriteWord(BLIP.BLIPType * $10 + 2);

    AStream.WriteWord(MSOFBT_BSE);
    PositionBSESize:= AStream.Position;
    AStream.WriteDWord(0);

    { BLIP type }
    AStream.WriteByte(BLIP.BLIPType);
    AStream.WriteByte(BLIP.BLIPType);

    { magic UID }
    FillChar(UID, sizeof(UID), 0);
    AStream.WriteBytes(@UID, SizeOf(UID));

    { tag - unused }
    AStream.WriteWord($FF);

    case BLIP.BLIPType of
      MSOBLIP_EMF,
      MSOBLIP_WMF: BLIPSize:= BLIP.ImageData.Size + 8;
      else         BLIPSize:= BLIP.ImageData.Size + 9 + 16;
    end;

    AStream.WriteDWord(BLIPSize);
    AStream.WriteDWord(BLIP.RefCount);
    AStream.WriteDWord(0);
    AStream.WriteDWord(0);

    { BLIP signature }
    case BLIP.BLIPType of
      MSOBLIP_DIB : AStream.WriteWord(MSOBLIPSIG_DIB);
      MSOBLIP_JPEG: AStream.WriteWord(MSOBLIPSIG_JPEG);
      MSOBLIP_PNG : AStream.WriteWord(MSOBLIPSIG_PNG);
      MSOBLIP_WMF : AStream.WriteWord(MSOBLIPSIG_WMF);
      MSOBLIP_EMF : AStream.WriteWord(MSOBLIPSIG_EMF);
    end;
    AStream.WriteWord(MSOFBT_Blip_START + BLIP.BLIPType);
    AStream.WriteDWord(BLIPSize - 8);

    if not (   ( BLIP.BLIPType = MSOBLIP_EMF )
            or ( BLIP.BLIPType = MSOBLIP_WMF )
            ) then
    begin
      AStream.WriteBytes(@UID, SizeOf(UID));
      AStream.WriteByte($FF);
    end;
    
    BLIP.ImageData.Seek(0, soFromBeginning);
    AStream.CopyFrom(BLIP.ImageData, BLIP.ImageData.Size);

    { BSE end - now we can save BSE size }
    CurrentPosition:= AStream.Position;
    AStream.Position:= PositionBSESize;
    AStream.WriteDWord(CurrentPosition - PositionBSESize - 4);
    AStream.Position := CurrentPosition;
  end;

begin
  { If nothing to write then exit }
  if (Self.ShapesCount = 0) then Exit;

  { dgg container }
  AStream.WriteWord(MSOInstContainer);
  AStream.WriteWord(MSOFBT_DggContainer);
  PositionDggSize:= AStream.Position;
  AStream.WriteDWord(0);

  { dgg }
  ClustersCount:= FShapeMap.ClustersCount;
  
  AStream.WriteWord(0);
  AStream.WriteWord(MSOFBT_Dgg);
  AStream.WriteDWord(16 + ClustersCount * 8);

  AStream.WriteDWord(FShapeMap.MaxSPID);                { max SPID }
  AStream.WriteDWord(ClustersCount + 1);                { number of ID clusters + 1}
  AStream.WriteDWord(Self.ShapesCount + ClustersCount); { shapes count }
  AStream.WriteDWord(1);                                { drawings count }

  for I:= 0 to FShapeMap.FSheetClusters.Count - 1 do
  begin
    if Assigned(FShapeMap.FSheetClusters[I]) then
    begin
      AStream.WriteDWord(I + 1); { Sheet index }
      AStream.WriteDWord(TList(FShapeMap.FSheetClusters[I]).Count + 1); { Shapes count }
    end;  
  end;

  { bstore container }
  if (Self.BLIPCount > 0) then
  begin
    AStream.WriteWord(MSOInstContainer + (Self.BLIPCount shl 4));
    AStream.WriteWord(MSOFBT_BstoreContainer);
    PositionBStoreSize:= AStream.Position;
    AStream.WriteDWord(0);

    { BLIPs }
    for I:= 0 to Self.BLIPCount - 1 do
      WriteBLIP(BLIP[I]);

    { BStore end - now we can save BStore size }
    CurrentPosition:= AStream.Position;
    AStream.Position:= PositionBStoreSize;
    AStream.WriteDWord(CurrentPosition - PositionBStoreSize - 4);
    AStream.Position := CurrentPosition;
  end;
  
  { msofbtOPT }
  AStream.WriteWord($33);
  AStream.WriteWord(MSOFBT_OPT);
  AStream.WriteDWord(SizeOf(Opt));
  AStream.WriteBytes(@Opt[0], SizeOf(Opt));

  { msofbtSplitMenuColors }
  AStream.WriteWord($40);
  AStream.WriteWord(MSOFBT_SplitMenuColors);
  AStream.WriteDWord(SizeOf(SplitMenuColors));
  AStream.WriteBytes(@SplitMenuColors[0], SizeOf(SplitMenuColors));

  { Dgg end - now we can save Dgg size }
  CurrentPosition:= AStream.Position;
  AStream.Position:= PositionDggSize;
  AStream.WriteDWord(CurrentPosition - PositionDggSize - 4);
  AStream.Position := CurrentPosition;
end;

procedure TMSOData.WriteMSODataSheet(AStream: TEasyStream; const ASheetIndex: Integer);
var
  SheetShapesList: TList;
  I: Integer;
  Buff: array[0..99] of Byte;
  PositionDgContainerSize: Integer;
  BeginDgPosition, BeginSpgrPosition: Integer;
  CurrentPosition: Integer;
  DgContainerSize: Integer;

  DgRecordSize: Integer;
  PositionDgRecordSize: Integer;

  SpContainerSize: Integer;
  PositionSpContainerSize: Integer;

  SpgrContainerSize: Integer;
  PositionSpgrContainerSize: Integer;

  DrawHeaderSaved: Boolean;

  procedure WriteDrawHeader;
  var
    SheetMaxSPID: Integer;
  begin
    DrawHeaderSaved:= True;

    { Dg container }
    AStream.WriteWord(MSOInstContainer);
    AStream.WriteWord(MSOFBT_DgContainer);
    PositionDgContainerSize:= AStream.Position;
    AStream.WriteDWord(0); { container size will be saved later }

    BeginDgPosition:= AStream.Position;

    AStream.WriteWord($10);
    AStream.WriteWord(MSOFBT_Dg);
    AStream.WriteDWord($08);
    AStream.WriteDWord(Self.ShapesCount + 1); { shapes count + 1}
    SheetMaxSPID:= Self.FShapeMap.SheetMaxSPID[ASheetIndex];
    AStream.WriteDWord(SheetMaxSPID);         { max SPID }

    { Spgr container }
    AStream.WriteWord(MSOInstContainer);
    AStream.WriteWord(MSOFBT_SpgrContainer);
    PositionSpgrContainerSize:= AStream.Position;
    AStream.WriteDWord(0);               { size will be saved later }

    BeginSpgrPosition:= AStream.Position;

    AStream.WriteWord(MSOInstContainer);
    AStream.WriteWord(MSOFBT_SpContainer);
    AStream.WriteDWord($28);

    AStream.WriteWord($01);
    AStream.WriteWord(MSOFBT_Spgr);
    AStream.WriteDWord($10);
    FillChar(Buff, $10, 0);
    AStream.WriteBytes(@Buff[0], $10);

    AStream.WriteWord($02);   { shape type = msosptNotPrimitive }
    AStream.WriteWord(MSOFBT_Sp);
    AStream.WriteDWord($08);
    AStream.WriteDWord($400 * (ASheetIndex + 1)); { SPID }
    AStream.WriteDWord($05);  { flags - This is the topmost group shape }
  end;

  procedure WriteShapeAnchor(const AShape: TMSOShape);
  var
    W: Word;
  begin
    AStream.WriteWord(0);
    AStream.WriteWord(MSOFBT_ClientAnchor);
    AStream.WriteDWord($12);
    AStream.WriteWord($02); 
    W:= AShape.Anchor.ColumnFrom;
    AStream.WriteWord(W);
    W:= AShape.Anchor.ColumnFromAddition;
    AStream.WriteWord(W);
    W:= AShape.Anchor.RowFrom;
    AStream.WriteWord(W);
    W:= AShape.Anchor.RowFromAddition;
    AStream.WriteWord(W);
    W:= AShape.Anchor.ColumnTo;
    AStream.WriteWord(W);
    W:= AShape.Anchor.ColumnToAddition;
    AStream.WriteWord(W);
    W:= AShape.Anchor.RowTo;
    AStream.WriteWord(W);
    W:= AShape.Anchor.RowToAddition;
    AStream.WriteWord(W);
  end;
  
  procedure WriteShapeImage(const AShapeImage: TMSOShapeImage);
  var
    BLIPID: Integer;
    SFileName: AnsiString;
    FileName: WideString;
  begin
    { find item index in BLIP list }
    BLIPID:= AShapeImage.BLIPID;

    { BIFF_MSODRAWING }
    AStream.WriteWord(BIFF_MSODRAWING);
    PositionDgRecordSize:= AStream.Position;
    AStream.WriteWord(0); { size will be saved later }

    if not DrawHeaderSaved then
      WriteDrawHeader
    else
    begin
      BeginDgPosition:= AStream.Position;
      BeginSpgrPosition:= AStream.Position;
    end;

    { common for all images }
    AStream.WriteWord(MSOInstContainer);
    AStream.WriteWord(MSOFBT_SpContainer);
    PositionSpContainerSize:= AStream.Position;
    AStream.WriteDWord(0);             { size will be saved later }

    AStream.WriteWord($4B2);           { shape type = msosptPictureFrame }
    AStream.WriteWord(MSOFBT_Sp);
    AStream.WriteDWord($08);
    AStream.WriteDWord(AShapeImage.SPID); { SPID }
    AStream.WriteDWord($0A00);         { flags }

    { options: BLIP ID and file name }
    FileName:= Self.BLIP[BLIPID].FileName;
    SFileName:= WideStringToANSIWideString(FileName) + #0#0;  { 0-terminated}

    AStream.WriteWord($23);
    AStream.WriteWord(MSOFBT_OPT);
    AStream.WriteDWord(6 + 6 + Length(SFileName));

    AStream.WriteWord($4104);          { property: BLIP ID }
    AStream.WriteDWord(BLIPID + 1);

    AStream.WriteWord($C105);          { property: BLIP file name }
    AStream.WriteDWord(Length(SFileName));
    AStream.WriteBytes(@SFileName[1], Length(SFileName));

    { Shape anchor }
    WriteShapeAnchor(AShapeImage);

    AStream.WriteWord(0);
    AStream.WriteWord(MSOFBT_ClientData);
    AStream.WriteDWord(0);

    { Sp container size }
    CurrentPosition:= AStream.Position;
    SpContainerSize:= CurrentPosition - PositionSpContainerSize - 4;
    AStream.Position:= PositionSpContainerSize;
    AStream.WriteDWord(SpContainerSize);
    AStream.Position:= CurrentPosition;

    { Spgr container size }
    SpgrContainerSize:= SpgrContainerSize + (AStream.Position - BeginSpgrPosition);
    { Dg container size }
    DgContainerSize:= DgContainerSize + (AStream.Position - BeginDgPosition);

    { record size }
    CurrentPosition:= AStream.Position;
    DgRecordSize:= CurrentPosition - PositionDgRecordSize - 2;
    AStream.Position:= PositionDgRecordSize;
    AStream.WriteWord(DgRecordSize);
    AStream.Position:= CurrentPosition;

    { BIFF_OBJ }
    AStream.WriteWord(BIFF_OBJ);
    AStream.WriteWord($26);
    
    { cmo }
    AStream.WriteWord($15);
    AStream.WriteWord($12);
    AStream.WriteWord(MSOOBJ_Picture);       { object type = picture }
    AStream.WriteWord(AShapeImage.ObjectID); { object id }
    AStream.WriteWord($6011); { flags }
    FillChar(Buff, 12, 0);
    AStream.WriteBytes(@Buff[0], 12);

    { clipboard format }
    AStream.WriteWord($7);
    AStream.WriteWord($2);
    AStream.WriteWord($FFFF);

    { picture options }
    AStream.WriteWord($08);
    AStream.WriteWord($02);
    AStream.WriteWord($01);

    { end }
    AStream.WriteWord(0);
    AStream.WriteWord(0);
  end;

  procedure WriteContainersSize;
  begin
    CurrentPosition:= AStream.Position;
    { write Spgr container size }
    AStream.Position:= PositionSpgrContainerSize;
    AStream.WriteDWord(SpgrContainerSize);
    AStream.Position:= CurrentPosition;

    { write container size }
    AStream.Position:= PositionDgContainerSize;
    AStream.WriteDWord(DgContainerSize);
    AStream.Position:= CurrentPosition;
  end;

  procedure WriteShapeComment(const AShapeComment: TMSOShapeComment);
  const
    ftNtsData: array[0..21] of Byte =
      ($38, $98, $EB, $79, $19, $2D, $92, $42, $BE, $49, $77, $64, $E2, $C4, $18, $ED,
       $00, $00, $10, $00, $00, $00);
    optData: array[0..53] of Byte =
      ($80, $00, $E8, $1A, $ED, $00, $BF, $00, $08, $00, $08, $00, $58, $01, $00, $00,
       $00, $00, $81, $01, $50, $00, $00, $08, $83, $01, $50, $00, $00, $08, $BF, $01,
       $10, $00, $11, $00, $01, $02, $00, $00, $00, $00, $3F, $02, $03, $00, $03, $00,
       $BF, $03, $02, $00, $0A, $00);
  var
    I: Integer;
    S: AnsiString;
  begin
    { BIFF_MSODRAWING }
    AStream.WriteWord(BIFF_MSODRAWING);
    PositionDgRecordSize:= AStream.Position;
    AStream.WriteWord(0); { size will be saved later }

    if not DrawHeaderSaved then
      WriteDrawHeader
    else
    begin
      BeginDgPosition:= AStream.Position;
      BeginSpgrPosition:= AStream.Position;
    end;

    { common for all images }
    AStream.WriteWord(MSOInstContainer);
    AStream.WriteWord(MSOFBT_SpContainer);
    PositionSpContainerSize:= AStream.Position;
    AStream.WriteDWord(0);             { size will be saved later }

    AStream.WriteWord($CA2);           { shape type = msosptTextBox }
    AStream.WriteWord(MSOFBT_Sp);
    AStream.WriteDWord($08);
    AStream.WriteDWord(AShapeComment.SPID); { SPID }
    AStream.WriteDWord($0A00);         { flags }

    { properties }
    AStream.WriteWord($93);
    AStream.WriteWord(MSOFBT_OPT);
    AStream.WriteDWord($36);
    AStream.WriteBytes(@optData[0], 54);

    { Shape anchor }
    WriteShapeAnchor(AShapeComment);

    AStream.WriteWord(0);
    AStream.WriteWord(MSOFBT_ClientData);
    AStream.WriteDWord(0);

    { Sp container size }
    CurrentPosition:= AStream.Position;
    SpContainerSize:= CurrentPosition - PositionSpContainerSize - 4 + 8;
    AStream.Position:= PositionSpContainerSize;
    AStream.WriteDWord(SpContainerSize);
    AStream.Position:= CurrentPosition;

    { Spgr container size }
    SpgrContainerSize:= SpgrContainerSize + (AStream.Position - BeginSpgrPosition) + 8;
    { Dg container size }
    DgContainerSize:= DgContainerSize + (AStream.Position - BeginDgPosition) + 8;

    { record size }
    CurrentPosition:= AStream.Position;
    DgRecordSize:= CurrentPosition - PositionDgRecordSize - 2;
    AStream.Position:= PositionDgRecordSize;
    AStream.WriteWord(DgRecordSize);
    AStream.Position:= CurrentPosition;

    { BIFF_OBJ }
    AStream.WriteWord(BIFF_OBJ);
    AStream.WriteWord(52);
    
    { cmo }
    AStream.WriteWord($15);
    AStream.WriteWord($12);
    AStream.WriteWord(MSOOBJ_Comment);       { object type = comment }
    AStream.WriteWord(AShapeComment.ObjectID); { object id }
    AStream.WriteWord($4011); { flags } 
    FillChar(Buff, 12, 0);
    AStream.WriteBytes(@Buff[0], 12);

    { ftNts (Note structure)}
    AStream.WriteWord($0D);
    AStream.WriteWord($16);
    AStream.WriteBytes(@ftNtsData[0], 22);

    { end }
    AStream.WriteWord(0);
    AStream.WriteWord(0);

    { BIFF_BIFF_MSODRAWING - client textbox }
    AStream.WriteWord(BIFF_MSODRAWING);
    AStream.WriteWord(8);
    AStream.WriteWord(0);
    AStream.WriteWord(MSOFBT_ClientTextbox);
    AStream.WriteDWord(0);

    { BIFF_TXO }
    AStream.WriteWord(BIFF_TXO);
    AStream.WriteWord(18);
    AStream.WriteWord($212);  { options }
    AStream.WriteWord($0);    { orientation }
    for I:= 1 to 6 do
      AStream.WriteByte(0);
    AStream.WriteWord(Length(AShapeComment.Text));
    AStream.WriteWord(Length(AShapeComment.RichFormat));
    AStream.WriteDWord($0);  {options}

    { BIFF_CONTINUE }
    S:= WideStringToANSIWideString(AShapeComment.Text);
    AStream.WriteWord(BIFF_CONTINUE);
    AStream.WriteWord(1 + Length(S));
    AStream.WriteByte(1);    
    AStream.WriteBytes(@S[1], Length(S));

    S:= AShapeComment.RichFormat;
    AStream.WriteWord(BIFF_CONTINUE);
    AStream.WriteWord(Length(S));
    AStream.WriteBytes(@S[1], Length(S));
  end;

  procedure WriteNotes;
  var
    I: Integer;
    S: AnsiString;
    ShapeComment: TMSOShapeComment;
  begin
    for I:= 0 to SheetShapesList.Count - 1 do
    begin
      if (TMSOShape(SheetShapesList[I]) is TMSOShapeComment) then
      begin
        ShapeComment:= TMSOShapeComment(SheetShapesList[I]);
        S:= WideStringToANSIWideString(ShapeComment.Author);
        AStream.WriteWord(BIFF_NOTE);
        AStream.WriteWord(Length(S) + 13);
        AStream.WriteWord(ShapeComment.LinkedToRow);
        AStream.WriteWord(ShapeComment.LinkedToColumn);
        AStream.WriteWord(0);  { options }
        AStream.WriteWord(ShapeComment.ObjectID);

        AStream.WriteWord(Length(ShapeComment.Author));
        AStream.WriteByte(1);  { Unicode }
        AStream.WriteBytes(@S[1], Length(S));
        AStream.WriteWord(0);  { 0-terminated string }
      end;
    end;
  end;

begin
  SheetShapesList:= FShapeMap.SheetCluster[ASheetIndex];

  { If nothing to write then exit }
  if not Assigned(SheetShapesList) then
    Exit;

  { Init containers' sizes }
  DgContainerSize:= 0;
  SpgrContainerSize:= 0;
  PositionDgContainerSize:= 0;
  PositionSpgrContainerSize:= 0;
  DrawHeaderSaved:= False;

  { Write shapes}
  for I:= 0 to SheetShapesList.Count - 1 do
  begin
    if (TMSOShape(SheetShapesList[I]) is TMSOShapeImage) then
      WriteShapeImage(TMSOShapeImage(SheetShapesList[I]))
    else
    if (TMSOShape(SheetShapesList[I]) is TMSOShapeComment) then
      WriteShapeComment(TMSOShapeComment(SheetShapesList[I]));
  end;

  { Write containers' sizes }
  WriteContainersSize;

  { Write cell comment NOTE records}
  WriteNotes;
end;

end.
