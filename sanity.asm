
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
   8:	83 ec 30             	sub    $0x30,%esp
	//int n = 20;
	//set_priority(1);
	//while (n-- > 0) {
		if (!fork()) { // child process
   b:	e8 41 03 00 00       	call   351 <fork>
  10:	85 c0                	test   %eax,%eax
  12:	75 2e                	jne    42 <main+0x42>
	//		//set_priority(n%3);
			double waister = 1000000;
  14:	dd 05 50 09 00 00    	fldl   0x950
  1a:	dd 5c 24 28          	fstpl  0x28(%esp)
			while ( (waister = waister-0.1) > 0.0);
  1e:	90                   	nop
  1f:	dd 44 24 28          	fldl   0x28(%esp)
  23:	dd 05 58 09 00 00    	fldl   0x958
  29:	de e9                	fsubrp %st,%st(1)
  2b:	dd 5c 24 28          	fstpl  0x28(%esp)
  2f:	dd 44 24 28          	fldl   0x28(%esp)
  33:	d9 ee                	fldz   
  35:	d9 c9                	fxch   %st(1)
  37:	df e9                	fucomip %st(1),%st
  39:	dd d8                	fstp   %st(0)
  3b:	77 e2                	ja     1f <main+0x1f>
	//		exit(getpid());
			exit();
  3d:	e8 17 03 00 00       	call   359 <exit>
		}
	//}
	printf(1, "Running highly consuming processes. Please wait...\n");
  42:	c7 44 24 04 d0 08 00 	movl   $0x8d0,0x4(%esp)
  49:	00 
  4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  51:	e8 ab 04 00 00       	call   501 <printf>
	int pid;
	struct perf *perfP=0;
  56:	c7 44 24 24 00 00 00 	movl   $0x0,0x24(%esp)
  5d:	00 
	perfP = malloc(sizeof(struct perf));
  5e:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
  65:	e8 83 07 00 00       	call   7ed <malloc>
  6a:	89 44 24 24          	mov    %eax,0x24(%esp)
	memset(perfP, 0, sizeof(struct perf));
  6e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  75:	00 
  76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  7d:	00 
  7e:	8b 44 24 24          	mov    0x24(%esp),%eax
  82:	89 04 24             	mov    %eax,(%esp)
  85:	e8 22 01 00 00       	call   1ac <memset>


	//while (++n < 20) {
		pid = wait_stat((struct perf *)perfP);
  8a:	8b 44 24 24          	mov    0x24(%esp),%eax
  8e:	89 04 24             	mov    %eax,(%esp)
  91:	e8 83 03 00 00       	call   419 <wait_stat>
  96:	89 44 24 20          	mov    %eax,0x20(%esp)
		printf(1, "pid: %d | ctime: %d | ttime: %d | stime: %d | retime: %d | rutime: %d\n"
  9a:	8b 44 24 24          	mov    0x24(%esp),%eax
  9e:	8b 70 10             	mov    0x10(%eax),%esi
  a1:	8b 44 24 24          	mov    0x24(%esp),%eax
  a5:	8b 58 0c             	mov    0xc(%eax),%ebx
  a8:	8b 44 24 24          	mov    0x24(%esp),%eax
  ac:	8b 48 08             	mov    0x8(%eax),%ecx
  af:	8b 44 24 24          	mov    0x24(%esp),%eax
  b3:	8b 50 04             	mov    0x4(%eax),%edx
  b6:	8b 44 24 24          	mov    0x24(%esp),%eax
  ba:	8b 00                	mov    (%eax),%eax
  bc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
  c0:	89 5c 24 18          	mov    %ebx,0x18(%esp)
  c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  d0:	8b 44 24 20          	mov    0x20(%esp),%eax
  d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  d8:	c7 44 24 04 04 09 00 	movl   $0x904,0x4(%esp)
  df:	00 
  e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e7:	e8 15 04 00 00       	call   501 <printf>
				, pid, perfP->ctime, perfP->ttime, perfP->stime, perfP->retime, perfP->rutime);
	//}
	//printf(1, "average waiting time: %d\naverage running time: %d\naverage sleeping time: %d\naverage turnaround time: %d\n", totwtime/20, totrtime/20, totiotime/20, totturnaround/20);
	//exit();
		exit();
  ec:	e8 68 02 00 00       	call   359 <exit>

