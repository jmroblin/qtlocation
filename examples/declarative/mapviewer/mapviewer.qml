/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import Qt.location 5.0
import "common" as Common

FocusScope {
    anchors.fill: parent
    id: page
    focus: true

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "darkgrey"
        z:2
    }

    Common.TitleBar {
        id: titleBar; z: mainMenu.z; width: parent.width; height: 40; opacity: 0.9; text: "QML mapviewer example"
        onClicked: { Qt.quit() }
    }

//=====================Menus=====================
    Common.Menu {
        id: mainMenu
        itemHeight: 40
        itemWidth: page.width / count
        anchors.bottom: parent.bottom
        orientation: ListView.Horizontal
        z: map.z + 3
        Component.onCompleted: {
            setModel(["Options","Settings"])
        }
        onClicked: {
            switch (button) {
                case 0: {
                    page.state = "Options"
                    break;
                }
                case 1: {
                    page.state = "Settings"
                    break;
                }
            }
        }
    }

    Common.Menu {
        id: optionsMenu
        orientation: ListView.Vertical
        z: mainMenu.z - 1
        Component.onCompleted: {
            setModel(["Reverse geocode", "Geocode","Search", "Route"])
            disableItem(2)
        }
        itemHeight: 30;
        itemWidth: mainMenu.itemWidth
        anchors.left: mainMenu.left
        y: page.height

        onClicked: {
            switch (button) {
                case 0: {
                    page.state = "RevGeocode"
                    break;
                }
                case 1: {
                    page.state = "Geocode"
                    break;
                }
                case 2: {
                    page.state = "Search"
                    break;
                }
                case 3: {
                    page.state = "Route"
                    break;
                }
            }
        }
    }

    Common.Menu {
        id: settingsMenu
        orientation: ListView.Vertical
        z: mainMenu.z - 1
        Component.onCompleted: {
            setModel([ settingsMenu.nestedMenuSign + " Map type", settingsMenu.nestedMenuSign + " Connectivity", "  Provider"])
        }

        itemHeight: 30;
        itemWidth: mainMenu.itemWidth
        y: page.height
        anchors.right: mainMenu.right

        onClicked: {
            switch (button) {
                case 0: {
                    page.state = "MapType"
                    break;
                }
                case 1: {
                    page.state = "Connectivity"
                    break;
                }
                case 2: {
                    messageDialog.state = "Provider"
                    page.state = "Message"
                    break;
                }
            }
        }
    }

    Common.Menu {
        id: mapTypeMenu
        orientation: ListView.Vertical
        z: mainMenu.z - 1
        keepPreviousValue: true
        opacity: 0

        itemHeight: 30;
        itemWidth: mainMenu.itemWidth*2/3
        anchors.bottom: mainMenu.top
        anchors.right: settingsMenu.left

        Component.onCompleted: {
            setModel(["Street", "Satellite", "Satellite Night", "Terrain"])
            disableItem(2) // Nokia map engine supports only Street, Satellite and Terrain map types
            button = 0 // Nokia plugin's default map type is Map.StreetMap
        }

        onClicked: {
            page.state = ""
        }

        onButtonChanged: {
            switch (button) {
                case 0: {
                    map.mapType = Map.StreetMap
                    break;
                }
                case 1: {
                    map.mapType = Map.SatelliteMapDay
                    break;
                }
                case 2: {
                    map.mapType = Map.SatelliteMapNight
                    break;
                }
                case 3: {
                    map.mapType = Map.TerrainMap
                    break;
                }
            }
        }
    }

    Common.Menu {
        id: connectivityModeMenu
        orientation: ListView.Vertical
        z: mainMenu.z - 1
        keepPreviousValue: true
        opacity: 0

        itemHeight: 30;
        itemWidth: mainMenu.itemWidth/2
        anchors.bottom: mainMenu.top
        anchors.right: settingsMenu.left

        Component.onCompleted: {
            setModel(["Offline", "Online", "Hybrid"])
            disableItem(0) // Nokia map engine supports online mode
            disableItem(2)
            button = 1
        }

        onClicked: {
            page.state = ""
        }

        onButtonChanged: {
            switch (button) {
                case 0: {
                    map.connectivityMode = Map.OfflineMode
                    break;
                }
                case 1: {
                    map.connectivityMode = Map.OnlineMode
                    break;
                }
                case 2: {
                    map.connectivityMode = Map.HybridMode
                    break;
                }
            }
        }
    }

