object FMain: TFMain
  Left = 74
  Top = 104
  Width = 567
  Height = 245
  Caption = 'FMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LBClub: TListBox
    Left = 120
    Top = 0
    Width = 121
    Height = 217
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 1
    OnClick = LBClubClick
  end
  object LBLeague: TListBox
    Left = -1
    Top = 1
    Width = 121
    Height = 216
    Color = clScrollBar
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 0
    OnClick = LBLeagueClick
  end
  object ETerm: TEdit
    Left = 0
    Top = 216
    Width = 545
    Height = 21
    TabOrder = 2
    Text = 'ETerm'
    Visible = False
    OnKeyPress = ETermKeyPress
  end
  inline FrShow: TFrShow
    Left = 368
    Top = 0
    Width = 177
    Height = 217
    TabOrder = 3
  end
  object LBPlayer: TListBox
    Left = 240
    Top = 0
    Width = 121
    Height = 217
    ItemHeight = 13
    ScrollWidth = 1
    TabOrder = 4
  end
end
