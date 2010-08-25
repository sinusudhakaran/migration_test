unit WPIOCSS;

{ ------------------------------------------------------------------------------
  WPCubed Complete Generic CSS Parser
  ------------------------------------------------------------------------------
  written by Julian Ziersch in July and August  2003, Last Update Speptember 2006
  Copyright (C) 2008 - all rights reserved by WPCubed GmbH
  WEB: http://www.wptools.de
  ------------------------------------------------------------------------------ }

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Restrictions:
   Comments are only allowed between styles and beween elements. Other comments are
   discarded.
   It is possible to mark elements, styles and atoms as deleted. Those will
   not any longer be recognized by any function and not saved with AsString

   The only published properties are 'Deleted' and 'AsString'.
   Those are used to set values


  p{display:block;font-family:"Arial";/* Ignored Comment */font-size:11pt;color:black;margin:0.00in;text-align:left;}
  // CommentA
  /* CommentB */
  LI{display:list-item;font-family:"Arial";font-size:0pt;color:black;margin-top:0.00in;margin-bottom:0.00in;text-align:left;}
  td{display:block;font-family:"Arial";font-size:0pt;color:black;margin-left:0.00in;margin-right:0.00in;text-align:left;}

  Relative length units
    em  The height of the element's font.
    ex  The height of the letter "x".
    px Pixels (uses 96 a reference)
    % Percentage.
  Absolute length units
    in Inches (1 inch = 2.54 centimeters).
    cm Centimeters.
    mm Millimeters.
    pt Points (1 point = 1/72 inches).
    pc Picas (1 pica = 12 points).
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

   {--$DEFINE DONT_RESTRICT_SPACE}// Don't allow smaller spacing and padding than -36 twips

interface

{$I WPINC.INC}

uses Classes, Sysutils, Graphics, WPRTEDefs, Windows {MulDiv};

{$IFDEF VER200} //For now - special adaption will be in V6
  {$WARNINGS OFF}
{$ENDIF}

type

  TWPCSSParserAtomType = (wp_EmptyValue, wp_ptValue, wp_pxValue, wp_inValue, wp_mmValue, wp_cmValue,
    wp_PHValue, wp_IValue, wp_FValue, wp_nameValue, wp_strValue, wp_urlValue);

type TWPCSSName = (
    wpcss_custom_defined, // Use 'Name' - this is undefined
    wpcss_direction,
    wpcss_font,
    wpcss_font_family,
    wpcss_font_size,
    wpcss_font_style,
    wpcss_font_variant,
    wpcss_font_weight,
    wpcss_ime_mode,
    wpcss_layout_grid,
    wpcss_layout_grid_char,
    wpcss_layout_grid_line,
    wpcss_layout_grid_mode,
    wpcss_layout_grid_type,
    wpcss_letter_spacing,
    wpcss_line_break,
    wpcss_line_height,
    wpcss_min_height,
    wpcss_ruby_align,
    wpcss_ruby_overhang,
    wpcss_ruby_position,
    wpcss_text_align,
    wpcss_text_autospace,
    wpcss_text_decoration,
    wpcss_text_indent,
    wpcss_text_justify,
    wpcss_text_kashida_space,
    wpcss_text_overflow,
    wpcss_text_transform,
    wpcss_text_underline_position,
    wpcss_unicode_bidi,
    wpcss_vertical_align,
    wpcss_white_space,
    wpcss_word_break,
    wpcss_word_spacing,
    wpcss_word_wrap,
    wpcss_writing_mode,
    wpcss_background_attachment,
    wpcss_background_color,
    wpcss_background_image,
    wpcss_background_position,
    wpcss_background_position_x,
    wpcss_background_position_y,
    wpcss_background_repeat,
    wpcss_color,
    wpcss_border,
    wpcss_border_bottom,
    wpcss_border_bottom_color,
    wpcss_border_bottom_style,
    wpcss_border_bottom_width,
    wpcss_border_collapse,
    wpcss_border_color,
    wpcss_border_left,
    wpcss_border_left_color,
    wpcss_border_left_style,
    wpcss_border_left_width,
    wpcss_border_right,
    wpcss_border_right_color,
    wpcss_border_right_style,
    wpcss_border_right_width,
    wpcss_border_style,
    wpcss_border_top,
    wpcss_border_top_color,
    wpcss_border_top_style,
    wpcss_border_top_width,
    wpcss_border_width,
    wpcss_clear,
    wpcss_float,
    wpcss_layout_flow,
    wpcss_margin,
    wpcss_margin_bottom,
    wpcss_margin_left,
    wpcss_margin_right,
    wpcss_margin_top,
    wpcss_padding,
    wpcss_padding_bottom,
    wpcss_padding_left,
    wpcss_padding_right,
    wpcss_padding_top,
    wpcss_scrollbar_3dlight_color,
    wpcss_scrollbar_arrow_color,
    wpcss_scrollbar_base_color,
    wpcss_scrollbar_darkshadow_color,
    wpcss_scrollbar_face_color,
    wpcss_scrollbar_highlight_color,
    wpcss_scrollbar_shadow_color,
    wpcss_table_layout,
    wpcss_zoom,
    wpcss_list_style,
    wpcss_list_style_image,
    wpcss_list_style_position,
    wpcss_list_style_type,
    wpcss_clip,
    wpcss_height,
    wpcss_left,
    wpcss_overflow,
    wpcss_overflow_x,
    wpcss_overflow_y,
    wpcss_position,
    wpcss_right,
    wpcss_top,
    wpcss_visibility,
    wpcss_width,
    wpcss_z_index,
    wpcss_pageBreakAfter,
    wpcss_pageBreakBefore,
 // WPCubed Enhancements, not existent anywhere else
    wpcss_tabstop, // Left Tab in in, cm ...
    wpcss_tabstop_left, // Left Tab in in, cm ...
    wpcss_tabstop_right, // Right Tab in in, cm ...
    wpcss_tabstop_center, // Center Tab in in, cm ...
    wpcss_tabstop_decimal, // Decimal Tab in in, cm ...
    wpcss_pageRotate,
    wpcss_style_next, // NEXT STyle
    wpcss_style_parent
    );

  TWPCSSParserAtom = class
  private
    FDeleted: Boolean;
    function iValue: Integer;
    function GetStringValue: string;
    function GetAsString: String;
    procedure SetAsString(x: String);
    procedure Clear;
    function GetAsTwipsEx(preferred_typ : TWPCSSParserAtomType = wp_EmptyValue): Integer;
    function GetAsTwips : Integer;
    function GetAsColor: TColor;
  public
    Typ: TWPCSSParserAtomType;
    fValue: Double; // wp_ptValue, wp_pxValue, wp_inValue
    sValue: string; // wp_strValue, wp_urlValue
    sName: string;
  public
    constructor Create;
    destructor Destroy; override;
    function IsColor: Boolean;
    property Deleted: Boolean read FDeleted write FDeleted;
    property AsString: String read GetAsString write SetAsString;
    property AsTwips: Integer read GetAsTwips; //TODO write SetAsTwips;
    property AsColor: TColor read GetAsColor; //TODO write SetAsTwips;
    property StringValue: string read GetStringValue; // text, twips or color (wpValue type!)
  end;

  TWPCSSParserItemType = (wpCSStyle, wpCommentA, wpCommentB);

// Each Style element
  TWPCSSParserStyleElement = class
  public
    Typ: TWPCSSParserItemType; // Comments between style elements
  // The name is defined at the '-' sign. so we can search quicker for
  // a certain item. for example 'margin-left'. If Name2 = '' then
  // we have an extra item which requires more work to parse since it
  // can contain several definitions at once.
    FCommentText: string;
  private
    FName: string; // name parts
    FCSSType: TWPCSSName;
    FDeleted: Boolean;
    FAtoms: TList; // List with all items defined for this style
  // Use 'First' to read the first. Can be nil !
    function GetAsString: string;
    function GetAsCommaString: string;
    procedure SetAsString(x: string);
    procedure SetName(x: string);
    procedure Clear;
    function GetAtoms(index: Integer): TWPCSSParserAtom;
  public
    constructor Create(aTyp: TWPCSSParserItemType);
    destructor Destroy; override;
    function AtomCount: Integer;
    property AsString: string read GetAsString write SetAsString;
    property Deleted: Boolean read FDeleted write FDeleted;
    property Atoms[index: Integer]: TWPCSSParserAtom read GetAtoms;
    property Name: string read FName write SetName;
    property CSS: TWPCSSName read FCSSType;
    // This properties read the first Atom!
    function GetStringValue(const defaultvalue: string): string;
    function GetTwipValue(atomnr: Integer; const defaultvalue: Integer; preferred_typ : TWPCSSParserAtomType = wp_EmptyValue): Integer;
    function GetColorValue(const defaultvalue: TColor): TColor;
    function IsEqualTo(const value: string): Boolean;
    function HasValue(const value: string): Boolean;
  end;

