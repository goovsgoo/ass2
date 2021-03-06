#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int
sys_signal(void)
{
	int signum;
	int handler;

	if ( (argint(0, &signum) < 0) | (argint(1, &handler) < 0) )
		return -1;
	return signal(signum, (sighandler_t)handler);
}

int
sys_sigsend(void)
{
	int pid;
	int signum;

	if ( (argint(0, &pid) < 0) | (argint(1, &signum) < 0) )
		return -1;
	return sigsend(pid, signum);
}

void copytf(struct trapframe *, struct trapframe *);

int
sys_sigreturn(void)
{
	//cprintf("sys_sigreturn for %d\n", proc->pid);
	copytf(proc->backuptf, proc->tf);	
	proc->insignal=0;
	return 0;
}

int
sys_advanceprocstats(void) {
       advanceprocstats();
       return 0;
}

int
sys_wait_stat(void)
{
	   int perfP = 0;
       if(argint(0,&perfP) < 0)
               return -1;
       return  wait_stat((struct perf *)perfP);

}

int
sys_priority(void)
{
      int priority = 0;
      if(argint(0, &priority) < 0)
	  return -1;
      proc->priority = priority;
      return 0;
}
