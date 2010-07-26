{***************************************************************************}
{ TDBAdvGrid component                                                      }
{ for Delphi & C++Builder                                                   }
{ version 2.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 1996-2005                                          }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}
{$I TMSDEFS.INC}
unit DBAdvGridDE;

interface

uses
  Classes, Controls, DBAdvGrid, DB, AsgDe, HTMLSDe
{$IFDEF DELPHI6_LVL}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  , DesignIntf, DesignEditors, ContNrs
  {$ENDIF}
{$ELSE}
  , DsgnIntf
{$ENDIF}
  ;

type

  TDBSgFieldNameProperty = class(TStringProperty)
  public
    function GetAttributes:TPropertyAttributes; override;
    procedure GetValues(Proc:TGetStrProc); override;
  end;

  TDBAdvGridEditor = class(TAdvStringGridEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  {$ENDIF}
  end;


procedure Register;

implementation

uses
  SysUtils;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string),TDBGridColumnItem,'FieldName',TDBSgFieldNameProperty);
  RegisterComponentEditor(TDBAdvGrid, TDBAdvGridEditor);
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(string), TDBGridColumnItem, 'HTMLTemplate', THTMLStringProperty);
  {$ENDIF}
end;

{$IFDEF DELPHI6_LVL}
procedure TDBAdvGridEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TDBAdvGridEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'COLUMNS') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;



{ TDBSgFieldNameProperty }

function TDBSgFieldNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList,paSortList];
end;

procedure TDBSgFieldNameProperty.GetValues(Proc: TGetStrProc);
var
  FDBGridColumnItem: TDBGridColumnItem;
  FDBGridColumnCollection: TDBGridColumnCollection;
  FDBStringGrid: TDBAdvGrid;//TDBAdvStringGrid;
  FDataSource: TDataSource;
  FDataSet: TDataSet;
  st: TStringList;
  i: Integer;
begin
  FDBGridColumnItem := (GetComponent(0) as TDBGridColumnItem);
  FDBGridColumnCollection := (fDBGridColumnItem.Collection as TDBGridColumnCollection);
  FDBStringGrid := FDBGridColumnCollection.GetOwner as TDBAdvGrid;//TDBAdvStringGrid;

  FDataSource := FDBStringGrid.DataSource;
  if not Assigned(FDataSource) then
    Exit;

  FDataSet := FDataSource.DataSet;

  if not Assigned(FDataSet) then
    Exit;

  st := TStringList.Create;
  FDataSet.GetFieldNames(st);
  for i := 1 to st.Count do
    proc(st.Strings[i-1]);
  st.Free;
end;

end.
