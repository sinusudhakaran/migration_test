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

type TProcedurePtr = procedure(Sender : TObject);

type
   TCustomRenderEngine = class( TObject)
   protected
      Owner : TObject;
   public
      constructor Create( aOwner : TObject); virtual;

      procedure RequireLines(lines :integer); virtual; abstract;
      procedure RenderDetailHeader; virtual; abstract;
      procedure RenderDetailLine; virtual; abstract;
      procedure RenderDetailSectionTotal; virtual; abstract;
      procedure RenderDetailSubTotal; virtual; abstract;
      procedure RenderDetailGrandTotal; virtual; abstract;
      procedure RenderTitleLine(Text : string); virtual; abstract;
      procedure RenderTextLine(Text:string); virtual; abstract;
      procedure RenderRuledLine; virtual; abstract;
      procedure SingleUnderLine; virtual; abstract;
      procedure DoubleUnderLine; virtual; abstract;
      procedure ReportNewPage; virtual; abstract;

      procedure Generate; virtual;
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
end.
