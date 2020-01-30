$(document).ready(function () {
    const config1 = {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: "Temperature(Celsius)",
                backgroundColor: 'rgb(255, 99, 132)',
                borderColor: 'rgb(255, 99, 132)',
                data: [],
                fill: false,
            }, {
                label: "Temperature(Fahrenheit)",
                backgroundColor: 'rgb(255, 132, 99)',
                borderColor: 'rgb(255, 132, 99)',
                data: [],
                fill: false,
            }, {
                label: "Humidity %",
                backgroundColor: 'rgb(132, 99, 255)',
                borderColor: 'rgb(132, 99, 255)',
                data: [],
                fill: false,
            }],
        },
        options: {
            responsive: true,
            title: {
                display: true,
                text: 'SHT31 Measurements'
            },
            tooltips: {
                mode: 'index',
                intersect: false,
            },
            hover: {
                mode: 'nearest',
                intersect: true
            },
            scales: {
                xAxes: [{
                    display: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Time'
                    }
                }],
                yAxes: [{
                    display: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Value'
                    }
                }]
            }
        }
    };

    const context1 = document.getElementById('canvas1').getContext('2d');
    const lineChart1 = new Chart(context1, config1);
    lineChart1.update();

    const source = new EventSource("/sensor-data");
    source.onmessage = function (event) {
        const data = JSON.parse(event.data);
        if (config1.data.labels.length === 20) {
            config1.data.labels.shift();
            config1.data.datasets[0].data.shift();
            config1.data.datasets[1].data.shift();
            config1.data.datasets[2].data.shift();
        }
        config1.data.labels.push(data.series[0].values[0][0]);
        config1.data.datasets[0].data.push(data.series[0].values[0][1]);
        config1.data.datasets[1].data.push(data.series[0].values[0][2]);
        config1.data.datasets[2].data.push(data.series[0].values[0][3]);
        lineChart1.update();
    }

    const config2 = {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: "Temperature(Celsius)",
                backgroundColor: 'rgb(255, 99, 132)',
                borderColor: 'rgb(255, 99, 132)',
                data: [],
                fill: false,
            }, {
                label: "Temperature(Fahrenheit)",
                backgroundColor: 'rgb(255, 132, 99)',
                borderColor: 'rgb(255, 132, 99)',
                data: [],
                fill: false,
            }, {
                label: "Humidity %",
                backgroundColor: 'rgb(132, 99, 255)',
                borderColor: 'rgb(132, 99, 255)',
                data: [],
                fill: false,
            }],
        },
        options: {
            responsive: true,
            title: {
                display: true,
                text: 'SHT31 Measurements'
            },
            tooltips: {
                mode: 'index',
                intersect: false,
            },
            hover: {
                mode: 'nearest',
                intersect: true
            },
            scales: {
                xAxes: [{
                    display: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Time'
                    }
                }],
                yAxes: [{
                    display: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Value'
                    }
                }]
            }
        }
    };

    const context2 = document.getElementById('canvas2').getContext('2d');
    lineChart2 = new Chart(context2, config2);
    lineChart2.update();

    $('form').on('submit', function (event) {
        var myurl = "";
        myurl = myurl.concat('/fromtime/', $('#fromInput').val(), '/totime/', $('#toInput').val());
        $.ajax({
            type: 'GET',
            url: myurl
        })
            .done(function (data) {
                config2.data.labels = []
                config2.data.datasets[0].data = []
                config2.data.datasets[1].data = []
                config2.data.datasets[2].data = []
                for (var i = 0; i < data.series[0].values.length; i++) {
                    config2.data.labels.push(data.series[0].values[i][0]);
                    config2.data.datasets[0].data.push(data.series[0].values[i][1]);
                    config2.data.datasets[1].data.push(data.series[0].values[i][2]);
                    config2.data.datasets[2].data.push(data.series[0].values[i][4]);
                }
                lineChart2.update();
            });
        event.preventDefault();
    });

});
