unit UFlxFormats;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
type
  THFlxAlignment=(fha_general, fha_left, fha_center, fha_right, fha_fill,
                  fha_justify, fha_center_across_selection);
  TVFlxAlignment=(fva_top, fva_center, fva_bottom, fva_justify);

  TFlxBorderStyle= (fbs_None, fbs_Thin, fbs_Medium, fbs_Dashed, fbs_Dotted, fbs_Thick,
                    fbs_Double, fbs_Hair, fbs_Medium_dashed, fbs_Dash_dot, fbs_Medium_dash_dot,
                    fbs_Dash_dot_dot, fbs_Medium_dash_dot_dot, fbs_Slanted_dash_dot);

  TFlxPatternStyle=0..19;

  TFlxDiagonalBorder =(fdb_None, fdb_DiagDown, fdb_DiagUp, fdb_Both);

  TFlxFontStyle = (flsBold, flsItalic, flsStrikeOut, flsSuperscript, flsSubscript);

  TFlxUnderline = (fu_None, fu_Single, fu_Double, fu_SingleAccounting, fu_DoubleAccounting);

  SetOfTFlxFontStyle= Set of TFlxFontStyle;

  TFlxFont=record
    Name: widestring;
    Size20: Word;
    ColorIndex: integer;
    Style: SetOfTFlxFontStyle;
    Underline: TFlxUnderline;
    Family: byte;
    CharSet: byte;
  end;

  TFlxOneBorder=record
    Style: TFlxBorderStyle;
    ColorIndex: integer;
  end;

  TFlxBorders=record
    Left,
    Right,
    Top,
    Bottom,
    Diagonal: TFlxOneBorder;

    DiagonalStyle: TFlxDiagonalBorder;
  end;

  TFlxFillPattern=record
    Pattern: TFlxPatternStyle;
    FgColorIndex: integer;
    BgColorIndex: integer;
  end;

  TFlxFormat=record
    Font: TFlxFont;
    Borders: TFlxBorders;
    Format: Widestring;

    FillPattern: TFlxFillPattern;

    HAlignment: THFlxAlignment;
    VAlignment: TVFlxAlignment;

    Locked: boolean;
    Hidden: boolean;
    Parent: integer;

    WrapText: boolean;
    ShrinkToFit: boolean;
    Rotation: byte;
    Indent:   byte;
  end;

  PFlxFormat=^TFlxFormat;

implementation

end.
