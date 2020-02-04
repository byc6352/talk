unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,richedit,
  uLog,uConfig,uDM,uOrder;

type
  TfMain = class(TForm)
    Bar1: TStatusBar;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    btnSendMSG: TButton;
    btnClose: TButton;
    Splitter1: TSplitter;
    edtInput: TRichEdit;
    btnSendFile: TButton;
    edtInfo: TRichEdit;
    GroupBox2: TGroupBox;
    edtFriendID: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSendMSGClick(Sender: TObject);
  private
    { Private declarations }
    procedure TryExcepts(Sender: TObject; E: Exception);
    procedure SetRichEditNum(RichEdit1:tRichEdit);
    procedure SetRichEditLineSpacing(RichEdit1:tRichEdit);
  public
    { Public declarations }
    procedure LogMain(const str: string);
    procedure MSGmain(friendID:integer;msg:ansistring);
    procedure myMSGmain(msg:string);
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
procedure TfMain.myMSGmain(msg:string);
var
  selStart:integer;
begin

  //edtInfo.Lines.Add(msg);
  //selStart:=length(edtInfo.Text)-length(msg)-2;
  selStart:=length(edtInfo.Text);
  //edtInfo.Lines.Add(msg);
  edtInfo.Text:=edtInfo.Text+msg+#13#10;
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(msg)+2;
  edtInfo.SelAttributes.Size:=12;
  edtInfo.SelAttributes.Color:=clBlue;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;
  bar1.Panels[1].Text:='selStart='+inttostr(selStart)+';len='+inttostr(length(msg)+2)+';text length='+inttostr(length(edtInfo.Text));
end;
procedure TfMain.MSGmain(friendID:integer;msg:ansistring);
var
  selStart:integer;
  mysmg:string;
begin
  edtFriendID.Text:=inttostr(friendID);
  selStart:=length(edtInfo.Lines.Text);
  mysmg:=string(msg);
  edtInfo.Lines.Add(mysmg);
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(mysmg);
  edtInfo.SelAttributes.Size:=12;
  edtInfo.SelAttributes.Color:=claqua;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;
end;
procedure TfMain.TryExcepts(Sender: TObject; E: Exception);
begin
  LogMain(E.Message);
end;
procedure TfMain.btnSendMSGClick(Sender: TObject);
var
  userID:integer;
  msg:string;
  ansimsg:ansiString;
  len:integer;
begin
  if dm.cs1.Active=false then
  begin
    showmessage('未连接服务器！');
    exit;
  end;
  if trim(edtFriendID.text)='' then
  begin
    showmessage('请输入对方编号！');
    exit;
  end;
  if trim(edtInput.text)='' then
  begin
    showmessage('消息内容为空！');
    exit;
  end;
  msg:=trim(edtInput.text);
  ansimsg:=ansiString(msg);
  len:=length(ansimsg);
  if len>=uDM.MAX_BUF_SIZE-sizeof(stOrderHeader) then
  begin
    showmessage('消息内容不能大于'+inttostr(uDM.MAX_BUF_SIZE-sizeof(stOrderHeader)));
    exit;
  end;
try
  userID:=strtoint(trim(edtFriendID.Text));

  dm.SendMSG(userID,ansimsg);
  myMSGmain(msg);
finally

end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
Application.OnException := TryExcepts;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION;
  if(dm.cs1.Active)then bar1.Panels[0].Text:='连接服务器成功！';
end;

procedure tfmain.LogMain(const str: string);
var
  selStart:integer;
  msg:string;
begin

  msg:=Log(str);


  selStart:=length(edtInfo.Text);
  //edtInfo.Lines.Add(msg);
  edtInfo.Text:=edtInfo.Text+msg+#13#10;
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(msg)+2;
  edtInfo.SelAttributes.Size:=8;
  edtInfo.SelAttributes.Color:=clGray;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;
  bar1.Panels[0].Text:='selStart='+inttostr(selStart)+';len='+inttostr(length(msg)+2)+';text length='+inttostr(length(edtInfo.Text));
