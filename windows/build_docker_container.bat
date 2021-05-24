cd %~dp0..
if not exist "%CD%\src\" mkdir %CD%\src\
if not exist "%CD%\libs\" mkdir %CD%\libs\
if not exist "%CD%\artifacts\" mkdir %CD%\artifacts\
if not exist "%CD%\other_mains\" mkdir %CD%\other_mains\
CALL docker build -t teensy_dev %CD%