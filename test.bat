@echo off
for /D %%i in (*) do (
    cd "%%i"
    jai test.jai
    cd ..
)
