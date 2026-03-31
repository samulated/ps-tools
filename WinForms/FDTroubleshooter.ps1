Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Doctor Fam - The Samily Doctor"
$form.Size = New-Object System.Drawing.Size(700, 800)
$form.StartPosition = "CenterScreen"

$iconPath = "FD.ico"
if (Test-Path $iconPath) {
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}


$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$tabControl.Alignment = [System.Windows.Forms.TabAlignment]::Left
$tabControl.SizeMode = [System.Windows.Forms.TabSizeMode]::Fixed
$tabControl.DrawMode = [System.Windows.Forms.TabDrawMode]::OwnerDrawFixed
$tabControl.ItemSize = New-Object System.Drawing.Point(60, 150)

# Page 1 - Welcome
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Welcome"

$welcomeTitle = New-Object System.Windows.Forms.Label
$welcomeTitle.Text = "Foreword"
$welcomeTitle.Font = New-Object System.Drawing.Font($welcomeTitle.Font, ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline))
$welcomeTitle.Location = New-Object System.Drawing.Point(($form.Width / 2 - 44), ($tabControl.Top + 6))

$welcomeText = New-Object System.Windows.Forms.Label
$welcomeText.Text = " This is a label that can be used to to display a bunch of text on your form, usually used to provide context to controls (such as what a particular text box or checkbox is for) although right now I'm using it in a more generally descriptive way.

 If there are any other ideas on how someone may utilise this feature, I'd certainly love to hear it!"
$welcomeText.Location = New-Object System.Drawing.Point(($form.Left), ($tabControl.Top + 28))
$welcomeText.Size = New-Object System.Drawing.Point(($form.Width - 20), 100)

$welcomeSignature = New-Object System.Windows.Forms.Label
$welcomeSignature.Text = "- Samuel Fawcett"
$welcomeSignature.Font = New-Object System.Drawing.Font($welcomeTitle.Font, [System.Drawing.FontStyle]::Italic)
$welcomeSignature.Location = New-Object System.Drawing.Point(($form.Right - 120), ($tabControl.Top + 134))

$tabPage1.Controls.Add($welcomeTitle)
$tabPage1.Controls.Add($welcomeText)
$tabPage1.Controls.Add($welcomeSignature)


# Page 2 - Tools
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Tools"

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$progressBar.Minimum = 0
$progressBar.Maximum = 10
$progressBar.Value = 0
$progressBar.Step = 1
$progressBar.Location = New-Object System.Drawing.Point(($form.Left), ($tabPage2.Top + 12))
$progressBar.Size = New-Object System.Drawing.Point(($form.Width - 23), 20)

$progressButton = New-Object System.Windows.Forms.Button
$progressButton.Text = "Step"
$progressButton.Location = New-Object System.Drawing.Point(($form.Right - 100), ($tabControl.Top + 40))

$tabPage2.Controls.Add($progressBar)
$tabPage2.Controls.Add($progressButton)

# Page 3 - Settings
$tabPage3 = New-Object System.Windows.Forms.TabPage
$tabPage3.Text = "Settings"



# Interactivity
$progressButton.Add_Click({
    $progressBar.PerformStep()
    $s = $progressBar.Value
    $m = $progressBar.Maximum
    if ($s -eq $m)
    {
        $progressButton.Enabled = $false
    }
})

# Add tab pages to Tab Control
$tabControl.Controls.Add($tabPage1)
$tabControl.Controls.Add($tabPage2)
$tabControl.Controls.Add($tabPage3)

# Add Tab Control to Form
$form.Controls.Add($tabControl)

# Display the form
$form.ShowDialog()