// Each Style:
  TWPCSSParserStyle = class(TObject)
  protected
    Typ: TWPCSSParserItemType;
    Text: string; // not modified text of that style or comment
    IsComment: Boolean;
    FName: string; // Can contain the following
    aNameSpace, aClass, aName, aID: string; // aNameSpace:aClass.aName#aID
  // .aName - such as '.small'
  // aClass - such as 'P'
    FElemements: TList; // of type TWPCSSParserStyleElement
    FDeleted, AllOK: Boolean;
    FReference: TObject;
    FReader : TWPCustomTextReader;
    function GetAsString: string;
    procedure SetAsString(Input: string);
    procedure Clear;
    function GetElements(index: Integer): TWPCSSParserStyleElement;
  protected
    procedure BeforeGet; virtual;
    procedure AfterSet; virtual;
  public
    constructor Create(aReader : TWPCustomTextReader);
    destructor Destroy; override;
    function GetElement(const Name: string): TWPCSSParserStyleElement;
    function GetProperty(PropType: TWPCSSName; add: Boolean): TWPCSSParserStyleElement;
    procedure DeleteElement(const Name: string);
    procedure Delete(nr: Integer);
    function HasValue(const ElPartName: string; const AcceptedValues: array of string): Boolean;
    function ElementCount: Integer;
    property Elements[index: Integer]: TWPCSSParserStyleElement read GetElements;
    property AsString: string read GetAsString write SetAsString;
    property Deleted: Boolean read FDeleted write FDeleted;
    property Name: string read FName;
    {:: free for any use }
    property Reference: TObject read FReference write FReference;
  end;

  TWPCSSParserStyleClass = class of TWPCSSParserStyle;

  TWPCSSParser = class(TObject)
  private
    FStyles: TList; // of type TWPCSSParserStyle;
    FStyleClass: TWPCSSParserStyleClass;
    FReader : TWPCustomTextReader;
    function GetAsString: string;
    procedure SetAsString(const Input: string);
    function GetStyleCount: Integer;
    function GetAStyle(index: Integer): TWPCSSParserStyle;
  protected
    procedure SetStyleCallback(const name, definition: string; IsComment: Boolean);
  public
    constructor Create(StyleClass: TWPCSSParserStyleClass; aReader : TWPCustomTextReader); 
    destructor Destroy; override;
    procedure Clear;
    function GetStyle(const aNameSpace, aClass, aName, aID: string): TWPCSSParserStyle;
    property AsString: string read GetAsString write SetAsString;
    property Style[index: Integer]: TWPCSSParserStyle read GetAStyle;
    property StyleCount: Integer read GetStyleCount;
  end;

// -----------------------------------------------------------------------------
// WPTools Stuff
// -----------------------------------------------------------------------------

  TWPCSSParserStyleWP = class(TWPCSSParserStyle)
  protected
    procedure BeforeGet; override;
    procedure AfterSet; override;
  public
    IsCharStyle: Boolean;
    procedure ApplyToStyle(TextStyle: TWPTextStyle);
    procedure ApplyToPar(RTFProps: TWPRTFProps; par: TWPTextStyle; NumLevel: Integer = 0);
    procedure ApplyToAttr(RTFProps: TWPRTFProps; var a: TWPCharAttr);
    // Get and set WPValue list
    procedure GetWPValues(FValues: TStrings);
    // procedure SetWPValues(FValues: TWPValueList);
  end;

  TWPStyleElementPar = (wpseIndentLeft, wpseIndentRight, wpseIndentFirst,
    wpseSpaceBefore, wpseMultSpaceBetween, wpseSpaceBetween, wpseSpaceAfter,
    wpseBrdLines, wpseBrdWidth, wpseBrdColor,
    wpseAlign, wpseColor, wpseShading, wpseTabs,
    wpseNumber, wpseNumberLevel, wpseIsOutline, wpseBorderSpacing, wpseKeepTogether, wpseKeepNext,
    wpseVertAlign);
  TWPStyleElementsPar = set of TWPStyleElementPar;

  TWPStyleElementChar = // attention: See also unit WPStyCol !!!
    (wpseFontBold,
    wpseFontItalic,
    wpseFontUnderline,
    wpseFontFont,
    wpseFontSize,
    wpseFontColor,
    wpseFontBGColor,
    wpseFontStrike);
  TWPStyleElementsChar = set of TWPStyleElementChar;

  TWPExtraStyleDisplayTypes = (wpstUndefined, wpstBlock, wpstInline, wpstList, wpstNone);
  (*
function WPGetCharAttrStr(ValueList: TWPValueList; RTFProps: TWPRTFProps; var ca: TWPCharAttr): string;
function WPGetParAttrStr(ValueList: TWPValueList; RTFProps: TWPRTFProps; par: TParagraph): string;
function WPGetStyleString(ValueList: TWPValueList; Display : TWPExtraStyleDisplayTypes): string;
   *)

var CSSPixelsPerInch: Integer = 96;

const
  // TParAlign = (paralLeft, paralCenter, paralRight, paralBlock);
  WPCSSAlignStr: array[TParAlign] of string = ('left', 'center', 'right', 'justify');
  WPCSSListStyles: array[TWPNumberStyle] of string =
  ('none', 'circle', 'disc',
    'decimal', 'upper-roman', 'lower-roman',
    'upper-alpha', 'lower-alpha',
    'decimal', 'decimal', 'decimal', 'square', 'square', // Undefined !
    'decimal-leading-zero');

  FWPStyleParElementName: array[TWPStyleElementPar] of string = (// Don't localize!
    'IndentLeft', 'IndentRight', 'IndentFirst',
    'SpaceBefore', 'MultSpaceBetween', 'SpaceBetween', 'SpaceAfter',
    'BrdLines', 'BrdWidth', 'BrdColor',
    'Align', 'Color', 'Shading', 'Tabs',
    'Number', 'NumLevel', 'IsOutline', 'BrdSpace', 'KeepTogther', 'KeepWithNext',
    'VertAlign');

  FWPStyleAttrElementName: array[TWPStyleElementChar] of string = (// Don't localize!
    'Bold', 'Italic', 'Underline', 'Font', 'Size',
    'FontColor', 'FontBGColor', 'FontStrikeThrough');

implementation

const WPCSSNames: array[TWPCSSName] of string =
  ('XXnameXX',
    'direction',
    'font',
    'font-family',
    'font-size',
    'font-style',
    'font-variant',
    'font-weight',
    'ime-mode',
    'layout-grid',
    'layout-grid-char',
    'layout-grid-line',
    'layout-grid-mode',
    'layout-grid-type',
    'letter-spacing',
    'line-break',
    'line-height',
    'min-height',
    'ruby-align',
    'ruby-overhang',
    'ruby-position',
    'text-align',
    'text-autospace',
    'text-decoration',
    'text-indent',
    'text-justify',
    'text-kashida-space',
    'text-overflow',
    'text-transform',
    'text-underline-position',
    'unicode-bidi',
    'vertical-align',
    'white-space',
    'word-break',
    'word-spacing',
    'word-wrap',
    'writing-mode',
    'background-attachment',
    'background-color',
    'background-image',
    'background-position',
    'background-position-x',
    'background-position-y',
    'background-repeat',
    'color',
    'border',
    'border-bottom',
    'border-bottom-color',
    'border-bottom-style',
    'border-bottom-width',
    'border-collapse',
    'border-color',
    'border-left',
    'border-left-color',
    'border-left-style',
    'border-left-width',
    'border-right',
    'border-right-color',
    'border-right-style',
    'border-right-width',
    'border-style',
    'border-top',
    'border-top-color',
    'border-top-style',
    'border-top-width',
    'border-width',
    'clear',
    'float',
    'layout-flow',
    'margin',
    'margin-bottom',
    'margin-left',
    'margin-right',
    'margin-top',
    'padding',
    'padding-bottom',
    'padding-left',
    'padding-right',
    'padding-top',
    'scrollbar-3dlight-color',
    'scrollbar-arrow-color',
    'scrollbar-base-color',
    'scrollbar-darkshadow-color',
    'scrollbar-face-color',
    'scrollbar-highlight-color',
    'scrollbar-shadow-color',
    'table-layout',
    'zoom',
    'list-style',
    'list-style-image',
    'list-style-position',
    'list-style-type',
    'clip',
    'height',
    'left',
    'overflow',
    'overflow-x',
    'overflow-y',
    'position',
    'right',
    'top',
    'visibility',
    'width',
    'z-index',
    'page-break-after',
    'page-break-before',
 // WPCubed Enhancements, not existent anywhere else
    'tabstop', // Left Tab in in, cm ...
    'tabstop-left', // Left Tab in in, cm ...
    'tabstop-right', // Right Tab in in, cm ...
    'tabstop-center', // Center Tab in in, cm ...
    'tabstop-decimal', // Decimal Tab in in, cm ...
    'page-rotate',
    'mso-style-next', // NEXT STyle
    'mso-style-parent' // BASE Style
    );

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

function RGB(r, g, b: Byte): CARDINAL;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

// --------------------------------------------------------------------------
// TWPCSSParser
// --------------------------------------------------------------------------

constructor TWPCSSParser.Create(StyleClass: TWPCSSParserStyleClass; aReader : TWPCustomTextReader);
begin
  inherited Create;
  FReader := aReader;
  FStyles := TList.Create;
  FStyleClass := StyleClass;
end;

destructor TWPCSSParser.Destroy;
begin
  Clear;
  FStyles.Free;
  inherited Destroy;
end;

procedure TWPCSSParser.Clear;
var i: Integer;
begin
  for i := 0 to FStyles.Count - 1 do
    TWPCSSParserStyle(FStyles[i]).Free;
  FStyles.Clear;
end;

// Procedure executed for each loaded style

procedure TWPCSSParser.SetStyleCallback(const name, definition: string; IsComment: Boolean);
var aNameSpace, aClass, aName, aID: string;
  Style: TWPCSSParserStyle;
begin
  aNameSpace := '';
  aClass := '';
  aName := '';
  aID := '';
  if IsComment then
  begin
    Style := FStyleClass.Create(FReader);
    Style.Text := definition;
    Style.IsComment := TRUE;
    FStyles.Add(Style);
  end else
  begin
    WPCSS.ParseName(name, aNameSpace, aClass, aName, aID);
    Style := FStyleClass.Create(FReader);
    Style.FName := TrimRight(name);
    Style.aNameSpace := aNameSpace;
    Style.aName := aName;
    Style.aClass := aClass;
    Style.aID := aID;
    Style.AsString := definition;
    FStyles.Add(Style);
  end;
end;

function TWPCSSParser.GetStyle(const aNameSpace, aClass, aName, aID: string): TWPCSSParserStyle;
var i: Integer;
begin
  for i := 0 to FStyles.Count - 1 do
    if (CompareText(TWPCSSParserStyle(FStyles[i]).aNameSpace, aNameSpace) = 0) and
      (CompareText(TWPCSSParserStyle(FStyles[i]).aClass, aClass) = 0) and
      (CompareText(TWPCSSParserStyle(FStyles[i]).aName, aName) = 0) and
      (CompareText(TWPCSSParserStyle(FStyles[i]).aID, aID) = 0) then
    begin
      Result := TWPCSSParserStyle(FStyles[i]);
      exit;
    end;
  Result := FStyleClass.Create(FReader);
  Result.aNameSpace := aNameSpace;
  Result.aClass := aClass;
  Result.aName := aName;
  Result.aID := aID;
  FStyles.Add(Result);
