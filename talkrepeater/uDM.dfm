object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 452
  Width = 620
  object ssOrder: TServerSocket
    Active = False
    Port = 6001
    ServerType = stNonBlocking
    OnClientConnect = ssOrderClientConnect
    OnClientDisconnect = ssOrderClientDisconnect
    OnClientRead = ssOrderClientRead
    OnClientError = ssOrderClientError
    Left = 128
    Top = 8
  end
  object ssData1: TServerSocket
    Active = False
    Port = 6011
    ServerType = stNonBlocking
    Left = 200
    Top = 8
  end
end
