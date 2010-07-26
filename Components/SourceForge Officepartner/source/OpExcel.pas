(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

{$IFDEF DCC6ORLATER}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

unit OpExcel;

interface

uses Windows, Messages, SysUtils, Classes, stdctrls, Graphics, Controls, Forms,
  ComObj, Dialogs, ActiveX,
  OpXLXP,                                                            {!!.62}
  OpShared, OpModels,
  OpOfcXP,                                                           {!!.62}
  OleCtrls {$IFDEF DCC6ORLATER}, Variants {$ENDIF};

type
  {: Use ExcelRange to avoid name clashes with Word Ranges}
  ExcelRange = type OpXLXP.Range;                                    {!!.62}
  {: Use ExcelWindow to avoid name clashes with Word Windows}
  ExcelWindow = type OpXLXP.Window_;                                 {!!.62}

  {: Exception thrown when invalid Range addresses are used. A well formed address
     is either a cell reference (e.g. A1) or a start/end pair (e.g. A1:C17).}
  ERangeException = class(Exception);


  {OfficePartner Cell Aligment and Orientation types}
  TOpXlCellOrientation = (xlcoDownward, xlcoHorizontal, xlcoUpward, xlcoVertical,
                          xlcoRotated);
  TOpXlCellHorizAlign = (xlchaGeneral, xlchaLeft, xlchaCenter, xlchaRight,
                         xlchaFill, xlchaJustify, xlchaCenterAcrossSelection);
  TOpXlCellVertAlign = (xlcvaTop, xlcvaCenter, xlcvaBottom, xlcvaJustify,
                        xlcvaDistributed);
  TOpXlInteriorPatterns = (xlipPatternAutomatic, xlipPatternChecker,
          xlipPatternCrissCross, xlipPatternDown, xlipPatternGray16,
          xlipPatternGray25, xlipPatternGray50, xlipPatternGray75, xlipPatternGray8,
          xlipPatternGrid, xlipPatternHorizontal, xlipPatternLightDown,
          xlipPatternLightHorizontal, xlipPatternLightUp, xlipPatternLightVertical,
          xlipPatternNone, xlipPatternSemiGray75, xlipPatternSolid, xlipPatternUp,
          xlipPatternVertical);
  TOpXlBorderLineStyles = (xlblsContinuous, xlblsDash, xlblsDashDot, xlblsDashDotDot,
                           xlblsDot, xlblsDouble, xlblsLineStyleNone, xlblsSlantDashDot);
  TOpXlBorderWeights = (xlbwHairline, xlbwThin, xlbwMedium, xlbwThick);

  TOpXlBorders = (xlbLeft, xlbRight, xlbTop, xlbBottom);
  TOpXlFontAttributes = (xlfaBold, xlfaItalic, xlfaUnderline, xlfaStrikethrough);
  TOpXlRangeBorders = set of TOpXlBorders;
  TOpXlRangeFontAttributes = set of TOpXlFontAttributes;




  TOpExcel = class;
  TOpExcelWorksheets = class;
  TOpExcelWorksheet = class;
  TOpExcelRanges = class;
  TOpExcelRange = class;
  TOpExcelHyperlinks = class;
  TOpExcelHyperlink = class;
  TOpExcelCharts = class;
  TOpExcelChart = class;


  {: Excel Cancel Key settings.
     Sets the behavior of the Cancel (Ctrl-C) key when running a VBA Macro. Refer to
     MSDN documentation for described behavior.}
  TOpXlCancelKey = (xlckDisabled, xlckErrorHandler, xlckInterrupt);

  {: Enumeration representing the possible states of the Excel Server window .}
  TOpXlWindowState = (xlwsNormal, xlwsMinimized, xlwsMaximized);

  {: OfficePartner Chart Types}
  {: Office Partner supports the Excel Chart Types included in the TOpXlChartType enumeration.}
  TOpXlChartType = (xlctArea, xlctBar, xlctLine, xlctPie, xlctRadar, xlctXYScatter, xlct3DArea, xlct3DBar,
    xlct3DLine, xlct3DPie, xlct3DColumn, xlctDoughnut, xlctUnknown);


  TOnNewWorkBook = procedure (Sender: TObject; const WorkBook: _Workbook) of object;
  TOnSheetSelectionChange = procedure (Sender: TObject; const Sh: IDispatch; const Target: ExcelRange) of object;
  TBeforeSheetDoubleClick = procedure (Sender: TObject; const Sh: IDispatch; const Target: ExcelRange; var Cancel: WordBool) of object;
  TBeforeSheetRightClick = procedure (Sender: TObject; const Sh: IDispatch; const Target: ExcelRange; var Cancel: WordBool) of object;
  TOnSheetActivate = procedure (Sender: TObject; const Sh: IDispatch) of object;
  TOnSheetDeactivate = procedure (Sender: TObject; const Sh: IDispatch) of object;
  TOnSheetCalculate = procedure (Sender: TObject; const Sh: IDispatch) of object;
  TOnSheetChange = procedure (Sender: TObject; const Sh: IDispatch; const Target: ExcelRange)of object;
  TOnWorkbookOpen = procedure (Sender: TObject; const Wb: Workbook) of object;
  TOnWorkbookActivate = procedure (Sender: TObject; const Wb: Workbook)of object;
  TOnWorkbookDeactivate = procedure (Sender: TObject; const Wb: Workbook)of object;
  TBeforeWorkbookClose = procedure (Sender: TObject; const Wb: Workbook; var Cancel: WordBool)of object;
  TBeforeWorkbookSave = procedure (Sender: TObject; const Wb: Workbook; SaveAsUI: WordBool; var Cancel: WordBool) of object;
  TBeforeWorkbookPrint = procedure (Sender: TObject; const Wb: Workbook; var Cancel: WordBool) of object;
  TOnWorkbookNewSheet = procedure (Sender: TObject; const Wb: Workbook; const Sh: IDispatch)of object;
  TOnWorkbookAddinInstall = procedure (Sender: TObject; const Wb: Workbook) of object;
  TOnWorkbookAddinUninstall = procedure (Sender: TObject; const Wb: Workbook) of object;
  TOnWindowResize = procedure (Sender: TObject; const Wb: Workbook; const Wn: ExcelWindow) of object;
  TOnWindowActivate = procedure (Sender: TObject; const Wb: Workbook; const Wn: ExcelWindow) of object;
  TOnWindowDeactivate = procedure (Sender: TObject; const Wb: Workbook; const Wn: ExcelWindow) of object;

  {Workbook Collection}

  {: TOpExcelWorkbook is the nested collection item that represents an Excel Workbook.
     An instance of TOpExcelWorkbooks contains a collection for WorkSheets that belong to
     the Workbook.}
  TOpExcelWorkbook = class(TOpNestedCollectionItem)
  private
    FFilename: TFilename;
    FWorksheets: TOpExcelWorksheets;
    procedure SetFilename(const Value: TFilename);
    function SaveCollection: Boolean;
    function GetAsWorkbook: _Workbook;
    function GetPropDirection: TOpPropDirection;
  protected
    function GetSubCollection(index: Integer): TCollection; override;
    function GetSubCollectionCount: Integer; override;
    procedure CreateSubCollections; override;
    procedure LoadWorkbook;
    function GetVerbCount: Integer; override;
    function GetVerb(index: Integer): String; override;
  public
    destructor Destroy; override;
    procedure Connect; override;
    {: This method will print the Workbook represented by the collection object.}
    procedure Print;
    {: If Excel is visible and connected, this method will activate the Workbook  }
    procedure Activate; override;
    procedure ExecuteVerb(index: Integer); override;
    {: Saves the Workbook using the current name.}
    procedure Save;
    {: Saves the Workbook using the FileName parameter as the name.}
    procedure SaveAs(FileName: TFileName);
    constructor Create(Collection: TCollection); override;
    {: Read-only property that specifies whether the workbook is created by the
       component, or loaded from an existing file}
    property PropDirection: TOpPropDirection read GetPropDirection;
    {: Read-only property allowing access to the underlying Automation interface for
       the Workbook.}
    property AsWorkbook: _Workbook read GetAsWorkbook;
  published
    {: Use the FileName property to load an existing Excel Workbook or Template.
       If FileName is assigned at design-time, Workbook members will not be persisted
        and will be populated with entities from the file or template.}
    property Filename: TFilename read FFilename write SetFilename;
    {: Collection containing all Worksheets in the Workbook.  Excel Chart and Macro Sheets are not
       currently supported.}
    property Worksheets: TOpExcelWorksheets read FWorkSheets write FWorksheets stored SaveCollection;
  end;

  {: The TOpExcelWorkbooks collection represents all of the Workbooks represented by the TOpExcel
      instance.}
  TOpExcelWorkbooks = class(TOpNestedCollection)
  protected
    function GetItem(index: Integer): TOpExcelWorkbook;
    procedure SetItem(index: Integer; const Value: TOpExcelWorkbook);
    function GetItemName: string; override;
  public
    {: Adds a new Workbook to Excel}
    function Add: TOpExcelWorkbook;
    {: Array property containing individual Workbook (TOpExcelWorkbook) items.}
    property Items[index: Integer]: TOpExcelWorkbook read GetItem write SetItem; default;
  end;

  {Worksheet Collection}


  {: A TOpExcelWorksheet item represents an Excel Worksheet in a specific Workbook.  A new
     Workbook will automatically have one Worksheet when it is created.}
  TOpExcelWorksheet = class(TOpNestedCollectionItem)
  private
    FName: WideString;
    FRanges: TOpExcelRanges;
    FHyperlinks: TOpExcelHyperlinks;
    FCharts: TOpExcelCharts;
    function GetAsWorksheet: _Worksheet;
    function GetName: WideString;
    procedure SetName(const Value: WideString);
  protected
    function GetSubCollection(index: Integer): TCollection; override;
    function GetSubCollectionCount: Integer; override;
    procedure CreateSubCollections; override;
  public
    {: If Excel is Visible and Connected, this method will select the Worksheet}
    procedure Activate; override;
    {: This method will print the Excel Worksheet represented by the collection object.}
    procedure Print;
    procedure Connect; override;
    {: Read-only property allowing access to the underlying Automation interface for
       the Worksheet.}
    property AsWorksheet: _Worksheet read GetAsWorksheet;
  published
    {: Destroys the Worksheet collection item and deletes the Worksheet from Excel
        if Connected and it is not the last Sheet in the Workbook.}
    destructor Destroy; override;
    {: Name is the string that appears on the Worksheet tab in the Excel Workbook.}
    property Name: WideString read GetName write SetName;
    {: A collection representing all the mapped Ranges in the Worksheet.}
    property Ranges: TOpExcelRanges read FRanges write FRanges;
    {: A collection representing all the Hyperlinks in the Worksheet.}
    property Hyperlinks: TOpExcelHyperlinks read FHyperlinks write FHyperlinks;
    {: A collection representing all the Excel ChartObjects in the Worksheet.}
    property Charts: TOpExcelCharts read FCharts write FCharts;
  end;

  {: The TOpExcelWorksheets collection represents all of the Worksheets inside of its'
      parent TOpExcelWorkbook item.}
  TOpExcelWorksheets = class(TOpNestedCollection)
  private
    function GetItem(index: Integer): TOpExcelWorksheet;
    procedure SetItem(index: Integer; const Value: TOpExcelWorksheet);
  protected
    function GetItemName: string; override;
  public
    {: Adds a new Worksheet to the parent Workbook}
    function Add: TOpExcelWorksheet;
    {: Array property containing individual Worksheet (TOpExcelWorksheet) items.}
    property Items[index: Integer]: TOpExcelWorksheet read GetItem write SetItem; default;
  end;

  {Range Collection}

  {: A TOpExcelRange item represents a single cell, or group of cells in the parent
      Worksheets.  Since there is an infinite number of Range combinations in any give
      Worksheet, Ranges can be mapped and persisted at design-time in order to be easily
      manipulated at run-time.}
  TOpExcelRange = class(TOpNestedCollectionItem)
  private
    FFontName            : String;
    FFontColor           : TColor;
    FFontSize            : Integer;
    FFontAttributes      : TOpXlRangeFontAttributes;
    FIndentLevel         : Integer;     {1-15}
    FOrientation         : TOpXlCellOrientation;
    FShrinkToFit         : Boolean;
    FRotateDegrees       : Integer;     {-90 - 90}
    FHorizontalAlignment : TOpXlCellHorizAlign;
    FVerticalAlignment   : TOpXlCellVertAlign;
    FColumnWidth         : Integer;
    FRowHeight           : Integer;
    FColor               : TColor;
    FPattern             : TOpXlInteriorPatterns;
    FPatternColor        : TColor;
    FBorderLineStyle     : TOpXlBorderLineStyles;
    FBorderLineThickness : TOpXlBorderWeights;
    FBorders             : TOpXlRangeBorders;
    FWrapText            : Boolean;

    FName: string;
    FModel: TOpUnknownComponent;
    FClearOnMove: Boolean;
    FSimpleText: string;
    FAddress: string;
    function ShouldPersistValue: Boolean;
    procedure SetModel(Value: TOpUnknownComponent);
    function GetAsRange: Range;
    function GetAddress: string;
    function GetAnchorCell: string;
    procedure SetAddress(const Value: string);
    function GetSimpleText: string;
    procedure SetSimpleText(const Value: string);
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    function GetIsEmpty: Boolean;

    //
    procedure SetFontName(val : String);
    procedure SetFontColor(val : TColor);
    procedure SetFontSize(val : Integer);
    procedure SetFontAttributes(val : TOpXlRangeFontAttributes);
    procedure SetIndentLevel(val : Integer);
    procedure SetOrientation(val : TOpXlCellOrientation);
    procedure SetShrinkToFit(val : Boolean);
    procedure SetRotateDegrees(val : Integer);
    procedure SetHorizontalAlignment(val : TOpXlCellHorizAlign);
    procedure SetVerticalAlignment(val : TOpXlCellVertAlign);
    procedure SetColumnWidth(val : Integer);
    procedure SetRowHeight(val : Integer);
    procedure SetColor(val : TColor);
    procedure SetPattern(val : TOpXlInteriorPatterns);
    procedure SetPatternColor(val : TColor);
    procedure SetBorderLineStyle(val : TOpXlBorderLineStyles);
    procedure SetBorders(val : TOpXlRangeBorders);
    procedure SetBorderLineThickness(val :TOpXlBorderWeights);
    procedure SetWrapText(val : Boolean);
  protected
    function GetSubCollection(index: Integer): TCollection; override;
    function GetSubCollectionCount: Integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: Integer): string; override;
  public
    procedure Clear;
    procedure AutoFitColumns;
    procedure AutoFitRows;
    constructor Create(Collection: TCollection); override;

    procedure Connect; override;
    procedure ExecuteVerb(index: Integer); override;
    {: The Populate method fills a Range with data from a "Model".  The Model will be
        iterated and the Range will be filled with all rows and columns.  Although the
        Populate method can be called at design-time (from the Nested Collection Editor),
        populated values will not be persisted, and Populate should be called at run-time to
        fill the Range from the associated Model.  Populate will supply column headers if they are
        supported by the Model.  If the Model has a DetailModel (for TOpDatasetModels) then
        the Range will be generated in outline form, showing the master-detail relationship.
        Populate fills data starting at the AnchorCell and proceeding down for rows, and across for
        columns.  After calling Populate, the TOpExcelRange will represent all of the populated cells.}
    procedure Populate;
    {: The PopulateCurrent method populates a Range with data from a Model, similar to the Populate
        method.  PopulateCurrent does not iterate the model and only fills a Range with the single,
        currently positioned row in the Model.  PopulateCurrent does not retireve column headings
        from the Model and is therefore useful for more customized population of Worksheets.
        After calling PopulateCurrent, the TOpExcelRange will represent all of the populated cells.}
    procedure PopulateCurrent;
    procedure PopulateHeaders;                                       {!!.63}
    {: The Select method highlights the represented Range if Excel is Connected and Visible}
    procedure Select;
    {: Activates the Worksheet containing the Range}
    procedure Activate; override;
    {: Clears the contents of the cells represented by the Range}
    procedure ClearRange;
    {: The SetAddressFromSelection method will set the Address of the Range to represent
       the selection in the Excel Workbook}
    procedure SetAddressFromSelection;
    {: Read-only property allowing access to the underlying Automation interface for
       the Range.}
    property AsRange: Range read GetAsRange;
    {: The AnchorCell is the Top Left cell of the current Range.  This is used by Populate and
       PopulateCurrent since it is unknown how many rows and columns will be filled with data.}
    property AnchorCell: string read GetAnchorCell;
    {: A Variant representing the Values in the represented Range.  If the Range represents a multiple
        cells, the return value will be a Variant array.  Multiple cell values can also be set by
        setting this property to a Variant array.}
    property Value: Variant read GetValue write SetValue;
    {: IsEmpty is a read-only property that returns a boolean value which signifies whether the Excel Range
       mapped to this TOpExcelRange objectcontains any values.  The server must be connected
       in order to read this property.}
    property IsEmpty: Boolean read GetIsEmpty;
  published
    {: This property can be assigned to a Component that descends from TOpUnknownComponent
       and implements the IOpModel interface.  Populate and PopulateCurrent will use the assigned
       Model to fill the Range with values.}
    property OfficeModel: TOpUnknownComponent read FModel write SetModel;
    {: The address of the Range in Excel A1 format.  This can be a single cell (e.g. D12), or
       multiple cells (e.g. A3:C27).  When this property is set, the AnchorCell property will
       automatically represent the top left cell of the Range.}
    property Address: string read GetAddress write SetAddress;
    {: Set ClearOnMove to True if you want the contents of the Range to be cleared when
       the address changes.}
    property ClearOnMove: Boolean read FClearOnMove write FClearOnMove;
    {: Assign a Name to the mapped Range.  This property has no meaning in Excel itself, but allows
       developers to use the RangeByName property to easily find any mapped Ranges in the TOpExcel component.
       It is currently the developers responsibility to ensure that Range names do not conflict.}
    property Name: string read FName write FName;
    {: The SimpleText property can be used at design-time or run-time to place simple string values into
       Ranges.  SimpleText is only available if the Range represents a single cell.  If the Range address
       spans multiple cells, SimpleText will return '(N/A)' and will not be persisted.}
    property SimpleText: string read GetSimpleText write SetSimpleText stored ShouldPersistValue;

    property FontName : String read FFontName write SetFontName;
    property FontColor : TColor read FFontColor write SetFontColor;
    property FontSize : Integer read FFontSize write SetFontSize;
    property FontAttributes : TOpXlRangeFontAttributes
                              read FFontAttributes
                              write SetFontAttributes;
    property IndentLevel : Integer read FIndentLevel write SetIndentLevel;
    property Orientation : TOpXlCellOrientation read FOrientation write SetOrientation;
    property ShrinkToFit : Boolean read FShrinkToFit write SetShrinkToFit;
    property RotateDegrees : Integer read FRotateDegrees write SetRotateDegrees;
    property HorizontalAlignment : TOpXlCellHorizAlign read FHorizontalAlignment
                                  write SetHorizontalAlignment;
    property VerticalAlignment : TOpXlCellVertAlign read FVerticalAlignment
                                   write SetVerticalAlignment;
    property ColumnWidth : Integer read FColumnWidth write SetColumnWidth;
    property RowHeight : Integer read FRowHeight write SetRowHeight;
    property Color : TColor read FColor write SetColor;
    property Pattern : TOpXlInteriorPatterns read FPattern write SetPattern;
    property PatternColor : TColor read FPatternColor write SetPatternColor;
    property BorderStyle : TOpXlBorderLineStyles read FBorderLineStyle
                      write SetBorderLineStyle;
    property Borders : TOpXlRangeBorders read FBorders write SetBorders;
    property BorderLineWeight : TOpXlBorderWeights
                        read FBorderLineThickness write SetBorderLineThickness;
    property WrapText : Boolean read FWrapText write SetWrapText;
