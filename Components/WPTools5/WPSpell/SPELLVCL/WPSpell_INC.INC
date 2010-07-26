// WPSpell_INC.INC Include File for WPSpell


//  Remove period in front of languages you would like supported
//  NOTE: These defines need only be enabled if you would like the spell
//        dialog's buttons and labels to change language.   If you would
//        simply like to add support for spell checking a particular
//        language, you need only include the appropriate DCT file, there
//        is no need to enable the defines below.


{$DEFINE SupportEnglish}
{$DEFINE SupportGerman}
{$DEFINE SupportSpanish}
{$DEFINE SupportBritish}
{$DEFINE SupportItalian}
{$DEFINE SupportFrench}
{$DEFINE SupportDutch}
{$DEFINE SupportPortogese}

{$IFNDEF WPSPELL_DEMODLL}
{--$DEFINE WPSPELL_DEMO} // If this is defined we link in the DLL WPSpellDemo01.DLL
{$ENDIF}

{$DEFINE IGNOREONECHARS}

{$IFDEF VER120}
  {$DEFINE OLDDELPHI} // Delphi 4
{$ENDIF}
{$IFDEF VER130}
  {$DEFINE OLDDELPHI} // Delphi 5
{$ENDIF}
{$IFDEF BCB}
  {$DEFINE OLDDELPHI} // BCB 5
{$ENDIF}

