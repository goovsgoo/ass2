
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
8010003a:	c7 44 24 04 60 8f 10 	movl   $0x80108f60,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 c4 53 00 00       	call   80105412 <initlock>

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
801000bd:	e8 71 53 00 00       	call   80105433 <acquire>

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
80100104:	e8 8c 53 00 00       	call   80105495 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 63 4d 00 00       	call   80104e87 <sleep>
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
8010017c:	e8 14 53 00 00       	call   80105495 <release>
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
80100198:	c7 04 24 67 8f 10 80 	movl   $0x80108f67,(%esp)
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
801001ef:	c7 04 24 78 8f 10 80 	movl   $0x80108f78,(%esp)
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
80100229:	c7 04 24 7f 8f 10 80 	movl   $0x80108f7f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 f2 51 00 00       	call   80105433 <acquire>

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
8010029d:	e8 c1 4c 00 00       	call   80104f63 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 e7 51 00 00       	call   80105495 <release>
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
801003bb:	e8 73 50 00 00       	call   80105433 <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 86 8f 10 80 	movl   $0x80108f86,(%esp)
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
801004b0:	c7 45 ec 8f 8f 10 80 	movl   $0x80108f8f,-0x14(%ebp)
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
80100533:	e8 5d 4f 00 00       	call   80105495 <release>
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
8010055f:	c7 04 24 96 8f 10 80 	movl   $0x80108f96,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 a5 8f 10 80 	movl   $0x80108fa5,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 50 4f 00 00       	call   801054e4 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 a7 8f 10 80 	movl   $0x80108fa7,(%esp)
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
801006b2:	e8 9f 50 00 00       	call   80105756 <memmove>
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
801006e1:	e8 a1 4f 00 00       	call   80105687 <memset>
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
80100776:	e8 25 6e 00 00       	call   801075a0 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 19 6e 00 00       	call   801075a0 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 0d 6e 00 00       	call   801075a0 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 00 6e 00 00       	call   801075a0 <uartputc>
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
801007ba:	e8 74 4c 00 00       	call   80105433 <acquire>
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
801007ea:	e8 1a 48 00 00       	call   80105009 <procdump>
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
801008f3:	e8 6b 46 00 00       	call   80104f63 <wakeup>
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
80100914:	e8 7c 4b 00 00       	call   80105495 <release>
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
80100939:	e8 f5 4a 00 00       	call   80105433 <acquire>
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
80100959:	e8 37 4b 00 00       	call   80105495 <release>
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
80100982:	e8 00 45 00 00       	call   80104e87 <sleep>

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
801009fe:	e8 92 4a 00 00       	call   80105495 <release>
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
80100a32:	e8 fc 49 00 00       	call   80105433 <acquire>
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
80100a6c:	e8 24 4a 00 00       	call   80105495 <release>
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
80100a87:	c7 44 24 04 ab 8f 10 	movl   $0x80108fab,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a96:	e8 77 49 00 00       	call   80105412 <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 b3 8f 10 	movl   $0x80108fb3,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100aaa:	e8 63 49 00 00       	call   80105412 <initlock>

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
80100b73:	e8 79 7b 00 00       	call   801086f1 <setupkvm>
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
80100c14:	e8 a6 7e 00 00       	call   80108abf <allocuvm>
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
80100c52:	e8 7d 7d 00 00       	call   801089d4 <loaduvm>
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
80100cc0:	e8 fa 7d 00 00       	call   80108abf <allocuvm>
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
80100ce5:	e8 05 80 00 00       	call   80108cef <clearpteu>
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
80100d1b:	e8 d1 4b 00 00       	call   801058f1 <strlen>
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
80100d44:	e8 a8 4b 00 00       	call   801058f1 <strlen>
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
80100d74:	e8 3b 81 00 00       	call   80108eb4 <copyout>
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
80100e1b:	e8 94 80 00 00       	call   80108eb4 <copyout>
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
80100e73:	e8 2f 4a 00 00       	call   801058a7 <safestrcpy>

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
80100ec5:	e8 18 79 00 00       	call   801087e2 <switchuvm>
  freevm(oldpgdir);
80100eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ecd:	89 04 24             	mov    %eax,(%esp)
80100ed0:	e8 80 7d 00 00       	call   80108c55 <freevm>
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
80100ee8:	e8 68 7d 00 00       	call   80108c55 <freevm>
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
80100f10:	c7 44 24 04 b9 8f 10 	movl   $0x80108fb9,0x4(%esp)
80100f17:	80 
80100f18:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f1f:	e8 ee 44 00 00       	call   80105412 <initlock>
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
80100f33:	e8 fb 44 00 00       	call   80105433 <acquire>
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
80100f5c:	e8 34 45 00 00       	call   80105495 <release>
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
80100f7a:	e8 16 45 00 00       	call   80105495 <release>
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
80100f93:	e8 9b 44 00 00       	call   80105433 <acquire>
  if(f->ref < 1)
80100f98:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9b:	8b 40 04             	mov    0x4(%eax),%eax
80100f9e:	85 c0                	test   %eax,%eax
80100fa0:	7f 0c                	jg     80100fae <filedup+0x28>
    panic("filedup");
80100fa2:	c7 04 24 c0 8f 10 80 	movl   $0x80108fc0,(%esp)
80100fa9:	e8 8c f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fae:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb1:	8b 40 04             	mov    0x4(%eax),%eax
80100fb4:	8d 50 01             	lea    0x1(%eax),%edx
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fba:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbd:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fc4:	e8 cc 44 00 00       	call   80105495 <release>
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
80100fdb:	e8 53 44 00 00       	call   80105433 <acquire>
  if(f->ref < 1)
80100fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe3:	8b 40 04             	mov    0x4(%eax),%eax
80100fe6:	85 c0                	test   %eax,%eax
80100fe8:	7f 0c                	jg     80100ff6 <fileclose+0x28>
    panic("fileclose");
80100fea:	c7 04 24 c8 8f 10 80 	movl   $0x80108fc8,(%esp)
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
80101016:	e8 7a 44 00 00       	call   80105495 <release>
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
80101060:	e8 30 44 00 00       	call   80105495 <release>
  
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
801011a1:	c7 04 24 d2 8f 10 80 	movl   $0x80108fd2,(%esp)
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
801012ad:	c7 04 24 db 8f 10 80 	movl   $0x80108fdb,(%esp)
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
801012df:	c7 04 24 eb 8f 10 80 	movl   $0x80108feb,(%esp)
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
80101325:	e8 2c 44 00 00       	call   80105756 <memmove>
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
8010136b:	e8 17 43 00 00       	call   80105687 <memset>
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
801014c8:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
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
8010155a:	c7 04 24 0b 90 10 80 	movl   $0x8010900b,(%esp)
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
801015aa:	c7 44 24 04 1e 90 10 	movl   $0x8010901e,0x4(%esp)
801015b1:	80 
801015b2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801015b9:	e8 54 3e 00 00       	call   80105412 <initlock>
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
8010163b:	e8 47 40 00 00       	call   80105687 <memset>
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
80101691:	c7 04 24 25 90 10 80 	movl   $0x80109025,(%esp)
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
8010173a:	e8 17 40 00 00       	call   80105756 <memmove>
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
80101764:	e8 ca 3c 00 00       	call   80105433 <acquire>

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
801017ae:	e8 e2 3c 00 00       	call   80105495 <release>
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
801017e1:	c7 04 24 37 90 10 80 	movl   $0x80109037,(%esp)
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
8010181f:	e8 71 3c 00 00       	call   80105495 <release>

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
80101836:	e8 f8 3b 00 00       	call   80105433 <acquire>
  ip->ref++;
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	8d 50 01             	lea    0x1(%eax),%edx
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101851:	e8 3f 3c 00 00       	call   80105495 <release>
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
80101871:	c7 04 24 47 90 10 80 	movl   $0x80109047,(%esp)
80101878:	e8 bd ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010187d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101884:	e8 aa 3b 00 00       	call   80105433 <acquire>
  while(ip->flags & I_BUSY)
80101889:	eb 13                	jmp    8010189e <ilock+0x43>
    sleep(ip, &icache.lock);
8010188b:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80101892:	80 
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	89 04 24             	mov    %eax,(%esp)
80101899:	e8 e9 35 00 00       	call   80104e87 <sleep>

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
801018c3:	e8 cd 3b 00 00       	call   80105495 <release>

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
8010196e:	e8 e3 3d 00 00       	call   80105756 <memmove>
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
8010199b:	c7 04 24 4d 90 10 80 	movl   $0x8010904d,(%esp)
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
801019cc:	c7 04 24 5c 90 10 80 	movl   $0x8010905c,(%esp)
801019d3:	e8 62 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019d8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801019df:	e8 4f 3a 00 00       	call   80105433 <acquire>
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
801019fb:	e8 63 35 00 00       	call   80104f63 <wakeup>
  release(&icache.lock);
80101a00:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a07:	e8 89 3a 00 00       	call   80105495 <release>
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
80101a1b:	e8 13 3a 00 00       	call   80105433 <acquire>
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
80101a59:	c7 04 24 64 90 10 80 	movl   $0x80109064,(%esp)
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
80101a7d:	e8 13 3a 00 00       	call   80105495 <release>
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
80101aa8:	e8 86 39 00 00       	call   80105433 <acquire>
    ip->flags = 0;
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 04 24             	mov    %eax,(%esp)
80101abd:	e8 a1 34 00 00       	call   80104f63 <wakeup>
  }
  ip->ref--;
80101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac5:	8b 40 08             	mov    0x8(%eax),%eax
80101ac8:	8d 50 ff             	lea    -0x1(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101ad8:	e8 b8 39 00 00       	call   80105495 <release>
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
80101bf8:	c7 04 24 6e 90 10 80 	movl   $0x8010906e,(%esp)
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
80101e99:	e8 b8 38 00 00       	call   80105756 <memmove>
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
80101ff8:	e8 59 37 00 00       	call   80105756 <memmove>
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
80102076:	e8 7e 37 00 00       	call   801057f9 <strncmp>
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
80102090:	c7 04 24 81 90 10 80 	movl   $0x80109081,(%esp)
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
801020ce:	c7 04 24 93 90 10 80 	movl   $0x80109093,(%esp)
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
801021b3:	c7 04 24 93 90 10 80 	movl   $0x80109093,(%esp)
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
801021f8:	e8 52 36 00 00       	call   8010584f <strncpy>
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
8010222a:	c7 04 24 a0 90 10 80 	movl   $0x801090a0,(%esp)
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
801022af:	e8 a2 34 00 00       	call   80105756 <memmove>
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
801022ca:	e8 87 34 00 00       	call   80105756 <memmove>
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
80102519:	c7 44 24 04 a8 90 10 	movl   $0x801090a8,0x4(%esp)
80102520:	80 
80102521:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102528:	e8 e5 2e 00 00       	call   80105412 <initlock>
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
801025c5:	c7 04 24 ac 90 10 80 	movl   $0x801090ac,(%esp)
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
801026eb:	e8 43 2d 00 00       	call   80105433 <acquire>
  if((b = idequeue) == 0){
801026f0:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801026f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026fc:	75 11                	jne    8010270f <ideintr+0x31>
    release(&idelock);
801026fe:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102705:	e8 8b 2d 00 00       	call   80105495 <release>
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
80102778:	e8 e6 27 00 00       	call   80104f63 <wakeup>
  
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
8010279a:	e8 f6 2c 00 00       	call   80105495 <release>
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
801027b3:	c7 04 24 b5 90 10 80 	movl   $0x801090b5,(%esp)
801027ba:	e8 7b dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	8b 00                	mov    (%eax),%eax
801027c4:	83 e0 06             	and    $0x6,%eax
801027c7:	83 f8 02             	cmp    $0x2,%eax
801027ca:	75 0c                	jne    801027d8 <iderw+0x37>
    panic("iderw: nothing to do");
801027cc:	c7 04 24 c9 90 10 80 	movl   $0x801090c9,(%esp)
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
801027eb:	c7 04 24 de 90 10 80 	movl   $0x801090de,(%esp)
801027f2:	e8 43 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027f7:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801027fe:	e8 30 2c 00 00       	call   80105433 <acquire>

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
80102859:	e8 29 26 00 00       	call   80104e87 <sleep>
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
80102872:	e8 1e 2c 00 00       	call   80105495 <release>
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
80102900:	c7 04 24 fc 90 10 80 	movl   $0x801090fc,(%esp)
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
801029ba:	c7 44 24 04 2e 91 10 	movl   $0x8010912e,0x4(%esp)
801029c1:	80 
801029c2:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
801029c9:	e8 44 2a 00 00       	call   80105412 <initlock>
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
80102a76:	c7 04 24 33 91 10 80 	movl   $0x80109133,(%esp)
80102a7d:	e8 b8 da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a89:	00 
80102a8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a91:	00 
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	89 04 24             	mov    %eax,(%esp)
80102a98:	e8 ea 2b 00 00       	call   80105687 <memset>

  if(kmem.use_lock)
80102a9d:	a1 74 32 11 80       	mov    0x80113274,%eax
80102aa2:	85 c0                	test   %eax,%eax
80102aa4:	74 0c                	je     80102ab2 <kfree+0x69>
    acquire(&kmem.lock);
80102aa6:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102aad:	e8 81 29 00 00       	call   80105433 <acquire>
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
80102adb:	e8 b5 29 00 00       	call   80105495 <release>
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
80102af8:	e8 36 29 00 00       	call   80105433 <acquire>
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
80102b25:	e8 6b 29 00 00       	call   80105495 <release>
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
80102ea5:	c7 04 24 3c 91 10 80 	movl   $0x8010913c,(%esp)
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
80103108:	e8 f1 25 00 00       	call   801056fe <memcmp>
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
80103208:	c7 44 24 04 68 91 10 	movl   $0x80109168,0x4(%esp)
8010320f:	80 
80103210:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103217:	e8 f6 21 00 00       	call   80105412 <initlock>
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
801032cb:	e8 86 24 00 00       	call   80105756 <memmove>
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
8010341d:	e8 11 20 00 00       	call   80105433 <acquire>
  while(1){
    if(log.committing){
80103422:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103427:	85 c0                	test   %eax,%eax
80103429:	74 16                	je     80103441 <begin_op+0x31>
      sleep(&log, &log.lock);
8010342b:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103432:	80 
80103433:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010343a:	e8 48 1a 00 00       	call   80104e87 <sleep>
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
8010346e:	e8 14 1a 00 00       	call   80104e87 <sleep>
80103473:	eb 1b                	jmp    80103490 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103475:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103482:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103489:	e8 07 20 00 00       	call   80105495 <release>
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
801034a8:	e8 86 1f 00 00       	call   80105433 <acquire>
  log.outstanding -= 1;
801034ad:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034b2:	83 e8 01             	sub    $0x1,%eax
801034b5:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801034ba:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034bf:	85 c0                	test   %eax,%eax
801034c1:	74 0c                	je     801034cf <end_op+0x3b>
    panic("log.committing");
801034c3:	c7 04 24 6c 91 10 80 	movl   $0x8010916c,(%esp)
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
801034f2:	e8 6c 1a 00 00       	call   80104f63 <wakeup>
  }
  release(&log.lock);
801034f7:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034fe:	e8 92 1f 00 00       	call   80105495 <release>

  if(do_commit){
80103503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103507:	74 33                	je     8010353c <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103509:	e8 de 00 00 00       	call   801035ec <commit>
    acquire(&log.lock);
8010350e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103515:	e8 19 1f 00 00       	call   80105433 <acquire>
    log.committing = 0;
8010351a:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103521:	00 00 00 
    wakeup(&log);
80103524:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010352b:	e8 33 1a 00 00       	call   80104f63 <wakeup>
    release(&log.lock);
80103530:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103537:	e8 59 1f 00 00       	call   80105495 <release>
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
801035b2:	e8 9f 21 00 00       	call   80105756 <memmove>
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
8010363d:	c7 04 24 7b 91 10 80 	movl   $0x8010917b,(%esp)
80103644:	e8 f1 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103649:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010364e:	85 c0                	test   %eax,%eax
80103650:	7f 0c                	jg     8010365e <log_write+0x43>
    panic("log_write outside of trans");
80103652:	c7 04 24 91 91 10 80 	movl   $0x80109191,(%esp)
80103659:	e8 dc ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
8010365e:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103665:	e8 c9 1d 00 00       	call   80105433 <acquire>
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
801036dc:	e8 b4 1d 00 00       	call   80105495 <release>
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
80103734:	e8 75 50 00 00       	call   801087ae <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 46 04 00 00       	call   80103b84 <mpinit>
  lapicinit();
8010373e:	e8 dc f5 ff ff       	call   80102d1f <lapicinit>
  seginit();       // set up segments
80103743:	e8 f9 49 00 00       	call   80108141 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103748:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	89 44 24 04          	mov    %eax,0x4(%esp)
80103758:	c7 04 24 ac 91 10 80 	movl   $0x801091ac,(%esp)
8010375f:	e8 3c cc ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103764:	e8 79 06 00 00       	call   80103de2 <picinit>
  ioapicinit();    // another interrupt controller
80103769:	e8 3c f1 ff ff       	call   801028aa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010376e:	e8 0e d3 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103773:	e8 18 3d 00 00       	call   80107490 <uartinit>
  pinit();         // process table
80103778:	e8 e0 0d 00 00       	call   8010455d <pinit>
  tvinit();        // trap vectors
8010377d:	e8 e7 34 00 00       	call   80106c69 <tvinit>
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
8010379f:	e8 03 34 00 00       	call   80106ba7 <timerinit>
  startothers();   // start other processors
801037a4:	e8 7f 00 00 00       	call   80103828 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b0:	8e 
801037b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037b8:	e8 2f f2 ff ff       	call   801029ec <kinit2>
  userinit();      // first user process
801037bd:	e8 e5 0e 00 00       	call   801046a7 <userinit>
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
801037cd:	e8 f3 4f 00 00       	call   801087c5 <switchkvm>
  seginit();
801037d2:	e8 6a 49 00 00       	call   80108141 <seginit>
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
801037f7:	c7 04 24 c3 91 10 80 	movl   $0x801091c3,(%esp)
801037fe:	e8 9d cb ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103803:	e8 d5 35 00 00       	call   80106ddd <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103808:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010380e:	05 a8 00 00 00       	add    $0xa8,%eax
80103813:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010381a:	00 
8010381b:	89 04 24             	mov    %eax,(%esp)
8010381e:	e8 da fe ff ff       	call   801036fd <xchg>
  scheduler();     // start running processes
80103823:	e8 b4 14 00 00       	call   80104cdc <scheduler>

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
80103855:	e8 fc 1e 00 00       	call   80105756 <memmove>

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
801039d7:	c7 44 24 04 d4 91 10 	movl   $0x801091d4,0x4(%esp)
801039de:	80 
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 14 1d 00 00       	call   801056fe <memcmp>
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
80103b18:	c7 44 24 04 d9 91 10 	movl   $0x801091d9,0x4(%esp)
80103b1f:	80 
80103b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b23:	89 04 24             	mov    %eax,(%esp)
80103b26:	e8 d3 1b 00 00       	call   801056fe <memcmp>
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
80103bf4:	8b 04 85 1c 92 10 80 	mov    -0x7fef6de4(,%eax,4),%eax
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
80103c2d:	c7 04 24 de 91 10 80 	movl   $0x801091de,(%esp)
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
80103cc0:	c7 04 24 fc 91 10 80 	movl   $0x801091fc,(%esp)
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
80103fb9:	c7 44 24 04 30 92 10 	movl   $0x80109230,0x4(%esp)
80103fc0:	80 
80103fc1:	89 04 24             	mov    %eax,(%esp)
80103fc4:	e8 49 14 00 00       	call   80105412 <initlock>
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
80104070:	e8 be 13 00 00       	call   80105433 <acquire>
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
80104093:	e8 cb 0e 00 00       	call   80104f63 <wakeup>
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
801040b2:	e8 ac 0e 00 00       	call   80104f63 <wakeup>
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
801040d7:	e8 b9 13 00 00       	call   80105495 <release>
    kfree((char*)p);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 62 e9 ff ff       	call   80102a49 <kfree>
801040e7:	eb 0b                	jmp    801040f4 <pipeclose+0x90>
  } else
    release(&p->lock);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 a1 13 00 00       	call   80105495 <release>
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
80104102:	e8 2c 13 00 00       	call   80105433 <acquire>
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
80104135:	e8 5b 13 00 00       	call   80105495 <release>
        return -1;
8010413a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010413f:	e9 9f 00 00 00       	jmp    801041e3 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	05 34 02 00 00       	add    $0x234,%eax
8010414c:	89 04 24             	mov    %eax,(%esp)
8010414f:	e8 0f 0e 00 00       	call   80104f63 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	8b 55 08             	mov    0x8(%ebp),%edx
8010415a:	81 c2 38 02 00 00    	add    $0x238,%edx
80104160:	89 44 24 04          	mov    %eax,0x4(%esp)
80104164:	89 14 24             	mov    %edx,(%esp)
80104167:	e8 1b 0d 00 00       	call   80104e87 <sleep>
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
801041d0:	e8 8e 0d 00 00       	call   80104f63 <wakeup>
  release(&p->lock);
801041d5:	8b 45 08             	mov    0x8(%ebp),%eax
801041d8:	89 04 24             	mov    %eax,(%esp)
801041db:	e8 b5 12 00 00       	call   80105495 <release>
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
801041f2:	e8 3c 12 00 00       	call   80105433 <acquire>
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
8010420c:	e8 84 12 00 00       	call   80105495 <release>
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
8010422e:	e8 54 0c 00 00       	call   80104e87 <sleep>
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
801042bd:	e8 a1 0c 00 00       	call   80104f63 <wakeup>
  release(&p->lock);
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	89 04 24             	mov    %eax,(%esp)
801042c8:	e8 c8 11 00 00       	call   80105495 <release>
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
80104359:	e8 d5 10 00 00       	call   80105433 <acquire>
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
80104381:	e8 0f 11 00 00       	call   80105495 <release>
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
80104395:	e8 99 10 00 00       	call   80105433 <acquire>
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
801043e0:	e8 b0 10 00 00       	call   80105495 <release>
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
80104494:	e8 9a 0f 00 00       	call   80105433 <acquire>
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
80104508:	e8 88 0f 00 00       	call   80105495 <release>
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
80104529:	e8 05 0f 00 00       	call   80105433 <acquire>
    struct proc * p = rrqueue.last;
8010452e:	a1 b8 39 11 80       	mov    0x801139b8,%eax
80104533:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == 0) {
80104536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010453a:	75 0e                	jne    8010454a <deliverTicketsToFIFOProcs+0x38>
	release(&rrqueue.lock);
8010453c:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104543:	e8 4d 0f 00 00       	call   80105495 <release>
	return;
80104548:	eb 11                	jmp    8010455b <deliverTicketsToFIFOProcs+0x49>
	    p->tickets = EXE_TICKETS + EXE_TICKETS*p->priority;
	    totalTickets += p->tickets;
	    p = p->rrprev;
	}	      
    #endif
    release(&rrqueue.lock);
8010454a:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104551:	e8 3f 0f 00 00       	call   80105495 <release>
    printRRQueue();
80104556:	e8 f1 fd ff ff       	call   8010434c <printRRQueue>
}
8010455b:	c9                   	leave  
8010455c:	c3                   	ret    

8010455d <pinit>:

void
pinit(void)
{
8010455d:	55                   	push   %ebp
8010455e:	89 e5                	mov    %esp,%ebp
80104560:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104563:	c7 44 24 04 35 92 10 	movl   $0x80109235,0x4(%esp)
8010456a:	80 
8010456b:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104572:	e8 9b 0e 00 00       	call   80105412 <initlock>
}
80104577:	c9                   	leave  
80104578:	c3                   	ret    

80104579 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104579:	55                   	push   %ebp
8010457a:	89 e5                	mov    %esp,%ebp
8010457c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010457f:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104586:	e8 a8 0e 00 00       	call   80105433 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010458b:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104592:	eb 7b                	jmp    8010460f <allocproc+0x96>
    if(p->state == UNUSED)
80104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104597:	8b 40 0c             	mov    0xc(%eax),%eax
8010459a:	85 c0                	test   %eax,%eax
8010459c:	75 6a                	jne    80104608 <allocproc+0x8f>
      goto found;
8010459e:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010459f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a2:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045a9:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801045ae:	8d 50 01             	lea    0x1(%eax),%edx
801045b1:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801045b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ba:	89 42 10             	mov    %eax,0x10(%edx)
//   p->tickets = EXE_TICKETS;
//   totalTickets += EXE_TICKETS;
  acquire(&tickslock);
801045bd:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801045c4:	e8 6a 0e 00 00       	call   80105433 <acquire>
  p->ctime = ticks;
801045c9:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801045ce:	89 c2                	mov    %eax,%edx
801045d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d3:	89 90 08 01 00 00    	mov    %edx,0x108(%eax)
  release(&tickslock);
801045d9:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801045e0:	e8 b0 0e 00 00       	call   80105495 <release>
  release(&ptable.lock);
801045e5:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801045ec:	e8 a4 0e 00 00       	call   80105495 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045f1:	e8 ec e4 ff ff       	call   80102ae2 <kalloc>
801045f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f9:	89 42 08             	mov    %eax,0x8(%edx)
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	8b 40 08             	mov    0x8(%eax),%eax
80104602:	85 c0                	test   %eax,%eax
80104604:	75 3a                	jne    80104640 <allocproc+0xc7>
80104606:	eb 27                	jmp    8010462f <allocproc+0xb6>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104608:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
8010460f:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104616:	0f 82 78 ff ff ff    	jb     80104594 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010461c:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104623:	e8 6d 0e 00 00       	call   80105495 <release>
  return 0;
80104628:	b8 00 00 00 00       	mov    $0x0,%eax
8010462d:	eb 76                	jmp    801046a5 <allocproc+0x12c>
  release(&tickslock);
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104639:	b8 00 00 00 00       	mov    $0x0,%eax
8010463e:	eb 65                	jmp    801046a5 <allocproc+0x12c>
  }
  sp = p->kstack + KSTACKSIZE;
80104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104643:	8b 40 08             	mov    0x8(%eax),%eax
80104646:	05 00 10 00 00       	add    $0x1000,%eax
8010464b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010464e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104655:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104658:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010465b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010465f:	ba 1c 6c 10 80       	mov    $0x80106c1c,%edx
80104664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104667:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104669:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010466d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104670:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104673:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
80104676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104679:	8b 40 20             	mov    0x20(%eax),%eax
8010467c:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104683:	00 
80104684:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010468b:	00 
8010468c:	89 04 24             	mov    %eax,(%esp)
8010468f:	e8 f3 0f 00 00       	call   80105687 <memset>
  p->context->eip = (uint)forkret;
80104694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104697:	8b 40 20             	mov    0x20(%eax),%eax
8010469a:	ba 5b 4e 10 80       	mov    $0x80104e5b,%edx
8010469f:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046a5:	c9                   	leave  
801046a6:	c3                   	ret    

801046a7 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801046a7:	55                   	push   %ebp
801046a8:	89 e5                	mov    %esp,%ebp
801046aa:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801046ad:	e8 c7 fe ff ff       	call   80104579 <allocproc>
801046b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801046b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b8:	a3 6c c6 10 80       	mov    %eax,0x8010c66c
  if((p->pgdir = setupkvm()) == 0)
801046bd:	e8 2f 40 00 00       	call   801086f1 <setupkvm>
801046c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c5:	89 42 04             	mov    %eax,0x4(%edx)
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	8b 40 04             	mov    0x4(%eax),%eax
801046ce:	85 c0                	test   %eax,%eax
801046d0:	75 0c                	jne    801046de <userinit+0x37>
    panic("userinit: out of memory?");
801046d2:	c7 04 24 3c 92 10 80 	movl   $0x8010923c,(%esp)
801046d9:	e8 5c be ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046de:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e6:	8b 40 04             	mov    0x4(%eax),%eax
801046e9:	89 54 24 08          	mov    %edx,0x8(%esp)
801046ed:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801046f4:	80 
801046f5:	89 04 24             	mov    %eax,(%esp)
801046f8:	e8 4c 42 00 00       	call   80108949 <inituvm>
  p->sz = PGSIZE;
801046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104700:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104709:	8b 40 18             	mov    0x18(%eax),%eax
8010470c:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104713:	00 
80104714:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010471b:	00 
8010471c:	89 04 24             	mov    %eax,(%esp)
8010471f:	e8 63 0f 00 00       	call   80105687 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104727:	8b 40 18             	mov    0x18(%eax),%eax
8010472a:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104733:	8b 40 18             	mov    0x18(%eax),%eax
80104736:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473f:	8b 40 18             	mov    0x18(%eax),%eax
80104742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104745:	8b 52 18             	mov    0x18(%edx),%edx
80104748:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010474c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104753:	8b 40 18             	mov    0x18(%eax),%eax
80104756:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104759:	8b 52 18             	mov    0x18(%edx),%edx
8010475c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104760:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104767:	8b 40 18             	mov    0x18(%eax),%eax
8010476a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104774:	8b 40 18             	mov    0x18(%eax),%eax
80104777:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010477e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104781:	8b 40 18             	mov    0x18(%eax),%eax
80104784:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010478b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478e:	83 c0 70             	add    $0x70,%eax
80104791:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104798:	00 
80104799:	c7 44 24 04 55 92 10 	movl   $0x80109255,0x4(%esp)
801047a0:	80 
801047a1:	89 04 24             	mov    %eax,(%esp)
801047a4:	e8 fe 10 00 00       	call   801058a7 <safestrcpy>
  p->cwd = namei("/");
801047a9:	c7 04 24 5e 92 10 80 	movl   $0x8010925e,(%esp)
801047b0:	e8 51 dc ff ff       	call   80102406 <namei>
801047b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047b8:	89 42 6c             	mov    %eax,0x6c(%edx)

  p->state = RUNNABLE;
801047bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047be:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
//   p->tickets = EXE_TICKETS;
#if defined(FRR) || defined(FCFS) || defined(PRS)
  pushProcToRRqueue(p);
#endif
}
801047c5:	c9                   	leave  
801047c6:	c3                   	ret    

801047c7 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047c7:	55                   	push   %ebp
801047c8:	89 e5                	mov    %esp,%ebp
801047ca:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801047cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d3:	8b 00                	mov    (%eax),%eax
801047d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047dc:	7e 34                	jle    80104812 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801047de:	8b 55 08             	mov    0x8(%ebp),%edx
801047e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e4:	01 c2                	add    %eax,%edx
801047e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ec:	8b 40 04             	mov    0x4(%eax),%eax
801047ef:	89 54 24 08          	mov    %edx,0x8(%esp)
801047f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801047fa:	89 04 24             	mov    %eax,(%esp)
801047fd:	e8 bd 42 00 00       	call   80108abf <allocuvm>
80104802:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104805:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104809:	75 41                	jne    8010484c <growproc+0x85>
      return -1;
8010480b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104810:	eb 58                	jmp    8010486a <growproc+0xa3>
  } else if(n < 0){
80104812:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104816:	79 34                	jns    8010484c <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104818:	8b 55 08             	mov    0x8(%ebp),%edx
8010481b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481e:	01 c2                	add    %eax,%edx
80104820:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104826:	8b 40 04             	mov    0x4(%eax),%eax
80104829:	89 54 24 08          	mov    %edx,0x8(%esp)
8010482d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104830:	89 54 24 04          	mov    %edx,0x4(%esp)
80104834:	89 04 24             	mov    %eax,(%esp)
80104837:	e8 5d 43 00 00       	call   80108b99 <deallocuvm>
8010483c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010483f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104843:	75 07                	jne    8010484c <growproc+0x85>
      return -1;
80104845:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010484a:	eb 1e                	jmp    8010486a <growproc+0xa3>
  }
  proc->sz = sz;
8010484c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104852:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104855:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485d:	89 04 24             	mov    %eax,(%esp)
80104860:	e8 7d 3f 00 00       	call   801087e2 <switchuvm>
  return 0;
80104865:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010486a:	c9                   	leave  
8010486b:	c3                   	ret    

8010486c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010486c:	55                   	push   %ebp
8010486d:	89 e5                	mov    %esp,%ebp
8010486f:	57                   	push   %edi
80104870:	56                   	push   %esi
80104871:	53                   	push   %ebx
80104872:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104875:	e8 ff fc ff ff       	call   80104579 <allocproc>
8010487a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010487d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104881:	75 0a                	jne    8010488d <fork+0x21>
    return -1;
80104883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104888:	e9 c8 01 00 00       	jmp    80104a55 <fork+0x1e9>
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010488d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104893:	8b 10                	mov    (%eax),%edx
80104895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489b:	8b 40 04             	mov    0x4(%eax),%eax
8010489e:	89 54 24 04          	mov    %edx,0x4(%esp)
801048a2:	89 04 24             	mov    %eax,(%esp)
801048a5:	e8 8b 44 00 00       	call   80108d35 <copyuvm>
801048aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048ad:	89 42 04             	mov    %eax,0x4(%edx)
801048b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b3:	8b 40 04             	mov    0x4(%eax),%eax
801048b6:	85 c0                	test   %eax,%eax
801048b8:	75 2c                	jne    801048e6 <fork+0x7a>
    kfree(np->kstack);
801048ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048bd:	8b 40 08             	mov    0x8(%eax),%eax
801048c0:	89 04 24             	mov    %eax,(%esp)
801048c3:	e8 81 e1 ff ff       	call   80102a49 <kfree>
    np->kstack = 0;
801048c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048e1:	e9 6f 01 00 00       	jmp    80104a55 <fork+0x1e9>
  }
  np->sz = proc->sz;
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	8b 10                	mov    (%eax),%edx
801048ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f1:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801048f3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048fd:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104900:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104903:	8b 50 18             	mov    0x18(%eax),%edx
80104906:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490c:	8b 40 18             	mov    0x18(%eax),%eax
8010490f:	89 c3                	mov    %eax,%ebx
80104911:	b8 13 00 00 00       	mov    $0x13,%eax
80104916:	89 d7                	mov    %edx,%edi
80104918:	89 de                	mov    %ebx,%esi
8010491a:	89 c1                	mov    %eax,%ecx
8010491c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010491e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104921:	8b 40 18             	mov    0x18(%eax),%eax
80104924:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010492b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104932:	eb 3d                	jmp    80104971 <fork+0x105>
    if(proc->ofile[i])
80104934:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010493d:	83 c2 08             	add    $0x8,%edx
80104940:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104944:	85 c0                	test   %eax,%eax
80104946:	74 25                	je     8010496d <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104948:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104951:	83 c2 08             	add    $0x8,%edx
80104954:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104958:	89 04 24             	mov    %eax,(%esp)
8010495b:	e8 26 c6 ff ff       	call   80100f86 <filedup>
80104960:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104963:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104966:	83 c1 08             	add    $0x8,%ecx
80104969:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010496d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104971:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104975:	7e bd                	jle    80104934 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497d:	8b 40 6c             	mov    0x6c(%eax),%eax
80104980:	89 04 24             	mov    %eax,(%esp)
80104983:	e8 a1 ce ff ff       	call   80101829 <idup>
80104988:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010498b:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010498e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104994:	8d 50 70             	lea    0x70(%eax),%edx
80104997:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010499a:	83 c0 70             	add    $0x70,%eax
8010499d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801049a4:	00 
801049a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801049a9:	89 04 24             	mov    %eax,(%esp)
801049ac:	e8 f6 0e 00 00       	call   801058a7 <safestrcpy>
 
  pid = np->pid;
