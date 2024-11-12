class Logger {
    [LogFile]$LogFile
    [string]$LogLevel = "Info"
    [LogFormat]$LogFormat

    # Constructor to initialize the Logger with a LogFile object
    Logger([LogFile]$logFile) {
        $this.Set-LogFile($logFile)
    }

    # Method to set or update the LogFile object and its associated LogFormat
    [void]Set-LogFile([LogFile]$newLogFile) {
        if (-not $newLogFile) {
            throw "Invalid LogFile object provided."
        }
        $this.LogFile = $newLogFile
        $this.LogFormat = $newLogFile.LogFormat
    }

    # Method to set the logging level
    [void]SetLogLevel([string]$level) {
        if ($level -notin @("DEBUG", "INFO", "WARNING", "ERROR")) {
            throw "Invalid LogLevel. Valid levels are DEBUG, INFO, WARNING, ERROR."
        }
        $this.LogLevel = $level
    }

    # Main logging method with optional parameters for one-time overrides
    [void]Write2Log([string]$message, [string]$level = $null, [LogFormat]$logFormatOverride = $null, [LogFile]$logFileOverride = $null) {
        # Step 1: Check if a logFileOverride is provided
        if ($logFileOverride) {
            $this.Set-LogFile($logFileOverride)
        }

        # Step 2: Determine the effective LogLevel
        $effectiveLogLevel = if ($level) { $level } elseif ($this.LogLevel) { $this.LogLevel } else { "Info" }

        # Step 3: Determine the effective LogFormat
        $effectiveLogFormat = if ($logFormatOverride) { $logFormatOverride } elseif ($this.LogFormat) { $this.LogFormat } else {
            # Fallback default format
            $defaultFormat = [LogFormat]::new()
            $defaultFormat.SetMessageFormat("{Timestamp} [Info] {Message}")
            $defaultFormat
        }

        # Step 4: Check if the message level meets the Logger's LogLevel
        $validLevels = @("DEBUG", "INFO", "WARNING", "ERROR")
        if ($validLevels.IndexOf($effectiveLogLevel.ToUpper()) -lt $validLevels.IndexOf($this.LogLevel.ToUpper())) {
            return  # Do not log if the effective level is lower than the Logger's level
        }

        # Step 5: Format the message using the effective LogFormat
        $formattedMessage = $effectiveLogFormat.FormatEntry($effectiveLogLevel, $message)

        # Step 6: Write the formatted message to the LogFile
        $this.LogFile.NoteToSelf($formattedMessage)

        # Step 7: Update the LogFile's EditedOn timestamp
        $this.LogFile.EditedOn = [datetime]::Now
    }

    # Method to flush any buffered entries (placeholder, if buffering is implemented later)
    [void]Flush() {
        # Currently, no buffering is implemented, so this method does nothing.
    }

    # Method to close the Logger and set the LogFile to read-only if necessary
    [void]Close() {
        $this.Flush()
        if (-not $this.LogFile.ReadOnly) {
            $this.LogFile.SetReadOnly()
        }
    }
}
