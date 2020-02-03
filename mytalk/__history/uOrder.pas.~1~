unit uOrder;

interface
uses  windows;
const

  //数据传输协议包头：
  UID:integer=8888;//包头标识;
  VER:integer=1003;
  ENC:integer=7620;

  CMD_TEST=1000;//测试；

  CMD_READY=1001;//准备好命令;
  CMD_REQUEST_USER_ID=1002;//申请用户ID
  CMD_INFO=1003;//获取信息命令;
  CMD_FILE_TRANS=1004;//传输文件命令;
  CMD_SEND_RESULT=1005;//转发数据成功否；（对方是否在线）
type
  POrderHeader=^stOrderHeader;
  stOrderHeader=packed record
    uid:DWORD;
    Ver:DWORD;
    Enc:DWORD;
    id:DWORD;
    pid:DWORD;
    cmd:DWORD;
    len:DWORD;
    dat:pointer;
  end;
  function VerifyOH(oh:stOrderHeader) :boolean;//校验包头;
  function formatOH(var oh:stOrderHeader) :stOrderHeader;//格式化包头;
implementation
function VerifyOH(oh:stOrderHeader) :boolean;//校验包头;
begin
  result:=true;
  if(oh.uid<>UID)then result:=false;
  if(oh.Ver<>VER)then result:=false;
  if(oh.ENC<>ENC)then result:=false;
end;
function formatOH(var oh:stOrderHeader) :stOrderHeader;//格式化包头;
begin
  oh.uid:=UID;
  oh.Ver:=VER;
  oh.Enc:=ENC;
  oh.id:=0;
  oh.pid:=0;
  oh.cmd:=CMD_READY;
  oh.len:=0;
  oh.dat:=nil;
  result:=oh;
end;

end.