801049b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b4:	8b 40 10             	mov    0x10(%eax),%eax
801049b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
   np->runQuanta = 0;		//reset proc Time
801049ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049bd:	c7 80 1c 01 00 00 00 	movl   $0x0,0x11c(%eax)
801049c4:	00 00 00 
   np->rutime = 0;
801049c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ca:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%eax)
801049d1:	00 00 00 
   acquire(&tickslock);
801049d4:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801049db:	e8 53 0a 00 00       	call   80105433 <acquire>
   np->ctime = ticks;
801049e0:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801049e5:	89 c2                	mov    %eax,%edx
801049e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ea:	89 90 08 01 00 00    	mov    %edx,0x108(%eax)
   release(&tickslock);
801049f0:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801049f7:	e8 99 0a 00 00       	call   80105495 <release>
   np->ttime	 = 0;
801049fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ff:	c7 80 0c 01 00 00 00 	movl   $0x0,0x10c(%eax)
80104a06:	00 00 00 
   np->stime	 = 0;
80104a09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a0c:	c7 80 10 01 00 00 00 	movl   $0x0,0x110(%eax)
80104a13:	00 00 00 
   np->retime	 = 0;
80104a16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a19:	c7 80 14 01 00 00 00 	movl   $0x0,0x114(%eax)
80104a20:	00 00 00 
   np->priority = 1;
80104a23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a26:	c7 80 20 01 00 00 01 	movl   $0x1,0x120(%eax)
80104a2d:	00 00 00 
  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a30:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104a37:	e8 f7 09 00 00       	call   80105433 <acquire>
  np->state = RUNNABLE;
80104a3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a3f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(np);
  #endif
  release(&ptable.lock);
80104a46:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104a4d:	e8 43 0a 00 00       	call   80105495 <release>
  
  return pid;
80104a52:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104a55:	83 c4 2c             	add    $0x2c,%esp
80104a58:	5b                   	pop    %ebx
80104a59:	5e                   	pop    %esi
80104a5a:	5f                   	pop    %edi
80104a5b:	5d                   	pop    %ebp
80104a5c:	c3                   	ret    

80104a5d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a5d:	55                   	push   %ebp
80104a5e:	89 e5                	mov    %esp,%ebp
80104a60:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104a63:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a6a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80104a6f:	39 c2                	cmp    %eax,%edx
80104a71:	75 0c                	jne    80104a7f <exit+0x22>
    panic("init exiting");
80104a73:	c7 04 24 60 92 10 80 	movl   $0x80109260,(%esp)
80104a7a:	e8 bb ba ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a86:	eb 44                	jmp    80104acc <exit+0x6f>
    if(proc->ofile[fd]){
80104a88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a91:	83 c2 08             	add    $0x8,%edx
80104a94:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a98:	85 c0                	test   %eax,%eax
80104a9a:	74 2c                	je     80104ac8 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104a9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aa5:	83 c2 08             	add    $0x8,%edx
80104aa8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104aac:	89 04 24             	mov    %eax,(%esp)
80104aaf:	e8 1a c5 ff ff       	call   80100fce <fileclose>
      proc->ofile[fd] = 0;
80104ab4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aba:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104abd:	83 c2 08             	add    $0x8,%edx
80104ac0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80104ac7:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ac8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104acc:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104ad0:	7e b6                	jle    80104a88 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104ad2:	e8 39 e9 ff ff       	call   80103410 <begin_op>
  iput(proc->cwd);
80104ad7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104add:	8b 40 6c             	mov    0x6c(%eax),%eax
80104ae0:	89 04 24             	mov    %eax,(%esp)
80104ae3:	e8 26 cf ff ff       	call   80101a0e <iput>
  end_op();
80104ae8:	e8 a7 e9 ff ff       	call   80103494 <end_op>
  proc->cwd = 0;
80104aed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af3:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)

  acquire(&ptable.lock);
80104afa:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104b01:	e8 2d 09 00 00       	call   80105433 <acquire>

//   totalTickets -= proc->tickets;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104b06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b0c:	8b 40 14             	mov    0x14(%eax),%eax
80104b0f:	89 04 24             	mov    %eax,(%esp)
80104b12:	e8 0b 04 00 00       	call   80104f22 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b17:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104b1e:	eb 3b                	jmp    80104b5b <exit+0xfe>
    if(p->parent == proc){
80104b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b23:	8b 50 14             	mov    0x14(%eax),%edx
80104b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2c:	39 c2                	cmp    %eax,%edx
80104b2e:	75 24                	jne    80104b54 <exit+0xf7>
      p->parent = initproc;
80104b30:	8b 15 6c c6 10 80    	mov    0x8010c66c,%edx
80104b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b39:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b42:	83 f8 05             	cmp    $0x5,%eax
80104b45:	75 0d                	jne    80104b54 <exit+0xf7>
        wakeup1(initproc);
80104b47:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80104b4c:	89 04 24             	mov    %eax,(%esp)
80104b4f:	e8 ce 03 00 00       	call   80104f22 <wakeup1>
//   totalTickets -= proc->tickets;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b54:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104b5b:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104b62:	72 bc                	jb     80104b20 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104b64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b6a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  acquire(&tickslock);
80104b71:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104b78:	e8 b6 08 00 00       	call   80105433 <acquire>
  proc->ttime = ticks;
80104b7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b83:	8b 15 40 8f 11 80    	mov    0x80118f40,%edx
80104b89:	89 90 0c 01 00 00    	mov    %edx,0x10c(%eax)
  release(&tickslock);
80104b8f:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80104b96:	e8 fa 08 00 00       	call   80105495 <release>
  sched();
80104b9b:	e8 d7 01 00 00       	call   80104d77 <sched>
  panic("zombie exit");
80104ba0:	c7 04 24 6d 92 10 80 	movl   $0x8010926d,(%esp)
80104ba7:	e8 8e b9 ff ff       	call   8010053a <panic>

80104bac <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104bac:	55                   	push   %ebp
80104bad:	89 e5                	mov    %esp,%ebp
80104baf:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104bb2:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104bb9:	e8 75 08 00 00       	call   80105433 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104bbe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc5:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104bcc:	e9 bb 00 00 00       	jmp    80104c8c <wait+0xe0>
      if(p->parent != proc)
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	8b 50 14             	mov    0x14(%eax),%edx
80104bd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdd:	39 c2                	cmp    %eax,%edx
80104bdf:	74 05                	je     80104be6 <wait+0x3a>
        continue;
80104be1:	e9 9f 00 00 00       	jmp    80104c85 <wait+0xd9>
      havekids = 1;
80104be6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf3:	83 f8 05             	cmp    $0x5,%eax
80104bf6:	0f 85 89 00 00 00    	jne    80104c85 <wait+0xd9>
        // Found one.
        pid = p->pid;
80104bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bff:	8b 40 10             	mov    0x10(%eax),%eax
80104c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c08:	8b 40 08             	mov    0x8(%eax),%eax
80104c0b:	89 04 24             	mov    %eax,(%esp)
80104c0e:	e8 36 de ff ff       	call   80102a49 <kfree>
        p->kstack = 0;
80104c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c20:	8b 40 04             	mov    0x4(%eax),%eax
80104c23:	89 04 24             	mov    %eax,(%esp)
80104c26:	e8 2a 40 00 00       	call   80108c55 <freevm>
        p->state = UNUSED;
80104c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c38:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c42:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4c:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c53:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
        p->runQuanta = 0;		//reset proc Time
80104c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5d:	c7 80 1c 01 00 00 00 	movl   $0x0,0x11c(%eax)
80104c64:	00 00 00 
        p->rutime = 0;
80104c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6a:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%eax)
80104c71:	00 00 00 
        release(&ptable.lock);
80104c74:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104c7b:	e8 15 08 00 00       	call   80105495 <release>
        return pid;
80104c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c83:	eb 55                	jmp    80104cda <wait+0x12e>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c85:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104c8c:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104c93:	0f 82 38 ff ff ff    	jb     80104bd1 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104c99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c9d:	74 0d                	je     80104cac <wait+0x100>
80104c9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca5:	8b 40 28             	mov    0x28(%eax),%eax
80104ca8:	85 c0                	test   %eax,%eax
80104caa:	74 13                	je     80104cbf <wait+0x113>
      release(&ptable.lock);
80104cac:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104cb3:	e8 dd 07 00 00       	call   80105495 <release>
      return -1;
80104cb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cbd:	eb 1b                	jmp    80104cda <wait+0x12e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104cbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc5:	c7 44 24 04 c0 39 11 	movl   $0x801139c0,0x4(%esp)
80104ccc:	80 
80104ccd:	89 04 24             	mov    %eax,(%esp)
80104cd0:	e8 b2 01 00 00       	call   80104e87 <sleep>
  }
80104cd5:	e9 e4 fe ff ff       	jmp    80104bbe <wait+0x12>
}
80104cda:	c9                   	leave  
80104cdb:	c3                   	ret    

80104cdc <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104cdc:	55                   	push   %ebp
80104cdd:	89 e5                	mov    %esp,%ebp
80104cdf:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104ce2:	e8 ff f5 ff ff       	call   801042e6 <sti>

    // Loop over process table looking for process to run.
acquire(&ptable.lock);    
80104ce7:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104cee:	e8 40 07 00 00       	call   80105433 <acquire>
#ifdef DEFAULT
    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cf3:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104cfa:	eb 61                	jmp    80104d5d <scheduler+0x81>
      if(p->state != RUNNABLE)
80104cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cff:	8b 40 0c             	mov    0xc(%eax),%eax
80104d02:	83 f8 03             	cmp    $0x3,%eax
80104d05:	74 02                	je     80104d09 <scheduler+0x2d>
        continue;
80104d07:	eb 4d                	jmp    80104d56 <scheduler+0x7a>
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d15:	89 04 24             	mov    %eax,(%esp)
80104d18:	e8 c5 3a 00 00       	call   801087e2 <switchuvm>
      p->state = RUNNING;
80104d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d20:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104d27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d2d:	8b 40 20             	mov    0x20(%eax),%eax
80104d30:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d37:	83 c2 04             	add    $0x4,%edx
80104d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d3e:	89 14 24             	mov    %edx,(%esp)
80104d41:	e8 d2 0b 00 00       	call   80105918 <swtch>
      switchkvm();
80104d46:	e8 7a 3a 00 00       	call   801087c5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104d4b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d52:	00 00 00 00 

    // Loop over process table looking for process to run.
acquire(&ptable.lock);    
#ifdef DEFAULT
    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d56:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104d5d:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104d64:	72 96                	jb     80104cfc <scheduler+0x20>
	// It should have changed its p->state before coming back.
	proc = 0;
	//break;
    }
#endif
release(&ptable.lock);
80104d66:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104d6d:	e8 23 07 00 00       	call   80105495 <release>
  }
80104d72:	e9 6b ff ff ff       	jmp    80104ce2 <scheduler+0x6>

80104d77 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d77:	55                   	push   %ebp
80104d78:	89 e5                	mov    %esp,%ebp
80104d7a:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d7d:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104d84:	e8 d4 07 00 00       	call   8010555d <holding>
80104d89:	85 c0                	test   %eax,%eax
80104d8b:	75 0c                	jne    80104d99 <sched+0x22>
    panic("sched ptable.lock");
80104d8d:	c7 04 24 79 92 10 80 	movl   $0x80109279,(%esp)
80104d94:	e8 a1 b7 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104d99:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d9f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104da5:	83 f8 01             	cmp    $0x1,%eax
80104da8:	74 0c                	je     80104db6 <sched+0x3f>
    panic("sched locks");
80104daa:	c7 04 24 8b 92 10 80 	movl   $0x8010928b,(%esp)
80104db1:	e8 84 b7 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104db6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbc:	8b 40 0c             	mov    0xc(%eax),%eax
80104dbf:	83 f8 04             	cmp    $0x4,%eax
80104dc2:	75 0c                	jne    80104dd0 <sched+0x59>
    panic("sched running");
80104dc4:	c7 04 24 97 92 10 80 	movl   $0x80109297,(%esp)
80104dcb:	e8 6a b7 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104dd0:	e8 01 f5 ff ff       	call   801042d6 <readeflags>
80104dd5:	25 00 02 00 00       	and    $0x200,%eax
80104dda:	85 c0                	test   %eax,%eax
80104ddc:	74 0c                	je     80104dea <sched+0x73>
    panic("sched interruptible");
80104dde:	c7 04 24 a5 92 10 80 	movl   $0x801092a5,(%esp)
80104de5:	e8 50 b7 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104dea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104df0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104df9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dff:	8b 40 04             	mov    0x4(%eax),%eax
80104e02:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e09:	83 c2 20             	add    $0x20,%edx
80104e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e10:	89 14 24             	mov    %edx,(%esp)
80104e13:	e8 00 0b 00 00       	call   80105918 <swtch>
  cpu->intena = intena;
80104e18:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e21:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104e27:	c9                   	leave  
80104e28:	c3                   	ret    

80104e29 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e29:	55                   	push   %ebp
80104e2a:	89 e5                	mov    %esp,%ebp
80104e2c:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e2f:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104e36:	e8 f8 05 00 00       	call   80105433 <acquire>
  proc->state = RUNNABLE;
80104e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e41:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(proc);
  #endif
  sched();
80104e48:	e8 2a ff ff ff       	call   80104d77 <sched>
  release(&ptable.lock);
80104e4d:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104e54:	e8 3c 06 00 00       	call   80105495 <release>
}
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e61:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104e68:	e8 28 06 00 00       	call   80105495 <release>

  if (first) {
80104e6d:	a1 18 c0 10 80       	mov    0x8010c018,%eax
80104e72:	85 c0                	test   %eax,%eax
80104e74:	74 0f                	je     80104e85 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e76:	c7 05 18 c0 10 80 00 	movl   $0x0,0x8010c018
80104e7d:	00 00 00 
    initlog();
80104e80:	e8 7d e3 ff ff       	call   80103202 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e85:	c9                   	leave  
80104e86:	c3                   	ret    

80104e87 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e87:	55                   	push   %ebp
80104e88:	89 e5                	mov    %esp,%ebp
80104e8a:	83 ec 18             	sub    $0x18,%esp
  //cprintf("I, process %d, went to sleep\n", proc->pid);
  if(proc == 0)
80104e8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e93:	85 c0                	test   %eax,%eax
80104e95:	75 0c                	jne    80104ea3 <sleep+0x1c>
    panic("sleep");
80104e97:	c7 04 24 b9 92 10 80 	movl   $0x801092b9,(%esp)
80104e9e:	e8 97 b6 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104ea3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ea7:	75 0c                	jne    80104eb5 <sleep+0x2e>
    panic("sleep without lk");
80104ea9:	c7 04 24 bf 92 10 80 	movl   $0x801092bf,(%esp)
80104eb0:	e8 85 b6 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104eb5:	81 7d 0c c0 39 11 80 	cmpl   $0x801139c0,0xc(%ebp)
80104ebc:	74 17                	je     80104ed5 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ebe:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104ec5:	e8 69 05 00 00       	call   80105433 <acquire>
    release(lk);
80104eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ecd:	89 04 24             	mov    %eax,(%esp)
80104ed0:	e8 c0 05 00 00       	call   80105495 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ed5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104edb:	8b 55 08             	mov    0x8(%ebp),%edx
80104ede:	89 50 24             	mov    %edx,0x24(%eax)
  proc->state = SLEEPING;
80104ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
//   totalTickets -= proc->tickets;
  sched();
80104eee:	e8 84 fe ff ff       	call   80104d77 <sched>

  // Tidy up.
  proc->chan = 0;
80104ef3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ef9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f00:	81 7d 0c c0 39 11 80 	cmpl   $0x801139c0,0xc(%ebp)
80104f07:	74 17                	je     80104f20 <sleep+0x99>
    release(&ptable.lock);
80104f09:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f10:	e8 80 05 00 00       	call   80105495 <release>
    acquire(lk);
80104f15:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f18:	89 04 24             	mov    %eax,(%esp)
80104f1b:	e8 13 05 00 00       	call   80105433 <acquire>
  }
}
80104f20:	c9                   	leave  
80104f21:	c3                   	ret    

80104f22 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f22:	55                   	push   %ebp
80104f23:	89 e5                	mov    %esp,%ebp
80104f25:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f28:	c7 45 fc f4 39 11 80 	movl   $0x801139f4,-0x4(%ebp)
80104f2f:	eb 27                	jmp    80104f58 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan){
80104f31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f34:	8b 40 0c             	mov    0xc(%eax),%eax
80104f37:	83 f8 02             	cmp    $0x2,%eax
80104f3a:	75 15                	jne    80104f51 <wakeup1+0x2f>
80104f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3f:	8b 40 24             	mov    0x24(%eax),%eax
80104f42:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f45:	75 0a                	jne    80104f51 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f4a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f51:	81 45 fc 34 01 00 00 	addl   $0x134,-0x4(%ebp)
80104f58:	81 7d fc f4 86 11 80 	cmpl   $0x801186f4,-0x4(%ebp)
80104f5f:	72 d0                	jb     80104f31 <wakeup1+0xf>
//       totalTickets += p->tickets;
      #if defined(FRR) || defined(FCFS) || defined(PRS)
	  pushProcToRRqueue(p);
      #endif
    }
}
80104f61:	c9                   	leave  
80104f62:	c3                   	ret    

80104f63 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f63:	55                   	push   %ebp
80104f64:	89 e5                	mov    %esp,%ebp
80104f66:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f69:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f70:	e8 be 04 00 00       	call   80105433 <acquire>
  wakeup1(chan);
80104f75:	8b 45 08             	mov    0x8(%ebp),%eax
80104f78:	89 04 24             	mov    %eax,(%esp)
80104f7b:	e8 a2 ff ff ff       	call   80104f22 <wakeup1>
  release(&ptable.lock);
80104f80:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f87:	e8 09 05 00 00       	call   80105495 <release>
}
80104f8c:	c9                   	leave  
80104f8d:	c3                   	ret    

80104f8e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f8e:	55                   	push   %ebp
80104f8f:	89 e5                	mov    %esp,%ebp
80104f91:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f94:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104f9b:	e8 93 04 00 00       	call   80105433 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fa0:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80104fa7:	eb 44                	jmp    80104fed <kill+0x5f>
    if(p->pid == pid){
80104fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fac:	8b 40 10             	mov    0x10(%eax),%eax
80104faf:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fb2:	75 32                	jne    80104fe6 <kill+0x58>
      p->killed = 1;
80104fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb7:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
80104fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fc4:	83 f8 02             	cmp    $0x2,%eax
80104fc7:	75 0a                	jne    80104fd3 <kill+0x45>
        p->state = RUNNABLE;
80104fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	#if defined(FRR) || defined(FCFS) || defined(PRS)
	    pushProcToRRqueue(p);
	#endif
      }
      release(&ptable.lock);
80104fd3:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104fda:	e8 b6 04 00 00       	call   80105495 <release>
      return 0;
80104fdf:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe4:	eb 21                	jmp    80105007 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe6:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
80104fed:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104ff4:	72 b3                	jb     80104fa9 <kill+0x1b>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ff6:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80104ffd:	e8 93 04 00 00       	call   80105495 <release>
  return -1;
80105002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105007:	c9                   	leave  
80105008:	c3                   	ret    

80105009 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105009:	55                   	push   %ebp
8010500a:	89 e5                	mov    %esp,%ebp
8010500c:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010500f:	c7 45 f0 f4 39 11 80 	movl   $0x801139f4,-0x10(%ebp)
80105016:	e9 d9 00 00 00       	jmp    801050f4 <procdump+0xeb>
    if(p->state == UNUSED)
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	8b 40 0c             	mov    0xc(%eax),%eax
80105021:	85 c0                	test   %eax,%eax
80105023:	75 05                	jne    8010502a <procdump+0x21>
      continue;
80105025:	e9 c3 00 00 00       	jmp    801050ed <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010502a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502d:	8b 40 0c             	mov    0xc(%eax),%eax
80105030:	83 f8 05             	cmp    $0x5,%eax
80105033:	77 23                	ja     80105058 <procdump+0x4f>
80105035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105038:	8b 40 0c             	mov    0xc(%eax),%eax
8010503b:	8b 04 85 1c c0 10 80 	mov    -0x7fef3fe4(,%eax,4),%eax
80105042:	85 c0                	test   %eax,%eax
80105044:	74 12                	je     80105058 <procdump+0x4f>
      state = states[p->state];
80105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105049:	8b 40 0c             	mov    0xc(%eax),%eax
8010504c:	8b 04 85 1c c0 10 80 	mov    -0x7fef3fe4(,%eax,4),%eax
80105053:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105056:	eb 07                	jmp    8010505f <procdump+0x56>
    else
      state = "???";
80105058:	c7 45 ec d0 92 10 80 	movl   $0x801092d0,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105062:	8d 50 70             	lea    0x70(%eax),%edx
80105065:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105068:	8b 40 10             	mov    0x10(%eax),%eax
8010506b:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010506f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105072:	89 54 24 08          	mov    %edx,0x8(%esp)
80105076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010507a:	c7 04 24 d4 92 10 80 	movl   $0x801092d4,(%esp)
80105081:	e8 1a b3 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80105086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105089:	8b 40 0c             	mov    0xc(%eax),%eax
8010508c:	83 f8 02             	cmp    $0x2,%eax
8010508f:	75 50                	jne    801050e1 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105091:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105094:	8b 40 20             	mov    0x20(%eax),%eax
80105097:	8b 40 0c             	mov    0xc(%eax),%eax
8010509a:	83 c0 08             	add    $0x8,%eax
8010509d:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801050a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801050a4:	89 04 24             	mov    %eax,(%esp)
801050a7:	e8 38 04 00 00       	call   801054e4 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801050ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050b3:	eb 1b                	jmp    801050d0 <procdump+0xc7>
        cprintf(" %p", pc[i]);
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801050c0:	c7 04 24 dd 92 10 80 	movl   $0x801092dd,(%esp)
801050c7:	e8 d4 b2 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801050cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050d0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050d4:	7f 0b                	jg     801050e1 <procdump+0xd8>
801050d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050dd:	85 c0                	test   %eax,%eax
801050df:	75 d4                	jne    801050b5 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801050e1:	c7 04 24 e1 92 10 80 	movl   $0x801092e1,(%esp)
801050e8:	e8 b3 b2 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050ed:	81 45 f0 34 01 00 00 	addl   $0x134,-0x10(%ebp)
801050f4:	81 7d f0 f4 86 11 80 	cmpl   $0x801186f4,-0x10(%ebp)
801050fb:	0f 82 1a ff ff ff    	jb     8010501b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105101:	c9                   	leave  
80105102:	c3                   	ret    

80105103 <signal>:

int 
signal(int signum, sighandler_t handler) {
80105103:	55                   	push   %ebp
80105104:	89 e5                	mov    %esp,%ebp
80105106:	83 ec 10             	sub    $0x10,%esp
	sighandler_t retHandler;
	if (signum >= 32 || signum < 0) {
80105109:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
8010510d:	7f 06                	jg     80105115 <signal+0x12>
8010510f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105113:	79 07                	jns    8010511c <signal+0x19>
	    return -1;
80105115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511a:	eb 29                	jmp    80105145 <signal+0x42>
	}
	else {	
	    retHandler =  proc->signal_handlers[signum];
8010511c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105122:	8b 55 08             	mov    0x8(%ebp),%edx
80105125:	83 c2 20             	add    $0x20,%edx
80105128:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010512c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	    proc->signal_handlers[signum] = handler;
8010512f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105135:	8b 55 08             	mov    0x8(%ebp),%edx
80105138:	8d 4a 20             	lea    0x20(%edx),%ecx
8010513b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010513e:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
	}
	return (int)retHandler;
80105142:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105145:	c9                   	leave  
80105146:	c3                   	ret    

80105147 <sigsend>:

int 
sigsend(int pid, int signum) {
80105147:	55                   	push   %ebp
80105148:	89 e5                	mov    %esp,%ebp
8010514a:	83 ec 28             	sub    $0x28,%esp
    struct proc *p;

    if (signum >= 31 || signum < 0) {
8010514d:	83 7d 0c 1e          	cmpl   $0x1e,0xc(%ebp)
80105151:	7f 06                	jg     80105159 <sigsend+0x12>
80105153:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105157:	79 0a                	jns    80105163 <sigsend+0x1c>
	return -1;
80105159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515e:	e9 91 00 00 00       	jmp    801051f4 <sigsend+0xad>
    }
    uint signumBits = 1 << signum; // bit respresentation of signum. e.g: signum = 5 -> signumBits = 000000...0100000         
80105163:	8b 45 0c             	mov    0xc(%ebp),%eax
80105166:	ba 01 00 00 00       	mov    $0x1,%edx
8010516b:	89 c1                	mov    %eax,%ecx
8010516d:	d3 e2                	shl    %cl,%edx
8010516f:	89 d0                	mov    %edx,%eax
80105171:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&ptable.lock);
80105174:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010517b:	e8 b3 02 00 00       	call   80105433 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105180:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
80105187:	eb 51                	jmp    801051da <sigsend+0x93>
      if(p->pid == pid){
80105189:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518c:	8b 40 10             	mov    0x10(%eax),%eax
8010518f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105192:	75 3f                	jne    801051d3 <sigsend+0x8c>
	p->pending |= signumBits;
80105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105197:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010519d:	0b 45 f0             	or     -0x10(%ebp),%eax
801051a0:	89 c2                	mov    %eax,%edx
801051a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a5:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	// Wake process from sleep if necessary.
	if(p->state == SLEEPING)
801051ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ae:	8b 40 0c             	mov    0xc(%eax),%eax
801051b1:	83 f8 02             	cmp    $0x2,%eax
801051b4:	75 0a                	jne    801051c0 <sigsend+0x79>
	  p->state = RUNNABLE;
801051b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
	release(&ptable.lock);
801051c0:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801051c7:	e8 c9 02 00 00       	call   80105495 <release>
	return 0;
801051cc:	b8 00 00 00 00       	mov    $0x0,%eax
801051d1:	eb 21                	jmp    801051f4 <sigsend+0xad>
    if (signum >= 31 || signum < 0) {
	return -1;
    }
    uint signumBits = 1 << signum; // bit respresentation of signum. e.g: signum = 5 -> signumBits = 000000...0100000         
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051d3:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
801051da:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
801051e1:	72 a6                	jb     80105189 <sigsend+0x42>
	  p->state = RUNNABLE;
	release(&ptable.lock);
	return 0;
      }
    }
    release(&ptable.lock);
801051e3:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801051ea:	e8 a6 02 00 00       	call   80105495 <release>
    return -1;
801051ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051f4:	c9                   	leave  
801051f5:	c3                   	ret    

801051f6 <advanceprocstats>:

void
advanceprocstats(void)
{
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
801051f9:	83 ec 10             	sub    $0x10,%esp
	struct proc *p;

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051fc:	c7 45 fc f4 39 11 80 	movl   $0x801139f4,-0x4(%ebp)
80105203:	eb 6c                	jmp    80105271 <advanceprocstats+0x7b>
		if(p->state == RUNNING) {
80105205:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105208:	8b 40 0c             	mov    0xc(%eax),%eax
8010520b:	83 f8 04             	cmp    $0x4,%eax
8010520e:	75 17                	jne    80105227 <advanceprocstats+0x31>
			p->rutime++;
80105210:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105213:	8b 80 18 01 00 00    	mov    0x118(%eax),%eax
80105219:	8d 50 01             	lea    0x1(%eax),%edx
8010521c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010521f:	89 90 18 01 00 00    	mov    %edx,0x118(%eax)
			continue;
80105225:	eb 43                	jmp    8010526a <advanceprocstats+0x74>
		}
		if(p->state == RUNNABLE) {
80105227:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010522a:	8b 40 0c             	mov    0xc(%eax),%eax
8010522d:	83 f8 03             	cmp    $0x3,%eax
80105230:	75 17                	jne    80105249 <advanceprocstats+0x53>
			p->retime++;
80105232:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105235:	8b 80 14 01 00 00    	mov    0x114(%eax),%eax
8010523b:	8d 50 01             	lea    0x1(%eax),%edx
8010523e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105241:	89 90 14 01 00 00    	mov    %edx,0x114(%eax)
			continue;
80105247:	eb 21                	jmp    8010526a <advanceprocstats+0x74>
		}
		if(p->state == SLEEPING) {
80105249:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010524c:	8b 40 0c             	mov    0xc(%eax),%eax
8010524f:	83 f8 02             	cmp    $0x2,%eax
80105252:	75 16                	jne    8010526a <advanceprocstats+0x74>
			p->stime++;
80105254:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105257:	8b 80 10 01 00 00    	mov    0x110(%eax),%eax
8010525d:	8d 50 01             	lea    0x1(%eax),%edx
80105260:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105263:	89 90 10 01 00 00    	mov    %edx,0x110(%eax)
			continue;
80105269:	90                   	nop
void
advanceprocstats(void)
{
	struct proc *p;

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010526a:	81 45 fc 34 01 00 00 	addl   $0x134,-0x4(%ebp)
80105271:	81 7d fc f4 86 11 80 	cmpl   $0x801186f4,-0x4(%ebp)
80105278:	72 8b                	jb     80105205 <advanceprocstats+0xf>
		if(p->state == SLEEPING) {
			p->stime++;
			continue;
		}
	}
 }
8010527a:	c9                   	leave  
8010527b:	c3                   	ret    

8010527c <wait_stat>:

int
wait_stat(struct perf *perfP){
8010527c:	55                   	push   %ebp
8010527d:	89 e5                	mov    %esp,%ebp
8010527f:	83 ec 28             	sub    $0x28,%esp
	struct proc *p;
	int havekids, pid;
	acquire(&ptable.lock);
80105282:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
80105289:	e8 a5 01 00 00       	call   80105433 <acquire>
	for(;;){
		// Scan through table looking for zombie children.
		havekids = 0;
8010528e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105295:	c7 45 f4 f4 39 11 80 	movl   $0x801139f4,-0xc(%ebp)
8010529c:	e9 eb 00 00 00       	jmp    8010538c <wait_stat+0x110>
			if(p->parent != proc)
801052a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a4:	8b 50 14             	mov    0x14(%eax),%edx
801052a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ad:	39 c2                	cmp    %eax,%edx
801052af:	74 05                	je     801052b6 <wait_stat+0x3a>
				continue;
801052b1:	e9 cf 00 00 00       	jmp    80105385 <wait_stat+0x109>
			havekids = 1;
801052b6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
			if(p->state == ZOMBIE){
801052bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c0:	8b 40 0c             	mov    0xc(%eax),%eax
801052c3:	83 f8 05             	cmp    $0x5,%eax
801052c6:	0f 85 b9 00 00 00    	jne    80105385 <wait_stat+0x109>
			  
				// Found one.
				pid = p->pid;
801052cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052cf:	8b 40 10             	mov    0x10(%eax),%eax
801052d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
				
				// the extra
				perfP->ctime =  p->ctime ;
801052d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d8:	8b 90 08 01 00 00    	mov    0x108(%eax),%edx
801052de:	8b 45 08             	mov    0x8(%ebp),%eax
801052e1:	89 10                	mov    %edx,(%eax)
				perfP->ttime =  p->ttime ;
801052e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e6:	8b 90 0c 01 00 00    	mov    0x10c(%eax),%edx
801052ec:	8b 45 08             	mov    0x8(%ebp),%eax
801052ef:	89 50 04             	mov    %edx,0x4(%eax)
				perfP->stime =  p->stime ;
801052f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f5:	8b 90 10 01 00 00    	mov    0x110(%eax),%edx
801052fb:	8b 45 08             	mov    0x8(%ebp),%eax
801052fe:	89 50 08             	mov    %edx,0x8(%eax)
				perfP->retime = p->retime ;
80105301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105304:	8b 90 14 01 00 00    	mov    0x114(%eax),%edx
8010530a:	8b 45 08             	mov    0x8(%ebp),%eax
8010530d:	89 50 0c             	mov    %edx,0xc(%eax)
				perfP->rutime = p->rutime ;
80105310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105313:	8b 90 18 01 00 00    	mov    0x118(%eax),%edx
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	89 50 10             	mov    %edx,0x10(%eax)
				kfree(p->kstack);
8010531f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105322:	8b 40 08             	mov    0x8(%eax),%eax
80105325:	89 04 24             	mov    %eax,(%esp)
80105328:	e8 1c d7 ff ff       	call   80102a49 <kfree>
				p->kstack = 0;
8010532d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105330:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
				freevm(p->pgdir);
80105337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533a:	8b 40 04             	mov    0x4(%eax),%eax
8010533d:	89 04 24             	mov    %eax,(%esp)
80105340:	e8 10 39 00 00       	call   80108c55 <freevm>
				p->state = UNUSED;
80105345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105348:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
				p->pid = 0;
8010534f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105352:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
				p->parent = 0;
80105359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
				p->name[0] = 0;
80105363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105366:	c6 40 70 00          	movb   $0x0,0x70(%eax)
				p->killed = 0;
8010536a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536d:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
				release(&ptable.lock);
80105374:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
8010537b:	e8 15 01 00 00       	call   80105495 <release>
				return pid;
80105380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105383:	eb 55                	jmp    801053da <wait_stat+0x15e>
	int havekids, pid;
	acquire(&ptable.lock);
	for(;;){
		// Scan through table looking for zombie children.
		havekids = 0;
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105385:	81 45 f4 34 01 00 00 	addl   $0x134,-0xc(%ebp)
8010538c:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80105393:	0f 82 08 ff ff ff    	jb     801052a1 <wait_stat+0x25>
				return pid;
			}
		}
		
		// No point waiting if we don't have any children.
		if(!havekids || proc->killed){
80105399:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010539d:	74 0d                	je     801053ac <wait_stat+0x130>
8010539f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a5:	8b 40 28             	mov    0x28(%eax),%eax
801053a8:	85 c0                	test   %eax,%eax
801053aa:	74 13                	je     801053bf <wait_stat+0x143>
			release(&ptable.lock);
801053ac:	c7 04 24 c0 39 11 80 	movl   $0x801139c0,(%esp)
801053b3:	e8 dd 00 00 00       	call   80105495 <release>
			return -1;
801053b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053bd:	eb 1b                	jmp    801053da <wait_stat+0x15e>
		}

		// Wait for children to exit.  (See wakeup1 call in proc_exit.)
		sleep(proc, &ptable.lock);  //DOC: wait-sleep
801053bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c5:	c7 44 24 04 c0 39 11 	movl   $0x801139c0,0x4(%esp)
801053cc:	80 
801053cd:	89 04 24             	mov    %eax,(%esp)
801053d0:	e8 b2 fa ff ff       	call   80104e87 <sleep>
	}
801053d5:	e9 b4 fe ff ff       	jmp    8010528e <wait_stat+0x12>

 }
801053da:	c9                   	leave  
801053db:	c3                   	ret    

801053dc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801053dc:	55                   	push   %ebp
801053dd:	89 e5                	mov    %esp,%ebp
801053df:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801053e2:	9c                   	pushf  
801053e3:	58                   	pop    %eax
801053e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801053e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053ea:	c9                   	leave  
801053eb:	c3                   	ret    

801053ec <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801053ec:	55                   	push   %ebp
801053ed:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801053ef:	fa                   	cli    
}
801053f0:	5d                   	pop    %ebp
801053f1:	c3                   	ret    

801053f2 <sti>:

static inline void
sti(void)
{
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801053f5:	fb                   	sti    
}
801053f6:	5d                   	pop    %ebp
801053f7:	c3                   	ret    

