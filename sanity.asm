
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  int rutime;					//Running state time
};

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	83 e4 f0             	and    $0xfffffff0,%esp
   8:	83 ec 40             	sub    $0x40,%esp
	int n = 20;
   b:	c7 44 24 3c 14 00 00 	movl   $0x14,0x3c(%esp)
  12:	00 
	int toWait = 0;
  13:	c7 44 24 38 00 00 00 	movl   $0x0,0x38(%esp)
  1a:	00 
	int toRun = 0;
  1b:	c7 44 24 34 00 00 00 	movl   $0x0,0x34(%esp)
  22:	00 
	int toTurnaround = 0;
  23:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
  2a:	00 
	printf(1, "Please wait......\n");
  2b:	c7 44 24 04 b8 09 00 	movl   $0x9b8,0x4(%esp)
  32:	00 
  33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3a:	e8 aa 05 00 00       	call   5e9 <printf>
	//set_priority(1);
	while (n-- > 0) {
  3f:	eb 37                	jmp    78 <main+0x78>
		if (!fork()) { // child process
  41:	e8 eb 03 00 00       	call   431 <fork>
  46:	85 c0                	test   %eax,%eax
  48:	75 2e                	jne    78 <main+0x78>
	//		//set_priority(n%3);
			double waister = 1000000;
  4a:	dd 05 60 0a 00 00    	fldl   0xa60
  50:	dd 5c 24 28          	fstpl  0x28(%esp)
			while ( (waister = waister-0.1) > 0.0);
  54:	90                   	nop
  55:	dd 44 24 28          	fldl   0x28(%esp)
  59:	dd 05 68 0a 00 00    	fldl   0xa68
  5f:	de e9                	fsubrp %st,%st(1)
  61:	dd 5c 24 28          	fstpl  0x28(%esp)
  65:	dd 44 24 28          	fldl   0x28(%esp)
  69:	d9 ee                	fldz   
  6b:	d9 c9                	fxch   %st(1)
  6d:	df e9                	fucomip %st(1),%st
  6f:	dd d8                	fstp   %st(0)
  71:	77 e2                	ja     55 <main+0x55>
			//*********** for ck sleep time!
			//int pidg = getpid();
			//int tmp[2];
			//read(tmp[0], &pidg, sizeof(pidg));
			exit();
  73:	e8 c1 03 00 00       	call   439 <exit>
	int toWait = 0;
	int toRun = 0;
	int toTurnaround = 0;
	printf(1, "Please wait......\n");
	//set_priority(1);
	while (n-- > 0) {
  78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  7c:	8d 50 ff             	lea    -0x1(%eax),%edx
  7f:	89 54 24 3c          	mov    %edx,0x3c(%esp)
  83:	85 c0                	test   %eax,%eax
  85:	7f ba                	jg     41 <main+0x41>
			//read(tmp[0], &pidg, sizeof(pidg));
			exit();
		}
	}
	int pid;
	struct perf *perfP=0;
  87:	c7 44 24 24 00 00 00 	movl   $0x0,0x24(%esp)
  8e:	00 
	perfP = malloc(sizeof(struct perf));
  8f:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
  96:	e8 3a 08 00 00       	call   8d5 <malloc>
  9b:	89 44 24 24          	mov    %eax,0x24(%esp)
	memset(perfP, 0, sizeof(struct perf));
  9f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  a6:	00 
  a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ae:	00 
  af:	8b 44 24 24          	mov    0x24(%esp),%eax
  b3:	89 04 24             	mov    %eax,(%esp)
  b6:	e8 d1 01 00 00       	call   28c <memset>


	while (++n < 20) {
  bb:	e9 91 00 00 00       	jmp    151 <main+0x151>
		pid = wait_stat((struct perf *)perfP);
  c0:	8b 44 24 24          	mov    0x24(%esp),%eax
  c4:	89 04 24             	mov    %eax,(%esp)
  c7:	e8 2d 04 00 00       	call   4f9 <wait_stat>
  cc:	89 44 24 20          	mov    %eax,0x20(%esp)
		//printf(1, "pid: %d | ctime: %d | ttime: %d | stime: %d | retime: %d | rutime: %d\n"
		//		, pid, perfP->ctime, perfP->ttime, perfP->stime, perfP->retime, perfP->rutime);
		printf(1, "pid: %d | waiting time: %d | running time: %d | turnaround time: %d\n"
						, pid, perfP->retime, perfP->rutime, perfP->ttime - perfP->ctime + perfP->stime);
  d0:	8b 44 24 24          	mov    0x24(%esp),%eax
  d4:	8b 50 04             	mov    0x4(%eax),%edx
  d7:	8b 44 24 24          	mov    0x24(%esp),%eax
  db:	8b 00                	mov    (%eax),%eax
  dd:	29 c2                	sub    %eax,%edx
  df:	8b 44 24 24          	mov    0x24(%esp),%eax
  e3:	8b 40 08             	mov    0x8(%eax),%eax

	while (++n < 20) {
		pid = wait_stat((struct perf *)perfP);
		//printf(1, "pid: %d | ctime: %d | ttime: %d | stime: %d | retime: %d | rutime: %d\n"
		//		, pid, perfP->ctime, perfP->ttime, perfP->stime, perfP->retime, perfP->rutime);
		printf(1, "pid: %d | waiting time: %d | running time: %d | turnaround time: %d\n"
  e6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  e9:	8b 44 24 24          	mov    0x24(%esp),%eax
  ed:	8b 50 10             	mov    0x10(%eax),%edx
  f0:	8b 44 24 24          	mov    0x24(%esp),%eax
  f4:	8b 40 0c             	mov    0xc(%eax),%eax
  f7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
 103:	8b 44 24 20          	mov    0x20(%esp),%eax
 107:	89 44 24 08          	mov    %eax,0x8(%esp)
 10b:	c7 44 24 04 cc 09 00 	movl   $0x9cc,0x4(%esp)
 112:	00 
 113:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11a:	e8 ca 04 00 00       	call   5e9 <printf>
						, pid, perfP->retime, perfP->rutime, perfP->ttime - perfP->ctime + perfP->stime);
		toWait += perfP->retime;
 11f:	8b 44 24 24          	mov    0x24(%esp),%eax
 123:	8b 40 0c             	mov    0xc(%eax),%eax
 126:	01 44 24 38          	add    %eax,0x38(%esp)
		toRun += perfP->rutime;
 12a:	8b 44 24 24          	mov    0x24(%esp),%eax
 12e:	8b 40 10             	mov    0x10(%eax),%eax
 131:	01 44 24 34          	add    %eax,0x34(%esp)
		toTurnaround += perfP->ttime - perfP->ctime + perfP->stime;
 135:	8b 44 24 24          	mov    0x24(%esp),%eax
 139:	8b 50 04             	mov    0x4(%eax),%edx
 13c:	8b 44 24 24          	mov    0x24(%esp),%eax
 140:	8b 00                	mov    (%eax),%eax
 142:	29 c2                	sub    %eax,%edx
 144:	8b 44 24 24          	mov    0x24(%esp),%eax
 148:	8b 40 08             	mov    0x8(%eax),%eax
 14b:	01 d0                	add    %edx,%eax
 14d:	01 44 24 30          	add    %eax,0x30(%esp)
	struct perf *perfP=0;
	perfP = malloc(sizeof(struct perf));
	memset(perfP, 0, sizeof(struct perf));


	while (++n < 20) {
 151:	83 44 24 3c 01       	addl   $0x1,0x3c(%esp)
 156:	83 7c 24 3c 13       	cmpl   $0x13,0x3c(%esp)
 15b:	0f 8e 5f ff ff ff    	jle    c0 <main+0xc0>
						, pid, perfP->retime, perfP->rutime, perfP->ttime - perfP->ctime + perfP->stime);
		toWait += perfP->retime;
		toRun += perfP->rutime;
		toTurnaround += perfP->ttime - perfP->ctime + perfP->stime;
	}
	printf(1, "Avg waiting time: %d\n Avg running time: %d\n Avg turnaround time: %d \n", toWait/20, toRun/20, toTurnaround/20);
 161:	8b 4c 24 30          	mov    0x30(%esp),%ecx
 165:	ba 67 66 66 66       	mov    $0x66666667,%edx
 16a:	89 c8                	mov    %ecx,%eax
 16c:	f7 ea                	imul   %edx
 16e:	c1 fa 03             	sar    $0x3,%edx
 171:	89 c8                	mov    %ecx,%eax
 173:	c1 f8 1f             	sar    $0x1f,%eax
 176:	89 d6                	mov    %edx,%esi
 178:	29 c6                	sub    %eax,%esi
 17a:	8b 4c 24 34          	mov    0x34(%esp),%ecx
 17e:	ba 67 66 66 66       	mov    $0x66666667,%edx
 183:	89 c8                	mov    %ecx,%eax
 185:	f7 ea                	imul   %edx
 187:	c1 fa 03             	sar    $0x3,%edx
 18a:	89 c8                	mov    %ecx,%eax
 18c:	c1 f8 1f             	sar    $0x1f,%eax
 18f:	89 d3                	mov    %edx,%ebx
 191:	29 c3                	sub    %eax,%ebx
 193:	8b 4c 24 38          	mov    0x38(%esp),%ecx
 197:	ba 67 66 66 66       	mov    $0x66666667,%edx
 19c:	89 c8                	mov    %ecx,%eax
 19e:	f7 ea                	imul   %edx
 1a0:	c1 fa 03             	sar    $0x3,%edx
 1a3:	89 c8                	mov    %ecx,%eax
 1a5:	c1 f8 1f             	sar    $0x1f,%eax
 1a8:	29 c2                	sub    %eax,%edx
 1aa:	89 d0                	mov    %edx,%eax
 1ac:	89 74 24 10          	mov    %esi,0x10(%esp)
 1b0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 1b4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b8:	c7 44 24 04 14 0a 00 	movl   $0xa14,0x4(%esp)
 1bf:	00 
 1c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1c7:	e8 1d 04 00 00       	call   5e9 <printf>
		exit();
 1cc:	e8 68 02 00 00       	call   439 <exit>

000001d1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	57                   	push   %edi
 1d5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1d9:	8b 55 10             	mov    0x10(%ebp),%edx
 1dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1df:	89 cb                	mov    %ecx,%ebx
 1e1:	89 df                	mov    %ebx,%edi
 1e3:	89 d1                	mov    %edx,%ecx
 1e5:	fc                   	cld    
 1e6:	f3 aa                	rep stos %al,%es:(%edi)
 1e8:	89 ca                	mov    %ecx,%edx
 1ea:	89 fb                	mov    %edi,%ebx
 1ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f2:	5b                   	pop    %ebx
 1f3:	5f                   	pop    %edi
 1f4:	5d                   	pop    %ebp
 1f5:	c3                   	ret    

000001f6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 202:	90                   	nop
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	8d 50 01             	lea    0x1(%eax),%edx
 209:	89 55 08             	mov    %edx,0x8(%ebp)
 20c:	8b 55 0c             	mov    0xc(%ebp),%edx
 20f:	8d 4a 01             	lea    0x1(%edx),%ecx
 212:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 215:	0f b6 12             	movzbl (%edx),%edx
 218:	88 10                	mov    %dl,(%eax)
 21a:	0f b6 00             	movzbl (%eax),%eax
 21d:	84 c0                	test   %al,%al
 21f:	75 e2                	jne    203 <strcpy+0xd>
    ;
  return os;
 221:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 229:	eb 08                	jmp    233 <strcmp+0xd>
    p++, q++;
 22b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 22f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	84 c0                	test   %al,%al
 23b:	74 10                	je     24d <strcmp+0x27>
 23d:	8b 45 08             	mov    0x8(%ebp),%eax
 240:	0f b6 10             	movzbl (%eax),%edx
 243:	8b 45 0c             	mov    0xc(%ebp),%eax
 246:	0f b6 00             	movzbl (%eax),%eax
 249:	38 c2                	cmp    %al,%dl
 24b:	74 de                	je     22b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	0f b6 d0             	movzbl %al,%edx
 256:	8b 45 0c             	mov    0xc(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	0f b6 c0             	movzbl %al,%eax
 25f:	29 c2                	sub    %eax,%edx
 261:	89 d0                	mov    %edx,%eax
}
 263:	5d                   	pop    %ebp
 264:	c3                   	ret    

00000265 <strlen>:

uint
strlen(char *s)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 26b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 272:	eb 04                	jmp    278 <strlen+0x13>
 274:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 278:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27b:	8b 45 08             	mov    0x8(%ebp),%eax
 27e:	01 d0                	add    %edx,%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	84 c0                	test   %al,%al
 285:	75 ed                	jne    274 <strlen+0xf>
    ;
  return n;
 287:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28a:	c9                   	leave  
 28b:	c3                   	ret    

0000028c <memset>:

void*
memset(void *dst, int c, uint n)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 292:	8b 45 10             	mov    0x10(%ebp),%eax
 295:	89 44 24 08          	mov    %eax,0x8(%esp)
 299:	8b 45 0c             	mov    0xc(%ebp),%eax
 29c:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	89 04 24             	mov    %eax,(%esp)
 2a6:	e8 26 ff ff ff       	call   1d1 <stosb>
  return dst;
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <strchr>:

char*
strchr(const char *s, char c)
{
 2b0:	55                   	push   %ebp
 2b1:	89 e5                	mov    %esp,%ebp
 2b3:	83 ec 04             	sub    $0x4,%esp
 2b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2bc:	eb 14                	jmp    2d2 <strchr+0x22>
    if(*s == c)
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	0f b6 00             	movzbl (%eax),%eax
 2c4:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c7:	75 05                	jne    2ce <strchr+0x1e>
      return (char*)s;
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	eb 13                	jmp    2e1 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	0f b6 00             	movzbl (%eax),%eax
 2d8:	84 c0                	test   %al,%al
 2da:	75 e2                	jne    2be <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <gets>:

char*
gets(char *buf, int max)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2f0:	eb 4c                	jmp    33e <gets+0x5b>
    cc = read(0, &c, 1);
 2f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f9:	00 
 2fa:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 301:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 308:	e8 44 01 00 00       	call   451 <read>
 30d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 310:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 314:	7f 02                	jg     318 <gets+0x35>
      break;
 316:	eb 31                	jmp    349 <gets+0x66>
    buf[i++] = c;
 318:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31b:	8d 50 01             	lea    0x1(%eax),%edx
 31e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 321:	89 c2                	mov    %eax,%edx
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	01 c2                	add    %eax,%edx
 328:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 32e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 332:	3c 0a                	cmp    $0xa,%al
 334:	74 13                	je     349 <gets+0x66>
 336:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33a:	3c 0d                	cmp    $0xd,%al
 33c:	74 0b                	je     349 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 341:	83 c0 01             	add    $0x1,%eax
 344:	3b 45 0c             	cmp    0xc(%ebp),%eax
 347:	7c a9                	jl     2f2 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 349:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	01 d0                	add    %edx,%eax
 351:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <stat>:

int
stat(char *n, struct stat *st)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 35f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 366:	00 
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	89 04 24             	mov    %eax,(%esp)
 36d:	e8 07 01 00 00       	call   479 <open>
 372:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 375:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 379:	79 07                	jns    382 <stat+0x29>
    return -1;
 37b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 380:	eb 23                	jmp    3a5 <stat+0x4c>
  r = fstat(fd, st);
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	89 44 24 04          	mov    %eax,0x4(%esp)
 389:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38c:	89 04 24             	mov    %eax,(%esp)
 38f:	e8 fd 00 00 00       	call   491 <fstat>
 394:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 397:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39a:	89 04 24             	mov    %eax,(%esp)
 39d:	e8 bf 00 00 00       	call   461 <close>
  return r;
 3a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <atoi>:

int
atoi(const char *s)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b4:	eb 25                	jmp    3db <atoi+0x34>
    n = n*10 + *s++ - '0';
 3b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b9:	89 d0                	mov    %edx,%eax
 3bb:	c1 e0 02             	shl    $0x2,%eax
 3be:	01 d0                	add    %edx,%eax
 3c0:	01 c0                	add    %eax,%eax
 3c2:	89 c1                	mov    %eax,%ecx
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	8d 50 01             	lea    0x1(%eax),%edx
 3ca:	89 55 08             	mov    %edx,0x8(%ebp)
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	0f be c0             	movsbl %al,%eax
 3d3:	01 c8                	add    %ecx,%eax
 3d5:	83 e8 30             	sub    $0x30,%eax
 3d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	0f b6 00             	movzbl (%eax),%eax
 3e1:	3c 2f                	cmp    $0x2f,%al
 3e3:	7e 0a                	jle    3ef <atoi+0x48>
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	3c 39                	cmp    $0x39,%al
 3ed:	7e c7                	jle    3b6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 406:	eb 17                	jmp    41f <memmove+0x2b>
    *dst++ = *src++;
 408:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40b:	8d 50 01             	lea    0x1(%eax),%edx
 40e:	89 55 fc             	mov    %edx,-0x4(%ebp)
 411:	8b 55 f8             	mov    -0x8(%ebp),%edx
 414:	8d 4a 01             	lea    0x1(%edx),%ecx
 417:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 41a:	0f b6 12             	movzbl (%edx),%edx
 41d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 41f:	8b 45 10             	mov    0x10(%ebp),%eax
 422:	8d 50 ff             	lea    -0x1(%eax),%edx
 425:	89 55 10             	mov    %edx,0x10(%ebp)
 428:	85 c0                	test   %eax,%eax
 42a:	7f dc                	jg     408 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 431:	b8 01 00 00 00       	mov    $0x1,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <exit>:
SYSCALL(exit)
 439:	b8 02 00 00 00       	mov    $0x2,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <wait>:
SYSCALL(wait)
 441:	b8 03 00 00 00       	mov    $0x3,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <pipe>:
SYSCALL(pipe)
 449:	b8 04 00 00 00       	mov    $0x4,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <read>:
SYSCALL(read)
 451:	b8 05 00 00 00       	mov    $0x5,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <write>:
SYSCALL(write)
 459:	b8 10 00 00 00       	mov    $0x10,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <close>:
SYSCALL(close)
 461:	b8 15 00 00 00       	mov    $0x15,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <kill>:
SYSCALL(kill)
 469:	b8 06 00 00 00       	mov    $0x6,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <exec>:
SYSCALL(exec)
 471:	b8 07 00 00 00       	mov    $0x7,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <open>:
SYSCALL(open)
 479:	b8 0f 00 00 00       	mov    $0xf,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret    

00000481 <mknod>:
SYSCALL(mknod)
 481:	b8 11 00 00 00       	mov    $0x11,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret    

00000489 <unlink>:
SYSCALL(unlink)
 489:	b8 12 00 00 00       	mov    $0x12,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret    

00000491 <fstat>:
SYSCALL(fstat)
 491:	b8 08 00 00 00       	mov    $0x8,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	ret    

00000499 <link>:
SYSCALL(link)
 499:	b8 13 00 00 00       	mov    $0x13,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	ret    

000004a1 <mkdir>:
SYSCALL(mkdir)
 4a1:	b8 14 00 00 00       	mov    $0x14,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	ret    

000004a9 <chdir>:
SYSCALL(chdir)
 4a9:	b8 09 00 00 00       	mov    $0x9,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	ret    

000004b1 <dup>:
SYSCALL(dup)
 4b1:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b6:	cd 40                	int    $0x40
 4b8:	c3                   	ret    

000004b9 <getpid>:
SYSCALL(getpid)
 4b9:	b8 0b 00 00 00       	mov    $0xb,%eax
 4be:	cd 40                	int    $0x40
 4c0:	c3                   	ret    

000004c1 <sbrk>:
SYSCALL(sbrk)
 4c1:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	ret    

000004c9 <sleep>:
SYSCALL(sleep)
 4c9:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <uptime>:
SYSCALL(uptime)
 4d1:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <signal>:
SYSCALL(signal)
 4d9:	b8 16 00 00 00       	mov    $0x16,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <sigsend>:
SYSCALL(sigsend)
 4e1:	b8 19 00 00 00       	mov    $0x19,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <sigreturn>:
SYSCALL(sigreturn)
 4e9:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <advanceprocstats>:
SYSCALL(advanceprocstats)
 4f1:	b8 17 00 00 00       	mov    $0x17,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <wait_stat>:
SYSCALL(wait_stat)
 4f9:	b8 18 00 00 00       	mov    $0x18,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <priority>:
SYSCALL(priority)
 501:	b8 1b 00 00 00       	mov    $0x1b,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 509:	55                   	push   %ebp
 50a:	89 e5                	mov    %esp,%ebp
 50c:	83 ec 18             	sub    $0x18,%esp
 50f:	8b 45 0c             	mov    0xc(%ebp),%eax
 512:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 515:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 51c:	00 
 51d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 520:	89 44 24 04          	mov    %eax,0x4(%esp)
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	89 04 24             	mov    %eax,(%esp)
 52a:	e8 2a ff ff ff       	call   459 <write>
}
 52f:	c9                   	leave  
 530:	c3                   	ret    

00000531 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 531:	55                   	push   %ebp
 532:	89 e5                	mov    %esp,%ebp
 534:	56                   	push   %esi
 535:	53                   	push   %ebx
 536:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 539:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 540:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 544:	74 17                	je     55d <printint+0x2c>
 546:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 54a:	79 11                	jns    55d <printint+0x2c>
    neg = 1;
 54c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 553:	8b 45 0c             	mov    0xc(%ebp),%eax
 556:	f7 d8                	neg    %eax
 558:	89 45 ec             	mov    %eax,-0x14(%ebp)
 55b:	eb 06                	jmp    563 <printint+0x32>
  } else {
    x = xx;
 55d:	8b 45 0c             	mov    0xc(%ebp),%eax
 560:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 563:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 56a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 56d:	8d 41 01             	lea    0x1(%ecx),%eax
 570:	89 45 f4             	mov    %eax,-0xc(%ebp)
 573:	8b 5d 10             	mov    0x10(%ebp),%ebx
 576:	8b 45 ec             	mov    -0x14(%ebp),%eax
 579:	ba 00 00 00 00       	mov    $0x0,%edx
 57e:	f7 f3                	div    %ebx
 580:	89 d0                	mov    %edx,%eax
 582:	0f b6 80 c0 0c 00 00 	movzbl 0xcc0(%eax),%eax
 589:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 58d:	8b 75 10             	mov    0x10(%ebp),%esi
 590:	8b 45 ec             	mov    -0x14(%ebp),%eax
 593:	ba 00 00 00 00       	mov    $0x0,%edx
 598:	f7 f6                	div    %esi
 59a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a1:	75 c7                	jne    56a <printint+0x39>
  if(neg)
 5a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a7:	74 10                	je     5b9 <printint+0x88>
    buf[i++] = '-';
 5a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ac:	8d 50 01             	lea    0x1(%eax),%edx
 5af:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5b2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5b7:	eb 1f                	jmp    5d8 <printint+0xa7>
 5b9:	eb 1d                	jmp    5d8 <printint+0xa7>
    putc(fd, buf[i]);
 5bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c1:	01 d0                	add    %edx,%eax
 5c3:	0f b6 00             	movzbl (%eax),%eax
 5c6:	0f be c0             	movsbl %al,%eax
 5c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
 5d0:	89 04 24             	mov    %eax,(%esp)
 5d3:	e8 31 ff ff ff       	call   509 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e0:	79 d9                	jns    5bb <printint+0x8a>
    putc(fd, buf[i]);
}
 5e2:	83 c4 30             	add    $0x30,%esp
 5e5:	5b                   	pop    %ebx
 5e6:	5e                   	pop    %esi
 5e7:	5d                   	pop    %ebp
 5e8:	c3                   	ret    

000005e9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e9:	55                   	push   %ebp
 5ea:	89 e5                	mov    %esp,%ebp
 5ec:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f6:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f9:	83 c0 04             	add    $0x4,%eax
 5fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 606:	e9 7c 01 00 00       	jmp    787 <printf+0x19e>
    c = fmt[i] & 0xff;
 60b:	8b 55 0c             	mov    0xc(%ebp),%edx
 60e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 611:	01 d0                	add    %edx,%eax
 613:	0f b6 00             	movzbl (%eax),%eax
 616:	0f be c0             	movsbl %al,%eax
 619:	25 ff 00 00 00       	and    $0xff,%eax
 61e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 621:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 625:	75 2c                	jne    653 <printf+0x6a>
      if(c == '%'){
 627:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62b:	75 0c                	jne    639 <printf+0x50>
        state = '%';
 62d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 634:	e9 4a 01 00 00       	jmp    783 <printf+0x19a>
      } else {
        putc(fd, c);
 639:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63c:	0f be c0             	movsbl %al,%eax
 63f:	89 44 24 04          	mov    %eax,0x4(%esp)
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	89 04 24             	mov    %eax,(%esp)
 649:	e8 bb fe ff ff       	call   509 <putc>
 64e:	e9 30 01 00 00       	jmp    783 <printf+0x19a>
      }
    } else if(state == '%'){
 653:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 657:	0f 85 26 01 00 00    	jne    783 <printf+0x19a>
      if(c == 'd'){
 65d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 661:	75 2d                	jne    690 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 663:	8b 45 e8             	mov    -0x18(%ebp),%eax
 666:	8b 00                	mov    (%eax),%eax
 668:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 66f:	00 
 670:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 677:	00 
 678:	89 44 24 04          	mov    %eax,0x4(%esp)
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 04 24             	mov    %eax,(%esp)
 682:	e8 aa fe ff ff       	call   531 <printint>
        ap++;
 687:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68b:	e9 ec 00 00 00       	jmp    77c <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 690:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 694:	74 06                	je     69c <printf+0xb3>
 696:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 69a:	75 2d                	jne    6c9 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 69c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6a8:	00 
 6a9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6b0:	00 
 6b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 71 fe ff ff       	call   531 <printint>
        ap++;
 6c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c4:	e9 b3 00 00 00       	jmp    77c <printf+0x193>
      } else if(c == 's'){
 6c9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6cd:	75 45                	jne    714 <printf+0x12b>
        s = (char*)*ap;
 6cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d2:	8b 00                	mov    (%eax),%eax
 6d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6df:	75 09                	jne    6ea <printf+0x101>
          s = "(null)";
 6e1:	c7 45 f4 70 0a 00 00 	movl   $0xa70,-0xc(%ebp)
        while(*s != 0){
 6e8:	eb 1e                	jmp    708 <printf+0x11f>
 6ea:	eb 1c                	jmp    708 <printf+0x11f>
          putc(fd, *s);
 6ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
 6fc:	89 04 24             	mov    %eax,(%esp)
 6ff:	e8 05 fe ff ff       	call   509 <putc>
          s++;
 704:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	0f b6 00             	movzbl (%eax),%eax
 70e:	84 c0                	test   %al,%al
 710:	75 da                	jne    6ec <printf+0x103>
 712:	eb 68                	jmp    77c <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 714:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 718:	75 1d                	jne    737 <printf+0x14e>
        putc(fd, *ap);
 71a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71d:	8b 00                	mov    (%eax),%eax
 71f:	0f be c0             	movsbl %al,%eax
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 d8 fd ff ff       	call   509 <putc>
        ap++;
 731:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 735:	eb 45                	jmp    77c <printf+0x193>
      } else if(c == '%'){
 737:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 73b:	75 17                	jne    754 <printf+0x16b>
        putc(fd, c);
 73d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 740:	0f be c0             	movsbl %al,%eax
 743:	89 44 24 04          	mov    %eax,0x4(%esp)
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	89 04 24             	mov    %eax,(%esp)
 74d:	e8 b7 fd ff ff       	call   509 <putc>
 752:	eb 28                	jmp    77c <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 754:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 75b:	00 
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	89 04 24             	mov    %eax,(%esp)
 762:	e8 a2 fd ff ff       	call   509 <putc>
        putc(fd, c);
 767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76a:	0f be c0             	movsbl %al,%eax
 76d:	89 44 24 04          	mov    %eax,0x4(%esp)
 771:	8b 45 08             	mov    0x8(%ebp),%eax
 774:	89 04 24             	mov    %eax,(%esp)
 777:	e8 8d fd ff ff       	call   509 <putc>
      }
      state = 0;
 77c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 783:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 787:	8b 55 0c             	mov    0xc(%ebp),%edx
 78a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78d:	01 d0                	add    %edx,%eax
 78f:	0f b6 00             	movzbl (%eax),%eax
 792:	84 c0                	test   %al,%al
 794:	0f 85 71 fe ff ff    	jne    60b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 79a:	c9                   	leave  
 79b:	c3                   	ret    

0000079c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79c:	55                   	push   %ebp
 79d:	89 e5                	mov    %esp,%ebp
 79f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	83 e8 08             	sub    $0x8,%eax
 7a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ab:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 7b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b3:	eb 24                	jmp    7d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 12                	ja     7d1 <free+0x35>
 7bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c5:	77 24                	ja     7eb <free+0x4f>
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7cf:	77 1a                	ja     7eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7df:	76 d4                	jbe    7b5 <free+0x19>
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e9:	76 ca                	jbe    7b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	8b 40 04             	mov    0x4(%eax),%eax
 7f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fb:	01 c2                	add    %eax,%edx
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	39 c2                	cmp    %eax,%edx
 804:	75 24                	jne    82a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 806:	8b 45 f8             	mov    -0x8(%ebp),%eax
 809:	8b 50 04             	mov    0x4(%eax),%edx
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	8b 00                	mov    (%eax),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	01 c2                	add    %eax,%edx
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
 828:	eb 0a                	jmp    834 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 82a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82d:	8b 10                	mov    (%eax),%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	01 d0                	add    %edx,%eax
 846:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 849:	75 20                	jne    86b <free+0xcf>
    p->s.size += bp->s.size;
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 50 04             	mov    0x4(%eax),%edx
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	8b 40 04             	mov    0x4(%eax),%eax
 857:	01 c2                	add    %eax,%edx
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 85f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	89 10                	mov    %edx,(%eax)
 869:	eb 08                	jmp    873 <free+0xd7>
  } else
    p->s.ptr = bp;
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 871:	89 10                	mov    %edx,(%eax)
  freep = p;
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	a3 dc 0c 00 00       	mov    %eax,0xcdc
}
 87b:	c9                   	leave  
 87c:	c3                   	ret    