end;

function TWPCSSParser.GetAsString: string;
var i: Integer;
begin
  Result := '';
  for i := 0 to FStyles.Count - 1 do
    Result := Result +
      TWPCSSParserStyle(FStyles[i]).AsString + #13 + #10;
end;

procedure TWPCSSParser.SetAsString(const Input: string);
begin
  Clear;
  WPCSS.ParseCSSTable(Input, nil, SetStyleCallback);
end;

function TWPCSSParser.GetStyleCount: Integer;
begin
  Result := FStyles.Count;
end;

function TWPCSSParser.GetAStyle(index: Integer): TWPCSSParserStyle;
begin
  Result := TWPCSSParserStyle(FStyles[index]);
end;

// --------------------------------------------------------------------------
// TWPCSSParserStyle
// --------------------------------------------------------------------------

constructor TWPCSSParserStyle.Create(aReader : TWPCustomTextReader);
begin
  inherited Create;
  
  FElemements := TList.Create;
  FName := '';
  aNameSpace := '';
  aClass := '';
  aName := '';
  aID := '';
end;

destructor TWPCSSParserStyle.Destroy;
begin
  Clear; //V5.15.6
  FElemements.Free;
  FName := '';
  aNameSpace := '';
  aClass := '';
  aName := '';
  aID := '';
  inherited Destroy;
end;

function TWPCSSParserStyle.GetAsString: string;
var i: Integer;
begin
  BeforeGet;
  if IsComment then
    Result := Text // contains already !'/* ' + Text + ' */'
  else begin
    Result := '';
    if aNameSpace <> '' then
      Result := Result + aNameSpace + ':';

    if aName <> '' then
      Result := Result + aClass + '.' + aName
    else Result := Result + aClass;

    if aID <> '' then
      Result := Result + '#' + aID;

    Result := Result + ' {';
    for i := 0 to FElemements.Count - 1 do
    begin
      if i < FElemements.Count - 1 then
        Result := Result + TWPCSSParserStyleElement(FElemements[i]).AsString + ';'
      else Result := Result + TWPCSSParserStyleElement(FElemements[i]).AsString;
    end;

    Result := Result + '}';
  end;
end;

procedure TWPCSSParserStyle.SetAsString(Input: string);
var i, l, j: Integer;
  hk1, hk2, hasopen, com1, com2: Boolean;
  c: Char;
  s: string;
  procedure AddItem(const Text: string; IsComment: Boolean);
  var element: TWPCSSParserStyleElement;
  begin
    if Text <> '' then
    begin
      if IsComment then
        element := TWPCSSParserStyleElement.Create(wpCommentA)
      else
        element := TWPCSSParserStyleElement.Create(wpCSStyle);
      element.AsString := Text;
      FElemements.Add(element);
    end;
  end;