//=====================Dialogs=====================
    Message {
        id: messageDialog
        z: mainMenu.z + 1
        onOkButtonClicked: {
            page.state = ""
        }
        onCancelButtonClicked: {
            page.state = ""
        }

        states: [
            State{
                name: "Provider"
                PropertyChanges { target: messageDialog; title: "Provider" }
                PropertyChanges { target: messageDialog; text: "Nokia OVI <a href=\http://doc.qt.nokia.com/qtmobility-1.2/location-overview.html#the-nokia-plugin\">map plugin</a>." }
            },
            State{
                name: "GeocodeError"
                PropertyChanges { target: messageDialog; title: "Geocode Error" }
                PropertyChanges { target: messageDialog; text: "Unable to find location for the given point" }
            },
            State{
                name: "UnknownGeocodeError"
                PropertyChanges { target: messageDialog; title: "Geocode Error" }
                PropertyChanges { target: messageDialog; text: "Unsuccessful geocode" }
            },
            State{
                name: "AmbiguousGeocode"
                PropertyChanges { target: messageDialog; title: "Ambiguous geocode" }
                PropertyChanges { target: messageDialog; text: map.geocodeModel.count + " results found for the given address, please specify location" }
            },
            State{
                name: "RouteError"
                PropertyChanges { target: messageDialog; title: "Route Error" }
                PropertyChanges { target: messageDialog; text: "Unable to find a route for the given points"}
            },
            State{
                name: "LocationInfo"
                PropertyChanges { target: messageDialog; title: "Location" }
                PropertyChanges { target: messageDialog; text: geocodeMessage() }
            }
        ]
    }

//Route Dialog
    RouteDialog {
        id: routeDialog
        z: mainMenu.z + 1

        Coordinate { id: endCoordinate }
        Coordinate { id: startCoordinate }
        Address { id:startAddress }
        Address { id:endAddress }

        GeocodeModel {
            id: tempGeocodeModel
            plugin : map.plugin
            property int success: 0
            onStatusChanged:{
                if ((status == GeocodeModel.Ready) && (count == 1)) {
                    success++
                    if (success == 1){
                        startCoordinate.latitude = get(0).coordinate.latitude
                        startCoordinate.longitude = get(0).coordinate.longitude
                        clear()
                        query = endAddress
                        update();
                    }
                    if (success == 2)
                    {
                        endCoordinate.latitude = get(0).coordinate.latitude
                        endCoordinate.longitude = get(0).coordinate.longitude
                        success = 0
                        routeDialog.calculateRoute()
                    }
                }
                else if ((status == GeocodeModel.Ready) || (status == GeocodeModel.Error)){
                    var st = (success == 0 ) ? "start" : "end"
                    messageDialog.state = ""
                    if ((status == GeocodeModel.Ready) && (count == 0 )) messageDialog.state = "UnknownGeocodeError"
                    else if (status == GeocodeModel.Error) {
                        messageDialog.state = "GeocodeError"
                        messageDialog.text = "Unable to find location for the " + st + " point"
                    }
                    else if ((status == GeocodeModel.Ready) && (count > 1 )){
                        messageDialog.state = "AmbiguousGeocode"
                        messageDialog.text = count + " results found for the " + st + " point, please specify location"
                    }
                    console.log("    state = " + messageDialog.state)
                    success = 0
                    page.state = "Message"
                }
            }
        }

        onGoButtonClicked: {
            var status = true

            messageDialog.state = ""
            if (routeDialog.byCoordinates) {
                startCoordinate.latitude = routeDialog.startLatitude
                startCoordinate.longitude = routeDialog.startLongitude
                endCoordinate.latitude = routeDialog.endLatitude
                endCoordinate.longitude = routeDialog.endLongitude

                calculateRoute()
            }
            else {
                startAddress.country = routeDialog.startCountry
                startAddress.street = routeDialog.startStreet
                startAddress.city = routeDialog.startCity

                endAddress.country = routeDialog.endCountry
                endAddress.street = routeDialog.endStreet
                endAddress.city = routeDialog.endCity

                tempGeocodeModel.query = startAddress
                tempGeocodeModel.update();
            }
            page.state = ""
        }

        onCancelButtonClicked: {
            page.state = ""
        }

        function calculateRoute(){
            map.routeQuery.clearWaypoints();
            map.center = startCoordinate
            map.routeQuery.addWaypoint(startCoordinate)
            map.routeQuery.addWaypoint(endCoordinate)
            map.routeQuery.travelModes = routeDialog.travelMode
            map.routeQuery.routeOptimizations = routeDialog.routeOptimization
            map.routeModel.update();
        }
    }

