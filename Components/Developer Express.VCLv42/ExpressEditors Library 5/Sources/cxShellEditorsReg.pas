
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxShellEditorsReg;

{$I cxVer.inc}

interface

procedure Register;

implementation

uses
{$IFDEF DELPHI6}
  DesignEditors, DesignIntf,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Windows, Classes, Forms, ShellApi, cxDBShellComboBox, cxEditPropEditors,
  cxEditRepositoryEditor, cxExtEditConsts, cxShellBrowserDialog, cxShellComboBox,
  cxShellCommon, cxShellEditRepositoryItems, cxShellListView, cxShellTreeView;

const
  cxShellBrowserEditorVerb = 'Test Browser...';

type
{$IFDEF DELPHI6}
  { TcxShellEditorSelectionEditor }

  TcxShellEditorSelectionEditor = class(TSelectionEditor)
  public
    procedure RequiresUnits(Proc: TGetStrProc); override;
  end;
{$ENDIF}

  { TcxShellBrowserEditor }

  TcxShellBrowserEditor = class(TcxEditorsLibraryComponentEditorEx)
  protected
    function GetEditItemCaption: string; override;
    procedure ExecuteEditAction; override;
  public
    procedure ExecuteVerb(Index: Integer); override;
  end;

{$IFDEF DELPHI6}
{ TcxShellEditorSelectionEditor }

procedure TcxShellEditorSelectionEditor.RequiresUnits(Proc: TGetStrProc);
begin
  Proc('ComCtrls');
  Proc('ShlObj');
  Proc('cxShellCommon');
end;
{$ENDIF}

{ TcxShellBrowserEditor }

procedure TcxShellBrowserEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 4 then
    ShellExecute(0, 'OPEN', 'http://www.devexpress.com', nil, nil, SW_SHOWMAXIMIZED)
  else
    inherited ExecuteVerb(Index);
end;

function TcxShellBrowserEditor.GetEditItemCaption: string;
begin
  Result := cxShellBrowserEditorVerb;
end;

procedure TcxShellBrowserEditor.ExecuteEditAction;
var
  ADialog: TcxShellBrowserDialog;
begin
ADialog := Component as TcxShellBrowserDialog;
with TcxShellBrowserDialog.Create(Application) do
  try
    if Length(ADialog.Title) > 0 then
      Title := ADialog.Title;
    if Length(ADialog.FolderLabelCaption) > 0 then
      FolderLabelCaption := ADialog.FolderLabelCaption;
    Options.ShowFolders := ADialog.Options.ShowFolders;
    Options.ShowToolTip := ADialog.Options.ShowToolTip;
    Options.TrackShellChanges := ADialog.Options.TrackShellChanges;
    Options.ContextMenus := ADialog.Options.ContextMenus;
    Options.ShowNonFolders := ADialog.Options.ShowNonFolders;
    Options.ShowHidden := ADialog.Options.ShowHidden;
    Root.BrowseFolder := ADialog.Root.BrowseFolder;
    Root.CustomPath := ADialog.Root.CustomPath;
    LookAndFeel.Kind := ADialog.LookAndFeel.Kind;
    LookAndFeel.NativeStyle := ADialog.LookAndFeel.NativeStyle;
    ShowButtons := ADialog.ShowButtons;
    ShowInfoTips := ADialog.ShowInfoTips;
    ShowLines := ADialog.ShowLines;
    ShowRoot := ADialog.ShowRoot;
    Path := ADialog.Path;
    Execute;
  finally
    Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('Express Editors 6', [TcxShellComboBox]);
  RegisterComponents('Express DBEditors 6', [TcxDBShellComboBox]);
  RegisterComponents('Express Utilities', [TcxShellListView, TcxShellTreeView,
    TcxShellBrowserDialog]);
{$IFDEF DELPHI6}
  RegisterSelectionEditor(TcxCustomShellComboBox, TcxShellEditorSelectionEditor);
  RegisterSelectionEditor(TcxCustomShellListView, TcxShellEditorSelectionEditor);
  RegisterSelectionEditor(TcxCustomShellTreeView, TcxShellEditorSelectionEditor);
{$ENDIF}
  RegisterComponentEditor(TcxShellBrowserDialog, TcxShellBrowserEditor);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxDragDropSettings, 'Scroll', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomShellTreeView, 'RightClickSelect', nil);
end;

initialization
  RegisterEditRepositoryItem(TcxEditRepositoryShellComboBoxItem,
    scxSEditRepositoryShellComboBoxItem);

finalization
  UnregisterEditRepositoryItem(TcxEditRepositoryShellComboBoxItem);

end.