000000f1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  f4:	57                   	push   %edi
  f5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f9:	8b 55 10             	mov    0x10(%ebp),%edx
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	89 cb                	mov    %ecx,%ebx
 101:	89 df                	mov    %ebx,%edi
 103:	89 d1                	mov    %edx,%ecx
 105:	fc                   	cld    
 106:	f3 aa                	rep stos %al,%es:(%edi)
 108:	89 ca                	mov    %ecx,%edx
 10a:	89 fb                	mov    %edi,%ebx
 10c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 112:	5b                   	pop    %ebx
 113:	5f                   	pop    %edi
 114:	5d                   	pop    %ebp
 115:	c3                   	ret    

00000116 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 122:	90                   	nop
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	8d 50 01             	lea    0x1(%eax),%edx
 129:	89 55 08             	mov    %edx,0x8(%ebp)
 12c:	8b 55 0c             	mov    0xc(%ebp),%edx
 12f:	8d 4a 01             	lea    0x1(%edx),%ecx
 132:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 135:	0f b6 12             	movzbl (%edx),%edx
 138:	88 10                	mov    %dl,(%eax)
 13a:	0f b6 00             	movzbl (%eax),%eax
 13d:	84 c0                	test   %al,%al
 13f:	75 e2                	jne    123 <strcpy+0xd>
    ;
  return os;
 141:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 144:	c9                   	leave  
 145:	c3                   	ret    

00000146 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 149:	eb 08                	jmp    153 <strcmp+0xd>
    p++, q++;
 14b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 153:	8b 45 08             	mov    0x8(%ebp),%eax
 156:	0f b6 00             	movzbl (%eax),%eax
 159:	84 c0                	test   %al,%al
 15b:	74 10                	je     16d <strcmp+0x27>
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 10             	movzbl (%eax),%edx
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	38 c2                	cmp    %al,%dl
 16b:	74 de                	je     14b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	0f b6 d0             	movzbl %al,%edx
 176:	8b 45 0c             	mov    0xc(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	0f b6 c0             	movzbl %al,%eax
 17f:	29 c2                	sub    %eax,%edx
 181:	89 d0                	mov    %edx,%eax
}
 183:	5d                   	pop    %ebp
 184:	c3                   	ret    

00000185 <strlen>:

uint
strlen(char *s)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 192:	eb 04                	jmp    198 <strlen+0x13>
 194:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 198:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	01 d0                	add    %edx,%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 ed                	jne    194 <strlen+0xf>
    ;
  return n;
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1b2:	8b 45 10             	mov    0x10(%ebp),%eax
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	89 04 24             	mov    %eax,(%esp)
 1c6:	e8 26 ff ff ff       	call   f1 <stosb>
  return dst;
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ce:	c9                   	leave  
 1cf:	c3                   	ret    

000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	55                   	push   %ebp
 1d1:	89 e5                	mov    %esp,%ebp
 1d3:	83 ec 04             	sub    $0x4,%esp
 1d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1dc:	eb 14                	jmp    1f2 <strchr+0x22>
    if(*s == c)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	0f b6 00             	movzbl (%eax),%eax
 1e4:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1e7:	75 05                	jne    1ee <strchr+0x1e>
      return (char*)s;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	eb 13                	jmp    201 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	0f b6 00             	movzbl (%eax),%eax
 1f8:	84 c0                	test   %al,%al
 1fa:	75 e2                	jne    1de <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 201:	c9                   	leave  
 202:	c3                   	ret    

00000203 <gets>:

