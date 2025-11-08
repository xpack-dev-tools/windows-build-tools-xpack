/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2019 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit.
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
