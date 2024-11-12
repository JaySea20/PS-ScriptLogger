class LogFile {
    [string]$FileName
    [string]$FileExt = ".log"
    [string]$FilePath = "C:\Logs"
    [string]$FQDN
    [LogFormat]$LogFormat
    [datetime]$CreatedOn = [datetime]::Now
    [datetime]$EditedOn
    [string]$Status = "Active"  # Possible values: Active, Archive, Trash
    [bool]$ReadOnly = $false
    [string]$Owner

    # Constructor to initialize LogFile with path, name, and format
    LogFile([string]$filePath, [string]$fileName, [LogFormat]$logFormat) {
        $this.Set-FilePath($filePath)
        $this.Set-FileName($fileName)
        $this.LogFormat = $logFormat
        $this.FQDN = Join-Path -Path $this.FilePath -ChildPath "$this.FileName$this.FileExt"
        $this.CreatedOn = [datetime]::Now
        $this.EditedOn = $this.CreatedOn
        $this.Owner = [System.Environment]::UserName
    }

    # Method to update the file name
    [void]Set-FileName([string]$newFileName) {
        $this.FileName = $newFileName
        $this.FQDN = Join-Path -Path $this.FilePath -ChildPath "$this.FileName$this.FileExt"
    }

    # Method to update the file path
    [void]Set-FilePath([string]$newFilePath) {
        $this.FilePath = $newFilePath
        $this.FQDN = Join-Path -Path $this.FilePath -ChildPath "$this.FileName$this.FileExt"
    }

    # Method to update the file extension
    [void]Set-FileType([string]$fileExt) {
        if ($fileExt -notin @(".log", ".csv")) {
            throw "Invalid file extension. Allowed extensions are .log and .csv."
        }
        $this.FileExt = $fileExt
        $this.FQDN = Join-Path -Path $this.FilePath -ChildPath "$this.FileName$this.FileExt"
    }

    # Method to check if the log file exists
    [bool]FileExists() {
        return Test-Path -Path $this.FQDN
    }

    # Method to write an entry to the log file
    [void]NoteToSelf([string]$entry) {
        if ($this.Status -ne "Active" -or $this.ReadOnly) {
            throw "Cannot write to a non-active or read-only log file."
        }
        Add-Content -Path $this.FQDN -Value $entry
        $this.EditedOn = [datetime]::Now
    }

    # Method to rotate (cascade) log files by versioning
    [void]CascadeFiles() {
        $version = 1
        while (Test-Path -Path ($this.FQDN -replace ".log", "_v$version.log")) {
            $version++
        }
        Rename-Item -Path $this.FQDN -NewName ($this.FQDN -replace ".log", "_v$version.log")
    }

    # Method to trash the log file (move to trash or delete)
    [void]TrashFile() {
        if ($this.FileExists()) {
            Remove-Item -Path $this.FQDN -Force
            $this.Status = "Trash"
        }
    }

    # Method to set the log file as read-only
    [void]SetReadOnly() {
        if ($this.FileExists()) {
            Set-ItemProperty -Path $this.FQDN -Name IsReadOnly -Value $true
            $this.ReadOnly = $true
        }
    }

    # Method to update the owner attribute
    [void]UpdateOwner([string]$newOwner) {
        $this.Owner = $newOwner
    }

    # Method to check for errors in file configuration
    [string[]]CheckForErrors() {
        $errors = @()
        if (-not $this.FileName) {
            $errors += "FileName is not set."
        }
        if (-not $this.FilePath) {
            $errors += "FilePath is not set."
        }
        if (-not (Test-Path -Path $this.FilePath)) {
            $errors += "FilePath does not exist."
        }
        return $errors
    }
}
