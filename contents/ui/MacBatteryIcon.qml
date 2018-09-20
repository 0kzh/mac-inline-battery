import QtQuick 2.0

Item {
	id: batteryIcon
	property bool charging: false
	property int charge: 0
	property color normalColor: theme.textColor
	property color chargingColor: "#1e1"
	property color lowBatteryColor: "#e33"
	property int lowBatteryPercent: 20

	Rectangle {
		// Outline
		id: container
		anchors.fill: parent
		anchors.rightMargin: 2
		color: "transparent"
		border.color: normalColor
		radius: 2

		Item {
			anchors.fill: parent
			anchors.margins: 2

			Rectangle {
				// Charged % Fill
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				color: {
					if (charging) {
						return chargingColor
					} else if (charge < lowBatteryPercent) {
						return lowBatteryColor
					} else {
						return normalColor
					}
				}
				width: parent.width * Math.max(0, Math.min(charge, 100)) / 100
			}
		}
	}
	Rectangle {
		// Bump
		anchors.left: container.right
		anchors.leftMargin: 1
		anchors.verticalCenter: parent.verticalCenter
		radius: 2
		height: parent.height / 3
		width: 2
		color: normalColor
	}
}
