#include "types.h"
#include "stat.h"
#include "user.h"

struct perf {
  int ctime;					//Creation time
  int ttime;					//Termination time
  int stime;					//Sleeping state time
  int retime;					//Ready state time
  int rutime;					//Running state time
};

int
main(int argc, char *argv[])
{
	int n = 20;
	int toWait = 0;
	int toRun = 0;
	int toTurnaround = 0;
	printf(1, "Please wait......\n");
	//set_priority(1);
	while (n-- > 0) {
		if (!fork()) { // child process
	//		//set_priority(n%3);
			double waister = 1000000;
			while ( (waister = waister-0.1) > 0.0);
			//*********** for ck sleep time!
			//int pidg = getpid();
			//int tmp[2];
			//read(tmp[0], &pidg, sizeof(pidg));
			exit();
		}
	}
	int pid;
	struct perf *perfP=0;
	perfP = malloc(sizeof(struct perf));
	memset(perfP, 0, sizeof(struct perf));


	while (++n < 20) {
		pid = wait_stat((struct perf *)perfP);
		//printf(1, "pid: %d | ctime: %d | ttime: %d | stime: %d | retime: %d | rutime: %d\n"
		//		, pid, perfP->ctime, perfP->ttime, perfP->stime, perfP->retime, perfP->rutime);
		printf(1, "pid: %d | waiting time: %d | running time: %d | turnaround time: %d\n"
						, pid, perfP->retime, perfP->rutime, perfP->ttime - perfP->ctime + perfP->stime);
		toWait += perfP->retime;
		toRun += perfP->rutime;
		toTurnaround += perfP->ttime - perfP->ctime + perfP->stime;
	}
	printf(1, "Avg waiting time: %d\n Avg running time: %d\n Avg turnaround time: %d \n", toWait/20, toRun/20, toTurnaround/20);
		exit();
		return 0;
}