char*
gets(char *buf, int max)
{
 203:	55                   	push   %ebp
 204:	89 e5                	mov    %esp,%ebp
 206:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 210:	eb 4c                	jmp    25e <gets+0x5b>
    cc = read(0, &c, 1);
 212:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 219:	00 
 21a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21d:	89 44 24 04          	mov    %eax,0x4(%esp)
 221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 228:	e8 44 01 00 00       	call   371 <read>
 22d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 230:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 234:	7f 02                	jg     238 <gets+0x35>
      break;
 236:	eb 31                	jmp    269 <gets+0x66>
    buf[i++] = c;
 238:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23b:	8d 50 01             	lea    0x1(%eax),%edx
 23e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 241:	89 c2                	mov    %eax,%edx
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	01 c2                	add    %eax,%edx
 248:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 252:	3c 0a                	cmp    $0xa,%al
 254:	74 13                	je     269 <gets+0x66>
 256:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25a:	3c 0d                	cmp    $0xd,%al
 25c:	74 0b                	je     269 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 261:	83 c0 01             	add    $0x1,%eax
 264:	3b 45 0c             	cmp    0xc(%ebp),%eax
 267:	7c a9                	jl     212 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 269:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	01 d0                	add    %edx,%eax
 271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <stat>:

int
stat(char *n, struct stat *st)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 286:	00 
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 07 01 00 00       	call   399 <open>
 292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 295:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 299:	79 07                	jns    2a2 <stat+0x29>
    return -1;
 29b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a0:	eb 23                	jmp    2c5 <stat+0x4c>
  r = fstat(fd, st);
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	89 04 24             	mov    %eax,(%esp)
 2af:	e8 fd 00 00 00       	call   3b1 <fstat>
 2b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 bf 00 00 00       	call   381 <close>
  return r;
 2c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <atoi>:

int
atoi(const char *s)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	eb 25                	jmp    2fb <atoi+0x34>
    n = n*10 + *s++ - '0';
 2d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d9:	89 d0                	mov    %edx,%eax
 2db:	c1 e0 02             	shl    $0x2,%eax
 2de:	01 d0                	add    %edx,%eax
 2e0:	01 c0                	add    %eax,%eax
 2e2:	89 c1                	mov    %eax,%ecx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 50 01             	lea    0x1(%eax),%edx
 2ea:	89 55 08             	mov    %edx,0x8(%ebp)
 2ed:	0f b6 00             	movzbl (%eax),%eax
 2f0:	0f be c0             	movsbl %al,%eax
 2f3:	01 c8                	add    %ecx,%eax
 2f5:	83 e8 30             	sub    $0x30,%eax
 2f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	3c 2f                	cmp    $0x2f,%al
 303:	7e 0a                	jle    30f <atoi+0x48>
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	0f b6 00             	movzbl (%eax),%eax
 30b:	3c 39                	cmp    $0x39,%al
 30d:	7e c7                	jle    2d6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 30f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 312:	c9                   	leave  
 313:	c3                   	ret    

00000314 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 314:	55                   	push   %ebp
 315:	89 e5                	mov    %esp,%ebp
 317:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 320:	8b 45 0c             	mov    0xc(%ebp),%eax
 323:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 326:	eb 17                	jmp    33f <memmove+0x2b>
    *dst++ = *src++;
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
 32b:	8d 50 01             	lea    0x1(%eax),%edx
 32e:	89 55 fc             	mov    %edx,-0x4(%ebp)
 331:	8b 55 f8             	mov    -0x8(%ebp),%edx
 334:	8d 4a 01             	lea    0x1(%edx),%ecx
 337:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 33a:	0f b6 12             	movzbl (%edx),%edx
 33d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33f:	8b 45 10             	mov    0x10(%ebp),%eax
 342:	8d 50 ff             	lea    -0x1(%eax),%edx
 345:	89 55 10             	mov    %edx,0x10(%ebp)
 348:	85 c0                	test   %eax,%eax
 34a:	7f dc                	jg     328 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34f:	c9                   	leave  
 350:	c3                   	ret    

00000351 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 351:	b8 01 00 00 00       	mov    $0x1,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <exit>:
SYSCALL(exit)
 359:	b8 02 00 00 00       	mov    $0x2,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <wait>:
SYSCALL(wait)
 361:	b8 03 00 00 00       	mov    $0x3,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <pipe>:
SYSCALL(pipe)
 369:	b8 04 00 00 00       	mov    $0x4,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <read>:
SYSCALL(read)
 371:	b8 05 00 00 00       	mov    $0x5,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <write>:
SYSCALL(write)
 379:	b8 10 00 00 00       	mov    $0x10,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <close>:
SYSCALL(close)
 381:	b8 15 00 00 00       	mov    $0x15,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <kill>:
SYSCALL(kill)
 389:	b8 06 00 00 00       	mov    $0x6,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <exec>:
SYSCALL(exec)
 391:	b8 07 00 00 00       	mov    $0x7,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <open>:
SYSCALL(open)
 399:	b8 0f 00 00 00       	mov    $0xf,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <mknod>:
SYSCALL(mknod)
 3a1:	b8 11 00 00 00       	mov    $0x11,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <unlink>:
SYSCALL(unlink)
 3a9:	b8 12 00 00 00       	mov    $0x12,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <fstat>:
SYSCALL(fstat)
 3b1:	b8 08 00 00 00       	mov    $0x8,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <link>:
SYSCALL(link)
 3b9:	b8 13 00 00 00       	mov    $0x13,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <mkdir>:
SYSCALL(mkdir)
 3c1:	b8 14 00 00 00       	mov    $0x14,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <chdir>:
SYSCALL(chdir)
 3c9:	b8 09 00 00 00       	mov    $0x9,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <dup>:
SYSCALL(dup)
 3d1:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <getpid>:
SYSCALL(getpid)
 3d9:	b8 0b 00 00 00       	mov    $0xb,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <sbrk>:
SYSCALL(sbrk)
 3e1:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <sleep>:
SYSCALL(sleep)
 3e9:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <uptime>:
SYSCALL(uptime)
 3f1:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <signal>:
SYSCALL(signal)
 3f9:	b8 16 00 00 00       	mov    $0x16,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <sigsend>:
SYSCALL(sigsend)
 401:	b8 19 00 00 00       	mov    $0x19,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <sigreturn>:
SYSCALL(sigreturn)
 409:	b8 1a 00 00 00       	mov    $0x1a,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <advanceprocstats>:
SYSCALL(advanceprocstats)
 411:	b8 17 00 00 00       	mov    $0x17,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <wait_stat>:
SYSCALL(wait_stat)
 419:	b8 18 00 00 00       	mov    $0x18,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 421:	55                   	push   %ebp
 422:	89 e5                	mov    %esp,%ebp
 424:	83 ec 18             	sub    $0x18,%esp
 427:	8b 45 0c             	mov    0xc(%ebp),%eax
 42a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 42d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 434:	00 
 435:	8d 45 f4             	lea    -0xc(%ebp),%eax
 438:	89 44 24 04          	mov    %eax,0x4(%esp)
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	89 04 24             	mov    %eax,(%esp)
 442:	e8 32 ff ff ff       	call   379 <write>
}
 447:	c9                   	leave  
 448:	c3                   	ret    

