module.exports = function( grunt ) {

	grunt.loadNpmTasks( 'grunt-contrib-uglify' );
	grunt.loadNpmTasks( "grunt-contrib-less"   );
	grunt.loadNpmTasks( "grunt-contrib-cssmin" );
	grunt.loadNpmTasks( 'grunt-contrib-clean'  );
	grunt.loadNpmTasks( 'grunt-rev'            );
	grunt.loadNpmTasks( 'grunt-contrib-rename' );
	grunt.loadNpmTasks( 'grunt-contrib-copy'   );
	grunt.loadNpmTasks( "grunt-contrib-watch"  );

	grunt.registerTask( "default", [ "uglify", "less", "cssmin", "clean", "rev", "rename", "copy" ] );

	grunt.initConfig( {
		uglify: {
			options:{
				  sourceMap     : true
				, sourceMapName : function( dest ){
					var parts = dest.split( "/" );
					parts[ parts.length-1 ] = parts[ parts.length-1 ].replace( /\.js$/, ".map" );
					return parts.join( "/" );
				 }
			},
			specific:{
				files: [{
					expand  : true,
					cwd     : "js/specific/",
					src     : ["**/*.js", "!**/*.min.js" ],
					dest    : "js/specific/",
					ext     : ".min.js",
					rename  : function( dest, src ){
						var pathSplit = src.split( '/' );

						pathSplit[ pathSplit.length-1 ] = '_' + pathSplit[ pathSplit.length-2 ] + '.min.js';

						return dest + pathSplit.join( '/' );
					}
				}]
			}
		},

		less: {
			  options  : { }
			, specific : {
				files: [{
					  expand  : true
					, cwd     : "css/"
					, src     : ["specific/**/*.less"]
					, dest    : "css/"
					, ext     : ".less.css"
				}]
			}
		},

		cssmin: {
			specific: {
				  expand : true
				, cwd    : "css/"
				, src    : [ "specific/**/*.css", "!**/*.min.css" ]
				, ext    : ".min.css"
				, dest   : "css/"
				, rename : function( dest, src ){
					var pathSplit = src.split( '/' );

					pathSplit[ pathSplit.length-1 ] = '_' + pathSplit[ pathSplit.length-2 ] + '.min.css';
					return dest + pathSplit.join( '/' );
				}
			}
		},

		copy: {
			main: {
				files: [
					{ expand: true, src: ['css/lib/*' ], dest: '../static/assets' },
					{ expand: true, src: ['css/specific/**/*.min.css' ], dest: '../static/assets' },

					{ expand: true, src: ['js/**/*'], dest: '../static/assets', filter: 'isFile' },
					{ expand: true, src: ['img/**/*'], dest: '../static/assets', filter: 'isFile' },
					{ src: ['StickerBundle.cfc'], dest: '../static/assets/StickerBundle.cfc' }
				]
			}
		},

		rev: {
			options: {
				algorithm : 'md5',
				length    : 8
			},
			default: {
				src : [ '**/_*.min.{js,css}' ]
			}
		},

		clean: {
			options : {
				force: true
			},
			default : {
				  src    : ['**/_*.min.{js,css}', '../static/assets/**/_*.min.{js,css}']
				, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
			}
		},

		rename: {
			assets: {
				expand : true,
				cwd    : '',
				src    : [ '**/*._*.min.{js,css}' , '!extensions/**/_*.min.{js,css}' ],
				dest   : '',
				rename : function( dest, src ){
					var pathSplit = src.split( '/' );

					pathSplit[ pathSplit.length-1 ] = '_' + pathSplit[ pathSplit.length-1 ].replace( /\._/, '.' );

					return dest + pathSplit.join( '/' );
				}
			}
		},

		watch: {
			scripts: {
				  files : [ "css/**/*.less", "js/**/*.js", "!js/**/*.min.css" ]
				, tasks : [ "default" ]
			}
		}

	} );
};