801053f8 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801053f8:	55                   	push   %ebp
801053f9:	89 e5                	mov    %esp,%ebp
801053fb:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801053fe:	8b 55 08             	mov    0x8(%ebp),%edx
80105401:	8b 45 0c             	mov    0xc(%ebp),%eax
80105404:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105407:	f0 87 02             	lock xchg %eax,(%edx)
8010540a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010540d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105410:	c9                   	leave  
80105411:	c3                   	ret    

80105412 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105412:	55                   	push   %ebp
80105413:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105415:	8b 45 08             	mov    0x8(%ebp),%eax
80105418:	8b 55 0c             	mov    0xc(%ebp),%edx
8010541b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010541e:	8b 45 08             	mov    0x8(%ebp),%eax
80105421:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105427:	8b 45 08             	mov    0x8(%ebp),%eax
8010542a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105431:	5d                   	pop    %ebp
80105432:	c3                   	ret    

80105433 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105433:	55                   	push   %ebp
80105434:	89 e5                	mov    %esp,%ebp
80105436:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105439:	e8 49 01 00 00       	call   80105587 <pushcli>
  if(holding(lk))
8010543e:	8b 45 08             	mov    0x8(%ebp),%eax
80105441:	89 04 24             	mov    %eax,(%esp)
80105444:	e8 14 01 00 00       	call   8010555d <holding>
80105449:	85 c0                	test   %eax,%eax
8010544b:	74 0c                	je     80105459 <acquire+0x26>
    panic("acquire");
8010544d:	c7 04 24 0d 93 10 80 	movl   $0x8010930d,(%esp)
80105454:	e8 e1 b0 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105459:	90                   	nop
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
8010545d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105464:	00 
80105465:	89 04 24             	mov    %eax,(%esp)
80105468:	e8 8b ff ff ff       	call   801053f8 <xchg>
8010546d:	85 c0                	test   %eax,%eax
8010546f:	75 e9                	jne    8010545a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105471:	8b 45 08             	mov    0x8(%ebp),%eax
80105474:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010547b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010547e:	8b 45 08             	mov    0x8(%ebp),%eax
80105481:	83 c0 0c             	add    $0xc,%eax
80105484:	89 44 24 04          	mov    %eax,0x4(%esp)
80105488:	8d 45 08             	lea    0x8(%ebp),%eax
8010548b:	89 04 24             	mov    %eax,(%esp)
8010548e:	e8 51 00 00 00       	call   801054e4 <getcallerpcs>
}
80105493:	c9                   	leave  
80105494:	c3                   	ret    

80105495 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105495:	55                   	push   %ebp
80105496:	89 e5                	mov    %esp,%ebp
80105498:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010549b:	8b 45 08             	mov    0x8(%ebp),%eax
8010549e:	89 04 24             	mov    %eax,(%esp)
801054a1:	e8 b7 00 00 00       	call   8010555d <holding>
801054a6:	85 c0                	test   %eax,%eax
801054a8:	75 0c                	jne    801054b6 <release+0x21>
    panic("release");
801054aa:	c7 04 24 15 93 10 80 	movl   $0x80109315,(%esp)
801054b1:	e8 84 b0 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
801054b6:	8b 45 08             	mov    0x8(%ebp),%eax
801054b9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801054c0:	8b 45 08             	mov    0x8(%ebp),%eax
801054c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801054ca:	8b 45 08             	mov    0x8(%ebp),%eax
801054cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801054d4:	00 
801054d5:	89 04 24             	mov    %eax,(%esp)
801054d8:	e8 1b ff ff ff       	call   801053f8 <xchg>

  popcli();
801054dd:	e8 e9 00 00 00       	call   801055cb <popcli>
}
801054e2:	c9                   	leave  
801054e3:	c3                   	ret    

801054e4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801054e4:	55                   	push   %ebp
801054e5:	89 e5                	mov    %esp,%ebp
801054e7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801054ea:	8b 45 08             	mov    0x8(%ebp),%eax
801054ed:	83 e8 08             	sub    $0x8,%eax
801054f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801054f3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801054fa:	eb 38                	jmp    80105534 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801054fc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105500:	74 38                	je     8010553a <getcallerpcs+0x56>
80105502:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105509:	76 2f                	jbe    8010553a <getcallerpcs+0x56>
8010550b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010550f:	74 29                	je     8010553a <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105511:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105514:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010551b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551e:	01 c2                	add    %eax,%edx
80105520:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105523:	8b 40 04             	mov    0x4(%eax),%eax
80105526:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105528:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010552b:	8b 00                	mov    (%eax),%eax
8010552d:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105530:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105534:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105538:	7e c2                	jle    801054fc <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010553a:	eb 19                	jmp    80105555 <getcallerpcs+0x71>
    pcs[i] = 0;
8010553c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010553f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105546:	8b 45 0c             	mov    0xc(%ebp),%eax
80105549:	01 d0                	add    %edx,%eax
8010554b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105551:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105555:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105559:	7e e1                	jle    8010553c <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010555b:	c9                   	leave  
8010555c:	c3                   	ret    

8010555d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010555d:	55                   	push   %ebp
8010555e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	8b 00                	mov    (%eax),%eax
80105565:	85 c0                	test   %eax,%eax
80105567:	74 17                	je     80105580 <holding+0x23>
80105569:	8b 45 08             	mov    0x8(%ebp),%eax
8010556c:	8b 50 08             	mov    0x8(%eax),%edx
8010556f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105575:	39 c2                	cmp    %eax,%edx
80105577:	75 07                	jne    80105580 <holding+0x23>
80105579:	b8 01 00 00 00       	mov    $0x1,%eax
8010557e:	eb 05                	jmp    80105585 <holding+0x28>
80105580:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105585:	5d                   	pop    %ebp
80105586:	c3                   	ret    

80105587 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105587:	55                   	push   %ebp
80105588:	89 e5                	mov    %esp,%ebp
8010558a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010558d:	e8 4a fe ff ff       	call   801053dc <readeflags>
80105592:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105595:	e8 52 fe ff ff       	call   801053ec <cli>
  if(cpu->ncli++ == 0)
8010559a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801055a1:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801055a7:	8d 48 01             	lea    0x1(%eax),%ecx
801055aa:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801055b0:	85 c0                	test   %eax,%eax
801055b2:	75 15                	jne    801055c9 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801055b4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055bd:	81 e2 00 02 00 00    	and    $0x200,%edx
801055c3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801055c9:	c9                   	leave  
801055ca:	c3                   	ret    

801055cb <popcli>:

void
popcli(void)
{
801055cb:	55                   	push   %ebp
801055cc:	89 e5                	mov    %esp,%ebp
801055ce:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801055d1:	e8 06 fe ff ff       	call   801053dc <readeflags>
801055d6:	25 00 02 00 00       	and    $0x200,%eax
801055db:	85 c0                	test   %eax,%eax
801055dd:	74 0c                	je     801055eb <popcli+0x20>
    panic("popcli - interruptible");
801055df:	c7 04 24 1d 93 10 80 	movl   $0x8010931d,(%esp)
801055e6:	e8 4f af ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801055eb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055f1:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801055f7:	83 ea 01             	sub    $0x1,%edx
801055fa:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105600:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105606:	85 c0                	test   %eax,%eax
80105608:	79 0c                	jns    80105616 <popcli+0x4b>
    panic("popcli");
8010560a:	c7 04 24 34 93 10 80 	movl   $0x80109334,(%esp)
80105611:	e8 24 af ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105616:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010561c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105622:	85 c0                	test   %eax,%eax
80105624:	75 15                	jne    8010563b <popcli+0x70>
80105626:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010562c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105632:	85 c0                	test   %eax,%eax
80105634:	74 05                	je     8010563b <popcli+0x70>
    sti();
80105636:	e8 b7 fd ff ff       	call   801053f2 <sti>
}
8010563b:	c9                   	leave  
8010563c:	c3                   	ret    

8010563d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010563d:	55                   	push   %ebp
8010563e:	89 e5                	mov    %esp,%ebp
80105640:	57                   	push   %edi
80105641:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105642:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105645:	8b 55 10             	mov    0x10(%ebp),%edx
80105648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564b:	89 cb                	mov    %ecx,%ebx
8010564d:	89 df                	mov    %ebx,%edi
8010564f:	89 d1                	mov    %edx,%ecx
80105651:	fc                   	cld    
80105652:	f3 aa                	rep stos %al,%es:(%edi)
80105654:	89 ca                	mov    %ecx,%edx
80105656:	89 fb                	mov    %edi,%ebx
80105658:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010565b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010565e:	5b                   	pop    %ebx
8010565f:	5f                   	pop    %edi
80105660:	5d                   	pop    %ebp
80105661:	c3                   	ret    

80105662 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105662:	55                   	push   %ebp
80105663:	89 e5                	mov    %esp,%ebp
80105665:	57                   	push   %edi
80105666:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105667:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010566a:	8b 55 10             	mov    0x10(%ebp),%edx
8010566d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105670:	89 cb                	mov    %ecx,%ebx
80105672:	89 df                	mov    %ebx,%edi
80105674:	89 d1                	mov    %edx,%ecx
80105676:	fc                   	cld    
80105677:	f3 ab                	rep stos %eax,%es:(%edi)
80105679:	89 ca                	mov    %ecx,%edx
8010567b:	89 fb                	mov    %edi,%ebx
8010567d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105680:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105683:	5b                   	pop    %ebx
80105684:	5f                   	pop    %edi
80105685:	5d                   	pop    %ebp
80105686:	c3                   	ret    

80105687 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105687:	55                   	push   %ebp
80105688:	89 e5                	mov    %esp,%ebp
8010568a:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	83 e0 03             	and    $0x3,%eax
80105693:	85 c0                	test   %eax,%eax
80105695:	75 49                	jne    801056e0 <memset+0x59>
80105697:	8b 45 10             	mov    0x10(%ebp),%eax
8010569a:	83 e0 03             	and    $0x3,%eax
8010569d:	85 c0                	test   %eax,%eax
8010569f:	75 3f                	jne    801056e0 <memset+0x59>
    c &= 0xFF;
801056a1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801056a8:	8b 45 10             	mov    0x10(%ebp),%eax
801056ab:	c1 e8 02             	shr    $0x2,%eax
801056ae:	89 c2                	mov    %eax,%edx
801056b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801056b3:	c1 e0 18             	shl    $0x18,%eax
801056b6:	89 c1                	mov    %eax,%ecx
801056b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801056bb:	c1 e0 10             	shl    $0x10,%eax
801056be:	09 c1                	or     %eax,%ecx
801056c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c3:	c1 e0 08             	shl    $0x8,%eax
801056c6:	09 c8                	or     %ecx,%eax
801056c8:	0b 45 0c             	or     0xc(%ebp),%eax
801056cb:	89 54 24 08          	mov    %edx,0x8(%esp)
801056cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801056d3:	8b 45 08             	mov    0x8(%ebp),%eax
801056d6:	89 04 24             	mov    %eax,(%esp)
801056d9:	e8 84 ff ff ff       	call   80105662 <stosl>
801056de:	eb 19                	jmp    801056f9 <memset+0x72>
  } else
    stosb(dst, c, n);
801056e0:	8b 45 10             	mov    0x10(%ebp),%eax
801056e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801056e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ee:	8b 45 08             	mov    0x8(%ebp),%eax
801056f1:	89 04 24             	mov    %eax,(%esp)
801056f4:	e8 44 ff ff ff       	call   8010563d <stosb>
  return dst;
801056f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056fc:	c9                   	leave  
801056fd:	c3                   	ret    

801056fe <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801056fe:	55                   	push   %ebp
801056ff:	89 e5                	mov    %esp,%ebp
80105701:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105704:	8b 45 08             	mov    0x8(%ebp),%eax
80105707:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010570a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105710:	eb 30                	jmp    80105742 <memcmp+0x44>
    if(*s1 != *s2)
80105712:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105715:	0f b6 10             	movzbl (%eax),%edx
80105718:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010571b:	0f b6 00             	movzbl (%eax),%eax
8010571e:	38 c2                	cmp    %al,%dl
80105720:	74 18                	je     8010573a <memcmp+0x3c>
      return *s1 - *s2;
80105722:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105725:	0f b6 00             	movzbl (%eax),%eax
80105728:	0f b6 d0             	movzbl %al,%edx
8010572b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010572e:	0f b6 00             	movzbl (%eax),%eax
80105731:	0f b6 c0             	movzbl %al,%eax
80105734:	29 c2                	sub    %eax,%edx
80105736:	89 d0                	mov    %edx,%eax
80105738:	eb 1a                	jmp    80105754 <memcmp+0x56>
    s1++, s2++;
8010573a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010573e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105742:	8b 45 10             	mov    0x10(%ebp),%eax
80105745:	8d 50 ff             	lea    -0x1(%eax),%edx
80105748:	89 55 10             	mov    %edx,0x10(%ebp)
8010574b:	85 c0                	test   %eax,%eax
8010574d:	75 c3                	jne    80105712 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010574f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105754:	c9                   	leave  
80105755:	c3                   	ret    

80105756 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105756:	55                   	push   %ebp
80105757:	89 e5                	mov    %esp,%ebp
80105759:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010575c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105762:	8b 45 08             	mov    0x8(%ebp),%eax
80105765:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105768:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010576e:	73 3d                	jae    801057ad <memmove+0x57>
80105770:	8b 45 10             	mov    0x10(%ebp),%eax
80105773:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105776:	01 d0                	add    %edx,%eax
80105778:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010577b:	76 30                	jbe    801057ad <memmove+0x57>
    s += n;
8010577d:	8b 45 10             	mov    0x10(%ebp),%eax
80105780:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105783:	8b 45 10             	mov    0x10(%ebp),%eax
80105786:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105789:	eb 13                	jmp    8010579e <memmove+0x48>
      *--d = *--s;
8010578b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010578f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105793:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105796:	0f b6 10             	movzbl (%eax),%edx
80105799:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010579c:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010579e:	8b 45 10             	mov    0x10(%ebp),%eax
801057a1:	8d 50 ff             	lea    -0x1(%eax),%edx
801057a4:	89 55 10             	mov    %edx,0x10(%ebp)
801057a7:	85 c0                	test   %eax,%eax
801057a9:	75 e0                	jne    8010578b <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801057ab:	eb 26                	jmp    801057d3 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057ad:	eb 17                	jmp    801057c6 <memmove+0x70>
      *d++ = *s++;
801057af:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057b2:	8d 50 01             	lea    0x1(%eax),%edx
801057b5:	89 55 f8             	mov    %edx,-0x8(%ebp)
801057b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057bb:	8d 4a 01             	lea    0x1(%edx),%ecx
801057be:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801057c1:	0f b6 12             	movzbl (%edx),%edx
801057c4:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057c6:	8b 45 10             	mov    0x10(%ebp),%eax
801057c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801057cc:	89 55 10             	mov    %edx,0x10(%ebp)
801057cf:	85 c0                	test   %eax,%eax
801057d1:	75 dc                	jne    801057af <memmove+0x59>
      *d++ = *s++;

  return dst;
801057d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057d6:	c9                   	leave  
801057d7:	c3                   	ret    

801057d8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801057d8:	55                   	push   %ebp
801057d9:	89 e5                	mov    %esp,%ebp
801057db:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801057de:	8b 45 10             	mov    0x10(%ebp),%eax
801057e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801057e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ec:	8b 45 08             	mov    0x8(%ebp),%eax
801057ef:	89 04 24             	mov    %eax,(%esp)
801057f2:	e8 5f ff ff ff       	call   80105756 <memmove>
}
801057f7:	c9                   	leave  
801057f8:	c3                   	ret    

801057f9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801057f9:	55                   	push   %ebp
801057fa:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801057fc:	eb 0c                	jmp    8010580a <strncmp+0x11>
    n--, p++, q++;
801057fe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105802:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105806:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010580a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010580e:	74 1a                	je     8010582a <strncmp+0x31>
80105810:	8b 45 08             	mov    0x8(%ebp),%eax
80105813:	0f b6 00             	movzbl (%eax),%eax
80105816:	84 c0                	test   %al,%al
80105818:	74 10                	je     8010582a <strncmp+0x31>
8010581a:	8b 45 08             	mov    0x8(%ebp),%eax
8010581d:	0f b6 10             	movzbl (%eax),%edx
80105820:	8b 45 0c             	mov    0xc(%ebp),%eax
80105823:	0f b6 00             	movzbl (%eax),%eax
80105826:	38 c2                	cmp    %al,%dl
80105828:	74 d4                	je     801057fe <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010582a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010582e:	75 07                	jne    80105837 <strncmp+0x3e>
    return 0;
80105830:	b8 00 00 00 00       	mov    $0x0,%eax
80105835:	eb 16                	jmp    8010584d <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105837:	8b 45 08             	mov    0x8(%ebp),%eax
8010583a:	0f b6 00             	movzbl (%eax),%eax
8010583d:	0f b6 d0             	movzbl %al,%edx
80105840:	8b 45 0c             	mov    0xc(%ebp),%eax
80105843:	0f b6 00             	movzbl (%eax),%eax
80105846:	0f b6 c0             	movzbl %al,%eax
80105849:	29 c2                	sub    %eax,%edx
8010584b:	89 d0                	mov    %edx,%eax
}
8010584d:	5d                   	pop    %ebp
8010584e:	c3                   	ret    

8010584f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010584f:	55                   	push   %ebp
80105850:	89 e5                	mov    %esp,%ebp
80105852:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105855:	8b 45 08             	mov    0x8(%ebp),%eax
80105858:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010585b:	90                   	nop
8010585c:	8b 45 10             	mov    0x10(%ebp),%eax
8010585f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105862:	89 55 10             	mov    %edx,0x10(%ebp)
80105865:	85 c0                	test   %eax,%eax
80105867:	7e 1e                	jle    80105887 <strncpy+0x38>
80105869:	8b 45 08             	mov    0x8(%ebp),%eax
8010586c:	8d 50 01             	lea    0x1(%eax),%edx
8010586f:	89 55 08             	mov    %edx,0x8(%ebp)
80105872:	8b 55 0c             	mov    0xc(%ebp),%edx
80105875:	8d 4a 01             	lea    0x1(%edx),%ecx
80105878:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010587b:	0f b6 12             	movzbl (%edx),%edx
8010587e:	88 10                	mov    %dl,(%eax)
80105880:	0f b6 00             	movzbl (%eax),%eax
80105883:	84 c0                	test   %al,%al
80105885:	75 d5                	jne    8010585c <strncpy+0xd>
    ;
  while(n-- > 0)
80105887:	eb 0c                	jmp    80105895 <strncpy+0x46>
    *s++ = 0;
80105889:	8b 45 08             	mov    0x8(%ebp),%eax
8010588c:	8d 50 01             	lea    0x1(%eax),%edx
8010588f:	89 55 08             	mov    %edx,0x8(%ebp)
80105892:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105895:	8b 45 10             	mov    0x10(%ebp),%eax
80105898:	8d 50 ff             	lea    -0x1(%eax),%edx
8010589b:	89 55 10             	mov    %edx,0x10(%ebp)
8010589e:	85 c0                	test   %eax,%eax
801058a0:	7f e7                	jg     80105889 <strncpy+0x3a>
    *s++ = 0;
  return os;
801058a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058a5:	c9                   	leave  
801058a6:	c3                   	ret    

801058a7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801058a7:	55                   	push   %ebp
801058a8:	89 e5                	mov    %esp,%ebp
801058aa:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801058ad:	8b 45 08             	mov    0x8(%ebp),%eax
801058b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801058b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058b7:	7f 05                	jg     801058be <safestrcpy+0x17>
    return os;
801058b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058bc:	eb 31                	jmp    801058ef <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801058be:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058c6:	7e 1e                	jle    801058e6 <safestrcpy+0x3f>
801058c8:	8b 45 08             	mov    0x8(%ebp),%eax
801058cb:	8d 50 01             	lea    0x1(%eax),%edx
801058ce:	89 55 08             	mov    %edx,0x8(%ebp)
801058d1:	8b 55 0c             	mov    0xc(%ebp),%edx
801058d4:	8d 4a 01             	lea    0x1(%edx),%ecx
801058d7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801058da:	0f b6 12             	movzbl (%edx),%edx
801058dd:	88 10                	mov    %dl,(%eax)
801058df:	0f b6 00             	movzbl (%eax),%eax
801058e2:	84 c0                	test   %al,%al
801058e4:	75 d8                	jne    801058be <safestrcpy+0x17>
    ;
  *s = 0;
801058e6:	8b 45 08             	mov    0x8(%ebp),%eax
801058e9:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801058ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058ef:	c9                   	leave  
801058f0:	c3                   	ret    

801058f1 <strlen>:

int
strlen(const char *s)
{
801058f1:	55                   	push   %ebp
801058f2:	89 e5                	mov    %esp,%ebp
801058f4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801058f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058fe:	eb 04                	jmp    80105904 <strlen+0x13>
80105900:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105904:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105907:	8b 45 08             	mov    0x8(%ebp),%eax
8010590a:	01 d0                	add    %edx,%eax
8010590c:	0f b6 00             	movzbl (%eax),%eax
8010590f:	84 c0                	test   %al,%al
80105911:	75 ed                	jne    80105900 <strlen+0xf>
    ;
  return n;
80105913:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105916:	c9                   	leave  
80105917:	c3                   	ret    

80105918 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105918:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010591c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105920:	55                   	push   %ebp
  pushl %ebx
80105921:	53                   	push   %ebx
  pushl %esi
80105922:	56                   	push   %esi
  pushl %edi
80105923:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105924:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105926:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105928:	5f                   	pop    %edi
  popl %esi
80105929:	5e                   	pop    %esi
  popl %ebx
8010592a:	5b                   	pop    %ebx
  popl %ebp
8010592b:	5d                   	pop    %ebp
  ret
8010592c:	c3                   	ret    

8010592d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010592d:	55                   	push   %ebp
8010592e:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105930:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105936:	8b 00                	mov    (%eax),%eax
80105938:	3b 45 08             	cmp    0x8(%ebp),%eax
8010593b:	76 12                	jbe    8010594f <fetchint+0x22>
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	8d 50 04             	lea    0x4(%eax),%edx
80105943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105949:	8b 00                	mov    (%eax),%eax
8010594b:	39 c2                	cmp    %eax,%edx
8010594d:	76 07                	jbe    80105956 <fetchint+0x29>
    return -1;
8010594f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105954:	eb 0f                	jmp    80105965 <fetchint+0x38>
  *ip = *(int*)(addr);
80105956:	8b 45 08             	mov    0x8(%ebp),%eax
80105959:	8b 10                	mov    (%eax),%edx
8010595b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595e:	89 10                	mov    %edx,(%eax)
  return 0;
80105960:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105965:	5d                   	pop    %ebp
80105966:	c3                   	ret    

80105967 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105967:	55                   	push   %ebp
80105968:	89 e5                	mov    %esp,%ebp
8010596a:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010596d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105973:	8b 00                	mov    (%eax),%eax
80105975:	3b 45 08             	cmp    0x8(%ebp),%eax
80105978:	77 07                	ja     80105981 <fetchstr+0x1a>
    return -1;
8010597a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597f:	eb 46                	jmp    801059c7 <fetchstr+0x60>
  *pp = (char*)addr;
80105981:	8b 55 08             	mov    0x8(%ebp),%edx
80105984:	8b 45 0c             	mov    0xc(%ebp),%eax
80105987:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105989:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010598f:	8b 00                	mov    (%eax),%eax
80105991:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105994:	8b 45 0c             	mov    0xc(%ebp),%eax
80105997:	8b 00                	mov    (%eax),%eax
80105999:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010599c:	eb 1c                	jmp    801059ba <fetchstr+0x53>
    if(*s == 0)
8010599e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059a1:	0f b6 00             	movzbl (%eax),%eax
801059a4:	84 c0                	test   %al,%al
801059a6:	75 0e                	jne    801059b6 <fetchstr+0x4f>
      return s - *pp;
801059a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ae:	8b 00                	mov    (%eax),%eax
801059b0:	29 c2                	sub    %eax,%edx
801059b2:	89 d0                	mov    %edx,%eax
801059b4:	eb 11                	jmp    801059c7 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801059b6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059bd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059c0:	72 dc                	jb     8010599e <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801059c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059c7:	c9                   	leave  
801059c8:	c3                   	ret    

801059c9 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801059c9:	55                   	push   %ebp
801059ca:	89 e5                	mov    %esp,%ebp
801059cc:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801059cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059d5:	8b 40 18             	mov    0x18(%eax),%eax
801059d8:	8b 50 44             	mov    0x44(%eax),%edx
801059db:	8b 45 08             	mov    0x8(%ebp),%eax
801059de:	c1 e0 02             	shl    $0x2,%eax
801059e1:	01 d0                	add    %edx,%eax
801059e3:	8d 50 04             	lea    0x4(%eax),%edx
801059e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ed:	89 14 24             	mov    %edx,(%esp)
801059f0:	e8 38 ff ff ff       	call   8010592d <fetchint>
}
801059f5:	c9                   	leave  
801059f6:	c3                   	ret    

801059f7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801059f7:	55                   	push   %ebp
801059f8:	89 e5                	mov    %esp,%ebp
801059fa:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801059fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a00:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a04:	8b 45 08             	mov    0x8(%ebp),%eax
80105a07:	89 04 24             	mov    %eax,(%esp)
80105a0a:	e8 ba ff ff ff       	call   801059c9 <argint>
80105a0f:	85 c0                	test   %eax,%eax
80105a11:	79 07                	jns    80105a1a <argptr+0x23>
    return -1;
80105a13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a18:	eb 3d                	jmp    80105a57 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a1d:	89 c2                	mov    %eax,%edx
80105a1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a25:	8b 00                	mov    (%eax),%eax
80105a27:	39 c2                	cmp    %eax,%edx
80105a29:	73 16                	jae    80105a41 <argptr+0x4a>
80105a2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a2e:	89 c2                	mov    %eax,%edx
80105a30:	8b 45 10             	mov    0x10(%ebp),%eax
80105a33:	01 c2                	add    %eax,%edx
80105a35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a3b:	8b 00                	mov    (%eax),%eax
80105a3d:	39 c2                	cmp    %eax,%edx
80105a3f:	76 07                	jbe    80105a48 <argptr+0x51>
    return -1;
80105a41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a46:	eb 0f                	jmp    80105a57 <argptr+0x60>
  *pp = (char*)i;
80105a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a4b:	89 c2                	mov    %eax,%edx
80105a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a50:	89 10                	mov    %edx,(%eax)
  return 0;
80105a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a5f:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a62:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a66:	8b 45 08             	mov    0x8(%ebp),%eax
80105a69:	89 04 24             	mov    %eax,(%esp)
80105a6c:	e8 58 ff ff ff       	call   801059c9 <argint>
80105a71:	85 c0                	test   %eax,%eax
80105a73:	79 07                	jns    80105a7c <argstr+0x23>
    return -1;
80105a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7a:	eb 12                	jmp    80105a8e <argstr+0x35>
  return fetchstr(addr, pp);
80105a7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a82:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a86:	89 04 24             	mov    %eax,(%esp)
80105a89:	e8 d9 fe ff ff       	call   80105967 <fetchstr>
}
80105a8e:	c9                   	leave  
80105a8f:	c3                   	ret    

80105a90 <syscall>:
[SYS_priority] sys_priority,
};

void
syscall(void)
{
80105a90:	55                   	push   %ebp
80105a91:	89 e5                	mov    %esp,%ebp
80105a93:	53                   	push   %ebx
80105a94:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105a97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9d:	8b 40 18             	mov    0x18(%eax),%eax
80105aa0:	8b 40 1c             	mov    0x1c(%eax),%eax
80105aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105aa6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aaa:	7e 30                	jle    80105adc <syscall+0x4c>
80105aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aaf:	83 f8 1b             	cmp    $0x1b,%eax
80105ab2:	77 28                	ja     80105adc <syscall+0x4c>
80105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab7:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105abe:	85 c0                	test   %eax,%eax
80105ac0:	74 1a                	je     80105adc <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105ac2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac8:	8b 58 18             	mov    0x18(%eax),%ebx
80105acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ace:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ad5:	ff d0                	call   *%eax
80105ad7:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105ada:	eb 3d                	jmp    80105b19 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105adc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ae2:	8d 48 70             	lea    0x70(%eax),%ecx
80105ae5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105aeb:	8b 40 10             	mov    0x10(%eax),%eax
80105aee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105af5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105afd:	c7 04 24 3b 93 10 80 	movl   $0x8010933b,(%esp)
80105b04:	e8 97 a8 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105b09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b0f:	8b 40 18             	mov    0x18(%eax),%eax
80105b12:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105b19:	83 c4 24             	add    $0x24,%esp
80105b1c:	5b                   	pop    %ebx
80105b1d:	5d                   	pop    %ebp
80105b1e:	c3                   	ret    

80105b1f <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105b1f:	55                   	push   %ebp
80105b20:	89 e5                	mov    %esp,%ebp
80105b22:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2f:	89 04 24             	mov    %eax,(%esp)
80105b32:	e8 92 fe ff ff       	call   801059c9 <argint>
80105b37:	85 c0                	test   %eax,%eax
80105b39:	79 07                	jns    80105b42 <argfd+0x23>
    return -1;
80105b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b40:	eb 50                	jmp    80105b92 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b45:	85 c0                	test   %eax,%eax
80105b47:	78 21                	js     80105b6a <argfd+0x4b>
80105b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4c:	83 f8 0f             	cmp    $0xf,%eax
80105b4f:	7f 19                	jg     80105b6a <argfd+0x4b>
80105b51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b5a:	83 c2 08             	add    $0x8,%edx
80105b5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b68:	75 07                	jne    80105b71 <argfd+0x52>
    return -1;
80105b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6f:	eb 21                	jmp    80105b92 <argfd+0x73>
  if(pfd)
80105b71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b75:	74 08                	je     80105b7f <argfd+0x60>
    *pfd = fd;
80105b77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b7d:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b83:	74 08                	je     80105b8d <argfd+0x6e>
    *pf = f;
80105b85:	8b 45 10             	mov    0x10(%ebp),%eax
80105b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b8b:	89 10                	mov    %edx,(%eax)
  return 0;
80105b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b92:	c9                   	leave  
80105b93:	c3                   	ret    

80105b94 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b94:	55                   	push   %ebp
80105b95:	89 e5                	mov    %esp,%ebp
80105b97:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b9a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105ba1:	eb 30                	jmp    80105bd3 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105ba3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ba9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bac:	83 c2 08             	add    $0x8,%edx
80105baf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105bb3:	85 c0                	test   %eax,%eax
80105bb5:	75 18                	jne    80105bcf <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105bb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bbd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bc0:	8d 4a 08             	lea    0x8(%edx),%ecx
80105bc3:	8b 55 08             	mov    0x8(%ebp),%edx
80105bc6:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80105bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bcd:	eb 0f                	jmp    80105bde <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105bcf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105bd3:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105bd7:	7e ca                	jle    80105ba3 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bde:	c9                   	leave  
80105bdf:	c3                   	ret    

80105be0 <sys_dup>:

int
sys_dup(void)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105be6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bf4:	00 
80105bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bfc:	e8 1e ff ff ff       	call   80105b1f <argfd>
80105c01:	85 c0                	test   %eax,%eax
80105c03:	79 07                	jns    80105c0c <sys_dup+0x2c>
    return -1;
80105c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0a:	eb 29                	jmp    80105c35 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0f:	89 04 24             	mov    %eax,(%esp)
80105c12:	e8 7d ff ff ff       	call   80105b94 <fdalloc>
80105c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c1e:	79 07                	jns    80105c27 <sys_dup+0x47>
    return -1;
80105c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c25:	eb 0e                	jmp    80105c35 <sys_dup+0x55>
  filedup(f);
80105c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2a:	89 04 24             	mov    %eax,(%esp)
80105c2d:	e8 54 b3 ff ff       	call   80100f86 <filedup>
  return fd;
80105c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c35:	c9                   	leave  
80105c36:	c3                   	ret    

80105c37 <sys_read>:

int
sys_read(void)
{
80105c37:	55                   	push   %ebp
80105c38:	89 e5                	mov    %esp,%ebp
80105c3a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c40:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c4b:	00 
80105c4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c53:	e8 c7 fe ff ff       	call   80105b1f <argfd>
80105c58:	85 c0                	test   %eax,%eax
80105c5a:	78 35                	js     80105c91 <sys_read+0x5a>
80105c5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c63:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c6a:	e8 5a fd ff ff       	call   801059c9 <argint>
80105c6f:	85 c0                	test   %eax,%eax
80105c71:	78 1e                	js     80105c91 <sys_read+0x5a>
80105c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c76:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c88:	e8 6a fd ff ff       	call   801059f7 <argptr>
80105c8d:	85 c0                	test   %eax,%eax
80105c8f:	79 07                	jns    80105c98 <sys_read+0x61>
    return -1;
80105c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c96:	eb 19                	jmp    80105cb1 <sys_read+0x7a>
  return fileread(f, p, n);
80105c98:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ca5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ca9:	89 04 24             	mov    %eax,(%esp)
80105cac:	e8 42 b4 ff ff       	call   801010f3 <fileread>
}
80105cb1:	c9                   	leave  
80105cb2:	c3                   	ret    

80105cb3 <sys_write>:

int
sys_write(void)
{
80105cb3:	55                   	push   %ebp
80105cb4:	89 e5                	mov    %esp,%ebp
80105cb6:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cbc:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cc7:	00 
80105cc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ccf:	e8 4b fe ff ff       	call   80105b1f <argfd>
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	78 35                	js     80105d0d <sys_write+0x5a>
80105cd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cdf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ce6:	e8 de fc ff ff       	call   801059c9 <argint>
80105ceb:	85 c0                	test   %eax,%eax
80105ced:	78 1e                	js     80105d0d <sys_write+0x5a>
80105cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d04:	e8 ee fc ff ff       	call   801059f7 <argptr>
80105d09:	85 c0                	test   %eax,%eax
80105d0b:	79 07                	jns    80105d14 <sys_write+0x61>
    return -1;
80105d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d12:	eb 19                	jmp    80105d2d <sys_write+0x7a>
  return filewrite(f, p, n);
80105d14:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d17:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d21:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d25:	89 04 24             	mov    %eax,(%esp)
80105d28:	e8 82 b4 ff ff       	call   801011af <filewrite>
}
80105d2d:	c9                   	leave  
80105d2e:	c3                   	ret    

80105d2f <sys_close>:

int
sys_close(void)
{
80105d2f:	55                   	push   %ebp
80105d30:	89 e5                	mov    %esp,%ebp
80105d32:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105d35:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d38:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d4a:	e8 d0 fd ff ff       	call   80105b1f <argfd>
80105d4f:	85 c0                	test   %eax,%eax
80105d51:	79 07                	jns    80105d5a <sys_close+0x2b>
    return -1;
80105d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d58:	eb 24                	jmp    80105d7e <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105d5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d63:	83 c2 08             	add    $0x8,%edx
80105d66:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105d6d:	00 
  fileclose(f);
80105d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d71:	89 04 24             	mov    %eax,(%esp)
80105d74:	e8 55 b2 ff ff       	call   80100fce <fileclose>
  return 0;
80105d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d7e:	c9                   	leave  
80105d7f:	c3                   	ret    

80105d80 <sys_fstat>:

int
sys_fstat(void)
{
80105d80:	55                   	push   %ebp
80105d81:	89 e5                	mov    %esp,%ebp
80105d83:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d89:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d94:	00 
80105d95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d9c:	e8 7e fd ff ff       	call   80105b1f <argfd>
80105da1:	85 c0                	test   %eax,%eax
80105da3:	78 1f                	js     80105dc4 <sys_fstat+0x44>
80105da5:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105dac:	00 
80105dad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dbb:	e8 37 fc ff ff       	call   801059f7 <argptr>
80105dc0:	85 c0                	test   %eax,%eax
80105dc2:	79 07                	jns    80105dcb <sys_fstat+0x4b>
    return -1;
80105dc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc9:	eb 12                	jmp    80105ddd <sys_fstat+0x5d>
  return filestat(f, st);
80105dcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dd5:	89 04 24             	mov    %eax,(%esp)
80105dd8:	e8 c7 b2 ff ff       	call   801010a4 <filestat>
}
80105ddd:	c9                   	leave  
80105dde:	c3                   	ret    

80105ddf <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ddf:	55                   	push   %ebp
80105de0:	89 e5                	mov    %esp,%ebp
80105de2:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105de5:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105df3:	e8 61 fc ff ff       	call   80105a59 <argstr>
80105df8:	85 c0                	test   %eax,%eax
80105dfa:	78 17                	js     80105e13 <sys_link+0x34>
80105dfc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105dff:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e0a:	e8 4a fc ff ff       	call   80105a59 <argstr>
80105e0f:	85 c0                	test   %eax,%eax
80105e11:	79 0a                	jns    80105e1d <sys_link+0x3e>
    return -1;
80105e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e18:	e9 42 01 00 00       	jmp    80105f5f <sys_link+0x180>

  begin_op();
80105e1d:	e8 ee d5 ff ff       	call   80103410 <begin_op>
  if((ip = namei(old)) == 0){
80105e22:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105e25:	89 04 24             	mov    %eax,(%esp)
80105e28:	e8 d9 c5 ff ff       	call   80102406 <namei>
80105e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e34:	75 0f                	jne    80105e45 <sys_link+0x66>
    end_op();
80105e36:	e8 59 d6 ff ff       	call   80103494 <end_op>
    return -1;
80105e3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e40:	e9 1a 01 00 00       	jmp    80105f5f <sys_link+0x180>
  }

  ilock(ip);
80105e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e48:	89 04 24             	mov    %eax,(%esp)
80105e4b:	e8 0b ba ff ff       	call   8010185b <ilock>
  if(ip->type == T_DIR){
80105e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e53:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e57:	66 83 f8 01          	cmp    $0x1,%ax
80105e5b:	75 1a                	jne    80105e77 <sys_link+0x98>
    iunlockput(ip);
80105e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e60:	89 04 24             	mov    %eax,(%esp)
80105e63:	e8 77 bc ff ff       	call   80101adf <iunlockput>
    end_op();
80105e68:	e8 27 d6 ff ff       	call   80103494 <end_op>
    return -1;
80105e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e72:	e9 e8 00 00 00       	jmp    80105f5f <sys_link+0x180>
  }

  ip->nlink++;
80105e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e7e:	8d 50 01             	lea    0x1(%eax),%edx
80105e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e84:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8b:	89 04 24             	mov    %eax,(%esp)
80105e8e:	e8 0c b8 ff ff       	call   8010169f <iupdate>
  iunlock(ip);
80105e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e96:	89 04 24             	mov    %eax,(%esp)
80105e99:	e8 0b bb ff ff       	call   801019a9 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105e9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ea1:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ea4:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ea8:	89 04 24             	mov    %eax,(%esp)
80105eab:	e8 78 c5 ff ff       	call   80102428 <nameiparent>
80105eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eb7:	75 02                	jne    80105ebb <sys_link+0xdc>
    goto bad;
80105eb9:	eb 68                	jmp    80105f23 <sys_link+0x144>
  ilock(dp);
80105ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebe:	89 04 24             	mov    %eax,(%esp)
80105ec1:	e8 95 b9 ff ff       	call   8010185b <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec9:	8b 10                	mov    (%eax),%edx
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	8b 00                	mov    (%eax),%eax
80105ed0:	39 c2                	cmp    %eax,%edx
80105ed2:	75 20                	jne    80105ef4 <sys_link+0x115>
80105ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed7:	8b 40 04             	mov    0x4(%eax),%eax
80105eda:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ede:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee8:	89 04 24             	mov    %eax,(%esp)
80105eeb:	e8 56 c2 ff ff       	call   80102146 <dirlink>
80105ef0:	85 c0                	test   %eax,%eax
80105ef2:	79 0d                	jns    80105f01 <sys_link+0x122>
    iunlockput(dp);
80105ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef7:	89 04 24             	mov    %eax,(%esp)
80105efa:	e8 e0 bb ff ff       	call   80101adf <iunlockput>
    goto bad;
80105eff:	eb 22                	jmp    80105f23 <sys_link+0x144>
  }
  iunlockput(dp);
80105f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f04:	89 04 24             	mov    %eax,(%esp)
80105f07:	e8 d3 bb ff ff       	call   80101adf <iunlockput>
  iput(ip);
80105f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0f:	89 04 24             	mov    %eax,(%esp)
80105f12:	e8 f7 ba ff ff       	call   80101a0e <iput>

  end_op();
80105f17:	e8 78 d5 ff ff       	call   80103494 <end_op>

  return 0;
80105f1c:	b8 00 00 00 00       	mov    $0x0,%eax
80105f21:	eb 3c                	jmp    80105f5f <sys_link+0x180>

bad:
  ilock(ip);
80105f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f26:	89 04 24             	mov    %eax,(%esp)
80105f29:	e8 2d b9 ff ff       	call   8010185b <ilock>
  ip->nlink--;
80105f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f31:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f35:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f42:	89 04 24             	mov    %eax,(%esp)
80105f45:	e8 55 b7 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80105f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4d:	89 04 24             	mov    %eax,(%esp)
80105f50:	e8 8a bb ff ff       	call   80101adf <iunlockput>
  end_op();
80105f55:	e8 3a d5 ff ff       	call   80103494 <end_op>
  return -1;
80105f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f5f:	c9                   	leave  
80105f60:	c3                   	ret    

80105f61 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f61:	55                   	push   %ebp
80105f62:	89 e5                	mov    %esp,%ebp
80105f64:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f67:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f6e:	eb 4b                	jmp    80105fbb <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f73:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f7a:	00 
80105f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f86:	8b 45 08             	mov    0x8(%ebp),%eax
80105f89:	89 04 24             	mov    %eax,(%esp)
80105f8c:	e8 d7 bd ff ff       	call   80101d68 <readi>
80105f91:	83 f8 10             	cmp    $0x10,%eax
80105f94:	74 0c                	je     80105fa2 <isdirempty+0x41>
      panic("isdirempty: readi");
80105f96:	c7 04 24 57 93 10 80 	movl   $0x80109357,(%esp)
80105f9d:	e8 98 a5 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105fa2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105fa6:	66 85 c0             	test   %ax,%ax
80105fa9:	74 07                	je     80105fb2 <isdirempty+0x51>
      return 0;
80105fab:	b8 00 00 00 00       	mov    $0x0,%eax
80105fb0:	eb 1b                	jmp    80105fcd <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb5:	83 c0 10             	add    $0x10,%eax
80105fb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc1:	8b 40 18             	mov    0x18(%eax),%eax
80105fc4:	39 c2                	cmp    %eax,%edx
80105fc6:	72 a8                	jb     80105f70 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105fc8:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105fcd:	c9                   	leave  
80105fce:	c3                   	ret    

80105fcf <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105fcf:	55                   	push   %ebp
80105fd0:	89 e5                	mov    %esp,%ebp
80105fd2:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105fd5:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fe3:	e8 71 fa ff ff       	call   80105a59 <argstr>
80105fe8:	85 c0                	test   %eax,%eax
80105fea:	79 0a                	jns    80105ff6 <sys_unlink+0x27>
    return -1;
80105fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff1:	e9 af 01 00 00       	jmp    801061a5 <sys_unlink+0x1d6>

  begin_op();
80105ff6:	e8 15 d4 ff ff       	call   80103410 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ffb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ffe:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106001:	89 54 24 04          	mov    %edx,0x4(%esp)
80106005:	89 04 24             	mov    %eax,(%esp)
80106008:	e8 1b c4 ff ff       	call   80102428 <nameiparent>
8010600d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106010:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106014:	75 0f                	jne    80106025 <sys_unlink+0x56>
    end_op();
80106016:	e8 79 d4 ff ff       	call   80103494 <end_op>
    return -1;
8010601b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106020:	e9 80 01 00 00       	jmp    801061a5 <sys_unlink+0x1d6>
  }

  ilock(dp);
