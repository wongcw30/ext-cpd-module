( function( $ ) {

	$( document ).ready( function() {

		var $resultEndpoint       = cfrequest.resultEndpoint
		, $chartEndpoint          = cfrequest.chartEndpoint
		, $resultsContainer       = $( cfrequest.resultsContainer )
		, $body                   = $( "body" )
		, $downloadReportId       = $( "#download-report-link" )
		, $CPDDateRange           = $( "#cpd_date_range" )
		, $CPDDateTo              = $( "input[name='cpd_date_to']" )
		, $CPDDateFrom            = $( "input[name='cpd_date_from']" )
		, $downloadReportEndpoint = cfrequest.downloadReportEndpoint
		, $chartContainer         = $( cfrequest.chartContainer )
		, fetchResult
		, getFilter
		, cpdCalendar
		, updateChart
		, loader            = $( '.resource-loader' );

		// setupCalendar = function( selectedDate ){

		// 	cpdCalendar = new dhx.Calendar("cpdcalendar", {
		// 		  range: true
		// 		, dateFormat:"%Y-%m-%d"
		// 		, value: ( selectedDate || [] )
		// 	});

		// 	cpdCalendar.events.on("Change",function(date, oldDate, click){
		// 		fetchResult();
		// 	});
		// }

		// setupCalendar(cfrequest.urlSelectedDate);

		updateURL = function( filterDataSet ){
			var url               = [ location.protocol, '//', location.host, location.pathname ].join( '' );
			var downloadReportUrl = $downloadReportEndpoint;
			var firstFilter       = true;

			for ( var filterData in filterDataSet ) {
				if ( filterDataSet[filterData].length ) {
					if ( firstFilter ) {
						url += "?";
						downloadReportUrl += "?";
						firstFilter = false;
					} else {
						url += "&";
						downloadReportUrl += "&";
					}

					url += filterData + "=" + filterDataSet[filterData];
					downloadReportUrl += filterData + "=" + filterDataSet[filterData];
				}
			}

			$downloadReportId.attr( "href", downloadReportUrl );

			window.history.pushState( { path: url },'', url );
		};

		getFilter = function(){
			var filter          = {};
			var checkboxFilters = {};

			$( '.filter-checkbox:checked' ).each( function() {
				var inputName = $(this).attr('name');
				if( typeof checkboxFilters[inputName] === "undefined" ){
					checkboxFilters[inputName]= [];
				}
				checkboxFilters[inputName].push( $(this).val() );
			});

			for( var checkboxFilter in checkboxFilters ) {
				filter[checkboxFilter] = checkboxFilters[checkboxFilter].toString();
			}

			filter.maxRows = cfrequest.maxRows;

			$( ".related-filter-field" ).each( function() {
				if( $(this).length ){
					var inputName = $(this).attr('name');
					filter[inputName] = $(this).val();
				}
			});

			if( $CPDDateTo.length ){
				filter['cpd_date_to'] = $CPDDateTo.val();
			}

			if( $CPDDateFrom.length ){
				filter['cpd_date_from'] = $CPDDateFrom.val();
			}

			// var calendarValue = cpdCalendar.getValue();
			// if( calendarValue.length ){
			// 	filter['date'] = cpdCalendar.getValue().join(",");
			// }

			updateURL( filter );

			filter.pageId  = cfrequest.pageId;

			return filter;
		};

		fetchResult = function(){
			loading( true );
			//var selectedDate = cpdCalendar.getValue();
			var filterValue  = getFilter();
			console.log(filterValue);
			$.ajax( $resultEndpoint, {
				  method  : "POST"
				, cache   : false
				, data    : filterValue
			} ).done( function( response ) {
				$resultsContainer.html( response );
				PIXL8.collapsible( $resultsContainer );

				//setupCalendar( selectedDate );
				updateChart( filterValue );

				//for manual load more
				if( $resultsContainer.find( '.load-more-link' ).length ){
					$( "a.load-more-link" ).loadMore();
				}
			}).fail(function() {
				alert('Connection failed, please try again later');
				return false;
			}).complete( function(){
				loading( false );
			} );

		};

		updateChart = function( filterValue ){
			$.ajax( $chartEndpoint, {
				  method  : "POST"
				, cache   : false
				, data    : filterValue
			} ).done( function( response ) {
				$chartContainer.html( response );
				PIXL8.cpdChart();
			}).fail(function() {
				alert('Connection failed, please try again later');
				return false;
			});
		}

		$body.on( "change", ".related-filter-field,.filter-checkbox", function( e ){
			if( $(this).attr('name') == "cpd_date" ){
				$CPDDateRange.prop( "checked", false ).trigger('change');
				resetDateRange();
			}
			e.preventDefault();
			fetchResult();

		});

		$CPDDateRange.on("change", function( e ){
			if( !$(this).prop('checked') ){
				resetDateRange();
				e.preventDefault();
				fetchResult();
			} else {
				$('input[name="cpd_date"]').prop( "checked", false );
			}
		});

		$body.on( "dp.change", ".date-filter", function( e ){
			$CPDDateTo.closest('.form-field').find('.alert').remove();

			if( $CPDDateTo.val() !='' && $CPDDateFrom.val() !='' ){
				var startDate = new Date( $CPDDateFrom.val() );
				var endDate   = new Date( $CPDDateTo.val() );
				if( startDate > endDate ){
					$CPDDateTo.closest('.form-field').append( $(document.createElement('div')).text('Invalid date').addClass('alert alert-message alert-danger error') )
				}
			}
			e.preventDefault();
			fetchResult();
		});


		$body.on( "click", ".tag-close-btn", function( e ){
			e.preventDefault();

			var $thisOjbect = $( this );
			$( "[name='" + $thisOjbect.data( "name" ) + "'][value='" + $thisOjbect.data( "value" ) + "']" ).prop( "checked", false );
			fetchResult();
		});

		$body.on( "click", ".tag-close-btn-date", function( e ){
			e.preventDefault();
			//setupCalendar();
			fetchResult();
		});

		function resetDateRange() {
			$CPDDateTo.val('');
			$CPDDateFrom.val('');
			$('#cpd_date_from').val('');
			$('#cpd_date_to').val('');
			$CPDDateTo.closest('.form-field').find('.alert').remove();
		}

		function loading( isLoading ){
			if ( isLoading ) {
				loader.removeClass( 'hide' );
			} else {
				loader.addClass( 'hide' );
			}
		}

	} );

} )( jQuery );