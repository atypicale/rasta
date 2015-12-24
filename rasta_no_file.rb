#######################################################
###### ice risk analysis slider tool application ######
###### alex fadel 09/2015						 ######
###### 											 ######
###### 09142015									 ######
###### v0.9 									 ######
#######################################################
######todo:
###### rand data feature
###### file upload from browser
###### default stratifications
###### stratification recomendations
###### fix styling to align with ABC themes
###### pretty print / export to pdf
###### multiple scenarios
###### cloud-based
######
######
######

require 'rubygems'
require 'sinatra'
require 'csv'
require 'descriptive_statistics'

=begin
def extract_score
	p @input_file
		p @input_file
			p @input_file
				p @input_file
	if @input_file.nil?
			p @input_file
		@scores = Array.new
		x = Random.new()
		x.rand(0...1000).times do @scores << x.rand(0.00...55.00) end	
	else
		csv = CSV.read(@input_file,:headers=>true,:col_sep=>"\t")
		@scores = csv["ASRISK_SCORE_PROSPECTIVE_OVERALL"]
		@scores.collect! {|x| x.to_f }
	end

	@scores.sort!
	@count = @scores.count

	@freq = Hash[@scores.group_by {|n| n.to_i/2}.map {|k,vs| [(2*k..2*k+2),vs]}]
	@data = []; @freq.keys.each {|k| @data<<['"'+k.to_s+'"',@freq[k].count] };nil
end
=end
#set :show_exceptions, false

get '/' do
	@scores = Array.new
	x = Random.new()
	x.rand(0...1000).times do @scores << x.rand(0.00...55.00) end	 
	#@input_file = Dir.pwd+'/'+ARGV[0].to_s

	#p @input_file
	#csv = CSV.read(@input_file,:headers=>true,:col_sep=>"\t")
	#csv = CSV.read(@input_file,:headers=>true,:col_sep=>"|")
	#@scores = csv["ASRISK_SCORE_PROSPECTIVE_OVERALL"]
	#@scores.collect! {|x| x.to_f }

	@scores.sort!
	@count = @scores.count

	@freq = Hash[@scores.group_by {|n| n.to_i/2}.map {|k,vs| [(2*k..2*k+2),vs]}]
	@data = []; @freq.keys.each {|k| @data<<['"'+k.to_s+'"',@freq[k].count] };nil

	p 'mean: '+@scores.mean.to_s
	p 'median: '+@scores.median.to_s
	p 'mode: '+@scores.mode.to_s
	p 'variance: '+@scores.variance.to_s
	p 'st dev: '+@scores.standard_deviation.to_s
	p @count
	p @data.count
	erb:index
end

error do
  "hm, that's not right. did you provide an input file from shell? /// e.g:
  'ruby rasta.rb yourfilename.txt' and was the file in the same directory as rasta.rb?" 
end

__END__

@@index

<head>
<script src='jquery-2.1.4.min.js'></script>
<script src='nouislider.js'></script>
<script src='highcharts.js'></script>
<script src='chartkick.js'></script>
<script src='wNumb.js'></script>
<link href='styles.css' rel='stylesheet' >
<link href="nouislider.min.css" rel="stylesheet">
<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>
</head>
<body>
records: <span id="count"></span><br>
average: <span><%= @scores.mean.to_s %> </span><br>
median: <span><%= @scores.median.to_s %> </span><br>
mode: <span><%= @scores.mode.to_s %> </span><br>
standard_deviation: <span><%= @scores.standard_deviation.to_s %> </span><br>
variance: <span><%= @scores.variance.to_s %> </span>
<div id="slider-handles"></div> 
<br>
<div id="container">
<table>
	<tr>
		<td id="low">LOW</td>
		<td>0 - <span hidden id="noUi-handle-lower"></span><span id='modLower0'></span></td>
		<td><span id="lowPcnt"></span>%</td>
		<td><span id="lowCount"></span></td>
	</tr>
	<tr>
		<td id="mod">MOD</td>
		<td><span id="modLower"></span> - <span hidden id="noUi-handle-upper"></span><span id="modHigher0"></span></td>
		<td><span id="modPcnt"></span>%</td>
		<td><span id="modCount"></span></td>
	</tr>
	<tr>
		<td id="high" >HIGH</td>
		<td><span id="modHigher"></span> - <span id="maxVal"></span></td>
		<td><span id="highPcnt"></span>%</td>
		<td><span id="highCount"></span></td>
	</tr>
	</table>
	</div>
	<br>

	<br>
	<div id="users-chart"></div>
