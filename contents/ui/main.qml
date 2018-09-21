import QtQuick 2.1
import QtQuick.Layouts 1.3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponent
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
	id: widget

	AppletConfig { id: config }

	// https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.h
	// https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.cpp
	PlasmaCore.DataSource {
		id: pmSource
		engine: "powermanagement"
		connectedSources: sources
		onSourceAdded: {
			// console.log('onSourceAdded', source)
			disconnectSource(source)
			connectSource(source)
		}
		onSourceRemoved: {
			disconnectSource(source)
		}

		function log() {
			for (var i = 0; i < pmSource.sources.length; i++) {
				var sourceName = pmSource.sources[i]
				var source = pmSource.data[sourceName]
				for (var key in source) {
					console.log('pmSource.data["'+sourceName+'"]["'+key+'"] =', source[key])
				}
			}
		}
	}

	function getData(sourceName, key, def) {
		var source = pmSource.data[sourceName]
		if (typeof source === 'undefined') {
			return def;
		} else {
			var value = source[key]
			if (typeof value === 'undefined') {
				return def;
			} else {
				return value;
			}
		}
	}

	property string currentBatteryName: 'Battery'
	property string currentBatteryState: getData(currentBatteryName, 'State', false)
	property int currentBatteryPercent: getData(currentBatteryName, 'Percent', 100)
	property bool currentBatteryLowPower: currentBatteryPercent <= config.lowBatteryPercent
	property color currentTextColor: {
		if (currentBatteryLowPower) {
			return config.lowBatteryColor
		} else {
			return config.normalColor
		}
	}

	Plasmoid.compactRepresentation: Item {
		id: panelItem

		Layout.minimumWidth: gridLayout.implicitWidth
		Layout.preferredWidth: gridLayout.implicitWidth

		Layout.minimumHeight: gridLayout.implicitHeight
		Layout.preferredHeight: gridLayout.implicitHeight

		// property int textHeight: Math.max(6, Math.min(panelItem.height, 16 * units.devicePixelRatio))
		property int textHeight: 12 * units.devicePixelRatio
		// onTextHeightChanged: console.log('textHeight', textHeight)

		GridLayout {
			id: gridLayout
			anchors.fill: parent

			// The rect around the Text items in the vertical layout should provide 2 pixels above
			// and below. Adding extra space will make the space between the percentage and time left
			// labels look bigger than the space between the icon and the percentage.
			// So for vertical layouts, we'll add the spacing to just the icon.
			property int spacing: 4 * units.devicePixelRatio
			columnSpacing: spacing
			rowSpacing: 0

			PlasmaComponent.Label {
				id: percentTextLeft
				visible: plasmoid.configuration.showPercentage && !!plasmoid.configuration.alignLeft
				anchors.right: batteryIconContainer.left
				anchors.rightMargin: config.padding
				text: {
					if (currentBatteryPercent > 0) {
						return '' + currentBatteryPercent + '%'
					} else {
						return '100%';
					}
				}
				font.pixelSize: config.fontSize
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: currentTextColor
			}

			Item {
				id: batteryIconContainer
				visible: plasmoid.configuration.showBatteryIcon
				width: config.iconWidth * units.devicePixelRatio
				height: config.iconHeight * units.devicePixelRatio
				anchors.verticalCenter: parent.verticalCenter

				MacBatteryIcon {
					id: batteryIcon
					width: Math.min(parent.width, config.iconWidth * units.devicePixelRatio)
					height: Math.min(parent.height, config.iconHeight * units.devicePixelRatio)
					anchors.centerIn: parent
					charging: currentBatteryState == "Charging"
					charge: currentBatteryPercent
					normalColor: config.normalColor
					chargingColor: config.chargingColor
					lowBatteryColor: config.lowBatteryColor
					lowBatteryPercent: plasmoid.configuration.lowBatteryPercent
				}
			}

			PlasmaComponent.Label {
				id: percentTextRight
				visible: plasmoid.configuration.showPercentage && !plasmoid.configuration.alignLeft
				anchors.left: batteryIconContainer.right
				anchors.leftMargin: config.padding
				text: {
					if (currentBatteryPercent > 0) {
						return '' + currentBatteryPercent + '%'
					} else {
						return '100%';
					}
				}
				font.pixelSize: config.fontSize
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: currentTextColor
			}
		}
	}
}