00000449 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	56                   	push   %esi
 44d:	53                   	push   %ebx
 44e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 451:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 458:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 45c:	74 17                	je     475 <printint+0x2c>
 45e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 462:	79 11                	jns    475 <printint+0x2c>
    neg = 1;
 464:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 46b:	8b 45 0c             	mov    0xc(%ebp),%eax
 46e:	f7 d8                	neg    %eax
 470:	89 45 ec             	mov    %eax,-0x14(%ebp)
 473:	eb 06                	jmp    47b <printint+0x32>
  } else {
    x = xx;
 475:	8b 45 0c             	mov    0xc(%ebp),%eax
 478:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 47b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 482:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 485:	8d 41 01             	lea    0x1(%ecx),%eax
 488:	89 45 f4             	mov    %eax,-0xc(%ebp)
 48b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 48e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 491:	ba 00 00 00 00       	mov    $0x0,%edx
 496:	f7 f3                	div    %ebx
 498:	89 d0                	mov    %edx,%eax
 49a:	0f b6 80 b0 0b 00 00 	movzbl 0xbb0(%eax),%eax
 4a1:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4a5:	8b 75 10             	mov    0x10(%ebp),%esi
 4a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ab:	ba 00 00 00 00       	mov    $0x0,%edx
 4b0:	f7 f6                	div    %esi
 4b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b9:	75 c7                	jne    482 <printint+0x39>
  if(neg)
 4bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4bf:	74 10                	je     4d1 <printint+0x88>
    buf[i++] = '-';
 4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c4:	8d 50 01             	lea    0x1(%eax),%edx
 4c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ca:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4cf:	eb 1f                	jmp    4f0 <printint+0xa7>
 4d1:	eb 1d                	jmp    4f0 <printint+0xa7>
    putc(fd, buf[i]);
 4d3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d9:	01 d0                	add    %edx,%eax
 4db:	0f b6 00             	movzbl (%eax),%eax
 4de:	0f be c0             	movsbl %al,%eax
 4e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	89 04 24             	mov    %eax,(%esp)
 4eb:	e8 31 ff ff ff       	call   421 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f8:	79 d9                	jns    4d3 <printint+0x8a>
    putc(fd, buf[i]);
}
 4fa:	83 c4 30             	add    $0x30,%esp
 4fd:	5b                   	pop    %ebx
 4fe:	5e                   	pop    %esi
 4ff:	5d                   	pop    %ebp
 500:	c3                   	ret    