end;


  {: The TOpExcelRanges collection represents all of the mapped Ranges inside of its'
      parent TOpExcelWorksheet item.}
  TOpExcelRanges = class(TOpNestedCollection)
  private
    function GetItem(index: Integer): TOpExcelRange;
    procedure SetItem(index: Integer; const Value: TOpExcelRange);
  protected
    function GetItemName: string; override;
  public
    {: Adds a new Range to the parent Worksheet}
    function Add: TOpExcelRange;
    {: Array property containing individual Range (TOpExcelRange) items.}
    property Items[index: Integer]: TOpExcelRange read GetItem write SetItem; default;
  end;

  {Hyperlink Collection}

  {: A TOpExcelHyperlink item represents a Hyperlink in the parent Worksheet.  There are two types
     of Hyperlinks in Excel, those that are attached to Shapes and those that are attached to
     Ranges.  Currently we support reading of either type from an existing document, but creation
     of a Hyperlink that is attached to a Range only.}
  TOpExcelHyperlink = class(TOpNestedCollectionItem)
  private
    FAddress: string;
    FSubAddress: string;
    FAnchorCell: string;
    FNewWindow: Boolean;
    FVisible: Boolean;
    procedure SetAnchorCell(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetAddress(const Value: string);
    function GetAsHyperlink: Hyperlink;
    function GetAddress: string;
    function GetAnchorCell: string;
    function GetNewWindow: Boolean;
    function GetSubAddress: string;
    function GetVisible: Boolean;
    procedure SetNewWindow(const Value: Boolean);
    procedure SetSubAddress(const Value: string);
    procedure RecreateLink;
  protected
    function GetSubCollection(index: Integer): TCollection; override;
    function GetSubCollectionCount: Integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: Integer): string; override;
  public
    procedure ExecuteVerb(index: Integer); override;
    destructor Destroy; override;
    procedure Connect; override;
    {:  Calling this method will cause the Hyperlink to be followed.  If Address is
        a URL, then IE will be launched, if SubAddress is an Excel reference, then Excel
        will navigate to the proper location.}
    procedure Follow;
    {: Read-only property allowing access to the underlying Automation interface for
       the Hyperlink.}
    property AsHyperlink: Hyperlink read GetAsHyperlink;
  published
    {: An Excel Range in A1 notation that denotes where the Hyperlink should appear.  Hyperlinks
       use the text that is currently in the cell, if they are moved or deleted the text will
       remain but the style formatting is lost.  This is Excel behavior.}
    property AnchorCell: string read GetAnchorCell write SetAnchorCell;
    {: A URL that specifies a location on the WWW, if you wish to navigate within Excel,
       the SubAddress property should be used.}
    property Address: string read GetAddress write SetAddress;
    {: The target of the Hyperlink within Excel, in A1 notation.  Example:  'Sheet1!C12'}
    property SubAddress: string read GetSubAddress write SetSubAddress;
    {: If using Office2000, setting NewWindow to False will cause a WWW URL to be displayed within
       Excel itself.  Otherwise, an instance of a web browser will be launched.}
    property NewWindow: Boolean read GetNewWindow write SetNewWindow;
    {: The Visible property of a Hyperlink specifies whether the Hyperlink can be seen or not.}
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  {: The TOpExcelHyperlinks collection represents all of the mapped Hyperlinks inside of its'
      parent TOpExcelWorksheet item.}
  TOpExcelHyperlinks = class(TOpNestedCollection)
  private
    function GetItem(index: Integer): TOpExcelHyperlink;
    procedure SetItem(index: Integer; const Value: TOpExcelHyperlink);
  protected
    function GetItemName: string; override;
  public
    {: Adds a new Hyperlink to the parent Worksheet}
    function Add: TOpExcelHyperlink;
    {: Array property containing individual Hyperlink (TOpExcelHyperlink) items.}
    property Items[index: Integer]: TOpExcelHyperlink read GetItem write SetItem; default;
  end;

  {Chart Collection}

  {: A TOpExcelChart item represents a ChartObject in the parent Worksheet.  There are two types
     of Charts in Excel, Charts embedded in a Worksheet (ChartObject) and Charts that are a
     Sheet (ChartSheet).  Currently, OfficePartner supports ChartObjects only.}
  TOpExcelChart = class(TOpNestedCollectionItem)
  private
    FLeft: Integer;
    FTop: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FRange: string;
    FChartType: TOpXlChartType;
    function GetChartType: TOpXlChartType;
    procedure SetChartType(const Value: TOpXlChartType);
    function GetHeight: Integer;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetAsChart: Chart;
    function GetAsChartObject: ChartObject;
  protected
    function GetSubCollection(index: Integer): TCollection; override;
    function GetSubCollectionCount: Integer; override;
    function GetRange: string;
    procedure SetRange(const Value: string);
    function GetVerbCount: Integer; override;
    function GetVerb(index: Integer): string; override;
  public
    destructor Destroy; override;    
    procedure Connect; override;
    {: Activates the ChartObject represented by the collection item.  This method
       will bring the Workbook and Worksheet containing the ChartObject to the front
       in Excel.}
    procedure Activate; override;
    procedure ExecuteVerb(index: Integer); override;
    {: Calling this method assigned the chart's DataAddress to the currently selected
       Range in the Excel Worksheet.}
    procedure SetAddressFromSelection;
    {: Read-only property allowing access to the underlying Automation interface for
       the Chart.}
    property AsChart: Chart read GetAsChart;
    {: Read-only property allowing access to the underlying Automation interface for
       the ChartObject.}
    property AsChartObject: ChartObject read GetAsChartObject;
  published
    {: The Top (in pixels) of the ChartObject within the Worksheet.}
    property Top: Integer read GetTop write SetTop;
    {: The Left (in pixels) of the ChartObject within the Worksheet.}
    property Left: Integer read GetLeft write SetLeft;
    {: The Width (in pixels) of the ChartObject within the Worksheet.}
    property Width: Integer read GetWidth write SetWidth;
    {: The Height (in pixels) of the ChartObject within the Worksheet.}
    property Height: Integer read GetHeight write SetHeight;
    {: The address of the charted data in Excel A1 notation.  Currently, the values within
       this address should contain a column of category headers on the left (rows) and a row
       of series labels on the top (columns).}
    property DataRange: string read GetRange write SetRange;
    {: This property can be assigned a TOpXlChartType value which specifies the type of Chart
       desired.}
    property ChartType: TOpXlChartType read GetChartType write SetChartType;
  end;

  {: The TOpExcelCharts collection represents all of the mapped ChartObjects inside of its'
      parent TOpExcelWorksheet item.}
  TOpExcelCharts = class(TOpNestedCollection)
  private
    function GetItem(index: Integer): TOpExcelChart;
    procedure SetItem(index: Integer; const Value: TOpExcelChart);
  protected
    function GetItemName: string; override;
  public
    {: Adds a new ChartObject to the parent Worksheet}
    function Add: TOpExcelChart;
    {: Array property containing individual ChartObject (TOpExcelCharts) item.}
    property Items[index: Integer]: TOpExcelChart read GetItem write SetItem; default;
  end;

  {Main Excel Component}

  {: The TOpExcel component class represents an instance of Microsoft Excel.  This class
     contains a collection representing all Workbooks in Excel and Worksheets, Ranges, Charts
     and Hyperlinks within each Workbook.  The PropDirection property controls what happens to
     the component properties when the component is initially connected.  If PropDirection is pdToServer,
     the streamed design-time properties will be pushed to Excel immediately after Excel is launched.
     If PropDirection is set to pdFromServer, the streamed properties will be ignored and the
     component properties will represent the state of Excel when it is launched.}
  TOpExcel = class(TOpExcelBase)
  private
    FServer: _Application;
    FInteractive: Boolean;
    FWindowState: TOpXlWindowState;
    FCaption: string;
    FVisible: Boolean;
    FHeight: Integer;
    FTop: Integer;
    FWidth: Integer;
    FLeft: Integer;
    FEnableAutoComplete: WordBool;
    FEnableAnimations: WordBool;
    FEnableCancelKey: TOpXlCancelKey;
    FLargeButtons: WordBool;
    FUserName: WideString;
    FWorkbooks: TOpExcelWorkbooks;
    {Events}
    FOnNewWorkbook: TOnNewWorkbook;
    FOnSheetActivate: TOnSheetActivate;
    FBeforeSheetDoubleClick: TBeforeSheetDoubleClick;
    FBeforeSheetRightClick: TBeforeSheetRightClick;
    FOnSheetCalculate: TOnSheetCalculate;
    FOnSheetChange: TOnSheetChange;
    FOnSheetDeactivate: TOnSheetDeactivate;
    FOnSheetSelectionChange: TOnSheetSelectionChange;
    FOnWindowActivate: TOnWindowActivate;
    FOnWindowDeactivate: TOnWindowDeactivate;
    FOnWindowResize: TOnWindowResize;
    FOnWorkbookActivate: TOnWorkbookActivate;
    FOnWorkbookAddinInstall: TOnWorkbookAddinInstall;
    FOnWorkbookAddinUninstall: TOnWorkbookAddinUninstall;
    FBeforeWorkbookClose: TBeforeWorkbookClose;
    FBeforeWorkbookPrint: TBeforeWorkbookPrint;
    FBeforeWorkbookSave: TBeforeWorkbookSave;
    FOnWorkbookDeactivate: TOnWorkbookDeactivate;
    FOnWorkbookNewSheet: TOnWorkbookNewSheet;
    FOnWorkbookOpen: TOnWorkbookOpen;
    procedure SetVisible(Value: Boolean);
    function GetVisible: Boolean;
    procedure SetWindowState(Value: TOpXlWindowState);
    function GetWindowState: TOpXlWindowState;
    procedure SetCaption(const Value: string);
    procedure SetHeight(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetTop(Value: Integer);
    procedure SetWidth(Value: Integer);
    function GetHeight: Integer;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    function GetInteractive: Boolean;
    procedure SetInteractive(const Value: Boolean);
    procedure FixupCollection(Item: TOpNestedCollectionItem);
    procedure ReleaseCollectionInterface(Item: TOpNestedCollectionItem);
    function CollectionNotify(var Key; Item: TOpNestedCollectionItem): Boolean;
    function FindRange(var Key; Item: TOpNestedCollectionItem): Boolean;
    function DeleteWorkbook(var Key; Item: TOpNestedCollectionItem): Boolean;
    function GetRangeByName(Name: string): TOpExcelRange;
    procedure SetEnableAnimations(const Value: WordBool);
    procedure SetEnableAutoComplete(const Value: WordBool);
    procedure SetEnableCancelKey(Value: TOpXlCancelKey);
    procedure SetLargeButtons(const Value: WordBool);
    procedure SetUserName(const Value: WideString);
    function GetEnableAnimations: WordBool;
    function GetEnableAutoComplete: WordBool;
    function GetEnableCancelKey: TOpXlCancelKey;
    function GetLargeButtons: WordBool;
    function GetUserName: WideString;
    function GetCaption: string;
    function PointsToPixels(Points: Double): Integer;
    function PixelsToPoints(Pixels: Integer): Double;
    function PixelsPerInch: Integer;
    { Private declarations }
  protected
    { Protected declarations }
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoNewWorkbook(const WorkBook: Workbook); dynamic;
    procedure DoSheetSelectionChange(const Sh: IDispatch; const Target: Range);  dynamic;
    procedure DoBeforeSheetDoubleClick(const Sh: IDispatch; const Target: Range; var Cancel: WordBool); dynamic;
    procedure DoBeforeSheetRightClick(const Sh: IDispatch; const Target: Range; var Cancel: WordBool); dynamic;
    procedure DoSheetActivate(const Sh: IDispatch); dynamic;
    procedure DoSheetDeActivate(const Sh: IDispatch); dynamic;
    procedure DoSheetCalculate(const Sh: IDispatch); dynamic;
    procedure DoSheetChange(const Sh: IDispatch; const Target: Range); dynamic;
    procedure DoWorkbookOpen(const Wb: Workbook); dynamic;
    procedure DoWorkbookActivate(const Wb: Workbook); dynamic;
    procedure DoWorkbookDeactivate(const Wb: Workbook); dynamic;
    procedure DoBeforeWorkbookClose(const Wb: Workbook; var Cancel: WordBool); dynamic;
    procedure DoBeforeWorkbookSave(const Wb: Workbook; SaveAsUI: WordBool; var Cancel: WordBool); dynamic;
    procedure DoBeforeWorkbookPrint(const Wb: Workbook; var Cancel: WordBool); dynamic;
    procedure DoWorkbookNewSheet(const Wb: Workbook; const Sh: IDispatch); dynamic;
    procedure DoWorkbookAddinInstall(const Wb: Workbook); dynamic;
    procedure DoWorkbookAddinUninstall(const Wb: Workbook); dynamic;
    procedure DoWindowResize(const Wb: Workbook; const Wn: ExcelWindow); dynamic;
    procedure DoWindowActivate(const Wb: Workbook; const Wn: ExcelWindow); dynamic;
    procedure DoWindowDeactivate(const Wb: Workbook; const Wn: ExcelWindow); dynamic;
    procedure FixupProps; override;
    function GetConnected: Boolean; override;
    function GetOfficeVersionStr: string; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    {: The Excel destructor cleans up all owned collections and ensures that all COM interfaces
       are released in order to facilitate proper shutdown of the Excel Automation server.}
    destructor Destroy; override;
    {: Returns system/application information from the Automation server in "Key=Value" pairs.  If the component
       is not connected, this method will temporarily launch the server.}
    procedure GetAppInfo(Info: Tstrings); override;
    {: Returns filename extensions supported by this component.}
    procedure GetFileInfo(var Filter, DefExt: string); override;
    {: HandleEvent is overridden in each TOpOfficeComponent subclass in order to correctly dispatch
       Automation events to VCL Event Handlers.}
    procedure HandleEvent(const IID: TIID; DispId: Integer; const Params: TVariantArgList); override;
    {: All Collection children delegate initial Automation connections to this method.  This is
       done so that the component can properly synchronize and manage CoClass/Interface retrieval
       and maintenance.  Developers should not call this method directly.}
    function CreateItem(Item: TOpNestedCollectionItem): IDispatch; override;
    {: A read-only property representing the Automation interface for the Excel Server.}
    property Server: _Application read FServer;
    {:  The RangeByName property is a shortcut available to locate and return any named
        Range in all Workbooks represented by the component.  In the case of Range Name clashes,
        this property will return the first Range (TOpExcelRange) found.}
    property RangeByName[Name: string]: TOpExcelRange read GetRangeByName;
  published
    { Published declarations }
    {: Text string displayed in the Caption of Microsoft Excel.}
    property Caption: string read GetCaption write SetCaption;
    {: Specifies whether the component is connected to a live instance of Excel.  The OfficePartner
       components are designed to allow the setting of properties whether the server is running or not.
       When Connected is set to True,  Excel will be launched and properties will be "fixed-up"
       in accordance with the setting of the PropDirection property.  When Connected is set to False,
       Automation interfaces will be released to allow Excel to properly shut-down.}
    property Connected;
    {: This property allows for tighter Automation control of the Excel Server.  If Interactive
       is set to false, the end user cannot manipulate Excel, even if it is Visible.}
    property Interactive: boolean read GetInteractive write SetInteractive default True;
    {: Used for DCOM, Excel can be launched on another computer provided DCOM is configured
       correctly.}
    property MachineName;
    {: The PropDirection property controls what happens to
     the component properties when the component is initially connected.  If PropDirection is pdToServer,
     the streamed design-time properties will be pushed to Excel immediately after Excel is launched.
     If PropDirection is set to pdFromServer, the streamed properties will be ignored and the
     component properties will represent the state of Excel when it is launched.}
    property PropDirection;
    {: If Connected is True, this property specifies the visibility of the Excel Automation
       Server,  if Connected is False, Visible specifies the desired visibility of the server
       when it is eventually connected.}
    property Visible: boolean read GetVisible write SetVisible;
    {: This property can be assigned a TOpXlWindowState enumeration specifying the state
       of the Excel MDI window.}
    property WindowState: TOpXlWindowState read GetWindowState write SetWindowState;
    {: The Left position (in pixels) of the Excel MDI window.  This value is converted from
       points to pixels, so small rounding errors may occur.}
    property ServerLeft: Integer read GetLeft write SetLeft;
    {: The Top position (in pixels) of the Excel MDI window.  This value is converted from
       points to pixels, so small rounding errors may occur.}
    property ServerTop: Integer read GetTop write SetTop;
    {: The Height (in pixels) of the Excel MDI window.  This value is converted from
       points to pixels, so small rounding errors may occur.}
    property ServerHeight: Integer read GetHeight write SetHeight;
    {: The Width (in pixels) of the Excel MDI window.  This value is converted from
       points to pixels, so small rounding errors may occur.}
    property ServerWidth: Integer read GetWidth write SetWidth;
    {: This property specifies whether large or small buttons are displayed in the Excel MDI
       toolbar.}
    property LargeButtons: WordBool read GetLargeButtons write SetLargeButtons;
    {: This property specifies whether Excel shows delayed animation when rows, cols, etc.
       are inserted or deleted.}
    property EnableAnimations: WordBool read GetEnableAnimations write SetEnableAnimations;
    {: The UserName from Excel.  UserName is read/write and will update Excel accordingly,
       however it can only be set when at least one Workbook is open.}
    property UserName: WideString read GetUserName write SetUserName;
    {: Sets the Excel AutoComplete property.}
    property EnableAutoComplete: WordBool read GetEnableAutoComplete write SetEnableAutoComplete;
    {: Specifies whether CTRL-C can be used to interrupt running Excel macros.}
    property EnableCancelKey: TOpXlCancelKey read GetEnableCancelKey write SetEnableCancelKey;
    {: The Nested Collection which is the ultimate parent of all Excel entities supported by
       Office Partner (e.g. Workbooks, Worksheets, Ranges, Charts, and Hyperlinks).}
    property Workbooks: TOpExcelWorkbooks read FWorkbooks write FWorkbooks;
    //#<EVENTS>
    property OnOpConnect;
    property OnOpDisconnect;
    property OnGetInstance;
    property OnNewWorkbook: TOnNewWorkbook read FOnNewWorkbook write FOnNewWorkbook;
    property OnSheetSelectionChange: TOnSheetSelectionChange read FOnSheetSelectionChange write FOnSheetSelectionChange;
    property BeforeSheetDoubleClick: TBeforeSheetDoubleClick read FBeforeSheetDoubleClick write FBeforeSheetDoubleClick;
    property BeforeSheetRightClick: TBeforeSheetRightClick  read FBeforeSheetRightClick write FBeforeSheetRightClick;
    property OnSheetActivate: TOnSheetActivate   read FOnSheetActivate write FOnSheetActivate;
    property OnSheetDeactivate: TOnSheetDeactivate read FOnSheetDeactivate write FOnSheetDeactivate;
    property OnSheetCalculate: TOnSheetCalculate  read FOnSheetCalculate write FOnSheetCalculate;
    property OnSheetChange: TOnSheetChange  read FOnSheetChange write FOnSheetChange;
    property OnWorkbookOpen: TOnWorkbookOpen  read FOnWorkbookOpen write FOnWorkbookOpen;
    property OnWorkbookActivate: TOnWorkbookActivate  read FOnWorkbookActivate write FOnWorkbookActivate;
    property OnWorkbookDeactivate: TOnWorkbookDeactivate  read FOnWorkbookDeactivate write FOnWorkbookDeactivate;
    property BeforeWorkbookClose: TBeforeWorkbookClose  read FBeforeWorkbookClose write FBeforeWorkbookClose;
    property BeforeWorkbookSave: TBeforeWorkbookSave  read FBeforeWorkbookSave write FBeforeWorkbookSave;
    property BeforeWorkbookPrint: TBeforeWorkbookPrint  read FBeforeWorkbookPrint write FBeforeWorkbookPrint;
    property OnWorkbookNewSheet: TOnWorkbookNewSheet  read FOnWorkbookNewSheet write FOnWorkbookNewSheet;
    property OnWorkbookAddinInstall: TOnWorkbookAddinInstall  read FOnWorkbookAddinInstall write FOnWorkbookAddinInstall;
    property OnWorkbookAddinUninstall: TOnWorkbookAddinUninstall  read FOnWorkbookAddinUninstall write FOnWorkbookAddinUninstall;
    property OnWindowResize: TOnWindowResize  read FOnWindowResize write FOnWindowResize;
    property OnWindowActivate: TOnWindowActivate  read FOnWindowActivate write FOnWindowActivate;
    property OnWindowDeactivate: TOnWindowDeactivate  read FOnWindowDeactivate write FOnWindowDeactivate;
    //#</EVENTS>
  end;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
   OpConst, OpDbOfc;

{ TOpExcel }

constructor TOpExcel.Create(AOwner: TComponent);
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}

  inherited Create(AOwner);
  FLeft := 0;
  FTop := 0;
  FWidth := 640;
  FHeight := 480;
  FInteractive := True;


  FWorkbooks := TOpExcelWorkbooks.Create(self,self,TOpExcelWorkbook);
