object fMain: TfMain
  Left = 0
  Top = 0
  Caption = #36731#32842'v1.01'
  ClientHeight = 829
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 669
    Width = 635
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 672
  end
  object Bar1: TStatusBar
    Left = 0
    Top = 810
    Width = 635
    Height = 19
    Panels = <
      item
        Width = 400
      end
      item
        Width = 50
      end>
    ExplicitLeft = 328
    ExplicitTop = 424
    ExplicitWidth = 0
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 672
    Width = 635
    Height = 138
    Align = alBottom
    TabOrder = 1
    object Panel1: TPanel
      Left = 2
      Top = 95
      Width = 631
      Height = 41
      Align = alBottom
      TabOrder = 0
      ExplicitLeft = 224
      ExplicitTop = 48
      ExplicitWidth = 185
      object btnSendMSG: TButton
        Left = 555
        Top = 1
        Width = 75
        Height = 39
        Align = alRight
        Caption = #21457#36865
        TabOrder = 0
        OnClick = btnSendMSGClick
        ExplicitLeft = -21
        ExplicitTop = 25
      end
      object btnClose: TButton
        Left = 76
        Top = 1
        Width = 75
        Height = 39
        Align = alLeft
        Caption = #20851#38381
        TabOrder = 1
        OnClick = btnCloseClick
        ExplicitLeft = 280
        ExplicitTop = 8
        ExplicitHeight = 25
      end
      object btnSendFile: TButton
        Left = 1
        Top = 1
        Width = 75
        Height = 39
        Align = alLeft
        Caption = #21457#36865#25991#20214
        TabOrder = 2
        ExplicitLeft = 280
        ExplicitTop = 8
        ExplicitHeight = 25
      end
    end
    object edtInput: TRichEdit
      Left = 2
      Top = 15
      Width = 631
      Height = 80
      Align = alClient
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Zoom = 100
      ExplicitLeft = 208
      ExplicitTop = 51
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
  object edtInfo: TRichEdit
    Left = 0
    Top = 41
    Width = 635
    Height = 628
    Align = alClient
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
    Zoom = 100
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 0
    Width = 635
    Height = 41
    Align = alTop
    Caption = #23545#26041#32534#21495
    TabOrder = 3
    object edtFriendID: TEdit
      Left = 2
      Top = 15
      Width = 631
      Height = 21
      Align = alTop
      TabOrder = 0
      Text = '1001'
      ExplicitLeft = 256
      ExplicitTop = 24
      ExplicitWidth = 121
    end
  end
end
