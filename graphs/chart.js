window.plotCharts = function(resultDoc) {
/*const colorMappings = {
    "test_disperse_2",
    "test_disperse_4", 
    "test_disperse_opt_2", 
    "test_disperse_opt_4", 
    "test_replica_1", 
    "test_replica_2", 
    "test_replica_3", 
    "test_replica_4", 
    "test_replica_opt_1", 
    "test_replica_opt_2", 
    "test_replica_opt_3", 
    "test_replica_opt_4"
};*/

fetch(resultDoc).then((res) => res.json()).then((data) => {

const tests = data.reduce((res, t)=>{
    res[t.test] = res[t.test] || [];
    res[t.test].push(t);
    return res;
}, {});
const setups = data.reduce((res, t)=>{
    res[t.setup] = res[t.setup] || { setup: t.setup, tests: {} };
    res[t.setup].tests[t.test] = t;
    return res;
}, {});

let colorMappings = {};
Object.keys(setups).forEach((s,i)=> {
    let r, g, b;
    r = g = b = 90;
    if(i < 4) r = i%4*60;
    else if(i < 8) g = i%4*60;
    else b = i%4*60;
    colorMappings[s] = `rgb(${r},${g},${b})`
});

function createChart(elemId, title, dataMapper) {
    const data = Object.values(setups).map(s => {
	const val = dataMapper(s);
	return {
	    label: s.setup,
	    backgroundColor: colorMappings[s.setup],
	    data: val.values,
	    data_labels: val.labels
	};
    });
    const ctx = document.getElementById(elemId).getContext('2d');
    return new Chart(ctx, {
	type: 'bar',
	data: {
	    labels: data[0].data_labels,
	    datasets: data
	},
	options: {
	    responsive: false,
	    title: {
		display: true,
		text: title
	    },
	    legend: {
		display: true
	    },
	    scales: {
		yAxes: [{
		    type: 'linear'
		    //type: 'logarithmic'
		}]
	    }
	}
    });
}
function testNameDataMapper(tests, metric, factor) {
    factor = factor || 1;
    if(typeof metric === "string") metric = metric.split('.');
    function get(o, i) {
	i = i || 0;
	if(i>=metric.length)
	    return o;
	return get(o[metric[i]], i+1);
    }
    function jobDataMapper(test, job) {
	if(test.indexOf('read') >= 0) return get(job.read) / factor;
	if(test.indexOf('write') >= 0) return get(job.write) / factor;
	if(test.indexOf('RW') >= 0) return (get(job.read) + get(job.write)) / (2 * factor);
	console.log("Unkown test", test, job);
	return 0;
    }
    return function(setup) {
	return {
	    values: tests.map(t=>{
		return setup.tests[t].jobs.reduce((r,j)=>r+jobDataMapper(t, j), 0) / setup.tests[t].jobs.length
	    }),
	    labels: tests
	};
    }
}
function jobnameDataMapper(test, metric, factor) {
    factor = factor || 1;
    if(typeof metric === "string") metric = metric.split('.');
    function get(o, i) {
	i = i || 0;
	if(i>=metric.length)
	    return o;
	return get(o[metric[i]], i+1);
    }
    return function(setup) {
	console.log(setup);
	return {
	    values: setup.tests[test].jobs.map(j=>(get(j.read) + get(j.write)) / factor),
	    labels: setup.tests[test].jobs.map(j=>j.jobname)
	}
    }
}
createChart('seqChartBW', 'seq BW [mb/s]', testNameDataMapper(['fio-seq-read', 'fio-seq-write', 'fio-seq-RW'], "bw_mean", 1024));
createChart('randChartBW', 'rand BW [mb/s]', testNameDataMapper(['fio-rand-read', 'fio-rand-write', 'fio-rand-RW'], "bw_mean", 1024));
createChart('paraChartBW', 'parallel BW [mb/s]', jobnameDataMapper("parallel", "bw_mean", 1024));
createChart('seqChartIOPS', 'seq IOPS', testNameDataMapper(['fio-seq-read', 'fio-seq-write', 'fio-seq-RW'], "iops"));
createChart('randChartIOPS', 'rand IOPS', testNameDataMapper(['fio-rand-read', 'fio-rand-write', 'fio-rand-RW'], "iops"));
createChart('paraChartIOPS', 'parallel IOPS', jobnameDataMapper("parallel", "iops"));
createChart('seqChartLat', 'seq Latency [ms]', testNameDataMapper(['fio-seq-read', 'fio-seq-write', 'fio-seq-RW'], "lat.mean", 1000));
createChart('randChartLat', 'rand Latency [ms]', testNameDataMapper(['fio-rand-read', 'fio-rand-write', 'fio-rand-RW'], "lat.mean", 1000));
createChart('paraChartLat', 'parallel Latency [ms]', jobnameDataMapper("parallel", "lat.mean", 1000));

});
}