end;

destructor TOpExcel.Destroy;
begin
  Connected := False;
  FWorkbooks.Free;
  inherited Destroy;
end;

//Getters

function TOpExcel.GetLeft: Integer;
begin
  if (Connected) then
  begin
    Result := PointsToPixels(FServer.Left[0]);
    FLeft :=  Result;
  end
  else
    Result := FLeft;
end;

function TOpExcel.GetTop: Integer;
begin
  if (Connected) then
  begin
    Result := PointsToPixels(FServer.Top[0]);
    FTop := Result;
  end
  else
    Result := FTop;
end;

function TOpExcel.GetWidth: Integer;
begin
  if (Connected) then
  begin
    Result := PointsToPixels(FServer.Width[0]);
    FWidth := Result;
  end
  else
    Result := FWidth;
end;

function TOpExcel.GetHeight: Integer;
begin
  if (Connected) then
  begin
    Result := PointsToPixels(FServer.Height[0]);
    FHeight := Result;
  end
  else
    Result := FHeight;
end;

function TOpExcel.GetVisible: Boolean;
begin
  if (Connected) then
  begin
    Result := FServer.Visible[0];
    FVisible := Result;
  end
  else
    Result := FVisible;
end;

function TOpExcel.GetConnected: Boolean;
begin
  Result := assigned(FServer);
