object FHelp: TFHelp
  Left = 432
  Top = 179
  Width = 320
  Height = 257
  Caption = 'FHelp'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MHelp: TMemo
    Left = 0
    Top = 0
    Width = 305
    Height = 225
    Enabled = False
    Lines.Strings = (
      ':: Keys'
      'A - Add instance'
      'D - Delete instance'
      'R - Refresh'
      'L - Show debug log'
      'N - Next search result'
      'P - Prev search result'
      'Q - Quit'
      '? - Show this help'
      ': - Enter command mode'
      ''
      ':: Commands'
      'w [FILE]  - Save database'
      'o [FILE] - Open database'
      'q - Quit'
      '/ [TERM] - Search TERM in instances'
      'help - Show this help')
    TabOrder = 0
  end
end
