#!/bin/bash
# CPU Windows
powershell.exe -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage" 2>/dev/null | tr -d '\r'
