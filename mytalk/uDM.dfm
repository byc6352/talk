object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object cs1: TClientSocket
    Active = False
    Address = '127.0.0.1'
    ClientType = ctNonBlocking
    Port = 6010
    OnConnect = cs1Connect
    OnDisconnect = cs1Disconnect
    OnRead = cs1Read
    OnError = cs1Error
    Left = 88
    Top = 56
  end
end
