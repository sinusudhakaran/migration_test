{*******************************************************}
{                                                       }
{     ObjectSight Visual Components                     }
{     TopGrid components and editors registration unit  }
{                                                       }
{     Copyright (c) 1999-2002, ObjectSight              }
{                                                       }
{*******************************************************}

unit TSGReg;

{$INCLUDE TSCmpVer}

interface

uses
    TSGrid, TSDBGrid, TSMask, TSImageList, TSDateTime,
    TSImagelistEditor, {TSDateTimeEditor,}
    {$IFNDEF TSVER_V4PRO} tsHTMLGridProducer, {$ENDIF}
    osColorComboBox, osGridEditor
    {$IFDEF TSVER_V6} , DesignEditors {$ENDIF};

procedure Register;

implementation

uses
    Classes, {$IFDEF TSVER_V6} DesignIntf, {$ELSE} DsgnIntf, {$ENDIF} Controls;

procedure Register;
begin
    RegisterComponents('TopGrid', [TtsGrid]);
    RegisterComponents('TopGrid', [TtsDBGrid]);
    RegisterComponents('TopGrid', [TtsMaskDefs]);
    RegisterComponents('TopGrid', [TtsImageList]);
    RegisterComponents('TopGrid', [TtsDateTimeDef]);
    {$IFNDEF TSVER_V4PRO} RegisterComponents('TopGrid', [TtsHTMLGridProducer]); {$ENDIF}
    RegisterComponents('TopGrid', [TosColorComboBox]);

    RegisterPropertyEditor(TypeInfo(string), TtsCol, 'FieldName', TStringProperty);
//rh    RegisterPropertyEditor(TypeInfo(TDate), TtsDateTimeDefProps, 'MinDate', TtsDateTimeDateProperty);
//rh    RegisterPropertyEditor(TypeInfo(TDate), TtsDateTimeDefProps, 'MaxDate', TtsDateTimeDateProperty);

    RegisterComponentEditor(TtsBaseGrid, TosGridEditor);
    RegisterPropertyEditor(TypeInfo(TtsImageCollection), TtsImageList, '', TtsImageCollectionEditor);
    RegisterComponentEditor(TtsImageList, TtsImageListEditor);
    //RegisterComponentEditor(TtsDateTimeDef, TtsDateTimeEditor);
end;

end.
