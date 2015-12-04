#include "types.h"
#include "stat.h"
#include "user.h"

void
test(int num)
{
  printf(1, "recieved from %d signal %d\n", getpid(), num);
  //sigreturn();
}

int
main(int argc, char *argv[])
{
  int i,j;
  for (i=0; i < 32; i++) {
      signal(i, test);
  }
  
  for (j=0; j < 32; j++) {
      sigsend(getpid(), j);
  }
  
  exit();
}
 