80106025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 2b b8 ff ff       	call   8010185b <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106030:	c7 44 24 04 69 93 10 	movl   $0x80109369,0x4(%esp)
80106037:	80 
80106038:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010603b:	89 04 24             	mov    %eax,(%esp)
8010603e:	e8 18 c0 ff ff       	call   8010205b <namecmp>
80106043:	85 c0                	test   %eax,%eax
80106045:	0f 84 45 01 00 00    	je     80106190 <sys_unlink+0x1c1>
8010604b:	c7 44 24 04 6b 93 10 	movl   $0x8010936b,0x4(%esp)
80106052:	80 
80106053:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106056:	89 04 24             	mov    %eax,(%esp)
80106059:	e8 fd bf ff ff       	call   8010205b <namecmp>
8010605e:	85 c0                	test   %eax,%eax
80106060:	0f 84 2a 01 00 00    	je     80106190 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106066:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106069:	89 44 24 08          	mov    %eax,0x8(%esp)
8010606d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106070:	89 44 24 04          	mov    %eax,0x4(%esp)
80106074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106077:	89 04 24             	mov    %eax,(%esp)
8010607a:	e8 fe bf ff ff       	call   8010207d <dirlookup>
8010607f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106082:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106086:	75 05                	jne    8010608d <sys_unlink+0xbe>
    goto bad;
80106088:	e9 03 01 00 00       	jmp    80106190 <sys_unlink+0x1c1>
  ilock(ip);
8010608d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106090:	89 04 24             	mov    %eax,(%esp)
80106093:	e8 c3 b7 ff ff       	call   8010185b <ilock>

  if(ip->nlink < 1)
80106098:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010609f:	66 85 c0             	test   %ax,%ax
801060a2:	7f 0c                	jg     801060b0 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801060a4:	c7 04 24 6e 93 10 80 	movl   $0x8010936e,(%esp)
801060ab:	e8 8a a4 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801060b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060b7:	66 83 f8 01          	cmp    $0x1,%ax
801060bb:	75 1f                	jne    801060dc <sys_unlink+0x10d>
801060bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c0:	89 04 24             	mov    %eax,(%esp)
801060c3:	e8 99 fe ff ff       	call   80105f61 <isdirempty>
801060c8:	85 c0                	test   %eax,%eax
801060ca:	75 10                	jne    801060dc <sys_unlink+0x10d>
    iunlockput(ip);
801060cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cf:	89 04 24             	mov    %eax,(%esp)
801060d2:	e8 08 ba ff ff       	call   80101adf <iunlockput>
    goto bad;
801060d7:	e9 b4 00 00 00       	jmp    80106190 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
801060dc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801060e3:	00 
801060e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060eb:	00 
801060ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060ef:	89 04 24             	mov    %eax,(%esp)
801060f2:	e8 90 f5 ff ff       	call   80105687 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060f7:	8b 45 c8             	mov    -0x38(%ebp),%eax
801060fa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106101:	00 
80106102:	89 44 24 08          	mov    %eax,0x8(%esp)
80106106:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106109:	89 44 24 04          	mov    %eax,0x4(%esp)
8010610d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106110:	89 04 24             	mov    %eax,(%esp)
80106113:	e8 b4 bd ff ff       	call   80101ecc <writei>
80106118:	83 f8 10             	cmp    $0x10,%eax
8010611b:	74 0c                	je     80106129 <sys_unlink+0x15a>
    panic("unlink: writei");
8010611d:	c7 04 24 80 93 10 80 	movl   $0x80109380,(%esp)
80106124:	e8 11 a4 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80106129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106130:	66 83 f8 01          	cmp    $0x1,%ax
80106134:	75 1c                	jne    80106152 <sys_unlink+0x183>
    dp->nlink--;
80106136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106139:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010613d:	8d 50 ff             	lea    -0x1(%eax),%edx
80106140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106143:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614a:	89 04 24             	mov    %eax,(%esp)
8010614d:	e8 4d b5 ff ff       	call   8010169f <iupdate>
  }
  iunlockput(dp);
80106152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106155:	89 04 24             	mov    %eax,(%esp)
80106158:	e8 82 b9 ff ff       	call   80101adf <iunlockput>

  ip->nlink--;
8010615d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106160:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106164:	8d 50 ff             	lea    -0x1(%eax),%edx
80106167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	89 04 24             	mov    %eax,(%esp)
80106174:	e8 26 b5 ff ff       	call   8010169f <iupdate>
  iunlockput(ip);
80106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617c:	89 04 24             	mov    %eax,(%esp)
8010617f:	e8 5b b9 ff ff       	call   80101adf <iunlockput>

  end_op();
80106184:	e8 0b d3 ff ff       	call   80103494 <end_op>

  return 0;
80106189:	b8 00 00 00 00       	mov    $0x0,%eax
8010618e:	eb 15                	jmp    801061a5 <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80106190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106193:	89 04 24             	mov    %eax,(%esp)
80106196:	e8 44 b9 ff ff       	call   80101adf <iunlockput>
  end_op();
8010619b:	e8 f4 d2 ff ff       	call   80103494 <end_op>
  return -1;
801061a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061a5:	c9                   	leave  
801061a6:	c3                   	ret    

801061a7 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801061a7:	55                   	push   %ebp
801061a8:	89 e5                	mov    %esp,%ebp
801061aa:	83 ec 48             	sub    $0x48,%esp
801061ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801061b0:	8b 55 10             	mov    0x10(%ebp),%edx
801061b3:	8b 45 14             	mov    0x14(%ebp),%eax
801061b6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801061ba:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801061be:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801061c2:	8d 45 de             	lea    -0x22(%ebp),%eax
801061c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c9:	8b 45 08             	mov    0x8(%ebp),%eax
801061cc:	89 04 24             	mov    %eax,(%esp)
801061cf:	e8 54 c2 ff ff       	call   80102428 <nameiparent>
801061d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061db:	75 0a                	jne    801061e7 <create+0x40>
    return 0;
801061dd:	b8 00 00 00 00       	mov    $0x0,%eax
801061e2:	e9 7e 01 00 00       	jmp    80106365 <create+0x1be>
  ilock(dp);
801061e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ea:	89 04 24             	mov    %eax,(%esp)
801061ed:	e8 69 b6 ff ff       	call   8010185b <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801061f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801061f9:	8d 45 de             	lea    -0x22(%ebp),%eax
801061fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106203:	89 04 24             	mov    %eax,(%esp)
80106206:	e8 72 be ff ff       	call   8010207d <dirlookup>
8010620b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010620e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106212:	74 47                	je     8010625b <create+0xb4>
    iunlockput(dp);
80106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106217:	89 04 24             	mov    %eax,(%esp)
8010621a:	e8 c0 b8 ff ff       	call   80101adf <iunlockput>
    ilock(ip);
8010621f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106222:	89 04 24             	mov    %eax,(%esp)
80106225:	e8 31 b6 ff ff       	call   8010185b <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010622a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010622f:	75 15                	jne    80106246 <create+0x9f>
80106231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106234:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106238:	66 83 f8 02          	cmp    $0x2,%ax
8010623c:	75 08                	jne    80106246 <create+0x9f>
      return ip;
8010623e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106241:	e9 1f 01 00 00       	jmp    80106365 <create+0x1be>
    iunlockput(ip);
80106246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106249:	89 04 24             	mov    %eax,(%esp)
8010624c:	e8 8e b8 ff ff       	call   80101adf <iunlockput>
    return 0;
80106251:	b8 00 00 00 00       	mov    $0x0,%eax
80106256:	e9 0a 01 00 00       	jmp    80106365 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010625b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010625f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106262:	8b 00                	mov    (%eax),%eax
80106264:	89 54 24 04          	mov    %edx,0x4(%esp)
80106268:	89 04 24             	mov    %eax,(%esp)
8010626b:	e8 50 b3 ff ff       	call   801015c0 <ialloc>
80106270:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106273:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106277:	75 0c                	jne    80106285 <create+0xde>
    panic("create: ialloc");
80106279:	c7 04 24 8f 93 10 80 	movl   $0x8010938f,(%esp)
80106280:	e8 b5 a2 ff ff       	call   8010053a <panic>

  ilock(ip);
80106285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106288:	89 04 24             	mov    %eax,(%esp)
8010628b:	e8 cb b5 ff ff       	call   8010185b <ilock>
  ip->major = major;
80106290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106293:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106297:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010629b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801062a2:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801062a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a9:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801062af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b2:	89 04 24             	mov    %eax,(%esp)
801062b5:	e8 e5 b3 ff ff       	call   8010169f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801062ba:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801062bf:	75 6a                	jne    8010632b <create+0x184>
    dp->nlink++;  // for ".."
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062c8:	8d 50 01             	lea    0x1(%eax),%edx
801062cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ce:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801062d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d5:	89 04 24             	mov    %eax,(%esp)
801062d8:	e8 c2 b3 ff ff       	call   8010169f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e0:	8b 40 04             	mov    0x4(%eax),%eax
801062e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801062e7:	c7 44 24 04 69 93 10 	movl   $0x80109369,0x4(%esp)
801062ee:	80 
801062ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f2:	89 04 24             	mov    %eax,(%esp)
801062f5:	e8 4c be ff ff       	call   80102146 <dirlink>
801062fa:	85 c0                	test   %eax,%eax
801062fc:	78 21                	js     8010631f <create+0x178>
801062fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106301:	8b 40 04             	mov    0x4(%eax),%eax
80106304:	89 44 24 08          	mov    %eax,0x8(%esp)
80106308:	c7 44 24 04 6b 93 10 	movl   $0x8010936b,0x4(%esp)
8010630f:	80 
80106310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106313:	89 04 24             	mov    %eax,(%esp)
80106316:	e8 2b be ff ff       	call   80102146 <dirlink>
8010631b:	85 c0                	test   %eax,%eax
8010631d:	79 0c                	jns    8010632b <create+0x184>
      panic("create dots");
8010631f:	c7 04 24 9e 93 10 80 	movl   $0x8010939e,(%esp)
80106326:	e8 0f a2 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010632b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632e:	8b 40 04             	mov    0x4(%eax),%eax
80106331:	89 44 24 08          	mov    %eax,0x8(%esp)
80106335:	8d 45 de             	lea    -0x22(%ebp),%eax
80106338:	89 44 24 04          	mov    %eax,0x4(%esp)
8010633c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633f:	89 04 24             	mov    %eax,(%esp)
80106342:	e8 ff bd ff ff       	call   80102146 <dirlink>
80106347:	85 c0                	test   %eax,%eax
80106349:	79 0c                	jns    80106357 <create+0x1b0>
    panic("create: dirlink");
8010634b:	c7 04 24 aa 93 10 80 	movl   $0x801093aa,(%esp)
80106352:	e8 e3 a1 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635a:	89 04 24             	mov    %eax,(%esp)
8010635d:	e8 7d b7 ff ff       	call   80101adf <iunlockput>

  return ip;
80106362:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106365:	c9                   	leave  
80106366:	c3                   	ret    

80106367 <sys_open>:

int
sys_open(void)
{
80106367:	55                   	push   %ebp
80106368:	89 e5                	mov    %esp,%ebp
8010636a:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010636d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106370:	89 44 24 04          	mov    %eax,0x4(%esp)
80106374:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010637b:	e8 d9 f6 ff ff       	call   80105a59 <argstr>
80106380:	85 c0                	test   %eax,%eax
80106382:	78 17                	js     8010639b <sys_open+0x34>
80106384:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106387:	89 44 24 04          	mov    %eax,0x4(%esp)
8010638b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106392:	e8 32 f6 ff ff       	call   801059c9 <argint>
80106397:	85 c0                	test   %eax,%eax
80106399:	79 0a                	jns    801063a5 <sys_open+0x3e>
    return -1;
8010639b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a0:	e9 5c 01 00 00       	jmp    80106501 <sys_open+0x19a>

  begin_op();
801063a5:	e8 66 d0 ff ff       	call   80103410 <begin_op>

  if(omode & O_CREATE){
801063aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ad:	25 00 02 00 00       	and    $0x200,%eax
801063b2:	85 c0                	test   %eax,%eax
801063b4:	74 3b                	je     801063f1 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801063b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063c0:	00 
801063c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063c8:	00 
801063c9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801063d0:	00 
801063d1:	89 04 24             	mov    %eax,(%esp)
801063d4:	e8 ce fd ff ff       	call   801061a7 <create>
801063d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801063dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063e0:	75 6b                	jne    8010644d <sys_open+0xe6>
      end_op();
801063e2:	e8 ad d0 ff ff       	call   80103494 <end_op>
      return -1;
801063e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ec:	e9 10 01 00 00       	jmp    80106501 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
801063f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063f4:	89 04 24             	mov    %eax,(%esp)
801063f7:	e8 0a c0 ff ff       	call   80102406 <namei>
801063fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106403:	75 0f                	jne    80106414 <sys_open+0xad>
      end_op();
80106405:	e8 8a d0 ff ff       	call   80103494 <end_op>
      return -1;
8010640a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640f:	e9 ed 00 00 00       	jmp    80106501 <sys_open+0x19a>
    }
    ilock(ip);
80106414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106417:	89 04 24             	mov    %eax,(%esp)
8010641a:	e8 3c b4 ff ff       	call   8010185b <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010641f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106422:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106426:	66 83 f8 01          	cmp    $0x1,%ax
8010642a:	75 21                	jne    8010644d <sys_open+0xe6>
8010642c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010642f:	85 c0                	test   %eax,%eax
80106431:	74 1a                	je     8010644d <sys_open+0xe6>
      iunlockput(ip);
80106433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106436:	89 04 24             	mov    %eax,(%esp)
80106439:	e8 a1 b6 ff ff       	call   80101adf <iunlockput>
      end_op();
8010643e:	e8 51 d0 ff ff       	call   80103494 <end_op>
      return -1;
80106443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106448:	e9 b4 00 00 00       	jmp    80106501 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010644d:	e8 d4 aa ff ff       	call   80100f26 <filealloc>
80106452:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106455:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106459:	74 14                	je     8010646f <sys_open+0x108>
8010645b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645e:	89 04 24             	mov    %eax,(%esp)
80106461:	e8 2e f7 ff ff       	call   80105b94 <fdalloc>
80106466:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106469:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010646d:	79 28                	jns    80106497 <sys_open+0x130>
    if(f)
8010646f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106473:	74 0b                	je     80106480 <sys_open+0x119>
      fileclose(f);
80106475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106478:	89 04 24             	mov    %eax,(%esp)
8010647b:	e8 4e ab ff ff       	call   80100fce <fileclose>
    iunlockput(ip);
80106480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106483:	89 04 24             	mov    %eax,(%esp)
80106486:	e8 54 b6 ff ff       	call   80101adf <iunlockput>
    end_op();
8010648b:	e8 04 d0 ff ff       	call   80103494 <end_op>
    return -1;
80106490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106495:	eb 6a                	jmp    80106501 <sys_open+0x19a>
  }
  iunlock(ip);
80106497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649a:	89 04 24             	mov    %eax,(%esp)
8010649d:	e8 07 b5 ff ff       	call   801019a9 <iunlock>
  end_op();
801064a2:	e8 ed cf ff ff       	call   80103494 <end_op>

  f->type = FD_INODE;
801064a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064aa:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801064b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064b6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801064b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801064c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c6:	83 e0 01             	and    $0x1,%eax
801064c9:	85 c0                	test   %eax,%eax
801064cb:	0f 94 c0             	sete   %al
801064ce:	89 c2                	mov    %eax,%edx
801064d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064d9:	83 e0 01             	and    $0x1,%eax
801064dc:	85 c0                	test   %eax,%eax
801064de:	75 0a                	jne    801064ea <sys_open+0x183>
801064e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064e3:	83 e0 02             	and    $0x2,%eax
801064e6:	85 c0                	test   %eax,%eax
801064e8:	74 07                	je     801064f1 <sys_open+0x18a>
801064ea:	b8 01 00 00 00       	mov    $0x1,%eax
801064ef:	eb 05                	jmp    801064f6 <sys_open+0x18f>
801064f1:	b8 00 00 00 00       	mov    $0x0,%eax
801064f6:	89 c2                	mov    %eax,%edx
801064f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106501:	c9                   	leave  
80106502:	c3                   	ret    

80106503 <sys_mkdir>:

