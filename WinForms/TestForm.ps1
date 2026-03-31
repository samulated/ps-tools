# Boilerplate WinForm

Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Test Form"
$form.Size = New-Object System.Drawing.Size(400, 600)
$form.StartPosition = "CenterScreen"

$checkBox = New-Object System.Windows.Forms.CheckBox
$checkBox.Text = "Enable Feature"
$checkBox.Location = New-Object System.Drawing.Point(70, 30)
$checkBox.Enabled = $false

# Add Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Click Me"
$button.Location = New-Object System.Drawing.Point(100, 100)
$button.Size = New-Object System.Drawing.Size(75, 23)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Test label status..."

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Location = New-Object System.Drawing.Point($form.Left, ($form.Bottom - 30))
$statusStrip.Size = New-Object System.Drawing.Point($form.Size.Width, 30)
$statusStrip.Text = "Test status..."

$statusStrip.Items.Add($statusLabel)

# Define the button click action
$button.Add_Click({
    if ($checkBox.Checked) {
        [System.Windows.Forms.MessageBox]::Show("Hello, World! (Premium)")
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Hello, World!")
    }
    
})

$form.Controls.Add($checkBox)

$form.Controls.Add($statusStrip)

# Add the button to the form controls
$form.Controls.Add($button)

# Display the form
$form.ShowDialog()
