#!/bin/sh

petcat $1 | cut -d " " -f 2- 
