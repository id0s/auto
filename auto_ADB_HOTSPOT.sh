#!/system/bin/sh
su -c setprop service.adb.tcp.port 5555
su -c adb kill-server
su -c adb start-server

# Wait for 100 seconds
sleep 100

# Start TetherSettings activity
su -c "am start -n com.android.settings/.TetherSettings"

# Wait for 2 seconds
sleep 2

# Simulate pressing the Enter key
su -c "input keyevent 66"
sleep 2

# Simulate pressing the Enter key again
su -c "input keyevent 66"
sleep 2

# Simulate pressing the Enter key again
su -c "input keyevent 66"
sleep 2

# Simulate pressing the Home key twice
su -c "input keyevent 3"
su -c "input keyevent 3"