0000087d <morecore>:

static Header*
morecore(uint nu)
{
 87d:	55                   	push   %ebp
 87e:	89 e5                	mov    %esp,%ebp
 880:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 883:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 88a:	77 07                	ja     893 <morecore+0x16>
    nu = 4096;
 88c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 893:	8b 45 08             	mov    0x8(%ebp),%eax
 896:	c1 e0 03             	shl    $0x3,%eax
 899:	89 04 24             	mov    %eax,(%esp)
 89c:	e8 20 fc ff ff       	call   4c1 <sbrk>
 8a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a8:	75 07                	jne    8b1 <morecore+0x34>
    return 0;
 8aa:	b8 00 00 00 00       	mov    $0x0,%eax
 8af:	eb 22                	jmp    8d3 <morecore+0x56>
  hp = (Header*)p;
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ba:	8b 55 08             	mov    0x8(%ebp),%edx
 8bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c3:	83 c0 08             	add    $0x8,%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 ce fe ff ff       	call   79c <free>
  return freep;
 8ce:	a1 dc 0c 00 00       	mov    0xcdc,%eax
}
 8d3:	c9                   	leave  
 8d4:	c3                   	ret    

000008d5 <malloc>:

void*
malloc(uint nbytes)
{
 8d5:	55                   	push   %ebp
 8d6:	89 e5                	mov    %esp,%ebp
 8d8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8db:	8b 45 08             	mov    0x8(%ebp),%eax
 8de:	83 c0 07             	add    $0x7,%eax
 8e1:	c1 e8 03             	shr    $0x3,%eax
 8e4:	83 c0 01             	add    $0x1,%eax
 8e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ea:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 8ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8f6:	75 23                	jne    91b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8f8:	c7 45 f0 d4 0c 00 00 	movl   $0xcd4,-0x10(%ebp)
 8ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 902:	a3 dc 0c 00 00       	mov    %eax,0xcdc
 907:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 90c:	a3 d4 0c 00 00       	mov    %eax,0xcd4
    base.s.size = 0;
 911:	c7 05 d8 0c 00 00 00 	movl   $0x0,0xcd8
 918:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91e:	8b 00                	mov    (%eax),%eax
 920:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	8b 40 04             	mov    0x4(%eax),%eax
 929:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92c:	72 4d                	jb     97b <malloc+0xa6>
      if(p->s.size == nunits)
 92e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 931:	8b 40 04             	mov    0x4(%eax),%eax
 934:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 937:	75 0c                	jne    945 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 939:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93c:	8b 10                	mov    (%eax),%edx
 93e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 941:	89 10                	mov    %edx,(%eax)
 943:	eb 26                	jmp    96b <malloc+0x96>
      else {
        p->s.size -= nunits;
 945:	8b 45 f4             	mov    -0xc(%ebp),%eax
 948:	8b 40 04             	mov    0x4(%eax),%eax
 94b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 94e:	89 c2                	mov    %eax,%edx
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	8b 40 04             	mov    0x4(%eax),%eax
 95c:	c1 e0 03             	shl    $0x3,%eax
 95f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 962:	8b 45 f4             	mov    -0xc(%ebp),%eax
 965:	8b 55 ec             	mov    -0x14(%ebp),%edx
 968:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 96b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96e:	a3 dc 0c 00 00       	mov    %eax,0xcdc
      return (void*)(p + 1);
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	83 c0 08             	add    $0x8,%eax
 979:	eb 38                	jmp    9b3 <malloc+0xde>
    }
    if(p == freep)
 97b:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 980:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 983:	75 1b                	jne    9a0 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 985:	8b 45 ec             	mov    -0x14(%ebp),%eax
 988:	89 04 24             	mov    %eax,(%esp)
 98b:	e8 ed fe ff ff       	call   87d <morecore>
 990:	89 45 f4             	mov    %eax,-0xc(%ebp)
 993:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 997:	75 07                	jne    9a0 <malloc+0xcb>
        return 0;
 999:	b8 00 00 00 00       	mov    $0x0,%eax
 99e:	eb 13                	jmp    9b3 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a9:	8b 00                	mov    (%eax),%eax
 9ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ae:	e9 70 ff ff ff       	jmp    923 <malloc+0x4e>
}
 9b3:	c9                   	leave  
 9b4:	c3                   	ret    