int
sys_mkdir(void)
{
80106503:	55                   	push   %ebp
80106504:	89 e5                	mov    %esp,%ebp
80106506:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106509:	e8 02 cf ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010650e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106511:	89 44 24 04          	mov    %eax,0x4(%esp)
80106515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010651c:	e8 38 f5 ff ff       	call   80105a59 <argstr>
80106521:	85 c0                	test   %eax,%eax
80106523:	78 2c                	js     80106551 <sys_mkdir+0x4e>
80106525:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106528:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010652f:	00 
80106530:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106537:	00 
80106538:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010653f:	00 
80106540:	89 04 24             	mov    %eax,(%esp)
80106543:	e8 5f fc ff ff       	call   801061a7 <create>
80106548:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010654b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010654f:	75 0c                	jne    8010655d <sys_mkdir+0x5a>
    end_op();
80106551:	e8 3e cf ff ff       	call   80103494 <end_op>
    return -1;
80106556:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655b:	eb 15                	jmp    80106572 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010655d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106560:	89 04 24             	mov    %eax,(%esp)
80106563:	e8 77 b5 ff ff       	call   80101adf <iunlockput>
  end_op();
80106568:	e8 27 cf ff ff       	call   80103494 <end_op>
  return 0;
8010656d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106572:	c9                   	leave  
80106573:	c3                   	ret    

80106574 <sys_mknod>:

int
sys_mknod(void)
{
80106574:	55                   	push   %ebp
80106575:	89 e5                	mov    %esp,%ebp
80106577:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010657a:	e8 91 ce ff ff       	call   80103410 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010657f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106582:	89 44 24 04          	mov    %eax,0x4(%esp)
80106586:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010658d:	e8 c7 f4 ff ff       	call   80105a59 <argstr>
80106592:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106595:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106599:	78 5e                	js     801065f9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010659b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010659e:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065a9:	e8 1b f4 ff ff       	call   801059c9 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801065ae:	85 c0                	test   %eax,%eax
801065b0:	78 47                	js     801065f9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801065c0:	e8 04 f4 ff ff       	call   801059c9 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801065c5:	85 c0                	test   %eax,%eax
801065c7:	78 30                	js     801065f9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801065c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065cc:	0f bf c8             	movswl %ax,%ecx
801065cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065d2:	0f bf d0             	movswl %ax,%edx
801065d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065d8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801065dc:	89 54 24 08          	mov    %edx,0x8(%esp)
801065e0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801065e7:	00 
801065e8:	89 04 24             	mov    %eax,(%esp)
801065eb:	e8 b7 fb ff ff       	call   801061a7 <create>
801065f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065f7:	75 0c                	jne    80106605 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801065f9:	e8 96 ce ff ff       	call   80103494 <end_op>
    return -1;
801065fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106603:	eb 15                	jmp    8010661a <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106605:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106608:	89 04 24             	mov    %eax,(%esp)
8010660b:	e8 cf b4 ff ff       	call   80101adf <iunlockput>
  end_op();
80106610:	e8 7f ce ff ff       	call   80103494 <end_op>
  return 0;
80106615:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661a:	c9                   	leave  
8010661b:	c3                   	ret    

8010661c <sys_chdir>:

int
sys_chdir(void)
{
8010661c:	55                   	push   %ebp
8010661d:	89 e5                	mov    %esp,%ebp
8010661f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106622:	e8 e9 cd ff ff       	call   80103410 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106627:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010662a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010662e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106635:	e8 1f f4 ff ff       	call   80105a59 <argstr>
8010663a:	85 c0                	test   %eax,%eax
8010663c:	78 14                	js     80106652 <sys_chdir+0x36>
8010663e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106641:	89 04 24             	mov    %eax,(%esp)
80106644:	e8 bd bd ff ff       	call   80102406 <namei>
80106649:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010664c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106650:	75 0c                	jne    8010665e <sys_chdir+0x42>
    end_op();
80106652:	e8 3d ce ff ff       	call   80103494 <end_op>
    return -1;
80106657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665c:	eb 61                	jmp    801066bf <sys_chdir+0xa3>
  }
  ilock(ip);
8010665e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106661:	89 04 24             	mov    %eax,(%esp)
80106664:	e8 f2 b1 ff ff       	call   8010185b <ilock>
  if(ip->type != T_DIR){
80106669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106670:	66 83 f8 01          	cmp    $0x1,%ax
80106674:	74 17                	je     8010668d <sys_chdir+0x71>
    iunlockput(ip);
80106676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106679:	89 04 24             	mov    %eax,(%esp)
8010667c:	e8 5e b4 ff ff       	call   80101adf <iunlockput>
    end_op();
80106681:	e8 0e ce ff ff       	call   80103494 <end_op>
    return -1;
80106686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668b:	eb 32                	jmp    801066bf <sys_chdir+0xa3>
  }
  iunlock(ip);
8010668d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106690:	89 04 24             	mov    %eax,(%esp)
80106693:	e8 11 b3 ff ff       	call   801019a9 <iunlock>
  iput(proc->cwd);
80106698:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010669e:	8b 40 6c             	mov    0x6c(%eax),%eax
801066a1:	89 04 24             	mov    %eax,(%esp)
801066a4:	e8 65 b3 ff ff       	call   80101a0e <iput>
  end_op();
801066a9:	e8 e6 cd ff ff       	call   80103494 <end_op>
  proc->cwd = ip;
801066ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066b7:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
801066ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066bf:	c9                   	leave  
801066c0:	c3                   	ret    

801066c1 <sys_exec>:

int
sys_exec(void)
{
801066c1:	55                   	push   %ebp
801066c2:	89 e5                	mov    %esp,%ebp
801066c4:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801066ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066d8:	e8 7c f3 ff ff       	call   80105a59 <argstr>
801066dd:	85 c0                	test   %eax,%eax
801066df:	78 1a                	js     801066fb <sys_exec+0x3a>
801066e1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066f2:	e8 d2 f2 ff ff       	call   801059c9 <argint>
801066f7:	85 c0                	test   %eax,%eax
801066f9:	79 0a                	jns    80106705 <sys_exec+0x44>
    return -1;
801066fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106700:	e9 c8 00 00 00       	jmp    801067cd <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106705:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010670c:	00 
8010670d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106714:	00 
80106715:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010671b:	89 04 24             	mov    %eax,(%esp)
8010671e:	e8 64 ef ff ff       	call   80105687 <memset>
  for(i=0;; i++){
80106723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672d:	83 f8 1f             	cmp    $0x1f,%eax
80106730:	76 0a                	jbe    8010673c <sys_exec+0x7b>
      return -1;
80106732:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106737:	e9 91 00 00 00       	jmp    801067cd <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010673c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673f:	c1 e0 02             	shl    $0x2,%eax
80106742:	89 c2                	mov    %eax,%edx
80106744:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010674a:	01 c2                	add    %eax,%edx
8010674c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106752:	89 44 24 04          	mov    %eax,0x4(%esp)
80106756:	89 14 24             	mov    %edx,(%esp)
80106759:	e8 cf f1 ff ff       	call   8010592d <fetchint>
8010675e:	85 c0                	test   %eax,%eax
80106760:	79 07                	jns    80106769 <sys_exec+0xa8>
      return -1;
80106762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106767:	eb 64                	jmp    801067cd <sys_exec+0x10c>
    if(uarg == 0){
80106769:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010676f:	85 c0                	test   %eax,%eax
80106771:	75 26                	jne    80106799 <sys_exec+0xd8>
      argv[i] = 0;
80106773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106776:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010677d:	00 00 00 00 
      break;
80106781:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106785:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010678b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010678f:	89 04 24             	mov    %eax,(%esp)
80106792:	e8 58 a3 ff ff       	call   80100aef <exec>
80106797:	eb 34                	jmp    801067cd <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106799:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010679f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067a2:	c1 e2 02             	shl    $0x2,%edx
801067a5:	01 c2                	add    %eax,%edx
801067a7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801067ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801067b1:	89 04 24             	mov    %eax,(%esp)
801067b4:	e8 ae f1 ff ff       	call   80105967 <fetchstr>
801067b9:	85 c0                	test   %eax,%eax
801067bb:	79 07                	jns    801067c4 <sys_exec+0x103>
      return -1;
801067bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c2:	eb 09                	jmp    801067cd <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801067c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801067c8:	e9 5d ff ff ff       	jmp    8010672a <sys_exec+0x69>
  return exec(path, argv);
}
801067cd:	c9                   	leave  
801067ce:	c3                   	ret    

801067cf <sys_pipe>:

int
sys_pipe(void)
{
801067cf:	55                   	push   %ebp
801067d0:	89 e5                	mov    %esp,%ebp
801067d2:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801067d5:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801067dc:	00 
801067dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801067e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067eb:	e8 07 f2 ff ff       	call   801059f7 <argptr>
801067f0:	85 c0                	test   %eax,%eax
801067f2:	79 0a                	jns    801067fe <sys_pipe+0x2f>
    return -1;
801067f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f9:	e9 9b 00 00 00       	jmp    80106899 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801067fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106801:	89 44 24 04          	mov    %eax,0x4(%esp)
80106805:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106808:	89 04 24             	mov    %eax,(%esp)
8010680b:	e8 11 d7 ff ff       	call   80103f21 <pipealloc>
80106810:	85 c0                	test   %eax,%eax
80106812:	79 07                	jns    8010681b <sys_pipe+0x4c>
    return -1;
80106814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106819:	eb 7e                	jmp    80106899 <sys_pipe+0xca>
  fd0 = -1;
8010681b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106822:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106825:	89 04 24             	mov    %eax,(%esp)
80106828:	e8 67 f3 ff ff       	call   80105b94 <fdalloc>
8010682d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106830:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106834:	78 14                	js     8010684a <sys_pipe+0x7b>
80106836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106839:	89 04 24             	mov    %eax,(%esp)
8010683c:	e8 53 f3 ff ff       	call   80105b94 <fdalloc>
80106841:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106844:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106848:	79 37                	jns    80106881 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010684a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010684e:	78 14                	js     80106864 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106850:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106856:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106859:	83 c2 08             	add    $0x8,%edx
8010685c:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80106863:	00 
    fileclose(rf);
80106864:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106867:	89 04 24             	mov    %eax,(%esp)
8010686a:	e8 5f a7 ff ff       	call   80100fce <fileclose>
    fileclose(wf);
8010686f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106872:	89 04 24             	mov    %eax,(%esp)
80106875:	e8 54 a7 ff ff       	call   80100fce <fileclose>
    return -1;
8010687a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687f:	eb 18                	jmp    80106899 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106881:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106884:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106887:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106889:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010688c:	8d 50 04             	lea    0x4(%eax),%edx
8010688f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106892:	89 02                	mov    %eax,(%edx)
  return 0;
80106894:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106899:	c9                   	leave  
8010689a:	c3                   	ret    

8010689b <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010689b:	55                   	push   %ebp
8010689c:	89 e5                	mov    %esp,%ebp
8010689e:	83 ec 08             	sub    $0x8,%esp
  return fork();
801068a1:	e8 c6 df ff ff       	call   8010486c <fork>
}
801068a6:	c9                   	leave  
801068a7:	c3                   	ret    

801068a8 <sys_exit>:

int
sys_exit(void)
{
801068a8:	55                   	push   %ebp
801068a9:	89 e5                	mov    %esp,%ebp
801068ab:	83 ec 08             	sub    $0x8,%esp
  exit();
801068ae:	e8 aa e1 ff ff       	call   80104a5d <exit>
  return 0;  // not reached
801068b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068b8:	c9                   	leave  
801068b9:	c3                   	ret    

801068ba <sys_wait>:

int
sys_wait(void)
{
801068ba:	55                   	push   %ebp
801068bb:	89 e5                	mov    %esp,%ebp
801068bd:	83 ec 08             	sub    $0x8,%esp
  return wait();
801068c0:	e8 e7 e2 ff ff       	call   80104bac <wait>
}
801068c5:	c9                   	leave  
801068c6:	c3                   	ret    

801068c7 <sys_kill>:

int
sys_kill(void)
{
801068c7:	55                   	push   %ebp
801068c8:	89 e5                	mov    %esp,%ebp
801068ca:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068db:	e8 e9 f0 ff ff       	call   801059c9 <argint>
801068e0:	85 c0                	test   %eax,%eax
801068e2:	79 07                	jns    801068eb <sys_kill+0x24>
    return -1;
801068e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e9:	eb 0b                	jmp    801068f6 <sys_kill+0x2f>
  return kill(pid);
801068eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ee:	89 04 24             	mov    %eax,(%esp)
801068f1:	e8 98 e6 ff ff       	call   80104f8e <kill>
}
801068f6:	c9                   	leave  
801068f7:	c3                   	ret    

801068f8 <sys_getpid>:

int
sys_getpid(void)
{
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801068fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106901:	8b 40 10             	mov    0x10(%eax),%eax
}
80106904:	5d                   	pop    %ebp
80106905:	c3                   	ret    

80106906 <sys_sbrk>:

int
sys_sbrk(void)
{
80106906:	55                   	push   %ebp
80106907:	89 e5                	mov    %esp,%ebp
80106909:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010690c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010690f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010691a:	e8 aa f0 ff ff       	call   801059c9 <argint>
8010691f:	85 c0                	test   %eax,%eax
80106921:	79 07                	jns    8010692a <sys_sbrk+0x24>
    return -1;
80106923:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106928:	eb 24                	jmp    8010694e <sys_sbrk+0x48>
  addr = proc->sz;
8010692a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106930:	8b 00                	mov    (%eax),%eax
80106932:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106938:	89 04 24             	mov    %eax,(%esp)
8010693b:	e8 87 de ff ff       	call   801047c7 <growproc>
80106940:	85 c0                	test   %eax,%eax
80106942:	79 07                	jns    8010694b <sys_sbrk+0x45>
    return -1;
80106944:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106949:	eb 03                	jmp    8010694e <sys_sbrk+0x48>
  return addr;
8010694b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010694e:	c9                   	leave  
8010694f:	c3                   	ret    

80106950 <sys_sleep>:

int
sys_sleep(void)
{
80106950:	55                   	push   %ebp
80106951:	89 e5                	mov    %esp,%ebp
80106953:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106956:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106959:	89 44 24 04          	mov    %eax,0x4(%esp)
8010695d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106964:	e8 60 f0 ff ff       	call   801059c9 <argint>
80106969:	85 c0                	test   %eax,%eax
8010696b:	79 07                	jns    80106974 <sys_sleep+0x24>
    return -1;
8010696d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106972:	eb 6c                	jmp    801069e0 <sys_sleep+0x90>
  acquire(&tickslock);
80106974:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
8010697b:	e8 b3 ea ff ff       	call   80105433 <acquire>
  ticks0 = ticks;
80106980:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106985:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106988:	eb 34                	jmp    801069be <sys_sleep+0x6e>
    if(proc->killed){
8010698a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106990:	8b 40 28             	mov    0x28(%eax),%eax
80106993:	85 c0                	test   %eax,%eax
80106995:	74 13                	je     801069aa <sys_sleep+0x5a>
      release(&tickslock);
80106997:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
8010699e:	e8 f2 ea ff ff       	call   80105495 <release>
      return -1;
801069a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069a8:	eb 36                	jmp    801069e0 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801069aa:	c7 44 24 04 00 87 11 	movl   $0x80118700,0x4(%esp)
801069b1:	80 
801069b2:	c7 04 24 40 8f 11 80 	movl   $0x80118f40,(%esp)
801069b9:	e8 c9 e4 ff ff       	call   80104e87 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801069be:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801069c3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801069c6:	89 c2                	mov    %eax,%edx
801069c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cb:	39 c2                	cmp    %eax,%edx
801069cd:	72 bb                	jb     8010698a <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801069cf:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801069d6:	e8 ba ea ff ff       	call   80105495 <release>
  return 0;
801069db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069e0:	c9                   	leave  
801069e1:	c3                   	ret    

801069e2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069e2:	55                   	push   %ebp
801069e3:	89 e5                	mov    %esp,%ebp
801069e5:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801069e8:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801069ef:	e8 3f ea ff ff       	call   80105433 <acquire>
  xticks = ticks;
801069f4:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801069f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069fc:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106a03:	e8 8d ea ff ff       	call   80105495 <release>
  return xticks;
80106a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a0b:	c9                   	leave  
80106a0c:	c3                   	ret    

80106a0d <sys_signal>:

int
sys_signal(void)
{
80106a0d:	55                   	push   %ebp
80106a0e:	89 e5                	mov    %esp,%ebp
80106a10:	53                   	push   %ebx
80106a11:	83 ec 24             	sub    $0x24,%esp
	int signum;
	int handler;

	if ( (argint(0, &signum) < 0) | (argint(1, &handler) < 0) )
80106a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a17:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a22:	e8 a2 ef ff ff       	call   801059c9 <argint>
80106a27:	c1 e8 1f             	shr    $0x1f,%eax
80106a2a:	89 c3                	mov    %eax,%ebx
80106a2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a3a:	e8 8a ef ff ff       	call   801059c9 <argint>
80106a3f:	c1 e8 1f             	shr    $0x1f,%eax
80106a42:	09 d8                	or     %ebx,%eax
80106a44:	84 c0                	test   %al,%al
80106a46:	74 07                	je     80106a4f <sys_signal+0x42>
		return -1;
80106a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a4d:	eb 14                	jmp    80106a63 <sys_signal+0x56>
	return signal(signum, (sighandler_t)handler);
80106a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a52:	89 c2                	mov    %eax,%edx
80106a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a57:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a5b:	89 04 24             	mov    %eax,(%esp)
80106a5e:	e8 a0 e6 ff ff       	call   80105103 <signal>
}
80106a63:	83 c4 24             	add    $0x24,%esp
80106a66:	5b                   	pop    %ebx
80106a67:	5d                   	pop    %ebp
80106a68:	c3                   	ret    

80106a69 <sys_sigsend>:

int
sys_sigsend(void)
{
80106a69:	55                   	push   %ebp
80106a6a:	89 e5                	mov    %esp,%ebp
80106a6c:	53                   	push   %ebx
80106a6d:	83 ec 24             	sub    $0x24,%esp
	int pid;
	int signum;

	if ( (argint(0, &pid) < 0) | (argint(1, &signum) < 0) )
80106a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a73:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a7e:	e8 46 ef ff ff       	call   801059c9 <argint>
80106a83:	c1 e8 1f             	shr    $0x1f,%eax
80106a86:	89 c3                	mov    %eax,%ebx
80106a88:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a96:	e8 2e ef ff ff       	call   801059c9 <argint>
80106a9b:	c1 e8 1f             	shr    $0x1f,%eax
80106a9e:	09 d8                	or     %ebx,%eax
80106aa0:	84 c0                	test   %al,%al
80106aa2:	74 07                	je     80106aab <sys_sigsend+0x42>
		return -1;
80106aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa9:	eb 12                	jmp    80106abd <sys_sigsend+0x54>
	return sigsend(pid, signum);
80106aab:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ab5:	89 04 24             	mov    %eax,(%esp)
80106ab8:	e8 8a e6 ff ff       	call   80105147 <sigsend>
}
80106abd:	83 c4 24             	add    $0x24,%esp
80106ac0:	5b                   	pop    %ebx
80106ac1:	5d                   	pop    %ebp
80106ac2:	c3                   	ret    

80106ac3 <sys_sigreturn>:

void copytf(struct trapframe *, struct trapframe *);

int
sys_sigreturn(void)
{
80106ac3:	55                   	push   %ebp
80106ac4:	89 e5                	mov    %esp,%ebp
80106ac6:	83 ec 18             	sub    $0x18,%esp
	//cprintf("sys_sigreturn for %d\n", proc->pid);
	copytf(proc->backuptf, proc->tf);	
80106ac9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106acf:	8b 50 18             	mov    0x18(%eax),%edx
80106ad2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad8:	8b 40 1c             	mov    0x1c(%eax),%eax
80106adb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106adf:	89 04 24             	mov    %eax,(%esp)
80106ae2:	e8 44 03 00 00       	call   80106e2b <copytf>
	proc->insignal=0;
80106ae7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aed:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80106af4:	00 00 00 
	return 0;
80106af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106afc:	c9                   	leave  
80106afd:	c3                   	ret    

80106afe <sys_advanceprocstats>:

int
sys_advanceprocstats(void) {
80106afe:	55                   	push   %ebp
80106aff:	89 e5                	mov    %esp,%ebp
80106b01:	83 ec 08             	sub    $0x8,%esp
       advanceprocstats();
80106b04:	e8 ed e6 ff ff       	call   801051f6 <advanceprocstats>
       return 0;
80106b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b0e:	c9                   	leave  
80106b0f:	c3                   	ret    

80106b10 <sys_wait_stat>:

int
sys_wait_stat(void)
{
80106b10:	55                   	push   %ebp
80106b11:	89 e5                	mov    %esp,%ebp
80106b13:	83 ec 28             	sub    $0x28,%esp
      // struct perf *perfP=0;
	   int perfP = 0;
80106b16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
       //cprintf("sys_wait_stat \n");
       //if(argptr(0, (char**)&perfP, 32) < 0)
       if(argint(0,&perfP) < 0)
80106b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b20:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b2b:	e8 99 ee ff ff       	call   801059c9 <argint>
80106b30:	85 c0                	test   %eax,%eax
80106b32:	79 07                	jns    80106b3b <sys_wait_stat+0x2b>
               return -1;
80106b34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b39:	eb 0b                	jmp    80106b46 <sys_wait_stat+0x36>
       return  wait_stat((struct perf *)perfP);
80106b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3e:	89 04 24             	mov    %eax,(%esp)
80106b41:	e8 36 e7 ff ff       	call   8010527c <wait_stat>
       //return  wait_stat((struct perf *)perfP);
}
80106b46:	c9                   	leave  
80106b47:	c3                   	ret    

80106b48 <sys_priority>:

int
sys_priority(void)
{
80106b48:	55                   	push   %ebp
80106b49:	89 e5                	mov    %esp,%ebp
80106b4b:	83 ec 28             	sub    $0x28,%esp
      int priority = 0;
80106b4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      if(argint(0, &priority) < 0)
80106b55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b58:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b63:	e8 61 ee ff ff       	call   801059c9 <argint>
80106b68:	85 c0                	test   %eax,%eax
80106b6a:	79 07                	jns    80106b73 <sys_priority+0x2b>
	  return -1;
80106b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b71:	eb 14                	jmp    80106b87 <sys_priority+0x3f>
      proc->priority = priority;
80106b73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b7c:	89 90 20 01 00 00    	mov    %edx,0x120(%eax)
      return 0;
80106b82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b87:	c9                   	leave  
80106b88:	c3                   	ret    

80106b89 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b89:	55                   	push   %ebp
80106b8a:	89 e5                	mov    %esp,%ebp
80106b8c:	83 ec 08             	sub    $0x8,%esp
80106b8f:	8b 55 08             	mov    0x8(%ebp),%edx
80106b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b95:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b99:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b9c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ba0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ba4:	ee                   	out    %al,(%dx)
}
80106ba5:	c9                   	leave  
80106ba6:	c3                   	ret    

80106ba7 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106ba7:	55                   	push   %ebp
80106ba8:	89 e5                	mov    %esp,%ebp
80106baa:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106bad:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106bb4:	00 
80106bb5:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106bbc:	e8 c8 ff ff ff       	call   80106b89 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106bc1:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106bc8:	00 
80106bc9:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106bd0:	e8 b4 ff ff ff       	call   80106b89 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106bd5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106bdc:	00 
80106bdd:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106be4:	e8 a0 ff ff ff       	call   80106b89 <outb>
  picenable(IRQ_TIMER);
80106be9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bf0:	e8 bf d1 ff ff       	call   80103db4 <picenable>
}
80106bf5:	c9                   	leave  
80106bf6:	c3                   	ret    

80106bf7 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106bf7:	1e                   	push   %ds
  pushl %es
80106bf8:	06                   	push   %es
  pushl %fs
80106bf9:	0f a0                	push   %fs
  pushl %gs
80106bfb:	0f a8                	push   %gs
  pushal
80106bfd:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106bfe:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106c02:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106c04:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106c06:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106c0a:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106c0c:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106c0e:	54                   	push   %esp
  call trap
80106c0f:	e8 4f 05 00 00       	call   80107163 <trap>
  call handleSignals
80106c14:	e8 d1 03 00 00       	call   80106fea <handleSignals>
  addl $4, %esp
80106c19:	83 c4 04             	add    $0x4,%esp

80106c1c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106c1c:	61                   	popa   
  popl %gs
80106c1d:	0f a9                	pop    %gs
  popl %fs
80106c1f:	0f a1                	pop    %fs
  popl %es
80106c21:	07                   	pop    %es
  popl %ds
80106c22:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106c23:	83 c4 08             	add    $0x8,%esp
  iret
80106c26:	cf                   	iret   

80106c27 <implicit_sigret>:

# new func - implicit_sigret

implicit_sigret:
  pushl %eax
80106c27:	50                   	push   %eax
  movl $SYS_sigreturn, %eax
80106c28:	b8 1a 00 00 00       	mov    $0x1a,%eax
  int $T_SYSCALL
80106c2d:	cd 40                	int    $0x40

80106c2f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106c2f:	55                   	push   %ebp
80106c30:	89 e5                	mov    %esp,%ebp
80106c32:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c38:	83 e8 01             	sub    $0x1,%eax
80106c3b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c42:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106c46:	8b 45 08             	mov    0x8(%ebp),%eax
80106c49:	c1 e8 10             	shr    $0x10,%eax
80106c4c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106c50:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106c53:	0f 01 18             	lidtl  (%eax)
}
80106c56:	c9                   	leave  
80106c57:	c3                   	ret    

80106c58 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106c58:	55                   	push   %ebp
80106c59:	89 e5                	mov    %esp,%ebp
80106c5b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106c5e:	0f 20 d0             	mov    %cr2,%eax
80106c61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106c67:	c9                   	leave  
80106c68:	c3                   	ret    

80106c69 <tvinit>:
extern int implicit_sigret();
extern int end_of_sigret();

void
tvinit(void)
{
80106c69:	55                   	push   %ebp
80106c6a:	89 e5                	mov    %esp,%ebp
80106c6c:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106c6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c76:	e9 c3 00 00 00       	jmp    80106d3e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c7e:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106c85:	89 c2                	mov    %eax,%edx
80106c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c8a:	66 89 14 c5 40 87 11 	mov    %dx,-0x7fee78c0(,%eax,8)
80106c91:	80 
80106c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c95:	66 c7 04 c5 42 87 11 	movw   $0x8,-0x7fee78be(,%eax,8)
80106c9c:	80 08 00 
80106c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca2:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106ca9:	80 
80106caa:	83 e2 e0             	and    $0xffffffe0,%edx
80106cad:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cb7:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106cbe:	80 
80106cbf:	83 e2 1f             	and    $0x1f,%edx
80106cc2:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ccc:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106cd3:	80 
80106cd4:	83 e2 f0             	and    $0xfffffff0,%edx
80106cd7:	83 ca 0e             	or     $0xe,%edx
80106cda:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ce4:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106ceb:	80 
80106cec:	83 e2 ef             	and    $0xffffffef,%edx
80106cef:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cf9:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106d00:	80 
80106d01:	83 e2 9f             	and    $0xffffff9f,%edx
80106d04:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d0e:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106d15:	80 
80106d16:	83 ca 80             	or     $0xffffff80,%edx
80106d19:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d23:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106d2a:	c1 e8 10             	shr    $0x10,%eax
80106d2d:	89 c2                	mov    %eax,%edx
80106d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d32:	66 89 14 c5 46 87 11 	mov    %dx,-0x7fee78ba(,%eax,8)
80106d39:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106d3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d3e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106d45:	0f 8e 30 ff ff ff    	jle    80106c7b <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106d4b:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106d50:	66 a3 40 89 11 80    	mov    %ax,0x80118940
80106d56:	66 c7 05 42 89 11 80 	movw   $0x8,0x80118942
80106d5d:	08 00 
80106d5f:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106d66:	83 e0 e0             	and    $0xffffffe0,%eax
80106d69:	a2 44 89 11 80       	mov    %al,0x80118944
80106d6e:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106d75:	83 e0 1f             	and    $0x1f,%eax
80106d78:	a2 44 89 11 80       	mov    %al,0x80118944
80106d7d:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106d84:	83 c8 0f             	or     $0xf,%eax
80106d87:	a2 45 89 11 80       	mov    %al,0x80118945
80106d8c:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106d93:	83 e0 ef             	and    $0xffffffef,%eax
80106d96:	a2 45 89 11 80       	mov    %al,0x80118945
80106d9b:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106da2:	83 c8 60             	or     $0x60,%eax
80106da5:	a2 45 89 11 80       	mov    %al,0x80118945
80106daa:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106db1:	83 c8 80             	or     $0xffffff80,%eax
80106db4:	a2 45 89 11 80       	mov    %al,0x80118945
80106db9:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106dbe:	c1 e8 10             	shr    $0x10,%eax
80106dc1:	66 a3 46 89 11 80    	mov    %ax,0x80118946
  
  initlock(&tickslock, "time");
80106dc7:	c7 44 24 04 bc 93 10 	movl   $0x801093bc,0x4(%esp)
80106dce:	80 
80106dcf:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
80106dd6:	e8 37 e6 ff ff       	call   80105412 <initlock>
}
80106ddb:	c9                   	leave  
80106ddc:	c3                   	ret    

80106ddd <idtinit>:

void
idtinit(void)
{
80106ddd:	55                   	push   %ebp
80106dde:	89 e5                	mov    %esp,%ebp
80106de0:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106de3:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106dea:	00 
80106deb:	c7 04 24 40 87 11 80 	movl   $0x80118740,(%esp)
80106df2:	e8 38 fe ff ff       	call   80106c2f <lidt>
}
80106df7:	c9                   	leave  
80106df8:	c3                   	ret    

80106df9 <getLowestSetBit>:

/**
 * Gets an integer, and returns the number of the lowest bit which is set to 1
**/
int 
getLowestSetBit(int num) {
80106df9:	55                   	push   %ebp
80106dfa:	89 e5                	mov    %esp,%ebp
80106dfc:	83 ec 10             	sub    $0x10,%esp
    if (num == 0)
80106dff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106e03:	75 07                	jne    80106e0c <getLowestSetBit+0x13>
	return -1;
80106e05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e0a:	eb 1d                	jmp    80106e29 <getLowestSetBit+0x30>
    
    int bitNum = 0;
80106e0c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while ((num & 1) == 0) {
80106e13:	eb 07                	jmp    80106e1c <getLowestSetBit+0x23>
	num = num >> 1;
80106e15:	d1 7d 08             	sarl   0x8(%ebp)
	bitNum++;
80106e18:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
getLowestSetBit(int num) {
    if (num == 0)
	return -1;
    
    int bitNum = 0;
    while ((num & 1) == 0) {
80106e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1f:	83 e0 01             	and    $0x1,%eax
80106e22:	85 c0                	test   %eax,%eax
80106e24:	74 ef                	je     80106e15 <getLowestSetBit+0x1c>
	num = num >> 1;
	bitNum++;
    }
    return bitNum;
80106e26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106e29:	c9                   	leave  
80106e2a:	c3                   	ret    

80106e2b <copytf>:

void
copytf(struct trapframe * tf, struct trapframe * copyaddr) {
80106e2b:	55                   	push   %ebp
80106e2c:	89 e5                	mov    %esp,%ebp
    copyaddr->edi = tf->edi;
80106e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e31:	8b 10                	mov    (%eax),%edx
80106e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e36:	89 10                	mov    %edx,(%eax)
    copyaddr->esi = tf->esi;
80106e38:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3b:	8b 50 04             	mov    0x4(%eax),%edx
80106e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e41:	89 50 04             	mov    %edx,0x4(%eax)
    copyaddr->ebp = tf->ebp;
80106e44:	8b 45 08             	mov    0x8(%ebp),%eax
80106e47:	8b 50 08             	mov    0x8(%eax),%edx
80106e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e4d:	89 50 08             	mov    %edx,0x8(%eax)
    copyaddr->oesp = tf->oesp;
80106e50:	8b 45 08             	mov    0x8(%ebp),%eax
80106e53:	8b 50 0c             	mov    0xc(%eax),%edx
80106e56:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e59:	89 50 0c             	mov    %edx,0xc(%eax)
    copyaddr->ebx = tf->ebx;
80106e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5f:	8b 50 10             	mov    0x10(%eax),%edx
80106e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e65:	89 50 10             	mov    %edx,0x10(%eax)
    copyaddr->edx = tf->edx;
80106e68:	8b 45 08             	mov    0x8(%ebp),%eax
80106e6b:	8b 50 14             	mov    0x14(%eax),%edx
80106e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e71:	89 50 14             	mov    %edx,0x14(%eax)
    copyaddr->ecx = tf->ecx;
80106e74:	8b 45 08             	mov    0x8(%ebp),%eax
80106e77:	8b 50 18             	mov    0x18(%eax),%edx
80106e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e7d:	89 50 18             	mov    %edx,0x18(%eax)
    copyaddr->eax = tf->eax;
80106e80:	8b 45 08             	mov    0x8(%ebp),%eax
80106e83:	8b 50 1c             	mov    0x1c(%eax),%edx
80106e86:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e89:	89 50 1c             	mov    %edx,0x1c(%eax)
    copyaddr->gs = tf->gs;
80106e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e8f:	0f b7 50 20          	movzwl 0x20(%eax),%edx
80106e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e96:	66 89 50 20          	mov    %dx,0x20(%eax)
    copyaddr->padding1 = tf->padding1;
80106e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9d:	0f b7 50 22          	movzwl 0x22(%eax),%edx
80106ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ea4:	66 89 50 22          	mov    %dx,0x22(%eax)
    copyaddr->fs = tf->fs;
80106ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80106eab:	0f b7 50 24          	movzwl 0x24(%eax),%edx
80106eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eb2:	66 89 50 24          	mov    %dx,0x24(%eax)
    copyaddr->padding2 = tf->padding2;
80106eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb9:	0f b7 50 26          	movzwl 0x26(%eax),%edx
80106ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ec0:	66 89 50 26          	mov    %dx,0x26(%eax)
    copyaddr->es = tf->es;
80106ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec7:	0f b7 50 28          	movzwl 0x28(%eax),%edx
80106ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ece:	66 89 50 28          	mov    %dx,0x28(%eax)
    copyaddr->padding3 = tf->padding3;
80106ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed5:	0f b7 50 2a          	movzwl 0x2a(%eax),%edx
80106ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106edc:	66 89 50 2a          	mov    %dx,0x2a(%eax)
    copyaddr->ds = tf->ds;
80106ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee3:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80106ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eea:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    copyaddr->padding4 = tf->padding4;
80106eee:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef1:	0f b7 50 2e          	movzwl 0x2e(%eax),%edx
80106ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ef8:	66 89 50 2e          	mov    %dx,0x2e(%eax)
    copyaddr->trapno = tf->trapno;
80106efc:	8b 45 08             	mov    0x8(%ebp),%eax
80106eff:	8b 50 30             	mov    0x30(%eax),%edx
80106f02:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f05:	89 50 30             	mov    %edx,0x30(%eax)
    copyaddr->err = tf->err;
80106f08:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0b:	8b 50 34             	mov    0x34(%eax),%edx
80106f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f11:	89 50 34             	mov    %edx,0x34(%eax)
    copyaddr->eip = tf->eip;
80106f14:	8b 45 08             	mov    0x8(%ebp),%eax
80106f17:	8b 50 38             	mov    0x38(%eax),%edx
80106f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f1d:	89 50 38             	mov    %edx,0x38(%eax)
    copyaddr->cs = tf->cs;
80106f20:	8b 45 08             	mov    0x8(%ebp),%eax
80106f23:	0f b7 50 3c          	movzwl 0x3c(%eax),%edx
80106f27:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f2a:	66 89 50 3c          	mov    %dx,0x3c(%eax)
    copyaddr->padding5 = tf->padding5;
80106f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f31:	0f b7 50 3e          	movzwl 0x3e(%eax),%edx
80106f35:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f38:	66 89 50 3e          	mov    %dx,0x3e(%eax)
    copyaddr->eflags = tf->eflags;
80106f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3f:	8b 50 40             	mov    0x40(%eax),%edx
80106f42:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f45:	89 50 40             	mov    %edx,0x40(%eax)
    copyaddr->esp = tf->esp;
80106f48:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4b:	8b 50 44             	mov    0x44(%eax),%edx
80106f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f51:	89 50 44             	mov    %edx,0x44(%eax)
    copyaddr->ss = tf->ss;
80106f54:	8b 45 08             	mov    0x8(%ebp),%eax
80106f57:	0f b7 50 48          	movzwl 0x48(%eax),%edx
80106f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f5e:	66 89 50 48          	mov    %dx,0x48(%eax)
    copyaddr->padding6 = tf->padding6;
80106f62:	8b 45 08             	mov    0x8(%ebp),%eax
80106f65:	0f b7 50 4a          	movzwl 0x4a(%eax),%edx
80106f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f6c:	66 89 50 4a          	mov    %dx,0x4a(%eax)
    return;
80106f70:	90                   	nop
}
80106f71:	5d                   	pop    %ebp
80106f72:	c3                   	ret    

80106f73 <int2bin>:


char *int2bin(int a)
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
80106f76:	83 ec 18             	sub    $0x18,%esp
 char *str,*tmp;
 int cnt = 31;
80106f79:	c7 45 f4 1f 00 00 00 	movl   $0x1f,-0xc(%ebp)
 str = (char *) kalloc(); /*32 + 1 , because its a 32 bit bin number*/
80106f80:	e8 5d bb ff ff       	call   80102ae2 <kalloc>
80106f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
 tmp = str;
80106f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 while ( cnt > -1 ){
80106f8e:	eb 0f                	jmp    80106f9f <int2bin+0x2c>
      str[cnt]= '0';
80106f90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f96:	01 d0                	add    %edx,%eax
80106f98:	c6 00 30             	movb   $0x30,(%eax)
      cnt --;
80106f9b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
{
 char *str,*tmp;
 int cnt = 31;
 str = (char *) kalloc(); /*32 + 1 , because its a 32 bit bin number*/
 tmp = str;
 while ( cnt > -1 ){
80106f9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fa3:	79 eb                	jns    80106f90 <int2bin+0x1d>
      str[cnt]= '0';
      cnt --;
 }
 cnt = 31;
80106fa5:	c7 45 f4 1f 00 00 00 	movl   $0x1f,-0xc(%ebp)
 while (a > 0){
80106fac:	eb 31                	jmp    80106fdf <int2bin+0x6c>
       if (a%2==1){
80106fae:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb1:	99                   	cltd   
80106fb2:	c1 ea 1f             	shr    $0x1f,%edx
80106fb5:	01 d0                	add    %edx,%eax
80106fb7:	83 e0 01             	and    $0x1,%eax
80106fba:	29 d0                	sub    %edx,%eax
80106fbc:	83 f8 01             	cmp    $0x1,%eax
80106fbf:	75 0b                	jne    80106fcc <int2bin+0x59>
           str[cnt] = '1';
80106fc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fc7:	01 d0                	add    %edx,%eax
80106fc9:	c6 00 31             	movb   $0x31,(%eax)
        }
      cnt--;
80106fcc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
        a = a/2 ;
80106fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd3:	89 c2                	mov    %eax,%edx
80106fd5:	c1 ea 1f             	shr    $0x1f,%edx
80106fd8:	01 d0                	add    %edx,%eax
80106fda:	d1 f8                	sar    %eax
80106fdc:	89 45 08             	mov    %eax,0x8(%ebp)
 while ( cnt > -1 ){
      str[cnt]= '0';
      cnt --;
 }
 cnt = 31;
 while (a > 0){
80106fdf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106fe3:	7f c9                	jg     80106fae <int2bin+0x3b>
           str[cnt] = '1';
        }
      cnt--;
        a = a/2 ;
 }
 return tmp;
80106fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax

}
80106fe8:	c9                   	leave  
80106fe9:	c3                   	ret    

80106fea <handleSignals>:

void
handleSignals(struct trapframe *tf) {      
80106fea:	55                   	push   %ebp
80106feb:	89 e5                	mov    %esp,%ebp
80106fed:	56                   	push   %esi
80106fee:	53                   	push   %ebx
80106fef:	83 ec 30             	sub    $0x30,%esp
    if(tf->trapno == T_SYSCALL && proc->pending > 0 && proc->insignal == 0) {      
80106ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ff5:	8b 40 30             	mov    0x30(%eax),%eax
80106ff8:	83 f8 40             	cmp    $0x40,%eax
80106ffb:	0f 85 5a 01 00 00    	jne    8010715b <handleSignals+0x171>
80107001:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107007:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010700d:	85 c0                	test   %eax,%eax
8010700f:	0f 8e 46 01 00 00    	jle    8010715b <handleSignals+0x171>
80107015:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010701b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80107021:	85 c0                	test   %eax,%eax
80107023:	0f 85 32 01 00 00    	jne    8010715b <handleSignals+0x171>
      int signum = getLowestSetBit(proc->pending);
80107029:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010702f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107035:	89 04 24             	mov    %eax,(%esp)
80107038:	e8 bc fd ff ff       	call   80106df9 <getLowestSetBit>
8010703d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      proc->pending &= ~(1 << signum);
80107040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107046:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010704d:	8b 9a 80 00 00 00    	mov    0x80(%edx),%ebx
80107053:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107056:	be 01 00 00 00       	mov    $0x1,%esi
8010705b:	89 d1                	mov    %edx,%ecx
8010705d:	d3 e6                	shl    %cl,%esi
8010705f:	89 f2                	mov    %esi,%edx
80107061:	f7 d2                	not    %edx
80107063:	21 da                	and    %ebx,%edx
80107065:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
      proc->insignal = 1;
8010706b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107071:	c7 80 84 00 00 00 01 	movl   $0x1,0x84(%eax)
80107078:	00 00 00 
      sighandler_t handler = proc->signal_handlers[signum];
8010707b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107081:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107084:	83 c2 20             	add    $0x20,%edx
80107087:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010708b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (!proc->backuptf) {
8010708e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107094:	8b 40 1c             	mov    0x1c(%eax),%eax
80107097:	85 c0                	test   %eax,%eax
80107099:	75 0f                	jne    801070aa <handleSignals+0xc0>
          proc->backuptf = (struct trapframe*)kalloc();
8010709b:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801070a2:	e8 3b ba ff ff       	call   80102ae2 <kalloc>
801070a7:	89 43 1c             	mov    %eax,0x1c(%ebx)
      }
      copytf(proc->tf, proc->backuptf);          // Copy trap frame, to be reconstruced later
801070aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070b0:	8b 50 1c             	mov    0x1c(%eax),%edx
801070b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070b9:	8b 40 18             	mov    0x18(%eax),%eax
801070bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801070c0:	89 04 24             	mov    %eax,(%esp)
801070c3:	e8 63 fd ff ff       	call   80106e2b <copytf>
      
      int* sp = (int*)proc->tf->esp;
801070c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070ce:	8b 40 18             	mov    0x18(%eax),%eax
801070d1:	8b 40 44             	mov    0x44(%eax),%eax
801070d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      int funcAddr = (int)(sp - 5); // We put the sigret function 5*4 bytes under the stack pointer. (its size is approx. 8 bytes)
801070d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070da:	83 e8 14             	sub    $0x14,%eax
801070dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int funcSize = (int)&end_of_sigret - (int)&implicit_sigret;		
801070e0:	ba 2f 6c 10 80       	mov    $0x80106c2f,%edx
801070e5:	b8 27 6c 10 80       	mov    $0x80106c27,%eax
801070ea:	29 c2                	sub    %eax,%edx
801070ec:	89 d0                	mov    %edx,%eax
801070ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      copyout(proc->pgdir, funcAddr, &implicit_sigret, funcSize);			// Push implicit_sigret argument to stack
801070f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801070f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801070f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070fd:	8b 40 04             	mov    0x4(%eax),%eax
80107100:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107104:	c7 44 24 08 27 6c 10 	movl   $0x80106c27,0x8(%esp)
8010710b:	80 
8010710c:	89 54 24 04          	mov    %edx,0x4(%esp)
80107110:	89 04 24             	mov    %eax,(%esp)
80107113:	e8 9c 1d 00 00       	call   80108eb4 <copyout>
      
      // We put the arguent 4 bytes under the stack pointer, and the ret address 8 bytes under.
      sp--;
80107118:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
      *sp = signum;
8010711c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010711f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107122:	89 10                	mov    %edx,(%eax)
      sp--;  
80107124:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
      *sp = funcAddr;    
80107128:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010712b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010712e:	89 10                	mov    %edx,(%eax)
    
      // new we set the stack pointer to be 8 bytes under (where the ret address is located)
      proc->tf->esp -= 8;
80107130:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107136:	8b 40 18             	mov    0x18(%eax),%eax
80107139:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107140:	8b 52 18             	mov    0x18(%edx),%edx
80107143:	8b 52 44             	mov    0x44(%edx),%edx
80107146:	83 ea 08             	sub    $0x8,%edx
80107149:	89 50 44             	mov    %edx,0x44(%eax)
      proc->tf->eip = (uint)handler;
8010714c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107152:	8b 40 18             	mov    0x18(%eax),%eax
80107155:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107158:	89 50 38             	mov    %edx,0x38(%eax)
    }
    return;
8010715b:	90                   	nop
}
8010715c:	83 c4 30             	add    $0x30,%esp
8010715f:	5b                   	pop    %ebx
80107160:	5e                   	pop    %esi
80107161:	5d                   	pop    %ebp
80107162:	c3                   	ret    

80107163 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107163:	55                   	push   %ebp
80107164:	89 e5                	mov    %esp,%ebp
80107166:	57                   	push   %edi
80107167:	56                   	push   %esi
80107168:	53                   	push   %ebx
80107169:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010716c:	8b 45 08             	mov    0x8(%ebp),%eax
8010716f:	8b 40 30             	mov    0x30(%eax),%eax
80107172:	83 f8 40             	cmp    $0x40,%eax
80107175:	75 3f                	jne    801071b6 <trap+0x53>
    if(proc->killed)
80107177:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010717d:	8b 40 28             	mov    0x28(%eax),%eax
80107180:	85 c0                	test   %eax,%eax
80107182:	74 05                	je     80107189 <trap+0x26>
      exit();
80107184:	e8 d4 d8 ff ff       	call   80104a5d <exit>
    proc->tf = tf;
80107189:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010718f:	8b 55 08             	mov    0x8(%ebp),%edx
80107192:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107195:	e8 f6 e8 ff ff       	call   80105a90 <syscall>
    if(proc->killed)
8010719a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071a0:	8b 40 28             	mov    0x28(%eax),%eax
801071a3:	85 c0                	test   %eax,%eax
801071a5:	74 0a                	je     801071b1 <trap+0x4e>
      exit();
801071a7:	e8 b1 d8 ff ff       	call   80104a5d <exit>
    return;
801071ac:	e9 9c 02 00 00       	jmp    8010744d <trap+0x2ea>
801071b1:	e9 97 02 00 00       	jmp    8010744d <trap+0x2ea>
  }

  switch(tf->trapno){
801071b6:	8b 45 08             	mov    0x8(%ebp),%eax
801071b9:	8b 40 30             	mov    0x30(%eax),%eax
801071bc:	83 e8 20             	sub    $0x20,%eax
801071bf:	83 f8 1f             	cmp    $0x1f,%eax
801071c2:	0f 87 c1 00 00 00    	ja     80107289 <trap+0x126>
801071c8:	8b 04 85 64 94 10 80 	mov    -0x7fef6b9c(,%eax,4),%eax
801071cf:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801071d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801071d7:	0f b6 00             	movzbl (%eax),%eax
801071da:	84 c0                	test   %al,%al
801071dc:	75 36                	jne    80107214 <trap+0xb1>
      acquire(&tickslock);
801071de:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
801071e5:	e8 49 e2 ff ff       	call   80105433 <acquire>
      ticks++;
801071ea:	a1 40 8f 11 80       	mov    0x80118f40,%eax
801071ef:	83 c0 01             	add    $0x1,%eax
801071f2:	a3 40 8f 11 80       	mov    %eax,0x80118f40
      wakeup(&ticks);
801071f7:	c7 04 24 40 8f 11 80 	movl   $0x80118f40,(%esp)
801071fe:	e8 60 dd ff ff       	call   80104f63 <wakeup>
      advanceprocstats();
80107203:	e8 ee df ff ff       	call   801051f6 <advanceprocstats>
      release(&tickslock);
80107208:	c7 04 24 00 87 11 80 	movl   $0x80118700,(%esp)
8010720f:	e8 81 e2 ff ff       	call   80105495 <release>
    }
    lapiceoi();
80107214:	e8 b7 bc ff ff       	call   80102ed0 <lapiceoi>
    break;
80107219:	e9 41 01 00 00       	jmp    8010735f <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010721e:	e8 bb b4 ff ff       	call   801026de <ideintr>
    lapiceoi();
80107223:	e8 a8 bc ff ff       	call   80102ed0 <lapiceoi>
    break;
80107228:	e9 32 01 00 00       	jmp    8010735f <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010722d:	e8 6d ba ff ff       	call   80102c9f <kbdintr>
    lapiceoi();
80107232:	e8 99 bc ff ff       	call   80102ed0 <lapiceoi>
    break;
80107237:	e9 23 01 00 00       	jmp    8010735f <trap+0x1fc>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010723c:	e8 01 04 00 00       	call   80107642 <uartintr>
    lapiceoi();
80107241:	e8 8a bc ff ff       	call   80102ed0 <lapiceoi>
    break;
80107246:	e9 14 01 00 00       	jmp    8010735f <trap+0x1fc>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010724b:	8b 45 08             	mov    0x8(%ebp),%eax
8010724e:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107251:	8b 45 08             	mov    0x8(%ebp),%eax
80107254:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107258:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010725b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107261:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107264:	0f b6 c0             	movzbl %al,%eax
80107267:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010726b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010726f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107273:	c7 04 24 c4 93 10 80 	movl   $0x801093c4,(%esp)
8010727a:	e8 21 91 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010727f:	e8 4c bc ff ff       	call   80102ed0 <lapiceoi>
    break;
80107284:	e9 d6 00 00 00       	jmp    8010735f <trap+0x1fc>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010728f:	85 c0                	test   %eax,%eax
80107291:	74 11                	je     801072a4 <trap+0x141>
80107293:	8b 45 08             	mov    0x8(%ebp),%eax
80107296:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010729a:	0f b7 c0             	movzwl %ax,%eax
8010729d:	83 e0 03             	and    $0x3,%eax
801072a0:	85 c0                	test   %eax,%eax
801072a2:	75 46                	jne    801072ea <trap+0x187>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801072a4:	e8 af f9 ff ff       	call   80106c58 <rcr2>
801072a9:	8b 55 08             	mov    0x8(%ebp),%edx
801072ac:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801072af:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801072b6:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801072b9:	0f b6 ca             	movzbl %dl,%ecx
801072bc:	8b 55 08             	mov    0x8(%ebp),%edx
801072bf:	8b 52 30             	mov    0x30(%edx),%edx
801072c2:	89 44 24 10          	mov    %eax,0x10(%esp)
801072c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801072ca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801072ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801072d2:	c7 04 24 e8 93 10 80 	movl   $0x801093e8,(%esp)
801072d9:	e8 c2 90 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801072de:	c7 04 24 1a 94 10 80 	movl   $0x8010941a,(%esp)
801072e5:	e8 50 92 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072ea:	e8 69 f9 ff ff       	call   80106c58 <rcr2>
801072ef:	89 c2                	mov    %eax,%edx
801072f1:	8b 45 08             	mov    0x8(%ebp),%eax
801072f4:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801072f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801072fd:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107300:	0f b6 f0             	movzbl %al,%esi
80107303:	8b 45 08             	mov    0x8(%ebp),%eax
80107306:	8b 58 34             	mov    0x34(%eax),%ebx
80107309:	8b 45 08             	mov    0x8(%ebp),%eax
8010730c:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010730f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107315:	83 c0 70             	add    $0x70,%eax
80107318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010731b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107321:	8b 40 10             	mov    0x10(%eax),%eax
80107324:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107328:	89 7c 24 18          	mov    %edi,0x18(%esp)
8010732c:	89 74 24 14          	mov    %esi,0x14(%esp)
80107330:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107334:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107338:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010733b:	89 74 24 08          	mov    %esi,0x8(%esp)
8010733f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107343:	c7 04 24 20 94 10 80 	movl   $0x80109420,(%esp)
8010734a:	e8 51 90 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010734f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107355:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
8010735c:	eb 01                	jmp    8010735f <trap+0x1fc>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010735e:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010735f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107365:	85 c0                	test   %eax,%eax
80107367:	74 24                	je     8010738d <trap+0x22a>
80107369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010736f:	8b 40 28             	mov    0x28(%eax),%eax
80107372:	85 c0                	test   %eax,%eax
80107374:	74 17                	je     8010738d <trap+0x22a>
80107376:	8b 45 08             	mov    0x8(%ebp),%eax
80107379:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010737d:	0f b7 c0             	movzwl %ax,%eax
80107380:	83 e0 03             	and    $0x3,%eax
80107383:	83 f8 03             	cmp    $0x3,%eax
80107386:	75 05                	jne    8010738d <trap+0x22a>
    exit();
80107388:	e8 d0 d6 ff ff       	call   80104a5d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
8010738d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107393:	85 c0                	test   %eax,%eax
80107395:	0f 84 84 00 00 00    	je     8010741f <trap+0x2bc>
8010739b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a1:	8b 40 0c             	mov    0xc(%eax),%eax
801073a4:	83 f8 04             	cmp    $0x4,%eax
801073a7:	75 76                	jne    8010741f <trap+0x2bc>
801073a9:	8b 45 08             	mov    0x8(%ebp),%eax
801073ac:	8b 40 30             	mov    0x30(%eax),%eax
801073af:	83 f8 20             	cmp    $0x20,%eax
801073b2:	75 6b                	jne    8010741f <trap+0x2bc>
	  #ifdef FCFS
		 isFCFS = 1;
	  #endif
	  if( proc->runQuanta % QUANTA == 0 && isFCFS == 0){
801073b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073ba:	8b 88 1c 01 00 00    	mov    0x11c(%eax),%ecx
801073c0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801073c5:	89 c8                	mov    %ecx,%eax
801073c7:	f7 ea                	imul   %edx
801073c9:	d1 fa                	sar    %edx
801073cb:	89 c8                	mov    %ecx,%eax
801073cd:	c1 f8 1f             	sar    $0x1f,%eax
801073d0:	29 c2                	sub    %eax,%edx
801073d2:	89 d0                	mov    %edx,%eax
801073d4:	c1 e0 02             	shl    $0x2,%eax
801073d7:	01 d0                	add    %edx,%eax
801073d9:	29 c1                	sub    %eax,%ecx
801073db:	89 ca                	mov    %ecx,%edx
801073dd:	85 d2                	test   %edx,%edx
801073df:	75 29                	jne    8010740a <trap+0x2a7>
801073e1:	a1 70 c6 10 80       	mov    0x8010c670,%eax
801073e6:	85 c0                	test   %eax,%eax
801073e8:	75 20                	jne    8010740a <trap+0x2a7>
		  //cprintf(" \n ******* pid=%d; runQuanta=%d; rutime=%d; \n",proc->pid,proc->runQuanta,proc->rutime-1);
		  proc->runQuanta=proc->rutime;
801073ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801073f7:	8b 92 18 01 00 00    	mov    0x118(%edx),%edx
801073fd:	89 90 1c 01 00 00    	mov    %edx,0x11c(%eax)
		  yield();
80107403:	e8 21 da ff ff       	call   80104e29 <yield>
80107408:	eb 15                	jmp    8010741f <trap+0x2bc>
	  }
	  else
		  proc->runQuanta++;
8010740a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107410:	8b 90 1c 01 00 00    	mov    0x11c(%eax),%edx
80107416:	83 c2 01             	add    $0x1,%edx
80107419:	89 90 1c 01 00 00    	mov    %edx,0x11c(%eax)
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010741f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107425:	85 c0                	test   %eax,%eax
80107427:	74 24                	je     8010744d <trap+0x2ea>
80107429:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010742f:	8b 40 28             	mov    0x28(%eax),%eax
80107432:	85 c0                	test   %eax,%eax
80107434:	74 17                	je     8010744d <trap+0x2ea>
80107436:	8b 45 08             	mov    0x8(%ebp),%eax
80107439:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010743d:	0f b7 c0             	movzwl %ax,%eax
80107440:	83 e0 03             	and    $0x3,%eax
80107443:	83 f8 03             	cmp    $0x3,%eax
80107446:	75 05                	jne    8010744d <trap+0x2ea>
    exit();
80107448:	e8 10 d6 ff ff       	call   80104a5d <exit>
}
8010744d:	83 c4 3c             	add    $0x3c,%esp
80107450:	5b                   	pop    %ebx
80107451:	5e                   	pop    %esi
80107452:	5f                   	pop    %edi
80107453:	5d                   	pop    %ebp
80107454:	c3                   	ret    

80107455 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107455:	55                   	push   %ebp
80107456:	89 e5                	mov    %esp,%ebp
80107458:	83 ec 14             	sub    $0x14,%esp
8010745b:	8b 45 08             	mov    0x8(%ebp),%eax
8010745e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107462:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107466:	89 c2                	mov    %eax,%edx
80107468:	ec                   	in     (%dx),%al
80107469:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010746c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107470:	c9                   	leave  
80107471:	c3                   	ret    

80107472 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107472:	55                   	push   %ebp
80107473:	89 e5                	mov    %esp,%ebp
80107475:	83 ec 08             	sub    $0x8,%esp
80107478:	8b 55 08             	mov    0x8(%ebp),%edx
8010747b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010747e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107482:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107485:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107489:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010748d:	ee                   	out    %al,(%dx)
}
8010748e:	c9                   	leave  
8010748f:	c3                   	ret    

80107490 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107490:	55                   	push   %ebp
80107491:	89 e5                	mov    %esp,%ebp
80107493:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107496:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010749d:	00 
8010749e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801074a5:	e8 c8 ff ff ff       	call   80107472 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801074aa:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801074b1:	00 
801074b2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801074b9:	e8 b4 ff ff ff       	call   80107472 <outb>
  outb(COM1+0, 115200/9600);
801074be:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801074c5:	00 
801074c6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801074cd:	e8 a0 ff ff ff       	call   80107472 <outb>
  outb(COM1+1, 0);
801074d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801074d9:	00 
801074da:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801074e1:	e8 8c ff ff ff       	call   80107472 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801074e6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801074ed:	00 
801074ee:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801074f5:	e8 78 ff ff ff       	call   80107472 <outb>
  outb(COM1+4, 0);
801074fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107501:	00 
80107502:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107509:	e8 64 ff ff ff       	call   80107472 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010750e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107515:	00 
80107516:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010751d:	e8 50 ff ff ff       	call   80107472 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107522:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107529:	e8 27 ff ff ff       	call   80107455 <inb>
8010752e:	3c ff                	cmp    $0xff,%al
80107530:	75 02                	jne    80107534 <uartinit+0xa4>
    return;
80107532:	eb 6a                	jmp    8010759e <uartinit+0x10e>
  uart = 1;
80107534:	c7 05 74 c6 10 80 01 	movl   $0x1,0x8010c674
8010753b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010753e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107545:	e8 0b ff ff ff       	call   80107455 <inb>
  inb(COM1+0);
8010754a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107551:	e8 ff fe ff ff       	call   80107455 <inb>
  picenable(IRQ_COM1);
80107556:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010755d:	e8 52 c8 ff ff       	call   80103db4 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107562:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107569:	00 
8010756a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107571:	e8 e7 b3 ff ff       	call   8010295d <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107576:	c7 45 f4 e4 94 10 80 	movl   $0x801094e4,-0xc(%ebp)
8010757d:	eb 15                	jmp    80107594 <uartinit+0x104>
    uartputc(*p);
8010757f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107582:	0f b6 00             	movzbl (%eax),%eax
80107585:	0f be c0             	movsbl %al,%eax
80107588:	89 04 24             	mov    %eax,(%esp)
8010758b:	e8 10 00 00 00       	call   801075a0 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107590:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107597:	0f b6 00             	movzbl (%eax),%eax
8010759a:	84 c0                	test   %al,%al
8010759c:	75 e1                	jne    8010757f <uartinit+0xef>
    uartputc(*p);
}
8010759e:	c9                   	leave  
8010759f:	c3                   	ret    

801075a0 <uartputc>:

void
uartputc(int c)
{
801075a0:	55                   	push   %ebp
801075a1:	89 e5                	mov    %esp,%ebp
801075a3:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801075a6:	a1 74 c6 10 80       	mov    0x8010c674,%eax
801075ab:	85 c0                	test   %eax,%eax
801075ad:	75 02                	jne    801075b1 <uartputc+0x11>
    return;
801075af:	eb 4b                	jmp    801075fc <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801075b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801075b8:	eb 10                	jmp    801075ca <uartputc+0x2a>
    microdelay(10);
801075ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801075c1:	e8 2f b9 ff ff       	call   80102ef5 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801075c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075ca:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801075ce:	7f 16                	jg     801075e6 <uartputc+0x46>
801075d0:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801075d7:	e8 79 fe ff ff       	call   80107455 <inb>
801075dc:	0f b6 c0             	movzbl %al,%eax
801075df:	83 e0 20             	and    $0x20,%eax
801075e2:	85 c0                	test   %eax,%eax
801075e4:	74 d4                	je     801075ba <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801075e6:	8b 45 08             	mov    0x8(%ebp),%eax
801075e9:	0f b6 c0             	movzbl %al,%eax
801075ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801075f0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801075f7:	e8 76 fe ff ff       	call   80107472 <outb>
}
801075fc:	c9                   	leave  
801075fd:	c3                   	ret    

801075fe <uartgetc>:

static int
uartgetc(void)
{
801075fe:	55                   	push   %ebp
801075ff:	89 e5                	mov    %esp,%ebp
80107601:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107604:	a1 74 c6 10 80       	mov    0x8010c674,%eax
80107609:	85 c0                	test   %eax,%eax
8010760b:	75 07                	jne    80107614 <uartgetc+0x16>
    return -1;
8010760d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107612:	eb 2c                	jmp    80107640 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107614:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010761b:	e8 35 fe ff ff       	call   80107455 <inb>
80107620:	0f b6 c0             	movzbl %al,%eax
80107623:	83 e0 01             	and    $0x1,%eax
80107626:	85 c0                	test   %eax,%eax
80107628:	75 07                	jne    80107631 <uartgetc+0x33>
    return -1;
8010762a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010762f:	eb 0f                	jmp    80107640 <uartgetc+0x42>
  return inb(COM1+0);
80107631:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107638:	e8 18 fe ff ff       	call   80107455 <inb>
8010763d:	0f b6 c0             	movzbl %al,%eax
}
80107640:	c9                   	leave  
80107641:	c3                   	ret    

80107642 <uartintr>:

void
uartintr(void)
{
80107642:	55                   	push   %ebp
80107643:	89 e5                	mov    %esp,%ebp
80107645:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107648:	c7 04 24 fe 75 10 80 	movl   $0x801075fe,(%esp)
8010764f:	e8 59 91 ff ff       	call   801007ad <consoleintr>
}
80107654:	c9                   	leave  
80107655:	c3                   	ret    

80107656 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $0
80107658:	6a 00                	push   $0x0
  jmp alltraps
8010765a:	e9 98 f5 ff ff       	jmp    80106bf7 <alltraps>

8010765f <vector1>:
.globl vector1
vector1:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $1
80107661:	6a 01                	push   $0x1
  jmp alltraps
80107663:	e9 8f f5 ff ff       	jmp    80106bf7 <alltraps>

80107668 <vector2>:
.globl vector2
vector2:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $2
8010766a:	6a 02                	push   $0x2
  jmp alltraps
8010766c:	e9 86 f5 ff ff       	jmp    80106bf7 <alltraps>

80107671 <vector3>:
.globl vector3
vector3:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $3
80107673:	6a 03                	push   $0x3
  jmp alltraps
80107675:	e9 7d f5 ff ff       	jmp    80106bf7 <alltraps>

8010767a <vector4>:
.globl vector4
vector4:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $4
8010767c:	6a 04                	push   $0x4
  jmp alltraps
8010767e:	e9 74 f5 ff ff       	jmp    80106bf7 <alltraps>

80107683 <vector5>:
.globl vector5
vector5:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $5
80107685:	6a 05                	push   $0x5
  jmp alltraps
80107687:	e9 6b f5 ff ff       	jmp    80106bf7 <alltraps>

8010768c <vector6>:
.globl vector6
vector6:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $6
8010768e:	6a 06                	push   $0x6
  jmp alltraps
80107690:	e9 62 f5 ff ff       	jmp    80106bf7 <alltraps>

80107695 <vector7>:
.globl vector7
vector7:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $7
80107697:	6a 07                	push   $0x7
  jmp alltraps
80107699:	e9 59 f5 ff ff       	jmp    80106bf7 <alltraps>

8010769e <vector8>:
.globl vector8
vector8:
  pushl $8
8010769e:	6a 08                	push   $0x8
  jmp alltraps
801076a0:	e9 52 f5 ff ff       	jmp    80106bf7 <alltraps>

801076a5 <vector9>:
.globl vector9
vector9:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $9
801076a7:	6a 09                	push   $0x9
  jmp alltraps
801076a9:	e9 49 f5 ff ff       	jmp    80106bf7 <alltraps>

801076ae <vector10>:
.globl vector10
vector10:
  pushl $10
801076ae:	6a 0a                	push   $0xa
  jmp alltraps
801076b0:	e9 42 f5 ff ff       	jmp    80106bf7 <alltraps>

801076b5 <vector11>:
.globl vector11
vector11:
  pushl $11
801076b5:	6a 0b                	push   $0xb
  jmp alltraps
801076b7:	e9 3b f5 ff ff       	jmp    80106bf7 <alltraps>

801076bc <vector12>:
.globl vector12
vector12:
  pushl $12
801076bc:	6a 0c                	push   $0xc
  jmp alltraps
801076be:	e9 34 f5 ff ff       	jmp    80106bf7 <alltraps>

801076c3 <vector13>:
.globl vector13
vector13:
  pushl $13
801076c3:	6a 0d                	push   $0xd
  jmp alltraps
801076c5:	e9 2d f5 ff ff       	jmp    80106bf7 <alltraps>

801076ca <vector14>:
.globl vector14
vector14:
  pushl $14
801076ca:	6a 0e                	push   $0xe
  jmp alltraps
801076cc:	e9 26 f5 ff ff       	jmp    80106bf7 <alltraps>

801076d1 <vector15>:
.globl vector15
vector15:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $15
801076d3:	6a 0f                	push   $0xf
  jmp alltraps
801076d5:	e9 1d f5 ff ff       	jmp    80106bf7 <alltraps>

801076da <vector16>:
.globl vector16
vector16:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $16
801076dc:	6a 10                	push   $0x10
  jmp alltraps
801076de:	e9 14 f5 ff ff       	jmp    80106bf7 <alltraps>

801076e3 <vector17>:
.globl vector17
vector17:
  pushl $17
801076e3:	6a 11                	push   $0x11
  jmp alltraps
801076e5:	e9 0d f5 ff ff       	jmp    80106bf7 <alltraps>

801076ea <vector18>:
.globl vector18
vector18:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $18
801076ec:	6a 12                	push   $0x12
  jmp alltraps
801076ee:	e9 04 f5 ff ff       	jmp    80106bf7 <alltraps>

801076f3 <vector19>:
.globl vector19
vector19:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $19
801076f5:	6a 13                	push   $0x13
  jmp alltraps
801076f7:	e9 fb f4 ff ff       	jmp    80106bf7 <alltraps>

801076fc <vector20>:
.globl vector20
vector20:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $20
801076fe:	6a 14                	push   $0x14
  jmp alltraps
80107700:	e9 f2 f4 ff ff       	jmp    80106bf7 <alltraps>

80107705 <vector21>:
.globl vector21
vector21:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $21
80107707:	6a 15                	push   $0x15
  jmp alltraps
80107709:	e9 e9 f4 ff ff       	jmp    80106bf7 <alltraps>

8010770e <vector22>:
.globl vector22
vector22:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $22
80107710:	6a 16                	push   $0x16
  jmp alltraps
80107712:	e9 e0 f4 ff ff       	jmp    80106bf7 <alltraps>

80107717 <vector23>:
.globl vector23
vector23:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $23
80107719:	6a 17                	push   $0x17
  jmp alltraps
8010771b:	e9 d7 f4 ff ff       	jmp    80106bf7 <alltraps>

80107720 <vector24>:
.globl vector24
vector24:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $24
80107722:	6a 18                	push   $0x18
  jmp alltraps
80107724:	e9 ce f4 ff ff       	jmp    80106bf7 <alltraps>

80107729 <vector25>:
.globl vector25
vector25:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $25
8010772b:	6a 19                	push   $0x19
  jmp alltraps
8010772d:	e9 c5 f4 ff ff       	jmp    80106bf7 <alltraps>

80107732 <vector26>:
.globl vector26
vector26:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $26
80107734:	6a 1a                	push   $0x1a
  jmp alltraps
80107736:	e9 bc f4 ff ff       	jmp    80106bf7 <alltraps>

8010773b <vector27>:
.globl vector27
vector27:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $27
8010773d:	6a 1b                	push   $0x1b
  jmp alltraps
8010773f:	e9 b3 f4 ff ff       	jmp    80106bf7 <alltraps>

80107744 <vector28>:
.globl vector28
vector28:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $28
80107746:	6a 1c                	push   $0x1c
  jmp alltraps
80107748:	e9 aa f4 ff ff       	jmp    80106bf7 <alltraps>

8010774d <vector29>:
.globl vector29
vector29:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $29
8010774f:	6a 1d                	push   $0x1d
  jmp alltraps
80107751:	e9 a1 f4 ff ff       	jmp    80106bf7 <alltraps>

80107756 <vector30>:
.globl vector30
vector30:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $30
80107758:	6a 1e                	push   $0x1e
  jmp alltraps
8010775a:	e9 98 f4 ff ff       	jmp    80106bf7 <alltraps>

8010775f <vector31>:
.globl vector31
vector31:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $31
80107761:	6a 1f                	push   $0x1f
  jmp alltraps
80107763:	e9 8f f4 ff ff       	jmp    80106bf7 <alltraps>

80107768 <vector32>:
.globl vector32
vector32:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $32
8010776a:	6a 20                	push   $0x20
  jmp alltraps
8010776c:	e9 86 f4 ff ff       	jmp    80106bf7 <alltraps>

80107771 <vector33>:
.globl vector33
vector33:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $33
80107773:	6a 21                	push   $0x21
  jmp alltraps
80107775:	e9 7d f4 ff ff       	jmp    80106bf7 <alltraps>

8010777a <vector34>:
.globl vector34
vector34:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $34
8010777c:	6a 22                	push   $0x22
  jmp alltraps
8010777e:	e9 74 f4 ff ff       	jmp    80106bf7 <alltraps>

80107783 <vector35>:
.globl vector35
vector35:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $35
80107785:	6a 23                	push   $0x23
  jmp alltraps
80107787:	e9 6b f4 ff ff       	jmp    80106bf7 <alltraps>

8010778c <vector36>:
.globl vector36
vector36:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $36
8010778e:	6a 24                	push   $0x24
  jmp alltraps
80107790:	e9 62 f4 ff ff       	jmp    80106bf7 <alltraps>

80107795 <vector37>:
.globl vector37
vector37:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $37
80107797:	6a 25                	push   $0x25
  jmp alltraps
80107799:	e9 59 f4 ff ff       	jmp    80106bf7 <alltraps>

8010779e <vector38>:
.globl vector38
vector38:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $38
801077a0:	6a 26                	push   $0x26
  jmp alltraps
801077a2:	e9 50 f4 ff ff       	jmp    80106bf7 <alltraps>

801077a7 <vector39>:
.globl vector39
vector39:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $39
801077a9:	6a 27                	push   $0x27
  jmp alltraps
801077ab:	e9 47 f4 ff ff       	jmp    80106bf7 <alltraps>

801077b0 <vector40>:
.globl vector40
vector40:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $40
801077b2:	6a 28                	push   $0x28
  jmp alltraps
801077b4:	e9 3e f4 ff ff       	jmp    80106bf7 <alltraps>

801077b9 <vector41>:
.globl vector41
vector41:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $41
801077bb:	6a 29                	push   $0x29
  jmp alltraps
801077bd:	e9 35 f4 ff ff       	jmp    80106bf7 <alltraps>

801077c2 <vector42>:
.globl vector42
vector42:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $42
801077c4:	6a 2a                	push   $0x2a
  jmp alltraps
801077c6:	e9 2c f4 ff ff       	jmp    80106bf7 <alltraps>

801077cb <vector43>:
.globl vector43
vector43:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $43
801077cd:	6a 2b                	push   $0x2b
  jmp alltraps
801077cf:	e9 23 f4 ff ff       	jmp    80106bf7 <alltraps>

801077d4 <vector44>:
.globl vector44
vector44:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $44
801077d6:	6a 2c                	push   $0x2c
  jmp alltraps
801077d8:	e9 1a f4 ff ff       	jmp    80106bf7 <alltraps>

801077dd <vector45>:
.globl vector45
vector45:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $45
801077df:	6a 2d                	push   $0x2d
  jmp alltraps
801077e1:	e9 11 f4 ff ff       	jmp    80106bf7 <alltraps>

801077e6 <vector46>:
.globl vector46
vector46:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $46
801077e8:	6a 2e                	push   $0x2e
  jmp alltraps
801077ea:	e9 08 f4 ff ff       	jmp    80106bf7 <alltraps>

801077ef <vector47>:
.globl vector47
vector47:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $47
801077f1:	6a 2f                	push   $0x2f
  jmp alltraps
801077f3:	e9 ff f3 ff ff       	jmp    80106bf7 <alltraps>

801077f8 <vector48>:
.globl vector48
vector48:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $48
801077fa:	6a 30                	push   $0x30
  jmp alltraps
801077fc:	e9 f6 f3 ff ff       	jmp    80106bf7 <alltraps>

80107801 <vector49>:
.globl vector49
vector49:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $49
80107803:	6a 31                	push   $0x31
  jmp alltraps
80107805:	e9 ed f3 ff ff       	jmp    80106bf7 <alltraps>

8010780a <vector50>:
.globl vector50
vector50:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $50
8010780c:	6a 32                	push   $0x32
  jmp alltraps
8010780e:	e9 e4 f3 ff ff       	jmp    80106bf7 <alltraps>

80107813 <vector51>:
.globl vector51
vector51:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $51
80107815:	6a 33                	push   $0x33
  jmp alltraps
80107817:	e9 db f3 ff ff       	jmp    80106bf7 <alltraps>

8010781c <vector52>:
.globl vector52
vector52:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $52
8010781e:	6a 34                	push   $0x34
  jmp alltraps
80107820:	e9 d2 f3 ff ff       	jmp    80106bf7 <alltraps>

80107825 <vector53>:
.globl vector53
vector53:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $53
80107827:	6a 35                	push   $0x35
  jmp alltraps
80107829:	e9 c9 f3 ff ff       	jmp    80106bf7 <alltraps>

8010782e <vector54>:
.globl vector54
vector54:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $54
80107830:	6a 36                	push   $0x36
  jmp alltraps
80107832:	e9 c0 f3 ff ff       	jmp    80106bf7 <alltraps>

80107837 <vector55>:
.globl vector55
vector55:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $55
80107839:	6a 37                	push   $0x37
  jmp alltraps
8010783b:	e9 b7 f3 ff ff       	jmp    80106bf7 <alltraps>

80107840 <vector56>:
.globl vector56
vector56:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $56
80107842:	6a 38                	push   $0x38
  jmp alltraps
80107844:	e9 ae f3 ff ff       	jmp    80106bf7 <alltraps>

80107849 <vector57>:
.globl vector57
vector57:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $57
8010784b:	6a 39                	push   $0x39
  jmp alltraps
8010784d:	e9 a5 f3 ff ff       	jmp    80106bf7 <alltraps>

80107852 <vector58>:
.globl vector58
vector58:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $58
80107854:	6a 3a                	push   $0x3a
  jmp alltraps
80107856:	e9 9c f3 ff ff       	jmp    80106bf7 <alltraps>

8010785b <vector59>:
.globl vector59
vector59:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $59
8010785d:	6a 3b                	push   $0x3b
  jmp alltraps
8010785f:	e9 93 f3 ff ff       	jmp    80106bf7 <alltraps>

80107864 <vector60>:
.globl vector60
vector60:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $60
80107866:	6a 3c                	push   $0x3c
  jmp alltraps
80107868:	e9 8a f3 ff ff       	jmp    80106bf7 <alltraps>

8010786d <vector61>:
.globl vector61
vector61:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $61
8010786f:	6a 3d                	push   $0x3d
  jmp alltraps
80107871:	e9 81 f3 ff ff       	jmp    80106bf7 <alltraps>

80107876 <vector62>:
.globl vector62
vector62:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $62
80107878:	6a 3e                	push   $0x3e
  jmp alltraps
8010787a:	e9 78 f3 ff ff       	jmp    80106bf7 <alltraps>

8010787f <vector63>:
.globl vector63
vector63:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $63
80107881:	6a 3f                	push   $0x3f
  jmp alltraps
80107883:	e9 6f f3 ff ff       	jmp    80106bf7 <alltraps>

80107888 <vector64>:
.globl vector64
vector64:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $64
8010788a:	6a 40                	push   $0x40
  jmp alltraps
8010788c:	e9 66 f3 ff ff       	jmp    80106bf7 <alltraps>

80107891 <vector65>:
.globl vector65
vector65:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $65
80107893:	6a 41                	push   $0x41
  jmp alltraps
80107895:	e9 5d f3 ff ff       	jmp    80106bf7 <alltraps>

8010789a <vector66>:
.globl vector66
vector66:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $66
8010789c:	6a 42                	push   $0x42
  jmp alltraps
8010789e:	e9 54 f3 ff ff       	jmp    80106bf7 <alltraps>

801078a3 <vector67>:
.globl vector67
vector67:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $67
801078a5:	6a 43                	push   $0x43
  jmp alltraps
801078a7:	e9 4b f3 ff ff       	jmp    80106bf7 <alltraps>

801078ac <vector68>:
.globl vector68
vector68:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $68
801078ae:	6a 44                	push   $0x44
  jmp alltraps
801078b0:	e9 42 f3 ff ff       	jmp    80106bf7 <alltraps>

801078b5 <vector69>:
.globl vector69
vector69:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $69
801078b7:	6a 45                	push   $0x45
  jmp alltraps
801078b9:	e9 39 f3 ff ff       	jmp    80106bf7 <alltraps>

801078be <vector70>:
.globl vector70
vector70:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $70
801078c0:	6a 46                	push   $0x46
  jmp alltraps
801078c2:	e9 30 f3 ff ff       	jmp    80106bf7 <alltraps>

801078c7 <vector71>:
.globl vector71
vector71:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $71
801078c9:	6a 47                	push   $0x47
  jmp alltraps
801078cb:	e9 27 f3 ff ff       	jmp    80106bf7 <alltraps>

801078d0 <vector72>:
.globl vector72
vector72:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $72
801078d2:	6a 48                	push   $0x48
  jmp alltraps
801078d4:	e9 1e f3 ff ff       	jmp    80106bf7 <alltraps>

801078d9 <vector73>:
.globl vector73
vector73:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $73
801078db:	6a 49                	push   $0x49
  jmp alltraps
801078dd:	e9 15 f3 ff ff       	jmp    80106bf7 <alltraps>

801078e2 <vector74>:
.globl vector74
vector74:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $74
801078e4:	6a 4a                	push   $0x4a
  jmp alltraps
801078e6:	e9 0c f3 ff ff       	jmp    80106bf7 <alltraps>

801078eb <vector75>:
.globl vector75
vector75:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $75
801078ed:	6a 4b                	push   $0x4b
  jmp alltraps
801078ef:	e9 03 f3 ff ff       	jmp    80106bf7 <alltraps>

801078f4 <vector76>:
.globl vector76
vector76:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $76
801078f6:	6a 4c                	push   $0x4c
  jmp alltraps
801078f8:	e9 fa f2 ff ff       	jmp    80106bf7 <alltraps>

801078fd <vector77>:
.globl vector77
vector77:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $77
801078ff:	6a 4d                	push   $0x4d
  jmp alltraps
80107901:	e9 f1 f2 ff ff       	jmp    80106bf7 <alltraps>

80107906 <vector78>:
.globl vector78
vector78:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $78
80107908:	6a 4e                	push   $0x4e
  jmp alltraps
8010790a:	e9 e8 f2 ff ff       	jmp    80106bf7 <alltraps>

8010790f <vector79>:
.globl vector79
vector79:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $79
80107911:	6a 4f                	push   $0x4f
  jmp alltraps
80107913:	e9 df f2 ff ff       	jmp    80106bf7 <alltraps>

80107918 <vector80>:
.globl vector80
vector80:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $80
8010791a:	6a 50                	push   $0x50
  jmp alltraps
8010791c:	e9 d6 f2 ff ff       	jmp    80106bf7 <alltraps>

80107921 <vector81>:
.globl vector81
vector81:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $81
80107923:	6a 51                	push   $0x51
  jmp alltraps
80107925:	e9 cd f2 ff ff       	jmp    80106bf7 <alltraps>

8010792a <vector82>:
.globl vector82
vector82:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $82
8010792c:	6a 52                	push   $0x52
  jmp alltraps
8010792e:	e9 c4 f2 ff ff       	jmp    80106bf7 <alltraps>

80107933 <vector83>:
.globl vector83
vector83:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $83
80107935:	6a 53                	push   $0x53
  jmp alltraps
80107937:	e9 bb f2 ff ff       	jmp    80106bf7 <alltraps>

8010793c <vector84>:
.globl vector84
vector84:
  pushl $0
8010793c:	6a 00                	push   $0x0
  pushl $84
8010793e:	6a 54                	push   $0x54
  jmp alltraps
80107940:	e9 b2 f2 ff ff       	jmp    80106bf7 <alltraps>

80107945 <vector85>:
.globl vector85
vector85:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $85
80107947:	6a 55                	push   $0x55
  jmp alltraps
80107949:	e9 a9 f2 ff ff       	jmp    80106bf7 <alltraps>

8010794e <vector86>:
.globl vector86
vector86:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $86
80107950:	6a 56                	push   $0x56
  jmp alltraps
80107952:	e9 a0 f2 ff ff       	jmp    80106bf7 <alltraps>

80107957 <vector87>:
.globl vector87
vector87:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $87
80107959:	6a 57                	push   $0x57
  jmp alltraps
8010795b:	e9 97 f2 ff ff       	jmp    80106bf7 <alltraps>

80107960 <vector88>:
.globl vector88
vector88:
  pushl $0
80107960:	6a 00                	push   $0x0
  pushl $88
80107962:	6a 58                	push   $0x58
  jmp alltraps
80107964:	e9 8e f2 ff ff       	jmp    80106bf7 <alltraps>

80107969 <vector89>:
.globl vector89
vector89:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $89
8010796b:	6a 59                	push   $0x59
  jmp alltraps
8010796d:	e9 85 f2 ff ff       	jmp    80106bf7 <alltraps>

80107972 <vector90>:
.globl vector90
vector90:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $90
80107974:	6a 5a                	push   $0x5a
  jmp alltraps
80107976:	e9 7c f2 ff ff       	jmp    80106bf7 <alltraps>

8010797b <vector91>:
.globl vector91
vector91:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $91
8010797d:	6a 5b                	push   $0x5b
  jmp alltraps
8010797f:	e9 73 f2 ff ff       	jmp    80106bf7 <alltraps>

80107984 <vector92>:
.globl vector92
vector92:
  pushl $0
80107984:	6a 00                	push   $0x0
  pushl $92
80107986:	6a 5c                	push   $0x5c
  jmp alltraps
80107988:	e9 6a f2 ff ff       	jmp    80106bf7 <alltraps>

8010798d <vector93>:
.globl vector93
vector93:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $93
8010798f:	6a 5d                	push   $0x5d
  jmp alltraps
80107991:	e9 61 f2 ff ff       	jmp    80106bf7 <alltraps>

80107996 <vector94>:
.globl vector94
vector94:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $94
80107998:	6a 5e                	push   $0x5e
  jmp alltraps
8010799a:	e9 58 f2 ff ff       	jmp    80106bf7 <alltraps>

8010799f <vector95>:
.globl vector95
vector95:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $95
801079a1:	6a 5f                	push   $0x5f
  jmp alltraps
801079a3:	e9 4f f2 ff ff       	jmp    80106bf7 <alltraps>

801079a8 <vector96>:
.globl vector96
vector96:
  pushl $0
801079a8:	6a 00                	push   $0x0
  pushl $96
801079aa:	6a 60                	push   $0x60
  jmp alltraps
801079ac:	e9 46 f2 ff ff       	jmp    80106bf7 <alltraps>

801079b1 <vector97>:
.globl vector97
vector97:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $97
801079b3:	6a 61                	push   $0x61
  jmp alltraps
801079b5:	e9 3d f2 ff ff       	jmp    80106bf7 <alltraps>

801079ba <vector98>:
.globl vector98
vector98:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $98
801079bc:	6a 62                	push   $0x62
  jmp alltraps
801079be:	e9 34 f2 ff ff       	jmp    80106bf7 <alltraps>

801079c3 <vector99>:
.globl vector99
vector99:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $99
801079c5:	6a 63                	push   $0x63
  jmp alltraps
801079c7:	e9 2b f2 ff ff       	jmp    80106bf7 <alltraps>

801079cc <vector100>:
.globl vector100
vector100:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $100
801079ce:	6a 64                	push   $0x64
  jmp alltraps
801079d0:	e9 22 f2 ff ff       	jmp    80106bf7 <alltraps>

801079d5 <vector101>:
.globl vector101
vector101:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $101
801079d7:	6a 65                	push   $0x65
  jmp alltraps
801079d9:	e9 19 f2 ff ff       	jmp    80106bf7 <alltraps>

801079de <vector102>:
.globl vector102
vector102:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $102
801079e0:	6a 66                	push   $0x66
  jmp alltraps
801079e2:	e9 10 f2 ff ff       	jmp    80106bf7 <alltraps>

801079e7 <vector103>:
.globl vector103
vector103:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $103
801079e9:	6a 67                	push   $0x67
  jmp alltraps
801079eb:	e9 07 f2 ff ff       	jmp    80106bf7 <alltraps>

801079f0 <vector104>:
.globl vector104
vector104:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $104
801079f2:	6a 68                	push   $0x68
  jmp alltraps
801079f4:	e9 fe f1 ff ff       	jmp    80106bf7 <alltraps>

801079f9 <vector105>:
.globl vector105
vector105:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $105
801079fb:	6a 69                	push   $0x69
  jmp alltraps
801079fd:	e9 f5 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a02 <vector106>:
.globl vector106
vector106:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $106
80107a04:	6a 6a                	push   $0x6a
  jmp alltraps
80107a06:	e9 ec f1 ff ff       	jmp    80106bf7 <alltraps>

80107a0b <vector107>:
.globl vector107
vector107:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $107
80107a0d:	6a 6b                	push   $0x6b
  jmp alltraps
80107a0f:	e9 e3 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a14 <vector108>:
.globl vector108
vector108:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $108
80107a16:	6a 6c                	push   $0x6c
  jmp alltraps
80107a18:	e9 da f1 ff ff       	jmp    80106bf7 <alltraps>

80107a1d <vector109>:
.globl vector109
vector109:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $109
80107a1f:	6a 6d                	push   $0x6d
  jmp alltraps
80107a21:	e9 d1 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a26 <vector110>:
.globl vector110
vector110:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $110
80107a28:	6a 6e                	push   $0x6e
  jmp alltraps
80107a2a:	e9 c8 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a2f <vector111>:
.globl vector111
vector111:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $111
80107a31:	6a 6f                	push   $0x6f
  jmp alltraps
80107a33:	e9 bf f1 ff ff       	jmp    80106bf7 <alltraps>

80107a38 <vector112>:
.globl vector112
vector112:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $112
80107a3a:	6a 70                	push   $0x70
  jmp alltraps
80107a3c:	e9 b6 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a41 <vector113>:
.globl vector113
vector113:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $113
80107a43:	6a 71                	push   $0x71
  jmp alltraps
80107a45:	e9 ad f1 ff ff       	jmp    80106bf7 <alltraps>

80107a4a <vector114>:
.globl vector114
vector114:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $114
80107a4c:	6a 72                	push   $0x72
  jmp alltraps
80107a4e:	e9 a4 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a53 <vector115>:
.globl vector115
vector115:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $115
80107a55:	6a 73                	push   $0x73
  jmp alltraps
80107a57:	e9 9b f1 ff ff       	jmp    80106bf7 <alltraps>

80107a5c <vector116>:
.globl vector116
vector116:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $116
80107a5e:	6a 74                	push   $0x74
  jmp alltraps
80107a60:	e9 92 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a65 <vector117>:
.globl vector117
vector117:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $117
80107a67:	6a 75                	push   $0x75
  jmp alltraps
80107a69:	e9 89 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a6e <vector118>:
.globl vector118
vector118:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $118
80107a70:	6a 76                	push   $0x76
  jmp alltraps
80107a72:	e9 80 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a77 <vector119>:
.globl vector119
vector119:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $119
80107a79:	6a 77                	push   $0x77
  jmp alltraps
80107a7b:	e9 77 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a80 <vector120>:
.globl vector120
vector120:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $120
80107a82:	6a 78                	push   $0x78
  jmp alltraps
80107a84:	e9 6e f1 ff ff       	jmp    80106bf7 <alltraps>

80107a89 <vector121>:
.globl vector121
vector121:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $121
80107a8b:	6a 79                	push   $0x79
  jmp alltraps
80107a8d:	e9 65 f1 ff ff       	jmp    80106bf7 <alltraps>

80107a92 <vector122>:
.globl vector122
vector122:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $122
80107a94:	6a 7a                	push   $0x7a
  jmp alltraps
80107a96:	e9 5c f1 ff ff       	jmp    80106bf7 <alltraps>

80107a9b <vector123>:
.globl vector123
vector123:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $123
80107a9d:	6a 7b                	push   $0x7b
  jmp alltraps
80107a9f:	e9 53 f1 ff ff       	jmp    80106bf7 <alltraps>

80107aa4 <vector124>:
.globl vector124
vector124:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $124
80107aa6:	6a 7c                	push   $0x7c
  jmp alltraps
80107aa8:	e9 4a f1 ff ff       	jmp    80106bf7 <alltraps>

80107aad <vector125>:
.globl vector125
vector125:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $125
80107aaf:	6a 7d                	push   $0x7d
  jmp alltraps
80107ab1:	e9 41 f1 ff ff       	jmp    80106bf7 <alltraps>

80107ab6 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $126
80107ab8:	6a 7e                	push   $0x7e
  jmp alltraps
80107aba:	e9 38 f1 ff ff       	jmp    80106bf7 <alltraps>

80107abf <vector127>:
.globl vector127
vector127:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $127
80107ac1:	6a 7f                	push   $0x7f
  jmp alltraps
80107ac3:	e9 2f f1 ff ff       	jmp    80106bf7 <alltraps>

80107ac8 <vector128>:
.globl vector128
vector128:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $128
80107aca:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107acf:	e9 23 f1 ff ff       	jmp    80106bf7 <alltraps>

80107ad4 <vector129>:
.globl vector129
vector129:
  pushl $0
80107ad4:	6a 00                	push   $0x0
  pushl $129
80107ad6:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107adb:	e9 17 f1 ff ff       	jmp    80106bf7 <alltraps>

80107ae0 <vector130>:
.globl vector130
vector130:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $130
80107ae2:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107ae7:	e9 0b f1 ff ff       	jmp    80106bf7 <alltraps>

80107aec <vector131>:
.globl vector131
vector131:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $131
80107aee:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107af3:	e9 ff f0 ff ff       	jmp    80106bf7 <alltraps>

80107af8 <vector132>:
.globl vector132
vector132:
  pushl $0
80107af8:	6a 00                	push   $0x0
  pushl $132
80107afa:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107aff:	e9 f3 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b04 <vector133>:
.globl vector133
vector133:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $133
80107b06:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107b0b:	e9 e7 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b10 <vector134>:
.globl vector134
vector134:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $134
80107b12:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107b17:	e9 db f0 ff ff       	jmp    80106bf7 <alltraps>

80107b1c <vector135>:
.globl vector135
vector135:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $135
80107b1e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107b23:	e9 cf f0 ff ff       	jmp    80106bf7 <alltraps>

80107b28 <vector136>:
.globl vector136
vector136:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $136
80107b2a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107b2f:	e9 c3 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b34 <vector137>:
.globl vector137
vector137:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $137
80107b36:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107b3b:	e9 b7 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b40 <vector138>:
.globl vector138
vector138:
  pushl $0
80107b40:	6a 00                	push   $0x0
  pushl $138
80107b42:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107b47:	e9 ab f0 ff ff       	jmp    80106bf7 <alltraps>

80107b4c <vector139>:
.globl vector139
vector139:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $139
80107b4e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107b53:	e9 9f f0 ff ff       	jmp    80106bf7 <alltraps>

80107b58 <vector140>:
.globl vector140
vector140:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $140
80107b5a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107b5f:	e9 93 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b64 <vector141>:
.globl vector141
vector141:
  pushl $0
80107b64:	6a 00                	push   $0x0
  pushl $141
80107b66:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107b6b:	e9 87 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b70 <vector142>:
.globl vector142
vector142:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $142
80107b72:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107b77:	e9 7b f0 ff ff       	jmp    80106bf7 <alltraps>

80107b7c <vector143>:
.globl vector143
vector143:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $143
80107b7e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107b83:	e9 6f f0 ff ff       	jmp    80106bf7 <alltraps>

80107b88 <vector144>:
.globl vector144
vector144:
  pushl $0
80107b88:	6a 00                	push   $0x0
  pushl $144
80107b8a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107b8f:	e9 63 f0 ff ff       	jmp    80106bf7 <alltraps>

80107b94 <vector145>:
.globl vector145
vector145:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $145
80107b96:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107b9b:	e9 57 f0 ff ff       	jmp    80106bf7 <alltraps>

80107ba0 <vector146>:
.globl vector146
vector146:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $146
80107ba2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ba7:	e9 4b f0 ff ff       	jmp    80106bf7 <alltraps>

80107bac <vector147>:
.globl vector147
vector147:
  pushl $0
80107bac:	6a 00                	push   $0x0
  pushl $147
80107bae:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107bb3:	e9 3f f0 ff ff       	jmp    80106bf7 <alltraps>

80107bb8 <vector148>:
.globl vector148
vector148:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $148
80107bba:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107bbf:	e9 33 f0 ff ff       	jmp    80106bf7 <alltraps>

80107bc4 <vector149>:
.globl vector149
vector149:
  pushl $0
80107bc4:	6a 00                	push   $0x0
  pushl $149
80107bc6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107bcb:	e9 27 f0 ff ff       	jmp    80106bf7 <alltraps>

80107bd0 <vector150>:
.globl vector150
vector150:
  pushl $0
80107bd0:	6a 00                	push   $0x0
  pushl $150
80107bd2:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107bd7:	e9 1b f0 ff ff       	jmp    80106bf7 <alltraps>

80107bdc <vector151>:
.globl vector151
vector151:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $151
80107bde:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107be3:	e9 0f f0 ff ff       	jmp    80106bf7 <alltraps>

80107be8 <vector152>:
.globl vector152
vector152:
  pushl $0
80107be8:	6a 00                	push   $0x0
  pushl $152
80107bea:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107bef:	e9 03 f0 ff ff       	jmp    80106bf7 <alltraps>

80107bf4 <vector153>:
.globl vector153
vector153:
  pushl $0
80107bf4:	6a 00                	push   $0x0
  pushl $153
80107bf6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107bfb:	e9 f7 ef ff ff       	jmp    80106bf7 <alltraps>

80107c00 <vector154>:
.globl vector154
vector154:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $154
80107c02:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107c07:	e9 eb ef ff ff       	jmp    80106bf7 <alltraps>

80107c0c <vector155>:
.globl vector155
vector155:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $155
80107c0e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107c13:	e9 df ef ff ff       	jmp    80106bf7 <alltraps>

80107c18 <vector156>:
.globl vector156
vector156:
  pushl $0
80107c18:	6a 00                	push   $0x0
  pushl $156
80107c1a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107c1f:	e9 d3 ef ff ff       	jmp    80106bf7 <alltraps>

80107c24 <vector157>:
.globl vector157
vector157:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $157
80107c26:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107c2b:	e9 c7 ef ff ff       	jmp    80106bf7 <alltraps>

80107c30 <vector158>:
.globl vector158
vector158:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $158
80107c32:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107c37:	e9 bb ef ff ff       	jmp    80106bf7 <alltraps>

80107c3c <vector159>:
.globl vector159
vector159:
  pushl $0
80107c3c:	6a 00                	push   $0x0
  pushl $159
80107c3e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107c43:	e9 af ef ff ff       	jmp    80106bf7 <alltraps>

80107c48 <vector160>:
.globl vector160
vector160:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $160
80107c4a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107c4f:	e9 a3 ef ff ff       	jmp    80106bf7 <alltraps>

80107c54 <vector161>:
.globl vector161
vector161:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $161
80107c56:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107c5b:	e9 97 ef ff ff       	jmp    80106bf7 <alltraps>

80107c60 <vector162>:
.globl vector162
vector162:
  pushl $0
80107c60:	6a 00                	push   $0x0
  pushl $162
80107c62:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107c67:	e9 8b ef ff ff       	jmp    80106bf7 <alltraps>

80107c6c <vector163>:
.globl vector163
vector163:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $163
80107c6e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107c73:	e9 7f ef ff ff       	jmp    80106bf7 <alltraps>

80107c78 <vector164>:
.globl vector164
vector164:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $164
80107c7a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107c7f:	e9 73 ef ff ff       	jmp    80106bf7 <alltraps>

80107c84 <vector165>:
.globl vector165
vector165:
  pushl $0
80107c84:	6a 00                	push   $0x0
  pushl $165
80107c86:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107c8b:	e9 67 ef ff ff       	jmp    80106bf7 <alltraps>

80107c90 <vector166>:
.globl vector166
vector166:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $166
80107c92:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107c97:	e9 5b ef ff ff       	jmp    80106bf7 <alltraps>

80107c9c <vector167>:
.globl vector167
vector167:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $167
80107c9e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ca3:	e9 4f ef ff ff       	jmp    80106bf7 <alltraps>

80107ca8 <vector168>:
.globl vector168
vector168:
  pushl $0
80107ca8:	6a 00                	push   $0x0
  pushl $168
80107caa:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107caf:	e9 43 ef ff ff       	jmp    80106bf7 <alltraps>

80107cb4 <vector169>:
.globl vector169
vector169:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $169
80107cb6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107cbb:	e9 37 ef ff ff       	jmp    80106bf7 <alltraps>

80107cc0 <vector170>:
.globl vector170
vector170:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $170
80107cc2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107cc7:	e9 2b ef ff ff       	jmp    80106bf7 <alltraps>

80107ccc <vector171>:
.globl vector171
vector171:
  pushl $0
80107ccc:	6a 00                	push   $0x0
  pushl $171
80107cce:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107cd3:	e9 1f ef ff ff       	jmp    80106bf7 <alltraps>

80107cd8 <vector172>:
.globl vector172
vector172:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $172
80107cda:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107cdf:	e9 13 ef ff ff       	jmp    80106bf7 <alltraps>

80107ce4 <vector173>:
.globl vector173
vector173:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $173
80107ce6:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107ceb:	e9 07 ef ff ff       	jmp    80106bf7 <alltraps>

80107cf0 <vector174>:
.globl vector174
vector174:
  pushl $0
80107cf0:	6a 00                	push   $0x0
  pushl $174
80107cf2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107cf7:	e9 fb ee ff ff       	jmp    80106bf7 <alltraps>

80107cfc <vector175>:
.globl vector175
vector175:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $175
80107cfe:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107d03:	e9 ef ee ff ff       	jmp    80106bf7 <alltraps>

80107d08 <vector176>:
.globl vector176
vector176:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $176
80107d0a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107d0f:	e9 e3 ee ff ff       	jmp    80106bf7 <alltraps>

80107d14 <vector177>:
.globl vector177
vector177:
  pushl $0
80107d14:	6a 00                	push   $0x0
  pushl $177
80107d16:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107d1b:	e9 d7 ee ff ff       	jmp    80106bf7 <alltraps>

80107d20 <vector178>:
.globl vector178
vector178:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $178
80107d22:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107d27:	e9 cb ee ff ff       	jmp    80106bf7 <alltraps>

80107d2c <vector179>:
.globl vector179
vector179:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $179
80107d2e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107d33:	e9 bf ee ff ff       	jmp    80106bf7 <alltraps>

80107d38 <vector180>:
.globl vector180
vector180:
  pushl $0
80107d38:	6a 00                	push   $0x0
  pushl $180
80107d3a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107d3f:	e9 b3 ee ff ff       	jmp    80106bf7 <alltraps>

80107d44 <vector181>:
.globl vector181
vector181:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $181
80107d46:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107d4b:	e9 a7 ee ff ff       	jmp    80106bf7 <alltraps>

80107d50 <vector182>:
.globl vector182
vector182:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $182
80107d52:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107d57:	e9 9b ee ff ff       	jmp    80106bf7 <alltraps>

80107d5c <vector183>:
.globl vector183
vector183:
  pushl $0
80107d5c:	6a 00                	push   $0x0
  pushl $183
80107d5e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107d63:	e9 8f ee ff ff       	jmp    80106bf7 <alltraps>

80107d68 <vector184>:
.globl vector184
vector184:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $184
80107d6a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107d6f:	e9 83 ee ff ff       	jmp    80106bf7 <alltraps>

80107d74 <vector185>:
.globl vector185
vector185:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $185
80107d76:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107d7b:	e9 77 ee ff ff       	jmp    80106bf7 <alltraps>

80107d80 <vector186>:
.globl vector186
vector186:
  pushl $0
80107d80:	6a 00                	push   $0x0
  pushl $186
80107d82:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107d87:	e9 6b ee ff ff       	jmp    80106bf7 <alltraps>

80107d8c <vector187>:
.globl vector187
vector187:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $187
80107d8e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107d93:	e9 5f ee ff ff       	jmp    80106bf7 <alltraps>

80107d98 <vector188>:
.globl vector188
vector188:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $188
80107d9a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107d9f:	e9 53 ee ff ff       	jmp    80106bf7 <alltraps>

80107da4 <vector189>:
.globl vector189
vector189:
  pushl $0
80107da4:	6a 00                	push   $0x0
  pushl $189
80107da6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107dab:	e9 47 ee ff ff       	jmp    80106bf7 <alltraps>

80107db0 <vector190>:
.globl vector190
vector190:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $190
80107db2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107db7:	e9 3b ee ff ff       	jmp    80106bf7 <alltraps>

80107dbc <vector191>:
.globl vector191
vector191:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $191
80107dbe:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107dc3:	e9 2f ee ff ff       	jmp    80106bf7 <alltraps>

80107dc8 <vector192>:
.globl vector192
vector192:
  pushl $0
80107dc8:	6a 00                	push   $0x0
  pushl $192
80107dca:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107dcf:	e9 23 ee ff ff       	jmp    80106bf7 <alltraps>

80107dd4 <vector193>:
.globl vector193
vector193:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $193
80107dd6:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107ddb:	e9 17 ee ff ff       	jmp    80106bf7 <alltraps>

80107de0 <vector194>:
.globl vector194
vector194:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $194
80107de2:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107de7:	e9 0b ee ff ff       	jmp    80106bf7 <alltraps>

80107dec <vector195>:
.globl vector195
vector195:
  pushl $0
80107dec:	6a 00                	push   $0x0
  pushl $195
80107dee:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107df3:	e9 ff ed ff ff       	jmp    80106bf7 <alltraps>

80107df8 <vector196>:
.globl vector196
vector196:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $196
80107dfa:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107dff:	e9 f3 ed ff ff       	jmp    80106bf7 <alltraps>

80107e04 <vector197>:
.globl vector197
vector197:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $197
80107e06:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107e0b:	e9 e7 ed ff ff       	jmp    80106bf7 <alltraps>

80107e10 <vector198>:
.globl vector198
vector198:
  pushl $0
80107e10:	6a 00                	push   $0x0
  pushl $198
80107e12:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107e17:	e9 db ed ff ff       	jmp    80106bf7 <alltraps>

80107e1c <vector199>:
.globl vector199
vector199:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $199
80107e1e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107e23:	e9 cf ed ff ff       	jmp    80106bf7 <alltraps>

80107e28 <vector200>:
.globl vector200
vector200:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $200
80107e2a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107e2f:	e9 c3 ed ff ff       	jmp    80106bf7 <alltraps>

80107e34 <vector201>:
.globl vector201
vector201:
  pushl $0
80107e34:	6a 00                	push   $0x0
  pushl $201
80107e36:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107e3b:	e9 b7 ed ff ff       	jmp    80106bf7 <alltraps>

80107e40 <vector202>:
.globl vector202
vector202:
  pushl $0
80107e40:	6a 00                	push   $0x0
  pushl $202
80107e42:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107e47:	e9 ab ed ff ff       	jmp    80106bf7 <alltraps>

80107e4c <vector203>:
.globl vector203
vector203:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $203
80107e4e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107e53:	e9 9f ed ff ff       	jmp    80106bf7 <alltraps>

80107e58 <vector204>:
.globl vector204
vector204:
  pushl $0
80107e58:	6a 00                	push   $0x0
  pushl $204
80107e5a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107e5f:	e9 93 ed ff ff       	jmp    80106bf7 <alltraps>

80107e64 <vector205>:
.globl vector205
vector205:
  pushl $0
80107e64:	6a 00                	push   $0x0
  pushl $205
80107e66:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107e6b:	e9 87 ed ff ff       	jmp    80106bf7 <alltraps>

80107e70 <vector206>:
.globl vector206
vector206:
  pushl $0
80107e70:	6a 00                	push   $0x0
  pushl $206
80107e72:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107e77:	e9 7b ed ff ff       	jmp    80106bf7 <alltraps>

80107e7c <vector207>:
.globl vector207
vector207:
  pushl $0
80107e7c:	6a 00                	push   $0x0
  pushl $207
80107e7e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107e83:	e9 6f ed ff ff       	jmp    80106bf7 <alltraps>

80107e88 <vector208>:
.globl vector208
vector208:
  pushl $0
80107e88:	6a 00                	push   $0x0
  pushl $208
80107e8a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107e8f:	e9 63 ed ff ff       	jmp    80106bf7 <alltraps>

80107e94 <vector209>:
.globl vector209
vector209:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $209
80107e96:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107e9b:	e9 57 ed ff ff       	jmp    80106bf7 <alltraps>

80107ea0 <vector210>:
.globl vector210
vector210:
  pushl $0
80107ea0:	6a 00                	push   $0x0
  pushl $210
80107ea2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107ea7:	e9 4b ed ff ff       	jmp    80106bf7 <alltraps>

80107eac <vector211>:
.globl vector211
vector211:
  pushl $0
80107eac:	6a 00                	push   $0x0
  pushl $211
80107eae:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107eb3:	e9 3f ed ff ff       	jmp    80106bf7 <alltraps>

80107eb8 <vector212>:
.globl vector212
vector212:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $212
80107eba:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107ebf:	e9 33 ed ff ff       	jmp    80106bf7 <alltraps>

80107ec4 <vector213>:
.globl vector213
vector213:
  pushl $0
80107ec4:	6a 00                	push   $0x0
  pushl $213
80107ec6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107ecb:	e9 27 ed ff ff       	jmp    80106bf7 <alltraps>

80107ed0 <vector214>:
.globl vector214
vector214:
  pushl $0
80107ed0:	6a 00                	push   $0x0
  pushl $214
80107ed2:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107ed7:	e9 1b ed ff ff       	jmp    80106bf7 <alltraps>

80107edc <vector215>:
.globl vector215
vector215:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $215
80107ede:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107ee3:	e9 0f ed ff ff       	jmp    80106bf7 <alltraps>

80107ee8 <vector216>:
.globl vector216
vector216:
  pushl $0
80107ee8:	6a 00                	push   $0x0
  pushl $216
80107eea:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107eef:	e9 03 ed ff ff       	jmp    80106bf7 <alltraps>

80107ef4 <vector217>:
.globl vector217
vector217:
  pushl $0
80107ef4:	6a 00                	push   $0x0
  pushl $217
80107ef6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107efb:	e9 f7 ec ff ff       	jmp    80106bf7 <alltraps>

80107f00 <vector218>:
.globl vector218
vector218:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $218
80107f02:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107f07:	e9 eb ec ff ff       	jmp    80106bf7 <alltraps>

80107f0c <vector219>:
.globl vector219
vector219:
  pushl $0
80107f0c:	6a 00                	push   $0x0
  pushl $219
80107f0e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107f13:	e9 df ec ff ff       	jmp    80106bf7 <alltraps>

80107f18 <vector220>:
.globl vector220
vector220:
  pushl $0
80107f18:	6a 00                	push   $0x0
  pushl $220
80107f1a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107f1f:	e9 d3 ec ff ff       	jmp    80106bf7 <alltraps>

80107f24 <vector221>:
.globl vector221
vector221:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $221
80107f26:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107f2b:	e9 c7 ec ff ff       	jmp    80106bf7 <alltraps>

80107f30 <vector222>:
.globl vector222
vector222:
  pushl $0
80107f30:	6a 00                	push   $0x0
  pushl $222
80107f32:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107f37:	e9 bb ec ff ff       	jmp    80106bf7 <alltraps>

80107f3c <vector223>:
.globl vector223
vector223:
  pushl $0
80107f3c:	6a 00                	push   $0x0
  pushl $223
80107f3e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107f43:	e9 af ec ff ff       	jmp    80106bf7 <alltraps>

80107f48 <vector224>:
.globl vector224
vector224:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $224
80107f4a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107f4f:	e9 a3 ec ff ff       	jmp    80106bf7 <alltraps>

80107f54 <vector225>:
.globl vector225
vector225:
  pushl $0
80107f54:	6a 00                	push   $0x0
  pushl $225
80107f56:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107f5b:	e9 97 ec ff ff       	jmp    80106bf7 <alltraps>

80107f60 <vector226>:
.globl vector226
vector226:
  pushl $0
80107f60:	6a 00                	push   $0x0
  pushl $226
80107f62:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107f67:	e9 8b ec ff ff       	jmp    80106bf7 <alltraps>

80107f6c <vector227>:
.globl vector227
vector227:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $227
80107f6e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107f73:	e9 7f ec ff ff       	jmp    80106bf7 <alltraps>

80107f78 <vector228>:
.globl vector228
vector228:
  pushl $0
80107f78:	6a 00                	push   $0x0
  pushl $228
80107f7a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107f7f:	e9 73 ec ff ff       	jmp    80106bf7 <alltraps>

80107f84 <vector229>:
.globl vector229
vector229:
  pushl $0
80107f84:	6a 00                	push   $0x0
  pushl $229
80107f86:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107f8b:	e9 67 ec ff ff       	jmp    80106bf7 <alltraps>

80107f90 <vector230>:
.globl vector230
vector230:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $230
80107f92:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107f97:	e9 5b ec ff ff       	jmp    80106bf7 <alltraps>

80107f9c <vector231>:
.globl vector231
vector231:
  pushl $0
80107f9c:	6a 00                	push   $0x0
  pushl $231
80107f9e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107fa3:	e9 4f ec ff ff       	jmp    80106bf7 <alltraps>

80107fa8 <vector232>:
.globl vector232
vector232:
  pushl $0
80107fa8:	6a 00                	push   $0x0
  pushl $232
80107faa:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107faf:	e9 43 ec ff ff       	jmp    80106bf7 <alltraps>

80107fb4 <vector233>:
.globl vector233
vector233:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $233
80107fb6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107fbb:	e9 37 ec ff ff       	jmp    80106bf7 <alltraps>

80107fc0 <vector234>:
.globl vector234
vector234:
  pushl $0
80107fc0:	6a 00                	push   $0x0
  pushl $234
80107fc2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107fc7:	e9 2b ec ff ff       	jmp    80106bf7 <alltraps>

80107fcc <vector235>:
.globl vector235
vector235:
  pushl $0
80107fcc:	6a 00                	push   $0x0
  pushl $235
80107fce:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107fd3:	e9 1f ec ff ff       	jmp    80106bf7 <alltraps>

80107fd8 <vector236>:
.globl vector236
vector236:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $236
80107fda:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107fdf:	e9 13 ec ff ff       	jmp    80106bf7 <alltraps>

80107fe4 <vector237>:
.globl vector237
vector237:
  pushl $0
80107fe4:	6a 00                	push   $0x0
  pushl $237
80107fe6:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107feb:	e9 07 ec ff ff       	jmp    80106bf7 <alltraps>

80107ff0 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ff0:	6a 00                	push   $0x0
  pushl $238
80107ff2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ff7:	e9 fb eb ff ff       	jmp    80106bf7 <alltraps>

80107ffc <vector239>:
.globl vector239
vector239:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $239
80107ffe:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108003:	e9 ef eb ff ff       	jmp    80106bf7 <alltraps>

80108008 <vector240>:
.globl vector240
vector240:
  pushl $0
80108008:	6a 00                	push   $0x0
  pushl $240
8010800a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010800f:	e9 e3 eb ff ff       	jmp    80106bf7 <alltraps>

80108014 <vector241>:
.globl vector241
vector241:
  pushl $0
80108014:	6a 00                	push   $0x0
  pushl $241
80108016:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010801b:	e9 d7 eb ff ff       	jmp    80106bf7 <alltraps>

80108020 <vector242>:
.globl vector242
vector242:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $242
80108022:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108027:	e9 cb eb ff ff       	jmp    80106bf7 <alltraps>

8010802c <vector243>:
.globl vector243
vector243:
  pushl $0
8010802c:	6a 00                	push   $0x0
  pushl $243
8010802e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108033:	e9 bf eb ff ff       	jmp    80106bf7 <alltraps>

80108038 <vector244>:
.globl vector244
vector244:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $244
8010803a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010803f:	e9 b3 eb ff ff       	jmp    80106bf7 <alltraps>

80108044 <vector245>:
.globl vector245
vector245:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $245
80108046:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010804b:	e9 a7 eb ff ff       	jmp    80106bf7 <alltraps>

80108050 <vector246>:
.globl vector246
vector246:
  pushl $0
80108050:	6a 00                	push   $0x0
  pushl $246
80108052:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108057:	e9 9b eb ff ff       	jmp    80106bf7 <alltraps>

8010805c <vector247>:
.globl vector247
vector247:
  pushl $0
8010805c:	6a 00                	push   $0x0
  pushl $247
8010805e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108063:	e9 8f eb ff ff       	jmp    80106bf7 <alltraps>

80108068 <vector248>:
.globl vector248
vector248:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $248
8010806a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010806f:	e9 83 eb ff ff       	jmp    80106bf7 <alltraps>

80108074 <vector249>:
.globl vector249
vector249:
  pushl $0
80108074:	6a 00                	push   $0x0
  pushl $249
80108076:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010807b:	e9 77 eb ff ff       	jmp    80106bf7 <alltraps>

80108080 <vector250>:
.globl vector250
vector250:
  pushl $0
80108080:	6a 00                	push   $0x0
  pushl $250
80108082:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108087:	e9 6b eb ff ff       	jmp    80106bf7 <alltraps>

8010808c <vector251>:
.globl vector251
vector251:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $251
8010808e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108093:	e9 5f eb ff ff       	jmp    80106bf7 <alltraps>

80108098 <vector252>:
.globl vector252
vector252:
  pushl $0
80108098:	6a 00                	push   $0x0
  pushl $252
8010809a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010809f:	e9 53 eb ff ff       	jmp    80106bf7 <alltraps>

801080a4 <vector253>:
.globl vector253
vector253:
  pushl $0
801080a4:	6a 00                	push   $0x0
  pushl $253
801080a6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801080ab:	e9 47 eb ff ff       	jmp    80106bf7 <alltraps>

801080b0 <vector254>:
.globl vector254
vector254:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $254
801080b2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801080b7:	e9 3b eb ff ff       	jmp    80106bf7 <alltraps>

801080bc <vector255>:
.globl vector255
vector255:
  pushl $0
801080bc:	6a 00                	push   $0x0
  pushl $255
801080be:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801080c3:	e9 2f eb ff ff       	jmp    80106bf7 <alltraps>

801080c8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801080c8:	55                   	push   %ebp
801080c9:	89 e5                	mov    %esp,%ebp
801080cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801080ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d1:	83 e8 01             	sub    $0x1,%eax
801080d4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801080d8:	8b 45 08             	mov    0x8(%ebp),%eax
801080db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801080df:	8b 45 08             	mov    0x8(%ebp),%eax
801080e2:	c1 e8 10             	shr    $0x10,%eax
801080e5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801080e9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801080ec:	0f 01 10             	lgdtl  (%eax)
}
801080ef:	c9                   	leave  
801080f0:	c3                   	ret    

801080f1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801080f1:	55                   	push   %ebp
801080f2:	89 e5                	mov    %esp,%ebp
801080f4:	83 ec 04             	sub    $0x4,%esp
801080f7:	8b 45 08             	mov    0x8(%ebp),%eax
801080fa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801080fe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108102:	0f 00 d8             	ltr    %ax
}
80108105:	c9                   	leave  
80108106:	c3                   	ret    

80108107 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108107:	55                   	push   %ebp
80108108:	89 e5                	mov    %esp,%ebp
8010810a:	83 ec 04             	sub    $0x4,%esp
8010810d:	8b 45 08             	mov    0x8(%ebp),%eax
80108110:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108114:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108118:	8e e8                	mov    %eax,%gs
}
8010811a:	c9                   	leave  
8010811b:	c3                   	ret    

8010811c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010811c:	55                   	push   %ebp
8010811d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010811f:	8b 45 08             	mov    0x8(%ebp),%eax
80108122:	0f 22 d8             	mov    %eax,%cr3
}
80108125:	5d                   	pop    %ebp
80108126:	c3                   	ret    

80108127 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108127:	55                   	push   %ebp
80108128:	89 e5                	mov    %esp,%ebp
8010812a:	8b 45 08             	mov    0x8(%ebp),%eax
8010812d:	05 00 00 00 80       	add    $0x80000000,%eax
80108132:	5d                   	pop    %ebp
80108133:	c3                   	ret    

80108134 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108134:	55                   	push   %ebp
80108135:	89 e5                	mov    %esp,%ebp
80108137:	8b 45 08             	mov    0x8(%ebp),%eax
8010813a:	05 00 00 00 80       	add    $0x80000000,%eax
8010813f:	5d                   	pop    %ebp
80108140:	c3                   	ret    

80108141 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108141:	55                   	push   %ebp
80108142:	89 e5                	mov    %esp,%ebp
80108144:	53                   	push   %ebx
80108145:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108148:	e8 2b ad ff ff       	call   80102e78 <cpunum>
8010814d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108153:	05 80 33 11 80       	add    $0x80113380,%eax
80108158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010815b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108167:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010816d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108170:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010817b:	83 e2 f0             	and    $0xfffffff0,%edx
8010817e:	83 ca 0a             	or     $0xa,%edx
80108181:	88 50 7d             	mov    %dl,0x7d(%eax)
80108184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108187:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010818b:	83 ca 10             	or     $0x10,%edx
8010818e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108194:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108198:	83 e2 9f             	and    $0xffffff9f,%edx
8010819b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010819e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801081a5:	83 ca 80             	or     $0xffffff80,%edx
801081a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801081ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081b2:	83 ca 0f             	or     $0xf,%edx
801081b5:	88 50 7e             	mov    %dl,0x7e(%eax)
801081b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081bf:	83 e2 ef             	and    $0xffffffef,%edx
801081c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801081c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081cc:	83 e2 df             	and    $0xffffffdf,%edx
801081cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801081d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081d9:	83 ca 40             	or     $0x40,%edx
801081dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801081df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801081e6:	83 ca 80             	or     $0xffffff80,%edx
801081e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801081ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ef:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801081f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801081fd:	ff ff 
801081ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108202:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108209:	00 00 
8010820b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108218:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010821f:	83 e2 f0             	and    $0xfffffff0,%edx
80108222:	83 ca 02             	or     $0x2,%edx
80108225:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010822b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108235:	83 ca 10             	or     $0x10,%edx
80108238:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010823e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108241:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108248:	83 e2 9f             	and    $0xffffff9f,%edx
8010824b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108254:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010825b:	83 ca 80             	or     $0xffffff80,%edx
8010825e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108267:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010826e:	83 ca 0f             	or     $0xf,%edx
80108271:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108281:	83 e2 ef             	and    $0xffffffef,%edx
80108284:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010828a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108294:	83 e2 df             	and    $0xffffffdf,%edx
80108297:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010829d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082a7:	83 ca 40             	or     $0x40,%edx
801082aa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801082ba:	83 ca 80             	or     $0xffffff80,%edx
801082bd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801082c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801082cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801082d7:	ff ff 
801082d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082dc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801082e3:	00 00 
801082e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801082f9:	83 e2 f0             	and    $0xfffffff0,%edx
801082fc:	83 ca 0a             	or     $0xa,%edx
801082ff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108308:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010830f:	83 ca 10             	or     $0x10,%edx
80108312:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108322:	83 ca 60             	or     $0x60,%edx
80108325:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010832b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108335:	83 ca 80             	or     $0xffffff80,%edx
80108338:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010833e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108341:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108348:	83 ca 0f             	or     $0xf,%edx
8010834b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108354:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010835b:	83 e2 ef             	and    $0xffffffef,%edx
8010835e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108367:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010836e:	83 e2 df             	and    $0xffffffdf,%edx
80108371:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108381:	83 ca 40             	or     $0x40,%edx
80108384:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010838a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108394:	83 ca 80             	or     $0xffffff80,%edx
80108397:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010839d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801083a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083aa:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801083b1:	ff ff 
801083b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801083bd:	00 00 
801083bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801083c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083d3:	83 e2 f0             	and    $0xfffffff0,%edx
801083d6:	83 ca 02             	or     $0x2,%edx
801083d9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801083df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083e9:	83 ca 10             	or     $0x10,%edx
801083ec:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801083f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801083fc:	83 ca 60             	or     $0x60,%edx
801083ff:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108408:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010840f:	83 ca 80             	or     $0xffffff80,%edx
80108412:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108422:	83 ca 0f             	or     $0xf,%edx
80108425:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010842b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108435:	83 e2 ef             	and    $0xffffffef,%edx
80108438:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108441:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108448:	83 e2 df             	and    $0xffffffdf,%edx
8010844b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108454:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010845b:	83 ca 40             	or     $0x40,%edx
8010845e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108467:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010846e:	83 ca 80             	or     $0xffffff80,%edx
80108471:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108484:	05 b4 00 00 00       	add    $0xb4,%eax
80108489:	89 c3                	mov    %eax,%ebx
8010848b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848e:	05 b4 00 00 00       	add    $0xb4,%eax
80108493:	c1 e8 10             	shr    $0x10,%eax
80108496:	89 c1                	mov    %eax,%ecx
80108498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849b:	05 b4 00 00 00       	add    $0xb4,%eax
801084a0:	c1 e8 18             	shr    $0x18,%eax
801084a3:	89 c2                	mov    %eax,%edx
801084a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a8:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801084af:	00 00 
801084b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084be:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801084c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801084ce:	83 e1 f0             	and    $0xfffffff0,%ecx
801084d1:	83 c9 02             	or     $0x2,%ecx
801084d4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801084e4:	83 c9 10             	or     $0x10,%ecx
801084e7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801084ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801084f7:	83 e1 9f             	and    $0xffffff9f,%ecx
801084fa:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108503:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010850a:	83 c9 80             	or     $0xffffff80,%ecx
8010850d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108516:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010851d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108520:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108530:	83 e1 ef             	and    $0xffffffef,%ecx
80108533:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108543:	83 e1 df             	and    $0xffffffdf,%ecx
80108546:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108556:	83 c9 40             	or     $0x40,%ecx
80108559:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010855f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108562:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108569:	83 c9 80             	or     $0xffffff80,%ecx
8010856c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108575:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010857b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857e:	83 c0 70             	add    $0x70,%eax
80108581:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108588:	00 
80108589:	89 04 24             	mov    %eax,(%esp)
8010858c:	e8 37 fb ff ff       	call   801080c8 <lgdt>
  loadgs(SEG_KCPU << 3);
80108591:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108598:	e8 6a fb ff ff       	call   80108107 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010859d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801085a6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801085ad:	00 00 00 00 
}
801085b1:	83 c4 24             	add    $0x24,%esp
801085b4:	5b                   	pop    %ebx
801085b5:	5d                   	pop    %ebp
801085b6:	c3                   	ret    

801085b7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801085b7:	55                   	push   %ebp
801085b8:	89 e5                	mov    %esp,%ebp
801085ba:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801085bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c0:	c1 e8 16             	shr    $0x16,%eax
801085c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085ca:	8b 45 08             	mov    0x8(%ebp),%eax
801085cd:	01 d0                	add    %edx,%eax
801085cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801085d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d5:	8b 00                	mov    (%eax),%eax
801085d7:	83 e0 01             	and    $0x1,%eax
801085da:	85 c0                	test   %eax,%eax
801085dc:	74 17                	je     801085f5 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801085de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e1:	8b 00                	mov    (%eax),%eax
801085e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e8:	89 04 24             	mov    %eax,(%esp)
801085eb:	e8 44 fb ff ff       	call   80108134 <p2v>
801085f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085f3:	eb 4b                	jmp    80108640 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801085f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801085f9:	74 0e                	je     80108609 <walkpgdir+0x52>
801085fb:	e8 e2 a4 ff ff       	call   80102ae2 <kalloc>
80108600:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108603:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108607:	75 07                	jne    80108610 <walkpgdir+0x59>
      return 0;
80108609:	b8 00 00 00 00       	mov    $0x0,%eax
8010860e:	eb 47                	jmp    80108657 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108610:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108617:	00 
80108618:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010861f:	00 
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	89 04 24             	mov    %eax,(%esp)
80108626:	e8 5c d0 ff ff       	call   80105687 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	89 04 24             	mov    %eax,(%esp)
80108631:	e8 f1 fa ff ff       	call   80108127 <v2p>
80108636:	83 c8 07             	or     $0x7,%eax
80108639:	89 c2                	mov    %eax,%edx
8010863b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108640:	8b 45 0c             	mov    0xc(%ebp),%eax
80108643:	c1 e8 0c             	shr    $0xc,%eax
80108646:	25 ff 03 00 00       	and    $0x3ff,%eax
8010864b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108655:	01 d0                	add    %edx,%eax
}
80108657:	c9                   	leave  
80108658:	c3                   	ret    

80108659 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108659:	55                   	push   %ebp
8010865a:	89 e5                	mov    %esp,%ebp
8010865c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010865f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108662:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108667:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010866a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010866d:	8b 45 10             	mov    0x10(%ebp),%eax
80108670:	01 d0                	add    %edx,%eax
80108672:	83 e8 01             	sub    $0x1,%eax
80108675:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010867a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010867d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108684:	00 
80108685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108688:	89 44 24 04          	mov    %eax,0x4(%esp)
8010868c:	8b 45 08             	mov    0x8(%ebp),%eax
8010868f:	89 04 24             	mov    %eax,(%esp)
80108692:	e8 20 ff ff ff       	call   801085b7 <walkpgdir>
80108697:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010869a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010869e:	75 07                	jne    801086a7 <mappages+0x4e>
      return -1;
801086a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086a5:	eb 48                	jmp    801086ef <mappages+0x96>
    if(*pte & PTE_P)
801086a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086aa:	8b 00                	mov    (%eax),%eax
801086ac:	83 e0 01             	and    $0x1,%eax
801086af:	85 c0                	test   %eax,%eax
801086b1:	74 0c                	je     801086bf <mappages+0x66>
      panic("remap");
801086b3:	c7 04 24 ec 94 10 80 	movl   $0x801094ec,(%esp)
801086ba:	e8 7b 7e ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801086bf:	8b 45 18             	mov    0x18(%ebp),%eax
801086c2:	0b 45 14             	or     0x14(%ebp),%eax
801086c5:	83 c8 01             	or     $0x1,%eax
801086c8:	89 c2                	mov    %eax,%edx
801086ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086cd:	89 10                	mov    %edx,(%eax)
    if(a == last)
801086cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801086d5:	75 08                	jne    801086df <mappages+0x86>
      break;
801086d7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801086d8:	b8 00 00 00 00       	mov    $0x0,%eax
801086dd:	eb 10                	jmp    801086ef <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801086df:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801086e6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801086ed:	eb 8e                	jmp    8010867d <mappages+0x24>
  return 0;
}
801086ef:	c9                   	leave  
801086f0:	c3                   	ret    

801086f1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801086f1:	55                   	push   %ebp
801086f2:	89 e5                	mov    %esp,%ebp
801086f4:	53                   	push   %ebx
801086f5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801086f8:	e8 e5 a3 ff ff       	call   80102ae2 <kalloc>
801086fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108700:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108704:	75 0a                	jne    80108710 <setupkvm+0x1f>
    return 0;
80108706:	b8 00 00 00 00       	mov    $0x0,%eax
8010870b:	e9 98 00 00 00       	jmp    801087a8 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108710:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108717:	00 
80108718:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010871f:	00 
80108720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108723:	89 04 24             	mov    %eax,(%esp)
80108726:	e8 5c cf ff ff       	call   80105687 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010872b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108732:	e8 fd f9 ff ff       	call   80108134 <p2v>
80108737:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010873c:	76 0c                	jbe    8010874a <setupkvm+0x59>
    panic("PHYSTOP too high");
8010873e:	c7 04 24 f2 94 10 80 	movl   $0x801094f2,(%esp)
80108745:	e8 f0 7d ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010874a:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108751:	eb 49                	jmp    8010879c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108756:	8b 48 0c             	mov    0xc(%eax),%ecx
80108759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875c:	8b 50 04             	mov    0x4(%eax),%edx
8010875f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108762:	8b 58 08             	mov    0x8(%eax),%ebx
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	8b 40 04             	mov    0x4(%eax),%eax
8010876b:	29 c3                	sub    %eax,%ebx
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	8b 00                	mov    (%eax),%eax
80108772:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108776:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010877a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010877e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108785:	89 04 24             	mov    %eax,(%esp)
80108788:	e8 cc fe ff ff       	call   80108659 <mappages>
8010878d:	85 c0                	test   %eax,%eax
8010878f:	79 07                	jns    80108798 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108791:	b8 00 00 00 00       	mov    $0x0,%eax
80108796:	eb 10                	jmp    801087a8 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108798:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010879c:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801087a3:	72 ae                	jb     80108753 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801087a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801087a8:	83 c4 34             	add    $0x34,%esp
801087ab:	5b                   	pop    %ebx
801087ac:	5d                   	pop    %ebp
801087ad:	c3                   	ret    

801087ae <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801087ae:	55                   	push   %ebp
801087af:	89 e5                	mov    %esp,%ebp
801087b1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801087b4:	e8 38 ff ff ff       	call   801086f1 <setupkvm>
801087b9:	a3 98 8f 11 80       	mov    %eax,0x80118f98
  switchkvm();
801087be:	e8 02 00 00 00       	call   801087c5 <switchkvm>
}
801087c3:	c9                   	leave  
801087c4:	c3                   	ret    

