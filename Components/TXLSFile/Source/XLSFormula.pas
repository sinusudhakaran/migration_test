unit XLSFormula;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface

uses XLSBase;

type
  TXLSFunctionRec = record
    Name: AnsiString;
    Code: Integer;
    ArgsCount: Integer;
  end;

const
  {formula tokens subtypes}
  FMLA_TOKEN_NUMBER         = 1;
  FMLA_TOKEN_CELL           = 2;
  FMLA_TOKEN_AREA           = 3;
  FMLA_TOKEN_STRING         = 4;
  FMLA_TOKEN_3D_CELL        = 5;
  FMLA_TOKEN_3D_AREA        = 6;
  FMLA_TOKEN_BOOL           = 7;
  FMLA_TOKEN_NAME           = 8;
  FMLA_TOKEN_EXT_NAME       = 9;
  FMLA_TOKEN_EXT_CELL       = 10;
  FMLA_TOKEN_EXT_AREA       = 11;
  FMLA_TOKEN_MISARG         = 12;  

  {string quotes char}
  FMLA_STRING_QUOTE = '"';

  {operators}
  FMLA_OPERATORS_COUNT = 14;
  FmlaOperators: array[0..13] of AnsiString = (
    '(', ')', '+', '-', '*', '/', '<', '<=', '=', '>=', '>', '<>', '&', ':');

  {Excel functions}
  FMLA_FUNCTION_UDF = $FF;

  FMLA_FUNCTIONS_COUNT = 78;
  
  FmlaFunctions: array[0..FMLA_FUNCTIONS_COUNT-1] of TXLSFunctionRec = (
    // logical
    ( Name: 'IF';          Code: 1;     ArgsCount: 3),
    ( Name: 'ISERROR';     Code: 3;     ArgsCount: 1),
    ( Name: 'AND';         Code: $24;   ArgsCount: -1),
    ( Name: 'OR';          Code: $25;   ArgsCount: -1),
    ( Name: 'NOT';         Code: $26;   ArgsCount: 1),

    // statistics
    ( Name: 'COUNT';       Code: 0;     ArgsCount: -1),
    ( Name: 'SUM';         Code: 4;     ArgsCount: -1),
    ( Name: 'AVERAGE';     Code: 5;     ArgsCount: -1),
    ( Name: 'MIN';         Code: 6;     ArgsCount: -1),
    ( Name: 'MAX';         Code: 7;     ArgsCount: -1),
    ( Name: 'ROW';         Code: 8;     ArgsCount: -1),
    ( Name: 'COLUMN';      Code: 9;     ArgsCount: -1),
    ( Name: 'NPV';         Code: 11;    ArgsCount: -1),
    ( Name: 'STDEV';       Code: 12;    ArgsCount: -1),
    ( Name: 'PRODUCT';     Code: 183;   ArgsCount: -1),    
    ( Name: 'SUMPRODUCT';  Code: 228;   ArgsCount: -1),
    ( Name: 'FREQUENCY';   Code: 252;   ArgsCount: 2),
    ( Name: 'SUMSQ';       Code: 321;   ArgsCount: -1),
    ( Name: 'SUMX2MY2';    Code: 304;   ArgsCount: -1),
    ( Name: 'SUMX2PY2';    Code: 305;   ArgsCount: -1),
    ( Name: 'SUMXMY2';     Code: 303;   ArgsCount: -1),
    ( Name: 'SUMIF';       Code: 345;   ArgsCount: -1),

    // math
    ( Name: 'SIN';         Code: 15;    ArgsCount: 1),
    ( Name: 'COS';         Code: 16;    ArgsCount: 1),
    ( Name: 'TAN';         Code: 17;    ArgsCount: 1),
    ( Name: 'ATAN';        Code: 18;    ArgsCount: 1),
    ( Name: 'SQRT';        Code: 20;    ArgsCount: 1),
    ( Name: 'EXP';         Code: 21;    ArgsCount: 1),
    ( Name: 'LN';          Code: 22;    ArgsCount: 1),
    ( Name: 'LOG10';       Code: 23;    ArgsCount: 1),
    ( Name: 'ABS';         Code: 24;    ArgsCount: 1),
    ( Name: 'INT';         Code: 25;    ArgsCount: 1),
    ( Name: 'SIGN';        Code: 26;    ArgsCount: 1),
    ( Name: 'ROUND';       Code: 27;    ArgsCount: 2),

    ( Name: 'LOOKUP';      Code: 28;    ArgsCount: -1),
    ( Name: 'INDEX';       Code: 29;    ArgsCount: -1),

    // string functions
    ( Name: 'REPT';        Code: 30;    ArgsCount: 2),
    ( Name: 'MID';         Code: 31;    ArgsCount: 3),
    ( Name: 'LEN';         Code: 32;    ArgsCount: 1),
    ( Name: 'VALUE';       Code: 33;    ArgsCount: 1),

    ( Name: 'MOD';         Code: 39;    ArgsCount: 2),
    ( Name: 'DSUM';        Code: 41;    ArgsCount: 3),
    ( Name: 'VAR';         Code: 46;    ArgsCount: -1),

    // date
    ( Name: 'DATE';        Code: 65;    ArgsCount: 3),
    ( Name: 'TIME';        Code: 66;    ArgsCount: 3),
    ( Name: 'DAY';         Code: 67;    ArgsCount: 1),
    ( Name: 'MONTH';       Code: 68;    ArgsCount: 1),
    ( Name: 'YEAR';        Code: 69;    ArgsCount: 1),
    ( Name: 'WEEKDAY';     Code: 70;    ArgsCount: 1),
    ( Name: 'HOUR';        Code: 71;    ArgsCount: 1),
    ( Name: 'MINUTE';      Code: 72;    ArgsCount: 1),
    ( Name: 'SECOND';      Code: 73;    ArgsCount: 1),
    ( Name: 'NOW';         Code: 74;    ArgsCount: 0),

    ( Name: 'HLOOKUP';     Code: 101;   ArgsCount: 4),
    ( Name: 'VLOOKUP';     Code: 102;   ArgsCount: 4),

    ( Name: 'LOWER';       Code: 112;   ArgsCount: 1),
    ( Name: 'UPPER';       Code: 113;   ArgsCount: 1),
    ( Name: 'PROPER';      Code: 114;   ArgsCount: 1),
    ( Name: 'LEFT';        Code: 115;   ArgsCount: 2),
    ( Name: 'RIGHT';       Code: 116;   ArgsCount: 2),
    ( Name: 'TRIM';        Code: 118;   ArgsCount: 1),
    ( Name: 'REPLACE';     Code: 119;   ArgsCount: 4),
    ( Name: 'SUBSTITUTE';  Code: 120;   ArgsCount: 4),

    ( Name: 'ISERR';       Code: 126;   ArgsCount: 1),
    ( Name: 'ISTEXT';      Code: 127;   ArgsCount: 1),
    ( Name: 'ISNUMBER';    Code: 128;   ArgsCount: 1),
    ( Name: 'ISBLANK';     Code: 129;   ArgsCount: 1),

    ( Name: 'COUNTA';      Code: 169;   ArgsCount: -1),
    ( Name: 'TRUNC';       Code: 197;   ArgsCount: 1),
    ( Name: 'ROUNDUP';     Code: 212;   ArgsCount: 1),
    ( Name: 'ROUNDDOWN';   Code: 213;   ArgsCount: 1),

    ( Name: 'TODAY';       Code: 221;   ArgsCount: 0),

    ( Name: 'FLOOR';       Code: 285;   ArgsCount: 1),
    ( Name: 'CEILING';     Code: 288;   ArgsCount: 1),

    ( Name: 'CONCATENATE'; Code: 336;   ArgsCount: -1),
    ( Name: 'SUBTOTAL';    Code: 344;   ArgsCount: 2),
    ( Name: 'COUNTBLANK';  Code: 347;   ArgsCount: 1),

    // ÃÂÀ
    ( Name: '<UDF>';  Code: $FF;   ArgsCount: -1)
    );

  {ptgs}
  FMLA_PTG_ADD = 3;
  FMLA_PTG_SUB = 4;
  FMLA_PTG_MUL = 5;
  FMLA_PTG_DIV = 6;

  FMLA_PTG_LT = $09;
  FMLA_PTG_LE = $0A;
  FMLA_PTG_EQ = $0B;
  FMLA_PTG_GE = $0C;
  FMLA_PTG_GT = $0D;
  FMLA_PTG_NE = $0E;
  FMLA_PTG_CONCAT = $08;
  FMLA_PTG_POWER = $07;
  FMLA_PTG_RANGE = $11;
  FMLA_PTG_MISARG = $16;
  
  FMLA_PTG_FUNCF = $41;
  FMLA_PTG_FUNCF_REF = $21;
  FMLA_PTG_FUNCF_ARR = $61;  
  FMLA_PTG_FUNC = $42;
  FMLA_PTG_FUNC_REF = $22;
  FMLA_PTG_FUNC_ARR = $62;  

  FMLA_PTG_REF  = $44; //$24;
  FMLA_PTG_REF_VAL = $44;
  FMLA_PTG_REF_REF = $24;
  FMLA_PTG_REF_ARR = $64;
  FMLA_PTG_N_REF_VAL = $4C;
  FMLA_PTG_N_REF_REF = $2C;
  FMLA_PTG_N_REF_ARR = $6C;

  FMLA_PTG_AREA = $25;
  FMLA_PTG_AREA_VAL = $45;
  FMLA_PTG_AREA_REF = $25;
  FMLA_PTG_AREA_ARR = $65;
  FMLA_PTG_N_AREA_VAL = $4D;
  FMLA_PTG_N_AREA_REF = $2D;
  FMLA_PTG_N_AREA_ARR = $6D;

  FMLA_PTG_3DREF  = $5a;
  FMLA_PTG_3DREF_VAL = $5a;
  FMLA_PTG_3DREF_REF = $3a;
  FMLA_PTG_3DREF_ARR = $7a;

  FMLA_PTG_3DAREA = $3b;
  FMLA_PTG_3DAREA_VAL = $5b;
  FMLA_PTG_3DAREA_REF = $3b;
  FMLA_PTG_3DAREA_ARR = $7b;

  FMLA_PTG_NAME = $23;
  FMLA_PTG_NAME_VAL = $43;
  FMLA_PTG_NAME_ARR = $63;

  FMLA_PTG_NAMEX = $39;
  FMLA_PTG_NAMEX_VAL = $59;
  FMLA_PTG_NAMEX_ARR = $79;

  FMLA_PTG_INT  = $1E;
  FMLA_PTG_NUM  = $1F;
  FMLA_PTG_STR  = $17;
  FMLA_PTG_PAREN = $15;
  FMLA_PTG_BOOL = $1d;

  FMLA_PTG_ATTR = $19;

  FMLA_PTG_MEMFUNC = $29;

{function arguments separator char}
{$IFDEF OLE_XLSFile}
threadvar FMLA_ARG_SEPARATOR: AnsiChar;
{$ELSE}
var FMLA_ARG_SEPARATOR: AnsiChar;
{$ENDIF}

implementation
 
end.
