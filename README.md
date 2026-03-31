# PS Tools
This is a repo for different Powershell tools I've put together. Ideally, I shoud be able to chunk up some common functions to reuse easily. Otherwise this will be some stuff that does some pretty specific things.

## Current Focus
Currently focusing on implementing side-aligned tabs with horizontal label text, using the [Microsoft C# example](https://learn.microsoft.com/en-us/dotnet/desktop/winforms/controls/how-to-display-side-aligned-tabs-with-tabcontrol) as a base. Mostly because it looks super cool, and it's more visually pleasing that the default top-aligned tabs.

Would like to use this to create a multi-tool app for various checks and automations at work.

Potentially want to look into a form builder helper too. A lot of my values are hand-coded when they don't need to be right now.

## Script List
### Best Practice - Standard Troubleshooting
This automates the standard troubleshooting steps sent out by Best Practice to resolve issues, which mostly involves updating the security settings of a bunch of different folders.

The steps are rather time consuming, so I'm automating as much as I can, wrapping it up in a friendly WinForms UI, and then generating automatic notes to be pasted into the response email to them.

### WinForms Tests
Testing out making WinForms apps in certain configurations.

Can use for quick prototyping of WinForms apps in future.