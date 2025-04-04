# Setting Up a Pixel 6 Emulator for Flutter Development

This guide will walk you through setting up a Pixel 6 emulator using Android Studio, which you can then use with the VS Code launch configuration.

## Steps to Create a Pixel 6 Emulator

1. **Open Android Studio**

2. **Access the AVD Manager**:
   - Click on "More Actions" (three dots or gear icon) in the welcome screen
   - Select "Virtual Device Manager" or "AVD Manager"
   - Alternatively, if a project is already open, go to Tools > Device Manager

3. **Create a New Virtual Device**:
   - Click on "+ Create Device" button 
   - Select "Phone" category
   - Scroll down and select "Pixel 6" from the list
   - Click "Next"

4. **Select a System Image**:
   - Choose a system image (recommended: Android 13 - API Level 33 or higher)
   - If the system image isn't downloaded yet, click the "Download" link next to it
   - After download completes, select it and click "Next"

5. **Configure the AVD**:
   - Keep the default name (typically "Pixel 6 API XX") or change it as needed
   - Ensure "Startup orientation" is set to "Portrait"
   - Under "Emulated Performance", select "Hardware - GLES 2.0" for best performance
   - Click "Finish"

6. **Use with VS Code**:
   - Your emulator is now ready to use with VS Code's launch configuration
   - Launch the emulator either from Android Studio or using `flutter emulators --launch Pixel_6` (replace "Pixel_6" with your exact emulator name if different)
   - Use the "sahtech (Pixel 6)" launch configuration in VS Code to run the app

## Important Notes

- Ensure your launch.json's `deviceId` matches the name of your emulator (it's case-sensitive)
- The current configuration uses "Pixel_6" as the deviceId, which should match most default Pixel 6 emulator names
- If your emulator has a different name, please update the "deviceId" field in .vscode/launch.json accordingly
- You may need to run the emulator before launching from VS Code

## Troubleshooting

If the app doesn't launch on your Pixel 6 emulator:

1. Check if the emulator is running first
2. Verify the exact name of your emulator using `flutter devices` command
3. Update the deviceId in launch.json to match the exact name shown 