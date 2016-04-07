#include <limits.h>
#include <stddef.h>
#include <limits.h>
#include <stddef.h>
#include <string.h>
#include <malloc.h>
#include <lzo/lzo1x.h>

int main(){

	char  in[65535];
	char  out[65535];
	int i,in_len, total_len;
	FILE *fp;
	fp = fopen("/tmp/test.elf","r");
	fread(in,2729,1,fp);
	total_len;
	in_len = 1840;
	lzo1x_decompress_safe(in,in_len,out,&i,NULL);	

		write(1,out,i);
	// second page
	bzero(out,i);
	i = 0;

	in_len = 0x036d;
//	fprintf(stderr,"second len = %d",in_len);
	lzo1x_decompress_safe(in+1844,in_len,out,&i,NULL);	
//	fprintf(stderr,"second out = %d",i);
	write(1,out,i);
}
