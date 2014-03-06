object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Audit Trail'
  ClientHeight = 472
  ClientWidth = 875
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 875
    Height = 472
    ActivePage = TabSheet5
    Align = alClient
    TabOrder = 0
    object TabSheet2: TTabSheet
      Caption = 'Users (SY)'
      ImageIndex = 1
      DesignSize = (
        867
        444)
      object Label3: TLabel
        Left = 376
        Top = 32
        Width = 25
        Height = 13
        Caption = 'Code'
      end
      object Label4: TLabel
        Left = 376
        Top = 64
        Width = 27
        Height = 13
        Caption = 'Name'
      end
      object Label5: TLabel
        Left = 376
        Top = 95
        Width = 24
        Height = 13
        Caption = 'Email'
      end
      object Label7: TLabel
        Left = 16
        Top = 214
        Width = 40
        Height = 13
        Caption = 'SY Audit'
      end
      object btnSaveUser: TButton
        Left = 448
        Top = 128
        Width = 75
        Height = 25
        Caption = 'Save'
        TabOrder = 3
        OnClick = btnSaveUserClick
      end
      object ListView3: TListView
        Left = 16
        Top = 24
        Width = 313
        Height = 177
        Columns = <
          item
            Caption = 'Code'
            Width = 75
          end
          item
            Caption = 'Name'
            Width = 100
          end
          item
            AutoSize = True
            Caption = 'Email'
          end>
        RowSelect = True
        TabOrder = 4
        ViewStyle = vsReport
        OnChange = ListView3Change
        OnSelectItem = ListView3SelectItem
      end
      object Edit2: TEdit
        Left = 448
        Top = 29
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object Edit3: TEdit
        Left = 448
        Top = 61
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object Edit4: TEdit
        Left = 448
        Top = 92
        Width = 121
        Height = 21
        TabOrder = 2
      end
      object ListView4: TListView
        Left = 16
        Top = 231
        Width = 831
        Height = 199
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'ID'
            Width = 30
          end
          item
            Caption = 'Transaction Type'
            Width = 100
          end
          item
            Caption = 'Parent ID'
            Width = 90
          end
          item
            Caption = 'Transaction ID'
            Width = 90
          end
          item
            Caption = 'Action'
            Width = 60
          end
          item
            Caption = 'User Code'
            Width = 75
          end
          item
            Caption = 'Date/Time'
            Width = 120
          end
          item
            AutoSize = True
            Caption = 'Values'
          end>
        RowSelect = True
        TabOrder = 5
        ViewStyle = vsReport
      end
      object Button2: TButton
        Left = 529
        Top = 128
        Width = 75
        Height = 25
        Caption = 'Delete'
        TabOrder = 6
        OnClick = Button2Click
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Payees (BK)'
      DesignSize = (
        867
        444)
      object Label1: TLabel
        Left = 344
        Top = 31
        Width = 37
        Height = 13
        Caption = 'Number'
      end
      object Label2: TLabel
        Left = 344
        Top = 59
        Width = 27
        Height = 13
        Caption = 'Name'
      end
      object Label6: TLabel
        Left = 16
        Top = 214
        Width = 40
        Height = 13
        Caption = 'BK Audit'
      end
      object ListView2: TListView
        Left = 16
        Top = 24
        Width = 313
        Height = 177
        Columns = <
          item
            Caption = 'Audit ID'
            Width = 75
          end
          item
            Caption = 'Payee #'
            Width = 75
          end
          item
            AutoSize = True
            Caption = 'Name'
          end>
        RowSelect = True
        TabOrder = 4
        ViewStyle = vsReport
        OnChange = ListView2Change
        OnSelectItem = ListView2SelectItem
      end
      object Edit1: TEdit
        Left = 408
        Top = 56
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object SpinEdit1: TSpinEdit
        Left = 408
        Top = 28
        Width = 121
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 0
      end
      object btnSavePayee: TButton
        Left = 408
        Top = 83
        Width = 75
        Height = 25
        Caption = 'Save'
        TabOrder = 2
        OnClick = btnSavePayeeClick
      end
      object btnDelete: TButton
        Left = 489
        Top = 83
        Width = 75
        Height = 25
        Caption = 'Delete'
        TabOrder = 3
        OnClick = btnDeleteClick
      end
      object ListView1: TListView
        Left = 16
        Top = 231
        Width = 831
        Height = 199
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'ID'
            Width = 30
          end
          item
            Caption = 'Transaction Type'
            Width = 100
          end
          item
            Caption = 'Parent ID'
            Width = 90
          end
          item
            Caption = 'Transaction ID'
            Width = 90
          end
          item
            Caption = 'Action'
            Width = 60
          end
          item
            Caption = 'User Code'
            Width = 75
          end
          item
            Caption = 'Date/Time'
            Width = 120
          end
          item
            AutoSize = True
            Caption = 'Values'
          end>
        RowSelect = True
        TabOrder = 5
        ViewStyle = vsReport
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Practice (SY)'
      ImageIndex = 3
      object Label8: TLabel
        Left = 40
        Top = 43
        Width = 68
        Height = 13
        Caption = 'Practice Name'
      end
      object Label9: TLabel
        Left = 40
        Top = 70
        Width = 30
        Height = 13
        Caption = 'Phone'
      end
      object Label10: TLabel
        Left = 40
        Top = 112
        Width = 50
        Height = 13
        Caption = 'GST Rates'
      end
      object Edit5: TEdit
        Left = 128
        Top = 40
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object Edit6: TEdit
        Left = 128
        Top = 67
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object StringGrid1: TStringGrid
        Left = 40
        Top = 131
        Width = 425
        Height = 158
        ColCount = 4
        DefaultColWidth = 100
        DefaultRowHeight = 17
        FixedCols = 0
        RowCount = 6
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 2
      end
      object Button3: TButton
        Left = 40
        Top = 304
        Width = 75
        Height = 25
        Caption = 'Save'
        TabOrder = 3
        OnClick = Button3Click
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Report'
      ImageIndex = 4
      ExplicitLeft = 44
      ExplicitTop = 28
      DesignSize = (
        867
        444)
      object Label11: TLabel
        Left = 16
        Top = 24
        Width = 83
        Height = 13
        Caption = 'Transaction Type'
      end
      object Label12: TLabel
        Left = 16
        Top = 56
        Width = 70
        Height = 13
        Caption = 'Transaction ID'
      end
      object cbAuditTypes: TComboBox
        Left = 136
        Top = 21
        Width = 209
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
      end
      object Edit7: TEdit
        Left = 136
        Top = 53
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object ListView5: TListView
        Left = 16
        Top = 88
        Width = 831
        Height = 342
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'ID'
            Width = 30
          end
          item
            Caption = 'Transaction Type'
            Width = 100
          end
          item
            Caption = 'Parent ID'
            Width = 90
          end
          item
            Caption = 'Transaction ID'
            Width = 90
          end
          item
            Caption = 'Action'
            Width = 60
          end
          item
            Caption = 'User Code'
            Width = 75
          end
          item
            Caption = 'Date/Time'
            Width = 120
          end
          item
            AutoSize = True
            Caption = 'Values'
          end>
        RowSelect = True
        TabOrder = 2
        ViewStyle = vsReport
      end
      object btnByTxnType: TButton
        Left = 351
        Top = 19
        Width = 43
        Height = 25
        Caption = 'Go'
        TabOrder = 3
        OnClick = btnByTxnTypeClick
      end
      object btnByTxnID: TButton
        Left = 265
        Top = 51
        Width = 43
        Height = 25
        Caption = 'Go'
        TabOrder = 4
        OnClick = btnByTxnIDClick
      end
      object btnSaveToCSV: TButton
        Left = 674
        Top = 57
        Width = 75
        Height = 25
        Caption = 'Save to CSV'
        TabOrder = 5
        OnClick = btnSaveToCSVClick
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Audit Types'
      ImageIndex = 2
      object ListView6: TListView
        Left = 24
        Top = 64
        Width = 521
        Height = 337
        Columns = <
          item
            Caption = 'Audit Type'
            Width = 200
          end
          item
            Caption = 'Database'
            Width = 100
          end
          item
            Caption = 'Table'
            Width = 200
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
      object btnListAuditTypes: TButton
        Left = 24
        Top = 33
        Width = 121
        Height = 25
        Caption = 'List Audit Types'
        TabOrder = 1
        OnClick = btnListAuditTypesClick
      end
    end
  end
end
