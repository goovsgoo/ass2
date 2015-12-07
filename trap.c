#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;
int isFCFS = 0;

extern int implicit_sigret();
extern int end_of_sigret();

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
  
  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

/**
 * Gets an integer, and returns the number of the lowest bit which is set to 1
**/
int 
getLowestSetBit(int num) {
    if (num == 0)
	return -1;
    
    int bitNum = 0;
    while ((num & 1) == 0) {
	num = num >> 1;
	bitNum++;
    }
    return bitNum;
}

void
copytf(struct trapframe * tf, struct trapframe * copyaddr) {
    copyaddr->edi = tf->edi;
    copyaddr->esi = tf->esi;
    copyaddr->ebp = tf->ebp;
    copyaddr->oesp = tf->oesp;
    copyaddr->ebx = tf->ebx;
    copyaddr->edx = tf->edx;
    copyaddr->ecx = tf->ecx;
    copyaddr->eax = tf->eax;
    copyaddr->gs = tf->gs;
    copyaddr->padding1 = tf->padding1;
    copyaddr->fs = tf->fs;
    copyaddr->padding2 = tf->padding2;
    copyaddr->es = tf->es;
    copyaddr->padding3 = tf->padding3;
    copyaddr->ds = tf->ds;
    copyaddr->padding4 = tf->padding4;
    copyaddr->trapno = tf->trapno;
    copyaddr->err = tf->err;
    copyaddr->eip = tf->eip;
    copyaddr->cs = tf->cs;
    copyaddr->padding5 = tf->padding5;
    copyaddr->eflags = tf->eflags;
    copyaddr->esp = tf->esp;
    copyaddr->ss = tf->ss;
    copyaddr->padding6 = tf->padding6;
    return;
}


char *int2bin(int a)
{
 char *str,*tmp;
 int cnt = 31;
 str = (char *) kalloc(); /*32 + 1 , because its a 32 bit bin number*/
 tmp = str;
 while ( cnt > -1 ){
      str[cnt]= '0';
      cnt --;
 }
 cnt = 31;
 while (a > 0){
       if (a%2==1){
           str[cnt] = '1';
        }
      cnt--;
        a = a/2 ;
 }
 return tmp;

}

void
handleSignals(struct trapframe *tf) {      
    if(tf->trapno == T_SYSCALL && proc->pending > 0 && proc->insignal == 0) {      
      int signum = getLowestSetBit(proc->pending);
      proc->pending &= ~(1 << signum);
      proc->insignal = 1;
      sighandler_t handler = proc->signal_handlers[signum];
      if (!proc->backuptf) {
          proc->backuptf = (struct trapframe*)kalloc();
      }
      copytf(proc->tf, proc->backuptf);          // Copy trap frame, to be reconstruced later
      
      int* sp = (int*)proc->tf->esp;
      int funcAddr = (int)(sp - 5); // We put the sigret function 5*4 bytes under the stack pointer. (its size is approx. 8 bytes)
      int funcSize = (int)&end_of_sigret - (int)&implicit_sigret;		
      copyout(proc->pgdir, funcAddr, &implicit_sigret, funcSize);			// Push implicit_sigret argument to stack
      
      // We put the arguent 4 bytes under the stack pointer, and the ret address 8 bytes under.
      sp--;
      *sp = signum;
      sp--;  
      *sp = funcAddr;    
    
      // new we set the stack pointer to be 8 bytes under (where the ret address is located)
      proc->tf->esp -= 8;
      proc->tf->eip = (uint)handler;
    }
    return;
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(proc->killed)
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      advanceprocstats();
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
    break;
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
	  #ifdef FCFS
		 isFCFS = 1;
	  #endif
	  if( proc->runQuanta % QUANTA == 0 && isFCFS == 0){
		  //cprintf(" \n ******* pid=%d; runQuanta=%d; rutime=%d; \n",proc->pid,proc->runQuanta,proc->rutime-1);
		  proc->runQuanta=proc->rutime;
		  yield();
	  }
	  else
		  proc->runQuanta++;
  }

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
