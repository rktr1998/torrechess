# Remove existing .venv folder
Write-Output "Removing existing .venv folder"
Remove-Item -Path .venv -Recurse -Force -ErrorAction SilentlyContinue

# Create new virtual environment
Write-Output "Creating new .venv environment"
python -m venv .venv

# Activate virtual environment
Write-Output "Activating .venv environment"
.venv\Scripts\Activate.ps1

# Install required packages
Write-Output "Installing pip package from ..\..\ (torrechess)"
python -m pip install ..\..\

# Deactivate virtual environment
Write-Output "Deactivating .venv environment"
deactivate

# Keep the console open
Write-Output "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
