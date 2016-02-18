unit RenderEngineObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Report Rendering Engine

  Written: Dec 1999
  Authors: Matthew

  Purpose: Provide a base object for the Rendering Engine objects ( File, Canvas, Excel )

  Notes:   Provides the basic interface required for generating a report.
           It is expected that each of the calls will be redefined in the descendant classes.

           Should always be "Owned" by a report object

           Only exists so that it can be descended from.  Not intended to be created
           directly;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  reportTypes,
  Graphics;

type
   TWrappedText = array of String;

   TProcedurePtr = procedure(Sender : TObject);

   TCustomRenderEngine = class( TObject)
   protected
      FOnAfterNewPage : TProcedurePtr;
      Owner : TObject;

      function GetFont() : TFont; virtual; abstract;
      procedure SetFont(aFont : TFont); virtual; abstract;
   public
      constructor Create( aOwner : TObject); virtual;

      procedure RequireLines(lines :integer); virtual; abstract;
      procedure RenderDetailHeader; virtual; abstract;
      procedure RenderDetailLine; virtual; abstract;
      procedure RenderDetailSubSectionTotal(const TotalName : string); virtual; abstract;
      procedure RenderDetailSectionTotal(const TotalName : string); virtual; abstract;
      procedure RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
        KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal); virtual; abstract;
      procedure RenderDetailGrandTotal(const TotalName : string); virtual; abstract;
      procedure RenderDetailRunningTotal(const TotalName : string); virtual; abstract;
      procedure RenderTitleLine(Text : string); virtual; abstract;
      procedure RenderTextLine(Text:string; Underlined : boolean; AddLineIfUnderlined: boolean = True); virtual; abstract;
      procedure RenderMemo( Text : string); virtual;
      procedure RenderRuledLine; overload; virtual; abstract;
      procedure RenderRuledLine(Style : TPenStyle); overload; virtual; abstract;
      procedure SingleUnderLine; virtual; abstract;
      procedure DoubleUnderLine; virtual; abstract;
      procedure ReportNewPage; virtual; abstract;
      function  RenderColumnWidth(ColumnID: Integer; Text : String): Integer; virtual; abstract;
      procedure RenderColumnLine(ColNo: Integer); virtual; abstract;
      procedure RenderVerticalColumnLine(ColNo: Integer); virtual;
      procedure RenderAllVerticalColumnLines; virtual;
      procedure RenderRuledLineWithColLines(LeaveLines: integer = 0;
        aPenStyle: TPenStyle = psSolid; VertColLineType: TVertColLineType = vcFull); virtual;
      procedure RenderEmptyLine(); virtual; abstract;
      procedure UseCustomFont( aFontname : string; aFontSize : integer; aFontStyle : TFontStyles; aLineSize : integer); virtual; abstract;
      procedure UseDefaultFont; virtual; abstract;
      function GetTextLength(s: string): Integer; virtual;
      procedure SetItemStyle(const Value: TStyleTypes); virtual;
      function GetPrintableWidth: Integer; virtual;

      procedure Generate; virtual;

      procedure SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText); virtual;

      property  OnAfterNewPage : TProcedurePtr read FOnAfterNewPage write FOnAfterNewPage;
      property Font : TFont read GetFont write SetFont;
   end;

//******************************************************************************
implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TRenderEngine }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TCustomRenderEngine.Create(aOwner: TObject);
begin
   inherited Create;
   Owner     := aOwner;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCustomRenderEngine.Generate;
begin
   //Should be overriden
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCustomRenderEngine.RenderAllVerticalColumnLines;
begin
  //Override in subclass if needed
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCustomRenderEngine.RenderMemo(Text: string);
begin
   Assert( false, 'TCustomRenderEngine.RenderWrappedText called');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCustomRenderEngine.RenderRuledLineWithColLines(LeaveLines: integer;
  aPenStyle: TPenStyle; VertColLineType: TVertColLineType);
begin
  //Override in subclass if needed
end;

procedure TCustomRenderEngine.RenderVerticalColumnLine(ColNo: Integer);
begin
  //Override in subclass if needed
end;

procedure TCustomRenderEngine.SetItemStyle(const Value: TStyleTypes);
begin

end;

procedure TCustomRenderEngine.SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText);
begin
  SetLength(WrappedText, 1);

  WrappedText[0] := Text;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TCustomRenderEngine.GetTextLength(s: string): Integer;
begin
  Result := -1;
end;

function TCustomRenderEngine.GetPrintableWidth: Integer;
begin
  Result := -1;
end;

end.
