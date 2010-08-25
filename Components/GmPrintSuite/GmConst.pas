{******************************************************************************}
{                                                                              }
{                                 GmConst.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmConst;

interface

uses Messages;

const
  GMPS_VERSION  = 2.96;
  BUILD_VERSION = 6;

  DEFAULT_BUFFER    = 4096;
  DEFAULT_FONT      = 'Arial';
  DEFAULT_FONT_SIZE = 10;
  MM_PER_INCH       = 25.4;
  SCREEN_PPI        = 96;
  DEFAULT_TITLE     = '<document>';
  DEFAULT_MAX_ZOOM  = 400;
  DEFAULT_MIN_ZOOM  = 5;
  DEFAULT_ZOOM_INC  = 10;
  DEFAULT_BUFSIZE   = 4096;
  // messages...

  GM_SET_ZOOM             = WM_USER + 6000;
  GM_SET_ORIENTATION      = WM_USER + 6001;
  GM_SET_PAPERSIZE        = WM_USER + 6003;
  GM_CENTER_PAGE          = WM_USER + 6005;
  GM_PAGE_MOUSEDOWN       = WM_USER + 6006;
  GM_PAGE_MOUSEMOVE       = WM_USER + 6007;
  GM_PAGE_MOUSEUP         = WM_USER + 6008;
  GM_GET_NUM_PAGES        = WM_USER + 6009;
  GM_MULTIPAGE_CHANGED    = WM_USER + 6010;
  GM_HEADERFOOTER_CHANGED = WM_USER + 6011;
  GM_ORIENTATION_CHANGED  = WM_USER + 6012;
  GM_PREVIEW_UPDATED      = WM_USER + 6013;

  GM_PAGE_CONTENT_CHANGED = WM_USER + 6014;
  GM_PAGE_COUNT_CHANGED   = WM_USER + 6015;

  GM_GET_ORIENTATION_TYPE = WM_USER + 6016;
  GM_PREVIEW_ZOOM_CHANGED = WM_USER + 6017;
  GM_PRINTER_CHANGED      = WM_USER + 6018;
  GM_BEGINUPDATE          = WM_USER + 6019;
  GM_ENDUPDATE            = WM_USER + 6020;
  GM_PAPERSIZE_CHANGED    = WM_USER + 6021;
  GM_GETPAGELIST          = WM_USER + 6022;

  GM_PAGE_NUM_CHANGED     = WM_USER + 6023;

  GM_VARIABLE_ZOOM: array[0..14] of integer = (7, 10, 14, 20, 30, 45,
                                               60, 80, 120, 170, 250,
                                               350, 500, 650, 800);

  // File ID values...
  C_V   = 'V';    // version
  C_O   = 'O';    // orientation
  C_PS  = 'PS';   // paper size
  C_PH  = 'PH';   // page height
  C_PW  = 'PW';   // page width
  C_NP  = 'NP';   // num pages
  C_SH  = 'SH';   // show header
  C_SF  = 'SF';   // show footer
  C_NO  = 'NO';   // num objects

  C_CLM = 'CLM';  // clip margins
  C_MV  = 'MV';   // margin values
  C_WRT = 'C_WRT';// wrap rich text 

  C_VS  = 'VS';   // visible
  C_SL  = 'SL';   // show line
  C_HT  = 'HT';   // height

  C_ID  = 'ID';   // object ID
  C_UI  = 'UI';   // object unique id
  C_RT  = 'RT';   // resource type
  C_RC  = 'RC';   // reference count
  C_RN  = 'RN';   // reference number
  C_CL  = 'CL';   // color
  C_ST  = 'ST';   // style
  C_SZ  = 'SZ';   // size

  // resource id's
  C_B   = 'B';    // brush
  C_F   = 'F';    // font
  C_P   = 'P';    // pen
  C_G   = 'G';    // graphic
  C_M   = 'M';    // memo

  C_FA  = 'FA';   // font angle
  C_FN  = 'FN';   // font name
  C_CS  = 'CS';   // character set
  C_PM  = 'PM';   // men mode
  C_XY  = 'XY';   // coords
  C_XY2 = 'XY2';  // X2 & Y2 coords
  C_XY3 = 'XY3';  // X3 & Y3 coords
  C_XY4 = 'XY4';  // X4 & Y4 coords
  C_T   = 'T';    // text
  C_TA  = 'TA';   // text alignment
  C_VA  = 'VA';   // vertical alignment
  C_CT  = 'CT';   // clip text
  C_CR  = 'CR';   // clip rect
  C_TP  = 'TP';   // text padding
  C_TH  = 'TH';   // text height
  C_WB  = 'WB';   // word break

  C_CM  = 'CM';   // copy mode
  C_PF  = 'PF';   // pixel format
  C_PT  = 'PT';   // path type


var
  CALC_PPI: integer;
  GlobalTimeTokenFormat: string;
  GlobalDateTokenFormat: string;

  function GetStrVersion(Sender: TObject): string;


implementation

uses SysUtils, GmFuncs;

  function GetStrVersion(Sender: TObject): string;
  begin
    Result := Sender.ClassName+' v'+FormatFloat('0.00#', GMPS_VERSION)+'.'+IntToStr(BUILD_VERSION);
//    if IsBeta then
//      Result := Result + '.'+IntToStr(BETA_VERSION)+' (beta)';
//    {$IFDEF GMPS_LITE}
//      Result := Result + ' Lite';
//    {$ENDIF}
  end;

initialization

  GlobalDateTokenFormat := 'dd/mm/yyyy';
  GlobalTimeTokenFormat := 'hh/mm';

end.