00000501 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 501:	55                   	push   %ebp
 502:	89 e5                	mov    %esp,%ebp
 504:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 507:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 50e:	8d 45 0c             	lea    0xc(%ebp),%eax
 511:	83 c0 04             	add    $0x4,%eax
 514:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 517:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 51e:	e9 7c 01 00 00       	jmp    69f <printf+0x19e>
    c = fmt[i] & 0xff;
 523:	8b 55 0c             	mov    0xc(%ebp),%edx
 526:	8b 45 f0             	mov    -0x10(%ebp),%eax
 529:	01 d0                	add    %edx,%eax
 52b:	0f b6 00             	movzbl (%eax),%eax
 52e:	0f be c0             	movsbl %al,%eax
 531:	25 ff 00 00 00       	and    $0xff,%eax
 536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 539:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 53d:	75 2c                	jne    56b <printf+0x6a>
      if(c == '%'){
 53f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 543:	75 0c                	jne    551 <printf+0x50>
        state = '%';
 545:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 54c:	e9 4a 01 00 00       	jmp    69b <printf+0x19a>
      } else {
        putc(fd, c);
 551:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	89 44 24 04          	mov    %eax,0x4(%esp)
 55b:	8b 45 08             	mov    0x8(%ebp),%eax
 55e:	89 04 24             	mov    %eax,(%esp)
 561:	e8 bb fe ff ff       	call   421 <putc>
 566:	e9 30 01 00 00       	jmp    69b <printf+0x19a>
      }
    } else if(state == '%'){
 56b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 56f:	0f 85 26 01 00 00    	jne    69b <printf+0x19a>
      if(c == 'd'){
 575:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 579:	75 2d                	jne    5a8 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 57b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57e:	8b 00                	mov    (%eax),%eax
 580:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 587:	00 
 588:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 58f:	00 
 590:	89 44 24 04          	mov    %eax,0x4(%esp)
 594:	8b 45 08             	mov    0x8(%ebp),%eax
 597:	89 04 24             	mov    %eax,(%esp)
 59a:	e8 aa fe ff ff       	call   449 <printint>
        ap++;
 59f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a3:	e9 ec 00 00 00       	jmp    694 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5a8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5ac:	74 06                	je     5b4 <printf+0xb3>
 5ae:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b2:	75 2d                	jne    5e1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b7:	8b 00                	mov    (%eax),%eax
 5b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c0:	00 
 5c1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5c8:	00 
 5c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
 5d0:	89 04 24             	mov    %eax,(%esp)
 5d3:	e8 71 fe ff ff       	call   449 <printint>
        ap++;
 5d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5dc:	e9 b3 00 00 00       	jmp    694 <printf+0x193>
      } else if(c == 's'){
 5e1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5e5:	75 45                	jne    62c <printf+0x12b>
        s = (char*)*ap;
 5e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ea:	8b 00                	mov    (%eax),%eax
 5ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f7:	75 09                	jne    602 <printf+0x101>
          s = "(null)";
 5f9:	c7 45 f4 60 09 00 00 	movl   $0x960,-0xc(%ebp)
        while(*s != 0){
 600:	eb 1e                	jmp    620 <printf+0x11f>
 602:	eb 1c                	jmp    620 <printf+0x11f>
          putc(fd, *s);
 604:	8b 45 f4             	mov    -0xc(%ebp),%eax
 607:	0f b6 00             	movzbl (%eax),%eax
 60a:	0f be c0             	movsbl %al,%eax
 60d:	89 44 24 04          	mov    %eax,0x4(%esp)
 611:	8b 45 08             	mov    0x8(%ebp),%eax
 614:	89 04 24             	mov    %eax,(%esp)
 617:	e8 05 fe ff ff       	call   421 <putc>
          s++;
 61c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 620:	8b 45 f4             	mov    -0xc(%ebp),%eax
 623:	0f b6 00             	movzbl (%eax),%eax
 626:	84 c0                	test   %al,%al
 628:	75 da                	jne    604 <printf+0x103>
 62a:	eb 68                	jmp    694 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 62c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 630:	75 1d                	jne    64f <printf+0x14e>
        putc(fd, *ap);
 632:	8b 45 e8             	mov    -0x18(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	0f be c0             	movsbl %al,%eax
 63a:	89 44 24 04          	mov    %eax,0x4(%esp)
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	89 04 24             	mov    %eax,(%esp)
 644:	e8 d8 fd ff ff       	call   421 <putc>
        ap++;
 649:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64d:	eb 45                	jmp    694 <printf+0x193>
      } else if(c == '%'){
 64f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 653:	75 17                	jne    66c <printf+0x16b>
        putc(fd, c);
 655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 658:	0f be c0             	movsbl %al,%eax
 65b:	89 44 24 04          	mov    %eax,0x4(%esp)
 65f:	8b 45 08             	mov    0x8(%ebp),%eax
 662:	89 04 24             	mov    %eax,(%esp)
 665:	e8 b7 fd ff ff       	call   421 <putc>
 66a:	eb 28                	jmp    694 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 673:	00 
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 a2 fd ff ff       	call   421 <putc>
        putc(fd, c);
 67f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 682:	0f be c0             	movsbl %al,%eax
 685:	89 44 24 04          	mov    %eax,0x4(%esp)
 689:	8b 45 08             	mov    0x8(%ebp),%eax
 68c:	89 04 24             	mov    %eax,(%esp)
 68f:	e8 8d fd ff ff       	call   421 <putc>
      }
      state = 0;
 694:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 69f:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a5:	01 d0                	add    %edx,%eax
 6a7:	0f b6 00             	movzbl (%eax),%eax
 6aa:	84 c0                	test   %al,%al
 6ac:	0f 85 71 fe ff ff    	jne    523 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b2:	c9                   	leave  
 6b3:	c3                   	ret    

000006b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	83 e8 08             	sub    $0x8,%eax
 6c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c3:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 6c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cb:	eb 24                	jmp    6f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d5:	77 12                	ja     6e9 <free+0x35>
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6dd:	77 24                	ja     703 <free+0x4f>
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e7:	77 1a                	ja     703 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f7:	76 d4                	jbe    6cd <free+0x19>
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 701:	76 ca                	jbe    6cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	8b 40 04             	mov    0x4(%eax),%eax
 709:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	01 c2                	add    %eax,%edx
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	39 c2                	cmp    %eax,%edx
 71c:	75 24                	jne    742 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	8b 50 04             	mov    0x4(%eax),%edx
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	8b 40 04             	mov    0x4(%eax),%eax
 72c:	01 c2                	add    %eax,%edx
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	8b 10                	mov    (%eax),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 10                	mov    %edx,(%eax)
 740:	eb 0a                	jmp    74c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 742:	8b 45 fc             	mov    -0x4(%ebp),%eax
 745:	8b 10                	mov    (%eax),%edx
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 40 04             	mov    0x4(%eax),%eax
 752:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	01 d0                	add    %edx,%eax
 75e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 761:	75 20                	jne    783 <free+0xcf>
    p->s.size += bp->s.size;
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	8b 50 04             	mov    0x4(%eax),%edx
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	8b 40 04             	mov    0x4(%eax),%eax
 76f:	01 c2                	add    %eax,%edx
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 777:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77a:	8b 10                	mov    (%eax),%edx
 77c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77f:	89 10                	mov    %edx,(%eax)
 781:	eb 08                	jmp    78b <free+0xd7>
  } else
    p->s.ptr = bp;
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	8b 55 f8             	mov    -0x8(%ebp),%edx
 789:	89 10                	mov    %edx,(%eax)
  freep = p;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	a3 cc 0b 00 00       	mov    %eax,0xbcc
}
 793:	c9                   	leave  
 794:	c3                   	ret    

00000795 <morecore>:

static Header*
morecore(uint nu)
{
 795:	55                   	push   %ebp
 796:	89 e5                	mov    %esp,%ebp
 798:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a2:	77 07                	ja     7ab <morecore+0x16>
    nu = 4096;
 7a4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	c1 e0 03             	shl    $0x3,%eax
 7b1:	89 04 24             	mov    %eax,(%esp)
 7b4:	e8 28 fc ff ff       	call   3e1 <sbrk>
 7b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7bc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c0:	75 07                	jne    7c9 <morecore+0x34>
    return 0;
 7c2:	b8 00 00 00 00       	mov    $0x0,%eax
 7c7:	eb 22                	jmp    7eb <morecore+0x56>
  hp = (Header*)p;
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	8b 55 08             	mov    0x8(%ebp),%edx
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	83 c0 08             	add    $0x8,%eax
 7de:	89 04 24             	mov    %eax,(%esp)
 7e1:	e8 ce fe ff ff       	call   6b4 <free>
  return freep;
 7e6:	a1 cc 0b 00 00       	mov    0xbcc,%eax
}
 7eb:	c9                   	leave  
 7ec:	c3                   	ret    

000007ed <malloc>:

void*
malloc(uint nbytes)
{
 7ed:	55                   	push   %ebp
 7ee:	89 e5                	mov    %esp,%ebp
 7f0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f3:	8b 45 08             	mov    0x8(%ebp),%eax
 7f6:	83 c0 07             	add    $0x7,%eax
 7f9:	c1 e8 03             	shr    $0x3,%eax
 7fc:	83 c0 01             	add    $0x1,%eax
 7ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 802:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 807:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 80e:	75 23                	jne    833 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 810:	c7 45 f0 c4 0b 00 00 	movl   $0xbc4,-0x10(%ebp)
 817:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81a:	a3 cc 0b 00 00       	mov    %eax,0xbcc
 81f:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 824:	a3 c4 0b 00 00       	mov    %eax,0xbc4
    base.s.size = 0;
 829:	c7 05 c8 0b 00 00 00 	movl   $0x0,0xbc8
 830:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 833:	8b 45 f0             	mov    -0x10(%ebp),%eax
 836:	8b 00                	mov    (%eax),%eax
 838:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	8b 40 04             	mov    0x4(%eax),%eax
 841:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 844:	72 4d                	jb     893 <malloc+0xa6>
      if(p->s.size == nunits)
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	8b 40 04             	mov    0x4(%eax),%eax
 84c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84f:	75 0c                	jne    85d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 851:	8b 45 f4             	mov    -0xc(%ebp),%eax
 854:	8b 10                	mov    (%eax),%edx
 856:	8b 45 f0             	mov    -0x10(%ebp),%eax
 859:	89 10                	mov    %edx,(%eax)
 85b:	eb 26                	jmp    883 <malloc+0x96>
      else {
        p->s.size -= nunits;
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	8b 40 04             	mov    0x4(%eax),%eax
 863:	2b 45 ec             	sub    -0x14(%ebp),%eax
 866:	89 c2                	mov    %eax,%edx
 868:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 871:	8b 40 04             	mov    0x4(%eax),%eax
 874:	c1 e0 03             	shl    $0x3,%eax
 877:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 880:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 883:	8b 45 f0             	mov    -0x10(%ebp),%eax
 886:	a3 cc 0b 00 00       	mov    %eax,0xbcc
      return (void*)(p + 1);
 88b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88e:	83 c0 08             	add    $0x8,%eax
 891:	eb 38                	jmp    8cb <malloc+0xde>
    }
    if(p == freep)
 893:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 898:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 89b:	75 1b                	jne    8b8 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 89d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a0:	89 04 24             	mov    %eax,(%esp)
 8a3:	e8 ed fe ff ff       	call   795 <morecore>
 8a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8af:	75 07                	jne    8b8 <malloc+0xcb>
        return 0;
 8b1:	b8 00 00 00 00       	mov    $0x0,%eax
 8b6:	eb 13                	jmp    8cb <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	8b 00                	mov    (%eax),%eax
 8c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8c6:	e9 70 ff ff ff       	jmp    83b <malloc+0x4e>
}
 8cb:	c9                   	leave  
 8cc:	c3                   	ret    
