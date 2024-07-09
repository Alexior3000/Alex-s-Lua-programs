@echo off
title Gra-w-terminalu
color 0e
echo O to jest ta gra!
setlocal enabledelayedexpansion

rem Definicja mapy jako osobne linie
set "mapa[0]=#########"
set "mapa[1]=#P  #   #"
set "mapa[2]=# ## ## #"
set "mapa[3]=#    #  #"
set "mapa[4]=### #####"
set "mapa[5]=#      ##"
set "mapa[6]=## #### #"
set "mapa[7]=#      ##"
set "mapa[8]=# ####  E"
set "mapa[9]=#########"

rem Inicjalizacja pozycji gracza
set gx=1
set gy=1

rem Inicjalizacja przeciwnikow
set ex1=3
set ey1=3
set ex2=6
set ey2=4

:draw_map
cls
for /l %%y in (0,1,9) do (
    set "line=!mapa[%%y]!"
    set "output_line="
    for /l %%x in (0,1,8) do (
        set "char=!line:~%%x,1!"
        if %%x==%gx% if %%y==%gy% (
            set "char=P"
        ) else if %%x==%ex1% if %%y==%ey1% (
            set "char=Z"
        ) else if %%x==%ex2% if %%y==%ey2% (
            set "char=Z"
        )
        set "output_line=!output_line!!char!"
    )
    echo(!output_line!
)
echo Use W A S D to move
set "direction="
set /p "direction=>"
goto process_input

:process_input
set "dx=0"
set "dy=0"
if /i "%direction%"=="W" set "dy=-1"
if /i "%direction%"=="A" set "dx=-1"
if /i "%direction%"=="S" set "dy=1"
if /i "%direction%"=="D" set "dx=1"

set /a nx=gx+dx
set /a ny=gy+dy

if %ny% geq 0 if %ny% lss 10 if %nx% geq 0 if %nx% lss 9 (
    set "line=!mapa[%ny%]!"
    if "!line:~%nx%,1!"==" " (
        set gx=%nx%
        set gy=%ny%
    ) else if "!line:~%nx%,1!"=="E" (
        cls
        echo Gratulacje! Dotarles do wyjscia.
        goto end_game
    )
)

goto draw_map

:end_game
echo Koniec gry!
pause