end;

function TOpExcel.GetInteractive: Boolean;
begin
  if (Connected) then
  begin
    Result := FServer.Interactive[0];
    FInteractive := Result;
  end
  else
    Result := FInteractive;
end;

function TOpExcel.GetEnableAnimations: WordBool;
begin
  if (Connected) then
  begin
    Result := FServer.EnableAnimations[0];
    FEnableAnimations := Result;
  end
  else
    Result := FEnableAnimations;
end;

function TOpExcel.GetEnableAutoComplete: WordBool;
begin
  if (Connected) then
  begin
    Result := FServer.EnableAutoComplete;
    FEnableAutoComplete := Result;
  end
  else
    Result := FEnableAutoComplete;
end;

function TOpExcel.GetEnableCancelKey: TOpXlCancelKey;
begin
  if (Connected) then
  begin
    case FServer.EnableCancelKey[0] of
      xlDisabled: Result := xlckDisabled;
      xlErrorHandler: Result := xlckErrorHandler;
      xlInterrupt: Result := xlckInterrupt;
      else
        Result := xlckDisabled;
    end;
    FEnableCancelKey := Result;
  end
  else
    Result := FEnableCancelKey;
end;

function TOpExcel.GetLargeButtons: WordBool;
begin
  if (Connected) then
  begin
    Result := FServer.LargeButtons;
    FLargeButtons := Result;
  end
  else
    Result := FLargeButtons;
end;

function TOpExcel.GetUserName: WideString;
begin
  if (Connected) then
  begin
    Result := FServer.UserName[0];
    FUserName := Result;
  end
  else
    Result := FUserName;
end;

function TOpExcel.GetWindowState: TOpXlWindowState;
begin
  if (Connected) then
  begin
    case DWord(FServer.WindowState[0]) of
      xlNormal: Result := xlwsNormal;
      xlMinimized: Result := xlwsMinimized;
      xlMaximized: Result := xlwsMaximized;
      else
        Result := xlwsNormal;
    end;
    FWindowState := Result;
  end
  else
    Result := FWindowState;
end;

function TOpExcel.GetCaption: string;
begin
  if (Connected) then
  begin
    Result := Server.Caption;
    FCaption := Result;
  end
  else
    Result := FCaption;
end;

// Setters

procedure TOpExcel.SetCaption(const Value: string);
begin
  if (Connected) then
    FServer.Caption := Value
  else
    FCaption := Value;
end;

procedure TOpExcel.SetHeight(Value: Integer);
begin
  FHeight := Value;
  if (Connected) and (FWindowState = xlwsNormal) then
    FServer.Height[0] := PixelsToPoints(Value);
end;

procedure TOpExcel.SetLeft(Value: Integer);
begin
  FLeft := Value;
  if (Connected) and (FWindowState = xlwsNormal) then
    FServer.Left[0] := PixelsToPoints(FLeft);
end;

procedure TOpExcel.SetTop(Value: Integer);
begin
  FTop := Value;
  if (Connected) and (FWindowState = xlwsNormal) then
    FServer.Top[0] := PixelsToPoints(FTop);
end;

procedure TOpExcel.SetVisible(Value: Boolean);
begin
  if (Connected) then
  begin
    FServer.Visible[0] := Value;
    FServer.ScreenUpdating[0] := True;
  end;
  FVisible := Value;
end;

procedure TOpExcel.SetWidth(Value: Integer);
begin
  FWidth := Value;
  if (Connected)  and (FWindowState = xlwsNormal) then
    FServer.Width[0] := PixelsToPoints(FWidth);
end;

procedure TOpExcel.SetWindowState(Value: TOpXlWindowState);
begin
  if (Connected)  then
  begin
    case Value of
    {$IFDEF DCC6ORLATER}
      xlwsNormal: FServer.WindowState[0] := Int64(xlNormal);
      xlwsMinimized: FServer.WindowState[0] := Int64(xlMinimized);
      xlwsMaximized: FServer.WindowState[0] := Int64(xlMaximized);
    {$ELSE}
      xlwsNormal: FServer.WindowState[0] := Integer(xlNormal);
      xlwsMinimized: FServer.WindowState[0] := Integer(xlMinimized);
      xlwsMaximized: FServer.WindowState[0] := Integer(xlMaximized);
    {$ENDIF}
    end;
  end;
  FWindowState := Value;
end;

procedure TOpExcel.SetInteractive(const Value: Boolean);
begin
  if (Connected) then
    FServer.Interactive[0] := Value;
  FInteractive := Value;
end;

procedure TOpExcel.SetEnableAnimations(const Value: WordBool);
begin
  if (Connected) then
    FServer.EnableAnimations[0] := Value;
  FEnableAnimations := Value;
end;

procedure TOpExcel.SetEnableAutoComplete(const Value: WordBool);
begin
  if (Connected) then
    FServer.EnableAutoComplete := Value;
  FEnableAutoComplete := Value;
end;

procedure TOpExcel.SetEnableCancelKey(Value: TOpXlCancelKey);
begin
  if (Connected) then
  begin
    case Value of
      xlckDisabled:      FServer.EnableCancelKey[0] := xlDisabled;
      xlckErrorHandler:  FServer.EnableCancelKey[0] := xlErrorHandler;
      xlckInterrupt:     FServer.EnableCancelKey[0] := xlInterrupt;
    end;
  end;
  FEnableCancelKey := Value;
end;

procedure TOpExcel.SetLargeButtons(const Value: WordBool);
begin
  if (Connected) then
    FServer.LargeButtons := Value;
  FLargeButtons := Value;
end;

procedure TOpExcel.SetUserName(const Value: WideString);
begin
  if (Connected) and (FServer.Workbooks.Count > 0) then
    FServer.Set_UserName(0,Value);
  FUserName := Value;
end;

// Event Support

procedure TOpExcel.HandleEvent(const IID: TIID; DispID: Integer; const Params: TVariantArgList);
begin
  if IsEqualGuid(IID,AppEvents) then
  begin
    ClientState := ClientState + [csInEvent];
    try
      case DispId of
        // NewWorkbook
        1565: DoNewWorkbook(IDispatch(Params[0].dispVal) as _Workbook);
        // SheetSelectionChange
        1558: DoSheetSelectionChange(IDispatch(Params[0].dispVal),Range(Params[1].dispVal));
        // SheetBeforeDoubleClick
        1559: DoBeforeSheetDoubleClick(IDispatch(Params[0].dispVal),Range(Params[1].dispVal),Params[2].pBool^);
        // SheetBeforeRightClick
        1560: DoBeforeSheetRightClick(IDispatch(Params[0].dispVal),Range(Params[1].dispVal),Params[2].pBool^);
        // SheetActivate
        1561: DoSheetActivate(IDispatch(Params[0].dispVal));
        // SheetDeactivate
        1562: DoSheetDeactivate(IDispatch(Params[0].dispVal));
        // SheetCalculate
        1563: DoSheetCalculate(IDispatch(Params[0].dispVal));
        // SheetChange
        1564: DoSheetChange(IDispatch(Params[0].dispVal),Range(Params[1].dispVal));
        // WorkbookOpen
        1567: DoWorkbookOpen(IDispatch(Params[0].dispVal) as _Workbook);
        // WorkbookActivate
        1568: DoWorkbookActivate(IDispatch(Params[0].dispVal) as _Workbook);
        // WorkbookDeactivate
        1569: DoWorkbookDeactivate(IDispatch(Params[0].dispVal) as _Workbook);
        // WorkbookBeforeClose
        1570: DoBeforeWorkbookClose(IDispatch(Params[0].dispVal) as _Workbook,Params[1].pBool^);
        // WorkbookBeforeSave
        1571: DoBeforeWorkbookSave(IDispatch(Params[0].dispVal) as _Workbook,Params[1].vBool,Params[2].pBool^);
        // WorkbookBeforePrint
        1572: DoBeforeWorkbookPrint(IDispatch(Params[0].dispVal) as _Workbook,Params[1].pBool^);
        // WorkbookNewSheet
        1573: DoWorkbookNewSheet(IDispatch(Params[0].dispVal) as _Workbook,IDispatch(Params[1].dispVal));
        // WorkbookAddinInstall
        1574: DoWorkbookAddinInstall(IDispatch(Params[0].dispVal) as _Workbook);
        // WorkbookAddinUninstall
        1575: DoWorkbookAddinUninstall(IDispatch(Params[0].dispVal) as _Workbook);
        // WindowResize
        1554: DoWindowResize(IDispatch(Params[0].dispVal) as _Workbook,ExcelWindow(Params[1].dispVal));
        // WindowActivate
        1556: DoWindowActivate(IDispatch(Params[0].dispVal) as _Workbook,ExcelWindow(Params[1].dispVal));
        // WindowDeactivate
        1557: DoWindowDeactivate(IDispatch(Params[0].dispVal) as _Workbook,ExcelWindow(Params[1].dispVal));
      end;
    finally
      ClientState := ClientState - [csInEvent];
    end;
  end;
end;

procedure TOpExcel.DoNewWorkbook(const WorkBook: _Workbook);
begin
  if assigned(FOnNewWorkbook) then FOnNewWorkbook(self,Workbook);
end;

procedure TOpExcel.DoSheetActivate(const Sh: IDispatch);
begin
  if assigned(FOnSheetActivate) then FOnSheetActivate(self,Sh);
end;

procedure TOpExcel.DoBeforeSheetDoubleClick(const Sh: IDispatch;
  const Target: Range; var Cancel: WordBool);
begin
  if assigned(FBeforeSheetDoubleClick) then FBeforeSheetDoubleClick(self,Sh,ExcelRange(Target),Cancel);
end;

procedure TOpExcel.DoBeforeSheetRightClick(const Sh: IDispatch;
  const Target: Range; var Cancel: WordBool);
begin
  if assigned(FBeforeSheetRightClick) then FBeforeSheetRightClick(self,Sh,ExcelRange(Target),Cancel);
end;

procedure TOpExcel.DoSheetCalculate(const Sh: IDispatch);
begin
  if assigned(FOnSheetCalculate) then FOnSheetCalculate(self,Sh);
end;

procedure TOpExcel.DoSheetChange(const Sh: IDispatch;
  const Target: Range);
begin
  if assigned(FOnSheetChange) then FOnSheetChange(self,Sh,ExcelRange(Target));
end;

procedure TOpExcel.DoSheetDeactivate(const Sh: IDispatch);
begin
  if assigned(FOnSheetActivate) then FOnSheetActivate(self,Sh);
end;

procedure TOpExcel.DoSheetSelectionChange(const Sh: IDispatch;
  const Target: Range);
begin
  if assigned(FOnSheetSelectionChange) then FOnSheetSelectionChange(self,Sh,ExcelRange(Target));
end;

procedure TOpExcel.DoWindowActivate(const Wb: Workbook;
  const Wn: ExcelWindow);
begin
  if assigned(FOnWindowActivate) then FOnWindowActivate(self,Wb,Wn);
end;

procedure TOpExcel.DoWindowDeactivate(const Wb: Workbook;
  const Wn: ExcelWindow);
begin
  if assigned(FOnWindowDeactivate) then FOnWindowDeactivate(self,Wb,Wn);
end;

procedure TOpExcel.DoWindowResize(const Wb: Workbook;
  const Wn: ExcelWindow);
begin
  if assigned(FOnWindowResize) then FOnWindowResize(self,Wb,Wn);
end;

procedure TOpExcel.DoWorkbookActivate(const Wb: Workbook);
begin
  if assigned(FOnWorkbookActivate) then FOnWorkbookActivate(self,Wb);
end;

procedure TOpExcel.DoWorkbookAddinInstall(const Wb: Workbook);
begin
  if assigned(FOnWorkbookAddinInstall) then FOnWorkbookAddinInstall(self,Wb);
end;

procedure TOpExcel.DoWorkbookAddinUninstall(const Wb: Workbook);
begin
  if assigned(FOnWorkbookAddinUninstall) then FOnWorkbookAddinUninstall(self,Wb);
end;

procedure TOpExcel.DoBeforeWorkbookClose(const Wb: Workbook; var Cancel: WordBool);
var
  i: Integer;
  Book: Workbook;
  FreeList: TList;
begin
  if assigned(FBeforeWorkbookClose) then FBeforeWorkbookClose(self,Wb,Cancel);
  if not(Cancel) then
  begin
    FreeList := TList.Create;
    try
      Book := Wb;
      if Workbooks.FindItem(Book,DeleteWorkbook,FreeList) then
      begin
        for i := 0 to FreeList.Count - 1 do
        begin
          TOpNestedCollectionItem(FreeList[i]).Free;
        end;
        UpdateDesigner;
      end;
    finally
      FreeList.Free;
    end;
  end;
