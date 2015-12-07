
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 64 0f 00 00       	call   f75 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 20 15 00 00 	mov    0x1520(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 f4 14 00 00 	movl   $0x14f4,(%esp)
      2b:	e8 3b 03 00 00       	call   36b <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 30 0f 00 00       	call   f75 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 50 0f 00 00       	call   fad <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 fb 14 00 	movl   $0x14fb,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 aa 10 00 00       	call   1125 <printf>
    break;
      7b:	e9 86 01 00 00       	jmp    206 <runcmd+0x206>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 09 0f 00 00       	call   f9d <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 09 0f 00 00       	call   fb5 <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 0b 15 00 	movl   $0x150b,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 57 10 00 00       	call   1125 <printf>
      exit();
      ce:	e8 a2 0e 00 00       	call   f75 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 20 01 00 00       	jmp    206 <runcmd+0x206>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 a0 02 00 00       	call   391 <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
      runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 75 0e 00 00       	call   f7d <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 eb 00 00 00       	jmp    206 <runcmd+0x206>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 59 0e 00 00       	call   f85 <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 1b 15 00 00 	movl   $0x151b,(%esp)
     137:	e8 2f 02 00 00       	call   36b <panic>
    if(fork1() == 0){
     13c:	e8 50 02 00 00       	call   391 <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 4c 0e 00 00       	call   f9d <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 91 0e 00 00       	call   fed <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 36 0e 00 00       	call   f9d <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 2b 0e 00 00       	call   f9d <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 0c 02 00 00       	call   391 <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 08 0e 00 00       	call   f9d <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 4d 0e 00 00       	call   fed <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 f2 0d 00 00       	call   f9d <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 e7 0d 00 00       	call   f9d <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 ce 0d 00 00       	call   f9d <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 c3 0d 00 00       	call   f9d <close>
    wait();
     1da:	e8 9e 0d 00 00       	call   f7d <wait>
    wait();
     1df:	e8 99 0d 00 00       	call   f7d <wait>
    break;
     1e4:	eb 20                	jmp    206 <runcmd+0x206>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 a0 01 00 00       	call   391 <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 10                	jne    205 <runcmd+0x205>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	eb 00                	jmp    205 <runcmd+0x205>
     205:	90                   	nop
  }
  exit();
     206:	e8 6a 0d 00 00       	call   f75 <exit>

0000020b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     20b:	55                   	push   %ebp
     20c:	89 e5                	mov    %esp,%ebp
     20e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     211:	c7 44 24 04 38 15 00 	movl   $0x1538,0x4(%esp)
     218:	00 
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 00 0f 00 00       	call   1125 <printf>
  memset(buf, 0, nbuf);
     225:	8b 45 0c             	mov    0xc(%ebp),%eax
     228:	89 44 24 08          	mov    %eax,0x8(%esp)
     22c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     233:	00 
     234:	8b 45 08             	mov    0x8(%ebp),%eax
     237:	89 04 24             	mov    %eax,(%esp)
     23a:	e8 89 0b 00 00       	call   dc8 <memset>
  gets(buf, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 04          	mov    %eax,0x4(%esp)
     246:	8b 45 08             	mov    0x8(%ebp),%eax
     249:	89 04 24             	mov    %eax,(%esp)
     24c:	e8 ce 0b 00 00       	call   e1f <gets>
  if(buf[0] == 0) // EOF
     251:	8b 45 08             	mov    0x8(%ebp),%eax
     254:	0f b6 00             	movzbl (%eax),%eax
     257:	84 c0                	test   %al,%al
     259:	75 07                	jne    262 <getcmd+0x57>
    return -1;
     25b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     260:	eb 05                	jmp    267 <getcmd+0x5c>
  return 0;
     262:	b8 00 00 00 00       	mov    $0x0,%eax
}
     267:	c9                   	leave  
     268:	c3                   	ret    

00000269 <main>:

int
main(void)
{
     269:	55                   	push   %ebp
     26a:	89 e5                	mov    %esp,%ebp
     26c:	83 e4 f0             	and    $0xfffffff0,%esp
     26f:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     272:	eb 15                	jmp    289 <main+0x20>
    if(fd >= 3){
     274:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     279:	7e 0e                	jle    289 <main+0x20>
      close(fd);
     27b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     27f:	89 04 24             	mov    %eax,(%esp)
     282:	e8 16 0d 00 00       	call   f9d <close>
      break;
     287:	eb 1f                	jmp    2a8 <main+0x3f>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     289:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     290:	00 
     291:	c7 04 24 3b 15 00 00 	movl   $0x153b,(%esp)
     298:	e8 18 0d 00 00       	call   fb5 <open>
     29d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2a1:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2a6:	79 cc                	jns    274 <main+0xb>
// #ifndef FCFS
 	printf(1, "RUNNING FIFO ROUND RUBIN SCHEDULER\n");
// #endif
 #endif
 #ifdef FCFS
 	printf(1, "RUNNING FIRST COME FIRST SERVED SCHEDULER\n");
     2a8:	c7 44 24 04 44 15 00 	movl   $0x1544,0x4(%esp)
     2af:	00 
     2b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2b7:	e8 69 0e 00 00       	call   1125 <printf>
 #ifdef CFS
 	printf(1, "RUNNING COMPLETELY FAIR SCHEDULING SCHEDULER\n");
 #endif

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2bc:	e9 89 00 00 00       	jmp    34a <main+0xe1>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2c1:	0f b6 05 c0 1a 00 00 	movzbl 0x1ac0,%eax
     2c8:	3c 63                	cmp    $0x63,%al
     2ca:	75 5c                	jne    328 <main+0xbf>
     2cc:	0f b6 05 c1 1a 00 00 	movzbl 0x1ac1,%eax
     2d3:	3c 64                	cmp    $0x64,%al
     2d5:	75 51                	jne    328 <main+0xbf>
     2d7:	0f b6 05 c2 1a 00 00 	movzbl 0x1ac2,%eax
     2de:	3c 20                	cmp    $0x20,%al
     2e0:	75 46                	jne    328 <main+0xbf>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2e2:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     2e9:	e8 b3 0a 00 00       	call   da1 <strlen>
     2ee:	83 e8 01             	sub    $0x1,%eax
     2f1:	c6 80 c0 1a 00 00 00 	movb   $0x0,0x1ac0(%eax)
      if(chdir(buf+3) < 0)
     2f8:	c7 04 24 c3 1a 00 00 	movl   $0x1ac3,(%esp)
     2ff:	e8 e1 0c 00 00       	call   fe5 <chdir>
     304:	85 c0                	test   %eax,%eax
     306:	79 1e                	jns    326 <main+0xbd>
        printf(2, "cannot cd %s\n", buf+3);
     308:	c7 44 24 08 c3 1a 00 	movl   $0x1ac3,0x8(%esp)
     30f:	00 
     310:	c7 44 24 04 6f 15 00 	movl   $0x156f,0x4(%esp)
     317:	00 
     318:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     31f:	e8 01 0e 00 00       	call   1125 <printf>
      continue;
     324:	eb 24                	jmp    34a <main+0xe1>
     326:	eb 22                	jmp    34a <main+0xe1>
    }
    if(fork1() == 0)
     328:	e8 64 00 00 00       	call   391 <fork1>
     32d:	85 c0                	test   %eax,%eax
     32f:	75 14                	jne    345 <main+0xdc>
      runcmd(parsecmd(buf));
     331:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     338:	e8 c9 03 00 00       	call   706 <parsecmd>
     33d:	89 04 24             	mov    %eax,(%esp)
     340:	e8 bb fc ff ff       	call   0 <runcmd>
    wait();
     345:	e8 33 0c 00 00       	call   f7d <wait>
 #ifdef CFS
 	printf(1, "RUNNING COMPLETELY FAIR SCHEDULING SCHEDULER\n");
 #endif

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     34a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     351:	00 
     352:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     359:	e8 ad fe ff ff       	call   20b <getcmd>
     35e:	85 c0                	test   %eax,%eax
     360:	0f 89 5b ff ff ff    	jns    2c1 <main+0x58>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     366:	e8 0a 0c 00 00       	call   f75 <exit>

0000036b <panic>:
}

void
panic(char *s)
{
     36b:	55                   	push   %ebp
     36c:	89 e5                	mov    %esp,%ebp
     36e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     371:	8b 45 08             	mov    0x8(%ebp),%eax
     374:	89 44 24 08          	mov    %eax,0x8(%esp)
     378:	c7 44 24 04 7d 15 00 	movl   $0x157d,0x4(%esp)
     37f:	00 
     380:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     387:	e8 99 0d 00 00       	call   1125 <printf>
  exit();
     38c:	e8 e4 0b 00 00       	call   f75 <exit>

00000391 <fork1>:
}

int
fork1(void)
{
     391:	55                   	push   %ebp
     392:	89 e5                	mov    %esp,%ebp
     394:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     397:	e8 d1 0b 00 00       	call   f6d <fork>
     39c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     39f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3a3:	75 0c                	jne    3b1 <fork1+0x20>
    panic("fork");
     3a5:	c7 04 24 81 15 00 00 	movl   $0x1581,(%esp)
     3ac:	e8 ba ff ff ff       	call   36b <panic>
  return pid;
     3b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3b4:	c9                   	leave  
     3b5:	c3                   	ret    

000003b6 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3b6:	55                   	push   %ebp
     3b7:	89 e5                	mov    %esp,%ebp
     3b9:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3bc:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3c3:	e8 49 10 00 00       	call   1411 <malloc>
     3c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3cb:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3d2:	00 
     3d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3da:	00 
     3db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3de:	89 04 24             	mov    %eax,(%esp)
     3e1:	e8 e2 09 00 00       	call   dc8 <memset>
  cmd->type = EXEC;
     3e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3e9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3f2:	c9                   	leave  
     3f3:	c3                   	ret    

000003f4 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     3f4:	55                   	push   %ebp
     3f5:	89 e5                	mov    %esp,%ebp
     3f7:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3fa:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     401:	e8 0b 10 00 00       	call   1411 <malloc>
     406:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     409:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     410:	00 
     411:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     418:	00 
     419:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41c:	89 04 24             	mov    %eax,(%esp)
     41f:	e8 a4 09 00 00       	call   dc8 <memset>
  cmd->type = REDIR;
     424:	8b 45 f4             	mov    -0xc(%ebp),%eax
     427:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     430:	8b 55 08             	mov    0x8(%ebp),%edx
     433:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     436:	8b 45 f4             	mov    -0xc(%ebp),%eax
     439:	8b 55 0c             	mov    0xc(%ebp),%edx
     43c:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     43f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     442:	8b 55 10             	mov    0x10(%ebp),%edx
     445:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     448:	8b 45 f4             	mov    -0xc(%ebp),%eax
     44b:	8b 55 14             	mov    0x14(%ebp),%edx
     44e:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     451:	8b 45 f4             	mov    -0xc(%ebp),%eax
     454:	8b 55 18             	mov    0x18(%ebp),%edx
     457:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     45a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     45d:	c9                   	leave  
     45e:	c3                   	ret    

0000045f <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     45f:	55                   	push   %ebp
     460:	89 e5                	mov    %esp,%ebp
     462:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     465:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     46c:	e8 a0 0f 00 00       	call   1411 <malloc>
     471:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     474:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     47b:	00 
     47c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     483:	00 
     484:	8b 45 f4             	mov    -0xc(%ebp),%eax
     487:	89 04 24             	mov    %eax,(%esp)
     48a:	e8 39 09 00 00       	call   dc8 <memset>
  cmd->type = PIPE;
     48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     492:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     498:	8b 45 f4             	mov    -0xc(%ebp),%eax
     49b:	8b 55 08             	mov    0x8(%ebp),%edx
     49e:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a4:	8b 55 0c             	mov    0xc(%ebp),%edx
     4a7:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4ad:	c9                   	leave  
     4ae:	c3                   	ret    

000004af <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4af:	55                   	push   %ebp
     4b0:	89 e5                	mov    %esp,%ebp
     4b2:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4b5:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4bc:	e8 50 0f 00 00       	call   1411 <malloc>
     4c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4c4:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4cb:	00 
     4cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4d3:	00 
     4d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d7:	89 04 24             	mov    %eax,(%esp)
     4da:	e8 e9 08 00 00       	call   dc8 <memset>
  cmd->type = LIST;
     4df:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4e2:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4eb:	8b 55 08             	mov    0x8(%ebp),%edx
     4ee:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f4:	8b 55 0c             	mov    0xc(%ebp),%edx
     4f7:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4fd:	c9                   	leave  
     4fe:	c3                   	ret    

000004ff <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     4ff:	55                   	push   %ebp
     500:	89 e5                	mov    %esp,%ebp
     502:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     505:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     50c:	e8 00 0f 00 00       	call   1411 <malloc>
     511:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     514:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     51b:	00 
     51c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     523:	00 
     524:	8b 45 f4             	mov    -0xc(%ebp),%eax
     527:	89 04 24             	mov    %eax,(%esp)
     52a:	e8 99 08 00 00       	call   dc8 <memset>
  cmd->type = BACK;
     52f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     532:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     538:	8b 45 f4             	mov    -0xc(%ebp),%eax
     53b:	8b 55 08             	mov    0x8(%ebp),%edx
     53e:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     541:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     544:	c9                   	leave  
     545:	c3                   	ret    

00000546 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     546:	55                   	push   %ebp
     547:	89 e5                	mov    %esp,%ebp
     549:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     54c:	8b 45 08             	mov    0x8(%ebp),%eax
     54f:	8b 00                	mov    (%eax),%eax
     551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     554:	eb 04                	jmp    55a <gettoken+0x14>
    s++;
     556:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     55d:	3b 45 0c             	cmp    0xc(%ebp),%eax
     560:	73 1d                	jae    57f <gettoken+0x39>
     562:	8b 45 f4             	mov    -0xc(%ebp),%eax
     565:	0f b6 00             	movzbl (%eax),%eax
     568:	0f be c0             	movsbl %al,%eax
     56b:	89 44 24 04          	mov    %eax,0x4(%esp)
     56f:	c7 04 24 98 1a 00 00 	movl   $0x1a98,(%esp)
     576:	e8 71 08 00 00       	call   dec <strchr>
     57b:	85 c0                	test   %eax,%eax
     57d:	75 d7                	jne    556 <gettoken+0x10>
    s++;
  if(q)
     57f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     583:	74 08                	je     58d <gettoken+0x47>
    *q = s;
     585:	8b 45 10             	mov    0x10(%ebp),%eax
     588:	8b 55 f4             	mov    -0xc(%ebp),%edx
     58b:	89 10                	mov    %edx,(%eax)
  ret = *s;
     58d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     590:	0f b6 00             	movzbl (%eax),%eax
     593:	0f be c0             	movsbl %al,%eax
     596:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     599:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59c:	0f b6 00             	movzbl (%eax),%eax
     59f:	0f be c0             	movsbl %al,%eax
     5a2:	83 f8 29             	cmp    $0x29,%eax
     5a5:	7f 14                	jg     5bb <gettoken+0x75>
     5a7:	83 f8 28             	cmp    $0x28,%eax
     5aa:	7d 28                	jge    5d4 <gettoken+0x8e>
     5ac:	85 c0                	test   %eax,%eax
     5ae:	0f 84 94 00 00 00    	je     648 <gettoken+0x102>
     5b4:	83 f8 26             	cmp    $0x26,%eax
     5b7:	74 1b                	je     5d4 <gettoken+0x8e>
     5b9:	eb 3c                	jmp    5f7 <gettoken+0xb1>
     5bb:	83 f8 3e             	cmp    $0x3e,%eax
     5be:	74 1a                	je     5da <gettoken+0x94>
     5c0:	83 f8 3e             	cmp    $0x3e,%eax
     5c3:	7f 0a                	jg     5cf <gettoken+0x89>
     5c5:	83 e8 3b             	sub    $0x3b,%eax
     5c8:	83 f8 01             	cmp    $0x1,%eax
     5cb:	77 2a                	ja     5f7 <gettoken+0xb1>
     5cd:	eb 05                	jmp    5d4 <gettoken+0x8e>
     5cf:	83 f8 7c             	cmp    $0x7c,%eax
     5d2:	75 23                	jne    5f7 <gettoken+0xb1>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5d8:	eb 6f                	jmp    649 <gettoken+0x103>
  case '>':
    s++;
     5da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5de:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5e1:	0f b6 00             	movzbl (%eax),%eax
     5e4:	3c 3e                	cmp    $0x3e,%al
     5e6:	75 0d                	jne    5f5 <gettoken+0xaf>
      ret = '+';
     5e8:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     5f3:	eb 54                	jmp    649 <gettoken+0x103>
     5f5:	eb 52                	jmp    649 <gettoken+0x103>
  default:
    ret = 'a';
     5f7:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5fe:	eb 04                	jmp    604 <gettoken+0xbe>
      s++;
     600:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     604:	8b 45 f4             	mov    -0xc(%ebp),%eax
     607:	3b 45 0c             	cmp    0xc(%ebp),%eax
     60a:	73 3a                	jae    646 <gettoken+0x100>
     60c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     60f:	0f b6 00             	movzbl (%eax),%eax
     612:	0f be c0             	movsbl %al,%eax
     615:	89 44 24 04          	mov    %eax,0x4(%esp)
     619:	c7 04 24 98 1a 00 00 	movl   $0x1a98,(%esp)
     620:	e8 c7 07 00 00       	call   dec <strchr>
     625:	85 c0                	test   %eax,%eax
     627:	75 1d                	jne    646 <gettoken+0x100>
     629:	8b 45 f4             	mov    -0xc(%ebp),%eax
     62c:	0f b6 00             	movzbl (%eax),%eax
     62f:	0f be c0             	movsbl %al,%eax
     632:	89 44 24 04          	mov    %eax,0x4(%esp)
     636:	c7 04 24 9e 1a 00 00 	movl   $0x1a9e,(%esp)
     63d:	e8 aa 07 00 00       	call   dec <strchr>
     642:	85 c0                	test   %eax,%eax
     644:	74 ba                	je     600 <gettoken+0xba>
      s++;
    break;
     646:	eb 01                	jmp    649 <gettoken+0x103>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     648:	90                   	nop
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     649:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     64d:	74 0a                	je     659 <gettoken+0x113>
    *eq = s;
     64f:	8b 45 14             	mov    0x14(%ebp),%eax
     652:	8b 55 f4             	mov    -0xc(%ebp),%edx
     655:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     657:	eb 06                	jmp    65f <gettoken+0x119>
     659:	eb 04                	jmp    65f <gettoken+0x119>
    s++;
     65b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     65f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     662:	3b 45 0c             	cmp    0xc(%ebp),%eax
     665:	73 1d                	jae    684 <gettoken+0x13e>
     667:	8b 45 f4             	mov    -0xc(%ebp),%eax
     66a:	0f b6 00             	movzbl (%eax),%eax
     66d:	0f be c0             	movsbl %al,%eax
     670:	89 44 24 04          	mov    %eax,0x4(%esp)
     674:	c7 04 24 98 1a 00 00 	movl   $0x1a98,(%esp)
     67b:	e8 6c 07 00 00       	call   dec <strchr>
     680:	85 c0                	test   %eax,%eax
     682:	75 d7                	jne    65b <gettoken+0x115>
    s++;
  *ps = s;
     684:	8b 45 08             	mov    0x8(%ebp),%eax
     687:	8b 55 f4             	mov    -0xc(%ebp),%edx
     68a:	89 10                	mov    %edx,(%eax)
  return ret;
     68c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     68f:	c9                   	leave  
     690:	c3                   	ret    

00000691 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     691:	55                   	push   %ebp
     692:	89 e5                	mov    %esp,%ebp
     694:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     697:	8b 45 08             	mov    0x8(%ebp),%eax
     69a:	8b 00                	mov    (%eax),%eax
     69c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     69f:	eb 04                	jmp    6a5 <peek+0x14>
    s++;
     6a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6ab:	73 1d                	jae    6ca <peek+0x39>
     6ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6b0:	0f b6 00             	movzbl (%eax),%eax
     6b3:	0f be c0             	movsbl %al,%eax
     6b6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ba:	c7 04 24 98 1a 00 00 	movl   $0x1a98,(%esp)
     6c1:	e8 26 07 00 00       	call   dec <strchr>
     6c6:	85 c0                	test   %eax,%eax
     6c8:	75 d7                	jne    6a1 <peek+0x10>
    s++;
  *ps = s;
     6ca:	8b 45 08             	mov    0x8(%ebp),%eax
     6cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6d0:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6d5:	0f b6 00             	movzbl (%eax),%eax
     6d8:	84 c0                	test   %al,%al
     6da:	74 23                	je     6ff <peek+0x6e>
     6dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6df:	0f b6 00             	movzbl (%eax),%eax
     6e2:	0f be c0             	movsbl %al,%eax
     6e5:	89 44 24 04          	mov    %eax,0x4(%esp)
     6e9:	8b 45 10             	mov    0x10(%ebp),%eax
     6ec:	89 04 24             	mov    %eax,(%esp)
     6ef:	e8 f8 06 00 00       	call   dec <strchr>
     6f4:	85 c0                	test   %eax,%eax
     6f6:	74 07                	je     6ff <peek+0x6e>
     6f8:	b8 01 00 00 00       	mov    $0x1,%eax
     6fd:	eb 05                	jmp    704 <peek+0x73>
     6ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
     704:	c9                   	leave  
     705:	c3                   	ret    

00000706 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     706:	55                   	push   %ebp
     707:	89 e5                	mov    %esp,%ebp
     709:	53                   	push   %ebx
     70a:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     70d:	8b 5d 08             	mov    0x8(%ebp),%ebx
     710:	8b 45 08             	mov    0x8(%ebp),%eax
     713:	89 04 24             	mov    %eax,(%esp)
     716:	e8 86 06 00 00       	call   da1 <strlen>
     71b:	01 d8                	add    %ebx,%eax
     71d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     720:	8b 45 f4             	mov    -0xc(%ebp),%eax
     723:	89 44 24 04          	mov    %eax,0x4(%esp)
     727:	8d 45 08             	lea    0x8(%ebp),%eax
     72a:	89 04 24             	mov    %eax,(%esp)
     72d:	e8 60 00 00 00       	call   792 <parseline>
     732:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     735:	c7 44 24 08 86 15 00 	movl   $0x1586,0x8(%esp)
     73c:	00 
     73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     740:	89 44 24 04          	mov    %eax,0x4(%esp)
     744:	8d 45 08             	lea    0x8(%ebp),%eax
     747:	89 04 24             	mov    %eax,(%esp)
     74a:	e8 42 ff ff ff       	call   691 <peek>
  if(s != es){
     74f:	8b 45 08             	mov    0x8(%ebp),%eax
     752:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     755:	74 27                	je     77e <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     757:	8b 45 08             	mov    0x8(%ebp),%eax
     75a:	89 44 24 08          	mov    %eax,0x8(%esp)
     75e:	c7 44 24 04 87 15 00 	movl   $0x1587,0x4(%esp)
     765:	00 
     766:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     76d:	e8 b3 09 00 00       	call   1125 <printf>
    panic("syntax");
     772:	c7 04 24 96 15 00 00 	movl   $0x1596,(%esp)
     779:	e8 ed fb ff ff       	call   36b <panic>
  }
  nulterminate(cmd);
     77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     781:	89 04 24             	mov    %eax,(%esp)
     784:	e8 a3 04 00 00       	call   c2c <nulterminate>
  return cmd;
     789:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     78c:	83 c4 24             	add    $0x24,%esp
     78f:	5b                   	pop    %ebx
     790:	5d                   	pop    %ebp
     791:	c3                   	ret    

00000792 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     792:	55                   	push   %ebp
     793:	89 e5                	mov    %esp,%ebp
     795:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     798:	8b 45 0c             	mov    0xc(%ebp),%eax
     79b:	89 44 24 04          	mov    %eax,0x4(%esp)
     79f:	8b 45 08             	mov    0x8(%ebp),%eax
     7a2:	89 04 24             	mov    %eax,(%esp)
     7a5:	e8 bc 00 00 00       	call   866 <parsepipe>
     7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7ad:	eb 30                	jmp    7df <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7b6:	00 
     7b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7be:	00 
     7bf:	8b 45 0c             	mov    0xc(%ebp),%eax
     7c2:	89 44 24 04          	mov    %eax,0x4(%esp)
     7c6:	8b 45 08             	mov    0x8(%ebp),%eax
     7c9:	89 04 24             	mov    %eax,(%esp)
     7cc:	e8 75 fd ff ff       	call   546 <gettoken>
    cmd = backcmd(cmd);
     7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7d4:	89 04 24             	mov    %eax,(%esp)
     7d7:	e8 23 fd ff ff       	call   4ff <backcmd>
     7dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7df:	c7 44 24 08 9d 15 00 	movl   $0x159d,0x8(%esp)
     7e6:	00 
     7e7:	8b 45 0c             	mov    0xc(%ebp),%eax
     7ea:	89 44 24 04          	mov    %eax,0x4(%esp)
     7ee:	8b 45 08             	mov    0x8(%ebp),%eax
     7f1:	89 04 24             	mov    %eax,(%esp)
     7f4:	e8 98 fe ff ff       	call   691 <peek>
     7f9:	85 c0                	test   %eax,%eax
     7fb:	75 b2                	jne    7af <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7fd:	c7 44 24 08 9f 15 00 	movl   $0x159f,0x8(%esp)
     804:	00 
     805:	8b 45 0c             	mov    0xc(%ebp),%eax
     808:	89 44 24 04          	mov    %eax,0x4(%esp)
     80c:	8b 45 08             	mov    0x8(%ebp),%eax
     80f:	89 04 24             	mov    %eax,(%esp)
     812:	e8 7a fe ff ff       	call   691 <peek>
     817:	85 c0                	test   %eax,%eax
     819:	74 46                	je     861 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     81b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     822:	00 
     823:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     82a:	00 
     82b:	8b 45 0c             	mov    0xc(%ebp),%eax
     82e:	89 44 24 04          	mov    %eax,0x4(%esp)
     832:	8b 45 08             	mov    0x8(%ebp),%eax
     835:	89 04 24             	mov    %eax,(%esp)
     838:	e8 09 fd ff ff       	call   546 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     83d:	8b 45 0c             	mov    0xc(%ebp),%eax
     840:	89 44 24 04          	mov    %eax,0x4(%esp)
     844:	8b 45 08             	mov    0x8(%ebp),%eax
     847:	89 04 24             	mov    %eax,(%esp)
     84a:	e8 43 ff ff ff       	call   792 <parseline>
     84f:	89 44 24 04          	mov    %eax,0x4(%esp)
     853:	8b 45 f4             	mov    -0xc(%ebp),%eax
     856:	89 04 24             	mov    %eax,(%esp)
     859:	e8 51 fc ff ff       	call   4af <listcmd>
     85e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     861:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     864:	c9                   	leave  
     865:	c3                   	ret    

00000866 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     866:	55                   	push   %ebp
     867:	89 e5                	mov    %esp,%ebp
     869:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     86c:	8b 45 0c             	mov    0xc(%ebp),%eax
     86f:	89 44 24 04          	mov    %eax,0x4(%esp)
     873:	8b 45 08             	mov    0x8(%ebp),%eax
     876:	89 04 24             	mov    %eax,(%esp)
     879:	e8 68 02 00 00       	call   ae6 <parseexec>
     87e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     881:	c7 44 24 08 a1 15 00 	movl   $0x15a1,0x8(%esp)
     888:	00 
     889:	8b 45 0c             	mov    0xc(%ebp),%eax
     88c:	89 44 24 04          	mov    %eax,0x4(%esp)
     890:	8b 45 08             	mov    0x8(%ebp),%eax
     893:	89 04 24             	mov    %eax,(%esp)
     896:	e8 f6 fd ff ff       	call   691 <peek>
     89b:	85 c0                	test   %eax,%eax
     89d:	74 46                	je     8e5 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     89f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8a6:	00 
     8a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8ae:	00 
     8af:	8b 45 0c             	mov    0xc(%ebp),%eax
     8b2:	89 44 24 04          	mov    %eax,0x4(%esp)
     8b6:	8b 45 08             	mov    0x8(%ebp),%eax
     8b9:	89 04 24             	mov    %eax,(%esp)
     8bc:	e8 85 fc ff ff       	call   546 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8c1:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c4:	89 44 24 04          	mov    %eax,0x4(%esp)
     8c8:	8b 45 08             	mov    0x8(%ebp),%eax
     8cb:	89 04 24             	mov    %eax,(%esp)
     8ce:	e8 93 ff ff ff       	call   866 <parsepipe>
     8d3:	89 44 24 04          	mov    %eax,0x4(%esp)
     8d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8da:	89 04 24             	mov    %eax,(%esp)
     8dd:	e8 7d fb ff ff       	call   45f <pipecmd>
     8e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8e8:	c9                   	leave  
     8e9:	c3                   	ret    

000008ea <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8ea:	55                   	push   %ebp
     8eb:	89 e5                	mov    %esp,%ebp
     8ed:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8f0:	e9 f6 00 00 00       	jmp    9eb <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     8f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8fc:	00 
     8fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     904:	00 
     905:	8b 45 10             	mov    0x10(%ebp),%eax
     908:	89 44 24 04          	mov    %eax,0x4(%esp)
     90c:	8b 45 0c             	mov    0xc(%ebp),%eax
     90f:	89 04 24             	mov    %eax,(%esp)
     912:	e8 2f fc ff ff       	call   546 <gettoken>
     917:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     91a:	8d 45 ec             	lea    -0x14(%ebp),%eax
     91d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     921:	8d 45 f0             	lea    -0x10(%ebp),%eax
     924:	89 44 24 08          	mov    %eax,0x8(%esp)
     928:	8b 45 10             	mov    0x10(%ebp),%eax
     92b:	89 44 24 04          	mov    %eax,0x4(%esp)
     92f:	8b 45 0c             	mov    0xc(%ebp),%eax
     932:	89 04 24             	mov    %eax,(%esp)
     935:	e8 0c fc ff ff       	call   546 <gettoken>
     93a:	83 f8 61             	cmp    $0x61,%eax
     93d:	74 0c                	je     94b <parseredirs+0x61>
      panic("missing file for redirection");
     93f:	c7 04 24 a3 15 00 00 	movl   $0x15a3,(%esp)
     946:	e8 20 fa ff ff       	call   36b <panic>
    switch(tok){
     94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     94e:	83 f8 3c             	cmp    $0x3c,%eax
     951:	74 0f                	je     962 <parseredirs+0x78>
     953:	83 f8 3e             	cmp    $0x3e,%eax
     956:	74 38                	je     990 <parseredirs+0xa6>
     958:	83 f8 2b             	cmp    $0x2b,%eax
     95b:	74 61                	je     9be <parseredirs+0xd4>
     95d:	e9 89 00 00 00       	jmp    9eb <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     962:	8b 55 ec             	mov    -0x14(%ebp),%edx
     965:	8b 45 f0             	mov    -0x10(%ebp),%eax
     968:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     96f:	00 
     970:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     977:	00 
     978:	89 54 24 08          	mov    %edx,0x8(%esp)
     97c:	89 44 24 04          	mov    %eax,0x4(%esp)
     980:	8b 45 08             	mov    0x8(%ebp),%eax
     983:	89 04 24             	mov    %eax,(%esp)
     986:	e8 69 fa ff ff       	call   3f4 <redircmd>
     98b:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     98e:	eb 5b                	jmp    9eb <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     990:	8b 55 ec             	mov    -0x14(%ebp),%edx
     993:	8b 45 f0             	mov    -0x10(%ebp),%eax
     996:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     99d:	00 
     99e:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9a5:	00 
     9a6:	89 54 24 08          	mov    %edx,0x8(%esp)
     9aa:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ae:	8b 45 08             	mov    0x8(%ebp),%eax
     9b1:	89 04 24             	mov    %eax,(%esp)
     9b4:	e8 3b fa ff ff       	call   3f4 <redircmd>
     9b9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9bc:	eb 2d                	jmp    9eb <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9be:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9c4:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9cb:	00 
     9cc:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9d3:	00 
     9d4:	89 54 24 08          	mov    %edx,0x8(%esp)
     9d8:	89 44 24 04          	mov    %eax,0x4(%esp)
     9dc:	8b 45 08             	mov    0x8(%ebp),%eax
     9df:	89 04 24             	mov    %eax,(%esp)
     9e2:	e8 0d fa ff ff       	call   3f4 <redircmd>
     9e7:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9ea:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9eb:	c7 44 24 08 c0 15 00 	movl   $0x15c0,0x8(%esp)
     9f2:	00 
     9f3:	8b 45 10             	mov    0x10(%ebp),%eax
     9f6:	89 44 24 04          	mov    %eax,0x4(%esp)
     9fa:	8b 45 0c             	mov    0xc(%ebp),%eax
     9fd:	89 04 24             	mov    %eax,(%esp)
     a00:	e8 8c fc ff ff       	call   691 <peek>
     a05:	85 c0                	test   %eax,%eax
     a07:	0f 85 e8 fe ff ff    	jne    8f5 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a0d:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a10:	c9                   	leave  
     a11:	c3                   	ret    

00000a12 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a12:	55                   	push   %ebp
     a13:	89 e5                	mov    %esp,%ebp
     a15:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a18:	c7 44 24 08 c3 15 00 	movl   $0x15c3,0x8(%esp)
     a1f:	00 
     a20:	8b 45 0c             	mov    0xc(%ebp),%eax
     a23:	89 44 24 04          	mov    %eax,0x4(%esp)
     a27:	8b 45 08             	mov    0x8(%ebp),%eax
     a2a:	89 04 24             	mov    %eax,(%esp)
     a2d:	e8 5f fc ff ff       	call   691 <peek>
     a32:	85 c0                	test   %eax,%eax
     a34:	75 0c                	jne    a42 <parseblock+0x30>
    panic("parseblock");
     a36:	c7 04 24 c5 15 00 00 	movl   $0x15c5,(%esp)
     a3d:	e8 29 f9 ff ff       	call   36b <panic>
  gettoken(ps, es, 0, 0);
     a42:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a49:	00 
     a4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a51:	00 
     a52:	8b 45 0c             	mov    0xc(%ebp),%eax
     a55:	89 44 24 04          	mov    %eax,0x4(%esp)
     a59:	8b 45 08             	mov    0x8(%ebp),%eax
     a5c:	89 04 24             	mov    %eax,(%esp)
     a5f:	e8 e2 fa ff ff       	call   546 <gettoken>
  cmd = parseline(ps, es);
     a64:	8b 45 0c             	mov    0xc(%ebp),%eax
     a67:	89 44 24 04          	mov    %eax,0x4(%esp)
     a6b:	8b 45 08             	mov    0x8(%ebp),%eax
     a6e:	89 04 24             	mov    %eax,(%esp)
     a71:	e8 1c fd ff ff       	call   792 <parseline>
     a76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a79:	c7 44 24 08 d0 15 00 	movl   $0x15d0,0x8(%esp)
     a80:	00 
     a81:	8b 45 0c             	mov    0xc(%ebp),%eax
     a84:	89 44 24 04          	mov    %eax,0x4(%esp)
     a88:	8b 45 08             	mov    0x8(%ebp),%eax
     a8b:	89 04 24             	mov    %eax,(%esp)
     a8e:	e8 fe fb ff ff       	call   691 <peek>
     a93:	85 c0                	test   %eax,%eax
     a95:	75 0c                	jne    aa3 <parseblock+0x91>
    panic("syntax - missing )");
     a97:	c7 04 24 d2 15 00 00 	movl   $0x15d2,(%esp)
     a9e:	e8 c8 f8 ff ff       	call   36b <panic>
  gettoken(ps, es, 0, 0);
     aa3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     aaa:	00 
     aab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ab2:	00 
     ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
     ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
     aba:	8b 45 08             	mov    0x8(%ebp),%eax
     abd:	89 04 24             	mov    %eax,(%esp)
     ac0:	e8 81 fa ff ff       	call   546 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
     ac8:	89 44 24 08          	mov    %eax,0x8(%esp)
     acc:	8b 45 08             	mov    0x8(%ebp),%eax
     acf:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ad6:	89 04 24             	mov    %eax,(%esp)
     ad9:	e8 0c fe ff ff       	call   8ea <parseredirs>
     ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     ae4:	c9                   	leave  
     ae5:	c3                   	ret    

00000ae6 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     ae6:	55                   	push   %ebp
     ae7:	89 e5                	mov    %esp,%ebp
     ae9:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     aec:	c7 44 24 08 c3 15 00 	movl   $0x15c3,0x8(%esp)
     af3:	00 
     af4:	8b 45 0c             	mov    0xc(%ebp),%eax
     af7:	89 44 24 04          	mov    %eax,0x4(%esp)
     afb:	8b 45 08             	mov    0x8(%ebp),%eax
     afe:	89 04 24             	mov    %eax,(%esp)
     b01:	e8 8b fb ff ff       	call   691 <peek>
     b06:	85 c0                	test   %eax,%eax
     b08:	74 17                	je     b21 <parseexec+0x3b>
    return parseblock(ps, es);
     b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
     b11:	8b 45 08             	mov    0x8(%ebp),%eax
     b14:	89 04 24             	mov    %eax,(%esp)
     b17:	e8 f6 fe ff ff       	call   a12 <parseblock>
     b1c:	e9 09 01 00 00       	jmp    c2a <parseexec+0x144>

  ret = execcmd();
     b21:	e8 90 f8 ff ff       	call   3b6 <execcmd>
     b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b2c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b36:	8b 45 0c             	mov    0xc(%ebp),%eax
     b39:	89 44 24 08          	mov    %eax,0x8(%esp)
     b3d:	8b 45 08             	mov    0x8(%ebp),%eax
     b40:	89 44 24 04          	mov    %eax,0x4(%esp)
     b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b47:	89 04 24             	mov    %eax,(%esp)
     b4a:	e8 9b fd ff ff       	call   8ea <parseredirs>
     b4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b52:	e9 8f 00 00 00       	jmp    be6 <parseexec+0x100>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b57:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b61:	89 44 24 08          	mov    %eax,0x8(%esp)
     b65:	8b 45 0c             	mov    0xc(%ebp),%eax
     b68:	89 44 24 04          	mov    %eax,0x4(%esp)
     b6c:	8b 45 08             	mov    0x8(%ebp),%eax
     b6f:	89 04 24             	mov    %eax,(%esp)
     b72:	e8 cf f9 ff ff       	call   546 <gettoken>
     b77:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b7a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b7e:	75 05                	jne    b85 <parseexec+0x9f>
      break;
     b80:	e9 83 00 00 00       	jmp    c08 <parseexec+0x122>
    if(tok != 'a')
     b85:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b89:	74 0c                	je     b97 <parseexec+0xb1>
      panic("syntax");
     b8b:	c7 04 24 96 15 00 00 	movl   $0x1596,(%esp)
     b92:	e8 d4 f7 ff ff       	call   36b <panic>
    cmd->argv[argc] = q;
     b97:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ba0:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     ba4:	8b 55 e0             	mov    -0x20(%ebp),%edx
     ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     baa:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bad:	83 c1 08             	add    $0x8,%ecx
     bb0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     bb4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     bb8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bbc:	7e 0c                	jle    bca <parseexec+0xe4>
      panic("too many args");
     bbe:	c7 04 24 e5 15 00 00 	movl   $0x15e5,(%esp)
     bc5:	e8 a1 f7 ff ff       	call   36b <panic>
    ret = parseredirs(ret, ps, es);
     bca:	8b 45 0c             	mov    0xc(%ebp),%eax
     bcd:	89 44 24 08          	mov    %eax,0x8(%esp)
     bd1:	8b 45 08             	mov    0x8(%ebp),%eax
     bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
     bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bdb:	89 04 24             	mov    %eax,(%esp)
     bde:	e8 07 fd ff ff       	call   8ea <parseredirs>
     be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     be6:	c7 44 24 08 f3 15 00 	movl   $0x15f3,0x8(%esp)
     bed:	00 
     bee:	8b 45 0c             	mov    0xc(%ebp),%eax
     bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
     bf5:	8b 45 08             	mov    0x8(%ebp),%eax
     bf8:	89 04 24             	mov    %eax,(%esp)
     bfb:	e8 91 fa ff ff       	call   691 <peek>
     c00:	85 c0                	test   %eax,%eax
     c02:	0f 84 4f ff ff ff    	je     b57 <parseexec+0x71>
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c0e:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c15:	00 
  cmd->eargv[argc] = 0;
     c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c1c:	83 c2 08             	add    $0x8,%edx
     c1f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c26:	00 
  return ret;
     c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c2a:	c9                   	leave  
     c2b:	c3                   	ret    

00000c2c <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c2c:	55                   	push   %ebp
     c2d:	89 e5                	mov    %esp,%ebp
     c2f:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c36:	75 0a                	jne    c42 <nulterminate+0x16>
    return 0;
     c38:	b8 00 00 00 00       	mov    $0x0,%eax
     c3d:	e9 c9 00 00 00       	jmp    d0b <nulterminate+0xdf>
  
  switch(cmd->type){
     c42:	8b 45 08             	mov    0x8(%ebp),%eax
     c45:	8b 00                	mov    (%eax),%eax
     c47:	83 f8 05             	cmp    $0x5,%eax
     c4a:	0f 87 b8 00 00 00    	ja     d08 <nulterminate+0xdc>
     c50:	8b 04 85 f8 15 00 00 	mov    0x15f8(,%eax,4),%eax
     c57:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c59:	8b 45 08             	mov    0x8(%ebp),%eax
     c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c66:	eb 14                	jmp    c7c <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c6e:	83 c2 08             	add    $0x8,%edx
     c71:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c75:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c82:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c86:	85 c0                	test   %eax,%eax
     c88:	75 de                	jne    c68 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     c8a:	eb 7c                	jmp    d08 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     c8c:	8b 45 08             	mov    0x8(%ebp),%eax
     c8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     c92:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c95:	8b 40 04             	mov    0x4(%eax),%eax
     c98:	89 04 24             	mov    %eax,(%esp)
     c9b:	e8 8c ff ff ff       	call   c2c <nulterminate>
    *rcmd->efile = 0;
     ca0:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ca3:	8b 40 0c             	mov    0xc(%eax),%eax
     ca6:	c6 00 00             	movb   $0x0,(%eax)
    break;
     ca9:	eb 5d                	jmp    d08 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     cab:	8b 45 08             	mov    0x8(%ebp),%eax
     cae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     cb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cb4:	8b 40 04             	mov    0x4(%eax),%eax
     cb7:	89 04 24             	mov    %eax,(%esp)
     cba:	e8 6d ff ff ff       	call   c2c <nulterminate>
    nulterminate(pcmd->right);
     cbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cc2:	8b 40 08             	mov    0x8(%eax),%eax
     cc5:	89 04 24             	mov    %eax,(%esp)
     cc8:	e8 5f ff ff ff       	call   c2c <nulterminate>
    break;
     ccd:	eb 39                	jmp    d08 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     ccf:	8b 45 08             	mov    0x8(%ebp),%eax
     cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cd8:	8b 40 04             	mov    0x4(%eax),%eax
     cdb:	89 04 24             	mov    %eax,(%esp)
     cde:	e8 49 ff ff ff       	call   c2c <nulterminate>
    nulterminate(lcmd->right);
     ce3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ce6:	8b 40 08             	mov    0x8(%eax),%eax
     ce9:	89 04 24             	mov    %eax,(%esp)
     cec:	e8 3b ff ff ff       	call   c2c <nulterminate>
    break;
     cf1:	eb 15                	jmp    d08 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     cf3:	8b 45 08             	mov    0x8(%ebp),%eax
     cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
     cfc:	8b 40 04             	mov    0x4(%eax),%eax
     cff:	89 04 24             	mov    %eax,(%esp)
     d02:	e8 25 ff ff ff       	call   c2c <nulterminate>
    break;
     d07:	90                   	nop
  }
  return cmd;
     d08:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d0b:	c9                   	leave  
     d0c:	c3                   	ret    

00000d0d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d0d:	55                   	push   %ebp
     d0e:	89 e5                	mov    %esp,%ebp
     d10:	57                   	push   %edi
     d11:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d15:	8b 55 10             	mov    0x10(%ebp),%edx
     d18:	8b 45 0c             	mov    0xc(%ebp),%eax
     d1b:	89 cb                	mov    %ecx,%ebx
     d1d:	89 df                	mov    %ebx,%edi
     d1f:	89 d1                	mov    %edx,%ecx
     d21:	fc                   	cld    
     d22:	f3 aa                	rep stos %al,%es:(%edi)
     d24:	89 ca                	mov    %ecx,%edx
     d26:	89 fb                	mov    %edi,%ebx
     d28:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d2b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d2e:	5b                   	pop    %ebx
     d2f:	5f                   	pop    %edi
     d30:	5d                   	pop    %ebp
     d31:	c3                   	ret    

00000d32 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d32:	55                   	push   %ebp
     d33:	89 e5                	mov    %esp,%ebp
     d35:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d38:	8b 45 08             	mov    0x8(%ebp),%eax
     d3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d3e:	90                   	nop
     d3f:	8b 45 08             	mov    0x8(%ebp),%eax
     d42:	8d 50 01             	lea    0x1(%eax),%edx
     d45:	89 55 08             	mov    %edx,0x8(%ebp)
     d48:	8b 55 0c             	mov    0xc(%ebp),%edx
     d4b:	8d 4a 01             	lea    0x1(%edx),%ecx
     d4e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     d51:	0f b6 12             	movzbl (%edx),%edx
     d54:	88 10                	mov    %dl,(%eax)
     d56:	0f b6 00             	movzbl (%eax),%eax
     d59:	84 c0                	test   %al,%al
     d5b:	75 e2                	jne    d3f <strcpy+0xd>
    ;
  return os;
     d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d60:	c9                   	leave  
     d61:	c3                   	ret    

00000d62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d62:	55                   	push   %ebp
     d63:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d65:	eb 08                	jmp    d6f <strcmp+0xd>
    p++, q++;
     d67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d6b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d6f:	8b 45 08             	mov    0x8(%ebp),%eax
     d72:	0f b6 00             	movzbl (%eax),%eax
     d75:	84 c0                	test   %al,%al
     d77:	74 10                	je     d89 <strcmp+0x27>
     d79:	8b 45 08             	mov    0x8(%ebp),%eax
     d7c:	0f b6 10             	movzbl (%eax),%edx
     d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d82:	0f b6 00             	movzbl (%eax),%eax
     d85:	38 c2                	cmp    %al,%dl
     d87:	74 de                	je     d67 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     d89:	8b 45 08             	mov    0x8(%ebp),%eax
     d8c:	0f b6 00             	movzbl (%eax),%eax
     d8f:	0f b6 d0             	movzbl %al,%edx
     d92:	8b 45 0c             	mov    0xc(%ebp),%eax
     d95:	0f b6 00             	movzbl (%eax),%eax
     d98:	0f b6 c0             	movzbl %al,%eax
     d9b:	29 c2                	sub    %eax,%edx
     d9d:	89 d0                	mov    %edx,%eax
}
     d9f:	5d                   	pop    %ebp
     da0:	c3                   	ret    

00000da1 <strlen>:

uint
strlen(char *s)
{
     da1:	55                   	push   %ebp
     da2:	89 e5                	mov    %esp,%ebp
     da4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     da7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     dae:	eb 04                	jmp    db4 <strlen+0x13>
     db0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     db4:	8b 55 fc             	mov    -0x4(%ebp),%edx
     db7:	8b 45 08             	mov    0x8(%ebp),%eax
     dba:	01 d0                	add    %edx,%eax
     dbc:	0f b6 00             	movzbl (%eax),%eax
     dbf:	84 c0                	test   %al,%al
     dc1:	75 ed                	jne    db0 <strlen+0xf>
    ;
  return n;
     dc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dc6:	c9                   	leave  
     dc7:	c3                   	ret    

00000dc8 <memset>:

void*
memset(void *dst, int c, uint n)
{
     dc8:	55                   	push   %ebp
     dc9:	89 e5                	mov    %esp,%ebp
     dcb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     dce:	8b 45 10             	mov    0x10(%ebp),%eax
     dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
     dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
     dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
     ddc:	8b 45 08             	mov    0x8(%ebp),%eax
     ddf:	89 04 24             	mov    %eax,(%esp)
     de2:	e8 26 ff ff ff       	call   d0d <stosb>
  return dst;
     de7:	8b 45 08             	mov    0x8(%ebp),%eax
}
     dea:	c9                   	leave  
     deb:	c3                   	ret    

00000dec <strchr>:

char*
strchr(const char *s, char c)
{
     dec:	55                   	push   %ebp
     ded:	89 e5                	mov    %esp,%ebp
     def:	83 ec 04             	sub    $0x4,%esp
     df2:	8b 45 0c             	mov    0xc(%ebp),%eax
     df5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     df8:	eb 14                	jmp    e0e <strchr+0x22>
    if(*s == c)
     dfa:	8b 45 08             	mov    0x8(%ebp),%eax
     dfd:	0f b6 00             	movzbl (%eax),%eax
     e00:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e03:	75 05                	jne    e0a <strchr+0x1e>
      return (char*)s;
     e05:	8b 45 08             	mov    0x8(%ebp),%eax
     e08:	eb 13                	jmp    e1d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e0e:	8b 45 08             	mov    0x8(%ebp),%eax
     e11:	0f b6 00             	movzbl (%eax),%eax
     e14:	84 c0                	test   %al,%al
     e16:	75 e2                	jne    dfa <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e18:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e1d:	c9                   	leave  
     e1e:	c3                   	ret    

00000e1f <gets>:

char*
gets(char *buf, int max)
{
     e1f:	55                   	push   %ebp
     e20:	89 e5                	mov    %esp,%ebp
     e22:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e2c:	eb 4c                	jmp    e7a <gets+0x5b>
    cc = read(0, &c, 1);
     e2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e35:	00 
     e36:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e39:	89 44 24 04          	mov    %eax,0x4(%esp)
     e3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e44:	e8 44 01 00 00       	call   f8d <read>
     e49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e50:	7f 02                	jg     e54 <gets+0x35>
      break;
     e52:	eb 31                	jmp    e85 <gets+0x66>
    buf[i++] = c;
     e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e57:	8d 50 01             	lea    0x1(%eax),%edx
     e5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e5d:	89 c2                	mov    %eax,%edx
     e5f:	8b 45 08             	mov    0x8(%ebp),%eax
     e62:	01 c2                	add    %eax,%edx
     e64:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e68:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     e6a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e6e:	3c 0a                	cmp    $0xa,%al
     e70:	74 13                	je     e85 <gets+0x66>
     e72:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e76:	3c 0d                	cmp    $0xd,%al
     e78:	74 0b                	je     e85 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e7d:	83 c0 01             	add    $0x1,%eax
     e80:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e83:	7c a9                	jl     e2e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e88:	8b 45 08             	mov    0x8(%ebp),%eax
     e8b:	01 d0                	add    %edx,%eax
     e8d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     e90:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e93:	c9                   	leave  
     e94:	c3                   	ret    

00000e95 <stat>:

int
stat(char *n, struct stat *st)
{
     e95:	55                   	push   %ebp
     e96:	89 e5                	mov    %esp,%ebp
     e98:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     ea2:	00 
     ea3:	8b 45 08             	mov    0x8(%ebp),%eax
     ea6:	89 04 24             	mov    %eax,(%esp)
     ea9:	e8 07 01 00 00       	call   fb5 <open>
     eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     eb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     eb5:	79 07                	jns    ebe <stat+0x29>
    return -1;
     eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ebc:	eb 23                	jmp    ee1 <stat+0x4c>
  r = fstat(fd, st);
     ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
     ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
     ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ec8:	89 04 24             	mov    %eax,(%esp)
     ecb:	e8 fd 00 00 00       	call   fcd <fstat>
     ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ed6:	89 04 24             	mov    %eax,(%esp)
     ed9:	e8 bf 00 00 00       	call   f9d <close>
  return r;
     ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ee1:	c9                   	leave  
     ee2:	c3                   	ret    

00000ee3 <atoi>:

int
atoi(const char *s)
{
     ee3:	55                   	push   %ebp
     ee4:	89 e5                	mov    %esp,%ebp
     ee6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     ee9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     ef0:	eb 25                	jmp    f17 <atoi+0x34>
    n = n*10 + *s++ - '0';
     ef2:	8b 55 fc             	mov    -0x4(%ebp),%edx
     ef5:	89 d0                	mov    %edx,%eax
     ef7:	c1 e0 02             	shl    $0x2,%eax
     efa:	01 d0                	add    %edx,%eax
     efc:	01 c0                	add    %eax,%eax
     efe:	89 c1                	mov    %eax,%ecx
     f00:	8b 45 08             	mov    0x8(%ebp),%eax
     f03:	8d 50 01             	lea    0x1(%eax),%edx
     f06:	89 55 08             	mov    %edx,0x8(%ebp)
     f09:	0f b6 00             	movzbl (%eax),%eax
     f0c:	0f be c0             	movsbl %al,%eax
     f0f:	01 c8                	add    %ecx,%eax
     f11:	83 e8 30             	sub    $0x30,%eax
     f14:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f17:	8b 45 08             	mov    0x8(%ebp),%eax
     f1a:	0f b6 00             	movzbl (%eax),%eax
     f1d:	3c 2f                	cmp    $0x2f,%al
     f1f:	7e 0a                	jle    f2b <atoi+0x48>
     f21:	8b 45 08             	mov    0x8(%ebp),%eax
     f24:	0f b6 00             	movzbl (%eax),%eax
     f27:	3c 39                	cmp    $0x39,%al
     f29:	7e c7                	jle    ef2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f2e:	c9                   	leave  
     f2f:	c3                   	ret    

00000f30 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f30:	55                   	push   %ebp
     f31:	89 e5                	mov    %esp,%ebp
     f33:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f36:	8b 45 08             	mov    0x8(%ebp),%eax
     f39:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
     f3f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f42:	eb 17                	jmp    f5b <memmove+0x2b>
    *dst++ = *src++;
     f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f47:	8d 50 01             	lea    0x1(%eax),%edx
     f4a:	89 55 fc             	mov    %edx,-0x4(%ebp)
     f4d:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f50:	8d 4a 01             	lea    0x1(%edx),%ecx
     f53:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     f56:	0f b6 12             	movzbl (%edx),%edx
     f59:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f5b:	8b 45 10             	mov    0x10(%ebp),%eax
     f5e:	8d 50 ff             	lea    -0x1(%eax),%edx
     f61:	89 55 10             	mov    %edx,0x10(%ebp)
     f64:	85 c0                	test   %eax,%eax
     f66:	7f dc                	jg     f44 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f68:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f6b:	c9                   	leave  
     f6c:	c3                   	ret    

00000f6d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f6d:	b8 01 00 00 00       	mov    $0x1,%eax
     f72:	cd 40                	int    $0x40
     f74:	c3                   	ret    

00000f75 <exit>:
SYSCALL(exit)
     f75:	b8 02 00 00 00       	mov    $0x2,%eax
     f7a:	cd 40                	int    $0x40
     f7c:	c3                   	ret    

00000f7d <wait>:
SYSCALL(wait)
     f7d:	b8 03 00 00 00       	mov    $0x3,%eax
     f82:	cd 40                	int    $0x40
     f84:	c3                   	ret    

00000f85 <pipe>:
SYSCALL(pipe)
     f85:	b8 04 00 00 00       	mov    $0x4,%eax
     f8a:	cd 40                	int    $0x40
     f8c:	c3                   	ret    

00000f8d <read>:
SYSCALL(read)
     f8d:	b8 05 00 00 00       	mov    $0x5,%eax
     f92:	cd 40                	int    $0x40
     f94:	c3                   	ret    

00000f95 <write>:
SYSCALL(write)
     f95:	b8 10 00 00 00       	mov    $0x10,%eax
     f9a:	cd 40                	int    $0x40
     f9c:	c3                   	ret    

00000f9d <close>:
SYSCALL(close)
     f9d:	b8 15 00 00 00       	mov    $0x15,%eax
     fa2:	cd 40                	int    $0x40
     fa4:	c3                   	ret    

00000fa5 <kill>:
SYSCALL(kill)
     fa5:	b8 06 00 00 00       	mov    $0x6,%eax
     faa:	cd 40                	int    $0x40
     fac:	c3                   	ret    

00000fad <exec>:
SYSCALL(exec)
     fad:	b8 07 00 00 00       	mov    $0x7,%eax
     fb2:	cd 40                	int    $0x40
     fb4:	c3                   	ret    

00000fb5 <open>:
SYSCALL(open)
     fb5:	b8 0f 00 00 00       	mov    $0xf,%eax
     fba:	cd 40                	int    $0x40
     fbc:	c3                   	ret    

00000fbd <mknod>:
SYSCALL(mknod)
     fbd:	b8 11 00 00 00       	mov    $0x11,%eax
     fc2:	cd 40                	int    $0x40
     fc4:	c3                   	ret    

00000fc5 <unlink>:
SYSCALL(unlink)
     fc5:	b8 12 00 00 00       	mov    $0x12,%eax
     fca:	cd 40                	int    $0x40
     fcc:	c3                   	ret    

00000fcd <fstat>:
SYSCALL(fstat)
     fcd:	b8 08 00 00 00       	mov    $0x8,%eax
     fd2:	cd 40                	int    $0x40
     fd4:	c3                   	ret    

00000fd5 <link>:
SYSCALL(link)
     fd5:	b8 13 00 00 00       	mov    $0x13,%eax
     fda:	cd 40                	int    $0x40
     fdc:	c3                   	ret    

00000fdd <mkdir>:
SYSCALL(mkdir)
     fdd:	b8 14 00 00 00       	mov    $0x14,%eax
     fe2:	cd 40                	int    $0x40
     fe4:	c3                   	ret    

00000fe5 <chdir>:
SYSCALL(chdir)
     fe5:	b8 09 00 00 00       	mov    $0x9,%eax
     fea:	cd 40                	int    $0x40
     fec:	c3                   	ret    

00000fed <dup>:
SYSCALL(dup)
     fed:	b8 0a 00 00 00       	mov    $0xa,%eax
     ff2:	cd 40                	int    $0x40
     ff4:	c3                   	ret    

00000ff5 <getpid>:
SYSCALL(getpid)
     ff5:	b8 0b 00 00 00       	mov    $0xb,%eax
     ffa:	cd 40                	int    $0x40
     ffc:	c3                   	ret    

00000ffd <sbrk>:
SYSCALL(sbrk)
     ffd:	b8 0c 00 00 00       	mov    $0xc,%eax
    1002:	cd 40                	int    $0x40
    1004:	c3                   	ret    

00001005 <sleep>:
SYSCALL(sleep)
    1005:	b8 0d 00 00 00       	mov    $0xd,%eax
    100a:	cd 40                	int    $0x40
    100c:	c3                   	ret    

0000100d <uptime>:
SYSCALL(uptime)
    100d:	b8 0e 00 00 00       	mov    $0xe,%eax
    1012:	cd 40                	int    $0x40
    1014:	c3                   	ret    

00001015 <signal>:
SYSCALL(signal)
    1015:	b8 16 00 00 00       	mov    $0x16,%eax
    101a:	cd 40                	int    $0x40
    101c:	c3                   	ret    

0000101d <sigsend>:
SYSCALL(sigsend)
    101d:	b8 19 00 00 00       	mov    $0x19,%eax
    1022:	cd 40                	int    $0x40
    1024:	c3                   	ret    

00001025 <sigreturn>:
SYSCALL(sigreturn)
    1025:	b8 1a 00 00 00       	mov    $0x1a,%eax
    102a:	cd 40                	int    $0x40
    102c:	c3                   	ret    

0000102d <advanceprocstats>:
SYSCALL(advanceprocstats)
    102d:	b8 17 00 00 00       	mov    $0x17,%eax
    1032:	cd 40                	int    $0x40
    1034:	c3                   	ret    

00001035 <wait_stat>:
SYSCALL(wait_stat)
    1035:	b8 18 00 00 00       	mov    $0x18,%eax
    103a:	cd 40                	int    $0x40
    103c:	c3                   	ret    

0000103d <priority>:
SYSCALL(priority)
    103d:	b8 1b 00 00 00       	mov    $0x1b,%eax
    1042:	cd 40                	int    $0x40
    1044:	c3                   	ret    

00001045 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1045:	55                   	push   %ebp
    1046:	89 e5                	mov    %esp,%ebp
    1048:	83 ec 18             	sub    $0x18,%esp
    104b:	8b 45 0c             	mov    0xc(%ebp),%eax
    104e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1051:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1058:	00 
    1059:	8d 45 f4             	lea    -0xc(%ebp),%eax
    105c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1060:	8b 45 08             	mov    0x8(%ebp),%eax
    1063:	89 04 24             	mov    %eax,(%esp)
    1066:	e8 2a ff ff ff       	call   f95 <write>
}
    106b:	c9                   	leave  
    106c:	c3                   	ret    

0000106d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    106d:	55                   	push   %ebp
    106e:	89 e5                	mov    %esp,%ebp
    1070:	56                   	push   %esi
    1071:	53                   	push   %ebx
    1072:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1075:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    107c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1080:	74 17                	je     1099 <printint+0x2c>
    1082:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1086:	79 11                	jns    1099 <printint+0x2c>
    neg = 1;
    1088:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    108f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1092:	f7 d8                	neg    %eax
    1094:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1097:	eb 06                	jmp    109f <printint+0x32>
  } else {
    x = xx;
    1099:	8b 45 0c             	mov    0xc(%ebp),%eax
    109c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    109f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    10a6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    10a9:	8d 41 01             	lea    0x1(%ecx),%eax
    10ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    10af:	8b 5d 10             	mov    0x10(%ebp),%ebx
    10b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10b5:	ba 00 00 00 00       	mov    $0x0,%edx
    10ba:	f7 f3                	div    %ebx
    10bc:	89 d0                	mov    %edx,%eax
    10be:	0f b6 80 a6 1a 00 00 	movzbl 0x1aa6(%eax),%eax
    10c5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    10c9:	8b 75 10             	mov    0x10(%ebp),%esi
    10cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10cf:	ba 00 00 00 00       	mov    $0x0,%edx
    10d4:	f7 f6                	div    %esi
    10d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10dd:	75 c7                	jne    10a6 <printint+0x39>
  if(neg)
    10df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10e3:	74 10                	je     10f5 <printint+0x88>
    buf[i++] = '-';
    10e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10e8:	8d 50 01             	lea    0x1(%eax),%edx
    10eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
    10ee:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    10f3:	eb 1f                	jmp    1114 <printint+0xa7>
    10f5:	eb 1d                	jmp    1114 <printint+0xa7>
    putc(fd, buf[i]);
    10f7:	8d 55 dc             	lea    -0x24(%ebp),%edx
    10fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10fd:	01 d0                	add    %edx,%eax
    10ff:	0f b6 00             	movzbl (%eax),%eax
    1102:	0f be c0             	movsbl %al,%eax
    1105:	89 44 24 04          	mov    %eax,0x4(%esp)
    1109:	8b 45 08             	mov    0x8(%ebp),%eax
    110c:	89 04 24             	mov    %eax,(%esp)
    110f:	e8 31 ff ff ff       	call   1045 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1114:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1118:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    111c:	79 d9                	jns    10f7 <printint+0x8a>
    putc(fd, buf[i]);
}
    111e:	83 c4 30             	add    $0x30,%esp
    1121:	5b                   	pop    %ebx
    1122:	5e                   	pop    %esi
    1123:	5d                   	pop    %ebp
    1124:	c3                   	ret    

00001125 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1125:	55                   	push   %ebp
    1126:	89 e5                	mov    %esp,%ebp
    1128:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    112b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1132:	8d 45 0c             	lea    0xc(%ebp),%eax
    1135:	83 c0 04             	add    $0x4,%eax
    1138:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    113b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1142:	e9 7c 01 00 00       	jmp    12c3 <printf+0x19e>
    c = fmt[i] & 0xff;
    1147:	8b 55 0c             	mov    0xc(%ebp),%edx
    114a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    114d:	01 d0                	add    %edx,%eax
    114f:	0f b6 00             	movzbl (%eax),%eax
    1152:	0f be c0             	movsbl %al,%eax
    1155:	25 ff 00 00 00       	and    $0xff,%eax
    115a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    115d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1161:	75 2c                	jne    118f <printf+0x6a>
      if(c == '%'){
    1163:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1167:	75 0c                	jne    1175 <printf+0x50>
        state = '%';
    1169:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1170:	e9 4a 01 00 00       	jmp    12bf <printf+0x19a>
      } else {
        putc(fd, c);
    1175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1178:	0f be c0             	movsbl %al,%eax
    117b:	89 44 24 04          	mov    %eax,0x4(%esp)
    117f:	8b 45 08             	mov    0x8(%ebp),%eax
    1182:	89 04 24             	mov    %eax,(%esp)
    1185:	e8 bb fe ff ff       	call   1045 <putc>
    118a:	e9 30 01 00 00       	jmp    12bf <printf+0x19a>
      }
    } else if(state == '%'){
    118f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1193:	0f 85 26 01 00 00    	jne    12bf <printf+0x19a>
      if(c == 'd'){
    1199:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    119d:	75 2d                	jne    11cc <printf+0xa7>
        printint(fd, *ap, 10, 1);
    119f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11a2:	8b 00                	mov    (%eax),%eax
    11a4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    11ab:	00 
    11ac:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    11b3:	00 
    11b4:	89 44 24 04          	mov    %eax,0x4(%esp)
    11b8:	8b 45 08             	mov    0x8(%ebp),%eax
    11bb:	89 04 24             	mov    %eax,(%esp)
    11be:	e8 aa fe ff ff       	call   106d <printint>
        ap++;
    11c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11c7:	e9 ec 00 00 00       	jmp    12b8 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    11cc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    11d0:	74 06                	je     11d8 <printf+0xb3>
    11d2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    11d6:	75 2d                	jne    1205 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    11d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11db:	8b 00                	mov    (%eax),%eax
    11dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    11e4:	00 
    11e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    11ec:	00 
    11ed:	89 44 24 04          	mov    %eax,0x4(%esp)
    11f1:	8b 45 08             	mov    0x8(%ebp),%eax
    11f4:	89 04 24             	mov    %eax,(%esp)
    11f7:	e8 71 fe ff ff       	call   106d <printint>
        ap++;
    11fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1200:	e9 b3 00 00 00       	jmp    12b8 <printf+0x193>
      } else if(c == 's'){
    1205:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1209:	75 45                	jne    1250 <printf+0x12b>
        s = (char*)*ap;
    120b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    120e:	8b 00                	mov    (%eax),%eax
    1210:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1213:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1217:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    121b:	75 09                	jne    1226 <printf+0x101>
          s = "(null)";
    121d:	c7 45 f4 10 16 00 00 	movl   $0x1610,-0xc(%ebp)
        while(*s != 0){
    1224:	eb 1e                	jmp    1244 <printf+0x11f>
    1226:	eb 1c                	jmp    1244 <printf+0x11f>
          putc(fd, *s);
    1228:	8b 45 f4             	mov    -0xc(%ebp),%eax
    122b:	0f b6 00             	movzbl (%eax),%eax
    122e:	0f be c0             	movsbl %al,%eax
    1231:	89 44 24 04          	mov    %eax,0x4(%esp)
    1235:	8b 45 08             	mov    0x8(%ebp),%eax
    1238:	89 04 24             	mov    %eax,(%esp)
    123b:	e8 05 fe ff ff       	call   1045 <putc>
          s++;
    1240:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1244:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1247:	0f b6 00             	movzbl (%eax),%eax
    124a:	84 c0                	test   %al,%al
    124c:	75 da                	jne    1228 <printf+0x103>
    124e:	eb 68                	jmp    12b8 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1250:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1254:	75 1d                	jne    1273 <printf+0x14e>
        putc(fd, *ap);
    1256:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1259:	8b 00                	mov    (%eax),%eax
    125b:	0f be c0             	movsbl %al,%eax
    125e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1262:	8b 45 08             	mov    0x8(%ebp),%eax
    1265:	89 04 24             	mov    %eax,(%esp)
    1268:	e8 d8 fd ff ff       	call   1045 <putc>
        ap++;
    126d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1271:	eb 45                	jmp    12b8 <printf+0x193>
      } else if(c == '%'){
    1273:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1277:	75 17                	jne    1290 <printf+0x16b>
        putc(fd, c);
    1279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    127c:	0f be c0             	movsbl %al,%eax
    127f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1283:	8b 45 08             	mov    0x8(%ebp),%eax
    1286:	89 04 24             	mov    %eax,(%esp)
    1289:	e8 b7 fd ff ff       	call   1045 <putc>
    128e:	eb 28                	jmp    12b8 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1290:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1297:	00 
    1298:	8b 45 08             	mov    0x8(%ebp),%eax
    129b:	89 04 24             	mov    %eax,(%esp)
    129e:	e8 a2 fd ff ff       	call   1045 <putc>
        putc(fd, c);
    12a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12a6:	0f be c0             	movsbl %al,%eax
    12a9:	89 44 24 04          	mov    %eax,0x4(%esp)
    12ad:	8b 45 08             	mov    0x8(%ebp),%eax
    12b0:	89 04 24             	mov    %eax,(%esp)
    12b3:	e8 8d fd ff ff       	call   1045 <putc>
      }
      state = 0;
    12b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12bf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12c3:	8b 55 0c             	mov    0xc(%ebp),%edx
    12c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12c9:	01 d0                	add    %edx,%eax
    12cb:	0f b6 00             	movzbl (%eax),%eax
    12ce:	84 c0                	test   %al,%al
    12d0:	0f 85 71 fe ff ff    	jne    1147 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12d6:	c9                   	leave  
    12d7:	c3                   	ret    

000012d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12d8:	55                   	push   %ebp
    12d9:	89 e5                	mov    %esp,%ebp
    12db:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12de:	8b 45 08             	mov    0x8(%ebp),%eax
    12e1:	83 e8 08             	sub    $0x8,%eax
    12e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12e7:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    12ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12ef:	eb 24                	jmp    1315 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12f4:	8b 00                	mov    (%eax),%eax
    12f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12f9:	77 12                	ja     130d <free+0x35>
    12fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12fe:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1301:	77 24                	ja     1327 <free+0x4f>
    1303:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1306:	8b 00                	mov    (%eax),%eax
    1308:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    130b:	77 1a                	ja     1327 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    130d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1310:	8b 00                	mov    (%eax),%eax
    1312:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1315:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1318:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    131b:	76 d4                	jbe    12f1 <free+0x19>
    131d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1320:	8b 00                	mov    (%eax),%eax
    1322:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1325:	76 ca                	jbe    12f1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1327:	8b 45 f8             	mov    -0x8(%ebp),%eax
    132a:	8b 40 04             	mov    0x4(%eax),%eax
    132d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1334:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1337:	01 c2                	add    %eax,%edx
    1339:	8b 45 fc             	mov    -0x4(%ebp),%eax
    133c:	8b 00                	mov    (%eax),%eax
    133e:	39 c2                	cmp    %eax,%edx
    1340:	75 24                	jne    1366 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1342:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1345:	8b 50 04             	mov    0x4(%eax),%edx
    1348:	8b 45 fc             	mov    -0x4(%ebp),%eax
    134b:	8b 00                	mov    (%eax),%eax
    134d:	8b 40 04             	mov    0x4(%eax),%eax
    1350:	01 c2                	add    %eax,%edx
    1352:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1355:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1358:	8b 45 fc             	mov    -0x4(%ebp),%eax
    135b:	8b 00                	mov    (%eax),%eax
    135d:	8b 10                	mov    (%eax),%edx
    135f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1362:	89 10                	mov    %edx,(%eax)
    1364:	eb 0a                	jmp    1370 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1366:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1369:	8b 10                	mov    (%eax),%edx
    136b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    136e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1370:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1373:	8b 40 04             	mov    0x4(%eax),%eax
    1376:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    137d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1380:	01 d0                	add    %edx,%eax
    1382:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1385:	75 20                	jne    13a7 <free+0xcf>
    p->s.size += bp->s.size;
    1387:	8b 45 fc             	mov    -0x4(%ebp),%eax
    138a:	8b 50 04             	mov    0x4(%eax),%edx
    138d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1390:	8b 40 04             	mov    0x4(%eax),%eax
    1393:	01 c2                	add    %eax,%edx
    1395:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1398:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    139b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    139e:	8b 10                	mov    (%eax),%edx
    13a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a3:	89 10                	mov    %edx,(%eax)
    13a5:	eb 08                	jmp    13af <free+0xd7>
  } else
    p->s.ptr = bp;
    13a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13aa:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13ad:	89 10                	mov    %edx,(%eax)
  freep = p;
    13af:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b2:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
}
    13b7:	c9                   	leave  
    13b8:	c3                   	ret    

000013b9 <morecore>:

static Header*
morecore(uint nu)
{
    13b9:	55                   	push   %ebp
    13ba:	89 e5                	mov    %esp,%ebp
    13bc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13bf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13c6:	77 07                	ja     13cf <morecore+0x16>
    nu = 4096;
    13c8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13cf:	8b 45 08             	mov    0x8(%ebp),%eax
    13d2:	c1 e0 03             	shl    $0x3,%eax
    13d5:	89 04 24             	mov    %eax,(%esp)
    13d8:	e8 20 fc ff ff       	call   ffd <sbrk>
    13dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    13e0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13e4:	75 07                	jne    13ed <morecore+0x34>
    return 0;
    13e6:	b8 00 00 00 00       	mov    $0x0,%eax
    13eb:	eb 22                	jmp    140f <morecore+0x56>
  hp = (Header*)p;
    13ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    13f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13f6:	8b 55 08             	mov    0x8(%ebp),%edx
    13f9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    13fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13ff:	83 c0 08             	add    $0x8,%eax
    1402:	89 04 24             	mov    %eax,(%esp)
    1405:	e8 ce fe ff ff       	call   12d8 <free>
  return freep;
    140a:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
}
    140f:	c9                   	leave  
    1410:	c3                   	ret    

00001411 <malloc>:

void*
malloc(uint nbytes)
{
    1411:	55                   	push   %ebp
    1412:	89 e5                	mov    %esp,%ebp
    1414:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1417:	8b 45 08             	mov    0x8(%ebp),%eax
    141a:	83 c0 07             	add    $0x7,%eax
    141d:	c1 e8 03             	shr    $0x3,%eax
    1420:	83 c0 01             	add    $0x1,%eax
    1423:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1426:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    142b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    142e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1432:	75 23                	jne    1457 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1434:	c7 45 f0 24 1b 00 00 	movl   $0x1b24,-0x10(%ebp)
    143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    143e:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
    1443:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    1448:	a3 24 1b 00 00       	mov    %eax,0x1b24
    base.s.size = 0;
    144d:	c7 05 28 1b 00 00 00 	movl   $0x0,0x1b28
    1454:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1457:	8b 45 f0             	mov    -0x10(%ebp),%eax
    145a:	8b 00                	mov    (%eax),%eax
    145c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    145f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1462:	8b 40 04             	mov    0x4(%eax),%eax
    1465:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1468:	72 4d                	jb     14b7 <malloc+0xa6>
      if(p->s.size == nunits)
    146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146d:	8b 40 04             	mov    0x4(%eax),%eax
    1470:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1473:	75 0c                	jne    1481 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1475:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1478:	8b 10                	mov    (%eax),%edx
    147a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    147d:	89 10                	mov    %edx,(%eax)
    147f:	eb 26                	jmp    14a7 <malloc+0x96>
      else {
        p->s.size -= nunits;
    1481:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1484:	8b 40 04             	mov    0x4(%eax),%eax
    1487:	2b 45 ec             	sub    -0x14(%ebp),%eax
    148a:	89 c2                	mov    %eax,%edx
    148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    148f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1492:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1495:	8b 40 04             	mov    0x4(%eax),%eax
    1498:	c1 e0 03             	shl    $0x3,%eax
    149b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
    14a4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    14a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14aa:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
      return (void*)(p + 1);
    14af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b2:	83 c0 08             	add    $0x8,%eax
    14b5:	eb 38                	jmp    14ef <malloc+0xde>
    }
    if(p == freep)
    14b7:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    14bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14bf:	75 1b                	jne    14dc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    14c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14c4:	89 04 24             	mov    %eax,(%esp)
    14c7:	e8 ed fe ff ff       	call   13b9 <morecore>
    14cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14d3:	75 07                	jne    14dc <malloc+0xcb>
        return 0;
    14d5:	b8 00 00 00 00       	mov    $0x0,%eax
    14da:	eb 13                	jmp    14ef <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14e5:	8b 00                	mov    (%eax),%eax
    14e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    14ea:	e9 70 ff ff ff       	jmp    145f <malloc+0x4e>
}
    14ef:	c9                   	leave  
    14f0:	c3                   	ret    