801087c5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801087c5:	55                   	push   %ebp
801087c6:	89 e5                	mov    %esp,%ebp
801087c8:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801087cb:	a1 98 8f 11 80       	mov    0x80118f98,%eax
801087d0:	89 04 24             	mov    %eax,(%esp)
801087d3:	e8 4f f9 ff ff       	call   80108127 <v2p>
801087d8:	89 04 24             	mov    %eax,(%esp)
801087db:	e8 3c f9 ff ff       	call   8010811c <lcr3>
}
801087e0:	c9                   	leave  
801087e1:	c3                   	ret    

801087e2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801087e2:	55                   	push   %ebp
801087e3:	89 e5                	mov    %esp,%ebp
801087e5:	53                   	push   %ebx
801087e6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801087e9:	e8 99 cd ff ff       	call   80105587 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801087ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801087f4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801087fb:	83 c2 08             	add    $0x8,%edx
801087fe:	89 d3                	mov    %edx,%ebx
80108800:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108807:	83 c2 08             	add    $0x8,%edx
8010880a:	c1 ea 10             	shr    $0x10,%edx
8010880d:	89 d1                	mov    %edx,%ecx
8010880f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108816:	83 c2 08             	add    $0x8,%edx
80108819:	c1 ea 18             	shr    $0x18,%edx
8010881c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108823:	67 00 
80108825:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010882c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108832:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108839:	83 e1 f0             	and    $0xfffffff0,%ecx
8010883c:	83 c9 09             	or     $0x9,%ecx
8010883f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108845:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010884c:	83 c9 10             	or     $0x10,%ecx
8010884f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108855:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010885c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010885f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108865:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010886c:	83 c9 80             	or     $0xffffff80,%ecx
8010886f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108875:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010887c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010887f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108885:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010888c:	83 e1 ef             	and    $0xffffffef,%ecx
8010888f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108895:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010889c:	83 e1 df             	and    $0xffffffdf,%ecx
8010889f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801088a5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801088ac:	83 c9 40             	or     $0x40,%ecx
801088af:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801088b5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801088bc:	83 e1 7f             	and    $0x7f,%ecx
801088bf:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801088c5:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801088cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088d1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801088d8:	83 e2 ef             	and    $0xffffffef,%edx
801088db:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801088e1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088e7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801088ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801088f3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801088fa:	8b 52 08             	mov    0x8(%edx),%edx
801088fd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108903:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108906:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010890d:	e8 df f7 ff ff       	call   801080f1 <ltr>
  if(p->pgdir == 0)
