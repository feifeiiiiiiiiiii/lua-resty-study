#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include "leveldb/db.h"
#include "leveldb/cache.h"

#ifdef __cplusplus
# define EXTERNC extern "C"
#else
# define EXTERNC
#endif

EXTERNC int add(int a, int b)
{
	leveldb::Options options;
  options.create_if_missing = true;
  return a + b;
}

EXTERNC const char* now_iso8601_utc()
{
  const size_t size = 21;
  char *buffer = (char*) malloc(sizeof(char)*size);

  const time_t t = time(NULL);
  if (!strftime(buffer, size, "%FT%TZ", gmtime(&t))) {
    buffer[0] = '\0';
  }

  return buffer;
}
