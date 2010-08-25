{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4

-----------------------------------------------------------------}

{$IFDEF VER100}
  {$DEFINE XLF_D3}        { Delphi 3 }
{$ENDIF}


{$IFNDEF VER80}           { Delphi 1.0 }
 {$IFNDEF VER90}          { Delphi 2.0 }
  {$IFNDEF VER100}        { Delphi 3.0 }
    {$IFNDEF VER120}      { Delphi 4.0 }
      {$IFNDEF VER130}    { Delphi 5.0 }
   
        {$DEFINE XLF_D6}  { Delphi 6.0 or higher }

      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF VER200}
  {$DEFINE XLF_D2009}     { Delphi 2009 }
{$ENDIF}