end;

procedure TOpExcel.DoBeforeWorkbookPrint(const Wb: Workbook;
  var Cancel: WordBool);
begin
  if assigned(FBeforeWorkbookPrint) then FBeforeWorkbookPrint(self,Wb,Cancel);
end;

procedure TOpExcel.DoBeforeWorkbookSave(const Wb: Workbook;
  SaveAsUI: WordBool; var Cancel: WordBool);
begin
  if assigned(FBeforeWorkbookSave) then FBeforeWorkbookSave(self,WB,SaveAsUI,Cancel);
end;

procedure TOpExcel.DoWorkbookDeactivate(const Wb: Workbook);
begin
  if assigned(FOnWorkbookDeactivate) then FOnWorkbookDeactivate(self,Wb);
end;

procedure TOpExcel.DoWorkbookNewSheet(const Wb: Workbook;
  const Sh: IDispatch);
begin
  if assigned(FOnWorkbookNewSheet) then FOnWorkbookNewSheet(self,Wb,Sh);
end;

procedure TOpExcel.DoWorkbookOpen(const Wb: Workbook);
begin
  if assigned(FOnWorkbookOpen) then FOnWorkbookOpen(self,Wb);
end;

procedure TOpExcel.FixupProps;
begin
  case PropDirection of
    pdToServer:     begin
                      WindowState := FWindowState;
                      Interactive := FInteractive;
                      Visible := FVisible;
                      ServerLeft := FLeft;
                      ServerTop := FTop;
                      ServerWidth := FWidth;
                      ServerHeight := FHeight;
                      Caption := FCaption;
                      EnableAnimations := FEnableAnimations;
                      EnableAutoComplete := FEnableAutoComplete;
                      EnableCancelKey := FEnableCancelKey;
                      LargeButtons := FLargeButtons;
                      UserName := FUserName;
                    end;
     pdFromServer:  begin
                      FWindowState := WindowState;
                      FInteractive := Interactive;
                      Visible := FVisible;
                      FLeft := ServerLeft;
                      FTop := ServerTop;
                      FWidth := ServerWidth;
                      FHeight := ServerHeight;
                      FCaption := Caption;
                      FEnableAnimations := EnableAnimations;
                      FEnableAutoComplete := EnableAutoComplete;
                      FEnableCancelKey := EnableCancelKey;
                      FLargeButtons := LargeButtons;
                      FUserName := UserName;
                    end;
  end;
  FWorkbooks.ForEachItem(FixupCollection);
end;

function TOpExcel.CreateItem(Item: TOpNestedCollectionItem): IDispatch;
begin
  if Connected then
  begin
    if (Item is TOpExcelWorkbook) then
    begin
      if TOpExcelWorkbook(Item).PropDirection = pdToServer then
      begin
        Result := Server.Workbooks.Add(EmptyParam,0);
      end
      else
        // Don't load if we're going to throw it away.
        Result := nil;
    end;

    if (Item is TOpExcelWorksheet) then
    begin
      if Item.Index >= (Item.ParentItem.Intf as Workbook).Worksheets.Count then
      begin
        Result := (Item.ParentItem.Intf as Workbook).Worksheets.Add(emptyParam,
          (Item.ParentItem.Intf as Workbook).Sheets[(Item.ParentItem.Intf as Workbook).Sheets.Count],1,
          emptyParam,0) ;
      end
      else
      begin
        Result := (Item.ParentItem.Intf as _Workbook).Worksheets[Item.Index + 1] ;
      end;
    end;

    if (Item is TOpExcelHyperlink) and
     ((Item.ParentItem.ParentItem as TOpExcelWorkbook).PropDirection = pdFromServer) then
    begin
        if Item.Index < (Item.ParentItem.Intf as _Worksheet).Hyperlinks.Count then
          Result := ((Item.ParentItem.Intf as _Worksheet).Hyperlinks[Item.Index + 1])
        else
          // Cannot assign, we dont have an address yet.
          Result := nil;
    end;

    if (Item is TOpExcelRange) then
    begin
      Result := IDispatch((Item.ParentItem.Intf as _Worksheet).Cells.Item[1,1]);
    end;

    if (Item is TOpExcelChart) then
    begin
      if Item.Index < ((Item.ParentItem.Intf as _Worksheet).ChartObjects(EmptyParam,0) as ChartObjects).Count then
        Result := (((Item.ParentItem.Intf as _Worksheet).ChartObjects(Item.Index+1,0) as ChartObject).Chart)
      else
        Result := ((Item.ParentItem.Intf as _Worksheet).ChartObjects(EmptyParam,0)
          as ChartObjects).Add(0,0,300,300).Chart;
    end;

  end;
end;

procedure TOpExcel.FixupCollection(Item: TOpNestedCollectionItem);
begin
  Item.Connect;
end;

procedure TOpExcel.ReleaseCollectionInterface(Item: TOpNestedCollectionItem);
begin
  Item.Intf := nil;
end;

procedure TOpExcel.GetAppInfo(Info: TStrings);
var
  App: _Application;
  Mcp: string;
begin
  if not Connected then
    OleCheck(CoCreate(CLASS_Application_, _Application, App))
  else
    App := FServer;
  if assigned(Info) then
  begin
    with Info do
    begin
      Clear;
      Add('User Name=' + App.UserName[0]);
      Add('Organization Name=' + App.OrganizationName[0]);
      Add('Operating System=' + App.OperatingSystem[0]);
      Add('Version=' + App.Version[0]);
      Add('Build=' + inttostr(App.Build[0]));
      Add('Memory Total=' + inttostr(App.MemoryTotal[0]));
      Add('Memory Free=' + inttostr(App.MemoryFree[0]));
      Add('Memory Used=' + inttostr(App.MemoryUsed[0]));
      if App.MathCoProcessorAvailable[0] then Mcp := 'Yes'
      else Mcp := 'No';
      Add('Math CoProcessorAvailable=' + Mcp);
    end;
  end;
end;

function TOpExcel.GetRangeByName(Name: string): TOpExcelRange;
var
  RangeList: TList;
begin
  Result := nil;
  RangeList := TList.Create;
  try
    if Workbooks.FindItem(Name,FindRange,RangeList) then
      Result := TOpExcelRange(RangeList[0])
    else
      Raise ERangeException.Create(SRangeFail);
  finally
    RangeList.Free;
  end;
end;

function TOpExcel.FindRange(var Key; Item: TOpNestedCollectionItem): Boolean;
begin
  Result := false;
  if (Item is TOpExcelRange) and (UpperCase(TOpExcelRange(Item).Name) = UpperCase(string(Key))) then
  begin
    Result := true;
  end;
end;

function TOpExcel.CollectionNotify(var Key;
  Item: TOpNestedCollectionItem): Boolean;
begin
  if (Item is TOpExcelRange) and (TComponent(Key) = (Item as TOpExcelRange).OfficeModel) then
  begin
    (Item as TOpExcelRange).OfficeModel := nil;
    Result := true;
  end
  else
    Result := false;
end;

procedure TOpExcel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent,Operation);
  if (Operation = opRemove) and (AComponent is TOpUnknownComponent) then
  begin
    Workbooks.FindItem(AComponent,CollectionNotify,nil)
  end;
end;

function TOpExcel.PixelsPerInch: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC,LOGPIXELSY);
  finally
    ReleaseDC(0,DC);
  end;
end;

function TOpExcel.PixelsToPoints(Pixels: Integer): Double;
begin
  Result := (Pixels / PixelsPerInch) * 72;
end;

function TOpExcel.PointsToPixels(Points: Double): Integer;
begin
  Result := Trunc((Points / 72) * PixelsPerInch);
end;

procedure TOpExcel.GetFileInfo(var Filter, DefExt: string);
begin
  Filter := SExcelFilter;
  DefExt := SExcelDef;
end;

function TOpExcel.DeleteWorkbook(var Key;
  Item: TOpNestedCollectionItem): Boolean;
begin
  Result := False;
  if (Item is TOpExcelWorkbook) then
  begin
    if Item.Intf = IDispatch(Key) then
      Result := True;
  end;
end;

procedure TOpExcel.DoConnect;
begin
  OleCheck(CoCreate(CLASS_Application_, _Application, FServer));
  FServer.SheetsInNewWorkbook[0] := 1;
  FServer.DisplayAlerts[0] := false;
  // Registers Connection Point
  CreateEvents(FServer, DIID_AppEvents);
  FServer.EnableEvents := true;
end;

procedure TOpExcel.DoDisconnect;
begin
  // UnRegisiter Connection Point
  Events.Free;
  // Mechanism to Release interfaces so Excel will go away.
  FWorkbooks.ForEachItem(ReleaseCollectionInterface);
  FServer.Quit;
  FServer := nil;
end;

function TOpExcel.GetOfficeVersionStr: string;
begin
  Result := FServer.Version[0];
end;

{ TOpExcelWorkbooks }

function TOpExcelWorkbooks.Add: TOpExcelWorkbook;
begin
  Result := TOpExcelWorkbook(inherited Add);
end;

function TOpExcelWorkbooks.GetItem(index: Integer): TOpExcelWorkbook;
begin
  Result := TOpExcelWorkbook(inherited GetItem(index));
end;

function TOpExcelWorkbooks.GetItemName: string;
begin
  Result := 'Workbook';
end;

procedure TOpExcelWorkbooks.SetItem(index: Integer;
  const Value: TOpExcelWorkbook);
begin
  inherited SetItem(index,Value);
end;

{ TOpExcelWorkbook }

constructor TOpExcelWorkbook.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  if PropDirection = pdToServer then Worksheets.Add;
end;

procedure TOpExcelWorkbook.Connect;
begin
  inherited Connect;
  // Fixup Workbook
  if PropDirection = pdFromServer then
    FileName := FFileName;
end;

procedure TOpExcelWorkbook.CreateSubCollections;
begin
  FWorksheets := TOpExcelWorksheets.Create(RootComponent,self,TOpExcelWorksheet);
end;

destructor TOpExcelWorkbook.Destroy;
begin
  FWorksheets.Free;
  if ((RootComponent as TOpOfficeComponent).Connected) and
    (not(csInEvent in (RootComponent as TOpOfficeComponent).ClientState)) then
  begin
    (RootComponent as TOpExcel).Server.EnableEvents := False;
    (Intf as _Workbook).Close(False,emptyParam,emptyParam,0);
    Intf := nil;
    (RootComponent as TOpExcel).Server.EnableEvents := True;
  end;
  inherited Destroy;
end;

function TOpExcelWorkbook.GetSubCollection(index: Integer): TCollection;
begin
  Result := FWorksheets;
end;

function TOpExcelWorkbook.GetSubCollectionCount: Integer;
begin
  Result := 1;
end;

procedure TOpExcelWorkbook.SetFilename(const Value: TFilename);
begin
  FFilename := Value;
  if (CheckActive(False,ctProperty)) and (PropDirection = pdFromServer) then
  begin
    Worksheets.Clear;
    if assigned(Intf) then
    begin
      (RootComponent as TOpExcel).Server.EnableEvents := False;
      AsWorkbook.Close(EmptyParam,EmptyParam,EmptyParam,0);
      (RootComponent as TOpExcel).Server.EnableEvents := True;
    end;
    LoadWorkbook;
  end;
end;

function TOpExcelWorkbook.SaveCollection: Boolean;
begin
  Result := PropDirection = pdToServer;
end;

procedure TOpExcelWorkbook.LoadWorkbook;
var
  i,j: Integer;
  NewSheet: TOpExcelWorksheet;
begin
  Intf := (RootComponent as TOpExcel).Server.Workbooks._Open(        {!!.62}
    FFileName,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
    EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
    EmptyParam,EmptyParam,EmptyParam,0);

  for i := 1 to AsWorkbook.Worksheets.Count do
  begin
    NewSheet := Worksheets.Add;
    // Hyperlinks

    for j := 1 to NewSheet.AsWorksheet.Hyperlinks.Count do
    begin
      NewSheet.Hyperlinks.Add;
    end;
    // Ranges
    // Maybe support loading of named ranges later.

    // Charts

    for j := 1 to (NewSheet.AsWorksheet.ChartObjects(EmptyParam,0) as ChartObjects).Count do
    begin
      NewSheet.Charts.Add;
    end;
  end;
end;

function TOpExcelWorkbook.GetAsWorkbook: _Workbook;
begin
  CheckActive(True,ctProperty);
  Result := Intf as _Workbook;
end;

function TOpExcelWorkbook.GetPropDirection: TOpPropDirection;
begin
  if FFilename = '' then
    Result := pdToServer
  else
    Result := pdFromServer;
end;

procedure TOpExcelWorkbook.Activate;
begin
  if CheckActive(False,ctMethod) then
    AsWorkbook.Activate(0);
end;

procedure TOpExcelWorkbook.Save;
begin
  AsWorkbook.Save(0);
end;

procedure TOpExcelWorkbook.SaveAs(FileName: TFileName);
begin
  AsWorkbook._SaveAs(FileName,EmptyParam,EmptyParam,EmptyParam,      {!!.62}
    EmptyParam,EmptyParam,xlNoChange,EmptyParam,EmptyParam,EmptyParam,
    EmptyParam,GetUserDefaultLCID);                                  {!!.63}
end;

procedure TOpExcelWorkbook.ExecuteVerb(index: Integer);
begin
  case index of
    0: Save;
  end;
end;

function TOpExcelWorkbook.GetVerb(index: Integer): String;
begin
  Result := 'Save Workbook';
end;

function TOpExcelWorkbook.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TOpExcelWorkbook.Print;
begin
  CheckActive(True,ctMethod);
  AsWorkbook._PrintOut(EmptyParam,EmptyParam,1,False,EmptyParam,False,False,0);
