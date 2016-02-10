function zoomChart(my_chart) {
	my_chart.zoomToIndexes(my_chart.dataProvider.length - 40,
			my_chart.dataProvider.length - 1);
}



var usersPerDayChart = AmCharts.makeChart("usersperday", {
	"type" : "serial",
	"theme" : "light",
	"marginRight" : 40,
	"marginLeft" : 40,
	"autoMarginOffset" : 20,
	"dataDateFormat" : "YYYY-MM-DD",
	"valueAxes" : [ {
		"id" : "v1",
		"axisAlpha" : 0,
		"position" : "left",
		"ignoreAxisWidth" : true
	} ],
	"balloon" : {
		"borderThickness" : 1,
		"shadowAlpha" : 0
	},
	"graphs" : [ {
		"id" : "g1",
		"balloon" : {
			"drop" : true,
			"adjustBorderColor" : false,
			"color" : "#ffffff"
		},
		"bullet" : "round",
		"bulletBorderAlpha" : 1,
		"bulletColor" : "#FFFFFF",
		"bulletSize" : 5,
		"hideBulletsCount" : 50,
		"lineThickness" : 2,
		"title" : "red line",
		"useLineColorForBulletBorder" : true,
		"valueField" : "value",
		"balloonText" : "<span style='font-size:18px;'>[[value]]</span>"
	} ],
	"chartScrollbar" : {
		"graph" : "g1",
		"oppositeAxis" : false,
		"offset" : 30,
		"scrollbarHeight" : 80,
		"backgroundAlpha" : 0,
		"selectedBackgroundAlpha" : 0.1,
		"selectedBackgroundColor" : "#888888",
		"graphFillAlpha" : 0,
		"graphLineAlpha" : 0.5,
		"selectedGraphFillAlpha" : 0,
		"selectedGraphLineAlpha" : 1,
		"autoGridCount" : true,
		"color" : "#AAAAAA"
	},
	"chartCursor" : {
		"pan" : true,
		"valueLineEnabled" : true,
		"valueLineBalloonEnabled" : true,
		"cursorAlpha" : 1,
		"cursorColor" : "#258cbb",
		"limitToGraph" : "g1",
		"valueLineAlpha" : 0.2
	},
	"valueScrollbar" : {
		"oppositeAxis" : false,
		"offset" : 50,
		"scrollbarHeight" : 10
	},
	"categoryField" : "date",
	"categoryAxis" : {
		"parseDates" : true,
		"dashLength" : 1,
		"minorGridEnabled" : true
	},
	"export" : {
		"enabled" : true
	},
	"dataProvider" : [ {
		"date" : "2012-07-27",
		"value" : 13
	}, {
		"date" : "2013-01-18",
		"value" : 78
	}, {
		"date" : "2013-01-19",
		"value" : 85
	}, {
		"date" : "2013-01-20",
		"value" : 82
	}, {
		"date" : "2013-01-21",
		"value" : 83
	}, {
		"date" : "2013-01-22",
		"value" : 88
	}, {
		"date" : "2013-01-23",
		"value" : 85
	}, {
		"date" : "2013-01-24",
		"value" : 85
	}, {
		"date" : "2013-01-25",
		"value" : 80
	}, {
		"date" : "2013-01-26",
		"value" : 87
	}, {
		"date" : "2013-01-27",
		"value" : 84
	}, {
		"date" : "2013-01-28",
		"value" : 83
	}, {
		"date" : "2013-01-29",
		"value" : 84
	}, {
		"date" : "2013-01-30",
		"value" : 81
	} ]
});

//usersPerDayChart.addListener("rendered", zoomChart);
//zoomChart(usersPerDayChart);

var videosPerDayChart = AmCharts.makeChart("videosperday", {
	"type" : "serial",
	"theme" : "light",
	"marginRight" : 40,
	"marginLeft" : 40,
	"autoMarginOffset" : 20,
	"dataDateFormat" : "YYYY-MM-DD",
	"dataLoader": {
	    "url": "get_videos_per_day",
	    "format": "json"
	 },
	"valueAxes" : [ {
		"id" : "v1",
		"axisAlpha" : 0,
		"position" : "left",
		"ignoreAxisWidth" : true
	} ],
	"balloon" : {
		"borderThickness" : 1,
		"shadowAlpha" : 0
	},
	"graphs" : [ {
		"id" : "g1",
		"balloon" : {
			"drop" : true,
			"adjustBorderColor" : false,
			"color" : "#ffffff"
		},
		"bullet" : "round",
		"bulletBorderAlpha" : 1,
		"bulletColor" : "#FFFFFF",
		"bulletSize" : 5,
		"hideBulletsCount" : 50,
		"lineThickness" : 2,
		"title" : "videos per day",
		"useLineColorForBulletBorder" : true,
		"valueField" : "count",
		"balloonText" : "<span style='font-size:18px;'>[[value]]</span>"
	} ],
	"chartScrollbar" : {
		"graph" : "g1",
		"oppositeAxis" : false,
		"offset" : 30,
		"scrollbarHeight" : 80,
		"backgroundAlpha" : 0,
		"selectedBackgroundAlpha" : 0.1,
		"selectedBackgroundColor" : "#888888",
		"graphFillAlpha" : 0,
		"graphLineAlpha" : 0.5,
		"selectedGraphFillAlpha" : 0,
		"selectedGraphLineAlpha" : 1,
		"autoGridCount" : true,
		"color" : "#AAAAAA"
	},
	"chartCursor" : {
		"pan" : true,
		"valueLineEnabled" : true,
		"valueLineBalloonEnabled" : true,
		"cursorAlpha" : 1,
		"cursorColor" : "#258cbb",
		"limitToGraph" : "g1",
		"valueLineAlpha" : 0.2
	},
	"valueScrollbar" : {
		"oppositeAxis" : false,
		"offset" : 50,
		"scrollbarHeight" : 10
	},
	"categoryField" : "day",
	"categoryAxis" : {
		"parseDates" : true,
		"dashLength" : 1,
		"minorGridEnabled" : true
	},
	"export" : {
		"enabled" : true
	}
});

//videosPerDayChart.addListener("rendered", zoomChart);
//zoomChart(videosPerDayChart);