//Search Dialog
    Dialog {
        id: searchDialog
        title: "Search"
        z: mainMenu.z + 1

        onGoButtonClicked: {
            page.state = ""
//            searchModel.searchString = dialogModel.get(0).inputText
//            searchModel.update();
        }
        Component.onCompleted: {
            var obj = [["Please enter thing to search:","53 Brandl St, Eight Mile Plains, Australia"]]
            setModel(obj)
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }

//Geocode Dialog
    Dialog {
        id: geocodeDialog
        title: "Geocode"
        z: mainMenu.z + 1

        Component.onCompleted: {
            var obj = [["Street", "Brandl St"],["District",""],["City", "Eight Mile Plains"], ["County", ""],["State", ""],["Country code",""],["Country","Australia"], ["Post code", ""]]
            setModel(obj)
        }

        Address {
            id: geocodeAddress
        }

        onGoButtonClicked: {
            page.state = ""
            messageDialog.state = ""
            geocodeAddress.street = dialogModel.get(0).inputText
            geocodeAddress.district = dialogModel.get(1).inputText
            geocodeAddress.city = dialogModel.get(2).inputText
            geocodeAddress.county = dialogModel.get(3).inputText
            geocodeAddress.state = dialogModel.get(4).inputText
            geocodeAddress.countryCode = dialogModel.get(5).inputText
            geocodeAddress.country = dialogModel.get(6).inputText
            geocodeAddress.postcode = dialogModel.get(7).inputText
            map.geocodeModel.clear()
            map.geocodeModel.query = geocodeAddress
            map.geocodeModel.update();
        }
        onCancelButtonClicked: {
            page.state = ""
        }
    }

//Reverse Geocode Dialog
    Dialog {
        id: reverseGeocodeDialog
        title: "Reverse Geocode"
        z: mainMenu.z + 1

        Component.onCompleted: {
            var obj = [["Latitude","-27.575"],["Longitude", "153.088"]]
            setModel(obj)
        }

        Coordinate {
            id: reverseGeocodeCoordinate
        }

        onGoButtonClicked: {
            page.state = ""
            messageDialog.state = ""

            reverseGeocodeCoordinate.latitude = dialogModel.get(0).inputText
            reverseGeocodeCoordinate.longitude = dialogModel.get(1).inputText
            map.geocodeModel.clear()
            map.geocodeModel.query = reverseGeocodeCoordinate
            map.geocodeModel.update();
        }

        onCancelButtonClicked: {
            page.state = ""
        }
    }

//Get new coordinates for marker
    Dialog {
        id: coordinatesDialog
        title: "New coordinates"
        z: mainMenu.z + 1

        Component.onCompleted: {
            var obj = [["Latitude", ""],["Longitude", ""]]
            setModel(obj)
        }

        onGoButtonClicked: {
            page.state = ""
            messageDialog.state = ""
            map.currentMarker.coordinate.latitude = dialogModel.get(0).inputText
            map.currentMarker.coordinate.longitude = dialogModel.get(1).inputText
            map.center = map.currentMarker.coordinate
        }

        onCancelButtonClicked: {
            page.state = ""
       }
    }

    GeocodeModel {
        id: geocodeModel
        plugin : Plugin { name : "nokia"}
        onLocationsChanged: {
            if (geocodeModel.count > 0) {
                console.log('setting the coordinate as locations changed in model.')
                map.center = geocodeModel.get(0).coordinate
            }
        }
    }


//=====================Map=====================
    MapComponent{
        id: map
        z : backgroundRect.z + 1
        size.width: parent.width
        size.height: parent.height - mainMenu.height

        onMousePressed: {
            page.state = ""
        }

        MapObjectView {
            model: geocodeModel
            delegate: Component {
                MapCircle {
                    radius: 10000
                    color: "red"
                    center: location.coordinate
                }
            }
        }

        onSliderUpdated: {
            page.state = ""
        }

        onCoordinatesCaptured: {
            messageDialog.title = "Coordinates"
            messageDialog.text = "<b>Latitude:</b> " + roundNumber(latitude,4) + "<br/><b>Longitude:</b> " + roundNumber(longitude,4);
            page.state = "Message"
        }

        onShowRouteInfo: {
            var value = map.routeModel.get(0).travelTime
            var seconds = value % 60
            value /= 60
            value = Math.round(value)
            var minutes = value % 60
            value /= 60
            value = Math.round(value)
            var hours = value
            var dist = roundNumber(map.routeModel.get(0).distance,0)

            if (dist>1000) dist = dist/1000 + " km"
            else dist = dist + " m"

            messageDialog.title = "Route info"
            messageDialog.text = "<b>Travel time:</b> " + hours + "h:"+ minutes + "m<br/><b>Distance:</b> " + dist;

            page.state = "Message"
        }

        onGeocodeFinished:{
            var street, district, city, county, state, countryCode, country, latitude, longitude, text

            if (map.geocodeModel.status == GeocodeModel.Ready){
                if (map.geocodeModel.count == 0) messageDialog.state = "UnknownGeocodeError"
                else if (map.geocodeModel.count > 1) messageDialog.state = "AmbiguousGeocode"
                else messageDialog.state = "LocationInfo";
            }
            else if (map.geocodeModel.status == GeocodeModel.Error) messageDialog.state = "GeocodeError"
            page.state = "Message"
        }

        onShowGeocodeInfo:{
            messageDialog.state = "LocationInfo"
            page.state = "Message"
        }

        onMoveMarker: {
            page.state = "Coordinates"
        }

        onRouteError: {
            messageDialog.state = "RouteError"
            page.state = "Message"
        }
    }

    function geocodeMessage(){
        var street, district, city, county, state, countryCode, country, postcode, latitude, longitude, text
        latitude = map.geocodeModel.get(0).coordinate.latitude
        longitude = map.geocodeModel.get(0).coordinate.longitude
        street = map.geocodeModel.get(0).address.street
        district = map.geocodeModel.get(0).address.district
        city = map.geocodeModel.get(0).address.city
        county = map.geocodeModel.get(0).address.county
        state = map.geocodeModel.get(0).address.state
        countryCode = map.geocodeModel.get(0).address.countryCode
        country = map.geocodeModel.get(0).address.country
        postcode = map.geocodeModel.get(0).address.postcode

        text = "<b>Latitude:</b> " + latitude + "<br/>"
        text +="<b>Longitude:</b> " + longitude + "<br/>" + "<br/>"
        if (street) text +="<b>Street: </b>"+ street + " <br/>"
        if (district) text +="<b>District: </b>"+ district +" <br/>"
        if (city) text +="<b>City: </b>"+ city + " <br/>"
        if (county) text +="<b>County: </b>"+ county + " <br/>"
        if (state) text +="<b>State: </b>"+ state + " <br/>"
        if (countryCode) text +="<b>Country code: </b>"+ countryCode + " <br/>"
        if (country) text +="<b>Country: </b>"+ country + " <br/>"
        if (postcode) text +="<b>Postcode: </b>"+ postcode + " <br/>"
        return text
    }


    function roundNumber(number, digits) {
            var multiple = Math.pow(10, digits);
            var rndedNum = Math.round(number * multiple) / multiple;
            return rndedNum;
    }

//=====================States of page=====================
    states: [
       State {
            name: ""
            PropertyChanges { target: map; focus: true }
        },
        State {
            name: "RevGeocode"
            PropertyChanges { target: reverseGeocodeDialog; opacity: 1 }
        },
        State {
            name: "Route"
            PropertyChanges { target: routeDialog; opacity: 1 }
        },
        State {
            name: "Search"
            PropertyChanges { target: searchDialog; opacity: 1 }
        },
        State {
            name: "Geocode"
            PropertyChanges { target: geocodeDialog; opacity: 1 }
        },
        State {
            name: "Coordinates"
            PropertyChanges { target: coordinatesDialog; opacity: 1 }
        },
        State {
            name: "Message"
            PropertyChanges { target: messageDialog; opacity: 1 }
        },
        State {
            name : "Options"
            PropertyChanges { target: optionsMenu; y: page.height - optionsMenu.height - mainMenu.height }
        },
        State {
            name : "Settings"
            PropertyChanges { target: settingsMenu; y: page.height - settingsMenu.height - mainMenu.height }
        },
        State {
            name : "MapType"
            PropertyChanges { target: mapTypeMenu; opacity: 1}
            PropertyChanges { target: settingsMenu; y: page.height - settingsMenu.height - mainMenu.height }
        },
        State {
            name : "Connectivity"
            PropertyChanges { target: connectivityModeMenu; opacity: 1}
            PropertyChanges { target: settingsMenu; y: page.height - settingsMenu.height - mainMenu.height }
        }
    ]

//=====================State-transition animations for page=====================
    transitions: [
        Transition {
            to: "RevGeocode"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Route"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Search"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Geocode"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Coordinates"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Message"
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: ""
            NumberAnimation { properties: "opacity" ; duration: 500; easing.type: Easing.Linear }
        },
        Transition {
            to: "Settings"
            NumberAnimation { properties: "y" ; duration: 300; easing.type: Easing.Linear }
        },
        Transition {
            to: "Options"
            NumberAnimation { properties: "y" ; duration: 300; easing.type: Easing.Linear }
        }
    ]
}