end;

{ TOpExcelWorksheets }

function TOpExcelWorksheets.Add: TOpExcelWorksheet;
begin
  Result := TOpExcelWorksheet(inherited Add);
end;

function TOpExcelWorksheets.GetItem(index: Integer): TOpExcelWorksheet;
begin
  Result := TOpExcelWorksheet(inherited GetItem(index));
end;

function TOpExcelWorksheets.GetItemName: string;
begin
  Result := 'Worksheet';
end;

procedure TOpExcelWorksheets.SetItem(index: Integer;
  const Value: TOpExcelWorksheet);
begin
  inherited SetItem(index,Value);
end;

{ TOpExcelWorksheet }


procedure TOpExcelWorksheet.Activate;
begin
  if CheckActive(False,ctMethod) then
    AsWorksheet.Activate(0);
end;

procedure TOpExcelWorksheet.Connect;
begin
  inherited Connect;
  // If no name, get from Excel.
  if ((ParentItem as TOpExcelWorkbook).PropDirection = pdFromServer) or (FName = '') then
    FName := Name
  else
    Name := FName;
end;

procedure TOpExcelWorksheet.CreateSubCollections;
begin
  FRanges := TOpExcelRanges.Create(RootComponent,self,TOpExcelRange);
  FHyperlinks := TOpExcelHyperlinks.Create(RootComponent,self,TOpExcelHyperlink);
  FCharts := TOpExcelCharts.Create(RootComponent,self,TOpExcelChart);
end;

destructor TOpExcelWorksheet.Destroy;
var
  Count : integer;
begin
  if assigned(Intf) and not(csInEvent in (RootComponent as TOpOfficeComponent).ClientState) then
  begin
    Count := (((Intf as _Worksheet).Parent as _Workbook).Worksheets).Count;
    if (Count > 1) then
    begin
      (Intf as _Worksheet).Delete(0);
      Intf := nil;
    end;
  end;
  FRanges.Free;
  FHyperlinks.Free;
  FCharts.Free;
  inherited Destroy;
end;

function TOpExcelWorksheet.GetAsWorksheet: _Worksheet;
begin
  CheckActive(True,ctProperty);
  Result := Intf as _Worksheet;
end;

function TOpExcelWorksheet.GetName: WideString;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsWorksheet.Name;
    FName := Result;
  end
  else
    Result := FName;
end;

procedure TOpExcelWorksheet.SetName(const Value: WideString);
begin
  FName := Value;
  if CheckActive(False,ctProperty) then
    AsWorksheet.Name := Value;
end;

function TOpExcelWorksheet.GetSubCollection(index: Integer): TCollection;
begin
  Result := nil;
  case index of
    0: Result := FRanges;
    1: Result := FHyperlinks;
    2: Result := FCharts;
  end;
end;

function TOpExcelWorksheet.GetSubCollectionCount: Integer;
begin
  Result := 3;
end;

procedure TOpExcelWorksheet.Print;
var
  Worksheet: Variant;
begin
  CheckActive(True,ctMethod);
  { Workaraound late-binding call here, the type library has been incorrectly changed }
  Worksheet := AsWorksheet;
  Worksheet.PrintOut(EmptyParam,EmptyParam,1,False,EmptyParam,False,False);
  Worksheet := UnAssigned;
end;

{ TOpExcelRange }


procedure TOpExcelRange.ClearRange;
begin
  CheckActive(True,ctMethod);
  AsRange.ClearContents;
end;

procedure TOpExcelRange.Activate;
begin
  if CheckActive(False,ctMethod) then
  begin
    (ParentItem.Intf as _Worksheet).Activate(0);
  end;
end;

procedure TOpExcelRange.ExecuteVerb(index: Integer);
begin
  case index of
    0: Populate;
    1: Select;
    2: SetAddressFromSelection;
  end;
end;

function TOpExcelRange.GetAddress: string;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := AsRange.Address[False,False,xlA1,EmptyParam,EmptyParam];
    FAddress := Result;
  end
  else
    Result := FAddress;
end;

function TOpExcelRange.GetAnchorCell: string;
begin
  CheckActive(True,ctProperty);
  Result := AsRange.Range['A1',EmptyParam].Address[False,False,xlA1,EmptyParam,EmptyParam];
end;

function TOpExcelRange.GetAsRange: Range;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as Range);
end;

function TOpExcelRange.GetSubCollection(index: Integer): TCollection;
begin
  Result := nil;
end;

function TOpExcelRange.GetSubCollectionCount: Integer;
begin
  Result := 0;
end;

function TOpExcelRange.GetVerb(index: Integer): string;
begin
  case index of
    0: Result := 'Populate Range';
    1: Result := 'Select Range';
    2: Result := 'Set From Selection';
  end;
end;

function TOpExcelRange.GetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TOpExcelRange.Populate;
var
  MaxCols: Integer;
  Model: IOpModel;
  Col,Row: integer;
  RangeCol: Range;
  NewRange: Range;
  Size: Integer;
begin
  CheckActive(True,ctMethod);

  Screen.Cursor := crHourglass;
  try
    MaxCols := 0;
    Model := FModel as IOpModel;
    if not(assigned(Model)) then raise EModelException.Create(SModelNotAssigned);
    Intf := (ParentItem.Intf as _Worksheet).Range[AnchorCell,AnchorCell];

    if assigned(Model) then
    begin
      (ParentItem.Intf as _Worksheet).Outline.SummaryRow := XLSummaryAbove;
      Row := 0;
      Model.BeginRead;
      (RootComponent as TOpExcel).Server.ScreenUpdating[0] := false;
      Model.First;
      NewRange := (Intf as Range).Offset[Row,0].Resize[1,Model.ColCount];
      NewRange.Value := Model.GetColHeaders;
      NewRange.Font.Bold := true;
      NewRange.HorizontalAlignment := TOleEnum(XLHAlignCenter);
      inc(Row);

      while not Model.Eof do
      begin
        if Model.ColCount > MaxCols then MaxCols := Model.ColCount;
        if rmPacket in Model.GetSupportedModes then
        begin
          NewRange := AsRange.Offset[Row,0].Resize[1,Model.ColCount];
          NewRange.Value := Model.GetData(0,rmPacket,Size);
          NewRange.EntireRow.OutlineLevel := Model.Level;
        end
        else
        begin
          for Col := 0 to Model.ColCount - 1 do
          begin
            AsRange.Offset[Row,Col].Value := Model.GetData(Col,rmCell,Size);
          end;
        end;
        Model.Next;
        inc(Row);
      end; //EndWhile
      for Col := 0 to MaxCols -1 do
      begin
        RangeCol := AsRange.Offset[0,Col].EntireColumn;
        if (FModel is TOpDataSetModel) then
        begin
          if (TOpDataSetModel(FModel).WantFullMemos) then
            RangeCol.VerticalAlignment := TOleEnum(xlVAlignTop);
        end;
        RangeCol.AutoFit;
      end;
      Intf :=
        AsRange.Offset[0,0].Resize[Row,MaxCols];
      UpdateDesigner;
      Model.EndRead;
    end;
  finally
    (RootComponent as TOpExcel).Server.ScreenUpdating[0] := true;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOpExcelRange.PopulateCurrent;
var
  Model: IOpModel;
  Col: integer;
  RangeCol: Range;
  NewRange: Range;
  Size: Integer;
begin
  CheckActive(True, ctMethod);

  Screen.Cursor := crHourglass;
  try
    Model := FModel as IOpModel;
    if not(assigned(Model)) then raise EModelException.Create(SModelNotAssigned);
    Intf := (ParentItem.Intf as _Worksheet).Range[AnchorCell,AnchorCell];

    if assigned(Model) then
    begin
      (RootComponent as TOpExcel).Server.ScreenUpdating[0] := false;

      if rmPacket in Model.GetSupportedModes then
      begin
        NewRange := (Intf as Range).Resize[1,Model.ColCount];
        NewRange.Value := Model.GetData(0,rmPacket,Size);
      end
      else
      begin
        for Col := 0 to Model.ColCount - 1 do
        begin
          (Intf as Range).Offset[0,Col].Value := Model.GetData(Col,rmCell,Size);
        end;
      end;

      for Col := 0 to Model.ColCount -1 do
      begin
        RangeCol := AsRange.Offset[0,Col].EntireColumn;
        if (FModel is TOpDataSetModel) then
        begin
          if (TOpDataSetModel(FModel).WantFullMemos) then
            RangeCol.VerticalAlignment := TOleEnum(xlVAlignTop);
        end;
        RangeCol.AutoFit;
      end;
      Intf :=
        AsRange.Offset[0,0].Resize[EmptyParam,Model.ColCount];
      UpdateDesigner;
    end;
  finally
    (RootComponent as TOpExcel).Server.ScreenUpdating[0] := true;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOpExcelRange.PopulateHeaders;                             {!!.63}
var
  Model: IOpModel;
  Row: integer;
  NewRange: Range;
begin
  CheckActive(True,ctMethod);
  try
    Model := FModel as IOpModel;
    if not(assigned(Model)) then raise EModelException.Create(SModelNotAssigned);
    Intf := (ParentItem.Intf as _Worksheet).Range[AnchorCell,AnchorCell];

    if assigned(Model) then
    begin
      (ParentItem.Intf as _Worksheet).Outline.SummaryRow := XLSummaryAbove;
      Row := 0;
      Model.BeginRead;
      (RootComponent as TOpExcel).Server.ScreenUpdating[0] := false;
      Model.First;
      NewRange := (Intf as Range).Offset[Row,0].Resize[1,Model.ColCount];
      NewRange.Value := Model.GetColHeaders;
      NewRange.Font.Bold := true;
      NewRange.HorizontalAlignment := TOleEnum(XLHAlignCenter);
    end;
  finally
    (RootComponent as TOpExcel).Server.ScreenUpdating[0] := true;
  end;
end;


procedure TOpExcelRange.SetAddress(const Value: string);
var
  OldRange: Range;
begin
  try
    if CheckActive(False,ctProperty) then
    begin
      if assigned(Intf) then
        OldRange := Intf as Range;
      Intf := (ParentItem.Intf as _Worksheet).Range[Value,Value];
      if assigned(OldRange) and FClearOnMove then
        OldRange.ClearContents;
      UpdateDesigner;
    end;
    FAddress := Value;
  except
    on EOleException do
    begin
      messageDlg(SInvalidRangeAddress,mtError,[mbOk],0);
    end;
  end;
end;

procedure TOpExcelRange.SetAddressFromSelection;
begin
  CheckActive(True,ctMethod);
  ParentItem.Activate;
  if assigned(((RootComponent as TOpExcel).Server.ActiveWindow).RangeSelection) then
  begin
    Intf := ((RootComponent as TOpExcel).Server.ActiveWindow).RangeSelection;
    // Update designer if there.
    UpdateDesigner;
  end
  else
    raise ERangeException.Create(SInvalidRangeSelection);
end;

procedure TOpExcelRange.SetModel(Value: TOpUnknownComponent);
begin
  if Value <> nil then Value.FreeNotification(self.RootComponent);
  FModel := Value;
end;

function TOpExcelRange.GetSimpleText: string;
begin
  if CheckActive(False,ctProperty) then
  begin
    try
      Result := AsRange.Text;
      FSimpleText := Result;
    except
      on EVariantError do
      begin
        Result := '(N/A)';
        FSimpleText := Result;
      end;
    end;
  end
  else
    Result := FSimpleText;
end;

procedure TOpExcelRange.SetSimpleText(const Value: string);
begin
  if CheckActive(False,ctProperty) then
  begin
    if Value <> '(N/A)' then
      AsRange.Value :=  Value;
  end;
  FSimpleText := Value;
end;

function TOpExcelRange.ShouldPersistValue: Boolean;
begin
  Result := FSimpleText <> '(N/A)';
end;

procedure TOpExcelRange.Select;
begin
  AsRange.Select;
  // Pop to top if visible.
  if (RootComponent as TOpExcel).Server.Visible[0] then (RootComponent as TOpExcel).Server.Visible[0] := True;
end;

procedure TOpExcelRange.Connect;
begin
  inherited Connect;
  if FAddress = '' then
  begin
    Address := 'A1';
    FSimpleText := SimpleText;
  end
  else
    Address := FAddress;
  case (ParentItem.ParentItem as TOpExcelWorkbook).PropDirection of
    pdToServer:    begin
                     SimpleText := FSimpleText;
                   end;
    pdFromServer:  begin
                     FSimpleText := SimpleText;
                     end;
  end;
end;

function TOpExcelRange.GetValue: Variant;
begin
  CheckActive(True,ctProperty);
  Result := AsRange.Value;
end;

procedure TOpExcelRange.SetValue(const Value: Variant);
begin
  CheckActive(True,ctProperty);
  AsRange.Value :=  Value;
end;

function TOpExcelRange.GetIsEmpty: Boolean;
var
  i,j: Integer;
  ExcelRangeData: Variant;
begin
  CheckActive(True,ctProperty);
  Result := True;
  ExcelRangeData := Value;
  if VarIsArray(ExcelRangeData) then
  begin
    for i := 1 to VarArrayDimCount(ExcelRangeData) do
    begin
      for j := VarArrayLowBound(ExcelRangeData,i) to
        VarArrayHighBound(ExcelRangeData,i) do
      begin
        if not VarIsEmpty(ExcelRangeData[j,i]) then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end
  else
    if not VarIsEmpty(Value) then
      Result := False;
end;

{ TOpExcelRanges }

function TOpExcelRanges.Add: TOpExcelRange;
begin
  Result := TOpExcelRange(inherited Add);
end;

function TOpExcelRanges.GetItem(index: Integer): TOpExcelRange;
begin
  Result := TOpExcelRange(inherited GetItem(index));
