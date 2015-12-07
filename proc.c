#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

struct {
	struct spinlock lock;
	struct proc* first;
	struct proc* last;
} rrqueue;

int x=1;
int y=2;
int z=3;
int w=4;

int totalTickets=0;

int
xorshift128(void) {
    int t = x ^ (x << 11);
    x = y; y = z; z = w;
    return w = w ^ (w >> 19) ^ t ^ (t >> 8);
}

// Prints the Round Robin FIFO queue - rightmost is the first in. (for tests)
void printRRQueue() {
  acquire(&rrqueue.lock);
  struct proc * p = rrqueue.first;
  while ( p != 0 ) {
      //cprintf("proc: %d, state: %d, tickets: %d to %d | ", p->pid, p->state, p->firstTicketNum, p->firstTicketNum + p->tickets - 1);
      p = p->rrnext;
  }  
  //cprintf("\n");
  release(&rrqueue.lock);
}

// Push process p to Round Robin FIFO queue
void
pushProcToRRqueue(struct proc* p)
{
    //cprintf("pushing proc %d to queue!\n", p->pid);
    acquire(&rrqueue.lock);
    if (!rrqueue.first) {
	rrqueue.first = p;    
    }
    if (rrqueue.last) {
	rrqueue.last->rrnext = p;
	p->rrprev = rrqueue.last;
    }
    rrqueue.last = p;
    release(&rrqueue.lock);
}

// Remove process p from Round Robin FIFO queue
void
removeProcFromRRqueue(struct proc* p)
{
    //cprintf("removing proc %d from queue!\n", p->pid);
    if (p->rrprev) {
	p->rrprev->rrnext = p->rrnext;
    }
    if (p->rrnext) {
	p->rrnext->rrprev = p->rrprev;
    }    
    if (p == rrqueue.first) {
	rrqueue.first = p->rrnext;
    }	    
    if (p == rrqueue.last) {
	rrqueue.last = p->rrprev;  
    }
    
    p->rrnext = 0;
    p->rrprev = 0;
}

// Rolling a ticket, and returns the process which holds that ticket, or 0 if FIFO is empty.
struct proc* 
pickProcess() 
{
    //cprintf("picking, total tickets: %d\n", totalTickets);
    struct proc * selectedProc = 0;
    
    acquire(&rrqueue.lock);
    if (totalTickets > 0) {
	int ticket = xorshift128() % totalTickets;      
	//cprintf("ticket no. is: %d\n", ticket);
	struct proc * p = rrqueue.first;
	while ( p != 0 ) {
	    if(ticket >= p->firstTicketNum && ticket <= (p->tickets + p->firstTicketNum - 1)) {
		selectedProc = p;
		break;
	    }	
	    p = p->rrnext;
	}  
    }
    release(&rrqueue.lock);
     //if (selectedProc != 0)
     //  cprintf("pid chose to run is: %d, tickets: %d to %d\n", selectedProc->pid, selectedProc->firstTicketNum, selectedProc->firstTicketNum + selectedProc->tickets - 1);
    return selectedProc;
}

// Deliver ticket to all processes in the FIFO queue
void
deliverTicketsToFIFOProcs()
{
    totalTickets = 0;
    acquire(&rrqueue.lock);
    struct proc * p = rrqueue.last;
    if (p == 0) {
	release(&rrqueue.lock);
	return;
    }
    #if defined(FRR) || defined(FCFS)
	while ( p != rrqueue.first ) {  
	    if (p->state != RUNNABLE) {
		struct proc* tmp = p->rrprev;
		removeProcFromRRqueue(p);
		p = tmp;
		continue;
	    }
	    p->firstTicketNum = totalTickets + 1;
	    p->tickets = EXE_TICKETS;
	    totalTickets += EXE_TICKETS;
	    p = p->rrprev;
	}	
	p->firstTicketNum = totalTickets + 1;
	p->tickets = EXE_TICKETS + FIFO_DIFFERECE * totalTickets;
	totalTickets += p->tickets;
    #endif
    #ifdef PRS
	int priority1Procs = 0;
	int priority2Procs = 0;
	int priority3Procs = 0;
	while ( p != 0 ) {
	    if (p->state != RUNNABLE) {
		struct proc* tmp = p->rrprev;
		removeProcFromRRqueue(p);
		p = tmp;
		continue;
	    }
	    if (p->priority <= 0) {
		  priority1Procs++;
	    }
	    else if (p->priority == 1) {
		  priority2Procs++;
	    }
	    else if (p->priority >= 2) {
		  priority3Procs++;
	    }
	    p = p->rrprev;
	}	
	
	p = rrqueue.last;
	while ( p != 0 ) {
	  p->firstTicketNum = totalTickets + 1;
	  if (p->priority <= 0) {
	      p->tickets = EXE_TICKETS;
	  }
	  else if (p->priority == 1) {
	      p->tickets = EXE_TICKETS + EXE_TICKETS * priority1Procs * FIFO_DIFFERECE;
	  }
	  else if (p->priority >= 2) {
	    p->tickets = EXE_TICKETS + EXE_TICKETS * (priority1Procs + priority2Procs * FIFO_DIFFERECE) * FIFO_DIFFERECE ;
	  }
	  totalTickets += p->tickets;
	  p = p->rrprev;
	}
    #endif
    release(&rrqueue.lock);
    printRRQueue();
}

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}


