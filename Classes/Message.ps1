# Create a new Message object
$message = [Message]::new()

# Set the final formatted string
$message.SetFinalString("2024-11-12 12:34:56 [INFO] This is a log entry")

# Add variables used to create the FinalString
$message.AddVariable("Timestamp", "2024-11-12 12:34:56")
$message.AddVariable("LogLevel", "INFO")
$message.AddVariable("MessageText", "This is a log entry")

# Retrieve the final formatted string
$finalString = $message.GetFinalString()
Write-Output $finalString

# Retrieve the variables used
$variables = $message.GetVariables()
Write-Output "Variables used: $variables"

# Clear the message object
$message.Clear()
