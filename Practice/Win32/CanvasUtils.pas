unit CanvasUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Canvas Utility Functions

   Written:  Mar 2000
   Authors:  Matthew

   Purpose:

   Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   Graphics;

function CalcAcctColWidth( aCanvas : TCanvas; aFont : TFont; MinWidth : integer ): integer;
//******************************************************************************
implementation
uses
   Globals,
   Math,
   GenUtils;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CalcAcctColWidth( aCanvas : TCanvas; aFont : TFont; MinWidth : integer ): integer;
//returns the greater of the min width, or the width of the max no of characters in the char
//as the would be rendered on the canvas provided.
// Steve, this function should be in a different unit because it uses graphics.pas.
begin
  //Assign the requested font to the canvas before calling text width or get wrong result
  aCanvas.Font.Assign( aFont);
  if Assigned( MyClient) then
     result := Max( aCanvas.TextWidth( ConstStr( 'X', MyClient.clChart.MaxCodeLength + 1 ) ), MinWidth )
  else
     result := MinWidth;
end;

end.
 