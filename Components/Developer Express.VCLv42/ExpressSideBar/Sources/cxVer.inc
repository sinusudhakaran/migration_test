{$B-} { Complete Boolean Evaluation }
{$R-} { Range-Checking }
{$T-} { Typed @ operator }
{$X+} { Extended syntax }
{$P+} { Open string params }
{$J+} { Writeable structured consts }
{$H+} { Use long strings by default }
{$Q-} { Overflow checking }

{$DEFINE DXVER500}

{$IFNDEF CLR}
  {$IFNDEF DONTUSEJPEGIMAGE}
    {$DEFINE USEJPEGIMAGE}
  {$ENDIF}
{$ENDIF}

{$DEFINE EXPRESSBARS5}

{$DEFINE VCL}

{$IFNDEF VER80}
 {$IFNDEF VER90}
  {$IFNDEF VER93}
    {$DEFINE DELPHI3} { Borland Delphi 3.0 }
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF VER110} { Borland C++Builder 3.0 }
  {$DEFINE CBUILDER3}
  {$ObjExportAll On}
{$ENDIF}

{$IFDEF VER120} { Borland Delphi 4.0 }
  {$DEFINE DELPHI4}
{$ENDIF}

{$IFDEF VER125} { Borland C++Builder 4.0 }
  {$DEFINE CBUILDER3}
  {$DEFINE DELPHI4}
  {$DEFINE CBUILDER4}
  {$ObjExportAll On}
{$ENDIF}

{$IFDEF VER130} { Borland Delphi 5.0 }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$IFDEF BCB}  { Borland C++Builder 5.0 }
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$ObjExportAll On}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER140} { Borland Delphi 6.0 }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$IFDEF BCB}  { Borland C++Builder 6.0 }
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$ObjExportAll On}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER150} { Borland Delphi 7.0 }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
{$ENDIF}

{$IFNDEF DELPHI6}
  {$DEFINE MSWINDOWS}
{$ENDIF}
{$IFDEF LINUX}
  {$UNDEF MSWINDOWS}
{$ENDIF}

{$IFDEF LINUX}
  {$DEFINE KYLIX1}     { Borland Kylix 1 }
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 14}
      {$DEFINE KYLIX2} { Borland Kylix 2 }
    {$IFEND}
    {$IF CompilerVersion >= 14.50}
      {$DEFINE KYLIX3} { Borland Kylix 3 }
    {$IFEND}
  {$ENDIF}
{$ENDIF}

{$IFDEF CLR} { Borland Delphi.Net }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI8}
{$ENDIF}

{$IFDEF VER170} { Borland Delphi 9.0 }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI8}
  {$DEFINE DELPHI9}
{$ENDIF}

{$IFDEF VER180} { Borland Delphi 10 }
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI8}
  {$DEFINE DELPHI9}
  {$DEFINE DELPHI10}
  {$IFDEF BCB}  { Borland C++Builder 10 }
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER10}
    {$ObjExportAll On}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER185} { Borland Delphi 11 //CodeGear}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI8}
  {$DEFINE DELPHI9}
  {$DEFINE DELPHI10}
  {$DEFINE DELPHI11}
  {$IFDEF BCB}  { Borland C++Builder 11 }
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER10}
    {$DEFINE CBUILDER11}
    {$ObjExportAll On}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER200} { Borland Delphi 12 //CodeGear/Tiburon}
  {$DEFINE DELPHI4}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI8}
  {$DEFINE DELPHI9}
  {$DEFINE DELPHI10}
  {$DEFINE DELPHI11}
  {$DEFINE DELPHI12}
  {$IFDEF BCB}  { Borland C++Builder 12 }
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER6}
    {$DEFINE CBUILDER10}
    {$DEFINE CBUILDER11}
    {$DEFINE CBUILDER12}
    {$ObjExportAll On}
  {$ENDIF}
{$ENDIF}

{$IFNDEF CLR}
  {$IFNDEF BCB}
    {$IFDEF DELPHI6}
      {$DEFINE REGISTERSHELLCTRLS}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF DELPHI7}
    {$WARN UNSAFE_CAST OFF}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
  {$ENDIF}
{$ENDIF}

{$IFDEF REGISTERSHELLCTRLS}
  {$DEFINE REGISTERCXSHELLCTRLS}
{$ENDIF}

{$IFDEF DELPHI6}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF}
