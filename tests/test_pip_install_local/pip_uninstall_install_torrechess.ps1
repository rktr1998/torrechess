# Activate the virtual environment .venv
Write-Output "Activating the virtual environment .venv"
.venv\Scripts\Activate.ps1

# Uninstall the current version of torrechess
Write-Output "Uninstalling the current version of torrechess"
python -m pip uninstall torrechess -y

# Install the latest version of torrechess
Write-Output "Installing the latest version of torrechess"
python -m pip install ..\..\

# Deactivate the virtual environment
Write-Output "Deactivating the virtual environment .venv"
deactivate

# Keep the console open
Write-Output "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