end;

function TOpExcelRanges.GetItemName: string;
begin
  Result := 'Range';
end;

procedure TOpExcelRanges.SetItem(index: Integer;
  const Value: TOpExcelRange);
begin
  inherited SetItem(index,Value);
end;

{ TOpHyperlink }

procedure TOpExcelHyperlink.Connect;
begin
  inherited Connect;

  case (ParentItem.ParentItem as TOpExcelWorkbook).PropDirection of
    pdToServer:    begin
                     Address := FAddress;
                     SubAddress := FSubAddress;
                     AnchorCell := FAnchorCell;
                     NewWindow := FNewWindow;
                     Visible := FVisible;
                   end;
    pdFromServer:  begin
                     FAddress := Address;
                     FSubAddress := SubAddress;
                     FAnchorCell := AnchorCell;
                     FNewWindow := NewWindow;
                     FVisible := True;
                   end;
  end;
end;

destructor TOpExcelHyperlink.Destroy;
begin
  try
    if assigned(Intf) and not(csInEvent in (RootComponent as TOpOfficeComponent).ClientState) then
      AsHyperlink.Delete;
    Intf := nil;
  except
    // Need to continue to go down if fails (e.g. protected cells).
  end;
  inherited Destroy;
end;

procedure TOpExcelHyperlink.ExecuteVerb(index: Integer);
begin
  case Index of
    0: Follow;
  end;
end;

procedure TOpExcelHyperlink.Follow;
begin
  CheckActive(True,ctMethod);
  (Intf as Hyperlink).Follow(FNewWindow,False,EmptyParam,EmptyParam,EmptyParam);
  // Need to do this or user entries will go to original sheet. MS Bug ?
  (RootComponent as TOpExcel).Server.ActiveWindow.Activate;
end;

function TOpExcelHyperlink.GetAddress: string;
begin
  if CheckActive(false,ctProperty) and assigned(Intf) then
  begin
    Result := AsHyperlink.Address;
    FAddress := Result;
  end
  else
    Result := FAddress;
end;

function TOpExcelHyperlink.GetAnchorCell: string;
begin
  if CheckActive(false,ctProperty) and assigned(Intf) then
  begin
    case AsHyperlink.Type_ of
      MSOHyperlinkRange: Result := AsHyperlink.Range.Address[False,False,xlA1,EmptyParam,EmptyParam];
      MSOHyperlinkShape: Result := AsHyperlink.Shape.Name;
      MSOHyperlinkInlineShape: Result := AsHyperlink.Shape.Name;
    end;
    FAnchorCell := Result;
  end
  else
    Result := FAnchorCell;
end;

function TOpExcelHyperlink.GetAsHyperlink: Hyperlink;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as Hyperlink);
end;

function TOpExcelHyperlink.GetNewWindow: Boolean;
begin
  Result := FNewWindow;
end;

function TOpExcelHyperlink.GetSubAddress: string;
begin
  if CheckActive(False,ctProperty) and assigned(Intf) then
  begin
    Result := AsHyperlink.SubAddress;
    FSubAddress := Result;
  end
  else
    Result := FSubAddress;
end;

function TOpExcelHyperlink.GetSubCollection(index: Integer): TCollection;
begin
  Result := nil;
end;

function TOpExcelHyperlink.GetSubCollectionCount: Integer;
begin
  Result := 0;
end;

function TOpExcelHyperlink.GetVerb(index: Integer): string;
begin
  Result := 'Follow';
end;

function TOpExcelHyperlink.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TOpExcelHyperlink.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TOpExcelHyperlink.RecreateLink;
var
  Temp: OLEVariant;
begin
  if (csLoading in RootComponent.ComponentState) then Exit;
  if assigned(Intf) then
  begin
    AsHyperlink.Delete;
    Intf := nil;
  end;
  try
    // Work around late-binding call for mistake in MS TLB.
    Temp := (ParentItem.Intf as _Worksheet).Hyperlinks;
    Intf := IDispatch(Temp.Add((ParentItem.Intf as _Worksheet).Range[FAnchorCell,FAnchorCell],FAddress,FSubAddress));
  except
    On Exception do
    begin
      if not (csConnecting in (RootComponent as TOpExcel).ClientState) then
        messageDlg(SHyperlinkError,mtError,[mbOk],0);
    end;
  end;
end;

procedure TOpExcelHyperlink.SetAddress(const Value: string);
begin
  if CheckActive(False,ctProperty) and assigned(Intf) then
    AsHyperlink.Address := Value;
  FAddress := Value;
end;

procedure TOpExcelHyperlink.SetAnchorCell(const Value: string);
begin
  FAnchorCell := Value;
  if Visible then RecreateLink;
end;

procedure TOpExcelHyperlink.SetNewWindow(const Value: Boolean);
begin
  FNewWindow := Value;
  if Visible then RecreateLink;
end;

procedure TOpExcelHyperlink.SetSubAddress(const Value: string);
begin
  if CheckActive(False,ctProperty) and assigned(Intf) then
    AsHyperlink.SubAddress := Value;
  FSubAddress := Value;
end;

procedure TOpExcelHyperlink.SetVisible(const Value: Boolean);
begin
  if Value = FVisible then Exit;
  if Value then
  begin
    RecreateLink;
  end
  else
    if assigned(Intf) then
    begin
      AsHyperlink.Delete;
      Intf := nil;
    end;
  FVisible := Value;
end;

{ TOpHyperlinks }

function TOpExcelHyperlinks.Add: TOpExcelHyperlink;
begin
  Result := TOpExcelHyperlink(inherited Add);
end;

function TOpExcelHyperlinks.GetItem(index: Integer): TOpExcelHyperlink;
begin
  Result := TOpExcelHyperlink(inherited GetItem(index));
end;

function TOpExcelHyperlinks.GetItemName: string;
begin
  Result := 'Hyperlink';
end;

procedure TOpExcelHyperlinks.SetItem(index: Integer; const Value: TOpExcelHyperlink);
begin
  inherited SetItem(index,Value);
end;

{ TOpExcelChart }

function TOpExcelChart.GetAsChart: Chart;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as Chart);
end;

procedure TOpExcelChart.Connect;
begin
  inherited Connect;
  case (ParentItem.ParentItem as TOpExcelWorkbook).PropDirection of
    pdToServer:   begin
                    Top := FTop;
                    Left := FLeft;
                    Width := FWidth;
                    Height := FHeight;
                    ChartType := FChartType;
                    if FRange <> '' then
                      DataRange := FRange;
                  end;
    pdFromServer: begin
                    FTop := Top;
                    FLeft := Left;
                    FWidth := Width;
                    FHeight := Height;
                    FChartType := ChartType;
                    FRange := '';
                  end;
  end;
end;

function TOpExcelChart.GetChartType: TOpXlChartType;
begin
  if CheckActive(False,ctProperty) then
  begin
    case DWord(AsChart.ChartType) of
      xlArea: Result := xlctArea ;
      xlBarStacked: Result := xlctBar;
      xlLine: Result := xlctLine;
      xlPie: Result := xlctPie;
      xlRadar: Result := xlctRadar;
      xlXYScatter: Result := xlctXYScatter;
      xl3DArea: Result := xlct3DArea;
      xl3DBarStacked: Result := xlct3DBar;
      xl3DColumn: Result := xlct3DColumn;
      xl3DLine: Result := xlct3DLine;
      xl3DPie: Result := xlct3DPie;
      xlDoughnut: Result := xlctDoughnut;
      else
        Result := xlctUnknown;
    end;
    FChartType := Result;
  end
  else
    Result := FChartType;
end;

function TOpExcelChart.GetHeight: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := (RootComponent as TOpExcel).PointsToPixels(AsChartObject.Height);
    FHeight := Result;
  end
  else
    Result := FHeight;
end;

function TOpExcelChart.GetLeft: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := (RootComponent as TOpExcel).PointsToPixels(AsChartObject.Left);
    FLeft := Result;
  end
  else
    Result := FLeft;
end;

function TOpExcelChart.GetRange: string;
begin
  Result := FRange;
end;

function TOpExcelChart.GetSubCollection(index: Integer): TCollection;
begin
  Result := nil;
end;

function TOpExcelChart.GetSubCollectionCount: Integer;
begin
  Result := 0;
end;

function TOpExcelChart.GetTop: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := (RootComponent as TOpExcel).PointsToPixels(AsChartObject.Top);
    FTop := Result;
  end;
  Result := FTop;
end;

function TOpExcelChart.GetWidth: Integer;
begin
  if CheckActive(False,ctProperty) then
  begin
    Result := (RootComponent as TOpExcel).PointsToPixels(AsChartObject.Width);
    FWidth := Result;
  end;
  Result := FWidth;
end;

procedure TOpExcelChart.SetChartType(const Value: TOpXlChartType);
var
  V: DWORD;
begin
  V := 0;
  if (RootComponent as TOpExcel).Connected then
  begin
    case Value of
      xlctArea: V := xlArea;
      xlctBar:  V := xlBarStacked;
      xlctLine: V := xlLine;
      xlctPie: V := xlPie;
      xlctRadar: V := xlRadar;
      xlctXYScatter: V := xlXYScatter;
      xlct3DArea: V := xl3DArea;
      xlct3DBar: V := xl3DBarStacked;
      xlct3DColumn: V := xl3DColumn;
      xlct3DLine: V := xl3DLine;
      xlct3DPie: V := xl3DPie;
      xlctDoughnut: V := xlDoughnut;
      xlctUnknown: V := xlDefaultAutoFormat;
    end;
    AsChart.ChartType := V;
  end;
  FChartType := Value;
end;

procedure TOpExcelChart.SetHeight(const Value: Integer);
begin
  if (RootComponent as TOpExcel).Connected then
  begin
    AsChartObject.Height := (RootComponent as TOpExcel).PixelsToPoints(Value);
  end;
  FHeight := Value;
end;

procedure TOpExcelChart.SetLeft(const Value: Integer);
begin
  if (RootComponent as TOpExcel).Connected then
  begin
    AsChartObject.Left := (RootComponent as TOpExcel).PixelsToPoints(Value);
  end;
  FLeft := Value;
end;

procedure TOpExcelChart.SetRange(const Value: string);
begin
  FRange := Value;
  if CheckActive(False,ctProperty) then
  begin
    AsChart.ChartWizard((ParentItem.Intf as Worksheet).Range[Value,Value],
      EmptyParam,EmptyParam,EmptyParam,1,1,true,EmptyParam,EmptyParam,EmptyParam,EmptyParam,0);
  end;
end;

procedure TOpExcelChart.SetTop(const Value: Integer);
begin
  if (RootComponent as TOpExcel).Connected then
  begin
    AsChartObject.Top := (RootComponent as TOpExcel).PixelsToPoints(Value);
  end;
  FTop := Value;
end;

procedure TOpExcelChart.SetWidth(const Value: Integer);
begin
  if (RootComponent as TOpExcel).Connected then
  begin
    AsChartObject.Width := (RootComponent as TOpExcel).PixelsToPoints(Value);
  end;
  FWidth := Value;
end;

procedure TOpExcelChart.Activate;
begin
  if CheckActive(False,ctMethod) then
    AsChartObject.Activate;
end;

function TOpExcelChart.GetAsChartObject: ChartObject;
begin
  CheckActive(True,ctMethod);
  Result := (AsChart.Parent as ChartObject);
end;

destructor TOpExcelChart.Destroy;
begin
  try
    if assigned(Intf) and not(csInEvent in (RootComponent as TOpOfficeComponent).ClientState) then
      AsChartObject.Delete;
    Intf := nil;
  except
    // Need to continue to go down if fails (e.g. protected cells).
  end;
  inherited Destroy;
end;

procedure TOpExcelChart.SetAddressFromSelection;
begin
  CheckActive(True,ctMethod);
  ParentItem.Activate;
  if assigned(((RootComponent as TOpExcel).Server.ActiveWindow).RangeSelection) then
  begin
    DataRange := ((RootComponent as TOpExcel).Server.ActiveWindow).RangeSelection
      .Address[False,False,xlA1,EmptyParam,EmptyParam];
    // Update designer if there.
    UpdateDesigner;
  end
  else
    raise ERangeException.Create(SInvalidRangeSelection);
end;

procedure TOpExcelChart.ExecuteVerb(index: Integer);
begin
  case index of
    0: SetAddressFromSelection;
  end;
end;

function TOpExcelChart.GetVerb(index: Integer): string;
begin
  Result := 'Set Range from Selection';
end;

function TOpExcelChart.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TOpExcelCharts }

function TOpExcelCharts.Add: TOpExcelChart;
begin
  Result := TOpExcelChart(inherited Add);
end;

function TOpExcelCharts.GetItem(index: Integer): TOpExcelChart;
begin
  Result := TOpExcelChart(inherited GetItem(index));
end;

function TOpExcelCharts.GetItemName: string;
begin
  Result := 'Chart';
end;

procedure TOpExcelCharts.SetItem(index: Integer;
  const Value: TOpExcelChart);
begin
  inherited SetItem(index,Value);
end;

{additional property setters}
procedure TOpExcelRange.SetFontName(val : String);
begin
  if FFontName <> val then begin
    FFontName := val;
    if CheckActive(False, ctProperty) then
      AsRange.Font.Name := FFontName;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetFontColor(val : TColor);
begin
  if (FFontColor <> val) then begin
    FFontColor := Val;
    if CheckActive(False, ctProperty) then
      AsRange.Font.Color := ColorToRGB(FFontColor);
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetFontSize(val : Integer);
begin
  if ((FFontSize <> val) and (val >= 1)) then begin
    FFontSize := Val;
    if CheckActive(False, ctProperty) then
      AsRange.Font.Size := FFontSize;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetFontAttributes(val : TOpXlRangeFontAttributes);
