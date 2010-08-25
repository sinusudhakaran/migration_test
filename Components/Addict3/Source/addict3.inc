(*************************************************************

Addict 3.4.2,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Addict3 INC file... all compiler directives.

**************************************************************)


// Do Not Edit Items Below!!!!!!!!!!!!!!

{$B-}   // Ensure that Complete Boolean Evaluation is off
{$T-}   // Ensure that the result of the @ operator is always an untyped pointer
{$A+}   // Ensure Record Fields are aligned
{$H+}   // Use Long Strings
{$X+}   // Enable Extended Syntax
{$Z1}   // Enumerated Types default to 1 Byte Minimum Storage

{$IFDEF VER120}
  {$DEFINE Delphi4AndAbove}
  {$DEFINE UsingDelphi4}
{$ENDIF}

{$IFDEF VER125}
  {$DEFINE Delphi4AndAbove}
  {$DEFINE UsingDelphi4}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE Delphi4AndAbove}
  {$DEFINE Delphi5AndAbove}
  {$DEFINE UsingDelphi5}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE Delphi4AndAbove}
  {$DEFINE Delphi5AndAbove}
  {$DEFINE Delphi6AndAbove}
  {$DEFINE UsingDelphi6}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE Delphi4AndAbove}
  {$DEFINE Delphi5AndAbove}
  {$DEFINE Delphi6AndAbove}
  {$DEFINE Delphi7AndAbove}
  {$DEFINE UsingDelphi7}
{$ENDIF}

{$IFDEF VER170}
  {$DEFINE UsingDelphi9}
  {$DEFINE Delphi4andAbove}
  {$DEFINE Delphi5andAbove}
  {$DEFINE Delphi6andAbove}
  {$DEFINE Delphi7andAbove}
  {$DEFINE Delphi9andAbove}
{$ENDIF}



