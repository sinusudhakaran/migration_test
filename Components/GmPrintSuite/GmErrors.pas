{******************************************************************************}
{                                                                              }
{                                GmErrors.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmErrors;

interface

uses Dialogs, Classes;

const
  GM_THUMBNAILS_GRID_RANGE  = '"GridWidth" property must be > 1';
  GM_NO_PREVIEW_ASSIGNED    = 'The "Preview" property must be set to a TGmPreview component';
  GM_NO_GRID_ASSIGNED       = 'The "Grid" property must be set to a valid grid component"';
  GM_DRAW_LABELS_FAILED     = 'Unable to draw labels...';
  GM_PRO_VERSION_ONLY       = 'This functionallity is only available in GmPrintSuite Professional.'+#13+#13+
                              'Register at:  http://www.murtsoft.co.uk/register.html';

  procedure ProVersionOnly(AText: string);
  procedure ShowGmError(Sender: TObject; AMessage: string);

implementation

procedure ProVersionOnly(AText: string);
begin
  ShowMessage(AText+#13+#13+GM_PRO_VERSION_ONLY);
end;

procedure ShowGmError(Sender: TObject; AMessage: string);
begin
  ShowMessage(Sender.ClassName+' Error!'+#13+#13+AMessage);
end;

end.
