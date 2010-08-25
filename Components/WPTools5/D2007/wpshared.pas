unit WPShared;
{ -----------------------------------------------------------------------------
  WPXMLInterface - Copyright (C) 2002 by wpcubed GmbH -  all rigths reserved!
  Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  License:
    You may use this components if you are a registered user
    of WPTools Version 4 or WPForm Version 2 or later.
  Distribution of the source code is prohibited - exception: WPLocalize.PAS
  -----------------------------------------------------------------------------
  Summary:
  TWPXMLInterface - Component to load and save an XML file. While loading
  and saving the tags, parameters and texts are created/provided by/to events.
  TWPCustomXMLTree - Component (based on TWPCustomXMLInterface) to load and
  save XML files to a tree representation stored in memory.
  TWPLanguageControl - interface component (one instance per project!) to add
  localization to a project. See unit WPLocalize for more info.
  TWPUndoStack - component to manage an undo/redo stack
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$IFNDEF RUNTIME}
{$DEFINE BUILDDESIGN}
{$ENDIF}

{$IFDEF	VER140}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER150}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER170}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER180}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER190}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFDEF	VER200}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}

{$IFDEF NODsgnIntf}
  {$UNDEF BUILDDESIGN}
{$ENDIF}

uses Classes, WPXMLInt, WPLngCtr, WPUndoMan
{$IFDEF BUILDDESIGN}, WPXMLEditor  
{$IFDEF DELPHI6ANDUP}, DesignIntf, DesignEditors{$ELSE}, DsgnIntf{$ENDIF}
{$ENDIF};

{$IFDEF BUILDDESIGN}
type
  TWPXMLInterfaceDataProperty = class(TPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    procedure SetValue(const Value: string); override;
    function GetValue: string; override;
  end;

  TWPXMLInterfaceDataPropertyEdit = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

{$ENDIF}


procedure Register;

implementation

{$R WPShared.RES}

{$IFDEF BUILDDESIGN}

function TWPXMLInterfaceDataProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TWPXMLInterfaceDataProperty.SetValue(const Value: string);
begin

end;

function TWPXMLInterfaceDataProperty.GetValue: string;
begin
  Result := 'XML Data';
end;


procedure TWPXMLInterfaceDataProperty.Edit;
var
  ed: TPersistent;
  EditDlg: TWPXMLPropertyEditor;
begin
  EditDlg := TWPXMLPropertyEditor.Create(nil);
  try
    ed := GetComponent(0);
    if (ed <> nil) and (ed is TWPCustomXMLInterface) then
    begin
      EditDlg.Source := TWPCustomXMLInterface(ed);
      EditDlg.Caption := 'XML-Data in ' + TWPCustomXMLInterface(ed).Name;
      EditDlg.WPXMLTree1.DontAllowMultTagsOnFirstLevel :=
             TWPCustomXMLTree(ed).DontAllowMultTagsOnFirstLevel;
      EditDlg.WPXMLTree1.XMLData.Assign(TWPCustomXMLInterface(ed).XMLData);
      EditDlg.Close1.Visible := FALSE;
      EditDlg.OK.Visible     := TRUE;
      EditDlg.CANCEL.Visible := TRUE;
      EditDlg.ShowModal;
      Modified;
    end;
  finally
    EditDlg.Free;
  end;
end;


function TWPXMLInterfaceDataPropertyEdit.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TWPXMLInterfaceDataPropertyEdit.ExecuteVerb(Index: Integer);
var
  ed: TPersistent;
  EditDlg: TWPXMLPropertyEditor;
begin
  if Index = 0 then
  begin
    EditDlg := TWPXMLPropertyEditor.Create(nil);
    try
      ed := Component;
      if (ed <> nil) and (ed is TWPCustomXMLInterface) then
      begin
        EditDlg.Source := TWPCustomXMLInterface(ed);
        EditDlg.Caption := 'XML-Data in ' + TWPCustomXMLInterface(ed).Name;
        EditDlg.WPXMLTree1.DontAllowMultTagsOnFirstLevel :=
             TWPCustomXMLTree(ed).DontAllowMultTagsOnFirstLevel;
        EditDlg.WPXMLTree1.XMLData.Assign(TWPCustomXMLInterface(ed).XMLData);
        EditDlg.Close1.Visible := FALSE;
        EditDlg.OK.Visible     := TRUE;
        EditDlg.CANCEL.Visible := TRUE;
        EditDlg.ShowModal;
        Designer.Modified;
      end;
    finally
      EditDlg.Free;
    end;
  end;
end;

function TWPXMLInterfaceDataPropertyEdit.GetVerb(Index: Integer): string;
begin
  if Index = 0 then Result := 'Edit XML Content';
end;
{$ENDIF}


procedure Register;
begin
  RegisterComponents('WP-Shared', [TWPXMLInterface, TWPXMLTree, TWPLanguageControl, TWPUndoStack]);
{$IFDEF BUILDDESIGN}
  RegisterPropertyEditor(TypeInfo(TWPXMLInterfaceData), TWPXMLTree, 'XMLData', TWPXMLInterfaceDataProperty);
  RegisterPropertyEditor(TypeInfo(TWPXMLInterfaceData), TWPLanguageControl, 'XMLData', TWPXMLInterfaceDataProperty);
  RegisterComponentEditor(TWPXMLTree, TWPXMLInterfaceDataPropertyEdit);
  RegisterComponentEditor(TWPLanguageControl, TWPXMLInterfaceDataPropertyEdit);
{$ENDIF}
end;

end.