begin
  Clear;
  AllOK := TRUE;

  // UnQuote the string
  while Input <> '' do
  begin
    if (Input[1] = #39) and (Input[Length(Input)] = #39) then
      Input := Copy(Input, 2, Length(Input) - 2)
    else if (Input[1] = '"') and (Input[Length(Input)] = '"') then
      Input := Copy(Input, 2, Length(Input) - 2)
    else break;
  end;

  l := Length(Input);
  i := 1;
  while (i <= l) do
  begin
    while ((i <= l) and (Input[i] <= #32)) do inc(i);
    if i > l - 1 then break; // need at least 2 chars!
      // Read /* */ comment
    if ((Input[i] = '/') and (Input[i + 1] = '*')) then
    begin
      j := i + 1;
      while (j <= l) do
      begin
        if ((j < l - 1) and (Input[j] = '*') and (Input[j + 1] = '/')) then
        begin inc(j, 2); break; end;
        inc(j);
      end;
      AddItem(Copy(Input, i, j - i), true);
      i := j;
    end
      // Read // Comment
    else if ((Input[i] = '/') and (Input[i + 1] = '/')) then
    begin
      j := i + 1;
      while (j <= l) and (Input[j] <> #10) do
        inc(j);
      AddItem(Copy(Input, i, j - i), true);
      i := j;
    end
      // Read anything until '}' - skips "", '' /* */ and //
    else
    begin
      j := i;
      hk1 := false;
      hk2 := false;
      com1 := false;
      com2 := false;
      hasopen := false;
      s := '';
      while (j <= l) do
      begin
        c := Input[j];
        if hk1 then
        begin
          if c = #39 then hk1 := false
          else if c = #10 then
          begin
            hk1 := false; // String not closed !
            AllOK := false;
          end;
        end else
          if hk2 then
          begin
            if c = '"' then hk2 := false
            else if c = #10 then
            begin
              hk2 := false;
              AllOK := false; // String not closed !
            end;
          end else
            if com1 then
            begin
              if c = #10 then
              begin
                com1 := false;
                inc(j);
                continue;
              end;
            end else
              if com2 then
              begin
                if (j < l) and (c = '*') and (Input[j + 1] = '/') then
                begin
                  com2 := false;
                  inc(j, 2);
                  continue;
                end;
              end
              else if (j < l) and (c = '/') and (Input[j + 1] = '/') then
              begin
                com1 := true;
                inc(j, 2);
                continue;
              end
              else if (j < l) and (c = '/') and (Input[j + 1] = '*') then
              begin
                com2 := true;
                inc(j, 2);
                continue;
              end
              else if c = #39 then hk1 := true
              else if c = '"' then hk2 := true
              else if c = '}' then
              begin
                inc(j);
            // NO !!! s := s+ c;
                break;
              end;
          // No comments and no closing '}'
        if not com1 and not com2 and (hk1 or hk2 or (c > #32)) then
        begin
          if hasopen and (c = ':') then
          begin
            AllOK := False; // Syntax error
          end
          else if c = ':' then
          begin
            hasopen := TRUE;
          end else
            if c = ';' then
            begin
              inc(j);
              break;
            end;
        end;

        if not com1 and not com2 then
        begin
          s := s + c;
        end;

        inc(j);
      end;
      AddItem(s, false);
      i := j;
    end;
  end;
  // ---------------------------------------------------------------------------
  AfterSet;
end;

procedure TWPCSSParserStyle.Clear;
var i: Integer;
begin
  for i := 0 to FElemements.Count - 1 do
    TWPCSSParserStyleElement(FElemements[i]).Free;
  FDeleted := FALSE;
end;

procedure TWPCSSParserStyle.BeforeGet;
begin
  // Override to retrieve the current data from other datastructures ?
end;

procedure TWPCSSParserStyle.AfterSet;
begin
  // Override to update list from other datastructures ?
end;

function TWPCSSParserStyle.GetElement(const Name: string): TWPCSSParserStyleElement;
var i: Integer;
begin
  for i := 0 to FElemements.Count - 1 do
    if (CompareText(TWPCSSParserStyleElement(FElemements[i]).Name, Name) = 0) then
    begin
      Result := TWPCSSParserStyleElement(FElemements[i]);
      exit;
    end;
  Result := TWPCSSParserStyleElement.Create(wpCSStyle);
  Result.Name := Name;
  FElemements.Add(Result);
end;

function TWPCSSParserStyle.GetProperty(PropType: TWPCSSName; add: Boolean): TWPCSSParserStyleElement;
var i: Integer;
begin
  for i := 0 to FElemements.Count - 1 do
    if TWPCSSParserStyleElement(FElemements[i]).FCSSType = PropType then
    begin
      Result := TWPCSSParserStyleElement(FElemements[i]);
      exit;
    end;
  if add then
  begin
    Result := TWPCSSParserStyleElement.Create(wpCSStyle);
    Result.Name := WPCSSNames[PropType];
    FElemements.Add(Result);
  end
  else Result := nil;
end;

procedure TWPCSSParserStyle.DeleteElement(const Name: string);
var i: Integer;
begin
  for i := 0 to FElemements.Count - 1 do
    if (CompareText(TWPCSSParserStyleElement(FElemements[i]).Name, Name) = 0) then
    begin
      TWPCSSParserStyleElement(FElemements[i]).Free;
      FElemements.Delete(i);
      exit;
    end;
end;

procedure TWPCSSParserStyle.Delete(nr: Integer);
begin
  TWPCSSParserStyleElement(FElemements[nr]).Free;
  FElemements.Delete(nr);
end;

function TWPCSSParserStyle.HasValue(const ElPartName: string;
  const AcceptedValues: array of string): Boolean;
var i, j: Integer;
begin
  Result := FALSE;
  for i := 0 to FElemements.Count - 1 do
    if (CompareText(Copy(TWPCSSParserStyleElement(FElemements[i]).Name, 1, Length(ElPartName)), Name) = 0) then
    begin
      for j := 0 to High(AcceptedValues) do
        if TWPCSSParserStyleElement(FElemements[i]).HasValue(AcceptedValues[j]) then
        begin
          Result := TRUE;
          exit;
        end;
    end;
end;

function TWPCSSParserStyle.ElementCount: Integer;
begin
  if FElemements = nil then Result := 0 else
    Result := FElemements.Count;
end;

function TWPCSSParserStyle.GetElements(index: Integer): TWPCSSParserStyleElement;
begin
  Result := TWPCSSParserStyleElement(FElemements[index]);
end;

// --------------------------------------------------------------------------
// TWPCSSParserStyleElement
// --------------------------------------------------------------------------

constructor TWPCSSParserStyleElement.Create(aTyp: TWPCSSParserItemType);
begin
  inherited Create;
  FAtoms := TList.Create;
  Typ := aTyp;
end;

destructor TWPCSSParserStyleElement.Destroy;
begin
  Clear;
  FAtoms.Free;
  inherited Destroy;
end;

procedure TWPCSSParserStyleElement.Clear;
var i: Integer;
begin
  for i := 0 to FAtoms.Count - 1 do
    TWPCSSParserAtom(FAtoms[i]).Free;
  FDeleted := FALSE;
  FCommentText := '';
end;

function TWPCSSParserStyleElement.AtomCount: Integer;
begin
  Result := FAtoms.Count;
end;

function TWPCSSParserStyleElement.GetAtoms(index: Integer): TWPCSSParserAtom;
begin
  Result := TWPCSSParserAtom(FAtoms[index]);
end;

function TWPCSSParserStyleElement.GetStringValue(const defaultvalue: string): string;
begin
  if (FAtoms.Count > 0)
    and (TWPCSSParserAtom(FAtoms[0]).typ in [wp_nameValue, wp_strValue])
    then Result := TWPCSSParserAtom(FAtoms[0]).sValue
 { else if (TWPCSSParserAtom(FAtoms[0]).typ in [wp_IValue]) then
     Result := IntToStr(Trunc(TWPCSSParserAtom(FAtoms[0]).fValue)) }
  else Result := defaultvalue;
end;

function TWPCSSParserStyleElement.GetTwipValue(atomnr: Integer; const defaultvalue: Integer; preferred_typ : TWPCSSParserAtomType = wp_EmptyValue): Integer;
begin
  if (FAtoms.Count > atomnr) and
    (TWPCSSParserAtom(FAtoms[atomnr]).typ in [wp_ptValue, wp_pxValue, wp_inValue,
    wp_mmValue, wp_cmValue,
      wp_IValue, wp_FValue]) then
    Result := TWPCSSParserAtom(FAtoms[0]).GetAsTwipsEx(preferred_typ)
  else Result := defaultvalue;
end;

function TWPCSSParserStyleElement.GetColorValue(const defaultvalue: TColor): TColor;
begin
  if FAtoms.Count = 0 then Result := defaultvalue else
  begin
    Result := TWPCSSParserAtom(FAtoms[0]).GetAsColor;
    if Result = clNone then Result := defaultvalue;
  end;
end;

function TWPCSSParserStyleElement.IsEqualTo(const value: string): Boolean;
begin
  if (FAtoms.Count > 0) and
    (TWPCSSParserAtom(FAtoms[0]).typ in [wp_nameValue, wp_strValue]) then
    Result := CompareText(TWPCSSParserAtom(FAtoms[0]).sValue, value) = 0
  else Result := FALSE;
end;

function TWPCSSParserStyleElement.HasValue(const value: string): Boolean;
var i: Integer;
begin
  Result := FALSE;
  for i := 0 to FAtoms.Count - 1 do
    if (TWPCSSParserAtom(FAtoms[i]).typ in [wp_nameValue, wp_strValue]) and
      (CompareText(TWPCSSParserAtom(FAtoms[0]).sValue, value) = 0) then
    begin
      Result := TRUE;
      exit;
    end;
end;

function TWPCSSParserStyleElement.GetAsString: string;
var i: Integer;
begin
  if typ in [wpCommentA, wpCommentB] then
  begin
    Result := '/* ' + FCommentText + ' */';
  end else
  begin
    if Name <> '' then
      Result := Name + ':'
    else Result := '';
    for i := 0 to FAtoms.Count - 1 do
      Result := Result + TWPCSSParserAtom(FAtoms[i]).AsString + #32;
  end;
end;

function TWPCSSParserStyleElement.GetAsCommaString: string;
var i: Integer;
begin
  if typ in [wpCommentA, wpCommentB] then
  begin
    Result := '/* ' + FCommentText + ' */';
  end else
  begin
    if Name <> '' then
      Result := Name + ':'
    else Result := '';
    for i := 0 to FAtoms.Count - 1 do
    begin
      if i > 0 then Result := Result + ',';
      Result := Result + TWPCSSParserAtom(FAtoms[i]).AsString;
    end;
  end;
end;

    // Creates  an atom list. Do not expect comments here!

procedure TWPCSSParserStyleElement.SetAsString(x: string);
var i, j: Integer;
  Atom: TWPCSSParserAtom;
  aValue: string;
begin
  Clear;
  if typ in [wpCommentA, wpCommentB] then
  begin
    FCommentText := x;
  end
  else
    if x <> '' then
    begin
      i := Pos(':', x);
      if i > 0 then
      begin
        Name := Copy(x, 1, i - 1);
        inc(i);
        while (i < Length(x)) and (x[i] = ':') and (x[i] <= #32) do inc(i);
        aValue := Copy(x, i, Length(x));
        // Create atom after atom. This is only enabled for certain elements such
        // as margin, font ...
        if (Pos(',', aValue) = 0) and (Pos(#32, aValue) = 0) then //V4.11f
        begin
          // Start with just one
          Atom := TWPCSSParserAtom.Create;
          Atom.AsString := aValue;
          FAtoms.Add(Atom);
        end else
        begin
          i := 1;
          while i <= Length(aValue) do
          begin
            j := i;
            if aValue[j] = '"' then
            begin
              inc(j);
              while (j <= Length(aValue)) and (aValue[j] <> '"') do inc(j);
              inc(j);
            end else
              if aValue[j] = #39 then
              begin
                inc(j);
                while (j <= Length(aValue)) and (aValue[j] <> #39) do inc(j);
                inc(j);
              end else
              begin
                while (j <= Length(aValue)) and (aValue[j] > #32) and (aValue[j] <> ',') do inc(j);
              end;

            if (i < Length(aValue) - 3) and (Pos('(', aValue) > 0) and (Pos(')', aValue) > 0) then
            begin
              Atom := TWPCSSParserAtom.Create;
              Atom.AsString := Copy(aValue, i, Length(aValue));
              FAtoms.Add(Atom);
              i := Length(aValue);
            end else
            begin

              if j - i > 0 then
              begin
                Atom := TWPCSSParserAtom.Create;
                Atom.AsString := Trim(Copy(aValue, i, j - i));
                FAtoms.Add(Atom);
              end;
              while (j < Length(aValue)) and ((aValue[j] <= #32) or (aValue[j] = ',')) do inc(j);
              i := j;
            end;

            if i >= Length(aValue) then break;
          end;
        end;
      end;
    end;
end;

procedure TWPCSSParserStyleElement.SetName(x: string);
var i: TWPCSSName; j: Integer;
begin
  FCSSType := wpcss_custom_defined;
  for i := wpcss_direction to High(TWPCSSName) do
    if CompareText(WPCSSNames[i], x) = 0 then
    begin
      FCSSType := i;
      break;
    end;
  // also support: "background.color:yellow"
  if (FCSSType = wpcss_custom_defined) then
  begin
    j := Pos('.', x);
    if j > 0 then
    begin
      x[j] := '-';
      for i := wpcss_direction to High(TWPCSSName) do
        if CompareText(WPCSSNames[i], x) = 0 then
        begin
          FCSSType := i;
          break;
        end;
    end;
  end;
end;

// --------------------------------------------------------------------------
// TWPCSSParserAtom
// --------------------------------------------------------------------------

 //   TWPCSSParserAtomType = (wp_EmptyValue, wp_ptValue, wp_pxValue, wp_inValue, wp_strValue, wp_urlValue);

constructor TWPCSSParserAtom.Create;
begin
  inherited Create;
end;

destructor TWPCSSParserAtom.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TWPCSSParserAtom.iValue: Integer;
begin
  if Typ in [wp_ptValue, wp_pxValue, wp_inValue, wp_FValue, wp_IValue] then
    Result := Round(fValue)
  else raise Exception.Create('Wrong value type ' + IntToStr(Integer(Typ)));
end;

// For WPValues - uses twips, color or just text

function TWPCSSParserAtom.GetStringValue: string;
begin
  case Typ of
    wp_ptValue: Result := IntToStr(GetAsTwips);
    wp_pxValue: Result := IntToStr(GetAsTwips);
    wp_inValue: Result := IntToStr(GetAsTwips);
    wp_mmValue: Result := IntToStr(GetAsTwips);
    wp_cmValue: Result := IntToStr(GetAsTwips);
    wp_PHValue: Result := FloatToStr(fValue) + '%';
    wp_FValue: Result := FloatToStr(fValue);
    wp_IValue: Result := IntToStr(Trunc(fValue));
    wp_nameValue: Result := sValue;
    wp_strValue: Result := sValue;
    wp_urlValue: Result := 'url(' + sValue + ')';
  else Result := '';
  end;
end;

function TWPCSSParserAtom.GetAsString: String;
begin
  case Typ of
    wp_ptValue: Result := FloatToStr(fValue) + 'pt';
    wp_pxValue: Result := FloatToStr(fValue) + 'px';
    wp_inValue: Result := FloatToStr(fValue) + 'in';
    wp_mmValue: Result := FloatToStr(fValue) + 'mm';
    wp_cmValue: Result := FloatToStr(fValue) + 'cm';
    wp_PHValue: Result := IntToStr(Round(fValue)) + '%';
    wp_FValue: Result := FloatToStr(fValue);
    wp_IValue: Result := IntToStr(Trunc(fValue));
    wp_nameValue: Result := sValue;
    wp_strValue: Result := AnsiQuotedStr(sValue, '"');
    wp_urlValue: Result := 'url(' + sValue + ')';
  else Result := '';
  end;
end;

function TWPCSSParserAtom.GetAsTwips : Integer;
begin
  Result := GetAsTwipsEx;
end;

function TWPCSSParserAtom.GetAsTwipsEx( preferred_typ : TWPCSSParserAtomType = wp_EmptyValue ) : Integer;
begin
  case Typ of
    wp_ptValue: Result := Round(fValue * 20);
    wp_pxValue:
    begin
      
         Result := Round(fValue * 1440 / CSSPixelsPerInch);
      
    end;
    wp_inValue: Result := Round(fValue * 1440);
    wp_mmValue: Result := Round(fValue * 1440 / 25.4);
    wp_cmValue: Result := Round(fValue * 1440 / 2.54);
    wp_PHValue: Result := 0; //  ???
    wp_FValue:
    begin
         
         Result := Round(fValue * 1440);
    end;
    wp_IValue:
    begin
       
       Result := Round(iValue * 1440);
    end;
    wp_nameValue: Result := 0;
    wp_strValue: Result := 0;
    wp_urlValue: Result := 0;
  else Result := 0;
  end;
end;

function TWPCSSParserAtom.IsColor: Boolean;
begin
  Result := false; //TODO

end;

type
  TWPXMLStyleColors = record
    name: string;
    value: TColor;
  end;

const
  WPXMLStyleColors: array[0..15] of TWPXMLStyleColors =
  ((name: 'aqua'; value: clAqua),
    (name: 'navy'; value: clNavy),
    (name: 'black'; value: clBlack),
    (name: 'blue'; value: clBlue),
    (name: 'olive'; value: clOlive),
    (name: 'purple'; value: clPurple),
    (name: 'fuchsia'; value: clFuchsia),
    (name: 'red'; value: clRed),
    (name: 'gray'; value: clGray),
    (name: 'silver'; value: clSilver),
    (name: 'green'; value: clGreen),
    (name: 'teal'; value: clTeal),
    (name: 'lime'; value: clLime),
    (name: 'white'; value: clWhite),
    (name: 'maroon'; value: clMaroon),
    (name: 'yellow'; value: clYellow));

function WPBufferToHex(s: string; index: Integer): Byte;
var c: Char;
begin
  Result := 0;
  if index < Length(s) then
  begin
    c := s[index];
    inc(index);
    if c in ['0'..'9'] then
      Result := Integer(c) - Integer('0')
    else if c in ['a'..'f'] then
      Result := Integer(c) - Integer('a') + 10
    else if c in ['A'..'F'] then
      Result := Integer(c) - Integer('A') + 10
    else exit;
    c := s[index];
    if c in ['0'..'9'] then
      Result := (Result * 16) + Integer(c) - Integer('0')
    else if c in ['a'..'f'] then
      Result := (Result * 16) + Integer(c) - Integer('a') + 10
    else if c in ['A'..'F'] then
      Result := (Result * 16) + Integer(c) - Integer('A') + 10;
  end;
end;

function TWPCSSParserAtom.GetAsColor: TColor;
var
  i: Integer;
  peRed, peGreen, peBlue: Byte;
  s: string;
begin
  Result := clNone;
  if Typ = wp_FValue then
    Result := Round(fValue)
  else if Typ = wp_IValue then
    Result := iValue
  else
    if Typ in [wp_nameValue, wp_strValue] then
    begin
      s := sValue;
    // Accept the 'clXXXX syntax, too
      if (Length(s) > 2) and (s[1] = 'c') and (s[2] = 'l') then
      begin
        Result := StringToColor(s);
        exit;
      end;

      s := Trim(s);
      s := TrimRight(s);

      for i := 0 to 15 do
        if CompareText(WPXMLStyleColors[i].Name, S) = 0 then
        begin
          Result := WPXMLStyleColors[i].Value;
          exit;
        end;

      if (s[1] = '#') and (Length(s) = 7) then // #RRGGBB
      begin
        peRed := Byte(WPBufferToHex(s, 2));
        peGreen := Byte(WPBufferToHex(s, 4));
        peBlue := Byte(WPBufferToHex(s, 6));
        Result := TColor(RGB(peRed, peGreen, peBlue));
      end
      else if ((s[1] = '#') or (s[1] = '$')
{$IFNDEF VER100} or (s[1] = HexDisplayPrefix){$ENDIF})
        and (Length(s) = 9) then // Delphi: #00BBGGRR   $00BBGGRR
      begin
        peBlue := Byte(WPBufferToHex(s, 4));
        peGreen := Byte(WPBufferToHex(s, 6));
        peRed := Byte(WPBufferToHex(s, 8));
        Result := TColor(RGB(peRed, peGreen, peBlue));
      end
      else
        Result := clNone;
    end;
end;

{$WARNINGS OFF}

function AnsiDequotedStr(const S: string; AQuote: Char): string;
var
  LText: PChar;
begin
  LText := PChar(S);
  Result := AnsiExtractQuotedStr(LText, AQuote);
  if Result = '' then
    Result := S;
end;
{$WARNINGS ON}

    // This is just one name, number, url etc which is used for
    // a certain  style element

procedure TWPCSSParserAtom.SetAsString(x: String);
var i: Integer;
  fN: Double;
  fDD: Double;
  fNeg: Boolean;
  fDez: Boolean;
  c: CHar;
  a: Integer;
begin
  typ := wp_EmptyValue;
  if x <> '' then
  begin
    i := 1;
    while (x[i] <= #32) and (i < Length(x)) do inc(i);
        // Detect Type - STRING ""
    if x[i] = '"' then
    begin
      typ := wp_strValue;
      sValue := AnsiDequotedStr(x, '"');
    end
        // Detect Type - STRING ''
    else if x[i] = #39 then
    begin
      typ := wp_strValue;
      sValue := AnsiDequotedStr(x, #39);
    end
        // Detect Type - url()
    else if Pos('url(', lowercase(x)) = i then
    begin
      typ := wp_urlValue;
      
    end
      // Detect Type RGB
    else if Pos('rgb(', lowercase(x)) = i then
    begin
      inc(i, 4);
      a := 0;
      while (i < length(x)) and (x[i] in ['0'..'9']) do
      begin
        a := a * 10 + Integer(Integer(x[i]) - Integer('0'));
        inc(i);
      end;
      sValue := '#' + IntToHex(a, 2);
      while (i < length(x)) and ((x[i] = ',') or (x[i] <= #32)) do inc(i);
      a := 0;
      while (i < length(x)) and (x[i] in ['0'..'9']) do
      begin
        a := a * 10 + Integer(Integer(x[i]) - Integer('0'));
        inc(i);
      end;
      sValue := sValue + IntToHex(a, 2);
      while (i < length(x)) and ((x[i] = ',') or (x[i] <= #32)) do inc(i);
      a := 0;
      while (i < length(x)) and (x[i] in ['0'..'9']) do
      begin
        a := a * 10 + Integer(Integer(x[i]) - Integer('0'));
        inc(i);
      end;
      typ := wp_nameValue;
      sValue := sValue + IntToHex(a, 2);

    end
        // Detect Type NAME
    else if (x[i] in ['A'..'Z']) or (x[i] in ['a'..'z']) or (x[i] = '#') then
    begin
      typ := wp_nameValue;
      sValue := x;
    end
    else
    begin
        // Read Number
      fN := 0;
      fNeg := FALSE;
      fDez := FALSE;
      fDD := 10;
      
      while i < Length(x) do
      
      begin
        c := x[i];
        if c = '-' then fNeg := not fNeg
        else if c = '.' then fDez := true
        else if c = ',' then fDez := true
        else if c in ['0'..'9'] then
        begin
          if fDez then
          begin
            fN := fN + (Integer(c) - Integer('0')) / fDD;
            fDD := fDD * 10;
          end else
          begin
            fN := fN * 10 + (Integer(c) - Integer('0'));
          end;
        end
        else break;
        inc(i);
      end;
      // Number
      if fNeg then fValue := -fN
      else fValue := fN;
      // Unit - 1 char
      if (i <= Length(x)) and (x[i] = '%') then
        typ := wp_PHValue
      // Unit - 2 chars
      else if i < Length(x) then
      begin
        if (x[i] = 'i') and (x[i + 1] = 'n') then
          typ := wp_inValue
        else if (x[i] = 'p') and (x[i + 1] = 't') then
          typ := wp_ptValue
        else if (x[i] = 'p') and (x[i + 1] = 'x') then
          typ := wp_pxValue
        else if (x[i] = 'm') and (x[i + 1] = 'm') then
          typ := wp_mmValue
        else if (x[i] = 'c') and (x[i + 1] = 'm') then
          typ := wp_cmValue;
      end else
        if fDez then // No Unit - Float
          typ := wp_FValue // No Unit - Int
        else typ := wp_IValue;

    end;
  end;
end;

procedure TWPCSSParserAtom.Clear;
begin
  sValue := '';
  Typ := wp_EmptyValue;
  FDeleted := FALSE;
end;

procedure TWPCSSParserStyleWP.BeforeGet;
begin
end;

procedure TWPCSSParserStyleWP.AfterSet;
begin
end;

procedure TWPCSSParserStyleWP.ApplyToStyle(TextStyle: TWPTextStyle);
begin
  ApplyToPar(TextStyle.RTFProps, TextStyle);
end;

procedure TWPCSSParserStyleWP.ApplyToPar(RTFProps: TWPRTFProps; par: TWPTextStyle; NumLevel: Integer = 0);
const DEFVALUE = -1000000;
var i: Integer;
  ls: TWPNumberStyle;
  element: TWPCSSParserStyleElement;
  CSS: TWPCSSName;
  UseBorder: Integer;
  procedure SetBorderStyle(TypeID, Flags: Integer);
  var BrdType: Integer;
  begin
    BrdType := -1;
    if element.HasValue('none') or element.HasValue('hidden') then
      BrdType := WPBRD_NONE
    else if element.HasValue('dotted') then
      BrdType := WPBRD_DOTTED
    else if element.HasValue('dashed') then
      BrdType := WPBRD_DASHED
    else if element.HasValue('double') then
      BrdType := WPBRD_DOUBLE
    else if element.HasValue('grooved') then
      BrdType := WPBRD_INSET
    else if element.HasValue('ridge') then
      BrdType := WPBRD_OUTSET
    else if element.HasValue('inset') then
      BrdType := WPBRD_INSET
    else if element.HasValue('outset') then
      BrdType := WPBRD_OUTSET
    else if not element.HasValue('inherit') then
      BrdType := WPBRD_SINGLE;
    if BrdType >= 0 then
      par.ASet(TypeID, BrdType);
    UseBorder := UseBorder or Flags;
  end;
  function SetColor(StyleID: Integer): Boolean;
  var col: TColor;
  begin
    col := element.GetColorValue(clNone);
    if col <> clNone then
    begin
      par.ASetColor(StyleID, col);
      Result := TRUE;
    end else Result := FALSE;
  end;
  procedure SetWidth(StyleID, Flags: Integer);
  var w, j: Integer;
  begin
    for j := 0 to element.AtomCount - 1 do
    begin
      if element.Atoms[j].Typ in [wp_ptValue, wp_pxValue, wp_inValue, wp_mmValue, wp_cmValue] then
      begin
        w := element.Atoms[j].GetAsTwips;
        if w < 1440 div 4 then // not wider than 1/4 inch !
        begin
          par.ASet(StyleID, w);
          UseBorder := UseBorder or Flags;
          break;
        end;
      end;
    end;
  end;
  procedure SetBorder(TypeID, ColorID, WidthID, Flags: Integer);
  begin
    SetBorderStyle(TypeID, Flags);
    SetColor(ColorID);
    SetWidth(WidthID, Flags);
  end;
  procedure SetTwipsParStyle(StyleID: Integer);
  var value: Integer;
  begin
    value := element.GetTwipValue(0, DEFVALUE);
    if value <> DEFVALUE then
      par.ASet(StyleID, value);
  end;
  procedure SetTabStops(kind: TTabKind);
  var j: Integer;
  begin
    for j := 0 to element.AtomCount - 1 do
    begin
      par.TabstopAdd(element.Atoms[j].AsTwips, kind);
    end;
  end;
var value, j, a: Integer; fn: string;
begin
  UseBorder := 0;

  for i := 0 to ElementCount - 1 do
  begin
    element := Elements[i];
    CSS := element.CSS;
    case CSS of
      wpcss_direction: begin end;
      wpcss_font:
        begin
          for j := 0 to element.AtomCount - 1 do
            case element.Atoms[j].Typ of
              wp_ptValue, wp_pxValue, wp_inValue, wp_mmValue, wp_cmValue:
                begin
                  a := MulDiv(element.Atoms[j].GetAsTwipsEx(wp_ptValue), 100, 20);
                  par.ASet(WPAT_CharFontSize, a);
                end;
              wp_strValue:
                begin
                  par.ASet(WPAT_CharFont, RTFProps.AddFontName(element.Atoms[j].sValue));
                end;
              // Color ??
            end;
        end;
      wpcss_font_family:
        begin
          fn := AnsiDequotedStr(element.GetAsCommaString, '"');
          if (fn <> '') and (fn[1] = '@') then System.delete(fn, 1, 1);
          if CompareText(fn, 'ms sans serif') = 0 then fn := 'Arial';
          par.ASet(WPAT_CharFont, RTFProps.AddFontName(fn));
        end;
      wpcss_font_size: 
        begin
          a := MulDiv(element.GetTwipValue(0, 11 * 20, wp_ptValue), 100, 20);
          par.ASet(WPAT_CharFontSize, a);
        end;
      wpcss_font_style:
        begin
          if element.IsEqualTo('normal') then
          begin
            par.ASetDelCharStyle(WPSTY_ITALIC);
          end
          else
          begin
            if element.IsEqualTo('italic') or element.IsEqualTo('oblique') then
            begin
              par.ASetAddCharStyle(WPSTY_ITALIC);
            end
          end;
        end;
      wpcss_font_variant:
        begin
          if element.IsEqualTo('normal') then
          begin
            par.ASetDelCharStyle(WPSTY_SMALLCAPS);
          end
          else
            if element.IsEqualTo('small-caps') then
            begin
              par.ASetAddCharStyle(WPSTY_SMALLCAPS);
            end;
        end;
      wpcss_font_weight:
        begin
          if element.IsEqualTo('normal') then
          begin
            par.ASetDelCharStyle(WPSTY_BOLD);
          end
          else
            if element.IsEqualTo('bold') or element.IsEqualTo('bolder') then
            begin
              par.ASetAddCharStyle(WPSTY_BOLD);
            end
        end;
      wpcss_ime_mode: begin end;
      wpcss_layout_grid: begin end;
      wpcss_layout_grid_char: begin end;
      wpcss_layout_grid_line: begin end;
      wpcss_layout_grid_mode: begin end;
      wpcss_layout_grid_type: begin end;
      wpcss_letter_spacing: begin end;
      wpcss_line_break: begin end;
      wpcss_line_height:
        if element.AtomCount > 0 then
        begin
          if element.Atoms[0].Typ = wp_PHValue then
          begin
            par.ASet(WPAT_LineHeight, Round(element.Atoms[0].fValue));
            par.ADel(WPAT_SpaceBetween);
          end else
          begin
            par.ASet(WPAT_SpaceBetween, Integer(element.Atoms[0].GetAsTwips));
            par.ADel(WPAT_LineHeight);
          end;
        end;
      wpcss_min_height: begin end;
      wpcss_ruby_align: begin end;
      wpcss_ruby_overhang: begin end;
      wpcss_ruby_position: begin end;
      wpcss_text_align:
        begin
          if element.IsEqualTo('left') then
            par.ASet(WPAT_Alignment, Integer(paralLeft))
          else if element.IsEqualTo('right') then
            par.ASet(WPAT_Alignment, Integer(paralRight))
          else if element.IsEqualTo('center') then
            par.ASet(WPAT_Alignment, Integer(paralCenter))
          else if element.IsEqualTo('justify') then
            par.ASet(WPAT_Alignment, Integer(paralBlock));
        end;
 
      wpcss_text_indent: SetTwipsParStyle(WPAT_IndentFirst);
      wpcss_unicode_bidi: begin end;
      wpcss_vertical_align:
 
        begin
          if element.IsEqualTo('top') then
            par.ASet(WPAT_VertAlignment, Integer(paralVertTop))
          else if element.IsEqualTo('middle') then
            par.ASet(WPAT_VertAlignment, Integer(paralVertCenter))
          else if element.IsEqualTo('bottom') then
            par.ASet(WPAT_VertAlignment, Integer(paralVertBottom));
        end;
      wpcss_white_space: begin end;
      wpcss_word_break: begin end;
      wpcss_word_spacing: begin end;
      wpcss_word_wrap: begin end;
      wpcss_writing_mode: begin end;
      
      wpcss_background_attachment: begin end;
      wpcss_background_image: begin end;
      wpcss_background_position: begin end;
      wpcss_background_position_x: begin end;
      wpcss_background_position_y: begin end;
      wpcss_background_repeat: begin end;
      
      wpcss_border_right_style: SetBorderStyle(WPAT_BorderTypeR, WPBRD_DRAW_Right);
      wpcss_border_right: SetBorder(WPAT_BorderTypeR, WPAT_BorderColorR, WPAT_BorderWidthR, WPBRD_DRAW_Right);
      wpcss_border_left_style: SetBorderStyle(WPAT_BorderTypeL, WPBRD_DRAW_Left);
      wpcss_border_left: SetBorder(WPAT_BorderTypeL, WPAT_BorderColorL, WPAT_BorderWidthL, WPBRD_DRAW_Left);
      wpcss_border_top_style: SetBorderStyle(WPAT_BorderTypeT, WPBRD_DRAW_Top);
      wpcss_border_top: SetBorder(WPAT_BorderTypeT, WPAT_BorderColorT, WPAT_BorderWidthT, WPBRD_DRAW_Top);
      wpcss_border_bottom_style: SetBorderStyle(WPAT_BorderTypeB, WPBRD_DRAW_Bottom);
      wpcss_border_bottom: SetBorder(WPAT_BorderTypeB, WPAT_BorderColorB, WPAT_BorderWidthB, WPBRD_DRAW_Bottom);
      wpcss_color:
        begin
          par.ASetColor(WPAT_CharColor, element.GetColorValue(clNone));
        end;
      wpcss_background_color:
        if not IsCharStyle then
        begin
          if SetColor(WPAT_BGColor) then
            par.ASet(WPAT_ShadingValue, 100);
        end else
        begin
          par.ASetColor(WPAT_CharBGColor, element.GetColorValue(clNone));
        end;
      wpcss_border_bottom_color: SetColor(WPAT_BorderColorB);
      wpcss_border_bottom_width: SetWidth(WPAT_BorderWidthB, WPBRD_DRAW_Bottom);
      wpcss_border_collapse: begin end;
      wpcss_border_color: SetColor(WPAT_BorderColor);
      wpcss_border_left_color: SetColor(WPAT_BorderColorL);
      wpcss_border_left_width: SetWidth(WPAT_BorderWidthL, WPBRD_DRAW_Left);
      wpcss_border_right_color: SetColor(WPAT_BorderColorR);
      wpcss_border_right_width: SetWidth(WPAT_BorderWidthR, WPBRD_DRAW_Right);
      wpcss_border_style:
        begin
          SetBorderStyle(WPAT_BorderType,
            WPBRD_DRAW_Left + WPBRD_DRAW_Right + WPBRD_DRAW_Top + WPBRD_DRAW_Bottom);
        end;
      wpcss_border_top_color: SetColor(WPAT_BorderColorT);
      wpcss_border_top_width: SetWidth(WPAT_BorderWidthT, WPBRD_DRAW_Top);
      wpcss_border_width: SetWidth(WPAT_BorderWidth, WPBRD_DRAW_Left + WPBRD_DRAW_Right + WPBRD_DRAW_Top + WPBRD_DRAW_Bottom);
      wpcss_margin: // one, two, three, four values possible
        begin
          if element.AtomCount = 1 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
            if value <> DEFVALUE then
            begin
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
              par.ASet(WPAT_SpaceBefore, value);
              par.ASet(WPAT_SpaceAfter, value);
              par.ASet(WPAT_IndentLeft, value);
              par.ASet(WPAT_IndentRight, value);
            end;
          end
          else if element.AtomCount = 2 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
            if value <> DEFVALUE then
            begin
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
              par.ASet(WPAT_SpaceBefore, value);
              par.ASet(WPAT_SpaceAfter, value);
            end;
            value := element.GetTwipValue(1, DEFVALUE);
            if value <> DEFVALUE then
            begin
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
              par.ASet(WPAT_IndentLeft, value);
              par.ASet(WPAT_IndentRight, value);
            end;
          end
          else if element.AtomCount = 3 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_SpaceBefore, value);
            value := element.GetTwipValue(1, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_IndentLeft, value);
            value := element.GetTwipValue(2, DEFVALUE);
            if value <> DEFVALUE then
            begin
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
              par.ASet(WPAT_IndentRight, value);
              par.ASet(WPAT_SpaceAfter, value);
            end;
          end
          else // if element.AtomCount=4 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_SpaceBefore, value);
            value := element.GetTwipValue(1, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_IndentRight, value);
            value := element.GetTwipValue(2, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_SpaceAfter, value);
            value := element.GetTwipValue(3, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_IndentLeft, value);
          end;
        end;
      wpcss_margin_bottom: SetTwipsParStyle(WPAT_SpaceAfter);
      wpcss_margin_left: SetTwipsParStyle(WPAT_IndentLeft);
      wpcss_margin_right: SetTwipsParStyle(WPAT_IndentRight);
      wpcss_margin_top: SetTwipsParStyle(WPAT_SpaceBefore);
      wpcss_padding:
        begin
          if element.AtomCount = 1 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then
            begin
              par.ASet(WPAT_PaddingTop, value);
              par.ASet(WPAT_PaddingBottom, value);
              par.ASet(WPAT_PaddingLeft, value);
              par.ASet(WPAT_PaddingRight, value);
            end;
          end
          else if element.AtomCount = 2 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then
            begin
              par.ASet(WPAT_PaddingTop, value);
              par.ASet(WPAT_PaddingBottom, value);
            end;
            value := element.GetTwipValue(1, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then
            begin
              par.ASet(WPAT_PaddingLeft, value);
              par.ASet(WPAT_PaddingRight, value);
            end;
          end
          else if element.AtomCount = 3 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingTop, value);
            value := element.GetTwipValue(1, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingLeft, value);
            value := element.GetTwipValue(2, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then
            begin
              par.ASet(WPAT_PaddingRight, value);
              par.ASet(WPAT_PaddingBottom, value);
            end;
          end
          else // if element.AtomCount=4 then
          begin
            value := element.GetTwipValue(0, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingTop, value);
            value := element.GetTwipValue(1, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingRight, value);
            value := element.GetTwipValue(2, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingBottom, value);
            value := element.GetTwipValue(3, DEFVALUE);
{$IFNDEF DONT_RESTRICT_SPACE}if value < -36 then value := -36; {$ENDIF}
            if value <> DEFVALUE then par.ASet(WPAT_PaddingLeft, value);
          end;
        end;
      wpcss_padding_bottom: SetTwipsParStyle(WPAT_PaddingBottom);
      wpcss_padding_left: SetTwipsParStyle(WPAT_PaddingLeft);
      wpcss_padding_right: SetTwipsParStyle(WPAT_PaddingRight);
      wpcss_padding_top: SetTwipsParStyle(WPAT_PaddingTop);
      wpcss_table_layout: begin end;
      wpcss_list_style:
        begin
          for ls := Low(TWPNumberStyle) to High(TWPNumberStyle) do
            if element.HasValue(WPCSSListStyles[ls]) then
            begin
              par.ASet(WPAT_NUMBERMODE, WPNumberStyle_to_Nr[ls]);
            end;
        end;
      wpcss_width:
        begin
          if element.AtomCount > 0 then
          begin
            if element.Atoms[0].Typ = wp_PHValue then
              par.ASet(WPAT_COLWIDTH_PC, Round(element.Atoms[0].fValue * 100))
            else par.ASet(WPAT_COLWIDTH, element.Atoms[0].GetAsTwips);
          end;
        end;
      wpcss_list_style_image: begin end;
      wpcss_list_style_position: begin end;
      wpcss_list_style_type: begin end;
      wpcss_pageBreakAfter:
        begin
          if element.HasValue('always') then
            par.ASetAdd(WPAT_ParFlags, WPPARFL_NewPageAfter);
        end;
      wpcss_pageBreakBefore:
        if par is TParagraph then
        begin
          if element.HasValue('always') then
            TParagraph(par).IsNewPage := TRUE;
        end else
        begin
          if element.HasValue('always') then
            par.ASetAdd(WPAT_ParFlags, WPPARFL_NewPage);
        end;   
      // WPCubed Propritary Enhancements
      wpcss_tabstop: SetTabStops(tkLeft);
      wpcss_tabstop_left: SetTabStops(tkLeft);
      wpcss_tabstop_right: SetTabStops(tkRight);
      wpcss_tabstop_center: SetTabStops(tkCenter);
      wpcss_tabstop_decimal: SetTabStops(tkDecimal);
      wpcss_pageRotate: ;
      wpcss_style_next: if (element.AtomCount = 1) and (element.Atoms[0].sValue <> '') then
          par.ASetStringProp(WPAT_STYLE_NEXT_NAME, element.Atoms[0].sValue);
      wpcss_style_parent: if (element.AtomCount = 1) and (element.Atoms[0].sValue <> '') then
          par.ASetStringProp(WPAT_STYLE_BASE_NAME, element.Atoms[0].sValue);
    end; // CASE
  end;
  if NumLevel > 0 then
    par.ASet(WPAT_NUMBERLEVEL, NumLevel);
  if UseBorder <> 0 then
    par.ASet(WPAT_BorderFlags, UseBorder);
end;

procedure TWPCSSParserStyleWP.ApplyToAttr(RTFProps: TWPRTFProps; var a: TWPCharAttr);
var i, j, aa: Integer;
  element: TWPCSSParserStyleElement;
  CSS: TWPCSSName;
begin
  for i := 0 to ElementCount - 1 do
  begin
    element := Elements[i];
    CSS := element.CSS;
    case CSS of
      wpcss_font:
        begin
          for j := 0 to element.AtomCount - 1 do
            case element.Atoms[j].Typ of
              wp_ptValue, wp_pxValue, wp_inValue, wp_mmValue, wp_cmValue :
                begin
                  a.MaskHash := a.MaskHash or BitMask[Integer(WPAT_CharFontSize)];
                  aa := MulDiv( element.Atoms[j].GetAsTwipsEx(wp_ptValue), 100, 20);
                  a.Values[WPAT_CharFontSize] := aa;
                end;
              wp_strValue:
                begin
                  a.MaskHash := a.MaskHash or BitMask[WPAT_CharFont];
                  a.Values[WPAT_CharFont] := RTFProps.AddFontName(element.Atoms[j].sValue);
                end;
              // Color ??
            end;
        end;
      wpcss_font_family:
        begin
          a.MaskHash := a.MaskHash or BitMask[WPAT_CharFont];
          a.Values[WPAT_CharFont] := RTFProps.AddFontName(AnsiDequotedStr(element.GetAsCommaString, '"'));
        end;
      wpcss_font_size:
        begin
          a.MaskHash := a.MaskHash or BitMask[WPAT_CharFontSize];
          a.Values[WPAT_CharFontSize] := MulDiv( element.GetTwipValue(0, 11, wp_ptValue), 100, 20); 
        end;
      wpcss_font_style:
        begin
          if element.IsEqualTo('normal') then
          begin
           // exclude(a.Style, afsItalic)
            a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
            a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] and not WPSTY_ITALIC;
          end
          else
          begin
            if element.IsEqualTo('italic') or element.IsEqualTo('oblique') then
            begin
              a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
              a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] or WPSTY_ITALIC;
            end
          end;
        end;
      wpcss_font_variant:
        begin
          if element.IsEqualTo('normal') then
          begin
            a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
            a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] and not WPSTY_SMALLCAPS;
          end
          else
            if element.IsEqualTo('small-caps') then
            begin
              a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
              a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] or WPSTY_SMALLCAPS;
            end;
        end;
      wpcss_font_weight:
        begin
          if element.IsEqualTo('normal') then
          begin
            a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
            a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] and not WPSTY_BOLD;
          end
          else
            if element.IsEqualTo('bold') or element.IsEqualTo('bolder') then
            begin
              a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
              a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] or WPSTY_BOLD;
            end
        end;
      wpcss_ruby_align: begin end;
      wpcss_ruby_overhang: begin end;
      wpcss_ruby_position: begin end;
      wpcss_text_autospace: begin end;
      wpcss_text_decoration:
        begin
          if element.IsEqualTo('none') then
          begin
            a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
            a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] and not WPSTY_UNDERLINE;
          end
          else
            if element.IsEqualTo('underline') then
            begin
              a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
              a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] or WPSTY_UNDERLINE;
            end
 
                ;

        // others are nor supported!
        end;
      wpcss_text_kashida_space: begin end;
      wpcss_text_transform:
        begin
          if element.IsEqualTo('none') or element.IsEqualTo('lowercase') then
          begin
            a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
            a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] and not WPSTY_UPPERCASE;
          end
          else
            if element.IsEqualTo('uppercase') or element.IsEqualTo('capitalize') then
            begin
              a.MaskHash := a.MaskHash or BitMask[WPAT_CharStyleON];
              a.Values[WPAT_CharStyleON] := a.Values[WPAT_CharStyleON] or WPSTY_UPPERCASE;
            end;
        // others are nor supported!
        end;
      wpcss_text_underline_position: begin end;
      wpcss_color:
        begin
          a.MaskHash := a.MaskHash or BitMask[WPAT_CharColor];
          a.Values[WPAT_CharColor] := RTFProps.AddColor(element.GetColorValue(clBlack));
        end;
      wpcss_background_color:
        if IsCharStyle then
        begin
          a.MaskHash := a.MaskHash or BitMask[WPAT_CharBGColor];
          a.Values[WPAT_CharBGColor] := RTFProps.AddColor(element.GetColorValue(clWhite));
        end;
 

    end; // Case
  end;
end;

// *****************************************************************************

procedure TWPCSSParserStyleWP.GetWPValues(FValues: TStrings);
var i, j, brdlines: Integer;
  brdcolor, s: string;
  element: TWPCSSParserStyleElement;
  CSS: TWPCSSName;
  strings: TStringList;
  function hasborder: Boolean;
  begin
    Result := element.HasValue('solid')
      or element.HasValue('double')
      or element.HasValue('dashed')
      or element.HasValue('dotted');
  end;
begin
  brdlines := 0;
  brdcolor := '';
  strings := TStringList.Create;
  try
    for i := 0 to ElementCount - 1 do
    begin
      element := Elements[i];
      CSS := element.CSS;
      strings.Clear;
      case CSS of
        wpcss_direction: begin end;
        wpcss_ime_mode: begin end;
        wpcss_layout_grid: begin end;
        wpcss_layout_grid_char: begin end;
        wpcss_layout_grid_line: begin end;
        wpcss_layout_grid_mode: begin end;
        wpcss_layout_grid_type: begin end;
        wpcss_letter_spacing: begin end;
        wpcss_line_break: begin end;
        wpcss_line_height:
          begin
            strings.Add(Format('%s=%d',
              [FWPStyleParElementName[wpseSpaceBetween],
              element.GetTwipValue(0, 0)]));
          end;
        wpcss_min_height: begin end;
        wpcss_ruby_align: begin end;
        wpcss_ruby_overhang: begin end;
        wpcss_ruby_position: begin end;
        wpcss_text_align:
          begin
            s := element.GetStringValue('left');
            if CompareText(s, 'left') = 0 then s := '0' else
              if CompareText(s, 'center') = 0 then s := '1' else
                if CompareText(s, 'right') = 0 then s := '2' else
                  if (CompareText(s, 'justify') = 0) or (CompareText(s, 'justified') = 0) then s := '3' else
                    if (Length(s) <> 1) or (s[1] > '3') then s := '';
            if s <> '' then
              strings.Add(FWPStyleParElementName[wpseAlign] + '=' + s);
          end;
        wpcss_text_indent:
          begin
            strings.Add(Format('%s=%d',
              [FWPStyleParElementName[wpseIndentFirst],
              element.GetTwipValue(0, 0)]));
          end;
        wpcss_unicode_bidi: begin end;
        wpcss_vertical_align:
          begin
            s := element.GetStringValue('top');
            if CompareText(s, 'top') = 0 then s := '0' else
              if CompareText(s, 'middle') = 0 then s := '1' else
                if CompareText(s, 'bottom') = 0 then s := '2' else
                  if (Length(s) <> 1) or (s[1] > '3') then s := '';
            if s <> '' then
              strings.Add(FWPStyleParElementName[wpseVertAlign] + '=' + s);
          end;
        wpcss_white_space: begin end;
        wpcss_word_break: begin end;
        wpcss_word_spacing: begin end;
        wpcss_word_wrap: begin end;
        wpcss_writing_mode: begin end;
        wpcss_background_attachment: begin end;
        wpcss_background_color:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleParElementName[wpseColor],
              element.GetStringValue('white')]));
          end;
        wpcss_background_image: begin end;
        wpcss_background_position: begin end;
        wpcss_background_position_x: begin end;
        wpcss_background_position_y: begin end;
        wpcss_background_repeat: begin end;
      // Borders: 1-left, 2-top, 4-right, 8-bottom
      // We only support ONE color and ONE width !
        wpcss_border_bottom_style, wpcss_border_bottom:
          begin
            if hasborder then brdlines := brdlines or 8;
          end;
        wpcss_border_color, wpcss_border_bottom_color, wpcss_border_left_color,
          wpcss_border_right_color, wpcss_border_top_color:
          begin
            brdcolor := element.GetStringValue('black');
          end;
        wpcss_border_width, wpcss_border_bottom_width, wpcss_border_left_width,
          wpcss_border_right_width, wpcss_border_top_width:
          begin
            strings.Add(Format('%s=%d',
              [FWPStyleParElementName[wpseBrdWidth], //V4.11f
              MulDiv(element.Atoms[0].AsTwips, CSSPixelsPerInch, 1440)]));
          end;
        wpcss_border_left_style, wpcss_border_left:
          begin
            if hasborder then brdlines := brdlines or 1;
          end;
        wpcss_border_right, wpcss_border_right_style:
          begin
            if hasborder then brdlines := brdlines or 4;
          end;
        wpcss_border, wpcss_border_style:
          begin
            if hasborder then brdlines := brdlines or (1 + 2 + 4 + 8);
          end;
        wpcss_border_top, wpcss_border_top_style:
          begin
            if hasborder then brdlines := brdlines or 2;
          end;
        wpcss_margin: // one, two, three, four values possible
          begin
            if element.AtomCount = 1 then
            begin
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceBefore],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceAfter],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentLeft],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentRight],
                element.Atoms[0].StringValue]));
            end
            else if element.AtomCount = 2 then
            begin
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceBefore],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceAfter],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentLeft],
                element.Atoms[1].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentRight],
                element.Atoms[1].StringValue]));
            end
            else if element.AtomCount = 3 then
            begin
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceBefore],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentLeft],
                element.Atoms[1].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentRight],
                element.Atoms[1].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceAfter],
                element.Atoms[2].StringValue]));
            end
            else // if element.AtomCount=4 then
            begin
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceBefore],
                element.Atoms[0].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentRight],
                element.Atoms[1].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseSpaceAfter],
                element.Atoms[2].StringValue]));
              strings.Add(Format('%s=%s',
                [FWPStyleParElementName[wpseIndentLeft],
                element.Atoms[3].StringValue]));

            end;
          end;
        wpcss_margin_bottom:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleParElementName[wpseSpaceAfter],
              IntToStr(element.GetTwipValue(0, 0))]));
          end;
        wpcss_margin_left:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleParElementName[wpseIndentLeft],
              IntToStr(element.GetTwipValue(0, 0))]));
          end;
        wpcss_margin_right:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleParElementName[wpseIndentRight],
              IntToStr(element.GetTwipValue(0, 0))]));
          end;
        wpcss_margin_top:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleParElementName[wpseSpaceBefore],
              IntToStr(element.GetTwipValue(0, 0))]));
          end;
        wpcss_padding: begin end;
        wpcss_padding_bottom: begin end;
        wpcss_padding_left: begin end;
        wpcss_padding_right: begin end;
        wpcss_padding_top: begin end;
        wpcss_table_layout: begin end;
        wpcss_list_style: begin end;
        wpcss_list_style_image: begin end;
        wpcss_list_style_position: begin end;
        wpcss_list_style_type: begin end;
        wpcss_pageBreakAfter: begin end;
        wpcss_pageBreakBefore: begin end;
      // WPCubed Enhancements: begin end; not existent anywhere else
        wpcss_tabstop: begin end; // Left Tab in in: begin end; cm ...
        wpcss_tabstop_left: begin end; // Left Tab in in: begin end; cm ...
        wpcss_tabstop_right: begin end; // Right Tab in in: begin end; cm ...
        wpcss_tabstop_center: begin end; // Center Tab in in: begin end; cm ...
        wpcss_tabstop_decimal: begin end; // Decimal Tab in in: begin end; cm ...

        wpcss_font:
          begin
            for j := 0 to element.AtomCount - 1 do
              case element.Atoms[j].Typ of
                wp_ptValue, wp_pxValue, wp_inValue, wp_mmValue, wp_cmValue:
                  strings.Add(Format('%s=%s',
                    [FWPStyleAttrElementName[wpseFontSize],
                    IntToStr(Round(element.Atoms[j].AsTwips / 20))]));
                wp_strValue:
                  strings.Add(Format('%s=%s',
                    [FWPStyleAttrElementName[wpseFontFont],
                    element.Atoms[j].StringValue]));
                wp_nameValue:
                  begin
              //TODO style and color ?
                  end;
              end;
          end;
        wpcss_font_family:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleAttrElementName[wpseFontFont],
              element.GetStringValue('')]));
          end;
        wpcss_font_size:
          begin
            strings.Add(Format('%s=%s',
              [FWPStyleAttrElementName[wpseFontSize],
              IntToStr(element.GetTwipValue(0, 200) div 20)])); //V4.11f
          end;
        wpcss_font_style:
          begin
            if element.IsEqualTo('italic') or element.IsEqualTo('oblique') then
              strings.Add(FWPStyleAttrElementName[wpseFontItalic] + '=1');
          end;
        wpcss_font_variant:
          begin
        // if element.IsEqualTo('small-caps') then
        //    strings.Add(Format(FWPStyleAttrElementName[wpseFontSmallCaps] + '=1');
          end;
        wpcss_font_weight:
          begin
            if element.IsEqualTo('bold') or element.IsEqualTo('bolder') then
              strings.Add(FWPStyleAttrElementName[wpseFontBold] + '=1');
          end;
        wpcss_text_autospace: begin end;
        wpcss_text_decoration:
          begin
            if element.IsEqualTo('underline') then
              strings.Add(FWPStyleAttrElementName[wpseFontUnderline] + '=1')
 
        // others are not supported!
          end;
        wpcss_text_kashida_space: begin end;
        wpcss_text_transform:
          begin
        // if element.IsEqualTo('uppercase') then
        //    strings.Add(Format(FWPStyleAttrElementName[wpseFontSmallCaps] + '=1');
        // others are nor supported!
          end;
        wpcss_text_underline_position: begin end;
        wpcss_color:
          begin
            strings.Add(FWPStyleAttrElementName[wpseFontColor] + '=' + element.GetStringValue('black'));
          end;
      end; // CASE
      for j := 0 to strings.count - 1 do
        FValues.Add(strings[j]);
    end;
  finally
    strings.Free;
  end;
  if brdlines <> 0 then
    FValues.Add(FWPStyleParElementName[wpseBrdLines] + '=' + IntToStr(brdlines));
end;

end.

