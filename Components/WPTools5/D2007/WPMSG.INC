{ --------------------------------------------------------------------------- }
{        Word Processing Tools: RTF proccessing in native Delphi              }
{                  (C) 1996/1997 by Julian Ziersch                            }
{               INFO: http://members.aol.com/jziersch                         }
{                  E-MAIL: WPTools@compuserve.com                             }
{ --------------------------------------------------------------------------- }

const
{$IFDEF WIN32}
   WP_BASE = $B800;
{$ELSE}
   WP_BASE = $1000;
{$ENDIF}
   WP_RTFEDIT_CHANGED = WP_BASE + 1;
   WP_SEL_ICON        = WP_BASE + 2;
   WP_ENABLE_ICON     = WP_BASE + 3;
   WP_SELLIST         = WP_BASE + 4;  { convert TWpSelNr types }

   WP_ICONUP    = 0;
   WP_ICONDOWN  = 1;
   WP_ICONCROSS = 2; 

   WP_wptName      = 1;
   WP_wptSize      = 2;
   WP_wptColor     = 3;
   WP_wptBkColor   = 4;
   WP_wptTyp       = 5;
   WP_wptIconSel   = 6;
   WP_wptIconDeSel = 7;
   WP_wptPage      = 8;
   WP_wptParagraph = 9;
   WP_wptParColor  = 10;
   WP_wptHtmlFontSize  = 11;
   WP_wptParAlignment  = 12;
   WP_wptStyleNames    = 13;
