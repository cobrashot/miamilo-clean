#!/bin/bash
# Configuration
APP_NAME="miamilo-designs"
LOCAL_BASE_PATH="/Users/sp/Documents/02-Dev/miamilo-designs/src/images"

# Dynamically discover all directories in the images folder
echo "Discovering image categories..."
IMAGE_CATEGORIES=()
for dir in "$LOCAL_BASE_PATH"/*/; do
  if [ -d "$dir" ]; then
    category=$(basename "$dir")
    IMAGE_CATEGORIES+=("$category")
    echo "Found category: $category"
  fi
done

echo "Starting image upload to fly.io..."

# Create script file for SFTP commands
SFTP_COMMANDS="/tmp/sftp_commands.txt"
rm -f "$SFTP_COMMANDS"
touch "$SFTP_COMMANDS"

# Add commands to create directories
for category in "${IMAGE_CATEGORIES[@]}"; do
  echo "mkdir -p /var/www/images/$category" >> "$SFTP_COMMANDS"
done

# Add commands to upload files for each category
for category in "${IMAGE_CATEGORIES[@]}"; do
  echo "Preparing upload commands for $category..."
  
  # Get list of files in the category
  FILES=$(find "$LOCAL_BASE_PATH/$category" -type f -not -path "*/\.*")
  
  # Add commands to upload each file
  for file in $FILES; do
    filename=$(basename "$file")
    echo "cd /var/www/images/$category" >> "$SFTP_COMMANDS"
    echo "put $file" >> "$SFTP_COMMANDS"
    echo "File added to upload queue: $filename to $category"
  done
done

# Execute the SFTP batch file
echo "Executing SFTP batch upload..."
fly sftp shell -a "$APP_NAME" < "$SFTP_COMMANDS"

echo "Upload complete!"
echo "Your images should now be accessible at:"
echo "https://$APP_NAME.fly.dev/images/[category]/[filename]"

# Clean up
rm -f "$SFTP_COMMANDS"