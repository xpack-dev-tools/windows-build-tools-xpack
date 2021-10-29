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

// extern char **environ;

// ----------------------------------------------------------------------------

// Print all environment variables.

int main(int argc, char *argv[], char *envp[])
{
  char **p;
  int i;

  for (i = 0, p = envp; *p; p++, i++)
  {
    printf("envp[%d]='%s'\n", i, *p);
  }

  for (i = 0, p = argv; *p; p++, i++)
  {
    printf("argv[%d]='%s'\n", i, *p);
  }

  return 0;
}

// ----------------------------------------------------------------------------
