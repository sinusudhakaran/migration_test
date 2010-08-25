{******************************************************************************}
{                                                                              }
{                                 GmPs.inc                                     }
{                                                                              }
{          Copyright (c) 2001 Graham Murt  - www.MurtSoft.co.uk                }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

{$IFDEF VER180}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF VER170}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF VER140}
  {$IFDEF BCB}
    {$DEFINE BCB6}
    {$DEFINE BCB}
  {$ELSE}
    {$DEFINE DELPHI6}
    {$DEFINE DELPHI}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER130}
  {$IFDEF BCB}
    {$DEFINE BCB5}
    {$DEFINE BCB}
  {$ELSE}
    {$DEFINE DELPHI5}
    {$DEFINE DELPHI}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER120}
   {$DEFINE DELPHI4}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF VER100}
  {$DEFINE DELPHI3}
  {$DEFINE DELPHI}
{$ENDIF}

{$IFDEF DELPHI7}
  {$DEFINE D7+}
  {$DEFINE D6+}
  {$DEFINE D5+}
  {$DEFINE D4+}
  {$DEFINE D3+}
{$ENDIF}

{$IFDEF DELPHI6}
  {$DEFINE D6+}
  {$DEFINE D5+}
  {$DEFINE D4+}
  {$DEFINE D3+}
{$ENDIF}

{$IFDEF DELPHI5}
  {$DEFINE D5+}
  {$DEFINE D4+}
  {$DEFINE D3+}
{$ENDIF}

{$IFDEF DELPHI4}
  {$DEFINE D4+}
  {$DEFINE D3+}
{$ENDIF}

{$IFDEF DELPHI3}
  {$DEFINE D3+}
{$ENDIF}


{$IFDEF BCB5}
  {$DEFINE BCB5+}
{$ENDIF}
