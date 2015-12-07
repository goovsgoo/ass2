
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 80 d6 10 80       	mov    $0x8010d680,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 17 37 10 80       	mov    $0x80103717,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 5c 90 10 	movl   $0x8010905c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 b3 54 00 00       	call   80105501 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 60 54 00 00       	call   80105522 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 7b 54 00 00       	call   80105584 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 3c 4e 00 00       	call   80104f60 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 03 54 00 00       	call   80105584 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 63 90 10 80 	movl   $0x80109063,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 c9 25 00 00       	call   801027a1 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 74 90 10 80 	movl   $0x80109074,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 8c 25 00 00       	call   801027a1 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 7b 90 10 80 	movl   $0x8010907b,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 e1 52 00 00       	call   80105522 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 a5 4d 00 00       	call   80105047 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 d6 52 00 00       	call   80105584 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bb:	e8 62 51 00 00       	call   80105522 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 82 90 10 80 	movl   $0x80109082,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 8b 90 10 80 	movl   $0x8010908b,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100533:	e8 4c 50 00 00       	call   80105584 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 92 90 10 80 	movl   $0x80109092,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 a1 90 10 80 	movl   $0x801090a1,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 3f 50 00 00       	call   801055d3 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 a3 90 10 80 	movl   $0x801090a3,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 8e 51 00 00       	call   80105845 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 90 50 00 00       	call   80105776 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 22 6f 00 00       	call   8010769d <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 16 6f 00 00       	call   8010769d <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 0a 6f 00 00       	call   8010769d <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 fd 6e 00 00       	call   8010769d <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801007ba:	e8 63 4d 00 00       	call   80105522 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 09 49 00 00       	call   801050f8 <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100816:	a1 58 18 11 80       	mov    0x80111858,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100840:	a1 58 18 11 80       	mov    0x80111858,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010087c:	a1 54 18 11 80       	mov    0x80111854,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 17 11 80    	mov    %al,-0x7feee82c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008d5:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008e7:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801008ec:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801008f3:	e8 4f 47 00 00       	call   80105047 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100914:	e8 6b 4c 00 00       	call   80105584 <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 7d 10 00 00       	call   801019a9 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100939:	e8 e4 4b 00 00       	call   80105522 <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 28             	mov    0x28(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100959:	e8 26 4c 00 00       	call   80105584 <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 f2 0e 00 00       	call   8010185b <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
80100982:	e8 d9 45 00 00       	call   80104f60 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 18 11 80    	mov    0x80111854,%edx
8010098d:	a1 58 18 11 80       	mov    0x80111858,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 18 11 80       	mov    0x80111854,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 54 18 11 80       	mov    0x80111854,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801009fe:	e8 81 4b 00 00       	call   80105584 <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 4d 0e 00 00       	call   8010185b <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 7e 0f 00 00       	call   801019a9 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a32:	e8 eb 4a 00 00       	call   80105522 <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a6c:	e8 13 4b 00 00       	call   80105584 <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 df 0d 00 00       	call   8010185b <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 a7 90 10 	movl   $0x801090a7,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a96:	e8 66 4a 00 00       	call   80105501 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 af 90 10 	movl   $0x801090af,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100aaa:	e8 52 4a 00 00       	call   80105501 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c 22 11 80 1a 	movl   $0x80100a1a,0x8011220c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 22 11 80 1b 	movl   $0x8010091b,0x80112208
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 db 32 00 00       	call   80103db4 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 70 1e 00 00       	call   8010295d <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100af8:	e8 13 29 00 00       	call   80103410 <begin_op>
  if((ip = namei(path)) == 0){
80100afd:	8b 45 08             	mov    0x8(%ebp),%eax
80100b00:	89 04 24             	mov    %eax,(%esp)
80100b03:	e8 fe 18 00 00       	call   80102406 <namei>
80100b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b0b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0f:	75 0f                	jne    80100b20 <exec+0x31>
    end_op();
80100b11:	e8 7e 29 00 00       	call   80103494 <end_op>
    return -1;
80100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1b:	e9 e8 03 00 00       	jmp    80100f08 <exec+0x419>
  }
  ilock(ip);
80100b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b23:	89 04 24             	mov    %eax,(%esp)
80100b26:	e8 30 0d 00 00       	call   8010185b <ilock>
  pgdir = 0;
80100b2b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b32:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b39:	00 
80100b3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b41:	00 
80100b42:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b4f:	89 04 24             	mov    %eax,(%esp)
80100b52:	e8 11 12 00 00       	call   80101d68 <readi>
80100b57:	83 f8 33             	cmp    $0x33,%eax
80100b5a:	77 05                	ja     80100b61 <exec+0x72>
    goto bad;
80100b5c:	e9 7b 03 00 00       	jmp    80100edc <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b61:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b67:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6c:	74 05                	je     80100b73 <exec+0x84>
    goto bad;
80100b6e:	e9 69 03 00 00       	jmp    80100edc <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b73:	e8 76 7c 00 00       	call   801087ee <setupkvm>
80100b78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b7f:	75 05                	jne    80100b86 <exec+0x97>
    goto bad;
80100b81:	e9 56 03 00 00       	jmp    80100edc <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b94:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9d:	e9 cb 00 00 00       	jmp    80100c6d <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bac:	00 
80100bad:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb1:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbe:	89 04 24             	mov    %eax,(%esp)
80100bc1:	e8 a2 11 00 00       	call   80101d68 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	74 05                	je     80100bd0 <exec+0xe1>
      goto bad;
80100bcb:	e9 0c 03 00 00       	jmp    80100edc <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100bd0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd6:	83 f8 01             	cmp    $0x1,%eax
80100bd9:	74 05                	je     80100be0 <exec+0xf1>
      continue;
80100bdb:	e9 80 00 00 00       	jmp    80100c60 <exec+0x171>
    if(ph.memsz < ph.filesz)
80100be0:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be6:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bec:	39 c2                	cmp    %eax,%edx
80100bee:	73 05                	jae    80100bf5 <exec+0x106>
      goto bad;
80100bf0:	e9 e7 02 00 00       	jmp    80100edc <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 a3 7f 00 00       	call   80108bbc <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	75 05                	jne    80100c27 <exec+0x138>
      goto bad;
80100c22:	e9 b5 02 00 00       	jmp    80100edc <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c27:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c33:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c39:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c41:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c44:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4f:	89 04 24             	mov    %eax,(%esp)
80100c52:	e8 7a 7e 00 00       	call   80108ad1 <loaduvm>
80100c57:	85 c0                	test   %eax,%eax
80100c59:	79 05                	jns    80100c60 <exec+0x171>
      goto bad;
80100c5b:	e9 7c 02 00 00       	jmp    80100edc <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c60:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c67:	83 c0 20             	add    $0x20,%eax
80100c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6d:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c74:	0f b7 c0             	movzwl %ax,%eax
80100c77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7a:	0f 8f 22 ff ff ff    	jg     80100ba2 <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c80:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c83:	89 04 24             	mov    %eax,(%esp)
80100c86:	e8 54 0e 00 00       	call   80101adf <iunlockput>
  end_op();
80100c8b:	e8 04 28 00 00       	call   80103494 <end_op>
  ip = 0;
80100c90:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9a:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100caa:	05 00 20 00 00       	add    $0x2000,%eax
80100caf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 f7 7e 00 00       	call   80108bbc <allocuvm>
80100cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ccc:	75 05                	jne    80100cd3 <exec+0x1e4>
    goto bad;
80100cce:	e9 09 02 00 00       	jmp    80100edc <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce2:	89 04 24             	mov    %eax,(%esp)
80100ce5:	e8 02 81 00 00       	call   80108dec <clearpteu>
  sp = sz;
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf7:	e9 9a 00 00 00       	jmp    80100d96 <exec+0x2a7>
    if(argc >= MAXARG)
80100cfc:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d00:	76 05                	jbe    80100d07 <exec+0x218>
      goto bad;
80100d02:	e9 d5 01 00 00       	jmp    80100edc <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d14:	01 d0                	add    %edx,%eax
80100d16:	8b 00                	mov    (%eax),%eax
80100d18:	89 04 24             	mov    %eax,(%esp)
80100d1b:	e8 c0 4c 00 00       	call   801059e0 <strlen>
80100d20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d23:	29 c2                	sub    %eax,%edx
80100d25:	89 d0                	mov    %edx,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	83 e0 fc             	and    $0xfffffffc,%eax
80100d2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d3d:	01 d0                	add    %edx,%eax
80100d3f:	8b 00                	mov    (%eax),%eax
80100d41:	89 04 24             	mov    %eax,(%esp)
80100d44:	e8 97 4c 00 00       	call   801059e0 <strlen>
80100d49:	83 c0 01             	add    $0x1,%eax
80100d4c:	89 c2                	mov    %eax,%edx
80100d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d51:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	01 c8                	add    %ecx,%eax
80100d5d:	8b 00                	mov    (%eax),%eax
80100d5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d63:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d71:	89 04 24             	mov    %eax,(%esp)
80100d74:	e8 38 82 00 00       	call   80108fb1 <copyout>
80100d79:	85 c0                	test   %eax,%eax
80100d7b:	79 05                	jns    80100d82 <exec+0x293>
      goto bad;
80100d7d:	e9 5a 01 00 00       	jmp    80100edc <exec+0x3ed>
    ustack[3+argc] = sp;
80100d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d85:	8d 50 03             	lea    0x3(%eax),%edx
80100d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d8b:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d92:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100da3:	01 d0                	add    %edx,%eax
80100da5:	8b 00                	mov    (%eax),%eax
80100da7:	85 c0                	test   %eax,%eax
80100da9:	0f 85 4d ff ff ff    	jne    80100cfc <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 03             	add    $0x3,%eax
80100db5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dbc:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dc0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dc7:	ff ff ff 
  ustack[1] = argc;
80100dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 01             	add    $0x1,%eax
80100dd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de3:	29 d0                	sub    %edx,%eax
80100de5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	83 c0 04             	add    $0x4,%eax
80100df1:	c1 e0 02             	shl    $0x2,%eax
80100df4:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	83 c0 04             	add    $0x4,%eax
80100dfd:	c1 e0 02             	shl    $0x2,%eax
80100e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e04:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e18:	89 04 24             	mov    %eax,(%esp)
80100e1b:	e8 91 81 00 00       	call   80108fb1 <copyout>
80100e20:	85 c0                	test   %eax,%eax
80100e22:	79 05                	jns    80100e29 <exec+0x33a>
    goto bad;
80100e24:	e9 b3 00 00 00       	jmp    80100edc <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e29:	8b 45 08             	mov    0x8(%ebp),%eax
80100e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e35:	eb 17                	jmp    80100e4e <exec+0x35f>
    if(*s == '/')
80100e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3a:	0f b6 00             	movzbl (%eax),%eax
80100e3d:	3c 2f                	cmp    $0x2f,%al
80100e3f:	75 09                	jne    80100e4a <exec+0x35b>
      last = s+1;
80100e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e44:	83 c0 01             	add    $0x1,%eax
80100e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e51:	0f b6 00             	movzbl (%eax),%eax
80100e54:	84 c0                	test   %al,%al
80100e56:	75 df                	jne    80100e37 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5e:	8d 50 70             	lea    0x70(%eax),%edx
80100e61:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e68:	00 
80100e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e70:	89 14 24             	mov    %edx,(%esp)
80100e73:	e8 1e 4b 00 00       	call   80105996 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7e:	8b 40 04             	mov    0x4(%eax),%eax
80100e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e8d:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e99:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea1:	8b 40 18             	mov    0x18(%eax),%eax
80100ea4:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100eaa:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	8b 40 18             	mov    0x18(%eax),%eax
80100eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec2:	89 04 24             	mov    %eax,(%esp)
80100ec5:	e8 15 7a 00 00       	call   801088df <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 7d 7e 00 00       	call   80108d52 <freevm>
  return 0;
80100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eda:	eb 2c                	jmp    80100f08 <exec+0x419>

 bad:
  if(pgdir)
80100edc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee0:	74 0b                	je     80100eed <exec+0x3fe>
    freevm(pgdir);
80100ee2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee5:	89 04 24             	mov    %eax,(%esp)
80100ee8:	e8 65 7e 00 00       	call   80108d52 <freevm>
  if(ip){
80100eed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef1:	74 10                	je     80100f03 <exec+0x414>
    iunlockput(ip);
80100ef3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef6:	89 04 24             	mov    %eax,(%esp)
80100ef9:	e8 e1 0b 00 00       	call   80101adf <iunlockput>
    end_op();
80100efe:	e8 91 25 00 00       	call   80103494 <end_op>
  }
  return -1;
80100f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f08:	c9                   	leave  
80100f09:	c3                   	ret    

80100f0a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0a:	55                   	push   %ebp
80100f0b:	89 e5                	mov    %esp,%ebp
80100f0d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f10:	c7 44 24 04 b5 90 10 	movl   $0x801090b5,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f1f:	e8 dd 45 00 00       	call   80105501 <initlock>
}
80100f24:	c9                   	leave  
80100f25:	c3                   	ret    

80100f26 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f26:	55                   	push   %ebp
80100f27:	89 e5                	mov    %esp,%ebp
80100f29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2c:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f33:	e8 ea 45 00 00       	call   80105522 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f38:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f3f:	eb 29                	jmp    80100f6a <filealloc+0x44>
    if(f->ref == 0){
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	8b 40 04             	mov    0x4(%eax),%eax
80100f47:	85 c0                	test   %eax,%eax
80100f49:	75 1b                	jne    80100f66 <filealloc+0x40>
      f->ref = 1;
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f55:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f5c:	e8 23 46 00 00       	call   80105584 <release>
      return f;
80100f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f64:	eb 1e                	jmp    80100f84 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6a:	81 7d f4 f4 21 11 80 	cmpl   $0x801121f4,-0xc(%ebp)
80100f71:	72 ce                	jb     80100f41 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f73:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f7a:	e8 05 46 00 00       	call   80105584 <release>
  return 0;
80100f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f84:	c9                   	leave  
80100f85:	c3                   	ret    

80100f86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f86:	55                   	push   %ebp
80100f87:	89 e5                	mov    %esp,%ebp
80100f89:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8c:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f93:	e8 8a 45 00 00       	call   80105522 <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 bc 90 10 80 	movl   $0x801090bc,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fc4:	e8 bb 45 00 00       	call   80105584 <release>
  return f;
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fcc:	c9                   	leave  
80100fcd:	c3                   	ret    

80100fce <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fce:	55                   	push   %ebp
80100fcf:	89 e5                	mov    %esp,%ebp
80100fd1:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd4:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fdb:	e8 42 45 00 00       	call   80105522 <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 c4 90 10 80 	movl   $0x801090c4,(%esp)
80100ff1:	e8 44 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fff:	8b 45 08             	mov    0x8(%ebp),%eax
80101002:	89 50 04             	mov    %edx,0x4(%eax)
80101005:	8b 45 08             	mov    0x8(%ebp),%eax
80101008:	8b 40 04             	mov    0x4(%eax),%eax
8010100b:	85 c0                	test   %eax,%eax
8010100d:	7e 11                	jle    80101020 <fileclose+0x52>
    release(&ftable.lock);
8010100f:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101016:	e8 69 45 00 00       	call   80105584 <release>
8010101b:	e9 82 00 00 00       	jmp    801010a2 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101020:	8b 45 08             	mov    0x8(%ebp),%eax
80101023:	8b 10                	mov    (%eax),%edx
80101025:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101028:	8b 50 04             	mov    0x4(%eax),%edx
8010102b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010102e:	8b 50 08             	mov    0x8(%eax),%edx
80101031:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101034:	8b 50 0c             	mov    0xc(%eax),%edx
80101037:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103a:	8b 50 10             	mov    0x10(%eax),%edx
8010103d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101040:	8b 40 14             	mov    0x14(%eax),%eax
80101043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101050:	8b 45 08             	mov    0x8(%ebp),%eax
80101053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101059:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101060:	e8 1f 45 00 00       	call   80105584 <release>
  
  if(ff.type == FD_PIPE)
80101065:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101068:	83 f8 01             	cmp    $0x1,%eax
8010106b:	75 18                	jne    80101085 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101071:	0f be d0             	movsbl %al,%edx
80101074:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101077:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107b:	89 04 24             	mov    %eax,(%esp)
8010107e:	e8 e1 2f 00 00       	call   80104064 <pipeclose>
80101083:	eb 1d                	jmp    801010a2 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101085:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101088:	83 f8 02             	cmp    $0x2,%eax
8010108b:	75 15                	jne    801010a2 <fileclose+0xd4>
    begin_op();
8010108d:	e8 7e 23 00 00       	call   80103410 <begin_op>
    iput(ff.ip);
80101092:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101095:	89 04 24             	mov    %eax,(%esp)
80101098:	e8 71 09 00 00       	call   80101a0e <iput>
    end_op();
8010109d:	e8 f2 23 00 00       	call   80103494 <end_op>
  }
}
801010a2:	c9                   	leave  
801010a3:	c3                   	ret    

801010a4 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 00                	mov    (%eax),%eax
801010af:	83 f8 02             	cmp    $0x2,%eax
801010b2:	75 38                	jne    801010ec <filestat+0x48>
    ilock(f->ip);
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	8b 40 10             	mov    0x10(%eax),%eax
801010ba:	89 04 24             	mov    %eax,(%esp)
801010bd:	e8 99 07 00 00       	call   8010185b <ilock>
    stati(f->ip, st);
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8b 40 10             	mov    0x10(%eax),%eax
801010c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801010cf:	89 04 24             	mov    %eax,(%esp)
801010d2:	e8 4c 0c 00 00       	call   80101d23 <stati>
    iunlock(f->ip);
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 10             	mov    0x10(%eax),%eax
801010dd:	89 04 24             	mov    %eax,(%esp)
801010e0:	e8 c4 08 00 00       	call   801019a9 <iunlock>
    return 0;
801010e5:	b8 00 00 00 00       	mov    $0x0,%eax
801010ea:	eb 05                	jmp    801010f1 <filestat+0x4d>
  }
  return -1;
801010ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f1:	c9                   	leave  
801010f2:	c3                   	ret    

801010f3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f3:	55                   	push   %ebp
801010f4:	89 e5                	mov    %esp,%ebp
801010f6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010f9:	8b 45 08             	mov    0x8(%ebp),%eax
801010fc:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101100:	84 c0                	test   %al,%al
80101102:	75 0a                	jne    8010110e <fileread+0x1b>
    return -1;
80101104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101109:	e9 9f 00 00 00       	jmp    801011ad <fileread+0xba>
  if(f->type == FD_PIPE)
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 00                	mov    (%eax),%eax
80101113:	83 f8 01             	cmp    $0x1,%eax
80101116:	75 1e                	jne    80101136 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 0c             	mov    0xc(%eax),%eax
8010111e:	8b 55 10             	mov    0x10(%ebp),%edx
80101121:	89 54 24 08          	mov    %edx,0x8(%esp)
80101125:	8b 55 0c             	mov    0xc(%ebp),%edx
80101128:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112c:	89 04 24             	mov    %eax,(%esp)
8010112f:	e8 b1 30 00 00       	call   801041e5 <piperead>
80101134:	eb 77                	jmp    801011ad <fileread+0xba>
  if(f->type == FD_INODE){
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 00                	mov    (%eax),%eax
8010113b:	83 f8 02             	cmp    $0x2,%eax
8010113e:	75 61                	jne    801011a1 <fileread+0xae>
    ilock(f->ip);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 0d 07 00 00       	call   8010185b <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010114e:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101151:	8b 45 08             	mov    0x8(%ebp),%eax
80101154:	8b 50 14             	mov    0x14(%eax),%edx
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 10             	mov    0x10(%eax),%eax
8010115d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101161:	89 54 24 08          	mov    %edx,0x8(%esp)
80101165:	8b 55 0c             	mov    0xc(%ebp),%edx
80101168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116c:	89 04 24             	mov    %eax,(%esp)
8010116f:	e8 f4 0b 00 00       	call   80101d68 <readi>
80101174:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101177:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117b:	7e 11                	jle    8010118e <fileread+0x9b>
      f->off += r;
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	8b 50 14             	mov    0x14(%eax),%edx
80101183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101186:	01 c2                	add    %eax,%edx
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 10             	mov    0x10(%eax),%eax
80101194:	89 04 24             	mov    %eax,(%esp)
80101197:	e8 0d 08 00 00       	call   801019a9 <iunlock>
    return r;
8010119c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119f:	eb 0c                	jmp    801011ad <fileread+0xba>
  }
  panic("fileread");
801011a1:	c7 04 24 ce 90 10 80 	movl   $0x801090ce,(%esp)
801011a8:	e8 8d f3 ff ff       	call   8010053a <panic>
}
801011ad:	c9                   	leave  
801011ae:	c3                   	ret    

801011af <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011af:	55                   	push   %ebp
801011b0:	89 e5                	mov    %esp,%ebp
801011b2:	53                   	push   %ebx
801011b3:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bd:	84 c0                	test   %al,%al
801011bf:	75 0a                	jne    801011cb <filewrite+0x1c>
    return -1;
801011c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c6:	e9 20 01 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 00                	mov    (%eax),%eax
801011d0:	83 f8 01             	cmp    $0x1,%eax
801011d3:	75 21                	jne    801011f6 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 0c             	mov    0xc(%eax),%eax
801011db:	8b 55 10             	mov    0x10(%ebp),%edx
801011de:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011e9:	89 04 24             	mov    %eax,(%esp)
801011ec:	e8 05 2f 00 00       	call   801040f6 <pipewrite>
801011f1:	e9 f5 00 00 00       	jmp    801012eb <filewrite+0x13c>
  if(f->type == FD_INODE){
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 00                	mov    (%eax),%eax
801011fb:	83 f8 02             	cmp    $0x2,%eax
801011fe:	0f 85 db 00 00 00    	jne    801012df <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101204:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101212:	e9 a8 00 00 00       	jmp    801012bf <filewrite+0x110>
      int n1 = n - i;
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	8b 55 10             	mov    0x10(%ebp),%edx
8010121d:	29 c2                	sub    %eax,%edx
8010121f:	89 d0                	mov    %edx,%eax
80101221:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101227:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122a:	7e 06                	jle    80101232 <filewrite+0x83>
        n1 = max;
8010122c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010122f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101232:	e8 d9 21 00 00       	call   80103410 <begin_op>
      ilock(f->ip);
80101237:	8b 45 08             	mov    0x8(%ebp),%eax
8010123a:	8b 40 10             	mov    0x10(%eax),%eax
8010123d:	89 04 24             	mov    %eax,(%esp)
80101240:	e8 16 06 00 00       	call   8010185b <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101245:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 50 14             	mov    0x14(%eax),%edx
8010124e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101251:	8b 45 0c             	mov    0xc(%ebp),%eax
80101254:	01 c3                	add    %eax,%ebx
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 40 10             	mov    0x10(%eax),%eax
8010125c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101260:	89 54 24 08          	mov    %edx,0x8(%esp)
80101264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101268:	89 04 24             	mov    %eax,(%esp)
8010126b:	e8 5c 0c 00 00       	call   80101ecc <writei>
80101270:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101273:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101277:	7e 11                	jle    8010128a <filewrite+0xdb>
        f->off += r;
80101279:	8b 45 08             	mov    0x8(%ebp),%eax
8010127c:	8b 50 14             	mov    0x14(%eax),%edx
8010127f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101282:	01 c2                	add    %eax,%edx
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	89 04 24             	mov    %eax,(%esp)
80101293:	e8 11 07 00 00       	call   801019a9 <iunlock>
      end_op();
80101298:	e8 f7 21 00 00       	call   80103494 <end_op>

      if(r < 0)
8010129d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a1:	79 02                	jns    801012a5 <filewrite+0xf6>
        break;
801012a3:	eb 26                	jmp    801012cb <filewrite+0x11c>
      if(r != n1)
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ab:	74 0c                	je     801012b9 <filewrite+0x10a>
        panic("short filewrite");
801012ad:	c7 04 24 d7 90 10 80 	movl   $0x801090d7,(%esp)
801012b4:	e8 81 f2 ff ff       	call   8010053a <panic>
      i += r;
801012b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012bc:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c5:	0f 8c 4c ff ff ff    	jl     80101217 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d1:	75 05                	jne    801012d8 <filewrite+0x129>
801012d3:	8b 45 10             	mov    0x10(%ebp),%eax
801012d6:	eb 05                	jmp    801012dd <filewrite+0x12e>
801012d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012dd:	eb 0c                	jmp    801012eb <filewrite+0x13c>
  }
  panic("filewrite");
801012df:	c7 04 24 e7 90 10 80 	movl   $0x801090e7,(%esp)
801012e6:	e8 4f f2 ff ff       	call   8010053a <panic>
}
801012eb:	83 c4 24             	add    $0x24,%esp
801012ee:	5b                   	pop    %ebx
801012ef:	5d                   	pop    %ebp
801012f0:	c3                   	ret    

801012f1 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f1:	55                   	push   %ebp
801012f2:	89 e5                	mov    %esp,%ebp
801012f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101301:	00 
80101302:	89 04 24             	mov    %eax,(%esp)
80101305:	e8 9c ee ff ff       	call   801001a6 <bread>
8010130a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	83 c0 18             	add    $0x18,%eax
80101313:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010131a:	00 
8010131b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101322:	89 04 24             	mov    %eax,(%esp)
80101325:	e8 1b 45 00 00       	call   80105845 <memmove>
  brelse(bp);
8010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132d:	89 04 24             	mov    %eax,(%esp)
80101330:	e8 e2 ee ff ff       	call   80100217 <brelse>
}
80101335:	c9                   	leave  
80101336:	c3                   	ret    

80101337 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101337:	55                   	push   %ebp
80101338:	89 e5                	mov    %esp,%ebp
8010133a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010133d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	89 54 24 04          	mov    %edx,0x4(%esp)
80101347:	89 04 24             	mov    %eax,(%esp)
8010134a:	e8 57 ee ff ff       	call   801001a6 <bread>
8010134f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	83 c0 18             	add    $0x18,%eax
80101358:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135f:	00 
80101360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101367:	00 
80101368:	89 04 24             	mov    %eax,(%esp)
8010136b:	e8 06 44 00 00       	call   80105776 <memset>
  log_write(bp);
80101370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101373:	89 04 24             	mov    %eax,(%esp)
80101376:	e8 a0 22 00 00       	call   8010361b <log_write>
  brelse(bp);
8010137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137e:	89 04 24             	mov    %eax,(%esp)
80101381:	e8 91 ee ff ff       	call   80100217 <brelse>
}
80101386:	c9                   	leave  
80101387:	c3                   	ret    

80101388 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101388:	55                   	push   %ebp
80101389:	89 e5                	mov    %esp,%ebp
8010138b:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010139b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139f:	89 04 24             	mov    %eax,(%esp)
801013a2:	e8 4a ff ff ff       	call   801012f1 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ae:	e9 07 01 00 00       	jmp    801014ba <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013bc:	85 c0                	test   %eax,%eax
801013be:	0f 48 c2             	cmovs  %edx,%eax
801013c1:	c1 f8 0c             	sar    $0xc,%eax
801013c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c7:	c1 ea 03             	shr    $0x3,%edx
801013ca:	01 d0                	add    %edx,%eax
801013cc:	83 c0 03             	add    $0x3,%eax
801013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	89 04 24             	mov    %eax,(%esp)
801013d9:	e8 c8 ed ff ff       	call   801001a6 <bread>
801013de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e8:	e9 9d 00 00 00       	jmp    8010148a <balloc+0x102>
      m = 1 << (bi % 8);
801013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f0:	99                   	cltd   
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 c1                	mov    %eax,%ecx
80101402:	d3 e2                	shl    %cl,%edx
80101404:	89 d0                	mov    %edx,%eax
80101406:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140c:	8d 50 07             	lea    0x7(%eax),%edx
8010140f:	85 c0                	test   %eax,%eax
80101411:	0f 48 c2             	cmovs  %edx,%eax
80101414:	c1 f8 03             	sar    $0x3,%eax
80101417:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010141f:	0f b6 c0             	movzbl %al,%eax
80101422:	23 45 e8             	and    -0x18(%ebp),%eax
80101425:	85 c0                	test   %eax,%eax
80101427:	75 5d                	jne    80101486 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142c:	8d 50 07             	lea    0x7(%eax),%edx
8010142f:	85 c0                	test   %eax,%eax
80101431:	0f 48 c2             	cmovs  %edx,%eax
80101434:	c1 f8 03             	sar    $0x3,%eax
80101437:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010143f:	89 d1                	mov    %edx,%ecx
80101441:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101444:	09 ca                	or     %ecx,%edx
80101446:	89 d1                	mov    %edx,%ecx
80101448:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010144f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101452:	89 04 24             	mov    %eax,(%esp)
80101455:	e8 c1 21 00 00       	call   8010361b <log_write>
        brelse(bp);
8010145a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145d:	89 04 24             	mov    %eax,(%esp)
80101460:	e8 b2 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101468:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146b:	01 c2                	add    %eax,%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	89 54 24 04          	mov    %edx,0x4(%esp)
80101474:	89 04 24             	mov    %eax,(%esp)
80101477:	e8 bb fe ff ff       	call   80101337 <bzero>
        return b + bi;
8010147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101482:	01 d0                	add    %edx,%eax
80101484:	eb 4e                	jmp    801014d4 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101486:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010148a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101491:	7f 15                	jg     801014a8 <balloc+0x120>
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101499:	01 d0                	add    %edx,%eax
8010149b:	89 c2                	mov    %eax,%edx
8010149d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a0:	39 c2                	cmp    %eax,%edx
801014a2:	0f 82 45 ff ff ff    	jb     801013ed <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014ab:	89 04 24             	mov    %eax,(%esp)
801014ae:	e8 64 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c0:	39 c2                	cmp    %eax,%edx
801014c2:	0f 82 eb fe ff ff    	jb     801013b3 <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014c8:	c7 04 24 f1 90 10 80 	movl   $0x801090f1,(%esp)
801014cf:	e8 66 f0 ff ff       	call   8010053a <panic>
}
801014d4:	c9                   	leave  
801014d5:	c3                   	ret    

801014d6 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d6:	55                   	push   %ebp
801014d7:	89 e5                	mov    %esp,%ebp
801014d9:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014df:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e3:	8b 45 08             	mov    0x8(%ebp),%eax
801014e6:	89 04 24             	mov    %eax,(%esp)
801014e9:	e8 03 fe ff ff       	call   801012f1 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	c1 e8 0c             	shr    $0xc,%eax
801014f4:	89 c2                	mov    %eax,%edx
801014f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014f9:	c1 e8 03             	shr    $0x3,%eax
801014fc:	01 d0                	add    %edx,%eax
801014fe:	8d 50 03             	lea    0x3(%eax),%edx
80101501:	8b 45 08             	mov    0x8(%ebp),%eax
80101504:	89 54 24 04          	mov    %edx,0x4(%esp)
80101508:	89 04 24             	mov    %eax,(%esp)
8010150b:	e8 96 ec ff ff       	call   801001a6 <bread>
80101510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101513:	8b 45 0c             	mov    0xc(%ebp),%eax
80101516:	25 ff 0f 00 00       	and    $0xfff,%eax
8010151b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101521:	99                   	cltd   
80101522:	c1 ea 1d             	shr    $0x1d,%edx
80101525:	01 d0                	add    %edx,%eax
80101527:	83 e0 07             	and    $0x7,%eax
8010152a:	29 d0                	sub    %edx,%eax
8010152c:	ba 01 00 00 00       	mov    $0x1,%edx
80101531:	89 c1                	mov    %eax,%ecx
80101533:	d3 e2                	shl    %cl,%edx
80101535:	89 d0                	mov    %edx,%eax
80101537:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	8d 50 07             	lea    0x7(%eax),%edx
80101540:	85 c0                	test   %eax,%eax
80101542:	0f 48 c2             	cmovs  %edx,%eax
80101545:	c1 f8 03             	sar    $0x3,%eax
80101548:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154b:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101550:	0f b6 c0             	movzbl %al,%eax
80101553:	23 45 ec             	and    -0x14(%ebp),%eax
80101556:	85 c0                	test   %eax,%eax
80101558:	75 0c                	jne    80101566 <bfree+0x90>
    panic("freeing free block");
8010155a:	c7 04 24 07 91 10 80 	movl   $0x80109107,(%esp)
80101561:	e8 d4 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101569:	8d 50 07             	lea    0x7(%eax),%edx
8010156c:	85 c0                	test   %eax,%eax
8010156e:	0f 48 c2             	cmovs  %edx,%eax
80101571:	c1 f8 03             	sar    $0x3,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010157f:	f7 d1                	not    %ecx
80101581:	21 ca                	and    %ecx,%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101588:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 84 20 00 00       	call   8010361b <log_write>
  brelse(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 75 ec ff ff       	call   80100217 <brelse>
}
801015a2:	c9                   	leave  
801015a3:	c3                   	ret    

801015a4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015a4:	55                   	push   %ebp
801015a5:	89 e5                	mov    %esp,%ebp
801015a7:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015aa:	c7 44 24 04 1a 91 10 	movl   $0x8010911a,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015b9:	e8 43 3f 00 00       	call   80105501 <initlock>
}
801015be:	c9                   	leave  
801015bf:	c3                   	ret    

801015c0 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015c0:	55                   	push   %ebp
801015c1:	89 e5                	mov    %esp,%ebp
801015c3:	83 ec 38             	sub    $0x38,%esp
801015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c9:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015cd:	8b 45 08             	mov    0x8(%ebp),%eax
801015d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d7:	89 04 24             	mov    %eax,(%esp)
801015da:	e8 12 fd ff ff       	call   801012f1 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015df:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015e6:	e9 98 00 00 00       	jmp    80101683 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ee:	c1 e8 03             	shr    $0x3,%eax
801015f1:	83 c0 02             	add    $0x2,%eax
801015f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f8:	8b 45 08             	mov    0x8(%ebp),%eax
801015fb:	89 04 24             	mov    %eax,(%esp)
801015fe:	e8 a3 eb ff ff       	call   801001a6 <bread>
80101603:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101606:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101609:	8d 50 18             	lea    0x18(%eax),%edx
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	83 e0 07             	and    $0x7,%eax
80101612:	c1 e0 06             	shl    $0x6,%eax
80101615:	01 d0                	add    %edx,%eax
80101617:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010161a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010161d:	0f b7 00             	movzwl (%eax),%eax
80101620:	66 85 c0             	test   %ax,%ax
80101623:	75 4f                	jne    80101674 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101625:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010162c:	00 
8010162d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101634:	00 
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	89 04 24             	mov    %eax,(%esp)
8010163b:	e8 36 41 00 00       	call   80105776 <memset>
      dip->type = type;
80101640:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101643:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101647:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	89 04 24             	mov    %eax,(%esp)
80101650:	e8 c6 1f 00 00       	call   8010361b <log_write>
      brelse(bp);
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	89 04 24             	mov    %eax,(%esp)
8010165b:	e8 b7 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101663:	89 44 24 04          	mov    %eax,0x4(%esp)
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	89 04 24             	mov    %eax,(%esp)
8010166d:	e8 e5 00 00 00       	call   80101757 <iget>
80101672:	eb 29                	jmp    8010169d <ialloc+0xdd>
    }
    brelse(bp);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 98 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010167f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101683:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101689:	39 c2                	cmp    %eax,%edx
8010168b:	0f 82 5a ff ff ff    	jb     801015eb <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101691:	c7 04 24 21 91 10 80 	movl   $0x80109121,(%esp)
80101698:	e8 9d ee ff ff       	call   8010053a <panic>
}
8010169d:	c9                   	leave  
8010169e:	c3                   	ret    

8010169f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010169f:	55                   	push   %ebp
801016a0:	89 e5                	mov    %esp,%ebp
801016a2:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	8b 40 04             	mov    0x4(%eax),%eax
801016ab:	c1 e8 03             	shr    $0x3,%eax
801016ae:	8d 50 02             	lea    0x2(%eax),%edx
801016b1:	8b 45 08             	mov    0x8(%ebp),%eax
801016b4:	8b 00                	mov    (%eax),%eax
801016b6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ba:	89 04 24             	mov    %eax,(%esp)
801016bd:	e8 e4 ea ff ff       	call   801001a6 <bread>
801016c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c8:	8d 50 18             	lea    0x18(%eax),%edx
801016cb:	8b 45 08             	mov    0x8(%ebp),%eax
801016ce:	8b 40 04             	mov    0x4(%eax),%eax
801016d1:	83 e0 07             	and    $0x7,%eax
801016d4:	c1 e0 06             	shl    $0x6,%eax
801016d7:	01 d0                	add    %edx,%eax
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e6:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101701:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101705:	8b 45 08             	mov    0x8(%ebp),%eax
80101708:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101713:	8b 45 08             	mov    0x8(%ebp),%eax
80101716:	8b 50 18             	mov    0x18(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010171f:	8b 45 08             	mov    0x8(%ebp),%eax
80101722:	8d 50 1c             	lea    0x1c(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	83 c0 0c             	add    $0xc,%eax
8010172b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101732:	00 
80101733:	89 54 24 04          	mov    %edx,0x4(%esp)
80101737:	89 04 24             	mov    %eax,(%esp)
8010173a:	e8 06 41 00 00       	call   80105845 <memmove>
  log_write(bp);
8010173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101742:	89 04 24             	mov    %eax,(%esp)
80101745:	e8 d1 1e 00 00       	call   8010361b <log_write>
  brelse(bp);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	89 04 24             	mov    %eax,(%esp)
80101750:	e8 c2 ea ff ff       	call   80100217 <brelse>
}
80101755:	c9                   	leave  
80101756:	c3                   	ret    

80101757 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101757:	55                   	push   %ebp
80101758:	89 e5                	mov    %esp,%ebp
8010175a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010175d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101764:	e8 b9 3d 00 00       	call   80105522 <acquire>

  // Is the inode already cached?
  empty = 0;
80101769:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101770:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101777:	eb 59                	jmp    801017d2 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 08             	mov    0x8(%eax),%eax
8010177f:	85 c0                	test   %eax,%eax
80101781:	7e 35                	jle    801017b8 <iget+0x61>
80101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101786:	8b 00                	mov    (%eax),%eax
80101788:	3b 45 08             	cmp    0x8(%ebp),%eax
8010178b:	75 2b                	jne    801017b8 <iget+0x61>
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	8b 40 04             	mov    0x4(%eax),%eax
80101793:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101796:	75 20                	jne    801017b8 <iget+0x61>
      ip->ref++;
80101798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179b:	8b 40 08             	mov    0x8(%eax),%eax
8010179e:	8d 50 01             	lea    0x1(%eax),%edx
801017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017a7:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801017ae:	e8 d1 3d 00 00       	call   80105584 <release>
      return ip;
801017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b6:	eb 6f                	jmp    80101827 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017bc:	75 10                	jne    801017ce <iget+0x77>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 08             	mov    0x8(%eax),%eax
801017c4:	85 c0                	test   %eax,%eax
801017c6:	75 06                	jne    801017ce <iget+0x77>
      empty = ip;
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ce:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017d2:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801017d9:	72 9e                	jb     80101779 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017df:	75 0c                	jne    801017ed <iget+0x96>
    panic("iget: no inodes");
801017e1:	c7 04 24 33 91 10 80 	movl   $0x80109133,(%esp)
801017e8:	e8 4d ed ff ff       	call   8010053a <panic>

  ip = empty;
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 55 08             	mov    0x8(%ebp),%edx
801017f9:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fe:	8b 55 0c             	mov    0xc(%ebp),%edx
80101801:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101807:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010180e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101818:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010181f:	e8 60 3d 00 00       	call   80105584 <release>

  return ip;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101827:	c9                   	leave  
80101828:	c3                   	ret    

80101829 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101829:	55                   	push   %ebp
8010182a:	89 e5                	mov    %esp,%ebp
8010182c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010182f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101836:	e8 e7 3c 00 00       	call   80105522 <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101851:	e8 2e 3d 00 00       	call   80105584 <release>
  return ip;
80101856:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101859:	c9                   	leave  
8010185a:	c3                   	ret    

8010185b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010185b:	55                   	push   %ebp
8010185c:	89 e5                	mov    %esp,%ebp
8010185e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101861:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101865:	74 0a                	je     80101871 <ilock+0x16>
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	8b 40 08             	mov    0x8(%eax),%eax
8010186d:	85 c0                	test   %eax,%eax
8010186f:	7f 0c                	jg     8010187d <ilock+0x22>
    panic("ilock");
80101871:	c7 04 24 43 91 10 80 	movl   $0x80109143,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101884:	e8 99 3c 00 00       	call   80105522 <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 c2 36 00 00       	call   80104f60 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010189e:	8b 45 08             	mov    0x8(%ebp),%eax
801018a1:	8b 40 0c             	mov    0xc(%eax),%eax
801018a4:	83 e0 01             	and    $0x1,%eax
801018a7:	85 c0                	test   %eax,%eax
801018a9:	75 e0                	jne    8010188b <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 c8 01             	or     $0x1,%eax
801018b4:	89 c2                	mov    %eax,%edx
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018bc:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018c3:	e8 bc 3c 00 00       	call   80105584 <release>

  if(!(ip->flags & I_VALID)){
801018c8:	8b 45 08             	mov    0x8(%ebp),%eax
801018cb:	8b 40 0c             	mov    0xc(%eax),%eax
801018ce:	83 e0 02             	and    $0x2,%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	0f 85 ce 00 00 00    	jne    801019a7 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018d9:	8b 45 08             	mov    0x8(%ebp),%eax
801018dc:	8b 40 04             	mov    0x4(%eax),%eax
801018df:	c1 e8 03             	shr    $0x3,%eax
801018e2:	8d 50 02             	lea    0x2(%eax),%edx
801018e5:	8b 45 08             	mov    0x8(%ebp),%eax
801018e8:	8b 00                	mov    (%eax),%eax
801018ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 b0 e8 ff ff       	call   801001a6 <bread>
801018f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8d 50 18             	lea    0x18(%eax),%edx
801018ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101902:	8b 40 04             	mov    0x4(%eax),%eax
80101905:	83 e0 07             	and    $0x7,%eax
80101908:	c1 e0 06             	shl    $0x6,%eax
8010190b:	01 d0                	add    %edx,%eax
8010190d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101913:	0f b7 10             	movzwl (%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101932:	8b 45 08             	mov    0x8(%ebp),%eax
80101935:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193c:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101940:	8b 45 08             	mov    0x8(%ebp),%eax
80101943:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194a:	8b 50 08             	mov    0x8(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	8d 50 0c             	lea    0xc(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	83 c0 1c             	add    $0x1c,%eax
8010195f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101966:	00 
80101967:	89 54 24 04          	mov    %edx,0x4(%esp)
8010196b:	89 04 24             	mov    %eax,(%esp)
8010196e:	e8 d2 3e 00 00       	call   80105845 <memmove>
    brelse(bp);
80101973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101976:	89 04 24             	mov    %eax,(%esp)
80101979:	e8 99 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	8b 40 0c             	mov    0xc(%eax),%eax
80101984:	83 c8 02             	or     $0x2,%eax
80101987:	89 c2                	mov    %eax,%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010198f:	8b 45 08             	mov    0x8(%ebp),%eax
80101992:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101996:	66 85 c0             	test   %ax,%ax
80101999:	75 0c                	jne    801019a7 <ilock+0x14c>
      panic("ilock: no type");
8010199b:	c7 04 24 49 91 10 80 	movl   $0x80109149,(%esp)
801019a2:	e8 93 eb ff ff       	call   8010053a <panic>
  }
}
801019a7:	c9                   	leave  
801019a8:	c3                   	ret    

801019a9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019a9:	55                   	push   %ebp
801019aa:	89 e5                	mov    %esp,%ebp
801019ac:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019b3:	74 17                	je     801019cc <iunlock+0x23>
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	8b 40 0c             	mov    0xc(%eax),%eax
801019bb:	83 e0 01             	and    $0x1,%eax
801019be:	85 c0                	test   %eax,%eax
801019c0:	74 0a                	je     801019cc <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 08             	mov    0x8(%eax),%eax
801019c8:	85 c0                	test   %eax,%eax
801019ca:	7f 0c                	jg     801019d8 <iunlock+0x2f>
    panic("iunlock");
801019cc:	c7 04 24 58 91 10 80 	movl   $0x80109158,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019df:	e8 3e 3b 00 00       	call   80105522 <acquire>
  ip->flags &= ~I_BUSY;
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 0c             	mov    0xc(%eax),%eax
801019ea:	83 e0 fe             	and    $0xfffffffe,%eax
801019ed:	89 c2                	mov    %eax,%edx
801019ef:	8b 45 08             	mov    0x8(%ebp),%eax
801019f2:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019f5:	8b 45 08             	mov    0x8(%ebp),%eax
801019f8:	89 04 24             	mov    %eax,(%esp)
801019fb:	e8 47 36 00 00       	call   80105047 <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a07:	e8 78 3b 00 00       	call   80105584 <release>
}
80101a0c:	c9                   	leave  
80101a0d:	c3                   	ret    

80101a0e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a0e:	55                   	push   %ebp
80101a0f:	89 e5                	mov    %esp,%ebp
80101a11:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a14:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a1b:	e8 02 3b 00 00       	call   80105522 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 08             	mov    0x8(%eax),%eax
80101a26:	83 f8 01             	cmp    $0x1,%eax
80101a29:	0f 85 93 00 00 00    	jne    80101ac2 <iput+0xb4>
80101a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a32:	8b 40 0c             	mov    0xc(%eax),%eax
80101a35:	83 e0 02             	and    $0x2,%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	0f 84 82 00 00 00    	je     80101ac2 <iput+0xb4>
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a47:	66 85 c0             	test   %ax,%ax
80101a4a:	75 76                	jne    80101ac2 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a52:	83 e0 01             	and    $0x1,%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	74 0c                	je     80101a65 <iput+0x57>
      panic("iput busy");
80101a59:	c7 04 24 60 91 10 80 	movl   $0x80109160,(%esp)
80101a60:	e8 d5 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 c8 01             	or     $0x1,%eax
80101a6e:	89 c2                	mov    %eax,%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a76:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a7d:	e8 02 3b 00 00       	call   80105584 <release>
    itrunc(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 7d 01 00 00       	call   80101c0a <itrunc>
    ip->type = 0;
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	89 04 24             	mov    %eax,(%esp)
80101a9c:	e8 fe fb ff ff       	call   8010169f <iupdate>
    acquire(&icache.lock);
80101aa1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101aa8:	e8 75 3a 00 00       	call   80105522 <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 85 35 00 00       	call   80105047 <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ad8:	e8 a7 3a 00 00       	call   80105584 <release>
}
80101add:	c9                   	leave  
80101ade:	c3                   	ret    

80101adf <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101adf:	55                   	push   %ebp
80101ae0:	89 e5                	mov    %esp,%ebp
80101ae2:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	89 04 24             	mov    %eax,(%esp)
80101aeb:	e8 b9 fe ff ff       	call   801019a9 <iunlock>
  iput(ip);
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	89 04 24             	mov    %eax,(%esp)
80101af6:	e8 13 ff ff ff       	call   80101a0e <iput>
}
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	53                   	push   %ebx
80101b01:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b04:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b08:	77 3e                	ja     80101b48 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b10:	83 c2 04             	add    $0x4,%edx
80101b13:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b1e:	75 20                	jne    80101b40 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	8b 00                	mov    (%eax),%eax
80101b25:	89 04 24             	mov    %eax,(%esp)
80101b28:	e8 5b f8 ff ff       	call   80101388 <balloc>
80101b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b36:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b3c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b43:	e9 bc 00 00 00       	jmp    80101c04 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b48:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b50:	0f 87 a2 00 00 00    	ja     80101bf8 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b63:	75 19                	jne    80101b7e <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 00                	mov    (%eax),%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 16 f8 ff ff       	call   80101388 <balloc>
80101b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b7b:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8a:	89 04 24             	mov    %eax,(%esp)
80101b8d:	e8 14 e6 ff ff       	call   801001a6 <bread>
80101b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	83 c0 18             	add    $0x18,%eax
80101b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bab:	01 d0                	add    %edx,%eax
80101bad:	8b 00                	mov    (%eax),%eax
80101baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb6:	75 30                	jne    80101be8 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bc5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 00                	mov    (%eax),%eax
80101bcd:	89 04 24             	mov    %eax,(%esp)
80101bd0:	e8 b3 f7 ff ff       	call   80101388 <balloc>
80101bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be0:	89 04 24             	mov    %eax,(%esp)
80101be3:	e8 33 1a 00 00       	call   8010361b <log_write>
    }
    brelse(bp);
80101be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101beb:	89 04 24             	mov    %eax,(%esp)
80101bee:	e8 24 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf6:	eb 0c                	jmp    80101c04 <bmap+0x107>
  }

  panic("bmap: out of range");
80101bf8:	c7 04 24 6a 91 10 80 	movl   $0x8010916a,(%esp)
80101bff:	e8 36 e9 ff ff       	call   8010053a <panic>
}
80101c04:	83 c4 24             	add    $0x24,%esp
80101c07:	5b                   	pop    %ebx
80101c08:	5d                   	pop    %ebp
80101c09:	c3                   	ret    

80101c0a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0a:	55                   	push   %ebp
80101c0b:	89 e5                	mov    %esp,%ebp
80101c0d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c17:	eb 44                	jmp    80101c5d <itrunc+0x53>
    if(ip->addrs[i]){
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1f:	83 c2 04             	add    $0x4,%edx
80101c22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c26:	85 c0                	test   %eax,%eax
80101c28:	74 2f                	je     80101c59 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c30:	83 c2 04             	add    $0x4,%edx
80101c33:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 00                	mov    (%eax),%eax
80101c3c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c40:	89 04 24             	mov    %eax,(%esp)
80101c43:	e8 8e f8 ff ff       	call   801014d6 <bfree>
      ip->addrs[i] = 0;
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c4e:	83 c2 04             	add    $0x4,%edx
80101c51:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c58:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c61:	7e b6                	jle    80101c19 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c69:	85 c0                	test   %eax,%eax
80101c6b:	0f 84 9b 00 00 00    	je     80101d0c <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 00                	mov    (%eax),%eax
80101c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c80:	89 04 24             	mov    %eax,(%esp)
80101c83:	e8 1e e5 ff ff       	call   801001a6 <bread>
80101c88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c8e:	83 c0 18             	add    $0x18,%eax
80101c91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9b:	eb 3b                	jmp    80101cd8 <itrunc+0xce>
      if(a[j])
80101c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101caa:	01 d0                	add    %edx,%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	85 c0                	test   %eax,%eax
80101cb0:	74 22                	je     80101cd4 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cbf:	01 d0                	add    %edx,%eax
80101cc1:	8b 10                	mov    (%eax),%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	8b 00                	mov    (%eax),%eax
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 02 f8 ff ff       	call   801014d6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdb:	83 f8 7f             	cmp    $0x7f,%eax
80101cde:	76 bd                	jbe    80101c9d <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce3:	89 04 24             	mov    %eax,(%esp)
80101ce6:	e8 2c e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf4:	8b 00                	mov    (%eax),%eax
80101cf6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfa:	89 04 24             	mov    %eax,(%esp)
80101cfd:	e8 d4 f7 ff ff       	call   801014d6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 7e f9 ff ff       	call   8010169f <iupdate>
}
80101d21:	c9                   	leave  
80101d22:	c3                   	ret    

80101d23 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 c2                	mov    %eax,%edx
80101d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d30:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 50 04             	mov    0x4(%eax),%edx
80101d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d49:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 50 18             	mov    0x18(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d66:	5d                   	pop    %ebp
80101d67:	c3                   	ret    

80101d68 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d75:	66 83 f8 03          	cmp    $0x3,%ax
80101d79:	75 60                	jne    80101ddb <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d82:	66 85 c0             	test   %ax,%ax
80101d85:	78 20                	js     80101da7 <readi+0x3f>
80101d87:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8e:	66 83 f8 09          	cmp    $0x9,%ax
80101d92:	7f 13                	jg     80101da7 <readi+0x3f>
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9b:	98                   	cwtl   
80101d9c:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101da3:	85 c0                	test   %eax,%eax
80101da5:	75 0a                	jne    80101db1 <readi+0x49>
      return -1;
80101da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dac:	e9 19 01 00 00       	jmp    80101eca <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db8:	98                   	cwtl   
80101db9:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101dc0:	8b 55 14             	mov    0x14(%ebp),%edx
80101dc3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101dca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dce:	8b 55 08             	mov    0x8(%ebp),%edx
80101dd1:	89 14 24             	mov    %edx,(%esp)
80101dd4:	ff d0                	call   *%eax
80101dd6:	e9 ef 00 00 00       	jmp    80101eca <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 18             	mov    0x18(%eax),%eax
80101de1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de4:	72 0d                	jb     80101df3 <readi+0x8b>
80101de6:	8b 45 14             	mov    0x14(%ebp),%eax
80101de9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dec:	01 d0                	add    %edx,%eax
80101dee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df1:	73 0a                	jae    80101dfd <readi+0x95>
    return -1;
80101df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101df8:	e9 cd 00 00 00       	jmp    80101eca <readi+0x162>
  if(off + n > ip->size)
80101dfd:	8b 45 14             	mov    0x14(%ebp),%eax
80101e00:	8b 55 10             	mov    0x10(%ebp),%edx
80101e03:	01 c2                	add    %eax,%edx
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	8b 40 18             	mov    0x18(%eax),%eax
80101e0b:	39 c2                	cmp    %eax,%edx
80101e0d:	76 0c                	jbe    80101e1b <readi+0xb3>
    n = ip->size - off;
80101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e12:	8b 40 18             	mov    0x18(%eax),%eax
80101e15:	2b 45 10             	sub    0x10(%ebp),%eax
80101e18:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e22:	e9 94 00 00 00       	jmp    80101ebb <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e27:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2a:	c1 e8 09             	shr    $0x9,%eax
80101e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e31:	8b 45 08             	mov    0x8(%ebp),%eax
80101e34:	89 04 24             	mov    %eax,(%esp)
80101e37:	e8 c1 fc ff ff       	call   80101afd <bmap>
80101e3c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3f:	8b 12                	mov    (%edx),%edx
80101e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e45:	89 14 24             	mov    %edx,(%esp)
80101e48:	e8 59 e3 ff ff       	call   801001a6 <bread>
80101e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e50:	8b 45 10             	mov    0x10(%ebp),%eax
80101e53:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e58:	89 c2                	mov    %eax,%edx
80101e5a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e5f:	29 d0                	sub    %edx,%eax
80101e61:	89 c2                	mov    %eax,%edx
80101e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e66:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e69:	29 c1                	sub    %eax,%ecx
80101e6b:	89 c8                	mov    %ecx,%eax
80101e6d:	39 c2                	cmp    %eax,%edx
80101e6f:	0f 46 c2             	cmovbe %edx,%eax
80101e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e75:	8b 45 10             	mov    0x10(%ebp),%eax
80101e78:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7d:	8d 50 10             	lea    0x10(%eax),%edx
80101e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e83:	01 d0                	add    %edx,%eax
80101e85:	8d 50 08             	lea    0x8(%eax),%edx
80101e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e96:	89 04 24             	mov    %eax,(%esp)
80101e99:	e8 a7 39 00 00       	call   80105845 <memmove>
    brelse(bp);
80101e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea1:	89 04 24             	mov    %eax,(%esp)
80101ea4:	e8 6e e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eac:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb2:	01 45 10             	add    %eax,0x10(%ebp)
80101eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb8:	01 45 0c             	add    %eax,0xc(%ebp)
80101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ebe:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec1:	0f 82 60 ff ff ff    	jb     80101e27 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec7:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eca:	c9                   	leave  
80101ecb:	c3                   	ret    

80101ecc <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ecc:	55                   	push   %ebp
80101ecd:	89 e5                	mov    %esp,%ebp
80101ecf:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed9:	66 83 f8 03          	cmp    $0x3,%ax
80101edd:	75 60                	jne    80101f3f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee6:	66 85 c0             	test   %ax,%ax
80101ee9:	78 20                	js     80101f0b <writei+0x3f>
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 83 f8 09          	cmp    $0x9,%ax
80101ef6:	7f 13                	jg     80101f0b <writei+0x3f>
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eff:	98                   	cwtl   
80101f00:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f07:	85 c0                	test   %eax,%eax
80101f09:	75 0a                	jne    80101f15 <writei+0x49>
      return -1;
80101f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f10:	e9 44 01 00 00       	jmp    80102059 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f24:	8b 55 14             	mov    0x14(%ebp),%edx
80101f27:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f32:	8b 55 08             	mov    0x8(%ebp),%edx
80101f35:	89 14 24             	mov    %edx,(%esp)
80101f38:	ff d0                	call   *%eax
80101f3a:	e9 1a 01 00 00       	jmp    80102059 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 40 18             	mov    0x18(%eax),%eax
80101f45:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f48:	72 0d                	jb     80101f57 <writei+0x8b>
80101f4a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f50:	01 d0                	add    %edx,%eax
80101f52:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f55:	73 0a                	jae    80101f61 <writei+0x95>
    return -1;
80101f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5c:	e9 f8 00 00 00       	jmp    80102059 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f61:	8b 45 14             	mov    0x14(%ebp),%eax
80101f64:	8b 55 10             	mov    0x10(%ebp),%edx
80101f67:	01 d0                	add    %edx,%eax
80101f69:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6e:	76 0a                	jbe    80101f7a <writei+0xae>
    return -1;
80101f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f75:	e9 df 00 00 00       	jmp    80102059 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	e9 9f 00 00 00       	jmp    80102025 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f86:	8b 45 10             	mov    0x10(%ebp),%eax
80101f89:	c1 e8 09             	shr    $0x9,%eax
80101f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f90:	8b 45 08             	mov    0x8(%ebp),%eax
80101f93:	89 04 24             	mov    %eax,(%esp)
80101f96:	e8 62 fb ff ff       	call   80101afd <bmap>
80101f9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9e:	8b 12                	mov    (%edx),%edx
80101fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa4:	89 14 24             	mov    %edx,(%esp)
80101fa7:	e8 fa e1 ff ff       	call   801001a6 <bread>
80101fac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101faf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb7:	89 c2                	mov    %eax,%edx
80101fb9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbe:	29 d0                	sub    %edx,%eax
80101fc0:	89 c2                	mov    %eax,%edx
80101fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc5:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc8:	29 c1                	sub    %eax,%ecx
80101fca:	89 c8                	mov    %ecx,%eax
80101fcc:	39 c2                	cmp    %eax,%edx
80101fce:	0f 46 c2             	cmovbe %edx,%eax
80101fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdc:	8d 50 10             	lea    0x10(%eax),%edx
80101fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe2:	01 d0                	add    %edx,%eax
80101fe4:	8d 50 08             	lea    0x8(%eax),%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 48 38 00 00       	call   80105845 <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 13 16 00 00       	call   8010361b <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 55 ff ff ff    	jb     80101f86 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18a>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18a>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 49 f6 ff ff       	call   8010169f <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102061:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102068:	00 
80102069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 6d 38 00 00       	call   801058e8 <strncmp>
}
8010207b:	c9                   	leave  
8010207c:	c3                   	ret    

8010207d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208a:	66 83 f8 01          	cmp    $0x1,%ax
8010208e:	74 0c                	je     8010209c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102090:	c7 04 24 7d 91 10 80 	movl   $0x8010917d,(%esp)
80102097:	e8 9e e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010209c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a3:	e9 88 00 00 00       	jmp    80102130 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020a8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020af:	00 
801020b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801020be:	8b 45 08             	mov    0x8(%ebp),%eax
801020c1:	89 04 24             	mov    %eax,(%esp)
801020c4:	e8 9f fc ff ff       	call   80101d68 <readi>
801020c9:	83 f8 10             	cmp    $0x10,%eax
801020cc:	74 0c                	je     801020da <dirlookup+0x5d>
      panic("dirlink read");
801020ce:	c7 04 24 8f 91 10 80 	movl   $0x8010918f,(%esp)
801020d5:	e8 60 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020da:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020de:	66 85 c0             	test   %ax,%ax
801020e1:	75 02                	jne    801020e5 <dirlookup+0x68>
      continue;
801020e3:	eb 47                	jmp    8010212c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e8:	83 c0 02             	add    $0x2,%eax
801020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f2:	89 04 24             	mov    %eax,(%esp)
801020f5:	e8 61 ff ff ff       	call   8010205b <namecmp>
801020fa:	85 c0                	test   %eax,%eax
801020fc:	75 2e                	jne    8010212c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801020fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102102:	74 08                	je     8010210c <dirlookup+0x8f>
        *poff = off;
80102104:	8b 45 10             	mov    0x10(%ebp),%eax
80102107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102110:	0f b7 c0             	movzwl %ax,%eax
80102113:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	8b 00                	mov    (%eax),%eax
8010211b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010211e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102122:	89 04 24             	mov    %eax,(%esp)
80102125:	e8 2d f6 ff ff       	call   80101757 <iget>
8010212a:	eb 18                	jmp    80102144 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102130:	8b 45 08             	mov    0x8(%ebp),%eax
80102133:	8b 40 18             	mov    0x18(%eax),%eax
80102136:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102139:	0f 87 69 ff ff ff    	ja     801020a8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010213f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102144:	c9                   	leave  
80102145:	c3                   	ret    

80102146 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102146:	55                   	push   %ebp
80102147:	89 e5                	mov    %esp,%ebp
80102149:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102153:	00 
80102154:	8b 45 0c             	mov    0xc(%ebp),%eax
80102157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215b:	8b 45 08             	mov    0x8(%ebp),%eax
8010215e:	89 04 24             	mov    %eax,(%esp)
80102161:	e8 17 ff ff ff       	call   8010207d <dirlookup>
80102166:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010216d:	74 15                	je     80102184 <dirlink+0x3e>
    iput(ip);
8010216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102172:	89 04 24             	mov    %eax,(%esp)
80102175:	e8 94 f8 ff ff       	call   80101a0e <iput>
    return -1;
8010217a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217f:	e9 b7 00 00 00       	jmp    8010223b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218b:	eb 46                	jmp    801021d3 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010218d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102190:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102197:	00 
80102198:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219f:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a3:	8b 45 08             	mov    0x8(%ebp),%eax
801021a6:	89 04 24             	mov    %eax,(%esp)
801021a9:	e8 ba fb ff ff       	call   80101d68 <readi>
801021ae:	83 f8 10             	cmp    $0x10,%eax
801021b1:	74 0c                	je     801021bf <dirlink+0x79>
      panic("dirlink read");
801021b3:	c7 04 24 8f 91 10 80 	movl   $0x8010918f,(%esp)
801021ba:	e8 7b e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c3:	66 85 c0             	test   %ax,%ax
801021c6:	75 02                	jne    801021ca <dirlink+0x84>
      break;
801021c8:	eb 16                	jmp    801021e0 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cd:	83 c0 10             	add    $0x10,%eax
801021d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d6:	8b 45 08             	mov    0x8(%ebp),%eax
801021d9:	8b 40 18             	mov    0x18(%eax),%eax
801021dc:	39 c2                	cmp    %eax,%edx
801021de:	72 ad                	jb     8010218d <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021e0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021e7:	00 
801021e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f2:	83 c0 02             	add    $0x2,%eax
801021f5:	89 04 24             	mov    %eax,(%esp)
801021f8:	e8 41 37 00 00       	call   8010593e <strncpy>
  de.inum = inum;
801021fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102200:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102207:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220e:	00 
8010220f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102213:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102216:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	89 04 24             	mov    %eax,(%esp)
80102220:	e8 a7 fc ff ff       	call   80101ecc <writei>
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0c                	je     80102236 <dirlink+0xf0>
    panic("dirlink");
8010222a:	c7 04 24 9c 91 10 80 	movl   $0x8010919c,(%esp)
80102231:	e8 04 e3 ff ff       	call   8010053a <panic>
  
  return 0;
80102236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223b:	c9                   	leave  
8010223c:	c3                   	ret    

8010223d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010223d:	55                   	push   %ebp
8010223e:	89 e5                	mov    %esp,%ebp
80102240:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102243:	eb 04                	jmp    80102249 <skipelem+0xc>
    path++;
80102245:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102249:	8b 45 08             	mov    0x8(%ebp),%eax
8010224c:	0f b6 00             	movzbl (%eax),%eax
8010224f:	3c 2f                	cmp    $0x2f,%al
80102251:	74 f2                	je     80102245 <skipelem+0x8>
    path++;
  if(*path == 0)
80102253:	8b 45 08             	mov    0x8(%ebp),%eax
80102256:	0f b6 00             	movzbl (%eax),%eax
80102259:	84 c0                	test   %al,%al
8010225b:	75 0a                	jne    80102267 <skipelem+0x2a>
    return 0;
8010225d:	b8 00 00 00 00       	mov    $0x0,%eax
80102262:	e9 86 00 00 00       	jmp    801022ed <skipelem+0xb0>
  s = path;
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010226d:	eb 04                	jmp    80102273 <skipelem+0x36>
    path++;
8010226f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	0f b6 00             	movzbl (%eax),%eax
80102279:	3c 2f                	cmp    $0x2f,%al
8010227b:	74 0a                	je     80102287 <skipelem+0x4a>
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	0f b6 00             	movzbl (%eax),%eax
80102283:	84 c0                	test   %al,%al
80102285:	75 e8                	jne    8010226f <skipelem+0x32>
    path++;
  len = path - s;
80102287:	8b 55 08             	mov    0x8(%ebp),%edx
8010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228d:	29 c2                	sub    %eax,%edx
8010228f:	89 d0                	mov    %edx,%eax
80102291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102294:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102298:	7e 1c                	jle    801022b6 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010229a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a1:	00 
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801022ac:	89 04 24             	mov    %eax,(%esp)
801022af:	e8 91 35 00 00       	call   80105845 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022b4:	eb 2a                	jmp    801022e0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c7:	89 04 24             	mov    %eax,(%esp)
801022ca:	e8 76 35 00 00       	call   80105845 <memmove>
    name[len] = 0;
801022cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d5:	01 d0                	add    %edx,%eax
801022d7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022da:	eb 04                	jmp    801022e0 <skipelem+0xa3>
    path++;
801022dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	0f b6 00             	movzbl (%eax),%eax
801022e6:	3c 2f                	cmp    $0x2f,%al
801022e8:	74 f2                	je     801022dc <skipelem+0x9f>
    path++;
  return path;
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022ed:	c9                   	leave  
801022ee:	c3                   	ret    

801022ef <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ef:	55                   	push   %ebp
801022f0:	89 e5                	mov    %esp,%ebp
801022f2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	0f b6 00             	movzbl (%eax),%eax
801022fb:	3c 2f                	cmp    $0x2f,%al
801022fd:	75 1c                	jne    8010231b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022ff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102306:	00 
80102307:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010230e:	e8 44 f4 ff ff       	call   80101757 <iget>
80102313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102316:	e9 af 00 00 00       	jmp    801023ca <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102321:	8b 40 6c             	mov    0x6c(%eax),%eax
80102324:	89 04 24             	mov    %eax,(%esp)
80102327:	e8 fd f4 ff ff       	call   80101829 <idup>
8010232c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010232f:	e9 96 00 00 00       	jmp    801023ca <namex+0xdb>
    ilock(ip);
80102334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102337:	89 04 24             	mov    %eax,(%esp)
8010233a:	e8 1c f5 ff ff       	call   8010185b <ilock>
    if(ip->type != T_DIR){
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102346:	66 83 f8 01          	cmp    $0x1,%ax
8010234a:	74 15                	je     80102361 <namex+0x72>
      iunlockput(ip);
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 88 f7 ff ff       	call   80101adf <iunlockput>
      return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
8010235c:	e9 a3 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102361:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102365:	74 1d                	je     80102384 <namex+0x95>
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	0f b6 00             	movzbl (%eax),%eax
8010236d:	84 c0                	test   %al,%al
8010236f:	75 13                	jne    80102384 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	89 04 24             	mov    %eax,(%esp)
80102377:	e8 2d f6 ff ff       	call   801019a9 <iunlock>
      return ip;
8010237c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237f:	e9 80 00 00 00       	jmp    80102404 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238b:	00 
8010238c:	8b 45 10             	mov    0x10(%ebp),%eax
8010238f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 df fc ff ff       	call   8010207d <dirlookup>
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a5:	75 12                	jne    801023b9 <namex+0xca>
      iunlockput(ip);
801023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023aa:	89 04 24             	mov    %eax,(%esp)
801023ad:	e8 2d f7 ff ff       	call   80101adf <iunlockput>
      return 0;
801023b2:	b8 00 00 00 00       	mov    $0x0,%eax
801023b7:	eb 4b                	jmp    80102404 <namex+0x115>
    }
    iunlockput(ip);
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	89 04 24             	mov    %eax,(%esp)
801023bf:	e8 1b f7 ff ff       	call   80101adf <iunlockput>
    ip = next;
801023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ca:	8b 45 10             	mov    0x10(%ebp),%eax
801023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d1:	8b 45 08             	mov    0x8(%ebp),%eax
801023d4:	89 04 24             	mov    %eax,(%esp)
801023d7:	e8 61 fe ff ff       	call   8010223d <skipelem>
801023dc:	89 45 08             	mov    %eax,0x8(%ebp)
801023df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e3:	0f 85 4b ff ff ff    	jne    80102334 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ed:	74 12                	je     80102401 <namex+0x112>
    iput(ip);
801023ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f2:	89 04 24             	mov    %eax,(%esp)
801023f5:	e8 14 f6 ff ff       	call   80101a0e <iput>
    return 0;
801023fa:	b8 00 00 00 00       	mov    $0x0,%eax
801023ff:	eb 03                	jmp    80102404 <namex+0x115>
  }
  return ip;
80102401:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <namei>:

struct inode*
namei(char *path)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010240c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010240f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241a:	00 
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	89 04 24             	mov    %eax,(%esp)
80102421:	e8 c9 fe ff ff       	call   801022ef <namex>
}
80102426:	c9                   	leave  
80102427:	c3                   	ret    

80102428 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010242e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102431:	89 44 24 08          	mov    %eax,0x8(%esp)
80102435:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010243c:	00 
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 a7 fe ff ff       	call   801022ef <namex>
}
80102448:	c9                   	leave  
80102449:	c3                   	ret    

8010244a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010244a:	55                   	push   %ebp
8010244b:	89 e5                	mov    %esp,%ebp
8010244d:	83 ec 14             	sub    $0x14,%esp
80102450:	8b 45 08             	mov    0x8(%ebp),%eax
80102453:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102457:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010245b:	89 c2                	mov    %eax,%edx
8010245d:	ec                   	in     (%dx),%al
8010245e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102461:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102465:	c9                   	leave  
80102466:	c3                   	ret    

80102467 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102467:	55                   	push   %ebp
80102468:	89 e5                	mov    %esp,%ebp
8010246a:	57                   	push   %edi
8010246b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010246c:	8b 55 08             	mov    0x8(%ebp),%edx
8010246f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102472:	8b 45 10             	mov    0x10(%ebp),%eax
80102475:	89 cb                	mov    %ecx,%ebx
80102477:	89 df                	mov    %ebx,%edi
80102479:	89 c1                	mov    %eax,%ecx
8010247b:	fc                   	cld    
8010247c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010247e:	89 c8                	mov    %ecx,%eax
80102480:	89 fb                	mov    %edi,%ebx
80102482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102485:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102488:	5b                   	pop    %ebx
80102489:	5f                   	pop    %edi
8010248a:	5d                   	pop    %ebp
8010248b:	c3                   	ret    

8010248c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010248c:	55                   	push   %ebp
8010248d:	89 e5                	mov    %esp,%ebp
8010248f:	83 ec 08             	sub    $0x8,%esp
80102492:	8b 55 08             	mov    0x8(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010249c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010249f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024a3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024a7:	ee                   	out    %al,(%dx)
}
801024a8:	c9                   	leave  
801024a9:	c3                   	ret    

801024aa <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024aa:	55                   	push   %ebp
801024ab:	89 e5                	mov    %esp,%ebp
801024ad:	56                   	push   %esi
801024ae:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024af:	8b 55 08             	mov    0x8(%ebp),%edx
801024b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024b5:	8b 45 10             	mov    0x10(%ebp),%eax
801024b8:	89 cb                	mov    %ecx,%ebx
801024ba:	89 de                	mov    %ebx,%esi
801024bc:	89 c1                	mov    %eax,%ecx
801024be:	fc                   	cld    
801024bf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024c1:	89 c8                	mov    %ecx,%eax
801024c3:	89 f3                	mov    %esi,%ebx
801024c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024c8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024cb:	5b                   	pop    %ebx
801024cc:	5e                   	pop    %esi
801024cd:	5d                   	pop    %ebp
801024ce:	c3                   	ret    

801024cf <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024cf:	55                   	push   %ebp
801024d0:	89 e5                	mov    %esp,%ebp
801024d2:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024d5:	90                   	nop
801024d6:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024dd:	e8 68 ff ff ff       	call   8010244a <inb>
801024e2:	0f b6 c0             	movzbl %al,%eax
801024e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024eb:	25 c0 00 00 00       	and    $0xc0,%eax
801024f0:	83 f8 40             	cmp    $0x40,%eax
801024f3:	75 e1                	jne    801024d6 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024f5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f9:	74 11                	je     8010250c <idewait+0x3d>
801024fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fe:	83 e0 21             	and    $0x21,%eax
80102501:	85 c0                	test   %eax,%eax
80102503:	74 07                	je     8010250c <idewait+0x3d>
    return -1;
80102505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010250a:	eb 05                	jmp    80102511 <idewait+0x42>
  return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102511:	c9                   	leave  
80102512:	c3                   	ret    

80102513 <ideinit>:

void
ideinit(void)
{
80102513:	55                   	push   %ebp
80102514:	89 e5                	mov    %esp,%ebp
80102516:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102519:	c7 44 24 04 a4 91 10 	movl   $0x801091a4,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102528:	e8 d4 2f 00 00       	call   80105501 <initlock>
  picenable(IRQ_IDE);
8010252d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102534:	e8 7b 18 00 00       	call   80103db4 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102539:	a1 60 39 11 80       	mov    0x80113960,%eax
8010253e:	83 e8 01             	sub    $0x1,%eax
80102541:	89 44 24 04          	mov    %eax,0x4(%esp)
80102545:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010254c:	e8 0c 04 00 00       	call   8010295d <ioapicenable>
  idewait(0);
80102551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102558:	e8 72 ff ff ff       	call   801024cf <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010255d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102564:	00 
80102565:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010256c:	e8 1b ff ff ff       	call   8010248c <outb>
  for(i=0; i<1000; i++){
80102571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102578:	eb 20                	jmp    8010259a <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010257a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102581:	e8 c4 fe ff ff       	call   8010244a <inb>
80102586:	84 c0                	test   %al,%al
80102588:	74 0c                	je     80102596 <ideinit+0x83>
      havedisk1 = 1;
8010258a:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102591:	00 00 00 
      break;
80102594:	eb 0d                	jmp    801025a3 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102596:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010259a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025a1:	7e d7                	jle    8010257a <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025a3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025aa:	00 
801025ab:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025b2:	e8 d5 fe ff ff       	call   8010248c <outb>
}
801025b7:	c9                   	leave  
801025b8:	c3                   	ret    

801025b9 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
801025bc:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c3:	75 0c                	jne    801025d1 <idestart+0x18>
    panic("idestart");
801025c5:	c7 04 24 a8 91 10 80 	movl   $0x801091a8,(%esp)
801025cc:	e8 69 df ff ff       	call   8010053a <panic>

  idewait(0);
801025d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d8:	e8 f2 fe ff ff       	call   801024cf <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025e4:	00 
801025e5:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025ec:	e8 9b fe ff ff       	call   8010248c <outb>
  outb(0x1f2, 1);  // number of sectors
801025f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025f8:	00 
801025f9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102600:	e8 87 fe ff ff       	call   8010248c <outb>
  outb(0x1f3, b->sector & 0xff);
80102605:	8b 45 08             	mov    0x8(%ebp),%eax
80102608:	8b 40 08             	mov    0x8(%eax),%eax
8010260b:	0f b6 c0             	movzbl %al,%eax
8010260e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102612:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102619:	e8 6e fe ff ff       	call   8010248c <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	8b 40 08             	mov    0x8(%eax),%eax
80102624:	c1 e8 08             	shr    $0x8,%eax
80102627:	0f b6 c0             	movzbl %al,%eax
8010262a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010262e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102635:	e8 52 fe ff ff       	call   8010248c <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
8010263d:	8b 40 08             	mov    0x8(%eax),%eax
80102640:	c1 e8 10             	shr    $0x10,%eax
80102643:	0f b6 c0             	movzbl %al,%eax
80102646:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102651:	e8 36 fe ff ff       	call   8010248c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
80102659:	8b 40 04             	mov    0x4(%eax),%eax
8010265c:	83 e0 01             	and    $0x1,%eax
8010265f:	c1 e0 04             	shl    $0x4,%eax
80102662:	89 c2                	mov    %eax,%edx
80102664:	8b 45 08             	mov    0x8(%ebp),%eax
80102667:	8b 40 08             	mov    0x8(%eax),%eax
8010266a:	c1 e8 18             	shr    $0x18,%eax
8010266d:	83 e0 0f             	and    $0xf,%eax
80102670:	09 d0                	or     %edx,%eax
80102672:	83 c8 e0             	or     $0xffffffe0,%eax
80102675:	0f b6 c0             	movzbl %al,%eax
80102678:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102683:	e8 04 fe ff ff       	call   8010248c <outb>
  if(b->flags & B_DIRTY){
80102688:	8b 45 08             	mov    0x8(%ebp),%eax
8010268b:	8b 00                	mov    (%eax),%eax
8010268d:	83 e0 04             	and    $0x4,%eax
80102690:	85 c0                	test   %eax,%eax
80102692:	74 34                	je     801026c8 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102694:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010269b:	00 
8010269c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026a3:	e8 e4 fd ff ff       	call   8010248c <outb>
    outsl(0x1f0, b->data, 512/4);
801026a8:	8b 45 08             	mov    0x8(%ebp),%eax
801026ab:	83 c0 18             	add    $0x18,%eax
801026ae:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026b5:	00 
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026c1:	e8 e4 fd ff ff       	call   801024aa <outsl>
801026c6:	eb 14                	jmp    801026dc <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026c8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026cf:	00 
801026d0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d7:	e8 b0 fd ff ff       	call   8010248c <outb>
  }
}
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026e4:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801026eb:	e8 32 2e 00 00       	call   80105522 <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102705:	e8 7a 2e 00 00       	call   80105584 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010270a:	e9 90 00 00 00       	jmp    8010279f <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010270f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102712:	8b 40 14             	mov    0x14(%eax),%eax
80102715:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	8b 00                	mov    (%eax),%eax
8010271f:	83 e0 04             	and    $0x4,%eax
80102722:	85 c0                	test   %eax,%eax
80102724:	75 2e                	jne    80102754 <ideintr+0x76>
80102726:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010272d:	e8 9d fd ff ff       	call   801024cf <idewait>
80102732:	85 c0                	test   %eax,%eax
80102734:	78 1e                	js     80102754 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102739:	83 c0 18             	add    $0x18,%eax
8010273c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102743:	00 
80102744:	89 44 24 04          	mov    %eax,0x4(%esp)
80102748:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010274f:	e8 13 fd ff ff       	call   80102467 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102757:	8b 00                	mov    (%eax),%eax
80102759:	83 c8 02             	or     $0x2,%eax
8010275c:	89 c2                	mov    %eax,%edx
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102766:	8b 00                	mov    (%eax),%eax
80102768:	83 e0 fb             	and    $0xfffffffb,%eax
8010276b:	89 c2                	mov    %eax,%edx
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	89 04 24             	mov    %eax,(%esp)
80102778:	e8 ca 28 00 00       	call   80105047 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010277d:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102782:	85 c0                	test   %eax,%eax
80102784:	74 0d                	je     80102793 <ideintr+0xb5>
    idestart(idequeue);
80102786:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010278b:	89 04 24             	mov    %eax,(%esp)
8010278e:	e8 26 fe ff ff       	call   801025b9 <idestart>

  release(&idelock);
80102793:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
8010279a:	e8 e5 2d 00 00       	call   80105584 <release>
}
8010279f:	c9                   	leave  
801027a0:	c3                   	ret    

801027a1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027a1:	55                   	push   %ebp
801027a2:	89 e5                	mov    %esp,%ebp
801027a4:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027a7:	8b 45 08             	mov    0x8(%ebp),%eax
801027aa:	8b 00                	mov    (%eax),%eax
801027ac:	83 e0 01             	and    $0x1,%eax
801027af:	85 c0                	test   %eax,%eax
801027b1:	75 0c                	jne    801027bf <iderw+0x1e>
    panic("iderw: buf not busy");
801027b3:	c7 04 24 b1 91 10 80 	movl   $0x801091b1,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 c5 91 10 80 	movl   $0x801091c5,(%esp)
801027d3:	e8 62 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027d8:	8b 45 08             	mov    0x8(%ebp),%eax
801027db:	8b 40 04             	mov    0x4(%eax),%eax
801027de:	85 c0                	test   %eax,%eax
801027e0:	74 15                	je     801027f7 <iderw+0x56>
801027e2:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027eb:	c7 04 24 da 91 10 80 	movl   $0x801091da,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801027fe:	e8 1f 2d 00 00       	call   80105522 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010280d:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102814:	eb 0b                	jmp    80102821 <iderw+0x80>
80102816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102819:	8b 00                	mov    (%eax),%eax
8010281b:	83 c0 14             	add    $0x14,%eax
8010281e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	85 c0                	test   %eax,%eax
80102828:	75 ec                	jne    80102816 <iderw+0x75>
    ;
  *pp = b;
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 55 08             	mov    0x8(%ebp),%edx
80102830:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102832:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102837:	3b 45 08             	cmp    0x8(%ebp),%eax
8010283a:	75 0d                	jne    80102849 <iderw+0xa8>
    idestart(b);
8010283c:	8b 45 08             	mov    0x8(%ebp),%eax
8010283f:	89 04 24             	mov    %eax,(%esp)
80102842:	e8 72 fd ff ff       	call   801025b9 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102847:	eb 15                	jmp    8010285e <iderw+0xbd>
80102849:	eb 13                	jmp    8010285e <iderw+0xbd>
    sleep(b, &idelock);
8010284b:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
80102852:	80 
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	89 04 24             	mov    %eax,(%esp)
80102859:	e8 02 27 00 00       	call   80104f60 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	8b 00                	mov    (%eax),%eax
80102863:	83 e0 06             	and    $0x6,%eax
80102866:	83 f8 02             	cmp    $0x2,%eax
80102869:	75 e0                	jne    8010284b <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
8010286b:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102872:	e8 0d 2d 00 00       	call   80105584 <release>
}
80102877:	c9                   	leave  
80102878:	c3                   	ret    

80102879 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102879:	55                   	push   %ebp
8010287a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010287c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102881:	8b 55 08             	mov    0x8(%ebp),%edx
80102884:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102886:	a1 34 32 11 80       	mov    0x80113234,%eax
8010288b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010288e:	5d                   	pop    %ebp
8010288f:	c3                   	ret    

80102890 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102893:	a1 34 32 11 80       	mov    0x80113234,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010289d:	a1 34 32 11 80       	mov    0x80113234,%eax
801028a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801028a5:	89 50 10             	mov    %edx,0x10(%eax)
}
801028a8:	5d                   	pop    %ebp
801028a9:	c3                   	ret    

801028aa <ioapicinit>:

void
ioapicinit(void)
{
801028aa:	55                   	push   %ebp
801028ab:	89 e5                	mov    %esp,%ebp
801028ad:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028b0:	a1 64 33 11 80       	mov    0x80113364,%eax
801028b5:	85 c0                	test   %eax,%eax
801028b7:	75 05                	jne    801028be <ioapicinit+0x14>
    return;
801028b9:	e9 9d 00 00 00       	jmp    8010295b <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028be:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
801028c5:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028cf:	e8 a5 ff ff ff       	call   80102879 <ioapicread>
801028d4:	c1 e8 10             	shr    $0x10,%eax
801028d7:	25 ff 00 00 00       	and    $0xff,%eax
801028dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028e6:	e8 8e ff ff ff       	call   80102879 <ioapicread>
801028eb:	c1 e8 18             	shr    $0x18,%eax
801028ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028f1:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028fe:	74 0c                	je     8010290c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102900:	c7 04 24 f8 91 10 80 	movl   $0x801091f8,(%esp)
80102907:	e8 94 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010290c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102913:	eb 3e                	jmp    80102953 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102918:	83 c0 20             	add    $0x20,%eax
8010291b:	0d 00 00 01 00       	or     $0x10000,%eax
80102920:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102923:	83 c2 08             	add    $0x8,%edx
80102926:	01 d2                	add    %edx,%edx
80102928:	89 44 24 04          	mov    %eax,0x4(%esp)
8010292c:	89 14 24             	mov    %edx,(%esp)
8010292f:	e8 5c ff ff ff       	call   80102890 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102937:	83 c0 08             	add    $0x8,%eax
8010293a:	01 c0                	add    %eax,%eax
8010293c:	83 c0 01             	add    $0x1,%eax
8010293f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102946:	00 
80102947:	89 04 24             	mov    %eax,(%esp)
8010294a:	e8 41 ff ff ff       	call   80102890 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010294f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102959:	7e ba                	jle    80102915 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010295b:	c9                   	leave  
8010295c:	c3                   	ret    

8010295d <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010295d:	55                   	push   %ebp
8010295e:	89 e5                	mov    %esp,%ebp
80102960:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102963:	a1 64 33 11 80       	mov    0x80113364,%eax
80102968:	85 c0                	test   %eax,%eax
8010296a:	75 02                	jne    8010296e <ioapicenable+0x11>
    return;
8010296c:	eb 37                	jmp    801029a5 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010296e:	8b 45 08             	mov    0x8(%ebp),%eax
80102971:	83 c0 20             	add    $0x20,%eax
80102974:	8b 55 08             	mov    0x8(%ebp),%edx
80102977:	83 c2 08             	add    $0x8,%edx
8010297a:	01 d2                	add    %edx,%edx
8010297c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102980:	89 14 24             	mov    %edx,(%esp)
80102983:	e8 08 ff ff ff       	call   80102890 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010298b:	c1 e0 18             	shl    $0x18,%eax
8010298e:	8b 55 08             	mov    0x8(%ebp),%edx
80102991:	83 c2 08             	add    $0x8,%edx
80102994:	01 d2                	add    %edx,%edx
80102996:	83 c2 01             	add    $0x1,%edx
80102999:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299d:	89 14 24             	mov    %edx,(%esp)
801029a0:	e8 eb fe ff ff       	call   80102890 <ioapicwrite>
}
801029a5:	c9                   	leave  
801029a6:	c3                   	ret    

801029a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029a7:	55                   	push   %ebp
801029a8:	89 e5                	mov    %esp,%ebp
801029aa:	8b 45 08             	mov    0x8(%ebp),%eax
801029ad:	05 00 00 00 80       	add    $0x80000000,%eax
801029b2:	5d                   	pop    %ebp
801029b3:	c3                   	ret    

801029b4 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029b4:	55                   	push   %ebp
801029b5:	89 e5                	mov    %esp,%ebp
801029b7:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029ba:	c7 44 24 04 2a 92 10 	movl   $0x8010922a,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029c9:	e8 33 2b 00 00       	call   80105501 <initlock>
  kmem.use_lock = 0;
801029ce:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
801029d5:	00 00 00 
  freerange(vstart, vend);
801029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 26 00 00 00       	call   80102a10 <freerange>
}
801029ea:	c9                   	leave  
801029eb:	c3                   	ret    

801029ec <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029ec:	55                   	push   %ebp
801029ed:	89 e5                	mov    %esp,%ebp
801029ef:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f9:	8b 45 08             	mov    0x8(%ebp),%eax
801029fc:	89 04 24             	mov    %eax,(%esp)
801029ff:	e8 0c 00 00 00       	call   80102a10 <freerange>
  kmem.use_lock = 1;
80102a04:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102a0b:	00 00 00 
}
80102a0e:	c9                   	leave  
80102a0f:	c3                   	ret    

80102a10 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a10:	55                   	push   %ebp
80102a11:	89 e5                	mov    %esp,%ebp
80102a13:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a26:	eb 12                	jmp    80102a3a <freerange+0x2a>
    kfree(p);
80102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2b:	89 04 24             	mov    %eax,(%esp)
80102a2e:	e8 16 00 00 00       	call   80102a49 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a33:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	05 00 10 00 00       	add    $0x1000,%eax
80102a42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a45:	76 e1                	jbe    80102a28 <freerange+0x18>
    kfree(p);
}
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    

80102a49 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a52:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a57:	85 c0                	test   %eax,%eax
80102a59:	75 1b                	jne    80102a76 <kfree+0x2d>
80102a5b:	81 7d 08 9c 8f 11 80 	cmpl   $0x80118f9c,0x8(%ebp)
80102a62:	72 12                	jb     80102a76 <kfree+0x2d>
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 38 ff ff ff       	call   801029a7 <v2p>
80102a6f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a74:	76 0c                	jbe    80102a82 <kfree+0x39>
    panic("kfree");
80102a76:	c7 04 24 2f 92 10 80 	movl   $0x8010922f,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 d9 2c 00 00       	call   80105776 <memset>

  if(kmem.use_lock)
80102a9d:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102aad:	e8 70 2a 00 00       	call   80105522 <acquire>
  r = (struct run*)v;
80102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ab8:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac1:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac6:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102acb:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ad0:	85 c0                	test   %eax,%eax
80102ad2:	74 0c                	je     80102ae0 <kfree+0x97>
    release(&kmem.lock);
80102ad4:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102adb:	e8 a4 2a 00 00       	call   80105584 <release>
}
80102ae0:	c9                   	leave  
80102ae1:	c3                   	ret    

80102ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ae2:	55                   	push   %ebp
80102ae3:	89 e5                	mov    %esp,%ebp
80102ae5:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ae8:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kalloc+0x1b>
    acquire(&kmem.lock);
80102af1:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102af8:	e8 25 2a 00 00       	call   80105522 <acquire>
  r = kmem.freelist;
80102afd:	a1 78 32 11 80       	mov    0x80113278,%eax
80102b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b09:	74 0a                	je     80102b15 <kalloc+0x33>
    kmem.freelist = r->next;
80102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0e:	8b 00                	mov    (%eax),%eax
80102b10:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b15:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b1a:	85 c0                	test   %eax,%eax
80102b1c:	74 0c                	je     80102b2a <kalloc+0x48>
    release(&kmem.lock);
80102b1e:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b25:	e8 5a 2a 00 00       	call   80105584 <release>
  return (char*)r;
80102b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b2d:	c9                   	leave  
80102b2e:	c3                   	ret    

80102b2f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 14             	sub    $0x14,%esp
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b40:	89 c2                	mov    %eax,%edx
80102b42:	ec                   	in     (%dx),%al
80102b43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b46:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b59:	e8 d1 ff ff ff       	call   80102b2f <inb>
80102b5e:	0f b6 c0             	movzbl %al,%eax
80102b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b67:	83 e0 01             	and    $0x1,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	75 0a                	jne    80102b78 <kbdgetc+0x2c>
    return -1;
80102b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b73:	e9 25 01 00 00       	jmp    80102c9d <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b78:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b7f:	e8 ab ff ff ff       	call   80102b2f <inb>
80102b84:	0f b6 c0             	movzbl %al,%eax
80102b87:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b8a:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b91:	75 17                	jne    80102baa <kbdgetc+0x5e>
    shift |= E0ESC;
80102b93:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102b98:	83 c8 40             	or     $0x40,%eax
80102b9b:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80102ba5:	e9 f3 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(data & 0x80){
80102baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bad:	25 80 00 00 00       	and    $0x80,%eax
80102bb2:	85 c0                	test   %eax,%eax
80102bb4:	74 45                	je     80102bfb <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bb6:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bbb:	83 e0 40             	and    $0x40,%eax
80102bbe:	85 c0                	test   %eax,%eax
80102bc0:	75 08                	jne    80102bca <kbdgetc+0x7e>
80102bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bc5:	83 e0 7f             	and    $0x7f,%eax
80102bc8:	eb 03                	jmp    80102bcd <kbdgetc+0x81>
80102bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd3:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102bd8:	0f b6 00             	movzbl (%eax),%eax
80102bdb:	83 c8 40             	or     $0x40,%eax
80102bde:	0f b6 c0             	movzbl %al,%eax
80102be1:	f7 d0                	not    %eax
80102be3:	89 c2                	mov    %eax,%edx
80102be5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102bea:	21 d0                	and    %edx,%eax
80102bec:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102bf1:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf6:	e9 a2 00 00 00       	jmp    80102c9d <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102bfb:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c00:	83 e0 40             	and    $0x40,%eax
80102c03:	85 c0                	test   %eax,%eax
80102c05:	74 14                	je     80102c1b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c07:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c0e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c13:	83 e0 bf             	and    $0xffffffbf,%eax
80102c16:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1e:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c23:	0f b6 00             	movzbl (%eax),%eax
80102c26:	0f b6 d0             	movzbl %al,%edx
80102c29:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c38:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c3d:	0f b6 00             	movzbl (%eax),%eax
80102c40:	0f b6 d0             	movzbl %al,%edx
80102c43:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c48:	31 d0                	xor    %edx,%eax
80102c4a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c4f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c54:	83 e0 03             	and    $0x3,%eax
80102c57:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c61:	01 d0                	add    %edx,%eax
80102c63:	0f b6 00             	movzbl (%eax),%eax
80102c66:	0f b6 c0             	movzbl %al,%eax
80102c69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c6c:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c71:	83 e0 08             	and    $0x8,%eax
80102c74:	85 c0                	test   %eax,%eax
80102c76:	74 22                	je     80102c9a <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c78:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c7c:	76 0c                	jbe    80102c8a <kbdgetc+0x13e>
80102c7e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c82:	77 06                	ja     80102c8a <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c84:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c88:	eb 10                	jmp    80102c9a <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c8a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c8e:	76 0a                	jbe    80102c9a <kbdgetc+0x14e>
80102c90:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c94:	77 04                	ja     80102c9a <kbdgetc+0x14e>
      c += 'a' - 'A';
80102c96:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <kbdintr>:

void
kbdintr(void)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ca5:	c7 04 24 4c 2b 10 80 	movl   $0x80102b4c,(%esp)
80102cac:	e8 fc da ff ff       	call   801007ad <consoleintr>
}
80102cb1:	c9                   	leave  
80102cb2:	c3                   	ret    

80102cb3 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cb3:	55                   	push   %ebp
80102cb4:	89 e5                	mov    %esp,%ebp
80102cb6:	83 ec 14             	sub    $0x14,%esp
80102cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cc4:	89 c2                	mov    %eax,%edx
80102cc6:	ec                   	in     (%dx),%al
80102cc7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cca:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cce:	c9                   	leave  
80102ccf:	c3                   	ret    

80102cd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cdc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ceb:	ee                   	out    %al,(%dx)
}
80102cec:	c9                   	leave  
80102ced:	c3                   	ret    

80102cee <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf4:	9c                   	pushf  
80102cf5:	58                   	pop    %eax
80102cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102cfc:	c9                   	leave  
80102cfd:	c3                   	ret    

80102cfe <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102cfe:	55                   	push   %ebp
80102cff:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d01:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	c1 e2 02             	shl    $0x2,%edx
80102d0c:	01 c2                	add    %eax,%edx
80102d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d11:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d13:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d18:	83 c0 20             	add    $0x20,%eax
80102d1b:	8b 00                	mov    (%eax),%eax
}
80102d1d:	5d                   	pop    %ebp
80102d1e:	c3                   	ret    

80102d1f <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d25:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102d2a:	85 c0                	test   %eax,%eax
80102d2c:	75 05                	jne    80102d33 <lapicinit+0x14>
    return;
80102d2e:	e9 43 01 00 00       	jmp    80102e76 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d33:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3a:	00 
80102d3b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d42:	e8 b7 ff ff ff       	call   80102cfe <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d47:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d4e:	00 
80102d4f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d56:	e8 a3 ff ff ff       	call   80102cfe <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d62:	00 
80102d63:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6a:	e8 8f ff ff ff       	call   80102cfe <lapicw>
  lapicw(TICR, 10000000); 
80102d6f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d76:	00 
80102d77:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d7e:	e8 7b ff ff ff       	call   80102cfe <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d83:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8a:	00 
80102d8b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d92:	e8 67 ff ff ff       	call   80102cfe <lapicw>
  lapicw(LINT1, MASKED);
80102d97:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9e:	00 
80102d9f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102da6:	e8 53 ff ff ff       	call   80102cfe <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102dab:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102db0:	83 c0 30             	add    $0x30,%eax
80102db3:	8b 00                	mov    (%eax),%eax
80102db5:	c1 e8 10             	shr    $0x10,%eax
80102db8:	0f b6 c0             	movzbl %al,%eax
80102dbb:	83 f8 03             	cmp    $0x3,%eax
80102dbe:	76 14                	jbe    80102dd4 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102dc0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dc7:	00 
80102dc8:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dcf:	e8 2a ff ff ff       	call   80102cfe <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dd4:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102ddb:	00 
80102ddc:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de3:	e8 16 ff ff ff       	call   80102cfe <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102de8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102def:	00 
80102df0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102df7:	e8 02 ff ff ff       	call   80102cfe <lapicw>
  lapicw(ESR, 0);
80102dfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e03:	00 
80102e04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0b:	e8 ee fe ff ff       	call   80102cfe <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e17:	00 
80102e18:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e1f:	e8 da fe ff ff       	call   80102cfe <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2b:	00 
80102e2c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e33:	e8 c6 fe ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e38:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e3f:	00 
80102e40:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e47:	e8 b2 fe ff ff       	call   80102cfe <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e4c:	90                   	nop
80102e4d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e52:	05 00 03 00 00       	add    $0x300,%eax
80102e57:	8b 00                	mov    (%eax),%eax
80102e59:	25 00 10 00 00       	and    $0x1000,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	75 eb                	jne    80102e4d <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e69:	00 
80102e6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e71:	e8 88 fe ff ff       	call   80102cfe <lapicw>
}
80102e76:	c9                   	leave  
80102e77:	c3                   	ret    

80102e78 <cpunum>:

int
cpunum(void)
{
80102e78:	55                   	push   %ebp
80102e79:	89 e5                	mov    %esp,%ebp
80102e7b:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e7e:	e8 6b fe ff ff       	call   80102cee <readeflags>
80102e83:	25 00 02 00 00       	and    $0x200,%eax
80102e88:	85 c0                	test   %eax,%eax
80102e8a:	74 25                	je     80102eb1 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e8c:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102e91:	8d 50 01             	lea    0x1(%eax),%edx
80102e94:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	75 13                	jne    80102eb1 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e9e:	8b 45 04             	mov    0x4(%ebp),%eax
80102ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ea5:	c7 04 24 38 92 10 80 	movl   $0x80109238,(%esp)
80102eac:	e8 ef d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eb1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	74 0f                	je     80102ec9 <cpunum+0x51>
    return lapic[ID]>>24;
80102eba:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ebf:	83 c0 20             	add    $0x20,%eax
80102ec2:	8b 00                	mov    (%eax),%eax
80102ec4:	c1 e8 18             	shr    $0x18,%eax
80102ec7:	eb 05                	jmp    80102ece <cpunum+0x56>
  return 0;
80102ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102ece:	c9                   	leave  
80102ecf:	c3                   	ret    

80102ed0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ed0:	55                   	push   %ebp
80102ed1:	89 e5                	mov    %esp,%ebp
80102ed3:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ed6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102edb:	85 c0                	test   %eax,%eax
80102edd:	74 14                	je     80102ef3 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ee6:	00 
80102ee7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eee:	e8 0b fe ff ff       	call   80102cfe <lapicw>
}
80102ef3:	c9                   	leave  
80102ef4:	c3                   	ret    

80102ef5 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ef5:	55                   	push   %ebp
80102ef6:	89 e5                	mov    %esp,%ebp
}
80102ef8:	5d                   	pop    %ebp
80102ef9:	c3                   	ret    

80102efa <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102efa:	55                   	push   %ebp
80102efb:	89 e5                	mov    %esp,%ebp
80102efd:	83 ec 1c             	sub    $0x1c,%esp
80102f00:	8b 45 08             	mov    0x8(%ebp),%eax
80102f03:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f06:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f0d:	00 
80102f0e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f15:	e8 b6 fd ff ff       	call   80102cd0 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f1a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f21:	00 
80102f22:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f29:	e8 a2 fd ff ff       	call   80102cd0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f2e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f35:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f38:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f40:	8d 50 02             	lea    0x2(%eax),%edx
80102f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f46:	c1 e8 04             	shr    $0x4,%eax
80102f49:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f4c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f50:	c1 e0 18             	shl    $0x18,%eax
80102f53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f57:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f5e:	e8 9b fd ff ff       	call   80102cfe <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f63:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f6a:	00 
80102f6b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f72:	e8 87 fd ff ff       	call   80102cfe <lapicw>
  microdelay(200);
80102f77:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f7e:	e8 72 ff ff ff       	call   80102ef5 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f83:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f8a:	00 
80102f8b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f92:	e8 67 fd ff ff       	call   80102cfe <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f97:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f9e:	e8 52 ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fa3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102faa:	eb 40                	jmp    80102fec <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fac:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb0:	c1 e0 18             	shl    $0x18,%eax
80102fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fb7:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fbe:	e8 3b fd ff ff       	call   80102cfe <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc6:	c1 e8 0c             	shr    $0xc,%eax
80102fc9:	80 cc 06             	or     $0x6,%ah
80102fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd7:	e8 22 fd ff ff       	call   80102cfe <lapicw>
    microdelay(200);
80102fdc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe3:	e8 0d ff ff ff       	call   80102ef5 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fe8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fec:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ff0:	7e ba                	jle    80102fac <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102ff2:	c9                   	leave  
80102ff3:	c3                   	ret    

80102ff4 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102ff4:	55                   	push   %ebp
80102ff5:	89 e5                	mov    %esp,%ebp
80102ff7:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80102ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80102ffd:	0f b6 c0             	movzbl %al,%eax
80103000:	89 44 24 04          	mov    %eax,0x4(%esp)
80103004:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010300b:	e8 c0 fc ff ff       	call   80102cd0 <outb>
  microdelay(200);
80103010:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103017:	e8 d9 fe ff ff       	call   80102ef5 <microdelay>

  return inb(CMOS_RETURN);
8010301c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103023:	e8 8b fc ff ff       	call   80102cb3 <inb>
80103028:	0f b6 c0             	movzbl %al,%eax
}
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
80103030:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010303a:	e8 b5 ff ff ff       	call   80102ff4 <cmos_read>
8010303f:	8b 55 08             	mov    0x8(%ebp),%edx
80103042:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103044:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010304b:	e8 a4 ff ff ff       	call   80102ff4 <cmos_read>
80103050:	8b 55 08             	mov    0x8(%ebp),%edx
80103053:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103056:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010305d:	e8 92 ff ff ff       	call   80102ff4 <cmos_read>
80103062:	8b 55 08             	mov    0x8(%ebp),%edx
80103065:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103068:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010306f:	e8 80 ff ff ff       	call   80102ff4 <cmos_read>
80103074:	8b 55 08             	mov    0x8(%ebp),%edx
80103077:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010307a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103081:	e8 6e ff ff ff       	call   80102ff4 <cmos_read>
80103086:	8b 55 08             	mov    0x8(%ebp),%edx
80103089:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010308c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103093:	e8 5c ff ff ff       	call   80102ff4 <cmos_read>
80103098:	8b 55 08             	mov    0x8(%ebp),%edx
8010309b:	89 42 14             	mov    %eax,0x14(%edx)
}
8010309e:	c9                   	leave  
8010309f:	c3                   	ret    

801030a0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030a6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030ad:	e8 42 ff ff ff       	call   80102ff4 <cmos_read>
801030b2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b8:	83 e0 04             	and    $0x4,%eax
801030bb:	85 c0                	test   %eax,%eax
801030bd:	0f 94 c0             	sete   %al
801030c0:	0f b6 c0             	movzbl %al,%eax
801030c3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801030c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801030c9:	89 04 24             	mov    %eax,(%esp)
801030cc:	e8 5c ff ff ff       	call   8010302d <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801030d1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801030d8:	e8 17 ff ff ff       	call   80102ff4 <cmos_read>
801030dd:	25 80 00 00 00       	and    $0x80,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 02                	je     801030e8 <cmostime+0x48>
        continue;
801030e6:	eb 36                	jmp    8010311e <cmostime+0x7e>
    fill_rtcdate(&t2);
801030e8:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 3a ff ff ff       	call   8010302d <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801030f3:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801030fa:	00 
801030fb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801030fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103102:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103105:	89 04 24             	mov    %eax,(%esp)
80103108:	e8 e0 26 00 00       	call   801057ed <memcmp>
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 0d                	jne    8010311e <cmostime+0x7e>
      break;
80103111:	90                   	nop
  }

  // convert
  if (bcd) {
80103112:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103116:	0f 84 ac 00 00 00    	je     801031c8 <cmostime+0x128>
8010311c:	eb 02                	jmp    80103120 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010311e:	eb a6                	jmp    801030c6 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103120:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103123:	c1 e8 04             	shr    $0x4,%eax
80103126:	89 c2                	mov    %eax,%edx
80103128:	89 d0                	mov    %edx,%eax
8010312a:	c1 e0 02             	shl    $0x2,%eax
8010312d:	01 d0                	add    %edx,%eax
8010312f:	01 c0                	add    %eax,%eax
80103131:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103134:	83 e2 0f             	and    $0xf,%edx
80103137:	01 d0                	add    %edx,%eax
80103139:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010313c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010313f:	c1 e8 04             	shr    $0x4,%eax
80103142:	89 c2                	mov    %eax,%edx
80103144:	89 d0                	mov    %edx,%eax
80103146:	c1 e0 02             	shl    $0x2,%eax
80103149:	01 d0                	add    %edx,%eax
8010314b:	01 c0                	add    %eax,%eax
8010314d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103150:	83 e2 0f             	and    $0xf,%edx
80103153:	01 d0                	add    %edx,%eax
80103155:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010315b:	c1 e8 04             	shr    $0x4,%eax
8010315e:	89 c2                	mov    %eax,%edx
80103160:	89 d0                	mov    %edx,%eax
80103162:	c1 e0 02             	shl    $0x2,%eax
80103165:	01 d0                	add    %edx,%eax
80103167:	01 c0                	add    %eax,%eax
80103169:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010316c:	83 e2 0f             	and    $0xf,%edx
8010316f:	01 d0                	add    %edx,%eax
80103171:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103177:	c1 e8 04             	shr    $0x4,%eax
8010317a:	89 c2                	mov    %eax,%edx
8010317c:	89 d0                	mov    %edx,%eax
8010317e:	c1 e0 02             	shl    $0x2,%eax
80103181:	01 d0                	add    %edx,%eax
80103183:	01 c0                	add    %eax,%eax
80103185:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103188:	83 e2 0f             	and    $0xf,%edx
8010318b:	01 d0                	add    %edx,%eax
8010318d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103190:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103193:	c1 e8 04             	shr    $0x4,%eax
80103196:	89 c2                	mov    %eax,%edx
80103198:	89 d0                	mov    %edx,%eax
8010319a:	c1 e0 02             	shl    $0x2,%eax
8010319d:	01 d0                	add    %edx,%eax
8010319f:	01 c0                	add    %eax,%eax
801031a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031a4:	83 e2 0f             	and    $0xf,%edx
801031a7:	01 d0                	add    %edx,%eax
801031a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031af:	c1 e8 04             	shr    $0x4,%eax
801031b2:	89 c2                	mov    %eax,%edx
801031b4:	89 d0                	mov    %edx,%eax
801031b6:	c1 e0 02             	shl    $0x2,%eax
801031b9:	01 d0                	add    %edx,%eax
801031bb:	01 c0                	add    %eax,%eax
801031bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031c0:	83 e2 0f             	and    $0xf,%edx
801031c3:	01 d0                	add    %edx,%eax
801031c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801031c8:	8b 45 08             	mov    0x8(%ebp),%eax
801031cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031ce:	89 10                	mov    %edx,(%eax)
801031d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031d3:	89 50 04             	mov    %edx,0x4(%eax)
801031d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d9:	89 50 08             	mov    %edx,0x8(%eax)
801031dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031df:	89 50 0c             	mov    %edx,0xc(%eax)
801031e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031e5:	89 50 10             	mov    %edx,0x10(%eax)
801031e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801031eb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801031ee:	8b 45 08             	mov    0x8(%ebp),%eax
801031f1:	8b 40 14             	mov    0x14(%eax),%eax
801031f4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801031fa:	8b 45 08             	mov    0x8(%ebp),%eax
801031fd:	89 50 14             	mov    %edx,0x14(%eax)
}
80103200:	c9                   	leave  
80103201:	c3                   	ret    

80103202 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103202:	55                   	push   %ebp
80103203:	89 e5                	mov    %esp,%ebp
80103205:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103208:	c7 44 24 04 64 92 10 	movl   $0x80109264,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103217:	e8 e5 22 00 00       	call   80105501 <initlock>
  readsb(ROOTDEV, &sb);
8010321c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010321f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010322a:	e8 c2 e0 ff ff       	call   801012f1 <readsb>
  log.start = sb.size - sb.nlog;
8010322f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103235:	29 c2                	sub    %eax,%edx
80103237:	89 d0                	mov    %edx,%eax
80103239:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
8010323e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103241:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
80103246:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
8010324d:	00 00 00 
  recover_from_log();
80103250:	e8 9a 01 00 00       	call   801033ef <recover_from_log>
}
80103255:	c9                   	leave  
80103256:	c3                   	ret    

80103257 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103257:	55                   	push   %ebp
80103258:	89 e5                	mov    %esp,%ebp
8010325a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010325d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103264:	e9 8c 00 00 00       	jmp    801032f5 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103269:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	83 c0 01             	add    $0x1,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010327e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103282:	89 04 24             	mov    %eax,(%esp)
80103285:	e8 1c cf ff ff       	call   801001a6 <bread>
8010328a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 c0 10             	add    $0x10,%eax
80103293:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
8010329a:	89 c2                	mov    %eax,%edx
8010329c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801032a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801032a5:	89 04 24             	mov    %eax,(%esp)
801032a8:	e8 f9 ce ff ff       	call   801001a6 <bread>
801032ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032b3:	8d 50 18             	lea    0x18(%eax),%edx
801032b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032b9:	83 c0 18             	add    $0x18,%eax
801032bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801032c3:	00 
801032c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801032c8:	89 04 24             	mov    %eax,(%esp)
801032cb:	e8 75 25 00 00       	call   80105845 <memmove>
    bwrite(dbuf);  // write dst to disk
801032d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 02 cf ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801032db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032de:	89 04 24             	mov    %eax,(%esp)
801032e1:	e8 31 cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801032e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e9:	89 04 24             	mov    %eax,(%esp)
801032ec:	e8 26 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f5:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801032fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032fd:	0f 8f 66 ff ff ff    	jg     80103269 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103303:	c9                   	leave  
80103304:	c3                   	ret    

80103305 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103305:	55                   	push   %ebp
80103306:	89 e5                	mov    %esp,%ebp
80103308:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010330b:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103310:	89 c2                	mov    %eax,%edx
80103312:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103317:	89 54 24 04          	mov    %edx,0x4(%esp)
8010331b:	89 04 24             	mov    %eax,(%esp)
8010331e:	e8 83 ce ff ff       	call   801001a6 <bread>
80103323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103329:	83 c0 18             	add    $0x18,%eax
8010332c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010332f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103332:	8b 00                	mov    (%eax),%eax
80103334:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103340:	eb 1b                	jmp    8010335d <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103342:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103345:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103348:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010334c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010334f:	83 c2 10             	add    $0x10,%edx
80103352:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103365:	7f db                	jg     80103342 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336a:	89 04 24             	mov    %eax,(%esp)
8010336d:	e8 a5 ce ff ff       	call   80100217 <brelse>
}
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010337a:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103386:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338a:	89 04 24             	mov    %eax,(%esp)
8010338d:	e8 14 ce ff ff       	call   801001a6 <bread>
80103392:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103398:	83 c0 18             	add    $0x18,%eax
8010339b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010339e:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801033a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b0:	eb 1b                	jmp    801033cd <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b5:	83 c0 10             	add    $0x10,%eax
801033b8:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
801033bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033c5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801033c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033cd:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033d5:	7f db                	jg     801033b2 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 fb cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801033e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 2a ce ff ff       	call   80100217 <brelse>
}
801033ed:	c9                   	leave  
801033ee:	c3                   	ret    

801033ef <recover_from_log>:

static void
recover_from_log(void)
{
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801033f5:	e8 0b ff ff ff       	call   80103305 <read_head>
  install_trans(); // if committed, copy from log to disk
801033fa:	e8 58 fe ff ff       	call   80103257 <install_trans>
  log.lh.n = 0;
801033ff:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103406:	00 00 00 
  write_head(); // clear the log
80103409:	e8 66 ff ff ff       	call   80103374 <write_head>
}
8010340e:	c9                   	leave  
8010340f:	c3                   	ret    

80103410 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103416:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010341d:	e8 00 21 00 00       	call   80105522 <acquire>
  while(1){
    if(log.committing){
80103422:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010343a:	e8 21 1b 00 00       	call   80104f60 <sleep>
8010343f:	eb 4f                	jmp    80103490 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103441:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103447:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010344c:	8d 50 01             	lea    0x1(%eax),%edx
8010344f:	89 d0                	mov    %edx,%eax
80103451:	c1 e0 02             	shl    $0x2,%eax
80103454:	01 d0                	add    %edx,%eax
80103456:	01 c0                	add    %eax,%eax
80103458:	01 c8                	add    %ecx,%eax
8010345a:	83 f8 1e             	cmp    $0x1e,%eax
8010345d:	7e 16                	jle    80103475 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010345f:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103466:	80 
80103467:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010346e:	e8 ed 1a 00 00       	call   80104f60 <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103482:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103489:	e8 f6 20 00 00       	call   80105584 <release>
      break;
8010348e:	eb 02                	jmp    80103492 <begin_op+0x82>
    }
  }
80103490:	eb 90                	jmp    80103422 <begin_op+0x12>
}
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034a1:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034a8:	e8 75 20 00 00       	call   80105522 <acquire>
  log.outstanding -= 1;
801034ad:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801034ba:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 68 92 10 80 	movl   $0x80109268,(%esp)
801034ca:	e8 6b d0 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
801034cf:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	75 13                	jne    801034eb <end_op+0x57>
    do_commit = 1;
801034d8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801034df:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801034e6:	00 00 00 
801034e9:	eb 0c                	jmp    801034f7 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801034eb:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034f2:	e8 50 1b 00 00       	call   80105047 <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034fe:	e8 81 20 00 00       	call   80105584 <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103515:	e8 08 20 00 00       	call   80105522 <acquire>
    log.committing = 0;
8010351a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010352b:	e8 17 1b 00 00       	call   80105047 <wakeup>
    release(&log.lock);
80103530:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103537:	e8 48 20 00 00       	call   80105584 <release>
  }
}
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010353e:	55                   	push   %ebp
8010353f:	89 e5                	mov    %esp,%ebp
80103541:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010354b:	e9 8c 00 00 00       	jmp    801035dc <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103550:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103559:	01 d0                	add    %edx,%eax
8010355b:	83 c0 01             	add    $0x1,%eax
8010355e:	89 c2                	mov    %eax,%edx
80103560:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103565:	89 54 24 04          	mov    %edx,0x4(%esp)
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 35 cc ff ff       	call   801001a6 <bread>
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
80103574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103577:	83 c0 10             	add    $0x10,%eax
8010357a:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103581:	89 c2                	mov    %eax,%edx
80103583:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358c:	89 04 24             	mov    %eax,(%esp)
8010358f:	e8 12 cc ff ff       	call   801001a6 <bread>
80103594:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359a:	8d 50 18             	lea    0x18(%eax),%edx
8010359d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a0:	83 c0 18             	add    $0x18,%eax
801035a3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035aa:	00 
801035ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801035af:	89 04 24             	mov    %eax,(%esp)
801035b2:	e8 8e 22 00 00       	call   80105845 <memmove>
    bwrite(to);  // write the log
801035b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ba:	89 04 24             	mov    %eax,(%esp)
801035bd:	e8 1b cc ff ff       	call   801001dd <bwrite>
    brelse(from); 
801035c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c5:	89 04 24             	mov    %eax,(%esp)
801035c8:	e8 4a cc ff ff       	call   80100217 <brelse>
    brelse(to);
801035cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d0:	89 04 24             	mov    %eax,(%esp)
801035d3:	e8 3f cc ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035dc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035e4:	0f 8f 66 ff ff ff    	jg     80103550 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <commit>:

static void
commit()
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
801035ef:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801035f2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035f7:	85 c0                	test   %eax,%eax
801035f9:	7e 1e                	jle    80103619 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801035fb:	e8 3e ff ff ff       	call   8010353e <write_log>
    write_head();    // Write header to disk -- the real commit
80103600:	e8 6f fd ff ff       	call   80103374 <write_head>
    install_trans(); // Now install writes to home locations
80103605:	e8 4d fc ff ff       	call   80103257 <install_trans>
    log.lh.n = 0; 
8010360a:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103611:	00 00 00 
    write_head();    // Erase the transaction from the log
80103614:	e8 5b fd ff ff       	call   80103374 <write_head>
  }
}
80103619:	c9                   	leave  
8010361a:	c3                   	ret    

8010361b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010361b:	55                   	push   %ebp
8010361c:	89 e5                	mov    %esp,%ebp
8010361e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103621:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103626:	83 f8 1d             	cmp    $0x1d,%eax
80103629:	7f 12                	jg     8010363d <log_write+0x22>
8010362b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103630:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103636:	83 ea 01             	sub    $0x1,%edx
80103639:	39 d0                	cmp    %edx,%eax
8010363b:	7c 0c                	jl     80103649 <log_write+0x2e>
    panic("too big a transaction");
8010363d:	c7 04 24 77 92 10 80 	movl   $0x80109277,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 8d 92 10 80 	movl   $0x8010928d,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103665:	e8 b8 1e 00 00       	call   80105522 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010366a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103671:	eb 1f                	jmp    80103692 <log_write+0x77>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
80103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103676:	83 c0 10             	add    $0x10,%eax
80103679:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103680:	89 c2                	mov    %eax,%edx
80103682:	8b 45 08             	mov    0x8(%ebp),%eax
80103685:	8b 40 08             	mov    0x8(%eax),%eax
80103688:	39 c2                	cmp    %eax,%edx
8010368a:	75 02                	jne    8010368e <log_write+0x73>
      break;
8010368c:	eb 0e                	jmp    8010369c <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
8010368e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103692:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103697:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369a:	7f d7                	jg     80103673 <log_write+0x58>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
  if (i == log.lh.n)
801036af:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xab>
    log.lh.n++;
801036b9:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	83 c8 04             	or     $0x4,%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801036d5:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801036dc:	e8 a3 1e 00 00       	call   80105584 <release>
}
801036e1:	c9                   	leave  
801036e2:	c3                   	ret    

801036e3 <v2p>:
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	8b 45 08             	mov    0x8(%ebp),%eax
801036e9:	05 00 00 00 80       	add    $0x80000000,%eax
801036ee:	5d                   	pop    %ebp
801036ef:	c3                   	ret    

801036f0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	05 00 00 00 80       	add    $0x80000000,%eax
801036fb:	5d                   	pop    %ebp
801036fc:	c3                   	ret    

801036fd <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103703:	8b 55 08             	mov    0x8(%ebp),%edx
80103706:	8b 45 0c             	mov    0xc(%ebp),%eax
80103709:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010370c:	f0 87 02             	lock xchg %eax,(%edx)
8010370f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103712:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 e4 f0             	and    $0xfffffff0,%esp
8010371d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103720:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103727:	80 
80103728:	c7 04 24 9c 8f 11 80 	movl   $0x80118f9c,(%esp)
8010372f:	e8 80 f2 ff ff       	call   801029b4 <kinit1>
  kvmalloc();      // kernel page table
80103734:	e8 72 51 00 00       	call   801088ab <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 46 04 00 00       	call   80103b84 <mpinit>
  lapicinit();
8010373e:	e8 dc f5 ff ff       	call   80102d1f <lapicinit>
  seginit();       // set up segments
80103743:	e8 f6 4a 00 00       	call   8010823e <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103748:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	89 44 24 04          	mov    %eax,0x4(%esp)
80103758:	c7 04 24 a8 92 10 80 	movl   $0x801092a8,(%esp)
8010375f:	e8 3c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103764:	e8 79 06 00 00       	call   80103de2 <picinit>
  ioapicinit();    // another interrupt controller
80103769:	e8 3c f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010376e:	e8 0e d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103773:	e8 15 3e 00 00       	call   8010758d <uartinit>
  pinit();         // process table
80103778:	e8 85 0e 00 00       	call   80104602 <pinit>
  tvinit();        // trap vectors
8010377d:	e8 d6 35 00 00       	call   80106d58 <tvinit>
  binit();         // buffer cache
80103782:	e8 ad c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103787:	e8 7e d7 ff ff       	call   80100f0a <fileinit>
  iinit();         // inode cache
8010378c:	e8 13 de ff ff       	call   801015a4 <iinit>
  ideinit();       // disk
80103791:	e8 7d ed ff ff       	call   80102513 <ideinit>
  if(!ismp)
80103796:	a1 64 33 11 80       	mov    0x80113364,%eax
8010379b:	85 c0                	test   %eax,%eax
8010379d:	75 05                	jne    801037a4 <main+0x8d>
    timerinit();   // uniprocessor timer
8010379f:	e8 f2 34 00 00       	call   80106c96 <timerinit>
  startothers();   // start other processors
801037a4:	e8 7f 00 00 00       	call   80103828 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b0:	8e 
801037b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037b8:	e8 2f f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037bd:	e8 8a 0f 00 00       	call   8010474c <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037c2:	e8 1a 00 00 00       	call   801037e1 <mpmain>

801037c7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037c7:	55                   	push   %ebp
801037c8:	89 e5                	mov    %esp,%ebp
801037ca:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801037cd:	e8 f0 50 00 00       	call   801088c2 <switchkvm>
  seginit();
801037d2:	e8 67 4a 00 00       	call   8010823e <seginit>
  lapicinit();
801037d7:	e8 43 f5 ff ff       	call   80102d1f <lapicinit>
  mpmain();
801037dc:	e8 00 00 00 00       	call   801037e1 <mpmain>

801037e1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037e1:	55                   	push   %ebp
801037e2:	89 e5                	mov    %esp,%ebp
801037e4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ed:	0f b6 00             	movzbl (%eax),%eax
801037f0:	0f b6 c0             	movzbl %al,%eax
801037f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801037f7:	c7 04 24 bf 92 10 80 	movl   $0x801092bf,(%esp)
801037fe:	e8 9d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103803:	e8 c4 36 00 00       	call   80106ecc <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380e:	05 a8 00 00 00       	add    $0xa8,%eax
80103813:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010381a:	00 
8010381b:	89 04 24             	mov    %eax,(%esp)
8010381e:	e8 da fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103823:	e8 6f 15 00 00       	call   80104d97 <scheduler>

80103828 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	53                   	push   %ebx
8010382c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010382f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103836:	e8 b5 fe ff ff       	call   801036f0 <p2v>
8010383b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010383e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103843:	89 44 24 08          	mov    %eax,0x8(%esp)
80103847:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
8010384e:	80 
8010384f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103852:	89 04 24             	mov    %eax,(%esp)
80103855:	e8 eb 1f 00 00       	call   80105845 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010385a:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103861:	e9 85 00 00 00       	jmp    801038eb <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103866:	e8 0d f6 ff ff       	call   80102e78 <cpunum>
8010386b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103871:	05 80 33 11 80       	add    $0x80113380,%eax
80103876:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103879:	75 02                	jne    8010387d <startothers+0x55>
      continue;
8010387b:	eb 67                	jmp    801038e4 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010387d:	e8 60 f2 ff ff       	call   80102ae2 <kalloc>
80103882:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103888:	83 e8 04             	sub    $0x4,%eax
8010388b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010388e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103894:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103899:	83 e8 08             	sub    $0x8,%eax
8010389c:	c7 00 c7 37 10 80    	movl   $0x801037c7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a5:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038a8:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
801038af:	e8 2f fe ff ff       	call   801036e3 <v2p>
801038b4:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b9:	89 04 24             	mov    %eax,(%esp)
801038bc:	e8 22 fe ff ff       	call   801036e3 <v2p>
801038c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038c4:	0f b6 12             	movzbl (%edx),%edx
801038c7:	0f b6 d2             	movzbl %dl,%edx
801038ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801038ce:	89 14 24             	mov    %edx,(%esp)
801038d1:	e8 24 f6 ff ff       	call   80102efa <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038d6:	90                   	nop
801038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038da:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	74 f3                	je     801038d7 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038e4:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038eb:	a1 60 39 11 80       	mov    0x80113960,%eax
801038f0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038f6:	05 80 33 11 80       	add    $0x80113380,%eax
801038fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038fe:	0f 87 62 ff ff ff    	ja     80103866 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103904:	83 c4 24             	add    $0x24,%esp
80103907:	5b                   	pop    %ebx
80103908:	5d                   	pop    %ebp
80103909:	c3                   	ret    

8010390a <p2v>:
8010390a:	55                   	push   %ebp
8010390b:	89 e5                	mov    %esp,%ebp
8010390d:	8b 45 08             	mov    0x8(%ebp),%eax
80103910:	05 00 00 00 80       	add    $0x80000000,%eax
80103915:	5d                   	pop    %ebp
80103916:	c3                   	ret    

80103917 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	83 ec 14             	sub    $0x14,%esp
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103924:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103928:	89 c2                	mov    %eax,%edx
8010392a:	ec                   	in     (%dx),%al
8010392b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010392e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103932:	c9                   	leave  
80103933:	c3                   	ret    

80103934 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103934:	55                   	push   %ebp
80103935:	89 e5                	mov    %esp,%ebp
80103937:	83 ec 08             	sub    $0x8,%esp
8010393a:	8b 55 08             	mov    0x8(%ebp),%edx
8010393d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103940:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103944:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103947:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010394b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010394f:	ee                   	out    %al,(%dx)
}
80103950:	c9                   	leave  
80103951:	c3                   	ret    

80103952 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103952:	55                   	push   %ebp
80103953:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103955:	a1 64 c6 10 80       	mov    0x8010c664,%eax
8010395a:	89 c2                	mov    %eax,%edx
8010395c:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103961:	29 c2                	sub    %eax,%edx
80103963:	89 d0                	mov    %edx,%eax
80103965:	c1 f8 02             	sar    $0x2,%eax
80103968:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010396e:	5d                   	pop    %ebp
8010396f:	c3                   	ret    

80103970 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103976:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010397d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103984:	eb 15                	jmp    8010399b <sum+0x2b>
    sum += addr[i];
80103986:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103989:	8b 45 08             	mov    0x8(%ebp),%eax
8010398c:	01 d0                	add    %edx,%eax
8010398e:	0f b6 00             	movzbl (%eax),%eax
80103991:	0f b6 c0             	movzbl %al,%eax
80103994:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103997:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010399b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010399e:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039a1:	7c e3                	jl     80103986 <sum+0x16>
    sum += addr[i];
  return sum;
801039a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039a6:	c9                   	leave  
801039a7:	c3                   	ret    

801039a8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039a8:	55                   	push   %ebp
801039a9:	89 e5                	mov    %esp,%ebp
801039ab:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039ae:	8b 45 08             	mov    0x8(%ebp),%eax
801039b1:	89 04 24             	mov    %eax,(%esp)
801039b4:	e8 51 ff ff ff       	call   8010390a <p2v>
801039b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801039bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c2:	01 d0                	add    %edx,%eax
801039c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039cd:	eb 3f                	jmp    80103a0e <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039cf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039d6:	00 
801039d7:	c7 44 24 04 d0 92 10 	movl   $0x801092d0,0x4(%esp)
801039de:	80 
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 03 1e 00 00       	call   801057ed <memcmp>
801039ea:	85 c0                	test   %eax,%eax
801039ec:	75 1c                	jne    80103a0a <mpsearch1+0x62>
801039ee:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039f5:	00 
801039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f9:	89 04 24             	mov    %eax,(%esp)
801039fc:	e8 6f ff ff ff       	call   80103970 <sum>
80103a01:	84 c0                	test   %al,%al
80103a03:	75 05                	jne    80103a0a <mpsearch1+0x62>
      return (struct mp*)p;
80103a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a08:	eb 11                	jmp    80103a1b <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a0a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a11:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a14:	72 b9                	jb     801039cf <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a1b:	c9                   	leave  
80103a1c:	c3                   	ret    

80103a1d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a1d:	55                   	push   %ebp
80103a1e:	89 e5                	mov    %esp,%ebp
80103a20:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a23:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2d:	83 c0 0f             	add    $0xf,%eax
80103a30:	0f b6 00             	movzbl (%eax),%eax
80103a33:	0f b6 c0             	movzbl %al,%eax
80103a36:	c1 e0 08             	shl    $0x8,%eax
80103a39:	89 c2                	mov    %eax,%edx
80103a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3e:	83 c0 0e             	add    $0xe,%eax
80103a41:	0f b6 00             	movzbl (%eax),%eax
80103a44:	0f b6 c0             	movzbl %al,%eax
80103a47:	09 d0                	or     %edx,%eax
80103a49:	c1 e0 04             	shl    $0x4,%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a53:	74 21                	je     80103a76 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a55:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a5c:	00 
80103a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a60:	89 04 24             	mov    %eax,(%esp)
80103a63:	e8 40 ff ff ff       	call   801039a8 <mpsearch1>
80103a68:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a6b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a6f:	74 50                	je     80103ac1 <mpsearch+0xa4>
      return mp;
80103a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a74:	eb 5f                	jmp    80103ad5 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a79:	83 c0 14             	add    $0x14,%eax
80103a7c:	0f b6 00             	movzbl (%eax),%eax
80103a7f:	0f b6 c0             	movzbl %al,%eax
80103a82:	c1 e0 08             	shl    $0x8,%eax
80103a85:	89 c2                	mov    %eax,%edx
80103a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8a:	83 c0 13             	add    $0x13,%eax
80103a8d:	0f b6 00             	movzbl (%eax),%eax
80103a90:	0f b6 c0             	movzbl %al,%eax
80103a93:	09 d0                	or     %edx,%eax
80103a95:	c1 e0 0a             	shl    $0xa,%eax
80103a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a9e:	2d 00 04 00 00       	sub    $0x400,%eax
80103aa3:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aaa:	00 
80103aab:	89 04 24             	mov    %eax,(%esp)
80103aae:	e8 f5 fe ff ff       	call   801039a8 <mpsearch1>
80103ab3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aba:	74 05                	je     80103ac1 <mpsearch+0xa4>
      return mp;
80103abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103abf:	eb 14                	jmp    80103ad5 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ac1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ac8:	00 
80103ac9:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ad0:	e8 d3 fe ff ff       	call   801039a8 <mpsearch1>
}
80103ad5:	c9                   	leave  
80103ad6:	c3                   	ret    

80103ad7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ad7:	55                   	push   %ebp
80103ad8:	89 e5                	mov    %esp,%ebp
80103ada:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103add:	e8 3b ff ff ff       	call   80103a1d <mpsearch>
80103ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ae5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ae9:	74 0a                	je     80103af5 <mpconfig+0x1e>
80103aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aee:	8b 40 04             	mov    0x4(%eax),%eax
80103af1:	85 c0                	test   %eax,%eax
80103af3:	75 0a                	jne    80103aff <mpconfig+0x28>
    return 0;
80103af5:	b8 00 00 00 00       	mov    $0x0,%eax
80103afa:	e9 83 00 00 00       	jmp    80103b82 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b02:	8b 40 04             	mov    0x4(%eax),%eax
80103b05:	89 04 24             	mov    %eax,(%esp)
80103b08:	e8 fd fd ff ff       	call   8010390a <p2v>
80103b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b10:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b17:	00 
80103b18:	c7 44 24 04 d5 92 10 	movl   $0x801092d5,0x4(%esp)
80103b1f:	80 
80103b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b23:	89 04 24             	mov    %eax,(%esp)
80103b26:	e8 c2 1c 00 00       	call   801057ed <memcmp>
80103b2b:	85 c0                	test   %eax,%eax
80103b2d:	74 07                	je     80103b36 <mpconfig+0x5f>
    return 0;
80103b2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b34:	eb 4c                	jmp    80103b82 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b39:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b3d:	3c 01                	cmp    $0x1,%al
80103b3f:	74 12                	je     80103b53 <mpconfig+0x7c>
80103b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b44:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b48:	3c 04                	cmp    $0x4,%al
80103b4a:	74 07                	je     80103b53 <mpconfig+0x7c>
    return 0;
80103b4c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b51:	eb 2f                	jmp    80103b82 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b56:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b5a:	0f b7 c0             	movzwl %ax,%eax
80103b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b64:	89 04 24             	mov    %eax,(%esp)
80103b67:	e8 04 fe ff ff       	call   80103970 <sum>
80103b6c:	84 c0                	test   %al,%al
80103b6e:	74 07                	je     80103b77 <mpconfig+0xa0>
    return 0;
80103b70:	b8 00 00 00 00       	mov    $0x0,%eax
80103b75:	eb 0b                	jmp    80103b82 <mpconfig+0xab>
  *pmp = mp;
80103b77:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7d:	89 10                	mov    %edx,(%eax)
  return conf;
80103b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b82:	c9                   	leave  
80103b83:	c3                   	ret    

80103b84 <mpinit>:

void
mpinit(void)
{
80103b84:	55                   	push   %ebp
80103b85:	89 e5                	mov    %esp,%ebp
80103b87:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b8a:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103b91:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103b94:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103b97:	89 04 24             	mov    %eax,(%esp)
80103b9a:	e8 38 ff ff ff       	call   80103ad7 <mpconfig>
80103b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ba2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ba6:	75 05                	jne    80103bad <mpinit+0x29>
    return;
80103ba8:	e9 9c 01 00 00       	jmp    80103d49 <mpinit+0x1c5>
  ismp = 1;
80103bad:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103bb4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bba:	8b 40 24             	mov    0x24(%eax),%eax
80103bbd:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc5:	83 c0 2c             	add    $0x2c,%eax
80103bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bce:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bd2:	0f b7 d0             	movzwl %ax,%edx
80103bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd8:	01 d0                	add    %edx,%eax
80103bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bdd:	e9 f4 00 00 00       	jmp    80103cd6 <mpinit+0x152>
    switch(*p){
80103be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be5:	0f b6 00             	movzbl (%eax),%eax
80103be8:	0f b6 c0             	movzbl %al,%eax
80103beb:	83 f8 04             	cmp    $0x4,%eax
80103bee:	0f 87 bf 00 00 00    	ja     80103cb3 <mpinit+0x12f>
80103bf4:	8b 04 85 18 93 10 80 	mov    -0x7fef6ce8(,%eax,4),%eax
80103bfb:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c06:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c0a:	0f b6 d0             	movzbl %al,%edx
80103c0d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c12:	39 c2                	cmp    %eax,%edx
80103c14:	74 2d                	je     80103c43 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c19:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c1d:	0f b6 d0             	movzbl %al,%edx
80103c20:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c25:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c2d:	c7 04 24 da 92 10 80 	movl   $0x801092da,(%esp)
80103c34:	e8 67 c7 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103c39:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103c40:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c46:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c4a:	0f b6 c0             	movzbl %al,%eax
80103c4d:	83 e0 02             	and    $0x2,%eax
80103c50:	85 c0                	test   %eax,%eax
80103c52:	74 15                	je     80103c69 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103c54:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c59:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c5f:	05 80 33 11 80       	add    $0x80113380,%eax
80103c64:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103c69:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103c6f:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c74:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c7a:	81 c2 80 33 11 80    	add    $0x80113380,%edx
80103c80:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c82:	a1 60 39 11 80       	mov    0x80113960,%eax
80103c87:	83 c0 01             	add    $0x1,%eax
80103c8a:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103c8f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c93:	eb 41                	jmp    80103cd6 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c9e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ca2:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103ca7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cab:	eb 29                	jmp    80103cd6 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cad:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cb1:	eb 23                	jmp    80103cd6 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	0f b6 00             	movzbl (%eax),%eax
80103cb9:	0f b6 c0             	movzbl %al,%eax
80103cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cc0:	c7 04 24 f8 92 10 80 	movl   $0x801092f8,(%esp)
80103cc7:	e8 d4 c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103ccc:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103cd3:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cdc:	0f 82 00 ff ff ff    	jb     80103be2 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103ce2:	a1 64 33 11 80       	mov    0x80113364,%eax
80103ce7:	85 c0                	test   %eax,%eax
80103ce9:	75 1d                	jne    80103d08 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ceb:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103cf2:	00 00 00 
    lapic = 0;
80103cf5:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103cfc:	00 00 00 
    ioapicid = 0;
80103cff:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103d06:	eb 41                	jmp    80103d49 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d08:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d0b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d0f:	84 c0                	test   %al,%al
80103d11:	74 36                	je     80103d49 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d13:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d1a:	00 
80103d1b:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d22:	e8 0d fc ff ff       	call   80103934 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d27:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d2e:	e8 e4 fb ff ff       	call   80103917 <inb>
80103d33:	83 c8 01             	or     $0x1,%eax
80103d36:	0f b6 c0             	movzbl %al,%eax
80103d39:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d3d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d44:	e8 eb fb ff ff       	call   80103934 <outb>
  }
}
80103d49:	c9                   	leave  
80103d4a:	c3                   	ret    

80103d4b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d4b:	55                   	push   %ebp
80103d4c:	89 e5                	mov    %esp,%ebp
80103d4e:	83 ec 08             	sub    $0x8,%esp
80103d51:	8b 55 08             	mov    0x8(%ebp),%edx
80103d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d57:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d5b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d5e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d62:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d66:	ee                   	out    %al,(%dx)
}
80103d67:	c9                   	leave  
80103d68:	c3                   	ret    

80103d69 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	83 ec 0c             	sub    $0xc,%esp
80103d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d72:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d76:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d7a:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103d80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d84:	0f b6 c0             	movzbl %al,%eax
80103d87:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d8b:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d92:	e8 b4 ff ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d97:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d9b:	66 c1 e8 08          	shr    $0x8,%ax
80103d9f:	0f b6 c0             	movzbl %al,%eax
80103da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103da6:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dad:	e8 99 ff ff ff       	call   80103d4b <outb>
}
80103db2:	c9                   	leave  
80103db3:	c3                   	ret    

80103db4 <picenable>:

void
picenable(int irq)
{
80103db4:	55                   	push   %ebp
80103db5:	89 e5                	mov    %esp,%ebp
80103db7:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dba:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbd:	ba 01 00 00 00       	mov    $0x1,%edx
80103dc2:	89 c1                	mov    %eax,%ecx
80103dc4:	d3 e2                	shl    %cl,%edx
80103dc6:	89 d0                	mov    %edx,%eax
80103dc8:	f7 d0                	not    %eax
80103dca:	89 c2                	mov    %eax,%edx
80103dcc:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103dd3:	21 d0                	and    %edx,%eax
80103dd5:	0f b7 c0             	movzwl %ax,%eax
80103dd8:	89 04 24             	mov    %eax,(%esp)
80103ddb:	e8 89 ff ff ff       	call   80103d69 <picsetmask>
}
80103de0:	c9                   	leave  
80103de1:	c3                   	ret    

80103de2 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103de2:	55                   	push   %ebp
80103de3:	89 e5                	mov    %esp,%ebp
80103de5:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103de8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103def:	00 
80103df0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df7:	e8 4f ff ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, 0xFF);
80103dfc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e03:	00 
80103e04:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e0b:	e8 3b ff ff ff       	call   80103d4b <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e10:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e17:	00 
80103e18:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e1f:	e8 27 ff ff ff       	call   80103d4b <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e24:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e2b:	00 
80103e2c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e33:	e8 13 ff ff ff       	call   80103d4b <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e38:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e3f:	00 
80103e40:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e47:	e8 ff fe ff ff       	call   80103d4b <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e4c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e53:	00 
80103e54:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e5b:	e8 eb fe ff ff       	call   80103d4b <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e60:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e67:	00 
80103e68:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e6f:	e8 d7 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e74:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e7b:	00 
80103e7c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e83:	e8 c3 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e88:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e8f:	00 
80103e90:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e97:	e8 af fe ff ff       	call   80103d4b <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e9c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ea3:	00 
80103ea4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eab:	e8 9b fe ff ff       	call   80103d4b <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103eb0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103eb7:	00 
80103eb8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ebf:	e8 87 fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ec4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ecb:	00 
80103ecc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ed3:	e8 73 fe ff ff       	call   80103d4b <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ed8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103edf:	00 
80103ee0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ee7:	e8 5f fe ff ff       	call   80103d4b <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103eec:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ef3:	00 
80103ef4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103efb:	e8 4b fe ff ff       	call   80103d4b <outb>

  if(irqmask != 0xFFFF)
80103f00:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f07:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f0b:	74 12                	je     80103f1f <picinit+0x13d>
    picsetmask(irqmask);
80103f0d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f14:	0f b7 c0             	movzwl %ax,%eax
80103f17:	89 04 24             	mov    %eax,(%esp)
80103f1a:	e8 4a fe ff ff       	call   80103d69 <picsetmask>
}
80103f1f:	c9                   	leave  
80103f20:	c3                   	ret    

80103f21 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f21:	55                   	push   %ebp
80103f22:	89 e5                	mov    %esp,%ebp
80103f24:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3a:	8b 10                	mov    (%eax),%edx
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f41:	e8 e0 cf ff ff       	call   80100f26 <filealloc>
80103f46:	8b 55 08             	mov    0x8(%ebp),%edx
80103f49:	89 02                	mov    %eax,(%edx)
80103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4e:	8b 00                	mov    (%eax),%eax
80103f50:	85 c0                	test   %eax,%eax
80103f52:	0f 84 c8 00 00 00    	je     80104020 <pipealloc+0xff>
80103f58:	e8 c9 cf ff ff       	call   80100f26 <filealloc>
80103f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f60:	89 02                	mov    %eax,(%edx)
80103f62:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f65:	8b 00                	mov    (%eax),%eax
80103f67:	85 c0                	test   %eax,%eax
80103f69:	0f 84 b1 00 00 00    	je     80104020 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f6f:	e8 6e eb ff ff       	call   80102ae2 <kalloc>
80103f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f7b:	75 05                	jne    80103f82 <pipealloc+0x61>
    goto bad;
80103f7d:	e9 9e 00 00 00       	jmp    80104020 <pipealloc+0xff>
  p->readopen = 1;
80103f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f85:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f8c:	00 00 00 
  p->writeopen = 1;
80103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f92:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f99:	00 00 00 
  p->nwrite = 0;
80103f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fa6:	00 00 00 
  p->nread = 0;
80103fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fac:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fb3:	00 00 00 
  initlock(&p->lock, "pipe");
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb9:	c7 44 24 04 2c 93 10 	movl   $0x8010932c,0x4(%esp)
80103fc0:	80 
80103fc1:	89 04 24             	mov    %eax,(%esp)
80103fc4:	e8 38 15 00 00       	call   80105501 <initlock>
  (*f0)->type = FD_PIPE;
80103fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcc:	8b 00                	mov    (%eax),%eax
80103fce:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd7:	8b 00                	mov    (%eax),%eax
80103fd9:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe0:	8b 00                	mov    (%eax),%eax
80103fe2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fee:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff4:	8b 00                	mov    (%eax),%eax
80103ff6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fff:	8b 00                	mov    (%eax),%eax
80104001:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104005:	8b 45 0c             	mov    0xc(%ebp),%eax
80104008:	8b 00                	mov    (%eax),%eax
8010400a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010400e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104011:	8b 00                	mov    (%eax),%eax
80104013:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104016:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104019:	b8 00 00 00 00       	mov    $0x0,%eax
8010401e:	eb 42                	jmp    80104062 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104020:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104024:	74 0b                	je     80104031 <pipealloc+0x110>
    kfree((char*)p);
80104026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104029:	89 04 24             	mov    %eax,(%esp)
8010402c:	e8 18 ea ff ff       	call   80102a49 <kfree>
  if(*f0)
80104031:	8b 45 08             	mov    0x8(%ebp),%eax
80104034:	8b 00                	mov    (%eax),%eax
80104036:	85 c0                	test   %eax,%eax
80104038:	74 0d                	je     80104047 <pipealloc+0x126>
    fileclose(*f0);
8010403a:	8b 45 08             	mov    0x8(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 87 cf ff ff       	call   80100fce <fileclose>
  if(*f1)
80104047:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	85 c0                	test   %eax,%eax
8010404e:	74 0d                	je     8010405d <pipealloc+0x13c>
    fileclose(*f1);
80104050:	8b 45 0c             	mov    0xc(%ebp),%eax
80104053:	8b 00                	mov    (%eax),%eax
80104055:	89 04 24             	mov    %eax,(%esp)
80104058:	e8 71 cf ff ff       	call   80100fce <fileclose>
  return -1;
8010405d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104062:	c9                   	leave  
80104063:	c3                   	ret    

80104064 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010406a:	8b 45 08             	mov    0x8(%ebp),%eax
8010406d:	89 04 24             	mov    %eax,(%esp)
80104070:	e8 ad 14 00 00       	call   80105522 <acquire>
  if(writable){
80104075:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104079:	74 1f                	je     8010409a <pipeclose+0x36>
    p->writeopen = 0;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104085:	00 00 00 
    wakeup(&p->nread);
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	05 34 02 00 00       	add    $0x234,%eax
80104090:	89 04 24             	mov    %eax,(%esp)
80104093:	e8 af 0f 00 00       	call   80105047 <wakeup>
80104098:	eb 1d                	jmp    801040b7 <pipeclose+0x53>
  } else {
    p->readopen = 0;
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040a4:	00 00 00 
    wakeup(&p->nwrite);
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	05 38 02 00 00       	add    $0x238,%eax
801040af:	89 04 24             	mov    %eax,(%esp)
801040b2:	e8 90 0f 00 00       	call   80105047 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040c0:	85 c0                	test   %eax,%eax
801040c2:	75 25                	jne    801040e9 <pipeclose+0x85>
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040cd:	85 c0                	test   %eax,%eax
801040cf:	75 18                	jne    801040e9 <pipeclose+0x85>
    release(&p->lock);
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 a8 14 00 00       	call   80105584 <release>
    kfree((char*)p);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 62 e9 ff ff       	call   80102a49 <kfree>
801040e7:	eb 0b                	jmp    801040f4 <pipeclose+0x90>
  } else
    release(&p->lock);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 90 14 00 00       	call   80105584 <release>
}
801040f4:	c9                   	leave  
801040f5:	c3                   	ret    

801040f6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040f6:	55                   	push   %ebp
801040f7:	89 e5                	mov    %esp,%ebp
801040f9:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	89 04 24             	mov    %eax,(%esp)
80104102:	e8 1b 14 00 00       	call   80105522 <acquire>
  for(i = 0; i < n; i++){
80104107:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010410e:	e9 a6 00 00 00       	jmp    801041b9 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104113:	eb 57                	jmp    8010416c <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010411e:	85 c0                	test   %eax,%eax
80104120:	74 0d                	je     8010412f <pipewrite+0x39>
80104122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104128:	8b 40 28             	mov    0x28(%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	74 15                	je     80104144 <pipewrite+0x4e>
        release(&p->lock);
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	89 04 24             	mov    %eax,(%esp)
80104135:	e8 4a 14 00 00       	call   80105584 <release>
        return -1;
8010413a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010413f:	e9 9f 00 00 00       	jmp    801041e3 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	05 34 02 00 00       	add    $0x234,%eax
8010414c:	89 04 24             	mov    %eax,(%esp)
8010414f:	e8 f3 0e 00 00       	call   80105047 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	8b 55 08             	mov    0x8(%ebp),%edx
8010415a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104160:	89 44 24 04          	mov    %eax,0x4(%esp)
80104164:	89 14 24             	mov    %edx,(%esp)
80104167:	e8 f4 0d 00 00       	call   80104f60 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010417e:	05 00 02 00 00       	add    $0x200,%eax
80104183:	39 c2                	cmp    %eax,%edx
80104185:	74 8e                	je     80104115 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104190:	8d 48 01             	lea    0x1(%eax),%ecx
80104193:	8b 55 08             	mov    0x8(%ebp),%edx
80104196:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010419c:	25 ff 01 00 00       	and    $0x1ff,%eax
801041a1:	89 c1                	mov    %eax,%ecx
801041a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a9:	01 d0                	add    %edx,%eax
801041ab:	0f b6 10             	movzbl (%eax),%edx
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801041bf:	0f 8c 4e ff ff ff    	jl     80104113 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041c5:	8b 45 08             	mov    0x8(%ebp),%eax
801041c8:	05 34 02 00 00       	add    $0x234,%eax
801041cd:	89 04 24             	mov    %eax,(%esp)
801041d0:	e8 72 0e 00 00       	call   80105047 <wakeup>
  release(&p->lock);
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	89 04 24             	mov    %eax,(%esp)
801041db:	e8 a4 13 00 00       	call   80105584 <release>
  return n;
801041e0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041e3:	c9                   	leave  
801041e4:	c3                   	ret    

801041e5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041e5:	55                   	push   %ebp
801041e6:	89 e5                	mov    %esp,%ebp
801041e8:	53                   	push   %ebx
801041e9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041ec:	8b 45 08             	mov    0x8(%ebp),%eax
801041ef:	89 04 24             	mov    %eax,(%esp)
801041f2:	e8 2b 13 00 00       	call   80105522 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041f7:	eb 3a                	jmp    80104233 <piperead+0x4e>
    if(proc->killed){
801041f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041ff:	8b 40 28             	mov    0x28(%eax),%eax
80104202:	85 c0                	test   %eax,%eax
80104204:	74 15                	je     8010421b <piperead+0x36>
      release(&p->lock);
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	89 04 24             	mov    %eax,(%esp)
8010420c:	e8 73 13 00 00       	call   80105584 <release>
      return -1;
80104211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104216:	e9 b5 00 00 00       	jmp    801042d0 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	8b 55 08             	mov    0x8(%ebp),%edx
80104221:	81 c2 34 02 00 00    	add    $0x234,%edx
80104227:	89 44 24 04          	mov    %eax,0x4(%esp)
8010422b:	89 14 24             	mov    %edx,(%esp)
8010422e:	e8 2d 0d 00 00       	call   80104f60 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104233:	8b 45 08             	mov    0x8(%ebp),%eax
80104236:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104245:	39 c2                	cmp    %eax,%edx
80104247:	75 0d                	jne    80104256 <piperead+0x71>
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104252:	85 c0                	test   %eax,%eax
80104254:	75 a3                	jne    801041f9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104256:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425d:	eb 4b                	jmp    801042aa <piperead+0xc5>
    if(p->nread == p->nwrite)
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104271:	39 c2                	cmp    %eax,%edx
80104273:	75 02                	jne    80104277 <piperead+0x92>
      break;
80104275:	eb 3b                	jmp    801042b2 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104277:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010427a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104289:	8d 48 01             	lea    0x1(%eax),%ecx
8010428c:	8b 55 08             	mov    0x8(%ebp),%edx
8010428f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104295:	25 ff 01 00 00       	and    $0x1ff,%eax
8010429a:	89 c2                	mov    %eax,%edx
8010429c:	8b 45 08             	mov    0x8(%ebp),%eax
8010429f:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042a4:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801042b0:	7c ad                	jl     8010425f <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042b2:	8b 45 08             	mov    0x8(%ebp),%eax
801042b5:	05 38 02 00 00       	add    $0x238,%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 85 0d 00 00       	call   80105047 <wakeup>
  release(&p->lock);
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	89 04 24             	mov    %eax,(%esp)
801042c8:	e8 b7 12 00 00       	call   80105584 <release>
  return i;
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042d0:	83 c4 24             	add    $0x24,%esp
801042d3:	5b                   	pop    %ebx
801042d4:	5d                   	pop    %ebp
801042d5:	c3                   	ret    

801042d6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042d6:	55                   	push   %ebp
801042d7:	89 e5                	mov    %esp,%ebp
801042d9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042dc:	9c                   	pushf  
801042dd:	58                   	pop    %eax
801042de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801042e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801042e4:	c9                   	leave  
801042e5:	c3                   	ret    

801042e6 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042e6:	55                   	push   %ebp
801042e7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042e9:	fb                   	sti    
}
801042ea:	5d                   	pop    %ebp
801042eb:	c3                   	ret    

801042ec <xorshift128>:
int w=4;

int totalTickets=0;

int
xorshift128(void) {
801042ec:	55                   	push   %ebp
801042ed:	89 e5                	mov    %esp,%ebp
801042ef:	83 ec 10             	sub    $0x10,%esp
    int t = x ^ (x << 11);
801042f2:	a1 08 c0 10 80       	mov    0x8010c008,%eax
801042f7:	c1 e0 0b             	shl    $0xb,%eax
801042fa:	89 c2                	mov    %eax,%edx
801042fc:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104301:	31 d0                	xor    %edx,%eax
80104303:	89 45 fc             	mov    %eax,-0x4(%ebp)
    x = y; y = z; z = w;
80104306:	a1 0c c0 10 80       	mov    0x8010c00c,%eax
8010430b:	a3 08 c0 10 80       	mov    %eax,0x8010c008
80104310:	a1 10 c0 10 80       	mov    0x8010c010,%eax
80104315:	a3 0c c0 10 80       	mov    %eax,0x8010c00c
8010431a:	a1 14 c0 10 80       	mov    0x8010c014,%eax
8010431f:	a3 10 c0 10 80       	mov    %eax,0x8010c010
    return w = w ^ (w >> 19) ^ t ^ (t >> 8);
80104324:	a1 14 c0 10 80       	mov    0x8010c014,%eax
80104329:	c1 f8 13             	sar    $0x13,%eax
8010432c:	89 c2                	mov    %eax,%edx
8010432e:	a1 14 c0 10 80       	mov    0x8010c014,%eax
80104333:	31 d0                	xor    %edx,%eax
80104335:	33 45 fc             	xor    -0x4(%ebp),%eax
80104338:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010433b:	c1 fa 08             	sar    $0x8,%edx
8010433e:	31 d0                	xor    %edx,%eax
80104340:	a3 14 c0 10 80       	mov    %eax,0x8010c014
80104345:	a1 14 c0 10 80       	mov    0x8010c014,%eax
}
8010434a:	c9                   	leave  
8010434b:	c3                   	ret    

8010434c <printRRQueue>:

// Prints the Round Robin FIFO queue - rightmost is the first in. (for tests)
void printRRQueue() {
8010434c:	55                   	push   %ebp
8010434d:	89 e5                	mov    %esp,%ebp
8010434f:	83 ec 28             	sub    $0x28,%esp
  acquire(&rrqueue.lock);
80104352:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104359:	e8 c4 11 00 00       	call   80105522 <acquire>
  struct proc * p = rrqueue.first;
8010435e:	a1 b4 39 11 80       	mov    0x801139b4,%eax
80104363:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while ( p != 0 ) {
80104366:	eb 0c                	jmp    80104374 <printRRQueue+0x28>
      //cprintf("proc: %d, state: %d, tickets: %d to %d | ", p->pid, p->state, p->firstTicketNum, p->firstTicketNum + p->tickets - 1);
      p = p->rrnext;
80104368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436b:	8b 80 2c 01 00 00    	mov    0x12c(%eax),%eax
80104371:	89 45 f4             	mov    %eax,-0xc(%ebp)

// Prints the Round Robin FIFO queue - rightmost is the first in. (for tests)
void printRRQueue() {
  acquire(&rrqueue.lock);
  struct proc * p = rrqueue.first;
  while ( p != 0 ) {
80104374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104378:	75 ee                	jne    80104368 <printRRQueue+0x1c>
      //cprintf("proc: %d, state: %d, tickets: %d to %d | ", p->pid, p->state, p->firstTicketNum, p->firstTicketNum + p->tickets - 1);
      p = p->rrnext;
  }  
  //cprintf("\n");
  release(&rrqueue.lock);
8010437a:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104381:	e8 fe 11 00 00       	call   80105584 <release>
}
80104386:	c9                   	leave  
80104387:	c3                   	ret    

80104388 <pushProcToRRqueue>:

// Push process p to Round Robin FIFO queue
void
pushProcToRRqueue(struct proc* p)
{
80104388:	55                   	push   %ebp
80104389:	89 e5                	mov    %esp,%ebp
8010438b:	83 ec 18             	sub    $0x18,%esp
    //cprintf("pushing proc %d to queue!\n", p->pid);
    acquire(&rrqueue.lock);
8010438e:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104395:	e8 88 11 00 00       	call   80105522 <acquire>
    if (!rrqueue.first) {
8010439a:	a1 b4 39 11 80       	mov    0x801139b4,%eax
8010439f:	85 c0                	test   %eax,%eax
801043a1:	75 08                	jne    801043ab <pushProcToRRqueue+0x23>
	rrqueue.first = p;    
801043a3:	8b 45 08             	mov    0x8(%ebp),%eax
801043a6:	a3 b4 39 11 80       	mov    %eax,0x801139b4
    }
    if (rrqueue.last) {
801043ab:	a1 b8 39 11 80       	mov    0x801139b8,%eax
801043b0:	85 c0                	test   %eax,%eax
801043b2:	74 1d                	je     801043d1 <pushProcToRRqueue+0x49>
	rrqueue.last->rrnext = p;
801043b4:	a1 b8 39 11 80       	mov    0x801139b8,%eax
801043b9:	8b 55 08             	mov    0x8(%ebp),%edx
801043bc:	89 90 2c 01 00 00    	mov    %edx,0x12c(%eax)
	p->rrprev = rrqueue.last;
801043c2:	8b 15 b8 39 11 80    	mov    0x801139b8,%edx
801043c8:	8b 45 08             	mov    0x8(%ebp),%eax
801043cb:	89 90 30 01 00 00    	mov    %edx,0x130(%eax)
    }
    rrqueue.last = p;
801043d1:	8b 45 08             	mov    0x8(%ebp),%eax
801043d4:	a3 b8 39 11 80       	mov    %eax,0x801139b8
    release(&rrqueue.lock);
801043d9:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043e0:	e8 9f 11 00 00       	call   80105584 <release>
}
801043e5:	c9                   	leave  
801043e6:	c3                   	ret    

801043e7 <removeProcFromRRqueue>:

// Remove process p from Round Robin FIFO queue
void
removeProcFromRRqueue(struct proc* p)
{
801043e7:	55                   	push   %ebp
801043e8:	89 e5                	mov    %esp,%ebp
    //cprintf("removing proc %d from queue!\n", p->pid);
    if (p->rrprev) {
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 80 30 01 00 00    	mov    0x130(%eax),%eax
801043f3:	85 c0                	test   %eax,%eax
801043f5:	74 18                	je     8010440f <removeProcFromRRqueue+0x28>
	p->rrprev->rrnext = p->rrnext;
801043f7:	8b 45 08             	mov    0x8(%ebp),%eax
801043fa:	8b 80 30 01 00 00    	mov    0x130(%eax),%eax
80104400:	8b 55 08             	mov    0x8(%ebp),%edx
80104403:	8b 92 2c 01 00 00    	mov    0x12c(%edx),%edx
80104409:	89 90 2c 01 00 00    	mov    %edx,0x12c(%eax)
    }
    if (p->rrnext) {
8010440f:	8b 45 08             	mov    0x8(%ebp),%eax
80104412:	8b 80 2c 01 00 00    	mov    0x12c(%eax),%eax
80104418:	85 c0                	test   %eax,%eax
8010441a:	74 18                	je     80104434 <removeProcFromRRqueue+0x4d>
	p->rrnext->rrprev = p->rrprev;
8010441c:	8b 45 08             	mov    0x8(%ebp),%eax
8010441f:	8b 80 2c 01 00 00    	mov    0x12c(%eax),%eax
80104425:	8b 55 08             	mov    0x8(%ebp),%edx
80104428:	8b 92 30 01 00 00    	mov    0x130(%edx),%edx
8010442e:	89 90 30 01 00 00    	mov    %edx,0x130(%eax)
    }    
    if (p == rrqueue.first) {
80104434:	a1 b4 39 11 80       	mov    0x801139b4,%eax
80104439:	3b 45 08             	cmp    0x8(%ebp),%eax
8010443c:	75 0e                	jne    8010444c <removeProcFromRRqueue+0x65>
	rrqueue.first = p->rrnext;
8010443e:	8b 45 08             	mov    0x8(%ebp),%eax
80104441:	8b 80 2c 01 00 00    	mov    0x12c(%eax),%eax
80104447:	a3 b4 39 11 80       	mov    %eax,0x801139b4
    }	    
    if (p == rrqueue.last) {
8010444c:	a1 b8 39 11 80       	mov    0x801139b8,%eax
80104451:	3b 45 08             	cmp    0x8(%ebp),%eax
80104454:	75 0e                	jne    80104464 <removeProcFromRRqueue+0x7d>
	rrqueue.last = p->rrprev;  
80104456:	8b 45 08             	mov    0x8(%ebp),%eax
80104459:	8b 80 30 01 00 00    	mov    0x130(%eax),%eax
8010445f:	a3 b8 39 11 80       	mov    %eax,0x801139b8
    }
    
    p->rrnext = 0;
80104464:	8b 45 08             	mov    0x8(%ebp),%eax
80104467:	c7 80 2c 01 00 00 00 	movl   $0x0,0x12c(%eax)
8010446e:	00 00 00 
    p->rrprev = 0;
80104471:	8b 45 08             	mov    0x8(%ebp),%eax
80104474:	c7 80 30 01 00 00 00 	movl   $0x0,0x130(%eax)
8010447b:	00 00 00 
}
8010447e:	5d                   	pop    %ebp
8010447f:	c3                   	ret    

80104480 <pickProcess>:

// Rolling a ticket, and returns the process which holds that ticket, or 0 if FIFO is empty.
struct proc* 
pickProcess() 
{
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	83 ec 28             	sub    $0x28,%esp
    //cprintf("picking, total tickets: %d\n", totalTickets);
    struct proc * selectedProc = 0;
80104486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    
    acquire(&rrqueue.lock);
8010448d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104494:	e8 89 10 00 00       	call   80105522 <acquire>
    if (totalTickets > 0) {
80104499:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010449e:	85 c0                	test   %eax,%eax
801044a0:	7e 5f                	jle    80104501 <pickProcess+0x81>
	int ticket = xorshift128() % totalTickets;      
801044a2:	e8 45 fe ff ff       	call   801042ec <xorshift128>
801044a7:	8b 0d 68 c6 10 80    	mov    0x8010c668,%ecx
801044ad:	99                   	cltd   
801044ae:	f7 f9                	idiv   %ecx
801044b0:	89 55 ec             	mov    %edx,-0x14(%ebp)
	//cprintf("ticket no. is: %d\n", ticket);
	struct proc * p = rrqueue.first;
801044b3:	a1 b4 39 11 80       	mov    0x801139b4,%eax
801044b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while ( p != 0 ) {
801044bb:	eb 3e                	jmp    801044fb <pickProcess+0x7b>
	    if(ticket >= p->firstTicketNum && ticket <= (p->tickets + p->firstTicketNum - 1)) {
801044bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c0:	8b 80 28 01 00 00    	mov    0x128(%eax),%eax
801044c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801044c9:	7f 24                	jg     801044ef <pickProcess+0x6f>
801044cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ce:	8b 90 24 01 00 00    	mov    0x124(%eax),%edx
801044d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d7:	8b 80 28 01 00 00    	mov    0x128(%eax),%eax
801044dd:	01 d0                	add    %edx,%eax
801044df:	83 e8 01             	sub    $0x1,%eax
801044e2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801044e5:	7c 08                	jl     801044ef <pickProcess+0x6f>
		selectedProc = p;
801044e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
801044ed:	eb 12                	jmp    80104501 <pickProcess+0x81>
	    }	
	    p = p->rrnext;
801044ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f2:	8b 80 2c 01 00 00    	mov    0x12c(%eax),%eax
801044f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&rrqueue.lock);
    if (totalTickets > 0) {
	int ticket = xorshift128() % totalTickets;      
	//cprintf("ticket no. is: %d\n", ticket);
	struct proc * p = rrqueue.first;
	while ( p != 0 ) {
801044fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044ff:	75 bc                	jne    801044bd <pickProcess+0x3d>
		break;
	    }	
	    p = p->rrnext;
	}  
    }
    release(&rrqueue.lock);
80104501:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104508:	e8 77 10 00 00       	call   80105584 <release>
     //if (selectedProc != 0)
     //  cprintf("pid chose to run is: %d, tickets: %d to %d\n", selectedProc->pid, selectedProc->firstTicketNum, selectedProc->firstTicketNum + selectedProc->tickets - 1);
    return selectedProc;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104510:	c9                   	leave  
80104511:	c3                   	ret    

80104512 <deliverTicketsToFIFOProcs>:

// Deliver ticket to all processes in the FIFO queue
void
deliverTicketsToFIFOProcs()
{
80104512:	55                   	push   %ebp
80104513:	89 e5                	mov    %esp,%ebp
80104515:	83 ec 28             	sub    $0x28,%esp
    totalTickets = 0;
80104518:	c7 05 68 c6 10 80 00 	movl   $0x0,0x8010c668
8010451f:	00 00 00 
    acquire(&rrqueue.lock);
80104522:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104529:	e8 f4 0f 00 00       	call   80105522 <acquire>
    struct proc * p = rrqueue.last;
8010452e:	a1 b8 39 11 80       	mov    0x801139b8,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == 0) {
80104536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453a:	75 11                	jne    8010454d <deliverTicketsToFIFOProcs+0x3b>
	release(&rrqueue.lock);
8010453c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104543:	e8 3c 10 00 00       	call   80105584 <release>
	return;
80104548:	e9 b3 00 00 00       	jmp    80104600 <deliverTicketsToFIFOProcs+0xee>
    }
    #if defined(FRR) || defined(FCFS)
	while ( p != rrqueue.first ) {  
8010454d:	eb 63                	jmp    801045b2 <deliverTicketsToFIFOProcs+0xa0>
	    if (p->state != RUNNABLE) {
8010454f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104552:	8b 40 0c             	mov    0xc(%eax),%eax
80104555:	83 f8 03             	cmp    $0x3,%eax
80104558:	74 1f                	je     80104579 <deliverTicketsToFIFOProcs+0x67>
		struct proc* tmp = p->rrprev;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	8b 80 30 01 00 00    	mov    0x130(%eax),%eax
80104563:	89 45 f0             	mov    %eax,-0x10(%ebp)
		removeProcFromRRqueue(p);
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	89 04 24             	mov    %eax,(%esp)
8010456c:	e8 76 fe ff ff       	call   801043e7 <removeProcFromRRqueue>
		p = tmp;
80104571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104574:	89 45 f4             	mov    %eax,-0xc(%ebp)
		continue;
80104577:	eb 39                	jmp    801045b2 <deliverTicketsToFIFOProcs+0xa0>
	    }
	    p->firstTicketNum = totalTickets + 1;
80104579:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010457e:	8d 50 01             	lea    0x1(%eax),%edx
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	89 90 28 01 00 00    	mov    %edx,0x128(%eax)
	    p->tickets = EXE_TICKETS;
8010458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458d:	c7 80 24 01 00 00 e8 	movl   $0x3e8,0x124(%eax)
80104594:	03 00 00 
	    totalTickets += EXE_TICKETS;
80104597:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010459c:	05 e8 03 00 00       	add    $0x3e8,%eax
801045a1:	a3 68 c6 10 80       	mov    %eax,0x8010c668
	    p = p->rrprev;
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	8b 80 30 01 00 00    	mov    0x130(%eax),%eax
801045af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == 0) {
	release(&rrqueue.lock);
	return;
    }
    #if defined(FRR) || defined(FCFS)
	while ( p != rrqueue.first ) {  
801045b2:	a1 b4 39 11 80       	mov    0x801139b4,%eax
801045b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045ba:	75 93                	jne    8010454f <deliverTicketsToFIFOProcs+0x3d>
	    p->firstTicketNum = totalTickets + 1;
	    p->tickets = EXE_TICKETS;
	    totalTickets += EXE_TICKETS;
	    p = p->rrprev;
	}	
	p->firstTicketNum = totalTickets + 1;
801045bc:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801045c1:	8d 50 01             	lea    0x1(%eax),%edx
801045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c7:	89 90 28 01 00 00    	mov    %edx,0x128(%eax)
	p->tickets = 100*EXE_TICKETS;
801045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d0:	c7 80 24 01 00 00 a0 	movl   $0x186a0,0x124(%eax)
801045d7:	86 01 00 
	totalTickets += p->tickets;
801045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dd:	8b 90 24 01 00 00    	mov    0x124(%eax),%edx
801045e3:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801045e8:	01 d0                	add    %edx,%eax
801045ea:	a3 68 c6 10 80       	mov    %eax,0x8010c668
	    p->tickets = EXE_TICKETS + EXE_TICKETS*p->priority;
	    totalTickets += p->tickets;
	    p = p->rrprev;
	}	      
    #endif
    release(&rrqueue.lock);
801045ef:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801045f6:	e8 89 0f 00 00       	call   80105584 <release>
    printRRQueue();
801045fb:	e8 4c fd ff ff       	call   8010434c <printRRQueue>
}
80104600:	c9                   	leave  
80104601:	c3                   	ret    

80104602 <pinit>:

void
pinit(void)
{
80104602:	55                   	push   %ebp
80104603:	89 e5                	mov    %esp,%ebp
80104605:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104608:	c7 44 24 04 31 93 10 	movl   $0x80109331,0x4(%esp)
8010460f:	80 
80104610:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104617:	e8 e5 0e 00 00       	call   80105501 <initlock>
}
8010461c:	c9                   	leave  
8010461d:	c3                   	ret    

8010461e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010461e:	55                   	push   %ebp
8010461f:	89 e5                	mov    %esp,%ebp
80104621:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104624:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010462b:	e8 f2 0e 00 00       	call   80105522 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104630:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104637:	eb 7b                	jmp    801046b4 <allocproc+0x96>
    if(p->state == UNUSED)
80104639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463c:	8b 40 0c             	mov    0xc(%eax),%eax
8010463f:	85 c0                	test   %eax,%eax
80104641:	75 6a                	jne    801046ad <allocproc+0x8f>
      goto found;
80104643:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104647:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010464e:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104653:	8d 50 01             	lea    0x1(%eax),%edx
80104656:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010465c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465f:	89 42 10             	mov    %eax,0x10(%edx)
//   p->tickets = EXE_TICKETS;
//   totalTickets += EXE_TICKETS;
  acquire(&tickslock);
80104662:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104669:	e8 b4 0e 00 00       	call   80105522 <acquire>
  p->ctime = ticks;
8010466e:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80104673:	89 c2                	mov    %eax,%edx
80104675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104678:	89 90 08 01 00 00    	mov    %edx,0x108(%eax)
  release(&tickslock);
8010467e:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104685:	e8 fa 0e 00 00       	call   80105584 <release>
  release(&ptable.lock);
8010468a:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104691:	e8 ee 0e 00 00       	call   80105584 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104696:	e8 47 e4 ff ff       	call   80102ae2 <kalloc>
8010469b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469e:	89 42 08             	mov    %eax,0x8(%edx)
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	8b 40 08             	mov    0x8(%eax),%eax
801046a7:	85 c0                	test   %eax,%eax
801046a9:	75 3a                	jne    801046e5 <allocproc+0xc7>
801046ab:	eb 27                	jmp    801046d4 <allocproc+0xb6>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046ad:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
801046b4:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
801046bb:	0f 82 78 ff ff ff    	jb     80104639 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801046c1:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801046c8:	e8 b7 0e 00 00       	call   80105584 <release>
  return 0;
801046cd:	b8 00 00 00 00       	mov    $0x0,%eax
801046d2:	eb 76                	jmp    8010474a <allocproc+0x12c>
  release(&tickslock);
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801046de:	b8 00 00 00 00       	mov    $0x0,%eax
801046e3:	eb 65                	jmp    8010474a <allocproc+0x12c>
  }
  sp = p->kstack + KSTACKSIZE;
801046e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e8:	8b 40 08             	mov    0x8(%eax),%eax
801046eb:	05 00 10 00 00       	add    $0x1000,%eax
801046f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801046f3:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046fd:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104700:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104704:	ba 0b 6d 10 80       	mov    $0x80106d0b,%edx
80104709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010470e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104715:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104718:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
8010471b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471e:	8b 40 20             	mov    0x20(%eax),%eax
80104721:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104728:	00 
80104729:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104730:	00 
80104731:	89 04 24             	mov    %eax,(%esp)
80104734:	e8 3d 10 00 00       	call   80105776 <memset>
  p->context->eip = (uint)forkret;
80104739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473c:	8b 40 20             	mov    0x20(%eax),%eax
8010473f:	ba 34 4f 10 80       	mov    $0x80104f34,%edx
80104744:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104747:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010474a:	c9                   	leave  
8010474b:	c3                   	ret    

8010474c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010474c:	55                   	push   %ebp
8010474d:	89 e5                	mov    %esp,%ebp
8010474f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104752:	e8 c7 fe ff ff       	call   8010461e <allocproc>
80104757:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	a3 6c c6 10 80       	mov    %eax,0x8010c66c
  if((p->pgdir = setupkvm()) == 0)
80104762:	e8 87 40 00 00       	call   801087ee <setupkvm>
80104767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010476a:	89 42 04             	mov    %eax,0x4(%edx)
8010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104770:	8b 40 04             	mov    0x4(%eax),%eax
80104773:	85 c0                	test   %eax,%eax
80104775:	75 0c                	jne    80104783 <userinit+0x37>
    panic("userinit: out of memory?");
80104777:	c7 04 24 38 93 10 80 	movl   $0x80109338,(%esp)
8010477e:	e8 b7 bd ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104783:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 04             	mov    0x4(%eax),%eax
8010478e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104792:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
80104799:	80 
8010479a:	89 04 24             	mov    %eax,(%esp)
8010479d:	e8 a4 42 00 00       	call   80108a46 <inituvm>
  p->sz = PGSIZE;
801047a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801047ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ae:	8b 40 18             	mov    0x18(%eax),%eax
801047b1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801047b8:	00 
801047b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801047c0:	00 
801047c1:	89 04 24             	mov    %eax,(%esp)
801047c4:	e8 ad 0f 00 00       	call   80105776 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cc:	8b 40 18             	mov    0x18(%eax),%eax
801047cf:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801047d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d8:	8b 40 18             	mov    0x18(%eax),%eax
801047db:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801047e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e4:	8b 40 18             	mov    0x18(%eax),%eax
801047e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047ea:	8b 52 18             	mov    0x18(%edx),%edx
801047ed:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801047f1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801047f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f8:	8b 40 18             	mov    0x18(%eax),%eax
801047fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047fe:	8b 52 18             	mov    0x18(%edx),%edx
80104801:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104805:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480c:	8b 40 18             	mov    0x18(%eax),%eax
8010480f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	8b 40 18             	mov    0x18(%eax),%eax
8010481c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104826:	8b 40 18             	mov    0x18(%eax),%eax
80104829:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104833:	83 c0 70             	add    $0x70,%eax
80104836:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010483d:	00 
8010483e:	c7 44 24 04 51 93 10 	movl   $0x80109351,0x4(%esp)
80104845:	80 
80104846:	89 04 24             	mov    %eax,(%esp)
80104849:	e8 48 11 00 00       	call   80105996 <safestrcpy>
  p->cwd = namei("/");
8010484e:	c7 04 24 5a 93 10 80 	movl   $0x8010935a,(%esp)
80104855:	e8 ac db ff ff       	call   80102406 <namei>
8010485a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010485d:	89 42 6c             	mov    %eax,0x6c(%edx)

  p->state = RUNNABLE;
80104860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104863:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
//   p->tickets = EXE_TICKETS;
#if defined(FRR) || defined(FCFS) || defined(PRS)
  pushProcToRRqueue(p);
8010486a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486d:	89 04 24             	mov    %eax,(%esp)
80104870:	e8 13 fb ff ff       	call   80104388 <pushProcToRRqueue>
#endif
}
80104875:	c9                   	leave  
80104876:	c3                   	ret    

80104877 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104877:	55                   	push   %ebp
80104878:	89 e5                	mov    %esp,%ebp
8010487a:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010487d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104883:	8b 00                	mov    (%eax),%eax
80104885:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104888:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010488c:	7e 34                	jle    801048c2 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010488e:	8b 55 08             	mov    0x8(%ebp),%edx
80104891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104894:	01 c2                	add    %eax,%edx
80104896:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489c:	8b 40 04             	mov    0x4(%eax),%eax
8010489f:	89 54 24 08          	mov    %edx,0x8(%esp)
801048a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801048aa:	89 04 24             	mov    %eax,(%esp)
801048ad:	e8 0a 43 00 00       	call   80108bbc <allocuvm>
801048b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048b9:	75 41                	jne    801048fc <growproc+0x85>
      return -1;
801048bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c0:	eb 58                	jmp    8010491a <growproc+0xa3>
  } else if(n < 0){
801048c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801048c6:	79 34                	jns    801048fc <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801048c8:	8b 55 08             	mov    0x8(%ebp),%edx
801048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ce:	01 c2                	add    %eax,%edx
801048d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d6:	8b 40 04             	mov    0x4(%eax),%eax
801048d9:	89 54 24 08          	mov    %edx,0x8(%esp)
801048dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801048e4:	89 04 24             	mov    %eax,(%esp)
801048e7:	e8 aa 43 00 00       	call   80108c96 <deallocuvm>
801048ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048f3:	75 07                	jne    801048fc <growproc+0x85>
      return -1;
801048f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fa:	eb 1e                	jmp    8010491a <growproc+0xa3>
  }
  proc->sz = sz;
801048fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104902:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104905:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104907:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490d:	89 04 24             	mov    %eax,(%esp)
80104910:	e8 ca 3f 00 00       	call   801088df <switchuvm>
  return 0;
80104915:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010491a:	c9                   	leave  
8010491b:	c3                   	ret    

8010491c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	57                   	push   %edi
80104920:	56                   	push   %esi
80104921:	53                   	push   %ebx
80104922:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104925:	e8 f4 fc ff ff       	call   8010461e <allocproc>
8010492a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010492d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104931:	75 0a                	jne    8010493d <fork+0x21>
    return -1;
80104933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104938:	e9 d3 01 00 00       	jmp    80104b10 <fork+0x1f4>
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010493d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104943:	8b 10                	mov    (%eax),%edx
80104945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494b:	8b 40 04             	mov    0x4(%eax),%eax
8010494e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104952:	89 04 24             	mov    %eax,(%esp)
80104955:	e8 d8 44 00 00       	call   80108e32 <copyuvm>
8010495a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010495d:	89 42 04             	mov    %eax,0x4(%edx)
80104960:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104963:	8b 40 04             	mov    0x4(%eax),%eax
80104966:	85 c0                	test   %eax,%eax
80104968:	75 2c                	jne    80104996 <fork+0x7a>
    kfree(np->kstack);
8010496a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010496d:	8b 40 08             	mov    0x8(%eax),%eax
80104970:	89 04 24             	mov    %eax,(%esp)
80104973:	e8 d1 e0 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
80104978:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010497b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104982:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104985:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010498c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104991:	e9 7a 01 00 00       	jmp    80104b10 <fork+0x1f4>
  }
  np->sz = proc->sz;
80104996:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499c:	8b 10                	mov    (%eax),%edx
8010499e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a1:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801049a3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ad:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801049b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b3:	8b 50 18             	mov    0x18(%eax),%edx
801049b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049bc:	8b 40 18             	mov    0x18(%eax),%eax
801049bf:	89 c3                	mov    %eax,%ebx
801049c1:	b8 13 00 00 00       	mov    $0x13,%eax
801049c6:	89 d7                	mov    %edx,%edi
801049c8:	89 de                	mov    %ebx,%esi
801049ca:	89 c1                	mov    %eax,%ecx
801049cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801049ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d1:	8b 40 18             	mov    0x18(%eax),%eax
801049d4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801049db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801049e2:	eb 3d                	jmp    80104a21 <fork+0x105>
    if(proc->ofile[i])
801049e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049ed:	83 c2 08             	add    $0x8,%edx
801049f0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801049f4:	85 c0                	test   %eax,%eax
801049f6:	74 25                	je     80104a1d <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801049f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a01:	83 c2 08             	add    $0x8,%edx
80104a04:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a08:	89 04 24             	mov    %eax,(%esp)
80104a0b:	e8 76 c5 ff ff       	call   80100f86 <filedup>
80104a10:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a13:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104a16:	83 c1 08             	add    $0x8,%ecx
80104a19:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104a1d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a21:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a25:	7e bd                	jle    801049e4 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104a27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a2d:	8b 40 6c             	mov    0x6c(%eax),%eax
80104a30:	89 04 24             	mov    %eax,(%esp)
80104a33:	e8 f1 cd ff ff       	call   80101829 <idup>
80104a38:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a3b:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104a3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a44:	8d 50 70             	lea    0x70(%eax),%edx
80104a47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a4a:	83 c0 70             	add    $0x70,%eax
80104a4d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104a54:	00 
80104a55:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a59:	89 04 24             	mov    %eax,(%esp)
80104a5c:	e8 35 0f 00 00       	call   80105996 <safestrcpy>
 
  pid = np->pid;
80104a61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a64:	8b 40 10             	mov    0x10(%eax),%eax
80104a67:	89 45 dc             	mov    %eax,-0x24(%ebp)
   np->runQuanta = 0;		//reset proc Time
80104a6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a6d:	c7 80 1c 01 00 00 00 	movl   $0x0,0x11c(%eax)
80104a74:	00 00 00 
   np->rutime = 0;
80104a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a7a:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%eax)
80104a81:	00 00 00 
   acquire(&tickslock);
80104a84:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104a8b:	e8 92 0a 00 00       	call   80105522 <acquire>
   np->ctime = ticks;
80104a90:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80104a95:	89 c2                	mov    %eax,%edx
80104a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a9a:	89 90 08 01 00 00    	mov    %edx,0x108(%eax)
   release(&tickslock);
80104aa0:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104aa7:	e8 d8 0a 00 00       	call   80105584 <release>
   np->ttime	 = 0;
80104aac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aaf:	c7 80 0c 01 00 00 00 	movl   $0x0,0x10c(%eax)
80104ab6:	00 00 00 
   np->stime	 = 0;
80104ab9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104abc:	c7 80 10 01 00 00 00 	movl   $0x0,0x110(%eax)
80104ac3:	00 00 00 
   np->retime	 = 0;
80104ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ac9:	c7 80 14 01 00 00 00 	movl   $0x0,0x114(%eax)
80104ad0:	00 00 00 
   np->priority = 1;
80104ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ad6:	c7 80 20 01 00 00 01 	movl   $0x1,0x120(%eax)
80104add:	00 00 00 
  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104ae0:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104ae7:	e8 36 0a 00 00       	call   80105522 <acquire>
  np->state = RUNNABLE;
80104aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aef:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(np);
80104af6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104af9:	89 04 24             	mov    %eax,(%esp)
80104afc:	e8 87 f8 ff ff       	call   80104388 <pushProcToRRqueue>
  #endif
  release(&ptable.lock);
80104b01:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104b08:	e8 77 0a 00 00       	call   80105584 <release>
  
  return pid;
80104b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104b10:	83 c4 2c             	add    $0x2c,%esp
80104b13:	5b                   	pop    %ebx
80104b14:	5e                   	pop    %esi
80104b15:	5f                   	pop    %edi
80104b16:	5d                   	pop    %ebp
80104b17:	c3                   	ret    

80104b18 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104b18:	55                   	push   %ebp
80104b19:	89 e5                	mov    %esp,%ebp
80104b1b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104b1e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b25:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80104b2a:	39 c2                	cmp    %eax,%edx
80104b2c:	75 0c                	jne    80104b3a <exit+0x22>
    panic("init exiting");
80104b2e:	c7 04 24 5c 93 10 80 	movl   $0x8010935c,(%esp)
80104b35:	e8 00 ba ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104b41:	eb 44                	jmp    80104b87 <exit+0x6f>
    if(proc->ofile[fd]){
80104b43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b49:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b4c:	83 c2 08             	add    $0x8,%edx
80104b4f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104b53:	85 c0                	test   %eax,%eax
80104b55:	74 2c                	je     80104b83 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104b57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b60:	83 c2 08             	add    $0x8,%edx
80104b63:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104b67:	89 04 24             	mov    %eax,(%esp)
80104b6a:	e8 5f c4 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
80104b6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b78:	83 c2 08             	add    $0x8,%edx
80104b7b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80104b82:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b83:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b87:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104b8b:	7e b6                	jle    80104b43 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104b8d:	e8 7e e8 ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
80104b92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b98:	8b 40 6c             	mov    0x6c(%eax),%eax
80104b9b:	89 04 24             	mov    %eax,(%esp)
80104b9e:	e8 6b ce ff ff       	call   80101a0e <iput>
  end_op();
80104ba3:	e8 ec e8 ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
80104ba8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bae:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80104bb5:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104bbc:	e8 61 09 00 00       	call   80105522 <acquire>

//   totalTickets -= proc->tickets;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104bc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc7:	8b 40 14             	mov    0x14(%eax),%eax
80104bca:	89 04 24             	mov    %eax,(%esp)
80104bcd:	e8 29 04 00 00       	call   80104ffb <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bd2:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104bd9:	eb 3b                	jmp    80104c16 <exit+0xfe>
    if(p->parent == proc){
80104bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bde:	8b 50 14             	mov    0x14(%eax),%edx
80104be1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be7:	39 c2                	cmp    %eax,%edx
80104be9:	75 24                	jne    80104c0f <exit+0xf7>
      p->parent = initproc;
80104beb:	8b 15 6c c6 10 80    	mov    0x8010c66c,%edx
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	8b 40 0c             	mov    0xc(%eax),%eax
80104bfd:	83 f8 05             	cmp    $0x5,%eax
80104c00:	75 0d                	jne    80104c0f <exit+0xf7>
        wakeup1(initproc);
80104c02:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80104c07:	89 04 24             	mov    %eax,(%esp)
80104c0a:	e8 ec 03 00 00       	call   80104ffb <wakeup1>
//   totalTickets -= proc->tickets;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c0f:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104c16:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104c1d:	72 bc                	jb     80104bdb <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104c1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c25:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  acquire(&tickslock);
80104c2c:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104c33:	e8 ea 08 00 00       	call   80105522 <acquire>
  proc->ttime = ticks;
80104c38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3e:	8b 15 40 8f 11 80    	mov    0x80118f40,%edx
80104c44:	89 90 0c 01 00 00    	mov    %edx,0x10c(%eax)
  release(&tickslock);
80104c4a:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104c51:	e8 2e 09 00 00       	call   80105584 <release>
  sched();
80104c56:	e8 e7 01 00 00       	call   80104e42 <sched>
  panic("zombie exit");
80104c5b:	c7 04 24 69 93 10 80 	movl   $0x80109369,(%esp)
80104c62:	e8 d3 b8 ff ff       	call   8010053a <panic>

80104c67 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104c67:	55                   	push   %ebp
80104c68:	89 e5                	mov    %esp,%ebp
80104c6a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104c6d:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104c74:	e8 a9 08 00 00       	call   80105522 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104c79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c80:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104c87:	e9 bb 00 00 00       	jmp    80104d47 <wait+0xe0>
      if(p->parent != proc)
80104c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8f:	8b 50 14             	mov    0x14(%eax),%edx
80104c92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c98:	39 c2                	cmp    %eax,%edx
80104c9a:	74 05                	je     80104ca1 <wait+0x3a>
        continue;
80104c9c:	e9 9f 00 00 00       	jmp    80104d40 <wait+0xd9>
      havekids = 1;
80104ca1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cab:	8b 40 0c             	mov    0xc(%eax),%eax
80104cae:	83 f8 05             	cmp    $0x5,%eax
80104cb1:	0f 85 89 00 00 00    	jne    80104d40 <wait+0xd9>
        // Found one.
        pid = p->pid;
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	8b 40 10             	mov    0x10(%eax),%eax
80104cbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc3:	8b 40 08             	mov    0x8(%eax),%eax
80104cc6:	89 04 24             	mov    %eax,(%esp)
80104cc9:	e8 7b dd ff ff       	call   80102a49 <kfree>
        p->kstack = 0;
80104cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdb:	8b 40 04             	mov    0x4(%eax),%eax
80104cde:	89 04 24             	mov    %eax,(%esp)
80104ce1:	e8 6c 40 00 00       	call   80108d52 <freevm>
        p->state = UNUSED;
80104ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d07:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0e:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->runQuanta = 0;		//reset proc Time
80104d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d18:	c7 80 1c 01 00 00 00 	movl   $0x0,0x11c(%eax)
80104d1f:	00 00 00 
        p->rutime = 0;
80104d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d25:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%eax)
80104d2c:	00 00 00 
        release(&ptable.lock);
80104d2f:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104d36:	e8 49 08 00 00       	call   80105584 <release>
        return pid;
80104d3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d3e:	eb 55                	jmp    80104d95 <wait+0x12e>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d40:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104d47:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104d4e:	0f 82 38 ff ff ff    	jb     80104c8c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104d54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d58:	74 0d                	je     80104d67 <wait+0x100>
80104d5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d60:	8b 40 28             	mov    0x28(%eax),%eax
80104d63:	85 c0                	test   %eax,%eax
80104d65:	74 13                	je     80104d7a <wait+0x113>
      release(&ptable.lock);
80104d67:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104d6e:	e8 11 08 00 00       	call   80105584 <release>
      return -1;
80104d73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d78:	eb 1b                	jmp    80104d95 <wait+0x12e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104d7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d80:	c7 44 24 04 c0 39 11 	movl   $0x801139c0,0x4(%esp)
80104d87:	80 
80104d88:	89 04 24             	mov    %eax,(%esp)
80104d8b:	e8 d0 01 00 00       	call   80104f60 <sleep>
  }
80104d90:	e9 e4 fe ff ff       	jmp    80104c79 <wait+0x12>
}
80104d95:	c9                   	leave  
80104d96:	c3                   	ret    

80104d97 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104d97:	55                   	push   %ebp
80104d98:	89 e5                	mov    %esp,%ebp
80104d9a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104d9d:	e8 44 f5 ff ff       	call   801042e6 <sti>

    // Loop over process table looking for process to run.
acquire(&ptable.lock);    
80104da2:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104da9:	e8 74 07 00 00       	call   80105522 <acquire>
    }
    
#endif
#if defined(FRR) || defined(FCFS) || defined(PRS)
  
    deliverTicketsToFIFOProcs();
80104dae:	e8 5f f7 ff ff       	call   80104512 <deliverTicketsToFIFOProcs>
    p = pickProcess(); 
80104db3:	e8 c8 f6 ff ff       	call   80104480 <pickProcess>
80104db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p != 0) {
80104dbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104dbf:	74 70                	je     80104e31 <scheduler+0x9a>
	proc = p;
80104dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc4:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	acquire(&rrqueue.lock);
80104dca:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104dd1:	e8 4c 07 00 00       	call   80105522 <acquire>
	removeProcFromRRqueue(p);
80104dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd9:	89 04 24             	mov    %eax,(%esp)
80104ddc:	e8 06 f6 ff ff       	call   801043e7 <removeProcFromRRqueue>
	release(&rrqueue.lock);
80104de1:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104de8:	e8 97 07 00 00       	call   80105584 <release>
	switchuvm(p);
80104ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df0:	89 04 24             	mov    %eax,(%esp)
80104df3:	e8 e7 3a 00 00       	call   801088df <switchuvm>
	p->state = RUNNING;    
80104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfb:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	swtch(&cpu->scheduler, proc->context);
80104e02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e08:	8b 40 20             	mov    0x20(%eax),%eax
80104e0b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e12:	83 c2 04             	add    $0x4,%edx
80104e15:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e19:	89 14 24             	mov    %edx,(%esp)
80104e1c:	e8 e6 0b 00 00       	call   80105a07 <swtch>
	switchkvm();
80104e21:	e8 9c 3a 00 00       	call   801088c2 <switchkvm>
	
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
80104e26:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104e2d:	00 00 00 00 
	//break;
    }
#endif
release(&ptable.lock);
80104e31:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104e38:	e8 47 07 00 00       	call   80105584 <release>
  }
80104e3d:	e9 5b ff ff ff       	jmp    80104d9d <scheduler+0x6>

80104e42 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104e42:	55                   	push   %ebp
80104e43:	89 e5                	mov    %esp,%ebp
80104e45:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104e48:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104e4f:	e8 f8 07 00 00       	call   8010564c <holding>
80104e54:	85 c0                	test   %eax,%eax
80104e56:	75 0c                	jne    80104e64 <sched+0x22>
    panic("sched ptable.lock");
80104e58:	c7 04 24 75 93 10 80 	movl   $0x80109375,(%esp)
80104e5f:	e8 d6 b6 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104e64:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e6a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104e70:	83 f8 01             	cmp    $0x1,%eax
80104e73:	74 0c                	je     80104e81 <sched+0x3f>
    panic("sched locks");
80104e75:	c7 04 24 87 93 10 80 	movl   $0x80109387,(%esp)
80104e7c:	e8 b9 b6 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e87:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8a:	83 f8 04             	cmp    $0x4,%eax
80104e8d:	75 0c                	jne    80104e9b <sched+0x59>
    panic("sched running");
80104e8f:	c7 04 24 93 93 10 80 	movl   $0x80109393,(%esp)
80104e96:	e8 9f b6 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104e9b:	e8 36 f4 ff ff       	call   801042d6 <readeflags>
80104ea0:	25 00 02 00 00       	and    $0x200,%eax
80104ea5:	85 c0                	test   %eax,%eax
80104ea7:	74 0c                	je     80104eb5 <sched+0x73>
    panic("sched interruptible");
80104ea9:	c7 04 24 a1 93 10 80 	movl   $0x801093a1,(%esp)
80104eb0:	e8 85 b6 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104eb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ebb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ec1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104ec4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104eca:	8b 40 04             	mov    0x4(%eax),%eax
80104ecd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ed4:	83 c2 20             	add    $0x20,%edx
80104ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104edb:	89 14 24             	mov    %edx,(%esp)
80104ede:	e8 24 0b 00 00       	call   80105a07 <swtch>
  cpu->intena = intena;
80104ee3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ee9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eec:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ef2:	c9                   	leave  
80104ef3:	c3                   	ret    

80104ef4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104efa:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f01:	e8 1c 06 00 00       	call   80105522 <acquire>
  proc->state = RUNNABLE;
80104f06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(proc);
80104f13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f19:	89 04 24             	mov    %eax,(%esp)
80104f1c:	e8 67 f4 ff ff       	call   80104388 <pushProcToRRqueue>
  #endif
  sched();
80104f21:	e8 1c ff ff ff       	call   80104e42 <sched>
  release(&ptable.lock);
80104f26:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f2d:	e8 52 06 00 00       	call   80105584 <release>
}
80104f32:	c9                   	leave  
80104f33:	c3                   	ret    

80104f34 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104f34:	55                   	push   %ebp
80104f35:	89 e5                	mov    %esp,%ebp
80104f37:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104f3a:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f41:	e8 3e 06 00 00       	call   80105584 <release>

  if (first) {
80104f46:	a1 18 c0 10 80       	mov    0x8010c018,%eax
80104f4b:	85 c0                	test   %eax,%eax
80104f4d:	74 0f                	je     80104f5e <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104f4f:	c7 05 18 c0 10 80 00 	movl   $0x0,0x8010c018
80104f56:	00 00 00 
    initlog();
80104f59:	e8 a4 e2 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104f5e:	c9                   	leave  
80104f5f:	c3                   	ret    

80104f60 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104f60:	55                   	push   %ebp
80104f61:	89 e5                	mov    %esp,%ebp
80104f63:	83 ec 18             	sub    $0x18,%esp
  //cprintf("I, process %d, went to sleep\n", proc->pid);
  if(proc == 0)
80104f66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f6c:	85 c0                	test   %eax,%eax
80104f6e:	75 0c                	jne    80104f7c <sleep+0x1c>
    panic("sleep");
80104f70:	c7 04 24 b5 93 10 80 	movl   $0x801093b5,(%esp)
80104f77:	e8 be b5 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104f7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f80:	75 0c                	jne    80104f8e <sleep+0x2e>
    panic("sleep without lk");
80104f82:	c7 04 24 bb 93 10 80 	movl   $0x801093bb,(%esp)
80104f89:	e8 ac b5 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104f8e:	81 7d 0c c0 39 11 80 	cmpl   $0x801139c0,0xc(%ebp)
80104f95:	74 17                	je     80104fae <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104f97:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f9e:	e8 7f 05 00 00       	call   80105522 <acquire>
    release(lk);
80104fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa6:	89 04 24             	mov    %eax,(%esp)
80104fa9:	e8 d6 05 00 00       	call   80105584 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104fae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb4:	8b 55 08             	mov    0x8(%ebp),%edx
80104fb7:	89 50 24             	mov    %edx,0x24(%eax)
  proc->state = SLEEPING;
80104fba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
//   totalTickets -= proc->tickets;
  sched();
80104fc7:	e8 76 fe ff ff       	call   80104e42 <sched>

  // Tidy up.
  proc->chan = 0;
80104fcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104fd9:	81 7d 0c c0 39 11 80 	cmpl   $0x801139c0,0xc(%ebp)
80104fe0:	74 17                	je     80104ff9 <sleep+0x99>
    release(&ptable.lock);
80104fe2:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104fe9:	e8 96 05 00 00       	call   80105584 <release>
    acquire(lk);
80104fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff1:	89 04 24             	mov    %eax,(%esp)
80104ff4:	e8 29 05 00 00       	call   80105522 <acquire>
  }
}
80104ff9:	c9                   	leave  
80104ffa:	c3                   	ret    

80104ffb <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ffb:	55                   	push   %ebp
80104ffc:	89 e5                	mov    %esp,%ebp
80104ffe:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105001:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80105008:	eb 32                	jmp    8010503c <wakeup1+0x41>
    if(p->state == SLEEPING && p->chan == chan){
8010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500d:	8b 40 0c             	mov    0xc(%eax),%eax
80105010:	83 f8 02             	cmp    $0x2,%eax
80105013:	75 20                	jne    80105035 <wakeup1+0x3a>
80105015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105018:	8b 40 24             	mov    0x24(%eax),%eax
8010501b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010501e:	75 15                	jne    80105035 <wakeup1+0x3a>
      p->state = RUNNABLE;
80105020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105023:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
//       totalTickets += p->tickets;
      #if defined(FRR) || defined(FCFS) || defined(PRS)
	  pushProcToRRqueue(p);
8010502a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502d:	89 04 24             	mov    %eax,(%esp)
80105030:	e8 53 f3 ff ff       	call   80104388 <pushProcToRRqueue>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105035:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
8010503c:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80105043:	72 c5                	jb     8010500a <wakeup1+0xf>
//       totalTickets += p->tickets;
      #if defined(FRR) || defined(FCFS) || defined(PRS)
	  pushProcToRRqueue(p);
      #endif
    }
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    

80105047 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105047:	55                   	push   %ebp
80105048:	89 e5                	mov    %esp,%ebp
8010504a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010504d:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80105054:	e8 c9 04 00 00       	call   80105522 <acquire>
  wakeup1(chan);
80105059:	8b 45 08             	mov    0x8(%ebp),%eax
8010505c:	89 04 24             	mov    %eax,(%esp)
8010505f:	e8 97 ff ff ff       	call   80104ffb <wakeup1>
  release(&ptable.lock);
80105064:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010506b:	e8 14 05 00 00       	call   80105584 <release>
}
80105070:	c9                   	leave  
80105071:	c3                   	ret    

80105072 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105072:	55                   	push   %ebp
80105073:	89 e5                	mov    %esp,%ebp
80105075:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105078:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010507f:	e8 9e 04 00 00       	call   80105522 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105084:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
8010508b:	eb 4f                	jmp    801050dc <kill+0x6a>
    if(p->pid == pid){
8010508d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105090:	8b 40 10             	mov    0x10(%eax),%eax
80105093:	3b 45 08             	cmp    0x8(%ebp),%eax
80105096:	75 3d                	jne    801050d5 <kill+0x63>
      p->killed = 1;
80105098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509b:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
801050a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a5:	8b 40 0c             	mov    0xc(%eax),%eax
801050a8:	83 f8 02             	cmp    $0x2,%eax
801050ab:	75 15                	jne    801050c2 <kill+0x50>
        p->state = RUNNABLE;
801050ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	#if defined(FRR) || defined(FCFS) || defined(PRS)
	    pushProcToRRqueue(p);
801050b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ba:	89 04 24             	mov    %eax,(%esp)
801050bd:	e8 c6 f2 ff ff       	call   80104388 <pushProcToRRqueue>
	#endif
      }
      release(&ptable.lock);
801050c2:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801050c9:	e8 b6 04 00 00       	call   80105584 <release>
      return 0;
801050ce:	b8 00 00 00 00       	mov    $0x0,%eax
801050d3:	eb 21                	jmp    801050f6 <kill+0x84>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050d5:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
801050dc:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
801050e3:	72 a8                	jb     8010508d <kill+0x1b>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801050e5:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801050ec:	e8 93 04 00 00       	call   80105584 <release>
  return -1;
801050f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050f6:	c9                   	leave  
801050f7:	c3                   	ret    

801050f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801050f8:	55                   	push   %ebp
801050f9:	89 e5                	mov    %esp,%ebp
801050fb:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050fe:	c7 45 f0 f4 39 11 80 	movl   $0x801139f4,-0x10(%ebp)
80105105:	e9 d9 00 00 00       	jmp    801051e3 <procdump+0xeb>
    if(p->state == UNUSED)
8010510a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510d:	8b 40 0c             	mov    0xc(%eax),%eax
80105110:	85 c0                	test   %eax,%eax
80105112:	75 05                	jne    80105119 <procdump+0x21>
      continue;
80105114:	e9 c3 00 00 00       	jmp    801051dc <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511c:	8b 40 0c             	mov    0xc(%eax),%eax
8010511f:	83 f8 05             	cmp    $0x5,%eax
80105122:	77 23                	ja     80105147 <procdump+0x4f>
80105124:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105127:	8b 40 0c             	mov    0xc(%eax),%eax
8010512a:	8b 04 85 1c c0 10 80 	mov    -0x7fef3fe4(,%eax,4),%eax
80105131:	85 c0                	test   %eax,%eax
80105133:	74 12                	je     80105147 <procdump+0x4f>
      state = states[p->state];
80105135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105138:	8b 40 0c             	mov    0xc(%eax),%eax
8010513b:	8b 04 85 1c c0 10 80 	mov    -0x7fef3fe4(,%eax,4),%eax
80105142:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105145:	eb 07                	jmp    8010514e <procdump+0x56>
    else
      state = "???";
80105147:	c7 45 ec cc 93 10 80 	movl   $0x801093cc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010514e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105151:	8d 50 70             	lea    0x70(%eax),%edx
80105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105157:	8b 40 10             	mov    0x10(%eax),%eax
8010515a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010515e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105161:	89 54 24 08          	mov    %edx,0x8(%esp)
80105165:	89 44 24 04          	mov    %eax,0x4(%esp)
80105169:	c7 04 24 d0 93 10 80 	movl   $0x801093d0,(%esp)
80105170:	e8 2b b2 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80105175:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105178:	8b 40 0c             	mov    0xc(%eax),%eax
8010517b:	83 f8 02             	cmp    $0x2,%eax
8010517e:	75 50                	jne    801051d0 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105183:	8b 40 20             	mov    0x20(%eax),%eax
80105186:	8b 40 0c             	mov    0xc(%eax),%eax
80105189:	83 c0 08             	add    $0x8,%eax
8010518c:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010518f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105193:	89 04 24             	mov    %eax,(%esp)
80105196:	e8 38 04 00 00       	call   801055d3 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010519b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051a2:	eb 1b                	jmp    801051bf <procdump+0xc7>
        cprintf(" %p", pc[i]);
801051a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801051af:	c7 04 24 d9 93 10 80 	movl   $0x801093d9,(%esp)
801051b6:	e8 e5 b1 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801051bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801051bf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801051c3:	7f 0b                	jg     801051d0 <procdump+0xd8>
801051c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051cc:	85 c0                	test   %eax,%eax
801051ce:	75 d4                	jne    801051a4 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801051d0:	c7 04 24 dd 93 10 80 	movl   $0x801093dd,(%esp)
801051d7:	e8 c4 b1 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051dc:	81 45 f0 34 01 00 00 	addl   $0x134,-0x10(%ebp)
801051e3:	81 7d f0 f4 86 11 80 	cmpl   $0x801186f4,-0x10(%ebp)
801051ea:	0f 82 1a ff ff ff    	jb     8010510a <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801051f0:	c9                   	leave  
801051f1:	c3                   	ret    

801051f2 <signal>:

int 
signal(int signum, sighandler_t handler) {
801051f2:	55                   	push   %ebp
801051f3:	89 e5                	mov    %esp,%ebp
801051f5:	83 ec 10             	sub    $0x10,%esp
	sighandler_t retHandler;
	if (signum >= 32 || signum < 0) {
801051f8:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
801051fc:	7f 06                	jg     80105204 <signal+0x12>
801051fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105202:	79 07                	jns    8010520b <signal+0x19>
	    return -1;
80105204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105209:	eb 29                	jmp    80105234 <signal+0x42>
	}
	else {	
	    retHandler =  proc->signal_handlers[signum];
8010520b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105211:	8b 55 08             	mov    0x8(%ebp),%edx
80105214:	83 c2 20             	add    $0x20,%edx
80105217:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010521b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	    proc->signal_handlers[signum] = handler;
8010521e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105224:	8b 55 08             	mov    0x8(%ebp),%edx
80105227:	8d 4a 20             	lea    0x20(%edx),%ecx
8010522a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010522d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
	}
	return (int)retHandler;
80105231:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105234:	c9                   	leave  
80105235:	c3                   	ret    

80105236 <sigsend>:

int 
sigsend(int pid, int signum) {
80105236:	55                   	push   %ebp
80105237:	89 e5                	mov    %esp,%ebp
80105239:	83 ec 28             	sub    $0x28,%esp
    struct proc *p;

    if (signum >= 31 || signum < 0) {
8010523c:	83 7d 0c 1e          	cmpl   $0x1e,0xc(%ebp)
80105240:	7f 06                	jg     80105248 <sigsend+0x12>
80105242:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105246:	79 0a                	jns    80105252 <sigsend+0x1c>
	return -1;
80105248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524d:	e9 91 00 00 00       	jmp    801052e3 <sigsend+0xad>
    }
    uint signumBits = 1 << signum; // bit respresentation of signum. e.g: signum = 5 -> signumBits = 000000...0100000         
80105252:	8b 45 0c             	mov    0xc(%ebp),%eax
80105255:	ba 01 00 00 00       	mov    $0x1,%edx
8010525a:	89 c1                	mov    %eax,%ecx
8010525c:	d3 e2                	shl    %cl,%edx
8010525e:	89 d0                	mov    %edx,%eax
80105260:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&ptable.lock);
80105263:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010526a:	e8 b3 02 00 00       	call   80105522 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010526f:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80105276:	eb 51                	jmp    801052c9 <sigsend+0x93>
      if(p->pid == pid){
80105278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527b:	8b 40 10             	mov    0x10(%eax),%eax
8010527e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105281:	75 3f                	jne    801052c2 <sigsend+0x8c>
	p->pending |= signumBits;
80105283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105286:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010528c:	0b 45 f0             	or     -0x10(%ebp),%eax
8010528f:	89 c2                	mov    %eax,%edx
80105291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105294:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	// Wake process from sleep if necessary.
	if(p->state == SLEEPING)
8010529a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529d:	8b 40 0c             	mov    0xc(%eax),%eax
801052a0:	83 f8 02             	cmp    $0x2,%eax
801052a3:	75 0a                	jne    801052af <sigsend+0x79>
	  p->state = RUNNABLE;
801052a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	release(&ptable.lock);
801052af:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801052b6:	e8 c9 02 00 00       	call   80105584 <release>
	return 0;
801052bb:	b8 00 00 00 00       	mov    $0x0,%eax
801052c0:	eb 21                	jmp    801052e3 <sigsend+0xad>
    if (signum >= 31 || signum < 0) {
	return -1;
    }
    uint signumBits = 1 << signum; // bit respresentation of signum. e.g: signum = 5 -> signumBits = 000000...0100000         
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052c2:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
801052c9:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
801052d0:	72 a6                	jb     80105278 <sigsend+0x42>
	  p->state = RUNNABLE;
	release(&ptable.lock);
	return 0;
      }
    }
    release(&ptable.lock);
801052d2:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801052d9:	e8 a6 02 00 00       	call   80105584 <release>
    return -1;
801052de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052e3:	c9                   	leave  
801052e4:	c3                   	ret    

801052e5 <advanceprocstats>:

void
advanceprocstats(void)
{
801052e5:	55                   	push   %ebp
801052e6:	89 e5                	mov    %esp,%ebp
801052e8:	83 ec 10             	sub    $0x10,%esp
	struct proc *p;

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052eb:	c7 45 fc f4 39 11 80 	movl   $0x801139f4,-0x4(%ebp)
801052f2:	eb 6c                	jmp    80105360 <advanceprocstats+0x7b>
		if(p->state == RUNNING) {
801052f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f7:	8b 40 0c             	mov    0xc(%eax),%eax
801052fa:	83 f8 04             	cmp    $0x4,%eax
801052fd:	75 17                	jne    80105316 <advanceprocstats+0x31>
			p->rutime++;
801052ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105302:	8b 80 18 01 00 00    	mov    0x118(%eax),%eax
80105308:	8d 50 01             	lea    0x1(%eax),%edx
8010530b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530e:	89 90 18 01 00 00    	mov    %edx,0x118(%eax)
			continue;
80105314:	eb 43                	jmp    80105359 <advanceprocstats+0x74>
		}
		if(p->state == RUNNABLE) {
80105316:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105319:	8b 40 0c             	mov    0xc(%eax),%eax
8010531c:	83 f8 03             	cmp    $0x3,%eax
8010531f:	75 17                	jne    80105338 <advanceprocstats+0x53>
			p->retime++;
80105321:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105324:	8b 80 14 01 00 00    	mov    0x114(%eax),%eax
8010532a:	8d 50 01             	lea    0x1(%eax),%edx
8010532d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105330:	89 90 14 01 00 00    	mov    %edx,0x114(%eax)
			continue;
80105336:	eb 21                	jmp    80105359 <advanceprocstats+0x74>
		}
		if(p->state == SLEEPING) {
80105338:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010533b:	8b 40 0c             	mov    0xc(%eax),%eax
8010533e:	83 f8 02             	cmp    $0x2,%eax
80105341:	75 16                	jne    80105359 <advanceprocstats+0x74>
			p->stime++;
80105343:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105346:	8b 80 10 01 00 00    	mov    0x110(%eax),%eax
8010534c:	8d 50 01             	lea    0x1(%eax),%edx
8010534f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105352:	89 90 10 01 00 00    	mov    %edx,0x110(%eax)
			continue;
80105358:	90                   	nop
void
advanceprocstats(void)
{
	struct proc *p;

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105359:	81 45 fc 34 01 00 00 	addl   $0x134,-0x4(%ebp)
80105360:	81 7d fc f4 86 11 80 	cmpl   $0x801186f4,-0x4(%ebp)
80105367:	72 8b                	jb     801052f4 <advanceprocstats+0xf>
		if(p->state == SLEEPING) {
			p->stime++;
			continue;
		}
	}
 }
80105369:	c9                   	leave  
8010536a:	c3                   	ret    

8010536b <wait_stat>:

int
wait_stat(struct perf *perfP){
8010536b:	55                   	push   %ebp
8010536c:	89 e5                	mov    %esp,%ebp
8010536e:	83 ec 28             	sub    $0x28,%esp
	struct proc *p;
	int havekids, pid;
	acquire(&ptable.lock);
80105371:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80105378:	e8 a5 01 00 00       	call   80105522 <acquire>
	for(;;){
		// Scan through table looking for zombie children.
		havekids = 0;
8010537d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105384:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
8010538b:	e9 eb 00 00 00       	jmp    8010547b <wait_stat+0x110>
			if(p->parent != proc)
80105390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105393:	8b 50 14             	mov    0x14(%eax),%edx
80105396:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010539c:	39 c2                	cmp    %eax,%edx
8010539e:	74 05                	je     801053a5 <wait_stat+0x3a>
				continue;
801053a0:	e9 cf 00 00 00       	jmp    80105474 <wait_stat+0x109>
			havekids = 1;
801053a5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
			if(p->state == ZOMBIE){
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	8b 40 0c             	mov    0xc(%eax),%eax
801053b2:	83 f8 05             	cmp    $0x5,%eax
801053b5:	0f 85 b9 00 00 00    	jne    80105474 <wait_stat+0x109>
			  
				// Found one.
				pid = p->pid;
801053bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053be:	8b 40 10             	mov    0x10(%eax),%eax
801053c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
				
				// the extra
				perfP->ctime =  p->ctime ;
801053c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c7:	8b 90 08 01 00 00    	mov    0x108(%eax),%edx
801053cd:	8b 45 08             	mov    0x8(%ebp),%eax
801053d0:	89 10                	mov    %edx,(%eax)
				perfP->ttime =  p->ttime ;
801053d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d5:	8b 90 0c 01 00 00    	mov    0x10c(%eax),%edx
801053db:	8b 45 08             	mov    0x8(%ebp),%eax
801053de:	89 50 04             	mov    %edx,0x4(%eax)
				perfP->stime =  p->stime ;
801053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e4:	8b 90 10 01 00 00    	mov    0x110(%eax),%edx
801053ea:	8b 45 08             	mov    0x8(%ebp),%eax
801053ed:	89 50 08             	mov    %edx,0x8(%eax)
				perfP->retime = p->retime ;
801053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f3:	8b 90 14 01 00 00    	mov    0x114(%eax),%edx
801053f9:	8b 45 08             	mov    0x8(%ebp),%eax
801053fc:	89 50 0c             	mov    %edx,0xc(%eax)
				perfP->rutime = p->rutime ;
801053ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105402:	8b 90 18 01 00 00    	mov    0x118(%eax),%edx
80105408:	8b 45 08             	mov    0x8(%ebp),%eax
8010540b:	89 50 10             	mov    %edx,0x10(%eax)
				kfree(p->kstack);
8010540e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105411:	8b 40 08             	mov    0x8(%eax),%eax
80105414:	89 04 24             	mov    %eax,(%esp)
80105417:	e8 2d d6 ff ff       	call   80102a49 <kfree>
				p->kstack = 0;
8010541c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
				freevm(p->pgdir);
80105426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105429:	8b 40 04             	mov    0x4(%eax),%eax
8010542c:	89 04 24             	mov    %eax,(%esp)
8010542f:	e8 1e 39 00 00       	call   80108d52 <freevm>
				p->state = UNUSED;
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
				p->pid = 0;
8010543e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105441:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
				p->parent = 0;
80105448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
				p->name[0] = 0;
80105452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105455:	c6 40 70 00          	movb   $0x0,0x70(%eax)
				p->killed = 0;
80105459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010545c:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
				release(&ptable.lock);
80105463:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010546a:	e8 15 01 00 00       	call   80105584 <release>
				return pid;
8010546f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105472:	eb 55                	jmp    801054c9 <wait_stat+0x15e>
	int havekids, pid;
	acquire(&ptable.lock);
	for(;;){
		// Scan through table looking for zombie children.
		havekids = 0;
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105474:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
8010547b:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80105482:	0f 82 08 ff ff ff    	jb     80105390 <wait_stat+0x25>
				return pid;
			}
		}
		
		// No point waiting if we don't have any children.
		if(!havekids || proc->killed){
80105488:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010548c:	74 0d                	je     8010549b <wait_stat+0x130>
8010548e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105494:	8b 40 28             	mov    0x28(%eax),%eax
80105497:	85 c0                	test   %eax,%eax
80105499:	74 13                	je     801054ae <wait_stat+0x143>
			release(&ptable.lock);
8010549b:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801054a2:	e8 dd 00 00 00       	call   80105584 <release>
			return -1;
801054a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ac:	eb 1b                	jmp    801054c9 <wait_stat+0x15e>
		}

		// Wait for children to exit.  (See wakeup1 call in proc_exit.)
		sleep(proc, &ptable.lock);  //DOC: wait-sleep
801054ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b4:	c7 44 24 04 c0 39 11 	movl   $0x801139c0,0x4(%esp)
801054bb:	80 
801054bc:	89 04 24             	mov    %eax,(%esp)
801054bf:	e8 9c fa ff ff       	call   80104f60 <sleep>
	}
801054c4:	e9 b4 fe ff ff       	jmp    8010537d <wait_stat+0x12>

 }
801054c9:	c9                   	leave  
801054ca:	c3                   	ret    

801054cb <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801054cb:	55                   	push   %ebp
801054cc:	89 e5                	mov    %esp,%ebp
801054ce:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801054d1:	9c                   	pushf  
801054d2:	58                   	pop    %eax
801054d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801054d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054d9:	c9                   	leave  
801054da:	c3                   	ret    

801054db <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801054db:	55                   	push   %ebp
801054dc:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801054de:	fa                   	cli    
}
801054df:	5d                   	pop    %ebp
801054e0:	c3                   	ret    

801054e1 <sti>:

static inline void
sti(void)
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801054e4:	fb                   	sti    
}
801054e5:	5d                   	pop    %ebp
801054e6:	c3                   	ret    

801054e7 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801054e7:	55                   	push   %ebp
801054e8:	89 e5                	mov    %esp,%ebp
801054ea:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801054ed:	8b 55 08             	mov    0x8(%ebp),%edx
801054f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054f6:	f0 87 02             	lock xchg %eax,(%edx)
801054f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801054fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054ff:	c9                   	leave  
80105500:	c3                   	ret    

80105501 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105501:	55                   	push   %ebp
80105502:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105504:	8b 45 08             	mov    0x8(%ebp),%eax
80105507:	8b 55 0c             	mov    0xc(%ebp),%edx
8010550a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010550d:	8b 45 08             	mov    0x8(%ebp),%eax
80105510:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105516:	8b 45 08             	mov    0x8(%ebp),%eax
80105519:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105520:	5d                   	pop    %ebp
80105521:	c3                   	ret    

80105522 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105522:	55                   	push   %ebp
80105523:	89 e5                	mov    %esp,%ebp
80105525:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105528:	e8 49 01 00 00       	call   80105676 <pushcli>
  if(holding(lk))
8010552d:	8b 45 08             	mov    0x8(%ebp),%eax
80105530:	89 04 24             	mov    %eax,(%esp)
80105533:	e8 14 01 00 00       	call   8010564c <holding>
80105538:	85 c0                	test   %eax,%eax
8010553a:	74 0c                	je     80105548 <acquire+0x26>
    panic("acquire");
8010553c:	c7 04 24 09 94 10 80 	movl   $0x80109409,(%esp)
80105543:	e8 f2 af ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105548:	90                   	nop
80105549:	8b 45 08             	mov    0x8(%ebp),%eax
8010554c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105553:	00 
80105554:	89 04 24             	mov    %eax,(%esp)
80105557:	e8 8b ff ff ff       	call   801054e7 <xchg>
8010555c:	85 c0                	test   %eax,%eax
8010555e:	75 e9                	jne    80105549 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010556a:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010556d:	8b 45 08             	mov    0x8(%ebp),%eax
80105570:	83 c0 0c             	add    $0xc,%eax
80105573:	89 44 24 04          	mov    %eax,0x4(%esp)
80105577:	8d 45 08             	lea    0x8(%ebp),%eax
8010557a:	89 04 24             	mov    %eax,(%esp)
8010557d:	e8 51 00 00 00       	call   801055d3 <getcallerpcs>
}
80105582:	c9                   	leave  
80105583:	c3                   	ret    

80105584 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105584:	55                   	push   %ebp
80105585:	89 e5                	mov    %esp,%ebp
80105587:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010558a:	8b 45 08             	mov    0x8(%ebp),%eax
8010558d:	89 04 24             	mov    %eax,(%esp)
80105590:	e8 b7 00 00 00       	call   8010564c <holding>
80105595:	85 c0                	test   %eax,%eax
80105597:	75 0c                	jne    801055a5 <release+0x21>
    panic("release");
80105599:	c7 04 24 11 94 10 80 	movl   $0x80109411,(%esp)
801055a0:	e8 95 af ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
801055a5:	8b 45 08             	mov    0x8(%ebp),%eax
801055a8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801055af:	8b 45 08             	mov    0x8(%ebp),%eax
801055b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801055b9:	8b 45 08             	mov    0x8(%ebp),%eax
801055bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055c3:	00 
801055c4:	89 04 24             	mov    %eax,(%esp)
801055c7:	e8 1b ff ff ff       	call   801054e7 <xchg>

  popcli();
801055cc:	e8 e9 00 00 00       	call   801056ba <popcli>
}
801055d1:	c9                   	leave  
801055d2:	c3                   	ret    

801055d3 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801055d3:	55                   	push   %ebp
801055d4:	89 e5                	mov    %esp,%ebp
801055d6:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801055d9:	8b 45 08             	mov    0x8(%ebp),%eax
801055dc:	83 e8 08             	sub    $0x8,%eax
801055df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801055e2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801055e9:	eb 38                	jmp    80105623 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801055eb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801055ef:	74 38                	je     80105629 <getcallerpcs+0x56>
801055f1:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801055f8:	76 2f                	jbe    80105629 <getcallerpcs+0x56>
801055fa:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801055fe:	74 29                	je     80105629 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105600:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105603:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010560a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010560d:	01 c2                	add    %eax,%edx
8010560f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105612:	8b 40 04             	mov    0x4(%eax),%eax
80105615:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010561f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105623:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105627:	7e c2                	jle    801055eb <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105629:	eb 19                	jmp    80105644 <getcallerpcs+0x71>
    pcs[i] = 0;
8010562b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010562e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105635:	8b 45 0c             	mov    0xc(%ebp),%eax
80105638:	01 d0                	add    %edx,%eax
8010563a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105640:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105644:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105648:	7e e1                	jle    8010562b <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010564a:	c9                   	leave  
8010564b:	c3                   	ret    

8010564c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010564c:	55                   	push   %ebp
8010564d:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010564f:	8b 45 08             	mov    0x8(%ebp),%eax
80105652:	8b 00                	mov    (%eax),%eax
80105654:	85 c0                	test   %eax,%eax
80105656:	74 17                	je     8010566f <holding+0x23>
80105658:	8b 45 08             	mov    0x8(%ebp),%eax
8010565b:	8b 50 08             	mov    0x8(%eax),%edx
8010565e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105664:	39 c2                	cmp    %eax,%edx
80105666:	75 07                	jne    8010566f <holding+0x23>
80105668:	b8 01 00 00 00       	mov    $0x1,%eax
8010566d:	eb 05                	jmp    80105674 <holding+0x28>
8010566f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105674:	5d                   	pop    %ebp
80105675:	c3                   	ret    

80105676 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105676:	55                   	push   %ebp
80105677:	89 e5                	mov    %esp,%ebp
80105679:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010567c:	e8 4a fe ff ff       	call   801054cb <readeflags>
80105681:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105684:	e8 52 fe ff ff       	call   801054db <cli>
  if(cpu->ncli++ == 0)
80105689:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105690:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105696:	8d 48 01             	lea    0x1(%eax),%ecx
80105699:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010569f:	85 c0                	test   %eax,%eax
801056a1:	75 15                	jne    801056b8 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801056a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056ac:	81 e2 00 02 00 00    	and    $0x200,%edx
801056b2:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801056b8:	c9                   	leave  
801056b9:	c3                   	ret    

801056ba <popcli>:

void
popcli(void)
{
801056ba:	55                   	push   %ebp
801056bb:	89 e5                	mov    %esp,%ebp
801056bd:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801056c0:	e8 06 fe ff ff       	call   801054cb <readeflags>
801056c5:	25 00 02 00 00       	and    $0x200,%eax
801056ca:	85 c0                	test   %eax,%eax
801056cc:	74 0c                	je     801056da <popcli+0x20>
    panic("popcli - interruptible");
801056ce:	c7 04 24 19 94 10 80 	movl   $0x80109419,(%esp)
801056d5:	e8 60 ae ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801056da:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801056e0:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801056e6:	83 ea 01             	sub    $0x1,%edx
801056e9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801056ef:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801056f5:	85 c0                	test   %eax,%eax
801056f7:	79 0c                	jns    80105705 <popcli+0x4b>
    panic("popcli");
801056f9:	c7 04 24 30 94 10 80 	movl   $0x80109430,(%esp)
80105700:	e8 35 ae ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105705:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010570b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105711:	85 c0                	test   %eax,%eax
80105713:	75 15                	jne    8010572a <popcli+0x70>
80105715:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010571b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105721:	85 c0                	test   %eax,%eax
80105723:	74 05                	je     8010572a <popcli+0x70>
    sti();
80105725:	e8 b7 fd ff ff       	call   801054e1 <sti>
}
8010572a:	c9                   	leave  
8010572b:	c3                   	ret    

8010572c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	57                   	push   %edi
80105730:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105731:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105734:	8b 55 10             	mov    0x10(%ebp),%edx
80105737:	8b 45 0c             	mov    0xc(%ebp),%eax
8010573a:	89 cb                	mov    %ecx,%ebx
8010573c:	89 df                	mov    %ebx,%edi
8010573e:	89 d1                	mov    %edx,%ecx
80105740:	fc                   	cld    
80105741:	f3 aa                	rep stos %al,%es:(%edi)
80105743:	89 ca                	mov    %ecx,%edx
80105745:	89 fb                	mov    %edi,%ebx
80105747:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010574a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010574d:	5b                   	pop    %ebx
8010574e:	5f                   	pop    %edi
8010574f:	5d                   	pop    %ebp
80105750:	c3                   	ret    

80105751 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105751:	55                   	push   %ebp
80105752:	89 e5                	mov    %esp,%ebp
80105754:	57                   	push   %edi
80105755:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105756:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105759:	8b 55 10             	mov    0x10(%ebp),%edx
8010575c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575f:	89 cb                	mov    %ecx,%ebx
80105761:	89 df                	mov    %ebx,%edi
80105763:	89 d1                	mov    %edx,%ecx
80105765:	fc                   	cld    
80105766:	f3 ab                	rep stos %eax,%es:(%edi)
80105768:	89 ca                	mov    %ecx,%edx
8010576a:	89 fb                	mov    %edi,%ebx
8010576c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010576f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105772:	5b                   	pop    %ebx
80105773:	5f                   	pop    %edi
80105774:	5d                   	pop    %ebp
80105775:	c3                   	ret    

80105776 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105776:	55                   	push   %ebp
80105777:	89 e5                	mov    %esp,%ebp
80105779:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010577c:	8b 45 08             	mov    0x8(%ebp),%eax
8010577f:	83 e0 03             	and    $0x3,%eax
80105782:	85 c0                	test   %eax,%eax
80105784:	75 49                	jne    801057cf <memset+0x59>
80105786:	8b 45 10             	mov    0x10(%ebp),%eax
80105789:	83 e0 03             	and    $0x3,%eax
8010578c:	85 c0                	test   %eax,%eax
8010578e:	75 3f                	jne    801057cf <memset+0x59>
    c &= 0xFF;
80105790:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105797:	8b 45 10             	mov    0x10(%ebp),%eax
8010579a:	c1 e8 02             	shr    $0x2,%eax
8010579d:	89 c2                	mov    %eax,%edx
8010579f:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a2:	c1 e0 18             	shl    $0x18,%eax
801057a5:	89 c1                	mov    %eax,%ecx
801057a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057aa:	c1 e0 10             	shl    $0x10,%eax
801057ad:	09 c1                	or     %eax,%ecx
801057af:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b2:	c1 e0 08             	shl    $0x8,%eax
801057b5:	09 c8                	or     %ecx,%eax
801057b7:	0b 45 0c             	or     0xc(%ebp),%eax
801057ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801057be:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c2:	8b 45 08             	mov    0x8(%ebp),%eax
801057c5:	89 04 24             	mov    %eax,(%esp)
801057c8:	e8 84 ff ff ff       	call   80105751 <stosl>
801057cd:	eb 19                	jmp    801057e8 <memset+0x72>
  } else
    stosb(dst, c, n);
801057cf:	8b 45 10             	mov    0x10(%ebp),%eax
801057d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801057d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801057dd:	8b 45 08             	mov    0x8(%ebp),%eax
801057e0:	89 04 24             	mov    %eax,(%esp)
801057e3:	e8 44 ff ff ff       	call   8010572c <stosb>
  return dst;
801057e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057eb:	c9                   	leave  
801057ec:	c3                   	ret    

801057ed <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801057ed:	55                   	push   %ebp
801057ee:	89 e5                	mov    %esp,%ebp
801057f0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801057f3:	8b 45 08             	mov    0x8(%ebp),%eax
801057f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801057f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801057ff:	eb 30                	jmp    80105831 <memcmp+0x44>
    if(*s1 != *s2)
80105801:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105804:	0f b6 10             	movzbl (%eax),%edx
80105807:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010580a:	0f b6 00             	movzbl (%eax),%eax
8010580d:	38 c2                	cmp    %al,%dl
8010580f:	74 18                	je     80105829 <memcmp+0x3c>
      return *s1 - *s2;
80105811:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105814:	0f b6 00             	movzbl (%eax),%eax
80105817:	0f b6 d0             	movzbl %al,%edx
8010581a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010581d:	0f b6 00             	movzbl (%eax),%eax
80105820:	0f b6 c0             	movzbl %al,%eax
80105823:	29 c2                	sub    %eax,%edx
80105825:	89 d0                	mov    %edx,%eax
80105827:	eb 1a                	jmp    80105843 <memcmp+0x56>
    s1++, s2++;
80105829:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010582d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105831:	8b 45 10             	mov    0x10(%ebp),%eax
80105834:	8d 50 ff             	lea    -0x1(%eax),%edx
80105837:	89 55 10             	mov    %edx,0x10(%ebp)
8010583a:	85 c0                	test   %eax,%eax
8010583c:	75 c3                	jne    80105801 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010583e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105843:	c9                   	leave  
80105844:	c3                   	ret    

80105845 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105845:	55                   	push   %ebp
80105846:	89 e5                	mov    %esp,%ebp
80105848:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010584b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105851:	8b 45 08             	mov    0x8(%ebp),%eax
80105854:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105857:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010585a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010585d:	73 3d                	jae    8010589c <memmove+0x57>
8010585f:	8b 45 10             	mov    0x10(%ebp),%eax
80105862:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105865:	01 d0                	add    %edx,%eax
80105867:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010586a:	76 30                	jbe    8010589c <memmove+0x57>
    s += n;
8010586c:	8b 45 10             	mov    0x10(%ebp),%eax
8010586f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105872:	8b 45 10             	mov    0x10(%ebp),%eax
80105875:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105878:	eb 13                	jmp    8010588d <memmove+0x48>
      *--d = *--s;
8010587a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010587e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105882:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105885:	0f b6 10             	movzbl (%eax),%edx
80105888:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010588b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010588d:	8b 45 10             	mov    0x10(%ebp),%eax
80105890:	8d 50 ff             	lea    -0x1(%eax),%edx
80105893:	89 55 10             	mov    %edx,0x10(%ebp)
80105896:	85 c0                	test   %eax,%eax
80105898:	75 e0                	jne    8010587a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010589a:	eb 26                	jmp    801058c2 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010589c:	eb 17                	jmp    801058b5 <memmove+0x70>
      *d++ = *s++;
8010589e:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058a1:	8d 50 01             	lea    0x1(%eax),%edx
801058a4:	89 55 f8             	mov    %edx,-0x8(%ebp)
801058a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058aa:	8d 4a 01             	lea    0x1(%edx),%ecx
801058ad:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801058b0:	0f b6 12             	movzbl (%edx),%edx
801058b3:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801058b5:	8b 45 10             	mov    0x10(%ebp),%eax
801058b8:	8d 50 ff             	lea    -0x1(%eax),%edx
801058bb:	89 55 10             	mov    %edx,0x10(%ebp)
801058be:	85 c0                	test   %eax,%eax
801058c0:	75 dc                	jne    8010589e <memmove+0x59>
      *d++ = *s++;

  return dst;
801058c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801058c5:	c9                   	leave  
801058c6:	c3                   	ret    

801058c7 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801058c7:	55                   	push   %ebp
801058c8:	89 e5                	mov    %esp,%ebp
801058ca:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801058cd:	8b 45 10             	mov    0x10(%ebp),%eax
801058d0:	89 44 24 08          	mov    %eax,0x8(%esp)
801058d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801058db:	8b 45 08             	mov    0x8(%ebp),%eax
801058de:	89 04 24             	mov    %eax,(%esp)
801058e1:	e8 5f ff ff ff       	call   80105845 <memmove>
}
801058e6:	c9                   	leave  
801058e7:	c3                   	ret    

801058e8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801058eb:	eb 0c                	jmp    801058f9 <strncmp+0x11>
    n--, p++, q++;
801058ed:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801058f5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801058f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058fd:	74 1a                	je     80105919 <strncmp+0x31>
801058ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105902:	0f b6 00             	movzbl (%eax),%eax
80105905:	84 c0                	test   %al,%al
80105907:	74 10                	je     80105919 <strncmp+0x31>
80105909:	8b 45 08             	mov    0x8(%ebp),%eax
8010590c:	0f b6 10             	movzbl (%eax),%edx
8010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105912:	0f b6 00             	movzbl (%eax),%eax
80105915:	38 c2                	cmp    %al,%dl
80105917:	74 d4                	je     801058ed <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105919:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010591d:	75 07                	jne    80105926 <strncmp+0x3e>
    return 0;
8010591f:	b8 00 00 00 00       	mov    $0x0,%eax
80105924:	eb 16                	jmp    8010593c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105926:	8b 45 08             	mov    0x8(%ebp),%eax
80105929:	0f b6 00             	movzbl (%eax),%eax
8010592c:	0f b6 d0             	movzbl %al,%edx
8010592f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105932:	0f b6 00             	movzbl (%eax),%eax
80105935:	0f b6 c0             	movzbl %al,%eax
80105938:	29 c2                	sub    %eax,%edx
8010593a:	89 d0                	mov    %edx,%eax
}
8010593c:	5d                   	pop    %ebp
8010593d:	c3                   	ret    

8010593e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010593e:	55                   	push   %ebp
8010593f:	89 e5                	mov    %esp,%ebp
80105941:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105944:	8b 45 08             	mov    0x8(%ebp),%eax
80105947:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010594a:	90                   	nop
8010594b:	8b 45 10             	mov    0x10(%ebp),%eax
8010594e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105951:	89 55 10             	mov    %edx,0x10(%ebp)
80105954:	85 c0                	test   %eax,%eax
80105956:	7e 1e                	jle    80105976 <strncpy+0x38>
80105958:	8b 45 08             	mov    0x8(%ebp),%eax
8010595b:	8d 50 01             	lea    0x1(%eax),%edx
8010595e:	89 55 08             	mov    %edx,0x8(%ebp)
80105961:	8b 55 0c             	mov    0xc(%ebp),%edx
80105964:	8d 4a 01             	lea    0x1(%edx),%ecx
80105967:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010596a:	0f b6 12             	movzbl (%edx),%edx
8010596d:	88 10                	mov    %dl,(%eax)
8010596f:	0f b6 00             	movzbl (%eax),%eax
80105972:	84 c0                	test   %al,%al
80105974:	75 d5                	jne    8010594b <strncpy+0xd>
    ;
  while(n-- > 0)
80105976:	eb 0c                	jmp    80105984 <strncpy+0x46>
    *s++ = 0;
80105978:	8b 45 08             	mov    0x8(%ebp),%eax
8010597b:	8d 50 01             	lea    0x1(%eax),%edx
8010597e:	89 55 08             	mov    %edx,0x8(%ebp)
80105981:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105984:	8b 45 10             	mov    0x10(%ebp),%eax
80105987:	8d 50 ff             	lea    -0x1(%eax),%edx
8010598a:	89 55 10             	mov    %edx,0x10(%ebp)
8010598d:	85 c0                	test   %eax,%eax
8010598f:	7f e7                	jg     80105978 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105991:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105994:	c9                   	leave  
80105995:	c3                   	ret    

80105996 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105996:	55                   	push   %ebp
80105997:	89 e5                	mov    %esp,%ebp
80105999:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010599c:	8b 45 08             	mov    0x8(%ebp),%eax
8010599f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801059a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059a6:	7f 05                	jg     801059ad <safestrcpy+0x17>
    return os;
801059a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ab:	eb 31                	jmp    801059de <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801059ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801059b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059b5:	7e 1e                	jle    801059d5 <safestrcpy+0x3f>
801059b7:	8b 45 08             	mov    0x8(%ebp),%eax
801059ba:	8d 50 01             	lea    0x1(%eax),%edx
801059bd:	89 55 08             	mov    %edx,0x8(%ebp)
801059c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801059c3:	8d 4a 01             	lea    0x1(%edx),%ecx
801059c6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801059c9:	0f b6 12             	movzbl (%edx),%edx
801059cc:	88 10                	mov    %dl,(%eax)
801059ce:	0f b6 00             	movzbl (%eax),%eax
801059d1:	84 c0                	test   %al,%al
801059d3:	75 d8                	jne    801059ad <safestrcpy+0x17>
    ;
  *s = 0;
801059d5:	8b 45 08             	mov    0x8(%ebp),%eax
801059d8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801059db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059de:	c9                   	leave  
801059df:	c3                   	ret    

801059e0 <strlen>:

int
strlen(const char *s)
{
801059e0:	55                   	push   %ebp
801059e1:	89 e5                	mov    %esp,%ebp
801059e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801059e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059ed:	eb 04                	jmp    801059f3 <strlen+0x13>
801059ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059f6:	8b 45 08             	mov    0x8(%ebp),%eax
801059f9:	01 d0                	add    %edx,%eax
801059fb:	0f b6 00             	movzbl (%eax),%eax
801059fe:	84 c0                	test   %al,%al
80105a00:	75 ed                	jne    801059ef <strlen+0xf>
    ;
  return n;
80105a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a05:	c9                   	leave  
80105a06:	c3                   	ret    

80105a07 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105a07:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105a0b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105a0f:	55                   	push   %ebp
  pushl %ebx
80105a10:	53                   	push   %ebx
  pushl %esi
80105a11:	56                   	push   %esi
  pushl %edi
80105a12:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105a13:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105a15:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105a17:	5f                   	pop    %edi
  popl %esi
80105a18:	5e                   	pop    %esi
  popl %ebx
80105a19:	5b                   	pop    %ebx
  popl %ebp
80105a1a:	5d                   	pop    %ebp
  ret
80105a1b:	c3                   	ret    

80105a1c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105a1c:	55                   	push   %ebp
80105a1d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105a1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a25:	8b 00                	mov    (%eax),%eax
80105a27:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a2a:	76 12                	jbe    80105a3e <fetchint+0x22>
80105a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105a2f:	8d 50 04             	lea    0x4(%eax),%edx
80105a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a38:	8b 00                	mov    (%eax),%eax
80105a3a:	39 c2                	cmp    %eax,%edx
80105a3c:	76 07                	jbe    80105a45 <fetchint+0x29>
    return -1;
80105a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a43:	eb 0f                	jmp    80105a54 <fetchint+0x38>
  *ip = *(int*)(addr);
80105a45:	8b 45 08             	mov    0x8(%ebp),%eax
80105a48:	8b 10                	mov    (%eax),%edx
80105a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a4d:	89 10                	mov    %edx,(%eax)
  return 0;
80105a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a54:	5d                   	pop    %ebp
80105a55:	c3                   	ret    

80105a56 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105a56:	55                   	push   %ebp
80105a57:	89 e5                	mov    %esp,%ebp
80105a59:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a62:	8b 00                	mov    (%eax),%eax
80105a64:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a67:	77 07                	ja     80105a70 <fetchstr+0x1a>
    return -1;
80105a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a6e:	eb 46                	jmp    80105ab6 <fetchstr+0x60>
  *pp = (char*)addr;
80105a70:	8b 55 08             	mov    0x8(%ebp),%edx
80105a73:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a76:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105a78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a7e:	8b 00                	mov    (%eax),%eax
80105a80:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a86:	8b 00                	mov    (%eax),%eax
80105a88:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105a8b:	eb 1c                	jmp    80105aa9 <fetchstr+0x53>
    if(*s == 0)
80105a8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a90:	0f b6 00             	movzbl (%eax),%eax
80105a93:	84 c0                	test   %al,%al
80105a95:	75 0e                	jne    80105aa5 <fetchstr+0x4f>
      return s - *pp;
80105a97:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a9d:	8b 00                	mov    (%eax),%eax
80105a9f:	29 c2                	sub    %eax,%edx
80105aa1:	89 d0                	mov    %edx,%eax
80105aa3:	eb 11                	jmp    80105ab6 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105aa5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105aaf:	72 dc                	jb     80105a8d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab6:	c9                   	leave  
80105ab7:	c3                   	ret    

80105ab8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105ab8:	55                   	push   %ebp
80105ab9:	89 e5                	mov    %esp,%ebp
80105abb:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105abe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac4:	8b 40 18             	mov    0x18(%eax),%eax
80105ac7:	8b 50 44             	mov    0x44(%eax),%edx
80105aca:	8b 45 08             	mov    0x8(%ebp),%eax
80105acd:	c1 e0 02             	shl    $0x2,%eax
80105ad0:	01 d0                	add    %edx,%eax
80105ad2:	8d 50 04             	lea    0x4(%eax),%edx
80105ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105adc:	89 14 24             	mov    %edx,(%esp)
80105adf:	e8 38 ff ff ff       	call   80105a1c <fetchint>
}
80105ae4:	c9                   	leave  
80105ae5:	c3                   	ret    

80105ae6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105ae6:	55                   	push   %ebp
80105ae7:	89 e5                	mov    %esp,%ebp
80105ae9:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105aec:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105aef:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af3:	8b 45 08             	mov    0x8(%ebp),%eax
80105af6:	89 04 24             	mov    %eax,(%esp)
80105af9:	e8 ba ff ff ff       	call   80105ab8 <argint>
80105afe:	85 c0                	test   %eax,%eax
80105b00:	79 07                	jns    80105b09 <argptr+0x23>
    return -1;
80105b02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b07:	eb 3d                	jmp    80105b46 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105b09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b0c:	89 c2                	mov    %eax,%edx
80105b0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b14:	8b 00                	mov    (%eax),%eax
80105b16:	39 c2                	cmp    %eax,%edx
80105b18:	73 16                	jae    80105b30 <argptr+0x4a>
80105b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b1d:	89 c2                	mov    %eax,%edx
80105b1f:	8b 45 10             	mov    0x10(%ebp),%eax
80105b22:	01 c2                	add    %eax,%edx
80105b24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b2a:	8b 00                	mov    (%eax),%eax
80105b2c:	39 c2                	cmp    %eax,%edx
80105b2e:	76 07                	jbe    80105b37 <argptr+0x51>
    return -1;
80105b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b35:	eb 0f                	jmp    80105b46 <argptr+0x60>
  *pp = (char*)i;
80105b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b3a:	89 c2                	mov    %eax,%edx
80105b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b3f:	89 10                	mov    %edx,(%eax)
  return 0;
80105b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b46:	c9                   	leave  
80105b47:	c3                   	ret    

80105b48 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105b48:	55                   	push   %ebp
80105b49:	89 e5                	mov    %esp,%ebp
80105b4b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105b4e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105b51:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b55:	8b 45 08             	mov    0x8(%ebp),%eax
80105b58:	89 04 24             	mov    %eax,(%esp)
80105b5b:	e8 58 ff ff ff       	call   80105ab8 <argint>
80105b60:	85 c0                	test   %eax,%eax
80105b62:	79 07                	jns    80105b6b <argstr+0x23>
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 12                	jmp    80105b7d <argstr+0x35>
  return fetchstr(addr, pp);
80105b6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b71:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b75:	89 04 24             	mov    %eax,(%esp)
80105b78:	e8 d9 fe ff ff       	call   80105a56 <fetchstr>
}
80105b7d:	c9                   	leave  
80105b7e:	c3                   	ret    

80105b7f <syscall>:
[SYS_priority] sys_priority,
};

void
syscall(void)
{
80105b7f:	55                   	push   %ebp
80105b80:	89 e5                	mov    %esp,%ebp
80105b82:	53                   	push   %ebx
80105b83:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105b86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b8c:	8b 40 18             	mov    0x18(%eax),%eax
80105b8f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b99:	7e 30                	jle    80105bcb <syscall+0x4c>
80105b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9e:	83 f8 1b             	cmp    $0x1b,%eax
80105ba1:	77 28                	ja     80105bcb <syscall+0x4c>
80105ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba6:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105bad:	85 c0                	test   %eax,%eax
80105baf:	74 1a                	je     80105bcb <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105bb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bb7:	8b 58 18             	mov    0x18(%eax),%ebx
80105bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbd:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105bc4:	ff d0                	call   *%eax
80105bc6:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105bc9:	eb 3d                	jmp    80105c08 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105bcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bd1:	8d 48 70             	lea    0x70(%eax),%ecx
80105bd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105bda:	8b 40 10             	mov    0x10(%eax),%eax
80105bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105be0:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105be4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105be8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bec:	c7 04 24 37 94 10 80 	movl   $0x80109437,(%esp)
80105bf3:	e8 a8 a7 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105bf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bfe:	8b 40 18             	mov    0x18(%eax),%eax
80105c01:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105c08:	83 c4 24             	add    $0x24,%esp
80105c0b:	5b                   	pop    %ebx
80105c0c:	5d                   	pop    %ebp
80105c0d:	c3                   	ret    

80105c0e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105c0e:	55                   	push   %ebp
80105c0f:	89 e5                	mov    %esp,%ebp
80105c11:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105c14:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1e:	89 04 24             	mov    %eax,(%esp)
80105c21:	e8 92 fe ff ff       	call   80105ab8 <argint>
80105c26:	85 c0                	test   %eax,%eax
80105c28:	79 07                	jns    80105c31 <argfd+0x23>
    return -1;
80105c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2f:	eb 50                	jmp    80105c81 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c34:	85 c0                	test   %eax,%eax
80105c36:	78 21                	js     80105c59 <argfd+0x4b>
80105c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3b:	83 f8 0f             	cmp    $0xf,%eax
80105c3e:	7f 19                	jg     80105c59 <argfd+0x4b>
80105c40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c46:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c49:	83 c2 08             	add    $0x8,%edx
80105c4c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105c50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c57:	75 07                	jne    80105c60 <argfd+0x52>
    return -1;
80105c59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5e:	eb 21                	jmp    80105c81 <argfd+0x73>
  if(pfd)
80105c60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c64:	74 08                	je     80105c6e <argfd+0x60>
    *pfd = fd;
80105c66:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c69:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c6c:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c72:	74 08                	je     80105c7c <argfd+0x6e>
    *pf = f;
80105c74:	8b 45 10             	mov    0x10(%ebp),%eax
80105c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c7a:	89 10                	mov    %edx,(%eax)
  return 0;
80105c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c81:	c9                   	leave  
80105c82:	c3                   	ret    

80105c83 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c83:	55                   	push   %ebp
80105c84:	89 e5                	mov    %esp,%ebp
80105c86:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105c89:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c90:	eb 30                	jmp    80105cc2 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105c92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c9b:	83 c2 08             	add    $0x8,%edx
80105c9e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	75 18                	jne    80105cbe <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105ca6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105caf:	8d 4a 08             	lea    0x8(%edx),%ecx
80105cb2:	8b 55 08             	mov    0x8(%ebp),%edx
80105cb5:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80105cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cbc:	eb 0f                	jmp    80105ccd <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105cbe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105cc2:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105cc6:	7e ca                	jle    80105c92 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ccd:	c9                   	leave  
80105cce:	c3                   	ret    

80105ccf <sys_dup>:

int
sys_dup(void)
{
80105ccf:	55                   	push   %ebp
80105cd0:	89 e5                	mov    %esp,%ebp
80105cd2:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105cd5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cdc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ce3:	00 
80105ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ceb:	e8 1e ff ff ff       	call   80105c0e <argfd>
80105cf0:	85 c0                	test   %eax,%eax
80105cf2:	79 07                	jns    80105cfb <sys_dup+0x2c>
    return -1;
80105cf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf9:	eb 29                	jmp    80105d24 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfe:	89 04 24             	mov    %eax,(%esp)
80105d01:	e8 7d ff ff ff       	call   80105c83 <fdalloc>
80105d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d0d:	79 07                	jns    80105d16 <sys_dup+0x47>
    return -1;
80105d0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d14:	eb 0e                	jmp    80105d24 <sys_dup+0x55>
  filedup(f);
80105d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d19:	89 04 24             	mov    %eax,(%esp)
80105d1c:	e8 65 b2 ff ff       	call   80100f86 <filedup>
  return fd;
80105d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d24:	c9                   	leave  
80105d25:	c3                   	ret    

80105d26 <sys_read>:

int
sys_read(void)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
80105d29:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d3a:	00 
80105d3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d42:	e8 c7 fe ff ff       	call   80105c0e <argfd>
80105d47:	85 c0                	test   %eax,%eax
80105d49:	78 35                	js     80105d80 <sys_read+0x5a>
80105d4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d52:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d59:	e8 5a fd ff ff       	call   80105ab8 <argint>
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 1e                	js     80105d80 <sys_read+0x5a>
80105d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d65:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d69:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d77:	e8 6a fd ff ff       	call   80105ae6 <argptr>
80105d7c:	85 c0                	test   %eax,%eax
80105d7e:	79 07                	jns    80105d87 <sys_read+0x61>
    return -1;
80105d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d85:	eb 19                	jmp    80105da0 <sys_read+0x7a>
  return fileread(f, p, n);
80105d87:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d90:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d94:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d98:	89 04 24             	mov    %eax,(%esp)
80105d9b:	e8 53 b3 ff ff       	call   801010f3 <fileread>
}
80105da0:	c9                   	leave  
80105da1:	c3                   	ret    

80105da2 <sys_write>:

int
sys_write(void)
{
80105da2:	55                   	push   %ebp
80105da3:	89 e5                	mov    %esp,%ebp
80105da5:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105da8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105daf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105db6:	00 
80105db7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dbe:	e8 4b fe ff ff       	call   80105c0e <argfd>
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	78 35                	js     80105dfc <sys_write+0x5a>
80105dc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dca:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dce:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105dd5:	e8 de fc ff ff       	call   80105ab8 <argint>
80105dda:	85 c0                	test   %eax,%eax
80105ddc:	78 1e                	js     80105dfc <sys_write+0x5a>
80105dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105de5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105df3:	e8 ee fc ff ff       	call   80105ae6 <argptr>
80105df8:	85 c0                	test   %eax,%eax
80105dfa:	79 07                	jns    80105e03 <sys_write+0x61>
    return -1;
80105dfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e01:	eb 19                	jmp    80105e1c <sys_write+0x7a>
  return filewrite(f, p, n);
80105e03:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105e06:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e10:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e14:	89 04 24             	mov    %eax,(%esp)
80105e17:	e8 93 b3 ff ff       	call   801011af <filewrite>
}
80105e1c:	c9                   	leave  
80105e1d:	c3                   	ret    

80105e1e <sys_close>:

int
sys_close(void)
{
80105e1e:	55                   	push   %ebp
80105e1f:	89 e5                	mov    %esp,%ebp
80105e21:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105e24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e27:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e39:	e8 d0 fd ff ff       	call   80105c0e <argfd>
80105e3e:	85 c0                	test   %eax,%eax
80105e40:	79 07                	jns    80105e49 <sys_close+0x2b>
    return -1;
80105e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e47:	eb 24                	jmp    80105e6d <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105e49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e52:	83 c2 08             	add    $0x8,%edx
80105e55:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105e5c:	00 
  fileclose(f);
80105e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e60:	89 04 24             	mov    %eax,(%esp)
80105e63:	e8 66 b1 ff ff       	call   80100fce <fileclose>
  return 0;
80105e68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e6d:	c9                   	leave  
80105e6e:	c3                   	ret    

80105e6f <sys_fstat>:

int
sys_fstat(void)
{
80105e6f:	55                   	push   %ebp
80105e70:	89 e5                	mov    %esp,%ebp
80105e72:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e78:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e83:	00 
80105e84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e8b:	e8 7e fd ff ff       	call   80105c0e <argfd>
80105e90:	85 c0                	test   %eax,%eax
80105e92:	78 1f                	js     80105eb3 <sys_fstat+0x44>
80105e94:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105e9b:	00 
80105e9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105eaa:	e8 37 fc ff ff       	call   80105ae6 <argptr>
80105eaf:	85 c0                	test   %eax,%eax
80105eb1:	79 07                	jns    80105eba <sys_fstat+0x4b>
    return -1;
80105eb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb8:	eb 12                	jmp    80105ecc <sys_fstat+0x5d>
  return filestat(f, st);
80105eba:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec0:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 d8 b1 ff ff       	call   801010a4 <filestat>
}
80105ecc:	c9                   	leave  
80105ecd:	c3                   	ret    

80105ece <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ece:	55                   	push   %ebp
80105ecf:	89 e5                	mov    %esp,%ebp
80105ed1:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ed4:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105edb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ee2:	e8 61 fc ff ff       	call   80105b48 <argstr>
80105ee7:	85 c0                	test   %eax,%eax
80105ee9:	78 17                	js     80105f02 <sys_link+0x34>
80105eeb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105eee:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ef9:	e8 4a fc ff ff       	call   80105b48 <argstr>
80105efe:	85 c0                	test   %eax,%eax
80105f00:	79 0a                	jns    80105f0c <sys_link+0x3e>
    return -1;
80105f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f07:	e9 42 01 00 00       	jmp    8010604e <sys_link+0x180>

  begin_op();
80105f0c:	e8 ff d4 ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
80105f11:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105f14:	89 04 24             	mov    %eax,(%esp)
80105f17:	e8 ea c4 ff ff       	call   80102406 <namei>
80105f1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f23:	75 0f                	jne    80105f34 <sys_link+0x66>
    end_op();
80105f25:	e8 6a d5 ff ff       	call   80103494 <end_op>
    return -1;
80105f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2f:	e9 1a 01 00 00       	jmp    8010604e <sys_link+0x180>
  }

  ilock(ip);
80105f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f37:	89 04 24             	mov    %eax,(%esp)
80105f3a:	e8 1c b9 ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f42:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f46:	66 83 f8 01          	cmp    $0x1,%ax
80105f4a:	75 1a                	jne    80105f66 <sys_link+0x98>
    iunlockput(ip);
80105f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4f:	89 04 24             	mov    %eax,(%esp)
80105f52:	e8 88 bb ff ff       	call   80101adf <iunlockput>
    end_op();
80105f57:	e8 38 d5 ff ff       	call   80103494 <end_op>
    return -1;
80105f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f61:	e9 e8 00 00 00       	jmp    8010604e <sys_link+0x180>
  }

  ip->nlink++;
80105f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f69:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f6d:	8d 50 01             	lea    0x1(%eax),%edx
80105f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f73:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7a:	89 04 24             	mov    %eax,(%esp)
80105f7d:	e8 1d b7 ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f85:	89 04 24             	mov    %eax,(%esp)
80105f88:	e8 1c ba ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105f8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f90:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f93:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f97:	89 04 24             	mov    %eax,(%esp)
80105f9a:	e8 89 c4 ff ff       	call   80102428 <nameiparent>
80105f9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa6:	75 02                	jne    80105faa <sys_link+0xdc>
    goto bad;
80105fa8:	eb 68                	jmp    80106012 <sys_link+0x144>
  ilock(dp);
80105faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fad:	89 04 24             	mov    %eax,(%esp)
80105fb0:	e8 a6 b8 ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb8:	8b 10                	mov    (%eax),%edx
80105fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbd:	8b 00                	mov    (%eax),%eax
80105fbf:	39 c2                	cmp    %eax,%edx
80105fc1:	75 20                	jne    80105fe3 <sys_link+0x115>
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	8b 40 04             	mov    0x4(%eax),%eax
80105fc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fcd:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd7:	89 04 24             	mov    %eax,(%esp)
80105fda:	e8 67 c1 ff ff       	call   80102146 <dirlink>
80105fdf:	85 c0                	test   %eax,%eax
80105fe1:	79 0d                	jns    80105ff0 <sys_link+0x122>
    iunlockput(dp);
80105fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe6:	89 04 24             	mov    %eax,(%esp)
80105fe9:	e8 f1 ba ff ff       	call   80101adf <iunlockput>
    goto bad;
80105fee:	eb 22                	jmp    80106012 <sys_link+0x144>
  }
  iunlockput(dp);
80105ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff3:	89 04 24             	mov    %eax,(%esp)
80105ff6:	e8 e4 ba ff ff       	call   80101adf <iunlockput>
  iput(ip);
80105ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffe:	89 04 24             	mov    %eax,(%esp)
80106001:	e8 08 ba ff ff       	call   80101a0e <iput>

  end_op();
80106006:	e8 89 d4 ff ff       	call   80103494 <end_op>

  return 0;
8010600b:	b8 00 00 00 00       	mov    $0x0,%eax
80106010:	eb 3c                	jmp    8010604e <sys_link+0x180>

bad:
  ilock(ip);
80106012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106015:	89 04 24             	mov    %eax,(%esp)
80106018:	e8 3e b8 ff ff       	call   8010185b <ilock>
  ip->nlink--;
8010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106020:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106024:	8d 50 ff             	lea    -0x1(%eax),%edx
80106027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010602e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106031:	89 04 24             	mov    %eax,(%esp)
80106034:	e8 66 b6 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80106039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603c:	89 04 24             	mov    %eax,(%esp)
8010603f:	e8 9b ba ff ff       	call   80101adf <iunlockput>
  end_op();
80106044:	e8 4b d4 ff ff       	call   80103494 <end_op>
  return -1;
80106049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010604e:	c9                   	leave  
8010604f:	c3                   	ret    

80106050 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106050:	55                   	push   %ebp
80106051:	89 e5                	mov    %esp,%ebp
80106053:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106056:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010605d:	eb 4b                	jmp    801060aa <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010605f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106062:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106069:	00 
8010606a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010606e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106071:	89 44 24 04          	mov    %eax,0x4(%esp)
80106075:	8b 45 08             	mov    0x8(%ebp),%eax
80106078:	89 04 24             	mov    %eax,(%esp)
8010607b:	e8 e8 bc ff ff       	call   80101d68 <readi>
80106080:	83 f8 10             	cmp    $0x10,%eax
80106083:	74 0c                	je     80106091 <isdirempty+0x41>
      panic("isdirempty: readi");
80106085:	c7 04 24 53 94 10 80 	movl   $0x80109453,(%esp)
8010608c:	e8 a9 a4 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80106091:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106095:	66 85 c0             	test   %ax,%ax
80106098:	74 07                	je     801060a1 <isdirempty+0x51>
      return 0;
8010609a:	b8 00 00 00 00       	mov    $0x0,%eax
8010609f:	eb 1b                	jmp    801060bc <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a4:	83 c0 10             	add    $0x10,%eax
801060a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060ad:	8b 45 08             	mov    0x8(%ebp),%eax
801060b0:	8b 40 18             	mov    0x18(%eax),%eax
801060b3:	39 c2                	cmp    %eax,%edx
801060b5:	72 a8                	jb     8010605f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801060b7:	b8 01 00 00 00       	mov    $0x1,%eax
}
801060bc:	c9                   	leave  
801060bd:	c3                   	ret    

801060be <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801060be:	55                   	push   %ebp
801060bf:	89 e5                	mov    %esp,%ebp
801060c1:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801060c4:	8d 45 cc             	lea    -0x34(%ebp),%eax
801060c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801060cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060d2:	e8 71 fa ff ff       	call   80105b48 <argstr>
801060d7:	85 c0                	test   %eax,%eax
801060d9:	79 0a                	jns    801060e5 <sys_unlink+0x27>
    return -1;
801060db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e0:	e9 af 01 00 00       	jmp    80106294 <sys_unlink+0x1d6>

  begin_op();
801060e5:	e8 26 d3 ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801060ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
801060ed:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801060f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801060f4:	89 04 24             	mov    %eax,(%esp)
801060f7:	e8 2c c3 ff ff       	call   80102428 <nameiparent>
801060fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106103:	75 0f                	jne    80106114 <sys_unlink+0x56>
    end_op();
80106105:	e8 8a d3 ff ff       	call   80103494 <end_op>
    return -1;
8010610a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610f:	e9 80 01 00 00       	jmp    80106294 <sys_unlink+0x1d6>
  }

  ilock(dp);
80106114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106117:	89 04 24             	mov    %eax,(%esp)
8010611a:	e8 3c b7 ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010611f:	c7 44 24 04 65 94 10 	movl   $0x80109465,0x4(%esp)
80106126:	80 
80106127:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010612a:	89 04 24             	mov    %eax,(%esp)
8010612d:	e8 29 bf ff ff       	call   8010205b <namecmp>
80106132:	85 c0                	test   %eax,%eax
80106134:	0f 84 45 01 00 00    	je     8010627f <sys_unlink+0x1c1>
8010613a:	c7 44 24 04 67 94 10 	movl   $0x80109467,0x4(%esp)
80106141:	80 
80106142:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106145:	89 04 24             	mov    %eax,(%esp)
80106148:	e8 0e bf ff ff       	call   8010205b <namecmp>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	0f 84 2a 01 00 00    	je     8010627f <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106155:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106158:	89 44 24 08          	mov    %eax,0x8(%esp)
8010615c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010615f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 0f bf ff ff       	call   8010207d <dirlookup>
8010616e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106171:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106175:	75 05                	jne    8010617c <sys_unlink+0xbe>
    goto bad;
80106177:	e9 03 01 00 00       	jmp    8010627f <sys_unlink+0x1c1>
  ilock(ip);
8010617c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617f:	89 04 24             	mov    %eax,(%esp)
80106182:	e8 d4 b6 ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80106187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010618e:	66 85 c0             	test   %ax,%ax
80106191:	7f 0c                	jg     8010619f <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80106193:	c7 04 24 6a 94 10 80 	movl   $0x8010946a,(%esp)
8010619a:	e8 9b a3 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010619f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061a6:	66 83 f8 01          	cmp    $0x1,%ax
801061aa:	75 1f                	jne    801061cb <sys_unlink+0x10d>
801061ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061af:	89 04 24             	mov    %eax,(%esp)
801061b2:	e8 99 fe ff ff       	call   80106050 <isdirempty>
801061b7:	85 c0                	test   %eax,%eax
801061b9:	75 10                	jne    801061cb <sys_unlink+0x10d>
    iunlockput(ip);
801061bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061be:	89 04 24             	mov    %eax,(%esp)
801061c1:	e8 19 b9 ff ff       	call   80101adf <iunlockput>
    goto bad;
801061c6:	e9 b4 00 00 00       	jmp    8010627f <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
801061cb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801061d2:	00 
801061d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061da:	00 
801061db:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061de:	89 04 24             	mov    %eax,(%esp)
801061e1:	e8 90 f5 ff ff       	call   80105776 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061e6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801061e9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801061f0:	00 
801061f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801061f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ff:	89 04 24             	mov    %eax,(%esp)
80106202:	e8 c5 bc ff ff       	call   80101ecc <writei>
80106207:	83 f8 10             	cmp    $0x10,%eax
8010620a:	74 0c                	je     80106218 <sys_unlink+0x15a>
    panic("unlink: writei");
8010620c:	c7 04 24 7c 94 10 80 	movl   $0x8010947c,(%esp)
80106213:	e8 22 a3 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010621f:	66 83 f8 01          	cmp    $0x1,%ax
80106223:	75 1c                	jne    80106241 <sys_unlink+0x183>
    dp->nlink--;
80106225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106228:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010622c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010622f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106232:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106239:	89 04 24             	mov    %eax,(%esp)
8010623c:	e8 5e b4 ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80106241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106244:	89 04 24             	mov    %eax,(%esp)
80106247:	e8 93 b8 ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
8010624c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106253:	8d 50 ff             	lea    -0x1(%eax),%edx
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010625d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106260:	89 04 24             	mov    %eax,(%esp)
80106263:	e8 37 b4 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80106268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626b:	89 04 24             	mov    %eax,(%esp)
8010626e:	e8 6c b8 ff ff       	call   80101adf <iunlockput>

  end_op();
80106273:	e8 1c d2 ff ff       	call   80103494 <end_op>

  return 0;
80106278:	b8 00 00 00 00       	mov    $0x0,%eax
8010627d:	eb 15                	jmp    80106294 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
8010627f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106282:	89 04 24             	mov    %eax,(%esp)
80106285:	e8 55 b8 ff ff       	call   80101adf <iunlockput>
  end_op();
8010628a:	e8 05 d2 ff ff       	call   80103494 <end_op>
  return -1;
8010628f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106294:	c9                   	leave  
80106295:	c3                   	ret    

80106296 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106296:	55                   	push   %ebp
80106297:	89 e5                	mov    %esp,%ebp
80106299:	83 ec 48             	sub    $0x48,%esp
8010629c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010629f:	8b 55 10             	mov    0x10(%ebp),%edx
801062a2:	8b 45 14             	mov    0x14(%ebp),%eax
801062a5:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801062a9:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801062ad:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801062b1:	8d 45 de             	lea    -0x22(%ebp),%eax
801062b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b8:	8b 45 08             	mov    0x8(%ebp),%eax
801062bb:	89 04 24             	mov    %eax,(%esp)
801062be:	e8 65 c1 ff ff       	call   80102428 <nameiparent>
801062c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ca:	75 0a                	jne    801062d6 <create+0x40>
    return 0;
801062cc:	b8 00 00 00 00       	mov    $0x0,%eax
801062d1:	e9 7e 01 00 00       	jmp    80106454 <create+0x1be>
  ilock(dp);
801062d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d9:	89 04 24             	mov    %eax,(%esp)
801062dc:	e8 7a b5 ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801062e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062e4:	89 44 24 08          	mov    %eax,0x8(%esp)
801062e8:	8d 45 de             	lea    -0x22(%ebp),%eax
801062eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f2:	89 04 24             	mov    %eax,(%esp)
801062f5:	e8 83 bd ff ff       	call   8010207d <dirlookup>
801062fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106301:	74 47                	je     8010634a <create+0xb4>
    iunlockput(dp);
80106303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106306:	89 04 24             	mov    %eax,(%esp)
80106309:	e8 d1 b7 ff ff       	call   80101adf <iunlockput>
    ilock(ip);
8010630e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106311:	89 04 24             	mov    %eax,(%esp)
80106314:	e8 42 b5 ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106319:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010631e:	75 15                	jne    80106335 <create+0x9f>
80106320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106323:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106327:	66 83 f8 02          	cmp    $0x2,%ax
8010632b:	75 08                	jne    80106335 <create+0x9f>
      return ip;
8010632d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106330:	e9 1f 01 00 00       	jmp    80106454 <create+0x1be>
    iunlockput(ip);
80106335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106338:	89 04 24             	mov    %eax,(%esp)
8010633b:	e8 9f b7 ff ff       	call   80101adf <iunlockput>
    return 0;
80106340:	b8 00 00 00 00       	mov    $0x0,%eax
80106345:	e9 0a 01 00 00       	jmp    80106454 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010634a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010634e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106351:	8b 00                	mov    (%eax),%eax
80106353:	89 54 24 04          	mov    %edx,0x4(%esp)
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 61 b2 ff ff       	call   801015c0 <ialloc>
8010635f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106366:	75 0c                	jne    80106374 <create+0xde>
    panic("create: ialloc");
80106368:	c7 04 24 8b 94 10 80 	movl   $0x8010948b,(%esp)
8010636f:	e8 c6 a1 ff ff       	call   8010053a <panic>

  ilock(ip);
80106374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106377:	89 04 24             	mov    %eax,(%esp)
8010637a:	e8 dc b4 ff ff       	call   8010185b <ilock>
  ip->major = major;
8010637f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106382:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106386:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010638a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106391:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106398:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	89 04 24             	mov    %eax,(%esp)
801063a4:	e8 f6 b2 ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801063a9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801063ae:	75 6a                	jne    8010641a <create+0x184>
    dp->nlink++;  // for ".."
801063b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801063b7:	8d 50 01             	lea    0x1(%eax),%edx
801063ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801063c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c4:	89 04 24             	mov    %eax,(%esp)
801063c7:	e8 d3 b2 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801063cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063cf:	8b 40 04             	mov    0x4(%eax),%eax
801063d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801063d6:	c7 44 24 04 65 94 10 	movl   $0x80109465,0x4(%esp)
801063dd:	80 
801063de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e1:	89 04 24             	mov    %eax,(%esp)
801063e4:	e8 5d bd ff ff       	call   80102146 <dirlink>
801063e9:	85 c0                	test   %eax,%eax
801063eb:	78 21                	js     8010640e <create+0x178>
801063ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f0:	8b 40 04             	mov    0x4(%eax),%eax
801063f3:	89 44 24 08          	mov    %eax,0x8(%esp)
801063f7:	c7 44 24 04 67 94 10 	movl   $0x80109467,0x4(%esp)
801063fe:	80 
801063ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106402:	89 04 24             	mov    %eax,(%esp)
80106405:	e8 3c bd ff ff       	call   80102146 <dirlink>
8010640a:	85 c0                	test   %eax,%eax
8010640c:	79 0c                	jns    8010641a <create+0x184>
      panic("create dots");
8010640e:	c7 04 24 9a 94 10 80 	movl   $0x8010949a,(%esp)
80106415:	e8 20 a1 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010641a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641d:	8b 40 04             	mov    0x4(%eax),%eax
80106420:	89 44 24 08          	mov    %eax,0x8(%esp)
80106424:	8d 45 de             	lea    -0x22(%ebp),%eax
80106427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010642b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642e:	89 04 24             	mov    %eax,(%esp)
80106431:	e8 10 bd ff ff       	call   80102146 <dirlink>
80106436:	85 c0                	test   %eax,%eax
80106438:	79 0c                	jns    80106446 <create+0x1b0>
    panic("create: dirlink");
8010643a:	c7 04 24 a6 94 10 80 	movl   $0x801094a6,(%esp)
80106441:	e8 f4 a0 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106449:	89 04 24             	mov    %eax,(%esp)
8010644c:	e8 8e b6 ff ff       	call   80101adf <iunlockput>

  return ip;
80106451:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106454:	c9                   	leave  
80106455:	c3                   	ret    

80106456 <sys_open>:

int
sys_open(void)
{
80106456:	55                   	push   %ebp
80106457:	89 e5                	mov    %esp,%ebp
80106459:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010645c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010645f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010646a:	e8 d9 f6 ff ff       	call   80105b48 <argstr>
8010646f:	85 c0                	test   %eax,%eax
80106471:	78 17                	js     8010648a <sys_open+0x34>
80106473:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106476:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106481:	e8 32 f6 ff ff       	call   80105ab8 <argint>
80106486:	85 c0                	test   %eax,%eax
80106488:	79 0a                	jns    80106494 <sys_open+0x3e>
    return -1;
8010648a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648f:	e9 5c 01 00 00       	jmp    801065f0 <sys_open+0x19a>

  begin_op();
80106494:	e8 77 cf ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
80106499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010649c:	25 00 02 00 00       	and    $0x200,%eax
801064a1:	85 c0                	test   %eax,%eax
801064a3:	74 3b                	je     801064e0 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801064a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801064af:	00 
801064b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064b7:	00 
801064b8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801064bf:	00 
801064c0:	89 04 24             	mov    %eax,(%esp)
801064c3:	e8 ce fd ff ff       	call   80106296 <create>
801064c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801064cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064cf:	75 6b                	jne    8010653c <sys_open+0xe6>
      end_op();
801064d1:	e8 be cf ff ff       	call   80103494 <end_op>
      return -1;
801064d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064db:	e9 10 01 00 00       	jmp    801065f0 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
801064e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064e3:	89 04 24             	mov    %eax,(%esp)
801064e6:	e8 1b bf ff ff       	call   80102406 <namei>
801064eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064f2:	75 0f                	jne    80106503 <sys_open+0xad>
      end_op();
801064f4:	e8 9b cf ff ff       	call   80103494 <end_op>
      return -1;
801064f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fe:	e9 ed 00 00 00       	jmp    801065f0 <sys_open+0x19a>
    }
    ilock(ip);
80106503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106506:	89 04 24             	mov    %eax,(%esp)
80106509:	e8 4d b3 ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010650e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106511:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106515:	66 83 f8 01          	cmp    $0x1,%ax
80106519:	75 21                	jne    8010653c <sys_open+0xe6>
8010651b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010651e:	85 c0                	test   %eax,%eax
80106520:	74 1a                	je     8010653c <sys_open+0xe6>
      iunlockput(ip);
80106522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106525:	89 04 24             	mov    %eax,(%esp)
80106528:	e8 b2 b5 ff ff       	call   80101adf <iunlockput>
      end_op();
8010652d:	e8 62 cf ff ff       	call   80103494 <end_op>
      return -1;
80106532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106537:	e9 b4 00 00 00       	jmp    801065f0 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010653c:	e8 e5 a9 ff ff       	call   80100f26 <filealloc>
80106541:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106544:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106548:	74 14                	je     8010655e <sys_open+0x108>
8010654a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654d:	89 04 24             	mov    %eax,(%esp)
80106550:	e8 2e f7 ff ff       	call   80105c83 <fdalloc>
80106555:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106558:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010655c:	79 28                	jns    80106586 <sys_open+0x130>
    if(f)
8010655e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106562:	74 0b                	je     8010656f <sys_open+0x119>
      fileclose(f);
80106564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106567:	89 04 24             	mov    %eax,(%esp)
8010656a:	e8 5f aa ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
8010656f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106572:	89 04 24             	mov    %eax,(%esp)
80106575:	e8 65 b5 ff ff       	call   80101adf <iunlockput>
    end_op();
8010657a:	e8 15 cf ff ff       	call   80103494 <end_op>
    return -1;
8010657f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106584:	eb 6a                	jmp    801065f0 <sys_open+0x19a>
  }
  iunlock(ip);
80106586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106589:	89 04 24             	mov    %eax,(%esp)
8010658c:	e8 18 b4 ff ff       	call   801019a9 <iunlock>
  end_op();
80106591:	e8 fe ce ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
80106596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106599:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010659f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801065a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ab:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801065b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b5:	83 e0 01             	and    $0x1,%eax
801065b8:	85 c0                	test   %eax,%eax
801065ba:	0f 94 c0             	sete   %al
801065bd:	89 c2                	mov    %eax,%edx
801065bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c2:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801065c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065c8:	83 e0 01             	and    $0x1,%eax
801065cb:	85 c0                	test   %eax,%eax
801065cd:	75 0a                	jne    801065d9 <sys_open+0x183>
801065cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065d2:	83 e0 02             	and    $0x2,%eax
801065d5:	85 c0                	test   %eax,%eax
801065d7:	74 07                	je     801065e0 <sys_open+0x18a>
801065d9:	b8 01 00 00 00       	mov    $0x1,%eax
801065de:	eb 05                	jmp    801065e5 <sys_open+0x18f>
801065e0:	b8 00 00 00 00       	mov    $0x0,%eax
801065e5:	89 c2                	mov    %eax,%edx
801065e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ea:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801065ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801065f0:	c9                   	leave  
801065f1:	c3                   	ret    

801065f2 <sys_mkdir>:

int
sys_mkdir(void)
{
801065f2:	55                   	push   %ebp
801065f3:	89 e5                	mov    %esp,%ebp
801065f5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065f8:	e8 13 ce ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801065fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106600:	89 44 24 04          	mov    %eax,0x4(%esp)
80106604:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010660b:	e8 38 f5 ff ff       	call   80105b48 <argstr>
80106610:	85 c0                	test   %eax,%eax
80106612:	78 2c                	js     80106640 <sys_mkdir+0x4e>
80106614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106617:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010661e:	00 
8010661f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106626:	00 
80106627:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010662e:	00 
8010662f:	89 04 24             	mov    %eax,(%esp)
80106632:	e8 5f fc ff ff       	call   80106296 <create>
80106637:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010663a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010663e:	75 0c                	jne    8010664c <sys_mkdir+0x5a>
    end_op();
80106640:	e8 4f ce ff ff       	call   80103494 <end_op>
    return -1;
80106645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664a:	eb 15                	jmp    80106661 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010664c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664f:	89 04 24             	mov    %eax,(%esp)
80106652:	e8 88 b4 ff ff       	call   80101adf <iunlockput>
  end_op();
80106657:	e8 38 ce ff ff       	call   80103494 <end_op>
  return 0;
8010665c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106661:	c9                   	leave  
80106662:	c3                   	ret    

80106663 <sys_mknod>:

int
sys_mknod(void)
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106669:	e8 a2 cd ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010666e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106671:	89 44 24 04          	mov    %eax,0x4(%esp)
80106675:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010667c:	e8 c7 f4 ff ff       	call   80105b48 <argstr>
80106681:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106688:	78 5e                	js     801066e8 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010668a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010668d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106691:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106698:	e8 1b f4 ff ff       	call   80105ab8 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010669d:	85 c0                	test   %eax,%eax
8010669f:	78 47                	js     801066e8 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801066a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801066af:	e8 04 f4 ff ff       	call   80105ab8 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801066b4:	85 c0                	test   %eax,%eax
801066b6:	78 30                	js     801066e8 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801066b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066bb:	0f bf c8             	movswl %ax,%ecx
801066be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066c1:	0f bf d0             	movswl %ax,%edx
801066c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801066c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801066cb:	89 54 24 08          	mov    %edx,0x8(%esp)
801066cf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801066d6:	00 
801066d7:	89 04 24             	mov    %eax,(%esp)
801066da:	e8 b7 fb ff ff       	call   80106296 <create>
801066df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066e6:	75 0c                	jne    801066f4 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801066e8:	e8 a7 cd ff ff       	call   80103494 <end_op>
    return -1;
801066ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f2:	eb 15                	jmp    80106709 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801066f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f7:	89 04 24             	mov    %eax,(%esp)
801066fa:	e8 e0 b3 ff ff       	call   80101adf <iunlockput>
  end_op();
801066ff:	e8 90 cd ff ff       	call   80103494 <end_op>
  return 0;
80106704:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106709:	c9                   	leave  
8010670a:	c3                   	ret    

8010670b <sys_chdir>:

int
sys_chdir(void)
{
8010670b:	55                   	push   %ebp
8010670c:	89 e5                	mov    %esp,%ebp
8010670e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106711:	e8 fa cc ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106716:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106719:	89 44 24 04          	mov    %eax,0x4(%esp)
8010671d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106724:	e8 1f f4 ff ff       	call   80105b48 <argstr>
80106729:	85 c0                	test   %eax,%eax
8010672b:	78 14                	js     80106741 <sys_chdir+0x36>
8010672d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106730:	89 04 24             	mov    %eax,(%esp)
80106733:	e8 ce bc ff ff       	call   80102406 <namei>
80106738:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010673f:	75 0c                	jne    8010674d <sys_chdir+0x42>
    end_op();
80106741:	e8 4e cd ff ff       	call   80103494 <end_op>
    return -1;
80106746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674b:	eb 61                	jmp    801067ae <sys_chdir+0xa3>
  }
  ilock(ip);
8010674d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106750:	89 04 24             	mov    %eax,(%esp)
80106753:	e8 03 b1 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
80106758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010675f:	66 83 f8 01          	cmp    $0x1,%ax
80106763:	74 17                	je     8010677c <sys_chdir+0x71>
    iunlockput(ip);
80106765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106768:	89 04 24             	mov    %eax,(%esp)
8010676b:	e8 6f b3 ff ff       	call   80101adf <iunlockput>
    end_op();
80106770:	e8 1f cd ff ff       	call   80103494 <end_op>
    return -1;
80106775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677a:	eb 32                	jmp    801067ae <sys_chdir+0xa3>
  }
  iunlock(ip);
8010677c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677f:	89 04 24             	mov    %eax,(%esp)
80106782:	e8 22 b2 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
80106787:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010678d:	8b 40 6c             	mov    0x6c(%eax),%eax
80106790:	89 04 24             	mov    %eax,(%esp)
80106793:	e8 76 b2 ff ff       	call   80101a0e <iput>
  end_op();
80106798:	e8 f7 cc ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
8010679d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067a6:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
801067a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067ae:	c9                   	leave  
801067af:	c3                   	ret    

801067b0 <sys_exec>:

int
sys_exec(void)
{
801067b0:	55                   	push   %ebp
801067b1:	89 e5                	mov    %esp,%ebp
801067b3:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801067b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801067c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c7:	e8 7c f3 ff ff       	call   80105b48 <argstr>
801067cc:	85 c0                	test   %eax,%eax
801067ce:	78 1a                	js     801067ea <sys_exec+0x3a>
801067d0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801067d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801067da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067e1:	e8 d2 f2 ff ff       	call   80105ab8 <argint>
801067e6:	85 c0                	test   %eax,%eax
801067e8:	79 0a                	jns    801067f4 <sys_exec+0x44>
    return -1;
801067ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ef:	e9 c8 00 00 00       	jmp    801068bc <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801067f4:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801067fb:	00 
801067fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106803:	00 
80106804:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010680a:	89 04 24             	mov    %eax,(%esp)
8010680d:	e8 64 ef ff ff       	call   80105776 <memset>
  for(i=0;; i++){
80106812:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681c:	83 f8 1f             	cmp    $0x1f,%eax
8010681f:	76 0a                	jbe    8010682b <sys_exec+0x7b>
      return -1;
80106821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106826:	e9 91 00 00 00       	jmp    801068bc <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010682b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682e:	c1 e0 02             	shl    $0x2,%eax
80106831:	89 c2                	mov    %eax,%edx
80106833:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106839:	01 c2                	add    %eax,%edx
8010683b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106841:	89 44 24 04          	mov    %eax,0x4(%esp)
80106845:	89 14 24             	mov    %edx,(%esp)
80106848:	e8 cf f1 ff ff       	call   80105a1c <fetchint>
8010684d:	85 c0                	test   %eax,%eax
8010684f:	79 07                	jns    80106858 <sys_exec+0xa8>
      return -1;
80106851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106856:	eb 64                	jmp    801068bc <sys_exec+0x10c>
    if(uarg == 0){
80106858:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010685e:	85 c0                	test   %eax,%eax
80106860:	75 26                	jne    80106888 <sys_exec+0xd8>
      argv[i] = 0;
80106862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106865:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010686c:	00 00 00 00 
      break;
80106870:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106874:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010687a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010687e:	89 04 24             	mov    %eax,(%esp)
80106881:	e8 69 a2 ff ff       	call   80100aef <exec>
80106886:	eb 34                	jmp    801068bc <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106888:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010688e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106891:	c1 e2 02             	shl    $0x2,%edx
80106894:	01 c2                	add    %eax,%edx
80106896:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010689c:	89 54 24 04          	mov    %edx,0x4(%esp)
801068a0:	89 04 24             	mov    %eax,(%esp)
801068a3:	e8 ae f1 ff ff       	call   80105a56 <fetchstr>
801068a8:	85 c0                	test   %eax,%eax
801068aa:	79 07                	jns    801068b3 <sys_exec+0x103>
      return -1;
801068ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b1:	eb 09                	jmp    801068bc <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801068b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801068b7:	e9 5d ff ff ff       	jmp    80106819 <sys_exec+0x69>
  return exec(path, argv);
}
801068bc:	c9                   	leave  
801068bd:	c3                   	ret    

801068be <sys_pipe>:

int
sys_pipe(void)
{
801068be:	55                   	push   %ebp
801068bf:	89 e5                	mov    %esp,%ebp
801068c1:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801068c4:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801068cb:	00 
801068cc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068da:	e8 07 f2 ff ff       	call   80105ae6 <argptr>
801068df:	85 c0                	test   %eax,%eax
801068e1:	79 0a                	jns    801068ed <sys_pipe+0x2f>
    return -1;
801068e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e8:	e9 9b 00 00 00       	jmp    80106988 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801068ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801068f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801068f4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068f7:	89 04 24             	mov    %eax,(%esp)
801068fa:	e8 22 d6 ff ff       	call   80103f21 <pipealloc>
801068ff:	85 c0                	test   %eax,%eax
80106901:	79 07                	jns    8010690a <sys_pipe+0x4c>
    return -1;
80106903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106908:	eb 7e                	jmp    80106988 <sys_pipe+0xca>
  fd0 = -1;
8010690a:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106911:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106914:	89 04 24             	mov    %eax,(%esp)
80106917:	e8 67 f3 ff ff       	call   80105c83 <fdalloc>
8010691c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010691f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106923:	78 14                	js     80106939 <sys_pipe+0x7b>
80106925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106928:	89 04 24             	mov    %eax,(%esp)
8010692b:	e8 53 f3 ff ff       	call   80105c83 <fdalloc>
80106930:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106933:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106937:	79 37                	jns    80106970 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106939:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010693d:	78 14                	js     80106953 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010693f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106945:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106948:	83 c2 08             	add    $0x8,%edx
8010694b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80106952:	00 
    fileclose(rf);
80106953:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106956:	89 04 24             	mov    %eax,(%esp)
80106959:	e8 70 a6 ff ff       	call   80100fce <fileclose>
    fileclose(wf);
8010695e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106961:	89 04 24             	mov    %eax,(%esp)
80106964:	e8 65 a6 ff ff       	call   80100fce <fileclose>
    return -1;
80106969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010696e:	eb 18                	jmp    80106988 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106970:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106973:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106976:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106978:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010697b:	8d 50 04             	lea    0x4(%eax),%edx
8010697e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106981:	89 02                	mov    %eax,(%edx)
  return 0;
80106983:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106988:	c9                   	leave  
80106989:	c3                   	ret    

8010698a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010698a:	55                   	push   %ebp
8010698b:	89 e5                	mov    %esp,%ebp
8010698d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106990:	e8 87 df ff ff       	call   8010491c <fork>
}
80106995:	c9                   	leave  
80106996:	c3                   	ret    

80106997 <sys_exit>:

int
sys_exit(void)
{
80106997:	55                   	push   %ebp
80106998:	89 e5                	mov    %esp,%ebp
8010699a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010699d:	e8 76 e1 ff ff       	call   80104b18 <exit>
  return 0;  // not reached
801069a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069a7:	c9                   	leave  
801069a8:	c3                   	ret    

801069a9 <sys_wait>:

int
sys_wait(void)
{
801069a9:	55                   	push   %ebp
801069aa:	89 e5                	mov    %esp,%ebp
801069ac:	83 ec 08             	sub    $0x8,%esp
  return wait();
801069af:	e8 b3 e2 ff ff       	call   80104c67 <wait>
}
801069b4:	c9                   	leave  
801069b5:	c3                   	ret    

801069b6 <sys_kill>:

int
sys_kill(void)
{
801069b6:	55                   	push   %ebp
801069b7:	89 e5                	mov    %esp,%ebp
801069b9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801069bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069ca:	e8 e9 f0 ff ff       	call   80105ab8 <argint>
801069cf:	85 c0                	test   %eax,%eax
801069d1:	79 07                	jns    801069da <sys_kill+0x24>
    return -1;
801069d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d8:	eb 0b                	jmp    801069e5 <sys_kill+0x2f>
  return kill(pid);
801069da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069dd:	89 04 24             	mov    %eax,(%esp)
801069e0:	e8 8d e6 ff ff       	call   80105072 <kill>
}
801069e5:	c9                   	leave  
801069e6:	c3                   	ret    

801069e7 <sys_getpid>:

int
sys_getpid(void)
{
801069e7:	55                   	push   %ebp
801069e8:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801069ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069f0:	8b 40 10             	mov    0x10(%eax),%eax
}
801069f3:	5d                   	pop    %ebp
801069f4:	c3                   	ret    

801069f5 <sys_sbrk>:

int
sys_sbrk(void)
{
801069f5:	55                   	push   %ebp
801069f6:	89 e5                	mov    %esp,%ebp
801069f8:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801069fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a09:	e8 aa f0 ff ff       	call   80105ab8 <argint>
80106a0e:	85 c0                	test   %eax,%eax
80106a10:	79 07                	jns    80106a19 <sys_sbrk+0x24>
    return -1;
80106a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a17:	eb 24                	jmp    80106a3d <sys_sbrk+0x48>
  addr = proc->sz;
80106a19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a1f:	8b 00                	mov    (%eax),%eax
80106a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a27:	89 04 24             	mov    %eax,(%esp)
80106a2a:	e8 48 de ff ff       	call   80104877 <growproc>
80106a2f:	85 c0                	test   %eax,%eax
80106a31:	79 07                	jns    80106a3a <sys_sbrk+0x45>
    return -1;
80106a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a38:	eb 03                	jmp    80106a3d <sys_sbrk+0x48>
  return addr;
80106a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a3d:	c9                   	leave  
80106a3e:	c3                   	ret    

80106a3f <sys_sleep>:

int
sys_sleep(void)
{
80106a3f:	55                   	push   %ebp
80106a40:	89 e5                	mov    %esp,%ebp
80106a42:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106a45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a53:	e8 60 f0 ff ff       	call   80105ab8 <argint>
80106a58:	85 c0                	test   %eax,%eax
80106a5a:	79 07                	jns    80106a63 <sys_sleep+0x24>
    return -1;
80106a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a61:	eb 6c                	jmp    80106acf <sys_sleep+0x90>
  acquire(&tickslock);
80106a63:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106a6a:	e8 b3 ea ff ff       	call   80105522 <acquire>
  ticks0 = ticks;
80106a6f:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106a77:	eb 34                	jmp    80106aad <sys_sleep+0x6e>
    if(proc->killed){
80106a79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a7f:	8b 40 28             	mov    0x28(%eax),%eax
80106a82:	85 c0                	test   %eax,%eax
80106a84:	74 13                	je     80106a99 <sys_sleep+0x5a>
      release(&tickslock);
80106a86:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106a8d:	e8 f2 ea ff ff       	call   80105584 <release>
      return -1;
80106a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a97:	eb 36                	jmp    80106acf <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106a99:	c7 44 24 04 00 87 11 	movl   $0x80118700,0x4(%esp)
80106aa0:	80 
80106aa1:	c7 04 24 40 8f 11 80 	movl   $0x80118f40,(%esp)
80106aa8:	e8 b3 e4 ff ff       	call   80104f60 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106aad:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106ab2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106ab5:	89 c2                	mov    %eax,%edx
80106ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aba:	39 c2                	cmp    %eax,%edx
80106abc:	72 bb                	jb     80106a79 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106abe:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106ac5:	e8 ba ea ff ff       	call   80105584 <release>
  return 0;
80106aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106acf:	c9                   	leave  
80106ad0:	c3                   	ret    

80106ad1 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106ad1:	55                   	push   %ebp
80106ad2:	89 e5                	mov    %esp,%ebp
80106ad4:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106ad7:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106ade:	e8 3f ea ff ff       	call   80105522 <acquire>
  xticks = ticks;
80106ae3:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106ae8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106aeb:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106af2:	e8 8d ea ff ff       	call   80105584 <release>
  return xticks;
80106af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106afa:	c9                   	leave  
80106afb:	c3                   	ret    

80106afc <sys_signal>:

int
sys_signal(void)
{
80106afc:	55                   	push   %ebp
80106afd:	89 e5                	mov    %esp,%ebp
80106aff:	53                   	push   %ebx
80106b00:	83 ec 24             	sub    $0x24,%esp
	int signum;
	int handler;

	if ( (argint(0, &signum) < 0) | (argint(1, &handler) < 0) )
80106b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b06:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b11:	e8 a2 ef ff ff       	call   80105ab8 <argint>
80106b16:	c1 e8 1f             	shr    $0x1f,%eax
80106b19:	89 c3                	mov    %eax,%ebx
80106b1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b29:	e8 8a ef ff ff       	call   80105ab8 <argint>
80106b2e:	c1 e8 1f             	shr    $0x1f,%eax
80106b31:	09 d8                	or     %ebx,%eax
80106b33:	84 c0                	test   %al,%al
80106b35:	74 07                	je     80106b3e <sys_signal+0x42>
		return -1;
80106b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b3c:	eb 14                	jmp    80106b52 <sys_signal+0x56>
	return signal(signum, (sighandler_t)handler);
80106b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b41:	89 c2                	mov    %eax,%edx
80106b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b46:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b4a:	89 04 24             	mov    %eax,(%esp)
80106b4d:	e8 a0 e6 ff ff       	call   801051f2 <signal>
}
80106b52:	83 c4 24             	add    $0x24,%esp
80106b55:	5b                   	pop    %ebx
80106b56:	5d                   	pop    %ebp
80106b57:	c3                   	ret    

80106b58 <sys_sigsend>:

int
sys_sigsend(void)
{
80106b58:	55                   	push   %ebp
80106b59:	89 e5                	mov    %esp,%ebp
80106b5b:	53                   	push   %ebx
80106b5c:	83 ec 24             	sub    $0x24,%esp
	int pid;
	int signum;

	if ( (argint(0, &pid) < 0) | (argint(1, &signum) < 0) )
80106b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b62:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b6d:	e8 46 ef ff ff       	call   80105ab8 <argint>
80106b72:	c1 e8 1f             	shr    $0x1f,%eax
80106b75:	89 c3                	mov    %eax,%ebx
80106b77:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b85:	e8 2e ef ff ff       	call   80105ab8 <argint>
80106b8a:	c1 e8 1f             	shr    $0x1f,%eax
80106b8d:	09 d8                	or     %ebx,%eax
80106b8f:	84 c0                	test   %al,%al
80106b91:	74 07                	je     80106b9a <sys_sigsend+0x42>
		return -1;
80106b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b98:	eb 12                	jmp    80106bac <sys_sigsend+0x54>
	return sigsend(pid, signum);
80106b9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba0:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ba4:	89 04 24             	mov    %eax,(%esp)
80106ba7:	e8 8a e6 ff ff       	call   80105236 <sigsend>
}
80106bac:	83 c4 24             	add    $0x24,%esp
80106baf:	5b                   	pop    %ebx
80106bb0:	5d                   	pop    %ebp
80106bb1:	c3                   	ret    

80106bb2 <sys_sigreturn>:

void copytf(struct trapframe *, struct trapframe *);

int
sys_sigreturn(void)
{
80106bb2:	55                   	push   %ebp
80106bb3:	89 e5                	mov    %esp,%ebp
80106bb5:	83 ec 18             	sub    $0x18,%esp
	//cprintf("sys_sigreturn for %d\n", proc->pid);
	copytf(proc->backuptf, proc->tf);	
80106bb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bbe:	8b 50 18             	mov    0x18(%eax),%edx
80106bc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc7:	8b 40 1c             	mov    0x1c(%eax),%eax
80106bca:	89 54 24 04          	mov    %edx,0x4(%esp)
80106bce:	89 04 24             	mov    %eax,(%esp)
80106bd1:	e8 44 03 00 00       	call   80106f1a <copytf>
	proc->insignal=0;
80106bd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bdc:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80106be3:	00 00 00 
	return 0;
80106be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106beb:	c9                   	leave  
80106bec:	c3                   	ret    

80106bed <sys_advanceprocstats>:

int
sys_advanceprocstats(void) {
80106bed:	55                   	push   %ebp
80106bee:	89 e5                	mov    %esp,%ebp
80106bf0:	83 ec 08             	sub    $0x8,%esp
       advanceprocstats();
80106bf3:	e8 ed e6 ff ff       	call   801052e5 <advanceprocstats>
       return 0;
80106bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bfd:	c9                   	leave  
80106bfe:	c3                   	ret    

80106bff <sys_wait_stat>:

int
sys_wait_stat(void)
{
80106bff:	55                   	push   %ebp
80106c00:	89 e5                	mov    %esp,%ebp
80106c02:	83 ec 28             	sub    $0x28,%esp
      // struct perf *perfP=0;
	   int perfP = 0;
80106c05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
       //cprintf("sys_wait_stat \n");
       //if(argptr(0, (char**)&perfP, 32) < 0)
       if(argint(0,&perfP) < 0)
80106c0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c1a:	e8 99 ee ff ff       	call   80105ab8 <argint>
80106c1f:	85 c0                	test   %eax,%eax
80106c21:	79 07                	jns    80106c2a <sys_wait_stat+0x2b>
               return -1;
80106c23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c28:	eb 0b                	jmp    80106c35 <sys_wait_stat+0x36>
       return  wait_stat((struct perf *)perfP);
80106c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2d:	89 04 24             	mov    %eax,(%esp)
80106c30:	e8 36 e7 ff ff       	call   8010536b <wait_stat>
       //return  wait_stat((struct perf *)perfP);
}
80106c35:	c9                   	leave  
80106c36:	c3                   	ret    

80106c37 <sys_priority>:

int
sys_priority(void)
{
80106c37:	55                   	push   %ebp
80106c38:	89 e5                	mov    %esp,%ebp
80106c3a:	83 ec 28             	sub    $0x28,%esp
      int priority = 0;
80106c3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      if(argint(0, &priority) < 0)
80106c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c52:	e8 61 ee ff ff       	call   80105ab8 <argint>
80106c57:	85 c0                	test   %eax,%eax
80106c59:	79 07                	jns    80106c62 <sys_priority+0x2b>
	  return -1;
80106c5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c60:	eb 14                	jmp    80106c76 <sys_priority+0x3f>
      proc->priority = priority;
80106c62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c6b:	89 90 20 01 00 00    	mov    %edx,0x120(%eax)
      return 0;
80106c71:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c76:	c9                   	leave  
80106c77:	c3                   	ret    

80106c78 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c78:	55                   	push   %ebp
80106c79:	89 e5                	mov    %esp,%ebp
80106c7b:	83 ec 08             	sub    $0x8,%esp
80106c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80106c81:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c84:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c88:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c8b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c8f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c93:	ee                   	out    %al,(%dx)
}
80106c94:	c9                   	leave  
80106c95:	c3                   	ret    

80106c96 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106c96:	55                   	push   %ebp
80106c97:	89 e5                	mov    %esp,%ebp
80106c99:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106c9c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106ca3:	00 
80106ca4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106cab:	e8 c8 ff ff ff       	call   80106c78 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106cb0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106cb7:	00 
80106cb8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106cbf:	e8 b4 ff ff ff       	call   80106c78 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106cc4:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106ccb:	00 
80106ccc:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106cd3:	e8 a0 ff ff ff       	call   80106c78 <outb>
  picenable(IRQ_TIMER);
80106cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cdf:	e8 d0 d0 ff ff       	call   80103db4 <picenable>
}
80106ce4:	c9                   	leave  
80106ce5:	c3                   	ret    

80106ce6 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ce6:	1e                   	push   %ds
  pushl %es
80106ce7:	06                   	push   %es
  pushl %fs
80106ce8:	0f a0                	push   %fs
  pushl %gs
80106cea:	0f a8                	push   %gs
  pushal
80106cec:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106ced:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106cf1:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106cf3:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106cf5:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106cf9:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106cfb:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106cfd:	54                   	push   %esp
  call trap
80106cfe:	e8 4f 05 00 00       	call   80107252 <trap>
  call handleSignals
80106d03:	e8 d1 03 00 00       	call   801070d9 <handleSignals>
  addl $4, %esp
80106d08:	83 c4 04             	add    $0x4,%esp

80106d0b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106d0b:	61                   	popa   
  popl %gs
80106d0c:	0f a9                	pop    %gs
  popl %fs
80106d0e:	0f a1                	pop    %fs
  popl %es
80106d10:	07                   	pop    %es
  popl %ds
80106d11:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106d12:	83 c4 08             	add    $0x8,%esp
  iret
80106d15:	cf                   	iret   

80106d16 <implicit_sigret>:

# new func - implicit_sigret

implicit_sigret:
  pushl %eax
80106d16:	50                   	push   %eax
  movl $SYS_sigreturn, %eax
80106d17:	b8 1a 00 00 00       	mov    $0x1a,%eax
  int $T_SYSCALL
80106d1c:	cd 40                	int    $0x40

80106d1e <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106d1e:	55                   	push   %ebp
80106d1f:	89 e5                	mov    %esp,%ebp
80106d21:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d27:	83 e8 01             	sub    $0x1,%eax
80106d2a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d31:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106d35:	8b 45 08             	mov    0x8(%ebp),%eax
80106d38:	c1 e8 10             	shr    $0x10,%eax
80106d3b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106d3f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106d42:	0f 01 18             	lidtl  (%eax)
}
80106d45:	c9                   	leave  
80106d46:	c3                   	ret    

80106d47 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106d47:	55                   	push   %ebp
80106d48:	89 e5                	mov    %esp,%ebp
80106d4a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106d4d:	0f 20 d0             	mov    %cr2,%eax
80106d50:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d56:	c9                   	leave  
80106d57:	c3                   	ret    

80106d58 <tvinit>:
extern int implicit_sigret();
extern int end_of_sigret();

void
tvinit(void)
{
80106d58:	55                   	push   %ebp
80106d59:	89 e5                	mov    %esp,%ebp
80106d5b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106d5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d65:	e9 c3 00 00 00       	jmp    80106e2d <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6d:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106d74:	89 c2                	mov    %eax,%edx
80106d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d79:	66 89 14 c5 40 87 11 	mov    %dx,-0x7fee78c0(,%eax,8)
80106d80:	80 
80106d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d84:	66 c7 04 c5 42 87 11 	movw   $0x8,-0x7fee78be(,%eax,8)
80106d8b:	80 08 00 
80106d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d91:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106d98:	80 
80106d99:	83 e2 e0             	and    $0xffffffe0,%edx
80106d9c:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106da6:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106dad:	80 
80106dae:	83 e2 1f             	and    $0x1f,%edx
80106db1:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dbb:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106dc2:	80 
80106dc3:	83 e2 f0             	and    $0xfffffff0,%edx
80106dc6:	83 ca 0e             	or     $0xe,%edx
80106dc9:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd3:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106dda:	80 
80106ddb:	83 e2 ef             	and    $0xffffffef,%edx
80106dde:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106de8:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106def:	80 
80106df0:	83 e2 9f             	and    $0xffffff9f,%edx
80106df3:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dfd:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106e04:	80 
80106e05:	83 ca 80             	or     $0xffffff80,%edx
80106e08:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e12:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106e19:	c1 e8 10             	shr    $0x10,%eax
80106e1c:	89 c2                	mov    %eax,%edx
80106e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e21:	66 89 14 c5 46 87 11 	mov    %dx,-0x7fee78ba(,%eax,8)
80106e28:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106e29:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e2d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106e34:	0f 8e 30 ff ff ff    	jle    80106d6a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106e3a:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106e3f:	66 a3 40 89 11 80    	mov    %ax,0x80118940
80106e45:	66 c7 05 42 89 11 80 	movw   $0x8,0x80118942
80106e4c:	08 00 
80106e4e:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106e55:	83 e0 e0             	and    $0xffffffe0,%eax
80106e58:	a2 44 89 11 80       	mov    %al,0x80118944
80106e5d:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106e64:	83 e0 1f             	and    $0x1f,%eax
80106e67:	a2 44 89 11 80       	mov    %al,0x80118944
80106e6c:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e73:	83 c8 0f             	or     $0xf,%eax
80106e76:	a2 45 89 11 80       	mov    %al,0x80118945
80106e7b:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e82:	83 e0 ef             	and    $0xffffffef,%eax
80106e85:	a2 45 89 11 80       	mov    %al,0x80118945
80106e8a:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e91:	83 c8 60             	or     $0x60,%eax
80106e94:	a2 45 89 11 80       	mov    %al,0x80118945
80106e99:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106ea0:	83 c8 80             	or     $0xffffff80,%eax
80106ea3:	a2 45 89 11 80       	mov    %al,0x80118945
80106ea8:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106ead:	c1 e8 10             	shr    $0x10,%eax
80106eb0:	66 a3 46 89 11 80    	mov    %ax,0x80118946
  
  initlock(&tickslock, "time");
80106eb6:	c7 44 24 04 b8 94 10 	movl   $0x801094b8,0x4(%esp)
80106ebd:	80 
80106ebe:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106ec5:	e8 37 e6 ff ff       	call   80105501 <initlock>
}
80106eca:	c9                   	leave  
80106ecb:	c3                   	ret    

80106ecc <idtinit>:

void
idtinit(void)
{
80106ecc:	55                   	push   %ebp
80106ecd:	89 e5                	mov    %esp,%ebp
80106ecf:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ed2:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106ed9:	00 
80106eda:	c7 04 24 40 87 11 80 	movl   $0x80118740,(%esp)
80106ee1:	e8 38 fe ff ff       	call   80106d1e <lidt>
}
80106ee6:	c9                   	leave  
80106ee7:	c3                   	ret    

80106ee8 <getLowestSetBit>:

/**
 * Gets an integer, and returns the number of the lowest bit which is set to 1
**/
int 
getLowestSetBit(int num) {
80106ee8:	55                   	push   %ebp
80106ee9:	89 e5                	mov    %esp,%ebp
80106eeb:	83 ec 10             	sub    $0x10,%esp
    if (num == 0)
80106eee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106ef2:	75 07                	jne    80106efb <getLowestSetBit+0x13>
	return -1;
80106ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef9:	eb 1d                	jmp    80106f18 <getLowestSetBit+0x30>
    
    int bitNum = 0;
80106efb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while ((num & 1) == 0) {
80106f02:	eb 07                	jmp    80106f0b <getLowestSetBit+0x23>
	num = num >> 1;
80106f04:	d1 7d 08             	sarl   0x8(%ebp)
	bitNum++;
80106f07:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
getLowestSetBit(int num) {
    if (num == 0)
	return -1;
    
    int bitNum = 0;
    while ((num & 1) == 0) {
80106f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0e:	83 e0 01             	and    $0x1,%eax
80106f11:	85 c0                	test   %eax,%eax
80106f13:	74 ef                	je     80106f04 <getLowestSetBit+0x1c>
	num = num >> 1;
	bitNum++;
    }
    return bitNum;
80106f15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f18:	c9                   	leave  
80106f19:	c3                   	ret    

80106f1a <copytf>:

void
copytf(struct trapframe * tf, struct trapframe * copyaddr) {
80106f1a:	55                   	push   %ebp
80106f1b:	89 e5                	mov    %esp,%ebp
    copyaddr->edi = tf->edi;
80106f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f20:	8b 10                	mov    (%eax),%edx
80106f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f25:	89 10                	mov    %edx,(%eax)
    copyaddr->esi = tf->esi;
80106f27:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2a:	8b 50 04             	mov    0x4(%eax),%edx
80106f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f30:	89 50 04             	mov    %edx,0x4(%eax)
    copyaddr->ebp = tf->ebp;
80106f33:	8b 45 08             	mov    0x8(%ebp),%eax
80106f36:	8b 50 08             	mov    0x8(%eax),%edx
80106f39:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f3c:	89 50 08             	mov    %edx,0x8(%eax)
    copyaddr->oesp = tf->oesp;
80106f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f42:	8b 50 0c             	mov    0xc(%eax),%edx
80106f45:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f48:	89 50 0c             	mov    %edx,0xc(%eax)
    copyaddr->ebx = tf->ebx;
80106f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4e:	8b 50 10             	mov    0x10(%eax),%edx
80106f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f54:	89 50 10             	mov    %edx,0x10(%eax)
    copyaddr->edx = tf->edx;
80106f57:	8b 45 08             	mov    0x8(%ebp),%eax
80106f5a:	8b 50 14             	mov    0x14(%eax),%edx
80106f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f60:	89 50 14             	mov    %edx,0x14(%eax)
    copyaddr->ecx = tf->ecx;
80106f63:	8b 45 08             	mov    0x8(%ebp),%eax
80106f66:	8b 50 18             	mov    0x18(%eax),%edx
80106f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f6c:	89 50 18             	mov    %edx,0x18(%eax)
    copyaddr->eax = tf->eax;
80106f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80106f72:	8b 50 1c             	mov    0x1c(%eax),%edx
80106f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f78:	89 50 1c             	mov    %edx,0x1c(%eax)
    copyaddr->gs = tf->gs;
80106f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7e:	0f b7 50 20          	movzwl 0x20(%eax),%edx
80106f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f85:	66 89 50 20          	mov    %dx,0x20(%eax)
    copyaddr->padding1 = tf->padding1;
80106f89:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8c:	0f b7 50 22          	movzwl 0x22(%eax),%edx
80106f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f93:	66 89 50 22          	mov    %dx,0x22(%eax)
    copyaddr->fs = tf->fs;
80106f97:	8b 45 08             	mov    0x8(%ebp),%eax
80106f9a:	0f b7 50 24          	movzwl 0x24(%eax),%edx
80106f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fa1:	66 89 50 24          	mov    %dx,0x24(%eax)
    copyaddr->padding2 = tf->padding2;
80106fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80106fa8:	0f b7 50 26          	movzwl 0x26(%eax),%edx
80106fac:	8b 45 0c             	mov    0xc(%ebp),%eax
80106faf:	66 89 50 26          	mov    %dx,0x26(%eax)
    copyaddr->es = tf->es;
80106fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb6:	0f b7 50 28          	movzwl 0x28(%eax),%edx
80106fba:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fbd:	66 89 50 28          	mov    %dx,0x28(%eax)
    copyaddr->padding3 = tf->padding3;
80106fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80106fc4:	0f b7 50 2a          	movzwl 0x2a(%eax),%edx
80106fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fcb:	66 89 50 2a          	mov    %dx,0x2a(%eax)
    copyaddr->ds = tf->ds;
80106fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd2:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80106fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fd9:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    copyaddr->padding4 = tf->padding4;
80106fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106fe0:	0f b7 50 2e          	movzwl 0x2e(%eax),%edx
80106fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fe7:	66 89 50 2e          	mov    %dx,0x2e(%eax)
    copyaddr->trapno = tf->trapno;
80106feb:	8b 45 08             	mov    0x8(%ebp),%eax
80106fee:	8b 50 30             	mov    0x30(%eax),%edx
80106ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ff4:	89 50 30             	mov    %edx,0x30(%eax)
    copyaddr->err = tf->err;
80106ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80106ffa:	8b 50 34             	mov    0x34(%eax),%edx
80106ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107000:	89 50 34             	mov    %edx,0x34(%eax)
    copyaddr->eip = tf->eip;
80107003:	8b 45 08             	mov    0x8(%ebp),%eax
80107006:	8b 50 38             	mov    0x38(%eax),%edx
80107009:	8b 45 0c             	mov    0xc(%ebp),%eax
8010700c:	89 50 38             	mov    %edx,0x38(%eax)
    copyaddr->cs = tf->cs;
8010700f:	8b 45 08             	mov    0x8(%ebp),%eax
80107012:	0f b7 50 3c          	movzwl 0x3c(%eax),%edx
80107016:	8b 45 0c             	mov    0xc(%ebp),%eax
80107019:	66 89 50 3c          	mov    %dx,0x3c(%eax)
    copyaddr->padding5 = tf->padding5;
8010701d:	8b 45 08             	mov    0x8(%ebp),%eax
80107020:	0f b7 50 3e          	movzwl 0x3e(%eax),%edx
80107024:	8b 45 0c             	mov    0xc(%ebp),%eax
80107027:	66 89 50 3e          	mov    %dx,0x3e(%eax)
    copyaddr->eflags = tf->eflags;
8010702b:	8b 45 08             	mov    0x8(%ebp),%eax
8010702e:	8b 50 40             	mov    0x40(%eax),%edx
80107031:	8b 45 0c             	mov    0xc(%ebp),%eax
80107034:	89 50 40             	mov    %edx,0x40(%eax)
    copyaddr->esp = tf->esp;
80107037:	8b 45 08             	mov    0x8(%ebp),%eax
8010703a:	8b 50 44             	mov    0x44(%eax),%edx
8010703d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107040:	89 50 44             	mov    %edx,0x44(%eax)
    copyaddr->ss = tf->ss;
80107043:	8b 45 08             	mov    0x8(%ebp),%eax
80107046:	0f b7 50 48          	movzwl 0x48(%eax),%edx
8010704a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010704d:	66 89 50 48          	mov    %dx,0x48(%eax)
    copyaddr->padding6 = tf->padding6;
80107051:	8b 45 08             	mov    0x8(%ebp),%eax
80107054:	0f b7 50 4a          	movzwl 0x4a(%eax),%edx
80107058:	8b 45 0c             	mov    0xc(%ebp),%eax
8010705b:	66 89 50 4a          	mov    %dx,0x4a(%eax)
    return;
8010705f:	90                   	nop
}
80107060:	5d                   	pop    %ebp
80107061:	c3                   	ret    

80107062 <int2bin>:


char *int2bin(int a)
{
80107062:	55                   	push   %ebp
80107063:	89 e5                	mov    %esp,%ebp
80107065:	83 ec 18             	sub    $0x18,%esp
 char *str,*tmp;
 int cnt = 31;
80107068:	c7 45 f4 1f 00 00 00 	movl   $0x1f,-0xc(%ebp)
 str = (char *) kalloc(); /*32 + 1 , because its a 32 bit bin number*/
8010706f:	e8 6e ba ff ff       	call   80102ae2 <kalloc>
80107074:	89 45 f0             	mov    %eax,-0x10(%ebp)
 tmp = str;
80107077:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010707a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 while ( cnt > -1 ){
8010707d:	eb 0f                	jmp    8010708e <int2bin+0x2c>
      str[cnt]= '0';
8010707f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107082:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107085:	01 d0                	add    %edx,%eax
80107087:	c6 00 30             	movb   $0x30,(%eax)
      cnt --;
8010708a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
{
 char *str,*tmp;
 int cnt = 31;
 str = (char *) kalloc(); /*32 + 1 , because its a 32 bit bin number*/
 tmp = str;
 while ( cnt > -1 ){
8010708e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107092:	79 eb                	jns    8010707f <int2bin+0x1d>
      str[cnt]= '0';
      cnt --;
 }
 cnt = 31;
80107094:	c7 45 f4 1f 00 00 00 	movl   $0x1f,-0xc(%ebp)
 while (a > 0){
8010709b:	eb 31                	jmp    801070ce <int2bin+0x6c>
       if (a%2==1){
8010709d:	8b 45 08             	mov    0x8(%ebp),%eax
801070a0:	99                   	cltd   
801070a1:	c1 ea 1f             	shr    $0x1f,%edx
801070a4:	01 d0                	add    %edx,%eax
801070a6:	83 e0 01             	and    $0x1,%eax
801070a9:	29 d0                	sub    %edx,%eax
801070ab:	83 f8 01             	cmp    $0x1,%eax
801070ae:	75 0b                	jne    801070bb <int2bin+0x59>
           str[cnt] = '1';
801070b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070b6:	01 d0                	add    %edx,%eax
801070b8:	c6 00 31             	movb   $0x31,(%eax)
        }
      cnt--;
801070bb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
        a = a/2 ;
801070bf:	8b 45 08             	mov    0x8(%ebp),%eax
801070c2:	89 c2                	mov    %eax,%edx
801070c4:	c1 ea 1f             	shr    $0x1f,%edx
801070c7:	01 d0                	add    %edx,%eax
801070c9:	d1 f8                	sar    %eax
801070cb:	89 45 08             	mov    %eax,0x8(%ebp)
 while ( cnt > -1 ){
      str[cnt]= '0';
      cnt --;
 }
 cnt = 31;
 while (a > 0){
801070ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801070d2:	7f c9                	jg     8010709d <int2bin+0x3b>
           str[cnt] = '1';
        }
      cnt--;
        a = a/2 ;
 }
 return tmp;
801070d4:	8b 45 ec             	mov    -0x14(%ebp),%eax

}
801070d7:	c9                   	leave  
801070d8:	c3                   	ret    

801070d9 <handleSignals>:

void
handleSignals(struct trapframe *tf) {      
801070d9:	55                   	push   %ebp
801070da:	89 e5                	mov    %esp,%ebp
801070dc:	56                   	push   %esi
801070dd:	53                   	push   %ebx
801070de:	83 ec 30             	sub    $0x30,%esp
    if(tf->trapno == T_SYSCALL && proc->pending > 0 && proc->insignal == 0) {      
801070e1:	8b 45 08             	mov    0x8(%ebp),%eax
801070e4:	8b 40 30             	mov    0x30(%eax),%eax
801070e7:	83 f8 40             	cmp    $0x40,%eax
801070ea:	0f 85 5a 01 00 00    	jne    8010724a <handleSignals+0x171>
801070f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070f6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801070fc:	85 c0                	test   %eax,%eax
801070fe:	0f 8e 46 01 00 00    	jle    8010724a <handleSignals+0x171>
80107104:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010710a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80107110:	85 c0                	test   %eax,%eax
80107112:	0f 85 32 01 00 00    	jne    8010724a <handleSignals+0x171>
      int signum = getLowestSetBit(proc->pending);
80107118:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010711e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107124:	89 04 24             	mov    %eax,(%esp)
80107127:	e8 bc fd ff ff       	call   80106ee8 <getLowestSetBit>
8010712c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      proc->pending &= ~(1 << signum);
8010712f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107135:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010713c:	8b 9a 80 00 00 00    	mov    0x80(%edx),%ebx
80107142:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107145:	be 01 00 00 00       	mov    $0x1,%esi
8010714a:	89 d1                	mov    %edx,%ecx
8010714c:	d3 e6                	shl    %cl,%esi
8010714e:	89 f2                	mov    %esi,%edx
80107150:	f7 d2                	not    %edx
80107152:	21 da                	and    %ebx,%edx
80107154:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      proc->insignal = 1;
8010715a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107160:	c7 80 84 00 00 00 01 	movl   $0x1,0x84(%eax)
80107167:	00 00 00 
      sighandler_t handler = proc->signal_handlers[signum];
8010716a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107170:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107173:	83 c2 20             	add    $0x20,%edx
80107176:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010717a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!proc->backuptf) {
8010717d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107183:	8b 40 1c             	mov    0x1c(%eax),%eax
80107186:	85 c0                	test   %eax,%eax
80107188:	75 0f                	jne    80107199 <handleSignals+0xc0>
          proc->backuptf = (struct trapframe*)kalloc();
8010718a:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80107191:	e8 4c b9 ff ff       	call   80102ae2 <kalloc>
80107196:	89 43 1c             	mov    %eax,0x1c(%ebx)
      }
      copytf(proc->tf, proc->backuptf);          // Copy trap frame, to be reconstruced later
80107199:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010719f:	8b 50 1c             	mov    0x1c(%eax),%edx
801071a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071a8:	8b 40 18             	mov    0x18(%eax),%eax
801071ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801071af:	89 04 24             	mov    %eax,(%esp)
801071b2:	e8 63 fd ff ff       	call   80106f1a <copytf>
      
      int* sp = (int*)proc->tf->esp;
801071b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071bd:	8b 40 18             	mov    0x18(%eax),%eax
801071c0:	8b 40 44             	mov    0x44(%eax),%eax
801071c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      int funcAddr = (int)(sp - 5); // We put the sigret function 5*4 bytes under the stack pointer. (its size is approx. 8 bytes)
801071c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071c9:	83 e8 14             	sub    $0x14,%eax
801071cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int funcSize = (int)&end_of_sigret - (int)&implicit_sigret;		
801071cf:	ba 1e 6d 10 80       	mov    $0x80106d1e,%edx
801071d4:	b8 16 6d 10 80       	mov    $0x80106d16,%eax
801071d9:	29 c2                	sub    %eax,%edx
801071db:	89 d0                	mov    %edx,%eax
801071dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      copyout(proc->pgdir, funcAddr, &implicit_sigret, funcSize);			// Push implicit_sigret argument to stack
801071e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801071e3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801071e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071ec:	8b 40 04             	mov    0x4(%eax),%eax
801071ef:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801071f3:	c7 44 24 08 16 6d 10 	movl   $0x80106d16,0x8(%esp)
801071fa:	80 
801071fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801071ff:	89 04 24             	mov    %eax,(%esp)
80107202:	e8 aa 1d 00 00       	call   80108fb1 <copyout>
      
      // We put the arguent 4 bytes under the stack pointer, and the ret address 8 bytes under.
      sp--;
80107207:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
      *sp = signum;
8010720b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010720e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107211:	89 10                	mov    %edx,(%eax)
      sp--;  
80107213:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
      *sp = funcAddr;    
80107217:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010721a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010721d:	89 10                	mov    %edx,(%eax)
    
      // new we set the stack pointer to be 8 bytes under (where the ret address is located)
      proc->tf->esp -= 8;
8010721f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107225:	8b 40 18             	mov    0x18(%eax),%eax
80107228:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010722f:	8b 52 18             	mov    0x18(%edx),%edx
80107232:	8b 52 44             	mov    0x44(%edx),%edx
80107235:	83 ea 08             	sub    $0x8,%edx
80107238:	89 50 44             	mov    %edx,0x44(%eax)
      proc->tf->eip = (uint)handler;
8010723b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107241:	8b 40 18             	mov    0x18(%eax),%eax
80107244:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107247:	89 50 38             	mov    %edx,0x38(%eax)
    }
    return;
8010724a:	90                   	nop
}
8010724b:	83 c4 30             	add    $0x30,%esp
8010724e:	5b                   	pop    %ebx
8010724f:	5e                   	pop    %esi
80107250:	5d                   	pop    %ebp
80107251:	c3                   	ret    

80107252 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107252:	55                   	push   %ebp
80107253:	89 e5                	mov    %esp,%ebp
80107255:	57                   	push   %edi
80107256:	56                   	push   %esi
80107257:	53                   	push   %ebx
80107258:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010725b:	8b 45 08             	mov    0x8(%ebp),%eax
8010725e:	8b 40 30             	mov    0x30(%eax),%eax
80107261:	83 f8 40             	cmp    $0x40,%eax
80107264:	75 3f                	jne    801072a5 <trap+0x53>
    if(proc->killed)
80107266:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010726c:	8b 40 28             	mov    0x28(%eax),%eax
8010726f:	85 c0                	test   %eax,%eax
80107271:	74 05                	je     80107278 <trap+0x26>
      exit();
80107273:	e8 a0 d8 ff ff       	call   80104b18 <exit>
    proc->tf = tf;
80107278:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010727e:	8b 55 08             	mov    0x8(%ebp),%edx
80107281:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107284:	e8 f6 e8 ff ff       	call   80105b7f <syscall>
    if(proc->killed)
80107289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010728f:	8b 40 28             	mov    0x28(%eax),%eax
80107292:	85 c0                	test   %eax,%eax
80107294:	74 0a                	je     801072a0 <trap+0x4e>
      exit();
80107296:	e8 7d d8 ff ff       	call   80104b18 <exit>
    return;
8010729b:	e9 aa 02 00 00       	jmp    8010754a <trap+0x2f8>
801072a0:	e9 a5 02 00 00       	jmp    8010754a <trap+0x2f8>
  }

  switch(tf->trapno){
801072a5:	8b 45 08             	mov    0x8(%ebp),%eax
801072a8:	8b 40 30             	mov    0x30(%eax),%eax
801072ab:	83 e8 20             	sub    $0x20,%eax
801072ae:	83 f8 1f             	cmp    $0x1f,%eax
801072b1:	0f 87 c1 00 00 00    	ja     80107378 <trap+0x126>
801072b7:	8b 04 85 60 95 10 80 	mov    -0x7fef6aa0(,%eax,4),%eax
801072be:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801072c0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801072c6:	0f b6 00             	movzbl (%eax),%eax
801072c9:	84 c0                	test   %al,%al
801072cb:	75 36                	jne    80107303 <trap+0xb1>
      acquire(&tickslock);
801072cd:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801072d4:	e8 49 e2 ff ff       	call   80105522 <acquire>
      ticks++;
801072d9:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801072de:	83 c0 01             	add    $0x1,%eax
801072e1:	a3 40 8f 11 80       	mov    %eax,0x80118f40
      wakeup(&ticks);
801072e6:	c7 04 24 40 8f 11 80 	movl   $0x80118f40,(%esp)
801072ed:	e8 55 dd ff ff       	call   80105047 <wakeup>
      advanceprocstats();
801072f2:	e8 ee df ff ff       	call   801052e5 <advanceprocstats>
      release(&tickslock);
801072f7:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801072fe:	e8 81 e2 ff ff       	call   80105584 <release>
    }
    lapiceoi();
80107303:	e8 c8 bb ff ff       	call   80102ed0 <lapiceoi>
    break;
80107308:	e9 41 01 00 00       	jmp    8010744e <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010730d:	e8 cc b3 ff ff       	call   801026de <ideintr>
    lapiceoi();
80107312:	e8 b9 bb ff ff       	call   80102ed0 <lapiceoi>
    break;
80107317:	e9 32 01 00 00       	jmp    8010744e <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010731c:	e8 7e b9 ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
80107321:	e8 aa bb ff ff       	call   80102ed0 <lapiceoi>
    break;
80107326:	e9 23 01 00 00       	jmp    8010744e <trap+0x1fc>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010732b:	e8 0f 04 00 00       	call   8010773f <uartintr>
    lapiceoi();
80107330:	e8 9b bb ff ff       	call   80102ed0 <lapiceoi>
    break;
80107335:	e9 14 01 00 00       	jmp    8010744e <trap+0x1fc>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010733a:	8b 45 08             	mov    0x8(%ebp),%eax
8010733d:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107340:	8b 45 08             	mov    0x8(%ebp),%eax
80107343:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107347:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010734a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107350:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107353:	0f b6 c0             	movzbl %al,%eax
80107356:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010735a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010735e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107362:	c7 04 24 c0 94 10 80 	movl   $0x801094c0,(%esp)
80107369:	e8 32 90 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010736e:	e8 5d bb ff ff       	call   80102ed0 <lapiceoi>
    break;
80107373:	e9 d6 00 00 00       	jmp    8010744e <trap+0x1fc>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107378:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010737e:	85 c0                	test   %eax,%eax
80107380:	74 11                	je     80107393 <trap+0x141>
80107382:	8b 45 08             	mov    0x8(%ebp),%eax
80107385:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107389:	0f b7 c0             	movzwl %ax,%eax
8010738c:	83 e0 03             	and    $0x3,%eax
8010738f:	85 c0                	test   %eax,%eax
80107391:	75 46                	jne    801073d9 <trap+0x187>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107393:	e8 af f9 ff ff       	call   80106d47 <rcr2>
80107398:	8b 55 08             	mov    0x8(%ebp),%edx
8010739b:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010739e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801073a5:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801073a8:	0f b6 ca             	movzbl %dl,%ecx
801073ab:	8b 55 08             	mov    0x8(%ebp),%edx
801073ae:	8b 52 30             	mov    0x30(%edx),%edx
801073b1:	89 44 24 10          	mov    %eax,0x10(%esp)
801073b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801073b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801073bd:	89 54 24 04          	mov    %edx,0x4(%esp)
801073c1:	c7 04 24 e4 94 10 80 	movl   $0x801094e4,(%esp)
801073c8:	e8 d3 8f ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801073cd:	c7 04 24 16 95 10 80 	movl   $0x80109516,(%esp)
801073d4:	e8 61 91 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801073d9:	e8 69 f9 ff ff       	call   80106d47 <rcr2>
801073de:	89 c2                	mov    %eax,%edx
801073e0:	8b 45 08             	mov    0x8(%ebp),%eax
801073e3:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801073e6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801073ec:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801073ef:	0f b6 f0             	movzbl %al,%esi
801073f2:	8b 45 08             	mov    0x8(%ebp),%eax
801073f5:	8b 58 34             	mov    0x34(%eax),%ebx
801073f8:	8b 45 08             	mov    0x8(%ebp),%eax
801073fb:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801073fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107404:	83 c0 70             	add    $0x70,%eax
80107407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010740a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107410:	8b 40 10             	mov    0x10(%eax),%eax
80107413:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107417:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010741b:	89 74 24 14          	mov    %esi,0x14(%esp)
8010741f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107423:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107427:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010742a:	89 74 24 08          	mov    %esi,0x8(%esp)
8010742e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107432:	c7 04 24 1c 95 10 80 	movl   $0x8010951c,(%esp)
80107439:	e8 62 8f ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010743e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107444:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
8010744b:	eb 01                	jmp    8010744e <trap+0x1fc>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010744d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010744e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107454:	85 c0                	test   %eax,%eax
80107456:	74 24                	je     8010747c <trap+0x22a>
80107458:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010745e:	8b 40 28             	mov    0x28(%eax),%eax
80107461:	85 c0                	test   %eax,%eax
80107463:	74 17                	je     8010747c <trap+0x22a>
80107465:	8b 45 08             	mov    0x8(%ebp),%eax
80107468:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010746c:	0f b7 c0             	movzwl %ax,%eax
8010746f:	83 e0 03             	and    $0x3,%eax
80107472:	83 f8 03             	cmp    $0x3,%eax
80107475:	75 05                	jne    8010747c <trap+0x22a>
    exit();
80107477:	e8 9c d6 ff ff       	call   80104b18 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
8010747c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107482:	85 c0                	test   %eax,%eax
80107484:	0f 84 92 00 00 00    	je     8010751c <trap+0x2ca>
8010748a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107490:	8b 40 0c             	mov    0xc(%eax),%eax
80107493:	83 f8 04             	cmp    $0x4,%eax
80107496:	0f 85 80 00 00 00    	jne    8010751c <trap+0x2ca>
8010749c:	8b 45 08             	mov    0x8(%ebp),%eax
8010749f:	8b 40 30             	mov    0x30(%eax),%eax
801074a2:	83 f8 20             	cmp    $0x20,%eax
801074a5:	75 75                	jne    8010751c <trap+0x2ca>
	  #ifdef FCFS
		 isFCFS = 1;
801074a7:	c7 05 70 c6 10 80 01 	movl   $0x1,0x8010c670
801074ae:	00 00 00 
	  #endif
	  if( proc->runQuanta % QUANTA == 0 && isFCFS == 0){
801074b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074b7:	8b 88 1c 01 00 00    	mov    0x11c(%eax),%ecx
801074bd:	ba 67 66 66 66       	mov    $0x66666667,%edx
801074c2:	89 c8                	mov    %ecx,%eax
801074c4:	f7 ea                	imul   %edx
801074c6:	d1 fa                	sar    %edx
801074c8:	89 c8                	mov    %ecx,%eax
801074ca:	c1 f8 1f             	sar    $0x1f,%eax
801074cd:	29 c2                	sub    %eax,%edx
801074cf:	89 d0                	mov    %edx,%eax
801074d1:	c1 e0 02             	shl    $0x2,%eax
801074d4:	01 d0                	add    %edx,%eax
801074d6:	29 c1                	sub    %eax,%ecx
801074d8:	89 ca                	mov    %ecx,%edx
801074da:	85 d2                	test   %edx,%edx
801074dc:	75 29                	jne    80107507 <trap+0x2b5>
801074de:	a1 70 c6 10 80       	mov    0x8010c670,%eax
801074e3:	85 c0                	test   %eax,%eax
801074e5:	75 20                	jne    80107507 <trap+0x2b5>
		  //cprintf(" \n ******* pid=%d; runQuanta=%d; rutime=%d; \n",proc->pid,proc->runQuanta,proc->rutime-1);
		  proc->runQuanta=proc->rutime;
801074e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801074ed:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801074f4:	8b 92 18 01 00 00    	mov    0x118(%edx),%edx
801074fa:	89 90 1c 01 00 00    	mov    %edx,0x11c(%eax)
		  yield();
80107500:	e8 ef d9 ff ff       	call   80104ef4 <yield>
80107505:	eb 15                	jmp    8010751c <trap+0x2ca>
	  }
	  else
		  proc->runQuanta++;
80107507:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010750d:	8b 90 1c 01 00 00    	mov    0x11c(%eax),%edx
80107513:	83 c2 01             	add    $0x1,%edx
80107516:	89 90 1c 01 00 00    	mov    %edx,0x11c(%eax)
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010751c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107522:	85 c0                	test   %eax,%eax
80107524:	74 24                	je     8010754a <trap+0x2f8>
80107526:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010752c:	8b 40 28             	mov    0x28(%eax),%eax
8010752f:	85 c0                	test   %eax,%eax
80107531:	74 17                	je     8010754a <trap+0x2f8>
80107533:	8b 45 08             	mov    0x8(%ebp),%eax
80107536:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010753a:	0f b7 c0             	movzwl %ax,%eax
8010753d:	83 e0 03             	and    $0x3,%eax
80107540:	83 f8 03             	cmp    $0x3,%eax
80107543:	75 05                	jne    8010754a <trap+0x2f8>
    exit();
80107545:	e8 ce d5 ff ff       	call   80104b18 <exit>
}
8010754a:	83 c4 3c             	add    $0x3c,%esp
8010754d:	5b                   	pop    %ebx
8010754e:	5e                   	pop    %esi
8010754f:	5f                   	pop    %edi
80107550:	5d                   	pop    %ebp
80107551:	c3                   	ret    

80107552 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107552:	55                   	push   %ebp
80107553:	89 e5                	mov    %esp,%ebp
80107555:	83 ec 14             	sub    $0x14,%esp
80107558:	8b 45 08             	mov    0x8(%ebp),%eax
8010755b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010755f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107563:	89 c2                	mov    %eax,%edx
80107565:	ec                   	in     (%dx),%al
80107566:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107569:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010756d:	c9                   	leave  
8010756e:	c3                   	ret    

8010756f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010756f:	55                   	push   %ebp
80107570:	89 e5                	mov    %esp,%ebp
80107572:	83 ec 08             	sub    $0x8,%esp
80107575:	8b 55 08             	mov    0x8(%ebp),%edx
80107578:	8b 45 0c             	mov    0xc(%ebp),%eax
8010757b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010757f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107582:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107586:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010758a:	ee                   	out    %al,(%dx)
}
8010758b:	c9                   	leave  
8010758c:	c3                   	ret    

8010758d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010758d:	55                   	push   %ebp
8010758e:	89 e5                	mov    %esp,%ebp
80107590:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107593:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010759a:	00 
8010759b:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801075a2:	e8 c8 ff ff ff       	call   8010756f <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801075a7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801075ae:	00 
801075af:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801075b6:	e8 b4 ff ff ff       	call   8010756f <outb>
  outb(COM1+0, 115200/9600);
801075bb:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801075c2:	00 
801075c3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801075ca:	e8 a0 ff ff ff       	call   8010756f <outb>
  outb(COM1+1, 0);
801075cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801075d6:	00 
801075d7:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801075de:	e8 8c ff ff ff       	call   8010756f <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801075e3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801075ea:	00 
801075eb:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801075f2:	e8 78 ff ff ff       	call   8010756f <outb>
  outb(COM1+4, 0);
801075f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801075fe:	00 
801075ff:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107606:	e8 64 ff ff ff       	call   8010756f <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010760b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107612:	00 
80107613:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010761a:	e8 50 ff ff ff       	call   8010756f <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010761f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107626:	e8 27 ff ff ff       	call   80107552 <inb>
8010762b:	3c ff                	cmp    $0xff,%al
8010762d:	75 02                	jne    80107631 <uartinit+0xa4>
    return;
8010762f:	eb 6a                	jmp    8010769b <uartinit+0x10e>
  uart = 1;
80107631:	c7 05 74 c6 10 80 01 	movl   $0x1,0x8010c674
80107638:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010763b:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107642:	e8 0b ff ff ff       	call   80107552 <inb>
  inb(COM1+0);
80107647:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010764e:	e8 ff fe ff ff       	call   80107552 <inb>
  picenable(IRQ_COM1);
80107653:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010765a:	e8 55 c7 ff ff       	call   80103db4 <picenable>
  ioapicenable(IRQ_COM1, 0);
8010765f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107666:	00 
80107667:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010766e:	e8 ea b2 ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107673:	c7 45 f4 e0 95 10 80 	movl   $0x801095e0,-0xc(%ebp)
8010767a:	eb 15                	jmp    80107691 <uartinit+0x104>
    uartputc(*p);
8010767c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767f:	0f b6 00             	movzbl (%eax),%eax
80107682:	0f be c0             	movsbl %al,%eax
80107685:	89 04 24             	mov    %eax,(%esp)
80107688:	e8 10 00 00 00       	call   8010769d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010768d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	0f b6 00             	movzbl (%eax),%eax
80107697:	84 c0                	test   %al,%al
80107699:	75 e1                	jne    8010767c <uartinit+0xef>
    uartputc(*p);
}
8010769b:	c9                   	leave  
8010769c:	c3                   	ret    

8010769d <uartputc>:

void
uartputc(int c)
{
8010769d:	55                   	push   %ebp
8010769e:	89 e5                	mov    %esp,%ebp
801076a0:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801076a3:	a1 74 c6 10 80       	mov    0x8010c674,%eax
801076a8:	85 c0                	test   %eax,%eax
801076aa:	75 02                	jne    801076ae <uartputc+0x11>
    return;
801076ac:	eb 4b                	jmp    801076f9 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801076ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801076b5:	eb 10                	jmp    801076c7 <uartputc+0x2a>
    microdelay(10);
801076b7:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801076be:	e8 32 b8 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801076c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801076c7:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801076cb:	7f 16                	jg     801076e3 <uartputc+0x46>
801076cd:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801076d4:	e8 79 fe ff ff       	call   80107552 <inb>
801076d9:	0f b6 c0             	movzbl %al,%eax
801076dc:	83 e0 20             	and    $0x20,%eax
801076df:	85 c0                	test   %eax,%eax
801076e1:	74 d4                	je     801076b7 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801076e3:	8b 45 08             	mov    0x8(%ebp),%eax
801076e6:	0f b6 c0             	movzbl %al,%eax
801076e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801076ed:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801076f4:	e8 76 fe ff ff       	call   8010756f <outb>
}
801076f9:	c9                   	leave  
801076fa:	c3                   	ret    

801076fb <uartgetc>:

static int
uartgetc(void)
{
801076fb:	55                   	push   %ebp
801076fc:	89 e5                	mov    %esp,%ebp
801076fe:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107701:	a1 74 c6 10 80       	mov    0x8010c674,%eax
80107706:	85 c0                	test   %eax,%eax
80107708:	75 07                	jne    80107711 <uartgetc+0x16>
    return -1;
8010770a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010770f:	eb 2c                	jmp    8010773d <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107711:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107718:	e8 35 fe ff ff       	call   80107552 <inb>
8010771d:	0f b6 c0             	movzbl %al,%eax
80107720:	83 e0 01             	and    $0x1,%eax
80107723:	85 c0                	test   %eax,%eax
80107725:	75 07                	jne    8010772e <uartgetc+0x33>
    return -1;
80107727:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010772c:	eb 0f                	jmp    8010773d <uartgetc+0x42>
  return inb(COM1+0);
8010772e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107735:	e8 18 fe ff ff       	call   80107552 <inb>
8010773a:	0f b6 c0             	movzbl %al,%eax
}
8010773d:	c9                   	leave  
8010773e:	c3                   	ret    

8010773f <uartintr>:

void
uartintr(void)
{
8010773f:	55                   	push   %ebp
80107740:	89 e5                	mov    %esp,%ebp
80107742:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107745:	c7 04 24 fb 76 10 80 	movl   $0x801076fb,(%esp)
8010774c:	e8 5c 90 ff ff       	call   801007ad <consoleintr>
}
80107751:	c9                   	leave  
80107752:	c3                   	ret    

80107753 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $0
80107755:	6a 00                	push   $0x0
  jmp alltraps
80107757:	e9 8a f5 ff ff       	jmp    80106ce6 <alltraps>

8010775c <vector1>:
.globl vector1
vector1:
  pushl $0
8010775c:	6a 00                	push   $0x0
  pushl $1
8010775e:	6a 01                	push   $0x1
  jmp alltraps
80107760:	e9 81 f5 ff ff       	jmp    80106ce6 <alltraps>

80107765 <vector2>:
.globl vector2
vector2:
  pushl $0
80107765:	6a 00                	push   $0x0
  pushl $2
80107767:	6a 02                	push   $0x2
  jmp alltraps
80107769:	e9 78 f5 ff ff       	jmp    80106ce6 <alltraps>

8010776e <vector3>:
.globl vector3
vector3:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $3
80107770:	6a 03                	push   $0x3
  jmp alltraps
80107772:	e9 6f f5 ff ff       	jmp    80106ce6 <alltraps>

80107777 <vector4>:
.globl vector4
vector4:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $4
80107779:	6a 04                	push   $0x4
  jmp alltraps
8010777b:	e9 66 f5 ff ff       	jmp    80106ce6 <alltraps>

80107780 <vector5>:
.globl vector5
vector5:
  pushl $0
80107780:	6a 00                	push   $0x0
  pushl $5
80107782:	6a 05                	push   $0x5
  jmp alltraps
80107784:	e9 5d f5 ff ff       	jmp    80106ce6 <alltraps>

80107789 <vector6>:
.globl vector6
vector6:
  pushl $0
80107789:	6a 00                	push   $0x0
  pushl $6
8010778b:	6a 06                	push   $0x6
  jmp alltraps
8010778d:	e9 54 f5 ff ff       	jmp    80106ce6 <alltraps>

80107792 <vector7>:
.globl vector7
vector7:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $7
80107794:	6a 07                	push   $0x7
  jmp alltraps
80107796:	e9 4b f5 ff ff       	jmp    80106ce6 <alltraps>

8010779b <vector8>:
.globl vector8
vector8:
  pushl $8
8010779b:	6a 08                	push   $0x8
  jmp alltraps
8010779d:	e9 44 f5 ff ff       	jmp    80106ce6 <alltraps>

801077a2 <vector9>:
.globl vector9
vector9:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $9
801077a4:	6a 09                	push   $0x9
  jmp alltraps
801077a6:	e9 3b f5 ff ff       	jmp    80106ce6 <alltraps>

801077ab <vector10>:
.globl vector10
vector10:
  pushl $10
801077ab:	6a 0a                	push   $0xa
  jmp alltraps
801077ad:	e9 34 f5 ff ff       	jmp    80106ce6 <alltraps>

801077b2 <vector11>:
.globl vector11
vector11:
  pushl $11
801077b2:	6a 0b                	push   $0xb
  jmp alltraps
801077b4:	e9 2d f5 ff ff       	jmp    80106ce6 <alltraps>

801077b9 <vector12>:
.globl vector12
vector12:
  pushl $12
801077b9:	6a 0c                	push   $0xc
  jmp alltraps
801077bb:	e9 26 f5 ff ff       	jmp    80106ce6 <alltraps>

801077c0 <vector13>:
.globl vector13
vector13:
  pushl $13
801077c0:	6a 0d                	push   $0xd
  jmp alltraps
801077c2:	e9 1f f5 ff ff       	jmp    80106ce6 <alltraps>

801077c7 <vector14>:
.globl vector14
vector14:
  pushl $14
801077c7:	6a 0e                	push   $0xe
  jmp alltraps
801077c9:	e9 18 f5 ff ff       	jmp    80106ce6 <alltraps>

801077ce <vector15>:
.globl vector15
vector15:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $15
801077d0:	6a 0f                	push   $0xf
  jmp alltraps
801077d2:	e9 0f f5 ff ff       	jmp    80106ce6 <alltraps>

801077d7 <vector16>:
.globl vector16
vector16:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $16
801077d9:	6a 10                	push   $0x10
  jmp alltraps
801077db:	e9 06 f5 ff ff       	jmp    80106ce6 <alltraps>

801077e0 <vector17>:
.globl vector17
vector17:
  pushl $17
801077e0:	6a 11                	push   $0x11
  jmp alltraps
801077e2:	e9 ff f4 ff ff       	jmp    80106ce6 <alltraps>

801077e7 <vector18>:
.globl vector18
vector18:
  pushl $0
801077e7:	6a 00                	push   $0x0
  pushl $18
801077e9:	6a 12                	push   $0x12
  jmp alltraps
801077eb:	e9 f6 f4 ff ff       	jmp    80106ce6 <alltraps>

801077f0 <vector19>:
.globl vector19
vector19:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $19
801077f2:	6a 13                	push   $0x13
  jmp alltraps
801077f4:	e9 ed f4 ff ff       	jmp    80106ce6 <alltraps>

801077f9 <vector20>:
.globl vector20
vector20:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $20
801077fb:	6a 14                	push   $0x14
  jmp alltraps
801077fd:	e9 e4 f4 ff ff       	jmp    80106ce6 <alltraps>

80107802 <vector21>:
.globl vector21
vector21:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $21
80107804:	6a 15                	push   $0x15
  jmp alltraps
80107806:	e9 db f4 ff ff       	jmp    80106ce6 <alltraps>

8010780b <vector22>:
.globl vector22
vector22:
  pushl $0
8010780b:	6a 00                	push   $0x0
  pushl $22
8010780d:	6a 16                	push   $0x16
  jmp alltraps
8010780f:	e9 d2 f4 ff ff       	jmp    80106ce6 <alltraps>

80107814 <vector23>:
.globl vector23
vector23:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $23
80107816:	6a 17                	push   $0x17
  jmp alltraps
80107818:	e9 c9 f4 ff ff       	jmp    80106ce6 <alltraps>

8010781d <vector24>:
.globl vector24
vector24:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $24
8010781f:	6a 18                	push   $0x18
  jmp alltraps
80107821:	e9 c0 f4 ff ff       	jmp    80106ce6 <alltraps>

80107826 <vector25>:
.globl vector25
vector25:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $25
80107828:	6a 19                	push   $0x19
  jmp alltraps
8010782a:	e9 b7 f4 ff ff       	jmp    80106ce6 <alltraps>

8010782f <vector26>:
.globl vector26
vector26:
  pushl $0
8010782f:	6a 00                	push   $0x0
  pushl $26
80107831:	6a 1a                	push   $0x1a
  jmp alltraps
80107833:	e9 ae f4 ff ff       	jmp    80106ce6 <alltraps>

80107838 <vector27>:
.globl vector27
vector27:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $27
8010783a:	6a 1b                	push   $0x1b
  jmp alltraps
8010783c:	e9 a5 f4 ff ff       	jmp    80106ce6 <alltraps>

80107841 <vector28>:
.globl vector28
vector28:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $28
80107843:	6a 1c                	push   $0x1c
  jmp alltraps
80107845:	e9 9c f4 ff ff       	jmp    80106ce6 <alltraps>

8010784a <vector29>:
.globl vector29
vector29:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $29
8010784c:	6a 1d                	push   $0x1d
  jmp alltraps
8010784e:	e9 93 f4 ff ff       	jmp    80106ce6 <alltraps>

80107853 <vector30>:
.globl vector30
vector30:
  pushl $0
80107853:	6a 00                	push   $0x0
  pushl $30
80107855:	6a 1e                	push   $0x1e
  jmp alltraps
80107857:	e9 8a f4 ff ff       	jmp    80106ce6 <alltraps>

8010785c <vector31>:
.globl vector31
vector31:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $31
8010785e:	6a 1f                	push   $0x1f
  jmp alltraps
80107860:	e9 81 f4 ff ff       	jmp    80106ce6 <alltraps>

80107865 <vector32>:
.globl vector32
vector32:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $32
80107867:	6a 20                	push   $0x20
  jmp alltraps
80107869:	e9 78 f4 ff ff       	jmp    80106ce6 <alltraps>

8010786e <vector33>:
.globl vector33
vector33:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $33
80107870:	6a 21                	push   $0x21
  jmp alltraps
80107872:	e9 6f f4 ff ff       	jmp    80106ce6 <alltraps>

80107877 <vector34>:
.globl vector34
vector34:
  pushl $0
80107877:	6a 00                	push   $0x0
  pushl $34
80107879:	6a 22                	push   $0x22
  jmp alltraps
8010787b:	e9 66 f4 ff ff       	jmp    80106ce6 <alltraps>

80107880 <vector35>:
.globl vector35
vector35:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $35
80107882:	6a 23                	push   $0x23
  jmp alltraps
80107884:	e9 5d f4 ff ff       	jmp    80106ce6 <alltraps>

80107889 <vector36>:
.globl vector36
vector36:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $36
8010788b:	6a 24                	push   $0x24
  jmp alltraps
8010788d:	e9 54 f4 ff ff       	jmp    80106ce6 <alltraps>

80107892 <vector37>:
.globl vector37
vector37:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $37
80107894:	6a 25                	push   $0x25
  jmp alltraps
80107896:	e9 4b f4 ff ff       	jmp    80106ce6 <alltraps>

8010789b <vector38>:
.globl vector38
vector38:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $38
8010789d:	6a 26                	push   $0x26
  jmp alltraps
8010789f:	e9 42 f4 ff ff       	jmp    80106ce6 <alltraps>

801078a4 <vector39>:
.globl vector39
vector39:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $39
801078a6:	6a 27                	push   $0x27
  jmp alltraps
801078a8:	e9 39 f4 ff ff       	jmp    80106ce6 <alltraps>

801078ad <vector40>:
.globl vector40
vector40:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $40
801078af:	6a 28                	push   $0x28
  jmp alltraps
801078b1:	e9 30 f4 ff ff       	jmp    80106ce6 <alltraps>

801078b6 <vector41>:
.globl vector41
vector41:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $41
801078b8:	6a 29                	push   $0x29
  jmp alltraps
801078ba:	e9 27 f4 ff ff       	jmp    80106ce6 <alltraps>

801078bf <vector42>:
.globl vector42
vector42:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $42
801078c1:	6a 2a                	push   $0x2a
  jmp alltraps
801078c3:	e9 1e f4 ff ff       	jmp    80106ce6 <alltraps>

801078c8 <vector43>:
.globl vector43
vector43:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $43
801078ca:	6a 2b                	push   $0x2b
  jmp alltraps
801078cc:	e9 15 f4 ff ff       	jmp    80106ce6 <alltraps>

801078d1 <vector44>:
.globl vector44
vector44:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $44
801078d3:	6a 2c                	push   $0x2c
  jmp alltraps
801078d5:	e9 0c f4 ff ff       	jmp    80106ce6 <alltraps>

801078da <vector45>:
.globl vector45
vector45:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $45
801078dc:	6a 2d                	push   $0x2d
  jmp alltraps
801078de:	e9 03 f4 ff ff       	jmp    80106ce6 <alltraps>

801078e3 <vector46>:
.globl vector46
vector46:
  pushl $0
801078e3:	6a 00                	push   $0x0
  pushl $46
801078e5:	6a 2e                	push   $0x2e
  jmp alltraps
801078e7:	e9 fa f3 ff ff       	jmp    80106ce6 <alltraps>

801078ec <vector47>:
.globl vector47
vector47:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $47
801078ee:	6a 2f                	push   $0x2f
  jmp alltraps
801078f0:	e9 f1 f3 ff ff       	jmp    80106ce6 <alltraps>

801078f5 <vector48>:
.globl vector48
vector48:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $48
801078f7:	6a 30                	push   $0x30
  jmp alltraps
801078f9:	e9 e8 f3 ff ff       	jmp    80106ce6 <alltraps>

801078fe <vector49>:
.globl vector49
vector49:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $49
80107900:	6a 31                	push   $0x31
  jmp alltraps
80107902:	e9 df f3 ff ff       	jmp    80106ce6 <alltraps>

80107907 <vector50>:
.globl vector50
vector50:
  pushl $0
80107907:	6a 00                	push   $0x0
  pushl $50
80107909:	6a 32                	push   $0x32
  jmp alltraps
8010790b:	e9 d6 f3 ff ff       	jmp    80106ce6 <alltraps>

80107910 <vector51>:
.globl vector51
vector51:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $51
80107912:	6a 33                	push   $0x33
  jmp alltraps
80107914:	e9 cd f3 ff ff       	jmp    80106ce6 <alltraps>

80107919 <vector52>:
.globl vector52
vector52:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $52
8010791b:	6a 34                	push   $0x34
  jmp alltraps
8010791d:	e9 c4 f3 ff ff       	jmp    80106ce6 <alltraps>

80107922 <vector53>:
.globl vector53
vector53:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $53
80107924:	6a 35                	push   $0x35
  jmp alltraps
80107926:	e9 bb f3 ff ff       	jmp    80106ce6 <alltraps>

8010792b <vector54>:
.globl vector54
vector54:
  pushl $0
8010792b:	6a 00                	push   $0x0
  pushl $54
8010792d:	6a 36                	push   $0x36
  jmp alltraps
8010792f:	e9 b2 f3 ff ff       	jmp    80106ce6 <alltraps>

80107934 <vector55>:
.globl vector55
vector55:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $55
80107936:	6a 37                	push   $0x37
  jmp alltraps
80107938:	e9 a9 f3 ff ff       	jmp    80106ce6 <alltraps>

8010793d <vector56>:
.globl vector56
vector56:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $56
8010793f:	6a 38                	push   $0x38
  jmp alltraps
80107941:	e9 a0 f3 ff ff       	jmp    80106ce6 <alltraps>

80107946 <vector57>:
.globl vector57
vector57:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $57
80107948:	6a 39                	push   $0x39
  jmp alltraps
8010794a:	e9 97 f3 ff ff       	jmp    80106ce6 <alltraps>

8010794f <vector58>:
.globl vector58
vector58:
  pushl $0
8010794f:	6a 00                	push   $0x0
  pushl $58
80107951:	6a 3a                	push   $0x3a
  jmp alltraps
80107953:	e9 8e f3 ff ff       	jmp    80106ce6 <alltraps>

80107958 <vector59>:
.globl vector59
vector59:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $59
8010795a:	6a 3b                	push   $0x3b
  jmp alltraps
8010795c:	e9 85 f3 ff ff       	jmp    80106ce6 <alltraps>

80107961 <vector60>:
.globl vector60
vector60:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $60
80107963:	6a 3c                	push   $0x3c
  jmp alltraps
80107965:	e9 7c f3 ff ff       	jmp    80106ce6 <alltraps>

8010796a <vector61>:
.globl vector61
vector61:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $61
8010796c:	6a 3d                	push   $0x3d
  jmp alltraps
8010796e:	e9 73 f3 ff ff       	jmp    80106ce6 <alltraps>

80107973 <vector62>:
.globl vector62
vector62:
  pushl $0
80107973:	6a 00                	push   $0x0
  pushl $62
80107975:	6a 3e                	push   $0x3e
  jmp alltraps
80107977:	e9 6a f3 ff ff       	jmp    80106ce6 <alltraps>

8010797c <vector63>:
.globl vector63
vector63:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $63
8010797e:	6a 3f                	push   $0x3f
  jmp alltraps
80107980:	e9 61 f3 ff ff       	jmp    80106ce6 <alltraps>

80107985 <vector64>:
.globl vector64
vector64:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $64
80107987:	6a 40                	push   $0x40
  jmp alltraps
80107989:	e9 58 f3 ff ff       	jmp    80106ce6 <alltraps>

8010798e <vector65>:
.globl vector65
vector65:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $65
80107990:	6a 41                	push   $0x41
  jmp alltraps
80107992:	e9 4f f3 ff ff       	jmp    80106ce6 <alltraps>

80107997 <vector66>:
.globl vector66
vector66:
  pushl $0
80107997:	6a 00                	push   $0x0
  pushl $66
80107999:	6a 42                	push   $0x42
  jmp alltraps
8010799b:	e9 46 f3 ff ff       	jmp    80106ce6 <alltraps>

801079a0 <vector67>:
.globl vector67
vector67:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $67
801079a2:	6a 43                	push   $0x43
  jmp alltraps
801079a4:	e9 3d f3 ff ff       	jmp    80106ce6 <alltraps>

801079a9 <vector68>:
.globl vector68
vector68:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $68
801079ab:	6a 44                	push   $0x44
  jmp alltraps
801079ad:	e9 34 f3 ff ff       	jmp    80106ce6 <alltraps>

801079b2 <vector69>:
.globl vector69
vector69:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $69
801079b4:	6a 45                	push   $0x45
  jmp alltraps
801079b6:	e9 2b f3 ff ff       	jmp    80106ce6 <alltraps>

801079bb <vector70>:
.globl vector70
vector70:
  pushl $0
801079bb:	6a 00                	push   $0x0
  pushl $70
801079bd:	6a 46                	push   $0x46
  jmp alltraps
801079bf:	e9 22 f3 ff ff       	jmp    80106ce6 <alltraps>

801079c4 <vector71>:
.globl vector71
vector71:
  pushl $0
801079c4:	6a 00                	push   $0x0
  pushl $71
801079c6:	6a 47                	push   $0x47
  jmp alltraps
801079c8:	e9 19 f3 ff ff       	jmp    80106ce6 <alltraps>

801079cd <vector72>:
.globl vector72
vector72:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $72
801079cf:	6a 48                	push   $0x48
  jmp alltraps
801079d1:	e9 10 f3 ff ff       	jmp    80106ce6 <alltraps>

801079d6 <vector73>:
.globl vector73
vector73:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $73
801079d8:	6a 49                	push   $0x49
  jmp alltraps
801079da:	e9 07 f3 ff ff       	jmp    80106ce6 <alltraps>

801079df <vector74>:
.globl vector74
vector74:
  pushl $0
801079df:	6a 00                	push   $0x0
  pushl $74
801079e1:	6a 4a                	push   $0x4a
  jmp alltraps
801079e3:	e9 fe f2 ff ff       	jmp    80106ce6 <alltraps>

801079e8 <vector75>:
.globl vector75
vector75:
  pushl $0
801079e8:	6a 00                	push   $0x0
  pushl $75
801079ea:	6a 4b                	push   $0x4b
  jmp alltraps
801079ec:	e9 f5 f2 ff ff       	jmp    80106ce6 <alltraps>

801079f1 <vector76>:
.globl vector76
vector76:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $76
801079f3:	6a 4c                	push   $0x4c
  jmp alltraps
801079f5:	e9 ec f2 ff ff       	jmp    80106ce6 <alltraps>

801079fa <vector77>:
.globl vector77
vector77:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $77
801079fc:	6a 4d                	push   $0x4d
  jmp alltraps
801079fe:	e9 e3 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a03 <vector78>:
.globl vector78
vector78:
  pushl $0
80107a03:	6a 00                	push   $0x0
  pushl $78
80107a05:	6a 4e                	push   $0x4e
  jmp alltraps
80107a07:	e9 da f2 ff ff       	jmp    80106ce6 <alltraps>

80107a0c <vector79>:
.globl vector79
vector79:
  pushl $0
80107a0c:	6a 00                	push   $0x0
  pushl $79
80107a0e:	6a 4f                	push   $0x4f
  jmp alltraps
80107a10:	e9 d1 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a15 <vector80>:
.globl vector80
vector80:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $80
80107a17:	6a 50                	push   $0x50
  jmp alltraps
80107a19:	e9 c8 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a1e <vector81>:
.globl vector81
vector81:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $81
80107a20:	6a 51                	push   $0x51
  jmp alltraps
80107a22:	e9 bf f2 ff ff       	jmp    80106ce6 <alltraps>

80107a27 <vector82>:
.globl vector82
vector82:
  pushl $0
80107a27:	6a 00                	push   $0x0
  pushl $82
80107a29:	6a 52                	push   $0x52
  jmp alltraps
80107a2b:	e9 b6 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a30 <vector83>:
.globl vector83
vector83:
  pushl $0
80107a30:	6a 00                	push   $0x0
  pushl $83
80107a32:	6a 53                	push   $0x53
  jmp alltraps
80107a34:	e9 ad f2 ff ff       	jmp    80106ce6 <alltraps>

80107a39 <vector84>:
.globl vector84
vector84:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $84
80107a3b:	6a 54                	push   $0x54
  jmp alltraps
80107a3d:	e9 a4 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a42 <vector85>:
.globl vector85
vector85:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $85
80107a44:	6a 55                	push   $0x55
  jmp alltraps
80107a46:	e9 9b f2 ff ff       	jmp    80106ce6 <alltraps>

80107a4b <vector86>:
.globl vector86
vector86:
  pushl $0
80107a4b:	6a 00                	push   $0x0
  pushl $86
80107a4d:	6a 56                	push   $0x56
  jmp alltraps
80107a4f:	e9 92 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a54 <vector87>:
.globl vector87
vector87:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $87
80107a56:	6a 57                	push   $0x57
  jmp alltraps
80107a58:	e9 89 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a5d <vector88>:
.globl vector88
vector88:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $88
80107a5f:	6a 58                	push   $0x58
  jmp alltraps
80107a61:	e9 80 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a66 <vector89>:
.globl vector89
vector89:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $89
80107a68:	6a 59                	push   $0x59
  jmp alltraps
80107a6a:	e9 77 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a6f <vector90>:
.globl vector90
vector90:
  pushl $0
80107a6f:	6a 00                	push   $0x0
  pushl $90
80107a71:	6a 5a                	push   $0x5a
  jmp alltraps
80107a73:	e9 6e f2 ff ff       	jmp    80106ce6 <alltraps>

80107a78 <vector91>:
.globl vector91
vector91:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $91
80107a7a:	6a 5b                	push   $0x5b
  jmp alltraps
80107a7c:	e9 65 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a81 <vector92>:
.globl vector92
vector92:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $92
80107a83:	6a 5c                	push   $0x5c
  jmp alltraps
80107a85:	e9 5c f2 ff ff       	jmp    80106ce6 <alltraps>

80107a8a <vector93>:
.globl vector93
vector93:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $93
80107a8c:	6a 5d                	push   $0x5d
  jmp alltraps
80107a8e:	e9 53 f2 ff ff       	jmp    80106ce6 <alltraps>

80107a93 <vector94>:
.globl vector94
vector94:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $94
80107a95:	6a 5e                	push   $0x5e
  jmp alltraps
80107a97:	e9 4a f2 ff ff       	jmp    80106ce6 <alltraps>

80107a9c <vector95>:
.globl vector95
vector95:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $95
80107a9e:	6a 5f                	push   $0x5f
  jmp alltraps
80107aa0:	e9 41 f2 ff ff       	jmp    80106ce6 <alltraps>

80107aa5 <vector96>:
.globl vector96
vector96:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $96
80107aa7:	6a 60                	push   $0x60
  jmp alltraps
80107aa9:	e9 38 f2 ff ff       	jmp    80106ce6 <alltraps>

80107aae <vector97>:
.globl vector97
vector97:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $97
80107ab0:	6a 61                	push   $0x61
  jmp alltraps
80107ab2:	e9 2f f2 ff ff       	jmp    80106ce6 <alltraps>

80107ab7 <vector98>:
.globl vector98
vector98:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $98
80107ab9:	6a 62                	push   $0x62
  jmp alltraps
80107abb:	e9 26 f2 ff ff       	jmp    80106ce6 <alltraps>

80107ac0 <vector99>:
.globl vector99
vector99:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $99
80107ac2:	6a 63                	push   $0x63
  jmp alltraps
80107ac4:	e9 1d f2 ff ff       	jmp    80106ce6 <alltraps>

80107ac9 <vector100>:
.globl vector100
vector100:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $100
80107acb:	6a 64                	push   $0x64
  jmp alltraps
80107acd:	e9 14 f2 ff ff       	jmp    80106ce6 <alltraps>

80107ad2 <vector101>:
.globl vector101
vector101:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $101
80107ad4:	6a 65                	push   $0x65
  jmp alltraps
80107ad6:	e9 0b f2 ff ff       	jmp    80106ce6 <alltraps>

80107adb <vector102>:
.globl vector102
vector102:
  pushl $0
80107adb:	6a 00                	push   $0x0
  pushl $102
80107add:	6a 66                	push   $0x66
  jmp alltraps
80107adf:	e9 02 f2 ff ff       	jmp    80106ce6 <alltraps>

80107ae4 <vector103>:
.globl vector103
vector103:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $103
80107ae6:	6a 67                	push   $0x67
  jmp alltraps
80107ae8:	e9 f9 f1 ff ff       	jmp    80106ce6 <alltraps>

80107aed <vector104>:
.globl vector104
vector104:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $104
80107aef:	6a 68                	push   $0x68
  jmp alltraps
80107af1:	e9 f0 f1 ff ff       	jmp    80106ce6 <alltraps>

80107af6 <vector105>:
.globl vector105
vector105:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $105
80107af8:	6a 69                	push   $0x69
  jmp alltraps
80107afa:	e9 e7 f1 ff ff       	jmp    80106ce6 <alltraps>

80107aff <vector106>:
.globl vector106
vector106:
  pushl $0
80107aff:	6a 00                	push   $0x0
  pushl $106
80107b01:	6a 6a                	push   $0x6a
  jmp alltraps
80107b03:	e9 de f1 ff ff       	jmp    80106ce6 <alltraps>

80107b08 <vector107>:
.globl vector107
vector107:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $107
80107b0a:	6a 6b                	push   $0x6b
  jmp alltraps
80107b0c:	e9 d5 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b11 <vector108>:
.globl vector108
vector108:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $108
80107b13:	6a 6c                	push   $0x6c
  jmp alltraps
80107b15:	e9 cc f1 ff ff       	jmp    80106ce6 <alltraps>

80107b1a <vector109>:
.globl vector109
vector109:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $109
80107b1c:	6a 6d                	push   $0x6d
  jmp alltraps
80107b1e:	e9 c3 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b23 <vector110>:
.globl vector110
vector110:
  pushl $0
80107b23:	6a 00                	push   $0x0
  pushl $110
80107b25:	6a 6e                	push   $0x6e
  jmp alltraps
80107b27:	e9 ba f1 ff ff       	jmp    80106ce6 <alltraps>

80107b2c <vector111>:
.globl vector111
vector111:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $111
80107b2e:	6a 6f                	push   $0x6f
  jmp alltraps
80107b30:	e9 b1 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b35 <vector112>:
.globl vector112
vector112:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $112
80107b37:	6a 70                	push   $0x70
  jmp alltraps
80107b39:	e9 a8 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b3e <vector113>:
.globl vector113
vector113:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $113
80107b40:	6a 71                	push   $0x71
  jmp alltraps
80107b42:	e9 9f f1 ff ff       	jmp    80106ce6 <alltraps>

80107b47 <vector114>:
.globl vector114
vector114:
  pushl $0
80107b47:	6a 00                	push   $0x0
  pushl $114
80107b49:	6a 72                	push   $0x72
  jmp alltraps
80107b4b:	e9 96 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b50 <vector115>:
.globl vector115
vector115:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $115
80107b52:	6a 73                	push   $0x73
  jmp alltraps
80107b54:	e9 8d f1 ff ff       	jmp    80106ce6 <alltraps>

80107b59 <vector116>:
.globl vector116
vector116:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $116
80107b5b:	6a 74                	push   $0x74
  jmp alltraps
80107b5d:	e9 84 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b62 <vector117>:
.globl vector117
vector117:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $117
80107b64:	6a 75                	push   $0x75
  jmp alltraps
80107b66:	e9 7b f1 ff ff       	jmp    80106ce6 <alltraps>

80107b6b <vector118>:
.globl vector118
vector118:
  pushl $0
80107b6b:	6a 00                	push   $0x0
  pushl $118
80107b6d:	6a 76                	push   $0x76
  jmp alltraps
80107b6f:	e9 72 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b74 <vector119>:
.globl vector119
vector119:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $119
80107b76:	6a 77                	push   $0x77
  jmp alltraps
80107b78:	e9 69 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b7d <vector120>:
.globl vector120
vector120:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $120
80107b7f:	6a 78                	push   $0x78
  jmp alltraps
80107b81:	e9 60 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b86 <vector121>:
.globl vector121
vector121:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $121
80107b88:	6a 79                	push   $0x79
  jmp alltraps
80107b8a:	e9 57 f1 ff ff       	jmp    80106ce6 <alltraps>

80107b8f <vector122>:
.globl vector122
vector122:
  pushl $0
80107b8f:	6a 00                	push   $0x0
  pushl $122
80107b91:	6a 7a                	push   $0x7a
  jmp alltraps
80107b93:	e9 4e f1 ff ff       	jmp    80106ce6 <alltraps>

80107b98 <vector123>:
.globl vector123
vector123:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $123
80107b9a:	6a 7b                	push   $0x7b
  jmp alltraps
80107b9c:	e9 45 f1 ff ff       	jmp    80106ce6 <alltraps>

80107ba1 <vector124>:
.globl vector124
vector124:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $124
80107ba3:	6a 7c                	push   $0x7c
  jmp alltraps
80107ba5:	e9 3c f1 ff ff       	jmp    80106ce6 <alltraps>

80107baa <vector125>:
.globl vector125
vector125:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $125
80107bac:	6a 7d                	push   $0x7d
  jmp alltraps
80107bae:	e9 33 f1 ff ff       	jmp    80106ce6 <alltraps>

80107bb3 <vector126>:
.globl vector126
vector126:
  pushl $0
80107bb3:	6a 00                	push   $0x0
  pushl $126
80107bb5:	6a 7e                	push   $0x7e
  jmp alltraps
80107bb7:	e9 2a f1 ff ff       	jmp    80106ce6 <alltraps>

80107bbc <vector127>:
.globl vector127
vector127:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $127
80107bbe:	6a 7f                	push   $0x7f
  jmp alltraps
80107bc0:	e9 21 f1 ff ff       	jmp    80106ce6 <alltraps>

80107bc5 <vector128>:
.globl vector128
vector128:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $128
80107bc7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107bcc:	e9 15 f1 ff ff       	jmp    80106ce6 <alltraps>

80107bd1 <vector129>:
.globl vector129
vector129:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $129
80107bd3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107bd8:	e9 09 f1 ff ff       	jmp    80106ce6 <alltraps>

80107bdd <vector130>:
.globl vector130
vector130:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $130
80107bdf:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107be4:	e9 fd f0 ff ff       	jmp    80106ce6 <alltraps>

80107be9 <vector131>:
.globl vector131
vector131:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $131
80107beb:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107bf0:	e9 f1 f0 ff ff       	jmp    80106ce6 <alltraps>

80107bf5 <vector132>:
.globl vector132
vector132:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $132
80107bf7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107bfc:	e9 e5 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c01 <vector133>:
.globl vector133
vector133:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $133
80107c03:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107c08:	e9 d9 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c0d <vector134>:
.globl vector134
vector134:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $134
80107c0f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107c14:	e9 cd f0 ff ff       	jmp    80106ce6 <alltraps>

80107c19 <vector135>:
.globl vector135
vector135:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $135
80107c1b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107c20:	e9 c1 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c25 <vector136>:
.globl vector136
vector136:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $136
80107c27:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107c2c:	e9 b5 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c31 <vector137>:
.globl vector137
vector137:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $137
80107c33:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107c38:	e9 a9 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c3d <vector138>:
.globl vector138
vector138:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $138
80107c3f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107c44:	e9 9d f0 ff ff       	jmp    80106ce6 <alltraps>

80107c49 <vector139>:
.globl vector139
vector139:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $139
80107c4b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107c50:	e9 91 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c55 <vector140>:
.globl vector140
vector140:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $140
80107c57:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107c5c:	e9 85 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c61 <vector141>:
.globl vector141
vector141:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $141
80107c63:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107c68:	e9 79 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c6d <vector142>:
.globl vector142
vector142:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $142
80107c6f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107c74:	e9 6d f0 ff ff       	jmp    80106ce6 <alltraps>

80107c79 <vector143>:
.globl vector143
vector143:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $143
80107c7b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107c80:	e9 61 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c85 <vector144>:
.globl vector144
vector144:
  pushl $0
80107c85:	6a 00                	push   $0x0
  pushl $144
80107c87:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107c8c:	e9 55 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c91 <vector145>:
.globl vector145
vector145:
  pushl $0
80107c91:	6a 00                	push   $0x0
  pushl $145
80107c93:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107c98:	e9 49 f0 ff ff       	jmp    80106ce6 <alltraps>

80107c9d <vector146>:
.globl vector146
vector146:
  pushl $0
80107c9d:	6a 00                	push   $0x0
  pushl $146
80107c9f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ca4:	e9 3d f0 ff ff       	jmp    80106ce6 <alltraps>

80107ca9 <vector147>:
.globl vector147
vector147:
  pushl $0
80107ca9:	6a 00                	push   $0x0
  pushl $147
80107cab:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107cb0:	e9 31 f0 ff ff       	jmp    80106ce6 <alltraps>

80107cb5 <vector148>:
.globl vector148
vector148:
  pushl $0
80107cb5:	6a 00                	push   $0x0
  pushl $148
80107cb7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107cbc:	e9 25 f0 ff ff       	jmp    80106ce6 <alltraps>

80107cc1 <vector149>:
.globl vector149
vector149:
  pushl $0
80107cc1:	6a 00                	push   $0x0
  pushl $149
80107cc3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107cc8:	e9 19 f0 ff ff       	jmp    80106ce6 <alltraps>

80107ccd <vector150>:
.globl vector150
vector150:
  pushl $0
80107ccd:	6a 00                	push   $0x0
  pushl $150
80107ccf:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107cd4:	e9 0d f0 ff ff       	jmp    80106ce6 <alltraps>

80107cd9 <vector151>:
.globl vector151
vector151:
  pushl $0
80107cd9:	6a 00                	push   $0x0
  pushl $151
80107cdb:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107ce0:	e9 01 f0 ff ff       	jmp    80106ce6 <alltraps>

80107ce5 <vector152>:
.globl vector152
vector152:
  pushl $0
80107ce5:	6a 00                	push   $0x0
  pushl $152
80107ce7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107cec:	e9 f5 ef ff ff       	jmp    80106ce6 <alltraps>

80107cf1 <vector153>:
.globl vector153
vector153:
  pushl $0
80107cf1:	6a 00                	push   $0x0
  pushl $153
80107cf3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107cf8:	e9 e9 ef ff ff       	jmp    80106ce6 <alltraps>

80107cfd <vector154>:
.globl vector154
vector154:
  pushl $0
80107cfd:	6a 00                	push   $0x0
  pushl $154
80107cff:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107d04:	e9 dd ef ff ff       	jmp    80106ce6 <alltraps>

80107d09 <vector155>:
.globl vector155
vector155:
  pushl $0
80107d09:	6a 00                	push   $0x0
  pushl $155
80107d0b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107d10:	e9 d1 ef ff ff       	jmp    80106ce6 <alltraps>

80107d15 <vector156>:
.globl vector156
vector156:
  pushl $0
80107d15:	6a 00                	push   $0x0
  pushl $156
80107d17:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107d1c:	e9 c5 ef ff ff       	jmp    80106ce6 <alltraps>

80107d21 <vector157>:
.globl vector157
vector157:
  pushl $0
80107d21:	6a 00                	push   $0x0
  pushl $157
80107d23:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107d28:	e9 b9 ef ff ff       	jmp    80106ce6 <alltraps>

80107d2d <vector158>:
.globl vector158
vector158:
  pushl $0
80107d2d:	6a 00                	push   $0x0
  pushl $158
80107d2f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107d34:	e9 ad ef ff ff       	jmp    80106ce6 <alltraps>

80107d39 <vector159>:
.globl vector159
vector159:
  pushl $0
80107d39:	6a 00                	push   $0x0
  pushl $159
80107d3b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107d40:	e9 a1 ef ff ff       	jmp    80106ce6 <alltraps>

80107d45 <vector160>:
.globl vector160
vector160:
  pushl $0
80107d45:	6a 00                	push   $0x0
  pushl $160
80107d47:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107d4c:	e9 95 ef ff ff       	jmp    80106ce6 <alltraps>

80107d51 <vector161>:
.globl vector161
vector161:
  pushl $0
80107d51:	6a 00                	push   $0x0
  pushl $161
80107d53:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107d58:	e9 89 ef ff ff       	jmp    80106ce6 <alltraps>

80107d5d <vector162>:
.globl vector162
vector162:
  pushl $0
80107d5d:	6a 00                	push   $0x0
  pushl $162
80107d5f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107d64:	e9 7d ef ff ff       	jmp    80106ce6 <alltraps>

80107d69 <vector163>:
.globl vector163
vector163:
  pushl $0
80107d69:	6a 00                	push   $0x0
  pushl $163
80107d6b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107d70:	e9 71 ef ff ff       	jmp    80106ce6 <alltraps>

80107d75 <vector164>:
.globl vector164
vector164:
  pushl $0
80107d75:	6a 00                	push   $0x0
  pushl $164
80107d77:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107d7c:	e9 65 ef ff ff       	jmp    80106ce6 <alltraps>

80107d81 <vector165>:
.globl vector165
vector165:
  pushl $0
80107d81:	6a 00                	push   $0x0
  pushl $165
80107d83:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107d88:	e9 59 ef ff ff       	jmp    80106ce6 <alltraps>

80107d8d <vector166>:
.globl vector166
vector166:
  pushl $0
80107d8d:	6a 00                	push   $0x0
  pushl $166
80107d8f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107d94:	e9 4d ef ff ff       	jmp    80106ce6 <alltraps>

80107d99 <vector167>:
.globl vector167
vector167:
  pushl $0
80107d99:	6a 00                	push   $0x0
  pushl $167
80107d9b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107da0:	e9 41 ef ff ff       	jmp    80106ce6 <alltraps>

80107da5 <vector168>:
.globl vector168
vector168:
  pushl $0
80107da5:	6a 00                	push   $0x0
  pushl $168
80107da7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107dac:	e9 35 ef ff ff       	jmp    80106ce6 <alltraps>

80107db1 <vector169>:
.globl vector169
vector169:
  pushl $0
80107db1:	6a 00                	push   $0x0
  pushl $169
80107db3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107db8:	e9 29 ef ff ff       	jmp    80106ce6 <alltraps>

80107dbd <vector170>:
.globl vector170
vector170:
  pushl $0
80107dbd:	6a 00                	push   $0x0
  pushl $170
80107dbf:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107dc4:	e9 1d ef ff ff       	jmp    80106ce6 <alltraps>

80107dc9 <vector171>:
.globl vector171
vector171:
  pushl $0
80107dc9:	6a 00                	push   $0x0
  pushl $171
80107dcb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107dd0:	e9 11 ef ff ff       	jmp    80106ce6 <alltraps>

80107dd5 <vector172>:
.globl vector172
vector172:
  pushl $0
80107dd5:	6a 00                	push   $0x0
  pushl $172
80107dd7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107ddc:	e9 05 ef ff ff       	jmp    80106ce6 <alltraps>

80107de1 <vector173>:
.globl vector173
vector173:
  pushl $0
80107de1:	6a 00                	push   $0x0
  pushl $173
80107de3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107de8:	e9 f9 ee ff ff       	jmp    80106ce6 <alltraps>

80107ded <vector174>:
.globl vector174
vector174:
  pushl $0
80107ded:	6a 00                	push   $0x0
  pushl $174
80107def:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107df4:	e9 ed ee ff ff       	jmp    80106ce6 <alltraps>

80107df9 <vector175>:
.globl vector175
vector175:
  pushl $0
80107df9:	6a 00                	push   $0x0
  pushl $175
80107dfb:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107e00:	e9 e1 ee ff ff       	jmp    80106ce6 <alltraps>

80107e05 <vector176>:
.globl vector176
vector176:
  pushl $0
80107e05:	6a 00                	push   $0x0
  pushl $176
80107e07:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107e0c:	e9 d5 ee ff ff       	jmp    80106ce6 <alltraps>

80107e11 <vector177>:
.globl vector177
vector177:
  pushl $0
80107e11:	6a 00                	push   $0x0
  pushl $177
80107e13:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107e18:	e9 c9 ee ff ff       	jmp    80106ce6 <alltraps>

80107e1d <vector178>:
.globl vector178
vector178:
  pushl $0
80107e1d:	6a 00                	push   $0x0
  pushl $178
80107e1f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107e24:	e9 bd ee ff ff       	jmp    80106ce6 <alltraps>

80107e29 <vector179>:
.globl vector179
vector179:
  pushl $0
80107e29:	6a 00                	push   $0x0
  pushl $179
80107e2b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107e30:	e9 b1 ee ff ff       	jmp    80106ce6 <alltraps>

80107e35 <vector180>:
.globl vector180
vector180:
  pushl $0
80107e35:	6a 00                	push   $0x0
  pushl $180
80107e37:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107e3c:	e9 a5 ee ff ff       	jmp    80106ce6 <alltraps>

80107e41 <vector181>:
.globl vector181
vector181:
  pushl $0
80107e41:	6a 00                	push   $0x0
  pushl $181
80107e43:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107e48:	e9 99 ee ff ff       	jmp    80106ce6 <alltraps>

80107e4d <vector182>:
.globl vector182
vector182:
  pushl $0
80107e4d:	6a 00                	push   $0x0
  pushl $182
80107e4f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107e54:	e9 8d ee ff ff       	jmp    80106ce6 <alltraps>

80107e59 <vector183>:
.globl vector183
vector183:
  pushl $0
80107e59:	6a 00                	push   $0x0
  pushl $183
80107e5b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107e60:	e9 81 ee ff ff       	jmp    80106ce6 <alltraps>

80107e65 <vector184>:
.globl vector184
vector184:
  pushl $0
80107e65:	6a 00                	push   $0x0
  pushl $184
80107e67:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107e6c:	e9 75 ee ff ff       	jmp    80106ce6 <alltraps>

80107e71 <vector185>:
.globl vector185
vector185:
  pushl $0
80107e71:	6a 00                	push   $0x0
  pushl $185
80107e73:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107e78:	e9 69 ee ff ff       	jmp    80106ce6 <alltraps>

80107e7d <vector186>:
.globl vector186
vector186:
  pushl $0
80107e7d:	6a 00                	push   $0x0
  pushl $186
80107e7f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107e84:	e9 5d ee ff ff       	jmp    80106ce6 <alltraps>

80107e89 <vector187>:
.globl vector187
vector187:
  pushl $0
80107e89:	6a 00                	push   $0x0
  pushl $187
80107e8b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107e90:	e9 51 ee ff ff       	jmp    80106ce6 <alltraps>

80107e95 <vector188>:
.globl vector188
vector188:
  pushl $0
80107e95:	6a 00                	push   $0x0
  pushl $188
80107e97:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107e9c:	e9 45 ee ff ff       	jmp    80106ce6 <alltraps>

80107ea1 <vector189>:
.globl vector189
vector189:
  pushl $0
80107ea1:	6a 00                	push   $0x0
  pushl $189
80107ea3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107ea8:	e9 39 ee ff ff       	jmp    80106ce6 <alltraps>

80107ead <vector190>:
.globl vector190
vector190:
  pushl $0
80107ead:	6a 00                	push   $0x0
  pushl $190
80107eaf:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107eb4:	e9 2d ee ff ff       	jmp    80106ce6 <alltraps>

80107eb9 <vector191>:
.globl vector191
vector191:
  pushl $0
80107eb9:	6a 00                	push   $0x0
  pushl $191
80107ebb:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107ec0:	e9 21 ee ff ff       	jmp    80106ce6 <alltraps>

80107ec5 <vector192>:
.globl vector192
vector192:
  pushl $0
80107ec5:	6a 00                	push   $0x0
  pushl $192
80107ec7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107ecc:	e9 15 ee ff ff       	jmp    80106ce6 <alltraps>

80107ed1 <vector193>:
.globl vector193
vector193:
  pushl $0
80107ed1:	6a 00                	push   $0x0
  pushl $193
80107ed3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107ed8:	e9 09 ee ff ff       	jmp    80106ce6 <alltraps>

80107edd <vector194>:
.globl vector194
vector194:
  pushl $0
80107edd:	6a 00                	push   $0x0
  pushl $194
80107edf:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107ee4:	e9 fd ed ff ff       	jmp    80106ce6 <alltraps>

80107ee9 <vector195>:
.globl vector195
vector195:
  pushl $0
80107ee9:	6a 00                	push   $0x0
  pushl $195
80107eeb:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107ef0:	e9 f1 ed ff ff       	jmp    80106ce6 <alltraps>

80107ef5 <vector196>:
.globl vector196
vector196:
  pushl $0
80107ef5:	6a 00                	push   $0x0
  pushl $196
80107ef7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107efc:	e9 e5 ed ff ff       	jmp    80106ce6 <alltraps>

80107f01 <vector197>:
.globl vector197
vector197:
  pushl $0
80107f01:	6a 00                	push   $0x0
  pushl $197
80107f03:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107f08:	e9 d9 ed ff ff       	jmp    80106ce6 <alltraps>

80107f0d <vector198>:
.globl vector198
vector198:
  pushl $0
80107f0d:	6a 00                	push   $0x0
  pushl $198
80107f0f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107f14:	e9 cd ed ff ff       	jmp    80106ce6 <alltraps>

80107f19 <vector199>:
.globl vector199
vector199:
  pushl $0
80107f19:	6a 00                	push   $0x0
  pushl $199
80107f1b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107f20:	e9 c1 ed ff ff       	jmp    80106ce6 <alltraps>

80107f25 <vector200>:
.globl vector200
vector200:
  pushl $0
80107f25:	6a 00                	push   $0x0
  pushl $200
80107f27:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107f2c:	e9 b5 ed ff ff       	jmp    80106ce6 <alltraps>

80107f31 <vector201>:
.globl vector201
vector201:
  pushl $0
80107f31:	6a 00                	push   $0x0
  pushl $201
80107f33:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107f38:	e9 a9 ed ff ff       	jmp    80106ce6 <alltraps>

80107f3d <vector202>:
.globl vector202
vector202:
  pushl $0
80107f3d:	6a 00                	push   $0x0
  pushl $202
80107f3f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107f44:	e9 9d ed ff ff       	jmp    80106ce6 <alltraps>

80107f49 <vector203>:
.globl vector203
vector203:
  pushl $0
80107f49:	6a 00                	push   $0x0
  pushl $203
80107f4b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107f50:	e9 91 ed ff ff       	jmp    80106ce6 <alltraps>

80107f55 <vector204>:
.globl vector204
vector204:
  pushl $0
80107f55:	6a 00                	push   $0x0
  pushl $204
80107f57:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107f5c:	e9 85 ed ff ff       	jmp    80106ce6 <alltraps>

80107f61 <vector205>:
.globl vector205
vector205:
  pushl $0
80107f61:	6a 00                	push   $0x0
  pushl $205
80107f63:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107f68:	e9 79 ed ff ff       	jmp    80106ce6 <alltraps>

80107f6d <vector206>:
.globl vector206
vector206:
  pushl $0
80107f6d:	6a 00                	push   $0x0
  pushl $206
80107f6f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107f74:	e9 6d ed ff ff       	jmp    80106ce6 <alltraps>

80107f79 <vector207>:
.globl vector207
vector207:
  pushl $0
80107f79:	6a 00                	push   $0x0
  pushl $207
80107f7b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107f80:	e9 61 ed ff ff       	jmp    80106ce6 <alltraps>

80107f85 <vector208>:
.globl vector208
vector208:
  pushl $0
80107f85:	6a 00                	push   $0x0
  pushl $208
80107f87:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107f8c:	e9 55 ed ff ff       	jmp    80106ce6 <alltraps>

80107f91 <vector209>:
.globl vector209
vector209:
  pushl $0
80107f91:	6a 00                	push   $0x0
  pushl $209
80107f93:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107f98:	e9 49 ed ff ff       	jmp    80106ce6 <alltraps>

80107f9d <vector210>:
.globl vector210
vector210:
  pushl $0
80107f9d:	6a 00                	push   $0x0
  pushl $210
80107f9f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107fa4:	e9 3d ed ff ff       	jmp    80106ce6 <alltraps>

80107fa9 <vector211>:
.globl vector211
vector211:
  pushl $0
80107fa9:	6a 00                	push   $0x0
  pushl $211
80107fab:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107fb0:	e9 31 ed ff ff       	jmp    80106ce6 <alltraps>

80107fb5 <vector212>:
.globl vector212
vector212:
  pushl $0
80107fb5:	6a 00                	push   $0x0
  pushl $212
80107fb7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107fbc:	e9 25 ed ff ff       	jmp    80106ce6 <alltraps>

80107fc1 <vector213>:
.globl vector213
vector213:
  pushl $0
80107fc1:	6a 00                	push   $0x0
  pushl $213
80107fc3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107fc8:	e9 19 ed ff ff       	jmp    80106ce6 <alltraps>

80107fcd <vector214>:
.globl vector214
vector214:
  pushl $0
80107fcd:	6a 00                	push   $0x0
  pushl $214
80107fcf:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107fd4:	e9 0d ed ff ff       	jmp    80106ce6 <alltraps>

80107fd9 <vector215>:
.globl vector215
vector215:
  pushl $0
80107fd9:	6a 00                	push   $0x0
  pushl $215
80107fdb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107fe0:	e9 01 ed ff ff       	jmp    80106ce6 <alltraps>

80107fe5 <vector216>:
.globl vector216
vector216:
  pushl $0
80107fe5:	6a 00                	push   $0x0
  pushl $216
80107fe7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107fec:	e9 f5 ec ff ff       	jmp    80106ce6 <alltraps>

80107ff1 <vector217>:
.globl vector217
vector217:
  pushl $0
80107ff1:	6a 00                	push   $0x0
  pushl $217
80107ff3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107ff8:	e9 e9 ec ff ff       	jmp    80106ce6 <alltraps>

80107ffd <vector218>:
.globl vector218
vector218:
  pushl $0
80107ffd:	6a 00                	push   $0x0
  pushl $218
80107fff:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108004:	e9 dd ec ff ff       	jmp    80106ce6 <alltraps>

80108009 <vector219>:
.globl vector219
vector219:
  pushl $0
80108009:	6a 00                	push   $0x0
  pushl $219
8010800b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108010:	e9 d1 ec ff ff       	jmp    80106ce6 <alltraps>

80108015 <vector220>:
.globl vector220
vector220:
  pushl $0
80108015:	6a 00                	push   $0x0
  pushl $220
80108017:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010801c:	e9 c5 ec ff ff       	jmp    80106ce6 <alltraps>

80108021 <vector221>:
.globl vector221
vector221:
  pushl $0
80108021:	6a 00                	push   $0x0
  pushl $221
80108023:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108028:	e9 b9 ec ff ff       	jmp    80106ce6 <alltraps>

8010802d <vector222>:
.globl vector222
vector222:
  pushl $0
8010802d:	6a 00                	push   $0x0
  pushl $222
8010802f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108034:	e9 ad ec ff ff       	jmp    80106ce6 <alltraps>

80108039 <vector223>:
.globl vector223
vector223:
  pushl $0
80108039:	6a 00                	push   $0x0
  pushl $223
8010803b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108040:	e9 a1 ec ff ff       	jmp    80106ce6 <alltraps>

80108045 <vector224>:
.globl vector224
vector224:
  pushl $0
80108045:	6a 00                	push   $0x0
  pushl $224
80108047:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010804c:	e9 95 ec ff ff       	jmp    80106ce6 <alltraps>

80108051 <vector225>:
.globl vector225
vector225:
  pushl $0
80108051:	6a 00                	push   $0x0
  pushl $225
80108053:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108058:	e9 89 ec ff ff       	jmp    80106ce6 <alltraps>

8010805d <vector226>:
.globl vector226
vector226:
  pushl $0
8010805d:	6a 00                	push   $0x0
  pushl $226
8010805f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108064:	e9 7d ec ff ff       	jmp    80106ce6 <alltraps>

80108069 <vector227>:
.globl vector227
vector227:
  pushl $0
80108069:	6a 00                	push   $0x0
  pushl $227
8010806b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108070:	e9 71 ec ff ff       	jmp    80106ce6 <alltraps>

80108075 <vector228>:
.globl vector228
vector228:
  pushl $0
80108075:	6a 00                	push   $0x0
  pushl $228
80108077:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010807c:	e9 65 ec ff ff       	jmp    80106ce6 <alltraps>

80108081 <vector229>:
.globl vector229
vector229:
  pushl $0
80108081:	6a 00                	push   $0x0
  pushl $229
80108083:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108088:	e9 59 ec ff ff       	jmp    80106ce6 <alltraps>

8010808d <vector230>:
.globl vector230
vector230:
  pushl $0
8010808d:	6a 00                	push   $0x0
  pushl $230
8010808f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108094:	e9 4d ec ff ff       	jmp    80106ce6 <alltraps>

80108099 <vector231>:
.globl vector231
vector231:
  pushl $0
80108099:	6a 00                	push   $0x0
  pushl $231
8010809b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801080a0:	e9 41 ec ff ff       	jmp    80106ce6 <alltraps>

801080a5 <vector232>:
.globl vector232
vector232:
  pushl $0
801080a5:	6a 00                	push   $0x0
  pushl $232
801080a7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801080ac:	e9 35 ec ff ff       	jmp    80106ce6 <alltraps>

801080b1 <vector233>:
.globl vector233
vector233:
  pushl $0
801080b1:	6a 00                	push   $0x0
  pushl $233
801080b3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801080b8:	e9 29 ec ff ff       	jmp    80106ce6 <alltraps>

801080bd <vector234>:
.globl vector234
vector234:
  pushl $0
801080bd:	6a 00                	push   $0x0
  pushl $234
801080bf:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801080c4:	e9 1d ec ff ff       	jmp    80106ce6 <alltraps>

801080c9 <vector235>:
.globl vector235
vector235:
  pushl $0
801080c9:	6a 00                	push   $0x0
  pushl $235
801080cb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801080d0:	e9 11 ec ff ff       	jmp    80106ce6 <alltraps>

801080d5 <vector236>:
.globl vector236
vector236:
  pushl $0
801080d5:	6a 00                	push   $0x0
  pushl $236
801080d7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801080dc:	e9 05 ec ff ff       	jmp    80106ce6 <alltraps>

801080e1 <vector237>:
.globl vector237
vector237:
  pushl $0
801080e1:	6a 00                	push   $0x0
  pushl $237
801080e3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801080e8:	e9 f9 eb ff ff       	jmp    80106ce6 <alltraps>

801080ed <vector238>:
.globl vector238
vector238:
  pushl $0
801080ed:	6a 00                	push   $0x0
  pushl $238
801080ef:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801080f4:	e9 ed eb ff ff       	jmp    80106ce6 <alltraps>

801080f9 <vector239>:
.globl vector239
vector239:
  pushl $0
801080f9:	6a 00                	push   $0x0
  pushl $239
801080fb:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108100:	e9 e1 eb ff ff       	jmp    80106ce6 <alltraps>

80108105 <vector240>:
.globl vector240
vector240:
  pushl $0
80108105:	6a 00                	push   $0x0
  pushl $240
80108107:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010810c:	e9 d5 eb ff ff       	jmp    80106ce6 <alltraps>

80108111 <vector241>:
.globl vector241
vector241:
  pushl $0
80108111:	6a 00                	push   $0x0
  pushl $241
80108113:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108118:	e9 c9 eb ff ff       	jmp    80106ce6 <alltraps>

8010811d <vector242>:
.globl vector242
vector242:
  pushl $0
8010811d:	6a 00                	push   $0x0
  pushl $242
8010811f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108124:	e9 bd eb ff ff       	jmp    80106ce6 <alltraps>

80108129 <vector243>:
.globl vector243
vector243:
  pushl $0
80108129:	6a 00                	push   $0x0
  pushl $243
8010812b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108130:	e9 b1 eb ff ff       	jmp    80106ce6 <alltraps>

80108135 <vector244>:
.globl vector244
vector244:
  pushl $0
80108135:	6a 00                	push   $0x0
  pushl $244
80108137:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010813c:	e9 a5 eb ff ff       	jmp    80106ce6 <alltraps>

80108141 <vector245>:
.globl vector245
vector245:
  pushl $0
80108141:	6a 00                	push   $0x0
  pushl $245
80108143:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108148:	e9 99 eb ff ff       	jmp    80106ce6 <alltraps>

8010814d <vector246>:
.globl vector246
vector246:
  pushl $0
8010814d:	6a 00                	push   $0x0
  pushl $246
8010814f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108154:	e9 8d eb ff ff       	jmp    80106ce6 <alltraps>

80108159 <vector247>:
.globl vector247
vector247:
  pushl $0
80108159:	6a 00                	push   $0x0
  pushl $247
8010815b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108160:	e9 81 eb ff ff       	jmp    80106ce6 <alltraps>

80108165 <vector248>:
.globl vector248
vector248:
  pushl $0
80108165:	6a 00                	push   $0x0
  pushl $248
80108167:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010816c:	e9 75 eb ff ff       	jmp    80106ce6 <alltraps>

80108171 <vector249>:
.globl vector249
vector249:
  pushl $0
80108171:	6a 00                	push   $0x0
  pushl $249
80108173:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108178:	e9 69 eb ff ff       	jmp    80106ce6 <alltraps>

8010817d <vector250>:
.globl vector250
vector250:
  pushl $0
8010817d:	6a 00                	push   $0x0
  pushl $250
8010817f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108184:	e9 5d eb ff ff       	jmp    80106ce6 <alltraps>

80108189 <vector251>:
.globl vector251
vector251:
  pushl $0
80108189:	6a 00                	push   $0x0
  pushl $251
8010818b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108190:	e9 51 eb ff ff       	jmp    80106ce6 <alltraps>

80108195 <vector252>:
.globl vector252
vector252:
  pushl $0
80108195:	6a 00                	push   $0x0
  pushl $252
80108197:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010819c:	e9 45 eb ff ff       	jmp    80106ce6 <alltraps>

801081a1 <vector253>:
.globl vector253
vector253:
  pushl $0
801081a1:	6a 00                	push   $0x0
  pushl $253
801081a3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801081a8:	e9 39 eb ff ff       	jmp    80106ce6 <alltraps>

801081ad <vector254>:
.globl vector254
vector254:
  pushl $0
801081ad:	6a 00                	push   $0x0
  pushl $254
801081af:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801081b4:	e9 2d eb ff ff       	jmp    80106ce6 <alltraps>

801081b9 <vector255>:
.globl vector255
vector255:
  pushl $0
801081b9:	6a 00                	push   $0x0
  pushl $255
801081bb:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801081c0:	e9 21 eb ff ff       	jmp    80106ce6 <alltraps>

801081c5 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801081c5:	55                   	push   %ebp
801081c6:	89 e5                	mov    %esp,%ebp
801081c8:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801081cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ce:	83 e8 01             	sub    $0x1,%eax
801081d1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801081d5:	8b 45 08             	mov    0x8(%ebp),%eax
801081d8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801081dc:	8b 45 08             	mov    0x8(%ebp),%eax
801081df:	c1 e8 10             	shr    $0x10,%eax
801081e2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801081e6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801081e9:	0f 01 10             	lgdtl  (%eax)
}
801081ec:	c9                   	leave  
801081ed:	c3                   	ret    

801081ee <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801081ee:	55                   	push   %ebp
801081ef:	89 e5                	mov    %esp,%ebp
801081f1:	83 ec 04             	sub    $0x4,%esp
801081f4:	8b 45 08             	mov    0x8(%ebp),%eax
801081f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801081fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801081ff:	0f 00 d8             	ltr    %ax
}
80108202:	c9                   	leave  
80108203:	c3                   	ret    

80108204 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108204:	55                   	push   %ebp
80108205:	89 e5                	mov    %esp,%ebp
80108207:	83 ec 04             	sub    $0x4,%esp
8010820a:	8b 45 08             	mov    0x8(%ebp),%eax
8010820d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108211:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108215:	8e e8                	mov    %eax,%gs
}
80108217:	c9                   	leave  
80108218:	c3                   	ret    

80108219 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108219:	55                   	push   %ebp
8010821a:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010821c:	8b 45 08             	mov    0x8(%ebp),%eax
8010821f:	0f 22 d8             	mov    %eax,%cr3
}
80108222:	5d                   	pop    %ebp
80108223:	c3                   	ret    

80108224 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108224:	55                   	push   %ebp
80108225:	89 e5                	mov    %esp,%ebp
80108227:	8b 45 08             	mov    0x8(%ebp),%eax
8010822a:	05 00 00 00 80       	add    $0x80000000,%eax
8010822f:	5d                   	pop    %ebp
80108230:	c3                   	ret    

80108231 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108231:	55                   	push   %ebp
80108232:	89 e5                	mov    %esp,%ebp
80108234:	8b 45 08             	mov    0x8(%ebp),%eax
80108237:	05 00 00 00 80       	add    $0x80000000,%eax
8010823c:	5d                   	pop    %ebp
8010823d:	c3                   	ret    

8010823e <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010823e:	55                   	push   %ebp
8010823f:	89 e5                	mov    %esp,%ebp
80108241:	53                   	push   %ebx
80108242:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108245:	e8 2e ac ff ff       	call   80102e78 <cpunum>
8010824a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108250:	05 80 33 11 80       	add    $0x80113380,%eax
80108255:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108264:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010826a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108274:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108278:	83 e2 f0             	and    $0xfffffff0,%edx
8010827b:	83 ca 0a             	or     $0xa,%edx
8010827e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108284:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108288:	83 ca 10             	or     $0x10,%edx
8010828b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010828e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108291:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108295:	83 e2 9f             	and    $0xffffff9f,%edx
80108298:	88 50 7d             	mov    %dl,0x7d(%eax)
8010829b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801082a2:	83 ca 80             	or     $0xffffff80,%edx
801082a5:	88 50 7d             	mov    %dl,0x7d(%eax)
801082a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ab:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801082af:	83 ca 0f             	or     $0xf,%edx
801082b2:	88 50 7e             	mov    %dl,0x7e(%eax)
801082b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801082bc:	83 e2 ef             	and    $0xffffffef,%edx
801082bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801082c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801082c9:	83 e2 df             	and    $0xffffffdf,%edx
801082cc:	88 50 7e             	mov    %dl,0x7e(%eax)
801082cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801082d6:	83 ca 40             	or     $0x40,%edx
801082d9:	88 50 7e             	mov    %dl,0x7e(%eax)
801082dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082df:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801082e3:	83 ca 80             	or     $0xffffff80,%edx
801082e6:	88 50 7e             	mov    %dl,0x7e(%eax)
801082e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ec:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801082f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f3:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801082fa:	ff ff 
801082fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ff:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108306:	00 00 
80108308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108312:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108315:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010831c:	83 e2 f0             	and    $0xfffffff0,%edx
8010831f:	83 ca 02             	or     $0x2,%edx
80108322:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108332:	83 ca 10             	or     $0x10,%edx
80108335:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108345:	83 e2 9f             	and    $0xffffff9f,%edx
80108348:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010834e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108351:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108358:	83 ca 80             	or     $0xffffff80,%edx
8010835b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108364:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010836b:	83 ca 0f             	or     $0xf,%edx
8010836e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108377:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010837e:	83 e2 ef             	and    $0xffffffef,%edx
80108381:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108391:	83 e2 df             	and    $0xffffffdf,%edx
80108394:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010839a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801083a4:	83 ca 40             	or     $0x40,%edx
801083a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801083ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801083b7:	83 ca 80             	or     $0xffffff80,%edx
801083ba:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801083c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801083d4:	ff ff 
801083d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d9:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801083e0:	00 00 
801083e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e5:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801083f6:	83 e2 f0             	and    $0xfffffff0,%edx
801083f9:	83 ca 0a             	or     $0xa,%edx
801083fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108405:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010840c:	83 ca 10             	or     $0x10,%edx
8010840f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010841f:	83 ca 60             	or     $0x60,%edx
80108422:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108432:	83 ca 80             	or     $0xffffff80,%edx
80108435:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108445:	83 ca 0f             	or     $0xf,%edx
80108448:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108458:	83 e2 ef             	and    $0xffffffef,%edx
8010845b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108464:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010846b:	83 e2 df             	and    $0xffffffdf,%edx
8010846e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108477:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010847e:	83 ca 40             	or     $0x40,%edx
80108481:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108491:	83 ca 80             	or     $0xffffff80,%edx
80108494:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010849a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801084a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a7:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801084ae:	ff ff 
801084b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b3:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801084ba:	00 00 
801084bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bf:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801084c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801084d0:	83 e2 f0             	and    $0xfffffff0,%edx
801084d3:	83 ca 02             	or     $0x2,%edx
801084d6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801084dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084df:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801084e6:	83 ca 10             	or     $0x10,%edx
801084e9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801084ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801084f9:	83 ca 60             	or     $0x60,%edx
801084fc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108505:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010850c:	83 ca 80             	or     $0xffffff80,%edx
8010850f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108518:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010851f:	83 ca 0f             	or     $0xf,%edx
80108522:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108532:	83 e2 ef             	and    $0xffffffef,%edx
80108535:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108545:	83 e2 df             	and    $0xffffffdf,%edx
80108548:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108558:	83 ca 40             	or     $0x40,%edx
8010855b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010856b:	83 ca 80             	or     $0xffffff80,%edx
8010856e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108577:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010857e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108581:	05 b4 00 00 00       	add    $0xb4,%eax
80108586:	89 c3                	mov    %eax,%ebx
80108588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858b:	05 b4 00 00 00       	add    $0xb4,%eax
80108590:	c1 e8 10             	shr    $0x10,%eax
80108593:	89 c1                	mov    %eax,%ecx
80108595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108598:	05 b4 00 00 00       	add    $0xb4,%eax
8010859d:	c1 e8 18             	shr    $0x18,%eax
801085a0:	89 c2                	mov    %eax,%edx
801085a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a5:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801085ac:	00 00 
801085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b1:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801085b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bb:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801085c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c4:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801085cb:	83 e1 f0             	and    $0xfffffff0,%ecx
801085ce:	83 c9 02             	or     $0x2,%ecx
801085d1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801085d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085da:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801085e1:	83 c9 10             	or     $0x10,%ecx
801085e4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801085ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ed:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801085f4:	83 e1 9f             	and    $0xffffff9f,%ecx
801085f7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801085fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108600:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108607:	83 c9 80             	or     $0xffffff80,%ecx
8010860a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108613:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010861a:	83 e1 f0             	and    $0xfffffff0,%ecx
8010861d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108626:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010862d:	83 e1 ef             	and    $0xffffffef,%ecx
80108630:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108639:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108640:	83 e1 df             	and    $0xffffffdf,%ecx
80108643:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108653:	83 c9 40             	or     $0x40,%ecx
80108656:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010865c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108666:	83 c9 80             	or     $0xffffff80,%ecx
80108669:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010866f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108672:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867b:	83 c0 70             	add    $0x70,%eax
8010867e:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108685:	00 
80108686:	89 04 24             	mov    %eax,(%esp)
80108689:	e8 37 fb ff ff       	call   801081c5 <lgdt>
  loadgs(SEG_KCPU << 3);
8010868e:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108695:	e8 6a fb ff ff       	call   80108204 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801086a3:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801086aa:	00 00 00 00 
}
801086ae:	83 c4 24             	add    $0x24,%esp
801086b1:	5b                   	pop    %ebx
801086b2:	5d                   	pop    %ebp
801086b3:	c3                   	ret    

801086b4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801086b4:	55                   	push   %ebp
801086b5:	89 e5                	mov    %esp,%ebp
801086b7:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801086ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801086bd:	c1 e8 16             	shr    $0x16,%eax
801086c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086c7:	8b 45 08             	mov    0x8(%ebp),%eax
801086ca:	01 d0                	add    %edx,%eax
801086cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801086cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d2:	8b 00                	mov    (%eax),%eax
801086d4:	83 e0 01             	and    $0x1,%eax
801086d7:	85 c0                	test   %eax,%eax
801086d9:	74 17                	je     801086f2 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801086db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086de:	8b 00                	mov    (%eax),%eax
801086e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e5:	89 04 24             	mov    %eax,(%esp)
801086e8:	e8 44 fb ff ff       	call   80108231 <p2v>
801086ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086f0:	eb 4b                	jmp    8010873d <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801086f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801086f6:	74 0e                	je     80108706 <walkpgdir+0x52>
801086f8:	e8 e5 a3 ff ff       	call   80102ae2 <kalloc>
801086fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108700:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108704:	75 07                	jne    8010870d <walkpgdir+0x59>
      return 0;
80108706:	b8 00 00 00 00       	mov    $0x0,%eax
8010870b:	eb 47                	jmp    80108754 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010870d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108714:	00 
80108715:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010871c:	00 
8010871d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108720:	89 04 24             	mov    %eax,(%esp)
80108723:	e8 4e d0 ff ff       	call   80105776 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	89 04 24             	mov    %eax,(%esp)
8010872e:	e8 f1 fa ff ff       	call   80108224 <v2p>
80108733:	83 c8 07             	or     $0x7,%eax
80108736:	89 c2                	mov    %eax,%edx
80108738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010873d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108740:	c1 e8 0c             	shr    $0xc,%eax
80108743:	25 ff 03 00 00       	and    $0x3ff,%eax
80108748:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010874f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108752:	01 d0                	add    %edx,%eax
}
80108754:	c9                   	leave  
80108755:	c3                   	ret    

80108756 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108756:	55                   	push   %ebp
80108757:	89 e5                	mov    %esp,%ebp
80108759:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010875c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010875f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108764:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108767:	8b 55 0c             	mov    0xc(%ebp),%edx
8010876a:	8b 45 10             	mov    0x10(%ebp),%eax
8010876d:	01 d0                	add    %edx,%eax
8010876f:	83 e8 01             	sub    $0x1,%eax
80108772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010877a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108781:	00 
80108782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108785:	89 44 24 04          	mov    %eax,0x4(%esp)
80108789:	8b 45 08             	mov    0x8(%ebp),%eax
8010878c:	89 04 24             	mov    %eax,(%esp)
8010878f:	e8 20 ff ff ff       	call   801086b4 <walkpgdir>
80108794:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108797:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010879b:	75 07                	jne    801087a4 <mappages+0x4e>
      return -1;
8010879d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087a2:	eb 48                	jmp    801087ec <mappages+0x96>
    if(*pte & PTE_P)
801087a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a7:	8b 00                	mov    (%eax),%eax
801087a9:	83 e0 01             	and    $0x1,%eax
801087ac:	85 c0                	test   %eax,%eax
801087ae:	74 0c                	je     801087bc <mappages+0x66>
      panic("remap");
801087b0:	c7 04 24 e8 95 10 80 	movl   $0x801095e8,(%esp)
801087b7:	e8 7e 7d ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801087bc:	8b 45 18             	mov    0x18(%ebp),%eax
801087bf:	0b 45 14             	or     0x14(%ebp),%eax
801087c2:	83 c8 01             	or     $0x1,%eax
801087c5:	89 c2                	mov    %eax,%edx
801087c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ca:	89 10                	mov    %edx,(%eax)
    if(a == last)
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801087d2:	75 08                	jne    801087dc <mappages+0x86>
      break;
801087d4:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801087d5:	b8 00 00 00 00       	mov    $0x0,%eax
801087da:	eb 10                	jmp    801087ec <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801087dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801087e3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801087ea:	eb 8e                	jmp    8010877a <mappages+0x24>
  return 0;
}
801087ec:	c9                   	leave  
801087ed:	c3                   	ret    

801087ee <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801087ee:	55                   	push   %ebp
801087ef:	89 e5                	mov    %esp,%ebp
801087f1:	53                   	push   %ebx
801087f2:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801087f5:	e8 e8 a2 ff ff       	call   80102ae2 <kalloc>
801087fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801087fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108801:	75 0a                	jne    8010880d <setupkvm+0x1f>
    return 0;
80108803:	b8 00 00 00 00       	mov    $0x0,%eax
80108808:	e9 98 00 00 00       	jmp    801088a5 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
8010880d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108814:	00 
80108815:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010881c:	00 
8010881d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108820:	89 04 24             	mov    %eax,(%esp)
80108823:	e8 4e cf ff ff       	call   80105776 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108828:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010882f:	e8 fd f9 ff ff       	call   80108231 <p2v>
80108834:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108839:	76 0c                	jbe    80108847 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010883b:	c7 04 24 ee 95 10 80 	movl   $0x801095ee,(%esp)
80108842:	e8 f3 7c ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108847:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
8010884e:	eb 49                	jmp    80108899 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108853:	8b 48 0c             	mov    0xc(%eax),%ecx
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108859:	8b 50 04             	mov    0x4(%eax),%edx
8010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885f:	8b 58 08             	mov    0x8(%eax),%ebx
80108862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108865:	8b 40 04             	mov    0x4(%eax),%eax
80108868:	29 c3                	sub    %eax,%ebx
8010886a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886d:	8b 00                	mov    (%eax),%eax
8010886f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108873:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108877:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010887b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010887f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108882:	89 04 24             	mov    %eax,(%esp)
80108885:	e8 cc fe ff ff       	call   80108756 <mappages>
8010888a:	85 c0                	test   %eax,%eax
8010888c:	79 07                	jns    80108895 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010888e:	b8 00 00 00 00       	mov    $0x0,%eax
80108893:	eb 10                	jmp    801088a5 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108895:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108899:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801088a0:	72 ae                	jb     80108850 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801088a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801088a5:	83 c4 34             	add    $0x34,%esp
801088a8:	5b                   	pop    %ebx
801088a9:	5d                   	pop    %ebp
801088aa:	c3                   	ret    

801088ab <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801088ab:	55                   	push   %ebp
801088ac:	89 e5                	mov    %esp,%ebp
801088ae:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801088b1:	e8 38 ff ff ff       	call   801087ee <setupkvm>
801088b6:	a3 98 8f 11 80       	mov    %eax,0x80118f98
  switchkvm();
801088bb:	e8 02 00 00 00       	call   801088c2 <switchkvm>
}
801088c0:	c9                   	leave  
801088c1:	c3                   	ret    

801088c2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801088c2:	55                   	push   %ebp
801088c3:	89 e5                	mov    %esp,%ebp
801088c5:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801088c8:	a1 98 8f 11 80       	mov    0x80118f98,%eax
801088cd:	89 04 24             	mov    %eax,(%esp)
801088d0:	e8 4f f9 ff ff       	call   80108224 <v2p>
801088d5:	89 04 24             	mov    %eax,(%esp)
801088d8:	e8 3c f9 ff ff       	call   80108219 <lcr3>
}
801088dd:	c9                   	leave  
801088de:	c3                   	ret    

801088df <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801088df:	55                   	push   %ebp
801088e0:	89 e5                	mov    %esp,%ebp
801088e2:	53                   	push   %ebx
801088e3:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801088e6:	e8 8b cd ff ff       	call   80105676 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801088eb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088f1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801088f8:	83 c2 08             	add    $0x8,%edx
801088fb:	89 d3                	mov    %edx,%ebx
801088fd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108904:	83 c2 08             	add    $0x8,%edx
80108907:	c1 ea 10             	shr    $0x10,%edx
8010890a:	89 d1                	mov    %edx,%ecx
8010890c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108913:	83 c2 08             	add    $0x8,%edx
80108916:	c1 ea 18             	shr    $0x18,%edx
80108919:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108920:	67 00 
80108922:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108929:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010892f:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108936:	83 e1 f0             	and    $0xfffffff0,%ecx
80108939:	83 c9 09             	or     $0x9,%ecx
8010893c:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108942:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108949:	83 c9 10             	or     $0x10,%ecx
8010894c:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108952:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108959:	83 e1 9f             	and    $0xffffff9f,%ecx
8010895c:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108962:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108969:	83 c9 80             	or     $0xffffff80,%ecx
8010896c:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108972:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108979:	83 e1 f0             	and    $0xfffffff0,%ecx
8010897c:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108982:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108989:	83 e1 ef             	and    $0xffffffef,%ecx
8010898c:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108992:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108999:	83 e1 df             	and    $0xffffffdf,%ecx
8010899c:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801089a2:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801089a9:	83 c9 40             	or     $0x40,%ecx
801089ac:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801089b2:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801089b9:	83 e1 7f             	and    $0x7f,%ecx
801089bc:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801089c2:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801089c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089ce:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801089d5:	83 e2 ef             	and    $0xffffffef,%edx
801089d8:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801089de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089e4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801089ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801089f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801089f7:	8b 52 08             	mov    0x8(%edx),%edx
801089fa:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108a00:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108a03:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108a0a:	e8 df f7 ff ff       	call   801081ee <ltr>
  if(p->pgdir == 0)
80108a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a12:	8b 40 04             	mov    0x4(%eax),%eax
80108a15:	85 c0                	test   %eax,%eax
80108a17:	75 0c                	jne    80108a25 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108a19:	c7 04 24 ff 95 10 80 	movl   $0x801095ff,(%esp)
80108a20:	e8 15 7b ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108a25:	8b 45 08             	mov    0x8(%ebp),%eax
80108a28:	8b 40 04             	mov    0x4(%eax),%eax
80108a2b:	89 04 24             	mov    %eax,(%esp)
80108a2e:	e8 f1 f7 ff ff       	call   80108224 <v2p>
80108a33:	89 04 24             	mov    %eax,(%esp)
80108a36:	e8 de f7 ff ff       	call   80108219 <lcr3>
  popcli();
80108a3b:	e8 7a cc ff ff       	call   801056ba <popcli>
}
80108a40:	83 c4 14             	add    $0x14,%esp
80108a43:	5b                   	pop    %ebx
80108a44:	5d                   	pop    %ebp
80108a45:	c3                   	ret    

80108a46 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108a46:	55                   	push   %ebp
80108a47:	89 e5                	mov    %esp,%ebp
80108a49:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108a4c:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108a53:	76 0c                	jbe    80108a61 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108a55:	c7 04 24 13 96 10 80 	movl   $0x80109613,(%esp)
80108a5c:	e8 d9 7a ff ff       	call   8010053a <panic>
  mem = kalloc();
80108a61:	e8 7c a0 ff ff       	call   80102ae2 <kalloc>
80108a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108a69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a70:	00 
80108a71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a78:	00 
80108a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7c:	89 04 24             	mov    %eax,(%esp)
80108a7f:	e8 f2 cc ff ff       	call   80105776 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a87:	89 04 24             	mov    %eax,(%esp)
80108a8a:	e8 95 f7 ff ff       	call   80108224 <v2p>
80108a8f:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108a96:	00 
80108a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108a9b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aa2:	00 
80108aa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108aaa:	00 
80108aab:	8b 45 08             	mov    0x8(%ebp),%eax
80108aae:	89 04 24             	mov    %eax,(%esp)
80108ab1:	e8 a0 fc ff ff       	call   80108756 <mappages>
  memmove(mem, init, sz);
80108ab6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ab9:	89 44 24 08          	mov    %eax,0x8(%esp)
80108abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac7:	89 04 24             	mov    %eax,(%esp)
80108aca:	e8 76 cd ff ff       	call   80105845 <memmove>
}
80108acf:	c9                   	leave  
80108ad0:	c3                   	ret    

80108ad1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108ad1:	55                   	push   %ebp
80108ad2:	89 e5                	mov    %esp,%ebp
80108ad4:	53                   	push   %ebx
80108ad5:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108adb:	25 ff 0f 00 00       	and    $0xfff,%eax
80108ae0:	85 c0                	test   %eax,%eax
80108ae2:	74 0c                	je     80108af0 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108ae4:	c7 04 24 30 96 10 80 	movl   $0x80109630,(%esp)
80108aeb:	e8 4a 7a ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108af0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108af7:	e9 a9 00 00 00       	jmp    80108ba5 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aff:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b02:	01 d0                	add    %edx,%eax
80108b04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b0b:	00 
80108b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b10:	8b 45 08             	mov    0x8(%ebp),%eax
80108b13:	89 04 24             	mov    %eax,(%esp)
80108b16:	e8 99 fb ff ff       	call   801086b4 <walkpgdir>
80108b1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b22:	75 0c                	jne    80108b30 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108b24:	c7 04 24 53 96 10 80 	movl   $0x80109653,(%esp)
80108b2b:	e8 0a 7a ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b33:	8b 00                	mov    (%eax),%eax
80108b35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b40:	8b 55 18             	mov    0x18(%ebp),%edx
80108b43:	29 c2                	sub    %eax,%edx
80108b45:	89 d0                	mov    %edx,%eax
80108b47:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108b4c:	77 0f                	ja     80108b5d <loaduvm+0x8c>
      n = sz - i;
80108b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b51:	8b 55 18             	mov    0x18(%ebp),%edx
80108b54:	29 c2                	sub    %eax,%edx
80108b56:	89 d0                	mov    %edx,%eax
80108b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b5b:	eb 07                	jmp    80108b64 <loaduvm+0x93>
    else
      n = PGSIZE;
80108b5d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b67:	8b 55 14             	mov    0x14(%ebp),%edx
80108b6a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b70:	89 04 24             	mov    %eax,(%esp)
80108b73:	e8 b9 f6 ff ff       	call   80108231 <p2v>
80108b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108b7f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108b83:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b87:	8b 45 10             	mov    0x10(%ebp),%eax
80108b8a:	89 04 24             	mov    %eax,(%esp)
80108b8d:	e8 d6 91 ff ff       	call   80101d68 <readi>
80108b92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b95:	74 07                	je     80108b9e <loaduvm+0xcd>
      return -1;
80108b97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b9c:	eb 18                	jmp    80108bb6 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108b9e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba8:	3b 45 18             	cmp    0x18(%ebp),%eax
80108bab:	0f 82 4b ff ff ff    	jb     80108afc <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108bb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bb6:	83 c4 24             	add    $0x24,%esp
80108bb9:	5b                   	pop    %ebx
80108bba:	5d                   	pop    %ebp
80108bbb:	c3                   	ret    

80108bbc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108bbc:	55                   	push   %ebp
80108bbd:	89 e5                	mov    %esp,%ebp
80108bbf:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108bc2:	8b 45 10             	mov    0x10(%ebp),%eax
80108bc5:	85 c0                	test   %eax,%eax
80108bc7:	79 0a                	jns    80108bd3 <allocuvm+0x17>
    return 0;
80108bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80108bce:	e9 c1 00 00 00       	jmp    80108c94 <allocuvm+0xd8>
  if(newsz < oldsz)
80108bd3:	8b 45 10             	mov    0x10(%ebp),%eax
80108bd6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108bd9:	73 08                	jae    80108be3 <allocuvm+0x27>
    return oldsz;
80108bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bde:	e9 b1 00 00 00       	jmp    80108c94 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108be6:	05 ff 0f 00 00       	add    $0xfff,%eax
80108beb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108bf3:	e9 8d 00 00 00       	jmp    80108c85 <allocuvm+0xc9>
    mem = kalloc();
80108bf8:	e8 e5 9e ff ff       	call   80102ae2 <kalloc>
80108bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c04:	75 2c                	jne    80108c32 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108c06:	c7 04 24 71 96 10 80 	movl   $0x80109671,(%esp)
80108c0d:	e8 8e 77 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108c12:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c15:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c19:	8b 45 10             	mov    0x10(%ebp),%eax
80108c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c20:	8b 45 08             	mov    0x8(%ebp),%eax
80108c23:	89 04 24             	mov    %eax,(%esp)
80108c26:	e8 6b 00 00 00       	call   80108c96 <deallocuvm>
      return 0;
80108c2b:	b8 00 00 00 00       	mov    $0x0,%eax
80108c30:	eb 62                	jmp    80108c94 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108c32:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c39:	00 
80108c3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108c41:	00 
80108c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c45:	89 04 24             	mov    %eax,(%esp)
80108c48:	e8 29 cb ff ff       	call   80105776 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c50:	89 04 24             	mov    %eax,(%esp)
80108c53:	e8 cc f5 ff ff       	call   80108224 <v2p>
80108c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108c5b:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108c62:	00 
80108c63:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108c67:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c6e:	00 
80108c6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80108c73:	8b 45 08             	mov    0x8(%ebp),%eax
80108c76:	89 04 24             	mov    %eax,(%esp)
80108c79:	e8 d8 fa ff ff       	call   80108756 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108c7e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c88:	3b 45 10             	cmp    0x10(%ebp),%eax
80108c8b:	0f 82 67 ff ff ff    	jb     80108bf8 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108c91:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c94:	c9                   	leave  
80108c95:	c3                   	ret    

80108c96 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c96:	55                   	push   %ebp
80108c97:	89 e5                	mov    %esp,%ebp
80108c99:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108c9c:	8b 45 10             	mov    0x10(%ebp),%eax
80108c9f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ca2:	72 08                	jb     80108cac <deallocuvm+0x16>
    return oldsz;
80108ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ca7:	e9 a4 00 00 00       	jmp    80108d50 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108cac:	8b 45 10             	mov    0x10(%ebp),%eax
80108caf:	05 ff 0f 00 00       	add    $0xfff,%eax
80108cb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108cbc:	e9 80 00 00 00       	jmp    80108d41 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ccb:	00 
80108ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd3:	89 04 24             	mov    %eax,(%esp)
80108cd6:	e8 d9 f9 ff ff       	call   801086b4 <walkpgdir>
80108cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108cde:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ce2:	75 09                	jne    80108ced <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108ce4:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108ceb:	eb 4d                	jmp    80108d3a <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf0:	8b 00                	mov    (%eax),%eax
80108cf2:	83 e0 01             	and    $0x1,%eax
80108cf5:	85 c0                	test   %eax,%eax
80108cf7:	74 41                	je     80108d3a <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cfc:	8b 00                	mov    (%eax),%eax
80108cfe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108d06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d0a:	75 0c                	jne    80108d18 <deallocuvm+0x82>
        panic("kfree");
80108d0c:	c7 04 24 89 96 10 80 	movl   $0x80109689,(%esp)
80108d13:	e8 22 78 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108d18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d1b:	89 04 24             	mov    %eax,(%esp)
80108d1e:	e8 0e f5 ff ff       	call   80108231 <p2v>
80108d23:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108d26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d29:	89 04 24             	mov    %eax,(%esp)
80108d2c:	e8 18 9d ff ff       	call   80102a49 <kfree>
      *pte = 0;
80108d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108d3a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d44:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d47:	0f 82 74 ff ff ff    	jb     80108cc1 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108d4d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d50:	c9                   	leave  
80108d51:	c3                   	ret    

80108d52 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108d52:	55                   	push   %ebp
80108d53:	89 e5                	mov    %esp,%ebp
80108d55:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108d58:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108d5c:	75 0c                	jne    80108d6a <freevm+0x18>
    panic("freevm: no pgdir");
80108d5e:	c7 04 24 8f 96 10 80 	movl   $0x8010968f,(%esp)
80108d65:	e8 d0 77 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108d6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d71:	00 
80108d72:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108d79:	80 
80108d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108d7d:	89 04 24             	mov    %eax,(%esp)
80108d80:	e8 11 ff ff ff       	call   80108c96 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108d85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d8c:	eb 48                	jmp    80108dd6 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d98:	8b 45 08             	mov    0x8(%ebp),%eax
80108d9b:	01 d0                	add    %edx,%eax
80108d9d:	8b 00                	mov    (%eax),%eax
80108d9f:	83 e0 01             	and    $0x1,%eax
80108da2:	85 c0                	test   %eax,%eax
80108da4:	74 2c                	je     80108dd2 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108db0:	8b 45 08             	mov    0x8(%ebp),%eax
80108db3:	01 d0                	add    %edx,%eax
80108db5:	8b 00                	mov    (%eax),%eax
80108db7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dbc:	89 04 24             	mov    %eax,(%esp)
80108dbf:	e8 6d f4 ff ff       	call   80108231 <p2v>
80108dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dca:	89 04 24             	mov    %eax,(%esp)
80108dcd:	e8 77 9c ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108dd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dd6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ddd:	76 af                	jbe    80108d8e <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80108de2:	89 04 24             	mov    %eax,(%esp)
80108de5:	e8 5f 9c ff ff       	call   80102a49 <kfree>
}
80108dea:	c9                   	leave  
80108deb:	c3                   	ret    

80108dec <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108dec:	55                   	push   %ebp
80108ded:	89 e5                	mov    %esp,%ebp
80108def:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108df2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108df9:	00 
80108dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e01:	8b 45 08             	mov    0x8(%ebp),%eax
80108e04:	89 04 24             	mov    %eax,(%esp)
80108e07:	e8 a8 f8 ff ff       	call   801086b4 <walkpgdir>
80108e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108e0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108e13:	75 0c                	jne    80108e21 <clearpteu+0x35>
    panic("clearpteu");
80108e15:	c7 04 24 a0 96 10 80 	movl   $0x801096a0,(%esp)
80108e1c:	e8 19 77 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e24:	8b 00                	mov    (%eax),%eax
80108e26:	83 e0 fb             	and    $0xfffffffb,%eax
80108e29:	89 c2                	mov    %eax,%edx
80108e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2e:	89 10                	mov    %edx,(%eax)
}
80108e30:	c9                   	leave  
80108e31:	c3                   	ret    

80108e32 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108e32:	55                   	push   %ebp
80108e33:	89 e5                	mov    %esp,%ebp
80108e35:	53                   	push   %ebx
80108e36:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108e39:	e8 b0 f9 ff ff       	call   801087ee <setupkvm>
80108e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e45:	75 0a                	jne    80108e51 <copyuvm+0x1f>
    return 0;
80108e47:	b8 00 00 00 00       	mov    $0x0,%eax
80108e4c:	e9 fd 00 00 00       	jmp    80108f4e <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108e51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e58:	e9 d0 00 00 00       	jmp    80108f2d <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e67:	00 
80108e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108e6f:	89 04 24             	mov    %eax,(%esp)
80108e72:	e8 3d f8 ff ff       	call   801086b4 <walkpgdir>
80108e77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e7e:	75 0c                	jne    80108e8c <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108e80:	c7 04 24 aa 96 10 80 	movl   $0x801096aa,(%esp)
80108e87:	e8 ae 76 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108e8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e8f:	8b 00                	mov    (%eax),%eax
80108e91:	83 e0 01             	and    $0x1,%eax
80108e94:	85 c0                	test   %eax,%eax
80108e96:	75 0c                	jne    80108ea4 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108e98:	c7 04 24 c4 96 10 80 	movl   $0x801096c4,(%esp)
80108e9f:	e8 96 76 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108ea4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea7:	8b 00                	mov    (%eax),%eax
80108ea9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108eb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb4:	8b 00                	mov    (%eax),%eax
80108eb6:	25 ff 0f 00 00       	and    $0xfff,%eax
80108ebb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108ebe:	e8 1f 9c ff ff       	call   80102ae2 <kalloc>
80108ec3:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ec6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108eca:	75 02                	jne    80108ece <copyuvm+0x9c>
      goto bad;
80108ecc:	eb 70                	jmp    80108f3e <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108ece:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ed1:	89 04 24             	mov    %eax,(%esp)
80108ed4:	e8 58 f3 ff ff       	call   80108231 <p2v>
80108ed9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ee0:	00 
80108ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ee8:	89 04 24             	mov    %eax,(%esp)
80108eeb:	e8 55 c9 ff ff       	call   80105845 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108ef0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108ef3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ef6:	89 04 24             	mov    %eax,(%esp)
80108ef9:	e8 26 f3 ff ff       	call   80108224 <v2p>
80108efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f01:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108f05:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108f09:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f10:	00 
80108f11:	89 54 24 04          	mov    %edx,0x4(%esp)
80108f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f18:	89 04 24             	mov    %eax,(%esp)
80108f1b:	e8 36 f8 ff ff       	call   80108756 <mappages>
80108f20:	85 c0                	test   %eax,%eax
80108f22:	79 02                	jns    80108f26 <copyuvm+0xf4>
      goto bad;
80108f24:	eb 18                	jmp    80108f3e <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108f26:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f30:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f33:	0f 82 24 ff ff ff    	jb     80108e5d <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3c:	eb 10                	jmp    80108f4e <copyuvm+0x11c>

bad:
  freevm(d);
80108f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f41:	89 04 24             	mov    %eax,(%esp)
80108f44:	e8 09 fe ff ff       	call   80108d52 <freevm>
  return 0;
80108f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f4e:	83 c4 44             	add    $0x44,%esp
80108f51:	5b                   	pop    %ebx
80108f52:	5d                   	pop    %ebp
80108f53:	c3                   	ret    

80108f54 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108f54:	55                   	push   %ebp
80108f55:	89 e5                	mov    %esp,%ebp
80108f57:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f61:	00 
80108f62:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f65:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f69:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6c:	89 04 24             	mov    %eax,(%esp)
80108f6f:	e8 40 f7 ff ff       	call   801086b4 <walkpgdir>
80108f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7a:	8b 00                	mov    (%eax),%eax
80108f7c:	83 e0 01             	and    $0x1,%eax
80108f7f:	85 c0                	test   %eax,%eax
80108f81:	75 07                	jne    80108f8a <uva2ka+0x36>
    return 0;
80108f83:	b8 00 00 00 00       	mov    $0x0,%eax
80108f88:	eb 25                	jmp    80108faf <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f8d:	8b 00                	mov    (%eax),%eax
80108f8f:	83 e0 04             	and    $0x4,%eax
80108f92:	85 c0                	test   %eax,%eax
80108f94:	75 07                	jne    80108f9d <uva2ka+0x49>
    return 0;
80108f96:	b8 00 00 00 00       	mov    $0x0,%eax
80108f9b:	eb 12                	jmp    80108faf <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa0:	8b 00                	mov    (%eax),%eax
80108fa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fa7:	89 04 24             	mov    %eax,(%esp)
80108faa:	e8 82 f2 ff ff       	call   80108231 <p2v>
}
80108faf:	c9                   	leave  
80108fb0:	c3                   	ret    

80108fb1 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108fb1:	55                   	push   %ebp
80108fb2:	89 e5                	mov    %esp,%ebp
80108fb4:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80108fba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108fbd:	e9 87 00 00 00       	jmp    80109049 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fc5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80108fd7:	89 04 24             	mov    %eax,(%esp)
80108fda:	e8 75 ff ff ff       	call   80108f54 <uva2ka>
80108fdf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108fe2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108fe6:	75 07                	jne    80108fef <copyout+0x3e>
      return -1;
80108fe8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fed:	eb 69                	jmp    80109058 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108ff5:	29 c2                	sub    %eax,%edx
80108ff7:	89 d0                	mov    %edx,%eax
80108ff9:	05 00 10 00 00       	add    $0x1000,%eax
80108ffe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109004:	3b 45 14             	cmp    0x14(%ebp),%eax
80109007:	76 06                	jbe    8010900f <copyout+0x5e>
      n = len;
80109009:	8b 45 14             	mov    0x14(%ebp),%eax
8010900c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010900f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109012:	8b 55 0c             	mov    0xc(%ebp),%edx
80109015:	29 c2                	sub    %eax,%edx
80109017:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010901a:	01 c2                	add    %eax,%edx
8010901c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901f:	89 44 24 08          	mov    %eax,0x8(%esp)
80109023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109026:	89 44 24 04          	mov    %eax,0x4(%esp)
8010902a:	89 14 24             	mov    %edx,(%esp)
8010902d:	e8 13 c8 ff ff       	call   80105845 <memmove>
    len -= n;
80109032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109035:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109038:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010903b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010903e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109041:	05 00 10 00 00       	add    $0x1000,%eax
80109046:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109049:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010904d:	0f 85 6f ff ff ff    	jne    80108fc2 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109053:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109058:	c9                   	leave  
80109059:	c3                   	ret    
