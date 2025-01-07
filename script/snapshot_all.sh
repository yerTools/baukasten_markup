#!/bin/bash

while true
do
    if gleam test; then
        break
    else
        gleam run -m birdie
    fi
done