80108912:	8b 45 08             	mov    0x8(%ebp),%eax
80108915:	8b 40 04             	mov    0x4(%eax),%eax
80108918:	85 c0                	test   %eax,%eax
8010891a:	75 0c                	jne    80108928 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010891c:	c7 04 24 03 95 10 80 	movl   $0x80109503,(%esp)
80108923:	e8 12 7c ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108928:	8b 45 08             	mov    0x8(%ebp),%eax
8010892b:	8b 40 04             	mov    0x4(%eax),%eax
8010892e:	89 04 24             	mov    %eax,(%esp)
80108931:	e8 f1 f7 ff ff       	call   80108127 <v2p>
80108936:	89 04 24             	mov    %eax,(%esp)
80108939:	e8 de f7 ff ff       	call   8010811c <lcr3>
  popcli();
8010893e:	e8 88 cc ff ff       	call   801055cb <popcli>
}
80108943:	83 c4 14             	add    $0x14,%esp
80108946:	5b                   	pop    %ebx
80108947:	5d                   	pop    %ebp
80108948:	c3                   	ret    

80108949 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108949:	55                   	push   %ebp
8010894a:	89 e5                	mov    %esp,%ebp
8010894c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010894f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108956:	76 0c                	jbe    80108964 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108958:	c7 04 24 17 95 10 80 	movl   $0x80109517,(%esp)
8010895f:	e8 d6 7b ff ff       	call   8010053a <panic>
  mem = kalloc();
