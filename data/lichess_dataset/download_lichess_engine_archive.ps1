$URL = "https://database.lichess.org/lichess_db_eval.jsonl.zst"
$PATH = "lichess_db_eval.jsonl.zst"

Start-BitsTransfer -Source $URL -Destination $PATH

# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
