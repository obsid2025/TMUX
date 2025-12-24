#!/bin/bash
# RAM Windows
powershell.exe -Command "\$os = Get-CimInstance Win32_OperatingSystem; [math]::Round(100 - (\$os.FreePhysicalMemory / \$os.TotalVisibleMemorySize) * 100, 1)" 2>/dev/null | tr -d '\r'
