#!/bin/bash

# Unbind the device
echo '0000:c4:00.4' > /sys/bus/pci/drivers/xhci_hcd/unbind

# Wait for the hardware to settle
sleep 5

# Bind the device back
echo '0000:c4:00.4' > /sys/bus/pci/drivers/xhci_hcd/bind

