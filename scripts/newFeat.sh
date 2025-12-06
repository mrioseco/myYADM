#!/bin/bash

# Helper para crear commits de nuevas features con formato estándar
# Uso: ./newFeat.sh o newfeat (si tienes el alias configurado)

yadm add . && yadm commit -m '[FEAT] ' -e && yadm push

