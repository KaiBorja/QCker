#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#define HAVE_STRUCT_TIMESPEC
#define NUM_THREADS	2

extern int strcnt();

//Thread1
extern int getinst();
extern int precheckblk();
extern int checkblkavx();
//extern int getrank();
extern int getindex();
extern int checkblk1();
//extern int threshold();
extern char movstring();	
extern int avxrank();
extern int avxprerank();
extern int avxthres();

//Thread2
extern int getinst2();
extern int precheckblk2();
extern int checkblkavx2();
//extern int getrank2();
extern int getindex2();
extern int checkblk2();
//extern int threshold2();
extern char movstring2();
extern int avxrank2();
extern int avxprerank2();
extern int avxthres2();



void *filter(void *threadid)
{
clock_t begin = clock();
	
    long tid;
    tid = (long)threadid;
		
    	
    printf("It's me, thread #%ld!\n", tid);
	int *pos = malloc(150000000*sizeof(int)); // position of the 2grams in refernce
	//int *rank = malloc(1000000*sizeof(int)); // rank of gram
	int *dir = malloc(1000000*sizeof(int)); // tells number of instances
	//int *tempdir = malloc(1000000*sizeof(int));
	int instans;
	int instans2;	//Number of instances
	int dirLen =0; //Size of Dir Table
	int possize=0; //Size of Pos Table
	//int ranksize = 0;//Size of Rank Table
	int readsize=0; //Size of Read
	int thold =0; //Computed Threshold
	char curread[12]__attribute__ ((aligned (16)))="";
	int seedsize = 8;
	int k=0; // number of errors
	//printf("Enter seedsize: ");
	//scanf("%d",&seedsize);

//************************************************************
int currblk=0;
int crank=0;// rank of read variable
int indexofrank=0;
int i=0;// counter for loop
int y=0; // counter for loop
int x=0; // counter for loop
int posindex=0; // variable for index in pos table 
int inst=0; // number of instances of a read
int result=0;	
int z=0; // counter for loop
int length=0; // length of reference
int dum=0;
int idk=0;
int p=0;	
	FILE *fp_ref;					//Reference text file
	FILE *fp_read;					//FILE declarations for reads.txt
	FILE *fp_read2;					//FILE declarations for reads.txt
	FILE *fp_read3;					//FILE declarations for reads.txt
	FILE *fp_dir;					//dir.txt which contains number of instances
	//FILE *fp_rank;					//rank_table.txt which contains the computed ranks
	FILE *fp_pos;					//pos.txt which contains position of the q-grams
	FILE *fp_out;
	fp_ref= fopen("Ndna.txt","r");
	fp_dir = fopen("dir.txt","r");
	//fp_rank= fopen("rank.txt","r");
	fp_pos = fopen("pos.txt","r");
	fp_read = fopen("readTest.txt","r");
	fp_read2 = fopen("readTest.txt","r");
	fp_read3 = fopen("readTest.txt","r");
	if(tid==1)
		fp_out = fopen("out1.txt","w");
	else
		fp_out = fopen("out2.txt","w");
	
		
	int a;
	char *str = malloc(1000000*sizeof(char));
	char mainread[104];//size of read
	char mainreadcpy[104];//size of read
		
	
	while(fgets(str,1000,fp_ref)!=NULL){			//read through the input reference
		length =length+strcnt(str);				//get the length of the input reference
	}	
	

	int nreads=0;
	while(fgets(mainread,1000,fp_read)!=NULL){			//read through the reads
		readsize = strcnt(mainread);				//get the length of the reads
		nreads++;
	}
	readsize=readsize-1;

	int lenblk=(readsize+k)*2;// length of block	
	int nblock=(length/readsize)-1;// num blocks

//	int cntblk[nblock]  __attribute__ ((aligned (16)));
//	int blkpass[nblock] __attribute__ ((aligned (16)));
	int dumvar[seedsize]  __attribute__ ((aligned (16)));
	int dumvar2[seedsize] __attribute__ ((aligned (16)));
	int *cntblk  __attribute__ ((aligned (16)))= malloc(nblock*sizeof(int));
	int *blkpass __attribute__ ((aligned (16))) = malloc(nblock*sizeof(int));
//	int *dumvar  __attribute__ ((aligned (16)))= malloc(nblock*sizeof(int));
//	int *dumvar2 __attribute__ ((aligned (16))) = malloc(nblock*sizeof(int));
	
	int *lowblk  __attribute__ ((aligned (16)))= malloc(nblock*sizeof(int));
	int *uppblk __attribute__ ((aligned (16))) = malloc(nblock*sizeof(int));
	int *lowblk2  __attribute__ ((aligned (16)))= malloc(nblock*sizeof(int));
	int *uppblk2 __attribute__ ((aligned (16))) = malloc(nblock*sizeof(int));
	int threadread=nreads/2;
	int thdctr=0; 
	


	while(fscanf(fp_dir," %d",&dir[i])!=EOF){
		dirLen++;
		i++;
	}

//	for(int i=0; i <dirLen; i++)
//		*(tempdir+i)=*(dir+i);

	
	
//	i=0;
//	while(fscanf(fp_rank," %d",&rank[i])!=EOF){
//		i++;
//		ranksize++;
//	}
	i=0;
	

	while(fscanf(fp_pos," %d",&pos[i])!=EOF){
		i++;
		possize++;
	}

	fclose(fp_dir);
//	fclose(fp_rank);
	fclose(fp_pos);
	

	printf("number of read is: %d\n",nreads);	
	printf("readsize is: %d\n",readsize);
	printf("length is: %d\n",length);
	printf("blklen is: %d\n", lenblk);
	printf("nblks is: %d\n", nblock);
	printf("number of seeds is: %d\n", readsize-seedsize+1);
	
//	printf("Dir is: ");
//	for(i=0; i<dirLen;i++)
//	printf("%d ",dir[i]);
//	printf("\n");
//	
//	printf("Rank is: ");
//	for(i=0; i<ranksize;i++)
//	printf("%d ",rank[i]);
//	printf("\n");
//
//	printf("pos is: ");
//	for(i=0; i<possize;i++)
//	printf("%d ",pos[i]);
//	printf("\n");
//************************************************************




	int position=(readsize+2) *(nreads/2);
	
	//tid 0 is out 2 ;  tid 1 is out 1 
	if(tid==1)
		fseek(fp_read2,position,SEEK_SET);
	//for(thdctr=0; thdctr<1; thdctr++) {	
	for(thdctr=0; thdctr<nreads/2; thdctr++) {	//read through the reads
	
	if(tid==1)
		fgets(mainread,1000,fp_read2);
	else{
		fgets(mainread,1000,fp_read2);	
	}
//	strcpy(mainreadcpy, mainread);
	for(int i=0; i<nblock;i++){
		cntblk[i]=0;
		blkpass[i]=0;
	}
	
	z=0;
	//precheckblk(nblock,lenblk/2,seedsize,lowblk,uppblk);	
	//precheckblk2(nblock,lenblk/2,seedsize,lowblk2,uppblk2);	
	for	(z=0; z<readsize-seedsize+1; z++){	
		//printf("how many iterations:%d\n",readsize-seedsize+1);
				
		if(tid==1){
			movstring(seedsize,mainread,z,curread);
		}
		else{
			
			//	printf("STR1:%s\n",mainread);
			movstring2(seedsize,mainread,z,curread);
				//printf("STR1:%s\n",curread);
			//		exit(0);
		
		}
	
		if(tid==1)	{
			for(i=0; i<seedsize;i++)	
			dumvar[i]=0;
			avxprerank(seedsize,curread,dumvar);
			//printf("here?");
			crank=avxrank(dumvar,seedsize);
			//printf("rank is: %d\n",crank);
			indexofrank=crank;
			//indexofrank = getindex2(crank,possize,pos);
			//printf("index of rank is: %d\n",indexofrank);
			//exit(0);
		}
		else{
			for(i=0; i<seedsize;i++)	
			dumvar2[i]=0;	
			avxprerank2(seedsize,curread,dumvar2);
			//printf("here?");
			crank=avxrank2(dumvar2,seedsize);
			//printf("rank is: %d\n",crank);
			indexofrank=crank;
			//indexofrank = getindex2(crank,possize,pos);
			//printf("index of rank is: %d\n",indexofrank);
			//exit(0);
		
		}
		
	
		if(indexofrank==-1){
			printf("Seed is:%s\n",curread);		
			printf(",rank is: %d\n",crank);
			printf("Cannot find index of rank\n");
		}
		else{
			//printf("here!!!\n");
//			for(int i=0; i <dirLen; i++)
//				dir[i]=tempdir[i];	
			posindex = dir[indexofrank];//what index in pos table
			
			if(tid==1)	{
				instans = getinst(indexofrank,dirLen,dir);
				inst= dir[instans] -dir[indexofrank];
			}
			else{
				//crank == indexofrank
				//65535
				instans2 = getinst2(indexofrank,dirLen,dir);
				inst= dir[instans2] -dir[indexofrank];
//				if(crank==65535){
//					printf("index of rank: %d\n",dir[indexofrank]);	
//					printf("dir[inst ans: %d\n",dir[instans2]);	
//					printf("inst: %d\n",inst);
//					printf("inst: ans; %d\n",instans2);
//				}
				//exit(0);
			}
			
		

					if(tid==1){
						//inst=checkblk2(seedsize,readsize,inst,nblock,lenblk,posindex,cntblk,pos);
						if(instans!=-1)
							inst=checkblkavx(nblock,lowblk2,posindex,uppblk2,cntblk,inst,pos,readsize);
					}
					else{
						//inst=checkblkavx(nblock,lowblk2,posindex,uppblk2,cntblk,inst,pos,trail,bullshit,bullshit2);
						//printf("z: %d\n",z);
						//if(thdctr==94)
						//printf("!!!!inst: %d\n",inst);
						
						
						//rank== 65535
						if(instans2!=-1)
							inst=checkblkavx2(nblock,lowblk,posindex,uppblk,cntblk,inst,pos,readsize);
						//inst=checkblk1(seedsize,readsize,inst,nblock,lenblk,posindex,cntblk,pos);
						//printf("thdctr: %d\n",thdctr);
						//exit(0);
//						printf("curread:%s\n",curread);
//						printf("rank is:%d\n",crank);
//						printf("block[%d]:%d\n",19,cntblk[19]);
//						printf("block[%d]:%d\n",20,cntblk[20]);
						}
				
		}
	}
		
		for(i=0; i<nblock; i++)
			cntblk[i]=abs(cntblk[i]);
	k=0;
	thold =readsize -seedsize + 1 +k;
	



//	printf("blk[%d]=%d\n",1362,cntblk[1362]);
//		for(i=0; i<nblock-1; i=i+1)
//		if(cntblk[i]+cntblk[i+1]>=thold)
//			blkpass[i]=-1;

	
//	for(i=0; i<nblock; i++)
//			if(cntblk[i]>0)
//				printf("cntblk[%d],%d\n",i,cntblk[i]);
	if(tid==1)
		avxthres(thold,cntblk,blkpass,(nblock/8)+1);
	else
		avxthres2(thold,cntblk,blkpass,(nblock/8)+1);


	//	printf("Blck pass/fail:");
	//	for(i=0; i<nblock; i++)
	//		printf("%d ",blkpass[i]);
	//	printf("\n");

//	for(i=0; i<nblock; i++)
//		if(cntblk[i]>20)


//printf("blk[238]= %d:\n",cntblk[238]);
//printf("blk[239]= %d:\n",cntblk[239]);
			
	fprintf (fp_out, "%s:",mainread);

	 for(i = 0; i < nblock;i++){
	 	if(blkpass[i]==-1){
	       fprintf (fp_out, "%d ",i*(lenblk)/2);
	       }
	   }
	   
	fprintf (fp_out, "\n");	
	}

	fclose(fp_out);
	
	free(dumvar);
	free(dumvar2);
	free(pos);
	//free(rank);
	free(dir);
	//free(tempdir);
	free(lowblk);
	free(uppblk);
	free(lowblk2);
	free(uppblk2);
	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	printf("Tid[%d] Execution time: %lf\n",tid,time_spent);	
	//exit(0);
   pthread_exit(NULL);
}


int main()
{
   pthread_t threads[NUM_THREADS];
   int rc;
   long t;
   for(t=0;t<NUM_THREADS;t++){
     printf("In main: creating thread %ld\n", t);
     rc = pthread_create(&threads[t], NULL, filter, (void *)t);
     
	 if (rc){
       printf("ERROR; return code from pthread_create() is %d\n", rc);
       exit(-1);
       }
     }

   /* Last thing that main() should do */
   pthread_exit(NULL);
   return 0;
}
