/*
    Copyright (C) 2015 Nile Group
    http://nilegroup.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    id: page
    width: 100
    height: 62
    color: "#dddddd"

    property alias count: list.count

    ListObject {
        id: list
        onCountChanged: {
            if( count <= 1 ) {
                BackHandler.removeHandler(page)
                materialDesignButton.show()
            } else
            if( count == 2 ) {
                BackHandler.pushHandler(page, page.back)
            }
        }
    }

    Connections {
        target: Database
        onInitializeFinished: {
            var item = category_component.createObject(base_frame, {"catId": 0, "startY": 0, "startHeight": base_frame.height})
            item.startInit = true
            list.append(item)
        }
    }

    Rectangle {
        id: title_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Devices.standardTitleBarHeight + View.statusBarHeight
        color: "#881010"
    }

    Item {
        id: base_frame
        anchors.top: title_bar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Component {
        id: category_component

        CategoryPageItem {
            categoryComponent: category_component
            poemsComponent: poems_component
            baseFrame: base_frame
            hafezOmenComponent: hafez_omen_component
        }
    }

    Component {
        id: hafez_omen_component
        HafezOmen {
            id: homen
            width: parent.width
            height: parent.height
            x: inited? 0 : -width

            property bool inited: false
            property bool outside: false

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Timer {
                id: destroy_timer
                interval: 400
                onTriggered: homen.destroy()
            }

            function end() {
                inited = false
                destroy_timer.restart()
            }
        }
    }

    Component {
        id: poems_component

        PoemsPage {
            id: ppage
            width: parent.width
            height: parent.height
            x: inited? 0 : -width

            property bool inited: false
            property bool outside: false

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Timer {
                id: destroy_timer
                interval: 400
                onTriggered: ppage.destroy()
            }

            function end() {
                inited = false
                destroy_timer.restart()
            }
        }
    }

    Component {
        id: poemview_component

        PoemView {
            id: pview
            width: parent.width
            height: parent.height
            x: inited? 0 : -width
            rememberBar: true

            property bool inited: false
            property bool outside: false

            Behavior on x {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Timer {
                id: destroy_timer
                interval: 400
                onTriggered: pview.destroy()
            }

            function end() {
                inited = false
                destroy_timer.restart()
            }
        }
    }

    function back() {
        if( list.count == 1 )
            return

        var item = list.takeLast()
        item.end()
        if( list.count != 0 )
            list.last().outside = false

        main.focus = true
        if( list.count == 1 )
            BackHandler.removeHandler(page)
        else
            return false
    }

    function showHafezOmen() {
        var item = hafez_omen_component.createObject( base_frame, {"catId": 10001} )
        item.inited = true

        if( list.count != 0 )
            list.last().outside = true

        list.append(item)
        materialDesignButton.hide()
    }

    function showRandom() {
        var poets = Database.poets()
        var poet_id_rnd = Math.floor(Math.random()*poets.length)
        if(poet_id_rnd == poets.length)
            poet_id_rnd--

        var poet = poets[poet_id_rnd]

        var cats = Database.childsOf(poet)
        var poem = -1
        while(cats.length != 0)
        {
            var cat_id_rnd = Math.floor(Math.random()*cats.length)
            if(cat_id_rnd == cats.length)
                cat_id_rnd--

            var cat = cats[cat_id_rnd]
            var poems = Database.catPoems(cat)
            if(poems.length != 0)
            {
                var poem_id_rnd = Math.floor(Math.random()*poems.length)
                if(poem_id_rnd == poems.length)
                    poem_id_rnd--

                poem = poems[poem_id_rnd]
                break;
            }

            cats = Database.childsOf(cat)
        }

        if(poem == -1 || !poem)
            return false

        var item = poemview_component.createObject( base_frame, {"poemId": poem} )
        item.inited = true

        if( list.count != 0 )
            list.last().outside = true

        list.append(item)
        materialDesignButton.hide()
        return true
    }
}