</body>
<script>
	var data = <%= @scores %>

	function roundNearest(num, acc){
	    if ( acc < 0 ) {
	        return Math.round(num*acc)/acc;
	    } else {
	        return Math.round(num/acc)*acc;
	    }
	 }

	function closest(array,num){
	    var i=0;
	    var minDiff=1000;
	    var ans;
	    for(i in array){
	         var m=Math.abs(num-array[i]);
	         if(m<minDiff){ 
	                minDiff=m; 
	                ans=array[i]; 
	            }
	      }
	    return ans;
	}

	function count(array,num){
		var count = 0; data.forEach(function(val){ if(val == num){ count++ } })
	    return count;
	}
	 
	var nonLinearSlider = document.getElementById('slider-handles');

      
	noUiSlider.create(nonLinearSlider, {
		start: [ data[roundNearest(data.length*0.33,1)], data[roundNearest(data.length*0.66,1)] ],
		connect: true,
		step: 0.001,
		range: {
		'min': [  0 ],
		'33%': [  data[roundNearest(data.length*0.33,1)] ],
		'50%': [  data[roundNearest(data.length*0.50,1)] ],
		'66%': [  data[roundNearest(data.length*0.66,1)] ],
		'max': [ data[data.length - 1] ]
		}
	});


	var rangeValues = [
	document.getElementById('noUi-handle-lower'),
	document.getElementById('noUi-handle-upper')
	];

	nonLinearSlider.noUiSlider.on('update', function( values, handle ) {
	rangeValues[handle].innerHTML = values[handle];
	var low_raw = $('#noUi-handle-lower')[0].innerHTML
	var high_raw = $('#noUi-handle-upper')[0].innerHTML

	$('#maxVal')[0].innerHTML = data[data.length-1]
	$('#count')[0].innerHTML = data.length

	//$('#lowCnt')[0].innerHTML = count(data,closest(data,low_raw))
	//$('#lowVal')[0].innerHTML = closest(data,low_raw)

	$('#modLower0')[0].innerHTML = data[data.indexOf(closest(data,low_raw)) ]
	$('#lowPcnt')[0].innerHTML = roundNearest(data.indexOf(closest(data,low_raw))/data.length*100,-100)	
	if( count(data,closest(data,low_raw)) == 1) {
		$('#lowCount')[0].innerHTML = data.indexOf(closest(data,low_raw))
	} else {
		$('#lowCount')[0].innerHTML = data.indexOf(closest(data,low_raw)) + count(data,closest(data,low_raw)) - 1
	}

	//$('#modVal')[0].innerHTML = closest(data,high_raw)

	if( count(data,closest(data,high_raw)) == 1) {
		$('#modCount')[0].innerHTML = (data.indexOf(closest(data,high_raw)) - Number($('#lowCount')[0].innerHTML) )
	} else {
		$('#modCount')[0].innerHTML = (data.indexOf(closest(data,high_raw)) + count(data,closest(data,high_raw))) - Number($('#lowCount')[0].innerHTML) - 1
	}

	$('#modLower')[0].innerHTML = data[data.indexOf(closest(data,low_raw))+count(data,closest(data,low_raw)) ]
	//
	$('#modPcnt')[0].innerHTML = roundNearest((data.indexOf(closest(data,high_raw)) + count(data,closest(data,high_raw)))/data.length*100 - data.indexOf(closest(data,low_raw))/data.length*100,-100)

	$('#modHigher0')[0].innerHTML = closest(data,high_raw)
	if($('#modHigher')[0].innerHTML = data[data.indexOf(closest(data,high_raw)) + count(data,closest(data,high_raw))] == undefined ){
		$('#modHigher')[0].innerHTML = data[data.length-1]
	} else {
		$('#modHigher')[0].innerHTML = data[data.indexOf(closest(data,high_raw)) + count(data,closest(data,high_raw))]
	}
	$('#highCount')[0].innerHTML = data.length - Number($('#modCount')[0].innerHTML) - Number($('#lowCount')[0].innerHTML)
	$('#highPcnt')[0].innerHTML = roundNearest(100 - (data.indexOf(closest(data,high_raw)) + count(data,closest(data,high_raw)))/data.length*100,-100)

	})
new Chartkick.ColumnChart("users-chart", [{
        "name": "Count of Scores",
        "data": <%= @data %>	
    }], {
        "library": {
            "pointSize": 0,
            "chartArea": {
                "width": "95%",
                "left": 0,
                "top": 0
            },
            "legend": {
                "position": "bottom"
            },
            "hAxis": {
                "textPosition": "out"
            },
            "vAxes": {
                "0": {
                    "gridlines": {
                        "count": 0
                    },
                    "textPosition": "none",
                    "viewWindowMode": "pretty"
                },
                "1": {
                    "gridlines": {
                        "count": 0
                    },
                    "textPosition": "none",
                    "viewWindowMode": "pretty"
                }
            },
            "series": {
                "0": {
                    "color": "#DC3912"
                },
                "1": {
                    "color": "#3366CC",
                    "targetAxisIndex": 1
                }
            }
        }
    });
</script>
