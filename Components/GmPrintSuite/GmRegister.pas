{******************************************************************************}
{                                                                              }
{                               GmRegister.pas                                 }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmRegister;

interface

//{$I GMPS.INC}

uses
  Classes,
  GmPreview,
  GmThumbnails,
  GmRtfPreview,
  GmRtfMailMerge,
  GmGridPrint,
  GmDbGridPrint,
  GmLabelPrinter,
  GmPageNavigator,
  GmTreeViewPrint,
  GmPropertyComboBox,
  GmPropertyGraphic;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('GmPrintSuite', [TGmPreview]);
  RegisterComponents('GmPrintSuite', [TGmThumbnails]);
  RegisterComponents('GmPrintSuite', [TGmRtfPreview]);
  RegisterComponents('GmPrintSuite', [TGmRtfMailMerge]);
  RegisterComponents('GmPrintSuite', [TGmGridPrint]);
  RegisterComponents('GmPrintSuite', [TGmDbGridPrint]);
  RegisterComponents('GmPrintSuite', [TGmLabelPrinter]);
  RegisterComponents('GmPrintSuite', [TGmPageNavigator]);
  RegisterComponents('GmPrintSuite', [TGmTreeViewPrint]);
  RegisterComponents('GmPrintSuite', [TGmPropertyComboBox]);
  RegisterComponents('GmPrintSuite', [TGmPropertyGraphic]);
end;

end.