end;

procedure TfMain.btnCloseClick(Sender: TObject);
begin
  close;
end;


























procedure TfMain.SetRichEditLineSpacing(RichEdit1:tRichEdit);
var
  pf: PARAFORMAT2;
begin
  FillChar(pf, sizeof(paraformat2), #0);
  pf.cbSize := SizeOf(paraformat2);
  pf.dwMask := PFM_LINESPACING  ;   //需要设置上 PFM_LINESPACING 标志，bLineSpacingRule和dyLineSpacing才可能有效

//  pf.bLineSpacingRule := 0;   //单倍行距，dyLineSpacing的值将被忽略
//  pf.bLineSpacingRule := 1;   //1.5倍行距，dyLineSpacing的值将被忽略
//  pf.bLineSpacingRule := 2;   //两倍行距，dyLineSpacing的值将被忽略
//  pf.bLineSpacingRule := 3;   //用dyLineSpacing以缇为单位指定行间距，当此值小于单倍行距时，效果为单倍行距
//  pf.bLineSpacingRule := 5;   //用dyLineSpacing/20指定行间距

  pf.bLineSpacingRule := 4;   //用dyLineSpacing以缇为单位指定行间距
  pf.dyLineSpacing := RichEdit1.Font.Size * 20 + 20 * 4; //这是笔者大概计算的，可以根据字体大小调节的，行间最小距离，大字体时可能出现上下行重叠，可以设置为300或者自己计算

  RichEdit1.SelectAll;   //只对选择的文本有效，***重要***
  SendMessage(RichEdit1.Handle, EM_SETPARAFORMAT, 0, LPARAM(@pf));
  RichEdit1.SelStart := 0;
  RichEdit1.SelLength := 0;

end;
procedure TfMain.SetRichEditNum(RichEdit1:tRichEdit);
const
  PFNS_PAREN    =   $000;  //e.g. 1)
  PFNS_PARENS   = $100;  //e.g. (1)
  PFNS_PERIOD   = $200;  //e.g. 1.
  PFNS_PLAIN    =   $300;
  PFNS_NONUMBER =   $400;

const
  PFN_NONE     = $00000000;  //无
  PFN_BULLET   = $00000001;  //黑色实心圆点
  PFN_ARABIC   = $00000002;  //0,1,2
  PFN_LCLETTER = $00000003;  //a,b,c
  PFN_UCLETTER = $00000004;  //A,B,C
  PFN_LCROMAN  = $00000005;  //i,ii,iii
  PFN_UCROMAN  = $00000006;  //I,II,III

  var
  pf: PARAFORMAT2;
begin
  FillChar(pf, sizeof(paraformat2), #0);
  pf.cbSize := SizeOf(paraformat2);
  //PFM_NUMBERING: wNumbering 值有效
  //PFM_NUMBERINGSTYLE: wNumberingStyle值有效
  //PFM_NUMBERINGSTART: wNumberingStart值有效
  //PFM_STARTINDENT: dxStartIndent值有效
  pf.dwMask := PFM_NUMBERING or PFM_NUMBERINGSTYLE or PFM_NUMBERINGSTART or PFM_STARTINDENT;//or PFM_OFFSET;

  pf.wNumberingStyle := PFNS_PERIOD;  //设置行号的样式，可以为“)”，“.”，“()”
  pf.wNumberingStart := 1;            //设置行号起始值
  pf.wNumbering := PFN_ARABIC;        //设置行号的格式，可以为阿拉伯数字或者英文字母等格式
  pf.dxStartIndent := 60;             //设置行首缩进值

  RichEdit1.SelectAll;
  SendMessage(RichEdit1.Handle, EM_SETPARAFORMAT, 0, LPARAM(@pf));
  RichEdit1.SelStart := 0;
  RichEdit1.SelLength := 0;

end;

end.
