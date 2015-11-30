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
	//int n = 20;
	//set_priority(1);
	//while (n-- > 0) {
		if (!fork()) { // child process
	//		//set_priority(n%3);
			double waister = 1000000;
			while ( (waister = waister-0.1) > 0.0);
	//		exit(getpid());
			exit();
		}
	//}
	printf(1, "Running highly consuming processes. Please wait...\n");
	int pid;
	struct perf *perfP=0;
	perfP = malloc(sizeof(struct perf));
	memset(perfP, 0, sizeof(struct perf));


	//while (++n < 20) {
		pid = wait_stat((struct perf *)perfP);
		printf(1, "pid: %d | ctime: %d | ttime: %d | stime: %d | retime: %d | rutime: %d\n"
				, pid, perfP->ctime, perfP->ttime, perfP->stime, perfP->retime, perfP->rutime);
	//}
	//printf(1, "average waiting time: %d\naverage running time: %d\naverage sleeping time: %d\naverage turnaround time: %d\n", totwtime/20, totrtime/20, totiotime/20, totturnaround/20);
	//exit();
		exit();
		return 0;
}
