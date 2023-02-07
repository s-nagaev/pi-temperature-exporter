#!/bin/bash

GITHUB_REPO="https://github.com/s-nagaev/pi-temperature-exporter"
LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' ${GITHUB_REPO}/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
BIN_ARCH_FILE_NAME="pi-temp-exporter_${LATEST_VERSION}_armv7.tar.gz"
BIN_ARCH_FILE_URL="${GITHUB_REPO}/releases/download/${LATEST_VERSION}/${BIN_ARCH_FILE_NAME}"
BIN_FILE_NAME="pi-temp-exporter"
SERVICE_FILE_NAME="temp-exporter.service"
SERVICE_FILE_URL="https://raw.githubusercontent.com/s-nagaev/pi-temperature-exporter/${LATEST_VERSION}/systemd/${SERVICE_FILE_NAME}"
INSTALL_DIR="/usr/local/bin"

# Download the archive with the binary
curl -L -s -o ${BIN_ARCH_FILE_NAME} ${BIN_ARCH_FILE_URL}
if [ $? -ne 0 ]; then
	echo "Error downloading the archive with the binary"
	exit 1
fi

# Unpack the archive to the $HOME/.local/bin directory
tar xvfz ${BIN_ARCH_FILE_NAME} -C "$HOME"
sudo install -Dm 755 ${BIN_FILE_NAME} -t ${INSTALL_DIR}
if [ $? -ne 0 ]; then
	echo "Error installing the binary file"
	exit 1
fi
rm $HOME/${BIN_FILE_NAME}
rm ${BIN_ARCH_FILE_NAME}

# Download the service file
curl -L -s -o ${SERVICE_FILE_NAME} ${SERVICE_FILE_URL}
if [ $? -ne 0 ]; then
	echo "Error downloading the service file"
	exit 1
fi

# Save the service file with sudo permissions
sudo mv ${SERVICE_FILE_NAME} /lib/systemd/system/
if [ $? -ne 0 ]; then
	echo "Error saving the service file"
	exit 1
fi

# Reload the system daemon
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable ${SERVICE_FILE_NAME}
if [ $? -ne 0 ]; then
	echo "Error enabling the service ${SERVICE_FILE_NAME}"
	exit 1
fi

# Restart the service
sudo systemctl restart ${SERVICE_FILE_NAME}
if [ $? -ne 0 ]; then
	echo "Error restarting the service ${SERVICE_FILE_NAME}"
	exit 1
fi

echo "Pi Temperature Exporter service has been successfully installed!"
