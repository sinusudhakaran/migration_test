(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{NOTE: OPDEFINE.INC is included in all OfficePartner units,
       so you can specify global compiler options here.
       OPDEFINE.INC is included *before* each unit's own required
       compiler options, so options specified here could be
       overridden by hardcoded options in the unit source file.}

{====Compiler options that can be changed====}
{$A+ Force alignment on word/dword boundaries}
{$S- No stack checking}

{====Global fixed compiler options (do NOT change)====}

{$B- Incomplete boolean evaluation}
{$H+ Long string support}
{$J+ Writeable typed constants}
{$P- No open string parameters}
{$Q- No arithmetic overflow checking}
{$R- No range checking}
{$T- No type-checked pointers}
{$V- No var string checking}
{$X+ Extended syntax}
{$Z1 Enumerations are byte sized}

{====General defines=================================================}


{-------- !! DO NOT CHANGE DEFINES BELOW THIS LINE !! --------}

{ Compiler stoppers for unsupported compilers }

{$IFDEF VER80}
  !!! OfficePartner does not support Delphi 1
{$ENDIF}

{$IFDEF VER90}
  !!! OfficePartner does not support Delphi 2
{$ENDIF}

{$IFDEF VER93}
  !!! OfficePartner does not support C++Builder 1
{$ENDIF}



{$IFDEF VER100}              { Delphi 3 }
  {$DEFINE VERSION3}
{$ENDIF}

{$IFDEF VER110}              { C++ Builder 3 }
  {$ObjExportAll On}
  {$DEFINE CBuilder}
  {$DEFINE VERSION3}
{$ENDIF}

{$IFDEF VER120}              { Delphi 4 }
  {$DEFINE VERSION4}
{$ENDIF}

{$IFDEF VER125}              { C++ Builder 4 }
  {$ObjExportAll On}
  {$DEFINE CBuilder}
  {$DEFINE VERSION4}
{$ENDIF}

{$IFDEF VER130}              { Delphi 5 & C++ Builder 5 }
  {$DEFINE VERSION5}
 {$IFDEF BCB}
  {$ObjExportAll On}
  {$DEFINE CBuilder}
 {$ENDIF}
{$ENDIF}


{$IFDEF VER140}
  {$IFNDEF LINUX}
    {$DEFINE VERSION6}
    {$DEFINE DCC6ORLATER}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER150}
  {$IFNDEF LINUX}
    {$DEFINE VERSION7}
    {$DEFINE DCC6ORLATER}
  {$ENDIF}
{$ENDIF}

{$IFDEF VER180}
  {$IFNDEF LINUX}
    {$DEFINE VERSION7}
    {$DEFINE DCC6ORLATER}
  {$ENDIF}
{$ENDIF}  
