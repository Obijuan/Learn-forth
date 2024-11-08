#!/bin/sh
#-- Ejecutar el forth como interprete, incluyendo
#-- todas sus palabras del nucleo y de la extension
cat kernel-ext.fs $1 - | ./run_rars.sh kernel.s