80108964:	e8 79 a1 ff ff       	call   80102ae2 <kalloc>
80108969:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010896c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108973:	00 
80108974:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010897b:	00 
8010897c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897f:	89 04 24             	mov    %eax,(%esp)
80108982:	e8 00 cd ff ff       	call   80105687 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	89 04 24             	mov    %eax,(%esp)
8010898d:	e8 95 f7 ff ff       	call   80108127 <v2p>
80108992:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108999:	00 
8010899a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010899e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089a5:	00 
801089a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801089ad:	00 
801089ae:	8b 45 08             	mov    0x8(%ebp),%eax
801089b1:	89 04 24             	mov    %eax,(%esp)
801089b4:	e8 a0 fc ff ff       	call   80108659 <mappages>
  memmove(mem, init, sz);
801089b9:	8b 45 10             	mov    0x10(%ebp),%eax
801089bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801089c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801089c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801089c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ca:	89 04 24             	mov    %eax,(%esp)
801089cd:	e8 84 cd ff ff       	call   80105756 <memmove>
}
801089d2:	c9                   	leave  
801089d3:	c3                   	ret    

801089d4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801089d4:	55                   	push   %ebp
801089d5:	89 e5                	mov    %esp,%ebp
801089d7:	53                   	push   %ebx
801089d8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801089db:	8b 45 0c             	mov    0xc(%ebp),%eax
801089de:	25 ff 0f 00 00       	and    $0xfff,%eax
801089e3:	85 c0                	test   %eax,%eax
801089e5:	74 0c                	je     801089f3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801089e7:	c7 04 24 34 95 10 80 	movl   $0x80109534,(%esp)
801089ee:	e8 47 7b ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
801089f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089fa:	e9 a9 00 00 00       	jmp    80108aa8 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801089ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a02:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a05:	01 d0                	add    %edx,%eax
80108a07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a0e:	00 
80108a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a13:	8b 45 08             	mov    0x8(%ebp),%eax
80108a16:	89 04 24             	mov    %eax,(%esp)
80108a19:	e8 99 fb ff ff       	call   801085b7 <walkpgdir>
80108a1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a25:	75 0c                	jne    80108a33 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108a27:	c7 04 24 57 95 10 80 	movl   $0x80109557,(%esp)
80108a2e:	e8 07 7b ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a36:	8b 00                	mov    (%eax),%eax
80108a38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a43:	8b 55 18             	mov    0x18(%ebp),%edx
80108a46:	29 c2                	sub    %eax,%edx
80108a48:	89 d0                	mov    %edx,%eax
80108a4a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108a4f:	77 0f                	ja     80108a60 <loaduvm+0x8c>
      n = sz - i;
80108a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a54:	8b 55 18             	mov    0x18(%ebp),%edx
80108a57:	29 c2                	sub    %eax,%edx
80108a59:	89 d0                	mov    %edx,%eax
80108a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a5e:	eb 07                	jmp    80108a67 <loaduvm+0x93>
    else
      n = PGSIZE;
80108a60:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6a:	8b 55 14             	mov    0x14(%ebp),%edx
80108a6d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a73:	89 04 24             	mov    %eax,(%esp)
80108a76:	e8 b9 f6 ff ff       	call   80108134 <p2v>
80108a7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108a82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108a86:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a8a:	8b 45 10             	mov    0x10(%ebp),%eax
80108a8d:	89 04 24             	mov    %eax,(%esp)
80108a90:	e8 d3 92 ff ff       	call   80101d68 <readi>
80108a95:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a98:	74 07                	je     80108aa1 <loaduvm+0xcd>
      return -1;
80108a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a9f:	eb 18                	jmp    80108ab9 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108aa1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aab:	3b 45 18             	cmp    0x18(%ebp),%eax
80108aae:	0f 82 4b ff ff ff    	jb     801089ff <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108ab4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ab9:	83 c4 24             	add    $0x24,%esp
80108abc:	5b                   	pop    %ebx
80108abd:	5d                   	pop    %ebp
80108abe:	c3                   	ret    

80108abf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108abf:	55                   	push   %ebp
80108ac0:	89 e5                	mov    %esp,%ebp
80108ac2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80108ac8:	85 c0                	test   %eax,%eax
80108aca:	79 0a                	jns    80108ad6 <allocuvm+0x17>
    return 0;
80108acc:	b8 00 00 00 00       	mov    $0x0,%eax
80108ad1:	e9 c1 00 00 00       	jmp    80108b97 <allocuvm+0xd8>
  if(newsz < oldsz)
80108ad6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ad9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108adc:	73 08                	jae    80108ae6 <allocuvm+0x27>
    return oldsz;
80108ade:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ae1:	e9 b1 00 00 00       	jmp    80108b97 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ae9:	05 ff 0f 00 00       	add    $0xfff,%eax
80108aee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108af3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108af6:	e9 8d 00 00 00       	jmp    80108b88 <allocuvm+0xc9>
    mem = kalloc();
80108afb:	e8 e2 9f ff ff       	call   80102ae2 <kalloc>
80108b00:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108b03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b07:	75 2c                	jne    80108b35 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108b09:	c7 04 24 75 95 10 80 	movl   $0x80109575,(%esp)
80108b10:	e8 8b 78 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108b15:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b18:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b1c:	8b 45 10             	mov    0x10(%ebp),%eax
80108b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b23:	8b 45 08             	mov    0x8(%ebp),%eax
80108b26:	89 04 24             	mov    %eax,(%esp)
80108b29:	e8 6b 00 00 00       	call   80108b99 <deallocuvm>
      return 0;
80108b2e:	b8 00 00 00 00       	mov    $0x0,%eax
80108b33:	eb 62                	jmp    80108b97 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108b35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b3c:	00 
80108b3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b44:	00 
80108b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b48:	89 04 24             	mov    %eax,(%esp)
80108b4b:	e8 37 cb ff ff       	call   80105687 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b53:	89 04 24             	mov    %eax,(%esp)
80108b56:	e8 cc f5 ff ff       	call   80108127 <v2p>
80108b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b5e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b65:	00 
80108b66:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b71:	00 
80108b72:	89 54 24 04          	mov    %edx,0x4(%esp)
80108b76:	8b 45 08             	mov    0x8(%ebp),%eax
80108b79:	89 04 24             	mov    %eax,(%esp)
80108b7c:	e8 d8 fa ff ff       	call   80108659 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108b81:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80108b8e:	0f 82 67 ff ff ff    	jb     80108afb <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108b94:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b97:	c9                   	leave  
80108b98:	c3                   	ret    

80108b99 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108b99:	55                   	push   %ebp
80108b9a:	89 e5                	mov    %esp,%ebp
80108b9c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108b9f:	8b 45 10             	mov    0x10(%ebp),%eax
80108ba2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ba5:	72 08                	jb     80108baf <deallocuvm+0x16>
    return oldsz;
80108ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108baa:	e9 a4 00 00 00       	jmp    80108c53 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108baf:	8b 45 10             	mov    0x10(%ebp),%eax
80108bb2:	05 ff 0f 00 00       	add    $0xfff,%eax
80108bb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108bbf:	e9 80 00 00 00       	jmp    80108c44 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bce:	00 
80108bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd6:	89 04 24             	mov    %eax,(%esp)
80108bd9:	e8 d9 f9 ff ff       	call   801085b7 <walkpgdir>
80108bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108be1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108be5:	75 09                	jne    80108bf0 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108be7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108bee:	eb 4d                	jmp    80108c3d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bf3:	8b 00                	mov    (%eax),%eax
80108bf5:	83 e0 01             	and    $0x1,%eax
80108bf8:	85 c0                	test   %eax,%eax
80108bfa:	74 41                	je     80108c3d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bff:	8b 00                	mov    (%eax),%eax
80108c01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108c09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c0d:	75 0c                	jne    80108c1b <deallocuvm+0x82>
        panic("kfree");
80108c0f:	c7 04 24 8d 95 10 80 	movl   $0x8010958d,(%esp)
80108c16:	e8 1f 79 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c1e:	89 04 24             	mov    %eax,(%esp)
80108c21:	e8 0e f5 ff ff       	call   80108134 <p2v>
80108c26:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c2c:	89 04 24             	mov    %eax,(%esp)
80108c2f:	e8 15 9e ff ff       	call   80102a49 <kfree>
      *pte = 0;
80108c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108c3d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c47:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c4a:	0f 82 74 ff ff ff    	jb     80108bc4 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108c50:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c53:	c9                   	leave  
80108c54:	c3                   	ret    

80108c55 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108c55:	55                   	push   %ebp
80108c56:	89 e5                	mov    %esp,%ebp
80108c58:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108c5b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108c5f:	75 0c                	jne    80108c6d <freevm+0x18>
    panic("freevm: no pgdir");
80108c61:	c7 04 24 93 95 10 80 	movl   $0x80109593,(%esp)
80108c68:	e8 cd 78 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108c6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c74:	00 
80108c75:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108c7c:	80 
80108c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80108c80:	89 04 24             	mov    %eax,(%esp)
80108c83:	e8 11 ff ff ff       	call   80108b99 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108c88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c8f:	eb 48                	jmp    80108cd9 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9e:	01 d0                	add    %edx,%eax
80108ca0:	8b 00                	mov    (%eax),%eax
80108ca2:	83 e0 01             	and    $0x1,%eax
80108ca5:	85 c0                	test   %eax,%eax
80108ca7:	74 2c                	je     80108cd5 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cb6:	01 d0                	add    %edx,%eax
80108cb8:	8b 00                	mov    (%eax),%eax
80108cba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cbf:	89 04 24             	mov    %eax,(%esp)
80108cc2:	e8 6d f4 ff ff       	call   80108134 <p2v>
80108cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccd:	89 04 24             	mov    %eax,(%esp)
80108cd0:	e8 74 9d ff ff       	call   80102a49 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108cd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108cd9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ce0:	76 af                	jbe    80108c91 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce5:	89 04 24             	mov    %eax,(%esp)
80108ce8:	e8 5c 9d ff ff       	call   80102a49 <kfree>
}
80108ced:	c9                   	leave  
80108cee:	c3                   	ret    

80108cef <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108cef:	55                   	push   %ebp
80108cf0:	89 e5                	mov    %esp,%ebp
80108cf2:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108cf5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108cfc:	00 
80108cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d04:	8b 45 08             	mov    0x8(%ebp),%eax
80108d07:	89 04 24             	mov    %eax,(%esp)
80108d0a:	e8 a8 f8 ff ff       	call   801085b7 <walkpgdir>
80108d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108d12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d16:	75 0c                	jne    80108d24 <clearpteu+0x35>
    panic("clearpteu");
80108d18:	c7 04 24 a4 95 10 80 	movl   $0x801095a4,(%esp)
80108d1f:	e8 16 78 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d27:	8b 00                	mov    (%eax),%eax
80108d29:	83 e0 fb             	and    $0xfffffffb,%eax
80108d2c:	89 c2                	mov    %eax,%edx
80108d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d31:	89 10                	mov    %edx,(%eax)
}
80108d33:	c9                   	leave  
80108d34:	c3                   	ret    

80108d35 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108d35:	55                   	push   %ebp
80108d36:	89 e5                	mov    %esp,%ebp
80108d38:	53                   	push   %ebx
80108d39:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108d3c:	e8 b0 f9 ff ff       	call   801086f1 <setupkvm>
80108d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d48:	75 0a                	jne    80108d54 <copyuvm+0x1f>
    return 0;
80108d4a:	b8 00 00 00 00       	mov    $0x0,%eax
80108d4f:	e9 fd 00 00 00       	jmp    80108e51 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108d54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d5b:	e9 d0 00 00 00       	jmp    80108e30 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d6a:	00 
80108d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d72:	89 04 24             	mov    %eax,(%esp)
80108d75:	e8 3d f8 ff ff       	call   801085b7 <walkpgdir>
80108d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d81:	75 0c                	jne    80108d8f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108d83:	c7 04 24 ae 95 10 80 	movl   $0x801095ae,(%esp)
80108d8a:	e8 ab 77 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108d8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d92:	8b 00                	mov    (%eax),%eax
80108d94:	83 e0 01             	and    $0x1,%eax
80108d97:	85 c0                	test   %eax,%eax
80108d99:	75 0c                	jne    80108da7 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108d9b:	c7 04 24 c8 95 10 80 	movl   $0x801095c8,(%esp)
80108da2:	e8 93 77 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108daa:	8b 00                	mov    (%eax),%eax
80108dac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108db1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db7:	8b 00                	mov    (%eax),%eax
80108db9:	25 ff 0f 00 00       	and    $0xfff,%eax
80108dbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108dc1:	e8 1c 9d ff ff       	call   80102ae2 <kalloc>
80108dc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108dc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108dcd:	75 02                	jne    80108dd1 <copyuvm+0x9c>
      goto bad;
80108dcf:	eb 70                	jmp    80108e41 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108dd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dd4:	89 04 24             	mov    %eax,(%esp)
80108dd7:	e8 58 f3 ff ff       	call   80108134 <p2v>
80108ddc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108de3:	00 
80108de4:	89 44 24 04          	mov    %eax,0x4(%esp)
80108de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108deb:	89 04 24             	mov    %eax,(%esp)
80108dee:	e8 63 c9 ff ff       	call   80105756 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108df3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108df9:	89 04 24             	mov    %eax,(%esp)
80108dfc:	e8 26 f3 ff ff       	call   80108127 <v2p>
80108e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108e04:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108e08:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108e0c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e13:	00 
80108e14:	89 54 24 04          	mov    %edx,0x4(%esp)
80108e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1b:	89 04 24             	mov    %eax,(%esp)
80108e1e:	e8 36 f8 ff ff       	call   80108659 <mappages>
80108e23:	85 c0                	test   %eax,%eax
80108e25:	79 02                	jns    80108e29 <copyuvm+0xf4>
      goto bad;
80108e27:	eb 18                	jmp    80108e41 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108e29:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e33:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e36:	0f 82 24 ff ff ff    	jb     80108d60 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e3f:	eb 10                	jmp    80108e51 <copyuvm+0x11c>

bad:
  freevm(d);
80108e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e44:	89 04 24             	mov    %eax,(%esp)
80108e47:	e8 09 fe ff ff       	call   80108c55 <freevm>
  return 0;
80108e4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e51:	83 c4 44             	add    $0x44,%esp
80108e54:	5b                   	pop    %ebx
80108e55:	5d                   	pop    %ebp
80108e56:	c3                   	ret    

80108e57 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108e57:	55                   	push   %ebp
80108e58:	89 e5                	mov    %esp,%ebp
80108e5a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108e5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e64:	00 
80108e65:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108e6f:	89 04 24             	mov    %eax,(%esp)
80108e72:	e8 40 f7 ff ff       	call   801085b7 <walkpgdir>
80108e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7d:	8b 00                	mov    (%eax),%eax
80108e7f:	83 e0 01             	and    $0x1,%eax
80108e82:	85 c0                	test   %eax,%eax
80108e84:	75 07                	jne    80108e8d <uva2ka+0x36>
    return 0;
80108e86:	b8 00 00 00 00       	mov    $0x0,%eax
80108e8b:	eb 25                	jmp    80108eb2 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e90:	8b 00                	mov    (%eax),%eax
80108e92:	83 e0 04             	and    $0x4,%eax
80108e95:	85 c0                	test   %eax,%eax
80108e97:	75 07                	jne    80108ea0 <uva2ka+0x49>
    return 0;
80108e99:	b8 00 00 00 00       	mov    $0x0,%eax
80108e9e:	eb 12                	jmp    80108eb2 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea3:	8b 00                	mov    (%eax),%eax
80108ea5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eaa:	89 04 24             	mov    %eax,(%esp)
80108ead:	e8 82 f2 ff ff       	call   80108134 <p2v>
}
80108eb2:	c9                   	leave  
80108eb3:	c3                   	ret    

80108eb4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108eb4:	55                   	push   %ebp
80108eb5:	89 e5                	mov    %esp,%ebp
80108eb7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108eba:	8b 45 10             	mov    0x10(%ebp),%eax
80108ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108ec0:	e9 87 00 00 00       	jmp    80108f4c <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ec8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ecd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80108eda:	89 04 24             	mov    %eax,(%esp)
80108edd:	e8 75 ff ff ff       	call   80108e57 <uva2ka>
80108ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108ee5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ee9:	75 07                	jne    80108ef2 <copyout+0x3e>
      return -1;
80108eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ef0:	eb 69                	jmp    80108f5b <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ef5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108ef8:	29 c2                	sub    %eax,%edx
80108efa:	89 d0                	mov    %edx,%eax
80108efc:	05 00 10 00 00       	add    $0x1000,%eax
80108f01:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f07:	3b 45 14             	cmp    0x14(%ebp),%eax
80108f0a:	76 06                	jbe    80108f12 <copyout+0x5e>
      n = len;
80108f0c:	8b 45 14             	mov    0x14(%ebp),%eax
80108f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f18:	29 c2                	sub    %eax,%edx
80108f1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f1d:	01 c2                	add    %eax,%edx
80108f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f22:	89 44 24 08          	mov    %eax,0x8(%esp)
80108f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f29:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f2d:	89 14 24             	mov    %edx,(%esp)
80108f30:	e8 21 c8 ff ff       	call   80105756 <memmove>
    len -= n;
80108f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f38:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f44:	05 00 10 00 00       	add    $0x1000,%eax
80108f49:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108f4c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108f50:	0f 85 6f ff ff ff    	jne    80108ec5 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108f56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f5b:	c9                   	leave  
80108f5c:	c3                   	ret    
