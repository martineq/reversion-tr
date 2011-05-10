#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <unistd.h>
#include <stdlib.h>
#include "tr.h"

static void usage(void);

int
main(argc, argv)
	int argc;
	char **argv;
{
	int ch, dflag, sflag, isset2;

	dflag = sflag = 0;
	while ((ch = getopt(argc, argv, "ds")) != -1)
		switch((char)ch) {
		case 'd':
			dflag = 1;
			break;
		case 's':
			sflag = 1;
			break;
		case '?':
		default:
			usage();
		}
	argc -= optind;
	argv += optind;

	switch(argc) {
	case 0:
	default:
		usage();
		/* NOTREACHED */
	case 1:
		isset2 = 0;
		break;
	case 2:
		isset2 = 1;
		break;
	}


	if (dflag && sflag) {
		if (!isset2) usage();
		tr_ds(argv[0], argv[1]);
	}
	else if (dflag) {
		if (isset2) usage();
		tr_d(argv[0]);
	}
	else if (sflag && !isset2) {
		tr_s1(argv[0]);
	}
	else if (sflag && isset2) {
		tr_s2(argv[0], argv[1]);
	}
	else if (isset2) {
		tr(argv[0], argv[1]);
	}
	else {
		assert(0);
	}
	
	exit(0);

}

static void
usage()
{
	(void)fprintf(stderr, "usage: tr [-s] string1 string2\n");
	(void)fprintf(stderr, "       tr -d string1\n");
	(void)fprintf(stderr, "       tr -s string1\n");
	(void)fprintf(stderr, "       tr -ds string1 string2\n");
	exit(1);
}

