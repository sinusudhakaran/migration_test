object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Audit Trail'
  ClientHeight = 472
  ClientWidth = 817
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
  DesignSize = (
    817
    472)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 25
    Top = 21
    Width = 770
    Height = 436
    ActivePage = TabSheet2
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TabSheet2: TTabSheet
      Caption = 'Users (SY)'
      ImageIndex = 1
      DesignSize = (
        762
        408)
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
        TabOrder = 0
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
        TabOrder = 1
        ViewStyle = vsReport
        OnChange = ListView3Change
        OnSelectItem = ListView3SelectItem
      end
      object Edit2: TEdit
        Left = 448
        Top = 29
        Width = 121
        Height = 21
        TabOrder = 2
      end
      object Edit3: TEdit
        Left = 448
        Top = 61
        Width = 121
        Height = 21
        TabOrder = 3
      end
      object Edit4: TEdit
        Left = 448
        Top = 92
        Width = 121
        Height = 21
        TabOrder = 4
      end
      object ListView4: TListView
        Left = 16
        Top = 231
        Width = 726
        Height = 163
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'ID'
          end
          item
            Caption = 'Transaction Type'
            Width = 100
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
            Width = 100
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
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        762
        408)
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
        TabOrder = 0
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
        TabOrder = 2
        Value = 0
      end
      object btnSavePayee: TButton
        Left = 408
        Top = 83
        Width = 75
        Height = 25
        Caption = 'Save'
        TabOrder = 3
        OnClick = btnSavePayeeClick
      end
      object btnDelete: TButton
        Left = 489
        Top = 83
        Width = 75
        Height = 25
        Caption = 'Delete'
        TabOrder = 4
        OnClick = btnDeleteClick
      end
      object ListView1: TListView
        Left = 16
        Top = 231
        Width = 726
        Height = 163
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'ID'
          end
          item
            Caption = 'Transaction Type'
            Width = 100
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
            Width = 100
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
    object TabSheet3: TTabSheet
      Caption = 'Test'
      ImageIndex = 2
      object Memo1: TMemo
        Left = 24
        Top = 64
        Width = 241
        Height = 313
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object Button1: TButton
        Left = 24
        Top = 33
        Width = 113
        Height = 25
        Caption = 'List All Tables'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button3: TButton
        Left = 312
        Top = 33
        Width = 145
        Height = 25
        Caption = 'List Tables to Audit'
        TabOrder = 2
        OnClick = Button3Click
      end
      object Memo2: TMemo
        Left = 312
        Top = 64
        Width = 241
        Height = 313
        ScrollBars = ssVertical
        TabOrder = 3
      end
    end
  end
end
