{
   SYMBOLS
}

{$IFNDEF VER70}
   !! This is a TurboVision unit
{$ENDIF}

{$DEFINE TV}
{$DEFINE BANKLINK}
{...$DEFINE SMARTBOOKS}
{...$DEFINE DEBUG}
{$DEFINE heapview }
{$DEFINE FourByteDates }

   {===================================================================

   SWITCH DIRECTIVES

   ===================================================================}
   {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   GLOBAL
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
{$A+}                                    { Align data (286+ machines) }
{$E+}                                      { Emulate 8087 coprocessor }
{$N+}                                   { Generate 8087 specific code }
{$O+}                                              { Overlays allowed }
{$X+}                                               { Extended Syntax }
{$T-}                                  { Type Check Pointer Operation }
{$Q-}

   {- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LOCAL

{$G+}
{$IFDEF SUP_8086}
  {$G-}
{$ENDIF}

{$B-}                                   { Complete boolean evaluation }
{$F+}                                      { FAR calls (for overlays) }
{$V-}                                              { VAR String check }

{$IFDEF DEBUG}
   {$S+,L+,D+,I+,R+,Y+}
{$ELSE}
   {$S-,L-,D-,I-,R-,Y-}
{$ENDIF}

{$M 32767,65536,655360 }    { Stack, HEAP min, HEAP max }