//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
//   p->tickets = EXE_TICKETS;
//   totalTickets += EXE_TICKETS;
  acquire(&tickslock);
  p->ctime = ticks;
  release(&tickslock);
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
  p->priority = 0;
//   p->tickets = EXE_TICKETS;
#if defined(FRR) || defined(FCFS) || defined(PRS)
  pushProcToRRqueue(p);
#endif
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
   pid = np->pid;
   np->runQuanta = 0;		//reset proc Time
   np->rutime = 0;
   acquire(&tickslock);
   np->ctime = ticks;
   release(&tickslock);
   np->ttime	 = 0;
   np->stime	 = 0;
   np->retime	 = 0;
   np->priority = proc->priority;
  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(np);
  #endif
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

//   totalTickets -= proc->tickets;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  acquire(&tickslock);
  proc->ttime = ticks;
  release(&tickslock);
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->runQuanta = 0;		//reset proc Time
        p->rutime = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
acquire(&ptable.lock);    
#ifdef DEFAULT
    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    
#endif
#if defined(FRR) || defined(FCFS) || defined(PRS)
  
    deliverTicketsToFIFOProcs();
    p = pickProcess(); 
    if (p != 0) {
	proc = p;
	acquire(&rrqueue.lock);
	removeProcFromRRqueue(p);
	release(&rrqueue.lock);
	switchuvm(p);
	p->state = RUNNING;    
	swtch(&cpu->scheduler, proc->context);
	switchkvm();
	
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
	//break;
    }
#endif
release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  #if defined(FRR) || defined(FCFS) || defined(PRS)
      pushProcToRRqueue(proc);
  #endif
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  //cprintf("I, process %d, went to sleep\n", proc->pid);
  if(proc == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;
//   totalTickets -= proc->tickets;
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;
//       totalTickets += p->tickets;
      #if defined(FRR) || defined(FCFS) || defined(PRS)
	  pushProcToRRqueue(p);
      #endif
    }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
        p->state = RUNNABLE;
	#if defined(FRR) || defined(FCFS) || defined(PRS)
	    pushProcToRRqueue(p);
	#endif
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

int 
signal(int signum, sighandler_t handler) {
	sighandler_t retHandler;
	if (signum >= 32 || signum < 0) {
	    return -1;
	}
	else {	
	    retHandler =  proc->signal_handlers[signum];
	    proc->signal_handlers[signum] = handler;
	}
	return (int)retHandler;
}

int 
sigsend(int pid, int signum) {
    struct proc *p;

    if (signum >= 31 || signum < 0) {
	return -1;
    }
    uint signumBits = 1 << signum; // bit respresentation of signum. e.g: signum = 5 -> signumBits = 000000...0100000         
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->pid == pid){
	p->pending |= signumBits;
	// Wake process from sleep if necessary.
	if(p->state == SLEEPING)
	  p->state = RUNNABLE;
	release(&ptable.lock);
	return 0;
      }
    }
    release(&ptable.lock);
    return -1;
}

void
advanceprocstats(void)
{
	struct proc *p;

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
		if(p->state == RUNNING) {
			p->rutime++;
			continue;
		}
		if(p->state == RUNNABLE) {
			p->retime++;
			continue;
		}
		if(p->state == SLEEPING) {
			p->stime++;
			continue;
		}
	}
 }

int
wait_stat(struct perf *perfP){
	struct proc *p;
	int havekids, pid;
	acquire(&ptable.lock);
	for(;;){
		// Scan through table looking for zombie children.
		havekids = 0;
		for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if(p->parent != proc)
				continue;
			havekids = 1;
			if(p->state == ZOMBIE){
			  
				// Found one.
				pid = p->pid;
				
				// the extra
				perfP->ctime =  p->ctime ;
				perfP->ttime =  p->ttime ;
				perfP->stime =  p->stime ;
				perfP->retime = p->retime ;
				perfP->rutime = p->rutime ;
				kfree(p->kstack);
				p->kstack = 0;
				freevm(p->pgdir);
				p->state = UNUSED;
				p->pid = 0;
				p->parent = 0;
				p->name[0] = 0;
				p->killed = 0;
				release(&ptable.lock);
				return pid;
			}
		}
		
		// No point waiting if we don't have any children.
		if(!havekids || proc->killed){
			release(&ptable.lock);
			return -1;
		}

		// Wait for children to exit.  (See wakeup1 call in proc_exit.)
		sleep(proc, &ptable.lock);  //DOC: wait-sleep
	}

 }


