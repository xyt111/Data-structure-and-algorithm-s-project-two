<#assign baseUrl=request.getContextPath()>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
    <style type="text/css">
        body, html, #allmap {
            width: 100%;
            height: 100%;
            overflow: hidden;
            margin: 0;
            font-family: "微软雅黑";
        }
    </style>
    <script type="text/javascript"
            src="http://api.map.baidu.com/api?v=2.0&ak=EuQZy4q2kFskzCIImsMvnvwtHkkyEzAd"></script>
    <title>地图展示</title>
</head>
<body style="height:100%;width: 100%;font-size:0px;background-image: url('https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1545836931&di=ecf67ed9e965f5f72cb1a21728b97892&imgtype=jpg&er=1&src=http%3A%2F%2Fdl.ppt123.net%2Fpptbj%2F51%2F20181115%2Fuqswv0kzdtq.jpg');">
<input id="hiddenBaseUrl" type="hidden" value="${baseUrl}"/>
<div style="width:80%;display: inline-block;" id="allmap"></div>
<div style="width:20%; height:100%;display:inline-block; ">
    <form style="position:absolute;font-size:16px;top:5%;background-color: rgba(228,216,255,0.23);border: none;width: 250px;border-radius: 10px;padding-bottom: 20px;padding-top: 20px;margin-left: 8px" id="submitForm">
        &nbsp;&nbsp;&nbsp;起点: <input type="text" name="startAddress" id="startAddress" value="复旦大学张江校区"/>
        <input type="hidden" id="hiddenStartLongitude" value="121.604569"/>
        <input type="hidden" id="hiddenStartLatitude" value="31.196348"/>
        <br/><br/>
        &nbsp;&nbsp;&nbsp;终点: <input type="text" name="endAddress" id="endAddress" value="人民广场"/>
        <input type="hidden" id="hiddenEndLongitude" value="121.478941"/>
        <input type="hidden" id="hiddenEndLatitude" value="31.236009"/>
        <br/><br/>
        &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="1"/>步行最少<br/>
        &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="2"/>换乘最少<br/>
        &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="3"/>时间最短<br/><br/>
        <input style="position:relative;left:40%;width:100px;height:40px;border:none;font-size: 16px;border-radius: 7px;color: black;background-color: #d7c8ff;cursor: pointer" type="button" value="查询"
               onclick="clickButton()">
    </form>
    <br/>
    <div style="position:absolute;top:40%;width: 20%;height: 60%;margin-left: 8px">
        <span style="font-size:18px;position:relative;">display the result:</span><br/>
        <textarea id="resultDiv"
             style="background-color:rgba(245, 245, 245, 0.44);width: 90%;height:90%;font-size:18px;word-wrap: break-word;border-radius: 10px">

        </textarea>
    </div>
</div>
</body>
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
<script type="text/javascript">
    // 百度地图API功能
    var map = new BMap.Map("allmap");    // 创建Map实例
    map.centerAndZoom("上海", 16);  // 初始化地图,设置中心点坐标和地图级别
    map.enableScrollWheelZoom(true);     //开启鼠标滚轮缩放
    var geocoder = new BMap.Geocoder();
    map.addEventListener("rightclick", function (e) {
        RightClickMap(e.point);
    });

    function RightClickMap(point) {
        var EventStartMarker = function (map) {
            //addEventF是具体的菜单方法，要实现什么功能取决自身需求
            geocoder.getLocation(point, function (rs) {
                //addressComponents对象可以获取到详细的地址信息
                var addComp = rs.addressComponents;
                var site = addComp.district + ", " + addComp.street + ", " + addComp.streetNumber;
                //将对应的HTML元素设置值
                $("#startAddress").val(site);
                $("#hiddenStartLongitude").val(point.lng);
                $("#hiddenStartLatitude").val(point.lat);
            });
        };
        var EventEndMarker = function (map) {
            //addEventF是具体的菜单方法，要实现什么功能取决自身需求
            geocoder.getLocation(point, function (rs) {
                //addressComponents对象可以获取到详细的地址信息
                var addComp = rs.addressComponents;
                var site = addComp.district + ", " + addComp.street + ", " + addComp.streetNumber;
                //将对应的HTML元素设置值
                $("#endAddress").val(site);
                $("#hiddenEndLongitude").val(point.lng);
                $("#hiddenEndLatitude").val(point.lat);
            });
        };
        var markerMenu = new BMap.ContextMenu();
        markerMenu.addItem(new BMap.MenuItem('设为起点', EventStartMarker.bind(map)));
        map.addContextMenu(markerMenu);

        var markerMenuEnd = new BMap.ContextMenu();
        markerMenu.addItem(new BMap.MenuItem('设为终点', EventEndMarker.bind(map)));
        map.addContextMenu(markerMenuEnd);
    }

    //提交按钮的点击事件
    function clickButton() {
        //请在这里检查数据

        var baseUrl = $("#hiddenBaseUrl").val();
        $.ajax({
            url: baseUrl + "/submitsearch",
            type: 'POST',
            data:
                JSON.stringify({
                    "startAddress": $("#startAddress").val(),
                    "startLongitude": $("#hiddenStartLongitude").val(),
                    "startLatitude": $("#hiddenStartLatitude").val(),
                    "endAddress": $("#endAddress").val(),
                    "endLongitude": $("#hiddenEndLongitude").val(),
                    "endLatitude": $("#hiddenEndLatitude").val(),
                    "choose": $('input[name=items]:checked', '#submitForm').val()
                }),
            dataType: 'JSON',
            contentType: "application/json; charset=UTF-8",
            success: function (data) {
                map.clearOverlays();
                let len = data.subwayList.length;
                let placeStart = new BMap.Point(data.startPoint.longitude, data.startPoint.latitude);
                let placeEnd = new BMap.Point(data.endPoint.longitude, data.endPoint.latitude);
                let arrayList = [];
                arrayList.push(placeStart);
                for (let i = 0; i < len; ++i) {
                    let p = new BMap.Point(data.subwayList[i].longitude, data.subwayList[i].latitude);
                    arrayList.push(p);
                    drawPoint(p, data.subwayList[i].address);
                }
                arrayList.push(placeEnd);

                let polylineRoute = new BMap.Polyline(arrayList);
                map.addOverlay(polylineRoute);
                map.setViewport(arrayList);

                drawPoint(placeStart, data.startPoint.address);
                drawPoint(placeEnd, data.endPoint.address);

                let str = data.startPoint.address;
                for (let i = 0; i < len; ++i)
                    str += "&nbsp;&nbsp;->&nbsp;&nbsp;" + data.subwayList[i].address;
                str += "&nbsp;&nbsp;->&nbsp;&nbsp;" + data.endPoint.address + "\n";
                str += "花费时间为:&nbsp;&nbsp; " + data.minutes + "&nbsp;分钟" + "\n";
                str += "步行距离为:&nbsp;&nbsp; " + data.walkDistance + "&nbsp;km";
                $("#resultDiv").html(str);
            },
            error: function (data) {
                alert("很抱歉,服务器出错!");
            }
        });
    }

    // 绘制marker（起点、经点、终点），添加文本标注
    function drawPoint(point, content) {
        let marker = new BMap.Marker(point);
        this.map.addOverlay(marker);
        var label = new BMap.Label(content, {
            offset: new BMap.Size(20, -10)
        });
        marker.setLabel(label);
    }
</script>
</html>