begin
  FFontAttributes := val;
  if CheckActive(False, ctProperty) then begin
    if (xlfaBold in val) then
      AsRange.Font.Bold := True
    else
      AsRange.Font.Bold := False;
    if (xlfaItalic in val) then
      AsRange.Font.Italic := True
    else
      AsRange.Font.Italic := False;
    if (xlfaUnderline in val) then
      AsRange.Font.Underline := True
    else
      AsRange.Font.Underline := False;
    if (xlfaStrikethrough in val) then
      AsRange.Font.Strikethrough := True
    else
      AsRange.Font.Strikethrough := False;  
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetIndentLevel(val : Integer);
begin
  if (Val <> FIndentLevel) then begin
    if (Val < 1) then
      FIndentLevel := 1
    else if (Val > 15) then
      FIndentLevel := 15
    else
      FIndentLevel := Val;
    if CheckActive(False,ctProperty) then
      AsRange.IndentLevel := FIndentLevel;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetOrientation(val : TOpXlCellOrientation);
begin
  if (FOrientation <> Val) then begin
    FOrientation := Val;
    if CheckActive(False,ctProperty) then
      case FOrientation of
        xlcoDownward : AsRange.Orientation := OleVariant(xlDownward);
        xlcoHorizontal : AsRange.Orientation := OleVariant(xlHorizontal);
        xlcoUpward : AsRange.Orientation := OleVariant(xlUpward);
        xlcoVertical : AsRange.Orientation := OleVariant(xlVertical);
        xlCoRotated : AsRange.Orientation := OleVariant(FRotateDegrees);
      end;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetShrinkToFit(val : Boolean);
begin
  if (FShrinkToFit <> Val) then begin
    FShrinkToFit := Val;
  if CheckActive(False,ctProperty) then
    AsRange.ShrinkToFit := FShrinkToFit;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetRotateDegrees(val : Integer);
begin
  if (FRotateDegrees <> Val) then
    begin
      if (val < -90) then
        FRotateDegrees := -90
      else if (val > 90) then
        FRotateDegrees := 90
      else
        FRotateDegrees := Val;
      if CheckActive(False,ctProperty) then begin
        if (FOrientation = xlCoRotated) then
          AsRange.Orientation := FRotateDegrees;
      end;
    end;
end;
{-------------------------}
procedure TOpExcelRange.SetHorizontalAlignment(val : TOpXlCellHorizAlign);
begin
  if (FHorizontalAlignment <> val) then
    begin
      FHorizontalAlignment := Val;
      if CheckActive(False,ctProperty) then
        case FHorizontalAlignment of
          xlchaGeneral : AsRange.HorizontalAlignment := OleVariant(xlHAlignGeneral);
          xlchaLeft : AsRange.HorizontalAlignment := OleVariant(xlHAlignLeft);
          xlchaCenter : AsRange.HorizontalAlignment := OleVariant(xlHAlignCenter);
          xlchaRight : AsRange.HorizontalAlignment := OleVariant(xlHAlignRight);
          xlchaFill : AsRange.HorizontalAlignment := OleVariant(xlHAlignDistributed);
          //xlHAlignFill??
          xlchaJustify : AsRange.HorizontalAlignment := OleVariant(xlHAlignJustify);
          xlchaCenterAcrossSelection : AsRange.HorizontalAlignment := OleVariant(xlHAlignCenterAcrossSelection);
        end;
    end;
end;
{-------------------------}
procedure TOpExcelRange.SetVerticalAlignment(val : TOpXlCellVertAlign);
begin
  if (FVerticalAlignment <> Val) then begin
    FVerticalAlignment := Val;
    if CheckActive(False,ctProperty) then
      case FVerticalAlignment of
        xlcvaTop : AsRange.VerticalAlignment := OleVariant(xlVAlignTop);
        xlcvaCenter : AsRange.VerticalAlignment := OleVariant(xlVAlignCenter);
        xlcvaBottom : AsRange.VerticalAlignment := OleVariant(xlVAlignBottom);
        xlcvaJustify : AsRange.VerticalAlignment := OleVariant(xlVAlignJustify);
        xlcvaDistributed : AsRange.VerticalAlignment := OleVariant(xlVAlignDistributed);
      end;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetColumnWidth(val : Integer);
begin
  if ((FColumnWidth <> val) and (Val > 0)) then begin
    FColumnWidth := Val;
    if CheckActive(False, ctProperty) then
      AsRange.ColumnWidth := FColumnWidth;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetRowHeight(val : Integer);
begin
  if ((FRowHeight <> val) and (val > 0)) then begin
    FRowHeight := val;
    if CheckActive(False, ctProperty) then
      AsRange.RowHeight := FRowHeight;
  end;    
end;
{-------------------------}
procedure TOpExcelRange.SetColor(val : TColor);
begin
  if (FColor <> val) then begin
    FColor := val;
    if CheckActive(False, ctProperty) then
      AsRange.Interior.Color := FColor;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetPattern(val : TOpXlInteriorPatterns);
begin
  if (FPattern <> val) then
    FPattern := val;
  if CheckActive(False, ctProperty) then
    case FPattern of
      xlipPatternAutomatic : AsRange.Interior.Pattern := OleVariant(xlPatternAutomatic);
      xlipPatternChecker : AsRange.Interior.Pattern := OleVariant(XlPatternChecker);
      xlipPatternCrissCross : AsRange.Interior.Pattern := OleVariant(XlPatternCrissCross);
      xlipPatternDown : AsRange.Interior.Pattern := OleVariant(XlPatternDown);
      xlipPatternGray16 : AsRange.Interior.Pattern := OleVariant(xlPatternGray16);
      xlipPatternGray25 : AsRange.Interior.Pattern := OleVariant(xlPatternGray25);
      xlipPatternGray50 : AsRange.Interior.Pattern := OleVariant(xlPatternGray50);
      xlipPatternGray75 : AsRange.Interior.Pattern := OleVariant(xlPatternGray75);
      xlipPatternGray8 : AsRange.Interior.Pattern := OleVariant(xlPatternGray8);
      xlipPatternGrid : AsRange.Interior.Pattern := OleVariant(XlPatternGrid);
      xlipPatternHorizontal : AsRange.Interior.Pattern := OleVariant(XlPatternHorizontal);
      xlipPatternLightDown : AsRange.Interior.Pattern := OleVariant(XlPatternLightDown);
      xlipPatternLightHorizontal : AsRange.Interior.Pattern := OleVariant(XlPatternLightHorizontal);
      xlipPatternLightUp : AsRange.Interior.Pattern := OleVariant(XlPatternLightUp);
      xlipPatternLightVertical : AsRange.Interior.Pattern := OleVariant(XlPatternLightVertical);
      xlipPatternNone : AsRange.Interior.Pattern := OleVariant(XlPatternNone);
      xlipPatternSemiGray75 : AsRange.Interior.Pattern := OleVariant(xlPatternSemiGray75);
      xlipPatternSolid : AsRange.Interior.Pattern := OleVariant(XlPatternSolid);
      xlipPatternUp : AsRange.Interior.Pattern := OleVariant(XlPatternUp);
      xlipPatternVertical : AsRange.Interior.Pattern := OleVariant(xlPatternVertical);
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetPatternColor(val : TColor);
begin
  if (FPatternColor <> val) then begin
    FPatternColor := val;
    if CheckActive(False, ctProperty) then
      AsRange.Interior.PatternColor := FPatternColor;
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetBorderLineStyle(val : TOpXlBorderLineStyles);
begin
  if (FBorderLineStyle <> val) then
    FBorderLineStyle := val;
  if CheckActive(False, ctProperty) then begin
    if (xlbLeft in FBorders) then
      case FBorderLineStyle of
        xlblsContinuous : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlContinuous);
        xlblsDash  : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlDash);
        xlblsDashDot : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlDashDot);
        xlblsDashDotDot : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlDashDotDot);
        xlblsDot  : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlDot);
        xlblsDouble : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlDouble);
        xlblsLineStyleNone : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlLineStyleNone);
        xlblsSlantDashDot : AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(XlSlantDashDot);
      end
    else
      AsRange.Borders[xlEdgeLeft].LineStyle := OleVariant(xlLineStyleNone);

    if (xlbRight in FBorders) then
      case FBorderLineStyle of
        xlblsContinuous : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlContinuous);
        xlblsDash  : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlDash);
        xlblsDashDot : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlDashDot);
        xlblsDashDotDot : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlDashDotDot);
        xlblsDot  : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlDot);
        xlblsDouble : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlDouble);
        xlblsLineStyleNone : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlLineStyleNone);
        xlblsSlantDashDot : AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(XlSlantDashDot);
      end
    else
      AsRange.Borders[xlEdgeRight].LineStyle := OleVariant(xlLineStyleNone);


    if (xlbTop in FBorders) then
      case FBorderLineStyle of
        xlblsContinuous : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlContinuous);
        xlblsDash  : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlDash);
        xlblsDashDot : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlDashDot);
        xlblsDashDotDot : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlDashDotDot);
        xlblsDot  : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlDot);
        xlblsDouble : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlDouble);
        xlblsLineStyleNone : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlLineStyleNone);
        xlblsSlantDashDot : AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(XlSlantDashDot);
      end
    else
      AsRange.Borders[xlEdgeTop].LineStyle := OleVariant(xlLineStyleNone);


    if (xlbBottom in FBorders) then
      case FBorderLineStyle of
        xlblsContinuous : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlContinuous);
        xlblsDash  : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlDash);
        xlblsDashDot : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlDashDot);
        xlblsDashDotDot : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlDashDotDot);
        xlblsDot  : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlDot);
        xlblsDouble : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlDouble);
        xlblsLineStyleNone : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlLineStyleNone);
        xlblsSlantDashDot : AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(XlSlantDashDot);
      end
    else
      AsRange.Borders[xlEdgeBottom].LineStyle := OleVariant(xlLineStyleNone);
  end;
end;
{-------------------------}
procedure TOpExcelRange.SetBorders(val : TOpXlRangeBorders);
begin
  FBorders := val;
  SetBorderLineThickness(FBorderLineThickness);
  SetBorderLineStyle(FBorderLineStyle);
end;
{-------------------------}
procedure TOpExcelRange.SetBorderLineThickness(val :TOpXlBorderWeights);
begin
  if (FBorderLineThickness <> val) then
    FBorderLineThickness := val;
  if CheckActive(False, ctProperty) then begin

    if (xlbLeft in FBorders) then
      case FBorderLineThickness of
        xlbwHairline : AsRange.Borders[xlEdgeLeft].Weight := OleVariant(XlHairline);
        xlbwThin : AsRange.Borders[xlEdgeLeft].Weight := OleVariant(XlThin);
        xlbwMedium : AsRange.Borders[xlEdgeLeft].Weight := OleVariant(XlMedium);
        xlbwThick : AsRange.Borders[xlEdgeLeft].Weight := OleVariant(XlThick);
      end;

    if (xlbRight in FBorders) then
      case FBorderLineThickness of
        xlbwHairline : AsRange.Borders[xlEdgeRight].Weight := OleVariant(XlHairline);
        xlbwThin : AsRange.Borders[xlEdgeRight].Weight := OleVariant(XlThin);
        xlbwMedium : AsRange.Borders[xlEdgeRight].Weight := OleVariant(XlMedium);
        xlbwThick : AsRange.Borders[xlEdgeRight].Weight := OleVariant(XlThick);
      end;

    if (xlbTop in FBorders) then
      case FBorderLineThickness of
        xlbwHairline : AsRange.Borders[xlEdgeTop].Weight := OleVariant(XlHairline);
        xlbwThin : AsRange.Borders[xlEdgeTop].Weight := OleVariant(XlThin);
        xlbwMedium : AsRange.Borders[xlEdgeTop].Weight := OleVariant(XlMedium);
        xlbwThick : AsRange.Borders[xlEdgeTop].Weight := OleVariant(XlThick);
      end;

    if (xlbBottom in FBorders) then
      case FBorderLineThickness of
        xlbwHairline : AsRange.Borders[xlEdgeBottom].Weight := OleVariant(XlHairline);
        xlbwThin : AsRange.Borders[xlEdgeBottom].Weight := OleVariant(XlThin);
        xlbwMedium : AsRange.Borders[xlEdgeBottom].Weight := OleVariant(XlMedium);
        xlbwThick : AsRange.Borders[xlEdgeBottom].Weight := OleVariant(XlThick);
      end;
  end;
end;

procedure TOpExcelRange.SetWrapText(val : Boolean);
begin
  if (FWrapText <> Val) then
    FWrapText := Val;
  if CheckActive(False, ctProperty) then
    AsRange.WrapText := FWrapText;
end;

procedure TOpExcelRange.AutoFitColumns;
begin
  if CheckActive(False, ctProperty) then
    AsRange.Columns.AutoFit;
end;

procedure TOpExcelRange.AutoFitRows;
begin
  if CheckActive(False, ctProperty) then
    AsRange.Rows.AutoFit;
end;


procedure TOpExcelRange.Clear;
begin
  AsRange.Clear;
end;

constructor TOpExcelRange.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  {set defaults...}
  //FFontName := FontName;
  FFontColor := clWindowText;
  FFontSize := 12;
  FFontAttributes := [];
  FIndentLevel := 0;
  FOrientation := xlcoHorizontal;
  FShrinkToFit := False;
  FRotateDegrees := 0;
  FHorizontalAlignment := xlchaLeft;
  FVerticalAlignment := xlcvaBottom;
  FColumnWidth := 20;
  FRowHeight := 12;
  FColor := clWindow;
  FPattern := xlipPatternNone;
  FPatternColor := clWhite;
  FBorderLineStyle := xlblsLineStyleNone;
  FBorderLineThickness := xlbwHairline;
  FBorders := [];
end;

end.
