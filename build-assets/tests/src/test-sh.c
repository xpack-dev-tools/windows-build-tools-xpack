/*
 * This file is part of the xPack distribution.
 *   (https://xpack.github.io)
 * Copyright (c) 2019 Liviu Ionescu.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 */

// ----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>

// ----------------------------------------------------------------------------

// Very simple sh-like program, used to test make.
// It behaves like `sh -c command args...`

char **split_argv(char *str);
int is_exe(char *str);
char *append_exe(char *str);

int main(int argc, char *argv[], char *envp[])
{
  char **p;
  int i;

  printf("sh_start\n");

  for (i = 0, p = envp; *p; p++, i++)
  {
    printf("sh_env[%d]='%s'\n", i, *p);
  }

  for (i = 0, p = argv; *p; p++, i++)
  {
    printf("sh_argv[%d]='%s'\n", i, *p);
  }

  if (argc < 2 || strcmp(argv[1], "-c") != 0)
  {
    fprintf(stderr, "usage: sh -c command [opts...]\n");
    exit(1);
  }

  char **sub_argv = split_argv(argv[2]);
  char *command = is_exe(sub_argv[0]) ? sub_argv[0] : append_exe(sub_argv[0]);

  printf("sh_spawn '%s'...\n", command);

  int ret;
  errno = 0;
#if defined(__USE_NULL_ENVP)
  ret = _spawnvpe(0, command, sub_argv, NULL);
#else
  ret = _spawnvpe(0, command, sub_argv, envp);
#endif

  printf("sh_ret=%d errno=%d\n", ret, errno);

  // Don't bother to free.
  return ret;
}

int is_exe(char *str)
{
  const char *exe = ".exe";
  if (strlen(str) >= strlen(exe))
  {
    if (strcmp(str + strlen(str) - strlen(exe), exe) == 0)
    {
      return 1; // Found it!
    }
  }
  return 0;
}

char *
append_exe(char *str)
{
  const char *exe = ".exe";
  char *new_str = (char *)malloc(strlen(str) + strlen(exe) + 1);
  strcpy(new_str, str);
  strcat(new_str, exe);

  return new_str;
}

// Split a string into space separated substrings.
char **
split_argv(char *str)
{
  char **argv = (char **)malloc(sizeof(char *) * 10000); // Big enough.
  char **pa = argv;

  // Make a writable copy, spaces are replaced by '\0'.
  char *p = _strdup(str);

  while (*p != '\0')
  {
    // Turn all spaces into string terminators.
    if (*p == ' ')
    {
      *p++ = '\0';
      continue;
    }

    // First non-space, remember position.
    *pa++ = p;
    // Skip all next non-spaces.
    while (*p && *p != ' ')
    {
      ++p;
    }
  }
  // Add the array terminator as a NULL Pointer.
  *pa = NULL;

  return argv;
}

// ----------------------------------------------------------------------------
